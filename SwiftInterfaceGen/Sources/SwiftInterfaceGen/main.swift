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
                let libSymbols = extractSymbols(from: libContent)
                let libModule = (lib as NSString).lastPathComponent.replacingOccurrences(of: ".framework", with: "")
                processSymbols(libSymbols, parser: parser, module: libModule, depth: 1)
            }
        }
        
        processSymbols(symbols, parser: parser, module: currentModule, depth: 0)

        let startGen = Date()
        let allCode = parser.generateAll()
        print("generateAll took: \(Date().timeIntervalSince(startGen))s", to: &Self.standardError)
        
        let startPost = Date()
        let finalCode = postProcess(allCode, parser: parser)
        print("postProcess took: \(Date().timeIntervalSince(startPost))s", to: &Self.standardError)
        
        let imports = resolveImports(from: allCode, currentModule: currentModule, parser: parser)
        for imp in imports {
            print("import \(imp)")
        }
        
        let exportsContent = parser.tbdSymbols.sorted().joined(separator: "\n") + "\n"
        try? exportsContent.write(toFile: "\(currentModule)_exports.txt", atomically: true, encoding: .utf8)
        
        print(finalCode)
    }

    static func resolveImports(from code: String, currentModule: String, parser: Parser) -> [String] {
        var imports = Set<String>()
        imports.insert("Foundation")
        
        for mod in parser.referencedModules {
            if mod != currentModule && mod != "Swift" && mod != "__C" {
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
        
        for mod in parser.discoveredNamespaces {
            if code.contains("\(mod).") && mod != currentModule {
                if mod == "__C" { continue }
                let path1 = "\(ConfigManager.sdkRoot)/System/Library/PrivateFrameworks/\(mod).framework"
                let path2 = "\(ConfigManager.sdkRoot)/System/Library/SubFrameworks/\(mod).framework"
                if FileManager.default.fileExists(atPath: path1) || FileManager.default.fileExists(atPath: path2) {
                    imports.insert(mod)
                }
            }
        }
        
        return Array(imports).sorted()
    }

    static func processSymbols(_ symbols: [String], parser: Parser, module: String, depth: Int = 0) {
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
            let escapingResults = runDemangleExpand(symbols: symbolsWithClosures)
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

    struct TreeNode {
        let kind: String
        let text: String?
        let indent: Int
    }

    static func runDemangleExpand(symbols: [String]) -> [String: [Int: Bool]] {
        var allResults: [String: [Int: Bool]] = [:]
        let chunkSize = 100
        for i in stride(from: 0, to: symbols.count, by: chunkSize) {
            let end = min(i + chunkSize, symbols.count)
            let chunk = Array(symbols[i..<end])
            let chunkResult = runDemangleExpandChunk(symbols: chunk)
            allResults.merge(chunkResult) { (_, new) in new }
        }
        return allResults
    }

    static func runDemangleExpandChunk(symbols: [String]) -> [String: [Int: Bool]] {
        var result: [String: [Int: Bool]] = [:]
        if symbols.isEmpty { return result }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["swift-demangle", "--expand"]
        
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        
        do {
            try process.run()
        } catch {
            print("Failed to run swift-demangle --expand: \(error)", to: &Self.standardError)
            return result
        }
        
        let symbolsData = (symbols.joined(separator: "\n") + "\n").data(using: .utf8)!
        try? inputPipe.fileHandleForWriting.write(contentsOf: symbolsData)
        try? inputPipe.fileHandleForWriting.close()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        
        guard let output = String(data: data, encoding: .utf8) else { return result }
        
        return parseExpandTree(output: output)
    }

    static func parseExpandTree(output: String) -> [String: [Int: Bool]] {
        var result: [String: [Int: Bool]] = [:]
        
        let lines = output.components(separatedBy: .newlines)
        var currentSymbol: String? = nil
        var symbolLines: [String] = []
        
        for line in lines {
            if line.isEmpty { continue }
            if line.hasPrefix("Demangling for ") {
                if let sym = currentSymbol {
                    result[sym] = parseParameters(from: symbolLines)
                }
                currentSymbol = line.replacingOccurrences(of: "Demangling for ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                symbolLines = []
            } else if currentSymbol != nil {
                if !line.hasPrefix(" ") && !line.contains("kind=") {
                    // This is the demangled name line, end of tree for this symbol
                    if let sym = currentSymbol {
                        result[sym] = parseParameters(from: symbolLines)
                    }
                    currentSymbol = nil
                    symbolLines = []
                } else {
                    symbolLines.append(line)
                }
            }
        }
        if let sym = currentSymbol {
            result[sym] = parseParameters(from: symbolLines)
        }
        return result
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
            guard let demangledNamePtr = _stdlib_demangleImpl(
                mangledNamePtr,
                mangledNameLength: mangledName.count,
                outputBuffer: nil,
                outputBufferLength: nil,
                flags: 0
            ) else {
                return nil
            }
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
    }

    static func postProcess(_ code: String, parser: Parser) -> String {
        var c = code
        // Remove redundant current module prefix to avoid self-referencing, and ObjectiveC.
        c = c.replacingOccurrences(of: "\(parser.defaultModule).", with: "")
        c = c.replacingOccurrences(of: "ObjectiveC.", with: "")
        
        // Handle Foundation and Swift more carefully to avoid "typealias NSCoder = NSCoder"
        c = c.replacingOccurrences(of: ": Foundation.", with: ": ___FOUNDATION___")
        c = c.replacingOccurrences(of: "-> Foundation.", with: "-> ___FOUNDATION___")
        c = c.replacingOccurrences(of: "Array<Foundation.", with: "Array<___FOUNDATION___")
        c = c.replacingOccurrences(of: "Optional<Foundation.", with: "Optional<___FOUNDATION___")
        c = c.replacingOccurrences(of: "= Foundation.", with: "= ___FOUNDATION___")

        c = c.replacingOccurrences(of: "Foundation.", with: "")
        c = c.replacingOccurrences(of: "___FOUNDATION___", with: "Foundation.")
        
        // Strip Swift. from types unless there is a collision
        let standardShadowedTypes = ["Float", "Double", "Int", "String", "Bool"].filter { parser.discoveredConcreteTypes.contains($0) }
        for type in standardShadowedTypes {
            c = c.replacingOccurrences(of: "Swift.\(type)", with: "___SWIFT_SHIELDED_\(type)___")
        }
        
        c = c.replacingOccurrences(of: "Swift.", with: "")
        
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
            
            let flatName = t.replacingOccurrences(of: ".", with: "_")
            flatGenerics[flatName] = max(flatGenerics[flatName] ?? 0, count)
            
            let components = t.components(separatedBy: ".")
            if components.count <= 2 {
                shortGenerics[shortName] = max(shortGenerics[shortName] ?? 0, count)
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
        
        // Final cleanup of redundant newlines
        let lines = c.components(separatedBy: "\n")
        var newLines = [String]()
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            newLines.append(line)
        }
        c = newLines.joined(separator: "\n")
        
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
        for sym in missing {
            stubsContent += ".globl \(sym)\n\(sym):\n    .quad 0\n"
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
        process.arguments = ["-gU", dylibPath]
        
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
