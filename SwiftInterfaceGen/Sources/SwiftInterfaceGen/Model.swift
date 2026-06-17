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
    var nestedTypes: [String: TypeNode] = [:]
    var conformances: Set<String> = []
    var isGeneric: Bool = false
    var baseClass: String?
    var rawType: String?
    var finalMembers: Set<String> = []
    weak var parent: TypeNode? = nil

    func hasConformance(_ proto: String) -> Bool {
        return conformances.contains(proto) || 
               conformances.contains("Swift.\(proto)") || 
               conformances.contains("any \(proto)") || 
               conformances.contains("any Swift.\(proto)")
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
        if ["Double", "Float", "Float16", "CGFloat"].contains(t) { return "fatalError()" }
        if t == "String" { return "\"\"" }
        if t == "StaticString" { return "\"\"" }
        if t.starts(with: "Array<") || t.starts(with: "[") { return "[]" }
        if t.starts(with: "Dictionary<") || (t.starts(with: "[") && t.contains(":")) { return "[:]" }
        if t.starts(with: "Optional<") || t.hasSuffix("?") { return "nil" }
        if t.starts(with: "Set<") { return "[]" }
        if t == "Void" || t == "()" { return "" }
        if t == "Data" { return "Data()" }
        return "fatalError()"
    }

    func generateCode(indent: String = "", nameOverride: String? = nil, parser: Parser? = nil) -> String {
        let n = nameOverride ?? name
        if n.contains(" ") { return "" }
        var lines = [String]()
        let actualKind = kind == "unknown" ? "struct" : kind
        let isProtocol = actualKind == "protocol"
        let isEnum = actualKind == "enum"
        
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
            for i in 0..<count {
                inScope.insert(i < placeholders.count ? placeholders[i] : "A\(i)")
            }
        }
        for member in members.values {
            if case .associatedType(let code) = member {
                let parts = code.components(separatedBy: " ")
                if parts.count >= 2 {
                    inScope.insert(parts[1].trimmingCharacters(in: .whitespaces))
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
            if case .property(_, let t, _, let isStatic) = member {
                if isEnum && isStatic && (t == self.name || t.hasSuffix("." + self.name)) {
                    hasCases = true
                    break
                }
            }
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
            let forbiddenProtocols: Set<String> = [
                "AdditiveArithmetic", "BinaryFloatingPoint", "Comparable", "ExpressibleByFloatLiteral",
                "ExpressibleByIntegerLiteral", "FloatingPoint", "Numeric", "SignedNumeric", "Strideable"
            ]
            inheritsList = inheritsList.filter { !forbiddenProtocols.contains($0) }
        }
        if actualKind == "class" {
            inheritsList = inheritsList.filter { !["Hashable", "Codable", "Sendable", "Equatable"].contains($0) }
        }
        
        let inheritance = inheritsList.isEmpty ? "" : ": " + inheritsList.joined(separator: ", ")
        
        let typeName = nameOverride ?? name
        var displayTypeName = escapeKeyword(typeName)
        if isGeneric && !displayTypeName.contains("<") {
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
                if i < placeholders.count {
                    params.append(placeholders[i])
                } else {
                    params.append("A\(i)")
                }
            }
            displayTypeName += "<\(params.joined(separator: ", "))>"
        }
        
        lines.append("\(indent)public \(actualKind) \(displayTypeName)\(inheritance) {")
        
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
                isOverride = baseClass == "NSObject" && ["description", "hash", "debugDescription"].contains(n)
            case .method(let n, _, _):
                isOverride = baseClass == "NSObject" && ["isEqual"].contains(n)
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
                    var topLevelCommas = 0
                    var depth = 0
                    for c in payload {
                        if c == "(" || c == "<" || c == "[" { depth += 1 }
                        else if c == ")" || c == ">" || c == "]" { depth -= 1 }
                        else if c == "," && depth == 0 {
                            topLevelCommas += 1
                        }
                    }
                    if topLevelCommas == 0 {
                        if hasLabel {
                            lines.append("\(nextIndent)\(indirectPrefix)case \(escapeKeyword(name))(\(name): \(payload))")
                        } else {
                            lines.append("\(nextIndent)\(indirectPrefix)case \(escapeKeyword(name))(_: \(payload))")
                        }
                    } else {
                        lines.append("\(nextIndent)\(indirectPrefix)case \(escapeKeyword(name))(\(payload))")
                    }
                } else {
                    lines.append("\(nextIndent)case \(escapeKeyword(name))")
                }
            case .initializer(let sig):
                var cleanedSig = sig
                if isProtocol {
                    cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf()
                    cleanedSig = cleanedSig.replaceWord("A", with: "Self")
                    cleanedSig = cleanedSig.replaceMultiSegmentSelfPathsWithAny()
                } else {
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny()
                }
                cleanedSig = cleanScope(cleanedSig)
                
                var normalizedSig = cleanedSig
                if let parser = parser, !parser.defaultModule.isEmpty {
                    normalizedSig = normalizedSig.replacingOccurrences(of: "\(parser.defaultModule).", with: "")
                }
                normalizedSig = normalizedSig.replacingOccurrences(of: " ", with: "")
                if generatedInitializers.contains(normalizedSig) { continue }
                generatedInitializers.insert(normalizedSig)
                
                if isProtocol { lines.append("\(nextIndent)\(cleanedSig)") }
                else if isEnum { /* skip */ }
                else { lines.append("\(nextIndent)public \(overrideMod)\(cleanedSig) {}") }
            case .property(let n, let t, let isReadOnly, let isStatic):
                let propKey = "\(isStatic ? "static" : "instance")-\(n)"
                if generatedProperties.contains(propKey) { continue }
                generatedProperties.insert(propKey)
                
                if n == "allCases" && isEnum { continue }
                if n == "rawValue" && isEnum { continue }
                
                if isEnum && isStatic && (t == self.name || t.hasSuffix("." + self.name)) {
                    lines.append("\(nextIndent)case \(escapeKeyword(n))")
                    continue
                }
                
                var cleanT = t
                // Strip the parent's fully qualified prefix from any nested types
                cleanT = cleanT.stripParentPrefix(parentName: self.name)

                cleanT = cleanT.replaceSelfPattern(parentName: self.name, enclosingPath: self.getEnclosingPath(), replaceWith: self.name)

                if let brace = cleanT.firstIndex(of: "{") {
                    cleanT = String(cleanT[..<brace]).trimmingCharacters(in: .whitespaces)
                }
                cleanT = cleanT.replacingOccurrences(of: "}", with: "")

                if isProtocol {
                    cleanT = cleanT.replacePlaceholderDotsWithSelf()
                    cleanT = cleanT.replaceWord("A", with: "Self")
                    cleanT = cleanT.replaceMultiSegmentSelfPathsWithAny()
                } else {
                    cleanT = cleanT.replaceGenericPlaceholderPathsWithAny()
                }
                cleanT = cleanScope(cleanT)

                let staticMod = isStatic ? "static " : ""
                let finalMod = (!isStatic && self.kind == "class" && self.finalMembers.contains(n)) ? "final " : ""
                if n == "subscript" || n == "`subscript`" {
                    lines.append(renderSubscript(cleanT: cleanT, isProtocol: isProtocol, isReadOnly: isReadOnly, staticMod: staticMod, finalMod: finalMod, overrideMod: overrideMod, nextIndent: nextIndent))
                } else if isProtocol {
                    let suffix = isReadOnly ? "{ get }" : "{ get set }"
                    lines.append("\(nextIndent)\(staticMod)var \(n): \(cleanT) \(suffix)")
                } else {
                    let defaultVal = TypeNode.defaultReturnValue(for: cleanT)
                    let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
                    let suffix = isReadOnly ? "{ get \(getter) }" : "{ get \(getter) set {} }"
                    lines.append("\(nextIndent)public \(finalMod)\(overrideMod)\(staticMod)var \(n): \(cleanT) \(suffix)")
                }
            case .method(let n, let sig, let isStatic):
                var cleanedSig = sig.replacingOccurrences(of: " infix", with: "")
                let cleanN = n.replacingOccurrences(of: " infix", with: "").trimmingCharacters(in: .whitespaces)
                
                var fixModifier = ""
                if cleanedSig.contains(" prefix(") {
                    cleanedSig = cleanedSig.replacingOccurrences(of: " prefix(", with: "(")
                    fixModifier = "prefix "
                } else if cleanedSig.contains(" postfix(") {
                    cleanedSig = cleanedSig.replacingOccurrences(of: " postfix(", with: "(")
                    fixModifier = "postfix "
                }
                
                // Strip the parent's fully qualified prefix from any nested types
                cleanedSig = cleanedSig.stripParentPrefix(parentName: self.name)
                
                cleanedSig = cleanedSig.replaceSelfPattern(parentName: self.name, enclosingPath: self.getEnclosingPath(), replaceWith: self.name)
                
                if isProtocol {
                    cleanedSig = cleanedSig.replacePlaceholderDotsWithSelf()
                    cleanedSig = cleanedSig.replaceWord("A", with: "Self")
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
                                let filtered = parts.filter { $0 != "A" && $0 != "Self" }
                                if filtered.isEmpty {
                                    cleanedSig = String(cleanedSig[..<openIdx]) + String(cleanedSig[cleanedSig.index(after: closeIdx)...])
                                } else {
                                    cleanedSig = String(cleanedSig[..<openIdx]) + "<\(filtered.joined(separator: ", "))>" + String(cleanedSig[cleanedSig.index(after: closeIdx)...])
                                }
                            }
                        }
                    }
                } else {
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny()
                }
                cleanedSig = cleanScope(cleanedSig)
                
                if cleanN == "==" && (sig.contains(".Type") || sig.contains(".`Type`")) {
                    continue
                }

                let genericPlaceholders = ["A", "B", "C", "D"]
                var paramsToRemove = [String]()
                for p in genericPlaceholders {
                    if cleanedSig.hasGenericPlaceholderInBrackets(p: p) {
                        if cleanedSig.contains("\(p).") || cleanedSig.contains("\(p)1.") {
                             paramsToRemove.append(p)
                             paramsToRemove.append("\(p)1")
                        } else {
                             let variations = ["\(p)", "\(p)1", "\(p)2"]
                             for v in variations {
                                 cleanedSig = cleanedSig.replacingOccurrences(of: "<\(v)>", with: "<Generic\(p)>")
                                 cleanedSig = cleanedSig.replacingOccurrences(of: "<\(v),", with: "<Generic\(p),")
                                 cleanedSig = cleanedSig.replacingOccurrences(of: ", \(v)>", with: ", Generic\(p)>")
                                 cleanedSig = cleanedSig.replacingOccurrences(of: ", \(v),", with: ", Generic\(p),")
                                 cleanedSig = cleanedSig.replaceWord(v, with: "Generic\(p)")
                             }
                        }
                    }
                }
                
                for p in paramsToRemove {
                    cleanedSig = cleanedSig.replaceWord(p, with: "Any")
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

                if isProtocol {
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
                                    cleanedSig = baseName + ", " + methodGenericParams.joined(separator: ", ") + ">" + methodArgs
                                }
                            } else {
                                cleanedSig = methodName + "<\(methodGenericParams.joined(separator: ", "))>" + methodArgs
                            }
                        }
                    }
                }

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

                        lines.append("\(nextIndent)public static func == (lhs: \(left), rhs: \(right)) -> \(returnType) { \(returnType == "Bool" ? "true" : "fatalError()") }")
                        continue
                    }
                }
                
                let staticMod = isStatic ? "static " : ""
                let finalMod = (!isStatic && self.kind == "class" && self.finalMembers.contains(sig)) ? "final " : ""
                if isProtocol { 
                    lines.append("\(nextIndent)\(staticMod)\(fixModifier)func \(cleanedSig)") 
                } else { 
                    var returnType = "Void"
                    if let arrowRange = cleanedSig.range(of: " -> ", options: .backwards) {
                        returnType = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                    let defaultVal = TypeNode.defaultReturnValue(for: returnType)
                    let body = defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }"
                    let finalBody = defaultVal == "fatalError()" ? "{ fatalError() }" : body
                    lines.append("\(nextIndent)public \(finalMod)\(overrideMod)\(staticMod)\(fixModifier)func \(cleanedSig) \(finalBody)") 
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

            if (hasConformance("Decodable") || hasConformance("Codable")) && !hasInitFrom {
                lines.append("\(nextIndent)public init(from decoder: any Decoder) throws { fatalError() }")
            }
            if (hasConformance("Encodable") || hasConformance("Codable")) && !hasEncodeTo {
                lines.append("\(nextIndent)public func encode(to encoder: Encoder) throws { fatalError() }")
            }
            if hasConformance("Hashable") && !hasHashInto {
                lines.append("\(nextIndent)public func hash(into hasher: inout Hasher) { fatalError() }")
            }
            if (hasConformance("Hashable") || hasConformance("Equatable")) && !hasEqualityOperator() {
                lines.append("\(nextIndent)public static func ==(_ lhs: \(escapeKeyword(n)), _ rhs: \(escapeKeyword(n))) -> Bool { fatalError() }")
            }
            if hasConformance("Comparable") && !hasLessThanOperator() {
                lines.append("\(nextIndent)public static func <(_ lhs: \(escapeKeyword(n)), _ rhs: \(escapeKeyword(n))) -> Bool { fatalError() }")
            }
            if hasConformance("CustomStringConvertible") && !hasDescriptionProperty() {
                lines.append("\(nextIndent)public var description: String { get { return \"\" } }")
            }
        }
        
        lines.append("\(indent)}")
        
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
        let separator = (path.isEmpty || path.hasSuffix("_")) ? "" : "."
        let currentPath = path.isEmpty ? name : path + separator + name
        
        if !extensionMembers.isEmpty {
            var inScope = Set<String>()
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
                    inScope.insert(i < placeholders.count ? placeholders[i] : "A\(i)")
                }
            }
            for member in members.values {
                if case .associatedType(let code) = member {
                    let parts = code.components(separatedBy: " ")
                    if parts.count >= 2 {
                        inScope.insert(parts[1].trimmingCharacters(in: .whitespaces))
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

            var extLines = [String]()
            extLines.append("extension \(currentPath) {")
            let extNextIndent = "    "
            
            let sortedExt = extensionMembers.values.sorted(by: { 
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
                    var cleanedSig = sig
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny()
                    cleanedSig = cleanScope(cleanedSig)
                    extLines.append("\(extNextIndent)public \(cleanedSig) { fatalError() }")
                case .property(let n, let t, let isReadOnly, let isStatic):
                    var cleanT = t
                    cleanT = cleanT.stripParentPrefix(parentName: self.name)
                    cleanT = cleanT.replaceGenericPlaceholderPathsWithAny()
                    cleanT = cleanScope(cleanT)
                    
                    let staticMod = isStatic ? "static " : ""
                    let defaultVal = TypeNode.defaultReturnValue(for: cleanT)
                    let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
                    let suffix = isReadOnly ? "{ get \(getter) }" : "{ get \(getter) set {} }"
                    extLines.append("\(extNextIndent)public \(staticMod)var \(n): \(cleanT) \(suffix)")
                case .method(_, let sig, let isStatic):
                    var cleanedSig = sig
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny()
                    cleanedSig = cleanScope(cleanedSig)
                    
                    let staticMod = isStatic ? "static " : ""
                    var returnType = "Void"
                    if let arrowRange = cleanedSig.range(of: " -> ", options: .backwards) {
                        returnType = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                    let defaultVal = TypeNode.defaultReturnValue(for: returnType)
                    let body = defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }"
                    let finalBody = defaultVal == "fatalError()" ? "{ fatalError() }" : body
                    extLines.append("\(extNextIndent)public \(staticMod)func \(cleanedSig) \(finalBody)")
                default:
                    break
                }
            }
            extLines.append("}")
            output += extLines.joined(separator: "\n") + "\n\n"
        }
        
        if kind == "protocol" {
             let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
             for nested in sortedNested {
                 output += nested.generateCode(indent: "", nameOverride: "\(name)_\(nested.name)", parser: parser) + "\n\n"
             }
        }

        if kind == "class" && baseClass != "NSObject" && !hasConformance("NSObject") {
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

    private func renderSubscript(cleanT: String, isProtocol: Bool, isReadOnly: Bool, staticMod: String, finalMod: String, overrideMod: String, nextIndent: String) -> String {
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
        
        if isProtocol {
            let suffix = isReadOnly ? "{ get }" : "{ get set }"
            return "\(nextIndent)\(staticMod)subscript\(genericPart)\(params) -> \(retType) \(suffix)"
        } else {
            let defaultVal = TypeNode.defaultReturnValue(for: retType)
            let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
            let suffix = isReadOnly ? "{ get \(getter) }" : "{ get \(getter) set {} }"
            return "\(nextIndent)public \(finalMod)\(overrideMod)\(staticMod)subscript\(genericPart)\(params) -> \(retType) \(suffix)"
        }
    }
}
