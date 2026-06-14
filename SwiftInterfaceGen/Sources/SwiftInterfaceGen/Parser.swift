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

    var discoveredGenerics = [String: Int]() // [DottedType: Count]
    var discoveredProtocols = Set<String>() // [DottedType]
    var discoveredNamespaces = Set<String>()
    var discoveredConcreteTypes = Set<String>()
    var processedModules = Set<String>()
    var currentPrecomputeModule = "ModelCatalog"
    var frameworkInterfaceCache: [String: String] = [:]
    var namespaceFrameworkCache: [String: Bool] = [:]
    var frameworkDefinedTypesCache: [String: Set<String>] = [:]
    private var scannedLocalSwiftFiles = false

    init() {}

    func precompute(demangled: String) {
        func countTopLevelCommas(in s: String) -> Int {
            var commas = 0
            var depth = 0
            var parenDepth = 0
            for char in s {
                if char == "<" { depth += 1 }
                else if char == ">" { depth -= 1 }
                else if char == "(" { parenDepth += 1 }
                else if char == ")" { parenDepth -= 1 }
                else if char == "," {
                    if depth == 0 && parenDepth == 0 {
                        commas += 1
                    }
                }
            }
            return commas + 1
        }

        // Infer generic types and their max parameter count using fully qualified names
        let genericTypes = demangled.scanGenericTypeApplications()
        for (name, params) in genericTypes {
            let shortName = name.components(separatedBy: ".").last!
            // Skip standard library types and single-letter generic parameter placeholders
            if shortName.count == 1 || ["Optional", "Array", "Dictionary", "Set", "UnsafePointer", "UnsafeMutablePointer", "UnsafeRawPointer", "UnsafeMutableRawPointer"].contains(shortName) {
                continue
            }
            
            let count = countTopLevelCommas(in: params)
            let currentMax = discoveredGenerics[name] ?? 0
            discoveredGenerics[name] = max(currentMax, count)
        }
        
        // Infer namespaces and verify they actually exist as frameworks in the SDK
        let namespaces = demangled.scanNamespaces()
        for ns in namespaces {
            if !["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC", "__C"].contains(ns) {
                let isFramework: Bool
                if let cached = namespaceFrameworkCache[ns] {
                    isFramework = cached
                } else {
                    let path1 = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks/\(ns).framework"
                    let path2 = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/SubFrameworks/\(ns).framework"
                    let exists = FileManager.default.fileExists(atPath: path1) || FileManager.default.fileExists(atPath: path2)
                    namespaceFrameworkCache[ns] = exists
                    isFramework = exists
                }
                if isFramework {
                    discoveredNamespaces.insert(ns)
                }
            }
        }
        
        // Infer protocols and preserve their dotted namespaces
        if demangled.contains("protocol descriptor for ") {
            let name = demangled.replacingOccurrences(of: "protocol descriptor for ", with: "")
            discoveredProtocols.insert(name)
        }
        let protocols = demangled.scanProtocols()
        for proto in protocols {
            discoveredProtocols.insert(proto)
        }
    }

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
        if ["struct", "class", "enum"].contains(node.kind) {
            discoveredConcreteTypes.insert(node.name)
        }
    }

    func parse(mangled: String, demangled: String, currentModule: String) {
        self.defaultModule = currentModule
        self.currentPrecomputeModule = currentModule
        
        if !scannedLocalSwiftFiles {
            scannedLocalSwiftFiles = true
            scanLocalSwiftFiles(currentModule: currentModule)
        }
        
        // Populate forced generics for the current module
        for (t, count) in ConfigManager.shared.forceGenerics {
            let fullPath = currentModule + "." + t
            if discoveredGenerics[fullPath] == nil {
                discoveredGenerics[fullPath] = count
            }
        }
        
        var d = demangled
        let d_orig = demangled
        
        if d_orig.starts(with: "associated type descriptor for ") {
            let fullPath = d_orig.replacingOccurrences(of: "associated type descriptor for ", with: "").trimmingCharacters(in: .whitespaces)
            let (typeName, assocName) = splitPath(fullPath)
            if !typeName.isEmpty && !assocName.isEmpty {
                let node = findOrCreateType(name: cleanType(typeName))
                setKind("protocol", for: node)
                node.members[assocName] = .associatedType("associatedtype \(assocName)")
            }
            return
        }
        
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

        if !ConfigManager.shared.systemModules.contains(parts[0]) && !discoveredNamespaces.contains(parts[0]) && parts[0] != defaultModule {
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
        if n.range(of: "[0-9]{5,}", options: .regularExpression) != nil {
            n = n.replacingOccurrences(of: "[0-9]{5,}", with: "", options: .regularExpression)
        }
        
        if n.contains("(extension in ") {
            for ext in discoveredNamespaces {
                n = n.replacingOccurrences(of: "\\(extension in \(ext)\\):", with: "", options: .regularExpression)
            }
        }
        
        if n.hasSuffix(".Array") { n = n.replacingOccurrences(of: ".Array", with: ".JSONArray") }
        if n.hasSuffix(".Dictionary") { n = n.replacingOccurrences(of: ".Dictionary", with: ".JSONDictionary") }
        if n.hasSuffix(".Object") { n = n.replacingOccurrences(of: ".Object", with: ".JSONObject") }
        if n.hasSuffix(".String") && n.contains("JSONSchema") { n = n.replacingOccurrences(of: ".String", with: ".JSONString") }

        return n
    }

    func simplifyType(_ type: String) -> String {
        var t = type
        
        let words = discoveredProtocols.filter { t.contains($0) }
        for p in words {
             t = t.replacingOccurrences(of: "\\b\(p)\\b", with: "any \(p)", options: .regularExpression)
        }
        
        if t.contains("<") || t.contains("[") {
            t = t.replacingOccurrences(of: "Sequence<[^>]+>", with: "Sequence", options: .regularExpression)
            t = t.replacingOccurrences(of: "[^\\s(,<>]+\\.\\[", with: "[", options: .regularExpression)
        }
        
        for mod in ConfigManager.shared.systemModules {
            if t.contains(mod) {
                t = t.replacingOccurrences(of: "\\b\(mod)\\.", with: "", options: .regularExpression)
            }
        }
        
        if t.contains("OS_dispatch_queue") {
            t = t.replacingOccurrences(of: "OS_dispatch_queue", with: "DispatchQueue")
        }
        if t.contains("NSOperatingSystemVersion") {
            t = t.replacingOccurrences(of: "NSOperatingSystemVersion", with: "OperatingSystemVersion")
        }

        t = t.replacingOccurrences(of: "[0-9]{5,}", with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\)[0-9]+", with: ")", options: .regularExpression)

        var frameworks = Array(discoveredNamespaces)
        if !frameworks.contains(defaultModule) && !defaultModule.isEmpty {
            frameworks.append(defaultModule)
        }
        for mod in frameworks {
             if t.contains(mod) {
                 if mod == defaultModule {
                     t = t.replacingOccurrences(of: "\\b\(mod)\\.", with: "", options: .regularExpression)
                 } else {
                     t = t.replacingOccurrences(of: "\\b\(mod)\\.", with: "\(mod)_", options: .regularExpression)
                 }
             }
        }
        
        if t.contains(".") {
            t = t.replacingOccurrences(of: "\\.Array\\b", with: ".JSONArray", options: .regularExpression)
            t = t.replacingOccurrences(of: "\\.Dictionary\\b", with: ".JSONDictionary", options: .regularExpression)
            t = t.replacingOccurrences(of: "\\.Object\\b", with: ".JSONObject", options: .regularExpression)
            t = t.replacingOccurrences(of: "\\.String\\b", with: ".JSONString", options: .regularExpression)
        }

        var prevT = ""
        while prevT != t {
            prevT = t
            t = t.replacingOccurrences(of: "any any ", with: "any ")
        }

        if t.contains("Optional") {
            t = t.replacingOccurrences(of: "Optional<", with: "___OPT_T___")
            t = t.replacingOccurrences(of: "\\bOptional\\b(?!<)", with: "Optional<Any>", options: .regularExpression)
            t = t.replacingOccurrences(of: "___OPT_T___", with: "Optional<")
        }
        
        if t.contains("ResourceBundle") {
            t = t.replacingOccurrences(of: "\\bany ResourceBundle\\b", with: "any ResourceBundle_P", options: .regularExpression)
        }

        if t.contains("Dictionary") {
            t = t.replacingOccurrences(of: "\\bDictionary\\b(?![<])", with: "[AnyHashable: Any]", options: .regularExpression)
        }
        if t.contains("Array") {
            t = t.replacingOccurrences(of: "\\bArray\\b(?![<])", with: "[Any]", options: .regularExpression)
        }
        
        while prevT != t {
            prevT = t
            t = t.replacingOccurrences(of: "[a-zA-Z0-9_$]+\\.\\[", with: "[", options: .regularExpression)
            t = t.replacingOccurrences(of: "[a-zA-Z0-9_$]+\\.<", with: "<", options: .regularExpression)
        }
        t = t.replacingOccurrences(of: "\\.\\[", with: "[")

        if t.contains("async") {
            t = t.replacingOccurrences(of: "\\(async throws\\s*\\)", with: "async throws", options: .regularExpression)
            t = t.replacingOccurrences(of: "\\(async\\s*\\)", with: "async", options: .regularExpression)
        }
        if t.contains("throws") {
            t = t.replacingOccurrences(of: "\\(throws\\s*\\)", with: "throws", options: .regularExpression)
        }
        
        if t.contains("extension") {
            t = t.replacingOccurrences(of: "\\(extension in [^)]+\\):", with: "", options: .regularExpression)
            t = t.replacingOccurrences(of: "\\(\\bextension\\b[^)]+\\)", with: "Any", options: .regularExpression)
        }
        if t.contains("==") {
            t = t.replacingOccurrences(of: "== String>", with: ">")
            t = t.replacingOccurrences(of: "== A>", with: ">")
        }
        if t.contains("some") {
            t = t.replacingOccurrences(of: "\\bsome\\b", with: "Any", options: .regularExpression)
        }
        
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
    
    func isModuleAvailable(_ name: String) -> Bool {
        let sdkRoot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
        let paths = [
            "\(sdkRoot)/System/Library/Frameworks/\(name).framework",
            "\(sdkRoot)/System/Library/PrivateFrameworks/\(name).framework",
            "\(sdkRoot)/System/Library/SubFrameworks/\(name).framework",
            "LocalFrameworks/\(name).framework"
        ]
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        let system = ["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC", "CoreVideo", "CoreMedia", "IOSurface"]
        if system.contains(name) {
            return true
        }
        return false
    }

    func genericParamsString(for node: TypeNode) -> String {
        if !node.isGeneric { return "" }
        var count = 1
        let fullPath1 = defaultModule + "." + node.name
        let fullPath2 = node.name
        if let inferredCount = discoveredGenerics[fullPath1] {
            count = inferredCount
        } else if let inferredCount = discoveredGenerics[fullPath2] {
            count = inferredCount
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
        return "<\(params.joined(separator: ", "))>"
    }
    
    private func getFrameworkInterfaceContent(module: String) -> String {
        if let cached = frameworkInterfaceCache[module] {
            return cached
        }
        var mergedContent = ""
        let sdkRoot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
        let searchDirs = [
            "\(sdkRoot)/System/Library/Frameworks/\(module).framework/Modules/\(module).swiftmodule",
            "\(sdkRoot)/System/Library/PrivateFrameworks/\(module).framework/Modules/\(module).swiftmodule",
            "\(sdkRoot)/System/Library/SubFrameworks/\(module).framework/Modules/\(module).swiftmodule",
            "LocalFrameworks/\(module).framework/Modules/\(module).swiftmodule"
        ]
        
        for dir in searchDirs {
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir) else { continue }
            for file in files {
                if file.hasSuffix(".swiftinterface") {
                    let path = "\(dir)/\(file)"
                    if let content = try? String(contentsOfFile: path, encoding: .utf8) {
                        mergedContent += content + "\n"
                    }
                }
            }
        }
        frameworkInterfaceCache[module] = mergedContent
        return mergedContent
    }

    func getFrameworkDefinedTypes(module: String) -> Set<String> {
        if let cached = frameworkDefinedTypesCache[module] {
            return cached
        }
        let content = getFrameworkInterfaceContent(module: module)
        let defined = content.scanFrameworkDefinedTypes()
        frameworkDefinedTypesCache[module] = defined
        return defined
    }

    func isTypeDefinedInFramework(module: String, typeName: String) -> Bool {
        return getFrameworkDefinedTypes(module: module).contains(typeName)
    }

    func generateAll() -> String {
        // Set all referenced but undefined types to struct
        func defaultUnknownTypes(node: TypeNode) {
            if node.kind == "unknown" {
                node.kind = "struct"
            }
            for nested in node.nestedTypes.values {
                defaultUnknownTypes(node: nested)
            }
        }
        for module in modules.values {
            for type in module.nestedTypes.values {
                defaultUnknownTypes(node: type)
            }
        }

        let shimHeader = ""
        var output = shimHeader
        var definedTypes = Set<String>()
        
        func markGenericRecursive(node: TypeNode) {
            let fullPath1 = defaultModule + "." + node.name
            let fullPath2 = node.name
            if discoveredGenerics[fullPath1] != nil || discoveredGenerics[fullPath2] != nil {
                 if !node.name.hasPrefix("JSON") {
                      node.isGeneric = true
                 }
            }
            for nested in node.nestedTypes.values {
                markGenericRecursive(node: nested)
            }
        }

        let sortedModuleNames = modules.keys.sorted()
        
        // Phase 1: Generate type/class/enum declarations
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC"].contains(moduleName) { continue }
            if moduleName != defaultModule && isModuleAvailable(moduleName) {
                continue
            }
            guard let module = modules[moduleName] else { continue }
            
            for type in module.nestedTypes.values {
                markGenericRecursive(node: type)
            }
            
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            for type in sortedTypes {
                let flattenedName = "\(moduleName)_\(type.name)"
                if definedTypes.contains(flattenedName) { continue }
                
                definedTypes.insert(flattenedName)
                let actualName = (moduleName == defaultModule) ? type.name : flattenedName
                output += type.generateCode(indent: "", nameOverride: actualName, parser: self) + "\n\n"
            }
        }
        
        // Phase 2: Generate type extensions
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC"].contains(moduleName) { continue }
            if moduleName != defaultModule && isModuleAvailable(moduleName) {
                continue
            }
            guard let module = modules[moduleName] else { continue }
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            for type in sortedTypes {
                let flattenedName = "\(moduleName)_\(type.name)"
                if !definedTypes.contains(flattenedName) { continue }
                
                let pathPrefix = (moduleName == defaultModule) ? "" : "\(moduleName)_"
                output += type.generateExtensions(defaultModule: defaultModule, parser: self, path: pathPrefix)
            }
        }

        // Phase 3: Generate namespace and convenient typealiases
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC"].contains(moduleName) { continue }
            if moduleName != defaultModule && isModuleAvailable(moduleName) {
                continue
            }
            if moduleName == defaultModule { continue }
            
            guard let module = modules[moduleName] else { continue }
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            if sortedTypes.isEmpty { continue }

            output += "public enum \(moduleName)_Namespace {\n"
            for type in sortedTypes {
                let flattenedName = "\(moduleName)_\(type.name)"
                if !definedTypes.contains(flattenedName) { continue }
                output += "    public typealias \(type.name) = \(flattenedName)\n"
            }
            output += "}\n\n"
            
            if !definedTypes.contains(moduleName) {
                output += "public typealias \(moduleName) = \(moduleName)_Namespace\n"
            }
        }
        
        // Phase 4: Generate generic typealiases mapping flattened names to imported module types, OR stubs if missing
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC"].contains(moduleName) { continue }
            if moduleName == defaultModule { continue }
            guard let module = modules[moduleName] else { continue }
            
            if isModuleAvailable(moduleName) {
                let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
                for type in sortedTypes {
                    let flattenedName = "\(moduleName)_\(type.name)"
                    if !definedTypes.contains(flattenedName) {
                        definedTypes.insert(flattenedName)
                        let gps = genericParamsString(for: type)
                        
                        // Check if type is publicly defined in the SDK or Local framework modules
                        if isTypeDefinedInFramework(module: moduleName, typeName: type.name) {
                            output += "public typealias \(flattenedName)\(gps) = \(moduleName).\(type.name)\(gps)\n"
                        } else {
                            // Leak/Missing type in dependency - generate local stub to compile
                            output += "public struct \(flattenedName)\(gps): Hashable, Codable, Sendable {}\n"
                        }
                    }
                }
            }
        }

        // Find all referenced but undefined types and generate stubs
        var stubs = ""
        let referenced = output.scanReferencedTypes()
        var referencedTypes = Set<String>()
        var protocolRefTypes = Set<String>()
        var genericRefTypes = Set<String>()
        
        for item in referenced {
            referencedTypes.insert(item.typeName)
            if item.isProtocol {
                protocolRefTypes.insert(item.typeName)
            }
            if item.isGeneric {
                genericRefTypes.insert(item.typeName)
            }
        }
        
        // Find all defined types in output
        let allDefinedInOutput = output.scanFrameworkDefinedTypes()
        
        let systemTypes: Set<String> = [
            "Bool", "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
            "Double", "Float", "Float16", "CGFloat", "Void", "Any", "Self", "Set", "Array", "Dictionary",
            "Optional", "URL", "Data", "Hasher", "Error", "Decoder", "Encoder", "UnsafeRawBufferPointer",
            "UnsafeMutableRawPointer", "UnsafePointer", "UnsafeMutablePointer", "URLResponse",
            "URLSession", "HTTPURLResponse", "String", "Character", "ClosedRange", "Range", "Selector",
            "NSObject", "Sendable", "Equatable", "Hashable", "Codable", "Decodable", "Encodable",
            "AnyObject", "Comparable", "Sequence", "IteratorProtocol", "CaseIterable", "RawRepresentable",
            "Result", "KeyValuePairs", "Locale", "TimeZone", "Calendar", "Notification", "NotificationCenter",
            "Bundle", "RunLoop", "ProcessInfo", "Process", "LanguageCode", "StaticString",
            "AnySequence", "FloatingPointRoundingRule"
        ]
        
        let sortedTypes = referencedTypes.sorted()
        for type in sortedTypes {
            if systemTypes.contains(type) { continue }
            if type.count == 1 { continue }
            if type.hasPrefix("JSON") { continue }
            
            // Check if defined
            let isDefined = allDefinedInOutput.contains(type)
            if !isDefined {
                // Check if used with "any" or ends with "_P"
                let isProtocolRef = protocolRefTypes.contains(type) || type.hasSuffix("_P")
                if isProtocolRef {
                    stubs += "public protocol \(type) {}\n"
                } else {
                    // Check if used as generic in the output
                    let isGenericRef = genericRefTypes.contains(type)
                    if isGenericRef {
                        stubs += "public struct \(type)<T>: Hashable, Codable, Sendable {}\n"
                    } else {
                        stubs += "public struct \(type): Hashable, Codable, Sendable {}\n"
                    }
                }
            }
        }
        output += "\n" + stubs

        return output
    }

    private func scanLocalSwiftFiles(currentModule: String) {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: fm.currentDirectoryPath) else { return }
        
        let genericUsagePattern = "\\b([A-Z][a-zA-Z0-9_$]*)\\s*<([^>]+)>"
        guard let regex = try? NSRegularExpression(pattern: genericUsagePattern, options: []) else { return }
        
        func countTopLevelCommas(in s: String) -> Int {
            var commas = 0
            var depth = 0
            var parenDepth = 0
            for char in s {
                if char == "<" { depth += 1 }
                else if char == ">" { depth -= 1 }
                else if char == "(" { parenDepth += 1 }
                else if char == ")" { parenDepth -= 1 }
                else if char == "," {
                    if depth == 0 && parenDepth == 0 {
                        commas += 1
                    }
                }
            }
            return commas + 1
        }
        
        for file in files {
            if file.hasSuffix(".swift") && !file.hasSuffix("Interface.swift") {
                guard let content = try? String(contentsOfFile: file, encoding: .utf8) else { continue }
                let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                let matches = regex.matches(in: content, options: [], range: nsRange)
                for match in matches {
                    guard let typeRange = Range(match.range(at: 1), in: content),
                          let paramsRange = Range(match.range(at: 2), in: content) else { continue }
                    let typeName = String(content[typeRange])
                    let params = String(content[paramsRange])
                    
                    if ["Optional", "Array", "Dictionary", "Set", "UnsafePointer", "UnsafeMutablePointer", "UnsafeRawPointer", "UnsafeMutableRawPointer"].contains(typeName) {
                        continue
                    }
                    
                    let count = countTopLevelCommas(in: params)
                    let fullPath = currentModule + "." + typeName
                    let currentMax = discoveredGenerics[fullPath] ?? 0
                    discoveredGenerics[fullPath] = max(currentMax, count)
                    let currentShortMax = discoveredGenerics[typeName] ?? 0
                    discoveredGenerics[typeName] = max(currentShortMax, count)
                }
            }
        }
    }

    func discoverNominalTypes(demangledMap: [(mangled: String, demangled: String)], currentModule: String) {
        for (mangled, demangled) in demangledMap {
            var path = ""
            var kind = "unknown"
            
            if demangled.hasPrefix("nominal type descriptor for ") {
                path = demangled.replacingOccurrences(of: "nominal type descriptor for ", with: "")
                if mangled.hasSuffix("OMn") { kind = "enum" }
                else if mangled.hasSuffix("VMn") { kind = "struct" }
                else if mangled.hasSuffix("CMn") { kind = "class" }
            } else if demangled.hasPrefix("protocol descriptor for ") {
                path = demangled.replacingOccurrences(of: "protocol descriptor for ", with: "")
                kind = "protocol"
            } else {
                continue
            }
            
            if let inIndex = path.range(of: " in ") {
                path = String(path[..<inIndex.lowerBound])
            }
            
            let parts = path.components(separatedBy: ".")
            guard parts.count >= 2 else { continue }
            
            let module = parts[0]
            if module != currentModule {
                discoveredNamespaces.insert(module)
            }
            
            let typePath = Array(parts[1...])
            
            let node = findOrCreateDiscoveredTypePath(module: module, path: typePath)
            setKind(kind, for: node)
        }
    }

    private func findOrCreateDiscoveredTypePath(module: String, path: [String]) -> TypeNode {
        if modules[module] == nil {
            modules[module] = TypeNode(name: module)
        }
        
        var current = modules[module]!
        for part in path {
            if current.nestedTypes[part] == nil {
                current.nestedTypes[part] = TypeNode(name: part)
            }
            current = current.nestedTypes[part]!
        }
        return current
    }
}
