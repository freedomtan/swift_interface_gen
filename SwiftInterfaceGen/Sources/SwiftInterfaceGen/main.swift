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
        parser.primaryTargetModule = currentModule
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
        
        // Process Swift symbols first so enum/struct kinds are established before
        // ObjC class registration, preventing ObjC from overriding Swift-known kinds.
        processSymbols(symbols, parser: parser, module: currentModule, depth: 0)
        registerObjcClasses(from: content, parser: parser, module: currentModule)
        
        if let dict = try? JSONSerialization.data(withJSONObject: parser.discoveredGenerics, options: [.prettyPrinted]),
           let str = String(data: dict, encoding: .utf8) {
            try? str.write(toFile: "discovered_generics.json", atomically: true, encoding: .utf8)
        }

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
                    var actualKind = t.kind == "unknown" ? "struct" : t.kind
                    if t.name == "MLModelStructure" {
                        actualKind = "class"
                    }
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
                var bridgeHeader = headerLines.joined(separator: "\n") + "\n"
                if currentModule == "CoreML" {
                    bridgeHeader += """
@interface MLBatchProvider : NSObject
@end
@interface MLComputeDeviceProtocol : NSObject
@end
@interface MLFeatureProvider : NSObject
@end
typedef NS_ENUM(NSInteger, MLComputeUnits) {
    MLComputeUnitsAll = 0
};
typedef NS_ENUM(NSInteger, MLFeatureType) {
    MLFeatureTypeInvalid = 0
};
typedef NS_ENUM(NSInteger, MLMultiArrayDataType) {
    MLMultiArrayDataTypeDouble = 0
};
@interface MLModelCollection : NSObject
@end

"""
                }
                // SFSpeechRecognitionTaskHint/SFSpeechErrorCode are real public ObjC enums
                // (Speech/SFSpeechRecognitionTaskHint.h, Speech/SFErrors.h) referenced only as
                // parameter/property types, never extended — so the parser's `isObjcBridged`
                // discovery (which only fires for So-prefixed *extension* symbols) never finds
                // them, and no declaration for them ends up in bridgedTypes above. Stub them
                // here so the __C.SFSpeechRecognitionTaskHint/__C.SFSpeechErrorCode references
                // resolve.
                if currentModule == "Speech" {
                    bridgeHeader += """
typedef NS_ENUM(NSInteger, SFSpeechRecognitionTaskHint) {
    SFSpeechRecognitionTaskHintUnspecified = 0
};
typedef NS_ENUM(NSInteger, SFSpeechErrorCode) {
    SFSpeechErrorCodeInternalServiceError = 1
};

"""
                }
                // HKWorkoutMetricsDelegate is a real @objc protocol (has @required/@optional
                // sections per the ObjC runtime metadata) referenced only as an optional
                // property type (`var delegate: HKWorkoutMetricsDelegate?`) — its own
                // declaration never emits a demangleable ABI symbol into the TBD at all, so
                // the parser has nothing to build a node from. Stub it as an @objc protocol so
                // the reference resolves.
                if currentModule == "HealthKit" {
                    bridgeHeader += """
@protocol HKWorkoutMetricsDelegate <NSObject>
@end
@protocol HKDataCacheContext <NSObject>
@end
@protocol HKDataCacheProviding <NSObject>
@end
typedef NSString * HKVerifiableClinicalRecordCredentialType;
typedef NSString * HKVerifiableClinicalRecordSourceType;

"""
                }
                let bridgeImpl   = implLines.joined(separator: "\n")   + "\n"
                try? bridgeHeader.write(toFile: "\(currentModule)Interface_bridge.h", atomically: true, encoding: .utf8)
                try? bridgeImpl.write(toFile:   "\(currentModule)Interface_bridge.m", atomically: true, encoding: .utf8)
                print("Wrote ObjC bridge for \(bridgedTypes.map { $0.name })", to: &Self.standardError)
            }
        }
    }

    static func resolveImports(from code: String, currentModule: String, parser: Parser) -> [String] {
        var imports = Set<String>()
        // Foundation-level modules must not import Foundation (circular dependency)
        let foundationLevel: Set<String> = ["Foundation", "Combine", "CoreFoundation", "Dispatch", "os"]
        if !foundationLevel.contains(currentModule) {
            imports.insert("Foundation")
        }
        
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
        if code.contains("NSWindow") || code.contains("NSView") || code.contains("NSViewController") || code.contains("NSResponder") { imports.insert("AppKit") }
        if code.contains("Combine.") && currentModule != "Combine" { imports.insert("Combine") }
        if code.contains("SwiftUI.") && currentModule != "SwiftUI" { imports.insert("SwiftUI") }
        if code.contains("AVFoundation.") || code.contains("AVAudio") || code.contains("AVVideo") || code.contains("AVDepthData") { imports.insert("AVFoundation") }
        if code.contains("CoreLocation.") || code.contains("CLLocation") { imports.insert("CoreLocation") }
        if code.contains("UAF") && currentModule != "UnifiedAssetFramework" { imports.insert("UnifiedAssetFramework") }
        if code.contains("LAContext") { imports.insert("LocalAuthentication") }
        if code.contains("NLLanguage") || code.contains("NLDistanceType") { imports.insert("NaturalLanguage") }
        if code.contains("VNImageCropAndScaleOption") || code.contains("VNRequest") || code.contains("VNBarcodeSymbology") { imports.insert("Vision") }
        if code.contains("ACAccount") { imports.insert("Accounts") }
        if code.contains("RBSAssertion") || code.contains("RBS") { imports.insert("RunningBoardServices") }
        
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
                    // Skip symbols embedded inside `$ld$previous$...` linker metadata lines.
                    // These appear as `_$s<mangled>` inside a `$ld$previous$/path/$...$` string
                    // and represent old ABI-compatibility symbols, not current exports.
                    let isPreviousSymbol = start > 0 && chars[start - 1] == "$"
                    if !isPreviousSymbol {
                        symbols.insert(token)
                    }
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
        
        // NSUnit subclasses: Measurement<T> requires T: Unit. Map NSUnit* classes to NSUnit base.
        let nsUnitSubclasses: Set<String> = [
            "NSUnitAcceleration", "NSUnitAngle", "NSUnitArea", "NSUnitConcentrationMass",
            "NSUnitDispersion", "NSUnitDuration", "NSUnitElectricCharge", "NSUnitElectricCurrent",
            "NSUnitElectricPotentialDifference", "NSUnitElectricResistance", "NSUnitEnergy",
            "NSUnitFrequency", "NSUnitFuelEfficiency", "NSUnitIlluminance",
            "NSUnitInformationStorage", "NSUnitLength", "NSUnitMass", "NSUnitPower", "NSUnitPressure",
            "NSUnitSpeed", "NSUnitTemperature", "NSUnitVolume",
        ]
        for objcClass in objcClasses {
            if objcClass.hasPrefix("_Tt") {
                continue
            }
            let node = parser.findOrCreateDiscoveredTypePath(module: module, path: [objcClass])
            if node.kind == "unknown" {
                parser.setKind("class", for: node)
                node.baseClass = nsUnitSubclasses.contains(objcClass) ? "NSUnit" : "NSObject"
                node.isObjcBridged = true
            } else if node.kind == "class" {
                node.isObjcBridged = true
            }
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
        // Shield conflict-prone system types from prefix-stripping in postProcess
        c = c.replacingOccurrences(of: "Foundation.FormatStyle", with: "___FOUNDATION_SHIELDED_FormatStyle___")
        c = c.replacingOccurrences(of: "Swift.Slice", with: "___SWIFT_SHIELDED_Slice___")
        
        // Remove DistributedActorSystemError from conformances. Order matters: the
        // ": X, Rest" case must run before the "X, " / ", X" cases below, otherwise a leading
        // conformance (": Distributed.DistributedActorSystemError, Swift.Error") loses only the
        // type name and leaves a dangling ": , Swift.Error" (invalid — "expected type").
        c = c.replacingOccurrences(of: ": Distributed.DistributedActorSystemError, ", with: ": ")
        c = c.replacingOccurrences(of: ", Distributed.DistributedActorSystemError", with: "")
        c = c.replacingOccurrences(of: ": Distributed.DistributedActorSystemError", with: ":")
        
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
        
        var standardShadowedTypes = ["Float", "Double", "Int", "String", "Bool", "Error"].filter { parser.discoveredConcreteTypes.contains($0) }
        // Decoder/Encoder are always shielded since generated code always references them by
        // full name. Sequence is shielded too: Combine declares its own nested type also named
        // "Sequence" (Publishers.Sequence), which shadows Swift.Sequence — without shielding,
        // the blanket `Swift.` prefix strip below turns a `Swift.Sequence` constraint bound into
        // a bare, self-referential `Sequence` bound.
        standardShadowedTypes.append(contentsOf: ["Decoder", "Encoder", "Sequence"])
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

        // Fix: `<Any: P>`, `<each Any>`, `<Self: P>` generic-parameter-NAME clauses on
        // func/init/subscript/associatedtype declarations (Any/Self are Swift keywords and
        // cannot name a generic parameter). Line-scoped to declarations only.
        c = c.removeInvalidAnyGenericClauses()

        // Fix: `associatedtype Result<Any, Error>` — associated types can't be generic.
        // Strip the `<...>` clause after the associatedtype name.
        if let regex = try? NSRegularExpression(
            pattern: "(associatedtype\\s+[A-Za-z_][A-Za-z0-9_]*)<[^>]*>", options: []) {
            c = regex.stringByReplacingMatches(
                in: c, range: NSRange(c.startIndex..<c.endIndex, in: c), withTemplate: "$1")
        }

        // Fix: Category B — `Predicate<Pack {` / `<Pack{...}>` parameter pack truncation.
        // Swift parameter packs produce `Pack{T...}` in the demangled output which we can't
        // fully reconstruct; replace with `Any` as an existential fallback.
        // `Pack{...}` may appear at any position inside a generic arg list, e.g.:
        //   `Predicate<Pack{A}>` → `Predicate<Any>`
        //   `Configuration<A, Pack{repeat B}>` → `Configuration<A, Any>`
        if let regex = try? NSRegularExpression(
            pattern: "Pack\\s*\\{[^}]*\\}", options: []) {
            c = regex.stringByReplacingMatches(
                in: c, range: NSRange(c.startIndex..<c.endIndex, in: c), withTemplate: "Any")
        }
        // Truncated form `<Pack ` or `<Pack\n` (trailing brace is actually the getter body):
        // replace `TypeName<Pack ` with `TypeName<Any> ` on each line
        var packLines = c.components(separatedBy: "\n")
        packLines = packLines.map { line in
            guard line.contains("<Pack") else { return line }
            if let r = line.range(of: "<Pack") {
                let suffix = line[r.upperBound...]
                if suffix.hasPrefix("{") || suffix.hasPrefix(" {") || suffix.hasPrefix("\n") || suffix.isEmpty {
                    return line.replacingCharacters(in: r, with: "<Any>")
                }
            }
            return line
        }
        c = packLines.joined(separator: "\n")

        // Fix: ObjC→Swift type renames.
        c = c.replacingOccurrences(of: "NSBundle", with: "Bundle")
        c = c.replacingOccurrences(of: "OS_os_log", with: "OSLog")
        c = c.replacingOccurrences(of: "NSUnitConverter", with: "UnitConverter")
        c = c.replacingOccurrences(of: "NSProgress", with: "Progress")
        c = c.replaceWord("NSComparisonResult", with: "ComparisonResult")
        c = c.replaceWord("NSFileProtectionType", with: "FileProtectionType")
        c = c.replaceWord("NSNotificationName", with: "NSNotification.Name")
        c = c.replaceWord("NSUndoManager", with: "UndoManager")
        c = c.replaceWord("NSValueTransformer", with: "ValueTransformer")
        c = c.replaceWord("SecKeyRef", with: "SecKey")
        c = c.replaceWord("SecAccessControlRef", with: "SecAccessControl")

        // Fix: CryptoKit's HKDF is actually generic (`struct HKDF<H> where H: HashFunction`),
        // but no ABI symbol ever applies a generic argument directly to the type itself (only
        // indirectly, via `extract`'s return type `HashedAuthenticationCode<H>`), so our
        // generic-parameter discovery pass never marks it generic. `extract`'s two overloads
        // reference the never-declared bare `HashedAuthenticationCode<GenericA>`/
        // `HashedAuthenticationCode<A>` — one wrongly reusing the method's own DataProtocol
        // placeholder, the other referencing an undeclared struct-scope `A`. Make HKDF generic
        // and fix both `extract` overloads to return `HashedAuthenticationCode` parameterized by
        // HKDF's own generic parameter, matching the real module.
        if parser.defaultModule == "CryptoKit" {
            c = c.replacingOccurrences(
                of: "public struct HKDF: Codable, Hashable, @unchecked Sendable {",
                with: "public struct HKDF<A>: Codable, Hashable, @unchecked Sendable where A: HashFunction {")
            c = c.replacingOccurrences(
                of: "public static func extract<GenericA>(inputKeyMaterial: SymmetricKey, salt: GenericA?) -> HashedAuthenticationCode<GenericA> where GenericA: DataProtocol { fatalError() }",
                with: "public static func extract<GenericA>(inputKeyMaterial: SymmetricKey, salt: GenericA?) -> HashedAuthenticationCode<A> where GenericA: DataProtocol { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func extract(inputKeyMaterial: SymmetricKey, salt: borrowing RawSpan?) -> HashedAuthenticationCode<A> { fatalError() }",
                with: "public static func extract(inputKeyMaterial: SymmetricKey, salt: borrowing RawSpan?) -> HashedAuthenticationCode<A> { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: HKDF, _ rhs: HKDF) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: HKDF<A>, _ rhs: HKDF<A>) -> Bool { fatalError() }")
            // `SecureEnclave.P256`/`.P384`/`.P521`/`.Curve` are distinct nested enums that shadow
            // the top-level `P256`/`P384`/`P521`/`Curve` types of the same name. Bare references
            // like `P256.KeyAgreement.PublicKey` written inside SecureEnclave's own nested types
            // resolve to the *enclosing* SecureEnclave.P256 (which has no such nested member)
            // instead of the top-level type the real module actually means. Fully qualify with
            // the module name (unambiguous everywhere, including outside SecureEnclave) so name
            // lookup can't shadow it.
            for curve in ["P256", "P384", "P521", "Curve"] {
                c = c.replacingOccurrences(of: "\(curve).KeyAgreement.PublicKey", with: "CryptoKit.\(curve).KeyAgreement.PublicKey")
                c = c.replacingOccurrences(of: "\(curve).Signing.ECDSASignature", with: "CryptoKit.\(curve).Signing.ECDSASignature")
                c = c.replacingOccurrences(of: "\(curve).Signing.PublicKey", with: "CryptoKit.\(curve).Signing.PublicKey")
            }
            // Same shadowing issue for the post-quantum key types nested under SecureEnclave.
            for pqType in ["MLDSA65", "MLDSA87", "MLKEM1024", "MLKEM768"] {
                c = c.replacingOccurrences(of: "\(pqType).PublicKey", with: "CryptoKit.\(pqType).PublicKey")
            }
            // HPKEDiffieHellmanPublicKey requires `associatedtype EphemeralPrivateKey:
            // HPKEDiffieHellmanPrivateKeyGeneration where Self == Self.EphemeralPrivateKey.PublicKey`.
            // The sibling `KeyAgreement.PrivateKey` in the same nested scope satisfies the
            // where-clause (its own `publicKey` property already returns this exact PublicKey
            // type), but the compiler can't infer that witness purely from context — every
            // curve's `KeyAgreement.PublicKey` struct has this identical declaration line, so a
            // single global replace adds the associated-type alias for all of them at once.
            c = c.replacingOccurrences(
                of: "public struct PublicKey: HPKEDiffieHellmanPublicKey, HPKEPublicKeySerialization {",
                with: "public struct PublicKey: HPKEDiffieHellmanPublicKey, HPKEPublicKeySerialization {\n            public typealias EphemeralPrivateKey = PrivateKey")
            // Same associated-type-inference gap as HPKEDiffieHellmanPublicKey above, but for
            // HPKEKEMPublicKey (XWingMLKEM768X's sibling PrivateKey/PublicKey pair).
            c = c.replacingOccurrences(
                of: "public struct PublicKey: HPKEKEMPublicKey, HPKEPublicKeySerialization, KEMPublicKey {",
                with: "public struct PublicKey: HPKEKEMPublicKey, HPKEPublicKeySerialization, KEMPublicKey {\n        public typealias EphemeralPrivateKey = PrivateKey")
            // HashFunction's `associatedtype Digest: Digest` shadows the bound protocol with the
            // associated type's own name — qualify the bound with the module name.
            c = c.replacingOccurrences(of: "associatedtype Digest: Digest", with: "associatedtype Digest: CryptoKit.Digest")
        }

        // Fix: CryptoKit's Digest/MessageAuthenticationCode `==<A1>(_ arg1: Any, _ arg2: A1)`
        // is a mis-demangled `==<A1>(Self, A1)` — the demangler's first parameter loses its
        // Self-typed identity and gets simplified down to the generic-placeholder fallback
        // `Any`, but a `==` overload defined in a protocol extension must have at least one
        // parameter of the exact type `Self`.
        c = c.replacingOccurrences(
            of: "public static func ==<A1>(_ arg1: Any, _ arg2: A1) -> Swift.Bool where A1: DataProtocol { fatalError() }",
            with: "public static func ==<A1>(_ arg1: Self, _ arg2: A1) -> Swift.Bool where A1: DataProtocol { fatalError() }")
        c = c.replaceWord("NSDecimal", with: "Decimal")
        c = c.replaceWord("CGImageRef", with: "CGImage")
        c = c.replaceWord("CGMutablePathRef", with: "CGMutablePath")
        c = c.replaceWord("CGPathRef", with: "CGPath")
        c = c.replaceWord("CGColorRef", with: "CGColor")
        c = c.replaceWord("CFStringRef", with: "CFString")
        // NSUnit* subclasses were renamed to Unit* in Swift; remove any locally-emitted
        // stub declarations for them BEFORE renaming (they shadow Foundation's real Unit subclasses).
        for nsUnitType in ["NSUnit", "NSUnitAcceleration", "NSUnitAngle", "NSUnitArea", "NSUnitConcentrationMass",
                           "NSUnitDispersion", "NSUnitDuration", "NSUnitElectricCharge", "NSUnitElectricCurrent",
                           "NSUnitElectricPotentialDifference", "NSUnitElectricResistance", "NSUnitEnergy",
                           "NSUnitFrequency", "NSUnitFuelEfficiency", "NSUnitIlluminance", "NSUnitInformationStorage",
                           "NSUnitLength", "NSUnitMass", "NSUnitPower", "NSUnitPressure", "NSUnitSpeed",
                           "NSUnitTemperature", "NSUnitVolume"] {
            c = c.replacingOccurrences(of: "public class \(nsUnitType):", with: "// Foundation type: \(nsUnitType):")
            c = c.replacingOccurrences(of: "public struct \(nsUnitType):", with: "// Foundation type: \(nsUnitType):")
        }

        // NSUnit* subclasses were renamed to Unit* in Swift. NSUnit itself (the base class,
        // e.g. Measurement<NSUnit>'s generic argument) renames to bare "Unit" — must run AFTER
        // the specific NSUnit<Dimension> renames above/below so "NSUnitLength" isn't partially
        // matched and renamed to "UnitLength" via the "NSUnit"->"Unit" rule first.
        for (old, new) in [
            ("NSUnitAcceleration", "UnitAcceleration"), ("NSUnitAngle", "UnitAngle"),
            ("NSUnitArea", "UnitArea"), ("NSUnitConcentrationMass", "UnitConcentrationMass"),
            ("NSUnitDispersion", "UnitDispersion"), ("NSUnitDuration", "UnitDuration"),
            ("NSUnitElectricCharge", "UnitElectricCharge"), ("NSUnitElectricCurrent", "UnitElectricCurrent"),
            ("NSUnitElectricPotentialDifference", "UnitElectricPotentialDifference"),
            ("NSUnitElectricResistance", "UnitElectricResistance"), ("NSUnitEnergy", "UnitEnergy"),
            ("NSUnitFrequency", "UnitFrequency"), ("NSUnitFuelEfficiency", "UnitFuelEfficiency"),
            ("NSUnitIlluminance", "UnitIlluminance"), ("NSUnitInformationStorage", "UnitInformationStorage"),
            ("NSUnitLength", "UnitLength"), ("NSUnitMass", "UnitMass"), ("NSUnitPower", "UnitPower"),
            ("NSUnitPressure", "UnitPressure"), ("NSUnitSpeed", "UnitSpeed"),
            ("NSUnitTemperature", "UnitTemperature"), ("NSUnitVolume", "UnitVolume"),
            ("NSUnit", "Unit"),
        ] as [(String, String)] {
            c = c.replaceWord(old, with: new)
        }

        // Fix: `var $foo` — `$` prefix is reserved for projected values of property wrappers.
        // The real symbol is the projected value (e.g. Published<T>.Publisher). Rename to avoid
        // the reserved-name error while still emitting the symbol.
        c = c.replacingOccurrences(of: " var $", with: " var _proj_")

        // Fix: `struct [A]: Protocol` — an extension on Array<A> was emitted as a struct.
        // Drop these lines; the conformance is provided by the real framework at runtime.
        if let regex = try? NSRegularExpression(pattern: "^public struct \\[[^\\]]+\\].*\\{[^\\}]*\\}\\s*$",
                                                options: [.anchorsMatchLines, .dotMatchesLineSeparators]) {
            c = regex.stringByReplacingMatches(
                in: c, range: NSRange(c.startIndex..<c.endIndex, in: c), withTemplate: "")
        }

        // Fix: `TypeName<A><A, A1>` double-generic — method-level generic was appended alongside
        // a struct-level generic. Merge consecutive `<X><Y>` into `<X>` (keep only the first).
        var mergeChanged = true
        while mergeChanged {
            mergeChanged = false
            var searchIdx = c.startIndex
            while let ltRange = c.range(of: "><", range: searchIdx..<c.endIndex) {
                // Found `><` — check if both sides are generic brackets
                // Find the opening `<` for the first bracket
                var depth = 0
                var firstOpen: String.Index? = nil
                var scanBack = ltRange.lowerBound
                while scanBack >= c.startIndex {
                    if c[scanBack] == ">" { depth += 1 }
                    else if c[scanBack] == "<" {
                        depth -= 1
                        if depth == 0 { firstOpen = scanBack; break }
                    }
                    if scanBack == c.startIndex { break }
                    scanBack = c.index(before: scanBack)
                }
                // Find the closing `>` for the second bracket
                depth = 0
                var secondClose: String.Index? = nil
                var scanFwd = c.index(before: ltRange.upperBound)  // the `<`
                while scanFwd < c.endIndex {
                    if c[scanFwd] == "<" { depth += 1 }
                    else if c[scanFwd] == ">" { depth -= 1; if depth == 0 { secondClose = scanFwd; break } }
                    scanFwd = c.index(after: scanFwd)
                }
                if let fo = firstOpen, let sc = secondClose {
                    // Check: the char before firstOpen is a valid type-name char
                    var isTypeGeneric = false
                    if fo > c.startIndex {
                        let prev = c[c.index(before: fo)]
                        isTypeGeneric = prev.isLetter || prev.isNumber || prev == "_"
                    }
                    if isTypeGeneric {
                        // Remove the second `<...>` bracket: from the `<` to `>` (inclusive)
                        // ltRange = range of `><` — upperBound-1 is the `<` of second bracket
                        let secondOpen = c.index(before: ltRange.upperBound)
                        c.removeSubrange(secondOpen...sc)
                        mergeChanged = true
                        break
                    }
                }
                searchIdx = ltRange.upperBound
            }
        }
        
        // Fix `Any<T>` — `Any` followed by generic args is invalid, strip the generic.
        // Use depth-aware loop to correctly handle nested generics like `Any<Any<T>>`.
        var anyGenChanged = true
        while anyGenChanged {
            anyGenChanged = false
            var anySearch = c.startIndex
            while let anyRange = c.range(of: "Any<", range: anySearch..<c.endIndex) {
                // Check word boundary before `Any`
                var isWordBefore = false
                if anyRange.lowerBound > c.startIndex {
                    let prev = c[c.index(before: anyRange.lowerBound)]
                    isWordBefore = prev.isLetter || prev.isNumber || prev == "_"
                }
                if isWordBefore { anySearch = anyRange.upperBound; continue }
                // Find matching `>` by depth
                let lt = c.index(before: anyRange.upperBound)  // position of `<`
                var depth = 0; var j = lt; var gt: String.Index? = nil
                while j < c.endIndex {
                    if c[j] == "<" { depth += 1 }
                    else if c[j] == ">" { depth -= 1; if depth == 0 { gt = j; break } }
                    j = c.index(after: j)
                }
                if let g = gt {
                    c.replaceSubrange(lt...g, with: "")  // strip `<...>` leaving just `Any`
                    anyGenChanged = true
                    anySearch = anyRange.lowerBound
                } else {
                    anySearch = anyRange.upperBound
                }
            }
        }

        // Fix: Category J — IndexingIterator needs IteratorProtocol conformance so that
        // `Sequence` conformances using `makeIterator() -> IndexingIterator<T>` type-check.
        // Use `Any` element type since this is a stub (the real type is T.Element).
        c = c.replacingOccurrences(
            of: "public struct IndexingIterator<T>: Hashable, Codable, Sendable {}",
            with: "public struct IndexingIterator<T>: IteratorProtocol { public typealias Element = Any; public mutating func next() -> Any? { nil } }")

        // Fix: `func init(` — `init` cannot be used as a function name; render as initializer.
        c = c.replacingOccurrences(of: "func init(", with: "init(")
        c = c.replacingOccurrences(of: "func init?(", with: "init?(")
        c = c.replacingOccurrences(of: "func init!(", with: "init!(")

        // Fix: subscript `{ get set }` in extension context — extensions need implementation
        // bodies, not protocol-style accessor declarations. This is applied line-by-line,
        // checking that we're NOT inside a `protocol` declaration (only inside extensions/structs).
        c = c.fixSubscriptGetSetInExtensions()

        // Fix: `where Any == ConcreteType` — same-type constraints with `Any` on LHS are invalid.
        // Remove `, Any == <anything>` and `Any == <anything>,` from where clauses safely.
        c = c.removeAnyConstraintsFromWhereClause()

        // Strip invalid/duplicate `extension RawRepresentableWrapper where ...` blocks
        c = c.stripRawRepresentableWrapperExtensions()

        // Fix: `where T: any Protocol` — `any` in conformance constraints is invalid;
        // remove `any` from constraint positions in where clauses.
        if let regex = try? NSRegularExpression(pattern: "(where\\s[^{]*?:\\s*)any\\s+", options: []) {
            var replaced = true
            while replaced {
                let before = c
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c), withTemplate: "$1")
                replaced = c.count != before.count
            }
        }

        // Fix stray double-`>>` before `(` in subscript/func generic clause:
        // `subscript<A1>>(` → `subscript<A1>(` (extra `>` from stripped second param).
        c = c.replacingOccurrences(of: ">>(", with: ">(")

        // Replace `any Self` inside protocol bodies with `any <ProtocolName>`.
        // The demangler produces `[any Self]` for some protocol requirements, but conforming
        // types implement them with the explicit protocol name (e.g. `[any AppleIntelligenceError]`).
        c = c.replaceAnySelfInProtocolBodies()

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

        // Re-apply: applyDiscoveredGenerics may have re-added `<Any, Error>` to associatedtype.
        // Strip generic clauses from associatedtype declarations (associatedtypes can't be generic).
        if let regex = try? NSRegularExpression(
            pattern: "(associatedtype\\s+[A-Za-z_][A-Za-z0-9_]*)<[^>]*>", options: []) {
            c = regex.stringByReplacingMatches(
                in: c, range: NSRange(c.startIndex..<c.endIndex, in: c), withTemplate: "$1")
        }
        // Fix: `Self.Result<Any, Error>` — applyDiscoveredGenerics adds `<Any, Error>` to `Result`
        // in use-site positions like `Self.Result<Any, Error>`. Associated types can't be specialized.
        if let regex = try? NSRegularExpression(
            pattern: "Self\\.([A-Z][A-Za-z0-9_]*)<[^>]*>", options: []) {
            c = regex.stringByReplacingMatches(
                in: c, range: NSRange(c.startIndex..<c.endIndex, in: c), withTemplate: "Self.$1")
        }
        // Also re-apply removeInvalidAnyGenericClauses for any new `<Any:>` that may appear.
        c = c.removeInvalidAnyGenericClauses()

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

        c = c.replacingOccurrences(of: "AVAudioSessionCategoryOptions", with: "AVAudioSession.CategoryOptions")
        c = c.replacingOccurrences(of: "AVAudioSessionCategory", with: "AVAudioSession.Category")
        c = c.replacingOccurrences(of: "AVAudioSessionMode", with: "AVAudioSession.Mode")
        c = c.replacingOccurrences(of: "NSUserDefaults", with: "UserDefaults")
        c = c.replacingOccurrences(of: "public typealias __C_NSVisualEffectBlendingMode = NSVisualEffectBlendingMode", with: "")
        c = c.replacingOccurrences(of: "public typealias __C_NSVisualEffectMaterial = NSVisualEffectMaterial", with: "")
        c = c.replacingOccurrences(of: "NSVisualEffectBlendingMode", with: "NSVisualEffectView.BlendingMode")
        c = c.replacingOccurrences(of: "NSVisualEffectMaterial", with: "NSVisualEffectView.Material")
        c = c.replacingOccurrences(of: "public typealias __C_NSCollectionViewItemHighlightState = NSCollectionViewItemHighlightState", with: "")
        c = c.replacingOccurrences(of: "public typealias __C_NSCollectionViewScrollDirection = NSCollectionViewScrollDirection", with: "")
        c = c.replacingOccurrences(of: "NSCollectionViewItemHighlightState", with: "NSCollectionViewItem.HighlightState")
        c = c.replacingOccurrences(of: "NSCollectionViewScrollDirection", with: "NSCollectionView.ScrollDirection")
        c = c.replacingOccurrences(of: "public typealias __C_NSURLSessionTask = NSURLSessionTask", with: "")
        c = c.replacingOccurrences(of: "public typealias __C_NSURLSessionTaskMetrics = NSURLSessionTaskMetrics", with: "")
        c = c.replacingOccurrences(of: "public typealias __C_NSURLSessionConfiguration = NSURLSessionConfiguration", with: "")
        c = c.replacingOccurrences(of: "public typealias __C_NSURLSession = NSURLSession", with: "")
        c = c.replacingOccurrences(of: "NSURLSessionTaskMetrics", with: "URLSessionTaskMetrics")
        c = c.replacingOccurrences(of: "NSURLSessionTask", with: "URLSessionTask")
        c = c.replacingOccurrences(of: "NSURLSessionConfiguration", with: "URLSessionConfiguration")
        c = c.replacingOccurrences(of: "NSURLSession", with: "URLSession")

        // Clean up invalid declarations with dots in name like `public struct __C_NSVisualEffectView.BlendingMode`
        c = c.replacingOccurrences(of: "public\\s+(?:struct|class|enum|typealias)\\s+__C_[A-Za-z0-9_]+\\.[^\n]+\n?", with: "", options: .regularExpression)

        if parser.defaultModule == "SoundAnalysis" {
            c = c.replacingOccurrences(of: "public typealias __C_SNRequest = SNRequest", with: "")
            c = c.replacingOccurrences(of: "public typealias __C_SNResult = SNResult", with: "")
            c = c.replacingOccurrences(of: "public typealias __C_AVAudioSession = AVAudioSession", with: "")
            c = c.replacingOccurrences(of: "public typealias __C_AVAudioSession.CategoryOptions = AVAudioSession.CategoryOptions", with: "")
            c = c.replacingOccurrences(of: "@nonobjc public convenience init() { fatalError() }", with: "@nonobjc public override convenience init() { fatalError() }")
            c = c.replaceWord("SNRequest", with: "Any")
            c = c.replaceWord("SNResult", with: "Any")
            c = c.replaceWord("MLMultiArray", with: "Any")
            c = c.replaceWord("SHSignature", with: "Any")
            c = c.replacingOccurrences(of: "GenericA.Result", with: "Any")
            c = c.replacingOccurrences(of: "GenericA.Arg", with: "Any")
            c = c.replacingOccurrences(of: "public static func automaticallyNotifiesObservers(forKey:", with: "public override static func automaticallyNotifiesObservers(forKey:")
            c = c.replacingOccurrences(of: "public struct AnyPublisher<A, B>:", with: "public struct AnyPublisher<A, B: Swift.Error>:")
            c = c.replacingOccurrences(of: "public struct AnySubject<A, B>:", with: "public struct AnySubject<A, B: Swift.Error>:")
            c = c.replacingOccurrences(of: "public enum Completion<A>:", with: "public enum Completion<A: Swift.Error>:")
            c = c.replacingOccurrences(of: "public enum Completion<A: Swift.Error>: Codable, Hashable", with: "public enum Completion<A: Swift.Error>: Codable")
            c = c.replacingOccurrences(of: "extension PubSub.Completion where A: Equatable", with: "extension PubSub.Completion where A: Equatable")
            c = c.replacingOccurrences(of: "extension PubSub.Completion where A: Hashable", with: "extension PubSub.Completion where A: Hashable")
            c = c.replacingOccurrences(of: "public struct RawRepresentableWrapper<A>:", with: "public struct RawRepresentableWrapper<A: RawRepresentable>:")
            c = c.removeAnyConstraintsFromWhereClause()

            c += """


            open class AVAudioSession: NSObject {
                public struct Category: Hashable, RawRepresentable { public var rawValue: Swift.String; public init(rawValue: Swift.String) { self.rawValue = rawValue } }
                public struct Mode: Hashable, RawRepresentable { public var rawValue: Swift.String; public init(rawValue: Swift.String) { self.rawValue = rawValue } }
                public struct CategoryOptions: OptionSet, Sendable { public var rawValue: Swift.UInt; public init(rawValue: Swift.UInt) { self.rawValue = rawValue } }
            }
            """
        }

        // Fix: StoreKit `StoreProductManager` is declared as an actor but Swift 6 strict
        // concurrency emits a [#ConformanceIsolation] error for explicit Actor conformance.
        // Convert it to a final class with @unchecked Sendable for compilation purposes.
        if parser.defaultModule == "StoreKit" {
            c = c.replacingOccurrences(of: "public actor StoreProductManager",
                                        with: "public final class StoreProductManager: @unchecked Sendable")
        }

        if parser.defaultModule == "Vision" {
            // Fix: VisionRequest declares `associatedtype Result` with no ABI-visible default
            // and no per-conformer typealias anywhere (satisfied only via the generic
            // `perform<each GenericA>` methods on VisionRequestHandler, never a per-conformer
            // ABI witness) — ~50 structs conform to VisionRequest, so give the protocol itself
            // a default associated-type value (Swift resolves an unconstrained associatedtype
            // to its default when no conformer supplies one) instead of patching every
            // conformer individually.
            if let declRange = c.range(of: "public protocol VisionRequest: CustomStringConvertible, Hashable {"),
               let braceEnd = c.range(of: "\n}", range: declRange.upperBound..<c.endIndex) {
                let bodyRange = declRange.upperBound..<braceEnd.lowerBound
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(of: "associatedtype Result", with: "associatedtype Result = Never")
                c.replaceSubrange(bodyRange, with: body)
            }
            // Fix: not every VisionRequest conformer implements
            // `supportedComputeStageDevices: [ComputeStage : [MLComputeDevice]]` (e.g.
            // TrackRectangleRequest has no ABI witness for it at all) — unlike
            // computeDevice(for:)/requireInProcessExecution, which the generator already found
            // a default `extension VisionRequest { ... }` implementation for, this one has no
            // default anywhere either. Add one so non-implementing conformers still compile.
            if let declRange = c.range(of: "extension VisionRequest {"),
               let braceEnd = c.range(of: "\n}", range: declRange.upperBound..<c.endIndex) {
                c.insert(contentsOf: "\n    public var supportedComputeStageDevices: [ComputeStage : [CoreML.MLComputeDevice]] { get { [:] } }", at: braceEnd.lowerBound)
            }

            // Fix: Attribute<A>'s allLabelsAndConfidences is [A : Float] (A used as a Dictionary
            // key), but A has no Hashable constraint on the struct's own declaration.
            c = c.replacingOccurrences(
                of: "public struct Attribute<A>: Codable, CustomStringConvertible, Hashable {",
                with: "public struct Attribute<A: Hashable>: Codable, CustomStringConvertible, Hashable {")

            // Fix: PoseProviding.PoseJointName is used as a Dictionary key
            // ([Self.PoseJointName : Joint]) but only declared `: Decodable` — the real ABI
            // shows PoseJointName: Hashable too (found via the P0B9JointNameAC_SH conformance
            // requirement symbol), just not resolved by the demangler-driven associated-type
            // extraction here.
            c = c.replacingOccurrences(
                of: "associatedtype PoseJointName: Decodable",
                with: "associatedtype PoseJointName: Decodable, Hashable")
        }

        if parser.defaultModule == "HealthKit" {
            // Fix: the demangler renders a metatype-of-composition ("(NSObject &
            // HKDataCacheProviding).Type") as "NSObject & HKDataCacheProviding.Type", which
            // parses as "NSObject & (HKDataCacheProviding.Type)" — invalid, since a protocol
            // composition member can't itself be a metatype. Add the missing parens.
            c = c.replacingOccurrences(
                of: "NSObject & HKDataCacheProviding.Type",
                with: "(NSObject & HKDataCacheProviding).Type")

            // Fix: BirthDateType/CategoryType/QuantityType/ScoredAssessmentType<A> conform to
            // SampleType (-> BasicObservableHealthType -> ObservableHealthType, ListHealthType),
            // whose observe(configuration:)/query(configuration:) requirements need
            // ObservationConfigurationKind/ListConfigurationKind: Decodable, and (per SampleType's
            // own associated-conformance requirement) ListConfigurationKind: Configuration.SampleBase
            // specifically. The demangler has no per-type ABI witness for what these associated
            // types actually resolve to (query/observe are satisfied via a default protocol-
            // extension implementation, not a per-conformance witness), so Model.swift emits the
            // bare placeholder `Any` for both — which isn't Decodable, so the compiler can't infer
            // the associated types and conformance fails. Retype to the concrete
            // SampleBaseConfiguration<Self>, the one real type in this module that conforms to
            // Configuration.SampleBase. Scoped per-struct (via struct-declaration boundaries)
            // since the placeholder text is identical across all four conforming structs.
            for (declPrefix, selfType) in [
                ("public struct BirthDateType:", "BirthDateType"),
                ("public struct CategoryType:", "CategoryType"),
                ("public struct QuantityType:", "QuantityType"),
                ("public struct ScoredAssessmentType<A>:", "ScoredAssessmentType<A>"),
            ] {
                guard let declRange = c.range(of: declPrefix) else { continue }
                guard let braceStart = c.range(of: "{", range: declRange.upperBound..<c.endIndex) else { continue }
                var depth = 1
                var idx = braceStart.upperBound
                var braceEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { braceEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                let bodyRange = braceStart.upperBound..<braceEnd
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(
                    of: "public func observe(configuration: Any) -> ObservationDescriptor<Any> { fatalError() }",
                    with: "public func observe(configuration: SampleBaseConfiguration<\(selfType)>) -> ObservationDescriptor<SampleBaseConfiguration<\(selfType)>> { fatalError() }\n    public typealias ObservationConfigurationKind = SampleBaseConfiguration<\(selfType)>")
                body = body.replacingOccurrences(
                    of: "public func query(configuration: Any) -> ListQueryDescriptor<Any, Any> { fatalError() }",
                    with: "public func query(configuration: SampleBaseConfiguration<\(selfType)>) -> ListQueryDescriptor<SampleBaseConfiguration<\(selfType)>, \(selfType)> { fatalError() }\n    public typealias ListConfigurationKind = SampleBaseConfiguration<\(selfType)>\n    public typealias ModelKind = \(selfType)")
                c.replaceSubrange(bodyRange, with: body)
            }

            // Fix: Configuration.WithPredicate.filter/Configuration.SampleBase's predicate and
            // sortDescriptors properties demangle with the bare placeholder "Any" instead of
            // "Self.PredicatedModelKind" (WithPredicate's own associated type) — unlike
            // Configuration.WithSortDescriptor's `sort(_:) -> SortDescriptor<Self.SortedModelKind>`,
            // which the generator DOES resolve correctly. Concrete conformers like
            // SampleBaseConfiguration<A> declare predicate/sortDescriptors typed by their own
            // generic parameter A, not Any, so the "Any" in the protocol requirement never
            // matches and PredicatedModelKind/SampleKind can't be inferred.
            if let declRange = c.range(of: "public protocol WithPredicate: Sendable {"),
               let braceEnd = c.range(of: "\n    }", range: declRange.upperBound..<c.endIndex) {
                let bodyRange = declRange.upperBound..<braceEnd.lowerBound
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(of: "func filter(_ arg1: Predicate<Any>) -> Self", with: "func filter(_ arg1: Predicate<Self.PredicatedModelKind>) -> Self")
                c.replaceSubrange(bodyRange, with: body)
            }
            // Member order inside the generated protocol body isn't stable across runs (varies
            // by internal dictionary iteration order), so patch each member line independently,
            // scoped to inside SampleBase's own declaration body rather than matching the whole
            // block verbatim.
            if let declRange = c.range(of: "public protocol SampleBase: Configuration.WithLimit, Configuration.WithPredicate, Configuration.WithSortDescriptor, Sendable {"),
               let braceEnd = c.range(of: "\n    }", range: declRange.upperBound..<c.endIndex) {
                let bodyRange = declRange.upperBound..<braceEnd.lowerBound
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(of: "var predicate: Predicate<Any>? { get }", with: "var predicate: Predicate<Self.PredicatedModelKind>? { get }")
                body = body.replacingOccurrences(of: "var sortDescriptors: [SortDescriptor<Any>] { get }", with: "var sortDescriptors: [SortDescriptor<Self.SortedModelKind>] { get }")
                c.replaceSubrange(bodyRange, with: body)
            }
            // Fix: ListQueryDescriptor<A, B>/ObservationDescriptor<A> conform to QueryDescriptor,
            // which requires `associatedtype ConfigurationKind: Decodable` satisfied via their
            // own `configuration: A`/`B` property — but the demangler exposes no generic-constraint
            // info for these structs' own declaration (no swiftinterface/header covers this
            // private SPI type), so A/B come through unconstrained and can't satisfy
            // ConfigurationKind: Decodable. Every real construction path for both types is only
            // ever reachable through ListHealthType/ObservableHealthType, whose own
            // ListConfigurationKind/ObservationConfigurationKind associated types ARE constrained
            // to Decodable — so constraining A (and ListQueryDescriptor's A specifically, the
            // configuration type) to Decodable here reflects the real usage without narrowing it
            // incorrectly.
            // QueryDescriptor also requires `associatedtype ModelKind` (unconstrained, no
            // Decodable bound) — ListQueryDescriptor's second generic param B fills that role
            // (matches ListHealthType.query's real return type
            // ListQueryDescriptor<Self.ListConfigurationKind, Self.ModelKind>); ObservationDescriptor
            // has no second param for it at all (ObservableHealthType.observe() never threads a
            // ModelKind through), so pin it to Never — an uninhabited type is a safe placeholder
            // since ObservationDescriptor's real construction path never produces a ModelKind value.
            // Fix: the SleepSessionResultProviding/SleepSessionComparisonProviding/
            // SleepSessionQueryProviding family requires RangeType/ConfigurationType/
            // ComparisonType/ResultType associated types, none of which have a discoverable
            // real-type mapping in the ABI (query/observe-style requirements satisfied via
            // default protocol-extension implementations, not per-conformance witnesses — same
            // root cause as the QueryDescriptor gaps above). Each conformer DOES have a real
            // nested `QueryConfiguration` struct that already conforms to
            // SleepSessionConfigurationProviding (found via the ABI's own protocol conformance
            // descriptors), so ConfigurationType is real; ComparisonType/ResultType map onto
            // the sibling Comparison/base types in the same family, which also have discoverable
            // real conformances. RangeType alone has no real conforming type anywhere in the ABI
            // (nothing implements SleepSessionRangeProviding's `split(_:) -> [Self]`) — use one
            // shared synthetic stub for it everywhere.
            c += "\npublic struct SleepSessionRangeStub: SleepSessionRangeProviding, Codable, Hashable, @unchecked Sendable {\n"
            c += "    public func split(_ arg1: Swift.Int) -> [SleepSessionRangeStub] { fatalError() }\n"
            c += "    public init(from decoder: Swift.Decoder) throws { fatalError() }\n"
            c += "    public func encode(to encoder: Swift.Encoder) throws {}\n"
            c += "}\n"
            for (declPrefix, typealiases) in [
                ("public struct SleepDaySummary:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryComparison"]),
                ("public struct SleepDaySummaryCollection:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryCollectionComparison"]),
                ("public struct SleepDaySummaryComparison:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryComparison", "ResultType = SleepDaySummary"]),
                ("public struct SleepDaySummaryCollectionComparison:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryCollectionComparison", "ResultType = SleepDaySummaryCollection"]),
                ("public struct SleepSession:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepSessionComparison"]),
                ("public struct SleepSessionComparison:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepSessionComparison", "ResultType = SleepSession"]),
            ] {
                guard let declRange = c.range(of: declPrefix) else { continue }
                guard let braceStart = c.range(of: "{", range: declRange.upperBound..<c.endIndex) else { continue }
                let insertion = typealiases.map { "    public typealias \($0)\n" }.joined()
                c.insert(contentsOf: "\n" + insertion, at: braceStart.upperBound)
            }
            // Fix: SleepSessionQuery<A> conforms to SleepSessionQueryProviding, whose
            // `associatedtype ResultType: SleepSessionResultProviding` is satisfied by A itself
            // (SleepSessionQuery's own resultsHandler produces [A] and its extension method
            // `SleepSessionResultProviding.makeSessionQueryDescriptor` returns
            // SleepSessionQuery<Self>.Descriptor<Self> — a generic Descriptor<A>, not the
            // non-generic struct the generator emitted since the demangler exposes no
            // per-instantiation ABI witness for a private, purely-generic-internal nested type).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class SleepSessionQuery<A>: SleepSessionQueryProviding {",
                with: "@_fixed_layout public class SleepSessionQuery<A: SleepSessionResultProviding>: SleepSessionQueryProviding {\n    public typealias ResultType = A")
            c = c.replacingOccurrences(
                of: "public struct Descriptor: Codable, Hashable, @unchecked Sendable {",
                with: "public struct Descriptor<B>: Codable, Hashable, @unchecked Sendable {")

            // SleepMetrics/SleepMetrics.Averages/SleepDaySummary.Metrics conform to SleepAverageProviding,
            // whose countProvider/durationProvider requirements resolve to bare `some Sendable` —
            // retype to the real sibling nested types (SleepMetrics.Counts/SleepMetrics.Durations)
            // that actually conform to SleepCountProviding/SleepDurationProviding.
            c = c.replacingOccurrences(
                of: "public var countProvider: some Sendable",
                with: "public var countProvider: SleepMetrics.Counts"
            )
            c = c.replacingOccurrences(
                of: "public var durationProvider: some Sendable",
                with: "public var durationProvider: SleepMetrics.Durations"
            )

            // Fix: QueryDescriptor extensions demangle constraints with redundant protocol wrapper paths like
            // `Self.ConfigurationKind.Configuration.WithPredicate.PredicatedModelKind` instead of
            // `Self.ConfigurationKind.PredicatedModelKind`.
            c = c.replacingOccurrences(
                of: "Configuration.WithPredicate.PredicatedModelKind",
                with: "PredicatedModelKind"
            )
            c = c.replacingOccurrences(
                of: "Configuration.WithSortDescriptor.SortedModelKind",
                with: "SortedModelKind"
            )

            // Fix: SleepClassification has an associated-value case (`indirect case
            // asleep(_: SleepClassification.Stage?)`), so Swift can't auto-synthesize
            // CaseIterable.allCases the way it does for a plain no-payload enum — Model.swift
            // unconditionally skips emitting `allCases` for every enum on the assumption
            // auto-synthesis covers it (true for every OTHER enum in this framework), so this
            // one real ABI member (`static HealthKit.SleepClassification.allCases.getter`) never
            // gets emitted. Add it back as an explicit stub.
            c = c.replacingOccurrences(
                of: "public enum SleepClassification: CaseIterable, Codable, Hashable {",
                with: "public enum SleepClassification: CaseIterable, Codable, Hashable {\n    public static var allCases: [SleepClassification] { fatalError() }")

            // Fix: HKCurrentActivityCacheQueryDescriptor.results(for:) conforms to
            // HKAsyncSequenceQuery, which requires `associatedtype Sequence: AsyncSequence` — the
            // demangler resolves the opaque return type to bare `some Sendable` (same gap as
            // Speech's `results: some Sendable` needing `some Sendable & AsyncSequence`, fixed
            // there via Model.swift retyping). Retype in place and return a concrete
            // AsyncStream value so the opaque type has a real underlying AsyncSequence.
            c = c.replacingOccurrences(
                of: "public func results(for: HKHealthStore) -> some Sendable { fatalError() }",
                with: "public func results(for: HKHealthStore) -> some Sendable & AsyncSequence { AsyncStream<HKCurrentActivityCacheQueryResult> { _ in } }")

            // CodableBoxDictionary<A, B> conforms to DefaultEncodable, whose `associatedtype T`
            // requirement is satisfied by its own `wrappedValue: [A : B]` — but the compiler
            // can't infer T from a property alone without an explicit typealias.
            c = c.replacingOccurrences(
                of: "public struct CodableBoxDictionary<A, B>: Codable, DefaultEncodable {",
                with: "public struct CodableBoxDictionary<A: Hashable, B>: Codable, DefaultEncodable {\n    public typealias T = [A: B]")
            c = c.replacingOccurrences(
                of: "public struct ListQueryDescriptor<A, B>: ListQueryDescriptorProtocol, QueryDescriptor {",
                with: "public struct ListQueryDescriptor<A: Decodable, B>: ListQueryDescriptorProtocol, QueryDescriptor {\n    public typealias ModelKind = B")
            c = c.replacingOccurrences(
                of: "public struct ObservationDescriptor<A>: ObservationQueryDescriptorProtocol, QueryDescriptor {",
                with: "public struct ObservationDescriptor<A: Decodable>: ObservationQueryDescriptorProtocol, QueryDescriptor {\n    public typealias ModelKind = Never")

            // SampleBaseConfiguration<A>'s own predicate-typed init parameter, predicate
            // property, and filter method also demangle with bare "Any" instead of "A" — same
            // root cause as above, just on the concrete conformer instead of the protocol
            // requirement. Scoped to inside the struct's own body (not a plain global replace)
            // since "Predicate<Any>? { get { return nil } }" also appears verbatim in the
            // unrelated Configuration.SampleSubtype extension, where "A" isn't in scope.
            if let declRange = c.range(of: "public struct SampleBaseConfiguration<A>:"),
               let braceStart = c.range(of: "{", range: declRange.upperBound..<c.endIndex) {
                var depth = 1
                var idx = braceStart.upperBound
                var braceEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { braceEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                let bodyRange = braceStart.upperBound..<braceEnd
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(
                    of: "public init(predicate: Predicate<Any>?, sortDescriptors: [SortDescriptor<A>], limit: Swift.Int?) { fatalError() }",
                    with: "public init(predicate: Predicate<A>?, sortDescriptors: [SortDescriptor<A>], limit: Swift.Int?) { fatalError() }")
                body = body.replacingOccurrences(
                    of: "public func filter(_ arg1: Predicate<Any>) -> SampleBaseConfiguration<A> { fatalError() }",
                    with: "public func filter(_ arg1: Predicate<A>) -> SampleBaseConfiguration<A> { fatalError() }")
                body = body.replacingOccurrences(
                    of: "public var predicate: Predicate<Any>? { get { return nil } }",
                    with: "public var predicate: Predicate<A>? { get { return nil } }")
                c.replaceSubrange(bodyRange, with: body)
            }
            // SampleBaseConfiguration<A>'s own predicate/sortDescriptors/filter are typed by A
            // directly (not Any), so pin its PredicatedModelKind/SortedModelKind/SampleKind to A
            // explicitly — the compiler can't otherwise unify a bare A-typed member against a
            // Self.PredicatedModelKind-typed requirement without a concrete typealias.
            c = c.replacingOccurrences(
                of: "public struct SampleBaseConfiguration<A>: Codable, Configuration.Constructible, Configuration.SampleBase, Configuration.WithLimit, Configuration.WithPredicate, Configuration.WithSortDescriptor {",
                with: "public struct SampleBaseConfiguration<A>: Codable, Configuration.Constructible, Configuration.SampleBase, Configuration.WithLimit, Configuration.WithPredicate, Configuration.WithSortDescriptor {\n    public typealias PredicatedModelKind = A\n    public typealias SortedModelKind = A\n    public typealias SampleKind = A")
        }

        // Fix: AttributeScopes.ConfidenceAttribute/TimeRangeAttribute conform to
        // AttributedStringKey (`associatedtype Value: Hashable`), which resolves to Double/
        // CMTimeRange respectively in the real module — never visible from the ABI since these
        // are plain typealiases with no symbol of their own.
        if parser.defaultModule == "Speech" {
            c = c.replacingOccurrences(
                of: "public struct ConfidenceAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {",
                with: "public struct ConfidenceAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {\n        public typealias Value = Double")
            c = c.replacingOccurrences(
                of: "public struct TimeRangeAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {",
                with: "public struct TimeRangeAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {\n        public typealias Value = CMTimeRange")
            // Fix: SpeechModule requires `associatedtype Result: SpeechModuleResult` and
            // `associatedtype Results: AsyncSequence` plus `var results: Self.Results { get }`.
            // Concrete classes expose a nested SpeechModuleResult type (Result or ModuleOutput)
            // and a `results` property typed as `some Sendable & AsyncSequence`. This opaque type
            // does NOT satisfy `var results: Self.Results` because the compiler can't verify
            // `some Sendable & AsyncSequence == AsyncStream<Result>`.
            //
            // Fix strategy:
            //   1. For EndpointDetector (uses ModuleOutput not Result):
            //      inject `typealias Result = ModuleOutput` + `typealias Results = AsyncStream<ModuleOutput>`
            //      before `struct ModuleOutput`.
            //   2. For all other classes (struct Result):
            //      inject `typealias Results = AsyncStream<Result>` before `struct Result`.
            //   3. Change every `results: some Sendable & AsyncSequence { get { return AsyncStream<Never> { _ in } } }`
            //      to `results: Results { get { fatalError() } }` so the property type matches.
            //
            // EndpointDetector: anchor on `struct ModuleOutput`
            c = c.replacingOccurrences(
                of: "    public struct ModuleOutput: CustomStringConvertible, SpeechModuleResult {",
                with: "    public typealias Result = ModuleOutput\n    public typealias Results = AsyncStream<ModuleOutput>\n    public struct ModuleOutput: CustomStringConvertible, SpeechModuleResult {")
            // All other SpeechModule classes: anchor on `struct Result: ... SpeechModuleResult`
            c = c.replacingOccurrences(
                of: "    public struct Result: CustomStringConvertible, SpeechModuleResult",
                with: "    public typealias Results = AsyncStream<Result>\n    public struct Result: CustomStringConvertible, SpeechModuleResult")
            // SpeechDetector has `struct Result: CustomStringConvertible, Hashable, SpeechModuleResult`
            // which is already covered by the Hashable variant below. Handle both variants:
            c = c.replacingOccurrences(
                of: "    public struct Result: CustomStringConvertible, Hashable, SpeechModuleResult",
                with: "    public typealias Results = AsyncStream<Result>\n    public struct Result: CustomStringConvertible, Hashable, SpeechModuleResult")
            // Change `results: some Sendable & AsyncSequence { get { return AsyncStream<Never> { _ in } } }`
            // to `results: Results { get { fatalError() } }` so the type matches `Self.Results`.
            c = c.replacingOccurrences(
                of: "    public final var results: some Sendable & AsyncSequence { get { return AsyncStream<Never> { _ in } } }",
                with: "    public final var results: Results { get { fatalError() } }")
        }

        // Fix: Charts's ChartContent requires `associatedtype Body: ChartContent`. Mark types
        // (AreaMark/LineMark/PointMark/etc.) render entirely through the static
        // _makeChartContent/_layoutChartContent/_renderChartContent hooks and never expose a
        // concrete Body type via the ABI, so their `body` property is retyped to `Swift.Never`
        // above (see the "n == \"body\"" property-emission fixup in Model.swift) — but `Never`
        // only conforms to ChartContent via a real-module extension we never discover from the
        // ABI (Charts.tbd has no symbols for it since it's implemented entirely via default
        // protocol-extension witnesses). Add it explicitly.
        if parser.defaultModule == "Charts" {
            c += """


            extension Swift.Never: ChartContent {
                public var body: Never { fatalError() }
                public static func _layoutChartContent(_ content: Never, _ inputs: _ChartContentLayoutInputs) {}
                public static func _renderChartContent(_ content: Never, _ inputs: _ChartContentRenderInputs) -> _ChartContentRenderOutputs { fatalError() }
                public static func _collectChartContent(content: Never, inputs: _ChartContentCollectInputs) -> _ChartContentCollectOutputs { fatalError() }
                public static func _chartContentCount(inputs: _ChartContentInputs) -> Int? { return nil }
                public static func _makeChartContent(content: SwiftUI._GraphValue<Never>, inputs: _ChartContentInputs) -> _ChartContentOutputs { fatalError() }
            }
            extension Swift.Never: Chart3DContent {
                public static func _makeChart3DContent(content: SwiftUI._GraphValue<Never>, inputs: _Chart3DContentInputs) -> _Chart3DContentOutputs { fatalError() }
            }

            """
            // AnyChartSymbolShape/BasicChartSymbolShape conform to ChartSymbolShape (which
            // requires SwiftUI.Shape's nonisolated `path(in:)`). Our synthesized init/path
            // witnesses default to the enclosing (main-actor-inferred) isolation, which the
            // compiler rejects as a data-race-unsafe conformance; the real module marks them
            // `nonisolated` explicitly.
            c = c.replacingOccurrences(
                of: "public init(_ arg1: any ChartSymbolShape) { fatalError() }",
                with: "nonisolated public init(_ arg1: any ChartSymbolShape) { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func path(in: CGRect) -> SwiftUI.Path { fatalError() }",
                with: "nonisolated public func path(in: CGRect) -> SwiftUI.Path { fatalError() }")
            c = c.replacingOccurrences(
                of: "public var perceptualUnitRect: CGRect { get { fatalError() } }",
                with: "nonisolated public var perceptualUnitRect: CGRect { get { fatalError() } }")
            // SPAngle (Chart3DPose.azimuth/inclination) is a private C type with no public
            // Swift declaration anywhere (not even bridged via __C. — the demangler resolves it
            // to a bare capitalized name that looks like a real bridged ObjC type, but it isn't
            // one). Stub it out.
            c += "\npublic struct SPAngle: Hashable, Sendable {}\n"
            // AnyChartContent's `_makeChartContent`/`body` witnesses are satisfied via a
            // "protocol witness for ..." ABI thunk, but ChartContent's own default-extension
            // implementation for them is never emitted by this generator (protocol-extension
            // defaults aren't reproduced, only concrete-type extensions), so AnyChartContent
            // itself needs the members explicitly.
            c = c.replacingOccurrences(
                of: "public struct AnyChartContent: ChartContent {",
                with: "public struct AnyChartContent: ChartContent {\n    public var body: Never { fatalError() }\n    public static func _makeChartContent(content: SwiftUI._GraphValue<AnyChartContent>, inputs: _ChartContentInputs) -> _ChartContentOutputs { fatalError() }")
            // The real module declares `extension Optional: ChartContent/AxisMark/
            // Chart3DContent/ContourContent where Wrapped: <same protocol>` so that optional
            // chart content (`if let ... { SomeMark(...) }`) participates directly in the
            // result-builder chain. These conditional extensions have real exported ABI symbols
            // (required by the .tbd's exports list) but the extension declarations themselves
            // are never discovered/emitted since our generator doesn't parse stdlib-type
            // conditional-conformance extensions from demangled symbols.
            c += """

            extension Swift.Optional: ChartContent where Wrapped: ChartContent {
                public var body: Never { fatalError() }
                public static func _layoutChartContent(_ content: Wrapped?, _ inputs: _ChartContentLayoutInputs) {}
                public static func _renderChartContent(_ content: Wrapped?, _ inputs: _ChartContentRenderInputs) -> _ChartContentRenderOutputs { fatalError() }
                public static func _collectChartContent(content: Wrapped?, inputs: _ChartContentCollectInputs) -> _ChartContentCollectOutputs { fatalError() }
                public static func _makeChartContent(content: SwiftUI._GraphValue<Wrapped?>, inputs: _ChartContentInputs) -> _ChartContentOutputs { fatalError() }
                public static func _chartContentCount(inputs: _ChartContentInputs) -> Int? { return nil }
            }
            extension Swift.Optional: Chart3DContent where Wrapped: Chart3DContent {
                public var body: Never { fatalError() }
                public static func _makeChart3DContent(content: SwiftUI._GraphValue<Wrapped?>, inputs: _Chart3DContentInputs) -> _Chart3DContentOutputs { fatalError() }
            }
            extension Swift.Optional: AxisMark where Wrapped: AxisMark {
                public static func _layoutAxisMark(_ content: Wrapped?, _ inputs: _AxisMarkLayoutInputs) {}
                public static func _renderAxisMark(_ content: Wrapped?, _ inputs: _AxisMarkRenderInputs) -> _AxisMarkRenderOutputs { fatalError() }
                public static func _collectAxisMark(_ content: Wrapped?, _ inputs: _AxisMarkCollectInputs) -> _AxisMarkCollectOutputs { fatalError() }
            }
            extension Swift.Optional: ContourContent where Wrapped: ContourContent {
                public static func _makeContourContent(_ content: Wrapped?, _ inputs: _ContourContentInputs) -> _ContourContentOutputs { fatalError() }
            }

            """
            // The Vectorized*PlotContent<Data> family (Area/Bar/Line/Point/Rectangle/Rule/
            // Sector) all conform to VectorizedChartContent, which requires `associatedtype
            // DataElement`; the real module resolves it to `Data.Element` (also requiring
            // `Data: RandomAccessCollection`) — neither is visible from the ABI alone.
            for plotKind in ["Area", "Bar", "Line", "Point", "Rectangle", "Rule", "Sector"] {
                c = c.replacingOccurrences(
                    of: "public struct Vectorized\(plotKind)PlotContent<A>: ChartContent, VectorizedChartContent {",
                    with: "public struct Vectorized\(plotKind)PlotContent<A>: ChartContent, VectorizedChartContent where A: RandomAccessCollection {\n    public typealias DataElement = A.Element")
            }
            // ChartBinRange<Bound> requires `Bound: Comparable` (RangeExpression's own
            // associatedtype bound) — not visible from the ABI alone.
            c = c.replacingOccurrences(
                of: "public struct ChartBinRange<A>: RangeExpression {",
                with: "public struct ChartBinRange<A>: RangeExpression where A: Comparable {")
            // NumberBins<Value>'s own generic parameter feeds ChartBinRange<Value>'s subscript,
            // so it needs the same Comparable bound (the real module also requires Numeric).
            c = c.replacingOccurrences(
                of: "public struct NumberBins<A>: Collection, Equatable, Sequence {",
                with: "public struct NumberBins<A>: Collection, Equatable, Sequence where A: Comparable, A: Numeric {")
            // BuilderTuple<A> is really a parameter-pack type (`struct BuilderTuple<each T>` in
            // the real, internal-only module) — its own generic parameter needs the `each`
            // marker to match the `(repeat A)` tuple type used in its members.
            c = c.replacingOccurrences(
                of: "public struct BuilderTuple<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct BuilderTuple<each A>: Sendable {")
            c = c.replacingOccurrences(
                of: "public init(elements: (repeat A)) { fatalError() }\n    public var elements: (repeat A) { get { fatalError() } set {} }\n    public init(from decoder: any Swift.Decoder) throws { fatalError() }\n    public func encode(to encoder: Swift.Encoder) throws { fatalError() }\n    public func hash(into hasher: inout Hasher) { fatalError() }\n    public static func ==(_ lhs: BuilderTuple<A>, _ rhs: BuilderTuple<A>) -> Bool { fatalError() }",
                with: "public init(elements: (repeat each A)) { fatalError() }\n    public var elements: (repeat each A) { get { fatalError() } }")
            // Chart<Content>.init(_:content:)'s real constraint is
            // `Content == ForEach<Data, Data.Element.ID, C>` (an associated-type chain through
            // Data.Element's Identifiable conformance), which the generic-placeholder-path
            // eraser can't resolve and erases to a self-contradictory bare `Any`.
            c = c.replacingOccurrences(
                of: "where A == SwiftUI.ForEach<A1, Any, B1>, A1: RandomAccessCollection, B1: ChartContent, A1.Element: Identifiable",
                with: "where A == SwiftUI.ForEach<A1, A1.Element.ID, B1>, A1: RandomAccessCollection, B1: ChartContent, A1.Element: Identifiable")
            c = c.replacingOccurrences(
                of: "where A == SwiftUI.ForEach<A1, Any, B1>, A1: RandomAccessCollection, B1: Chart3DContent, A1.Element: Identifiable",
                with: "where A == SwiftUI.ForEach<A1, A1.Element.ID, B1>, A1: RandomAccessCollection, B1: Chart3DContent, A1.Element: Identifiable")
            // ValueAlignedChartScrollTargetBehavior conforms to ChartScrollTargetBehavior, which
            // itself extends SwiftUI.ScrollTargetBehavior — the redundant explicit
            // `SwiftUI.ScrollTargetBehavior` conformance forces its `updateTarget(context:)`
            // requirement (typed with SwiftUI's own ScrollTargetBehaviorContext) to apply
            // directly instead of through ChartScrollTargetBehavior's default implementation,
            // conflicting with the witness typed for ChartScrollTargetBehavior's own
            // ChartScrollTargetBehaviorContext requirement.
            c = c.replacingOccurrences(
                of: "public struct ValueAlignedChartScrollTargetBehavior: ChartScrollTargetBehavior, SwiftUI.ScrollTargetBehavior {",
                with: "public struct ValueAlignedChartScrollTargetBehavior: ChartScrollTargetBehavior {")
            // ChartScrollTargetBehavior : SwiftUI.ScrollTargetBehavior requires
            // `updateTarget(context: Self.TargetContext)`; ValueAlignedChartScrollTargetBehavior
            // only implements the Charts-specific ChartScrollTargetBehaviorContext overload — the
            // real module also provides a ScrollTargetBehaviorContext overload via
            // ChartScrollTargetBehavior's own default extension (never emitted since we don't
            // generate protocol-extension defaults), which is what actually satisfies
            // SwiftUI.ScrollTargetBehavior's requirement. Add it directly.
            c = c.replacingOccurrences(
                of: "public func updateTarget(_: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n}",
                with: "public func updateTarget(_: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n    public func updateTarget(_ target: inout SwiftUI.ScrollTarget, context: SwiftUI.ScrollTargetBehaviorContext) -> () {}\n}")
        }

        // Fix: Network framework has many internal protocol conformances (NetworkProtocolOptions,
        // BottomProtocolHandler, LowerProtocolHandler, OutboundDatagramHandler, etc.) that require
        // associated types our stubs cannot satisfy. Strip these conformances from inheritance lists.
        // Also strip `where Self: ~Copyable` protocol extension constraints which are invalid
        // in Swift 6 standard compilation (Copyable is the default).
        if parser.defaultModule == "Network" {
            let networkConformancesToStrip: Set<String> = [
                "NetworkProtocolOptions", "BottomProtocolHandler", "LowerProtocolHandler",
                "OutboundDatagramHandler", "OutboundStreamHandler",
            ]
            // Process line by line: for type declaration lines (struct/class/protocol/enum/actor),
            // strip only the problematic conformances from the inheritance list (after the colon).
            let networkLines = c.components(separatedBy: "\n")
            var networkFixed = [String]()
            // Group 4 must swallow everything to end-of-line after the opening "{" (e.g. a
            // trailing "}" closing a same-line empty body like "... Sendable {}") — matching
            // only " {" and discarding the rest silently truncated single-line declarations,
            // leaving their closing brace missing (manifested as cascading "expected '}' in
            // struct" errors for the __C_* stub structs, which are emitted as one-liners).
            // The modifier prefix allows any order/combination of @_fixed_layout/public/open/
            // final (nested classes like "@_fixed_layout final public class BridgeInstance"
            // put final before public) — a fixed-order alternation missed those lines entirely,
            // leaving their BottomProtocolHandler/LowerProtocolHandler/etc. conformances
            // unstripped (manifested as "does not conform to protocol" errors).
            let typeHeaderRegex = try? NSRegularExpression(
                pattern: "^(\\s*(?:@_fixed_layout\\s+|public\\s+|open\\s+|final\\s+)+(?:struct|class|protocol|enum|actor|extension)\\s+\\S+)(:)(.*?)( \\{.*|$)", options: [])
            for line in networkLines {
                var fixedLine = line
                if let regex = typeHeaderRegex,
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                    // Extract the part before the colon, the inheritance list, and the trailing brace
                    if let prefixRange = Range(match.range(at: 1), in: line),
                       let colonRange = Range(match.range(at: 2), in: line),
                       let listRange = Range(match.range(at: 3), in: line),
                       let suffixRange = Range(match.range(at: 4), in: line) {
                        let prefix = String(line[prefixRange])
                        let list = String(line[listRange])
                        let suffix = String(line[suffixRange])
                        // Parse the conformance list and remove the problematic ones
                        var conformances = list.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        conformances.removeAll { networkConformancesToStrip.contains($0) }
                        if conformances.isEmpty {
                            fixedLine = prefix + suffix
                        } else {
                            fixedLine = prefix + ": " + conformances.joined(separator: ", ") + suffix
                        }
                        _ = colonRange // suppress warning
                    }
                }
                networkFixed.append(fixedLine)
            }
            c = networkFixed.joined(separator: "\n")
            // Strip `where Self: ~Copyable` extensions (not valid in standard Swift 6 mode).
            // The extension body contains member declarations with their own "{}" (e.g. stub
            // function bodies), so a naive "[^}]*}" regex closes on the FIRST brace it finds —
            // typically a member's own empty body — truncating the match and leaving the rest
            // of the real extension body as orphaned top-level text (manifests as cascading
            // "extraneous '}' at top level" errors). Scan brace depth instead.
            if let headerRegex = try? NSRegularExpression(
                pattern: "extension\\s+\\S+\\s+where\\s+Self\\s*:\\s*~Copyable[^{]*\\{", options: []) {
                var searchStart = c.startIndex
                while let match = headerRegex.firstMatch(in: c, range: NSRange(searchStart..<c.endIndex, in: c)),
                      let matchRange = Range(match.range, in: c) {
                    var depth = 1
                    var idx = matchRange.upperBound
                    var braceEnd = idx
                    while idx < c.endIndex {
                        if c[idx] == "{" { depth += 1 }
                        else if c[idx] == "}" { depth -= 1; if depth == 0 { braceEnd = c.index(after: idx); break } }
                        idx = c.index(after: idx)
                    }
                    c.removeSubrange(matchRange.lowerBound..<braceEnd)
                    searchStart = matchRange.lowerBound
                }
            }
        }

        // Fix: MetricKit `AverageStatistics<A>` and `Histogram<A>` require `A: Unit`
        // (they wrap Measurement<A> which has that constraint). The generic structs are
        // emitted without the constraint because it's not visible from the TBD alone.
        if parser.defaultModule == "MetricKit" {
            // AverageStatistics<DimensionType> and Histogram<DimensionType> both require
            // DimensionType: Foundation.Dimension (all MetricKit unit types are Dimension subclasses).
            c = c.replacingOccurrences(of: "public struct AverageStatistics<A>:",
                                        with: "public struct AverageStatistics<A: Foundation.Dimension>:")
            c = c.replacingOccurrences(of: "public struct Histogram<A>:",
                                        with: "public struct Histogram<A: Foundation.Dimension>:")
            // SignalBars is a Dimension subclass — override the NSObject base class with Dimension.
            if let regex = try? NSRegularExpression(
                pattern: "(?:public |open |@_fixed_layout )*(?:class|open class) SignalBars:\\s*NSObject", options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "open class SignalBars: Foundation.Dimension")
            }
            // Foundation.Dimension already conforms to NSCoding, so remove the redundant
            // NSCoding conformance from SignalBars's inheritance list.
            c = c.replacingOccurrences(of: "open class SignalBars: Foundation.Dimension, NSCoding",
                                        with: "open class SignalBars: Foundation.Dimension")
            // After substituting Dimension as parent, encode(with:) is now an override of
            // Foundation.Dimension's NSCoding conformance — mark it accordingly.
            c = c.replacingOccurrences(of: "open func encode(with coder: NSCoder) {}",
                                        with: "open override func encode(with coder: NSCoder) {}")
            // required init?(coder:) must call super.init(coder:) since Foundation.Dimension
            // is the new base class and its designated initializers must be called.
            c = c.replacingOccurrences(of: "public required init?(coder: NSCoder) {}",
                                        with: "public required init?(coder: NSCoder) { super.init(coder: coder) }")
        }

        // Fix: SwiftData's DefaultHistoryDelete<A>/DefaultHistoryInsert<A>/DefaultHistoryUpdate<A>
        // conform to HistoryDelete/HistoryInsert/HistoryUpdate via their own generic parameter
        // (associatedtype Model: PersistentModel), matching the real module's
        // `where Model : PersistentModel` constraint. The ABI doesn't reveal this bound, so add
        // it explicitly and provide the associated-type alias the same way TipKit's RuleInput fix
        // does for Event<A>/Parameter<A>.
        if parser.defaultModule == "SwiftData" {
            for historyType in ["DefaultHistoryDelete", "DefaultHistoryInsert", "DefaultHistoryUpdate"] {
                let protoName = historyType.replacingOccurrences(of: "Default", with: "")
                c = c.replacingOccurrences(
                    of: "public struct \(historyType)<A>: \(protoName) {",
                    with: "public struct \(historyType)<A>: \(protoName) where A: PersistentModel {\n    public typealias Model = A")
            }
            // DataStoreConfiguration requires `associatedtype Store: DataStore where Self ==
            // Self.Store.Configuration`, and DataStore requires `where Self ==
            // Self.Configuration.Store` — a mutually-referential pair the compiler can only
            // resolve if both sides declare the typealias explicitly (DefaultStore's own
            // Configuration is inferred fine from its init(_:migrationPlan:) witness, but
            // ModelConfiguration.Store has no witness to infer from).
            c = c.replacingOccurrences(
                of: "public struct ModelConfiguration: CustomDebugStringConvertible, DataStoreConfiguration, Hashable, Identifiable {",
                with: "public struct ModelConfiguration: CustomDebugStringConvertible, DataStoreConfiguration, Hashable, Identifiable {\n    public typealias Store = DefaultStore")
            // ResultsSection<Element, SectionName> conforms to Identifiable via `id: SectionName`
            // (its own second generic parameter), not the AnyObject-only default `id:
            // ObjectIdentifier`. The generated `id` property already returns `B`; the missing
            // piece is telling the compiler ResultsSection.ID is B, not the ambiguous default.
            // Identifiable.ID requires Hashable, so B needs that bound too (the real module
            // constrains SectionName: Swift.Hashable).
            c = c.replacingOccurrences(
                of: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Identifiable, RandomAccessCollection, Sequence {",
                with: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Identifiable, RandomAccessCollection, Sequence where B: Hashable {\n    public typealias ID = B")
            c = c.replacingOccurrences(
                of: "public struct ResultsSectionCollection<A, B>: BidirectionalCollection, Collection, RandomAccessCollection, Sequence {",
                with: "public struct ResultsSectionCollection<A, B>: BidirectionalCollection, Collection, RandomAccessCollection, Sequence where B: Hashable {")
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class ResultsObserver<A, B>: CustomDebugStringConvertible, Observation.Observable {",
                with: "@_fixed_layout final public class ResultsObserver<A, B>: CustomDebugStringConvertible, Observation.Observable where B: Hashable {")
            // `_computeSections`'s real constraint is `A == B.Element` (A is B's element type),
            // but replaceGenericPlaceholderPathsWithAny (applied generically to all top-level
            // global function signatures) erases "B.Element" to "Any" since it can't distinguish
            // a meaningful associated-type reference on a generic parameter from an unresolvable
            // demangler placeholder path — producing the self-contradictory "A == Any, A:
            // PersistentModel". Restore the real constraint.
            c = c.replacingOccurrences(
                of: "where A: PersistentModel, A == Any, B: RandomAccessCollection, C: Hashable",
                with: "where A: PersistentModel, A == B.Element, B: RandomAccessCollection, C: Hashable")
            // DefaultSerialModelExecutor is non-final but must conform to Sendable (required by
            // SerialExecutor/Executor); the real class declares this via `@unchecked Sendable`.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class DefaultSerialModelExecutor: Executor, ModelExecutor, SerialExecutor, SerialModelExecutor {",
                with: "@_fixed_layout public class DefaultSerialModelExecutor: Executor, ModelExecutor, SerialExecutor, SerialModelExecutor, @unchecked Sendable {")
            // Schema.Index<T>'s nested `Types` enum is itself generic (`enum Types<P> where P:
            // PersistentModel`) in the real module, but our generic-discovery pass never sees a
            // usage that would mark it generic (it's only ever referenced as `Index<T>.Types<T>`,
            // matching the outer class's own parameter), so it's emitted as a plain non-generic
            // enum while still being *referenced* with a `<A1>` argument. Make the declaration
            // generic to match its use sites, using Index's own parameter name.
            c = c.replacingOccurrences(
                of: "public enum Types: Codable, Hashable, @unchecked Sendable {",
                with: "public enum Types<A1>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: Types, _ rhs: Types) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: Types<A1>, _ rhs: Types<A1>) -> Bool { fatalError() }")
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

        // Fix: `any Protocol<X == Y, ...>` — constrained existential with same-type constraints
        // inside `<>` is not valid Swift. Strip the `<...>` clause entirely since we can't express
        // the constraint without primary associated type syntax.
        // Pattern: `any Identifier<...==...>` where the <...> contains `==`.
        c = c.stripConstrainedExistentialGenerics()

        if parser.defaultModule == "SwiftData" {
            // `BackingData` isn't declared with a primary associated type (`protocol
            // BackingData<Model>`), so constrained-existential usages like `any
            // BackingData<Self.Model == A1>` (left behind above as just `any BackingData`,
            // since stripConstrainedExistentialGenerics drops the whole `<...>` clause) are
            // already fixed by that strip. What's left is that A1 no longer appears anywhere
            // in these two extension methods' signatures once the constraint is gone, which
            // the compiler rejects as an unused generic parameter — add a same-named phantom
            // parameter so A1 appears in the parameter list too.
            c = c.replacingOccurrences(
                of: "public func _generateCurrentClassBackingData<A1>() -> any BackingData where A1: PersistentModel { fatalError() }",
                with: "public func _generateCurrentClassBackingData<A1>(as type: A1.Type) -> any BackingData where A1: PersistentModel { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func _superClassBackingData<A1>(of: any PersistentModel.Type) -> any BackingData where A1: PersistentModel { fatalError() }",
                with: "public func _superClassBackingData<A1>(of: any PersistentModel.Type, as type: A1.Type) -> any BackingData where A1: PersistentModel { fatalError() }")
            // `init(backingData:)`/`persistentBackingData` reference `any BackingData<Self.Model
            // == A>` in the real module; here the generic-placeholder-path eraser reduces the
            // constraint to plain `<Any>` (no `==` survives, so stripConstrainedExistentialGenerics
            // above doesn't catch it) rather than dropping it — BackingData has no primary
            // associated type, so any `<...>` on it is invalid.
            c = c.replacingOccurrences(of: "any BackingData<Any>", with: "any BackingData")
            // DefaultStore's HistoryProviding.historyType witness returns
            // `DefaultHistoryTransaction.Type` (a concrete metatype), but the protocol
            // requirement is typed `Any` (another generic-placeholder-path erasure — the real
            // requirement is `Self.HistoryType.Type`). A concrete-type witness can't satisfy a
            // requirement declared as bare `Any`; restore the associated-type-metatype form.
            c = c.replacingOccurrences(
                of: "static var historyType: Any { get }",
                with: "static var historyType: Self.HistoryType.Type { get }")
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
        // Emit empty stubs for undeclared underscore-prefixed types referenced in signatures.
        // These are SPI/internal types (e.g. `_AxisContentOutputs` in Charts) that appear as
        // parameter or return types but whose definitions aren't in the public TBD.
        var declaredTypes = Set<String>()
        let declPattern = "(?:public\\s+(?:struct|class|enum|protocol|typealias)|typealias|extension)\\s+(_[A-Za-z][A-Za-z0-9_]*)"
        if let declRegex = try? NSRegularExpression(pattern: declPattern, options: []) {
            let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
            for m in declRegex.matches(in: c, options: [], range: nsRange) {
                if let r = Range(m.range(at: 1), in: c) { declaredTypes.insert(String(c[r])) }
            }
        }
        var underscoreStubs = ""
        // Referenced with a generic argument (e.g. "_ScaleRangeOutputs<CGFloat>",
        // "_PrimitivePlottableKind<Self>") vs. bare — some undeclared SPI types are generic in
        // the real module even though no declaration site tells us so; detect this from a
        // trailing "<...>" at any use site so the stub's arity matches every reference.
        let refPattern = "\\b(_[A-Z][A-Za-z0-9_]+)\\b(<[^>{]*>)?"
        if let refRegex = try? NSRegularExpression(pattern: refPattern, options: []) {
            let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
            var seen = Set<String>()
            var isGenericRef = Set<String>()
            for m in refRegex.matches(in: c, options: [], range: nsRange) {
                if let r = Range(m.range(at: 1), in: c) {
                    let t = String(c[r])
                    if !declaredTypes.contains(t) {
                        seen.insert(t)
                        if m.range(at: 2).location != NSNotFound {
                            isGenericRef.insert(t)
                        }
                    }
                }
            }
            for t in seen {
                if isGenericRef.contains(t) {
                    underscoreStubs += "public struct \(t)<A>: Hashable, Sendable {}\n"
                } else {
                    underscoreStubs += "public struct \(t): Hashable, Sendable {}\n"
                }
            }
        }
        if !underscoreStubs.isEmpty {
            c += "\n// --- Auto-generated stubs for undeclared SPI types ---\n"
            c += underscoreStubs
        }

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
        
        if parser.defaultModule == "Network" {
            // Fix Swift 3 renamed types used in __C_ typealiases
            c = c.replacingOccurrences(of: "NSURLSessionTask", with: "URLSessionTask")
            c = c.replacingOccurrences(of: "NSURLSessionConfiguration", with: "URLSessionConfiguration")
            c = c.replacingOccurrences(of: "OS_dispatch_data", with: "__DispatchData")
            // MessageProtocol's real ABI declares `associatedtype Metadata` and every
            // requirement uses `Self.Metadata` (confirmed via `swift-demangle -expand` on the
            // protocol's dispatch-thunk symbols — e.g. send's witness type is literally
            // "metadata: A.Metadata"), but the generic-placeholder eraser replaced every
            // `Self.Metadata` in the protocol's own declaration with `Any` (it can't tell an
            // associated-type-of-Self reference from an unresolvable demangler path — same
            // class of bug as the ActorSystem `Self.ActorID == Act.ID` fix above). The
            // extension's default implementations already use the correct `Self.Metadata`
            // form, so once the protocol itself declares the associated type, every conformer's
            // ContentType/Metadata/LegacyMessage becomes inferable from receive/map alone, and
            // the extension's defaults satisfy send/makeIncomingMessage/mapLegacy even where a
            // conformer's own overloads (using `Any` or a concrete non-Metadata type from a
            // separate generator bug) don't match.
            // Member order inside the protocol body is not stable across generator runs
            // (dictionary iteration order), so a whole-block exact-string match is fragile —
            // scope the "metadata: Any" -> "metadata: Self.Metadata" replacement and the
            // associatedtype insertion to just this protocol's brace range instead.
            if let headerRange = c.range(of: "public protocol MessageProtocol: OneToOneProtocol {") {
                var depth = 1
                var idx = headerRange.upperBound
                var bodyEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { bodyEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                var body = String(c[headerRange.upperBound..<bodyEnd])
                body = body.replacingOccurrences(of: "metadata: Any", with: "metadata: Self.Metadata")
                body += "    associatedtype Metadata\n"
                c.replaceSubrange(headerRange.upperBound..<bodyEnd, with: body)
            }
            // JSON's generic-parameter discovery missed its own declaration — every member
            // (map/receive/send/mapLegacy/Metadata) references "JSON<A>" but the struct itself
            // was emitted non-generic ("public struct JSON: MessageProtocol, ..."), confirmed
            // generic via the ABI (every real use site is "JSON<A>", e.g. Connection1's
            // receiveOnce/receiveMessage symbols demangle to JSON<A>).
            c = c.replacingOccurrences(
                of: "public struct JSON: MessageProtocol, OneToOneProtocol {",
                with: "public struct JSON<A>: MessageProtocol, OneToOneProtocol {")
            // JSON.receive's real ABI returns "content: A" (JSON's own generic parameter, per
            // `swift-demangle`), not a second unrelated `Any` — same generic-placeholder-erasure
            // bug as elsewhere in this file, just on a bound-generic-self reference instead of
            // an associated type.
            c = c.replacingOccurrences(
                of: "public static func receive<GenericA>(connection: GenericA) async throws -> (content: Any, metadata: JSON<Any>.Metadata) where GenericA: ConnectionProtocol { fatalError() }",
                with: "public static func receive<GenericA>(connection: GenericA) async throws -> (content: A, metadata: JSON<A>.Metadata) where GenericA: ConnectionProtocol { fatalError() }")
            // NWActorID/NetworkActorID: DistributedActorSystem.ActorID requires `Hashable,
            // Sendable`; the generator only sees the demangled Codable/CustomStringConvertible/
            // Hashable conformances (Sendable is implicit-only in the ABI, no witness table
            // entry to detect it from).
            c = c.replacingOccurrences(
                of: "public struct NWActorID: Codable, CustomStringConvertible, Hashable {",
                with: "public struct NWActorID: Codable, CustomStringConvertible, Hashable, Sendable {")
            c = c.replacingOccurrences(
                of: "public struct NetworkActorID: Codable, CustomStringConvertible, Hashable {",
                with: "public struct NetworkActorID: Codable, CustomStringConvertible, Hashable, Sendable {")
            // NWActivity/NWFileTransferDelegate are held in TaskLocal<...>, which requires its
            // Value to be Sendable — same ABI-invisibility issue as above.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class NWActivity: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Equatable {",
                with: "@_fixed_layout public class NWActivity: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Equatable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public protocol NWFileTransferDelegate {",
                with: "public protocol NWFileTransferDelegate: Sendable {")
            // Distributed.DistributedActorSystem conformances (NWActorSystem/NetworkActorSystem):
            // 1. recordArgument/recordReturnType/decodeNextArgument witness `mutating func`
            //    protocol requirements (their conforming types are structs) — the generator
            //    emits plain `func`, which the compiler treats as a non-matching candidate.
            c = c.replacingOccurrences(
                of: "public func recordArgument<GenericA>(_ arg1: Distributed.RemoteCallArgument<GenericA>) throws -> () where GenericA: Decodable,  GenericA: Encodable {}",
                with: "public mutating func recordArgument<GenericA>(_ arg1: Distributed.RemoteCallArgument<GenericA>) throws -> () where GenericA: Decodable,  GenericA: Encodable {}")
            c = c.replacingOccurrences(
                of: "public func recordReturnType<GenericA>(_ arg1: GenericA.Type) throws -> () where GenericA: Decodable,  GenericA: Encodable {}",
                with: "public mutating func recordReturnType<GenericA>(_ arg1: GenericA.Type) throws -> () where GenericA: Decodable,  GenericA: Encodable {}")
            c = c.replacingOccurrences(
                of: "public func decodeNextArgument<GenericA>() throws -> GenericA where GenericA: Decodable,  GenericA: Encodable { fatalError() }",
                with: "public mutating func decodeNextArgument<GenericA>() throws -> GenericA where GenericA: Decodable,  GenericA: Encodable { fatalError() }")
            // 2. remoteCall/remoteCallVoid's real ABI constrains `Self.ActorID == Act.ID`
            //    (visible in the demangled symbol), but the generic-placeholder eraser drops it
            //    since it can't tell an associated-type-of-Self reference from an unresolvable
            //    demangler path — leaving these as "missing witness for protocol requirement".
            c = c.replacingOccurrences(
                of: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable { fatalError() }",
                with: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable, GenericA.ID == NWActorID { fatalError() }")
            c = c.replacingOccurrences(
                of: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error {}",
                with: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error, GenericA.ID == NWActorID {}")
            c = c.replacingOccurrences(
                of: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable { fatalError() }",
                with: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable, GenericA.ID == NetworkActorID { fatalError() }")
            c = c.replacingOccurrences(
                of: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error {}",
                with: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error, GenericA.ID == NetworkActorID {}")
            // 3. None of the 4 protocols' associated types (ActorID/InvocationEncoder/
            //    InvocationDecoder/ResultHandler on DistributedActorSystem,
            //    SerializationRequirement on all 4) can be inferred without an explicit
            //    typealias — nothing in the generated members' signatures pins them down
            //    uniquely (e.g. `resolve`'s `GenericA.Type` is generic, not concretely
            //    NWActorID). Missing inference cascades into "missing witness" for every
            //    requirement, even ones with a correctly-typed candidate already present.
            //    The class must also be `final` — DistributedActorSystem requires Sendable,
            //    and a non-final class can't conform to Sendable.
            for (systemName, idName, encName, decName, resultName) in [
                ("NWActorSystem", "NWActorID", "NWActorSystemInvocationEncoder", "NWActorSystemInvocationDecoder", "NWActorSystemResultHandler"),
                ("NetworkActorSystem", "NetworkActorID", "NetworkActorSystemInvocationEncoder", "NetworkActorSystemInvocationDecoder", "NetworkActorSystemResultHandler"),
            ] {
                c = c.replacingOccurrences(
                    of: "@_fixed_layout public class \(systemName): Distributed.DistributedActorSystem {",
                    with: """
                    @_fixed_layout final public class \(systemName): Distributed.DistributedActorSystem {
                        public typealias ActorID = \(idName)
                        public typealias InvocationEncoder = \(encName)
                        public typealias InvocationDecoder = \(decName)
                        public typealias ResultHandler = \(resultName)
                        public typealias SerializationRequirement = Codable
                    """)
                c = c.replacingOccurrences(
                    of: "public struct \(encName): Distributed.DistributedTargetInvocationEncoder {",
                    with: "public struct \(encName): Distributed.DistributedTargetInvocationEncoder {\n    public typealias SerializationRequirement = Codable")
                c = c.replacingOccurrences(
                    of: "public struct \(decName): Distributed.DistributedTargetInvocationDecoder {",
                    with: "public struct \(decName): Distributed.DistributedTargetInvocationDecoder {\n    public typealias SerializationRequirement = Codable")
                c = c.replacingOccurrences(
                    of: "public struct \(resultName): Distributed.DistributedTargetInvocationResultHandler {",
                    with: "public struct \(resultName): Distributed.DistributedTargetInvocationResultHandler {\n    public typealias SerializationRequirement = Codable")
            }
            c += """
            
            // --- Auto-generated stubs for C/system types ---
            public class OS_nw_application_id {}
            public class OS_nw_array {}
            public class OS_nw_browse_descriptor {}
            public class OS_nw_connection {}
            public class OS_nw_connection_group {}
            public class OS_nw_connection_progress_report {}
            public class OS_nw_content_context {}
            public class OS_nw_context {}
            public class OS_nw_endpoint {}
            public class OS_nw_error {}
            public class OS_nw_frame {}
            public class OS_nw_group_descriptor {}
            public class OS_nw_interface {}
            public class OS_nw_listener {}
            public class OS_nw_parameters {}
            public class OS_nw_path {}
            public class OS_nw_path_monitor {}
            public class OS_nw_protocol_definition {}
            public class OS_nw_protocol_metadata {}
            public class OS_nw_protocol_options {}
            public class OS_nw_proxy_config {}
            public class OS_nw_txt_record {}
            public class OS_sec_identity {}
            public class OS_sec_protocol_metadata {}
            public class OS_sec_protocol_options {}
            public class OS_sec_trust {}
            public struct ether_addr {}
            public struct tls_ciphersuite_group_t {}
            public struct tls_ciphersuite_t {}
            public struct tls_protocol_version_t {}
            
            """
        }
        // Sentinel structs go AFTER all generic helpers so Phase A (stripped at the marker)
        // still sees GenericA/B/etc. but not the protocol-conforming sentinels.
        if !sentinelSource.isEmpty {
            c += "\n// --- Protocol Default Sentinels (dylib-only, stripped for module emit) ---\n"
            c += sentinelSource
        }
        c = c.fixResultAndEmptyFailureTypes()
        c = c.removePrivateObjCTypeReferences()
        // Restore shielded system types
        c = c.replacingOccurrences(of: "___FOUNDATION_SHIELDED_FormatStyle___", with: "Foundation.FormatStyle")
        c = c.replacingOccurrences(of: "___SWIFT_SHIELDED_Slice___", with: "Swift.Slice")
        
        c = c.replacingOccurrences(of: "Darwin.POSIXErrorCode", with: "POSIXErrorCode")
        
        // Remove duplicate top-level free function declarations that arise when overlapping
        // `where Any: Protocol` constraints are stripped, leaving identical signatures.
        // Only targets non-indented lines (top-level scope) to avoid removing indented methods.
        let declLines = c.components(separatedBy: "\n")
        var seenDecls = Set<String>()
        var cleanedLines = [String]()
        for line in declLines {
            let isTopLevel = !line.hasPrefix(" ") && !line.hasPrefix("\t")
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isTopLevel && (trimmed.hasPrefix("public func ") || trimmed.hasPrefix("open func ")) {
                let normalized = trimmed.replacingOccurrences(of: " ", with: "")
                if seenDecls.contains(normalized) {
                    continue
                }
                seenDecls.insert(normalized)
            }
            cleanedLines.append(line)
        }
        c = cleanedLines.joined(separator: "\n")
        
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
        var conformances: [String] = []
        
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
            if isProtocol || kind == "protocol" {
                kindKeyword = "protocol"
            } else if kind == "enum" {
                kindKeyword = "enum"
            } else if kind == "class" {
                kindKeyword = "class"
            }
            
            var inheritance = ""
            if kindKeyword == "protocol" {
                let uniqueConformances = Array(Set(conformances)).sorted()
                if !uniqueConformances.isEmpty {
                    inheritance = ": " + uniqueConformances.joined(separator: ", ")
                }
            } else {
                var uniqueConformances = Set<String>(conformances)
                if uniqueConformances.contains("Codable") {
                    uniqueConformances.remove("Decodable")
                    uniqueConformances.remove("Encodable")
                }
                let isNonCopyable = uniqueConformances.contains("~Copyable") || uniqueConformances.contains("any ~Copyable")
                if kindKeyword == "struct" || kindKeyword == "enum" {
                    if !isNonCopyable {
                        uniqueConformances.insert("Codable")
                        uniqueConformances.insert("Hashable")
                    }
                    uniqueConformances.insert("Sendable")
                } else if kindKeyword == "class" {
                    if !uniqueConformances.contains("Sendable") && !uniqueConformances.contains("@unchecked Sendable") {
                        uniqueConformances.insert("@unchecked Sendable")
                    }
                }
                if isNonCopyable {
                    uniqueConformances.remove("Codable")
                    uniqueConformances.remove("Decodable")
                    uniqueConformances.remove("Encodable")
                    uniqueConformances.remove("Hashable")
                    uniqueConformances.remove("Equatable")
                }
                let sortedConformances = uniqueConformances.sorted()
                if !sortedConformances.isEmpty {
                    inheritance = ": " + sortedConformances.joined(separator: ", ")
                }
            }
            
            let escapedName = ["Type", "Protocol", "Self", "self"].contains(name) ? "`\(name)`" : name
            var s = "\(indent)public \(kindKeyword) \(escapedName)\(params)\(inheritance) {\n"
            if kindKeyword == "struct" || kindKeyword == "class" {
                s += "\(indent)    public init() {}\n"
            } else if kindKeyword == "enum" {
                s += "\(indent)    case case0\n"
            }
            
            for child in nested.values.sorted(by: { $0.name < $1.name }) {
                s += child.generateSwift(depth: depth + 1)
            }
            s += "\(indent)}\n"
            return s
        }
    }

    static func generateStubs(outputCode: String, currentModule: String, outputDir: String, parser: Parser) {
        try? outputCode.write(toFile: "/tmp/finalCode_\(currentModule)_first_run.swift", atomically: true, encoding: .utf8)
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
                    // Skip types the current module itself declares via extension on another
                    // module's type (e.g. TokenGeneration.Prompt.RenderedPromptFragment,
                    // injected by our own stdlibTypeExtensions mechanism) — these aren't real
                    // members of that external module, so stubbing them here would re-declare
                    // them and create a genuine ambiguous-lookup conflict with our own
                    // extension-injected declaration.
                    let isSelfDeclaredExtension = parser.selfDeclaredExternalExtensionPaths.contains {
                        typeName == $0 || typeName.hasPrefix($0 + ".")
                    }
                    if isPrivateFw && mod != currentModule && !isSelfDeclaredExtension {
                        var isProto = isProtocol
                        if constraintTypes.contains(typeName) || constraintTypes.contains(parts.dropFirst().joined(separator: ".")) {
                            isProto = true
                        }
                        externalTypes[mod, default: []].append((typeName: typeName, isProtocol: isProto, genericCount: genericCount))
                    }
                }
            }
        }
        
        var queue = [String]()
        for (mod, items) in externalTypes {
            for item in items {
                var cleanName = item.typeName
                if cleanName.hasPrefix("\(mod).") {
                    cleanName = String(cleanName.dropFirst(mod.count + 1))
                }
                queue.append("\(mod).\(cleanName)")
            }
        }
        var visited = Set(queue)
        var qIndex = 0
        while qIndex < queue.count {
            let fullTypeName = queue[qIndex]
            qIndex += 1
            
            let parts = fullTypeName.components(separatedBy: ".")
            let mod = parts[0]
            let path = Array(parts.dropFirst())
            
            if let node = parser.findTypeNode(module: mod, path: path) {
                for conf in node.conformances {
                    let cleanConf = conf.replacingOccurrences(of: "any ", with: "")
                    let confParts = cleanConf.components(separatedBy: ".")
                    guard confParts.count >= 2 else { continue }
                    let confMod = confParts[0]
                    
                    let sdkRoot = ConfigManager.sdkRoot
                    let isPrivate = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(confMod).framework") ||
                                    FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(confMod).framework")
                    
                    if isPrivate && confMod != currentModule {
                        let confName = confParts.dropFirst().joined(separator: ".")
                        let fullConfName = "\(confMod).\(confName)"
                        if !visited.contains(fullConfName) {
                            visited.insert(fullConfName)
                            queue.append(fullConfName)
                            
                            var isProto = false
                            if let confNode = parser.findTypeNode(module: confMod, path: Array(confParts.dropFirst())) {
                                isProto = (confNode.kind == "protocol")
                            } else {
                                isProto = confName.contains("Representable") || confName.contains("Protocol") || confName.contains("Delegate")
                            }
                            externalTypes[confMod, default: []].append((typeName: fullConfName, isProtocol: isProto, genericCount: 0))
                        }
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
        // Scan "extension Module.TypeName where TypeName.AssocType == X" patterns to extract
        // associated types for external protocols used as extension targets.
        let extWherePattern = "extension\\s+([A-Za-z_][A-Za-z0-9_.]+)\\s+where\\s+([A-Za-z_][A-Za-z0-9_.]+)\\.([A-Za-z_][A-Za-z0-9_]+)"
        if let regex = try? NSRegularExpression(pattern: extWherePattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let typeRange = Range(m.range(at: 1), in: outputCode),
                   let assocRange = Range(m.range(at: 3), in: outputCode) {
                    let typeName = String(outputCode[typeRange])
                    let assocName = String(outputCode[assocRange])
                    let shortName = typeName.components(separatedBy: ".").last ?? typeName
                    protocolAssociatedTypes[typeName, default: []].insert(assocName)
                    protocolAssociatedTypes[shortName, default: []].insert(assocName)
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

        // Pre-load type kind info from dependency TBD files so StubNode gets the correct
        // struct/enum/class keyword instead of defaulting to struct.
        let sdkRoot = ConfigManager.sdkRoot
        let tbdSearchPaths = [
            "\(sdkRoot)/System/Library/PrivateFrameworks",
            "\(sdkRoot)/System/Library/SubFrameworks",
            "\(sdkRoot)/System/Library/Frameworks"
        ]
        for mod in externalTypes.keys {
            var tbdContent: String? = nil
            for searchPath in tbdSearchPaths {
                let paths = [
                    "\(searchPath)/\(mod).framework/\(mod).tbd",
                    "\(searchPath)/\(mod).framework/Versions/A/\(mod).tbd",
                    "\(searchPath)/\(mod).framework/Versions/Current/\(mod).tbd"
                ]
                for p in paths {
                    if let c = try? String(contentsOfFile: p, encoding: .utf8) {
                        tbdContent = c; break
                    }
                }
                if tbdContent != nil { break }
            }
            if let content = tbdContent {
                let depSymbols = extractSymbols(from: content)
                var depDemangledMap: [(mangled: String, demangled: String)] = []
                for sym in depSymbols {
                    if let dem = demangle(symbol: sym) {
                        depDemangledMap.append((mangled: sym, demangled: dem))
                    }
                }
                parser.discoverNominalTypes(demangledMap: depDemangledMap, currentModule: mod)
            }
        }

        for (mod, items) in externalTypes {
            print("Stubbing: \(mod) has \(items.count) items: \(items.map { $0.typeName })", to: &Self.standardError)
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
                            node.conformances = typeNode.conformances.compactMap { conf in
                                let clean = conf.hasPrefix(mod + ".") ? String(conf.dropFirst(mod.count + 1)) : conf
                                let noAny = clean.replacingOccurrences(of: "any ", with: "")
                                
                                let rawNoAny = conf.replacingOccurrences(of: "any ", with: "")
                                let isSwift = rawNoAny.hasPrefix("Swift.") || ["Equatable", "Hashable", "Codable", "Decodable", "Encodable", "Sendable", "Error", "CustomStringConvertible", "Comparable", "Sequence", "Collection", "Strideable", "Numeric", "SignedNumeric", "AdditiveArithmetic", "FloatingPoint", "BinaryFloatingPoint", "LosslessStringConvertible", "CaseIterable", "RawRepresentable", "CodingKey", "LocalizedError"].contains(noAny)
                                let isFoundation = rawNoAny.hasPrefix("Foundation.")
                                
                                if isSwift || isFoundation {
                                    var baseName = noAny
                                    if baseName.hasPrefix("Swift.") {
                                        baseName = String(baseName.dropFirst(6))
                                    }
                                    if baseName.hasPrefix("Foundation.") {
                                        baseName = String(baseName.dropFirst(11))
                                    }
                                    let whitelist = ["Equatable", "Hashable", "Codable", "Decodable", "Encodable", "Sendable", "Error"]
                                    if whitelist.contains(baseName) {
                                        return baseName
                                    } else {
                                        return nil
                                    }
                                }
                                
                                if noAny.contains("ExpressibleBy") {
                                    return nil
                                }
                                // Filter out conformances to protocols defined in the target module
                                // (currentModule). simplifyType strips the currentModule prefix, so
                                // e.g. TokenGenerationCore.XPCRevivable becomes bare XPCRevivable
                                // which doesn't exist when compiling this dependency stub in isolation.
                                if !noAny.contains(".") || noAny.hasPrefix(currentModule + ".") {
                                    if let targetModule = parser.modules[currentModule] {
                                        let shortName = noAny.components(separatedBy: ".").last ?? noAny
                                        if let protoNode = targetModule.nestedTypes[shortName], protoNode.kind == "protocol" {
                                            return nil
                                        }
                                    }
                                }
                                return noAny
                            }
                        }
                        current.nested[part] = node
                    }
                    current = current.nested[part]!
                }
                if item.isProtocol || current.kind == "protocol" {
                    current.isProtocol = true
                }
                current.genericCount = max(current.genericCount, item.genericCount)
            }
            
            var topLevelProtocols = [StubNode]()
            var topLevelTypes = [StubNode]()
            
            for child in root.nested.values {
                let fullPath = "\(mod).\(child.name)"
                if child.isProtocol || child.kind == "protocol" || protocolAssociatedTypes[fullPath] != nil ||
                   ["Visitor", "Decoder", "Encoder", "Message", "Enum", "Stream"].contains(child.name) ||
                   child.name.hasSuffix("Protocol") || child.name.hasSuffix("Providing") || child.name.hasSuffix("Delegate") {
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

        // Emit minimal empty stubs for private-framework modules that were discovered
        // (via discoveredNamespaces) but have no referenced types in the interface
        // (e.g. GenerativeModelsFoundation) — their import line still requires the
        // module to exist at compile time.
        let systemMods: Set<String> = ["Swift", "Foundation", "ObjectiveC", "Dispatch", "os",
            "Metal", "CoreGraphics", "CoreVideo", "IOSurface", "MetricKit", "Combine",
            "Synchronization", "CoreMedia", "XPC", "CoreAI", "UniformTypeIdentifiers"]
        for modName in parser.discoveredNamespaces {
            guard modName != currentModule && !externalTypes.keys.contains(modName) else { continue }
            guard !systemMods.contains(modName) else { continue }
            // Only emit if it's a private framework in the SDK
            var tbdExists = false
            for searchPath in tbdSearchPaths {
                let p = "\(searchPath)/\(modName).framework/\(modName).tbd"
                if FileManager.default.fileExists(atPath: p) { tbdExists = true; break }
                let p2 = "\(searchPath)/\(modName).framework/Versions/A/\(modName).tbd"
                if FileManager.default.fileExists(atPath: p2) { tbdExists = true; break }
            }
            guard tbdExists else { continue }
            let filePath = "\(outputDir)/\(modName).swift"
            guard !FileManager.default.fileExists(atPath: filePath) else { continue }
            let emptyStub = "import Foundation\n// Empty stub for \(modName)\n"
            try? emptyStub.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("Generated empty stub for \(modName) at \(filePath)", to: &Self.standardError)
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
