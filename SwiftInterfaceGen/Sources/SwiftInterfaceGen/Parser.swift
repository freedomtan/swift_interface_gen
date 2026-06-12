import Foundation

class Parser {
    var modules: [String: TypeNode] = [:]
    var defaultModule: String = ""
    let swiftKeywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
        "func", "import", "init", "inout", "internal", "let", "open", "operator",
        "private", "protocol", "public", "reinit", "static", "struct", "subscript",
        "typealias", "var", "break", "case", "continue", "default", "defer",
        "do", "else", "fallthrough", "for", "guard", "if", "in", "is", "repeat",
        "return", "switch", "where", "while", "as", "Any", "AnyObject", "catch",
        "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws",
        "true", "try", "Type", "Protocol", "Array", "Dictionary", "Set", "String", "Int", "Bool", "Double", "Float", "AnyHashable"
    ]

    init() {}

    private func demangle(_ symbol: String) -> String? {
        return SwiftInterfaceGen.demangle(symbol: symbol)
    }

    private func escapeKeyword(_ name: String) -> String {
        if swiftKeywords.contains(name) {
            return "`\(name)`"
        }
        return name
    }

    private func setKind(_ kind: String, for node: TypeNode) {
        if node.kind == "unknown" || node.kind == "struct" {
             if kind == "class" || kind == "enum" || kind == "protocol" {
                 node.kind = kind
             }
        }
    }

    func parse(mangled: String, demangled: String, currentModule: String) {
        self.defaultModule = currentModule
        var d = demangled
        let d_orig = demangled
        
        let internalDescriptors = [
            "protocol descriptor for ",
            "nominal type descriptor for ",
            "type metadata for ",
            "metaclass for ",
            "associated type descriptor for ",
            "protocol requirements base descriptor for ",
            "method lookup function for ",
            "resilient class stub for ",
            "ObjC resilient class stub for ",
            "reflection metadata for ",
            "value witness table for "
        ]
        
        var forcedKind: String? = nil
        var isPrimaryDescriptor = false
        for desc in internalDescriptors {
            if d.starts(with: desc) {
                d = d.replacingOccurrences(of: desc, with: "")
                isPrimaryDescriptor = true
                if desc.contains("protocol") && !desc.contains("conformance") { forcedKind = "protocol" }
                else if desc.contains("class") || desc.contains("metaclass") { forcedKind = "class" }
                else if desc.contains("nominal type descriptor") {
                    if mangled.hasSuffix("OMn") { forcedKind = "enum" }
                    else if mangled.hasSuffix("VMn") { forcedKind = "struct" }
                    else if mangled.hasSuffix("CMn") { forcedKind = "class" }
                } else if desc.contains("protocol conformance descriptor") {
                    let parts = d.components(separatedBy: " : ")
                    if parts.count == 2 {
                        let typePath = parts[0].trimmingCharacters(in: .whitespaces)
                        var protoPath = parts[1].trimmingCharacters(in: .whitespaces)
                        if let inIndex = protoPath.range(of: " in ") {
                            protoPath = String(protoPath[..<inIndex.lowerBound]).trimmingCharacters(in: .whitespaces)
                        }
                        
                        let node = findOrCreateType(name: cleanType(typePath))
                        let simplifiedProto = simplifyType(protoPath)
                        node.conformances.insert(simplifiedProto)
                    }
                    return
                }
                break
            }
        }
        
        if !isPrimaryDescriptor {
            let junkKeywords = ["descriptor", "metadata", "witness table", "helper", "offset", "lookup function", "variable", "function pointer", "default argument", "enum case for", "lazy cache", "block copy", "block destroy", "property descriptor", "reflection metadata", "resilient class stub"]
            for junk in junkKeywords {
                if d_orig.contains(junk) {
                    if (d_orig.contains("dispatch thunk") || d_orig.contains("method descriptor")) && d_orig.contains("(") {
                        // Keep
                    } else {
                        return
                    }
                }
            }
        }
        
        if d_orig.contains(".modify") || d_orig.contains(".read") ||
           d_orig.contains("deinit") || d_orig.contains("__allocating_init") || 
           d_orig.contains(" where ") || d_orig.contains("initializeBufferWithCopy") ||
           d_orig.contains("async function pointer") {
            return
        }

        if d.contains("dispatch thunk of ") {
            d = d.replacingOccurrences(of: "dispatch thunk of ", with: "")
        } else if d.contains("method descriptor for ") {
            d = d.replacingOccurrences(of: "method descriptor for ", with: "")
        } else if d.contains("enum case for ") {
            d = d.replacingOccurrences(of: "enum case for ", with: "")
            if let openParen = d.firstIndex(of: "(") {
                let fullPath = String(d[..<openParen]).trimmingCharacters(in: .whitespaces)
                let (typeName, caseName) = splitPath(fullPath)
                if !typeName.isEmpty && !caseName.isEmpty {
                    let node = findOrCreateType(name: cleanType(typeName))
                    setKind("enum", for: node)
                    node.members[caseName] = .enumCase(caseName)
                }
            }
            return
        }

        let modulesToStrip = [defaultModule, "Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC"]
        for mod in modulesToStrip {
            if d.starts(with: mod + ".") {
                d = String(d.dropFirst(mod.count + 1))
            }
        }

        var cleanD = d
        if let inIndex = cleanD.range(of: " in ") {
            cleanD = String(cleanD[..<inIndex.lowerBound])
        }
        
        let isStatic = cleanD.starts(with: "static ")
        if isStatic {
            cleanD = String(cleanD.dropFirst(7))
        }

        if let openParenIndex = cleanD.firstIndex(of: "(") {
            let prefix = String(cleanD[..<openParenIndex])
            if !prefix.hasSuffix("<") && cleanD.contains(" -> ") {
                let fullMemberPath = prefix.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " :", with: "")
                if fullMemberPath.contains(".__") { return }
                
                var signatureRaw = String(cleanD[openParenIndex...])
                let (typeName, memberNameRaw) = splitPath(fullMemberPath)
                let memberName = memberNameRaw.replacingOccurrences(of: " :", with: "").trimmingCharacters(in: .whitespaces)
                
                if !typeName.isEmpty && !memberName.isEmpty {
                    if memberName.contains("getter") || memberName.contains("setter") { return }

                    let node = findOrCreateType(name: cleanType(typeName))
                    if let k = forcedKind { setKind(k, for: node) }
                    
                    let escapedMemberName = escapeKeyword(memberName)
                    
                    if memberName == "init" {
                        var depth = 0
                        var arrowIndex: String.Index? = nil
                        var j = signatureRaw.startIndex
                        while j < signatureRaw.endIndex {
                            if signatureRaw[j] == "(" { depth += 1 }
                            else if signatureRaw[j] == ")" { depth -= 1 }
                            else if depth == 0 && signatureRaw[j] == "-" && signatureRaw.index(after: j) < signatureRaw.endIndex && signatureRaw[signatureRaw.index(after: j)] == ">" {
                                arrowIndex = j
                                break
                            }
                            j = signatureRaw.index(after: j)
                        }
                        if let arrow = arrowIndex {
                            signatureRaw = String(signatureRaw[..<arrow]).trimmingCharacters(in: .whitespaces)
                        }
                        
                        let signature = simplifyType(signatureRaw)
                        let initSig = fixUnnamedParameters(signature)
                        node.members["init" + initSig] = .initializer("init" + initSig)
                    } else {
                        let signature = simplifyType(signatureRaw)
                        let fixedSignature = fixUnnamedParameters(escapedMemberName + signature)
                        node.members[fixedSignature] = .method(name: escapedMemberName, signature: fixedSignature, isStatic: isStatic)
                    }
                }
                return
            }
        }

        if cleanD.contains(" : ") {
            let parts = cleanD.components(separatedBy: " : ")
            var fullMemberPath = parts[0].trimmingCharacters(in: .whitespaces)
            let type = simplifyType(parts[1])
            
            var isReadOnly = d_orig.contains(" { get }") || !d_orig.contains(" { get set }")
            if fullMemberPath.hasSuffix(".getter") {
                fullMemberPath = String(fullMemberPath.dropLast(7))
                isReadOnly = true
            } else if fullMemberPath.hasSuffix(".setter") {
                fullMemberPath = String(fullMemberPath.dropLast(7))
                isReadOnly = false
            }
            
            let (typeName, memberName) = splitPath(fullMemberPath)
            if !typeName.isEmpty && !memberName.isEmpty {
                let node = findOrCreateType(name: cleanType(typeName))
                if let k = forcedKind { setKind(k, for: node) }
                
                if memberName == "rawValue" && (node.kind == "enum" || node.kind == "unknown") {
                    node.kind = "enum"
                    node.rawType = type
                }

                let escapedMemberName = escapeKeyword(memberName)
                node.members[escapedMemberName] = .property(name: escapedMemberName, type: type, isReadOnly: isReadOnly, isStatic: isStatic)
            }
            return
        }

        if !cleanD.contains("(") && !cleanD.contains(":") {
            let typeNameRaw = cleanType(cleanD.trimmingCharacters(in: .whitespaces))
            if typeNameRaw.isEmpty || typeNameRaw.contains(" ") || typeNameRaw.contains(":") { return }
            
            let typeName = typeNameRaw
            if let lastPart = typeName.components(separatedBy: ".").last, 
               let firstChar = lastPart.first, firstChar.isLowercase {
                if typeName.contains(".") { return }
            }

            let node = findOrCreateType(name: typeName)
            if let k = forcedKind { setKind(k, for: node) }
            
            if node.kind == "unknown" || node.kind == "struct" {
                if mangled.hasSuffix("V") || mangled.hasSuffix("VMn") { setKind("struct", for: node) }
                else if mangled.hasSuffix("C") || mangled.hasSuffix("CMn") { setKind("class", for: node) }
                else if mangled.hasSuffix("O") || mangled.hasSuffix("OMn") { setKind("enum", for: node) }
                else if mangled.hasSuffix("P") || mangled.hasSuffix("Mp") { setKind("protocol", for: node) }
            }
            
            if node.kind != "protocol" && node.kind != "class" {
                node.conformances.insert("Hashable")
                node.conformances.insert("Codable")
                node.conformances.insert("Sendable")
            }
            return
        }
    }

    private func findOrCreateType(name: String) -> TypeNode {
        var parts = name.components(separatedBy: ".")
        let standardModules = ["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC"]
        let knownFrameworks = ["GenerativeModelsFoundation", "TokenGeneration", "TokenGenerationCore", "PromptKit", "GenerativeFunctionsFoundation", "GenerativeFunctions", "ModelCatalog", "GenerativeModels"]

        if !standardModules.contains(parts[0]) && !knownFrameworks.contains(parts[0]) {
            parts.insert(defaultModule, at: 0)
        }
        
        let moduleName = parts[0]
        if modules[moduleName] == nil {
            modules[moduleName] = TypeNode(name: moduleName)
        }
        
        var current = modules[moduleName]!
        for part in parts.dropFirst() {
            if current.nestedTypes[part] == nil {
                current.nestedTypes[part] = TypeNode(name: part)
            }
            current = current.nestedTypes[part]!
        }
        return current
    }

    private func splitPath(_ path: String) -> (String, String) {
        let parts = path.components(separatedBy: ".")
        if parts.count == 1 {
            return (defaultModule, parts[0])
        }
        let memberName = parts.last!
        let typeName = parts.dropLast().joined(separator: ".")
        return (typeName, memberName)
    }

    private func cleanType(_ name: String) -> String {
        var n = name
        n = n.replacingOccurrences(of: "[0-9]{5,}", with: "", options: .regularExpression)
        
        let extensions = ["ModelCatalog", "GenerativeModels", "GenerativeModelsFoundation", "TokenGeneration", "TokenGenerationCore", "PromptKit", "GenerativeFunctions", "GenerativeFunctionsFoundation"]
        for ext in extensions {
            n = n.replacingOccurrences(of: "\\(extension in \(ext)\\):", with: "", options: .regularExpression)
        }
        
        if n.hasSuffix(".Array") { n = n.replacingOccurrences(of: ".Array", with: ".JSONArray") }
        if n.hasSuffix(".Dictionary") { n = n.replacingOccurrences(of: ".Dictionary", with: ".JSONDictionary") }
        if n.hasSuffix(".Object") { n = n.replacingOccurrences(of: ".Object", with: ".JSONObject") }
        if n.hasSuffix(".String") && n.contains("JSONSchema") { n = n.replacingOccurrences(of: ".String", with: ".JSONString") }

        return n
    }

    func simplifyType(_ type: String) -> String {
        var t = type
        
        t = t.replacingOccurrences(of: "Sequence<[^>]+>", with: "Sequence", options: .regularExpression)
        t = t.replacingOccurrences(of: "[^\\s(,<>]+\\.\\[", with: "[", options: .regularExpression)
        
        let standardMods = ["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC", "__C"]
        for mod in standardMods {
            t = t.replacingOccurrences(of: "\\b\(mod)\\.", with: "", options: .regularExpression)
        }
        
        t = t.replacingOccurrences(of: "OS_dispatch_queue", with: "DispatchQueue")
        t = t.replacingOccurrences(of: "NSOperatingSystemVersion", with: "OperatingSystemVersion")

        t = t.replacingOccurrences(of: "[0-9]{5,}", with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\)[0-9]+", with: ")", options: .regularExpression)

        let otherFrameworks = ["GenerativeModelsFoundation", "TokenGeneration", "TokenGenerationCore", "PromptKit", "GenerativeFunctionsFoundation", "GenerativeFunctions", "ModelCatalog", "GenerativeModels"]
        for mod in otherFrameworks {
             t = t.replacingOccurrences(of: "\\b\(mod)\\.", with: "\(mod)_", options: .regularExpression)
        }
        
        t = t.replacingOccurrences(of: "\\.Array\\b", with: ".JSONArray", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\.Dictionary\\b", with: ".JSONDictionary", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\.Object\\b", with: ".JSONObject", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\.String\\b", with: ".JSONString", options: .regularExpression)

        let protocols = ["CatalogResource", "AssetBackedResource", "LLMAdapter", "LLMModel", "ManagedResource", "ResourceBundle", "SafetyFailureWrapper", "UseCaseStatusesWrapper", "AsyncSequence", "PromptRetrieverProtocol", "CatalogClientProtocol", "InferenceSessionProtocol", "AttachmentTokenizer", "ChatLanguageModelResponse", "ChatLanguageModelProviding", "ChatLanguageModelProvidingStreamable", "ChatMessageResponse", "CompletionResponse", "CompletionLanguageModelProviding", "CompletionLanguageModelResponse", "CompletionLanguageModelProvidingStreamable"]
        for p in protocols {
             t = t.replacingOccurrences(of: "\\b([a-zA-Z0-9_$]+_)?\(p)\\b(?!\\.)", with: "any $1\(p)", options: .regularExpression)
        }

        var prevT = ""
        while prevT != t {
            prevT = t
            t = t.replacingOccurrences(of: "any any ", with: "any ")
        }

        t = t.replacingOccurrences(of: "Optional<", with: "___OPT_T___")
        t = t.replacingOccurrences(of: "\\bOptional\\b(?!<)", with: "Optional<Any>", options: .regularExpression)
        t = t.replacingOccurrences(of: "___OPT_T___", with: "Optional<")
        
        t = t.replacingOccurrences(of: "\\bany ResourceBundle\\b", with: "any ResourceBundle_P", options: .regularExpression)

        t = t.replacingOccurrences(of: "\\bDictionary\\b(?![<])", with: "[AnyHashable: Any]", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\bArray\\b(?![<])", with: "[Any]", options: .regularExpression)
        
        while prevT != t {
            prevT = t
            t = t.replacingOccurrences(of: "[a-zA-Z0-9_$]+\\.\\[", with: "[", options: .regularExpression)
            t = t.replacingOccurrences(of: "[a-zA-Z0-9_$]+\\.<", with: "<", options: .regularExpression)
        }
        t = t.replacingOccurrences(of: "\\.\\[", with: "[")

        t = t.replacingOccurrences(of: "\\(async throws\\s*\\)", with: "async throws", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\(async\\s*\\)", with: "async", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\(throws\\s*\\)", with: "throws", options: .regularExpression)
        
        t = t.replacingOccurrences(of: "\\(extension in [^)]+\\):", with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\(\\bextension\\b[^)]+\\)", with: "Any", options: .regularExpression)
        t = t.replacingOccurrences(of: "== String>", with: ">")
        t = t.replacingOccurrences(of: "== A>", with: ">")
        t = t.replacingOccurrences(of: "\\bsome\\b", with: "Any", options: .regularExpression)
        
        if t.contains("set {") {
            t = String(t.components(separatedBy: "set {").first!).trimmingCharacters(in: .whitespaces)
        }
        if let brace = t.firstIndex(of: "{") {
            t = String(t[..<brace]).trimmingCharacters(in: .whitespaces)
        }
        t = t.replacingOccurrences(of: "}", with: "")

        return t
    }

    private func fixUnnamedParameters(_ sig: String) -> String {
        guard let openParen = sig.firstIndex(of: "(") else { return sig }
        let prefix = sig[..<sig.index(after: openParen)]
        let rest = String(sig[sig.index(after: openParen)...])
        
        var depth = 0
        var matchingIndex: String.Index? = nil
        for (idx, char) in rest.enumerated() {
            if char == "(" { depth += 1 }
            else if char == ")" {
                if depth == 0 {
                    matchingIndex = rest.index(rest.startIndex, offsetBy: idx)
                    break
                }
                depth -= 1
            }
        }
        guard let closeParen = matchingIndex else { return sig }
        
        let paramsPart = rest[..<closeParen]
        let suffix = rest[closeParen...]
        
        var paramList = [String]()
        var current = ""
        var pDepth = 0
        var aDepth = 0
        var sDepth = 0
        for c in paramsPart {
            if c == "(" { pDepth += 1 }
            else if c == ")" { pDepth -= 1 }
            else if c == "<" { aDepth += 1 }
            else if c == ">" { aDepth -= 1 }
            else if c == "[" { sDepth += 1 }
            else if c == "]" { sDepth -= 1 }
            
            if c == "," && pDepth == 0 && aDepth == 0 && sDepth == 0 {
                paramList.append(current)
                current = ""
            } else {
                current.append(c)
            }
        }
        paramList.append(current)

        var newParams = [String]()
        for p in paramList {
            let trimmed = p.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            var hasLabel = false
            var depth_p = 0
            var depth_a = 0
            var depth_s = 0
            for c in trimmed {
                if c == "(" { depth_p += 1 }
                else if c == ")" { depth_p -= 1 }
                else if c == "<" { depth_a += 1 }
                else if c == ">" { depth_a -= 1 }
                else if c == "[" { depth_s += 1 }
                else if c == "]" { depth_s -= 1 }
                else if c == ":" && depth_p == 0 && depth_a == 0 && depth_s == 0 {
                    hasLabel = true
                    break
                }
            }

            if !hasLabel && trimmed != "()" {
                newParams.append("_: " + trimmed)
            } else {
                newParams.append(trimmed)
            }
        }
        return String(prefix) + newParams.joined(separator: ", ") + String(suffix)
    }
    
    func generateAll() -> String {
        let shimHeader = """
import Foundation
import CoreFoundation
import UniformTypeIdentifiers
import os
import ObjectiveC

// Fundamental shims
public typealias NSCoder = Foundation.NSCoder
public typealias NSZone = Foundation.NSZone
public typealias NSXPCConnection = Foundation.NSXPCConnection
public struct CoherenceToken: Hashable, Codable, Sendable {}
public struct UAFAssetSetConsistencyToken: Hashable, Codable, Sendable {}

public protocol AnyProtocol {}
public struct _Span<T>: Hashable, Codable, Sendable {}
public struct _MutableSpan<T>: Hashable, Codable, Sendable {}
public struct _RawSpan: Hashable, Codable, Sendable {}
public struct _MutableRawSpan: Hashable, Codable, Sendable {}
public struct PlaceholderA1<T>: AnyProtocol, Hashable, Codable, Sendable { 
    public struct Interface {} 
    public struct C {}
    public struct M {}
    public struct ModelType {}
    public struct TokenizerType {}
    public struct RemoteService { public struct Interface {} }
    public struct Service { public struct Interface {} }
    public struct Builder: Hashable, Codable, Sendable {}
    public struct RecognizerCache: Hashable, Codable, Sendable {}
    public struct ModelConfiguration: Hashable, Codable, Sendable {}
    public struct CustomDataType: Hashable, Codable, Sendable {}
    public struct RetrievedResult: Hashable, Codable, Sendable {}
    public struct CatalogAssetType: Hashable, Codable, Sendable {}
    public struct ValueKind: Hashable, Codable, Sendable {}
    public struct Value: Hashable, Codable, Sendable {}
    public struct Component: Hashable, Codable, Sendable {
        public struct Value: Hashable, Codable, Sendable {}
        public struct ValueKind: Hashable, Codable, Sendable {}
    }
    public struct RunnerConfiguration: Hashable, Codable, Sendable {}
    public struct Sanitizer: Hashable, Codable, Sendable {}
    public struct Content: Hashable, Codable, Sendable {}
    public struct Criteria: Hashable, Codable, Sendable {}
    public struct Arguments: Hashable, Codable, Sendable {}
    public struct Output: Hashable, Codable, Sendable {}
    public struct ChatStringResponse: Hashable, Codable, Sendable {}
    public struct ChatStringStreamResponse: Hashable, Codable, Sendable { public struct Stream: Hashable, Codable, Sendable {} }
    public struct CompletionStringParameters: Hashable, Codable, Sendable {}
    public struct CompletionStringResponse: Hashable, Codable, Sendable {}
    public struct CompletionStringStreamParameters: Hashable, Codable, Sendable {}
    public struct CompletionStringStreamResponse: Hashable, Codable, Sendable { public struct Stream: Hashable, Codable, Sendable {} }
    public typealias ChatStringParameters = PlaceholderA1<Any>
    public typealias ChatStringStreamParameters = PlaceholderA1<Any>
    public typealias Stream = PlaceholderA1<Any>
}
public struct PlaceholderB1: AnyProtocol, Hashable, Codable, Sendable { 
    public struct Interface {} 
    public struct ChatOneShotGenerableResponseAdditionalInfo: Hashable, Codable, Sendable {}
    public struct CompletionOneShotGenerableResponseAdditionalInfo: Hashable, Codable, Sendable {}
}

public typealias A = PlaceholderA1<Any>
public typealias B = PlaceholderB1
public typealias A1 = PlaceholderA1<Any>
public typealias B1 = PlaceholderB1
public typealias C1 = PlaceholderA1<Any>
public typealias D1 = PlaceholderA1<Any>
public typealias A2 = PlaceholderA1<Any>

public typealias IOSurface = PlaceholderA1<Any>
public protocol ResourceBundle: Hashable {}
public typealias ResourceBundle_P = ResourceBundle
public struct ResourceBundleIdentifier<T>: Hashable, Codable, Sendable { 
    public let rawValue: String; public init(rawValue: String) { self.rawValue = rawValue }
    public var id: String { rawValue }
}
public struct CatalogResourceResult: Hashable, Codable, Sendable {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws { fatalError() }
}
public protocol CatalogResource: Hashable { var id: String { get } }
public struct CatalogAsset<T, U>: Hashable, Codable, Sendable {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws { fatalError() }
}

public enum InternalSwiftProtobuf {
    public struct UnknownStorage: Hashable, Codable, Sendable {}
    public struct _NameMap { public init() {} }
}

// Extra frameworks
public enum AppleIntelligenceReporting {
    public struct AppleIntelligenceErrorCategory: Hashable, Codable, Sendable {}
    public struct AppleIntelligenceError: Hashable, Codable, Sendable {}
}
public enum ModelManagerServices {
    public struct InferenceProviderRequestConfiguration: Hashable, Codable, Sendable {}
    public struct InferenceError: Hashable, Codable, Sendable {}
    public struct Session: Hashable, Codable, Sendable {}
    public struct ClientData: Hashable, Codable, Sendable {}
    public struct Version: Hashable, Codable, Sendable {}
}
public enum GenerativeFunctionsInstrumentation {
    public struct GenerativeFunctionInstrumenter: Hashable, Codable, Sendable {}
    public struct EventReporter: Hashable, Codable, Sendable {}
}
public struct CMTime: Hashable, Codable, Sendable {}
public struct UUID: Hashable, Codable, Sendable {}
public typealias CVBufferRef = PlaceholderA1<Any>
public enum XPC {
    public struct XPCCodableObject: Hashable, Codable, Sendable {}
    public struct XPCDictionary: Hashable, Codable, Sendable {}
}
public enum Network {
    public struct NWConnection {
        public struct ConnectionProgressReport: Hashable, Codable, Sendable {}
    }
}
public struct TokenGeneration_TokenStream<T>: Hashable, Codable, Sendable {
    public init(from decoder: any Decoder) throws { fatalError() }
    public func encode(to encoder: any Encoder) throws { fatalError() }
}
public struct TokenGeneration_Prompt: Hashable, Codable, Sendable {
    public struct SpecialToken: Hashable, Codable, Sendable {}
    public struct Rendering: Hashable, Codable, Sendable {}
    public struct ImageAttachment: Hashable, Codable, Sendable {}
    public struct ImageEmbeddingAttachment: Hashable, Codable, Sendable {}
    public struct MediaCollectionAttachment: Hashable, Codable, Sendable {}
    public struct ImageSurfaceAttachment: Hashable, Codable, Sendable {}
    public struct PreprocessedImageAttachment: Hashable, Codable, Sendable {}
    public struct AudioEmbeddingAttachment: Hashable, Codable, Sendable {}
    public struct ToolCall: Hashable, Codable, Sendable { public struct Function: Hashable, Codable, Sendable {} }
    public struct ToolResult: Hashable, Codable, Sendable {}
    public struct Turn: Hashable, Codable, Sendable { public struct Segment: Hashable, Codable, Sendable {} }
    public struct ToolCallResult: Hashable, Codable, Sendable {}
    public struct MediaSegment: Hashable, Codable, Sendable {}
    public struct ResponseFormat: Hashable, Codable, Sendable {}
    public struct StringInterpolation: Hashable, Codable, Sendable {}
    public struct Component: Hashable, Codable, Sendable {
        public struct Value: Hashable, Codable, Sendable {}
        public struct ValueKind: Hashable, Codable, Sendable {}
    }
}
public enum FeatureFlags { public struct FeatureFlagsKey: Hashable, Codable, Sendable {} }
public typealias ResourceMetadata = PlaceholderA1<Any>
public struct UAFSubscriptionDownloadStatus: Hashable, Codable, Sendable {}
public typealias GenericA = PlaceholderA1<Any>
public typealias GenericB = PlaceholderA1<Any>
public typealias GenericC = PlaceholderA1<Any>
public typealias GenericD = PlaceholderA1<Any>
public struct GMAvailabilityStatus: Hashable, Codable, Sendable {}
public typealias NSUserDefaults = UserDefaults
public typealias OS_os_activity = PlaceholderA1<Any>
public typealias os_activity_flag_t = UInt32

// Protocol shims with primary associated types
public protocol SHIM_ChatLanguageModelResponse<Content>: Hashable { associatedtype Content }
public protocol SHIM_ChatLanguageModelProviding<Parameters>: Hashable { associatedtype Parameters }
public protocol SHIM_ChatLanguageModelProvidingStreamable<Parameters>: Hashable { associatedtype Parameters }
public protocol SHIM_ChatMessageResponse<Content>: Hashable { associatedtype Content }
public protocol SHIM_CompletionResponse<Content>: Hashable { associatedtype Content }
public protocol SHIM_CompletionLanguageModelProviding<Parameters>: Hashable { associatedtype Parameters }
public protocol SHIM_CompletionLanguageModelResponse<Content>: Hashable { associatedtype Content }
public protocol SHIM_CompletionLanguageModelProvidingStreamable<Parameters>: Hashable { associatedtype Parameters }

"""
        var output = shimHeader
        var definedTypes = Set<String>()
        
        func markGenericRecursive(node: TypeNode) {
            if ["ResourceBundleIdentifier", "CatalogAsset", "SupportedArgument", "GenerationGuide", "FailureRecord", "OverrideHint", "Criteria", "UserDefault", "__LoadedUseCaseConfigurations", "GenerativeStream", "Float4", "Float8", "BFloat16", "Tensor", "TensorRequirements", "UnsafeArrayPointer", "UnsafeMutableArrayPointer"].contains(node.name) {
                 if !node.name.hasPrefix("JSON") {
                      node.isGeneric = true
                 }
            }
            for nested in node.nestedTypes.values {
                markGenericRecursive(node: nested)
            }
        }

        let sortedModuleNames = modules.keys.sorted()
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC"].contains(moduleName) { continue }
            guard let module = modules[moduleName] else { continue }
            
            for type in module.nestedTypes.values {
                markGenericRecursive(node: type)
            }
            
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            for type in sortedTypes {
                let flattenedName = "\(moduleName)_\(type.name)"
                if definedTypes.contains(flattenedName) { continue }
                
                // Always skip fundamental shims if they collide by name
                if ["NSCoder", "NSZone", "NSXPCConnection", "CoherenceToken", "UAFAssetSetConsistencyToken", "PlaceholderA1", "PlaceholderB1", "A", "B", "A1", "B1", "C1", "D1", "A2", "IOSurface", "ResourceBundle", "ResourceBundleIdentifier", "CatalogResourceResult", "CatalogResource", "CatalogAsset", "AppleIntelligenceReporting", "ModelManagerServices", "GenerativeFunctionsInstrumentation", "CMTime", "UUID", "CVBufferRef", "XPC", "Network", "TokenStream", "Prompt", "FeatureFlags", "ResourceMetadata", "UAFSubscriptionDownloadStatus", "GenericA", "GenericB", "GenericC", "GenericD", "GMAvailabilityStatus", "NSUserDefaults", "OS_os_activity", "os_activity_flag_t"].contains(type.name) {
                     continue 
                }
                
                definedTypes.insert(flattenedName)
                output += type.generateCode(indent: "", nameOverride: flattenedName) + "\n\n"
            }
        }
        
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC"].contains(moduleName) { continue }
            guard let module = modules[moduleName] else { continue }
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            for type in sortedTypes {
                let flattenedName = "\(moduleName)_\(type.name)"
                if !definedTypes.contains(flattenedName) { continue }
                
                output += type.generateExtensions(defaultModule: defaultModule, path: "\(moduleName)_")
            }
        }

        // Generate namespaces and default module aliases
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC"].contains(moduleName) { continue }
            guard let module = modules[moduleName] else { continue }
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            if sortedTypes.isEmpty { continue }

            output += "public enum \(moduleName)_Namespace {\n"
            for type in sortedTypes {
                let flattenedName = "\(moduleName)_\(type.name)"
                output += "    public typealias \(type.name) = \(flattenedName)\n"
            }
            output += "}\n\n"
            
            // If the module name doesn't collide with a type, provide it as a convenient namespace alias
            if !definedTypes.contains(moduleName) && moduleName != defaultModule {
                output += "public typealias \(moduleName) = \(moduleName)_Namespace\n"
            }

            if moduleName == defaultModule {
                let shimsSet = Set(["NSCoder", "NSZone", "NSXPCConnection", "CoherenceToken", "UAFAssetSetConsistencyToken", "PlaceholderA1", "PlaceholderB1", "A", "B", "A1", "B1", "C1", "D1", "A2", "IOSurface", "ResourceBundle", "ResourceBundleIdentifier", "CatalogResourceResult", "CatalogResource", "CatalogAsset", "AppleIntelligenceReporting", "ModelManagerServices", "GenerativeFunctionsInstrumentation", "CMTime", "UUID", "CVBufferRef", "XPC", "Network", "FeatureFlags", "ResourceMetadata", "UAFSubscriptionDownloadStatus", "GenericA", "GenericB", "GenericC", "GenericD", "GMAvailabilityStatus", "NSUserDefaults", "OS_os_activity", "os_activity_flag_t"])
                for type in sortedTypes {
                    let flattenedName = "\(moduleName)_\(type.name)"
                    if type.name != moduleName && definedTypes.contains(flattenedName) && !shimsSet.contains(type.name) {
                        output += "public typealias \(type.name) = \(flattenedName)\n"
                    }
                }
                output += "\n"
            }
        }
        
        let shims = ["NSCoder", "NSZone", "NSXPCConnection", "CoherenceToken", "UAFAssetSetConsistencyToken", "PlaceholderA1", "PlaceholderB1", "A", "B", "A1", "B1", "C1", "D1", "A2", "IOSurface", "ResourceBundle", "ResourceBundleIdentifier", "CatalogResourceResult", "CatalogResource", "CatalogAsset", "AppleIntelligenceReporting", "ModelManagerServices", "GenerativeFunctionsInstrumentation", "CMTime", "UUID", "CVBufferRef", "XPC", "Network", "FeatureFlags", "ResourceMetadata", "UAFSubscriptionDownloadStatus", "GenericA", "GenericB", "GenericC", "GenericD", "GMAvailabilityStatus", "NSUserDefaults", "OS_os_activity", "os_activity_flag_t"]
        let otherFrameworks = ["GenerativeModelsFoundation", "TokenGeneration", "TokenGenerationCore", "PromptKit", "GenerativeFunctionsFoundation", "GenerativeFunctions", "ModelCatalog", "GenerativeModels"]
        for mod in otherFrameworks {
             for shim in shims {
                 if !definedTypes.contains("\(mod)_\(shim)") {
                     output += "public typealias \(mod)_\(shim) = \(shim)\n"
                 }
             }
             if mod != "TokenGeneration" {
                 if !definedTypes.contains("\(mod)_TokenStream") {
                     output += "public typealias \(mod)_TokenStream<T> = TokenGeneration_TokenStream<T>\n"
                 }
                 if !definedTypes.contains("\(mod)_Prompt") {
                     output += "public typealias \(mod)_Prompt = TokenGeneration_Prompt\n"
                 }
             }
        }

        output = output.replacingOccurrences(of: "TestCatalog.Resource.ResourceMetadata", with: "ResourceMetadata")
        output = output.replacingOccurrences(of: "Catalog.Resource.ResourceMetadata", with: "ResourceMetadata")
        
        // Final alias resolution for protocol shims
        let protoShims = ["ChatLanguageModelResponse", "ChatLanguageModelProviding", "ChatLanguageModelProvidingStreamable", "ChatMessageResponse", "CompletionResponse", "CompletionLanguageModelProviding", "CompletionLanguageModelResponse", "CompletionLanguageModelProvidingStreamable"]
        for p in protoShims {
             if !definedTypes.contains("GenerativeFunctionsFoundation_\(p)") {
                 output += "public typealias GenerativeFunctionsFoundation_\(p)<T> = SHIM_\(p)<T>\n"
             }
             if !definedTypes.contains("PromptKit_\(p)") {
                 output += "public typealias PromptKit_\(p)<T> = SHIM_\(p)<T>\n"
             }
        }

        return output
    }
}
