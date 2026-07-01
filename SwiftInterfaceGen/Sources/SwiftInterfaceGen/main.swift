import Foundation

@main
struct SwiftInterfaceGen {
    static func main() {
        let args = CommandLine.arguments
        if args.contains("--compare") {
            runCompare(args: args)
            return
        }
        if args.count < 2 {
            print("Usage: swift-interface-gen <path_to_tbd> [--config <path_to_config.json>] or swift-interface-gen --compare <tbd_path> <dylib_path> [aliases_output_path]")
            return
        }

        let tbdPath = args[1]
        
        if let configIndex = args.firstIndex(of: "--config"), configIndex + 1 < args.count {
            ConfigManager.load(from: args[configIndex + 1])
        }

        guard let content = try? String(contentsOfFile: tbdPath, encoding: .utf8) else {
            print("Error: Could not read TBD file at \(tbdPath)")
            return
        }

        let currentModule = (tbdPath as NSString).lastPathComponent.replacingOccurrences(of: ".tbd", with: "")
        let symbols = extractSymbols(from: content)
        
        let parser = Parser()
        parser.defaultModule = currentModule
        parser.currentPrecomputeModule = currentModule
        
        let reexportedLibraries = extractReexportedLibraries(from: content)
        for lib in reexportedLibraries {
            let libPath = resolveLibraryPath(lib)
            if let libContent = try? String(contentsOfFile: libPath, encoding: .utf8) {
                print("Discovered dependency: \(lib) -> \(libPath)", to: &Self.standardError)
                let libModule = (lib as NSString).lastPathComponent.replacingOccurrences(of: ".framework", with: "")
                // ObjC classes from dependency frameworks appear as __C.ClassName in Swift.
                // Register them under "__C" so stub generation knows not to create local stubs for them.
                registerObjcClasses(from: libContent, parser: parser, module: "__C")
                let libSymbols = extractSymbols(from: libContent)
                processSymbols(libSymbols, parser: parser, module: libModule, depth: 1)
            }
        }
        
        registerObjcClasses(from: content, parser: parser, module: currentModule)
        processSymbols(symbols, parser: parser, module: currentModule, depth: 0)

        let startGen = Date()
        let allCode = parser.generateAll()
        print("generateAll took: \(Date().timeIntervalSince(startGen))s", to: &Self.standardError)
        
        let startPost = Date()
        let finalCode = postProcess(allCode, parser: parser)
        print("postProcess took: \(Date().timeIntervalSince(startPost))s", to: &Self.standardError)
        
        if let stubsIndex = args.firstIndex(of: "--generate-stubs"), stubsIndex + 1 < args.count {
            let outputDir = args[stubsIndex + 1]
            generateStubs(outputCode: finalCode, currentModule: currentModule, outputDir: outputDir, parser: parser)
            return
        }
        
        let alignedCode = finalCode
        
        let imports = resolveImports(from: allCode, currentModule: currentModule, parser: parser)
        let reexportedModules = Set(reexportedLibraries.map { ($0 as NSString).lastPathComponent })
        for imp in imports {
            if reexportedModules.contains(imp) {
                print("@_exported import \(imp)")
            } else {
                print("import \(imp)")
            }
        }
        
        // Filter out symbols that our mock library cannot provide:
        // Extensions on Swift stdlib types (e.g. RawSpan, Float, Double, Int, etc.)
        // defined in this module use mangled names starting with _$ss, _$sSf, etc.
        // We can't define extensions on ~Escapable stdlib types or system primitive types.
        let stdlibExtPrefixes = ["_$ss", "_$sSf", "_$sSd", "_$sSi", "_$sSu", "_$sSb",
                                 "_$sSS", "_$sSs",  // Float/Double/Int/UInt/Bool/String/Substring
                                 "_$sSo"]           // ObjC class extensions (So = Swift ObjC bridge)
        let filteredExports = parser.tbdSymbols.sorted().filter { sym in
            !stdlibExtPrefixes.contains(where: { sym.hasPrefix($0) })
        }

        let exportsContent = filteredExports.joined(separator: "\n") + "\n"
        try? exportsContent.write(toFile: "\(currentModule)_exports.txt", atomically: true, encoding: .utf8)
        
        print(alignedCode)
        
        // Generate ObjC bridge files for any ObjC-bridged types (So-prefix extension symbols).
        // These files allow the orchestrator to compile the ObjC runtime symbols and pass
        // -import-objc-header so Swift can generate the correct So-mangled extension symbols.
        if let moduleNode = parser.modules[currentModule] {
            let bridgedTypes = moduleNode.nestedTypes.values
                .filter { $0.isObjcBridged }
                .sorted { $0.name < $1.name }
            if !bridgedTypes.isEmpty {
                var headerLines = ["#import <Foundation/Foundation.h>"]
                var implLines = ["#import \"\(currentModule)Interface_bridge.h\""]
                for t in bridgedTypes {
                    let actualKind = t.kind == "unknown" ? "struct" : t.kind
                    if actualKind == "class" {
                        headerLines.append("@interface \(t.name) : NSObject")
                        headerLines.append("@end")
                        implLines.append("@implementation \(t.name)")
                        implLines.append("@end")
                    } else if actualKind == "enum" {
                        headerLines.append("typedef NS_ENUM(NSInteger, \(t.name)) {")
                        headerLines.append("    \(t.name)Unknown = 0")
                        headerLines.append("};")
                    }
                }
                let bridgeHeader = headerLines.joined(separator: "\n") + "\n"
                let bridgeImpl   = implLines.joined(separator: "\n")   + "\n"
                try? bridgeHeader.write(toFile: "\(currentModule)Interface_bridge.h", atomically: true, encoding: .utf8)
                try? bridgeImpl.write(toFile:   "\(currentModule)Interface_bridge.m", atomically: true, encoding: .utf8)
                print("Wrote ObjC bridge for \(bridgedTypes.map { $0.name })", to: &Self.standardError)
            }
        }
    }

    static func resolveImports(from code: String, currentModule: String, parser: Parser) -> [String] {
        var imports = Set<String>()
        imports.insert("Foundation")
        
        for mod in parser.referencedModules {
            if mod != currentModule && mod != "Swift" && mod != "__C" && mod != "CoreAI" {
                imports.insert(mod)
            }
        }
        
        if code.contains("MTL") { imports.insert("Metal") }
        if code.contains("IOSurface") { imports.insert("IOSurface") }
        if code.contains("CGImage") || code.contains("CGRect") || code.contains("CGSize") || code.contains("CGFloat") { imports.insert("CoreGraphics") }
        if code.contains("CVPixelBuffer") || code.contains("CVBuffer") { imports.insert("CoreVideo") }
        if code.contains("CMTime") { imports.insert("CoreMedia") }
        if code.contains("CIImage") { imports.insert("CoreImage") }
        if code.contains("MLModel") { imports.insert("CoreML") }
        if code.contains("DispatchQueue") { imports.insert("Dispatch") }
        if code.contains("OS_xpc_object") { imports.insert("XPC") }
        if code.contains("UAF") && currentModule != "UnifiedAssetFramework" { imports.insert("UnifiedAssetFramework") }
        
        for mod in parser.discoveredNamespaces {
            let pattern = "(?:^|[^.])\\b\(NSRegularExpression.escapedPattern(for: mod))\\."
            let hasMatch: Bool
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)
                hasMatch = regex.firstMatch(in: code, options: [], range: nsRange) != nil
            } else {
                hasMatch = code.contains("\(mod).")
            }
            
            if hasMatch && mod != currentModule {
                if mod == "__C" { continue }
                let path1 = "\(ConfigManager.sdkRoot)/System/Library/PrivateFrameworks/\(mod).framework"
                let path2 = "\(ConfigManager.sdkRoot)/System/Library/SubFrameworks/\(mod).framework"
                if FileManager.default.fileExists(atPath: path1) || FileManager.default.fileExists(atPath: path2) {
                    imports.insert(mod)
                }
            }
        }
        
        // Also detect pseudo-module references like `IntelligencePlatformLibrary_AppleInternal.Something`
        // that appear as type prefixes in the code but are not real .framework bundles.
        // These are private submodules compiled as stub frameworks by orchestrate.py.
        let pseudoModulePattern = "\\b([A-Z][A-Za-z0-9_]+_[A-Za-z][A-Za-z0-9_]*)\\."
        if let regex = try? NSRegularExpression(pattern: pseudoModulePattern, options: []) {
            let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)
            let matches = regex.matches(in: code, options: [], range: nsRange)
            for m in matches {
                if let gr = Range(m.range(at: 1), in: code) {
                    let modName = String(code[gr])
                    if modName == currentModule { continue }
                    // Check if the base (before first _) is a real private framework
                    if let underIdx = modName.firstIndex(of: "_") {
                        let baseMod = String(modName[modName.startIndex..<underIdx])
                        let path1 = "\(ConfigManager.sdkRoot)/System/Library/PrivateFrameworks/\(baseMod).framework"
                        let path2 = "\(ConfigManager.sdkRoot)/System/Library/SubFrameworks/\(baseMod).framework"
                        if FileManager.default.fileExists(atPath: path1) || FileManager.default.fileExists(atPath: path2) {
                            imports.insert(modName)
                        }
                    }
                }
            }
        }

        return Array(imports).sorted()
    }

    static func processSymbols(_ symbols: [String], parser: Parser, module: String, depth: Int = 0) {
        for symbol in symbols {
            if symbol.contains("UAF") { fputs("Processing symbol: \(symbol)\n", stderr) }
        }
        parser.tbdSymbols.formUnion(symbols)
        if parser.processedModules.contains(module) { return }
        parser.processedModules.insert(module)
        
        parser.currentPrecomputeModule = module
        
        // Ensure module node exists early to prevent re-entry during precompute/parse if needed
        if parser.modules[module] == nil {
            parser.modules[module] = TypeNode(name: module)
        }
        
        let count = symbols.count
        print("Found \(count) new symbols in \(module). Demangling and precomputing...", to: &Self.standardError)
        
        let start = Date()
        var demangledMap: [(mangled: String, demangled: String)] = []
        for mangled in symbols {
            if let demangled = demangle(symbol: mangled) {
                demangledMap.append((mangled: mangled, demangled: demangled))
            }
        }
        print("Demangling took: \(Date().timeIntervalSince(start))s", to: &Self.standardError)

        let symbolsWithClosures = demangledMap.filter { $0.demangled.contains("->") }.map { $0.mangled }
        if !symbolsWithClosures.isEmpty {
            let startExpand = Date()
            let escapingResults = runDemangleExpand(symbols: symbolsWithClosures, parser: parser)
            parser.symbolEscapingMap.merge(escapingResults) { (_, new) in new }
            print("Demangle --expand for \(symbolsWithClosures.count) symbols took: \(Date().timeIntervalSince(startExpand))s", to: &Self.standardError)
        }
        
        // Swift ABI Nominal Type Discovery Pass
        parser.discoverNominalTypes(demangledMap: demangledMap, currentModule: module)

        let startPre = Date()
        for entry in demangledMap {
            parser.precompute(demangled: entry.demangled)
        }
        print("Precompute took: \(Date().timeIntervalSince(startPre))s", to: &Self.standardError)
        
        // Pre-pass: collect default argument positions before parsing functions
        for entry in demangledMap {
            guard entry.demangled.hasPrefix("default argument ") else { continue }
            let mangled = entry.mangled
            let argIndex: Int
            if mangled.hasSuffix("fA_") { argIndex = 0 }
            else if mangled.hasSuffix("fA0_") { argIndex = 1 }
            else if mangled.hasSuffix("fA1_") { argIndex = 2 }
            else if mangled.hasSuffix("fA2_") { argIndex = 3 }
            else if mangled.hasSuffix("fA3_") { argIndex = 4 }
            else if mangled.hasSuffix("fA4_") { argIndex = 5 }
            else { continue }
            // Derive base mangled by stripping fAN_ suffix
            var baseMangled = mangled
            if let range = baseMangled.range(of: "fA", options: .backwards) {
                baseMangled = String(baseMangled[..<range.lowerBound])
            }
            parser.defaultArgMap[baseMangled, default: []].insert(argIndex)
        }

        let startParse = Date()
        for entry in demangledMap {
            parser.parse(mangled: entry.mangled, demangled: entry.demangled, currentModule: module)
        }
        print("Parse took: \(Date().timeIntervalSince(startParse))s", to: &Self.standardError)
    }

    static func extractSymbols(from tbd: String) -> [String] {
        var symbols = Set<String>()
        let chars = Array(tbd)
        var i = 0
        let n = chars.count
        while i < n {
            let isSymbolChar = chars[i].isLetter || chars[i].isNumber || chars[i] == "_" || chars[i] == "$"
            if isSymbolChar {
                let start = i
                while i < n && (chars[i].isLetter || chars[i].isNumber || chars[i] == "_" || chars[i] == "$") {
                    i += 1
                }
                let token = String(chars[start..<i])
                if token.hasPrefix("_$s") || token.hasPrefix("_OBJC_CLASS_$_") {
                    symbols.insert(token)
                }
            } else {
                i += 1
            }
        }
        return Array(symbols).sorted()
    }

    static func extractObjcClasses(from tbd: String) -> [String] {
        var classes = Set<String>()
        var scanIdx = tbd.startIndex
        while let range = tbd.range(of: "objc-classes:", range: scanIdx..<tbd.endIndex) {
            scanIdx = range.upperBound
            
            // Determine if flow sequence (has '[' before next keyword or newline)
            var tempIdx = scanIdx
            var hasBrackets = false
            while tempIdx < tbd.endIndex {
                let c = tbd[tempIdx]
                if c == "[" {
                    hasBrackets = true
                    break
                }
                if c == "\n" {
                    // Check next non-whitespace character after newline
                    var nextIdx = tbd.index(after: tempIdx)
                    while nextIdx < tbd.endIndex && (tbd[nextIdx] == " " || tbd[nextIdx] == "\t") {
                        nextIdx = tbd.index(after: nextIdx)
                    }
                    if nextIdx < tbd.endIndex && tbd[nextIdx] == "-" {
                        // This is a block sequence, definitely no brackets
                        break
                    }
                }
                if c == ":" && tempIdx != scanIdx {
                    // Hitting another colon before '['
                    break
                }
                tempIdx = tbd.index(after: tempIdx)
            }
            
            if hasBrackets {
                // Flow sequence with [ ... ]
                scanIdx = tbd.index(after: tempIdx)
                let startOfClasses = scanIdx
                while scanIdx < tbd.endIndex && tbd[scanIdx] != "]" {
                    scanIdx = tbd.index(after: scanIdx)
                }
                if scanIdx >= tbd.endIndex { break }
                let endOfClasses = scanIdx
                let classListStr = String(tbd[startOfClasses..<endOfClasses])
                let parts = classListStr.components(separatedBy: CharacterSet(charactersIn: ",\n\r\t "))
                for part in parts {
                    let name = part.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !name.isEmpty {
                        classes.insert(name)
                    }
                }
                scanIdx = tbd.index(after: scanIdx)
            } else {
                // Block sequence: read line by line until next non-indented line or line without '-'
                var currentLineStart = scanIdx
                while currentLineStart < tbd.endIndex {
                    var lineEnd = currentLineStart
                    while lineEnd < tbd.endIndex && tbd[lineEnd] != "\n" && tbd[lineEnd] != "\r" {
                        lineEnd = tbd.index(after: lineEnd)
                    }
                    let line = String(tbd[currentLineStart..<lineEnd]).trimmingCharacters(in: .whitespaces)
                    if line.isEmpty {
                        // skip
                    } else if line.hasPrefix("-") {
                        let name = line.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty {
                            classes.insert(name)
                        }
                    } else if line.contains(":") {
                        break
                    } else {
                        let parts = line.components(separatedBy: CharacterSet(charactersIn: ",\t "))
                        var foundAny = false
                        for part in parts {
                            let name = part.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !name.isEmpty && (name.starts(with: "UAF") || name.starts(with: "OBJC") || name.rangeOfCharacter(from: CharacterSet.letters) != nil) {
                                classes.insert(name)
                                foundAny = true
                            }
                        }
                        if !foundAny {
                            break
                        }
                    }
                    if lineEnd >= tbd.endIndex { break }
                    currentLineStart = tbd.index(after: lineEnd)
                }
                scanIdx = currentLineStart
            }
        }
        return Array(classes).sorted()
    }

    static func registerObjcClasses(from content: String, parser: Parser, module: String) {
        let objcClasses = extractObjcClasses(from: content)
        
        for objcClass in objcClasses {
            if objcClass.hasPrefix("_Tt") {
                continue
            }
            let node = parser.findOrCreateDiscoveredTypePath(module: module, path: [objcClass])
            if node.kind == "unknown" {
                parser.setKind("class", for: node)
                node.baseClass = "NSObject"
            }
            node.isObjcBridged = true
        }
        
        // Special case: UAFSubscriptionDownloadStatus is an ObjC enum in UnifiedAssetFramework.
        // When UAF is the primary module, register it in the UAF module itself.
        // When processing UAF as a dependency (module == "__C"), register it in __C so ModelCatalog
        // won't generate a stub struct for it.
        let uafEnumTargetModule = (module == "__C") ? "__C" : module
        if module == "UnifiedAssetFramework" || module == "__C" {
            let enumNode = parser.findOrCreateDiscoveredTypePath(module: uafEnumTargetModule, path: ["UAFSubscriptionDownloadStatus"])
            if enumNode.kind == "unknown" {
                parser.setKind("enum", for: enumNode)
                enumNode.rawType = "Int"
                enumNode.conformances.insert("Codable")
                enumNode.conformances.insert("Hashable")
                enumNode.conformances.insert("Sendable")
                enumNode.conformances.insert("RawRepresentable")
                enumNode.members["unknown"] = .enumCase(name: "unknown", payload: nil, hasLabel: false)
            }
            enumNode.isObjcBridged = true
        }
    }


    static func extractReexportedLibraries(from tbd: String) -> [String] {
        guard let range = tbd.range(of: "reexported-libraries:") else { return [] }
        var scanIdx = range.upperBound
        // Find the opening bracket '['
        while scanIdx < tbd.endIndex && tbd[scanIdx] != "[" {
            scanIdx = tbd.index(after: scanIdx)
        }
        guard scanIdx < tbd.endIndex else { return [] }
        let openBracketIdx = scanIdx
        scanIdx = tbd.index(after: scanIdx)
        // Find the closing bracket ']'
        while scanIdx < tbd.endIndex && tbd[scanIdx] != "]" {
            scanIdx = tbd.index(after: scanIdx)
        }
        guard scanIdx < tbd.endIndex else { return [] }
        let closeBracketIdx = scanIdx
        
        let list = String(tbd[tbd.index(after: openBracketIdx)..<closeBracketIdx])
        return list.components(separatedBy: ",").map {
            $0.trimmingCharacters(in: .whitespaces)
              .replacingOccurrences(of: "\"", with: "")
              .replacingOccurrences(of: "'", with: "")
        }
    }

    static func resolveLibraryPath(_ lib: String) -> String {
        let sdkRoot = ConfigManager.sdkRoot
        if lib.starts(with: "/System/Library/PrivateFrameworks") {
            let parts = lib.components(separatedBy: "/")
            if let frameworkName = parts.first(where: { $0.hasSuffix(".framework") }) {
                let name = frameworkName.replacingOccurrences(of: ".framework", with: "")
                return "\(sdkRoot)/System/Library/PrivateFrameworks/\(name).framework/\(name).tbd"
            }
        }
        return "\(sdkRoot)\(lib).tbd"
    }



    static func runDemangleExpand(symbols: [String], parser: Parser) -> [String: [Int: Bool]] {
        var allResults: [String: [Int: Bool]] = [:]
        for symbol in symbols {
            symbol.withCString { cStr in
                if let astCStr = swift_demangle_ast(cStr) {
                    let ast = String(cString: astCStr)
                    let lines = ast.components(separatedBy: .newlines)
                    allResults[symbol] = parseParameters(from: lines)
                    if let root = buildTree(from: lines) {
                        traverseAndRegisterTypes(node: root, parser: parser)
                    }
                }
            }
        }
        return allResults
    }

    static func buildTree(from lines: [String]) -> TreeNodeObj? {
        var stack: [(node: TreeNodeObj, indent: Int)] = []
        var root: TreeNodeObj? = nil
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("kind=") else { continue }
            
            var spaces = 0
            for char in line {
                if char == " " { spaces += 1 } else { break }
            }
            
            let parts = trimmed.components(separatedBy: ", ")
            let kindPart = parts[0]
            let kind = kindPart.replacingOccurrences(of: "kind=", with: "")
            
            var text: String? = nil
            if parts.count > 1 {
                let textPart = parts[1]
                if textPart.hasPrefix("text=\"") && textPart.hasSuffix("\"") {
                    text = String(textPart.dropFirst(6).dropLast())
                }
            }
            
            let newNode = TreeNodeObj(kind: kind, text: text)
            if root == nil {
                root = newNode
            }
            
            while let last = stack.last, last.indent >= spaces {
                stack.removeLast()
            }
            
            if let parent = stack.last?.node {
                parent.children.append(newNode)
            }
            
            stack.append((newNode, spaces))
        }
        return root
    }

    static func traverseAndRegisterTypes(node: TreeNodeObj, parser: Parser) {
        _ = resolveType(node, parser: parser)
        for child in node.children {
            traverseAndRegisterTypes(node: child, parser: parser)
        }
    }

    static func resolveType(_ node: TreeNodeObj, parser: Parser) -> (module: String, path: [String], kind: String)? {
        if node.kind == "Module" {
            return (node.text ?? "", [], "")
        }
        
        if node.kind == "Type" {
            if let first = node.children.first {
                return resolveType(first, parser: parser)
            }
            return nil
        }
        if node.kind == "BoundGenericEnum" || node.kind == "BoundGenericStructure" || node.kind == "BoundGenericClass" {
            if let typeChild = node.children.first(where: { $0.kind == "Type" }) {
                return resolveType(typeChild, parser: parser)
            }
            return nil
        }
        
        let expectedKind: String
        switch node.kind {
        case "Enum": expectedKind = "enum"
        case "Structure": expectedKind = "struct"
        case "Class": expectedKind = "class"
        case "Protocol": expectedKind = "protocol"
        default: return nil
        }
        
        let containerKinds = ["Module", "Enum", "Structure", "Class", "Type", "BoundGenericEnum", "BoundGenericStructure", "BoundGenericClass"]
        guard let containerNode = node.children.first(where: { containerKinds.contains($0.kind) }),
              let identifierNode = node.children.first(where: { $0.kind == "Identifier" }),
              let typeName = identifierNode.text else {
            return nil
        }
        
        if let (module, parentPath, _) = resolveType(containerNode, parser: parser) {
            let fullPath = parentPath + [typeName]
            if !module.isEmpty {
                let pNode = parser.findOrCreateDiscoveredTypePath(module: module, path: fullPath)
                if pNode.kind == "unknown" {
                    parser.setKind(expectedKind, for: pNode)
                }
            }
            return (module, fullPath, expectedKind)
        }
        return nil
    }



    static func parseParameters(from lines: [String]) -> [Int: Bool] {
        var nodes: [TreeNode] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("kind=") else { continue }
            
            var spaces = 0
            for char in line {
                if char == " " { spaces += 1 } else { break }
            }
            
            let parts = trimmed.components(separatedBy: ", ")
            let kindPart = parts[0]
            let kind = kindPart.replacingOccurrences(of: "kind=", with: "")
            
            var text: String? = nil
            if parts.count > 1 {
                let textPart = parts[1]
                if textPart.hasPrefix("text=\"") && textPart.hasSuffix("\"") {
                    text = String(textPart.dropFirst(6).dropLast())
                }
            }
            nodes.append(TreeNode(kind: kind, text: text, indent: spaces))
        }
        
        func getChildren(ofParentIndex idx: Int) -> [Int] {
            guard idx < nodes.count else { return [] }
            let parentIndent = nodes[idx].indent
            var childrenIndices = [Int]()
            var i = idx + 1
            while i < nodes.count {
                let childIndent = nodes[i].indent
                if childIndent <= parentIndent {
                    break
                }
                if childIndent == parentIndent + 2 {
                    childrenIndices.append(i)
                }
                i += 1
            }
            return childrenIndices
        }
        
        var mainFuncIdx: Int? = nil
        for (idx, node) in nodes.enumerated() {
            if node.kind == "FunctionType" || node.kind == "NoEscapeFunctionType" {
                mainFuncIdx = idx
                break
            }
        }
        
        guard let funcIdx = mainFuncIdx else { return [:] }
        
        let funcChildren = getChildren(ofParentIndex: funcIdx)
        guard let argTupleIdx = funcChildren.first(where: { nodes[$0].kind == "ArgumentTuple" }) else { return [:] }
        
        let argChildren = getChildren(ofParentIndex: argTupleIdx)
        guard let typeIdx = argChildren.first(where: { nodes[$0].kind == "Type" }) else { return [:] }
        
        let typeChildren = getChildren(ofParentIndex: typeIdx)
        guard let firstChildIdx = typeChildren.first else { return [:] }
        
        var parameterNodeIndices = [Int]()
        if nodes[firstChildIdx].kind == "Tuple" {
            let tupleChildren = getChildren(ofParentIndex: firstChildIdx)
            parameterNodeIndices = tupleChildren.filter { nodes[$0].kind == "TupleElement" }
        } else {
            parameterNodeIndices = [typeIdx]
        }
        
        var parameterEscaping: [Int: Bool] = [:]
        for (paramIndex, paramNodeIdx) in parameterNodeIndices.enumerated() {
            let paramIndent = nodes[paramNodeIdx].indent
            var descIdx = paramNodeIdx + 1
            var hasFunctionType = false
            var isNoEscape = false
            
            while descIdx < nodes.count {
                let desc = nodes[descIdx]
                if desc.indent <= paramIndent {
                    break
                }
                if desc.kind == "NoEscapeFunctionType" {
                    hasFunctionType = true
                    isNoEscape = true
                } else if desc.kind == "FunctionType" {
                    hasFunctionType = true
                }
                descIdx += 1
            }
            
            if hasFunctionType {
                parameterEscaping[paramIndex] = !isNoEscape
            }
        }
        
        return parameterEscaping
    }

    static func demangle(symbol mangledName: String) -> String? {
        if mangledName.starts(with: "_OBJC_CLASS_$_") {
            return mangledName.replacingOccurrences(of: "_OBJC_CLASS_$_", with: "class ")
        }
        return mangledName.withCString { mangledNamePtr in
            if let demangledNamePtr = swift_demangle_flat(mangledNamePtr) {
                return String(cString: demangledNamePtr)
            }
            return nil
        }
    }

    static func postProcess(_ code: String, parser: Parser) -> String {
        var c = code
        c = c.replacingOccurrences(of: "OS_dispatch_queue", with: "DispatchQueue")
        // Remove redundant current module prefix to avoid self-referencing, and ObjectiveC.
        c = c.replacingOccurrences(of: "\(parser.defaultModule).", with: "")
        c = c.replacingOccurrences(of: "ObjectiveC.", with: "")
        
        // Handle Foundation and Swift more carefully to avoid "typealias NSCoder = NSCoder"
        c = c.replacingOccurrences(of: ": Foundation.", with: ": ___FOUNDATION___")
        c = c.replacingOccurrences(of: "-> Foundation.", with: "-> ___FOUNDATION___")
        c = c.replacingOccurrences(of: "Array<Foundation.", with: "Array<___FOUNDATION___")
        c = c.replacingOccurrences(of: "Optional<Foundation.", with: "Optional<___FOUNDATION___")
        c = c.replacingOccurrences(of: "= Foundation.", with: "= ___FOUNDATION___")

        c = c.replaceWordDot("Foundation", with: "")
        c = c.replacingOccurrences(of: "___FOUNDATION___", with: "Foundation.")
        
        // Strip Swift. from types unless there is a collision
        var standardShadowedTypes = ["Float", "Double", "Int", "String", "Bool"].filter { parser.discoveredConcreteTypes.contains($0) }
        standardShadowedTypes.append(contentsOf: ["Decoder", "Encoder"])
        for type in standardShadowedTypes {
            c = c.replacingOccurrences(of: "Swift.\(type)", with: "___SWIFT_SHIELDED_\(type)___")
        }
        
        c = c.replaceWordDot("Swift", with: "")
        
        for type in standardShadowedTypes {
            c = c.replacingOccurrences(of: "___SWIFT_SHIELDED_\(type)___", with: "Swift.\(type)")
        }
        
        // Handle AnySequence
        c = c.replaceWordWithoutGeneric("AnySequence", with: "AnySequence<Any>")
        
        
        // Fix prefix/postfix operators
        c = c.fixPrefixAndPostfixOperators()
        
        // Clean up invalid generic method declarations or erasures (only if followed by '(')
        c = c.stripAnyGenericApplicationBeforeParen()
        
        // Strip invalid 'any' prefixes from concrete types
        let protocolShortNames = Set(parser.discoveredProtocols.map { $0.components(separatedBy: ".").last ?? $0 })
        c = c.stripInvalidAnyPrefixes(concreteTypes: parser.discoveredConcreteTypes, protocolNames: protocolShortNames)
        
        // Fix Optional fallbacks
        c = c.replacingOccurrences(of: "(Optional,", with: "(Optional<Any>,")
        c = c.replacingOccurrences(of: "(Optional, ", with: "(Optional<Any>, ")
        c = c.replacingOccurrences(of: "(Optional ,", with: "(Optional<Any>,")
        c = c.replacingOccurrences(of: "Optional,", with: "Optional<Any>,")
        c = c.replacingOccurrences(of: "Optional)", with: "Optional<Any>)")
        
        // Add generic placeholders for dynamically discovered generic types (types only!)
        var flatGenerics = [String: Int]()
        var shortGenerics = [String: Int]()
        for (t, count) in parser.discoveredGenerics {
            let shortName = t.components(separatedBy: ".").last!
            if parser.discoveredProtocols.contains(t) || 
               parser.discoveredProtocols.contains(where: { $0.hasSuffix("." + t) }) ||
               parser.discoveredProtocols.contains(shortName) ||
               parser.discoveredProtocols.contains(where: { $0.hasSuffix("." + shortName) }) ||
               shortName.hasSuffix("_P") {
                continue
            }
            guard let firstChar = shortName.first, firstChar.isUppercase else { continue } // Only types!
            
            let isNonGenericConcrete = parser.isConcreteTypeNonGeneric(shortName: shortName)
            if !isNonGenericConcrete {
                let flatName = t.replacingOccurrences(of: ".", with: "_")
                flatGenerics[flatName] = max(flatGenerics[flatName] ?? 0, count)
            }
            
            let components = t.components(separatedBy: ".")
            if components.count <= 2 {
                if !isNonGenericConcrete {
                    shortGenerics[shortName] = max(shortGenerics[shortName] ?? 0, count)
                }
            }
        }
        
        c = c.applyDiscoveredGenerics(flatGenerics: flatGenerics, shortGenerics: shortGenerics)
        
        // Clean up invalid generic typealiases
        c = c.stripGenericFromTypealias()
        
        // Clean up protocols that were mistakenly made generic
        c = c.stripGenericFromProtocol()
        
        // Clean up invalid nested generic applications
        c = c.stripGenericFromView()
        

        
        if !parser.defaultModule.isEmpty {
            c = c.replacingOccurrences(of: "___SHIELDED_\(parser.defaultModule)___", with: parser.defaultModule)
        }

        // De-genericise types whose real binary exports use non-generic ABI mangling.
        // For Tensor/TensorRequirements: strip ALL <Any>/<A>/<T> since these types are
        // fully non-generic in the real binary ABI.
        // For UnsafeArrayPointer family: strip declaration <A> and own-type <A>/<Any>/<T>
        // references, but also strip <GenericA>/<GenericB> which are method-level params
        // that appear in closures passed to `withUnsafeArrayPointer(of:_:)`.
        // De-genericise Tensor/TensorRequirements — fully non-generic in real ABI.
        for (typeName, placeholders) in [
            ("Tensor",           ["A", "Any", "T"]),
            ("TensorRequirements", ["A", "Any", "T"]),
        ] as [(String, [String])] {
            for p in ["A", "T"] {
                c = c.replacingOccurrences(of: "struct \(typeName)<\(p)>", with: "struct \(typeName)")
                c = c.replacingOccurrences(of: "class \(typeName)<\(p)>",  with: "class \(typeName)")
            }
            for placeholder in placeholders {
                c = c.replacingOccurrences(of: "\(typeName)<\(placeholder)>", with: typeName)
            }
        }

        // Note: UnsafeArrayPointer/UnsafeMutableArrayPointer family are kept generic —
        // their ABI exports use <A> throughout (properties, subscripts, inits).
        // The pMV property descriptor stubs are handled by the assembly stub mechanism.

        // Fix constrained existential simplification artifacts: `any Mod.Source<Self.Stream>`
        // originates from `any Source<Self.Stream == A>` (a constrained existential where the
        // protocol's associated type `Stream` equals the generic param `A`).  Outside a protocol
        // body, `Self.Stream` is not meaningful – replace with `Any` so the class compiles.
        if let regex = try? NSRegularExpression(
            pattern: #"(any\s+\S+Source)<Self\.Stream\s*>"#, options: []) {
            let matches = regex.matches(in: c, range: NSRange(c.startIndex..., in: c))
            for m in matches.reversed() {
                if let r = Range(m.range, in: c),
                   let gr = Range(m.range(at: 1), in: c) {
                    let prefix = String(c[gr])
                    c.replaceSubrange(r, with: "\(prefix)<Any>")
                }
            }
        }

        if parser.defaultModule == "AppleIntelligenceReporting" {
            c = c.replacingOccurrences(
                of: "class lazySource<A> {",
                with: "class lazySource<A> where A: IntelligencePlatformLibrary.Stream {"
            )
            c = c.replacingOccurrences(
                of: "class lazySourceInternal<A> {",
                with: "class lazySourceInternal<A> where A: IntelligencePlatformLibrary_AppleInternal.Stream {"
            )
            c += """

extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.AssetDeliveryLog.Availability: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.Invocation.Step: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.MobileAsset.LifeCycle.InstrumentationEvent: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.Buddy: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.AssetDeliveryLog.MobileAsset: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.AssetDeliveryLog.MobileAssetVerbose: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.AssetDeliveryLog.ModelCatalog: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.AssetDeliveryLog.SoftwareUpdateController: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary.Library.Streams.AppleIntelligence.Reporting.AssetDeliveryLog.UnifiedAssetFramework: IntelligencePlatformLibrary.Stream {
    public typealias EventType = Any
}
extension IntelligencePlatformLibrary_AppleInternal.InternalLibrary.Streams.AppleIntelligence.Reporting.ModelIO: IntelligencePlatformLibrary_AppleInternal.Stream {
    public typealias EventType = Any
}

"""
        }

        // Final cleanup of redundant newlines
        let lines = c.components(separatedBy: "\n")
        var newLines = [String]()
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            newLines.append(line)
        }
        c = newLines.joined(separator: "\n")
        // Emit sentinel structs for any protocol existential defaults (_Default_ProtocolName)
        // so that "= _Default_Foo()" compiles and produces a stable fA_ symbol.
        let defaultSentinelPattern = "_Default_([A-Za-z_][A-Za-z0-9_]*)\\(\\)"
        var sentinelProtocols = [String]()
        var searchRange = c.startIndex..<c.endIndex
        while let matchRange = c.range(of: defaultSentinelPattern, options: .regularExpression, range: searchRange) {
            let matched = String(c[matchRange])
            // Extract protocol name between _Default_ and ()
            if let start = matched.range(of: "_Default_")?.upperBound,
               let end = matched.range(of: "()")?.lowerBound {
                let proto = String(matched[start..<end])
                if !sentinelProtocols.contains(proto) {
                    sentinelProtocols.append(proto)
                }
            }
            searchRange = matchRange.upperBound..<c.endIndex
        }
        // Build the sentinel struct source — placed after the generic helpers so Phase A still
        // sees GenericA/etc., but stripped at the sentinel marker for module emit.
        var sentinelSource = ""
        for proto in sentinelProtocols {
            // Remove any previously generated bare stub for this name (e.g. from unknown-type scan)
            let barePattern = "public struct _Default_\(proto):[^\n]*\n?"
            c = c.replacingOccurrences(of: barePattern, with: "", options: .regularExpression)
            // Scan the generated code for this protocol's requirements and synthesise stubs.
            var members = [String]()
            if let protoRange = c.range(of: "public protocol \(proto)") {
                // Find the opening brace
                if let braceStart = c[protoRange.upperBound...].firstIndex(of: "{") {
                    var depth = 1
                    var idx = c.index(after: braceStart)
                    var bodyLines = [String]()
                    while idx < c.endIndex && depth > 0 {
                        if c[idx] == "{" { depth += 1 }
                        else if c[idx] == "}" { depth -= 1; if depth == 0 { break } }
                        else if c[idx] == "\n" {
                            let lineStart = c.index(after: idx)
                            if let lineEnd = c[lineStart...].firstIndex(of: "\n") {
                                bodyLines.append(String(c[lineStart..<lineEnd]))
                            }
                        }
                        idx = c.index(after: idx)
                    }
                    for line in bodyLines {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        if trimmed.hasPrefix("var ") {
                            // e.g. "var foo: Type { get }" → emit computed property stub
                            if let colonIdx = trimmed.firstIndex(of: ":") {
                                let varName = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: 4)..<colonIdx]).trimmingCharacters(in: .whitespaces)
                                var typePart = String(trimmed[trimmed.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
                                if let braceIdx = typePart.firstIndex(of: "{") {
                                    typePart = String(typePart[..<braceIdx]).trimmingCharacters(in: .whitespaces)
                                }
                                members.append("    public var \(varName): \(typePart) { get { fatalError() } }")
                            }
                        } else if trimmed.hasPrefix("func ") {
                            // e.g. "func now() -> Date" → emit method stub
                            let sig = trimmed.hasPrefix("func ") ? String(trimmed.dropFirst(5)) : trimmed
                            members.append("    public func \(sig) { fatalError() }")
                        }
                    }
                }
            }
            let body = members.isEmpty ? "" : "\n" + members.joined(separator: "\n") + "\n"
            sentinelSource += "\npublic struct _Default_\(proto): \(proto) { public init() {}\(body)}\n"
        }

        c += "\n\npublic func dummyDefaultValue<T>() -> T { fatalError() }\n"
        c += "\n"
        c += "public struct GenericA: Hashable, Codable, Sendable {}\n"
        c += "public struct GenericB: Hashable, Codable, Sendable {}\n"
        c += "public struct GenericC: Hashable, Codable, Sendable {}\n"
        c += "public struct GenericD: Hashable, Codable, Sendable {}\n"
        c += "public struct A1: Hashable, Codable, Sendable {}\n"
        c += "public struct B1: Hashable, Codable, Sendable {}\n"
        c += "public struct C1: Hashable, Codable, Sendable {}\n"
        c += "public struct D1: Hashable, Codable, Sendable {}\n"
        if parser.defaultModule == "ModelCatalog" {
            c += "\n\nextension GenericA: AssetMetadata, AssetContents {\n"
            c += "    public init(baseURL: URL) { fatalError() }\n"
            c += "    public var baseURL: URL { get { fatalError() } }\n"
            c += "    public var metadataURL: URL { get { fatalError() } }\n"
            c += "}\n"
        }
        // Sentinel structs go AFTER all generic helpers so Phase A (stripped at the marker)
        // still sees GenericA/B/etc. but not the protocol-conforming sentinels.
        if !sentinelSource.isEmpty {
            c += "\n// --- Protocol Default Sentinels (dylib-only, stripped for module emit) ---\n"
            c += sentinelSource
        }
        return c
    }

    static func runCompare(args: [String]) {
        guard let compareIdx = args.firstIndex(of: "--compare"),
              compareIdx + 3 < args.count else {
            print("Usage: swift-interface-gen --compare <exports_file_path> <dylib_path> <stubs_s_output_path>")
            exit(1)
        }
        
        let tbdPath = args[compareIdx + 1]
        let dylibPath = args[compareIdx + 2]
        let stubsSPath = args[compareIdx + 3]
        
        guard let tbdContent = try? String(contentsOfFile: tbdPath, encoding: .utf8) else {
            print("Error: Could not read expected symbols file at \(tbdPath)")
            exit(1)
        }
        
        let tbdSyms = extractSymbols(from: tbdContent)
        let dylibSyms = extractDylibSymbols(dylibPath: dylibPath)
        
        print("Total symbols in expected file: \(tbdSyms.count)")
        print("Total symbols in Dylib: \(dylibSyms.count)")
        
        func normalize(_ sym: String) -> String {
            if sym.hasPrefix("_") {
                return String(sym.dropFirst())
            }
            return sym
        }
        
        var normalizedTbd = [String: String]()
        for s in tbdSyms {
            normalizedTbd[normalize(s)] = s
        }
        
        var normalizedDylib = [String: String]()
        for s in dylibSyms {
            normalizedDylib[normalize(s)] = s
        }
        
        var missing = [String]()
        for (norm, orig) in normalizedTbd {
            if normalizedDylib[norm] == nil {
                missing.append(orig)
            }
        }
        missing.sort()
        
        var extra = [String]()
        for (norm, orig) in normalizedDylib {
            if normalizedTbd[norm] == nil {
                extra.append(orig)
            }
        }
        extra.sort()
        
        print("\n--- Missing Symbols (in TBD/Expected but not in Dylib) ---")
        print("Count: \(missing.count)")
        for s in missing.prefix(50) {
            print("  \(s)")
        }
        if missing.count > 50 {
            print("  ... and \(missing.count - 50) more")
        }
        
        print("\n--- Extra Symbols (in Dylib but not in TBD/Expected) ---")
        print("Count: \(extra.count)")
        for s in extra.prefix(50) {
            print("  \(s)")
        }
        if extra.count > 50 {
            print("  ... and \(extra.count - 50) more")
        }
        
        // Generate stubs.s
        var stubsContent = ".data\n.align 3\n"
        var stubCount = 0
        for sym in missing {
            stubsContent += ".globl \(sym)\n\(sym):\n    .quad 0\n"
            stubCount += 1
        }
        do {
            try stubsContent.write(toFile: stubsSPath, atomically: true, encoding: .utf8)
            print("Generated \(missing.count) stubs in \(stubsSPath).")
        } catch {
            print("Error writing stubs.s file: \(error)")
        }
    }
    
static func extractDylibSymbols(dylibPath: String) -> Set<String> {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/nm")
        // Use -U (no -g) so local symbols (e.g. Swift fA_ default-argument thunks emitted
        // as local 't' under -enable-library-evolution) are included in the comparison.
        // Only .quad 0 stubs are generated for symbols truly absent from the dylib.
        process.arguments = ["-U", dylibPath]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            if let output = String(data: data, encoding: .utf8) {
                var symbols = Set<String>()
                output.enumerateLines { line, _ in
                    let parts = line.split { $0.isWhitespace }
                    if parts.count >= 3 {
                        symbols.insert(String(parts[2]))
                    } else if parts.count == 2 {
                        symbols.insert(String(parts[1]))
                    }
                }
                return symbols
            }
        } catch {
            print("Error running nm: \(error)")
        }
        return []
    }

    static func selfAlignInterface(code: String, parser: Parser, tbdPath: String) -> String {
        let tempInterfacePath = "/tmp/_self_align_interface.swift"
        let tempDylibPath = "/tmp/_self_align_dylib.dylib"
        
        let reexportedLibraries: [String]
        if let content = try? String(contentsOfFile: tbdPath, encoding: .utf8) {
            reexportedLibraries = extractReexportedLibraries(from: content)
        } else {
            reexportedLibraries = []
        }
        let reexportedModules = Set(reexportedLibraries.map { ($0 as NSString).lastPathComponent })
        var fullFile = ""
        let imports = resolveImports(from: code, currentModule: parser.defaultModule, parser: parser)
        for imp in imports {
            if reexportedModules.contains(imp) {
                fullFile += "@_exported import \(imp)\n"
            } else {
                fullFile += "import \(imp)\n"
            }
        }
        fullFile += "\n" + code
        
        do {
            try fullFile.write(toFile: tempInterfacePath, atomically: true, encoding: .utf8)
        } catch {
            fputs("Error writing temp interface file: \(error)\n", stderr)
            return code
        }
        
        // Find SDK root
        let sdkRoot: String
        if let envSdk = ProcessInfo.processInfo.environment["SDK_ROOT"] {
            sdkRoot = envSdk
        } else {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
            process.arguments = ["--show-sdk-path"]
            let pipe = Pipe()
            process.standardOutput = pipe
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                sdkRoot = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
            } catch {
                sdkRoot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
            }
        }
        
        // Compile temp dylib
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
        process.arguments = [
            "-emit-library",
            "-o", tempDylibPath,
            tempInterfacePath,
            "-enable-library-evolution",
            "-module-name", parser.defaultModule,
            "-F", "LocalFrameworks",
            "-sdk", sdkRoot,
            "-language-mode", "6",
            "-enable-experimental-feature", "NonescapableTypes",
            "-enable-experimental-feature", "Lifetimes"
        ]
        
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                fputs("Warning: Self-alignment compilation failed, returning unaligned code.\n", stderr)
                return code
            }
        } catch {
            fputs("Error compiling temp dylib: \(error)\n", stderr)
            return code
        }
        
        // Extract symbols
        let dylibSyms = extractDylibSymbols(dylibPath: tempDylibPath)
        
        func normalize(_ sym: String) -> String {
            if sym.hasPrefix("_") {
                return String(sym.dropFirst())
            }
            return sym
        }
        
        var normalizedDylib = Set<String>()
        for s in dylibSyms {
            normalizedDylib.insert(normalize(s))
        }
        
        var missing = [String]()
        for s in parser.tbdSymbols {
            if !normalizedDylib.contains(normalize(s)) {
                missing.append(s)
            }
        }
        missing.sort()
        
        fputs("Self-alignment: found \(missing.count) missing symbols to stub.\n", stderr)
        
        if missing.isEmpty {
            return code
        }
        
        var alignedCode = code
        alignedCode += "\n\n// --- Automatically Generated Self-Alignment Stubs ---\n"
        for (i, sym) in missing.enumerated() {
            let cleanSym = sym.hasPrefix("_") ? String(sym.dropFirst()) : sym
            alignedCode += "@_silgen_name(\"\(cleanSym)\")\n"
            alignedCode += "public func _self_align_stub_\(i)() { fatalError() }\n"
        }
        
        // Clean up temp files
        try? FileManager.default.removeItem(atPath: tempInterfacePath)
        try? FileManager.default.removeItem(atPath: tempDylibPath)
        
        return alignedCode
    }

    class StubNode {
        var name: String
        var isProtocol: Bool = false
        var kind: String = "struct"
        var genericCount: Int = 0
        var nested: [String: StubNode] = [:]
        
        init(name: String) {
            self.name = name
        }
        
        func generateSwift(depth: Int) -> String {
            let indent = String(repeating: "    ", count: depth)
            var params = ""
            if genericCount > 0 {
                let placeholders = ["A", "B", "C", "D", "E", "F"]
                let p = (0..<genericCount).map { $0 < placeholders.count ? placeholders[$0] : "A\($0)" }
                params = "<\(p.joined(separator: ", "))>"
            }
            
            var kindKeyword = "struct"
            if isProtocol {
                kindKeyword = "protocol"
            } else if kind == "enum" {
                kindKeyword = "enum"
            } else if kind == "class" {
                kindKeyword = "class"
            }
            
            let escapedName = ["Type", "Protocol", "Self", "self"].contains(name) ? "`\(name)`" : name
            var s = "\(indent)public \(kindKeyword) \(escapedName)\(params)"
            if kindKeyword == "struct" {
                s += ": Codable, Hashable, Sendable {\n"
                s += "\(indent)    public init() {}\n"
            } else if kindKeyword == "class" {
                // Classes cannot auto-synthesize Codable/Hashable — use @unchecked Sendable only
                s += ": @unchecked Sendable {\n"
                s += "\(indent)    public init() {}\n"
            } else if kindKeyword == "enum" {
                s += ": Codable, Hashable, Sendable {\n"
                s += "\(indent)    case case0\n"
            } else {
                s += " {\n"
            }
            
            for child in nested.values.sorted(by: { $0.name < $1.name }) {
                s += child.generateSwift(depth: depth + 1)
            }
            s += "\(indent)}\n"
            return s
        }
    }

    static func generateStubs(outputCode: String, currentModule: String, outputDir: String, parser: Parser) {
        var externalTypes = [String: [(typeName: String, isProtocol: Bool, genericCount: Int)]]()
        
        var constraintTypes = Set<String>()
        // 1. Parse 'where' constraints
        let localWherePattern = "where\\s+([^\\{]+)"
        if let regex = try? NSRegularExpression(pattern: localWherePattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    let constraintsStr = String(outputCode[range])
                    let individual = constraintsStr.components(separatedBy: ",")
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(":") {
                            let parts = trimmed.components(separatedBy: ":")
                            if parts.count == 2 {
                                let constraint = parts[1].replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                constraintTypes.insert(constraint)
                            }
                        }
                    }
                }
            }
        }
        // 2. Parse generic parameter lists `<...>`
        let localGenericListPattern = "<([^>]+)>"
        if let regex = try? NSRegularExpression(pattern: localGenericListPattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    let listStr = String(outputCode[range])
                    let individual = listStr.components(separatedBy: ",")
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(":") {
                            let parts = trimmed.components(separatedBy: ":")
                            if parts.count == 2 {
                                let constraint = parts[1].replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                constraintTypes.insert(constraint)
                            }
                        }
                    }
                }
            }
        }
        
        let pathPattern = "\\b([A-Z][a-zA-Z0-9_$]*\\.[a-zA-Z0-9_$]+(?:\\.[a-zA-Z0-9_$]+)*)\\b"
        if let regex = try? NSRegularExpression(pattern: pathPattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    let typeName = String(outputCode[range])
                    
                    var isProtocol = false
                    let startIdx = m.range(at: 1).location
                    if startIdx >= 4 {
                        let prevRange = NSRange(location: startIdx - 4, length: 4)
                        if let r = Range(prevRange, in: outputCode) {
                            let prevStr = String(outputCode[r])
                            if prevStr == "any " || prevStr.hasSuffix("any\t") {
                                isProtocol = true
                            }
                        }
                    }
                    
                    var genericCount = 0
                    let endIdx = m.range(at: 1).location + m.range(at: 1).length
                    if endIdx < outputCode.count {
                        var scan = endIdx
                        let chars = Array(outputCode)
                        while scan < chars.count && chars[scan].isWhitespace {
                            scan += 1
                        }
                        if scan < chars.count && chars[scan] == "<" {
                            var depth = 1
                            var commas = 0
                            scan += 1
                            while scan < chars.count && depth > 0 {
                                if chars[scan] == "<" { depth += 1 }
                                else if chars[scan] == ">" { depth -= 1 }
                                else if chars[scan] == "," && depth == 1 { commas += 1 }
                                scan += 1
                            }
                            if depth == 0 {
                                genericCount = commas + 1
                            }
                        }
                    }
                    
                    let parts = typeName.components(separatedBy: ".")
                    let mod = parts[0]
                    let sdkRoot = ConfigManager.sdkRoot
                    var isPrivateFw = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(mod).framework") ||
                                      FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(mod).framework")
                    // Also recognize pseudo-module names like `KnownFw_Suffix` (e.g.
                    // `IntelligencePlatformLibrary_AppleInternal`), which are private submodules
                    // not present as standalone .framework bundles.
                    if !isPrivateFw, let underIdx = mod.firstIndex(of: "_") {
                        let baseMod = String(mod[mod.startIndex..<underIdx])
                        if FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(baseMod).framework") ||
                           FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(baseMod).framework") {
                            isPrivateFw = true
                        }
                    }
                    if isPrivateFw && mod != currentModule {
                        var isProto = isProtocol
                        if constraintTypes.contains(typeName) || constraintTypes.contains(parts.dropFirst().joined(separator: ".")) {
                            isProto = true
                        }
                        externalTypes[mod, default: []].append((typeName: typeName, isProtocol: isProto, genericCount: genericCount))
                    }
                }
            }
        }
        
        var protocolAssociatedTypes = [String: Set<String>]()
        
        let declPattern = "(class|struct|enum|protocol)\\s+([a-zA-Z0-9_$]+)\\s*(?:<[^>]+>)?\\s*:\\s*([^{]+)"
        if let regex = try? NSRegularExpression(pattern: declPattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let kindRange = Range(m.range(at: 1), in: outputCode),
                   let listRange = Range(m.range(at: 3), in: outputCode) {
                    let kind = String(outputCode[kindRange])
                    let listStr = String(outputCode[listRange])
                    let inherits = listStr.components(separatedBy: ",")
                    for (idx, item) in inherits.enumerated() {
                        let cleanItem = item.trimmingCharacters(in: .whitespacesAndNewlines)
                        if kind == "struct" || kind == "enum" || kind == "protocol" || idx > 0 {
                            let cleanProto = cleanItem.replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            protocolAssociatedTypes[cleanProto] = protocolAssociatedTypes[cleanProto] ?? Set<String>()
                        }
                    }
                }
            }
        }
        let wherePattern = "where\\s+([^\\{]+)"
        if let regex = try? NSRegularExpression(pattern: wherePattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    let constraintsStr = String(outputCode[range])
                    let individual = constraintsStr.components(separatedBy: ",")
                    var typeToProtocol = [String: String]()
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(":") {
                            let subParts = trimmed.components(separatedBy: ":")
                            if subParts.count == 2 {
                                let lhs = subParts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                                let rhs = subParts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                                if lhs.count <= 3 {
                                    let cleanProto = rhs.replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                    typeToProtocol[lhs] = cleanProto
                                }
                            }
                        }
                    }
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(".") {
                            var clean = trimmed.replacingOccurrences(of: ":", with: " ")
                            clean = clean.replacingOccurrences(of: "==", with: " ")
                            let firstWord = clean.components(separatedBy: " ").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            if firstWord.contains(".") {
                                let subParts = firstWord.components(separatedBy: ".")
                                if subParts.count == 2 {
                                    let lhs = subParts[0]
                                    let rhs = subParts[1]
                                    if let proto = typeToProtocol[lhs] {
                                        protocolAssociatedTypes[proto, default: []].insert(rhs)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let fm = FileManager.default
        try? fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
        
        for (mod, items) in externalTypes {
            var fileContent = "import Foundation\n\n"
            let root = StubNode(name: mod)
            for item in items {
                let parts = item.typeName.components(separatedBy: ".")
                var current = root
                var pathSoFar = [String]()
                for part in parts.dropFirst() {
                    pathSoFar.append(part)
                    if current.nested[part] == nil {
                        let node = StubNode(name: part)
                        if let typeNode = parser.findTypeNode(module: mod, path: pathSoFar) {
                            node.kind = typeNode.kind
                        }
                        current.nested[part] = node
                    }
                    current = current.nested[part]!
                }
                if item.isProtocol {
                    current.isProtocol = true
                }
                current.genericCount = max(current.genericCount, item.genericCount)
            }
            
            var topLevelProtocols = [StubNode]()
            var topLevelTypes = [StubNode]()
            
            for child in root.nested.values {
                let fullPath = "\(mod).\(child.name)"
                if child.isProtocol || protocolAssociatedTypes[fullPath] != nil ||
                   ["Visitor", "Decoder", "Encoder", "Message", "Enum", "Stream"].contains(child.name) {
                    child.isProtocol = true
                    topLevelProtocols.append(child)
                } else {
                    topLevelTypes.append(child)
                }
            }
            
            for proto in topLevelProtocols.sorted(by: { $0.name < $1.name }) {
                let fullPath = "\(mod).\(proto.name)"
                var genericDecl = ""
                var assocDecl = ""
                var placeholderNames = Set<String>()
                if proto.genericCount > 0 {
                    let placeholders = ["A", "B", "C", "D", "E"]
                    let count = min(proto.genericCount, placeholders.count)
                    let names = Array(placeholders[..<count])
                    genericDecl = "<" + names.joined(separator: ", ") + ">"
                    placeholderNames = Set(names)
                    for name in names {
                        assocDecl += "    associatedtype \(name)\n"
                    }
                }
                fileContent += "public protocol \(proto.name)\(genericDecl) {\n"
                fileContent += assocDecl
                if let assocTypes = protocolAssociatedTypes[fullPath] {
                    for assoc in assocTypes.sorted() {
                        if !placeholderNames.contains(assoc) {
                            fileContent += "    associatedtype \(assoc)\n"
                        }
                    }
                }
                if proto.name == "Stream" {
                    fileContent += "    associatedtype EventType\n"
                }
                fileContent += "}\n\n"
            }
            
            for t in topLevelTypes.sorted(by: { $0.name < $1.name }) {
                fileContent += t.generateSwift(depth: 0) + "\n"
            }
            
            let filePath = "\(outputDir)/\(mod).swift"
            do {
                try fileContent.write(toFile: filePath, atomically: true, encoding: .utf8)
                print("Generated stub source for \(mod) at \(filePath)", to: &Self.standardError)
            } catch {
                print("Error: Could not write stub file to \(filePath)", to: &Self.standardError)
            }
        }
    }

    struct StandardError: TextOutputStream {
        func write(_ string: String) {
            fputs(string, stderr)
        }
    }
    static var standardError = StandardError()
}

@_silgen_name("swift_demangle")
func _stdlib_demangleImpl(
    _ mangledName: UnsafePointer<Int8>,
    mangledNameLength: Int,
    outputBuffer: UnsafeMutablePointer<Int8>?,
    outputBufferLength: UnsafeMutablePointer<Int>?,
    flags: Int32
) -> UnsafeMutablePointer<Int8>?

@_silgen_name("swift_demangle_flat")
func swift_demangle_flat(_ symbol: UnsafePointer<Int8>) -> UnsafePointer<Int8>?

@_silgen_name("swift_demangle_ast")
func swift_demangle_ast(_ symbol: UnsafePointer<Int8>) -> UnsafePointer<Int8>?
