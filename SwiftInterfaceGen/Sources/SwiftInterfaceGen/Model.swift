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
    weak var parent: TypeNode? = nil

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
               conformances.contains("any Swift.\(proto)")
    }

    static func getDefaultValue(for type: String) -> String {
        var cleanType = type.trimmingCharacters(in: .whitespaces)
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
        guard let openParen = signature.firstIndex(of: "("),
              let closeParen = signature.lastIndex(of: ")"),
              openParen < closeParen else {
            return signature
        }
        
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
        let t = type.trimmingCharacters(in: .whitespaces)
        if t == "Bool" { return "false" }
        if ["Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64"].contains(t) { return "0" }
        if ["Double", "Float", "Float16", "CGFloat"].contains(t) { return "0.0" }
        if t == "String" { return "\"\"" }
        if t == "StaticString" { return "\"\"" }
        if t.starts(with: "Array<") || t.starts(with: "[") { return "[]" }
        if t.starts(with: "Dictionary<") || (t.starts(with: "[") && t.contains(":")) { return "[:]" }
        if t.starts(with: "Optional<") || t.hasSuffix("?") { return "nil" }
        if t.starts(with: "Set<") { return "[]" }
        if t == "Void" || t == "()" { return "" }
        if t == "Data" { return "Data()" }
        if t.hasPrefix("AnySequence") { return "AnySequence([])" }
        return "fatalError()"
    }

    func generateCode(indent: String = "", nameOverride: String? = nil, parser: Parser? = nil) -> String {
        let n = nameOverride ?? name
        if n.contains(" ") { return "" }
        let actualKind = kind == "unknown" ? "struct" : kind
        if isObjcBridged && actualKind == "enum" {
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
        var genericParamsList = ""
        if isGeneric {
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            var count = 1
            if let parser = parser {
                let fullPath1 = parser.defaultModule + "." + name
                let fullPath2 = name
                if let inferredCount = parser.discoveredGenerics[fullPath1] {
                    count = inferredCount
                } else if let inferredCount = parser.discoveredGenerics[fullPath2] {
                    count = inferredCount
                }
            }
            var params = [String]()
            for i in 0..<count {
                let p = i < placeholders.count ? placeholders[i] : "A\(i)"
                inScope.insert(p)
                params.append(p)
            }
            genericParamsList = "<\(params.joined(separator: ", "))>"
        }
        let selfReplaceWith = name + (isGeneric ? genericParamsList : "")
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
        for member in members.values {
            if case .enumCase(_, _, _) = member { hasCases = true; break }
        }

        if isEnum && hasCases, let raw = rawType {
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
            let forbiddenProtocols: Set<String> = isCustomFloatType
                ? []  // allow all conformances for custom float types
                : ["AdditiveArithmetic", "BinaryFloatingPoint",
                   "FloatingPoint", "Numeric", "SignedNumeric", "Strideable",
                   "BinaryInteger", "FixedWidthInteger", "SignedInteger", "UnsignedInteger"]
            inheritsList = inheritsList.filter { !forbiddenProtocols.contains($0) }
        }
        if actualKind == "class" {
            // Strip Equatable and Hashable — these generate extra conformance descriptors
            // that the TBD does not export for class types.
            inheritsList = inheritsList.filter { !["Hashable", "Codable", "Sendable", "Equatable"].contains($0) }
            
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
        let inheritance = inheritsList.isEmpty ? "" : ": " + inheritsList.joined(separator: ", ")
        
        let typeName = nameOverride ?? name
        var displayTypeName = escapeKeyword(typeName)
        if typeName == "BidirectionalXPCServiceClientConnection" {
            displayTypeName += "<A: XPCService, B: XPCService>"
            isGeneric = false
            inScope.insert("A")
            inScope.insert("B")
        } else if typeName == "CatalogAsset" {
            displayTypeName += "<A: AssetMetadata, B: AssetContents>"
            isGeneric = false
            inScope.insert("A")
            inScope.insert("B")
        } else if typeName == "SupportedArgument" {
            displayTypeName += "<A: Equatable>"
            isGeneric = false
            inScope.insert("A")
        } else if typeName == "XPCServiceClientConnection" {
            displayTypeName += "<A: XPCService>"
            isGeneric = false
            inScope.insert("A")
        } else if isGeneric && !isProtocol && !displayTypeName.contains("<") {
            var count = 1
            if let parser = parser {
                let fullPath1 = parser.defaultModule + "." + name
                let fullPath2 = name
                if let inferredCount = parser.discoveredGenerics[fullPath1] {
                    count = inferredCount
                } else if let inferredCount = parser.discoveredGenerics[fullPath2] {
                    count = inferredCount
                }
            }
            
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
            
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
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
                        params.append(placeholders[i])
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
        if isObjcBridged && actualKind == "class" {
            lines.append("\(indent)// --- ObjC Extension (bridge-header required) ---")
            lines.append("\(indent)extension \(displayTypeName) {")
        } else {
            // NSObject subclasses need `open` so that library-evolution mode generates dispatch
            // thunks (Tj) for overridable/required methods like init?(coder:).
            let isNSObjectSubclass = baseClass == "NSObject"
            var classVisibility = (actualKind == "class" && isNSObjectSubclass) ? "open" : "public"
            if actualKind == "class" && classVisibility == "public" && name != "NSObject" {
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
            let fixedLayoutAttr = (actualKind == "class") ? "@_fixed_layout " : ""
            lines.append("\(indent)\(fixedLayoutAttr)\(classVisibility) \(actualKind) \(displayTypeName)\(inheritance) {")
        }
        
        let nextIndent = indent + "    "
        
        if isProtocol && isGeneric {
            var count = 1
            if let parser = parser {
                let fullPath1 = parser.defaultModule + "." + name
                let fullPath2 = name
                if let inferredCount = parser.discoveredGenerics[fullPath1] {
                    count = inferredCount
                } else if let inferredCount = parser.discoveredGenerics[fullPath2] {
                    count = inferredCount
                }
            }
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            for i in 0..<count {
                let paramName = i < placeholders.count ? placeholders[i] : "A\(i)"
                lines.append("\(nextIndent)associatedtype \(paramName)")
            }
        }
        
        if !isProtocol {
            let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
            for nested in sortedNested {
                lines.append(nested.generateCode(indent: nextIndent, parser: parser))
            }
        }
        
        let sortedMembers = members.values.sorted(by: { 
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
                isOverride = baseClass == "NSObject" && sig.starts(with: "init()")
            case .property(let n, _, _, _):
                isOverride = !isObjcBridged && baseClass == "NSObject" && ["description", "hash", "debugDescription"].contains(n)
            case .method(let n, _, _):
                isOverride = !isObjcBridged && baseClass == "NSObject" && ["isEqual"].contains(n)
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
                            let p = param.trimmingCharacters(in: .whitespaces)
                            if !p.isEmpty { initGenericInScope.insert(p) }
                        }
                    }
                }
                let effectiveScope = inScope.union(initGenericInScope)

                if isProtocol {
                    cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf()
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
                else if isObjcBridged {
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
                
                if n == "allCases" && isEnum { continue }
                if n == "rawValue" && isEnum { continue }
                
                var cleanT = t
                // Strip the parent's fully qualified prefix from any nested types
                cleanT = cleanT.stripParentPrefix(parentName: self.name)

                cleanT = cleanT.replaceSelfPattern(parentName: self.name, enclosingPath: self.getEnclosingPath(), replaceWith: selfReplaceWith)
                cleanT = cleanT.replaceWordWithoutGeneric(self.name, with: selfReplaceWith)

                if let brace = cleanT.firstIndex(of: "{") {
                    cleanT = String(cleanT[..<brace]).trimmingCharacters(in: .whitespaces)
                }
                cleanT = cleanT.replacingOccurrences(of: "}", with: "")

                if isProtocol {
                    cleanT = cleanT.replacePlaceholderDotsWithSelf()
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
                    let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
                    let hasLifetime = isReadOnly && isLifetimeSpanType(cleanT)
                    let getPrefix = hasLifetime ? "@_lifetime(borrow self) get" : "get"
                    let suffix = isReadOnly ? "{ \(getPrefix) \(getter) }" : "{ \(getPrefix) \(getter) set {} }"
                    if cleanT.contains("Mutex<") || cleanT.contains("Synchronization.Mutex<") {
                        lines.append("\(nextIndent)public \(finalMod)\(overrideMod)\(staticMod)let \(n): \(cleanT)")
                    } else {
                        lines.append("\(nextIndent)public \(finalMod)\(overrideMod)\(staticMod)var \(n): \(cleanT) \(suffix)")
                    }
                }
            case .method(let n, let sig, var isStatic):
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
                cleanedSig = cleanedSig.stripParentPrefix(parentName: self.name)
                
                cleanedSig = cleanedSig.replaceSelfPattern(parentName: self.name, enclosingPath: self.getEnclosingPath(), replaceWith: selfReplaceWith)
                cleanedSig = cleanedSig.replaceWordWithoutGeneric(self.name, with: selfReplaceWith)
                
                var shouldReplaceA = true
                if cleanedSig.hasGenericPlaceholderInBrackets(p: "A") || cleanedSig.hasGenericPlaceholderInBrackets(p: "A1") {
                    shouldReplaceA = false
                }
                if isProtocol {
                    cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf()
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
                        
                        if left.contains(": ") { left = String(left.components(separatedBy: ": ").last!) }
                        if right.contains(": ") { right = String(right.components(separatedBy: ": ").last!) }
                        
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
                    lines.append("\(nextIndent)\(lifetimeAttr)\(staticMod)\(funcModifier)func \(cleanedSig)") 
                } else { 
                    var returnType = "Void"
                    if let arrowRange = cleanedSig.range(of: " -> ", options: .backwards) {
                        returnType = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
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
                var count = 1
                if let parser = parser {
                    let fullPath1 = parser.defaultModule + "." + name
                    let fullPath2 = name
                    if let inferredCount = parser.discoveredGenerics[fullPath1] {
                        count = inferredCount
                    } else if let inferredCount = parser.discoveredGenerics[fullPath2] {
                        count = inferredCount
                    }
                }
                let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                var params = [String]()
                for i in 0..<count {
                    params.append(i < placeholders.count ? placeholders[i] : "A\(i)")
                }
                genericParamsList = "<\(params.joined(separator: ", "))>"
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
            if hasConformance("Comparable") && !hasLessThanOperator() {
                let leftType = escapeKeyword(n) + genericParamsList
                let rightType = escapeKeyword(n) + genericParamsList
                lines.append("\(nextIndent)public static func <(_ lhs: \(leftType), _ rhs: \(rightType)) -> Bool { fatalError() }")
            }
            if hasConformance("CustomStringConvertible") && !hasDescriptionProperty() {
                lines.append("\(nextIndent)public var description: String { get { return \"\" } }")
            }
            // NSCoding: open classes that NSObject subclasses need required init?(coder:) and encode(with:)
            // so that library-evolution dispatch thunks (Tj) are generated.
            let isNSObjectBase = baseClass == "NSObject"
            if isNSObjectBase && hasConformance("NSCoding") {
                if !hasCoderInit {
                    lines.append("\(nextIndent)public required init?(coder: NSCoder) {}")
                } else {
                    // Replace non-required coder init with required version
                    // (done at emit time: mark existing coder init as required)
                }
                if !hasEncodeWith {
                    lines.append("\(nextIndent)open func encode(with coder: NSCoder) {}")
                }
            }
            if actualKind == "struct" && hasConformance("~Copyable") {
                lines.append("\(nextIndent)deinit {}")
            }
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
        return false
    }

    func hasDescriptionProperty() -> Bool {
        return members["description"] != nil
    }

    func generateExtensions(defaultModule: String, parser: Parser? = nil, path: String = "") -> String {
        var output = ""
        let separator = (path.isEmpty || path.hasSuffix("_") || path.hasSuffix(".")) ? "" : "."
        let currentPath = path.isEmpty ? name : path + separator + name
        
        var inScope = Set<String>()
        let isProtocol = kind == "protocol"
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
            var count = 1
            if let parser = parser {
                let fullPath1 = defaultModule + "." + name
                let fullPath2 = name
                if let inferredCount = parser.discoveredGenerics[fullPath1] {
                    count = inferredCount
                } else if let inferredCount = parser.discoveredGenerics[fullPath2] {
                    count = inferredCount
                }
            }
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

            var constraintSuffix = constraint != nil ? " " + constraint! : ""
            if name == "Array" && path == "Swift" {
                constraintSuffix = constraintSuffix.replaceWord("A", with: "Element")
            } else if name == "Dictionary" && path == "Swift" {
                constraintSuffix = constraintSuffix.replaceWord("A", with: "Key").replaceWord("B", with: "Value")
            } else if name == "Set" && path == "Swift" {
                constraintSuffix = constraintSuffix.replaceWord("A", with: "Element")
            } else if name == "Optional" && path == "Swift" {
                constraintSuffix = constraintSuffix.replaceWord("A", with: "Wrapped")
            }
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
                    if isObjcExt {
                        extLines.append("\(extNextIndent)@nonobjc public convenience \(cleanedSig) { fatalError() }")
                    } else {
                        extLines.append("\(extNextIndent)public \(cleanedSig) { fatalError() }")
                    }
                case .property(let n, let t, let isReadOnly, let isStatic):
                    var cleanT = t
                    cleanT = cleanT.stripParentPrefix(parentName: self.name)
                    if isProtocol {
                        cleanT = cleanT.replaceWord("A", with: "Self")
                        cleanT = cleanT.replacePlaceholderDotsWithSelf()
                        cleanT = cleanT.replaceMultiSegmentSelfPathsWithAny()
                    } else {
                        cleanT = cleanT.replaceGenericPlaceholderPathsWithAny(inScope: extInScope)
                    }
                    cleanT = extCleanScope(cleanT)
                    
                    let staticMod = isStatic ? "static " : ""
                    if n == "subscript" || n == "`subscript`" {
                        extLines.append(renderSubscript(cleanT: cleanT, isProtocol: isProtocol, isReadOnly: isReadOnly, staticMod: staticMod, finalMod: "", overrideMod: "", nextIndent: extNextIndent, inScope: extInScope))
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
                    var shouldReplaceA = true
                    if cleanedSig.hasGenericPlaceholderInBrackets(p: "A") || cleanedSig.hasGenericPlaceholderInBrackets(p: "A1") {
                        shouldReplaceA = false
                    }
                    if isProtocol {
                        cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf()
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
                                let p = param.trimmingCharacters(in: .whitespaces)
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
                    
                    let staticMod = isStatic ? "static " : ""
                    var extLifetimeAttr = ""
                    if let arrowRange = cleanedSig.range(of: "->", options: .backwards) {
                        let retPart = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                        if isLifetimeSpanType(retPart) {
                            extLifetimeAttr = "@_lifetime(borrow self) "
                        }
                    }
                    var returnType = "Void"
                    if let arrowRange = cleanedSig.range(of: " -> ", options: .backwards) {
                        returnType = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
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
            return extLines.joined(separator: "\n") + "\n\n"
        }

        if !extensionMembers.isEmpty {
            output += generateOneExtension(membersList: Array(extensionMembers.values), constraint: nil)
        }
        
        let sortedConstraints = constrainedExtensions.keys.sorted()
        for constraint in sortedConstraints {
            if let membersMap = constrainedExtensions[constraint] {
                var finalConstraint = constraint
                if kind == "protocol" {
                    finalConstraint = finalConstraint.replacingOccurrences(of: "where A:", with: "where Self:")
                    finalConstraint = finalConstraint.replacingOccurrences(of: "where A ", with: "where Self ")
                    finalConstraint = finalConstraint.replacingOccurrences(of: ", A:", with: ", Self:")
                    finalConstraint = finalConstraint.replacingOccurrences(of: ", A ", with: ", Self ")
                }
                output += generateOneExtension(membersList: Array(membersMap.values), constraint: finalConstraint)
            }
        }
        
        if kind == "protocol" {
             let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
             for nested in sortedNested {
                 output += nested.generateCode(indent: "", nameOverride: "\(name)_\(nested.name)", parser: parser) + "\n\n"
             }
        }

        if kind == "class" && baseClass != "NSObject" && !hasConformance("NSObject") && hasConformance("Equatable") {
             if hasEqualityOperator() {
                 output += "extension \(currentPath): Equatable {}\n"
             } else {
                 var genericType = currentPath
                 if isGeneric {
                     var count = 1
                     if let parser = parser {
                         let fullPath1 = defaultModule + "." + name
                         let fullPath2 = name
                         if let inferredCount = parser.discoveredGenerics[fullPath1] {
                             count = inferredCount
                         } else if let inferredCount = parser.discoveredGenerics[fullPath2] {
                             count = inferredCount
                         }
                     }
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

    private func renderSubscript(cleanT: String, isProtocol: Bool, isReadOnly: Bool, staticMod: String, finalMod: String, overrideMod: String, nextIndent: String, inScope: Set<String>) -> String {
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
        
        if isProtocol {
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
