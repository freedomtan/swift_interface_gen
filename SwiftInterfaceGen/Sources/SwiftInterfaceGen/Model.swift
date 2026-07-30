import Foundation

struct Symbol {
    let mangled: String
    let demangled: String
}

enum MemberKind {
    case initializer(String)
    case property(name: String, type: String, isReadOnly: Bool, isStatic: Bool)
    case method(name: String, signature: String, isStatic: Bool)
    case enumCase(name: String, payload: String?, hasLabel: Bool)
    case associatedType(String)
    case other(String)
}

class TypeNode {
    let name: String
    var kind: String = "unknown"
    var members: [String: MemberKind] = [:]
    var extensionMembers: [String: MemberKind] = [:]
    var constrainedExtensions: [String: [String: MemberKind]] = [:]
    var nestedTypes: [String: TypeNode] = [:]
    var conformances: Set<String> = []
    var isGeneric: Bool = false
    var baseClass: String?
    var rawType: String?
    var finalMembers: Set<String> = []
    var isObjcBridged: Bool = false  // true when this is an ObjC class extended in Swift (So-prefix symbols)
    var hasDeinit: Bool = false  // true when the ABI has a "...deinit" (VfD/Cfd) symbol for this type
    weak var parent: TypeNode? = nil
    // Names of protocol requirements this type is KNOWN to implement via a "protocol witness
    // for ... in conformance" ABI thunk, even though that thunk's demangled text isn't itself
    // parsed as a member (it carries the REQUIREMENT's own signature, using the protocol's own
    // generic placeholder like bare "A", which is meaningless on a non-generic conforming type).
    // Populated so inheritProtocolMembers (Parser.swift) doesn't think the requirement is
    // missing and copy the protocol's raw (unresolvable) signature onto this type.
    var satisfiedRequirementNames: Set<String> = []

    private func isLifetimeSpanType(_ type: String) -> Bool {
        let clean = type.replacingOccurrences(of: "Optional<", with: "")
                        .replacingOccurrences(of: ">", with: "")
                        .trimmingCharacters(in: .whitespaces)
        return clean.contains("Span<") || clean == "RawSpan" || clean == "MutableRawSpan" || clean.contains("MutableSpan<")
    }

    func hasConformance(_ proto: String) -> Bool {
        return conformances.contains(proto) ||
               conformances.contains("Swift.\(proto)") ||
               conformances.contains("any \(proto)") ||
               conformances.contains("any Swift.\(proto)") ||
               conformances.contains(where: { $0.hasSuffix(".\(proto)") })
    }

    func getGenericCount(parser: Parser?) -> Int {
        // A non-generic type has 0 generic params — used as the base case when walking
        // up the parent chain (e.g. a top-level type's "parent" is the module, which is
        // never generic). Only fall back to the historical default of 1 when the type
        // IS marked generic but we can't find a discovered count for it.
        guard isGeneric else { return 0 }
        guard let parser = parser else { return 1 }
        let enclosing = getEnclosingPath()
        let relativeName = enclosing.isEmpty ? name : enclosing + "." + name
        let fullPath1 = parser.defaultModule + "." + relativeName
        let fullPath2 = relativeName
        if let inferredCount = parser.discoveredGenerics[fullPath1] {
            return inferredCount
        } else if let inferredCount = parser.discoveredGenerics[fullPath2] {
            return inferredCount
        }
        return 1
    }

    func getOwnGenericCount(parser: Parser?) -> Int {
        let total = getGenericCount(parser: parser)
        if let parentNode = parent {
            return max(0, total - parentNode.getGenericCount(parser: parser))
        }
        return total
    }

    func getParentGenericCount(parser: Parser?) -> Int {
        if let parentNode = parent {
            return parentNode.getGenericCount(parser: parser)
        }
        return 0
    }

    static func getDefaultValue(for type: String) -> String {
        var cleanType = type.trimmingCharacters(in: .whitespaces)
        // Strip @escaping / @autoclosure / @Sendable attributes
        while cleanType.hasPrefix("@") {
            if let spaceIdx = cleanType.firstIndex(of: " ") {
                cleanType = String(cleanType[cleanType.index(after: spaceIdx)...]).trimmingCharacters(in: .whitespaces)
            } else { break }
        }
        if cleanType.hasPrefix("Swift.") {
            cleanType = String(cleanType.dropFirst(6))
        }
        if cleanType.hasPrefix("Optional<") || cleanType.hasSuffix("?") || cleanType == "Any?" {
            return "nil"
        }
        if cleanType == "Bool" {
            return "false"
        }
        if cleanType == "Int" || cleanType == "Double" || cleanType == "Float" || cleanType == "UInt64" || cleanType == "Int64" || cleanType == "UInt32" || cleanType == "Int32" {
            return "0"
        }
        if cleanType == "String" {
            return "\"\""
        }
        if cleanType.hasPrefix("Array<") || (cleanType.hasPrefix("[") && cleanType.hasSuffix("]") && !cleanType.contains(":")) {
            return "[]"
        }
        if cleanType.hasPrefix("Dictionary<") || (cleanType.hasPrefix("[") && cleanType.contains(":")) {
            return "[:]"
        }
        if cleanType.hasPrefix("Set<") {
            return "[]"
        }
        // Closure types: "(Args) -> ReturnType" or "(Args) throws -> ReturnType"
        if cleanType.hasPrefix("(") {
            // Find the matching closing paren for the argument list
            var depth = 0
            var closeParenIdx: String.Index? = nil
            var i = cleanType.startIndex
            while i < cleanType.endIndex {
                let ch = cleanType[i]
                if ch == "(" { depth += 1 }
                else if ch == ")" {
                    depth -= 1
                    if depth == 0 {
                        closeParenIdx = i
                        break
                    }
                }
                i = cleanType.index(after: i)
            }
            if let closeParen = closeParenIdx {
                let argsPart = String(cleanType[cleanType.index(after: cleanType.startIndex)..<closeParen])
                    .trimmingCharacters(in: .whitespaces)
                let afterParen = String(cleanType[cleanType.index(after: closeParen)...]).trimmingCharacters(in: .whitespaces)
                // afterParen is "-> ReturnType" or "throws -> ReturnType"
                var retType = "Void"
                if let arrowRange = afterParen.range(of: "->") {
                    retType = String(afterParen[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                }
                let retDefault = getDefaultValue(for: retType)
                if argsPart.isEmpty {
                    return "{ \(retDefault) }"
                } else {
                    return "{ _ in \(retDefault) }"
                }
            }
        }
        // Protocol existential: "any ProtocolName" or "any Module.ProtocolName"
        // Use a sentinel struct _Default_ProtocolName that will be emitted by postProcess.
        if cleanType.hasPrefix("any ") {
            let protoName = String(cleanType.dropFirst(4))
                .components(separatedBy: ".").last ?? String(cleanType.dropFirst(4))
            return "_Default_\(protoName)()"
        }
        return "dummyDefaultValue()"
    }

    init(name: String) {
        self.name = name
    }

    func getEnclosingPath() -> String {
        var path = [String]()
        var curr = parent
        while let p = curr {
            if p.parent != nil {
                path.insert(p.name, at: 0)
            }
            curr = p.parent
        }
        return path.joined(separator: ".")
    }

    func injectDefaultArguments(signature: String, methodName: String, isStatic: Bool, parser: Parser?) -> String {
        guard let parser = parser else { return signature }
        guard let openParen = signature.firstIndex(of: "(") else { return signature }
        // Find the matching close paren by depth to avoid matching tuple return types
        var depth = 0
        var closeParen: String.Index? = nil
        var idx = openParen
        while idx < signature.endIndex {
            if signature[idx] == "(" { depth += 1 }
            else if signature[idx] == ")" {
                depth -= 1
                if depth == 0 { closeParen = idx; break }
            }
            idx = signature.index(after: idx)
        }
        guard let closeParen = closeParen, openParen < closeParen else { return signature }

        let paramsStr = String(signature[signature.index(after: openParen)..<closeParen])
        // Split parameters by top-level commas
        let params = parser.splitTopLevelCommas(paramsStr)
        var labels = [String]()
        for param in params {
            let trimmed = param.trimmingCharacters(in: .whitespaces)
            if let colonIdx = trimmed.firstIndex(of: ":") {
                let labelOrBoth = String(trimmed[..<colonIdx]).trimmingCharacters(in: .whitespaces)
                let labelParts = labelOrBoth.components(separatedBy: " ")
                let label = labelParts.first ?? "_"
                labels.append(label)
            } else {
                labels.append("_")
            }
        }
        
        let defaultModule = parser.defaultModule
        var pathComponents = [String]()
        if !defaultModule.isEmpty { pathComponents.append(defaultModule) }
        let enc = getEnclosingPath()
        if !enc.isEmpty { pathComponents.append(enc) }
        pathComponents.append(self.name)
        let fullTypeName = pathComponents.joined(separator: ".")
        let methodKey = "\(fullTypeName).\(methodName)(\(labels.joined(separator: ":"))\(labels.isEmpty ? "" : ":"))"
        
        guard let indices = parser.defaultArguments[methodKey] else {
            return signature
        }
        
        var newParams = [String]()
        for (i, param) in params.enumerated() {
            let trimmed = param.trimmingCharacters(in: .whitespaces)
            if indices.contains(i) {
                var defaultValue = "dummyDefaultValue()"
                if let colonIdx = trimmed.firstIndex(of: ":") {
                    let typePart = String(trimmed[trimmed.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
                    defaultValue = TypeNode.getDefaultValue(for: typePart)
                    fputs("applyDefaultArguments key: \(methodKey) typePart: '\(typePart)' resolved: '\(defaultValue)'\n", stderr)
                }
                newParams.append("\(trimmed) = \(defaultValue)")
            } else {
                newParams.append(trimmed)
            }
        }
        
        let prefix = signature[...openParen]
        let suffix = signature[closeParen...]
        return String(prefix) + newParams.joined(separator: ", ") + String(suffix)
    }

    private func escapeKeyword(_ name: String) -> String {
        let swiftKeywords: Set<String> = [
            "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
            "func", "import", "init", "inout", "internal", "let", "open", "operator",
            "private", "protocol", "public", "reinit", "static", "struct", "subscript",
            "typealias", "var", "break", "case", "continue", "default", "defer",
            "do", "else", "fallthrough", "for", "guard", "if", "in", "is", "repeat",
            "return", "switch", "where", "while", "as", "Any", "AnyObject", "catch",
            "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws",
            "true", "try", "Type", "Protocol"
        ]
        if swiftKeywords.contains(name) {
            return "`\(name)`"
        }
        return name
    }

    static func defaultReturnValue(for type: String) -> String {
        var t = type.trimmingCharacters(in: .whitespaces)
        if let whereRange = t.range(of: " where ") {
            t = String(t[..<whereRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        if t == "Bool" { return "false" }
        if ["Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64"].contains(t) { return "0" }
        if ["Double", "Float", "Float16", "CGFloat"].contains(t) { return "0.0" }
        if t == "String" { return "\"\"" }
        if t == "StaticString" { return "\"\"" }
        if t.contains("->") {
            if t.starts(with: "Optional<") || t.hasSuffix(")?") {
                return "nil"
            }
            return "fatalError()"
        }
        if t.starts(with: "Optional<") || t.hasSuffix("?") { return "nil" }
        if t.starts(with: "[[") { return "[]" }
        if t.starts(with: "Dictionary<") || (t.starts(with: "[") && t.contains(":") && !t.starts(with: "[(")) { return "[:]" }
        // A "[" prefix normally means Array<...>, but a bracketed type can also be followed by
        // a member access, e.g. "[Any]?.Publisher" (Combine's Optional<[Any]>.Publisher) — that
        // is NOT itself an array literal type, so only match when the brackets are genuinely
        // the outermost/entire type (nothing trails the closing bracket but an optional "?").
        if t.starts(with: "Array<") || (t.starts(with: "[") && (t.hasSuffix("]") || t.hasSuffix("]?"))) { return "[]" }
        if t.starts(with: "Set<") { return "[]" }
        if t == "Void" || t == "()" { return "" }
        if t == "Data" { return "Data()" }
        if t.hasPrefix("AnySequence") { return "AnySequence([])" }
        return "fatalError()"
    }

    static let systemAssociatedTypes: [String: [String]] = [
        "Publisher": ["Output", "Failure"],
        "Subscriber": ["Input", "Failure"],
        "Subject": ["Output", "Failure"],
        "Scheduler": ["SchedulerTimeType", "SchedulerOptions"],
        "Collection": ["Element", "Index", "Iterator", "SubSequence"],
        "Sequence": ["Element", "Iterator"],
        "IteratorProtocol": ["Element"],
        "AsyncSequence": ["Element", "AsyncIterator"],
        "AsyncIteratorProtocol": ["Element"],
        "RawRepresentable": ["RawValue"],
        "Identifiable": ["ID"]
    ]

    func getAllAssociatedTypes(parser: Parser?) -> Set<String> {
        var result = Set<String>()
        let shortName = name.components(separatedBy: ".").last ?? name
        if let systemTypes = TypeNode.systemAssociatedTypes[shortName] {
            result.formUnion(systemTypes)
        }
        
        for member in members.values {
            if case .associatedType(let code) = member {
                let parts = code.components(separatedBy: " ")
                if parts.count >= 2 {
                    let name = parts[1].replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
                    result.insert(name)
                }
            }
        }
        
        for conf in conformances {
            let cleanConf = conf.components(separatedBy: ".").last ?? conf
            if let systemTypes = TypeNode.systemAssociatedTypes[cleanConf] {
                result.formUnion(systemTypes)
            }
            if let parser = parser, let parentNode = parser.modules[parser.defaultModule]?.nestedTypes[cleanConf] {
                result.formUnion(parentNode.getAllAssociatedTypes(parser: parser))
            }
        }
        return result
    }

    // Infers a generic Publisher/Subscriber conformance's associated-type aliases (Output,
    // Failure, Input) from the same-type constraints already present on its own `receive`
    // method's where-clause — e.g. `receive<S>(subscriber: S) where S: Subscriber,
    // A.Failure == S.Failure, A.Output == S.Input` tells us `Output = A.Output` and
    // `Failure = A.Failure`. This generalizes the old Record-only hardcode to every Combine
    // Publisher/Subscriber type without needing a per-type-name table.
    func inferReceiveAssociatedTypes() -> [String: String] {
        var result = [String: String]()
        for member in members.values {
            guard case .method(let mName, let sig, _) = member, mName == "receive" || mName.hasPrefix("receive<") else { continue }
            guard sig.contains("subscriber:") else { continue }
            guard let whereRange = sig.range(of: " where ") else { continue }
            guard let subRange = sig.range(of: "subscriber: ") else { continue }
            var subParamStart = subRange.upperBound
            let modifiers = ["__owned ", "shared ", "inout "]
            for modifier in modifiers {
                if sig[subParamStart...].hasPrefix(modifier) {
                    subParamStart = sig.index(subParamStart, offsetBy: modifier.count)
                    break
                }
            }
            var subParam = ""
            for ch in sig[subParamStart...] {
                if ch.isLetter || ch.isNumber || ch == "_" { subParam.append(ch) } else { break }
            }
            guard !subParam.isEmpty else { continue }

            let whereClause = String(sig[whereRange.upperBound...])
            let constraints = splitWhereClauseConstraints(whereClause)
            for rawConstraint in constraints {
                let constraint = rawConstraint.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let eqRange = constraint.range(of: " == ") else { continue }
                let lhs = String(constraint[..<eqRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                let rhs = String(constraint[eqRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                for (assoc, other) in [(lhs, rhs), (rhs, lhs)] {
                    guard assoc.hasPrefix("\(subParam).") else { continue }
                    let subscriberAssoc = String(assoc.dropFirst(subParam.count + 1))
                    guard subscriberAssoc == "Input" || subscriberAssoc == "Failure" else { continue }
                    let ourAssoc = subscriberAssoc == "Input" ? "Output" : "Failure"
                    if result[ourAssoc] == nil, !other.isEmpty, other != subParam,
                       !other.contains(subParam) {
                        result[ourAssoc] = other
                    }
                }
            }
        }
        return result
    }

    func inferSubscriberAssociatedTypes() -> [String: String] {
        var result = [String: String]()
        for member in members.values {
            guard case .method(let mName, let sig, _) = member, mName == "receive" else { continue }
            if sig.contains("-> Subscribers.Demand") {
                if let openParen = sig.firstIndex(of: "("),
                   let closeParen = sig.firstIndex(of: ")"),
                   openParen < closeParen {
                    let paramList = String(sig[sig.index(after: openParen)..<closeParen])
                    let parts = paramList.components(separatedBy: ":")
                    let typePart = parts.last?.trimmingCharacters(in: .whitespaces) ?? paramList.trimmingCharacters(in: .whitespaces)
                    if !typePart.isEmpty && typePart != "Self" {
                        result["Input"] = typePart
                    }
                }
            }
            if sig.contains("completion:") {
                if let openAngle = sig.firstIndex(of: "<"),
                   let closeAngle = sig[openAngle...].firstIndex(of: ">") {
                    let failureType = String(sig[sig.index(after: openAngle)..<closeAngle]).trimmingCharacters(in: .whitespaces)
                    if !failureType.isEmpty && failureType != "Self" {
                        result["Failure"] = failureType
                    }
                }
            }
        }
        return result
    }

    private func splitWhereClauseConstraints(_ whereClause: String) -> [String] {
        var constraints = [String]()
        var current = ""
        var depth = 0
        for char in whereClause {
            if char == "(" || char == "<" || char == "[" {
                depth += 1
                current.append(char)
            } else if char == ")" || char == ">" || char == "]" {
                depth -= 1
                current.append(char)
            } else if char == "," && depth == 0 {
                constraints.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        if !current.isEmpty {
            constraints.append(current)
        }
        return constraints
    }

    func pruneInvalidSelfConstraints(from sig: String, parser: Parser?) -> String {
        guard sig.contains("Self.") else { return sig }
        
        let validAssoc = getAllAssociatedTypes(parser: parser)
        
        var baseSig = sig
        var whereClause = ""
        if let range = sig.range(of: " where ") {
            baseSig = String(sig[..<range.lowerBound])
            whereClause = String(sig[range.upperBound...])
        } else if let range = sig.range(of: "where ") {
            baseSig = String(sig[..<range.lowerBound])
            whereClause = String(sig[range.upperBound...])
        }
        
        guard !whereClause.isEmpty else { return sig }
        
        let constraints = whereClause.splitByCommaRespectingBrackets()
        var keptConstraints = [String]()
        for constraint in constraints {
            let trimmed = constraint.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            
            var hasInvalidSelf = false
            var searchRange = trimmed.startIndex..<trimmed.endIndex
            while let selfRange = trimmed.range(of: "Self.", options: [], range: searchRange) {
                let afterSelf = String(trimmed[selfRange.upperBound...])
                var assocName = ""
                for char in afterSelf {
                    if char.isLetter || char.isNumber || char == "_" {
                        assocName.append(char)
                    } else {
                        break
                    }
                }
                if !assocName.isEmpty && !validAssoc.contains(assocName) {
                    hasInvalidSelf = true
                    break
                }
                searchRange = selfRange.upperBound..<trimmed.endIndex
            }
            
            if !hasInvalidSelf {
                keptConstraints.append(trimmed)
            }
        }
        
        if keptConstraints.isEmpty {
            return baseSig
        } else {
            return baseSig + " where " + keptConstraints.joined(separator: ", ")
        }
    }


    func generateCode(indent: String = "", nameOverride: String? = nil, parser: Parser? = nil) -> String {
        let n = nameOverride ?? name
        if n.contains(" ") { return "" }
        let actualKind = kind == "unknown" ? "struct" : kind
        var finalKind = actualKind
        if actualKind == "class" && (hasConformance("Actor") || hasConformance("Swift.Actor")) {
            finalKind = "actor"
        }
        if isObjcBridged && finalKind == "enum" {
            return ""
        }
        var lines = [String]()
        let isProtocol = actualKind == "protocol"
        let isEnum = actualKind == "enum"

        // Swift 6: protocols used as `any P` associated values in Sendable enums/structs
        // must themselves inherit Sendable. If this protocol is nested inside a Sendable
        // parent, propagate Sendable into the protocol's conformance list.
        if isProtocol, let parentNode = parent, parentNode.hasConformance("Sendable") {
            conformances.insert("Sendable")
        }
        
        if !isProtocol && !isEnum {
            var hasCatalogResource = false
            var hasManagedResource = false
            var hasIdentifiable = false
            for conf in conformances {
                let cleanConf = conf.trimmingCharacters(in: .whitespaces)
                if cleanConf == "CatalogResource" || cleanConf.hasPrefix("CatalogResource<") || cleanConf.hasPrefix("any CatalogResource") {
                    hasCatalogResource = true
                }
                if cleanConf == "ManagedResource" || cleanConf.hasPrefix("ManagedResource<") || cleanConf.hasPrefix("any ManagedResource") {
                    hasManagedResource = true
                }
                if cleanConf == "Identifiable" || cleanConf.hasPrefix("any Identifiable") {
                    hasIdentifiable = true
                }
            }
            if hasCatalogResource {
                if members["typealias A"] == nil && members["A"] == nil {
                    members["typealias A"] = .associatedType("public typealias A = Any")
                }
                if members["id"] == nil {
                    members["id"] = .property(name: "id", type: "String", isReadOnly: true, isStatic: false)
                }
                if members["inferenceProviders"] == nil {
                    members["inferenceProviders"] = .property(name: "inferenceProviders", type: "Set<InferenceProvider>", isReadOnly: true, isStatic: false)
                }
            }
            if hasManagedResource {
                if members["typealias A"] == nil && members["A"] == nil {
                    members["typealias A"] = .associatedType("public typealias A = Any")
                }
                if members["cost"] == nil {
                    members["cost"] = .property(name: "cost", type: "CostProfile", isReadOnly: true, isStatic: false)
                }
                if members["executionContexts"] == nil {
                    members["executionContexts"] = .property(name: "executionContexts", type: "Set<ExecutionContext>", isReadOnly: false, isStatic: false)
                }
                if members["dependencies"] == nil {
                    members["dependencies"] = .property(name: "dependencies", type: "Array<any ManagedResource>", isReadOnly: true, isStatic: false)
                }
                if members["runtimeInformation"] == nil {
                    members["runtimeInformation"] = .property(name: "runtimeInformation", type: "Array<ManagedRuntimeInformation>", isReadOnly: true, isStatic: false)
                }
            }
            if hasIdentifiable {
                if members["id"] == nil {
                    members["id"] = .property(name: "id", type: "String", isReadOnly: true, isStatic: false)
                }
            }
        }
        
        var inScope = Set<String>()
        var parentNode = parent
        while let currParent = parentNode {
            let placeholders = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
            let parentOwnCount = currParent.getOwnGenericCount(parser: parser)
            let parentParentCount = currParent.getParentGenericCount(parser: parser)
            for i in 0..<parentOwnCount {
                let p = placeholders[parentParentCount + i]
                inScope.insert(p)
            }
            parentNode = currParent.parent
        }
        var genericParamsList = ""
        if isGeneric {
            let placeholders = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
            let ownCount = getOwnGenericCount(parser: parser)
            let parentCount = getParentGenericCount(parser: parser)
            if ownCount > 0 {
                var params = [String]()
                for i in 0..<ownCount {
                    let p = placeholders[parentCount + i]
                    inScope.insert(p)
                    params.append(p)
                }
                genericParamsList = "<\(params.joined(separator: ", "))>"
            }
        }
        let selfReplaceWith = isProtocol ? "Self" : name + (isGeneric ? genericParamsList : "")
        for member in members.values {
            if case .associatedType(let code) = member {
                let parts = code.components(separatedBy: " ")
                if parts.count >= 2 {
                    inScope.insert(parts[1].replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces))
                }
            }
        }
        let cleanScope = { (s: String) -> String in
            var res = s
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            for p in placeholders {
                if !inScope.contains(p) {
                    res = res.replaceWord(p, with: "Any")
                }
            }
            return res
        }

        var inherits = [String]()
        if let base = baseClass {
            inherits.append(base)
        }
        
        var hasCases = false
        var hasPayloadCase = false
        for member in members.values {
            if case .enumCase(_, let payload, _) = member {
                hasCases = true
                if payload != nil { hasPayloadCase = true }
            }
        }

        // A `rawValue` member alone doesn't mean the enum has a compiler-synthesized raw
        // type: real protobuf-style enums (e.g. InternalSwiftProtobuf's
        // Google_Protobuf_NullValue) declare a case with an associated value (`UNRECOGNIZED
        // (_: Int)`) alongside a manually-implemented `rawValue`/`init(rawValue:)` pair —
        // Swift rejects `: Int, RawRepresentable` on such an enum outright ("enum with raw
        // type cannot have cases with arguments"), since raw-type inheritance requires EVERY
        // case to carry no payload. Confirmed via the real ABI: Google_Protobuf_NullValue's
        // conformance-descriptor set has no RawRepresentable witness table at all — rawValue
        // there is just an ordinary computed property.
        if isEnum, hasPayloadCase, let raw = rawType {
            conformances.remove(raw)
            let rawValueName = "rawValue"
            if !members.values.contains(where: {
                if case .property(let n, _, _, _) = $0 { return n == rawValueName }
                return false
            }) {
                members[rawValueName] = .property(name: rawValueName, type: raw, isReadOnly: true, isStatic: false)
            }
        } else if isEnum, let raw = rawType {
            var cleanRaw = raw.trimmingCharacters(in: .whitespaces)
            if cleanRaw.hasPrefix("any ") {
                cleanRaw = String(cleanRaw.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            }
            if cleanRaw.hasPrefix("Swift.") {
                cleanRaw = String(cleanRaw.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            }
            let validRawTypes: Set<String> = [
                "Int", "Int8", "Int16", "Int32", "Int64",
                "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
                "Double", "Float", "Float16", "String", "Character"
            ]
            if validRawTypes.contains(cleanRaw) {
                inherits.append(raw)
            } else {
                conformances.insert(raw)
            }
        }
        
        var cleanConformances = Set<String>()
        for conf in conformances {
            var clean = conf.trimmingCharacters(in: .whitespaces)
            var changed = true
            while changed {
                changed = false
                if clean.hasPrefix("any ") {
                    clean = String(clean.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                    changed = true
                }
                if clean.hasPrefix("Swift.") {
                    clean = String(clean.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    changed = true
                }
            }
            if let parser = parser {
                let baseName = clean.stripGenericAngles()
                if parser.discoveredProtocols.contains(baseName) || 
                   parser.discoveredProtocols.contains(where: { $0.hasSuffix("." + baseName) }) ||
                   baseName.hasSuffix("_P") {
                    clean = baseName
                }
            }
            cleanConformances.insert(clean)
        }
        
        if cleanConformances.contains("Codable") {
            cleanConformances.remove("Decodable")
            cleanConformances.remove("Encodable")
        }
        if cleanConformances.contains("Decodable") && cleanConformances.contains("Encodable") {
            cleanConformances.remove("Decodable")
            cleanConformances.remove("Encodable")
            cleanConformances.insert("Codable")
        }
        if cleanConformances.contains("Hashable") {
            cleanConformances.remove("Equatable")
        }
        if isEnum && !hasCases {
            cleanConformances.remove("Codable")
            cleanConformances.remove("Decodable")
            cleanConformances.remove("Encodable")
        }
        if cleanConformances.contains("~Copyable") || cleanConformances.contains("Swift.~Copyable") {
            cleanConformances.remove("Codable")
            cleanConformances.remove("Decodable")
            cleanConformances.remove("Encodable")
            cleanConformances.remove("Hashable")
            cleanConformances.remove("Equatable")
            cleanConformances.remove("Comparable")
        }
        self.conformances = cleanConformances
        inherits.append(contentsOf: cleanConformances.sorted())
        
        var inheritsList = inherits.map { t in
            var clean = t.trimmingCharacters(in: .whitespaces)
            if clean == "Error" || clean == "Swift.Error" {
                return "Swift.Error"
            }
            var changed = true
            while changed {
                changed = false
                if clean.hasPrefix("any ") {
                    clean = String(clean.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                    changed = true
                }
                if clean.hasPrefix("Swift.") {
                    clean = String(clean.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    changed = true
                }
            }
            if let parser = parser {
                let baseName = clean.stripGenericAngles()
                if parser.discoveredProtocols.contains(baseName) || 
                   parser.discoveredProtocols.contains(where: { $0.hasSuffix("." + baseName) }) ||
                   baseName.hasSuffix("_P") {
                    clean = baseName
                }
            }
            if clean == "Error" {
                return "Swift.Error"
            }
            return clean
        }
        var seen = Set<String>()
        inheritsList = inheritsList.filter { seen.insert($0).inserted }
        if actualKind == "struct" || actualKind == "class" || actualKind == "enum" {
            // For custom float types (Float4, Float8, BFloat16) that explicitly conform to
            // numeric protocols in the TBD, we keep those conformances so the protocol
            // conformance descriptor symbols are generated. For all other types, these
            // protocols cause compiler errors because they require many protocol requirements
            // that our stubs cannot satisfy.
            let isCustomFloatType = ["Float4", "Float8", "BFloat16"].contains(n)
            let isSchedulerTimeType = n == "SchedulerTimeType" || n.hasSuffix(".SchedulerTimeType")
            let isStride = n == "Stride" || n.hasSuffix(".Stride")
            var forbiddenProtocols: Set<String> = ["AdditiveArithmetic", "BinaryFloatingPoint",
                   "FloatingPoint", "Numeric", "SignedNumeric", "Strideable",
                   "BinaryInteger", "FixedWidthInteger", "SignedInteger", "UnsignedInteger"]
            if isCustomFloatType {
                forbiddenProtocols = []
            } else if isSchedulerTimeType {
                forbiddenProtocols.remove("Strideable")
            } else if isStride {
                forbiddenProtocols.remove("SignedNumeric")
                forbiddenProtocols.remove("AdditiveArithmetic")
            }
            inheritsList = inheritsList.filter { !forbiddenProtocols.contains($0) }
        }
        if actualKind == "class" {
            // Strip Equatable, Hashable, and Codable — these generate extra conformance descriptors
            // that the TBD does not export for most class types.
            // Exception: keep them if the TBD actually exports the conformance Mc symbols.
            let hasCodableMc = parser?.conformancesFromTBD.contains(where: { $0.hasPrefix("\(n):") && ($0.hasSuffix(":Encodable") || $0.hasSuffix(":Decodable")) }) == true
            let hasHashableMc = parser?.conformancesFromTBD.contains(where: { $0 == "\(n):Hashable" }) == true
            let hasEquatableMc = parser?.conformancesFromTBD.contains(where: { $0 == "\(n):Equatable" }) == true
            var toStrip: Set<String> = ["Sendable"]
            if !hasHashableMc { toStrip.insert("Hashable") }
            if !hasEquatableMc { toStrip.insert("Equatable") }
            if !hasCodableMc { toStrip.formUnion(["Codable", "Encodable", "Decodable"]) }
            inheritsList = inheritsList.filter { !toStrip.contains($0) }
            
            var needsUncheckedSendable = false
            for inheritsType in inheritsList {
                if inheritsType == "Sendable" || inheritsType.hasSuffix("Error") {
                    needsUncheckedSendable = true
                }
                if let parser = parser, let protoNode = parser.modules[parser.defaultModule]?.nestedTypes[inheritsType], protoNode.conformances.contains("Sendable") {
                    needsUncheckedSendable = true
                }
            }
            if needsUncheckedSendable {
                inheritsList.append("@unchecked Sendable")
            }
        }
        
        if let idx = inheritsList.firstIndex(of: "Sendable") {
            if !isProtocol {
                inheritsList[idx] = "@unchecked Sendable"
            }
        }
        if finalKind == "actor" {
            inheritsList = inheritsList.filter { $0 != "Actor" && $0 != "Swift.Actor" }
        }
        let inheritance = inheritsList.isEmpty ? "" : ": " + inheritsList.joined(separator: ", ")
        
        let typeName = nameOverride ?? name
        var displayTypeName = escapeKeyword(typeName)
        if typeName == "BidirectionalXPCServiceClientConnection" {
            displayTypeName += "<A: XPCService, B: XPCService>"
            inScope.insert("A")
            inScope.insert("B")
        } else if typeName == "CatalogAsset" {
            displayTypeName += "<A: AssetMetadata, B: AssetContents>"
            inScope.insert("A")
            inScope.insert("B")
        } else if typeName == "SupportedArgument" {
            displayTypeName += "<A: Equatable>"
            inScope.insert("A")
        } else if typeName == "ResourceBundleIdentifier" {
            displayTypeName += "<A: ResourceBundle>"
            inScope.insert("A")
        } else if typeName == "MLShapedArray" {
            displayTypeName += "<A: MLShapedArrayScalar>"
            inScope.insert("A")
        } else if typeName == "MLShapedArraySlice" {
            displayTypeName += "<A: MLShapedArrayScalar>"
            inScope.insert("A")
        } else if typeName == "XPCServiceClientConnection" {
            displayTypeName += "<A: XPCService>"
            inScope.insert("A")
        } else if parser?.defaultModule == "Combine" && isGeneric && (typeName.contains("Sink") || typeName.contains("Record") || typeName.contains("Zip") || typeName.contains("CombineLatest") || typeName.contains("Merge") || typeName.contains("Sequence")) {
            let short = typeName.components(separatedBy: ".").last ?? typeName
            if short == "Sink" {
                displayTypeName += "<A, B: Error>"
                inScope.insert("A"); inScope.insert("B")
            } else if short == "Record" {
                displayTypeName += "<A, B: Error>"
                inScope.insert("A"); inScope.insert("B")
            } else if short.starts(with: "Zip") || short.starts(with: "CombineLatest") || short.starts(with: "Merge") {
                let count = getGenericCount(parser: parser)
                let placeholders = ["A", "B", "C", "D", "E", "F", "G", "H"]
                var params = [String]()
                for i in 0..<min(count, placeholders.count) {
                    let p = placeholders[i]
                    params.append("\(p): Publisher")
                    inScope.insert(p)
                }
                displayTypeName += "<\(params.joined(separator: ", "))>"
            } else if short == "Sequence" {
                // Qualified as Swift.Sequence (not bare "Sequence") so applyDiscoveredGenerics'
                // bare-word scanner — which sees a same-named struct declared elsewhere in the
                // generated code and treats every bare "Sequence" occurrence as a use site
                // needing <Any> args — skips this one (its dot-preceded-word guard).
                displayTypeName += "<A: Swift.Sequence, B: Error>"
                inScope.insert("A"); inScope.insert("B")
            } else {
                let count = getGenericCount(parser: parser)
                let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                var params = [String]()
                for i in 0..<min(count, placeholders.count) {
                    let p = placeholders[i]
                    params.append(p)
                    inScope.insert(p)
                }
                displayTypeName += "<\(params.joined(separator: ", "))>"
            }
        } else if isGeneric && !isProtocol && !displayTypeName.contains("<") {
            let count = getGenericCount(parser: parser)

            var assocTypes = [String]()
            for member in members.values {
                if case .associatedType(let code) = member {
                    let parts = code.components(separatedBy: " ")
                    if parts.count >= 2 {
                        let cleaned = parts[1].components(separatedBy: ":").first!.trimmingCharacters(in: .whitespaces)
                        assocTypes.append(cleaned)
                    }
                }
            }
            let sortedAssoc = assocTypes.sorted()

            // A generic param used elsewhere in this type's own (raw, pre-cleanup) member
            // signatures as `<param>.Output` or `<param>.Failure` must itself conform to
            // Publisher for those associated-type accesses to resolve — this is how Combine's
            // publisher-wrapping types (RemoveDuplicates<A>, ReplaceEmpty<A>, Reduce<A, B>, ...)
            // constrain their upstream generic params without a per-type-name table. Likewise
            // `<param>.Input` implies Subscriber. This applies even to internal helper types
            // that don't themselves declare a Publisher/Subscriber conformance (e.g.
            // AnySubscriberBox<A> uses A.Input/A.Failure without conforming to anything).
            func collectRawSignatures(node: TypeNode) -> [String] {
                var sigs = [String]()
                for member in node.members.values {
                    switch member {
                    case .method(_, let sig, _): sigs.append(sig)
                    case .property(_, let t, _, _): sigs.append(t)
                    case .initializer(let sig): sigs.append(sig)
                    case .associatedType(let sig): sigs.append(sig)
                    case .enumCase(_, let payload, _):
                        if let p = payload { sigs.append(p) }
                    default: break
                    }
                }
                for child in node.nestedTypes.values {
                    sigs.append(contentsOf: collectRawSignatures(node: child))
                }
                return sigs
            }
            var placeholdersNeedingPublisher = Set<String>()
            var placeholdersNeedingSubscriber = Set<String>()
            var placeholdersNeedingScheduler = Set<String>()
            // TabularData's FilledColumn<A> uses A.WrappedElement/A.Index without declaring
            // `where A: OptionalColumnProtocol` anywhere reconstructable from demangled symbol
            // text (the constraint lives in generic-requirement metadata swift-demangle doesn't
            // surface) — same inference approach as Publisher/Subscriber/Scheduler above.
            var placeholdersNeedingOptionalColumnProtocol = Set<String>()
            // Network's UpperHarness<A>/LowerHarness<A> use A.PairedLinkage (the associated type
            // declared on ProtocolLinkage) without a reconstructable `where A: ...` clause — same
            // inference approach as Publisher/Subscriber/Scheduler above. Which protocol A must
            // conform to depends on which handler protocol this type itself conforms to: a type
            // conforming to UpperProtocolHandler needs its own PairedLinkage-referencing param to
            // be UpperProtocolLinkage (UpperProtocolHandler.LowerProtocol: LowerProtocolLinkage is
            // UpperProtocolLinkage.PairedLinkage), while LowerProtocolHandler/BottomProtocolHandler
            // needs LowerProtocolLinkage (mirror relationship). Fall back to the common ancestor
            // ProtocolLinkage when neither conformance is present.
            let protocolLinkageBound: String
            if hasConformance("UpperProtocolHandler") {
                protocolLinkageBound = "UpperProtocolLinkage"
            } else if hasConformance("LowerProtocolHandler") || hasConformance("BottomProtocolHandler") {
                protocolLinkageBound = "LowerProtocolLinkage"
            } else {
                protocolLinkageBound = "ProtocolLinkage"
            }
            var placeholdersNeedingProtocolLinkage = Set<String>()
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            let allRawSigs = collectRawSignatures(node: self)
            for rawSig in allRawSigs {
                for p in placeholders {
                    if rawSig.contains("\(p).Output") || rawSig.contains("\(p).Failure") {
                        placeholdersNeedingPublisher.insert(p)
                    }
                    if rawSig.contains("\(p).Input") {
                        placeholdersNeedingSubscriber.insert(p)
                    }
                    if rawSig.contains("\(p).SchedulerTimeType") || rawSig.contains("\(p).SchedulerOptions") {
                        placeholdersNeedingScheduler.insert(p)
                    }
                    if rawSig.contains("\(p).WrappedElement") {
                        placeholdersNeedingOptionalColumnProtocol.insert(p)
                    }
                    if rawSig.contains("\(p).PairedLinkage") {
                        placeholdersNeedingProtocolLinkage.insert(p)
                    }
                }
            }
            // A generic param inferred as this type's own Failure (e.g. `B` in AnyPublisher<A, B>,
            // via inferReceiveAssociatedTypes/inferSubscriberAssociatedTypes below) must conform to Error —
            // Publisher.Failure/Subscriber.Failure requires it, and a bare placeholder has no constraint otherwise.
            var placeholdersNeedingError = Set<String>()
            if hasConformance("Publisher") || hasConformance("Subscriber") {
                let inferred = hasConformance("Publisher") ? inferReceiveAssociatedTypes() : inferSubscriberAssociatedTypes()
                if let failure = inferred["Failure"], placeholders.contains(failure) {
                    placeholdersNeedingError.insert(failure)
                }
            }

            var params = [String]()
            for i in 0..<count {
                if isProtocol {
                    if i < sortedAssoc.count {
                        params.append(sortedAssoc[i])
                    } else {
                        params.append(i < placeholders.count ? placeholders[i] : "A\(i)")
                    }
                } else {
                    if i < placeholders.count {
                        let p = placeholders[i]
                        if placeholdersNeedingSubscriber.contains(p) {
                            params.append("\(p): Subscriber")
                        } else if placeholdersNeedingPublisher.contains(p) {
                            params.append("\(p): Publisher")
                        } else if placeholdersNeedingScheduler.contains(p) {
                            params.append("\(p): Scheduler")
                        } else if placeholdersNeedingOptionalColumnProtocol.contains(p) {
                            params.append("\(p): OptionalColumnProtocol")
                        } else if placeholdersNeedingProtocolLinkage.contains(p) {
                            params.append("\(p): \(protocolLinkageBound)")
                        } else if placeholdersNeedingError.contains(p) {
                            params.append("\(p): Error")
                        } else {
                            params.append(p)
                        }
                    } else {
                        params.append("A\(i)")
                    }
                }
            }
            displayTypeName += "<\(params.joined(separator: ", "))>"
        }
        
        // ObjC-bridged types are extended via a Swift extension (not declared as a new class).
        // The extension block is wrapped in sentinel comments so orchestrate.py can strip it
        // from the module-interface compilation phase (which can't use -import-objc-header).
        if isObjcBridged && finalKind == "class" {
            lines.append("\(indent)// --- ObjC Extension (bridge-header required) ---")
            lines.append("\(indent)extension \(displayTypeName) {")
        } else {
            // NSObject subclasses need `open` so that library-evolution mode generates dispatch
            // thunks (Tj) for overridable/required methods like init?(coder:).
            let isNSObjectSubclass = baseClass == "NSObject"
            var classVisibility = (finalKind == "class" && isNSObjectSubclass) ? "open" : "public"
            if finalKind == "class" && classVisibility == "public" && name != "NSObject" {
                var hasSubclass = false
                var isNonFinalInTBD = false
                if let parser = parser {
                    let defaultModule = parser.defaultModule
                    var pathComponents = [String]()
                    if !defaultModule.isEmpty { pathComponents.append(defaultModule) }
                    let enc = getEnclosingPath()
                    if !enc.isEmpty { pathComponents.append(enc) }
                    pathComponents.append(name)
                    let fullClassName = pathComponents.joined(separator: ".")
                    
                    if parser.nonFinalClasses.contains(fullClassName) {
                        isNonFinalInTBD = true
                    }
                    
                    func scanForSubclass(node: TypeNode) {
                        if node.kind == "class", let base = node.baseClass {
                            let cleanBase = base.components(separatedBy: ".").last ?? ""
                            if cleanBase == name {
                                hasSubclass = true
                            }
                        }
                        for nested in node.nestedTypes.values {
                            scanForSubclass(node: nested)
                        }
                    }
                    for mod in parser.modules.values {
                        scanForSubclass(node: mod)
                    }
                }
                if !hasSubclass && !isNonFinalInTBD {
                    classVisibility = "final " + classVisibility
                }
            }
            let fixedLayoutAttr = (finalKind == "class") ? "@_fixed_layout " : ""
            lines.append("\(indent)\(fixedLayoutAttr)\(classVisibility) \(finalKind) \(displayTypeName)\(inheritance) {")
        }
        
        let nextIndent = indent + "    "
        
        if isProtocol && isGeneric {
            let count = getGenericCount(parser: parser)
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            for i in 0..<count {
                let paramName = i < placeholders.count ? placeholders[i] : "A\(i)"
                lines.append("\(nextIndent)associatedtype \(paramName)")
            }
        }
        
        // ContiguousBytes.withUnsafeBytes is declared `rethrows`; the ABI sometimes exposes a
        // spurious `throws`-only overload for it (its actual witness in the real module has no
        // separate throws-only entry) which can't coexist with the synthesized rethrows fallback
        // below — drop it so only the rethrows-conforming version is emitted.
        let membersFilteredForContiguousBytes: [MemberKind]
        if hasConformance("ContiguousBytes") {
            membersFilteredForContiguousBytes = members.values.filter {
                if case .method(let n, let sig, _) = $0 {
                    return !((n == "withUnsafeBytes" || n.hasPrefix("withUnsafeBytes<")) && !sig.contains("rethrows"))
                }
                return true
            }
        } else {
            membersFilteredForContiguousBytes = Array(members.values)
        }
        let sortedMembers = membersFilteredForContiguousBytes.sorted(by: {
            switch ($0, $1) {
            case (.enumCase(let n1, _, _), .enumCase(let n2, _, _)): return n1 < n2
            case (.enumCase(_, _, _), _): return true
            case (_, .enumCase(_, _, _)): return false
            case (.initializer(_), .initializer(_)): return false
            case (.initializer(_), _): return true
            case (_, .initializer(_)): return false
            case (.property(let n1, _, _, _), .property(let n2, _, _, _)): return n1 < n2
            default: return false
            }
        })

        if isEnum && !hasCases {
            lines.append("\(nextIndent)case _mock")
        }

        var generatedMethods = Set<String>()
        var generatedInitializers = Set<String>()
        var generatedProperties = Set<String>()
        var generatedEnumCases = Set<String>()

        for member in sortedMembers {
            let isOverride: Bool
            switch member {
            case .initializer(let sig):
                if baseClass == "NSObject" && sig.starts(with: "init()") {
                    isOverride = true
                } else if baseClass != nil && sig.contains("init(symbol:") && sig.contains("converter:") {
                    isOverride = true
                } else {
                    isOverride = false
                }
            case .property(let n, _, _, _):
                isOverride = !isObjcBridged && baseClass == "NSObject" && ["description", "hash", "debugDescription"].contains(n)
            case .method(let n, let sig, _):
                if !isObjcBridged && baseClass == "NSObject" && ["isEqual"].contains(n) {
                    isOverride = true
                } else if baseClass != nil && n == "baseUnit" {
                    isOverride = true
                } else if baseClass == "Foundation.Dimension" && n == "encode" && sig.contains("NSCoder") {
                    isOverride = true
                } else {
                    isOverride = false
                }
            default:
                isOverride = false
            }
            
            let overrideMod = isOverride ? "override " : ""
            
            switch member {
            case .enumCase(let name, let payload, let hasLabel):
                if generatedEnumCases.contains(name) { continue }
                generatedEnumCases.insert(name)
                var indirectPrefix = ""
                if self.kind == "enum", let payload = payload {
                    if payload.replaceWord(self.name, with: "").count < payload.count {
                        indirectPrefix = "indirect "
                    }
                }
                if let payload = payload {
                    let cleanPayload = payload.replaceWord(name, with: "").replaceWord("Self", with: "")
                    var topLevelCommas = 0
                    var depth = 0
                    for c in cleanPayload {
                        if c == "(" || c == "<" || c == "[" { depth += 1 }
                        else if c == ")" || c == ">" || c == "]" { depth -= 1 }
                        else if c == "," && depth == 0 {
                            topLevelCommas += 1
                        }
                    }
                    if topLevelCommas == 0 {
                        if hasLabel {
                            lines.append("\(nextIndent)\(indirectPrefix)case \(escapeKeyword(name))(\(name): \(cleanPayload))")
                        } else {
                            lines.append("\(nextIndent)\(indirectPrefix)case \(escapeKeyword(name))(_: \(cleanPayload))")
                        }
                    } else {
                        lines.append("\(nextIndent)\(indirectPrefix)case \(escapeKeyword(name))(\(cleanPayload))")
                    }
                } else {
                    lines.append("\(nextIndent)case \(escapeKeyword(name))")
                }
            case .initializer(let sig):
                var cleanedSig = injectDefaultArguments(signature: sig, methodName: "init", isStatic: false, parser: parser)
                
                var initGenericInScope = Set<String>()
                if let openAngle = cleanedSig.firstIndex(of: "<"),
                   let openParen = cleanedSig.firstIndex(of: "("),
                   openAngle < openParen {
                    var depth = 0
                    var closeAngle: String.Index? = nil
                    var i = openAngle
                    while i < openParen {
                        if cleanedSig[i] == "<" { depth += 1 }
                        else if cleanedSig[i] == ">" {
                            depth -= 1
                            if depth == 0 { closeAngle = i; break }
                        }
                        i = cleanedSig.index(after: i)
                    }
                    if let ca = closeAngle {
                        let inside = String(cleanedSig[cleanedSig.index(after: openAngle)..<ca])
                        for param in inside.components(separatedBy: ",") {
                            var p = param.trimmingCharacters(in: .whitespaces)
                            if p.hasPrefix("each ") {
                                p = String(p.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                            }
                            if !p.isEmpty { initGenericInScope.insert(p) }
                        }
                    }
                }
                let effectiveScope = inScope.union(initGenericInScope)

                if isProtocol {
                    cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf(validAssoc: getAllAssociatedTypes(parser: parser))
                    cleanedSig = cleanedSig.replaceWord("A", with: "Self")
                    cleanedSig = cleanedSig.replaceMultiSegmentSelfPathsWithAny()
                } else {
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny(inScope: effectiveScope)
                }
                
                let localCleanScope = { (s: String) -> String in
                    var res = s
                    let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                    for p in placeholders {
                        if !effectiveScope.contains(p) {
                            res = res.replaceWord(p, with: "Any")
                        }
                    }
                    return res
                }
                cleanedSig = localCleanScope(cleanedSig)
                
                for param in initGenericInScope {
                    var isPack = false
                    if let openBracket = cleanedSig.firstIndex(of: "<"),
                       let closeBracket = cleanedSig.firstIndex(of: ">"),
                       openBracket < closeBracket {
                        let bracketContent = String(cleanedSig[openBracket...closeBracket])
                        if bracketContent.contains("each \(param)") {
                            isPack = true
                        }
                    }
                    if isPack {
                        cleanedSig = cleanedSig.replacingOccurrences(of: "<\(param)>", with: "<each \(param)>")
                        cleanedSig = cleanedSig.replacingOccurrences(of: "<\(param),", with: "<each \(param),")
                        cleanedSig = cleanedSig.replacingOccurrences(of: ", \(param),", with: ", each \(param),")
                        cleanedSig = cleanedSig.replacingOccurrences(of: ", \(param)>", with: ", each \(param)>")
                        cleanedSig = cleanedSig.replacingOccurrences(of: "repeat \(param)", with: "repeat each \(param)")
                        cleanedSig = cleanedSig.replacingOccurrences(of: "repeat  \(param)", with: "repeat each \(param)")
                        // "repeat each A.Member" parses as "repeat (each A.Member)" — invalid,
                        // since a pack-expansion member access must bind the pack element first:
                        // "repeat (each A).Member". Parenthesize when a member access follows.
                        cleanedSig = cleanedSig.replacingOccurrences(of: "repeat each \(param).", with: "repeat (each \(param)).")
                        
                        if let whereRange = cleanedSig.range(of: " where ") {
                            let before = String(cleanedSig[..<whereRange.upperBound])
                            let after = String(cleanedSig[whereRange.upperBound...])
                            let constraints = after.splitByCommaRespectingBrackets()
                            var newConstraints = [String]()
                            for c in constraints {
                                let trimmed = c.trimmingCharacters(in: .whitespaces)
                                if trimmed.contains(param) && !trimmed.contains("repeat each \(param)") {
                                    let replaced = trimmed.replaceWord(param, with: "repeat each \(param)")
                                    newConstraints.append(replaced)
                                } else {
                                    newConstraints.append(c)
                                }
                            }
                            cleanedSig = before + newConstraints.joined(separator: ", ")
                        }
                    }
                }
                
                var normalizedSig = cleanedSig
                if let parser = parser, !parser.defaultModule.isEmpty {
                    normalizedSig = normalizedSig.replacingOccurrences(of: "\(parser.defaultModule).", with: "")
                }
                normalizedSig = normalizedSig.replacingOccurrences(of: " ", with: "")
                if generatedInitializers.contains(normalizedSig) { continue }
                generatedInitializers.insert(normalizedSig)
                
                if isProtocol { lines.append("\(nextIndent)\(cleanedSig)") }
                else if isEnum {
                    lines.append("\(nextIndent)public \(cleanedSig) { fatalError() }")
                }
                else if isObjcBridged && self.kind == "class" {
                    // Swift extension on an ObjC class: use @nonobjc convenience init to produce
                    // the So-prefixed mangled symbols without conflicting with the ObjC -init.
                    lines.append("\(nextIndent)@nonobjc public \(overrideMod)convenience \(cleanedSig) { fatalError() }")
                } else {
                    // For classes, ensure the init body is non-empty to force symbol emission.
                    // If it's NSObject, use super.init(), otherwise fatalError().
                    let initBody = isOverride && cleanedSig.starts(with: "init()") ? "{ super.init() }" : "{ fatalError() }"
                    let isRequired = self.kind == "class" && (cleanedSig.contains("init(from:") || cleanedSig.contains("init?(coder:") || cleanedSig.contains("init(coder:"))
                    let requiredMod = isRequired ? "required " : ""
                    lines.append("\(nextIndent)\(requiredMod)public \(overrideMod)\(cleanedSig) \(initBody)")
                }
            case .property(let n, let t, let isReadOnly, let isStatic):
                // Subscripts can have multiple overloads (e.g. subscript([Int]) and subscript(Int...))
                // so include the type signature in the dedup key to allow both to emit.
                let isSubscriptMember = n == "subscript" || n == "`subscript`"
                let propKey = isSubscriptMember
                    ? "\(isStatic ? "static" : "instance")-\(n)-\(t)"
                    : "\(isStatic ? "static" : "instance")-\(n)"
                if generatedProperties.contains(propKey) { continue }
                generatedProperties.insert(propKey)
                
                // Like rawValue below: allCases is normally compiler-synthesized for a
                // CaseIterable enum, but that synthesis requires every case to carry no
                // associated value — for a payload-carrying enum (see hasPayloadCase above)
                // it must be a real, manually-implemented static member instead (confirmed via
                // the real ABI: Google_Protobuf_NullValue exports both an allCases getter AND
                // its property descriptor, which wouldn't exist for compiler-synthesized code).
                if n == "allCases" && isEnum && !hasPayloadCase { continue }
                // Normally `rawValue`/`init(rawValue:)` are compiler-synthesized from the
                // `: Int`-style raw-type inheritance and shouldn't be redeclared. But when the
                // enum has a payload-carrying case (see hasPayloadCase above), the raw type is
                // deliberately NOT in the inheritance list — Swift disallows raw-type
                // inheritance on such enums — so `rawValue` must be rendered as a real,
                // manually-implemented member instead, matching the real ABI.
                if n == "rawValue" && isEnum && !hasPayloadCase { continue }
                // NSObject already declares description/hash/debugDescription; a Swift
                // extension on an ObjC-bridged class can't override them (extensions can't
                // override at all), and re-declaring them without `override` conflicts with the
                // inherited member — skip, relying on the real ObjC class's own inheritance.
                if isObjcBridged && baseClass == "NSObject" && ["description", "hash", "debugDescription"].contains(n) { continue }

                var t = t
                // ChartContent's `body` requirement is typed `Self.Body: ChartContent`, but its
                // ABI-visible witness never reveals a concrete Body type (mark types like
                // AreaMark/LineMark/PointMark render entirely through the static
                // _makeChartContent/_layoutChartContent/_renderChartContent hooks) — the raw
                // demangled type is a placeholder path like "A.Body" that later collapses to a
                // bare `Any`, which can't satisfy an associated-type-typed requirement.
                // `Swift.Never` genuinely conforms to ChartContent in the real module.
                if n == "body" && hasConformance("ChartContent") &&
                   (t == "Any" || t.range(of: "^[A-Z][A-Za-z0-9_]*\\.Body$", options: .regularExpression) != nil) {
                    t = "Never"
                }
                // VectorizedAreaPlotContent/VectorizedBarPlotContent/etc. have a real `body:
                // some Charts.ChartContent`, but simplifyType's `some`-return heuristic can't
                // see the enclosing type's conformances at parse time and defaults every
                // `body`-named opaque return to `some SwiftUI.View` — wrong here since these
                // types conform to ChartContent/VectorizedChartContent, not View.
                if n == "body" && t == "some SwiftUI.View" &&
                   (hasConformance("ChartContent") || hasConformance("VectorizedChartContent")) &&
                   !hasConformance("View") && !hasConformance("SwiftUI.View") {
                    t = "some Charts.ChartContent"
                }
                // SpeechModule requires `var results: Self.Results` where `associatedtype
                // Results: Sendable, AsyncSequence` — same `some`-return heuristic gap as
                // ChartContent's body above, defaulting to `some Sendable` (satisfies Sendable
                // but not AsyncSequence). An opaque `some ... AsyncSequence` return needs a
                // concrete underlying type at the fatalError() call site to type-check (a
                // Never-returning body alone can't establish one) — use AsyncStream<Never>.
                if (n == "countProvider" || n == "durationProvider") && t == "some Sendable" {
                    if n == "countProvider" { t = "SleepMetrics.Counts" }
                    if n == "durationProvider" { t = "SleepMetrics.Durations" }
                }
                var resultsElementType = "Never"
                if n == "results" && t == "some Sendable" && hasConformance("SpeechModule") {
                    t = "some Sendable & AsyncSequence"
                    // SpeechModule's `associatedtype Result: SpeechModuleResult where Self.Result
                    // == Self.Results.Element` needs the AsyncSequence's Element to match a real
                    // SpeechModuleResult-conforming nested type (usually named "Result", but
                    // EndpointDetector names its own "ModuleOutput") — find it so the same-type
                    // constraint infers correctly instead of leaving Result unresolved.
                    if let resultTypeName = self.nestedTypes.values.first(where: { $0.conformances.contains("SpeechModuleResult") })?.name {
                        resultsElementType = resultTypeName
                    }
                }
                var cleanT = t
                let fullEnclosingPath = self.getEnclosingPath().isEmpty ? self.name : self.getEnclosingPath() + "." + self.name
                cleanT = cleanT.stripParentPrefix(parentName: fullEnclosingPath)

                cleanT = cleanT.replaceSelfPattern(parentName: self.name, enclosingPath: self.getEnclosingPath(), replaceWith: selfReplaceWith, defaultModule: parser?.defaultModule ?? "")
                cleanT = cleanT.replaceWordWithoutGeneric(self.name, with: selfReplaceWith, allowPrecededByDot: false)

                // Find the first `{` outside any `<...>` generic clause.
                // Preserve `Pack{A}` braces inside `<...>` for the Pack-fix regex in postProcess.
                var propBrace: String.Index? = nil
                var propAngleDepth = 0
                for propIdx in cleanT.indices {
                    switch cleanT[propIdx] {
                    case "<": propAngleDepth += 1
                    case ">": if propAngleDepth > 0 { propAngleDepth -= 1 }
                    case "{": if propAngleDepth == 0 { propBrace = propIdx; break }
                    default: break
                    }
                    if propBrace != nil { break }
                }
                if let brace = propBrace {
                    cleanT = String(cleanT[..<brace]).trimmingCharacters(in: .whitespaces)
                }
                // Remove `}` outside `<...>` only.
                var propCleaned = ""
                var propAdepth = 0
                for ch in cleanT {
                    switch ch {
                    case "<": propAdepth += 1; propCleaned.append(ch)
                    case ">": if propAdepth > 0 { propAdepth -= 1 }; propCleaned.append(ch)
                    case "}": if propAdepth > 0 { propCleaned.append(ch) }
                    default: propCleaned.append(ch)
                    }
                }
                cleanT = propCleaned

                if isProtocol {
                    cleanT = cleanT.replacePlaceholderDotsWithSelf(validAssoc: getAllAssociatedTypes(parser: parser))
                    cleanT = cleanT.replaceWord("A", with: "Self")
                    cleanT = cleanT.replaceMultiSegmentSelfPathsWithAny()
                } else if !isSubscriptMember {
                    cleanT = cleanT.replaceGenericPlaceholderPathsWithAny(inScope: inScope)
                    cleanT = cleanScope(cleanT)
                } else {
                    var subGenericInScope = Set<String>()
                    if let openAngle = cleanT.firstIndex(of: "<"),
                       let openParen = cleanT.firstIndex(of: "("),
                       openAngle < openParen {
                        var depth = 0
                        var closeAngle: String.Index? = nil
                        var i = openAngle
                        while i < openParen {
                            if cleanT[i] == "<" { depth += 1 }
                            else if cleanT[i] == ">" {
                                depth -= 1
                                if depth == 0 { closeAngle = i; break }
                            }
                            i = cleanT.index(after: i)
                        }
                        if let ca = closeAngle {
                            let inside = String(cleanT[cleanT.index(after: openAngle)..<ca])
                            for param in inside.components(separatedBy: ",") {
                                let p = param.trimmingCharacters(in: .whitespaces)
                                if !p.isEmpty { subGenericInScope.insert(p) }
                            }
                        }
                    }
                    let effectiveScope = inScope.union(subGenericInScope)
                    
                    let localCleanScope = { (s: String) -> String in
                        var res = s
                        let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                        for p in placeholders {
                            if !effectiveScope.contains(p) {
                                res = res.replaceWord(p, with: "Any")
                            }
                        }
                        return res
                    }
                    cleanT = localCleanScope(cleanT)
                }

                let staticMod = isStatic ? "static " : ""
                let isFinal = isSubscriptMember ? (self.finalMembers.contains("\(n)[\(t)]") || self.finalMembers.contains("\(n)[\(cleanT)]")) : self.finalMembers.contains(n)
                let finalMod = (!isStatic && self.kind == "class" && isFinal) ? "final " : ""
                if n == "subscript" || n == "`subscript`" {
                    lines.append(renderSubscript(cleanT: cleanT, isProtocol: isProtocol, isReadOnly: isReadOnly, staticMod: staticMod, finalMod: finalMod, overrideMod: overrideMod, nextIndent: nextIndent, inScope: inScope))
                } else if isProtocol {
                    let suffix = isReadOnly ? "{ get }" : "{ get set }"
                    lines.append("\(nextIndent)\(staticMod)var \(n): \(cleanT) \(suffix)")
                } else {
                    let defaultVal = TypeNode.defaultReturnValue(for: cleanT)
                    var getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
                    if n == "results" && t == "some Sendable & AsyncSequence" {
                        getter = "{ return AsyncStream<\(resultsElementType)> { _ in } }"
                    }
                    let hasLifetime = isReadOnly && isLifetimeSpanType(cleanT)
                    let getPrefix = hasLifetime ? "@_lifetime(borrow self) get" : "get"
                    let suffix = isReadOnly ? "{ \(getPrefix) \(getter) }" : "{ \(getPrefix) \(getter) set {} }"
                    if cleanT.contains("Mutex<") || cleanT.contains("Synchronization.Mutex<") {
                        lines.append("\(nextIndent)public \(finalMod)\(overrideMod)\(staticMod)let \(n): \(cleanT)")
                    } else {
                        // Actor's own `unownedExecutor` requirement is declared `nonisolated`
                        // in the protocol; an actor's witness for it must match, or the
                        // compiler rejects the Actor conformance as isolation-unsafe.
                        let nonisolatedMod = (finalKind == "actor" && n == "unownedExecutor") ? "nonisolated " : ""
                        lines.append("\(nextIndent)\(nonisolatedMod)public \(finalMod)\(overrideMod)\(staticMod)var \(n): \(cleanT) \(suffix)")
                    }
                }
            case .method(let n, let sig, var isStatic):
                // NSObject already declares isEqual(_:); same reasoning as
                // description/hash/debugDescription above — skip for ObjC-bridged extensions.
                if isObjcBridged && baseClass == "NSObject" && n == "isEqual" { continue }
                var cleanedSig = sig.replacingOccurrences(of: " infix", with: "")
                let cleanN = n.replacingOccurrences(of: " infix", with: "").replacingOccurrences(of: " prefix", with: "").replacingOccurrences(of: " postfix", with: "").trimmingCharacters(in: .whitespaces)
                let isOperator = !cleanN.isEmpty && cleanN.allSatisfy { "+-*/=<>&|^~%!?.".contains($0) }
                if isOperator {
                    isStatic = true
                }
                cleanedSig = injectDefaultArguments(signature: cleanedSig, methodName: cleanN, isStatic: isStatic, parser: parser)
                
                var lifetimeAttr = ""
                if let arrowRange = cleanedSig.range(of: "->", options: .backwards) {
                    let retPart = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    if isLifetimeSpanType(retPart) {
                        lifetimeAttr = "@_lifetime(borrow self) "
                    }
                }
                var funcModifier = ""
                if cleanedSig.contains(" prefix(") {
                    cleanedSig = cleanedSig.replacingOccurrences(of: " prefix(", with: "(")
                    funcModifier = "prefix "
                } else if cleanedSig.contains(" postfix(") {
                    cleanedSig = cleanedSig.replacingOccurrences(of: " postfix(", with: "(")
                    funcModifier = "postfix "
                }

                // Strip the parent's fully qualified prefix from any nested types
                let fullEnclosingPath = self.getEnclosingPath().isEmpty ? self.name : self.getEnclosingPath() + "." + self.name
                cleanedSig = cleanedSig.stripParentPrefix(parentName: fullEnclosingPath)
                
                cleanedSig = cleanedSig.replaceSelfPattern(parentName: self.name, enclosingPath: self.getEnclosingPath(), replaceWith: selfReplaceWith, defaultModule: parser?.defaultModule ?? "")
                cleanedSig = cleanedSig.replaceWordWithoutGeneric(self.name, with: selfReplaceWith, allowPrecededByDot: false)
                
                // Only a method generic param literally named bare "A" can collide with the
                // protocol's own "A" == Self placeholder — see the matching, more detailed
                // comment where this same guard is used in generateOneExtension. Checking for
                // "A1" here was a false positive: replaceWord already word-boundary-skips it.
                let shouldReplaceA = !cleanedSig.hasGenericPlaceholderInBrackets(p: "A")
                if isProtocol {
                    cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf(validAssoc: getAllAssociatedTypes(parser: parser))
                    if shouldReplaceA {
                        cleanedSig = cleanedSig.replaceWord("A", with: "Self")
                    }
                    cleanedSig = cleanedSig.replaceMultiSegmentSelfPathsWithAny()

                    // Remove "A" and "Self" from the method generic parameter list (it represents Self)
                    if let openIdx = cleanedSig.firstIndex(of: "<"),
                       let parenIdx = cleanedSig.firstIndex(of: "("),
                       openIdx < parenIdx {
                        let methodName = String(cleanedSig[..<parenIdx]).trimmingCharacters(in: .whitespaces)
                        if methodName.contains("<") {
                            if let closeIdx = cleanedSig.firstIndex(of: ">"), openIdx < closeIdx {
                                let inside = String(cleanedSig[cleanedSig.index(after: openIdx)..<closeIdx])
                                let parts = inside.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                                let filtered = parts.filter { 
                                    if $0 == "Self" { return false }
                                    if $0 == "A" && shouldReplaceA { return false }
                                    return true
                                }
                                if filtered.isEmpty {
                                    cleanedSig = String(cleanedSig[..<openIdx]) + String(cleanedSig[cleanedSig.index(after: closeIdx)...])
                                } else {
                                    cleanedSig = String(cleanedSig[..<openIdx]) + "<\(filtered.joined(separator: ", "))>" + String(cleanedSig[cleanedSig.index(after: closeIdx)...])
                                }
                            }
                        }
                    }
                }
                // Extract method-level generic params (e.g. <A> in withLock<A>) and add to local scope
                // so cleanScope doesn't erase them to Any.
                var methodGenericInScope = Set<String>()
                if let openAngle = cleanedSig.firstIndex(of: "<") {
                    var depth = 0
                    var closeAngle: String.Index? = nil
                    var i = openAngle
                    while i < cleanedSig.endIndex {
                        if cleanedSig[i] == "<" { depth += 1 }
                        else if cleanedSig[i] == ">" {
                            depth -= 1
                            if depth == 0 { closeAngle = i; break }
                        }
                        i = cleanedSig.index(after: i)
                    }
                    if let ca = closeAngle {
                        let inside = String(cleanedSig[cleanedSig.index(after: openAngle)..<ca])
                        let beforeWhere: String
                        if let whereRange = inside.range(of: " where ") {
                            beforeWhere = String(inside[..<whereRange.lowerBound])
                        } else if let whereRange = inside.range(of: "where ") {
                            beforeWhere = String(inside[..<whereRange.lowerBound])
                        } else {
                            beforeWhere = inside
                        }
                        for param in beforeWhere.components(separatedBy: ",") {
                            var p = param.trimmingCharacters(in: .whitespaces)
                            if p.hasPrefix("each ") {
                                p = String(p.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                            }
                            if !p.isEmpty { methodGenericInScope.insert(p) }
                        }
                    }
                }
                let effectiveScope = inScope.union(methodGenericInScope)
                if !isProtocol {
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny(inScope: effectiveScope)
                }
                cleanedSig = {
                    var res = cleanedSig
                    let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                    for p in placeholders {
                        if !effectiveScope.contains(p) {
                            res = res.replaceWord(p, with: "Any")
                        }
                    }
                    return res
                }()
                
                for param in methodGenericInScope {
                    var isPack = false
                    if let openBracket = cleanedSig.firstIndex(of: "<"),
                       let closeBracket = cleanedSig.firstIndex(of: ">"),
                       openBracket < closeBracket {
                        let bracketContent = String(cleanedSig[openBracket...closeBracket])
                        if bracketContent.contains("each \(param)") {
                            isPack = true
                        }
                    }
                    if isPack {
                        cleanedSig = cleanedSig.replacingOccurrences(of: "<\(param)>", with: "<each \(param)>")
                        cleanedSig = cleanedSig.replacingOccurrences(of: "<\(param),", with: "<each \(param),")
                        cleanedSig = cleanedSig.replacingOccurrences(of: ", \(param),", with: ", each \(param),")
                        cleanedSig = cleanedSig.replacingOccurrences(of: ", \(param)>", with: ", each \(param)>")
                        cleanedSig = cleanedSig.replacingOccurrences(of: "repeat \(param)", with: "repeat each \(param)")
                        cleanedSig = cleanedSig.replacingOccurrences(of: "repeat  \(param)", with: "repeat each \(param)")
                        // "repeat each A.Member" parses as "repeat (each A.Member)" — invalid,
                        // since a pack-expansion member access must bind the pack element first:
                        // "repeat (each A).Member". Parenthesize when a member access follows.
                        cleanedSig = cleanedSig.replacingOccurrences(of: "repeat each \(param).", with: "repeat (each \(param)).")
                        
                        if let whereRange = cleanedSig.range(of: " where ") {
                            let before = String(cleanedSig[..<whereRange.upperBound])
                            let after = String(cleanedSig[whereRange.upperBound...])
                            let constraints = after.splitByCommaRespectingBrackets()
                            var newConstraints = [String]()
                            for c in constraints {
                                let trimmed = c.trimmingCharacters(in: .whitespaces)
                                if trimmed.contains(param) && !trimmed.contains("repeat each \(param)") {
                                    let replaced = trimmed.replaceWord(param, with: "repeat each \(param)")
                                    newConstraints.append(replaced)
                                } else {
                                    newConstraints.append(c)
                                }
                            }
                            cleanedSig = before + newConstraints.joined(separator: ", ")
                        }
                    }
                }

                if cleanN == "==" && (sig.contains(".Type") || sig.contains(".`Type`")) {
                    continue
                }

                let genericPlaceholders = ["A", "B", "C", "D"]
                var paramsToRemoveFromBrackets = [String]()
                for p in genericPlaceholders {
                    let variations = [p, "\(p)1", "\(p)2", "\(p)11", "\(p)21", "\(p)31"]
                    for v in variations {
                        if cleanedSig.hasGenericPlaceholderInBrackets(p: v) {
                            if inScope.contains(v) {
                                paramsToRemoveFromBrackets.append(v)
                            } else {
                                cleanedSig = cleanedSig.replacingOccurrences(of: "<\(v)>", with: "<Generic\(p)>")
                                cleanedSig = cleanedSig.replacingOccurrences(of: "<\(v),", with: "<Generic\(p),")
                                cleanedSig = cleanedSig.replacingOccurrences(of: ", \(v)>", with: ", Generic\(p)>")
                                cleanedSig = cleanedSig.replacingOccurrences(of: ", \(v),", with: ", Generic\(p),")
                                cleanedSig = cleanedSig.replaceWord(v, with: "Generic\(p)")
                            }
                        }
                    }
                }
                
                for p in paramsToRemoveFromBrackets {
                    if let openBracket = cleanedSig.firstIndex(of: "<"),
                       let closeBracket = cleanedSig.firstIndex(of: ">"),
                       openBracket < closeBracket {
                        let prefix = cleanedSig[..<openBracket]
                        var list = String(cleanedSig[cleanedSig.index(after: openBracket)..<closeBracket])
                        let suffix = cleanedSig[closeBracket...]
                        
                        list = list.replaceWord(p, with: "")
                        list = list.replacingOccurrences(of: ",,", with: ",")
                        list = list.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
                        
                        if list.isEmpty {
                            cleanedSig = String(prefix) + String(suffix.dropFirst())
                        } else {
                            cleanedSig = String(prefix) + "<\(list)>" + String(suffix.dropFirst())
                        }
                    }
                }
                cleanedSig = cleanedSig.replacingOccurrences(of: "<>", with: "")
                
                // Fix nested iterator specialization
                cleanedSig = cleanedSig.replacingOccurrences(of: "Iterator<GenericA>", with: "Iterator")
                cleanedSig = cleanedSig.replacingOccurrences(of: "Iterator<Any>", with: "Iterator")

                var methodGenericParams = [String]()
                let potentialParams = ["A1", "B1", "C1", "D1", "A2", "B2", "C2", "D2"]
                for p in potentialParams {
                    if cleanedSig.replaceWord(p, with: "").count < cleanedSig.count {
                        methodGenericParams.append(p)
                    }
                }
                if !methodGenericParams.isEmpty {
                    if let parenIdx = cleanedSig.firstIndex(of: "(") {
                        let methodName = String(cleanedSig[..<parenIdx]).trimmingCharacters(in: .whitespaces)
                        let methodArgs = String(cleanedSig[parenIdx...])
                        if methodName.contains("<") {
                            if let closeAngleIdx = methodName.firstIndex(of: ">") {
                                let baseName = String(methodName[..<closeAngleIdx])
                                var newParams = [String]()
                                for mp in methodGenericParams {
                                    if !baseName.contains(mp) {
                                        newParams.append(mp)
                                    }
                                }
                                if !newParams.isEmpty {
                                    cleanedSig = baseName + ", " + newParams.joined(separator: ", ") + ">" + methodArgs
                                }
                            }
                        } else {
                            cleanedSig = methodName + "<\(methodGenericParams.joined(separator: ", "))>" + methodArgs
                        }
                    }
                }
                
                // Prune GenericX params from the method's <...> bracket that are no longer
                // referenced in the function body (args + return type). This happens when e.g.
                // isCompatible<A>(with: A.Type) → GenericA gets renamed but A.Type → Any,
                // leaving GenericA unused → compiler error "generic parameter not used in signature".
                cleanedSig = cleanedSig.removingUnusedMethodGenericParams()

                var normalizedSig = cleanedSig
                if let parser = parser, !parser.defaultModule.isEmpty {
                    normalizedSig = normalizedSig.replacingOccurrences(of: "\(parser.defaultModule).", with: "")
                }
                normalizedSig = normalizedSig.replacingOccurrences(of: " ", with: "")
                let methodKey = "\(isStatic ? "static" : "instance")-\(normalizedSig)"
                if generatedMethods.contains(methodKey) {
                    continue
                }
                generatedMethods.insert(methodKey)

                if cleanN == "==" && cleanedSig.contains("(") {
                    if isProtocol { continue }
                    
                    let parts = cleanedSig.components(separatedBy: "(")
                    let argsPart = parts.dropFirst().joined(separator: "(")
                    let sigParts = argsPart.components(separatedBy: " -> ")
                    let returnType = sigParts.count > 1 ? sigParts.last!.replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces) : "Bool"
                    let allArgs = sigParts[0].trimmingCharacters(in: .whitespaces)
                    
                    let argTypes = allArgs.components(separatedBy: ", ")
                    if argTypes.count == 2 {
                        var left = argTypes[0].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)
                        var right = argTypes[1].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)
                        
                        if left.contains(":") { left = String(left.components(separatedBy: ":").last!) }
                        if right.contains(":") { right = String(right.components(separatedBy: ":").last!) }
                        
                        left = left.stripModuleBeforeSubscriptOrGeneric()
                        right = right.stripModuleBeforeSubscriptOrGeneric()
                        
                        if left == "Type" { left = "`Type`" }
                        if right == "Type" { right = "`Type`" }
                        if left.hasSuffix(".Type") && !left.contains("`Type`") { left = left.replacingOccurrences(of: ".Type", with: ".`Type`") }
                        if right.hasSuffix(".Type") && !right.contains("`Type`") { right = right.replacingOccurrences(of: ".Type", with: ".`Type`") }

                        let paramPrefix = self.hasConformance("~Copyable") ? "borrowing " : ""
                        let leftType = paramPrefix + ((left == right && self.kind != "class") ? "Self" : left)
                        let rightType = paramPrefix + ((left == right && self.kind != "class") ? "Self" : right)
                        lines.append("\(nextIndent)public static func == (lhs: \(leftType), rhs: \(rightType)) -> \(returnType) { \(returnType == "Bool" ? "true" : "fatalError()") }")
                        continue
                    }
                }
                
                let staticMod = isStatic ? "static " : ""
                let finalMod = (!isStatic && self.kind == "class" && self.finalMembers.contains(sig)) ? "final " : ""
                if isProtocol {
                    let prunedSig = pruneInvalidSelfConstraints(from: cleanedSig, parser: parser)
                    lines.append("\(nextIndent)\(lifetimeAttr)\(staticMod)\(funcModifier)func \(prunedSig)")
                } else {
                    var returnType = "Void"
                    if let parenIdx = cleanedSig.firstIndex(of: ")") {
                        let afterParen = cleanedSig[parenIdx...]
                        if let arrowIdx = afterParen.range(of: "->") {
                            returnType = String(afterParen[arrowIdx.upperBound...]).trimmingCharacters(in: .whitespaces)
                        }
                    }
                    let defaultVal = TypeNode.defaultReturnValue(for: returnType)
                    let body = defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }"
                    let finalBody = defaultVal == "fatalError()" ? "{ fatalError() }" : body
                    lines.append("\(nextIndent)\(lifetimeAttr)public \(finalMod)\(overrideMod)\(staticMod)\(funcModifier)func \(cleanedSig) \(finalBody)") 
                }
            case .associatedType(let code):
                lines.append("\(nextIndent)\(code)")
            case .other(let desc):
                lines.append("\(nextIndent)// \(desc)")
            }
        }

        // Render nested types after members (enum cases must come before nested types in enums)
        if !isProtocol {
            let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
            for nested in sortedNested {
                lines.append(nested.generateCode(indent: nextIndent, parser: parser))
            }
        }

        // Associated type fallbacks for common run() patterns
        if typeName == "Untyped" || typeName == "UntypedStreamable" {
             lines.append("\(nextIndent)public typealias Content = Any")
             lines.append("\(nextIndent)public typealias ChatStringParameters = Any")
             lines.append("\(nextIndent)public typealias ChatStringStreamParameters = Any")
             lines.append("\(nextIndent)public typealias CompletionStringParameters = Any")
             lines.append("\(nextIndent)public typealias CompletionStringStreamParameters = Any")
        }

        // Add explicit conformance stubs for non-protocol types IF not already provided
        if !isProtocol {
            let hasInitFrom = members.values.contains { if case .initializer(let s) = $0, s.contains("init(from:") { return true }; return false }
            let hasEncodeTo = members.values.contains { if case .method(let n, _, _) = $0, n == "encode" { return true }; return false }
            let hasHashInto = members.values.contains { if case .method(let n, _, _) = $0, n == "hash" { return true }; return false }
            let hasCoderInit = members.values.contains { if case .initializer(let s) = $0, s.contains("init(coder:") { return true }; return false }
            let hasEncodeWith = members.values.contains { if case .method(let n, let s, _) = $0, n == "encode" && s.contains("with:") { return true }; return false }
            let hasDebugDescription = members.values.contains { if case .property(let n, _, _, _) = $0, n == "debugDescription" { return true }; return false }

            if (hasConformance("Decodable") || hasConformance("Codable")) && !hasInitFrom {
                let requiredMod = (kind == "class") ? "required " : ""
                lines.append("\(nextIndent)\(requiredMod)public init(from decoder: any Swift.Decoder) throws { fatalError() }")
            }
            if (hasConformance("Encodable") || hasConformance("Codable")) && !hasEncodeTo {
                lines.append("\(nextIndent)public func encode(to encoder: Swift.Encoder) throws { fatalError() }")
            }
            if hasConformance("Hashable") && !hasHashInto {
                lines.append("\(nextIndent)public func hash(into hasher: inout Hasher) { fatalError() }")
            }
            if hasConformance("CustomDebugStringConvertible") && !hasDebugDescription {
                lines.append("\(nextIndent)public var debugDescription: String { get { fatalError() } }")
            }
            let genericParamsList: String
            if typeName == "BidirectionalXPCServiceClientConnection" {
                genericParamsList = "<A, B>"
            } else if typeName == "CatalogAsset" {
                genericParamsList = "<A, B>"
            } else if typeName == "XPCServiceClientConnection" {
                genericParamsList = "<A>"
            } else if isGeneric {
                let ownCount = getOwnGenericCount(parser: parser)
                let parentCount = getParentGenericCount(parser: parser)
                if ownCount > 0 {
                    let placeholders = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
                    var params = [String]()
                    for i in 0..<ownCount {
                        params.append(placeholders[parentCount + i])
                    }
                    genericParamsList = "<\(params.joined(separator: ", "))>"
                } else {
                    genericParamsList = ""
                }
            } else {
                genericParamsList = ""
            }

            // For class types, don't auto-generate == — the TBD may not export it,
            // and adding it creates spurious extra symbols. For structs/enums it's always needed.
            if (hasConformance("Hashable") || hasConformance("Equatable")) && !hasEqualityOperator() && actualKind != "class" {
                let leftType = escapeKeyword(n) + genericParamsList
                let rightType = escapeKeyword(n) + genericParamsList
                lines.append("\(nextIndent)public static func ==(_ lhs: \(leftType), _ rhs: \(rightType)) -> Bool { fatalError() }")
            }
            // RawRepresentable: enums without a primitive raw type need explicit rawValue.
            // If the enum conforms to RawRepresentable but doesn't inherit from a primitive raw type
            // (like NS-bridged enums or custom RawRepresentable conformances), emit a rawValue property
            // with type inferred from init(rawValue:).
            var inheritsFromPrimitiveRawType = false
            if let raw = rawType {
                let cleanRaw = raw.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "Swift.", with: "")
                let validRawTypes: Set<String> = [
                    "Int", "Int8", "Int16", "Int32", "Int64",
                    "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
                    "Double", "Float", "Float16", "String", "Character"
                ]
                if validRawTypes.contains(cleanRaw) {
                    inheritsFromPrimitiveRawType = true
                }
            }
            if isEnum && hasConformance("RawRepresentable") && !inheritsFromPrimitiveRawType {
                let hasRawValueProp = members.values.contains {
                    if case .property(let pname, _, _, _) = $0, pname == "rawValue" { return true }
                    return false
                }
                var rawValueType = "String"
                let hasRawValueInit = members.values.contains { member in
                    if case .initializer(let s) = member, s.contains("rawValue:") {
                        if let range = s.range(of: "rawValue:") {
                            let after = s[range.upperBound...]
                            let scanner = String(after).trimmingCharacters(in: .whitespaces)
                            var typeStr = ""
                            var depth = 0
                            for char in scanner {
                                if char == "(" || char == "<" {
                                    depth += 1
                                } else if char == ")" || char == ">" {
                                    depth -= 1
                                    if depth < 0 { break }
                                } else if char == "," && depth == 0 {
                                    break
                                }
                                typeStr.append(char)
                            }
                            let trimmedType = typeStr.trimmingCharacters(in: .whitespaces)
                            if !trimmedType.isEmpty {
                                rawValueType = trimmedType
                                return true
                            }
                        }
                    }
                    return false
                }
                if !hasRawValueProp && hasRawValueInit {
                    lines.append("\(nextIndent)public var rawValue: \(rawValueType) { get { fatalError() } }")
                }
            }

            if hasConformance("Comparable") && !hasLessThanOperator() {
                let leftType = escapeKeyword(n) + genericParamsList
                let rightType = escapeKeyword(n) + genericParamsList
                lines.append("\(nextIndent)public static func <(_ lhs: \(leftType), _ rhs: \(rightType)) -> Bool { fatalError() }")
            }
            if hasConformance("CustomStringConvertible") && !hasDescriptionProperty() {
                lines.append("\(nextIndent)public var description: String { get { return \"\" } }")
            }
            // ContiguousBytes requires `withUnsafeBytes<R>(_:) rethrows -> R`, which CryptoKit's
            // conforming types (Nonce/Digest/SymmetricKey/etc.) never declare explicitly in their
            // own ABI-visible members — the real implementation is presumably synthesized from a
            // stored buffer. Emit a fatalError() stub purely for compile-time conformance.
            // ContiguousBytes.withUnsafeBytes is declared `rethrows`; a witness declared
            // `throws` (as several CryptoKit types' own ABI-visible overload is) doesn't satisfy
            // a `rethrows` requirement, so the exact-effect overload must always be present
            // alongside any throws-only overload already emitted from real ABI symbols.
            let hasRethrowingWithUnsafeBytes = self.members.values.contains {
                if case .method(let n, let sig, _) = $0 {
                    return (n == "withUnsafeBytes" || n.hasPrefix("withUnsafeBytes<")) && sig.contains("rethrows")
                }
                return false
            }
            if hasConformance("ContiguousBytes") && !hasRethrowingWithUnsafeBytes {
                lines.append("\(nextIndent)public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R { fatalError() }")
            }
            // NSCoding: open classes that NSObject subclasses need required init?(coder:) and encode(with:)
            // so that library-evolution dispatch thunks (Tj) are generated.
            // ObjC-bridged classes are extended via a Swift extension on an empty ObjC stub
            // (see the isObjcBridged branch above) — Swift extensions can't add `required`
            // initializers to an imported ObjC class, so use the same @nonobjc convenience-init
            // pattern the regular initializer-emission path uses for these.
            let isNSObjectBase = baseClass == "NSObject"
            if isNSObjectBase && hasConformance("NSCoding") {
                if !hasCoderInit {
                    if isObjcBridged {
                        lines.append("\(nextIndent)@nonobjc public convenience init?(coder: NSCoder) { fatalError() }")
                    } else {
                        lines.append("\(nextIndent)public required init?(coder: NSCoder) {}")
                    }
                } else {
                    // Replace non-required coder init with required version
                    // (done at emit time: mark existing coder init as required)
                }
                if !hasEncodeWith {
                    lines.append("\(nextIndent)\(isObjcBridged ? "@nonobjc public" : "open") func encode(with coder: NSCoder) {}")
                }
            }
            if hasConformance("Publisher") {
                let inferred = inferReceiveAssociatedTypes()
                if let output = inferred["Output"],
                   !self.members.keys.contains("Output") && !self.members.keys.contains("typealias Output") {
                    lines.append("\(nextIndent)public typealias Output = \(output)")
                }
                if let failure = inferred["Failure"],
                   !self.members.keys.contains("Failure") && !self.members.keys.contains("typealias Failure") {
                    lines.append("\(nextIndent)public typealias Failure = \(failure)")
                }
            }
            if hasConformance("Subscriber") {
                let inferred = inferSubscriberAssociatedTypes()
                if let input = inferred["Input"],
                   !self.members.keys.contains("Input") && !self.members.keys.contains("typealias Input") {
                    lines.append("\(nextIndent)public typealias Input = \(input)")
                }
                if let failure = inferred["Failure"],
                   !self.members.keys.contains("Failure") && !self.members.keys.contains("typealias Failure") {
                    lines.append("\(nextIndent)public typealias Failure = \(failure)")
                }
            }
            if hasConformance("CustomCombineIdentifierConvertible") &&
               !self.members.keys.contains("combineIdentifier") {
                lines.append("\(nextIndent)public \(actualKind == "class" ? "final " : "")var combineIdentifier: CombineIdentifier { get { CombineIdentifier() } }")
            }
            // TabularData's OptionalColumnProtocol requires `associatedtype WrappedElement`.
            // Conforming types (Column<A>, ColumnSlice<A>, DiscontiguousColumnSlice<A>) never
            // declare it explicitly — it's just their own bare first generic parameter — so
            // infer it the same way Combine's Publisher/Subscriber associated types are
            // inferred above.
            if hasConformance("OptionalColumnProtocol") && isGeneric &&
               !self.members.keys.contains("WrappedElement") && !self.members.keys.contains("typealias WrappedElement") {
                lines.append("\(nextIndent)public typealias WrappedElement = A")
            }
            // TipKit's RuleInput requires `associatedtype Value`. Conforming types
            // (Event<A>, Parameter<A>) satisfy it via their own generic parameter in the
            // real module, but the ABI doesn't reveal the exact substitution, so infer the
            // same way OptionalColumnProtocol's WrappedElement is inferred above.
            if hasConformance("RuleInput") && isGeneric &&
               !self.members.keys.contains("Value") && !self.members.keys.contains("typealias Value") {
                lines.append("\(nextIndent)public typealias Value = A")
            }

            // Synthesize missing protocol requirements to guarantee conformance
            for conf in self.conformances {
                let confBase = conf.stripGenericAngles()
                
                // Fallbacks for common external/system protocols
                if confBase == "View" || confBase == "SwiftUI.View" {
                    let hasBody = self.members.values.contains {
                        if case .property(let name, _, _, _) = $0 { return name == "body" }
                        return false
                    }
                    // Shape (and Animatable-via-Shape) provides View's `body` requirement via
                    // its own protocol-extension default (returning `some View`, actually
                    // `Never` under the hood via `_ShapeView`) — conforming types never declare
                    // their own `body`, so don't inject the EmptyView fallback here; it would
                    // conflict with Shape's real default.
                    let satisfiesBodyViaShape = hasConformance("Shape") || hasConformance("SwiftUI.Shape")
                    // A real `body` property (e.g. inherited from View's own requirement via
                    // inheritProtocolMembers, typed `some SwiftUI.View`) already determines
                    // Body's underlying type via associated-type inference — an explicit
                    // `typealias Body = SwiftUI.EmptyView` alongside it would conflict with
                    // that inferred type (Self.Body must match body's declared type exactly).
                    // Only synthesize the EmptyView fallback pair when there's no body at all.
                    if !hasBody && !satisfiesBodyViaShape {
                        if !self.members.keys.contains("Body") && !self.members.keys.contains("typealias Body") {
                            lines.append("\(nextIndent)public typealias Body = SwiftUI.EmptyView")
                        }
                        lines.append("\(nextIndent)public var body: SwiftUI.EmptyView { get { fatalError() } }")
                    }
                }
                if confBase == "Scene" || confBase == "SwiftUI.Scene" {
                    if !self.members.keys.contains("Body") && !self.members.keys.contains("typealias Body") {
                        lines.append("\(nextIndent)public typealias Body = SwiftUI.EmptyScene")
                    }
                    let hasBody = self.members.values.contains {
                        if case .property(let name, _, _, _) = $0 { return name == "body" }
                        return false
                    }
                    if !hasBody {
                        lines.append("\(nextIndent)public var body: SwiftUI.EmptyScene { get { fatalError() } }")
                    }
                }
                if confBase == "Widget" || confBase == "WidgetKit.Widget" {
                    if !self.members.keys.contains("Body") && !self.members.keys.contains("typealias Body") {
                        lines.append("\(nextIndent)public typealias Body = Never")
                    }
                    let hasBody = self.members.values.contains {
                        if case .property(let name, _, _, _) = $0 { return name == "body" }
                        return false
                    }
                    if !hasBody {
                        lines.append("\(nextIndent)public var body: Never { get { fatalError() } }")
                    }
                }
                
                // Look up internal/custom protocols defined in the module
                // NOTE: Protocol synthesis disabled — associated-type fallback always synthesizes
                // `Any`, which fails when the associated type has its own conformance constraint
                // (e.g. `CatalogAssetType: CatalogAssetProtocol`). Needs further refinement.
                if false, let parser = parser {
                    var protoNode: TypeNode? = parser.findTypeNode(module: parser.defaultModule, path: [confBase])
                    if protoNode == nil {
                        let matching = parser.discoveredProtocols.first { $0.hasSuffix("." + confBase) }
                        if let m = matching {
                            let parts = m.components(separatedBy: ".").dropFirst()
                            protoNode = parser.findTypeNode(module: parser.defaultModule, path: Array(parts))
                        }
                    }

                    if let pn = protoNode, pn.kind == "protocol" {
                        // 1. Synthesize missing associated types
                        var hasAllMethods = true
                        var hasAnyProtoMethods = false
                        for (_, mKind) in pn.members {
                            if case .method(let name, _, _) = mKind {
                                hasAnyProtoMethods = true
                                let hasMethodInMembers = self.members.values.contains {
                                    if case .method(let n, _, _) = $0 { return n == name }
                                    return false
                                }
                                let hasMethodInExt = self.extensionMembers.values.contains {
                                    if case .method(let n, _, _) = $0 { return n == name }
                                    return false
                                }
                                if !hasMethodInMembers && !hasMethodInExt {
                                    hasAllMethods = false
                                }
                            }
                        }
                        let skipAssociatedTypes = hasAnyProtoMethods && hasAllMethods

                        if !skipAssociatedTypes {
                            for (mName, mKind) in pn.members {
                                if case .associatedType = mKind {
                                    if !self.members.keys.contains(mName) && !self.members.keys.contains("typealias " + mName) {
                                        var val = "Any"
                                        if mName == "Body" {
                                            if hasConformance("ChartContent") {
                                                val = "AnyChartContent"
                                            } else if hasConformance("View") {
                                                val = "SwiftUI.EmptyView"
                                            } else if hasConformance("Scene") {
                                                val = "SwiftUI.EmptyScene"
                                            } else {
                                                val = "Never"
                                            }
                                        }
                                        lines.append("\(nextIndent)public typealias \(mName) = \(val)")
                                    }
                                }
                            }
                        }
                        
                        // 2. Synthesize missing methods/properties
                        for (_, mKind) in pn.members {
                            switch mKind {
                            case .method(let name, let sig, let isStatic):
                                let hasMethodInMembers = self.members.values.contains {
                                    if case .method(let n, _, _) = $0 { return n == name }
                                    return false
                                }
                                let hasMethodInExt = self.extensionMembers.values.contains {
                                    if case .method(let n, _, _) = $0 { return n == name }
                                    return false
                                }
                                let hasMethodInConstrainedExt = self.constrainedExtensions.values.contains {
                                    $0.values.contains {
                                        if case .method(let n, _, _) = $0 { return n == name }
                                        return false
                                    }
                                }
                                let hasMethod = hasMethodInMembers || hasMethodInExt || hasMethodInConstrainedExt
                                // Skip synthesis if the signature uses associated type paths (e.g.
                                // `A.CatalogAssetType`) that can't be resolved when A = Any.
                                let hasAssocTypePath = sig.range(of: "[A-Z]\\.[A-Z][a-zA-Z]+",
                                    options: .regularExpression) != nil
                                if !hasMethod && !hasAssocTypePath {
                                    var cleanSig = sig.trimmingCharacters(in: .whitespaces)
                                    if cleanSig.hasPrefix("static ") {
                                        cleanSig = String(cleanSig.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                                    }
                                    cleanSig = cleanSig.replacingOccurrences(of: "Self", with: self.name)
                                    let staticPrefix = isStatic ? "static " : ""
                                    
                                    var retVal = ""
                                    if let arrowRange = cleanSig.range(of: "->") {
                                        let retType = String(cleanSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                                        let def = TypeNode.defaultReturnValue(for: retType)
                                        if def == "fatalError()" {
                                            retVal = "{ fatalError() }"
                                        } else if def.isEmpty {
                                            retVal = "{}"
                                        } else {
                                            retVal = "{ return \(def) }"
                                        }
                                    } else {
                                        retVal = "{}"
                                    }
                                    lines.append("\(nextIndent)public \(staticPrefix)func \(cleanSig) \(retVal)")
                                }
                            case .property(let pName, let pType, let isReadOnly, let isStatic):
                                let hasPropInMembers = self.members.values.contains {
                                    if case .property(let name, _, _, _) = $0 {
                                        return name == pName
                                    }
                                    return false
                                }
                                let hasPropInExt = self.extensionMembers.values.contains {
                                    if case .property(let name, _, _, _) = $0 {
                                        return name == pName
                                    }
                                    return false
                                }
                                let hasPropInConstrainedExt = self.constrainedExtensions.values.contains {
                                    $0.values.contains {
                                        if case .property(let name, _, _, _) = $0 { return name == pName }
                                        return false
                                    }
                                }
                                let hasProp = hasPropInMembers || hasPropInExt || hasPropInConstrainedExt
                                let propHasAssocTypePath = pType.range(of: "[A-Z]\\.[A-Z][a-zA-Z]+",
                                    options: .regularExpression) != nil
                                if !hasProp && !propHasAssocTypePath {
                                    var cleanType = pType.trimmingCharacters(in: .whitespaces)
                                    cleanType = cleanType.replacingOccurrences(of: "Self", with: self.name)
                                    let staticPrefix = isStatic ? "static " : ""
                                    
                                    var finalType = cleanType
                                    if pName == "body" {
                                        if hasConformance("ChartContent") {
                                            finalType = "AnyChartContent"
                                        } else if hasConformance("View") {
                                            finalType = "SwiftUI.EmptyView"
                                        } else if hasConformance("Scene") {
                                            finalType = "SwiftUI.EmptyScene"
                                        } else {
                                            finalType = "Never"
                                        }
                                    }
                                    
                                    let def = TypeNode.defaultReturnValue(for: finalType)
                                    let getter = def == "fatalError()" ? "{ fatalError() }" : (def.isEmpty ? "{}" : "{ return \(def) }")
                                    let suffix = isReadOnly ? "{ get \(getter) }" : "{ get \(getter) set {} }"
                                    lines.append("\(nextIndent)public \(staticPrefix)var \(pName): \(finalType) \(suffix)")
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        
        if hasDeinit && !isObjcBridged && (actualKind == "class" || (actualKind == "struct" && hasConformance("~Copyable"))) {
            lines.append("\(nextIndent)deinit {}")
        }
        lines.append("\(indent)}")
        if isObjcBridged && actualKind == "class" {
            lines.append("\(indent)// --- End ObjC Extension ---")
        }
        
        return lines.joined(separator: "\n")
    }

    func hasEqualityOperator() -> Bool {
        for member in Array(members.values) + Array(extensionMembers.values) {
            if case .method(let n, _, _) = member {
                let cleanN = n.replacingOccurrences(of: " infix", with: "").trimmingCharacters(in: .whitespaces)
                if cleanN == "==" {
                    return true
                }
            }
        }
        for ext in constrainedExtensions.values {
            for member in ext.values {
                if case .method(let n, _, _) = member {
                    let cleanN = n.replacingOccurrences(of: " infix", with: "").trimmingCharacters(in: .whitespaces)
                    if cleanN == "==" {
                        return true
                    }
                }
            }
        }
        return false
    }

    func hasLessThanOperator() -> Bool {
        for member in Array(members.values) + Array(extensionMembers.values) {
            if case .method(let n, _, _) = member {
                let cleanN = n.replacingOccurrences(of: " infix", with: "").trimmingCharacters(in: .whitespaces)
                if cleanN == "<" {
                    return true
                }
            }
        }
        for ext in constrainedExtensions.values {
            for member in ext.values {
                if case .method(let n, _, _) = member {
                    let cleanN = n.replacingOccurrences(of: " infix", with: "").trimmingCharacters(in: .whitespaces)
                    if cleanN == "<" {
                        return true
                    }
                }
            }
        }
        return false
    }

    func hasDescriptionProperty() -> Bool {
        return members["description"] != nil
    }

    func generateExtensions(defaultModule: String, parser: Parser? = nil, path: String = "") -> String {
        var output = ""
        let separator = (path.isEmpty || path.hasSuffix("_") || path.hasSuffix(".")) ? "" : "."
        let escapedName = escapeKeyword(name)
        let currentPath = path.isEmpty ? escapedName : path + separator + escapedName
        
        var inScope = Set<String>()
        // Well-known stdlib protocols (AsyncSequence, Sequence, Collection, ...) referenced only
        // via an extension constraint (e.g. "extension AsyncSequence where A.Element: X") never
        // get their own "protocol descriptor" ABI symbol parsed when they belong to Swift itself
        // rather than the framework being generated — so `kind` stays "unknown" and the "A" ==
        // Self placeholder rename below would otherwise never fire for them.
        let wellKnownStdlibProtocols: Set<String> = ["AsyncSequence", "Sequence", "Collection", "IteratorProtocol"]
        let isProtocol = kind == "protocol" || (path == "Swift" && wellKnownStdlibProtocols.contains(name))
        var assocTypes = [String]()
        for member in members.values {
            if case .associatedType(let code) = member {
                let parts = code.components(separatedBy: " ")
                if parts.count >= 2 {
                    let cleaned = parts[1].components(separatedBy: ":").first!.trimmingCharacters(in: .whitespaces)
                    assocTypes.append(cleaned)
                    inScope.insert(cleaned)
                }
            }
        }
        let sortedAssoc = assocTypes.sorted()

        if isGeneric {
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            let count = getGenericCount(parser: parser)
            for i in 0..<count {
                if isProtocol {
                    if i < sortedAssoc.count {
                        inScope.insert(sortedAssoc[i])
                    } else {
                        inScope.insert(i < placeholders.count ? placeholders[i] : "A\(i)")
                    }
                } else {
                    inScope.insert(i < placeholders.count ? placeholders[i] : "A\(i)")
                }
            }
        }

        func generateOneExtension(membersList: [MemberKind], constraint: String?) -> String {
            var extLines = [String]()
            
        // Collect generic parameters from constraint and all associated types
        var extInScope = inScope
        if isProtocol {
            for member in members.values {
                if case .associatedType(let code) = member {
                    let parts = code.components(separatedBy: " ")
                    if parts.count >= 2 {
                        extInScope.insert(parts[1].replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces))
                    }
                }
            }
        }
        if let constraint = constraint {
                let pattern = "\\b[A-G]\\b"
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    let matches = regex.matches(in: constraint, range: NSRange(constraint.startIndex..., in: constraint))
                    for match in matches {
                        if let range = Range(match.range, in: constraint) {
                            extInScope.insert(String(constraint[range]))
                        }
                    }
                }
                fputs("Extension constraint: \(constraint), extInScope: \(extInScope)\n", stderr)
            }
            
            let extCleanScope = { (s: String) -> String in
                var res = s
                let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                for p in placeholders {
                    // Do not replace if it's an associated type name
                    if !extInScope.contains(p) {
                        res = res.replaceWord(p, with: "Any")
                    }
                }
                return res
            }

            // `isGeneric` reflects whether THIS type declares its own generic parameters, but a
            // constrained extension can legitimately exist on a type with none of its own —
            // e.g. Combine.Record.Recording introduces no new generic params (it just inherits
            // A/B from its parent Record<A, B>), yet still has a real conditional-conformance
            // extension ("extension Record.Recording where A: Decodable, ..."). `isGeneric` is
            // also never set for stdlib collection types (Array/Dictionary/Set) — see
            // Parser.precompute — even though "extension Dictionary where Key == X, ..." is a
            // legitimate constrained extension on them too. In both cases the presence of a
            // real, already-derived `constraint` is itself sufficient proof the extension needs
            // it; only synthesize the empty-suffix fallback when there's no constraint to lose.
            var constraintSuffix = constraint != nil ? " " + constraint! : ""
            if kind != "protocol" && !isGeneric && constraint == nil {
                constraintSuffix = ""
            }
            // Stdlib collection types don't use "A"/"B" placeholders in their real generic
            // parameter lists (Array<Element>, Dictionary<Key, Value>, Range<Bound>, ...) — this
            // rename must apply not just to the extension's own where-clause (constraintSuffix)
            // but to every member's signature/type text too, since a member can freely reference
            // the bare placeholder (e.g. "init(_ arg1: MLDataColumn<A>)" on an Array extension,
            // where A means Element).
            let stdlibPlaceholderRename: (String) -> String
            if name == "Array" && path == "Swift" {
                stdlibPlaceholderRename = { $0.replaceWord("A", with: "Element") }
            } else if name == "Dictionary" && path == "Swift" {
                stdlibPlaceholderRename = { $0.replaceWord("A", with: "Key").replaceWord("B", with: "Value") }
            } else if name == "Set" && path == "Swift" {
                stdlibPlaceholderRename = { $0.replaceWord("A", with: "Element") }
            } else if (name == "Range" || name == "PartialRangeUpTo" || name == "PartialRangeFrom" || name == "PartialRangeThrough" || name == "ClosedRange") && path == "Swift" {
                stdlibPlaceholderRename = { $0.replaceWord("A", with: "Bound") }
            } else if name == "Optional" && path == "Swift" {
                stdlibPlaceholderRename = { $0.replaceWord("A", with: "Wrapped") }
            } else {
                stdlibPlaceholderRename = { $0 }
            }
            constraintSuffix = stdlibPlaceholderRename(constraintSuffix)
            let isObjcExt = (parser?.getTopLevelModule(for: self) == "__C")
            if isObjcExt {
                extLines.append("// --- ObjC Extension (bridge-header required) ---")
            }
            extLines.append("extension \(currentPath)\(constraintSuffix) {")
            let extNextIndent = "    "
            
            let sortedExt = membersList.sorted(by: { 
                switch ($0, $1) {
                case (.initializer(_), .initializer(_)): return false
                case (.initializer(_), _): return true
                case (_, .initializer(_)): return false
                case (.property(let n1, _, _, _), .property(let n2, _, _, _)): return n1 < n2
                default: return false
                }
            })
            
            for member in sortedExt {
                switch member {
                case .initializer(let sig):
                    var cleanedSig = injectDefaultArguments(signature: sig, methodName: "init", isStatic: false, parser: parser)
                    if isProtocol {
                        cleanedSig = cleanedSig.replaceWord("A", with: "Self")
                    }
                    var initGenericInScope = Set<String>()
                    if let openAngle = cleanedSig.firstIndex(of: "<"),
                       let openParen = cleanedSig.firstIndex(of: "("),
                       openAngle < openParen {
                        var depth = 0
                        var closeAngle: String.Index? = nil
                        var i = openAngle
                        while i < openParen {
                            if cleanedSig[i] == "<" { depth += 1 }
                            else if cleanedSig[i] == ">" {
                                depth -= 1
                                if depth == 0 { closeAngle = i; break }
                            }
                            i = cleanedSig.index(after: i)
                        }
                        if let ca = closeAngle {
                            let inside = String(cleanedSig[cleanedSig.index(after: openAngle)..<ca])
                            for param in inside.components(separatedBy: ",") {
                                let p = param.trimmingCharacters(in: .whitespaces)
                                if !p.isEmpty { initGenericInScope.insert(p) }
                            }
                        }
                    }
                    let effectiveScope = extInScope.union(initGenericInScope)
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny(inScope: effectiveScope)
                    let localCleanScope = { (s: String) -> String in
                        var res = s
                        let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                        for p in placeholders {
                            if !effectiveScope.contains(p) {
                                res = res.replaceWord(p, with: "Any")
                            }
                        }
                        return res
                    }
                    cleanedSig = localCleanScope(cleanedSig)
                    let convenienceMod = (kind == "class" || baseClass != nil) ? "convenience " : ""
                    if isObjcExt {
                        extLines.append("\(extNextIndent)@nonobjc public \(convenienceMod)\(cleanedSig) { fatalError() }")
                    } else {
                        extLines.append("\(extNextIndent)public \(convenienceMod)\(cleanedSig) { fatalError() }")
                    }
                case .property(let n, let t, let isReadOnly, let isStatic):
                    var cleanT = t
                    let fullEnclosingPath = self.getEnclosingPath().isEmpty ? self.name : self.getEnclosingPath() + "." + self.name
                    cleanT = cleanT.stripParentPrefix(parentName: fullEnclosingPath)
                    if isProtocol {
                        cleanT = cleanT.replaceWord("A", with: "Self")
                        cleanT = cleanT.replacePlaceholderDotsWithSelf(validAssoc: getAllAssociatedTypes(parser: parser))
                        cleanT = cleanT.replaceMultiSegmentSelfPathsWithAny()
                    } else {
                        cleanT = cleanT.replaceGenericPlaceholderPathsWithAny(inScope: extInScope)
                    }
                    cleanT = extCleanScope(cleanT)
                    
                    let staticMod = isStatic ? "static " : ""
                    if n == "subscript" || n == "`subscript`" {
                        extLines.append(renderSubscript(cleanT: cleanT, isProtocol: isProtocol, isReadOnly: isReadOnly, staticMod: staticMod, finalMod: "", overrideMod: "", nextIndent: extNextIndent, inScope: extInScope, isExtension: true))
                    } else {
                        let defaultVal = TypeNode.defaultReturnValue(for: cleanT)
                        let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
                        let hasLifetime = isReadOnly && isLifetimeSpanType(cleanT)
                        let getPrefix = hasLifetime ? "@_lifetime(borrow self) get" : "get"
                        let suffix = isReadOnly ? "{ \(getPrefix) \(getter) }" : "{ \(getPrefix) \(getter) set {} }"
                        if cleanT.contains("Mutex<") || cleanT.contains("Synchronization.Mutex<") {
                            extLines.append("\(extNextIndent)public \(staticMod)let \(n): \(cleanT)")
                        } else {
                            extLines.append("\(extNextIndent)public \(staticMod)var \(n): \(cleanT) \(suffix)")
                        }
                    }
                case .method(let name, let sig, var isStatic):
                    var cleanedSig = sig.replacingOccurrences(of: " infix", with: "")
                                        .replacingOccurrences(of: " prefix", with: "")
                                        .replacingOccurrences(of: " postfix", with: "")
                    let cleanN = name.replacingOccurrences(of: " infix", with: "").replacingOccurrences(of: " prefix", with: "").replacingOccurrences(of: " postfix", with: "").trimmingCharacters(in: .whitespaces)
                    let isOperator = !cleanN.isEmpty && cleanN.allSatisfy { "+-*/=<>&|^~%!?.".contains($0) }
                    if isOperator {
                        isStatic = true
                    }
                    cleanedSig = injectDefaultArguments(signature: cleanedSig, methodName: cleanN, isStatic: isStatic, parser: parser)
                    // Only a method generic param literally named bare "A" can collide with the
                    // protocol's own "A" == Self placeholder — replaceWord("A", with: "Self")
                    // already word-boundary-skips "A1"/"A2" etc (isWordCharAfter treats a
                    // trailing digit as part of the same word), so checking for "A1" here was
                    // needlessly disabling the Self-substitution for every method that merely
                    // HAS an A1 generic param, even though A1 was never actually at risk. That
                    // false positive left bare "A" (meaning Self) unresolved in the method body,
                    // which then fell out of `inScope` and got erased to `Any` downstream —
                    // e.g. Combine's `Publisher.flatMap<A1>(...) -> Publishers.FlatMap<A1, A>`
                    // needs the trailing "A" turned into "Self", not erased to "Any".
                    let shouldReplaceA = !cleanedSig.hasGenericPlaceholderInBrackets(p: "A")
                    if isProtocol {
                        cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf(validAssoc: getAllAssociatedTypes(parser: parser))
                        if shouldReplaceA {
                            cleanedSig = cleanedSig.replaceWord("A", with: "Self")
                        }
                        cleanedSig = cleanedSig.replaceMultiSegmentSelfPathsWithAny()

                        // Remove "A" and "Self" from the method generic parameter list (it represents Self)
                        if let openIdx = cleanedSig.firstIndex(of: "<"),
                           let parenIdx = cleanedSig.firstIndex(of: "("),
                           openIdx < parenIdx {
                            let methodName = String(cleanedSig[..<parenIdx]).trimmingCharacters(in: .whitespaces)
                            if methodName.contains("<") {
                                if let closeIdx = cleanedSig.firstIndex(of: ">"), openIdx < closeIdx {
                                    let inside = String(cleanedSig[cleanedSig.index(after: openIdx)..<closeIdx])
                                    let parts = inside.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                                    let filtered = parts.filter { 
                                        if $0 == "Self" { return false }
                                        if $0 == "A" && shouldReplaceA { return false }
                                        return true
                                    }
                                    if filtered.isEmpty {
                                        cleanedSig = String(cleanedSig[..<openIdx]) + String(cleanedSig[cleanedSig.index(after: closeIdx)...])
                                    } else {
                                        cleanedSig = String(cleanedSig[..<openIdx]) + "<\(filtered.joined(separator: ", "))>" + String(cleanedSig[cleanedSig.index(after: closeIdx)...])
                                    }
                                }
                            }
                        }
                    }
                    
                    var methodGenericInScope = Set<String>()
                    if let openAngle = cleanedSig.firstIndex(of: "<"),
                       let openParen = cleanedSig.firstIndex(of: "("),
                       openAngle < openParen {
                        var depth = 0
                        var closeAngle: String.Index? = nil
                        var i = openAngle
                        while i < openParen {
                            if cleanedSig[i] == "<" { depth += 1 }
                            else if cleanedSig[i] == ">" {
                                depth -= 1
                                if depth == 0 { closeAngle = i; break }
                            }
                            i = cleanedSig.index(after: i)
                        }
                        if let ca = closeAngle {
                            let inside = String(cleanedSig[cleanedSig.index(after: openAngle)..<ca])
                            for param in inside.components(separatedBy: ",") {
                                var p = param.trimmingCharacters(in: .whitespaces)
                                if p.hasPrefix("each ") {
                                    p = String(p.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                                }
                                if !p.isEmpty { methodGenericInScope.insert(p) }
                            }
                        }
                    }
                    let effectiveScope = extInScope.union(methodGenericInScope)
                    
                    if !isProtocol {
                        cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny(inScope: effectiveScope)
                    }
                    
                    let methodCleanScope = { (s: String) -> String in
                        var res = s
                        let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                        for p in placeholders {
                            if !effectiveScope.contains(p) {
                                res = res.replaceWord(p, with: "Any")
                            }
                        }
                        return res
                    }
                    cleanedSig = methodCleanScope(cleanedSig)
                    cleanedSig = cleanedSig.removingUnusedMethodGenericParams()
                    
                    for param in methodGenericInScope {
                        var isPack = false
                        if let openBracket = cleanedSig.firstIndex(of: "<"),
                           let closeBracket = cleanedSig.firstIndex(of: ">"),
                           openBracket < closeBracket {
                            let bracketContent = String(cleanedSig[openBracket...closeBracket])
                            if bracketContent.contains("each \(param)") {
                                isPack = true
                            }
                        }
                        if isPack {
                            cleanedSig = cleanedSig.replacingOccurrences(of: "repeat \(param)", with: "repeat each \(param)")
                            cleanedSig = cleanedSig.replacingOccurrences(of: "repeat  \(param)", with: "repeat each \(param)")
                            // "repeat each A.Member" parses as "repeat (each A.Member)" — invalid,
                            // since a pack-expansion member access must bind the pack element
                            // first: "repeat (each A).Member". Parenthesize when a member access
                            // follows.
                            cleanedSig = cleanedSig.replacingOccurrences(of: "repeat each \(param).", with: "repeat (each \(param)).")

                            if let whereRange = cleanedSig.range(of: " where ") {
                                let before = String(cleanedSig[..<whereRange.upperBound])
                                let after = String(cleanedSig[whereRange.upperBound...])
                                let constraints = after.splitByCommaRespectingBrackets()
                                var newConstraints = [String]()
                                for c in constraints {
                                    let trimmed = c.trimmingCharacters(in: .whitespaces)
                                    if trimmed.contains(param) && !trimmed.contains("repeat each \(param)") {
                                        let replaced = trimmed.replaceWord(param, with: "repeat each \(param)")
                                        newConstraints.append(replaced)
                                    } else {
                                        newConstraints.append(c)
                                    }
                                }
                                cleanedSig = before + newConstraints.joined(separator: ", ")
                            }
                        }
                    }
                    
                    let staticMod = isStatic ? "static " : ""
                    if cleanN == "==" && cleanedSig.contains("(") {
                        let parts = cleanedSig.components(separatedBy: "(")
                        let argsPart = parts.dropFirst().joined(separator: "(")
                        let sigParts = argsPart.components(separatedBy: " -> ")
                        let returnType = sigParts.count > 1 ? sigParts.last!.replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces) : "Bool"
                        let allArgs = sigParts[0].trimmingCharacters(in: .whitespaces)

                        let argTypes = allArgs.components(separatedBy: ", ")
                        if argTypes.count == 2 {
                            var left = argTypes[0].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)
                            var right = argTypes[1].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)

                            if left.contains(":") { left = String(left.components(separatedBy: ":").last!) }
                            if right.contains(":") { right = String(right.components(separatedBy: ":").last!) }

                            left = left.stripModuleBeforeSubscriptOrGeneric()
                            right = right.stripModuleBeforeSubscriptOrGeneric()

                            if left == "Type" { left = "`Type`" }
                            if right == "Type" { right = "`Type`" }
                            if left.hasSuffix(".Type") && !left.contains("`Type`") { left = left.replacingOccurrences(of: ".Type", with: ".`Type`") }
                            if right.hasSuffix(".Type") && !right.contains("`Type`") { right = right.replacingOccurrences(of: ".Type", with: ".`Type`") }

                            left = left.trimmingCharacters(in: .whitespaces)
                            right = right.trimmingCharacters(in: .whitespaces)
                            let returnTypeClean = returnType.trimmingCharacters(in: .whitespaces)
                            let paramPrefix = self.hasConformance("~Copyable") ? "borrowing " : ""
                            let leftType = paramPrefix + ((left == right && self.kind != "class") ? "Self" : left)
                            let rightType = paramPrefix + ((left == right && self.kind != "class") ? "Self" : right)
                            let isBoolReturn = returnTypeClean == "Bool" || returnTypeClean == "Swift.Bool"
                            extLines.append("\(extNextIndent)public static func == (lhs: \(leftType), rhs: \(rightType)) -> \(returnTypeClean) { \(isBoolReturn ? "true" : "fatalError()") }")
                            continue
                        }
                    }
                    var extLifetimeAttr = ""
                    if let arrowRange = cleanedSig.range(of: "->", options: .backwards) {
                        let retPart = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                        if isLifetimeSpanType(retPart) {
                            extLifetimeAttr = "@_lifetime(borrow self) "
                        }
                    }
                    var returnType = "Void"
                    if let parenIdx = cleanedSig.firstIndex(of: ")") {
                        let afterParen = cleanedSig[parenIdx...]
                        if let arrowIdx = afterParen.range(of: "->") {
                            returnType = String(afterParen[arrowIdx.upperBound...]).trimmingCharacters(in: .whitespaces)
                        }
                    }
                    let defaultVal = TypeNode.defaultReturnValue(for: returnType)
                    let body = defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }"
                    let finalBody = defaultVal == "fatalError()" ? "{ fatalError() }" : body
                    extLines.append("\(extNextIndent)\(extLifetimeAttr)public \(staticMod)func \(cleanedSig) \(finalBody)")
                default:
                    break
                }
            }
            extLines.append("}")
            if isObjcExt {
                extLines.append("// --- End ObjC Extension ---")
            }
            // Apply the stdlib placeholder rename to member bodies too, not just the
            // already-renamed extension header — see stdlibPlaceholderRename above.
            return stdlibPlaceholderRename(extLines.joined(separator: "\n")) + "\n\n"
        }

        if !extensionMembers.isEmpty {
            output += generateOneExtension(membersList: Array(extensionMembers.values), constraint: nil)
        }
        
        let sortedConstraints = constrainedExtensions.keys.sorted()
        for constraint in sortedConstraints {
            if let membersMap = constrainedExtensions[constraint] {
                var finalConstraint = constraint
                // Depth-suffixed placeholders (A1, B1, ...) name a generic parameter belonging
                // to a NESTED type one level deeper than the type this extension is declared on
                // (e.g. HealthKit.SleepSessionQuery<A>.Descriptor<A1> — "A1" is Descriptor's own
                // param, distinct from the outer SleepSessionQuery's "A"). Our generic-param
                // rendering is single-level and has no placeholder for that nested param, so a
                // constraint referencing one (e.g. "where A == A1") can't be expressed — emitting
                // it verbatim produces an unresolvable "cannot find type 'A1'"/conflicting-
                // constraint error. Render the extension unconstrained instead, matching prior
                // behavior before constrained extensions on such nested generics were emitted.
                let depthSuffixedPlaceholderPattern = "\\b[A-G][0-9]+\\b"
                var dropConstraint = false
                if finalConstraint.range(of: depthSuffixedPlaceholderPattern, options: .regularExpression) != nil {
                    dropConstraint = true
                }
                if isProtocol {
                    finalConstraint = finalConstraint.replacingOccurrences(of: "where A:", with: "where Self:")
                    finalConstraint = finalConstraint.replacingOccurrences(of: "where A ", with: "where Self ")
                    finalConstraint = finalConstraint.replacingOccurrences(of: ", A:", with: ", Self:")
                    finalConstraint = finalConstraint.replacingOccurrences(of: ", A ", with: ", Self ")
                    // Replace A.member with Self.member for associated type constraints
                    finalConstraint = finalConstraint.replaceWord("A", with: "Self")
                }
                // The real ABI can carry a conditional-conformance witness (e.g. Hashable only
                // "where A: ~Copyable, ...") separately from the type's own unconditional
                // conformance list. We don't currently model that distinction and instead render
                // Hashable/Codable/Equatable as always-unconditional on the type itself — so a
                // constrained extension re-declaring the exact same synthesized witness names
                // (==, hash(into:), hashValue, encode(to:), init(from:)) is a real duplicate-
                // declaration risk, not a second, independently-needed conformance. Drop those
                // specific names from the constrained extension when the base type already
                // declares the matching conformance unconditionally.
                let hashableWitnessNames: Set<String> = ["==", "hash", "hashValue"]
                let codableWitnessNames: Set<String> = ["encode", "init(from:)"]
                let alreadyConformsHashable = hasConformance("Hashable") || hasConformance("Equatable")
                let alreadyConformsCodable = hasConformance("Codable") || hasConformance("Decodable") || hasConformance("Encodable")
                let filteredMembersMap = membersMap.filter { _, member in
                    let memberName: String
                    switch member {
                    case .method(let n, _, _): memberName = n
                    case .property(let n, _, _, _): memberName = n
                    case .initializer: memberName = "init(from:)"
                    default: return true
                    }
                    if hashableWitnessNames.contains(memberName) && alreadyConformsHashable { return false }
                    if codableWitnessNames.contains(memberName) && alreadyConformsCodable { return false }
                    return true
                }
                if !filteredMembersMap.isEmpty {
                    output += generateOneExtension(membersList: Array(filteredMembersMap.values), constraint: dropConstraint ? nil : finalConstraint)
                }
            }
        }
        
        if kind == "protocol" {
             let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
             for nested in sortedNested {
                 output += nested.generateCode(indent: "", nameOverride: "\(name)_\(nested.name)", parser: parser) + "\n\n"
             }
        }

        // Emit Equatable extension only for classes where Equatable was stripped from the header
        // (i.e., not exported by the TBD). If it's in the header already, no extension needed.
        let equatableWasKeptInHeader = parser?.conformancesFromTBD.contains(where: { $0 == "\(name):Equatable" }) == true
        if kind == "class" && baseClass != "NSObject" && !hasConformance("NSObject") && hasConformance("Equatable") && !equatableWasKeptInHeader {
             if hasEqualityOperator() {
                 output += "extension \(currentPath): Equatable {}\n"
             } else {
                 var genericType = currentPath
                 if isGeneric {
                     let count = getGenericCount(parser: parser)
                     let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                     var params = [String]()
                     for i in 0..<count {
                         if i < placeholders.count {
                             params.append(placeholders[i])
                         } else {
                             params.append("A\(i)")
                         }
                     }
                     genericType += "<\(params.joined(separator: ", "))>"
                 }
                 output += "extension \(currentPath): Equatable { public static func == (lhs: \(genericType), rhs: \(genericType)) -> Bool { fatalError() } }\n"
             }
        }
        
        let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
        for nested in sortedNested {
            output += nested.generateExtensions(defaultModule: defaultModule, parser: parser, path: currentPath)
        }
        
        return output
    }

    private func splitFunctionType(_ typeStr: String) -> (params: String, ret: String)? {
        let trimmed = typeStr.trimmingCharacters(in: .whitespaces)
        var depth_p = 0
        var depth_a = 0
        var depth_s = 0
        var arrowIdx: String.Index? = nil
        var i = trimmed.index(before: trimmed.endIndex)
        while i >= trimmed.startIndex {
            let c = trimmed[i]
            if c == ">" && i > trimmed.startIndex && trimmed[trimmed.index(before: i)] == "-" {
                if depth_p == 0 && depth_a == 0 && depth_s == 0 {
                    arrowIdx = trimmed.index(before: i)
                    break
                }
                i = trimmed.index(before: i)
            }
            else if c == ")" { depth_p += 1 }
            else if c == "(" { depth_p -= 1 }
            else if c == ">" { depth_a += 1 }
            else if c == "<" { depth_a -= 1 }
            else if c == "]" { depth_s += 1 }
            else if c == "[" { depth_s -= 1 }
            if i == trimmed.startIndex { break }
            i = trimmed.index(before: i)
        }
        guard let arrow = arrowIdx else { return nil }
        let left = String(trimmed[..<arrow]).trimmingCharacters(in: .whitespaces)
        let right = String(trimmed[trimmed.index(arrow, offsetBy: 2)...]).trimmingCharacters(in: .whitespaces)
        return (left, right)
    }

    private func renderSubscript(cleanT: String, isProtocol: Bool, isReadOnly: Bool, staticMod: String, finalMod: String, overrideMod: String, nextIndent: String, inScope: Set<String>, isExtension: Bool = false) -> String {
        var params = cleanT
        var retType = "Any"
        var genericPart = ""
        
        if let split = splitFunctionType(cleanT) {
            var paramsPart = split.params
            retType = split.ret
            
            if paramsPart.hasPrefix("<") {
                if let closeAngleIdx = paramsPart.firstIndex(of: ">") {
                    genericPart = String(paramsPart[..<paramsPart.index(after: closeAngleIdx)]).trimmingCharacters(in: .whitespaces)
                    paramsPart = String(paramsPart[paramsPart.index(after: closeAngleIdx)...]).trimmingCharacters(in: .whitespaces)
                }
            }
            
            params = Parser.fixUnnamedParameters(paramsPart, isSubscript: true)
        }
        
        if !genericPart.isEmpty {
            var cleanedSig = genericPart + params + " -> " + retType
            
            let genericPlaceholders = ["A", "B", "C", "D"]
            var paramsToRemoveFromBrackets = [String]()
            for p in genericPlaceholders {
                let variations = [p, "\(p)1", "\(p)2", "\(p)11", "\(p)21", "\(p)31"]
                for v in variations {
                    if cleanedSig.hasGenericPlaceholderInBrackets(p: v) {
                        if inScope.contains(v) {
                            paramsToRemoveFromBrackets.append(v)
                        } else {
                            cleanedSig = cleanedSig.replacingOccurrences(of: "<\(v)>", with: "<Generic\(p)>")
                            cleanedSig = cleanedSig.replacingOccurrences(of: "<\(v),", with: "<Generic\(p),")
                            cleanedSig = cleanedSig.replacingOccurrences(of: ", \(v)>", with: ", Generic\(p)>")
                            cleanedSig = cleanedSig.replacingOccurrences(of: ", \(v),", with: ", Generic\(p),")
                            cleanedSig = cleanedSig.replaceWord(v, with: "Generic\(p)")
                        }
                    }
                }
            }
            
            for p in paramsToRemoveFromBrackets {
                if let openBracket = cleanedSig.firstIndex(of: "<"),
                   let closeBracket = cleanedSig.firstIndex(of: ">"),
                   openBracket < closeBracket {
                    let prefix = cleanedSig[..<openBracket]
                    var list = String(cleanedSig[cleanedSig.index(after: openBracket)..<closeBracket])
                    let suffix = cleanedSig[closeBracket...]
                    
                    list = list.replaceWord(p, with: "")
                    list = list.replacingOccurrences(of: ",,", with: ",")
                    list = list.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
                    
                    if list.isEmpty {
                        cleanedSig = String(prefix) + String(suffix.dropFirst())
                    } else {
                        cleanedSig = String(prefix) + "<\(list)>" + String(suffix.dropFirst())
                    }
                }
            }
            cleanedSig = cleanedSig.replacingOccurrences(of: "<>", with: "")
            
            params = cleanedSig
            genericPart = ""
            retType = "Any"
            if let split = splitFunctionType(cleanedSig) {
                let paramsPart = split.params
                retType = split.ret
                if paramsPart.hasPrefix("<") {
                    if let closeAngleIdx = paramsPart.firstIndex(of: ">") {
                        genericPart = String(paramsPart[..<paramsPart.index(after: closeAngleIdx)]).trimmingCharacters(in: .whitespaces)
                        params = String(paramsPart[paramsPart.index(after: closeAngleIdx)...]).trimmingCharacters(in: .whitespaces)
                    } else {
                        params = paramsPart
                    }
                } else {
                    params = paramsPart
                }
            }
        }
        
        if !genericPart.isEmpty {
            let inner = genericPart.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            let gps = inner.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            var newGps = [String]()
            for gp in gps {
                if params.contains("InlineArray<\(gp),") {
                    newGps.append("let \(gp): Int")
                } else {
                    newGps.append(gp)
                }
            }
            genericPart = "<" + newGps.joined(separator: ", ") + ">"
        }
        
        if isProtocol && !isExtension {
            let suffix = isReadOnly ? "{ get }" : "{ get set }"
            return "\(nextIndent)\(staticMod)subscript\(genericPart)\(params) -> \(retType) \(suffix)"
        } else {
            let defaultVal = TypeNode.defaultReturnValue(for: retType)
            let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
            let hasLifetime = isReadOnly && isLifetimeSpanType(retType)
            let getPrefix = hasLifetime ? "@_lifetime(borrow self) get" : "get"
            let suffix = isReadOnly ? "{ \(getPrefix) \(getter) }" : "{ \(getPrefix) \(getter) set {} }"
            return "\(nextIndent)public \(finalMod)\(overrideMod)\(staticMod)subscript\(genericPart)\(params) -> \(retType) \(suffix)"
        }
    }
}
