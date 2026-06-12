import Foundation

struct Symbol {
    let mangled: String
    let demangled: String
}

enum MemberKind {
    case initializer(String)
    case property(name: String, type: String, isReadOnly: Bool, isStatic: Bool)
    case method(name: String, signature: String, isStatic: Bool)
    case enumCase(String)
    case other(String)
}

class TypeNode {
    let name: String
    var kind: String = "unknown"
    var members: [String: MemberKind] = [:]
    var nestedTypes: [String: TypeNode] = [:]
    var conformances: Set<String> = []
    var isGeneric: Bool = false
    var baseClass: String?
    var rawType: String?

    init(name: String) {
        self.name = name
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

    private func defaultReturnValue(for type: String) -> String {
        let t = type.trimmingCharacters(in: .whitespaces)
        if t == "Bool" { return "false" }
        if t.starts(with: "Int") || t.starts(with: "UInt") || t == "Double" || t == "Float" || t == "CGFloat" { return "0" }
        if t == "String" { return "\"\"" }
        if t.starts(with: "Array<") || t.starts(with: "[") { return "[]" }
        if t.starts(with: "Dictionary<") || (t.starts(with: "[") && t.contains(":")) { return "[:]" }
        if t.starts(with: "Optional<") || t.hasSuffix("?") { return "nil" }
        if t.starts(with: "Set<") { return "[]" }
        if t == "Void" || t == "()" { return "" }
        if t == "Data" { return "Data()" }
        return "fatalError()"
    }

    func generateCode(indent: String = "", nameOverride: String? = nil) -> String {
        let n = nameOverride ?? name
        if n.contains(" ") { return "" }
        var lines = [String]()
        let actualKind = kind == "unknown" ? "struct" : kind
        let isProtocol = actualKind == "protocol"
        let isEnum = actualKind == "enum"
        
        var inherits = [String]()
        if let base = baseClass {
            inherits.append(base)
        }
        
        var hasCases = false
        for member in members.values {
            if case .enumCase(_) = member { hasCases = true; break }
            if case .property(_, let t, _, let isStatic) = member {
                if isEnum && isStatic && (t == self.name || t.hasSuffix("." + self.name)) {
                    hasCases = true
                    break
                }
            }
        }

        if isEnum && hasCases, let raw = rawType {
            inherits.append(raw)
        }
        
        var filteredConformances = conformances.sorted()
        if isEnum && !hasCases {
            filteredConformances = filteredConformances.filter { !["Codable", "Encodable", "Decodable"].contains($0) }
        }
        inherits.append(contentsOf: filteredConformances)
        
        var inheritsList = inherits
        if actualKind == "class" {
            inheritsList = inheritsList.filter { !["Hashable", "Codable", "Sendable", "Equatable"].contains($0) }
        }
        
        let inheritance = inheritsList.isEmpty ? "" : ": " + inheritsList.joined(separator: ", ")
        
        let typeName = nameOverride ?? name
        var displayTypeName = escapeKeyword(typeName)
        if isGeneric && !displayTypeName.contains("<") && actualKind != "protocol" {
            displayTypeName += "<T>"
        }
        
        lines.append("\(indent)public \(actualKind) \(displayTypeName)\(inheritance) {")
        
        let nextIndent = indent + "    "
        
        if !isProtocol {
            let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
            for nested in sortedNested {
                lines.append(nested.generateCode(indent: nextIndent))
            }
        }
        
        let sortedMembers = members.values.sorted(by: { 
            switch ($0, $1) {
            case (.enumCase(let n1), .enumCase(let n2)): return n1 < n2
            case (.enumCase(_), _): return true
            case (_, .enumCase(_)): return false
            case (.initializer(_), .initializer(_)): return false
            case (.initializer(_), _): return true
            case (_, .initializer(_)): return false
            case (.property(let n1, _, _, _), .property(let n2, _, _, _)): return n1 < n2
            default: return false
            }
        })

        for member in sortedMembers {
            let isClassOrProtocol = actualKind == "class" || actualKind == "protocol"
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
            case .enumCase(let n):
                lines.append("\(nextIndent)case \(escapeKeyword(n))")
            case .initializer(let sig):
                if isProtocol { lines.append("\(nextIndent)\(sig)") }
                else if isEnum { /* skip */ }
                else { lines.append("\(nextIndent)public \(overrideMod)\(sig) {}") }
            case .property(let n, let t, let isReadOnly, let isStatic):
                if n == "allCases" && isEnum { continue }
                if n == "rawValue" && isEnum { continue }
                
                if isEnum && isStatic && (t == self.name || t.hasSuffix("." + self.name)) {
                    lines.append("\(nextIndent)case \(escapeKeyword(n))")
                    continue
                }
                
                var cleanT = t
                if !isClassOrProtocol {
                    let selfPattern1 = "\\b([a-zA-Z0-9_]+\\.)+\(self.name)<[^>]+>"
                    cleanT = cleanT.replacingOccurrences(of: selfPattern1, with: "Self", options: .regularExpression)
                    let selfPattern2 = "\\b([a-zA-Z0-9_]+\\.)+\(self.name)\\b"
                    cleanT = cleanT.replacingOccurrences(of: selfPattern2, with: "Self", options: .regularExpression)
                } else {
                    let prefixPattern = "\\b([a-zA-Z0-9_]+\\.)+\(self.name)\\b"
                    cleanT = cleanT.replacingOccurrences(of: prefixPattern, with: "\(self.name)", options: .regularExpression)
                }

                if let brace = cleanT.firstIndex(of: "{") {
                    cleanT = String(cleanT[..<brace]).trimmingCharacters(in: .whitespaces)
                }
                cleanT = cleanT.replacingOccurrences(of: "}", with: "")

                let staticMod = isStatic ? "static " : ""
                if isProtocol {
                    let suffix = isReadOnly ? "{ get }" : "{ get set }"
                    lines.append("\(nextIndent)\(staticMod)var \(n): \(cleanT) \(suffix)")
                } else {
                    let defaultVal = defaultReturnValue(for: cleanT)
                    let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : "{ \(defaultVal) }"
                    let suffix = isReadOnly ? "{ get \(getter) }" : "{ get \(getter) set { fatalError() } }"
                    lines.append("\(nextIndent)public \(overrideMod)\(staticMod)var \(n): \(cleanT) \(suffix)")
                }
            case .method(let n, let sig, let isStatic):
                var cleanedSig = sig.replacingOccurrences(of: " infix", with: "")
                
                var fixModifier = ""
                if cleanedSig.contains(" prefix(") {
                    cleanedSig = cleanedSig.replacingOccurrences(of: " prefix(", with: "(")
                    fixModifier = "prefix "
                } else if cleanedSig.contains(" postfix(") {
                    cleanedSig = cleanedSig.replacingOccurrences(of: " postfix(", with: "(")
                    fixModifier = "postfix "
                }
                
                if !isClassOrProtocol {
                    let selfPattern1 = "\\b([a-zA-Z0-9_]+\\.)+\(self.name)<[^>]+>"
                    cleanedSig = cleanedSig.replacingOccurrences(of: selfPattern1, with: "Self", options: .regularExpression)
                    let selfPattern2 = "\\b([a-zA-Z0-9_]+\\.)+\(self.name)\\b"
                    cleanedSig = cleanedSig.replacingOccurrences(of: selfPattern2, with: "Self", options: .regularExpression)
                } else {
                    let prefixPattern = "\\b([a-zA-Z0-9_]+\\.)+\(self.name)\\b"
                    cleanedSig = cleanedSig.replacingOccurrences(of: prefixPattern, with: "\(self.name)", options: .regularExpression)
                }
                
                if n == "==" && (sig.contains(".Type") || sig.contains(".`Type`")) {
                    continue
                }

                let genericPlaceholders = ["A", "B", "C", "D"]
                var paramsToRemove = [String]()
                for p in genericPlaceholders {
                    let p_regex = try? NSRegularExpression(pattern: "<.*\\b\(p)[0-9]*\\b.*>", options: [])
                    let nsRange = NSRange(cleanedSig.startIndex..<cleanedSig.endIndex, in: cleanedSig)
                    
                    if let _ = p_regex?.firstMatch(in: cleanedSig, options: [], range: nsRange) {
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
                                 cleanedSig = cleanedSig.replacingOccurrences(of: "\\b\(v)\\b", with: "Generic\(p)", options: .regularExpression)
                             }
                        }
                    }
                }
                
                for p in paramsToRemove {
                    if let openBracket = cleanedSig.firstIndex(of: "<"),
                       let closeBracket = cleanedSig.firstIndex(of: ">"),
                       openBracket < closeBracket {
                        let prefix = cleanedSig[..<openBracket]
                        var list = String(cleanedSig[cleanedSig.index(after: openBracket)..<closeBracket])
                        let suffix = cleanedSig[closeBracket...]
                        
                        list = list.replacingOccurrences(of: "\\b\(p)\\b", with: "", options: .regularExpression)
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

                if n == "==" && cleanedSig.contains("(") {
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
                        
                        left = left.replacingOccurrences(of: "[^\\s(,<>]+\\.\\[", with: "[", options: .regularExpression)
                        right = right.replacingOccurrences(of: "[^\\s(,<>]+\\.\\[", with: "[", options: .regularExpression)
                        
                        if left == "Type" { left = "`Type`" }
                        if right == "Type" { right = "`Type`" }
                        if left.hasSuffix(".Type") && !left.contains("`Type`") { left = left.replacingOccurrences(of: ".Type", with: ".`Type`") }
                        if right.hasSuffix(".Type") && !right.contains("`Type`") { right = right.replacingOccurrences(of: ".Type", with: ".`Type`") }

                        lines.append("\(nextIndent)public static func == (lhs: \(left), rhs: \(right)) -> \(returnType) { \(returnType == "Bool" ? "true" : "fatalError()") }")
                        continue
                    }
                }
                
                let staticMod = isStatic ? "static " : ""
                if isProtocol { 
                    lines.append("\(nextIndent)\(staticMod)\(fixModifier)func \(cleanedSig)") 
                } else { 
                    var returnType = "Void"
                    if let arrowRange = cleanedSig.range(of: " -> ", options: .backwards) {
                        returnType = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                    let defaultVal = defaultReturnValue(for: returnType)
                    let body = defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }"
                    let finalBody = defaultVal == "fatalError()" ? "{ fatalError() }" : body
                    lines.append("\(nextIndent)public \(overrideMod)\(staticMod)\(fixModifier)func \(cleanedSig) \(finalBody)") 
                }
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
        if !isProtocol && !isEnum {
            let hasInitFrom = members.values.contains { if case .initializer(let s) = $0, s.contains("init(from:") { return true }; return false }
            let hasEncodeTo = members.values.contains { if case .method(let n, _, _) = $0, n == "encode" { return true }; return false }
            let hasHashInto = members.values.contains { if case .method(let n, _, _) = $0, n == "hash" { return true }; return false }

            if (conformances.contains("Decodable") || conformances.contains("Codable")) && !hasInitFrom {
                lines.append("\(nextIndent)public init(from decoder: any Decoder) throws {}")
            }
            if (conformances.contains("Encodable") || conformances.contains("Codable")) && !hasEncodeTo {
                lines.append("\(nextIndent)public func encode(to encoder: any Encoder) throws { fatalError() }")
            }
            if conformances.contains("Hashable") && !hasHashInto {
                lines.append("\(nextIndent)public func hash(into hasher: inout Hasher) { fatalError() }")
            }
        }
        
        lines.append("\(indent)}")
        
        return lines.joined(separator: "\n")
    }

    func hasEqualityOperator() -> Bool {
        for member in members.values {
            if case .method(let n, let sig, _) = member {
                if n == "==" || n.contains("==") || sig.starts(with: "==") {
                    return true
                }
            }
        }
        return false
    }

    func generateExtensions(defaultModule: String, path: String = "") -> String {
        var output = ""
        let separator = (path.isEmpty || path.hasSuffix("_")) ? "" : "."
        let currentPath = path.isEmpty ? name : path + separator + name
        
        if kind == "protocol" {
             let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
             for nested in sortedNested {
                 output += nested.generateCode(indent: "", nameOverride: "\(name)_\(nested.name)") + "\n\n"
             }
        }

        if kind == "class" && baseClass != "NSObject" && !conformances.contains("NSObject") {
             if hasEqualityOperator() {
                 output += "extension \(currentPath): Equatable {}\n"
             } else {
                 output += "extension \(currentPath): Equatable { public static func == (lhs: \(currentPath), rhs: \(currentPath)) -> Bool { fatalError() } }\n"
             }
        }
        
        let sortedNested = nestedTypes.values.sorted(by: { $0.name < $1.name })
        for nested in sortedNested {
            output += nested.generateExtensions(defaultModule: defaultModule, path: currentPath)
        }
        
        return output
    }
}
