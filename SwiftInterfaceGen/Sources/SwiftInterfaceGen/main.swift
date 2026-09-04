import Foundation

@main
struct SwiftInterfaceGen {
    static func main() {
        let args = CommandLine.arguments
        ConfigManager.verbose = args.contains("--verbose") || args.contains("--debug")
        if args.contains("--compare") {
            runCompare(args: args)
            return
        }
        if args.count < 2 {
            print("Usage: swift-interface-gen <path_to_tbd> [--config <path_to_config.json>] [--verbose|--debug] or swift-interface-gen --compare <tbd_path> <dylib_path> [aliases_output_path]")
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
        // A .tbd for a framework with `reexported-libraries:` is a multi-document file: its
        // own `--- !tapi-tbd` document, followed by one more per reexported library (Apple
        // flattens each dependency's full symbol table into the same file at .tbd-generation
        // time). Scanning the whole file for symbols would double-count those reexported
        // symbols as if they were this target's own — they're already fetched separately,
        // correctly, via extractReexportedLibraries()'s explicit per-library .tbd lookup below
        // (depth 1). Only the first document is this target's own ABI.
        let ownDocument = content.components(separatedBy: "--- !tapi-tbd").dropFirst().first.map { "--- !tapi-tbd" + $0 } ?? content
        let symbols = extractSymbols(from: ownDocument)
        
        let parser = Parser()
        parser.defaultModule = currentModule
        parser.primaryTargetModule = currentModule
        parser.currentPrecomputeModule = currentModule
        
        let reexportedLibraries = extractReexportedLibraries(from: content)
        for lib in reexportedLibraries {
            let libPath = resolveLibraryPath(lib)
            if let libContent = try? String(contentsOfFile: libPath, encoding: .utf8) {
                if ConfigManager.verbose { print("Discovered dependency: \(lib) -> \(libPath)", to: &Self.standardError) }
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
        if ConfigManager.verbose { print("generateAll took: \(Date().timeIntervalSince(startGen))s", to: &Self.standardError) }

        let startPost = Date()
        let finalCode = postProcess(allCode, parser: parser)
        if ConfigManager.verbose { print("postProcess took: \(Date().timeIntervalSince(startPost))s", to: &Self.standardError) }
        
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
        var movedTypeNames = Set<String>()
        if let moduleNode = parser.modules[currentModule] {
            for t in moduleNode.nestedTypes.values where t.movedFromModule != nil {
                movedTypeNames.insert(t.name)
            }
        }

        var filteredExports = parser.ownTbdSymbols.sorted().filter { sym in
            if stdlibExtPrefixes.contains(where: { sym.hasPrefix($0) }) {
                return false
            }
            if sym.hasPrefix("_$s") || sym.hasPrefix("$s") {
                if let mod = Parser.getMangledModule(sym), mod != currentModule {
                    // Can't just check for the literal "<currentModule.count><currentModule>E"
                    // substring -- Swift's mangler substitutes repeated identifier prefixes with
                    // back-references (e.g. CoreAIDelegates's shared "CoreAI" prefix with an
                    // earlier-mangled CoreAICompiler collapses "15CoreAIDelegatesE" down to
                    // "0A11AIDelegatesE"), so the literal marker silently never matches and a
                    // real cross-module extension member (e.g. CoreAIDelegates's own
                    // `extension Compiler { static func compileModel(...) }`) gets dropped from
                    // the exports list entirely, breaking linking for anything that calls it.
                    let isExtension: Bool
                    if let demangled = demangle(symbol: sym) {
                        isExtension = demangled.contains("(extension in \(currentModule))")
                    } else {
                        let extMarker = "\(currentModule.count)\(currentModule)E"
                        isExtension = sym.contains(extMarker)
                    }
                    let isMoved = movedTypeNames.contains(where: { sym.contains($0) })
                    if !isExtension && !isMoved {
                        return false
                    }
                }
            }
            return true
        }
        let ownObjcClasses = extractObjcClasses(from: content)
        for cls in ownObjcClasses {
            if !cls.hasPrefix("_Tt") {
                filteredExports.append("_OBJC_CLASS_$_\(cls)")
                filteredExports.append("_OBJC_METACLASS_$_\(cls)")
            }
        }
        filteredExports.sort()

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
                    let actualKind = t.kind == "enum" ? "enum" : "class"
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
                // MPSGraphNDXRuntime is only ever referenced as a property/parameter type
                // (MPSGraphDelegateKernel.ndxRuntime, MPSGraphDelegate.Executables.ndxRuntimeBase)
                // and never extended, so registerObjcClasses' So-prefix-extension-symbol
                // discovery never finds it and no declaration for it ends up in bridgedTypes
                // above -- yet the real ABI mangles every reference to it via the ClangImporter
                // "So" prefix (confirmed via swift-demangle: "__C.MPSGraphNDXRuntime"), meaning
                // it's a genuine ObjC class, not a native Swift one. A prior fix rendered it as
                // a plain native `public class MPSGraphNDXRuntime {}`, which compiles fine but
                // mangles under this module instead of "So", so every accessor/field-offset
                // symbol for properties of this type permanently mismatches the real ABI's
                // expected symbols no matter what the property bodies do. Forward-declaring it
                // here instead makes Swift import it through ClangImporter with the correct "So"
                // mangling, matching real usage elsewhere in this same file (e.g.
                // MPSGraphExecutable).
                if currentModule == "MetalPerformanceShadersGraph" {
                    bridgeHeader += """
@interface MPSGraphNDXRuntime : NSObject
@end

"""
                }
                // _LTTextSessionDelegate is only ever referenced as TranslationSession's
                // `textSessionDelegate` property type, never extended, so it's never discovered
                // as an isObjcBridged type -- but its real ABI mangles it as an existential
                // protocol ("So..._p", confirmed via swift-demangle), not a native Swift struct.
                // Forward-declare it as an @objc protocol (same technique as HealthKit's
                // HKWorkoutMetricsDelegate above).
                if currentModule == "Translation" {
                    bridgeHeader += """
@protocol _LTTextSessionDelegate <NSObject>
@end

"""
                }
                // MLMultiArray/SHSignature are only ever referenced as property types
                // (SNKShotSegmentationResult.exemplarEmbedding, SNShazamSignatureResult.signature,
                // etc.), never extended, so isObjcBridged discovery never finds them -- but their
                // real ABI mangles every reference via ClangImporter ("__C.MLMultiArray"/
                // "__C.SHSignature", confirmed via swift-demangle), meaning they're genuine ObjC
                // classes. Forward-declare them the same way as MPSGraphNDXRuntime/
                // _LTTextSessionDelegate above.
                if currentModule == "SoundAnalysis" {
                    bridgeHeader += """
@interface MLMultiArray : NSObject
@end
@interface SHSignature : NSObject
@end
@protocol SNRequest
@end
@protocol SNResult
@end

"""
                    // Unlike MPSGraphNDXRuntime/_LTTextSessionDelegate above (referenced only as
                    // opaque property types, never stored as a genuinely typed property), these
                    // are used as real get/set computed-property types -- the final link step
                    // (no `-undefined dynamic_lookup` there, unlike the first pass) needs an
                    // actual `_OBJC_CLASS_$_` symbol to resolve against, so a header-only forward
                    // declaration isn't enough; provide a matching stub @implementation too.
                    // SNRequest/SNResult are real ObjC *protocols* (confirmed via `swift-demangle
                    // -expand`: the real ABI mangles params as a `ProtocolList`/existential, not
                    // a class), so they need no @implementation -- only their `@protocol` forward
                    // declaration above, referenced in Swift as `any SNRequest`/`any SNResult`.
                    implLines.append("@implementation MLMultiArray")
                    implLines.append("@end")
                    implLines.append("@implementation SHSignature")
                    implLines.append("@end")
                }
                let bridgeImpl   = implLines.joined(separator: "\n")   + "\n"
                try? bridgeHeader.write(toFile: "\(currentModule)Interface_bridge.h", atomically: true, encoding: .utf8)
                try? bridgeImpl.write(toFile:   "\(currentModule)Interface_bridge.m", atomically: true, encoding: .utf8)
                if ConfigManager.verbose { print("Wrote ObjC bridge for \(bridgedTypes.map { $0.name })", to: &Self.standardError) }
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
        
        if code.contains("MTL") || code.contains("MPS") { imports.insert("Metal"); imports.insert("MetalPerformanceShaders") }
        if code.contains("IOSurface") { imports.insert("IOSurface") }
        if code.contains("simd_") { imports.insert("simd") }
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
        if ConfigManager.verbose {
            for symbol in symbols {
                if symbol.contains("UAF") { fputs("Processing symbol: \(symbol)\n", stderr) }
            }
        }
        parser.tbdSymbols.formUnion(symbols)
        if depth == 0 {
            parser.ownTbdSymbols.formUnion(symbols)
        }
        if parser.processedModules.contains(module) { return }
        parser.processedModules.insert(module)
        
        parser.currentPrecomputeModule = module
        
        // Ensure module node exists early to prevent re-entry during precompute/parse if needed
        if parser.modules[module] == nil {
            parser.modules[module] = TypeNode(name: module)
        }
        
        let count = symbols.count
        if ConfigManager.verbose { print("Found \(count) new symbols in \(module). Demangling and precomputing...", to: &Self.standardError) }

        let start = Date()
        var demangledMap: [(mangled: String, demangled: String)] = []
        for mangled in symbols {
            if let demangled = demangle(symbol: mangled) {
                demangledMap.append((mangled: mangled, demangled: demangled))
            }
        }
        if ConfigManager.verbose { print("Demangling took: \(Date().timeIntervalSince(start))s", to: &Self.standardError) }

        let symbolsWithClosures = demangledMap.filter { $0.demangled.contains("->") }.map { $0.mangled }
        if !symbolsWithClosures.isEmpty {
            let startExpand = Date()
            let escapingResults = runDemangleExpand(symbols: symbolsWithClosures, parser: parser)
            parser.symbolEscapingMap.merge(escapingResults) { (_, new) in new }
            if ConfigManager.verbose { print("Demangle --expand for \(symbolsWithClosures.count) symbols took: \(Date().timeIntervalSince(startExpand))s", to: &Self.standardError) }
        }

        // Swift ABI Nominal Type Discovery Pass
        parser.discoverNominalTypes(demangledMap: demangledMap, currentModule: module)

        let startPre = Date()
        for entry in demangledMap {
            parser.precompute(demangled: entry.demangled)
        }
        if ConfigManager.verbose { print("Precompute took: \(Date().timeIntervalSince(startPre))s", to: &Self.standardError) }
        
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
        if ConfigManager.verbose { print("Parse took: \(Date().timeIntervalSince(startParse))s", to: &Self.standardError) }
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
                if token.hasPrefix("_$s") || token.hasPrefix("_OBJC_CLASS_$_") || token.hasPrefix("_OBJC_METACLASS_$_") || token.hasPrefix("_OBJC_IVAR_$_") {
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
            // `.tbd`'s `objc-classes:` list conflates two different things: classes genuinely
            // implemented in Objective-C, and native Swift classes that merely subclass NSObject
            // (any `@objc`/NSObject-derived Swift class gets an ObjC runtime class record too).
            // Only the former need the extension-based ObjC-bridge rendering; a native class has
            // its own nominal type descriptor symbol in the TBD, which the latter never do.
            let nominalTypeDescriptor = "_$s\(module.count)\(module)\(objcClass.count)\(objcClass)CMn"
            let isNativeSwiftClass = parser.tbdSymbols.contains(nominalTypeDescriptor)
            let node = parser.findOrCreateDiscoveredTypePath(module: module, path: [objcClass])
            if node.kind == "unknown" {
                parser.setKind("class", for: node)
                node.baseClass = nsUnitSubclasses.contains(objcClass) ? "NSUnit" : "NSObject"
                node.isObjcBridged = !isNativeSwiftClass
            } else if node.kind == "class" {
                node.isObjcBridged = !isNativeSwiftClass
                if isNativeSwiftClass && node.baseClass == nil {
                    node.baseClass = nsUnitSubclasses.contains(objcClass) ? "NSUnit" : "NSObject"
                }
            }
            // A native class visible under a plain (unmangled) ObjC name needs an explicit
            // @objc(name) annotation, or Swift emits its ObjC class record under the
            // auto-mangled _TtC<module><Class> name instead of the real ABI's plain one.
            if isNativeSwiftClass {
                node.objcExplicitName = objcClass
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
            // Fix: the real module's Curve25519 type is misnamed "Curve" both at module scope
            // and inside SecureEnclave (confirmed via swift-demangle: every required symbol says
            // "CryptoKit.Curve25519..." / "CryptoKit.SecureEnclave.Curve25519...", never "Curve"),
            // while a SEPARATE, entirely empty "public enum Curve25519 { ... }" placeholder
            // (auto-generated stub for what the generator treated as an undeclared type) exists
            // alongside it at both scopes -- the parser evidently split the single real
            // "Curve25519" declaration into a correctly-named-but-empty stub and an incorrectly-
            // named-but-populated real one. Remove the empty duplicates and rename the real ones.
            c = c.replacingOccurrences(
                of: "public enum Curve25519 {\n    case _mock\n    public enum KeyAgreement {\n        case _mock\n        public struct PrivateKey {\n        }\n        public struct PublicKey {\n        }\n    }\n    public enum Signing {\n        case _mock\n        public struct PrivateKey {\n        }\n        public struct PublicKey {\n        }\n    }\n}\n",
                with: "")
            c = c.replacingOccurrences(
                of: "    public enum Curve25519 {\n        case _mock\n        public enum KeyAgreement {\n            case _mock\n            public struct PrivateKey {\n            }\n        }\n        public enum Signing {\n            case _mock\n            public struct PrivateKey {\n            }\n        }\n    }\n",
                with: "")
            c = c.replacingOccurrences(of: "public enum Curve: Hashable, @unchecked Sendable {", with: "public enum Curve25519: Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(of: "    public enum Curve: Hashable, @unchecked Sendable {", with: "    public enum Curve25519: Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(of: "public static func ==(_ lhs: Curve, _ rhs: Curve) -> Bool { fatalError() }", with: "public static func ==(_ lhs: Curve25519, _ rhs: Curve25519) -> Bool { fatalError() }")
            // Fix: AES.GCM.Nonce/ChaChaPoly.Nonce's init(copying:)/init(data:) render their
            // RawSpan parameter with an erroneous `borrowing` keyword copied verbatim from the
            // swiftinterface's printed ownership annotation -- same gap already fixed for
            // MetalPerformanceShadersGraph's Executables.init and Vision's several borrowing
            // params this session: the annotation reflects the implicit default calling
            // convention, not an actual source-level keyword. Confirmed via a minimal repro.
            c = c.replacingOccurrences(of: "init(copying: borrowing RawSpan) throws { fatalError() }", with: "init(copying: RawSpan) throws { fatalError() }")
            c = c.replacingOccurrences(of: "init(data: borrowing RawSpan) throws { fatalError() }", with: "init(data: RawSpan) throws { fatalError() }")
            // Same erroneous-borrowing gap for VRF.VRFPublicKey.init(publicKey:) and
            // SymmetricKey.init(size:initializingWith:)'s closure parameter.
            c = c.replacingOccurrences(
                of: "public init(publicKey: borrowing RawSpan) throws(VRFError) { fatalError() }",
                with: "public init(publicKey: RawSpan) throws(VRFError) { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(size: SymmetricKeySize, initializingWith: borrowing (inout OutputRawSpan) throws (A) -> ()) throws(A) where A: Error { fatalError() }",
                with: "public init<A>(size: SymmetricKeySize, initializingWith: (inout OutputRawSpan) throws (A) -> ()) throws(A) where A: Error { fatalError() }")

            // Fix: XWingMLKEM768X25519 (a post-quantum hybrid KEM) rendered as a completely
            // empty placeholder -- `case _mock` plus three bodyless structs -- instead of the
            // real ~20-member API surface (confirmed via swift-demangle against the full stub
            // list). Filled in by hand, mirroring the sibling Kyber1024/MLKEM768/MLKEM1024 KEM
            // types' established shape (KEMPrivateKey/KEMPublicKey/KEMOneTimePrivateKey, plus the
            // HPKE-specific protocols since this type also needs HPKE interop) and the exact
            // signatures from the demangled stub list.
            c = c.replacingOccurrences(
                of: """
                public enum XWingMLKEM768X25519 {
                    case _mock
                    public struct OneTimePrivateKey {
                    }
                    public struct PrivateKey {
                    }
                    public struct PublicKey {
                    }
                }
                """,
                with: """
                public enum XWingMLKEM768X25519 {
                    case _mock
                    public struct PublicKey: HPKEKEMPublicKey, HPKEPublicKeySerialization, KEMPublicKey {
                        public init<A>(rawRepresentation: A) throws where A: ContiguousBytes { fatalError() }
                        public init<A>(_ arg1: A, kem: HPKE.KEM) throws where A: ContiguousBytes { fatalError() }
                        public func encapsulate() throws -> KEM.EncapsulationResult { fatalError() }
                        public func hpkeRepresentation(kem: HPKE.KEM) throws -> Data { return Data() }
                        public var rawRepresentation: Data { get { return Data() } }
                    }
                    public struct PrivateKey: HPKEKEMPrivateKey, HPKEKEMPrivateKeyGeneration, KEMPrivateKey {
                        public typealias PublicKey = XWingMLKEM768X25519.PublicKey
                        public init() throws { fatalError() }
                        public init<A>(seedRepresentation: A, publicKey: XWingMLKEM768X25519.PublicKey?) throws where A: DataProtocol { fatalError() }
                        public init<A>(integrityCheckedRepresentation: A) throws where A: DataProtocol { fatalError() }
                        public func decapsulate(_ arg1: Data) throws -> SymmetricKey { fatalError() }
                        public var integrityCheckedRepresentation: Data { get { return Data() } }
                        public var publicKey: XWingMLKEM768X25519.PublicKey { get { fatalError() } }
                        public var seedRepresentation: Data { get { return Data() } }
                        public static func generate() throws -> PrivateKey { fatalError() }
                    }
                    public struct OneTimePrivateKey: KEMOneTimePrivateKey {
                        public typealias PublicKey = XWingMLKEM768X25519.PublicKey
                        public var publicKey: XWingMLKEM768X25519.PublicKey { get { fatalError() } }
                        public func decapsulate(_ arg1: Data) throws -> SymmetricKey { fatalError() }
                        public static func generate() throws -> OneTimePrivateKey { fatalError() }
                    }
                }
                """)
            // Fix: HPKE.Recipient/Sender's authenticatedBy/recipientKey params render as bare
            // "Any" instead of the real associated-type reference "A.PublicKey" (confirmed via
            // swift-demangle: DiffieHellmanKeyAgreement declares `associatedtype PublicKey:
            // HPKEDiffieHellmanPublicKey`, and A: HPKEDiffieHellmanPrivateKey inherits it) --
            // same generic-placeholder-resolved-as-Any gap seen elsewhere this session.
            c = c.replacingOccurrences(
                of: "authenticatedBy: Any, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "authenticatedBy: A.PublicKey, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(
                of: "authenticatedBy: Any) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "authenticatedBy: A.PublicKey) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(recipientKey: Any, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "public init<A>(recipientKey: A.PublicKey, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(recipientKey: Any, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "public init<A>(recipientKey: A.PublicKey, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(of: "Curve.KeyAgreement", with: "Curve25519.KeyAgreement")
            c = c.replacingOccurrences(of: "Curve.Signing", with: "Curve25519.Signing")

            // Fix: HPKEDiffieHellmanPrivateKey/HPKEKEMPrivateKey render as empty-bodied protocol
            // refinements, but their real ABI needs an "associated conformance descriptor"
            // narrowing the inherited PublicKey associatedtype to the HPKE-specific public-key
            // protocol (DiffieHellmanKeyAgreement.PublicKey -> HPKEDiffieHellmanPublicKey,
            // KEMPrivateKey.PublicKey -> HPKEKEMPublicKey) -- confirmed via a minimal repro that
            // redeclaring the associatedtype with the narrower bound produces exactly this symbol.
            c = c.replacingOccurrences(
                of: "public protocol HPKEDiffieHellmanPrivateKey: DiffieHellmanKeyAgreement {\n}",
                with: "public protocol HPKEDiffieHellmanPrivateKey: DiffieHellmanKeyAgreement {\n    associatedtype PublicKey: HPKEDiffieHellmanPublicKey\n}")
            c = c.replacingOccurrences(
                of: "public protocol HPKEKEMPrivateKey: KEMPrivateKey {\n}",
                with: "public protocol HPKEKEMPrivateKey: KEMPrivateKey {\n    associatedtype PublicKey: HPKEKEMPublicKey\n}")

            // Fix: a bogus, truncated-name duplicate of XWingMLKEM768X25519 ("XWingMLKEM768X",
            // missing the "25519" suffix) is auto-generated alongside our hand-written real type
            // -- no real ABI symbol ever demangles to bare "XWingMLKEM768X" (confirmed by
            // grepping every demangled CryptoKit.tbd symbol), so this is a phantom placeholder,
            // same "bogus auto-generated duplicate" family as the Curve/Curve25519 fix above.
            // It compiled harmlessly as an unconstrained conformance until the associated
            // conformance descriptor fix above required an explicit `PublicKey` witness -- delete
            // the whole phantom block outright via balanced-brace scan (member order inside it is
            // nondeterministic across generator runs, so a literal multi-line match is unsafe).
            if let markerRange = c.range(of: "public enum XWingMLKEM768X: Hashable, @unchecked Sendable {") {
                var depth = 1
                var idx = markerRange.upperBound
                var endIdx: String.Index? = nil
                while idx < c.endIndex {
                    let ch = c[idx]
                    if ch == "{" { depth += 1 } else if ch == "}" {
                        depth -= 1
                        if depth == 0 { endIdx = c.index(after: idx); break }
                    }
                    idx = c.index(after: idx)
                }
                if let endIdx {
                    var removeEnd = endIdx
                    if removeEnd < c.endIndex, c[removeEnd] == "\n" {
                        removeEnd = c.index(after: removeEnd)
                    }
                    c.removeSubrange(markerRange.lowerBound..<removeEnd)
                }
            }

            // Fix: P256/P384/P521 already implement CorecryptoSupportedNISTCurve's requirements
            // (curveType, hash2fieldL) but never declare the conformance itself, and are missing
            // the associatedtype H witness entirely; similarly MLKEM768/MLKEM1024 already
            // implement CorecryptoSupportedMLKEMKEM's requirements (createPublicKey, kemType,
            // unmaskedKemType) but never declare the conformance, missing the associatedtype
            // publicKeyType witness. Confirmed via swift-demangle that both conformances (and
            // their witness tables, since these are concrete, non-generic types -- unlike the
            // generic-conformance witness-table gap seen elsewhere this session) are real ABI.
            for (curve, hashFn) in [("P256", "SHA256"), ("P384", "SHA384"), ("P521", "SHA512")] {
                c = c.replacingOccurrences(
                    of: "public enum \(curve) {",
                    with: "public enum \(curve): CorecryptoSupportedNISTCurve {\n    public typealias H = \(hashFn)")
            }
            for kem in ["MLKEM768", "MLKEM1024"] {
                c = c.replacingOccurrences(
                    of: "public enum \(kem) {",
                    with: "public enum \(kem): CorecryptoSupportedMLKEMKEM {\n    public typealias publicKeyType = \(kem).PublicKey")
            }

            // `SecureEnclave.P256`/`.P384`/`.P521`/`.Curve25519` are distinct nested enums that
            // shadow the top-level `P256`/`P384`/`P521`/`Curve25519` types of the same name. Bare
            // references like `P256.KeyAgreement.PublicKey` written inside SecureEnclave's own
            // nested types resolve to the *enclosing* SecureEnclave.P256 (which has no such
            // nested member) instead of the top-level type the real module actually means. Fully
            // qualify with the module name (unambiguous everywhere, including outside
            // SecureEnclave) so name lookup can't shadow it.
            for curve in ["P256", "P384", "P521", "Curve25519"] {
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
        c = c.stripBogusArrayExtensionStructs()

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
            // Fix: MLMultiArray/SHSignature are blanket-replaced with `Any` above (needed
            // elsewhere in this file where the real type genuinely can't be resolved), but the
            // real ABI mangles these specific properties as `__C.MLMultiArray`/`__C.SHSignature`
            // (confirmed via swift-demangle) -- reinstate the real (now bridge-header-forward-
            // declared, see generateExports) type for exactly these known property sites.
            for (old, new) in [
                ("public var exemplar: Any { get { fatalError() } set {} }",
                 "public var exemplar: MLMultiArray { get { fatalError() } set {} }"),
                ("public var trainingDataEmbeddings: [Any] { get { return [] } set {} }",
                 "public var trainingDataEmbeddings: [MLMultiArray] { get { return [] } set {} }"),
                ("public var validationDataEmbeddings: [Any] { get { return [] } set {} }",
                 "public var validationDataEmbeddings: [MLMultiArray] { get { return [] } set {} }"),
                ("public var data: Any { get { fatalError() } set {} }",
                 "public var data: MLMultiArray { get { fatalError() } set {} }"),
                ("public var exemplarEmbedding: Any { get { fatalError() } set {} }",
                 "public var exemplarEmbedding: MLMultiArray { get { fatalError() } set {} }"),
                ("public final var signature: Any { get { fatalError() } set {} }",
                 "public final var signature: SHSignature { get { fatalError() } set {} }"),
                ("public final var featureVector: Any { get { fatalError() } set {} }",
                 "public final var featureVector: MLMultiArray { get { fatalError() } set {} }"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Fix: SNRequest/SNResult are blanket-replaced with `Any` above (needed elsewhere
            // where the real type genuinely can't be resolved), but SNResultsCollector's 3
            // delegate-style methods mangle their params as real ObjC-*protocol* existentials
            // `any __C.SNRequest`/`any __C.SNResult` (confirmed via `swift-demangle -expand`:
            // the params are a `ProtocolList`, not a class reference) -- same "reinstate the
            // real bridge-header type at known sites" pattern as the MLMultiArray/SHSignature
            // fix above, but as an existential since SNRequest/SNResult are protocols, not
            // classes (unlike MLMultiArray/SHSignature).
            c = c.replacingOccurrences(
                of: "public final func request(_ arg1: Any, didProduce: Any) -> () {}",
                with: "public final func request(_ arg1: any SNRequest, didProduce: any SNResult) -> () {}")
            c = c.replacingOccurrences(
                of: "public final func requestDidComplete(_ arg1: Any) -> () {}",
                with: "public final func requestDidComplete(_ arg1: any SNRequest) -> () {}")
            c = c.replacingOccurrences(
                of: "public final func request(_ arg1: Any, didFailWithError: any Error) -> () {}",
                with: "public final func request(_ arg1: any SNRequest, didFailWithError: any Error) -> () {}")
            c = c.replacingOccurrences(of: "GenericA.Result", with: "Any")
            c = c.replacingOccurrences(of: "GenericA.Arg", with: "Any")
            c = c.replacingOccurrences(of: "public static func automaticallyNotifiesObservers(forKey:", with: "public override static func automaticallyNotifiesObservers(forKey:")
            c = c.replacingOccurrences(of: "public struct AnyPublisher<A, B>:", with: "public struct AnyPublisher<A, B: Swift.Error>:")
            c = c.replacingOccurrences(of: "public struct AnySubject<A, B>:", with: "public struct AnySubject<A, B: Swift.Error>:")
            c = c.replacingOccurrences(of: "public enum Completion<A>:", with: "public enum Completion<A: Swift.Error>:")
            // Completion<A>'s Codable/Hashable conformances are each individually CONDITIONAL
            // in the real ABI (confirmed via swift-demangle -expand on their conformance
            // descriptors: "where A: Swift.Encodable"/"Decodable"/"Hashable"), not the single
            // unconditional "Codable, Hashable" the generator infers from the TBD's flat
            // conformance list.
            c = c.replacingOccurrences(of: "public enum Completion<A: Swift.Error>: Codable, Hashable, @unchecked Sendable", with: "public enum Completion<A: Swift.Error>: @unchecked Sendable")
            c = c.replacingOccurrences(of: "public enum Completion<A: Swift.Error>: Codable, @unchecked Sendable", with: "public enum Completion<A: Swift.Error>: @unchecked Sendable")
            // Fix: unlike hash(into:)/==, which stay correct either as an unconditional member
            // or duplicated into the extension, encode(to:)/init(from:) mangle as EXTENSION
            // members in the real ABI (confirmed via swift-demangle: "(extension in
            // SoundAnalysis):...Completion< where A: Swift.Encodable>.encode(to:)") -- leaving
            // them as unconditional members of the enum body (as originally generated) produces
            // a type-mangled symbol instead, which never matches. Remove them from the base body
            // and move them into their respective conditional extensions, matching the pattern
            // used for RawRepresentableWrapper's identical Encodable/Decodable/Hashable shape.
            c = c.replacingOccurrences(
                of: "public init(from decoder: any Swift.Decoder) throws { fatalError() }\n        public func encode(to encoder: Swift.Encoder) throws { fatalError() }\n        public func hash(into hasher: inout Hasher) { fatalError() }\n    }",
                with: "public func hash(into hasher: inout Hasher) { fatalError() }\n    }")
            c = c.replacingOccurrences(
                of: "extension PubSub.Completion where A: Equatable {\n    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }\n}",
                with: """
                extension PubSub.Completion: Swift.Equatable where A: Swift.Equatable {
                    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }
                }
                extension PubSub.Completion: Swift.Hashable where A: Swift.Hashable {
                    public func hash(into hasher: inout Hasher) { fatalError() }
                }
                extension PubSub.Completion: Swift.Encodable where A: Swift.Encodable {
                    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                }
                extension PubSub.Completion: Swift.Decodable where A: Swift.Decodable {
                    public init(from decoder: any Swift.Decoder) throws { fatalError() }
                }
                """)
            c = c.replacingOccurrences(of: "public struct RawRepresentableWrapper<A>:", with: "public struct RawRepresentableWrapper<A: RawRepresentable>:")
            // Same conditional-conformance shape as Completion<A> above, but keyed off
            // A.RawValue (confirmed via swift-demangle -expand: "where A.RawValue: Swift.X")
            // rather than A itself.
            c = c.replacingOccurrences(
                of: "public struct RawRepresentableWrapper<A: RawRepresentable>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct RawRepresentableWrapper<A: RawRepresentable>: @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: """
                public struct RawRepresentableWrapper<A: RawRepresentable>: @unchecked Sendable {
                    public init(_ arg1: A) { fatalError() }
                    public var rawValue: A.RawValue { get { fatalError() } }
                    public var value: A { get { fatalError() } }
                    public init(from decoder: any Swift.Decoder) throws { fatalError() }
                    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                    public func hash(into hasher: inout Hasher) { fatalError() }
                }
                """,
                with: """
                public struct RawRepresentableWrapper<A: RawRepresentable>: @unchecked Sendable {
                    public init(_ arg1: A) { fatalError() }
                    public var rawValue: A.RawValue { get { fatalError() } }
                    public var value: A { get { fatalError() } }
                }
                extension RawRepresentableWrapper: Swift.Equatable where A.RawValue: Swift.Equatable {
                    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
                }
                extension RawRepresentableWrapper: Swift.Hashable where A.RawValue: Swift.Hashable {
                    public func hash(into hasher: inout Hasher) { fatalError() }
                }
                extension RawRepresentableWrapper: Swift.Encodable where A.RawValue: Swift.Encodable {
                    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                }
                extension RawRepresentableWrapper: Swift.Decodable where A.RawValue: Swift.Decodable {
                    public init(from decoder: any Swift.Decoder) throws { fatalError() }
                }
                """)
            c = c.removeAnyConstraintsFromWhereClause()

            // Fix: SNDetectSoundActionsRequest/SNDetectSoundRequest/_SNClassifySoundRequest are
            // real native Swift classes (their required ABI symbols mangle with the SoundAnalysis
            // module prefix, not "__C."/"(extension in ...)"), but the parser never emits their
            // base class declaration at all -- only an "ObjC Extension (bridge-header required)"
            // extension on a type that doesn't exist, which the generator's isObjcBridged
            // detection wrongly classified as ObjC-imported. Confirmed via minimal repro that
            // declaring them as plain native classes (not ObjC-bridge extensions) reproduces the
            // required symbols almost exactly. Two remaining wrinkles, also confirmed via repro:
            // (1) a `coder:`-taking init produces an unwanted resilience dispatch thunk + method
            // descriptor UNLESS marked `@objc dynamic`, which suppresses both; (2) any additional
            // designated initializer causes NSObject's inherited bare `init()` to also become
            // exported (not part of the real ABI) UNLESS it's given a `private override init()`
            // to explicitly claim/hide it. A third gap, "method lookup function for X", was left
            // unresolved at the time of this fix (see the later _typeMetadataAnchor fix in this
            // block for the root cause and resolution: `final`-only members don't need a vtable
            // slot, so Swift elides the whole class-metadata suite unless a non-final member
            // exists -- SNDetectSoundRequest/_SNClassifySoundRequest already have one (`copy`),
            // but SNDetectSoundActionsRequest's bare `override init()` doesn't).
            c = c.replacingOccurrences(
                of: """
                // --- ObjC Extension (bridge-header required) ---
                extension SNDetectSoundActionsRequest {
                    @nonobjc public override convenience init() { fatalError() }
                    public struct __deallocating_deinit: Codable, Hashable, @unchecked Sendable {
                        public init(from decoder: any Swift.Decoder) throws { fatalError() }
                        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                        public func hash(into hasher: inout Hasher) { fatalError() }
                        public static func ==(_ lhs: __deallocating_deinit, _ rhs: __deallocating_deinit) -> Bool { fatalError() }
                    }
                }
                // --- End ObjC Extension ---
                """,
                with: """
                open class SNDetectSoundActionsRequest: NSObject {
                    public override init() { super.init() }
                    private var _typeMetadataAnchor: Int = 0
                }
                """)
            // Member order within these two extension bodies is nondeterministic across
            // generator runs (same class of issue as elsewhere this session), so extract each
            // whole extension body via a structural span match rather than assuming a fixed
            // member sequence, then rebuild the class unconditionally with the fixed member set
            // (both extensions always contain exactly the same members every run -- only their
            // relative order varies).
            for typeName in ["SNDetectSoundRequest", "_SNClassifySoundRequest"] {
                if let re = try? NSRegularExpression(pattern: "(// --- ObjC Extension \\(bridge-header required\\) ---\\n)?extension \(typeName) \\{[\\s\\S]*?\\n\\}\\n(// --- End ObjC Extension ---\\n)?"),
                   let m = re.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
                   let fullRange = Range(m.range, in: c) {
                    let descriptionMember = typeName == "SNDetectSoundRequest"
                        ? "    public override var description: Swift.String { get { fatalError() } }\n"
                        : ""
                    let replacement = """
                    public class \(typeName): NSObject {
                        public static var supportsSecureCoding: Swift.Bool { get { fatalError() } }
                        private override init() { super.init() }
                    \(descriptionMember)    public func copy(with: NSZone?) -> Any { fatalError() }
                        public override var hash: Swift.Int { get { fatalError() } }
                        public override func isEqual(_ arg1: Any?) -> Swift.Bool { fatalError() }
                        public func encode(with: NSCoder) -> () {}
                        @objc dynamic public convenience init?(coder: NSCoder) { fatalError() }
                    }

                    """
                    c.replaceSubrange(fullRange, with: replacement)
                }
            }
            // The bogus placeholder for the now-genuinely-declared _SNClassifySoundRequest above
            // -- same "phantom auto-generated duplicate" pattern as CryptoKit's XWingMLKEM768X and
            // CoreML's __C_MLComputeDeviceProtocol this session; confirmed unreferenced elsewhere.
            c = c.replacingOccurrences(
                of: "public struct __C_SNClassifySoundRequest: Hashable, Codable, Sendable {}",
                with: "")
            c = c.replacingOccurrences(
                of: "public struct _SNClassifySoundRequest: Hashable, Sendable {}",
                with: "")

            // Fix: SNFileServer/SNFileItem/SNFileSystem/SNCopyFilesRequest/etc. (~20 classes) are
            // real native NSObject subclasses whose real ABI requires the full class-metadata
            // symbol suite (type metadata accessor, nominal type descriptor, class metadata base
            // offset, method lookup function, type metadata, __deallocating_deinit), but the
            // generator renders them with either no members at all beyond `override init()`, or
            // (SNMovieRemixFinalResult only) only `final` members -- and `final` members don't
            // need a vtable slot, so Swift elides the whole metadata suite including the method
            // lookup function. Confirmed via minimal repro (-enable-library-evolution
            // -language-mode 6, matching verify_public.py's flags): adding any single *non-final*
            // member forces Swift to materialize the metadata suite; a `private var` reproduces
            // exactly the required symbol set with no side effects, since it exports no public
            // symbol of its own. This was the "method lookup function for X" mystery documented
            // as an unresolved gap in the SNDetectSoundActionsRequest/SNDetectSoundRequest/
            // _SNClassifySoundRequest fix earlier this session.
            for name in ["SNFileServer", "SNFileItem", "SNFileSystem", "SNCopyFilesRequest",
                         "SNCorrelateAudioRequest", "SNDeleteFilesRequest",
                         "SNDiscoverFileServerRequest", "SNFileCopyingResult",
                         "SNFileDeletionResult", "SNFileListingResult",
                         "SNFileServerDiscoveryResult", "SNFileServerInfo",
                         "SNLanguageAlignedAVFuser", "SNListFilesRequest",
                         "SNMovieRemixDSPParameter", "SNMovieRemixRequest",
                         "SNMovieRemixSession", "SNSystemAudioAnalyzer", "_SNAudioFileAnalyzer"] {
                let withInit = "@objc(\(name)) @_fixed_layout open class \(name): NSObject {\n    public override init() { super.init() }\n"
                let withoutInit = "@objc(\(name)) @_fixed_layout open class \(name): NSObject {\n"
                if c.contains(withInit) {
                    c = c.replacingOccurrences(
                        of: withInit,
                        with: withInit + "    private var _typeMetadataAnchor: Int = 0\n")
                } else {
                    c = c.replacingOccurrences(
                        of: withoutInit,
                        with: withoutInit + "    private var _typeMetadataAnchor: Int = 0\n")
                }
            }
            c = c.replacingOccurrences(
                of: "@objc(SNMovieRemixFinalResult) @_fixed_layout open class SNMovieRemixFinalResult: NSObject {\n    public override init() { super.init() }\n",
                with: "@objc(SNMovieRemixFinalResult) @_fixed_layout open class SNMovieRemixFinalResult: NSObject {\n    public override init() { super.init() }\n    private var _typeMetadataAnchor: Int = 0\n")

            // Fix: the real ABI has `_OBJC_CLASS_$_SNKShotLabel`/`_OBJC_METACLASS_$_SNKShotLabel`
            // and the same pair for SNTimeDurationConstraint, but both names are already declared
            // as native Swift enums here (with separate, differently-named ObjC-bridging
            // companion classes) -- same "hidden private ObjC-bridging shadow class sharing a
            // public value type's runtime name" pattern as CoreML's MLModelStructure/
            // MLOptimizationHints fix this session.
            c += "\n@objc(SNKShotLabel) open class _SNKShotLabelObjCShadow: NSObject {}\n"
            c += "@objc(SNTimeDurationConstraint) open class _SNTimeDurationConstraintObjCShadow: NSObject {}\n"

            c += """


            open class AVAudioSession: NSObject {
                public struct Category: Hashable, RawRepresentable { public var rawValue: Swift.String; public init(rawValue: Swift.String) { self.rawValue = rawValue } }
                public struct Mode: Hashable, RawRepresentable { public var rawValue: Swift.String; public init(rawValue: Swift.String) { self.rawValue = rawValue } }
                public struct CategoryOptions: OptionSet, Sendable { public var rawValue: Swift.UInt; public init(rawValue: Swift.UInt) { self.rawValue = rawValue } }
            }
            """

            // Fix: the real ABI's generic `run<A>` overloads constrain `A`'s associated types
            // (`A.Element ==`, `A.Failure ==`) and the `runLocally` overloads' `any Publisher`
            // existential param constrains its associated types too (`Failure ==`, `Output ==`)
            // -- omitting these equality constraints changes the mangled generic signature, so
            // the generator's unconstrained defaults never match the real symbols.
            for (old, new) in [
                ("public func run<A>(_ arg1: CLAP.AudioRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.AudioSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: CLAP.AudioRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.AudioSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, Int64), A.Failure == Error { fatalError() }"),
                ("public func run<A>(_ arg1: CLAP.DetectorHeadRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.DetectorHeadSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: CLAP.DetectorHeadRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.DetectorHeadSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, Int64), A.Failure == Error { fatalError() }"),
                ("public func run<A>(_ arg1: CLAP.TextRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.TextSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: CLAP.TextRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.TextSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, Int64), A.Failure == Error { fatalError() }"),
                ("public func run<A>(_ arg1: ClosedCaptioningRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> ClosedCaptioningSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: ClosedCaptioningRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> ClosedCaptioningSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, CMTime), A.Failure == Error { fatalError() }"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Fix: the `runLocally` overloads' `any Publisher` existential param is already
            // generated with the correct same-type constraints (confirmed via debug tracing:
            // `any Publisher<Self.Failure == Error, Self.Output == AVAudioPCMBuffer>`), but the
            // later generic `stripConstrainedExistentialGenerics` pass (which runs on ALL
            // frameworks to strip invalid `any Protocol<X == Y>` syntax) blindly erases the whole
            // `<...>` clause since it contains `==` -- it doesn't know Publisher supports Swift's
            // primary-associated-type sugar (`any Publisher<Output, Failure>`), unlike the
            // Sequence/Collection/AsyncSequence family already special-cased via
            // `knownPrimaryAssociatedTypes`. Convert to the sugared positional form here, before
            // that pass runs, instead of extending the general-purpose table for one protocol.
            for (old, new) in [
                ("any Publisher<Self.Failure == Error, Self.Output == AVAudioPCMBuffer>",
                 "any Publisher<AVAudioPCMBuffer, Error>"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Fix: PubSub.AnySubject.fromCombine/toCombine's `any Subject<...>` existential
            // param/return has the same shape as the runLocally/Publisher fix above -- generated
            // with the correct constraints (`Self.Failure == B, ` + the `___SAME_TYPE_A___`
            // marker for the primary-associated-type placeholder, confirmed via debug tracing),
            // but stripConstrainedExistentialGenerics erases the whole clause since Subject
            // (like Publisher) isn't in the `knownPrimaryAssociatedTypes` table even though it
            // does support `any Subject<Output, Failure>` sugar. Convert directly, before both
            // the marker-resolution pass and the strip pass run.
            c = c.replacingOccurrences(
                of: "any Subject<Self.Failure == B, ___SAME_TYPE_A___>",
                with: "any Subject<A, B>")

            // Fix: GenericThrowingClosureAudioDataAnalysisReceiver is generated as a completely
            // empty protocol -- its one requirement (a generic `run` method) never made it into
            // the interface at all. Confirmed via `swift-demangle -expand`: the requirement is
            // `associatedtype Arg`/`associatedtype Result` plus `func run<A1>(_ arg1: Arg, _
            // arg2: A1.Type) throws -> Result where A1: DependencyADAMAudioDataReceiver`.
            c = c.replacingOccurrences(
                of: "public protocol GenericThrowingClosureAudioDataAnalysisReceiver {\n}",
                with: """
                public protocol GenericThrowingClosureAudioDataAnalysisReceiver {
                    associatedtype Arg
                    associatedtype Result
                    func run<A1>(_ arg1: Arg, _ arg2: A1.Type) throws -> Result where A1: DependencyADAMAudioDataReceiver
                }
                """)
            // Fix: AudioDataAnalysisProviderProtocol.withAudioDataAnalysis (and its
            // AudioDataAnalysisProvider concrete implementation) is missing a same-type
            // constraint tying its second generic param to the first's `Arg` associated type,
            // and its return type is erased to `Any` instead of the first param's `Result`
            // (confirmed via swift-demangle -expand: `<A, B where A: ...Receiver, B ==
            // A.Arg>(B, A) throws -> A.Result`).
            c = c.replacingOccurrences(
                of: "func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> Any where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver",
                with: "func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> GenericA.Result where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver, GenericB == GenericA.Arg")
            c = c.replacingOccurrences(
                of: "public func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> Any where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver { fatalError() }",
                with: "public func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> GenericA.Result where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver, GenericB == GenericA.Arg { fatalError() }")
            // Fix: toAnyAsyncIterator()/toAnyAsyncSequence() are real extensions this module adds
            // to the stdlib's AsyncIteratorProtocol/AsyncSequence (confirmed via swift-demangle:
            // "(extension in SoundAnalysis):Swift.AsyncIteratorProtocol.toAnyAsyncIterator() ->
            // SoundAnalysis.AnyAsyncIterator<A.Element>"), but the generator never emits them at
            // all.
            c += """

            extension AsyncIteratorProtocol {
                public func toAnyAsyncIterator() -> AnyAsyncIterator<Element> { fatalError() }
            }
            extension AsyncSequence {
                public func toAnyAsyncSequence() -> AnyAsyncSequence<Element> { fatalError() }
            }
            """
        }

        if parser.defaultModule == "TabularData" {
            // Fix: ShapedData<A>'s real ABI conditionally conforms to Hashable/Equatable
            // (confirmed via swift-demangle: separate constrained conformance descriptors). The
            // generator already emits the correct conditional "where A: Equatable"/"where A:
            // Hashable" extensions with real hash(into:)/==/hashValue bodies, but ALSO declares
            // Hashable unconditionally on the struct's own header with a DUPLICATE unconditional
            // hash(into:)/== inside the base body -- redundant with (and ambiguous against) the
            // conditional extension members. Removing the unconditional header conformance and
            // duplicate members, and restating the conformance on the extensions (same gap
            // already fixed for StoreKit's VerificationResult<A> and elsewhere this session).
            c = c.replacingOccurrences(
                of: "public struct ShapedData<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct ShapedData<A>: Codable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "extension ShapedData where A: Equatable {",
                with: "extension ShapedData: Equatable where A: Equatable {")
            // Unlike Column/ColumnSlice/DiscontiguousColumnSlice, the generator never emits a
            // separate "extension ShapedData where A: Hashable" -- hash(into:) only ever exists
            // as a duplicate, unconditional member inside the base struct body (removed above
            // along with Hashable on the header). Extract it into a new conditional extension
            // via a structural span match rather than an exact adjacent-member literal, since
            // member order inside the struct body is nondeterministic across generator runs
            // (same root cause as Speech's TimeRangeAttribute/ConfidenceAttribute fix).
            if let structRe = try? NSRegularExpression(
                pattern: "public struct ShapedData<A>: Codable, @unchecked Sendable \\{([\\s\\S]*?)\\n\\}\\n"),
               let m = structRe.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
               let bodyRange = Range(m.range(at: 1), in: c),
               let fullRange = Range(m.range, in: c) {
                let body = String(c[bodyRange])
                let newBody = body.replacingOccurrences(
                    of: "\n    public func hash(into hasher: inout Hasher) { fatalError() }",
                    with: "")
                if newBody != body {
                    let replacement = "public struct ShapedData<A>: Codable, @unchecked Sendable {\(newBody)\n}\nextension ShapedData: Hashable where A: Hashable {\n    public func hash(into hasher: inout Hasher) { fatalError() }\n    public var hashValue: Swift.Int { fatalError() }\n}\n"
                    c.replaceSubrange(fullRange, with: replacement)
                }
            }

            // Fix: same unconditional-Hashable-header + duplicate-hash(into:)/== gap for
            // ColumnSlice<A> and DiscontiguousColumnSlice<A> -- each already has correct
            // conditional "where A: Equatable"/"where A: Hashable" extensions with real bodies.
            for name in ["ColumnSlice", "DiscontiguousColumnSlice"] {
                c = c.replacingOccurrences(
                    of: "    public func hash(into hasher: inout Hasher) { fatalError() }\n    public static func ==(_ lhs: \(name)<A>, _ rhs: \(name)<A>) -> Bool { fatalError() }\n}\n",
                    with: "}\n")
                c = c.replacingOccurrences(
                    of: "extension \(name) where A: Equatable {",
                    with: "extension \(name): Equatable where A: Equatable {")
                c = c.replacingOccurrences(
                    of: "extension \(name) where A: Hashable {",
                    with: "extension \(name): Hashable where A: Hashable {")
            }
            c = c.replacingOccurrences(
                of: "public struct ColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Hashable, MutableCollection, OptionalColumnProtocol, RandomAccessCollection, @unchecked Sendable, Sequence {",
                with: "public struct ColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, MutableCollection, OptionalColumnProtocol, RandomAccessCollection, @unchecked Sendable, Sequence {")
            c = c.replacingOccurrences(
                of: "public struct DiscontiguousColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Hashable, MutableCollection, OptionalColumnProtocol, @unchecked Sendable, Sequence {",
                with: "public struct DiscontiguousColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, MutableCollection, OptionalColumnProtocol, @unchecked Sendable, Sequence {")

            // Fix: Column<A>'s real ABI conditionally conforms to Decodable/Encodable/Equatable/
            // Hashable (confirmed via swift-demangle), but none of the existing per-bound
            // extensions restate the conformance -- same conformance-restatement gap.
            for proto in ["Decodable", "Encodable", "Equatable", "Hashable"] {
                c = c.replacingOccurrences(
                    of: "extension Column where A: \(proto) {",
                    with: "extension Column: \(proto) where A: \(proto) {")
            }

            // Fix: DataFrame.init<A: Sequence>(columns:) where A.Element == AnyColumn is real
            // ABI (confirmed via swift-demangle) but never rendered at all.
            c = c.replacingOccurrences(
                of: "public struct DataFrame: CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, DataFrameProtocol, ExpressibleByDictionaryLiteral, Hashable {",
                with: "public struct DataFrame: CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, DataFrameProtocol, ExpressibleByDictionaryLiteral, Hashable {\n    public init<GenericA>(columns: GenericA) where GenericA: Swift.Sequence, GenericA.Element == AnyColumn { fatalError() }")

            // Fix: {CSV,JSON}ReadingOptions.addDateParseStrategy<A>(_:) is missing the real ABI's
            // ParseInput/ParseOutput associated-type constraints (confirmed via swift-demangle:
            // "A.ParseInput == Swift.String, A.ParseOutput == Foundation.Date").
            c = c.replacingOccurrences(
                of: "public func addDateParseStrategy<GenericA>(_ arg1: GenericA) -> () where GenericA: ParseStrategy {}",
                with: "public func addDateParseStrategy<GenericA>(_ arg1: GenericA) -> () where GenericA: ParseStrategy, GenericA.ParseInput == Swift.String, GenericA.ParseOutput == Foundation.Date {}")

            // Fix: DiscontiguousColumnSlice's UnboundedRange subscript (`x[...]`) IS already
            // rendered, but as `subscript(_ arg1: @escaping (UnboundedRange_) -> ()) -> ...`
            // instead of the correct `subscript(bounds: UnboundedRange) -> ...` -- the shorthand
            // "..." subscript syntax apparently got parsed as if UnboundedRange were a closure
            // parameter. Confirmed via a minimal repro that the plain, non-closure form is what
            // produces the exact required mangled shape.
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: @escaping (UnboundedRange_) -> ()) -> DiscontiguousColumnSlice<A> { get { fatalError() } set {} }",
                with: "public subscript(bounds: UnboundedRange) -> DiscontiguousColumnSlice<A> { get { fatalError() } set {} }")

            // Fix: ColumnProtocol/OptionalColumnProtocol's arithmetic/comparison operator
            // overloads render their generic associated-type placeholder (Self.Element /
            // Self.WrappedElement) as a bare unconstrained "Any" -- both in the parameter type
            // and in the "Column<Any>" return type -- rather than the real associated type,
            // which changes the mangled generic signature entirely (confirmed via swift-demangle
            // and a minimal repro). Also, ColumnProtocol's Comparable extension only rendered
            // != and == and dropped </<=/>/>= entirely.
            //
            // A minimal repro further showed the (Self, Self.Element)/(Self.Element, Self)
            // overloads for the AdditiveArithmetic bound specifically need to live in a
            // *different* extension shape than the (Self, Self) overload: an unconstrained
            // "extension ColumnProtocol { ... where Self.Element: AdditiveArithmetic }" (the
            // bound restated per-function, not on the extension) mangles to
            // "ColumnProtocol.+ infix< where ...>(A, A.Element)", matching the real ABI, while
            // the same overload declared inside "extension ColumnProtocol where Self.Element:
            // AdditiveArithmetic" mangles to the WRONG "ColumnProtocol< where ...>.+ infix(...)"
            // shape instead. All other bounds (BinaryInteger/Comparable/FloatingPoint/Numeric)
            // do NOT have this quirk -- every overload for those bounds (including the mixed
            // Self/Self.Element ones) already mangles correctly from the plain bound extension,
            // confirmed via a separate minimal repro.
            //
            // Member order within each of these generated extension bodies is nondeterministic
            // across generator runs (same root cause as Speech's TimeRangeAttribute/
            // ConfidenceAttribute fix), so the AdditiveArithmetic restructuring below extracts
            // the whole extension body via a structural span match and edits it with
            // order-independent `contains`/`replacingOccurrences` calls, rather than assuming a
            // fixed member sequence. The non-restructuring fixes (BinaryInteger/FloatingPoint/
            // Numeric/Comparable) are simple global per-line replacements, which are inherently
            // order-independent since they don't depend on adjacent-line context.
            if let re = try? NSRegularExpression(pattern: "extension ColumnProtocol where Self\\.Element: AdditiveArithmetic \\{([\\s\\S]*?)\\n\\}\\n"),
               let m = re.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
               let bodyRange = Range(m.range(at: 1), in: c),
               let fullRange = Range(m.range, in: c) {
                var body = String(c[bodyRange])
                var extracted: [String] = []
                for (old, new) in [
                    ("    public static func +(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                     "    public static func +(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                    ("    public static func +(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                     "    public static func +(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                    ("    public static func -(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                     "    public static func -(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                    ("    public static func -(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                     "    public static func -(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                ] {
                    if body.contains(old) {
                        body = body.replacingOccurrences(of: "\n" + old, with: "")
                        extracted.append(new)
                    }
                }
                body = body.replacingOccurrences(
                    of: "    public static func +(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                    with: "    public static func +(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }")
                body = body.replacingOccurrences(
                    of: "    public static func -(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                    with: "    public static func -(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }")
                let replacement = "extension ColumnProtocol {\n\(extracted.joined(separator: "\n"))\n}\nextension ColumnProtocol where Self.Element: AdditiveArithmetic {\(body)\n}\n"
                c.replaceSubrange(fullRange, with: replacement)
            }
            for (old, new) in [
                ("    public static func /(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                 "    public static func /(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> { fatalError() }"),
                ("    public static func /(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func /(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func /(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func /(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func *(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func *(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func *(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                 "    public static func *(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> { fatalError() }"),
                ("    public static func *(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func *(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func !=(_ arg1: Self, _ arg2: Any) -> [Swift.Bool] { return [] }",
                 "    public static func !=(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }"),
                ("    public static func !=(_ arg1: Any, _ arg2: Self) -> [Swift.Bool] { return [] }",
                 "    public static func !=(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }"),
                ("    public static func == (lhs: Self, rhs: Any) -> [Swift.Bool] { fatalError() }",
                 "    public static func == (lhs: Self, rhs: Self.Element) -> [Swift.Bool] { fatalError() }"),
                ("    public static func == (lhs: Any, rhs: Self) -> [Swift.Bool] { fatalError() }",
                 "    public static func == (lhs: Self.Element, rhs: Self) -> [Swift.Bool] { fatalError() }"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Comparable's real ABI also needs </<=/>/>=, entirely missing from the generator's
            // output -- inserted right after the extension header so this doesn't depend on
            // where the existing != /== members happen to land.
            c = c.replacingOccurrences(
                of: "extension ColumnProtocol where Self.Element: Comparable {\n",
                with: """
                extension ColumnProtocol where Self.Element: Comparable {
                    public static func <(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func <(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }
                    public static func <=(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func <=(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }
                    public static func >(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func >(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }
                    public static func >=(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func >=(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }

                """)

            // Fix: the 10 top-level generic operators bridging ColumnProtocol<->
            // OptionalColumnProtocol render their shared-element constraint as a bogus
            // "Any: Numeric, Any == Any" (or similarly nonsensical) requirement instead of
            // "A.Element: Numeric, A.Element == B.WrappedElement" (or the WrappedElement/Element
            // mirror), and return "Column<Any>" instead of "Column<A.Element>"/
            // "Column<A.WrappedElement>" -- same generic-placeholder-resolved-as-Any gap,
            // confirmed via a minimal repro to produce the exact required mangled shape. Note
            // the double space after the first "where" clause comma -- that's how postProcess's
            // multi-constraint "where" rendering actually prints it for these functions.
            // "/" needs TWO real ABI symbols per direction (BinaryInteger- and FloatingPoint-
            // bound), but the generator only ever emits ONE stub per direction (its raw,
            // unfixed "Any"-typed text is byte-identical regardless of bound, so there's only
            // one line to find) -- the single old declaration is replaced with BOTH bound
            // variants as two separate overloads (legal, since a caller's concrete A.Element
            // can't simultaneously satisfy both bounds, so there's no ambiguity).
            struct TopLevelOp { let op: String; let aProto: String; let bProto: String; let aAssoc: String; let bAssoc: String; let bounds: [String] }
            let topLevelOps: [TopLevelOp] = [
                TopLevelOp(op: "*", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["Numeric"]),
                TopLevelOp(op: "*", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["Numeric"]),
                TopLevelOp(op: "+", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "+", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "-", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "-", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "/", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["BinaryInteger", "FloatingPoint"]),
                TopLevelOp(op: "/", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["BinaryInteger", "FloatingPoint"]),
            ]
            for entry in topLevelOps {
                let replacements = entry.bounds.map { bound in
                    "public func \(entry.op)<A, B>(_ arg1: A, _ arg2: B) -> Column<A.\(entry.aAssoc)> where A: \(entry.aProto), B: \(entry.bProto), A.\(entry.aAssoc): \(bound), A.\(entry.aAssoc) == B.\(entry.bAssoc) { fatalError() }"
                }.joined(separator: "\n")
                c = c.replacingOccurrences(
                    of: "public func \(entry.op)<A, B>(_ arg1: A, _ arg2: B) -> Column<Any> where A: \(entry.aProto),  B: \(entry.bProto) { fatalError() }",
                    with: replacements)
            }

            // Fix: OptionalColumnProtocol's AdditiveArithmetic extension already types its
            // mixed Self/Self.WrappedElement overloads correctly, but declares them inside the
            // bound "where Self.WrappedElement: AdditiveArithmetic" extension -- same wrong-
            // mangled-shape issue as ColumnProtocol's mixed overloads, since they already carry
            // the bound as a redundant per-function where clause and just need an unconstrained
            // enclosing extension. The (Self, Self) +/- overloads ARE real ABI too (confirmed via
            // swift-demangle, same "ColumnProtocol< where ...>.op infix(A, A)" bound-extension
            // shape as ColumnProtocol's own (Self, Self) overloads) and are already correctly
            // typed, so they stay behind in the original bound extension. Same order-independent
            // structural extraction as ColumnProtocol's AdditiveArithmetic fix above.
            if let re = try? NSRegularExpression(pattern: "extension OptionalColumnProtocol where Self\\.WrappedElement: AdditiveArithmetic \\{([\\s\\S]*?)\\n\\}\\n"),
               let m = re.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
               let bodyRange = Range(m.range(at: 1), in: c),
               let fullRange = Range(m.range, in: c) {
                var body = String(c[bodyRange])
                var extracted: [String] = []
                for old in [
                    "    public static func +(_ arg1: Self, _ arg2: Self.WrappedElement) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                    "    public static func -(_ arg1: Self, _ arg2: Self.WrappedElement) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                    "    public static func +(_ arg1: Self.WrappedElement, _ arg2: Self) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                    "    public static func -(_ arg1: Self.WrappedElement, _ arg2: Self) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                ] {
                    if body.contains(old) {
                        body = body.replacingOccurrences(of: "\n" + old, with: "")
                        extracted.append(old)
                    }
                }
                let replacement = "extension OptionalColumnProtocol {\n\(extracted.joined(separator: "\n"))\n}\nextension OptionalColumnProtocol where Self.WrappedElement: AdditiveArithmetic {\(body)\n}\n"
                c.replaceSubrange(fullRange, with: replacement)
            }
        }

        if parser.defaultModule == "StoreKit" {

            // Fix: Storefront._locale's real ABI additionally needs a "read" coroutine accessor
            // (confirmed via swift-demangle: "Storefront._locale.read"), alongside the getter the
            // generator already renders correctly. A plain `get` never produces one -- a minimal
            // repro showed only an explicit `_read { ... }` accessor body (the underscored,
            // library-internal coroutine-accessor syntax) makes the compiler synthesize both the
            // getter thunk AND the read accessor from a single declaration.
            c = c.replacingOccurrences(
                of: "public var _locale: Locale { get { fatalError() } }",
                with: "public var _locale: Locale { _read { fatalError() } }")

            // Fix: StoreProductManager.{CollectionObserver,SingleObserver,SubscriptionGroupObserver}
            // manually fake a "_proj_X" placeholder property for the real "$state"/"$error"/
            // "$storage" property-wrapper projections instead of using @Published (whose
            // projectedValue is compiler-synthesized and can't be spelled directly -- "$state" is
            // not a legal manually-declared identifier). Real ABI for each "$foo" has ONLY a
            // getter + property descriptor, no setter/modify, which a plain `@Published var` also
            // doesn't produce (that gives get+set+modify for both the property and its
            // projection) -- `private(set)` on the @Published property is what narrows it down to
            // match (confirmed via a minimal repro).
            // Each "_proj_X"/real-property pair is removed/rewritten as two INDEPENDENT
            // replacements, not one combined adjacent-lines match -- CollectionObserver declares
            // both "_proj_error" and "_proj_storage" back-to-back BEFORE either real property
            // (not interleaved pairwise), so a match requiring the two lines to be adjacent only
            // happened to work for SingleObserver/SubscriptionGroupObserver (which each have only
            // one such property).
            c = c.replacingOccurrences(
                of: "public final var _proj_storage: Published<[StoreProductManager.CollectionObserver.Storage]>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var storage: [StoreProductManager.CollectionObserver.Storage] { get { return [] } }",
                with: "@Published public final private(set) var storage: [StoreProductManager.CollectionObserver.Storage] = []")
            c = c.replacingOccurrences(
                of: "public final var _proj_error: Published<Error?>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var error: Error? { get { return nil } }",
                with: "@Published public final private(set) var error: Error? = nil")
            c = c.replacingOccurrences(
                of: "public final var _proj_state: Published<SingleObserver.Storage>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var state: SingleObserver.Storage { get { fatalError() } }",
                with: "@Published public final private(set) var state: SingleObserver.Storage = .loading")
            c = c.replacingOccurrences(
                of: "public final var _proj_state: Published<SubscriptionGroupObserver.Storage>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var state: SubscriptionGroupObserver.Storage { get { fatalError() } }",
                with: "@Published public final private(set) var state: SubscriptionGroupObserver.Storage = .loading")

            // Fix: VerificationResult<A>'s real ABI conditionally conforms to Hashable/Equatable
            // (confirmed via swift-demangle: separate "<A where A: Swift.Hashable> ... :
            // Swift.Hashable" and "<A where A: Swift.Equatable> ... : Swift.Equatable" conformance
            // descriptors), but the generator declares Hashable unconditionally on the enum's own
            // header, and the existing "where A: Equatable" extension never restates the
            // conformance at all -- same conformance-restatement gap fixed elsewhere this session,
            // plus needing to move Hashable off the base declaration entirely (confirmed via a
            // minimal repro: an unconditional base Hashable conformance produces a different,
            // unconstrained conformance-descriptor shape even when a conditional Equatable
            // extension coexists).
            c = c.replacingOccurrences(
                of: "public enum VerificationResult<A>: Hashable, @unchecked Sendable {",
                with: "public enum VerificationResult<A>: @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "extension VerificationResult where A: CustomDebugStringConvertible {",
                with: "extension VerificationResult: CustomDebugStringConvertible where A: CustomDebugStringConvertible {")
            c = c.replacingOccurrences(
                of: "extension VerificationResult where A: Equatable {\n    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }\n}",
                with: "extension VerificationResult: Equatable where A: Equatable {\n    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }\n}\nextension VerificationResult: Hashable where A: Hashable {\n    public func hash(into hasher: inout Hasher) { }\n    public var hashValue: Int { 0 }\n}")

            // Fix: several real ABI members are entirely missing from the generator's output
            // (confirmed via swift-demangle, each verified via a minimal repro to produce an
            // exact match).
            c += """

extension Foundation.DateComponents {
    public init(subscriptionPeriod: Product.SubscriptionPeriod) { self.init() }
}
extension Foundation.Data {
    public init?(_ arg1: BackingValue) { nil }
}
extension Foundation.Date {
    public init?(_ arg1: BackingValue) { nil }
}
extension Foundation.UUID {
    public init?(_ arg1: BackingValue) { nil }
}
extension Foundation.Locale.Currency {
    public init?(_ arg1: BackingValue) { nil }
}
extension Swift.BinaryFloatingPoint {
    public init?(_ arg1: BackingValue) { nil }
}
extension Swift.BinaryInteger {
    public init?(_ arg1: BackingValue) { nil }
}

"""
            // Fix: BackingValue.value(atKeyPath:sentinel:transform:)'s `sentinel` param renders
            // with an added `@escaping` -- but the real ABI (confirmed via swift-demangle) has no
            // ownership/escaping marker on it at all, matching the "erroneously-added @escaping"
            // gap already fixed for MetalPerformanceShadersGraph's reorderInputsAndOutputs.
            c = c.replacingOccurrences(
                of: "sentinel: @escaping @autoclosure () -> GenericA",
                with: "sentinel: @autoclosure () -> GenericA")

            // Fix: many properties across StoreKit render as plain synchronous computed
            // properties, but their real ABI needs "async function pointer" symbols -- same
            // "{ get async }" gap already fixed for Translation/Vision/Speech (confirmed via a
            // minimal repro that only a `{ get async }` accessor produces those). All occurrence
            // counts verified via grep -c to match the stub list's entry count exactly before
            // blanket-replacing.
            for (from, to) in [
                ("public var latestTransaction: VerificationResult<Transaction>? { get { return nil } }",
                 "public var latestTransaction: VerificationResult<Transaction>? { get async { return nil } }"),
                ("public static var _accountType: AppStore.AccountType { get { fatalError() } }",
                 "public static var _accountType: AppStore.AccountType { get async { fatalError() } }"),
                ("public static var canMakePaymentsAsync: Swift.Bool { get { fatalError() } }",
                 "public static var canMakePaymentsAsync: Swift.Bool { get async { fatalError() } }"),
                ("public static var ageRatingCode: Swift.Int? { get { return nil } }",
                 "public static var ageRatingCode: Swift.Int? { get async { return nil } }"),
                ("public static var canMakePaymentsAsyncUsableFromInline: Swift.Bool { get { fatalError() } }",
                 "public static var canMakePaymentsAsyncUsableFromInline: Swift.Bool { get async { fatalError() } }"),
                ("public static var shared: VerificationResult<AppTransaction> { get { fatalError() } }",
                 "public static var shared: VerificationResult<AppTransaction> { get async { fatalError() } }"),
                ("public static var canOpen: Swift.Bool { get { fatalError() } }",
                 "public static var canOpen: Swift.Bool { get async { fatalError() } }"),
                ("public static var canPresent: Swift.Bool { get { fatalError() } }",
                 "public static var canPresent: Swift.Bool { get async { fatalError() } }"),
                ("public static var isEligible: Swift.Bool { get { fatalError() } }",
                 "public static var isEligible: Swift.Bool { get async { fatalError() } }"),
                ("public static var eligibleURLs: [URL]? { get { return nil } }",
                 "public static var eligibleURLs: [URL]? { get async { return nil } }"),
                ("public static var isAvailable: Swift.Bool { get { fatalError() } }",
                 "public static var isAvailable: Swift.Bool { get async { fatalError() } }"),
                ("public var currentEntitlement: VerificationResult<Transaction>? { get { return nil } }",
                 "public var currentEntitlement: VerificationResult<Transaction>? { get async { return nil } }"),
                ("public static var currentOrder: [Product.PromotionInfo] { get { return [] } }",
                 "public static var currentOrder: [Product.PromotionInfo] { get async { return [] } }"),
                ("public var contingentPrices: [Product.ContingentPriceInfo] { get { return [] } }",
                 "public var contingentPrices: [Product.ContingentPriceInfo] { get async { return [] } }"),
                ("public var isEligibleForIntroOffer: Swift.Bool { get { fatalError() } }",
                 "public var isEligibleForIntroOffer: Swift.Bool { get async { fatalError() } }"),
                ("public var status: [Product.SubscriptionInfo.Status] { get { return [] } }",
                 "public var status: [Product.SubscriptionInfo.Status] { get async { return [] } }"),
                ("public static var current: Storefront? { get { return nil } }",
                 "public static var current: Storefront? { get async { return nil } }"),
                ("public var subscriptionStatus: Product.SubscriptionInfo.Status? { get { return nil } }",
                 "public var subscriptionStatus: Product.SubscriptionInfo.Status? { get async { return nil } }"),
            ] {
                c = c.replacingOccurrences(of: from, with: to)
            }

            // Fix: Message.acknowledge(bundleID:message:offer:overrideAuditToken:logKey:) and
            // Product.PurchaseOption.clientOverride(auditToken:) are real ABI (confirmed via
            // swift-demangle) but never rendered at all; both take/pass a real `audit_token_t`
            // (from Darwin, confirmed resolvable via a minimal repro) not otherwise imported here.
            c = c.replacingOccurrences(
                of: "public struct Message: Hashable {",
                with: "public struct Message: Hashable {\n    public static func acknowledge(bundleID: Swift.String?, message: Message.Reason, offer: Product.SubscriptionOffer, overrideAuditToken: audit_token_t?, logKey: Swift.String) async {}")
            // Product's own PurchaseOption is a distinct nested type from the other
            // (identically-textually-headed) PurchaseOption elsewhere in this file -- anchor on
            // Product's own unique header via a lazy multiline span, same technique as
            // MetricKit's baseUnit fix.
            if let regex = try? NSRegularExpression(
                pattern: "(public struct Product: CustomDebugStringConvertible, Hashable, Identifiable \\{[\\s\\S]*?public struct PurchaseOption: CustomDebugStringConvertible, Hashable \\{\\n)",
                options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "$1        public static func clientOverride(auditToken: audit_token_t) -> PurchaseOption { fatalError() }\n")
            }
            c = c.replacingOccurrences(
                of: "import Foundation",
                with: "import Darwin\nimport Foundation")
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
            // Fix: PoseProviding's real ABI also has associated conformance descriptors for
            // PoseJointName: RawRepresentable/Encodable and PoseJointsGroupName: RawRepresentable
            // (confirmed via swift-demangle) that the current bounds (Decodable/Hashable and
            // CaseIterable respectively) don't cover.
            c = c.replacingOccurrences(
                of: "associatedtype PoseJointName: Decodable, Hashable",
                with: "associatedtype PoseJointName: Decodable, Encodable, Hashable, RawRepresentable")
            c = c.replacingOccurrences(
                of: "associatedtype PoseJointsGroupName: CaseIterable",
                with: "associatedtype PoseJointsGroupName: CaseIterable, RawRepresentable")
            // Fix: GenerateIterativeSegmentationRequest.init(seedScribbleBuffer:_:) and
            // OpticalFlowObservation/PixelBufferObservation's init?(_:VNPixelBufferObservation)
            // all render their sole class-typed parameter with an explicit `borrowing` keyword
            // copied verbatim from the swiftinterface's printed ownership annotation -- same
            // "the annotation reflects the implicit default convention, not a real source-level
            // keyword" gap already fixed for MetalPerformanceShadersGraph's Executables.init:
            // re-emitting it literally adds an "h" ownership-convention marker the real mangled
            // symbols don't have (confirmed via a minimal repro).
            c = c.replacingOccurrences(
                of: "seedScribbleBuffer: borrowing CVReadOnlyPixelBuffer",
                with: "seedScribbleBuffer: CVReadOnlyPixelBuffer")
            c = c.replacingOccurrences(
                of: "init?(_ arg1: borrowing VNPixelBufferObservation) { fatalError() }",
                with: "init?(_ arg1: VNPixelBufferObservation) { fatalError() }")
            // Fix: DownloadableAssetsRequest.assetStatus (and its GenerateIterativeSegmentationRequest
            // conformance) render as plain synchronous computed properties, but their real ABI
            // needs "async function pointer" symbols -- same "{ get async }" gap already fixed
            // for Translation's isReady/supportedLanguages (confirmed via a minimal repro that
            // only a `{ get async }` accessor produces those).
            c = c.replacingOccurrences(
                of: "var assetStatus: DownloadableAssetsRequestStatus { get }",
                with: "var assetStatus: DownloadableAssetsRequestStatus { get async }")
            c = c.replacingOccurrences(
                of: "public final var assetStatus: DownloadableAssetsRequestStatus { get { fatalError() } }",
                with: "public final var assetStatus: DownloadableAssetsRequestStatus { get async { fatalError() } }")
            // Fix: VisionRequestIntrospectionManager.LogLevel's real ABI has a standalone,
            // hand-written `>=` operator (confirmed via swift-demangle: "static ...LogLevel.>=
            // infix" -- a minimal repro shows Comparable's synthesized default `>=`/`<=`/`>` are
            // plain stdlib protocol-extension methods with no per-conformer ABI symbol at all, so
            // this can't be from Comparable conformance; it must be a real, separate declaration),
            // but the generator never rendered it.
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: LogLevel, _ rhs: LogLevel) -> Bool { fatalError() }\n    }\n    public struct VisionRequestEntry:",
                with: "public static func ==(_ lhs: LogLevel, _ rhs: LogLevel) -> Bool { fatalError() }\n        public static func >= (lhs: LogLevel, rhs: LogLevel) -> Bool { fatalError() }\n    }\n    public struct VisionRequestEntry:")
            // Fix: Locale.Language.encodeCustom(to:)/createProperty(from:) are real ABI (confirmed
            // via swift-demangle) but never rendered at all. Neither has a protocol-conformance-
            // descriptor or witness-table symbol alongside it, so they're plain free-standing
            // members of a retroactive extension, not a protocol requirement -- add them directly
            // (confirmed via a minimal repro to produce an exact match).
            c += """

extension Locale.Language {
    public func encodeCustom(to encoder: Swift.Encoder) throws {}
    public static func createProperty(from: Any) throws -> Locale.Language { fatalError() }
}

"""
            // Accepted, documented-unfixable gap (4 remaining stubs): Serialization.decode/
            // encode and VisionInferenceProvider.requestOneShotInternal all reference
            // XPC.XPCCodableObject, and the real ABI genuinely mangles it as belonging to module
            // XPC -- but this SDK's real XPC module doesn't export that type at all (confirmed:
            // `import XPC; XPC.XPCCodableObject` fails to resolve even in isolation). Our local
            // opaque-struct fallback for it mangles under Vision's own module instead, which
            // can't be changed from declaration syntax alone. Forcing the correct module-
            // qualified mangling would require pulling "XPC" out of verify_public.py's
            // SYSTEM_MODULES (so a local per-target stub gets built instead of resolving the
            // real system module) and hand-populating that stub with XPCCodableObject -- but XPC
            // is shared with Network, which genuinely depends on the REAL module's XPCDictionary
            // (confirmed still resolving today), so a global SYSTEM_MODULES change would silently
            // swap Network's real XPC resolution for an empty one too. Left as-is rather than
            // diverging from real-module groundtruth for a 4-stub gain.
        }

        if parser.defaultModule == "Combine" {
            // Dozens of Publishers.X<...> types (CombineLatest, Zip, Merge, Drop, Retry, ...)
            // conditionally conform to Equatable in the real ABI (confirmed via each type's own
            // conformance descriptor), but the generator only emits the bare default-
            // implementation extension for the `==` witness without restating
            // "Publishers.X: Equatable" as the actual conformance -- same gap fixed for Charts'
            // result-builder types and HealthKit's CodableBox family in prior commits, just
            // recurring identically ~30 times here. Handled generally (only add the conformance
            // when EVERY constraint in the where-clause is an Equatable bound) rather than
            // per-name, since a per-name list would need constant upkeep as Publishers grows.
            if let regex = try? NSRegularExpression(pattern: "extension Publishers\\.(\\w+) where ([^{]+)\\{") {
                let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                var replacements: [(Range<String.Index>, String)] = []
                var candidatesByName: [String: [(range: Range<String.Index>, clause: String, hasDottedConstraint: Bool)]] = [:]
                for m in regex.matches(in: c, options: [], range: nsRange) {
                    guard let fullRange = Range(m.range, in: c),
                          let nameRange = Range(m.range(at: 1), in: c),
                          let clauseRange = Range(m.range(at: 2), in: c) else { continue }
                    let name = String(c[nameRange])
                    let clause = String(c[clauseRange])
                    let constraints = clause.trimmingCharacters(in: .whitespaces)
                        .components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    guard !constraints.isEmpty, constraints.allSatisfy({ $0.hasSuffix(": Equatable") }) else { continue }
                    let hasDotted = constraints.contains { $0.dropLast(": Equatable".count).contains(".") }
                    candidatesByName[name, default: []].append((fullRange, clause, hasDotted))
                }
                // Swift forbids two conformances to the same protocol on one type even under
                // different conditional bounds -- when a type has more than one all-Equatable
                // extension (e.g. Publishers.Sequence has both "A: Equatable" and the unrelated,
                // non-conforming "A.Element: Equatable" default-implementation block), only the
                // bare-param form matches the real conformance descriptor's own bound; prefer it.
                for (name, candidates) in candidatesByName {
                    let chosen = candidates.count > 1 ? candidates.filter { !$0.hasDottedConstraint } : candidates
                    for c2 in chosen {
                        replacements.append((c2.range, "extension Publishers.\(name): Equatable where \(c2.clause){"))
                    }
                }
                for (range, replacement) in replacements.sorted(by: { $0.0.lowerBound > $1.0.lowerBound }) {
                    c.replaceSubrange(range, with: replacement)
                }
            }
        }

        if parser.defaultModule == "HealthKit" {
            // Fix: the demangler renders a metatype-of-composition ("(NSObject &
            // HKDataCacheProviding).Type") as "NSObject & HKDataCacheProviding.Type", which
            // parses as "NSObject & (HKDataCacheProviding.Type)" — invalid, since a protocol
            // composition member can't itself be a metatype. Add the missing parens.
            c = c.replacingOccurrences(
                of: "NSObject & HKDataCacheProviding.Type",
                with: "(NSObject & HKDataCacheProviding).Type")

            // CodableBox<A>/CodableBoxArray<A>/CodableBoxDictionary<A, B> each conditionally
            // conform to Equatable/Hashable (confirmed via their real conformance descriptors),
            // but the generator only emits the bare default-implementation extension without
            // restating "X: Equatable"/"X: Hashable" as the actual conformance -- same gap as
            // the Charts result-builder types fixed in prior commits.
            for (type, param) in [("CodableBox", "A"), ("CodableBoxArray", "A"), ("CodableBoxDictionary", "B"), ("OptionalCodableBox", "A")] {
                c = c.replacingOccurrences(
                    of: "extension \(type) where \(param): Equatable {",
                    with: "extension \(type): Equatable where \(param): Equatable {")
                c = c.replacingOccurrences(
                    of: "extension \(type) where \(param): Hashable {",
                    with: "extension \(type): Hashable where \(param): Hashable {")
            }
            // These box types generically wrap a Codable payload -- the boxed type parameter
            // itself is Codable-constrained on the real struct declaration, not just where the
            // generic-conditional Equatable/Hashable extensions apply. Missing that struct-level
            // bound changes the mangled generic signature of every member (confirmed via a
            // minimal repro: "<A>" vs "<A: Codable>" mangles CodableBox's Hashable extension's
            // hash(into:) as ...SHRzlE... vs the real ABI's ...SHRzrlE...), so every member
            // stayed a stub even once the extension's own conformance/header matched.
            c = c.replacingOccurrences(of: "public struct CodableBox<A>: Codable, DefaultEncodable {", with: "public struct CodableBox<A: Codable>: Codable, DefaultEncodable {")
            c = c.replacingOccurrences(of: "public struct CodableBoxArray<A>: Codable, DefaultEncodable {", with: "public struct CodableBoxArray<A: Codable>: Codable, DefaultEncodable {")
            c = c.replacingOccurrences(of: "public struct CodableBoxDictionary<A: Hashable, B>: Codable, DefaultEncodable {", with: "public struct CodableBoxDictionary<A: Hashable, B: Codable>: Codable, DefaultEncodable {")
            c = c.replacingOccurrences(of: "public struct OptionalCodableBox<A>: Codable {", with: "public struct OptionalCodableBox<A: Codable>: Codable {")
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
            // (This still leaves each class's `results` getter stubbed for ABI-comparison
            // purposes -- the real declaration's opaque `some Sendable & AsyncSequence` return
            // type conceals whatever the real, unreproducible concrete backing type is; our
            // concrete `AsyncStream<Result>` is necessary for this to compile and conform at all,
            // but produces a different, non-opaque mangled shape. Accepted, same
            // "opaque-return-type" category as other frameworks' unfixable stubs this session.)
            c = c.replacingOccurrences(
                of: "    public final var results: some Sendable & AsyncSequence { get { return AsyncStream<Never> { _ in } } }",
                with: "    public final var results: Results { get { fatalError() } }")

            // Fix: AttributeScopes.SpeechAttributes.confidence/timeRange's real ABI type is a
            // BARE top-level `Speech.ConfidenceAttribute`/`Speech.TimeRangeAttribute` (confirmed
            // via swift-demangle -expand: "kind=Structure, kind=Module text=Speech" with no
            // enclosing AttributeScopes) -- a DIFFERENT type from the same-named one nested
            // directly inside SpeechAttributes (used by audioTimeRange/transcriptionConfidence,
            // and already correct). Our generator declared the bare-top-level pair inside
            // `extension AttributeScopes { ... }` though, mangling them as `AttributeScopes.
            // ConfidenceAttribute`/`AttributeScopes.TimeRangeAttribute` -- wrong module path, AND
            // the bare `ConfidenceAttribute`/`TimeRangeAttribute` references in confidence/
            // timeRange's own property declarations get shadowed by SpeechAttributes' own nested
            // same-named types (member lookup finds the sibling nested type before ever reaching
            // module scope), silently compiling to the wrong one. Fixed by un-wrapping the
            // top-level pair out of the `extension AttributeScopes` block entirely, and
            // explicitly module-qualifying confidence/timeRange's declared types to bypass the
            // shadowing (both confirmed via a minimal repro to produce an exact match).
            // Matched structurally (lazy span from the struct's own opening line to its own
            // closing brace, dropping the wrapping "extension AttributeScopes {"/final "}") --
            // NOT as an exact multi-line literal -- because member order/indentation inside this
            // struct isn't stable across generator runs (observed directly: two otherwise-
            // identical invocations of the same binary against the same .tbd produced `name`
            // before `decode` in one run and vice versa in another).
            for structName in ["ConfidenceAttribute", "TimeRangeAttribute"] {
                if let regex = try? NSRegularExpression(
                    pattern: "extension AttributeScopes \\{\\n(\\s*public struct \(structName): AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey \\{[\\s\\S]*?\\n\\s*\\})\\n\\}",
                    options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "$1")
                }
            }
            c = c.replacingOccurrences(
                of: "public var confidence: ConfidenceAttribute { get { fatalError() } }",
                with: "public var confidence: Speech.ConfidenceAttribute { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public var timeRange: TimeRangeAttribute { get { fatalError() } }",
                with: "public var timeRange: Speech.TimeRangeAttribute { get { fatalError() } }")

            // Fix: several real ABI members across Speech are entirely missing from the
            // generator's output (confirmed via swift-demangle, and each verified via a minimal
            // repro to produce an exact match).
            c += """

extension AttributedString {
    public func rangeOfTimeRangeAttributes(intersecting: CMTimeRange) -> Range<AttributedString.Index>? { nil }
    public func rangeOfAudioTimeRangeAttributes(intersecting: CMTimeRange) -> Range<AttributedString.Index>? { nil }
}
extension URL {
    public var filesystemPath: String { self.path }
}
extension Locale {
    public var languageRegionLocale: Locale? { nil }
    public var languageRegionLocaleWithReplacement: Locale? { nil }
    public var languageRegionIdentifier: String { "" }
    public var languageRegionIdentifierWithReplacement: String { "" }
}
public func addressDescription<A: AnyObject>(of: A) -> String { "" }

"""

            // Fix: many properties across Speech's module/analyzer/transcriber types render as
            // plain synchronous computed properties, but their real ABI needs "async function
            // pointer" symbols -- same "{ get async }" gap already fixed for Translation's
            // isReady/supportedLanguages and Vision's assetStatus (confirmed via a minimal repro
            // that only a `{ get async }` accessor produces those).
            //
            // Two protocol requirements, each with exactly one occurrence in the file (safe to
            // blanket-replace):
            c = c.replacingOccurrences(
                of: "var availableCompatibleAudioFormats: [AVAudioFormat] { get }",
                with: "var availableCompatibleAudioFormats: [AVAudioFormat] { get async }")
            c = c.replacingOccurrences(
                of: "static var supportedLocales: [Locale] { get }",
                with: "static var supportedLocales: [Locale] { get async }")
            // installedLocales/supportedLocales static vars: exactly 5 identical occurrences each
            // (SpeechTranscriber/Transcriber/DictationTranscriber/NormalizingTranscriber/
            // FoundationModelTranscriber), matching exactly the 5 classes the stub list names for
            // each -- safe to blanket-replace.
            c = c.replacingOccurrences(
                of: "public static var installedLocales: [Locale] { get { return [] } }",
                with: "public static var installedLocales: [Locale] { get async { return [] } }")
            c = c.replacingOccurrences(
                of: "public static var supportedLocales: [Locale] { get { return [] } }",
                with: "public static var supportedLocales: [Locale] { get async { return [] } }")
            // availableCompatibleAudioFormats "final var" shape: 9 classes share byte-identical
            // text, but only 6 need `get async` per the stub list (CommandRecognizer,
            // EndpointDetector, SpeechDetector do NOT) -- anchor each on its own nearest-preceding
            // class header via a lazy multiline span, same technique as MetricKit's baseUnit fix.
            for asyncAudioFormatsClass in ["SpeechTranscriber", "Transcriber", "LanguageDetector", "DictationTranscriber", "NormalizingTranscriber", "FoundationModelTranscriber"] {
                if let regex = try? NSRegularExpression(
                    pattern: "(class \(asyncAudioFormatsClass): [\\s\\S]*?)public final var availableCompatibleAudioFormats: \\[AVAudioFormat\\] \\{ get \\{ return \\[\\] \\} \\}",
                    options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "$1public final var availableCompatibleAudioFormats: [AVAudioFormat] { get async { return [] } }")
                }
            }
            // The rest are all individually unique members (verified via grep -c == 1 each), so
            // no per-class anchoring needed.
            for (from, to) in [
                ("public final var userData: [AnalysisContext.UserDataTag : Sendable] { get { return [:] } }",
                 "public final var userData: [AnalysisContext.UserDataTag : Sendable] { get async { return [:] } }"),
                ("public final var contextualStrings: [AnalysisContext.ContextualStringsTag : [Swift.String]] { get { return [:] } }",
                 "public final var contextualStrings: [AnalysisContext.ContextualStringsTag : [Swift.String]] { get async { return [:] } }"),
                ("public final var context: AnalysisContext { get { fatalError() } }",
                 "public final var context: AnalysisContext { get async { fatalError() } }"),
                ("public final var acousticModelVersion: Swift.String? { get { return nil } }",
                 "public final var acousticModelVersion: Swift.String? { get async { return nil } }"),
                ("public final var modelVersion: Swift.String? { get { return nil } }",
                 "public final var modelVersion: Swift.String? { get async { return nil } }"),
                ("public final var recognitionStatistics: [Swift.String : NSNumber]? { get { return nil } }",
                 "public final var recognitionStatistics: [Swift.String : NSNumber]? { get async { return nil } }"),
                ("public final var compatibleAudioFormats: [AVAudioFormat] { get { return [] } }",
                 "public final var compatibleAudioFormats: [AVAudioFormat] { get async { return [] } }"),
                ("public final var isSpeechProfileUsed: Swift.Bool { get { fatalError() } }",
                 "public final var isSpeechProfileUsed: Swift.Bool { get async { fatalError() } }"),
                ("public final var recognitionUtterenceStatistics: [Swift.String : Swift.String]? { get { return nil } }",
                 "public final var recognitionUtterenceStatistics: [Swift.String : Swift.String]? { get async { return nil } }"),
                ("public static var reservedLocales: [Locale] { get { return [] } }",
                 "public static var reservedLocales: [Locale] { get async { return [] } }"),
                ("public static var allocatedLocales: [Locale] { get { return [] } }",
                 "public static var allocatedLocales: [Locale] { get async { return [] } }"),
                ("public final var supportedLocales: [Locale]? { get { return nil } }",
                 "public final var supportedLocales: [Locale]? { get async { return nil } }"),
                ("public var modelSamplingRates: Set<Swift.Int> { get { fatalError() } }",
                 "public var modelSamplingRates: Set<Swift.Int> { get async { fatalError() } }"),
                ("public var modelTaskNames: [Swift.String] { get { return [] } }",
                 "public var modelTaskNames: [Swift.String] { get async { return [] } }"),
                ("public var modelVersion: Swift.String { get { fatalError() } }",
                 "public var modelVersion: Swift.String { get async { fatalError() } }"),
                ("public var modelQualityType: Swift.String { get { fatalError() } }",
                 "public var modelQualityType: Swift.String { get async { fatalError() } }"),
                ("public var modelRoot: URL { get { fatalError() } }",
                 "public var modelRoot: URL { get async { fatalError() } }"),
            ] {
                c = c.replacingOccurrences(of: from, with: to)
            }
        }

        if parser.defaultModule == "Charts" {
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
            // Same private-C-type gap as SPAngle above, but for Chart3DContentModifier's
            // symbolRotation(_:) parameter.
            c += "\npublic struct SPRotation3D: Hashable, Sendable {}\n"
            // Foundation.Date retroactively conforms to Plottable/PrimitivePlottableProtocol in
            // the real module (confirmed via its conformance-descriptor symbols in the .tbd:
            // "Date: Charts.Plottable"/"Date: Charts.PrimitivePlottableProtocol") -- needed by
            // PlottableProjection's "where B.PrimitivePlottable == Date" extension above. Our
            // parser never discovers extensions on external Foundation types, so this conformance
            // (and the one real member it needs beyond PrimitivePlottableProtocol's own default
            // init?(primitivePlottable:)/primitivePlottable implementations) has to be hand-added.
            c += "\nextension Foundation.Date: Plottable, PrimitivePlottableProtocol {\n    public static var _primitivePlottableKind: _PrimitivePlottableKind<Foundation.Date> { fatalError() }\n}\n"
            // AnyChartContent's `_makeChartContent`/`body` witnesses are satisfied via a
            // "protocol witness for ..." ABI thunk, but ChartContent's own default-extension
            // implementation for them is never emitted by this generator (protocol-extension
            // defaults aren't reproduced, only concrete-type extensions), so AnyChartContent
            // itself needs the members explicitly.
            //
            // AnyChartContent is also ChartContent's `@_typeEraser` type (confirmed in the real
            // .swiftinterface: `@_typeEraser(AnyChartContent) ... public protocol ChartContent`)
            // and is declared `@frozen` there. Under library evolution, a non-@frozen resilient
            // struct's protocol-witness thunks (for `_makeChartContent`/`body`, specifically) get
            // compiled as indirect/resilient-access thunks that reference the *protocol's*
            // generic-placeholder mangling rather than AnyChartContent's own — and those never
            // make it into `-exported_symbols_list`, leaving them undefined at final-link time
            // even though they compile fine into the first-pass (`-undefined dynamic_lookup`)
            // dylib. Adding `@frozen` makes the compiler emit direct witness-thunk symbols
            // instead, matching the real ABI. Verified via a minimal standalone repro: removing
            // `@frozen` alone reproduces the exact 2 undefined "protocol witness for ..." symbols
            // seen here; adding it back alone (no other change) fixes the link.
            c = c.replacingOccurrences(
                of: "public struct AnyChartContent: ChartContent {",
                with: "@frozen\npublic struct AnyChartContent: ChartContent {\n    public var body: Never { fatalError() }\n    public static func _makeChartContent(content: SwiftUI._GraphValue<AnyChartContent>, inputs: _ChartContentInputs) -> _ChartContentOutputs { fatalError() }")
            // The real module declares `extension Optional: ChartContent/AxisContent/AxisMark/
            // Chart3DContent/ContourContent where Wrapped: <same protocol>` so that optional
            // chart content (`if let ... { SomeMark(...) }`) participates directly in the
            // result-builder chain. Now that stripBogusArrayExtensionStructs() no longer deletes
            // half the file (see its doc comment), the generator's ordinary constrained-extension
            // machinery DOES discover and emit these members from the demangled symbols after
            // all -- it just renders the header as bare "extension Optional where Wrapped: X"
            // without restating "Swift.Optional: X", so the retroactive conformance itself never
            // gets declared. Add it via a header-only textual patch rather than a full duplicate
            // block (a previous version of this fixup duplicated the members outright, which
            // caused "invalid redeclaration" once the real extensions stopped being deleted).
            for proto in ["AxisContent", "AxisMark", "Chart3DContent", "ChartContent", "ContourContent"] {
                c = c.replacingOccurrences(
                    of: "extension Optional where Wrapped: \(proto) {",
                    with: "extension Swift.Optional: \(proto) where Wrapped: \(proto) {")
            }
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
            // BuilderTuple's own constrained default-implementation extensions (e.g.
            // "extension BuilderTuple where A: ChartContent") hit the same parameter-pack gap:
            // a `where` clause constraining a pack's element type needs "repeat each A: Protocol",
            // not the ordinary generic "A: Protocol" the constrained-extension renderer emits.
            for proto in ["AxisContent", "AxisMark", "Chart3DContent", "ChartContent", "ContourContent"] {
                c = c.replacingOccurrences(
                    of: "extension BuilderTuple where A: \(proto) {",
                    with: "extension BuilderTuple where repeat each A: \(proto) {")
            }
            // Same missing-retroactive-conformance-restatement gap as Optional/Never/BuilderTuple
            // above, for the rest of Charts's result-builder plumbing: each of these types has a
            // real conformance descriptor per protocol (confirmed via the .tbd) but the generator
            // only emits the bare "extension X where <param>: Y" default-implementation block.
            for (type, protos) in [
                ("BuilderConditional", ["AxisContent", "AxisMark", "Chart3DContent", "ChartContent", "ContourContent"]),
                ("BuilderPair", ["AxisContent", "AxisMark", "ChartContent"]),
            ] {
                for proto in protos {
                    c = c.replacingOccurrences(
                        of: "extension \(type) where A: \(proto),  B: \(proto) {",
                        with: "extension \(type): \(proto) where A: \(proto),  B: \(proto) {")
                }
            }
            // BarPlot/RectanglePlot/SectorPlot's `body` renders as `some SwiftUI.View`, which
            // can't satisfy ChartContent's "associatedtype Body: ChartContent" (an opaque View
            // isn't a ChartContent-conforming nominal type) -- so restating ": ChartContent"
            // here doesn't type-check; their conformance descriptor's ChartContent/
            // VectorizedChartContent requirements stay an accepted, unreproducible stub.
            // ChartModifiedContent<A, B>'s real conformance forwards to whichever protocol A
            // itself is (SwiftUI's ModifiedContent<Content, Modifier>: Content shape) -- but
            // Swift doesn't support conforming to a generic parameter as if it were a protocol
            // name ("extension X: A" is rejected as "inheritance from non-protocol type 'A'"),
            // so this one has no source-level fix either; also left as an accepted stub.
            // PlottableProjection<A, B>'s own declaration has no bound on B, so a constrained
            // extension referencing "B.PrimitivePlottable" can't resolve it as an associated
            // type -- the real constraint also requires B: Plottable (PrimitivePlottable is
            // Plottable's own associated type).
            c = c.replacingOccurrences(
                of: "extension PlottableProjection where B.PrimitivePlottable == Date {",
                with: "extension PlottableProjection where B: Plottable, B.PrimitivePlottable == Date {")
            // Chart<Content>.init(_:content:)'s real constraint is
            // `Content == ForEach<Data, Data.Element.ID, C>` (an associated-type chain through
            // Data.Element's Identifiable conformance), which the generic-placeholder-path
            // eraser can't resolve and erases to a self-contradictory bare `Any`.
            c = c.replacingOccurrences(
                of: "where A == SwiftUI.ForEach<A1, Any, B1>,  A1: RandomAccessCollection,  B1: ChartContent,  A1.Element: Identifiable",
                with: "where A == SwiftUI.ForEach<A1, A1.Element.ID, B1>,  A1: RandomAccessCollection,  B1: ChartContent,  A1.Element: Identifiable")
            c = c.replacingOccurrences(
                of: "where A == SwiftUI.ForEach<A1, Any, B1>,  A1: RandomAccessCollection,  B1: Chart3DContent,  A1.Element: Identifiable",
                with: "where A == SwiftUI.ForEach<A1, A1.Element.ID, B1>,  A1: RandomAccessCollection,  B1: Chart3DContent,  A1.Element: Identifiable")
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
                of: "public func updateTarget(_ arg1: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n}",
                with: "public func updateTarget(_ arg1: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n    public func updateTarget(_ target: inout SwiftUI.ScrollTarget, context: SwiftUI.ScrollTargetBehaviorContext) -> () {}\n}")
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
            // The type-name group must swallow a generic parameter list's own "<...>" as one
            // unit (e.g. "LowerHarness<A: LowerProtocolLinkage>") — a bare "\S+" stops at the
            // FIRST colon in the line, which is the one inside "<A: LowerProtocolLinkage>" once a
            // constrained generic param is present, not the real inheritance-list colon that
            // follows the closing ">". That misparse leaves the inheritance list's first entry
            // reading "LowerProtocolLinkage>: BottomProtocolHandler" instead of
            // "BottomProtocolHandler", which then fails to match networkConformancesToStrip.
            let typeHeaderRegex = try? NSRegularExpression(
                pattern: "^(\\s*(?:@_fixed_layout\\s+|public\\s+|open\\s+|final\\s+)+(?:struct|class|protocol|enum|actor|extension)\\s+[^\\s:<]+(?:<[^>]*>)?)(:)(.*?)( \\{.*|$)", options: [])
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
            // A protocol default-implementation extension constrained `where Self: ~Copyable`
            // (e.g. OneToOneStreamProtocol's real getOutboundStreamDataRoomAvailable(_:), whose
            // symbol demangles to "(extension in Network):Network.OneToOneStreamProtocol< where
            // A: ~Swift.Copyable>...") only compiles if the protocol ITSELF opts out of the
            // implicit `Self: Copyable` requirement (confirmed via a minimal swiftc repro:
            // `protocol Foo {}; extension Foo where Self: ~Copyable {}` fails with "'Self'
            // required to be 'Copyable'"; adding `~Copyable` to Foo's own declaration fixes it).
            // Swift requires every protocol in an inheritance chain to agree on this, so
            // transitively close over ancestors too (e.g. OneToOneStreamProtocol:
            // OneToOneDatapathProtocol: OneToOneProtocolHandler: ...: ProtocolInstance all need
            // it, even though only some of them have their own `~Copyable`-constrained
            // extension). This used to strip the whole extension instead, silently dropping
            // every default-implementation method it provided (the majority of Network's
            // first-pass stub count).
            var needsCopyable = Set<String>()
            if let extRegex = try? NSRegularExpression(
                pattern: "extension\\s+(\\S+)\\s+where\\s+Self\\s*:\\s*~Copyable[^{]*\\{", options: []) {
                let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                for m in extRegex.matches(in: c, options: [], range: nsRange) {
                    if let r = Range(m.range(at: 1), in: c) {
                        needsCopyable.insert(String(c[r]))
                    }
                }
            }
            if !needsCopyable.isEmpty {
                var ancestors = [String: [String]]()
                if let declRegex = try? NSRegularExpression(
                    pattern: "public protocol (\\S+?)(?:<[^>]*>)?(?:\\s*:\\s*([^{]+))?\\s*\\{", options: []) {
                    let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                    for m in declRegex.matches(in: c, options: [], range: nsRange) {
                        guard let nameRange = Range(m.range(at: 1), in: c) else { continue }
                        let protoName = String(c[nameRange])
                        var protoAncestors = [String]()
                        if m.range(at: 2).location != NSNotFound, let listRange = Range(m.range(at: 2), in: c) {
                            protoAncestors = String(c[listRange]).components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        }
                        ancestors[protoName] = protoAncestors
                    }
                }
                var frontier = Array(needsCopyable)
                while let protoName = frontier.popLast() {
                    for ancestor in ancestors[protoName] ?? [] where !needsCopyable.contains(ancestor) {
                        needsCopyable.insert(ancestor)
                        frontier.append(ancestor)
                    }
                }
                for protoName in needsCopyable {
                    let withInheritance = "public protocol \(protoName): "
                    if let range = c.range(of: withInheritance) {
                        c.insert(contentsOf: "~Copyable, ", at: range.upperBound)
                    } else if let range = c.range(of: "public protocol \(protoName) {") {
                        c.replaceSubrange(range, with: "public protocol \(protoName): ~Copyable {")
                    }
                }
            }
            // BottomProtocolHandler/OneToOneProtocolHandler's own `upper` requirement really has
            // type `Self.UpperProtocol` (confirmed via swift-demangle -expand on
            // BottomProtocolHandler.upper's dispatch thunk: "A.UpperProtocol", A = Self) --
            // real, ABI-confirmed associated types genuinely missing from both protocols' own
            // reconstruction (unrelated to the ~Copyable fix above), rendered as the generic
            // `Any` fallback instead. Without it, every constrained extension on either protocol
            // referencing `Self.UpperProtocol` (e.g. "where Self.UpperProtocol ==
            // InboundDatagramLinkage") fails with "'UpperProtocol' is not a member type of type
            // 'Self'", forcing those default implementations to fall back to stubs.
            for protoName in ["BottomProtocolHandler", "OneToOneProtocolHandler"] {
                for header in ["public protocol \(protoName): ~Copyable, ", "public protocol \(protoName): "] {
                    if let colonEnd = c.range(of: header)?.upperBound,
                       let braceRange = c.range(of: " {\n", range: colonEnd..<c.endIndex) {
                        c.insert(contentsOf: "    associatedtype UpperProtocol: UpperProtocolLinkage\n", at: braceRange.upperBound)
                        break
                    }
                }
            }
            c = c.replacingOccurrences(of: "var upper: Any { get set }", with: "var upper: UpperProtocol { get set }")
            // Strip a spurious ", Self: ~Copyable" tacked onto an otherwise-valid constrained
            // extension (e.g. "extension TopProtocolHandler where Self.LowerProtocol ==
            // OutboundDatagramLinkage,  Self: ~Copyable {") -- UNLESS the extension's own
            // protocol is one we just declared `~Copyable` above (needsCopyable), in which case
            // the combined constraint is real ABI (the mangled symbol only matches when BOTH
            // clauses are present on the same extension, confirmed empirically:
            // OneToOneProtocolHandler.invokeReceiveDatagrams(maximumDatagramCount:) still needed
            // a stub after dropping just the ~Copyable clause here, even though the method itself
            // rendered fine) and dropping it would leave the extension real but ABI-mismatched.
            // For every OTHER protocol (never declared ~Copyable), the whole extension is valid
            // once this one clause is dropped; stripping the entire extension here would throw
            // away real default-method bodies.
            if let spuriousRegex = try? NSRegularExpression(
                pattern: "extension\\s+(\\S+)\\s+where\\s+([^{]*?),\\s*Self:\\s*~Copyable\\s*\\{", options: []) {
                let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                var replacements: [(Range<String.Index>, String)] = []
                for m in spuriousRegex.matches(in: c, options: [], range: nsRange) {
                    guard let fullRange = Range(m.range, in: c),
                          let nameRange = Range(m.range(at: 1), in: c),
                          let restRange = Range(m.range(at: 2), in: c) else { continue }
                    let protoName = String(c[nameRange])
                    guard !needsCopyable.contains(protoName) else { continue }
                    replacements.append((fullRange, "extension \(protoName) where \(c[restRange]) {"))
                }
                for (range, replacement) in replacements.reversed() {
                    c.replaceSubrange(range, with: replacement)
                }
            }
            // Deserializer<A>/SerializerSpanFactory/InPlaceSerializer<A>: several extensions and
            // static methods relax their generic parameter to `~Copyable`/`~Escapable` (e.g.
            // "extension Deserializer where A: ~Copyable, A: ~Escapable", Serializer.serialize's
            // "where GenericA: ~Copyable, GenericA: ~Escapable" — confirmed as real ABI via
            // `swift-demangle -expand` on Serializer.serialize's mangled symbol), but the
            // generic parameter these relax was declared as a plain unconstrained placeholder
            // (implicitly Copyable & Escapable), making the relaxation self-contradictory. Add
            // `~Copyable & ~Escapable` directly to the declarations so the relaxation is valid.
            c = c.replacingOccurrences(
                of: "public struct Deserializer<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct Deserializer<A: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public struct InPlaceSerializer<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct InPlaceSerializer<A: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public protocol SerializerSpanFactory {",
                with: "public protocol SerializerSpanFactory: ~Copyable, ~Escapable {")
            c = c.replacingOccurrences(
                of: "public protocol DeserializerSpanFactory {",
                with: "public protocol DeserializerSpanFactory: ~Copyable, ~Escapable {")
            // Once ~Escapable is on the protocol, a method returning a ~Escapable type
            // (RawSpan?/MutableRawSpan?) needs an explicit lifetime-dependence attribute — the
            // compiler can't infer one for a protocol requirement. "borrow self" matches the
            // real semantics (the returned span only stays valid while the factory instance
            // does); conformers don't need to redeclare the attribute themselves.
            c = c.replacingOccurrences(
                of: "    func nextSpan() -> RawSpan?",
                with: "    @_lifetime(borrow self)\n    func nextSpan() -> RawSpan?")
            c = c.replacingOccurrences(
                of: "    func nextMutableSpan() -> MutableRawSpan?",
                with: "    @_lifetime(borrow self)\n    func nextMutableSpan() -> MutableRawSpan?")
            // Same class of bug as Deserializer/Serializer above: StreamDeserializer<A, B, C>'s
            // A and C are both relaxed to ~Copyable/~Escapable by its own extensions (never B),
            // and StreamDeserializerState (used as a constraint on A in one of those
            // extensions) needs the same ~Copyable relaxation for the same reason.
            c = c.replacingOccurrences(
                of: "public struct StreamDeserializer<A, B, C>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct StreamDeserializer<A: ~Copyable, B, C: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public protocol StreamDeserializerState {",
                with: "public protocol StreamDeserializerState: ~Copyable {")
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
            // The real arm64e swiftinterface declares it `final public class SignalBars :
            // Foundation::Dimension, @unchecked Swift::Sendable` (confirmed via swift-demangle:
            // its baseUnit() override needs the concrete return type, same as the other two
            // Dimension subclasses below, which only compiles/mangles correctly on a final class
            // -- `open` and `final` can't both apply), not `open` as this rendered previously.
            if let regex = try? NSRegularExpression(
                pattern: "(?:public |open |@_fixed_layout )*(?:class|open class) SignalBars:\\s*NSObject", options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "final public class SignalBars: Foundation.Dimension")
            }
            // Foundation.Dimension already conforms to NSCoding, so remove the redundant
            // NSCoding conformance from SignalBars's inheritance list.
            c = c.replacingOccurrences(of: "final public class SignalBars: Foundation.Dimension, NSCoding",
                                        with: "final public class SignalBars: Foundation.Dimension")
            // After substituting Dimension as parent, encode(with:) is now an override of
            // Foundation.Dimension's NSCoding conformance — mark it accordingly. `open` isn't
            // legal on a final class's member.
            c = c.replacingOccurrences(of: "open func encode(with coder: NSCoder) {}",
                                        with: "public override func encode(with coder: NSCoder) {}")
            // required init?(coder:) must call super.init(coder:) since Foundation.Dimension
            // is the new base class and its designated initializers must be called.
            c = c.replacingOccurrences(of: "public required init?(coder: NSCoder) {}",
                                        with: "public required init?(coder: NSCoder) { super.init(coder: coder) }")
            // HitchTimeRatio is likewise a Dimension subclass (real module: `final public class
            // HitchTimeRatio: Foundation.Dimension`) — Parser.swift sets its baseClass
            // accordingly, but the ABI-driven class-header text still renders it with the
            // NSObject/NSCoding-subclass shape (redundant NSCoding conformance, non-`open`
            // visibility+finality). Apply the same header substitution SignalBars needed above.
            if let regex = try? NSRegularExpression(
                pattern: "@_fixed_layout open class HitchTimeRatio:\\s*NSObject,\\s*NSCoding", options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "@_fixed_layout final public class HitchTimeRatio: Foundation.Dimension")
            }
            // Parser.swift's simplifyType() unconditionally rewrites every Dimension subclass's
            // `baseUnit()` override return type to `-> Self`, matching Foundation.Dimension's own
            // `open class func baseUnit() -> Self` declaration -- correct for `open` subclasses,
            // but AveragePixelLuminance/HitchTimeRatio/SignalBars are all `final` here, and the
            // real arm64e swiftinterface prints their overrides with the concrete return type
            // (e.g. "-> MetricKit.AveragePixelLuminance"), not `Self` (for a final class the two
            // are equivalent at the source level, but they mangle differently: `-> Self` adds a
            // dynamic-Self "XD" marker a minimal repro confirms the real symbols don't have).
            // All three classes render this override with byte-identical text, so a plain
            // replacingOccurrences(of:with:) (which replaces every match at once) can't target
            // each one with its own class name -- match each occurrence together with its
            // nearest-preceding class header instead, via a lazy multiline span.
            for finalUnitType in ["AveragePixelLuminance", "HitchTimeRatio", "SignalBars"] {
                if let regex = try? NSRegularExpression(
                    pattern: "(final public class \(finalUnitType): Foundation\\.Dimension[\\s\\S]*?)public override static func baseUnit\\(\\) -> Self \\{ fatalError\\(\\) \\}",
                    options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "$1public override static func baseUnit() -> \(finalUnitType) { fatalError() }")
                }
            }
            // MetricResult.hitchTime's real ABI enum-case constructor has an unlabeled associated
            // value (confirmed via swift-demangle -expand: its LabelList is empty), but the
            // generator renders it with a `hitchTime:` label -- a minimal repro confirms a
            // labeled single-payload case mangles differently ("V_t" tuple-with-label shape)
            // from an unlabeled one, which is what the real symbol has.
            c = c.replacingOccurrences(
                of: "case hitchTime(hitchTime: HitchTimeMetric)",
                with: "case hitchTime(HitchTimeMetric)")
            // mxSignpost(_:dso:log:name:signpostID:_:_:) -- the raw C-level signpost function
            // taking an os_signpost_type_t and a raw os_log_t -- is real ABI (confirmed via
            // swift-demangle) but never rendered at all; only its higher-level Swift wrappers
            // (mxSignpostAnimationIntervalBegin etc.) are. Add it directly: `OSSignpostType`/
            // `OSLog` are Swift's renamed-in-Swift-3 surface names for the same underlying
            // ObjC/C types the real symbol mangles as ("__C.os_signpost_type_t"/"__C.OS_os_log"),
            // confirmed via a minimal repro to produce an exact match.
            c += """

public func mxSignpost(_ type: OSSignpostType, dso: UnsafeRawPointer, log: OSLog, name: StaticString, signpostID: OSSignpostID, _ arg1: StaticString, _ arg2: [CVarArg]) -> () {}

"""
        }

        // Fix (general, not module-gated): every module that adds its own `XAttributes:
        // AttributeScope` conformer inside `extension AttributeScopes { ... }` (the standard
        // AttributedString custom-scope pattern -- Translation's TranslationAttributes, Speech's
        // SpeechAttributes, etc.) also needs two more members the generator never renders at all:
        // a scope-accessor property on AttributeScopes itself (e.g. `var translation:
        // TranslationAttributes.Type`) and a `AttributeDynamicLookup.subscript(dynamicMember:)`
        // overload keyed to that scope type, both confirmed via a minimal repro to produce exact
        // matches to the real mangled symbols. The scope-accessor's name is derived by dropping
        // the "Attributes" suffix and lowercasing the first letter, matching the real ABI's own
        // naming (confirmed for Translation: "TranslationAttributes" -> "translation").
        if let scopeRegex = try? NSRegularExpression(
            pattern: "public struct (\\w+)Attributes: (?:Foundation\\.)?AttributeScope\\b", options: []) {
            let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
            var scopeNames = [String]()
            for m in scopeRegex.matches(in: c, options: [], range: nsRange) {
                if let r = Range(m.range(at: 1), in: c) {
                    scopeNames.append(String(c[r]))
                }
            }
            for base in Set(scopeNames) {
                let typeName = "\(base)Attributes"
                let accessorName = base.prefix(1).lowercased() + base.dropFirst()
                c += """

extension AttributeScopes {
    public var \(accessorName): AttributeScopes.\(typeName).Type { AttributeScopes.\(typeName).self }
}
extension AttributeDynamicLookup {
    public subscript<A: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.\(typeName), A>) -> A {
        self[A.self]
    }
}

"""
            }
        }

        if parser.defaultModule == "Translation" {
            // TranslationSession's `textSessionDelegate` property is real ABI (confirmed via
            // swift-demangle: getter/setter/modify/property-descriptor all present) but never
            // rendered at all. A minimal repro confirms `(any _LTTextSessionDelegate)?` produces
            // an exact match to the real "So..._p" existential-protocol-typed symbols.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class TranslationSession {",
                with: "@_fixed_layout public class TranslationSession {\n    public var textSessionDelegate: (any _LTTextSessionDelegate)?")
            // LanguageAvailability.supportedLanguages / TranslationSession.isReady both render as
            // plain synchronous computed getters, but their real ABI needs "async function
            // pointer to dispatch thunk of ...getter" symbols -- confirmed via a minimal repro
            // that only a `{ get async }` accessor produces those (their signatures otherwise
            // match already).
            c = c.replacingOccurrences(
                of: "public var supportedLanguages: [Locale.Language] { get { return [] } }",
                with: "public var supportedLanguages: [Locale.Language] { get async { return [] } }")
            c = c.replacingOccurrences(
                of: "public var isReady: Swift.Bool { get { fatalError() } }",
                with: "public var isReady: Swift.Bool { get async { fatalError() } }")
        }

        // Fix: SwiftData's DefaultHistoryDelete<A>/DefaultHistoryInsert<A>/DefaultHistoryUpdate<A>
        // conform to HistoryDelete/HistoryInsert/HistoryUpdate via their own generic parameter
        // (associatedtype Model: PersistentModel), matching the real module's
        // `where Model : PersistentModel` constraint. The ABI doesn't reveal this bound, so add
        // it explicitly and provide the associated-type alias the same way TipKit's RuleInput fix
        // does for Event<A>/Parameter<A>.
        if parser.defaultModule == "SwiftData" {
            // Fix: BackingData<Model>'s real ABI init requirement is "init(for: Self.Model.Type)"
            // (confirmed via swift-demangle: "BackingData.init(for: A.Model.Type) -> A"), but the
            // generator renders it as "init(for: Any)" -- an unrelated bogus "associatedtype A"
            // (with no real ABI presence at all) sits right above it, suggesting the parser
            // mis-resolved the parameter's associated-type path to a fresh, meaningless
            // placeholder instead of "Self.Model". PersistentModel's init(backingData:)/
            // persistentBackingData similarly need the primary-associated-type-qualified "any
            // BackingData<Self>" existential (confirmed via swift-demangle: "any
            // SwiftData.BackingData<Self.Model == A>"), not the bare unconstrained "any
            // BackingData" the generator renders -- both fixes confirmed via a minimal repro to
            // produce the exact required dispatch-thunk/method-descriptor symbols.
            c = c.replacingOccurrences(
                of: "public protocol BackingData<Model> {\n    associatedtype A\n    init(for: Any)",
                with: "public protocol BackingData<Model> {\n    init(for: Self.Model.Type)")
            // Fix: same missing-second-generic-parameter gap as PersistentModel's getValue/
            // setValue extension methods (see below), but for BackingData's own protocol
            // requirements -- confirmed via a minimal repro to produce the exact required
            // dispatch-thunk/method-descriptor symbols.
            c = c.replacingOccurrences(
                of: "func getValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: RelationshipCollection",
                with: "func getValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")
            c = c.replacingOccurrences(
                of: "func setValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: RelationshipCollection",
                with: "func setValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")

            // Fix: BackingData/PersistentModel's Decodable/Encodable-combined RelationshipCollection
            // overloads have the same missing-second-generic-parameter gap as the plain
            // RelationshipCollection overload above, just with an extra Decodable/Encodable bound --
            // confirmed via a minimal repro that source order "GenericA: Decodable, GenericA:
            // RelationshipCollection, GenericB == GenericA.PersistentElement" produces the exact
            // required dispatch-thunk/method-descriptor symbols (a prior investigation this session
            // wrongly concluded this was uncontrollable from source order).
            c = c.replacingOccurrences(
                of: "func getValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: Decodable,  GenericA: RelationshipCollection",
                with: "func getValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: Decodable, GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")
            c = c.replacingOccurrences(
                of: "func setValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: Encodable,  GenericA: RelationshipCollection",
                with: "func setValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: Encodable, GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")

            // Fix: [A]/A? (Array/Optional) conditionally conform to RelationshipCollection in
            // the real module (confirmed via swift-demangle: "protocol conformance descriptor
            // for <A where A: PersistentModel> [A] : RelationshipCollection" and "<A where A:
            // Sequence, A.Element: PersistentModel> A? : RelationshipCollection"), but the
            // generator never renders these retroactive stdlib-type conformances at all --
            // confirmed via a minimal repro to produce the exact required conformance-descriptor
            // symbols (RelationshipCollection has no method requirements, only an associated
            // type, so no witness table is needed/emitted for either -- the still-remaining
            // witness-table stubs for these two conformances are a separate, unresolved gap).
            c += """


            extension Array: RelationshipCollection where Element: PersistentModel {
                public typealias PersistentElement = Element
            }
            extension Optional: RelationshipCollection where Wrapped: Sequence, Wrapped.Element: PersistentModel {
                public typealias PersistentElement = Wrapped.Element
            }
            """
            // Fix: HistoryDelete/HistoryInsert/HistoryUpdate/HistoryToken/HistoryTransaction's
            // associated types are missing extra real-ABI bounds (confirmed via swift-demangle:
            // each needs an "associated conformance descriptor ... : Swift.Hashable" that a
            // Comparable-only or Decodable-only bound can't produce, since Hashable isn't implied
            // by either). Each fix is a single-line, order-independent global replace -- member
            // order within these protocol bodies is nondeterministic across generator runs (same
            // root cause as Speech's TimeRangeAttribute/ConfidenceAttribute fix), so an earlier
            // attempt matching adjacent multi-line blocks only fired when two associatedtype
            // lines happened to land in the assumed order, producing a flaky 89-94 stub count
            // across repeated runs. "associatedtype TransactionIdentifier: Comparable" and
            // "associatedtype ChangeIdentifier: Comparable" are intentionally replaced globally
            // (`replaceAll`-equivalent via a single non-anchored match) since the identical fixed
            // text is correct everywhere they appear (HistoryDelete/HistoryInsert/HistoryUpdate).
            c = c.replacingOccurrences(
                of: "associatedtype TransactionIdentifier: Comparable\n",
                with: "associatedtype TransactionIdentifier: Comparable, Hashable\n")
            c = c.replacingOccurrences(
                of: "associatedtype ChangeIdentifier: Comparable\n",
                with: "associatedtype ChangeIdentifier: Comparable, Hashable\n")
            c = c.replacingOccurrences(
                of: "associatedtype TokenType: Decodable\n",
                with: "associatedtype TokenType: Decodable, Encodable, Hashable\n")
            c = c.replacingOccurrences(
                of: "associatedtype TokenType: Identifiable\n",
                with: "associatedtype TokenType: Identifiable, Comparable, Hashable\n")

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
                of: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Equatable, Identifiable, RandomAccessCollection, Sequence {",
                with: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Equatable, Identifiable, RandomAccessCollection, Sequence where B: Hashable {\n    public typealias ID = B")
            c = c.replacingOccurrences(
                of: "public struct ResultsSectionCollection<A, B>: BidirectionalCollection, Collection, RandomAccessCollection, Sequence {",
                with: "public struct ResultsSectionCollection<A, B>: BidirectionalCollection, Collection, RandomAccessCollection, Sequence where B: Hashable {")
            // SectionedResults<Element, SectionTitle> wraps [ResultsSection<A, B>] internally,
            // which itself now requires B: Hashable (real module: `where SectionTitle: Hashable`).
            c = c.replacingOccurrences(
                of: "public struct SectionedResults<A, B>: BidirectionalCollection, Collection, Equatable, RandomAccessCollection, Sequence {",
                with: "public struct SectionedResults<A, B>: BidirectionalCollection, Collection, Equatable, RandomAccessCollection, Sequence where B: Hashable {")
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class ResultsObserver<A, B>: CustomDebugStringConvertible, Observation.Observable {",
                with: "@_fixed_layout final public class ResultsObserver<A, B>: CustomDebugStringConvertible, Observation.Observable where B: Hashable {")
            // `_computeSections`'s real constraint is `A == B.Element` (A is B's element type),
            // but replaceGenericPlaceholderPathsWithAny (applied generically to all top-level
            // global function signatures) can't distinguish a meaningful associated-type
            // reference on a generic parameter from an unresolvable demangler placeholder path.
            // An earlier fix assumed this erased "B.Element" to a literal "A == Any" clause, but
            // the constraint is now dropped entirely instead (confirmed via direct inspection of
            // the generated interface) -- restore it by anchoring on the still-present
            // "A: PersistentModel,  B: RandomAccessCollection" pair.
            c = c.replacingOccurrences(
                of: "where A: PersistentModel,  B: RandomAccessCollection,  C: Hashable",
                with: "where A: PersistentModel, A == B.Element, B: RandomAccessCollection, C: Hashable")
            // Also drop the erroneously-added `@escaping` on `resolveSection` (real ABI shows a
            // plain, non-escaping closure type: "resolveSection: (A) -> C?") -- same
            // erroneously-added-@escaping gap already fixed for MetalPerformanceShadersGraph's
            // reorderInputsAndOutputs and StoreKit's BackingValue.value(atKeyPath:), confirmed
            // via a minimal repro.
            c = c.replacingOccurrences(
                of: "resolveSection: @escaping (A) -> C?",
                with: "resolveSection: (A) -> C?")
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
        // protocol's associated type `Stream` equals the generic param `A`). `Source<A>` IS
        // declared with a primary associated type (see IntelligencePlatformLibrary's
        // "public protocol Source<A> { associatedtype A }" stub/.swiftinterface), so the
        // constraint reconstructs validly as `any Source<A>` when the enclosing member's own
        // generic parameter is literally named "A" (true for every known use site — see
        // BiomeEventReporter.lazySource<A>). Parser.swift's simplifyType preserves that as the
        // "___SAME_TYPE_A___" marker instead of erasing it outright; resolve it here.
        //
        // The enclosing generic parameter is usually declared on the type's own header line
        // (e.g. "class lazySource<A> where A: ... {"), not on the member line carrying the
        // marker (e.g. "public var source: (any Source<___SAME_TYPE_A___>)? { ... }") — a
        // same-line-only scan never sees it and always falls back to "Any", silently erasing
        // the constraint. Track the innermost enclosing generic type's parameter name via a
        // brace-depth scope stack instead of scanning each marker line in isolation.
        var postProcessedLines = [String]()
        var genericScopeStack: [(name: String, depth: Int)] = []
        var braceDepth = 0
        let genericHeaderRegex = try? NSRegularExpression(
            pattern: #"\b(?:class|struct|enum)\s+\w+<([^>]+)>"#, options: [])
        for line in c.components(separatedBy: "\n") {
            if line.contains("___SAME_TYPE_A___") {
                let hasGenericA = line.contains("<A>") || line.contains("<A,") || line.contains(", A>") || line.contains(", A,") || line.contains("where A")
                    || genericScopeStack.contains(where: { $0.name == "A" })
                let replacement = hasGenericA ? "A" : "Any"
                postProcessedLines.append(line.replacingOccurrences(of: "___SAME_TYPE_A___", with: replacement))
            } else {
                postProcessedLines.append(line)
            }

            let openCount = line.filter { $0 == "{" }.count
            let closeCount = line.filter { $0 == "}" }.count
            braceDepth += openCount
            if openCount > 0, let regex = genericHeaderRegex,
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let paramsRange = Range(match.range(at: 1), in: line) {
                for param in line[paramsRange].split(separator: ",") {
                    let name = param.split(separator: ":").first.map { $0.trimmingCharacters(in: .whitespaces) } ?? ""
                    if !name.isEmpty {
                        genericScopeStack.append((name: name, depth: braceDepth))
                    }
                }
            }
            braceDepth -= closeCount
            while let last = genericScopeStack.last, braceDepth < last.depth {
                genericScopeStack.removeLast()
            }
        }
        c = postProcessedLines.joined(separator: "\n")

        // Outside a protocol body, `Self.Stream` (with no preserved same-type marker — the
        // constraint was already destroyed by an earlier `== String>`/generic-placeholder pass)
        // is not meaningful – replace with `Any` so the class compiles.
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
            // left with A1 not appearing anywhere in these two extension methods' signatures,
            // which the compiler rejects as an unused generic parameter. BackingData actually
            // DOES have a primary associated type (`protocol BackingData<Model>`, fixed earlier
            // this session), so instead of the unused-parameter workaround this used previously
            // (a phantom `as type: A1.Type` parameter, which doesn't match the real ABI's
            // parameter list), restore the constraint as `any BackingData<A1>` -- BackingData's
            // primary associated type argument -- which both keeps A1 used AND mangles to the
            // exact real ABI shape (confirmed via swift-demangle and a minimal repro).
            c = c.replacingOccurrences(
                of: "public func _generateCurrentClassBackingData<A1>() -> any BackingData where A1: PersistentModel { fatalError() }",
                with: "public func _generateCurrentClassBackingData<A1>() -> any BackingData<A1> where A1: PersistentModel { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func _superClassBackingData<A1>(of: any PersistentModel.Type) -> any BackingData where A1: PersistentModel { fatalError() }",
                with: "public func _superClassBackingData<A1>(of: any PersistentModel.Type) -> any BackingData<A1> where A1: PersistentModel { fatalError() }")
            // `init(backingData:)`/`persistentBackingData` reference `any BackingData<Self.Model
            // == A>` in the real module; here the generic-placeholder-path eraser reduces the
            // constraint to plain `<Any>` (no `==` survives, so stripConstrainedExistentialGenerics
            // above doesn't catch it) rather than dropping it — BackingData has no primary
            // associated type, so any `<...>` on it is invalid.
            c = c.replacingOccurrences(of: "any BackingData<Any>", with: "any BackingData")
            // PersistentModel.init(backingData:)/persistentBackingData reference `any
            // BackingData<Self.Model == A>` in the real module (confirmed via swift-demangle),
            // which needs BackingData's primary associated type argument restored as `<Self>`
            // (PersistentModel's own Self satisfies BackingData's Model bound) -- confirmed via a
            // minimal repro to produce the exact required dispatch-thunk/method-descriptor
            // symbols. This must run after the "any BackingData<Any>" strip right above, since
            // at the point the SwiftData block earlier in postProcess runs, this text is still
            // in its unstripped, generic-placeholder-eraser form and doesn't match yet.
            c = c.replacingOccurrences(
                of: "init(backingData: any BackingData)",
                with: "init(backingData: any BackingData<Self>)")
            c = c.replacingOccurrences(
                of: "var persistentBackingData: any BackingData { get set }",
                with: "var persistentBackingData: any BackingData<Self> { get set }")

            // Fix: PersistentModel.getValue/setValue's RelationshipCollection-bound overloads
            // are missing a second, structurally-required generic parameter tied via `==` to
            // A1.PersistentElement (confirmed via swift-demangle: "getValue<A, B where A1:
            // RelationshipCollection, B1 == A1.PersistentElement>" -- the mangler tracks
            // A1.PersistentElement as its own substitution slot, requiring a second declared
            // generic parameter even though it's otherwise unused in the visible signature).
            // Confirmed via a minimal repro to produce the exact required symbol. The Decodable/
            // Encodable-combined RelationshipCollection overloads need the same B1 parameter,
            // with A1: Decodable/Encodable listed before A1: RelationshipCollection in source --
            // confirmed via a minimal repro that this ordering produces the exact required symbol
            // (a prior investigation this session wrongly concluded the canonical order wasn't
            // controllable from source).
            c = c.replacingOccurrences(
                of: "public func getValue<A1>(forKey: KeyPath<Self, A1>) -> A1 where A1: RelationshipCollection { fatalError() }",
                with: "public func getValue<A1, B1>(forKey: KeyPath<Self, A1>) -> A1 where A1: RelationshipCollection, B1 == A1.PersistentElement { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func setValue<A1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: RelationshipCollection {}",
                with: "public func setValue<A1, B1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: RelationshipCollection, B1 == A1.PersistentElement {}")
            c = c.replacingOccurrences(
                of: "public func getValue<A1>(forKey: KeyPath<Self, A1>) -> A1 where A1: Decodable,  A1: RelationshipCollection { fatalError() }",
                with: "public func getValue<A1, B1>(forKey: KeyPath<Self, A1>) -> A1 where A1: Decodable, A1: RelationshipCollection, B1 == A1.PersistentElement { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func setValue<A1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: Encodable,  A1: RelationshipCollection {}",
                with: "public func setValue<A1, B1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: Encodable, A1: RelationshipCollection, B1 == A1.PersistentElement {}")

            // Fix: ResultsObserverDelegate has the same bogus-associatedtype pattern as
            // BackingData -- an unrelated `associatedtype A`/`associatedtype B` pair (no real
            // ABI presence) sits alongside the real Element/SectionTitle associated types, and
            // the protocol isn't declared with them as primary associated types at all.
            // ResultsObserver.delegate's real ABI is `any ResultsObserverDelegate<Self.Element ==
            // A, Self.SectionTitle == B>` (confirmed via swift-demangle), which requires
            // ResultsObserverDelegate<Element, SectionTitle> primary-associated-type syntax on
            // the protocol declaration and `any ResultsObserverDelegate<A, B>` (ResultsObserver's
            // own generic parameters) at the usage site -- confirmed via a minimal repro to
            // produce the exact required symbols.
            c = c.replacingOccurrences(
                of: "public protocol ResultsObserverDelegate {\n    associatedtype A\n    associatedtype B\n",
                with: "public protocol ResultsObserverDelegate<Element, SectionTitle> {\n")
            c = c.replacingOccurrences(
                of: "public final var delegate: (any ResultsObserverDelegate)? { get { return nil } set {} }",
                with: "public final var delegate: (any ResultsObserverDelegate<A, B>)? { get { return nil } set {} }")

            // Fix: DataStoreBatchDeleteRequest<A>/FetchDescriptor<A>/HistoryDescriptor<A>/
            // ResultsObserver<A, B>.predicate|filterBy, plus ModelContext.delete<GenericA>(where:),
            // all render `Foundation.Predicate<Any>` instead of `Foundation.Predicate<{their own
            // generic parameter}>` (confirmed via swift-demangle: real ABI is
            // "Foundation.Predicate<Pack{A}>", since Predicate is declared with a variadic-
            // generic `each Input` and each of these passes its own generic parameter as a
            // single-element pack) -- same generic-placeholder-resolved-as-Any gap seen elsewhere
            // this session, confirmed via a minimal repro to produce the exact required mangled
            // shape. A first attempt globally replaced every "Predicate<Any>" with "Predicate<A>",
            // which broke ModelContext.delete<GenericA>(...) (generic over "GenericA", not "A") --
            // fixed with a targeted per-line replacement instead of a blind global one.
            c = c.replacingOccurrences(of: "Predicate<Any>?, sortBy: [SortDescriptor<A>])", with: "Predicate<A>?, sortBy: [SortDescriptor<A>])")
            c = c.replacingOccurrences(of: "Predicate<Any>?) { fatalError() }", with: "Predicate<A>?) { fatalError() }")
            // Same Predicate<Any>-instead-of-Predicate<A> gap for ResultsObserver's
            // convenience init(filterBy:...) overloads specifically (missed by the targeted
            // replacements above, which didn't anticipate "init(filterBy:" as a distinct call
            // site) -- confirmed via the same swift-demangle evidence and repro as the other
            // Predicate<Any> fixes above.
            c = c.replacingOccurrences(of: "init(filterBy: Predicate<Any>?", with: "init(filterBy: Predicate<A>?")

            // Fix: _SectionExpression<A>'s cases render `Expression<Any, ...>` instead of
            // `Expression<A, ...>` (confirmed via swift-demangle: real ABI is
            // "Foundation.Expression<Pack{A}, Swift.String>", since Expression is declared with
            // a variadic generic `each Input` and this type passes its own generic parameter as
            // a single-element pack) -- same generic-placeholder-resolved-as-Any/Pack gap as the
            // Predicate<Any> fixes above, confirmed via a minimal repro.
            c = c.replacingOccurrences(of: "Expression<Any, Swift.String>", with: "Expression<A, Swift.String>")
            c = c.replacingOccurrences(of: "Expression<Any, Swift.String?>", with: "Expression<A, Swift.String?>")
            // The Expression<A,...> fix alone wasn't enough -- a byte-level symbol comparison
            // (nm on our fp dylib vs the required stub) showed the real enum case constructor
            // additionally mangles in a "where A: PersistentModel" constraint that
            // _SectionExpression<A>'s bare, unconstrained header doesn't carry.
            c = c.replacingOccurrences(
                of: "public enum _SectionExpression<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public enum _SectionExpression<A>: Codable, Hashable, @unchecked Sendable where A: PersistentModel {")

            // Fix: Schema.Index.Types<B>'s `binary`/`rtree` cases reference a bogus top-level
            // "A1" (the generator's auto-generated placeholder struct for an undeclared type,
            // confirmed via grep: "public struct A1: Hashable, Codable, Sendable {}" elsewhere in
            // this file) instead of Types' own generic parameter "B" -- the parser apparently
            // fell through to the undeclared-type stub path instead of binding to the enclosing
            // generic parameter. Confirmed via a minimal repro to produce the exact required
            // "enum case for ...Types.binary/rtree" symbols once corrected to "B".
            c = c.replacingOccurrences(of: "case binary(_: [PartialKeyPath<A1>])", with: "case binary(_: [PartialKeyPath<B>])")
            c = c.replacingOccurrences(of: "case rtree(_: [PartialKeyPath<A1>])", with: "case rtree(_: [PartialKeyPath<B>])")
            // Same byte-level finding as _SectionExpression above: the real enum case
            // constructor symbols additionally mangle in "where A: PersistentModel, B:
            // PersistentModel" constraints that Schema.Index<A>/Types<B>'s bare, unconstrained
            // headers don't carry.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class Index<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty {",
                with: "@_fixed_layout public class Index<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty where A: PersistentModel {")
            c = c.replacingOccurrences(
                of: "public enum Types<B>: Codable, Hashable, @unchecked Sendable {",
                with: "public enum Types<B>: Codable, Hashable, @unchecked Sendable where B: PersistentModel {")
            // Types<B>'s == also wrongly self-references "Types<Any>" instead of "Types<B>"
            // (same bogus-placeholder-Any pattern as the case payloads above) -- harmless before
            // the `where B: PersistentModel` bound was added, but now a hard compile error since
            // Any doesn't conform to PersistentModel.
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: Types<Any>, _ rhs: Types<Any>) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: Types<B>, _ rhs: Types<B>) -> Bool { fatalError() }")
            // Same fix for Schema.Unique<A> (its CodingKeys.constraints case constructor has the
            // identical missing-constraint gap).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class Unique<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty {",
                with: "@_fixed_layout public class Unique<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty where A: PersistentModel {")
            c = c.replacingOccurrences(of: "public var predicate: Predicate<Any>?", with: "public var predicate: Predicate<A>?")
            c = c.replacingOccurrences(of: "public final var filterBy: Predicate<Any>?", with: "public final var filterBy: Predicate<A>?")
            c = c.replacingOccurrences(
                of: "public func delete<GenericA>(model: GenericA.Type, where: Predicate<Any>?, includeSubclasses: Swift.Bool) throws -> () where GenericA: PersistentModel {}",
                with: "public func delete<GenericA>(model: GenericA.Type, where: Predicate<GenericA>?, includeSubclasses: Swift.Bool) throws -> () where GenericA: PersistentModel {}")
            // DefaultStore's HistoryProviding.historyType witness returns
            // `DefaultHistoryTransaction.Type` (a concrete metatype), but the protocol
            // requirement is typed `Any` (another generic-placeholder-path erasure — the real
            // requirement is `Self.HistoryType.Type`). A concrete-type witness can't satisfy a
            // requirement declared as bare `Any`; restore the associated-type-metatype form.
            c = c.replacingOccurrences(
                of: "static var historyType: Any { get }",
                with: "static var historyType: Self.HistoryType.Type { get }")
        }

        if parser.defaultModule == "TipKit" {
            // Fix: TipView<A> is missing its own `A: Tip` bound (confirmed via swift-demangle:
            // dropping this bound changes the generic-signature encoding of every "A == AnyTip"
            // -constrained member declared in the body, silently corrupting their mangled
            // symbols even though they otherwise compile fine). TipView<Content>'s 6
            // "Content == AnyTip"-constrained convenience inits are also entirely missing (the
            // generator only renders the unconstrained-Content overloads). Confirmed via a
            // minimal repro that restoring the `A: Tip` bound plus a member-level trailing
            // `where A == AnyTip` clause declared directly in the struct body (not a constrained
            // extension) produces exact byte-for-byte matches for all 6 required init symbols.
            c = c.replacingOccurrences(
                of: "public struct TipView<A>: SwiftUI.View {",
                with: """
                public struct TipView<A>: SwiftUI.View where A: Tip {
                    public init(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, action: @escaping (Tips.Action) -> () = { _ in }) where A == AnyTip { fatalError() }
                    public init<A1>(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, anchorID: A1, action: @escaping (Tips.Action) -> () = { _ in }) where A == AnyTip, A1: Hashable, A1: Sendable { fatalError() }
                    public init<A1>(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, anchorID: A1) where A == AnyTip, A1: Hashable, A1: Sendable { fatalError() }
                    public init<A1>(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, anchorTo: A1.Type) where A == AnyTip, A1: TipAnchorKey { fatalError() }
                    public init(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil) where A == AnyTip { fatalError() }
                    public init(_ arg1: (any Tip)?, arrowEdge: SwiftUI.Edge? = nil, action: @escaping (Tips.Action) -> () = { _ in }) where A == AnyTip { fatalError() }
                """)

            // Fix: DonatedWithin/DonationFilter/LargestSubset/SmallestSubset (all nested in
            // `extension PredicateExpressions`) render as completely non-generic structs with a
            // bogus `typealias A = Any` -- same generic-arity-discovery-failure pattern as
            // CryptoKit's HKDF fixed earlier this session, since no ABI symbol ever applies a
            // generic argument directly to any of these types outside their own members. Made
            // them properly generic (2 params for DonatedWithin, 3 for the other three) with the
            // real bounds, and added the entirely-missing build_donatedWithin/build_DonationFilter/
            // build_largestSubset/build_smallestSubset static factory functions. Confirmed via a
            // minimal repro to produce exact byte-for-byte matches for all 4 struct/evaluate/
            // conformance-descriptor triples and all 4 build_* functions (their generic
            // conformance witness tables remain unfixable, same established pattern as elsewhere).
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct DonatedWithin: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct DonatedWithin<A, B>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, B.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_donatedWithin<A, B>(_ arg1: B, _ arg2: Tips.DonationTimeRange) -> DonatedWithin<A, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct DonationFilter: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct DonationFilter<A, B, C>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Decodable, B: Encodable, B: Sendable, C: Sendable, C: EventPredicateExpression, C.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_DonationFilter<A, B, C>(_ arg1: B, keyPath: Swift.KeyPath<A, C>, op: PredicateExpressions.DonationFilterOperator, value: C) -> DonationFilter<A, C, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, C: Decodable, C: Encodable, C: Sendable, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct LargestSubset: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct LargestSubset<A, B, C>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Decodable, B: Encodable, B: Hashable, B: Sendable, C: Sendable, C: EventPredicateExpression, C.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_largestSubset<A, B, C>(_ arg1: B, groupedBy: Swift.KeyPath<A, C>) -> LargestSubset<A, C, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, C: Decodable, C: Encodable, C: Hashable, C: Sendable, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct SmallestSubset: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct SmallestSubset<A, B, C>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Decodable, B: Encodable, B: Hashable, B: Sendable, C: Sendable, C: EventPredicateExpression, C.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_smallestSubset<A, B, C>(_ arg1: B, groupedBy: Swift.KeyPath<A, C>) -> SmallestSubset<A, C, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, C: Decodable, C: Encodable, C: Hashable, C: Sendable, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)

            // Fix: Swift.Sequence's donatedWithin/largestSubset/smallestSubset extension methods
            // are entirely missing. Confirmed via a minimal repro to produce exact byte-for-byte
            // matches for all 3 required symbols.
            c += """


            extension Sequence {
                public func donatedWithin<A>(_ arg1: Tips.DonationTimeRange) -> [Self.Element] where A: Decodable, A: Encodable, A: Sendable, Self.Element == Tips.Event<A>.Donation { fatalError() }
                public func largestSubset<A, B>(groupedBy: Swift.KeyPath<A, B>) -> [Self.Element] where A: Decodable, A: Encodable, A: Sendable, B: Hashable, Self.Element == Tips.Event<A>.Donation { fatalError() }
                public func smallestSubset<A, B>(groupedBy: Swift.KeyPath<A, B>) -> [Self.Element] where A: Decodable, A: Encodable, A: Sendable, B: Hashable, Self.Element == Tips.Event<A>.Donation { fatalError() }
            }
            """

            // Fix: EventPredicateExpression's associated type renders as a bare, unnamed
            // `associatedtype A` instead of the real primary associated type `Output` (confirmed
            // via swift-demangle: "any TipKit.EventPredicateExpression<...Output == Swift.Bool>"
            // requires the protocol to declare `<Output>` as a primary associated type).
            c = c.replacingOccurrences(
                of: "public protocol EventPredicateExpression: Foundation.PredicateExpression {\n    associatedtype A\n}",
                with: "public protocol EventPredicateExpression<Output>: Foundation.PredicateExpression {\n}")

            // Fix: Tips.Rule's 2 inits use unconstrained existentials ("any StandardPredicateExpression",
            // "any EventPredicateExpression") instead of the required `<Bool>`-constrained ones
            // (both protocols declare a primary associated type `Output`, and the real ABI
            // constrains it to Swift.Bool). Confirmed via a minimal repro to produce exact
            // byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public init<A>(_ arg1: Tips.Parameter<A>, _ arg2: (PredicateExpressions.Variable<A>) -> any StandardPredicateExpression) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }",
                with: "public init<A>(_ arg1: Tips.Parameter<A>, _ arg2: (PredicateExpressions.Variable<A>) -> any StandardPredicateExpression<Swift.Bool>) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(_ arg1: Tips.Event<A>, _ arg2: (PredicateExpressions.Variable<Tips.Event<A>>) -> any EventPredicateExpression) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }",
                with: "public init<A>(_ arg1: Tips.Event<A>, _ arg2: (PredicateExpressions.Variable<Tips.Event<A>>) -> any EventPredicateExpression<Swift.Bool>) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }")

            // Fix: Tips.Event<A> is missing its own bound (A: Decodable, A: Encodable, A: Sendable)
            // and the Sendable conformance -- confirmed via swift-demangle: dropping these
            // silently corrupts the mangled signature of every "A == EmptyDonation"-constrained
            // member declared in the body, same pattern as TipView<A>'s missing `A: Tip` bound
            // above. Confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public struct Event<A>: Identifiable, Tips.RuleInput {",
                with: "public struct Event<A>: Identifiable, Tips.RuleInput, Sendable where A: Decodable, A: Encodable, A: Sendable {")
        }

        if parser.defaultModule == "CreateML" {
            // Fix: MLDataColumn<A>/MLUntypedColumn declare ==/!= but are missing the ordering
            // operators (>, <, >=, <=) entirely -- added directly, matching the existing ==/!=
            // overload shape (3 overloads each: column-column, column-scalar, scalar-column).
            // Confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public struct MLDataColumn<A>: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible {",
                with: """
                public struct MLDataColumn<A>: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible where A: MLDataValueConvertible {
                    public static func >(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >=(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >=(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >=(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <=(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <=(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <=(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public struct MLUntypedColumn: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible {",
                with: """
                public struct MLUntypedColumn: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible {
                    public static func >(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func >(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func >(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func <(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func >=(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func >=(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func >=(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <=(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <=(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func <=(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                """)

            // Fix: MLRegressorMetrics/MLClassifierMetrics/MLObjectDetectorMetrics's static
            // __evaluation(on:...) factory methods are entirely missing. Added directly,
            // confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public struct MLRegressorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {",
                with: """
                public struct MLRegressorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {
                    public static func __evaluation(on: MLDataTable, targetColumn: Swift.String, predictionColumn: Swift.String) throws -> MLRegressorMetrics { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public struct MLClassifierMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {",
                with: """
                public struct MLClassifierMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {
                    public static func __evaluation(on: MLDataTable, labelColumn: Swift.String, predictionColumn: Swift.String, classes: [Swift.String]) throws -> MLClassifierMetrics { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public struct MLObjectDetectorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {",
                with: """
                public struct MLObjectDetectorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {
                    public static func __evaluation(on: MLDataTable, imageColumn: Swift.String, annotationColumn: Swift.String, predictionColumn: Swift.String, classes: [Swift.String]) throws -> MLObjectDetectorMetrics { fatalError() }
                """)

            // Fix: `extension Array where Element: MLDataValueConvertible`/`extension Dictionary
            // where Key: ..., Value: ...` add the protocol's members conditionally but never
            // declare the conformance itself (`: MLDataValueConvertible` is missing from the
            // extension header) -- same "retroactive conditional conformance never declared" gap
            // fixed for SwiftData's Array/Optional:RelationshipCollection earlier this session.
            // Their witness tables remain unfixable (established generic-conformance pattern).
            c = c.replacingOccurrences(
                of: "extension Array where Element: MLDataValueConvertible {",
                with: "extension Array: MLDataValueConvertible where Element: MLDataValueConvertible {")
            c = c.replacingOccurrences(
                of: "extension Dictionary where Key: MLDataValueConvertible,  Value: MLDataValueConvertible {",
                with: "extension Dictionary: MLDataValueConvertible where Key: MLDataValueConvertible,  Value: MLDataValueConvertible {")

            // Fix: MLDataColumn<A> is missing its own `A: MLDataValueConvertible` bound (confirmed
            // via the real swiftinterface header -- restored above, alongside the >/</>=/<=
            // operators). The generator already renders every "A =="-constrained member
            // (arithmetic operators, aggregates, the cross-type `init(column:)`) correctly in
            // their own constrained extensions -- restoring just the missing base-struct bound is
            // enough for their mangled symbols to become correct too, confirmed via a minimal
            // repro to produce exact byte-for-byte matches for all of them.
        }

        if parser.defaultModule == "CoreML" {
            // Fix: `extension ClosedRange/Range where Bound == Swift.Int` add
            // _mlTensorRange/relative(toShapedArrayAxis:) members satisfying
            // MLTensorRangeExpression/MLShapedArrayRangeExpression but never declare either
            // conformance -- same "retroactive conditional conformance never declared" gap fixed
            // repeatedly elsewhere this session. Since Bound == Int makes this a concrete (not
            // generic) conformance, both the conformance descriptor AND witness table are
            // expected and confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "extension ClosedRange where Bound == Swift.Int {",
                with: "extension ClosedRange: MLTensorRangeExpression, MLShapedArrayRangeExpression where Bound == Swift.Int {")
            c = c.replacingOccurrences(
                of: "extension Range where Bound == Swift.Int {",
                with: "extension Range: MLTensorRangeExpression, MLShapedArrayRangeExpression where Bound == Swift.Int {")

            // Fix: `extension MLShapedArray/MLShapedArraySlice where A: Decodable/Encodable/
            // Equatable` add the matching init(from:)/encode(to:)/== members but never declare
            // the conformances themselves -- same "retroactive conditional conformance never
            // declared" gap fixed repeatedly elsewhere this session. Confirmed via a minimal
            // repro that only the conformance descriptors are needed (no witness tables, unlike
            // protocols with real requirement witnessing machinery).
            c = c.replacingOccurrences(
                of: "extension MLShapedArray where A: Decodable {",
                with: "extension MLShapedArray: Decodable where A: Decodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArray where A: Encodable {",
                with: "extension MLShapedArray: Encodable where A: Encodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArray where A: Equatable {",
                with: "extension MLShapedArray: Equatable where A: Equatable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArraySlice where A: Decodable {",
                with: "extension MLShapedArraySlice: Decodable where A: Decodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArraySlice where A: Encodable {",
                with: "extension MLShapedArraySlice: Encodable where A: Encodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArraySlice where A: Equatable {",
                with: "extension MLShapedArraySlice: Equatable where A: Equatable {")

            // Fix: withMLTensorComputePolicy's closure params are declared @escaping, but the
            // real ABI mangles them as non-escaping (`XE`, not `c`) -- confirmed via minimal
            // repro that dropping @escaping alone produces exact byte-for-byte matches for both
            // overloads and the async variant's async function pointer.
            c = c.replacingOccurrences(
                of: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: @escaping () throws -> A) throws -> A { fatalError() }",
                with: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: () throws -> A) throws -> A { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: @escaping () async throws -> A) async throws -> A { fatalError() }",
                with: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: () async throws -> A) async throws -> A { fatalError() }")

            // Fix: MLTensor is missing the .>/.</.>=/.<= comparison operators entirely (both the
            // MLTensor-MLTensor overload and the generic-scalar overload), while its sibling
            // .==/.!= operators ARE present -- confirmed via minimal repro these are simply
            // missing declarations, adding them alongside .== produces exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public static func .==(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }",
                with: """
                public static func .==(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .>(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .><GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                    public static func .<(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .<<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                    public static func .>=(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .>=<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                    public static func .<=(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .<=<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                """)

            // Fix: MLTensor.init(rangeFrom:to:by:scalarType:)'s `by` param is declared as `Any`
            // instead of the real `A.Stride` (A: Strideable) -- confirmed via minimal repro that
            // using the correct associated-type produces an exact byte-for-byte match.
            c = c.replacingOccurrences(
                of: "public init<A>(rangeFrom: A, to: A, by: Any, scalarType: A.Type) where A: MLTensorScalar,  A: Strideable { fatalError() }",
                with: "public init<A>(rangeFrom: A, to: A, by: A.Stride, scalarType: A.Type) where A: MLTensorScalar,  A: Strideable { fatalError() }")

            // Fix: MLTensor's 4 UnboundedRange-taking subscripts. 3 of the 4 leading-Range-count
            // variants (1/2/3 leading `(any MLTensorRangeExpression)?` params before the closure)
            // exist but declare the closure param `@escaping`, which mangles as a plain function
            // type (`c`) instead of the real noescape shape (`XE`); the 4th variant (0 leading
            // ranges, i.e. just the closure + trailing variadic) is missing outright. Confirmed
            // via minimal repro that dropping @escaping on the 3 existing ones, and adding the
            // missing 4th with the same non-escaping shape, produces exact byte-for-byte matches
            // for all 4.
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: (any MLTensorRangeExpression)?, _ arg4: @escaping (UnboundedRange_) -> (), _ arg5: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: (any MLTensorRangeExpression)?, _ arg4: (UnboundedRange_) -> (), _ arg5: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: @escaping (UnboundedRange_) -> (), _ arg4: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: (UnboundedRange_) -> (), _ arg4: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: @escaping (UnboundedRange_) -> (), _ arg3: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (UnboundedRange_) -> (), _ arg3: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: @escaping (UnboundedRange_) -> (), _ arg2: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (UnboundedRange_) -> (), _ arg2: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")

            // Fix: MLIRRepresentation.sourceIR is declared as a synchronous getter, but the real
            // ABI requires an async getter (hence the missing async function pointer symbol) --
            // confirmed via minimal repro that `get async` alone produces an exact byte-for-byte
            // match for both the getter and its async function pointer.
            c = c.replacingOccurrences(
                of: "public var sourceIR: Data { get { return Data() } }",
                with: "public var sourceIR: Data { get async { return Data() } }")

            // Fix: MLShapedArrayProtocol's UnboundedRange-taking subscript declares its closure
            // param `@escaping` -- same bug as MLTensor's equivalent subscripts above, mangling
            // as a plain function type (`c`) instead of the real noescape shape (`XE`). Confirmed
            // via minimal repro that dropping @escaping produces exact byte-for-byte matches for
            // the getter, setter, AND modify accessor.
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: @escaping (UnboundedRange_) -> ()) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }",
                with: "public subscript(_ arg1: (UnboundedRange_) -> ()) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }")

            // Fix: the real ABI has `_OBJC_CLASS_$_MLModelStructure`/`_OBJC_METACLASS_$_MLModelStructure`
            // and the same pair for MLOptimizationHints, but the real .swiftinterface shows both
            // names as genuine Swift value types (enum/struct) with no ObjC class at all -- these
            // ObjC symbols belong to a private, non-public-API ObjC-bridging implementation class
            // that happens to share the same runtime name. Confirmed via minimal repro that a
            // hidden `@objc(Name) open class` with a DIFFERENT Swift-visible identifier can coexist
            // with the public enum/struct of the same runtime name and produces the exact required
            // linker symbols without conflicting with the public declaration.
            c = c.replacingOccurrences(
                of: "public enum MLModelStructure: Codable, Hashable, @unchecked Sendable {",
                with: """
                @objc(MLModelStructure) open class _MLModelStructureObjCShadow: NSObject {}
                public enum MLModelStructure: Codable, Hashable, @unchecked Sendable {
                """)
            c = c.replacingOccurrences(
                of: "public struct MLOptimizationHints: Equatable {",
                with: """
                @objc(MLOptimizationHints) open class _MLOptimizationHintsObjCShadow: NSObject {}
                public struct MLOptimizationHints: Equatable {
                """)
        }

        if parser.defaultModule == "AppleIntelligenceReporting" {
            // Restore the header constraint the real class declares (confirmed via its own
            // ABI: lazySource.source's mangled type is "any Source<Self.Stream == A>", which
            // only a constrained "class lazySource<A> where A: Stream" produces) and restore
            // sendEvent's real parameter type. The earlier attempt to do this (commit 395cc88)
            // also declared the Stream conformance as a RETROACTIVE extension in THIS module
            // ("extension IntelligencePlatformLibrary.Foo: IntelligencePlatformLibrary.Stream")
            // — a cross-module conformance forces Swift to mangle every lazySource<Foo>
            // instantiation with an extra protocol-witness-table substitution path (confirmed
            // via isolated testing: same-module conformance mangles clean, cross-module
            // retroactive conformance adds "...AiG6StreamAAyHCg_G..."), which is what caused
            // the regression from 26 to 65 stubs and led to reverting this constraint entirely.
            // Fix: declare the conformance where the type itself lives instead — the
            // "stubTypeConformances" hook below injects it directly into the
            // IntelligencePlatformLibrary(_AppleInternal) stub's own StubNode, so the
            // conformance is native to that module, matching the real ABI's mangling.
            c = c.replacingOccurrences(
                of: "class lazySource<A> {",
                with: "class lazySource<A> where A: IntelligencePlatformLibrary.Stream {"
            )
            c = c.replacingOccurrences(
                of: "class lazySourceInternal<A> {",
                with: "class lazySourceInternal<A> where A: IntelligencePlatformLibrary_AppleInternal.Stream {"
            )
            c = c.replacingOccurrences(
                of: "func sendEvent(_ arg1: Any)",
                with: "func sendEvent(_ arg1: A.EventType)")
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
        let declPattern = "(?:(?:public|open)\\s+(?:struct|class|enum|protocol|typealias)|typealias|extension)\\s+(_[A-Za-z][A-Za-z0-9_]*)"
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
        if parser.defaultModule == "Translation" {
            // _LTTextSessionDelegate needs the @objc-protocol bridge-header forward-declaration
            // added in generateExports (this file's writeGeneratedFiles/bridge-header logic), not
            // the generic native-Swift-struct placeholder the "undeclared SPI type" fallback just
            // above renders for any bare underscore-prefixed identifier -- must run after that
            // fallback since it runs unconditionally for any bare `_LTTextSessionDelegate`
            // reference still in `c` at this point, re-adding the struct if stripped earlier.
            c = c.replacingOccurrences(
                of: "public struct _LTTextSessionDelegate: Hashable, Sendable {}",
                with: "")
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

        if parser.defaultModule == "CoreAIRuntime" {
            // _AllRange conforms to NDArray.RangeExpression (confirmed via a real conformance
            // descriptor symbol, `_$s13CoreAIRuntime9_AllRangeVAA7NDArrayV0D10ExpressionAAMc`)
            // but has no `relative(to:)` witness anywhere in the ABI at all — not on _AllRange
            // itself, nor on any of RangeExpression's other conformers (Int, ClosedRange<Int>),
            // meaning the real implementation is satisfied by an `@inline(__always)`/generic
            // default that never emits its own exported symbol. Give the protocol a default
            // implementation instead of guessing at per-conformer bodies: `_AllRange`
            // represents "the entire range" so returning the input unchanged is the only
            // semantically valid default reachable at all sites (each real conformer's actual
            // behavior differs, but none of it is ABI-visible to reconstruct).
            c += "\nextension NDArray.RangeExpression {\n    public func relative(to range: Range<Swift.Int>) -> Range<Swift.Int> { return range }\n}\n"

            // InferenceFunction.Inputs.insert<A>/MutableViews.insert<A> take an
            // A: ViewRepresentable/MutableViewRepresentable generic parameter that is ALSO
            // constrained `A: ~Copyable` (confirmed via swift-demangle -expand on the real
            // symbol: "insert<A where A: ...ViewRepresentable, A: ~Swift.Copyable>"). Two
            // gaps against that ABI:
            // 1. ViewRepresentable/MutableViewRepresentable are declared plain (implicitly
            //    `: Copyable`), so a conformer can never also be `~Copyable` — the protocols
            //    themselves must opt out of the implicit Copyable requirement.
            // 2. A noncopyable-typed parameter needs an explicit ownership convention
            //    (borrowing/consuming/inout); the demangled signature text doesn't carry
            //    calling-convention detail, so the generator emits a bare, unannotated
            //    parameter, which Swift rejects for any ~Copyable type. The real convention here
            //    is by-value read-only access (insert() doesn't mutate the argument, only the
            //    receiver), so `borrowing` is used for insert()'s immutable `A: ~Copyable` param,
            //    matching every other read-only Span/PixelBuffer-family
            //    noncopyable-parameter fixup already applied elsewhere in this generator.
            c = c.replacingOccurrences(
                of: "public protocol ViewRepresentable: Sendable {",
                with: "public protocol ViewRepresentable: Sendable, ~Copyable {")
            c = c.replacingOccurrences(
                of: "public protocol MutableViewRepresentable: Sendable {",
                with: "public protocol MutableViewRepresentable: Sendable, ~Copyable {")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_ arg1: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_ arg1: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_ arg1: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_ arg1: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}")
        }

        if parser.defaultModule == "InternalSwiftProtobuf" {
            // Message.isEqualTo(message:)'s real ABI mangling is a self-referencing
            // existential (`AaB_p` -> "any Message", confirmed via swift-demangle on the
            // protocol's own dispatch-thunk symbol: "Message.isEqualTo(message:
            // InternalSwiftProtobuf.Message) -> Bool"), not `Self`. The generic-placeholder
            // eraser can't distinguish that shape from an ordinary `Self`-typed requirement, so
            // it rendered the protocol requirement as `message: Self` and every per-conformer
            // witness/the _MessageImplementationBase extension default as `message: any
            // Message` — neither of which satisfies the OTHER: a `Self`-typed requirement
            // needs a `Self`-typed witness, so `any Message` witnesses failed "does not conform
            // to protocol 'Message'" on every single Google_Protobuf_* type (~90 conformers).
            // Fix: rewrite both sides to the real ABI shape, bare `Message` (an implicit
            // existential in this position, verified via a minimal standalone repro).
            c = c.replacingOccurrences(
                of: "func isEqualTo(message: Self) -> Swift.Bool",
                with: "func isEqualTo(message: Message) -> Swift.Bool")
            c = c.replacingOccurrences(
                of: "public func isEqualTo(message: any Message) -> Swift.Bool { fatalError() }",
                with: "public func isEqualTo(message: Message) -> Swift.Bool { fatalError() }")
            // Same self-referencing-existential shape, same fix, for
            // AnyExtensionField.isEqual(other:) across all 10 *ExtensionField conformers
            // (confirmed via swift-demangle: the real requirement is "isEqual(other:
            // InternalSwiftProtobuf.AnyExtensionField) -> Bool", not Self).
            c = c.replacingOccurrences(
                of: "func isEqual(other: Self) -> Swift.Bool",
                with: "func isEqual(other: AnyExtensionField) -> Swift.Bool")
            c = c.replacingOccurrences(
                of: "public func isEqual(other: any AnyExtensionField) -> Swift.Bool { fatalError() }",
                with: "public func isEqual(other: AnyExtensionField) -> Swift.Bool { fatalError() }")
        }

        if parser.defaultModule == "MetalPerformanceShadersGraph" {
            // `counter`'s real ABI (confirmed by grepping the .tbd directly) exports THREE
            // distinct symbols: "vau" (addressor), "vpZ" (raw storage), and "vrZ" (read-borrow
            // accessor) -- Parser.swift's generic stored-static-property handling (silgenSymbols)
            // already emits manual @_silgen_name stubs for "vau" and "vpZ" unconditionally, from
            // parsing the real ABI, independent of how (or whether) this property gets rendered
            // here. The default computed-getter rendering doesn't compile at all (Atomic is a
            // move-only-adjacent type Swift requires `let`, not `var { get }`), and giving it a
            // real initializer (`= .init(0)`) to satisfy that instead backfires for "vpZ"
            // specifically: this toolchain's codegen for such a static let always claims that
            // exact storage-symbol name too (confirmed via nm: as local/private "b"/bss, not
            // exported), colliding with -- and getting linker-renamed away from -- the manual
            // stub's identical name, so neither definition ends up correctly exported either way
            // (it does naturally produce a correctly-exported "vau" and "vrZ" though, with no
            // competing manual duplicate for either). Since nothing else in this generated file
            // references `counter`, simplest fix is to drop the property declaration entirely
            // (avoiding the initializer's "vpZ" collision) and add a manual stub for "vrZ" too
            // (which, unlike "vpZ", has no existing Parser.swift-side mechanism, since it's not
            // one of the two mangled shapes that mechanism recognizes) so all three end up
            // satisfied via manual stubs alone, with no natural declaration competing with any of
            // them.
            c = c.replacingOccurrences(
                of: #"\n\s*public static var counter: (?:Synchronization\.)?Atomic<.*?>.*"#,
                with: "",
                options: .regularExpression)
            c += """

@_silgen_name("$s28MetalPerformanceShadersGraph22MPSGraphDelegateKernelC7counter15Synchronization6AtomicVys6UInt32VGvrZ")
func _stub_counter_vrZ() { fatalError() }

"""
            // Model.swift's own `required` synthesis (isRequired, for a non-final class
            // conforming to a protocol) can already have prepended "required " to this exact
            // initializer -- blindly prepending a second one here produces the illegal
            // "required required public init(...)" (duplicate modifier). Only add it when
            // missing.
            c = c.replacingOccurrences(
                of: "public init(_ arg1: ODIE.DelegateProgramArguments)",
                with: "required public init(_ arg1: ODIE.DelegateProgramArguments)")
            c = c.replacingOccurrences(
                of: "required required public init(_ arg1: ODIE.DelegateProgramArguments)",
                with: "required public init(_ arg1: ODIE.DelegateProgramArguments)")
            // MPSGraphDelegate.Weak<A>'s `value: A?` field-offset symbol only exists in the real
            // ABI ("direct field offset for ...Weak.value : A?") because A is class-constrained
            // (verified via a minimal repro: an unconstrained generic class property gets no
            // direct offset at all under library evolution, needing generic metadata instead --
            // adding `A: AnyObject` alone, without even a `weak` qualifier on the property,
            // reproduces the exact real mangled symbol).
            c = c.replacingOccurrences(
                of: "public class Weak<A> {",
                with: "public class Weak<A: AnyObject> {")
            // Executables.init's `mpsExecutable`/`ndxRuntimeBase` defaults and
            // MPSGraphDelegateKernel.init's `executable`/`adapterExecutable`/
            // `executableExecutionDescriptor` params are all real ObjC class-typed optionals
            // that the generator renders with an explicit `borrowing` keyword (copied verbatim
            // from the swiftinterface's printed ownership annotation) -- but swift-demangle on
            // the real ABI symbols shows no ownership modifier ("...CSg_..." not "...CSgh_...";
            // confirmed via a minimal repro that explicit `borrowing` on a plain copyable
            // class-optional parameter adds an "h" ownership-convention marker the mangler
            // doesn't otherwise emit for the implicit default convention). The interface printer
            // annotation reflects the implicit default calling convention, not an explicit
            // source-level keyword, so re-emitting it as literal `borrowing` changes the mangled
            // signature of the initializer and all its default-argument thunks. Strip it here
            // (RawSpan/RawSpan-typed params elsewhere in this module are unaffected -- those
            // genuinely require explicit borrowing and aren't in the stub list).
            c = c.replacingOccurrences(
                of: "mpsExecutable: borrowing MPSGraphExecutable?",
                with: "mpsExecutable: MPSGraphExecutable?")
            c = c.replacingOccurrences(
                of: "executable: borrowing MPSGraphExecutable?, adapterExecutable: borrowing MPSGraphExecutable?",
                with: "executable: MPSGraphExecutable?, adapterExecutable: MPSGraphExecutable?")
            c = c.replacingOccurrences(
                of: "executableExecutionDescriptor: borrowing MPSGraphExecutableExecutionDescriptor?",
                with: "executableExecutionDescriptor: MPSGraphExecutableExecutionDescriptor?")
            // reorderInputsAndOutputs<A>'s outputIsInOut closure param renders with an explicit
            // `@escaping` the generator added -- but swift-demangle on the real ABI symbol shows
            // the non-escaping closure-type marker "XE" (confirmed via a minimal repro: default,
            // non-@escaping closures mangle with "XE"; @escaping ones mangle as a plain thick
            // closure with no "X" marker at all -- the reverse of what the keyword's name
            // suggests). Drop the erroneously-added `@escaping`.
            c = c.replacingOccurrences(
                of: "outputIsInOut: @escaping (Swift.Int) -> Swift.Bool) -> (reorderedInputs: [A], reorderedOutputs: [A])",
                with: "outputIsInOut: (Swift.Int) -> Swift.Bool) -> (reorderedInputs: [A], reorderedOutputs: [A])")
            // MPSGraphDelegateError's real ABI has init(from:)/encode(to:) members implying real
            // Codable conformance (confirmed via swift-demangle: separate Encodable and Decodable
            // conformance descriptors both exist), but the generator only emits the bare
            // default-implementation members without restating the conformance -- same
            // conformance-restatement gap already fixed for Charts/HealthKit/Combine types this
            // session.
            c = c.replacingOccurrences(
                of: "public enum MPSGraphDelegateError: Error {",
                with: "public enum MPSGraphDelegateError: Codable, Error {")
            // delegateLogger's real ABI (confirmed by grepping the .tbd directly) exports exactly
            // two symbols: "vau" (addressor) and "vp" (raw storage) -- no getter at all. The
            // generator renders any top-level `os.Logger`-typed global as a computed get-only
            // `var { get { fatalError() } }`, which produces neither. Giving it a real
            // initializer instead (`@MainActor public let delegateLogger: Logger = Logger()`)
            // does naturally produce a correctly-present "vau", but for "vp" specifically hits
            // the exact same collision as counter's "vpZ" above: nm shows Swift's own synthesized
            // storage for the constant claims that exact name as a local "b" (bss) symbol -- and
            // --compare's own extractDylibSymbols() explicitly excludes "b"-type symbols from
            // counting as present (main.swift's `symType != "b"` filter), so even though the name
            // exists in the dylib's symbol table, it never satisfies the comparison; a second,
            // manually `@_silgen_name`-tagged declaration of the identical name doesn't help
            // either, since the two same-named definitions just collide and one gets
            // linker-renamed away (confirmed via nm: "...Vvp.6"). Fixed the same way as counter:
            // drop the property declaration entirely (nothing else in this file references
            // delegateLogger) so no natural definition of either symbol competes with a manual
            // stub, then force both missing symbols directly.
            c = c.replacingOccurrences(
                of: "public var delegateLogger: Logger { get { fatalError() } }",
                with: "")
            c += """

@_silgen_name("$s28MetalPerformanceShadersGraph14delegateLogger2os0F0Vvau")
func _stub_delegateLogger_vau() { fatalError() }

@_silgen_name("$s28MetalPerformanceShadersGraph14delegateLogger2os0F0Vvp")
func _stub_delegateLogger_vp() { fatalError() }

"""
            // Executables.init's `mpsExecutable`/`ndxRuntimeBase` default-argument generator
            // thunks (args 0 and 2 -- kernelCache's arg 1, a non-trivial `[:]` dictionary literal,
            // already renders fine) never get emitted by this toolchain: a minimal repro
            // confirms plain `nil`-literal defaults for Optional<ObjC class> params produce no
            // default-argument-generator symbol at all under library evolution (the literal gets
            // inlined at every call site instead), yet the real ABI has genuine, separate
            // generator-function symbols for both -- almost certainly because the real framework
            // was built by an older Swift compiler whose codegen rules for trivial defaults
            // differed. Force both missing symbols directly.
            c += """

@_silgen_name("$s28MetalPerformanceShadersGraph16MPSGraphDelegateC11ExecutablesV13mpsExecutable11kernelCache14ndxRuntimeBaseAESo0eI0CSg_SDyAC06KernelK3KeyVAC4WeakCy_AA0efO0CGGSo0E10NDXRuntimeCSgtcfcfA_")
func _stub_ExecutablesV_defaultArg0() { fatalError() }

@_silgen_name("$s28MetalPerformanceShadersGraph16MPSGraphDelegateC11ExecutablesV13mpsExecutable11kernelCache14ndxRuntimeBaseAESo0eI0CSg_SDyAC06KernelK3KeyVAC4WeakCy_AA0efO0CGGSo0E10NDXRuntimeCSgtcfcfA1_")
func _stub_ExecutablesV_defaultArg2() { fatalError() }

"""
            // Array.init(Span<Element>) is a real retroactive extension MetalPerformanceShadersGraph
            // adds to Swift.Array (confirmed via swift-demangle: "(extension in
            // MetalPerformanceShadersGraph):Swift.Array.init(Swift.Span<A>) -> [A]") that the
            // generator never renders at all (Array is a stdlib type, not one of this module's
            // own nominal types, so the normal per-type extension-rendering path never reaches
            // it).
            c += """

extension Array {
    public init(_ span: Swift.Span<Element>) { fatalError() }
}

"""
        }

        if parser.defaultModule == "PromptKit" {
            // ChatMessagesPrompt/CompletionPrompt conform to GenerativeConfigurationProtocol
            // (associatedtype PromptType: PromptMode) and PromptMode (associatedtype
            // PromptContentType: Decodable) but never got per-conformer typealiases for either
            // associated type — the generator has no per-type ABI signal for them (neither
            // type has its own direct exported symbols; PromptKit.tbd shows only a single,
            // unrelated generic-bound reference to "ChatMessagesPrompt", no ChatMessagesPromptV
            // symbols at all), so the usual "resolve from a real witness" path finds nothing to
            // resolve from. PromptType is self-referential by construction (each of these types
            // IS its own PromptMode), and PromptContentType is satisfied by String (both types
            // are fundamentally string/message-content-based).
            c = c.replacingOccurrences(
                of: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {",
                with: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = ChatMessagesPrompt\n    public typealias PromptContentType = Swift.String")
            c = c.replacingOccurrences(
                of: "public struct CompletionPrompt: Codable, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {",
                with: "public struct CompletionPrompt: Codable, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = CompletionPrompt\n    public typealias PromptContentType = Swift.String")
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
            // StreamProtocol's real ABI likewise declares `associatedtype Metadata` (confirmed
            // via `swift-demangle` on its dispatch-thunk symbols, e.g. send's parameter type
            // demangles as "metadata: A.Metadata") and every requirement already correctly uses
            // `Self.Metadata` (no `Any`-erasure to fix here, unlike MessageProtocol above) — the
            // only missing piece is the associatedtype declaration itself.
            if let headerRange = c.range(of: "public protocol StreamProtocol: OneToOneProtocol {") {
                var depth = 1
                var idx = headerRange.upperBound
                var bodyEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { bodyEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                let body = String(c[headerRange.upperBound..<bodyEnd]) + "    associatedtype Metadata\n"
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
            // StreamDeserializationBuilder is the @resultBuilder type for StreamDeserializer.
            // The generator emitted it as a plain non-generic struct, but its sole extension
            // uses `A` and `C` freely (as in StreamDeserializer<A, Any, C>), producing 20
            // "cannot find type 'A' in scope" errors.  Fix: add `@resultBuilder` and make
            // the declaration generic <A: ~Copyable, C: ~Copyable & ~Escapable> to match.
            c = c.replacingOccurrences(
                of: "public struct StreamDeserializationBuilder: Codable, Hashable, @unchecked Sendable {",
                with: "@resultBuilder public struct StreamDeserializationBuilder<A: ~Copyable, C: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: StreamDeserializationBuilder, _ rhs: StreamDeserializationBuilder) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: StreamDeserializationBuilder<A, C>, _ rhs: StreamDeserializationBuilder<A, C>) -> Bool { fatalError() }")
            c = c.replacingOccurrences(
                of: "extension StreamDeserializationBuilder {",
                with: "extension StreamDeserializationBuilder where A: StreamDeserializerState {")
            // Fix 9: `TLVFramer` is a non-final class conforming to `NWProtocolFramerImplementation`
            // which requires `init(framer:)`.  Protocol init requirements must be `required` in
            // non-final classes.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class TLVFramer: NWProtocolFramerImplementation {\n    public init(framer: NWProtocolFramer.Instance)",
                with: "@_fixed_layout public class TLVFramer: NWProtocolFramerImplementation {\n    public required init(framer: NWProtocolFramer.Instance)")
            // Fix 10: `NetworkBrowser<A>.RunResult` is a plain (non-generic) enum, but the
            // `run<GenericA>` method was emitted with `RunResult<GenericA>` — strip the type arg.
            c = c.replacingOccurrences(
                of: "NetworkBrowser<A>.RunResult<GenericA>",
                with: "NetworkBrowser<A>.RunResult")
            // discoveredNestedGenericPairs (Parser.swift's precompute()) sees the real ABI's
            // "NetworkBrowser<A>.RunResult<A1>" case-witness symbols and correctly records
            // RunResult as taking 1 own generic param — but this codebase's established
            // workaround (above) keeps RunResult itself non-generic and instead lets its
            // `finish(_:)` payload fall back to the global opaque `A1` placeholder struct.
            // Undo the now-generic declaration/use-sites this produces so that workaround still
            // applies cleanly.
            c = c.replacingOccurrences(
                of: "public enum RunResult<B>: Codable, Hashable, @unchecked Sendable {",
                with: "public enum RunResult: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: RunResult<Any>, _ rhs: RunResult<Any>) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: RunResult, _ rhs: RunResult) -> Bool { fatalError() }")
            // Fix 11: `QUIC.TLS` (nested) and top-level `TLS` are two different structs.
            // `PeerAuthentication` lives in the top-level `TLS`; methods inside `QUIC.TLS` reference
            // `TLS.PeerAuthentication` which Swift resolves as `QUIC.TLS.PeerAuthentication` — but
            // that nested type doesn't exist.  The struct declaration line is stable and unique;
            // inject a typealias right after the opening brace.
            c = c.replacingOccurrences(
                of: "    public struct TLS: Codable, Hashable, @unchecked Sendable {\n",
                with: "    public struct TLS: Codable, Hashable, @unchecked Sendable {\n        public typealias PeerAuthentication = Network.TLS.PeerAuthentication\n")
            // Fix 12: Same demangler artifact as fix 8 but for `MultiplexingPath`.
            // `Self.Path.MultiplexingPath.ParentProtocol` → `Self.Path.ParentProtocol`.
            c = c.replacingOccurrences(
                of: "Self == Self.Path.MultiplexingPath.ParentProtocol",
                with: "Self == Self.Path.ParentProtocol")
            // Fix 8: The demangler emits `Self.Flow.MultiplexedFlow.ParentProtocol` (and the
            // `SecondaryFlow` variant) as extension constraints.  `MultiplexedFlow` here is the
            // *protocol* the flow conforms to, not a nested type — Swift can't resolve it as a
            // member type on `Self.Flow`.  The real semantic is `Self == Self.Flow.ParentProtocol`
            // (since `MultiplexedFlow` declares `associatedtype ParentProtocol: ManyToManyProtocolHandler`).
            // Strip the spurious `.MultiplexedFlow` path component from both variants.
            c = c.replacingOccurrences(
                of: "Self == Self.Flow.MultiplexedFlow.ParentProtocol",
                with: "Self == Self.Flow.ParentProtocol")
            c = c.replacingOccurrences(
                of: "Self == Self.SecondaryFlow.MultiplexedFlow.ParentProtocol",
                with: "Self == Self.SecondaryFlow.ParentProtocol")
            // Fix 7: `Frame` is `~Copyable`, so all parameters of type `Frame` must specify
            // ownership.  Three sites omit the keyword:
            //   1. `init(frame: Frame)` — borrowing (init just reads the frame to copy data)
            //   2. `peekFirstFrame<GenericA>(_ arg1: (Frame) -> GenericA)` — closure takes Frame
            //      by borrowing reference
            //   3. `iterateImmutableFrames(_ arg1: (Frame) -> Bool)` — same
            c = c.replacingOccurrences(of: "public init(frame: Frame)", with: "public init(frame: borrowing Frame)")
            c = c.replacingOccurrences(
                of: "public func peekFirstFrame<GenericA>(_ arg1: (Frame) -> GenericA)",
                with: "public func peekFirstFrame<GenericA>(_ arg1: (borrowing Frame) -> GenericA)")
            c = c.replacingOccurrences(
                of: "public func iterateImmutableFrames(_ arg1: (Frame) -> Swift.Bool)",
                with: "public func iterateImmutableFrames(_ arg1: (borrowing Frame) -> Swift.Bool)")
            // Fix 6: `NWBrowser`, `NWConnection`, and `NWParameters` are NSObject subclasses.
            // Their first extension blocks emit `public final var debugDescription` without
            // `override`, and `NWParameters` emits `convenience init()` without `override`.
            // Use a brace-depth-aware pass to only patch inside the FIRST matching extension.
            do {
                var lines = c.components(separatedBy: "\n")
                var inNWClass = ""
                var depth = 0
                var firstSeenForClass = Set<String>()
                for i in 0..<lines.count {
                    let line = lines[i]
                    let stripped = line.trimmingCharacters(in: .whitespaces)
                    // Track entering/leaving extension blocks
                    let opens = line.filter { $0 == "{" }.count
                    let closes = line.filter { $0 == "}" }.count
                    if depth == 0 {
                        if stripped.hasPrefix("extension NWBrowser") { inNWClass = "NWBrowser"; depth += opens - closes; continue }
                        if stripped.hasPrefix("extension NWConnection") { inNWClass = "NWConnection"; depth += opens - closes; continue }
                        if stripped.hasPrefix("extension NWParameters") { inNWClass = "NWParameters"; depth += opens - closes; continue }
                        inNWClass = ""
                    } else {
                        depth += opens - closes
                        if depth <= 0 { depth = 0; inNWClass = "" }
                    }
                    guard !inNWClass.isEmpty else { continue }
                    // Only patch the first occurrence of debugDescription in each class
                    if line.contains("public final var debugDescription: Swift.String") && !line.contains("override") {
                        if !firstSeenForClass.contains(inNWClass + ".debugDescription") {
                            firstSeenForClass.insert(inNWClass + ".debugDescription")
                            lines[i] = line.replacingOccurrences(
                                of: "public final var debugDescription:",
                                with: "public final override var debugDescription:")
                        }
                    }
                    if line.contains("@nonobjc public convenience init()") && !line.contains("override") {
                        lines[i] = line.replacingOccurrences(
                            of: "@nonobjc public convenience init()",
                            with: "@nonobjc public override convenience init()")
                    }
                }
                c = lines.joined(separator: "\n")
            }
            // Three protocols use `Self.UpperProtocol` without declaring the associatedtype,
            // and member ordering in the generated output varies across runs so we can't match
            // the full protocol body. Use stable anchor strings instead.
            // 1. BottomProtocolHandler: its extensions constrain `Self.UpperProtocol == Inbound*`
            //    but the protocol body only has `var upper: Any`.  Insert the associatedtype
            //    right after the opening brace, and retype `var upper: Any` → `Self.UpperProtocol`.
            c = c.replacingOccurrences(
                of: "public protocol BottomProtocolHandler: OutboundDataHandler {\n",
                with: "public protocol BottomProtocolHandler: OutboundDataHandler {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // Replace the erased `var upper: Any` with the properly typed version. Member
            // ordering in the generated output varies across runs, so locate the protocol body's
            // own brace span first and only replace `var upper: Any` WITHIN that span — a plain
            // whole-file replacingOccurrences would also hit LowerHarness's real class property
            // (same "var upper: Any" text, different declaration) elsewhere in the file.
            if let bodyStart = c.range(of: "public protocol BottomProtocolHandler: OutboundDataHandler {\n"),
               let bodyEnd = c.range(of: "\n}", range: bodyStart.upperBound..<c.endIndex) {
                let body = String(c[bodyStart.upperBound..<bodyEnd.lowerBound])
                let fixedBody = body.replacingOccurrences(
                    of: "var upper: Any { get set }",
                    with: "var upper: Self.UpperProtocol { get set }")
                c.replaceSubrange(bodyStart.upperBound..<bodyEnd.lowerBound, with: fixedBody)
            }
            // 2. MultiplexedFlow: insert `associatedtype UpperProtocol` after the opening brace.
            c = c.replacingOccurrences(
                of: "public protocol MultiplexedFlow: LoggableProtocol {\n",
                with: "public protocol MultiplexedFlow: LoggableProtocol {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // 3. ManyToManyProtocolHandler: insert `associatedtype UpperProtocol` right after
            //    its opening brace (stable position, not dependent on member order).
            c = c.replacingOccurrences(
                of: "public protocol ManyToManyProtocolHandler: ListenerHandler, LoggableProtocol {\n",
                with: "public protocol ManyToManyProtocolHandler: ListenerHandler, LoggableProtocol {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // OneToOneProtocolHandler extensions also constrain Self.UpperProtocol — same fix.
            c = c.replacingOccurrences(
                of: "public protocol OneToOneProtocolHandler: InboundDataHandler, LoggableProtocol, OutboundDataHandler {\n",
                with: "public protocol OneToOneProtocolHandler: InboundDataHandler, LoggableProtocol, OutboundDataHandler {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // ProtocolLinkage's `associatedtype PairedLinkage` is narrowed at every level of the
            // Inbound/Outbound/Upper/Lower/Listener/Flow linkage hierarchy (confirmed via
            // `swift-demangle` on each protocol's "associated conformance descriptor" symbol,
            // e.g. InboundDataLinkage.ProtocolLinkage.PairedLinkage: OutboundDataLinkage) — but
            // the generator emitted each narrowing as an orphaned nested protocol inside its own
            // throwaway "<Name>_Network { public protocol ProtocolLinkage { associatedtype
            // PairedLinkage: ... } }" wrapper struct instead of directly in the real protocol's
            // body, so the narrowing never actually applies. Move each into its real protocol.
            for (protoName, pairedType) in [
                ("InboundDataLinkage", "OutboundDataLinkage"),
                ("InboundFlowLinkage", "ListenerLinkage"),
                ("ListenerLinkage", "InboundFlowLinkage"),
                ("LowerProtocolLinkage", "UpperProtocolLinkage"),
                ("OutboundDataLinkage", "InboundDataLinkage"),
                ("UpperProtocolLinkage", "LowerProtocolLinkage"),
            ] {
                if let r = c.range(of: "public protocol \(protoName): ") {
                    if let braceEnd = c.range(of: " {", range: r.upperBound..<c.endIndex) {
                        c.insert(contentsOf: "\n    associatedtype PairedLinkage: \(pairedType)", at: braceEnd.upperBound)
                    }
                }
            }
            // LowerProtocolLinkage.invokeAttachUpperProtocol's real ABI returns `Self` (its
            // dispatch-thunk demangles to "...) throws(NetworkError) -> A" where A is the
            // protocol's own Self placeholder), but the generic-placeholder eraser replaced it
            // with `Any` on every conformer (DatagramListenerLinkage/OutboundDatagramLinkage/
            // OutboundStreamLinkage/StreamListenerLinkage) — `Self` is safe to substitute
            // directly since it resolves per-conforming-type automatically.
            c = c.replacingOccurrences(
                of: "public func invokeAttachUpperProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Any { fatalError() }",
                with: "public func invokeAttachUpperProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Self { fatalError() }")
            // None of the 8 concrete *Linkage structs declare their own PairedLinkage
            // typealias, and nothing in their member signatures pins it down uniquely (the
            // members that DO reference the paired type, e.g. InboundDatagramLinkage's own
            // deliver* methods don't mention it at all — only sibling types like
            // OutboundDatagramLinkage's attachUpper* methods reference it by name), so it's
            // not inferable. Add explicit typealiases; pairing follows the Datagram<->Datagram/
            // Stream<->Stream naming convention consistently used throughout this hierarchy.
            for (name, paired) in [
                ("InboundDatagramLinkage", "OutboundDatagramLinkage"),
                ("InboundStreamLinkage", "OutboundStreamLinkage"),
                ("InboundDatagramFlowLinkage", "DatagramListenerLinkage"),
                ("InboundStreamFlowLinkage", "StreamListenerLinkage"),
                ("OutboundDatagramLinkage", "InboundDatagramLinkage"),
                ("OutboundStreamLinkage", "InboundStreamLinkage"),
                ("DatagramListenerLinkage", "InboundDatagramFlowLinkage"),
                ("StreamListenerLinkage", "InboundStreamFlowLinkage"),
            ] {
                if let r = c.range(of: "public struct \(name): "), let braceEnd = c.range(of: " {", range: r.upperBound..<c.endIndex) {
                    c.insert(contentsOf: "\n    public typealias PairedLinkage = \(paired)", at: braceEnd.upperBound)
                }
            }
            // Configuration/Connection1-5/Listener1-6's second generic parameter `B` is a real
            // parameter pack, not a plain type — confirmed via `swift-demangle -expand` on their
            // ABI symbols (e.g. Connection1.init(to:using:) demangles to
            // "Configuration<A, Pack{repeat B}>", and the == operator to
            // "(Connection1<A, Pack{repeat B}>, Connection1<A, Pack{repeat B}>) -> Bool"). The
            // generator emitted the declaration as plain `<A, B>` and every use of "repeat B"
            // without the required "each" binding — hence "pack expansion 'B' must contain at
            // least one pack reference". Also erased every *bound* two-argument use site's
            // second slot to a bare `Any` (e.g. "Connection1<A, Any>", "Connection1<TLV, Any>")
            // since a pack argument list can't collapse to one placeholder name the same way a
            // plain generic can.
            for name in ["Configuration", "Connection1", "Connection2", "Connection3", "Connection4", "Connection5", "Listener1", "Listener2", "Listener3", "Listener4", "Listener5", "Listener6", "Listener7", "SendProgress"] {
                c = c.replacingOccurrences(of: "\(name)<A, B>", with: "\(name)<A, each B>")
                // Bound two-argument use sites: "<X, Any>" -> "<X, repeat each B>" for any first
                // argument (the class's own `A`, or a concrete type substituted for it, e.g.
                // "Connection1<TLV, Any>" inside a `where A == TLV` method).
                if let regex = try? NSRegularExpression(pattern: "\(name)<([^,<>]+), Any>", options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "\(name)<$1, repeat each B>")
                }
            }
            c = c.replacingOccurrences(of: "repeat B)", with: "repeat each B)")
            c = c.replacingOccurrences(of: "repeat B,", with: "repeat each B,")
            // NWParametersBuilder<A, B>'s `B` is also a pack (its own init(auto:)/init(_:) use
            // "repeat B", fixed by the two global replacements above). Its declaration and its
            // own two static `parameters(...)` factory methods (which return
            // "NWParametersBuilder<A, Any>" from *inside* NWParametersBuilder's own body, where
            // `B` is in scope) need "<A, each B>"/"<A, repeat each B>" respectively — but the 26
            // other "NWParametersBuilder<A, Any>" occurrences are all *external* call sites
            // (e.g. inside Connection6<A>/Connection7<A>/NWListener<A>) that each declare their
            // own local pack under a different name, always "A1" per a sibling
            // "() -> (A, repeat A1)" init in the very same type — confirmed by checking every
            // occurrence's surrounding declaration. Fix the struct's own declaration and its
            // two internal call sites first (unique strings), then treat every remaining
            // occurrence as an external call site using "A1".
            c = c.replacingOccurrences(of: "NWParametersBuilder<A, B>", with: "NWParametersBuilder<A, each B>")
            c = c.replacingOccurrences(
                of: "public static func parameters(initialParameters: NWParameters, _: () -> (A, repeat each B)) -> NWParametersBuilder<A, Any> { fatalError() }",
                with: "public static func parameters(initialParameters: NWParameters, _: () -> (A, repeat each B)) -> NWParametersBuilder<A, repeat each B> { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func parameters(_ arg1: () -> (A, repeat each B)) -> NWParametersBuilder<A, Any> { fatalError() }",
                with: "public static func parameters(_ arg1: () -> (A, repeat each B)) -> NWParametersBuilder<A, repeat each B> { fatalError() }")
            // Of the remaining call sites, only lines that also declare a local `<A1>` pack (a
            // sibling "() -> (A, repeat A1)" init in the same type) can use "repeat A1"; the
            // rest (NetworkListener<A>, withNetworkConnection<A>, NetworkConnection<A>
            // extensions — none of which declare any pack at all) collapse the argument to a
            // plain "NWParametersBuilder<A>", matching the already-valid empty-pack usage seen
            // elsewhere (e.g. "Configuration<A>").
            // A pre-existing bug (present in the raw generator output before any of this file's
            // Network fixes): these `init<A1>(..., using: () -> (A, repeat A1)) where A1: ...`
            // overloads already used "repeat A1" without ever binding "<A1>" as "<each A1>" —
            // the per-signature pack-detection pass in Model.swift didn't catch it because A1
            // isn't one of the placeholders ["A"..."G"] it scans for. Fix both the generic
            // parameter list and the repeat-expression on any line matching this pattern before
            // deciding whether a given NWParametersBuilder<A, Any> call site can reuse "A1".
            let networkParamsBuilderLines = c.components(separatedBy: "\n").map { line -> String in
                var fixedLine = line
                if fixedLine.contains("<A1>") && fixedLine.contains("repeat A1") {
                    fixedLine = fixedLine.replacingOccurrences(of: "<A1>", with: "<each A1>")
                    fixedLine = fixedLine.replacingOccurrences(of: "repeat A1", with: "repeat each A1")
                    // The `where A1: Protocol` constraint also references the pack itself and
                    // needs the same "repeat each" expansion keyword as any other pack
                    // reference — "where A1: X" is invalid once A1 is a pack, it must read
                    // "where repeat each A1: X".
                    fixedLine = fixedLine.replacingOccurrences(of: "where A1: ", with: "where repeat each A1: ")
                }
                guard fixedLine.contains("NWParametersBuilder<A, Any>") else { return fixedLine }
                if fixedLine.contains("<each A1>") {
                    return fixedLine.replacingOccurrences(of: "NWParametersBuilder<A, Any>", with: "NWParametersBuilder<A, repeat each A1>")
                }
                return fixedLine.replacingOccurrences(of: "NWParametersBuilder<A, Any>", with: "NWParametersBuilder<A>")
            }
            c = networkParamsBuilderLines.joined(separator: "\n")
            // After the NWParametersBuilder<A, Any> → NWParametersBuilder<A> collapse above,
            // lines like `init<A1>(to:, using: NWParametersBuilder<A>) where A1: NetworkProtocolOptions`
            // now have an orphaned `<A1>` generic param that never appears in the parameter
            // types — only in the (now-stale) where clause.  The compiler flags these as
            // [#NoUsage].  Strip the param and where clause entirely.
            c = c.components(separatedBy: "\n").map { line -> String in
                guard line.contains("<A1>") && line.contains("NWParametersBuilder") &&
                      !line.contains("repeat") && line.contains("where A1:") else { return line }
                var l = line
                l = l.replacingOccurrences(of: "<A1>", with: "")
                // Strip trailing " where A1: SomeProtocol" or " where A1: P1,  A1: P2"
                if let whereRange = l.range(of: " where A1:") {
                    l = String(l[..<whereRange.lowerBound]) + " { fatalError() }"
                    // Remove duplicate " { fatalError() } { fatalError() }" if present
                    l = l.replacingOccurrences(of: " { fatalError() } { fatalError() }", with: " { fatalError() }")
                    // Same for throws variants
                    l = l.replacingOccurrences(of: " throws { fatalError() } { fatalError() }", with: " throws { fatalError() }")
                }
                return l
            }.joined(separator: "\n")
            // Same pre-existing "repeat X without each" bug as above, on the `GenericA,
            // GenericB` placeholder pair Model.swift's generic-rename pass produces for
            // originally-anonymous type parameters, plus ProtocolStackBuilder.buildBlock where
            // the pack name itself was erased to a bare "Any" (confirmed via `swift-demangle
            // -expand`: real signature is "buildBlock<A, each B>(A, repeat each B) -> (A, repeat
            // each B)").
            c = c.replacingOccurrences(
                of: "public final func prependProtocols<GenericA, GenericB>(_ arg1: () -> (GenericA, repeat GenericB)) -> Connection7<GenericA> where GenericA: OneToOneProtocol,  GenericB: NetworkProtocolOptions { fatalError() }",
                with: "public final func prependProtocols<GenericA, each GenericB>(_ arg1: () -> (GenericA, repeat each GenericB)) -> Connection7<GenericA> where GenericA: OneToOneProtocol, repeat each GenericB: NetworkProtocolOptions { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func template<GenericA, GenericB>(_ arg1: @escaping () -> (GenericA, repeat GenericB)) -> () -> NWParametersBuilder<GenericA, Any> where GenericA: NetworkProtocolOptions,  GenericB: NetworkProtocolOptions { fatalError() }",
                with: "public static func template<GenericA, each GenericB>(_ arg1: @escaping () -> (GenericA, repeat each GenericB)) -> () -> NWParametersBuilder<GenericA, repeat each GenericB> where GenericA: NetworkProtocolOptions, repeat each GenericB: NetworkProtocolOptions { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func buildBlock(_ arg1: Any, _ arg2: repeat Any) -> (Any, repeat Any) { fatalError() }",
                with: "public static func buildBlock<GenericA, each GenericB>(_ arg1: GenericA, _ arg2: repeat each GenericB) -> (GenericA, repeat each GenericB) { fatalError() }")
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
            // `@escaping @isolated(any) @Sendable` on a closure parameter is rejected by
            // Swift 6 with "'@escaping' only applies to function types" — the `@isolated(any)`
            // attribute makes the closure type non-function from the compiler's perspective in
            // this position. Strip `@isolated(any)` globally from Network (our stubs don't need
            // isolation semantics, and the ABI shape is preserved without it).
            c = c.replacingOccurrences(of: "@escaping @isolated(any) @Sendable", with: "@escaping @Sendable")
            c = c.replacingOccurrences(of: "@isolated(any) @Sendable", with: "@Sendable")
            // nw_storage_* are free C-wrapper functions. Their closure parameters were
            // emitted with two problems:
            // 1. Double `@escaping @escaping` (generator adds @escaping, C demangle adds another)
            // 2. `@convention(block) (...)` — some params (OS_nw_array, DispatchData, etc.) are
            //    not ObjC-representable so they can't be block params.
            // Fix: strip @escaping @convention(block) broadly from any @escaping @escaping pattern
            // so the closure becomes a plain Swift function type.
            if let regex = try? NSRegularExpression(
                pattern: #"@escaping @escaping @convention\(block\) "#,
                options: [])
            {
                c = regex.stringByReplacingMatches(
                    in: c,
                    range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "")
            }
            // Also strip standalone double @escaping (without @convention(block))
            c = c.replacingOccurrences(of: "@escaping @escaping ", with: "@escaping ")
            // NetworkBrowser.run<GenericA> takes an `async throws` closure — `@escaping` on
            // an `async` closure parameter is invalid in Swift 6 in this position.  Drop it.
            c = c.replacingOccurrences(
                of: "@escaping @Sendable ([Any]) async throws ->",
                with: "@Sendable ([Any]) async throws ->")
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
            // DatagramUpperHarness/StreamUpperHarness/UpperHarness<A> conform to the
            // Top(Datagram|Stream)Protocol/TopDatapathProtocol/TopProtocolHandler/
            // InboundDataHandler/UpperProtocolHandler hierarchy, but the generator only
            // discovered the members that are actually exported for each class — several
            // requirements (context/eventManager/reference on ProtocolInstance, the
            // ProtocolInstanceReference-taking overloads of handleConnectedEvent/
            // handleDisconnectedEvent/handleNetworkProtocolEvent/handleInboundDataAvailableEvent/
            // handleOutboundRoomAvailableEvent on UpperProtocolHandler/InboundDataHandler, plus
            // attachLowerProtocol and associatedtype LowerProtocol) have no ABI symbol of their
            // own on these specific classes (same root cause as elsewhere in this file: a
            // protocol requirement satisfied only via default behavior with nothing exported per
            // conforming type). Add the missing stub members, matching the exact signatures used
            // by every other working conformer of the same protocols in this file.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class DatagramUpperHarness: InboundDatagramHandler, TopDatagramProtocol {",
                with: """
                @_fixed_layout public class DatagramUpperHarness: InboundDatagramHandler, TopDatagramProtocol {
                    public typealias LowerProtocol = OutboundDatagramLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public final var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public final var reference: ProtocolInstanceReference { get { fatalError() } }
                    public final var lower: OutboundDatagramLinkage { get { fatalError() } set {} }
                    public func handleConnectedEvent() -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleDisconnectedEvent(error: NetworkError?) -> () {}
                    public func handleDisconnectedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: NetworkProtocolEvent) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleInboundDataAvailableEvent() -> () {}
                    public func handleInboundDataAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleOutboundRoomAvailableEvent() -> () {}
                    public func handleOutboundRoomAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func attachLowerDatagramProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class StreamUpperHarness: InboundStreamHandler, TopStreamProtocol {",
                with: """
                @_fixed_layout public class StreamUpperHarness: InboundStreamHandler, TopStreamProtocol {
                    public typealias LowerProtocol = OutboundStreamLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public final var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public final var reference: ProtocolInstanceReference { get { fatalError() } }
                    public final var lower: OutboundStreamLinkage { get { fatalError() } set {} }
                    public func handleConnectedEvent() -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleDisconnectedEvent(error: NetworkError?) -> () {}
                    public func handleDisconnectedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: NetworkProtocolEvent) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleInboundDataAvailableEvent() -> () {}
                    public func handleInboundDataAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleOutboundRoomAvailableEvent() -> () {}
                    public func handleOutboundRoomAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleInboundAbortedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleOutboundAbortedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func attachLowerStreamProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                """)
            // UpperHarness<A>'s lowerProtocol init parameter and `lower` property are both
            // typed `A.PairedLinkage` in the real ABI (`swift-demangle -expand` on the init
            // symbol resolves the parameter type to exactly that dependent member type) — the
            // generator's own generic-constraint inference (Model.swift's
            // placeholdersNeedingProtocolLinkage) now derives `A: UpperProtocolLinkage` and
            // renders the init param/`lower` property with the correct type directly, so this
            // anchor only needs to add the ProtocolInstanceReference-taking overloads and
            // LowerProtocol typealias that have no ABI symbol of their own on this class (same
            // root cause as DatagramUpperHarness/StreamUpperHarness above).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class UpperHarness<A: UpperProtocolLinkage>: InboundDataHandler, LoggableProtocol, ProtocolInstance, TopDatapathProtocol, TopProtocolHandler, UpperHarnessProtocol, UpperProtocolHandler {",
                with: """
                @_fixed_layout public class UpperHarness<A: UpperProtocolLinkage>: InboundDataHandler, LoggableProtocol, ProtocolInstance, TopDatapathProtocol, TopProtocolHandler, UpperHarnessProtocol, UpperProtocolHandler {
                    public typealias LowerProtocol = A.PairedLinkage
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleDisconnectedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleInboundDataAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleOutboundRoomAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                """)
            // ConnectionProtocol requires `associatedtype ApplicationProtocolType: NetworkProtocolOptions`,
            // but no concrete type in the generated output conforms to NetworkProtocolOptions (it's only
            // ever used as a generic constraint), and the classes' own generic param `A` is bound to types
            // (WebSocket, TLV, JSON<GenericA>, UDP, DTLS, ...) that don't conform either. Since there's no
            // real per-instance application-protocol-options value being modeled here (the ABI doesn't
            // surface one), synthesize a trivial always-absent conformer and alias every ConnectionProtocol
            // conformer's ApplicationProtocolType to it.
            c += """

            public struct _NoApplicationProtocolOptions: NetworkProtocolOptions {
                public typealias BelowProtocol = Never
                public typealias ProtocolStorage = DefaultProtocolStorage
                public typealias Metadata = _NoApplicationProtocolMetadata
                public var belowProtocol: Never { fatalError() }
                public func configure(parameters: OS_nw_parameters) -> () {}
                public func configureNestedStack(parameters: OS_nw_parameters) -> () {}
                public func reconfigureNestedStack(connection: OS_nw_connection) -> () {}
            }
            public struct _NoApplicationProtocolMetadata: NetworkMetadataProtocol {
                public static func fromContentContext(context: NWConnection.ContentContext?, isComplete: Swift.Bool) -> Self? { return nil }
                public func toContentContext() -> NWConnection.ContentContext { fatalError() }
            }

            """
            for decl in [
                "@_fixed_layout public class Connection1<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection2<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection3<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection4<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection5<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection6<A>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection7<A>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class NetworkChannel<A>: ConnectionProtocol, CustomDebugStringConvertible, Hashable, Identifiable {",
            ] {
                c = c.replacingOccurrences(
                    of: decl,
                    with: decl + "\n    public typealias ApplicationProtocolType = _NoApplicationProtocolOptions")
            }
            // NetworkJSONCoder/NetworkPropertyListCoder conform to NetworkCoder, whose
            // makeDecoder()/makeEncoder() requirements return associatedtypes constrained to
            // NetworkDecoder/NetworkEncoder. Foundation's JSONDecoder/JSONEncoder/
            // PropertyListDecoder/PropertyListEncoder satisfy those protocols' requirements
            // structurally but have no declared conformance in the generated output.
            c += """

            extension JSONDecoder: NetworkDecoder {}
            extension JSONEncoder: NetworkEncoder {}
            extension PropertyListDecoder: NetworkDecoder {}
            extension PropertyListEncoder: NetworkEncoder {}

            """
            // InboundFlowLinkage adds `associatedtype DataLinkage: OutboundDataLinkage` on top of
            // its parent InboundFlowLinkage's own PairedLinkage requirement; both concrete
            // conformers are missing the DataLinkage typealias (the generator only discovered
            // PairedLinkage's exported symbol, not DataLinkage's, since it has no separate
            // per-type ABI representation).
            c = c.replacingOccurrences(
                of: """
                public struct InboundDatagramFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = DatagramListenerLinkage
                """,
                with: """
                public struct InboundDatagramFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = DatagramListenerLinkage
                    public typealias DataLinkage = OutboundDatagramLinkage
                """)
            c = c.replacingOccurrences(
                of: """
                public struct InboundStreamFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = StreamListenerLinkage
                """,
                with: """
                public struct InboundStreamFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = StreamListenerLinkage
                    public typealias DataLinkage = OutboundStreamLinkage
                """)
            // Coder<A, B, C> conforms to NetworkProtocolOptions but is missing BelowProtocol and
            // ProtocolStorage typealiases (no per-type exported ABI symbol for either). Its own
            // `belowProtocol` property is already typed `any NetworkProtocolOptions`, so
            // BelowProtocol matches that; ProtocolStorage reuses the same DefaultProtocolStorage
            // stub used by every other NetworkProtocolOptions conformer.
            c = c.replacingOccurrences(
                of: "public struct Coder<A, B, C>: MessageProtocol, NetworkProtocolOptions, OneToOneProtocol {",
                with: """
                public struct Coder<A, B, C>: MessageProtocol, NetworkProtocolOptions, OneToOneProtocol {
                    public typealias BelowProtocol = any NetworkProtocolOptions
                    public typealias ProtocolStorage = DefaultProtocolStorage
                """)
            // MultiplexedDatagramFlow/MultiplexedStreamFlow<A> conform to MultiplexedFlow, which
            // declares `associatedtype ParentProtocol: ManyToManyProtocolHandler` inferred from
            // the `parent` init parameter and `parentProtocol` property (both typed `A`) — so `A`
            // itself must be constrained to ManyToManyProtocolHandler. Also missing `context`
            // (ProtocolInstance, no per-type ABI symbol) and `required` on the memberwise init
            // (a protocol initializer requirement can only be satisfied by a required init on a
            // non-final class).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexedDatagramFlow<A>: AutomaticUpperDatagramProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {\n    public init(parent: A, inbound: Swift.Bool) { fatalError() }",
                with: """
                @_fixed_layout public class MultiplexedDatagramFlow<A: ManyToManyProtocolHandler>: AutomaticUpperDatagramProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public required init(parent: A, inbound: Swift.Bool) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexedStreamFlow<A>: AutomaticUpperStreamProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {\n    public init(parent: A, inbound: Swift.Bool) { fatalError() }",
                with: """
                @_fixed_layout public class MultiplexedStreamFlow<A: ManyToManyProtocolHandler>: AutomaticUpperStreamProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public required init(parent: A, inbound: Swift.Bool) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                """)
            // MultiplexingDatagramPath<A> conforms to MultiplexingPath/UpperProtocolHandler:
            // same ParentProtocol-inference issue on `A` as above, plus missing `context`,
            // `LowerProtocol` typealias, and the UpperProtocolHandler handle*/attachLowerProtocol
            // requirements (only the Datagram-specific attachLowerDatagramProtocol overload had
            // its own exported symbol).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexingDatagramPath<A>: AutomaticLowerDatagramProcessing, InboundDataHandler, InboundDatagramHandler, MultiplexingDatapathPath, MultiplexingPath, ProtocolInstance, ProtocolInstanceContainer, UpperProtocolHandler {\n    public init(parent: A) { fatalError() }",
                with: """
                @_fixed_layout public class MultiplexingDatagramPath<A: ManyToManyProtocolHandler>: AutomaticLowerDatagramProcessing, InboundDataHandler, InboundDatagramHandler, MultiplexingDatapathPath, MultiplexingPath, ProtocolInstance, ProtocolInstanceContainer, UpperProtocolHandler {
                    public typealias LowerProtocol = OutboundDatagramLinkage
                    public required init(parent: A) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleNetworkProtocolEvent(_: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleDisconnectedEvent(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                """)
            // NewFlowHarness<A, B> conforms to UpperProtocolHandler; its `listenerProtocol` init
            // parameter is typed `A.PairedLinkage` in the real ABI (confirmed via
            // `swift-demangle -expand` on the init symbol, same dependent-member pattern as the
            // UpperHarness<A> fix in Network fix 13). The generator's own generic-constraint
            // inference (Model.swift's placeholdersNeedingProtocolLinkage) now derives
            // `A: UpperProtocolLinkage` and renders the init param with the correct type
            // directly, so this anchor only needs to supply the missing LowerProtocol typealias
            // (no ABI symbol of its own on this class — same root cause as UpperHarness<A>
            // above).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class NewFlowHarness<A: UpperProtocolLinkage, B>: InboundFlowHandler, LoggableProtocol, ProtocolInstance, UpperProtocolHandler {",
                with: """
                @_fixed_layout public class NewFlowHarness<A: UpperProtocolLinkage, B>: InboundFlowHandler, LoggableProtocol, ProtocolInstance, UpperProtocolHandler {
                    public typealias LowerProtocol = A.PairedLinkage
                """)
            // QUICDatagramFlow/QUICPath are internal SPI helper classes (no public .swiftinterface
            // entry) referenced only via QUICConnection's multiplexedSecondaryFlows/
            // multiplexingPaths dictionaries; the generator captured only their exported members,
            // not their conformances to MultiplexedFlow/MultiplexingPath (needed for
            // QUICConnection's own HeterogeneousManyToManyProtocolHandler/ManyToManyProtocolHandler
            // conformance to be able to infer SecondaryFlow/Path). Added the missing conformances
            // and stub members, matching the shape of every other MultiplexedFlow/MultiplexingPath
            // conformer already fixed elsewhere in this file.
            // Header-only matches (not the whole class body) since member declaration order
            // inside these classes isn't guaranteed stable across generator runs.
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class QUICDatagramFlow {",
                with: """
                @_fixed_layout final public class QUICDatagramFlow: MultiplexedDatapathFlow {
                    public typealias UpperProtocol = InboundDatagramLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public var log: NetworkLoggerState { get { fatalError() } set {} }
                    public final var parentProtocol: QUICConnection { get { fatalError() } set {} }
                    public final var identifier: MultiplexedFlowIdentifier { get { fatalError() } }
                    public final var upper: InboundDatagramLinkage { get { fatalError() } set {} }
                    public var upperReceiveQueue: FrameArray { get { fatalError() } set {} }
                    public var upperSendQueue: FrameArray { get { fatalError() } set {} }
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class QUICPath: Equatable {",
                with: """
                @_fixed_layout final public class QUICPath: Equatable, MultiplexingDatapathPath {
                    public typealias LowerProtocol = OutboundDatagramLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public final var identifier: Swift.Int { get { fatalError() } }
                    public final var lower: OutboundDatagramLinkage { get { fatalError() } set {} }
                    public final var parentProtocol: QUICConnection { get { fatalError() } }
                    public final var pathIsPrimary: Swift.Bool { get { fatalError() } set {} }
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleNetworkProtocolEvent(_: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleDisconnectedEvent(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public required init(parent: QUICConnection) { fatalError() }
                """)
            // QUICConnection conforms to HeterogeneousManyToManyProtocolHandler/
            // ManyToManyProtocolHandler/StreamListenerHandler/HeterogeneousListenerHandler.
            // Its Flow/SecondaryFlow/Path/UpperProtocol/SecondaryUpperProtocol associatedtypes
            // are inferable now that QUICStreamInstance/QUICDatagramFlow/QUICPath conform to the
            // right protocols, but still need explicit typealiases (the properties alone leave
            // ambiguity between candidate inferences), plus the ListenerHandler/
            // StreamListenerHandler/ManyToManyProtocolHandler requirements that have no per-type
            // exported ABI symbol (they're satisfied only via default/inherited behavior on the
            // real type).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class QUICConnection: HeterogeneousListenerHandler, HeterogeneousManyToManyProtocolHandler, ListenerHandler, LoggableProtocol, ManyToManyApplicationDatagramProtocol, ManyToManyApplicationStreamProtocol, ManyToManyDatapathProtocol, ManyToManyOutboundDatagramProtocol, ManyToManyProtocolHandler, ProtocolInstance, ProtocolInstanceContainer, StreamListenerHandler, TimerSchedulable {",
                with: """
                @_fixed_layout public class QUICConnection: HeterogeneousListenerHandler, HeterogeneousManyToManyProtocolHandler, ListenerHandler, LoggableProtocol, ManyToManyApplicationDatagramProtocol, ManyToManyApplicationStreamProtocol, ManyToManyDatapathProtocol, ManyToManyOutboundDatagramProtocol, ManyToManyProtocolHandler, ProtocolInstance, ProtocolInstanceContainer, StreamListenerHandler, TimerSchedulable {
                    public typealias UpperProtocol = InboundStreamFlowLinkage
                    public typealias SecondaryUpperProtocol = InboundDatagramFlowLinkage
                    public typealias Flow = QUICStreamInstance
                    public typealias SecondaryFlow = QUICDatagramFlow
                    public typealias Path = QUICPath
                    public func attachUpperProtocolToExistingFlow<GenericA>(_: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> GenericA where GenericA: LowerProtocolLinkage { fatalError() }
                    public func attachUpperProtocolToNewFlow<GenericA>(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> GenericA where GenericA: LowerProtocolLinkage { fatalError() }
                    public func handleDisconnectedEvent(path: Swift.Int, error: NetworkError?) -> () {}
                    public func performInitialSetupIfNeeded(remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func handleNetworkProtocolEvent(path: Swift.Int, event: NetworkProtocolEvent) -> HandleNetworkEventResult { fatalError() }
                    public func teardownIfPossible() -> () {}
                    public func handleConnectedEvent(path: Swift.Int) -> () {}
                    public func attachLowerProtocolForNewPath(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func validate(inbound: ProtocolInstanceReference, _: Swift.String) throws(ProtocolInstanceError) -> () {}
                    public func attachNewStreamFlowProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> StreamListenerLinkage { fatalError() }
                    public func attachUpperStreamProtocolToExistingFlow(_: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> OutboundStreamLinkage { fatalError() }
                    public func attachUpperStreamProtocolToNewFlow(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> OutboundStreamLinkage { fatalError() }
                """)
            // QUICStreamInstance conforms to EarlyDataStreamFlow/UnidirectionalAbortingStreamFlow,
            // which pull in MultiplexedFlow/LoggableProtocol/ProtocolInstance/
            // OutboundStreamEarlyDataHandler requirements that have no per-type exported ABI
            // symbol on this specific class.
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class QUICStreamInstance: EarlyDataStreamFlow, OutboundStreamEarlyDataHandler, OutboundStreamUnidirectionalAbortHandler, UnidirectionalAbortingStreamFlow {\n    public init(parent: QUICConnection, inbound: Swift.Bool) { fatalError() }",
                with: """
                @_fixed_layout final public class QUICStreamInstance: EarlyDataStreamFlow, OutboundStreamEarlyDataHandler, OutboundStreamUnidirectionalAbortHandler, UnidirectionalAbortingStreamFlow {
                    public typealias UpperProtocol = InboundStreamLinkage
                    public init(parent: QUICConnection, inbound: Swift.Bool) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                    public var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public var log: NetworkLoggerState { get { fatalError() } set {} }
                    public final var parentProtocol: QUICConnection { get { fatalError() } set {} }
                    public final var identifier: MultiplexedFlowIdentifier { get { fatalError() } }
                    public final var upper: InboundStreamLinkage { get { fatalError() } set {} }
                    public var upperReceiveQueue: FrameArray { get { fatalError() } set {} }
                    public var upperSendQueue: FrameArray { get { fatalError() } set {} }
                    public func sendEarlyStreamData(_: ProtocolInstanceReference, streamData: __owned FrameArray) throws(NetworkError) -> () {}
                    public func abortOutbound(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func abortInbound(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                """)
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

        // A closure-typed parameter whose type is itself a function returning a function
        // (e.g. `(A) throws -> B` returned from another closure, as in resolver-wrapping
        // functions like CoreAIRuntime.wrapCoreAIResolver/wrapCoreAIOwnedResolver) gets
        // `@escaping` added twice by Parser.escapeClosures: once by the outer
        // isTopLevelParameter branch, and again by the inner enclosing-parens branch for
        // the same parameter, since the recursion has no way to know the prefix was
        // already applied one level up. Global, module-agnostic collapse — first spotted
        // and fixed only for Network's nw_storage_* C-wrapper functions (see the
        // Network-specific block above), generalized here since the same generator
        // recursion bug reproduces in other frameworks (e.g. CoreAIRuntime) too. Placed
        // last so it runs after any module-specific `@escaping @escaping @convention(block)`
        // handling that expects to see the un-collapsed pattern.
        c = c.replacingOccurrences(of: "@escaping @escaping ", with: "@escaping ")

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
        
        if ConfigManager.verbose {
            print("Total symbols in expected file: \(tbdSyms.count)")
            print("Total symbols in Dylib: \(dylibSyms.count)")
        }
        
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
        
        // The header+"Count:" lines below are regex-parsed by verify_public.py's run_compare()
        // as a fallback when "Generated N stubs" isn't present -- keep them unconditional even
        // though the per-symbol listing that follows is verbose-only.
        print("\n--- Missing Symbols (in TBD/Expected but not in Dylib) ---")
        print("Count: \(missing.count)")
        if ConfigManager.verbose {
            for s in missing.prefix(50) {
                print("  \(s)")
            }
            if missing.count > 50 {
                print("  ... and \(missing.count - 50) more")
            }
        }

        print("\n--- Extra Symbols (in Dylib but not in TBD/Expected) ---")
        print("Count: \(extra.count)")
        if ConfigManager.verbose {
            for s in extra.prefix(50) {
                print("  \(s)")
            }
            if extra.count > 50 {
                print("  ... and \(extra.count - 50) more")
            }
        }
        
        // Generate stubs.s
        func isDataSymbol(_ sym: String) -> Bool {
            if sym.hasPrefix("_OBJC_CLASS_$_") || sym.hasPrefix("_OBJC_METACLASS_$_") || sym.hasPrefix("_OBJC_IVAR_$_") {
                return true
            }
            let dataSuffixes = ["vpZ", "vp", "vpv", "vpvZ", "MF", "Mf", "WV", "VN", "MI", "Mi", "MP", "TL", "TM", "Mr", "MrZ"]
            for suf in dataSuffixes {
                if sym.hasSuffix(suf) {
                    return true
                }
            }
            return false
        }
        
        var textStubs = ""
        var dataStubs = ""
        for sym in missing {
            if isDataSymbol(sym) {
                dataStubs += ".globl \(sym)\n.no_dead_strip \(sym)\n.align 3\n\(sym):\n    .quad 0\n    .quad 0\n"
            } else {
                textStubs += ".globl \(sym)\n.no_dead_strip \(sym)\n.align 2\n\(sym):\n    ret\n"
            }
        }
        let stubsContent = ".text\n" + textStubs + "\n.data\n" + dataStubs
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
                        let symType = parts[1]
                        let symName = parts[2]
                        if symType != "U" && symType != "u" && symType != "b" {
                            symbols.insert(String(symName))
                        }
                    } else if parts.count == 2 {
                        let symType = parts[0]
                        let symName = parts[1]
                        if symType != "U" && symType != "u" && symType != "b" {
                            symbols.insert(String(symName))
                        }
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
        
        if ConfigManager.verbose { fputs("Self-alignment: found \(missing.count) missing symbols to stub.\n", stderr) }
        
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
        var originalPath: [String] = []
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
                let isNonCopyable = uniqueConformances.contains("~Copyable") || uniqueConformances.contains("any ~Copyable")
                if kindKeyword == "struct" || kindKeyword == "enum" {
                    if !isNonCopyable {
                        uniqueConformances.insert("Codable")
                        uniqueConformances.insert("Hashable")
                    }
                    uniqueConformances.insert("Sendable")
                }
                // Codable already implies Decodable + Encodable — declaring both is a
                // redundant-conformance error. This must run AFTER the unconditional
                // `insert("Codable")` above (not just the original, possibly-Codable-less
                // `conformances` check before it), since that insertion is exactly what can
                // introduce the redundancy in the first place.
                if uniqueConformances.contains("Codable") {
                    uniqueConformances.remove("Decodable")
                    uniqueConformances.remove("Encodable")
                }
                if kindKeyword == "class" {
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
            // Satisfy Stream's "associatedtype EventType" requirement for types injected with
            // a native Stream conformance (see the AppleIntelligenceReporting lazySource<A>
            // conformance hook in generateStubs) — the requirement's actual associated type is
            // never referenced elsewhere in these stub types, so "Any" is a valid witness.
            if conformances.contains("Stream") {
                s += "\(indent)    public typealias EventType = Any\n"
            }
            if conformances.contains(where: { $0.contains("ChatLanguageModelResponseStringStreamString") || $0.contains("CompletionLanguageModelResponseStringStreamString") }) {
                s += "\(indent)    public var text: Swift.String { get { fatalError() } }\n"
            }
            
            for child in nested.values.sorted(by: { $0.name < $1.name }) {
                s += child.generateSwift(depth: depth + 1)
            }
            s += "\(indent)}\n"
            return s
        }
    }

    static func pruneSelfDeclaredExtensionTypes(_ node: TypeNode, pathSoFar: String, selfDeclaredExtensionTypes: Set<String>) {
        node.nestedTypes = node.nestedTypes.filter { name, childNode in
            let fullPath = "\(pathSoFar).\(name)"
            let isSelfDeclared = selfDeclaredExtensionTypes.contains {
                fullPath == $0 || fullPath.hasPrefix($0 + ".")
            }
            if isSelfDeclared {
                return false
            }
            pruneSelfDeclaredExtensionTypes(childNode, pathSoFar: fullPath, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
            return true
        }
    }

    // Renders a real, enriched TypeNode (populated via the state-swapped re-parse in
    // generateStubs) for a dependency stub, instead of StubNode's empty-skeleton fallback.
    // Shared by generateStubs' main per-type emission loop and its same-module closure pass —
    // both need the identical circular-self-reference filter and Stream/EventType handling.
    // Emits ONLY the `@_originallyDefinedIn`-tagged extension blocks a TypeNode carries in
    // originallyDefinedInExtensions -- the one piece of extension-based enrichment genuinely
    // missing from renderEnrichedType's generateCode()-only render (see the comment at its call
    // site below). Deliberately self-contained rather than calling the full generateExtensions():
    // that function ALSO re-renders extensionMembers/constrainedExtensions, which for a protocol
    // would duplicate what generateProtocolDefaultExtension (below) already synthesizes from the
    // protocol's own requirement list, and carries a lot of unrelated machinery (retroactive-
    // conformance suffixes, stdlib placeholder renames, primary-associated-type scoping) this
    // narrow case has no need for -- the members a moved type's real ABI puts here are always
    // simple, already-fully-qualified signatures (see Parser.swift's originallyDefinedInExtensions
    // insert sites), never generic-placeholder-bearing ones. Recurses into nestedTypes so a moved
    // type nested several levels deep (e.g. RecursiveSchema.Options) is covered from a single
    // top-level call, matching generateCode()'s own self-recursing shape.
    static func renderOriginallyDefinedInExtensions(_ node: TypeNode, currentPath: String) -> String {
        var output = ""
        let escapedNodeName = node.escapeKeyword(node.name)
        let nodePath = currentPath.isEmpty ? escapedNodeName : "\(currentPath).\(escapedNodeName)"
        for origModule in node.originallyDefinedInExtensions.keys.sorted() {
            guard let membersMap = node.originallyDefinedInExtensions[origModule], !membersMap.isEmpty else { continue }
            let sortedMembers = membersMap.values.sorted { lhs, rhs in
                if case .initializer = lhs, case .initializer = rhs { return false }
                if case .initializer = lhs { return true }
                if case .initializer = rhs { return false }
                return false
            }
            var extBody = ""
            var emittedAny = false
            for member in sortedMembers {
                switch member {
                case .initializer(let sig):
                    // Used to unconditionally skip init(from:) here on the assumption that
                    // generateCode()'s own Codable-completeness fallback (Model.swift) already
                    // covers it -- but that fallback used to check only a struct/enum's own
                    // `members`, missing this real one living in originallyDefinedInExtensions,
                    // and synthesized a SECOND, wrongly-placed init(from:) directly in the type
                    // body instead (mangling under the moved-from module with no "extension in"
                    // marker, not matching the real ABI). Now that the fallback correctly checks
                    // every container (including this one) and skips synthesis when a real one is
                    // found here, this real member needs to actually be emitted.
                    if node.members.values.contains(where: { if case .initializer(let s) = $0 { return s == sig } else { return false } }) { continue }
                    extBody += "    public \(sig) { fatalError() }\n"
                    emittedAny = true
                case .method(let name, let sig, var isStatic):
                    // `sig` is already the full "name(params) -> ReturnType" text (see
                    // Parser.swift's `fixedSignature = escapedMemberName + signature(...)`) --
                    // do not re-prefix it with `name` again. An operator method's stored sig
                    // carries a literal trailing " infix"/" prefix"/" postfix" marker (mirroring
                    // Model.swift's own generateOneExtension handling of the same MemberKind) --
                    // strip it and force `static`, since Swift requires operator methods be static.
                    let cleanSig = sig.strippingOperatorFixityMarkers()
                    if cleanSig != sig { isStatic = true }
                    if node.members.values.contains(where: { if case .method(let n, let s, let st) = $0 { return (s == sig || s == cleanSig || n == name) && st == isStatic } else { return false } }) { continue }
                    extBody += "    public \(isStatic ? "static " : "")func \(cleanSig) { fatalError() }\n"
                    emittedAny = true
                case .property(let name, let type, let isReadOnly, let isStatic):
                    if node.members.values.contains(where: { if case .property(let n, _, _, let st) = $0 { return n == name && st == isStatic } else { return false } }) { continue }
                    let getter = "{ get { fatalError() }\(isReadOnly ? "" : " set { fatalError() }") }"
                    extBody += "    public \(isStatic ? "static " : "")var \(name): \(type) \(getter)\n"
                    emittedAny = true
                default:
                    break
                }
            }
            if emittedAny {
                output += "@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)\n"
                output += "@_originallyDefinedIn(module: \"\(origModule)\", macOS 10.15)\n"
                output += "extension \(nodePath) {\n"
                output += extBody
                output += "}\n"
            }
        }
        // A nested type literally named "Type" (or another Swift keyword) needs the SAME
        // backtick escaping inside every signature that references it qualified as
        // "...NodeName.Type" -- otherwise Swift parses the unescaped ".Type" suffix as the
        // metatype-of-NodeName expression instead of a reference to this nested type, which
        // silently type-checks wrong everywhere except where an exact-type match is required
        // (e.g. a static == operator's parameter list), where it surfaces as a hard compile
        // error ("member operator '==' must have at least one argument of type '...`Type`'").
        // Escaping only the extension's own header (nodePath) above isn't enough since member
        // signatures elsewhere in this same text can reference the identical qualified path.
        if escapedNodeName != node.name, let re = try? NSRegularExpression(pattern: "\\.\(NSRegularExpression.escapedPattern(for: node.name))\\b(?!`)") {
            let nsRange = NSRange(output.startIndex..<output.endIndex, in: output)
            output = re.stringByReplacingMatches(in: output, range: nsRange, withTemplate: ".`\(node.name)`")
        }
        for nested in node.nestedTypes.values {
            output += renderOriginallyDefinedInExtensions(nested, currentPath: nodePath)
        }
        return output
    }

    static func renderEnrichedType(_ realNode: TypeNode, mod: String, currentModule: String, parser: Parser, selfDeclaredExtensionTypes: Set<String> = []) -> String {
        if !selfDeclaredExtensionTypes.isEmpty {
            pruneSelfDeclaredExtensionTypes(realNode, pathSoFar: "\(mod).\(realNode.name)", selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
        }
        let savedDefaultModule = parser.defaultModule
        parser.defaultModule = mod
        // generateAll() (the real-target codegen path) always calls markGenericRecursive
        // before rendering, so a type's own real generic-application usages (from
        // discoveredGenerics, populated by precompute()) mark it isGeneric before generateCode()
        // ever runs. This dependency's members were parsed via the same processSymbols/
        // precompute() pipeline (generateStubs' state-swapped re-parse), so discoveredGenerics
        // already has the right entries — but nothing previously called markGenericRecursive
        // for a dependency's own types, so a real generic type like GenerativeStream<A> rendered
        // as if non-generic (no <A> in its header) despite its own real members using <A>.
        parser.markGenericRecursive(node: realNode)
        var code = realNode.generateCode(indent: "", parser: parser)
        // generateCode() only ever renders a type's own `members` (declared inline in its own
        // body) plus, for a protocol specifically, generateProtocolDefaultExtension (below)
        // synthesizes a trivial default-implementation extension straight from the protocol's
        // own requirement list. Neither path ever looks at originallyDefinedInExtensions, so a
        // type whose real ABI moved via @_originallyDefinedIn (e.g. PromptKit's RecursiveSchema.
        // Options.init(rawValue:)/rawValue, really exported under GenerativeFunctionsFoundation's
        // own mangled name) rendered with its base conformance list (RawRepresentable/SetAlgebra/
        // etc.) but none of the real members that satisfy it. Add just that one missing piece --
        // NOT the full generateExtensions() (which also re-renders extensionMembers/
        // constrainedExtensions and would duplicate generateProtocolDefaultExtension's synthesis
        // for protocols).
        let origDefExtCode = renderOriginallyDefinedInExtensions(realNode, currentPath: "")
        if !origDefExtCode.isEmpty {
            code += "\n" + origDefExtCode
        }
        parser.defaultModule = savedDefaultModule
        // simplifyType() (Parser.swift) strips a "defaultModule." prefix from EVERY type
        // reference — not just conformances — PERMANENTLY into this cached TypeNode's stored
        // member-signature strings, using whichever module identity was active the FIRST time
        // this type was parsed/enriched. When the same cached node is rendered again for a
        // DIFFERENT target build (Stage B/C's state-swapped re-parse is reused across multiple
        // target builds), a bare name from that original stripping can be flat-out wrong here —
        // e.g. "Prompt.Component.Value" (originally "PromptKit.Prompt...") rendered while
        // building TokenGenerationCore, where "Prompt" isn't visible unqualified. Conformances
        // are already re-qualified at TRUE render time (TypeNode.generateCode's inheritsList
        // construction, Model.swift) since that list is rebuilt fresh each call; member
        // signatures are cached as flat strings much earlier and can't cheaply get the same
        // treatment, so re-qualify bare foreign-module type names as a text-level pass here
        // instead — bounded to this one rendering path, not a Parser-wide behavior change.
        // Must run BEFORE the circular-module member filter below: a member whose stored
        // signature still has its module prefix stripped (e.g. bare "AnyGenerationGuides"
        // instead of "PromptKit.AnyGenerationGuides") is invisible to that filter's
        // dotted-qualifier check, so a genuinely circular reference would otherwise survive
        // unfiltered as a bare name, then get its qualifier reattached AFTER filtering already
        // ran and let it through uncaught.
        code = requalifyBareForeignTypeNames(code, mod: mod, parser: parser)
        // A member's real signature can genuinely reference the module we're building this
        // stub FOR (currentModule) -- e.g. TokenGeneration.Prompt.renderPromptModules(...)
        // returning [TokenGenerationCore.PromptModule] -- and this stub must compile
        // standalone, before currentModule exists. It can also reference any OTHER real target
        // currently on orchestrate.py's build call stack (SWIFT_INTERFACE_GEN_BUILDING_TARGETS,
        // set by orchestrate.py to its `building` set) -- e.g. while resolving TokenGenerationCore
        // -> PromptKit -> TokenGeneration (a stub), TokenGeneration's own real members can
        // reference TokenGenerationCore itself, which is equally circular (TokenGenerationCore
        // isn't built yet either, since we're still resolving ITS dependencies). Drop just the
        // offending single-line members (every member here renders self-contained on one line,
        // body included) rather than losing the whole type's enrichment.
        var circularModules = Set([currentModule])
        if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
            circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
        }
        let memberLinePrefixes = ["public func ", "public static func ", "public final func ",
                                   "public override func ", "public class func ", "public var ",
                                   "public final var ", "public static var ", "public override var ",
                                   "public let ", "public final let ", "public init", "public required init",
                                   "public convenience init", "public subscript",
                                   "public typealias ", "case ", "nonisolated public ",
                                   "func ", "static func ", "class func ", "mutating func ",
                                   "var ", "let ", "subscript", "init", "associatedtype ", "typealias "]
        let declLinePrefixes = ["public struct ", "public final class ", "public class ",
                                 "public enum ", "@_fixed_layout public class "]
        // TypeNode.init (Model.swift) permanently strips a conformance's module qualifier
        // whenever the protocol's dotted name is present in parser.discoveredProtocols --
        // that includes a protocol declared in a circularModules member, so the dotted-prefix
        // check above ("PromptKit.") never matches; the bare name (e.g.
        // "PromptComponentValueConvertible") is what actually appears in `code`. Recover the
        // owning module for every bare discoveredProtocols entry so a circular bare protocol
        // reference is filtered exactly like a still-qualified one.
        var bareProtocolOwningModule = [String: String]()
        for qualifiedProto in parser.discoveredProtocols {
            guard let dotIdx = qualifiedProto.range(of: ".", options: .backwards) else { continue }
            let owningModule = String(qualifiedProto[..<dotIdx.lowerBound])
            let bareName = String(qualifiedProto[dotIdx.upperBound...])
            // A protocol owned by `mod` itself (the dependency whose stub this is) is a
            // same-module reference, not circular -- e.g. GenerativeFunctionsFoundation's own
            // Tooling.Arguments: GenerableArguments, where GenerableArguments is also declared
            // in GenerativeFunctionsFoundation. Excluding it here mirrors the dotted-qualifier
            // check a few lines up, which already excludes `mod` the same way (`text.contains
            // ("\($0).")` only tests circularModules, and mod is deliberately not a member of
            // that set unless it's ALSO currentModule).
            if circularModules.contains(owningModule), owningModule != mod {
                bareProtocolOwningModule[bareName] = owningModule
            }
        }
        let lineReferencesCircularModule: (String) -> Bool = { text in
            // A dotted reference to `mod` ITSELF (e.g. "GenerativeFunctionsFoundation." while
            // rendering GenerativeFunctionsFoundation's own dependency stub) is never circular —
            // it's just this type's own home module, fully resolvable within the same file.
            // `mod` can still land in `circularModules` (added by orchestrate.py's stub-import-
            // cycle detection when `mod` participates in a cycle with some OTHER module), so it
            // must be excluded here explicitly rather than relying on circularModules' membership
            // alone.
            if circularModules.contains(where: { $0 != mod && text.contains("\($0).") }) { return true }
            for (bareName, owningModule) in bareProtocolOwningModule where owningModule != mod {
                if text.containsWord(bareName) { return true }
            }
            return false
        }
        code = code.split(separator: "\n", omittingEmptySubsequences: false).compactMap { line -> Substring? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard lineReferencesCircularModule(trimmed) else { return line }
            if memberLinePrefixes.contains(where: { trimmed.hasPrefix($0) }) {
                return nil
            }
            // A type's own declaration line (e.g. "public struct PromptTemplate: Codable,
            // PromptKit.ChatMessagePromptConvertible {") can conform to a protocol declared in
            // a circular module -- genuinely circular the same way a member signature can be
            // (this stub compiles standalone before that module exists), but dropping the whole
            // TYPE would lose all its other real enrichment. Strip just the offending
            // comma-separated conformance entries from the inheritance clause instead.
            if declLinePrefixes.contains(where: { trimmed.hasPrefix($0) }), trimmed.hasSuffix("{") {
                guard let colonIdx = line.firstIndex(of: ":") else { return line }
                let head = String(line[..<colonIdx])
                let bodyStart = line.index(after: colonIdx)
                let inheritancePart = String(line[bodyStart..<line.index(before: line.endIndex)])
                let entries = inheritancePart.splitByCommaRespectingBrackets().map { $0.trimmingCharacters(in: .whitespaces) }
                let kept = entries.filter { entry in !lineReferencesCircularModule(entry) }
                if kept.count == entries.count { return line }
                if kept.isEmpty {
                    return Substring(head + " {")
                }
                return Substring(head + ": " + kept.joined(separator: ", ") + " {")
            }
            return line
        }.joined(separator: "\n")
        // Mirrors StubNode.generateSwift's own handling: a type given a native Stream
        // conformance (the AppleIntelligenceReporting lazySource<A> hook, above) needs
        // Stream's "associatedtype EventType" requirement satisfied — generateCode() has no
        // knowledge of this synthetic conformance's associated-type requirement, since it's
        // injected after the type's own real members were already parsed. Any nested type
        // several levels deep can independently gain this conformance (each has its own
        // TypeNode.conformances set), so insert per matching declaration LINE (", Stream {"/
        // ", Stream," in the type's own inheritance clause), not just once for the top type.
        if code.contains(" Stream ") || code.contains(" Stream,") || code.contains(" Stream{") || code.contains(" Stream {") {
            let lines = code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            var result = [String]()
            for line in lines {
                result.append(line)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                let declaresStream = trimmed.range(of: #"\bStream\b"#, options: .regularExpression) != nil &&
                    (trimmed.contains(": ") || trimmed.contains(", ")) && trimmed.hasSuffix("{")
                if declaresStream {
                    let indent = String(line.prefix(while: { $0 == " " }))
                    result.append("\(indent)    public typealias EventType = Any")
                }
            }
            code = result.joined(separator: "\n")
        }
        // generateAll() (the real-target codegen path) always runs postProcess's
        // removePrivateObjCTypeReferences() before writing output — this path renders the same
        // TypeNode.generateCode() output but never went through postProcess, so a member
        // referencing a private/undeclared C typedef left qualified as "__C.snake_case" by
        // simplifyType (e.g. ModelManagerServices.AuditToken.init(__C.audit_token_t)) survives
        // into the stub and fails to compile ("cannot find type '__C' in scope" once __C isn't
        // otherwise visible in a standalone dependency-stub module).
        code = code.removePrivateObjCTypeReferences()
        if !selfDeclaredExtensionTypes.isEmpty {
            let stdlibTypes: Set<String> = [
                "String", "Int", "Double", "Float", "Bool", "UInt", "Int8", "Int16", "Int32", "Int64",
                "UInt8", "UInt16", "UInt32", "UInt64", "Data", "URL", "Error", "Decoder", "Encoder",
                "CodingKey", "Any", "Result", "Optional", "Array", "Dictionary", "Set"
            ]
            for extType in selfDeclaredExtensionTypes {
                let parts = extType.components(separatedBy: ".")
                if parts.count >= 2 {
                    let shortName = parts.suffix(2).joined(separator: ".")
                    let leafName = parts.last!
                    code = code.replacingOccurrences(of: extType, with: "Any")
                    code = code.replacingOccurrences(of: shortName, with: "Any")
                    if !stdlibTypes.contains(leafName) {
                        code = code.replaceWord(leafName, with: "Any")
                    }
                }
            }
        }
        // simplifyType()'s ambiguous-protocol disambiguation (Parser.swift, "any
        // ___SHIELDED_<module>___.Foo") is a TEMPORARY placeholder meant to survive just long
        // enough to bypass module-prefix stripping, then get restored to "any <module>.Foo" by
        // postProcess (main.swift's generateAll() path only) before being written out. This
        // stub-rendering path never went through postProcess, so an unrestored placeholder
        // ("___SHIELDED_ModelCatalog___") can leak straight into the compiled stub as an
        // unresolvable bare type name.
        code = code.replacingOccurrences(of: "___SHIELDED_\(mod)___", with: mod)
        if realNode.kind == "protocol" {
            let extCode = generateProtocolDefaultExtension(code: code, protocolName: realNode.name)
            if !extCode.isEmpty {
                code += "\n" + extCode
            }
        }
        return code
    }

    static func generateProtocolDefaultExtension(code: String, protocolName: String) -> String {
        let lines = code.components(separatedBy: "\n")
        var extMembers = [String]()
        var inProtocol = false
        var depth = 0
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("protocol \(protocolName)") || (trimmed.hasPrefix("public protocol ") && trimmed.contains(protocolName)) {
                inProtocol = true
            }
            if !inProtocol { continue }
            for ch in trimmed {
                if ch == "{" { depth += 1 }
                else if ch == "}" { depth -= 1 }
            }
            if depth == 1 && inProtocol {
                // Inside protocol body
                if trimmed.hasPrefix("static var ") || trimmed.hasPrefix("class var ") || trimmed.hasPrefix("var ") {
                    if let braceIdx = trimmed.firstIndex(of: "{") {
                        let head = String(trimmed[..<braceIdx]).trimmingCharacters(in: .whitespaces)
                        let isReadWrite = trimmed.contains("set")
                        let body = isReadWrite ? "{ get { fatalError() } set { fatalError() } }" : "{ get { fatalError() } }"
                        extMembers.append("    public \(head) \(body)")
                    }
                } else if trimmed.hasPrefix("static func ") || trimmed.hasPrefix("class func ") || trimmed.hasPrefix("func ") {
                    extMembers.append("    public \(trimmed) { fatalError() }")
                } else if trimmed.hasPrefix("static subscript") || trimmed.hasPrefix("subscript") {
                    if let braceIdx = trimmed.firstIndex(of: "{") {
                        let head = String(trimmed[..<braceIdx]).trimmingCharacters(in: .whitespaces)
                        let isReadWrite = trimmed.contains("set")
                        let body = isReadWrite ? "{ get { fatalError() } set { fatalError() } }" : "{ get { fatalError() } }"
                        extMembers.append("    public \(head) \(body)")
                    }
                }
            }
            if depth == 0 && inProtocol {
                inProtocol = false
            }
        }
        if extMembers.isEmpty { return "" }
        return "\nextension \(protocolName) {\n" + extMembers.joined(separator: "\n") + "\n}\n"
    }

    // Scans `code` for a bare (unqualified) capitalized identifier that isn't declared in `mod`
    // itself but IS a real top-level type in some OTHER known module, and qualifies it. Bounded
    // to top-level type names only (not nested paths) to keep false-positive risk low — a nested
    // path segment (e.g. the ".Component" in "Prompt.Component") is left alone since only the
    // leading segment can be an unqualified cross-module reference here.
    static func requalifyBareForeignTypeNames(_ code: String, mod: String, parser: Parser) -> String {
        var result = code
        guard let bareIdentRegex = try? NSRegularExpression(pattern: "(?<![.A-Za-z0-9_])([A-Z][A-Za-z0-9_]*)\\b", options: []) else { return result }
        let ownModuleTypeNames: Set<String> = parser.modules[mod].map { Set($0.nestedTypes.keys) } ?? []
        // Well-known Swift stdlib protocol/attribute names are never legitimately "owned" by
        // some other private-framework module even if that module's own conformance-injection
        // logic (applyTypeFixups etc.) happens to record them against a nestedTypes entry --
        // requalifying "Sendable" would corrupt "@Sendable" attribute syntax into
        // "@Swift.Sendable" (an unknown attribute), and similarly for the others below.
        let stdlibNames: Set<String> = ["Sendable", "Equatable", "Hashable", "Codable", "Decodable",
            "Encodable", "Identifiable", "BitwiseCopyable", "Copyable", "Escapable", "Error",
            "CustomStringConvertible", "CustomDebugStringConvertible", "Comparable", "Sequence",
            "Collection", "Strideable", "Numeric", "SignedNumeric", "AdditiveArithmetic",
            "FloatingPoint", "BinaryFloatingPoint", "LosslessStringConvertible", "CaseIterable",
            "RawRepresentable", "CodingKey", "LocalizedError", "Actor", "AnyObject", "Optional",
            "Array", "Dictionary", "Set", "Result", "Never", "Void",
            "String", "Int", "Double", "Float", "Bool", "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
            "Int8", "Int16", "Int32", "Int64", "Character", "StaticString", "Substring", "Decoder", "Encoder",
            "UUID", "Data", "Date", "URL", "URLRequest", "Locale", "TimeZone", "Calendar", "CharacterSet",
            "Notification", "IndexPath", "IndexSet", "Measurement", "Unit", "Dimension", "Duration",
            // Handled by its own dedicated fallback (the same-module closure pass's
            // newlyFoundOpaqueStruct case, main.swift) -- XPC has no real swiftinterface/tbd in
            // this SDK, so parser.modules["XPC"] can still hold a nestedTypes entry for
            // "XPCCodableObject" purely from a findOrCreateType() call site treating a
            // referenced (not independently declared) path as if it were one; requalifying
            // against that phantom entry produces "XPC.XPCCodableObject", which doesn't exist.
            "XPCCodableObject"]
        // A name this SAME stub file declares (nested at any depth, e.g. "public enum Streams {"
        // inside "public enum BiomeStreams.Streams" from an earlier bug) must never be
        // requalified — replaceWord below has no notion of declaration vs. reference sites and
        // would corrupt "enum Streams {" into "enum BiomeStreams.Streams {" (invalid syntax).
        var selfDeclaredNames = Set<String>()
        // "associatedtype Foo: Bound" is also a DECLARATION, not a reference -- e.g.
        // "associatedtype ModelConfiguration: Hashable" must never become
        // "associatedtype TokenGenerationCore.ModelConfiguration" (invalid: an associated
        // type's own name can never be dotted), even if some OTHER real module happens to
        // separately declare a same-named top-level type.
        if let declRegex = try? NSRegularExpression(pattern: "\\b(?:struct|enum|class|protocol|associatedtype|case) `?([A-Za-z_][A-Za-z0-9_]*)`?", options: []) {
            let declNsRange = NSRange(result.startIndex..<result.endIndex, in: result)
            for m in declRegex.matches(in: result, options: [], range: declNsRange) {
                if let r = Range(m.range(at: 1), in: result) {
                    selfDeclaredNames.insert(String(result[r]))
                }
            }
        }
        var seen = Set<String>()
        let nsRange = NSRange(result.startIndex..<result.endIndex, in: result)
        for m in bareIdentRegex.matches(in: result, options: [], range: nsRange) {
            guard let range = Range(m.range(at: 1), in: result) else { continue }
            let name = String(result[range])
            guard !seen.contains(name), name != mod, name != "Swift", name != "Foundation",
                  !ownModuleTypeNames.contains(name), !selfDeclaredNames.contains(name),
                  !stdlibNames.contains(name) else { continue }
            seen.insert(name)
            // "__C" is the synthetic ObjC-bridge pseudo-module (registerObjcClasses), never a
            // real importable module -- a bare ObjC-bridged name is deliberately left
            // unqualified elsewhere (the same-module closure pass emits a local placeholder
            // class for it), so requalifying against "__C" would break that existing handling.
            guard let owningModule = parser.modules.first(where: { $0.key != mod && $0.key != "__C" && $0.value.nestedTypes[name] != nil })?.key else { continue }
            result = result.replaceWord(name, with: "\(owningModule).\(name)", allowPrecededByDot: false)
        }
        // A reference can also be WRONGLY qualified rather than bare -- e.g. a demangled ABI
        // symbol names a return type "PromptKit.Prompt.Component.Value" because the SYMBOL
        // itself belongs to PromptKit (GenerativeModelsFoundation.SelfAttention.toValue()'s own
        // mangled name embeds that qualifier), even though "Prompt" is actually declared in
        // TokenGeneration (which PromptKit imports/depends on) -- simplifyType's defaultModule
        // stripping never touches this since the qualifier isn't `mod` here, so it survives
        // verbatim into the stub as an unresolvable cross-module reference. Detect a qualifier
        // that isn't a real module owning that type name, and correct it to whichever module
        // actually declares it.
        if let wrongQualifierRegex = try? NSRegularExpression(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\.([A-Z][A-Za-z0-9_]*)\\b", options: []) {
            var corrections = [(wrong: String, right: String)]()
            let wqNsRange = NSRange(result.startIndex..<result.endIndex, in: result)
            for m in wrongQualifierRegex.matches(in: result, options: [], range: wqNsRange) {
                guard let qualRange = Range(m.range(at: 1), in: result),
                      let nameRange = Range(m.range(at: 2), in: result) else { continue }
                let qualifier = String(result[qualRange])
                let name = String(result[nameRange])
                guard qualifier != mod, qualifier != "Swift", qualifier != "Foundation", qualifier != "__C",
                      !stdlibNames.contains(name) else { continue }
                // Only correct a qualifier that's a KNOWN module (real target/dependency) but
                // doesn't itself declare this name -- an unrecognized qualifier could be a
                // legitimate nested-type path segment (e.g. "Outer.Inner"), not a module prefix.
                guard parser.modules[qualifier] != nil, parser.modules[qualifier]?.nestedTypes[name] == nil else { continue }
                guard let rightModule = parser.modules.first(where: { $0.key != qualifier && $0.key != mod && $0.key != "__C" && $0.value.nestedTypes[name] != nil })?.key else { continue }
                corrections.append((wrong: "\(qualifier).\(name)", right: "\(rightModule).\(name)"))
            }
            for (wrong, right) in corrections where wrong != right {
                result = result.replacingOccurrences(of: wrong, with: right)
            }
        }
        return result
    }

    static func generateStubs(outputCode: String, currentModule: String, outputDir: String, parser: Parser) {
        try? outputCode.write(toFile: "/tmp/finalCode_\(currentModule)_first_run.swift", atomically: true, encoding: .utf8)
        var externalTypes = [String: [(typeName: String, isProtocol: Bool, genericCount: Int)]]()

        // Primary-associated-type protocols (e.g. "protocol Source<Stream>") mangle each
        // constrained-existential use site with the associated type's REAL name (e.g. "any
        // Source<Self.Stream == A>" mangles distinguishing "Stream", not just its position) —
        // stubbing the protocol with a generic "associatedtype A" placeholder produces a
        // same-position but differently-named associated type, which mangles differently and
        // never matches the real ABI symbol. Parser.swift's simplifyType recovers the real name
        // from "Self.<Name> == A>" while it's still present (before erasure/marker-replacement)
        // and records it in parser.primaryAssociatedTypeNames, keyed by the protocol's short
        // name — read it here so the stub declares "associatedtype <Name>" under the same
        // placeholder position instead of a bare "A".
        let primaryAssociatedTypeNames = parser.primaryAssociatedTypeNames
        var selfDeclaredExtensionTypes = Set<String>(parser.selfDeclaredExternalExtensionPaths)
        let outputLines = outputCode.components(separatedBy: .newlines)
        var activeExtPrefix: String? = nil
        var currentDepth = 0

        for line in outputLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if currentDepth == 0 && trimmed.hasPrefix("extension ") {
                let afterExt = trimmed.dropFirst("extension ".count).trimmingCharacters(in: .whitespaces)
                let header = afterExt.components(separatedBy: CharacterSet(charactersIn: " :{")).first ?? ""
                if header.contains(".") {
                    let mod = header.components(separatedBy: ".")[0]
                    if mod != currentModule {
                        activeExtPrefix = header
                    }
                }
            }
            
            let opens = line.filter { $0 == "{" }.count
            let closes = line.filter { $0 == "}" }.count
            currentDepth += (opens - closes)
            
            if let extPrefix = activeExtPrefix, currentDepth > 0 {
                if trimmed.hasPrefix("public enum ") || trimmed.hasPrefix("public struct ") ||
                   trimmed.hasPrefix("public class ") || trimmed.hasPrefix("public typealias ") ||
                   trimmed.hasPrefix("enum ") || trimmed.hasPrefix("struct ") ||
                   trimmed.hasPrefix("class ") || trimmed.hasPrefix("typealias ") {
                    let words = trimmed.components(separatedBy: CharacterSet.whitespaces.union(CharacterSet(charactersIn: ":<({")))
                    let keywords: Set<String> = ["public", "private", "fileprivate", "internal", "enum", "struct", "class", "typealias", "@unchecked", "Sendable", "@objc", "final", "indirect", ""]
                    let nonKeyWords = words.filter { !keywords.contains($0) }
                    if let nestedName = nonKeyWords.first {
                        let fullPath = "\(extPrefix).\(nestedName)"
                        selfDeclaredExtensionTypes.insert(fullPath)
                    }
                }
            }
            
            if currentDepth == 0 {
                activeExtPrefix = nil
            }
        }

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

        // A nested type literally named `Type` (or another Swift keyword) demangles/renders
        // backtick-escaped ("ToolDefinition.`Type`"), which the bare identifier character class
        // below doesn't match — missing it here means it's never added to externalTypes and
        // the dependency stub omits it entirely, e.g. "extension ...ToolDefinition.`Type` {"
        // referencing a `Type` that was never stubbed. Allow an optional backtick-quoted segment
        // anywhere in the dotted path.
        let identifierSegment = "(?:[a-zA-Z0-9_$]+|`[a-zA-Z0-9_$]+`)"
        // No trailing \b: a path ending in a backtick-quoted segment (e.g. "Foo.`Type`") has a
        // non-word character on both sides of that final backtick, so \b never matches there.
        let pathPattern = "\\b([A-Z][a-zA-Z0-9_$]*\\.\(identifierSegment)(?:\\.\(identifierSegment))*)"
        if let regex = try? NSRegularExpression(pattern: pathPattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            // Hoisted out of the match loop -- rebuilding a full Character array of the entire
            // (often 1MB+) generated file on EVERY match (this pattern alone can match thousands
            // of dotted-path references in a large file) turns this into an O(n*k) scan that was
            // measured taking 40+ seconds on ModelCatalog's ~1MB output. Building it once is O(n).
            let chars = Array(outputCode)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    // Strip backticks so a keyword-named segment ("`Type`") matches the plain
                    // "Type"/"Protocol"/... names generateSwift()'s own escaping check looks for
                    // — StubNode tree-building and re-escaping on emit stay in sync this way.
                    let typeName = String(outputCode[range]).replacingOccurrences(of: "`", with: "")

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
                    let isSelfDeclaredExtension = selfDeclaredExtensionTypes.contains {
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
                        let isSelfDeclaredExt = selfDeclaredExtensionTypes.contains {
                            fullConfName == $0 || fullConfName.hasPrefix($0 + ".")
                        }
                        if !visited.contains(fullConfName) && !isSelfDeclaredExt {
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

        // Loading a dependency's own .tbd and enriching it with real members (below) can reveal
        // that one of its real member signatures references a THIRD module's type/protocol that
        // was never part of the original externalTypes scan (nothing in the target's own
        // interface ever mentioned it) — e.g. IntelligencePlatformLibrary's real members
        // reference BiomeStreams.DataResource, but BiomeStreams was never otherwise discovered
        // as a dependency of TokenGenerationCore. Loop: load+enrich every currently-known
        // module, scan the newly-enriched real member signatures for private-framework type
        // references, add any newly-discovered ones to externalTypes, and repeat until a full
        // pass finds nothing new (fixed point) or a safety cap is hit — mirroring
        // orchestrate.py's own build_framework rescan loop (max_rescan_passes), which solves a
        // structurally similar "discovered too late" problem one level up, at the process level.
        var processedTbdModules = Set<String>()
        let maxTransitiveDepth = 10
        for _ in 0..<maxTransitiveDepth {
            let modsToLoad = Set(externalTypes.keys).subtracting(processedTbdModules)
            if modsToLoad.isEmpty { break }

            for mod in modsToLoad {
                processedTbdModules.insert(mod)
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
                guard let content = tbdContent else { continue }
                // A dependency's own .tbd can itself be a multi-document file if IT has
                // reexported-libraries (e.g. GenerativeFunctionsFoundation.tbd's second document
                // is actually PromptKit's re-exported symbol table, install-name and all).
                // Scanning the whole raw file (as opposed to just this dependency's own first
                // document) misattributes a reexported library's real, standalone symbols to
                // this dependency -- e.g. GenerativeFunctionsFoundation.tbd's doc2 exports
                // PromptKit.RecursiveSchema.Options's nominal-type-descriptor symbol as a
                // genuine current export, making it look like GenerativeFunctionsFoundation's
                // own ABI proof the type is real there, when it's actually only real in
                // PromptKit's document. Isolate this dependency's own first document exactly
                // like main.swift's `ownDocument` does for the primary target (line ~35).
                let ownDepDocument = content.components(separatedBy: "--- !tapi-tbd").dropFirst().first.map { "--- !tapi-tbd" + $0 } ?? content
                let depSymbols = extractSymbols(from: ownDepDocument)
                var depDemangledMap: [(mangled: String, demangled: String)] = []
                for sym in depSymbols {
                    if let dem = demangle(symbol: sym) {
                        depDemangledMap.append((mangled: sym, demangled: dem))
                    }
                }
                parser.discoverNominalTypes(demangledMap: depDemangledMap, currentModule: mod)
                // A dependency's own real members can reference an ObjC class (mangled "So...C",
                // e.g. IntelligencePlatformLibrary's BMSQLColumn) that's only ever registered via
                // this same objc-classes:-scanning mechanism (used at real-target-processing time
                // for the primary target and its depth-1 reexported libraries, main.swift ~51/60)
                // — without it, the class is genuinely undeclared anywhere and the enriched
                // member referencing it fails to compile. Register under "__C" (matching the
                // reexported-library convention) so it's visible bare, unqualified, exactly like
                // any other ObjC-bridged type.
                registerObjcClasses(from: content, parser: parser, module: "__C")

                // Additionally run this dependency's own symbols through the SAME
                // precompute/default-argument-prepass/parse pipeline used for the real target
                // (processSymbols), so its real members land in TypeNode.members instead of
                // being silently dropped. parse() gates member routing on
                // `getTopLevelModule(for: node) == primaryTargetModule` (Parser.swift) — with
                // primaryTargetModule/defaultModule still pointing at the top-level target,
                // every declaration native to this dependency looks "external" and never
                // reaches `.members`. Temporarily repoint both (defaultModule is read
                // pervasively by TypeNode.generateCode, not just primaryTargetModule) at the
                // dependency while processing its symbols, then restore.
                //
                // Known accepted gap: processSymbols() no-ops if parser.processedModules
                // already contains `mod` (e.g. it was already pulled in once as a depth-1
                // reexported library of the real target, under the WRONG primaryTargetModule) —
                // such a dependency silently falls back to the empty-skeleton stub below rather
                // than being force-reprocessed, since forcing a second pass over accumulating
                // parser state (tbdSymbols, symbolEscapingMap, defaultArgMap) not designed for
                // multiple passes over one module risks corrupting it in ways that are harder to
                // reason about than the empty-skeleton fallback this replaces.
                if !parser.processedModules.contains(mod) {
                    let savedPrimaryTarget = parser.primaryTargetModule
                    let savedDefaultModule = parser.defaultModule
                    let savedPrecomputeModule = parser.currentPrecomputeModule
                    // ownTbdSymbols only gets populated at depth 0 (processSymbols) -- but this
                    // call is always depth 1, so a member/extension this dependency's own real
                    // ABI moved via @_originallyDefinedIn (e.g. PromptKit's RecursiveSchema.
                    // Options.init(rawValue:), which really lives in PromptKit's OWN .tbd, not
                    // GenerativeFunctionsFoundation's) never satisfies originallyDefinedInExtensions'
                    // `ownTbdSymbols.contains(mangled)` check here, even though primaryTargetModule
                    // is correctly repointed at `mod` a few lines below. Temporarily add this
                    // dependency's own symbols so that check succeeds for symbols genuinely
                    // exported by `mod`'s own .tbd, then restore -- must not leak into the real
                    // target's own ownTbdSymbols, which drives Stage F's cross-target movedFromModule
                    // detection for OTHER modules and would misfire if left polluted.
                    let savedOwnTbdSymbols = parser.ownTbdSymbols
                    parser.ownTbdSymbols.formUnion(depSymbols)
                    parser.primaryTargetModule = mod
                    parser.defaultModule = mod
                    processSymbols(depSymbols, parser: parser, module: mod, depth: 1)
                    parser.primaryTargetModule = savedPrimaryTarget
                    parser.defaultModule = savedDefaultModule
                    parser.currentPrecomputeModule = savedPrecomputeModule
                    parser.ownTbdSymbols = savedOwnTbdSymbols
                }
            }

            // Scan every enriched module's real member signatures AND conformances for
            // private-framework type references not yet in externalTypes, using the same
            // dotted-path pattern used to scan the target's own interface further up this
            // function — this replaces the old one-shot conformance-only BFS (which only ever
            // walked the ORIGINAL externalTypes, before any dependency enrichment existed) by
            // running every pass against the current, growing externalTypes set instead.
            var foundNewTypeInThisPass = false
            func collectMemberSignatureText(_ node: TypeNode) -> String {
                var text = node.conformances.joined(separator: "\n") + "\n"
                for member in node.members.values {
                    switch member {
                    case .initializer(let s): text += s + "\n"
                    case .method(_, let s, _): text += s + "\n"
                    case .property(_, let t, _, _): text += t + "\n"
                    case .enumCase(_, let payload, _): text += (payload ?? "") + "\n"
                    case .associatedType(let s): text += s + "\n"
                    case .other: break
                    }
                }
                for nested in node.nestedTypes.values {
                    text += collectMemberSignatureText(nested)
                }
                return text
            }
            for mod in Set(externalTypes.keys) {
                guard let modNode = parser.modules[mod] else { continue }
                for topType in modNode.nestedTypes.values {
                    let text = collectMemberSignatureText(topType)
                    guard !text.isEmpty else { continue }
                    // The type-name capture (group 2) allows a leading underscore (e.g.
                    // GenerativeFunctions._StreamSanitizer) -- Swift's ABI-internal protocol
                    // naming convention prefixes some real, publicly-referenceable protocols
                    // with "_", and requiring an uppercase first character silently excluded
                    // them from transitive discovery, leaving the referencing module's own
                    // conformance unresolvable.
                    if let regex = try? NSRegularExpression(pattern: "(?<!\\.)\\b([A-Z][a-zA-Z0-9_$]*)\\.(_?[A-Z][a-zA-Z0-9_]*(?:\\._?[A-Z][a-zA-Z0-9_]*)*)", options: []) {
                        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
                        for m in regex.matches(in: text, options: [], range: nsRange) {
                            guard let modRange = Range(m.range(at: 1), in: text),
                                  let restRange = Range(m.range(at: 2), in: text) else { continue }
                            let refMod = String(text[modRange])
                            guard refMod != mod, refMod != currentModule, refMod != "Swift", refMod != "Foundation" else { continue }
                            let isPrivateFw = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(refMod).framework") ||
                                              FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(refMod).framework")
                            guard isPrivateFw else { continue }
                            // Keep the FULL dotted path (e.g. "BiomeStreams.LibraryArtifact.
                            // DataArtifact"), matching how the original target-interface scan
                            // (pathPattern, above) captures nested-type references — a namespace-
                            // only type like LibraryArtifact can have zero symbols of its own
                            // (no nominal type descriptor), existing purely as a path prefix for
                            // its real nested case-types, so truncating to the first segment
                            // would stub an empty, disconnected LibraryArtifact and never
                            // discover DataArtifact/Table as their own StubNode entries.
                            let fullPath = String(text[restRange])
                            let fullTypeName = "\(refMod).\(fullPath)"
                            let isSelfDeclaredExt = selfDeclaredExtensionTypes.contains {
                                fullTypeName == $0 || fullTypeName.hasPrefix($0 + ".")
                            }
                            let alreadyKnown = (externalTypes[refMod] ?? []).contains { $0.typeName == fullTypeName }
                            if !alreadyKnown && !isSelfDeclaredExt {
                                var isProto = false
                                if let confNode = parser.findTypeNode(module: refMod, path: fullPath.components(separatedBy: ".")) {
                                    isProto = (confNode.kind == "protocol")
                                }
                                externalTypes[refMod, default: []].append((typeName: fullTypeName, isProtocol: isProto, genericCount: 0))
                                foundNewTypeInThisPass = true
                            }
                        }
                    }
                }
            }
            if !foundNewTypeInThisPass && modsToLoad.isEmpty { break }
        }

        // Collected across ALL modules' hoists below — a protocol hoisted out of ITS OWN
        // module's nested path (e.g. BiomeStreams.LibraryArtifact.DataArtifact ->
        // BiomeStreams.DataArtifact) must also be rewritten wherever a DIFFERENT module's stub
        // (e.g. IntelligencePlatformLibrary) references the original nested path, so the rename
        // is applied as a final pass over every generated fileContent, after all modules have
        // been processed and all hoists are known.
        var allHoistedProtocolRenames = [(originalDottedPath: String, name: String)]()
        var fileContentsByModule = [String: String]()

        for (mod, items) in externalTypes {
            if ConfigManager.verbose { print("Stubbing: \(mod) has \(items.count) items: \(items.map { $0.typeName })", to: &Self.standardError) }
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
                        node.originalPath = pathSoFar
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
                                // A still dot-qualified conformance (e.g. "GenerativeFunctionsFoundation.
                                // ChatLanguageModelResponseStringStreamString") whose owning module is
                                // circular relative to `mod` is exactly as unresolvable here as the
                                // bare-name case handled below -- this memberless StubNode fallback
                                // never goes through renderEnrichedType's own circular-line filter, so
                                // without this check a genuinely circular qualified reference survives
                                // verbatim into the stub (confirmed via TokenGeneration.Token, whose
                                // GenerativeFunctionsFoundation-qualified conformance list compiled fine
                                // in isolation but failed once GenerativeFunctionsFoundation joined the
                                // detected stub-import cycle and its own dependency stub -- which this
                                // Token reference needs -- stopped being importable here).
                                if let dotIdx = noAny.range(of: ".", options: .backwards) {
                                    let owningModule = String(noAny[..<dotIdx.lowerBound])
                                    if owningModule != mod {
                                        var circularModules = Set([currentModule])
                                        if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
                                            circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
                                        }
                                        if circularModules.contains(owningModule) {
                                            return nil
                                        }
                                    }
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
                                // This memberless StubNode fallback path (its type had no real
                                // members/nested types, so renderEnrichedType's own circular
                                // filter -- which only ever runs on real enriched member/decl
                                // text -- never gets a chance to see this conformance at all) can
                                // still carry a bare protocol name whose owning module differs
                                // from `mod` -- e.g. GenerativeModelsFoundation.SelfAttention
                                // conforming to PromptKit.PromptComponentValueConvertible, already
                                // stripped bare by Model.swift's discoveredProtocols-driven
                                // qualifier stripping. If that owning module is circular relative
                                // to `mod` (PromptKit imports GenerativeModelsFoundation, so a
                                // GenerativeModelsFoundation stub can't import PromptKit back),
                                // drop the conformance exactly like renderEnrichedType does for
                                // circular bare protocol references on a real-enriched type.
                                if !noAny.contains("."), noAny != "AnyObject",
                                   let qualifiedMatch = parser.discoveredProtocols.first(where: { $0.hasSuffix("." + noAny) }) {
                                    let owningModule = String(qualifiedMatch.dropLast(noAny.count + 1))
                                    if owningModule != mod {
                                        var circularModules = Set([currentModule])
                                        if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
                                            circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
                                        }
                                        if circularModules.contains(owningModule) {
                                            return nil
                                        }
                                    }
                                }
                                return noAny
                            }
                        }
                        // AppleIntelligenceReporting's BiomeEventReporter.lazySource<A>/
                        // lazySourceInternal<A> declare "where A: Stream" (confirmed via real
                        // ABI mangling — see the comment at the "lazySource<A> {" replacement
                        // above), and every concrete Stream-typed generic argument (Availability,
                        // Buddy, MobileAsset, etc., all nested under
                        // IntelligencePlatformLibrary(_AppleInternal).Library/InternalLibrary.
                        // Streams...) must conform to Stream NATIVELY in this stub module, not
                        // via a retroactive extension declared in AppleIntelligenceReporting —
                        // a cross-module retroactive conformance forces an extra protocol-
                        // witness-table mangling substitution the real ABI doesn't have.
                        if currentModule == "AppleIntelligenceReporting",
                           (mod == "IntelligencePlatformLibrary" || mod == "IntelligencePlatformLibrary_AppleInternal"),
                           ["Availability", "Buddy", "MobileAsset", "MobileAssetVerbose", "ModelCatalog",
                            "SoftwareUpdateController", "UnifiedAssetFramework", "Step", "InstrumentationEvent",
                            "ModelIO"].contains(part) {
                            node.conformances.append("Stream")
                            // If this type ends up rendered from real, enriched member data
                            // (generateCode(), not this StubNode's own generateSwift()), the
                            // conformance injected above onto the StubNode never reaches the
                            // actual output — generateCode() reads TypeNode.conformances, a
                            // separate set. Mirror the injection onto the real TypeNode too.
                            if let realTypeNode = parser.findTypeNode(module: mod, path: pathSoFar) {
                                realTypeNode.conformances.insert("Stream")
                            }
                        }
                        // IntelligencePlatformLibrary_AppleInternal.InternalLibrary.Streams.
                        // AppleIntelligence.Reporting.ModelIO has zero real ABI ground truth
                        // anywhere (this synthetic module has no real .tbd at all), so
                        // parser.findTypeNode above never resolves a kind for it and it falls
                        // through to StubNode's "struct" default — but the real symbol mangles
                        // this whole namespace-only path as "O" (enum), matching the sibling
                        // IntelligencePlatformLibrary module's real, ABI-confirmed convention
                        // for the exact same "Library.Streams.AppleIntelligence.Reporting.*"
                        // hierarchy (which DOES have real .tbd data proving it's enums). Match
                        // that established convention for the corresponding _AppleInternal path
                        // instead of defaulting to struct.
                        if currentModule == "AppleIntelligenceReporting",
                           mod == "IntelligencePlatformLibrary_AppleInternal",
                           ["InternalLibrary", "Streams", "AppleIntelligence", "Reporting", "ModelIO"].contains(part),
                           node.kind == "struct" {
                            node.kind = "enum"
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
                    if !topLevelProtocols.contains(where: { $0.name == child.name }) {
                        topLevelProtocols.append(child)
                    }
                } else {
                    topLevelTypes.append(child)
                }
            }

            // Swift never permits a type declaration nested inside a protocol body (unlike
            // struct/class/enum, which can all nest each other and protocols freely) — a
            // protocol-kind StubNode discovered several nesting levels deep (e.g.
            // BiomeStreams.LibraryArtifact.DataArtifact, a protocol nested under the
            // namespace-only enum LibraryArtifact) must be hoisted out to a top-level
            // declaration instead of staying in its parent's `nested` dict, or the emitted stub
            // fails to compile ("type 'X' cannot be nested in protocol"/"cannot be nested in
            // struct" etc. for whatever nests it). Walk every top-level type's descendants,
            // remove any protocol-kind node from its parent, and promote it into
            // topLevelProtocols under its own top-level StubNode name (StubNode.name is only
            // the LEAF segment, so promoted protocols keep their real short name — a same-named
            // collision across two different nesting paths is deduplicated by name).
            func hoistNestedProtocols(_ node: StubNode, pathSoFar: [String]) {
                for (key, child) in node.nested {
                    let childPath = pathSoFar + [child.name]
                    if child.isProtocol || child.kind == "protocol" {
                        node.nested.removeValue(forKey: key)
                        if !topLevelProtocols.contains(where: { $0.name == child.name }) {
                            topLevelProtocols.append(child)
                        }
                        allHoistedProtocolRenames.append((originalDottedPath: "\(mod).\(childPath.joined(separator: "."))", name: child.name))
                    } else {
                        hoistNestedProtocols(child, pathSoFar: childPath)
                    }
                }
            }
            for t in topLevelTypes {
                hoistNestedProtocols(t, pathSoFar: [t.name])
            }
            
            for proto in topLevelProtocols.sorted(by: { $0.name < $1.name }) {
                let lookupPath = proto.originalPath.isEmpty ? [proto.name] : proto.originalPath
                if let realNode = parser.findTypeNode(module: mod, path: lookupPath), !realNode.members.isEmpty {
                    let code = renderEnrichedType(realNode, mod: mod, currentModule: currentModule, parser: parser, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
                    fileContent += code + "\n"
                } else {
                    let fullPath = "\(mod).\(proto.name)"
                var genericDecl = ""
                var assocDecl = ""
                var placeholderNames = Set<String>()
                if proto.genericCount > 0 {
                    let placeholders = ["A", "B", "C", "D", "E"]
                    let count = min(proto.genericCount, placeholders.count)
                    var names = Array(placeholders[..<count])
                    // A single-primary-associated-type protocol's real name (recovered from
                    // real usage sites — see primaryAssociatedTypeNames) must be used verbatim:
                    // the mangled ABI symbol encodes the associated type's actual declared name,
                    // not just its position, so a bare "A" placeholder here would never match.
                    if count == 1, let realName = primaryAssociatedTypeNames[proto.name] {
                        names = [realName]
                    }
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
            }
            
            for t in topLevelTypes.sorted(by: { $0.name < $1.name }) {
                // If this dependency was additionally run through the real parse() pipeline
                // above, its TypeNode carries real members/nested types (generateCode()
                // self-recurses into nestedTypes, so a single top-level call renders the whole
                // nested tree) — render those instead of StubNode's empty-skeleton fallback, so
                // the stub's ABI shape actually matches the real dependency.
                if let realNode = parser.findTypeNode(module: mod, path: [t.name]), (!realNode.members.isEmpty || !realNode.nestedTypes.isEmpty) {
                    let code = renderEnrichedType(realNode, mod: mod, currentModule: currentModule, parser: parser, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
                    fileContent += code + "\n"
                } else {
                    fileContent += t.generateSwift(depth: 0) + "\n"
                }
            }

            // Enriching a type with real members (above) can surface a bare reference to a
            // SIBLING type/protocol declared in this SAME module (mod) that was never part of
            // the original externalTypes scan, because nothing in the target's own interface
            // ever mentioned it as dotted "mod.Foo" text — e.g. IntelligencePlatformLibrary's
            // real StreamResource protocol, referenced bare ("any StreamResource.Type") from an
            // enriched member, with no other type in this stub ever conforming to or importing
            // it. Do a same-module closure pass: scan the assembled body for bare capitalized
            // identifiers not already declared here, and if parser has real (enriched) data for
            // that name under `mod`, emit its declaration too. This does not reach into a THIRD
            // module's own incomplete stub (that cross-module case is a distinct, larger problem
            // — see the import-inference comment below, which papers over it with a plain
            // "import Qualifier" instead of a real declaration).
            var knownStubTypeNames = Set(topLevelTypes.map { $0.name } + topLevelProtocols.map { $0.name })
            var closurePassBudget = 20
            while closurePassBudget > 0 {
                closurePassBudget -= 1
                var newlyFound = [String]()
                var newlyFoundObjc = [String]()
                var newlyFoundOpaqueStruct = [String]()
                // A same-module reference discovered via the enrichment pass (renderEnrichedType)
                // can be permanently baked into its cached signature string as "mod.Name" — the
                // TypeNode's member-signature text is computed once under whatever defaultModule
                // was active at first parse and reused verbatim (see requalifyBareForeignTypeNames'
                // header comment for the general shape of this caching quirk) — so a bare-identifier
                // scan alone misses it. Allow an optional "<mod>." qualifier directly before the
                // identifier without excluding it (unlike a genuinely foreign "OtherMod.Name",
                // which must stay excluded so this pass doesn't reach into a third module's stub).
                let qualifiedModPrefix = "(?:\(NSRegularExpression.escapedPattern(for: mod))\\.)?"
                if let bareIdentRegex = try? NSRegularExpression(pattern: "(?<![.A-Za-z0-9_])\(qualifiedModPrefix)([A-Z][A-Za-z0-9_]*)\\b", options: []) {
                    let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                    for m in bareIdentRegex.matches(in: fileContent, options: [], range: nsRange) {
                        if let range = Range(m.range(at: 1), in: fileContent) {
                            let name = String(fileContent[range])
                            guard !knownStubTypeNames.contains(name), name != mod, name != "Swift", name != "Foundation" else { continue }
                            // These bare names are real system-framework types that get a real
                            // "import <Framework>" below (mirroring resolveImports) rather than
                            // an opaque local placeholder — declaring both would be ambiguous.
                            let hasRealSystemFrameworkImport = ["IOSurface", "OSAllocatedUnfairLock", "CVPixelBuffer", "CVBuffer", "CMTime"].contains(name)
                            if hasRealSystemFrameworkImport {
                                knownStubTypeNames.insert(name)
                            } else if parser.systemTypes.contains(name) {
                                // A real TypeNode can exist under `mod` for a bare name that's
                                // ALSO a genuine Swift/Foundation system type (e.g. ModelCatalog's
                                // own ABI declares a "ModelCatalog.NSNumber" class purely because
                                // its symbols return the real Foundation.NSNumber under that
                                // qualifier — not because ModelCatalog owns a distinct NSNumber).
                                // Declaring a local stub here would collide with the real
                                // Foundation type already visible via "import Foundation"
                                // ("'NSNumber' is ambiguous for type lookup"). Leave it as the
                                // real system type; no stub, no import needed.
                                knownStubTypeNames.insert(name)
                            } else if parser.findTypeNode(module: mod, path: [name]) != nil {
                                // Any other real TypeNode discovered under this module qualifies,
                                // not just ones with real members or protocols -- a bare-
                                // referenced sibling type can be a genuine, real ABI type with NO
                                // members at all (e.g. ODIE.SharedMutableBytes, an opaque
                                // `@objc deinit`-only class referenced from
                                // Tensor.SharedStorageBacking.bytes), and skipping it here left
                                // the stub referencing a type it never declares ("cannot find
                                // type 'SharedMutableBytes' in scope"). generateCode()/
                                // renderEnrichedType() already render a memberless type correctly
                                // as an empty `class/struct/enum Name {}`.
                                newlyFound.append(name)
                            } else if parser.findTypeNode(module: "__C", path: [name]) != nil {
                                // A bare ObjC class (registered under "__C" above) referenced by
                                // an enriched member — no Swift-visible declaration exists
                                // anywhere for it beyond its bare name, so a minimal opaque
                                // placeholder is the correct (not just expedient) fix here, not
                                // a workaround: this mirrors how the real target itself renders
                                // an ObjC-bridged type it can't otherwise describe.
                                newlyFoundObjc.append(name)
                            } else if name == "XPCCodableObject" {
                                // Real ABI-visible (via swift-demangle) as XPC.XPCCodableObject,
                                // but XPC has no swiftinterface/tbd in this SDK at all — the type
                                // is genuinely undeclared anywhere reachable. generateAll() (the
                                // primary-target path) already falls back to a local opaque
                                // struct for this exact case; mirror that here for the dependency-
                                // stub path, which never went through that fallback.
                                newlyFoundOpaqueStruct.append(name)
                            }
                        }
                    }
                }
                if newlyFound.isEmpty && newlyFoundObjc.isEmpty && newlyFoundOpaqueStruct.isEmpty { break }
                for name in Set(newlyFoundObjc) {
                    knownStubTypeNames.insert(name)
                    fileContent += "public class \(name) {}\n"
                }
                for name in Set(newlyFoundOpaqueStruct) {
                    knownStubTypeNames.insert(name)
                    fileContent += "public struct \(name): Hashable, Codable, Sendable {}\n"
                }
                for name in Set(newlyFound) {
                    if knownStubTypeNames.contains(name) { continue }
                    knownStubTypeNames.insert(name)
                    let declPattern = "(?:^|\\n)(?:@[A-Za-z0-9_]+\\s+)*(?:public\\s+|open\\s+)?(?:protocol|struct|class|enum|typealias)\\s+\(name)\\b"
                    if fileContent.range(of: declPattern, options: .regularExpression) != nil { continue }
                    guard let realNode = parser.findTypeNode(module: mod, path: [name]) else { continue }
                    if realNode.kind == "protocol" {
                        fileContent += "public protocol \(name) {}\n"
                    } else {
                        let code = renderEnrichedType(realNode, mod: mod, currentModule: currentModule, parser: parser, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
                        fileContent += code + "\n"
                    }
                }
            }

            // GenerativeModelsFoundation.SelfAttention.toValue()'s real ABI return type demangles
            // as "PromptKit.Prompt.Component.Value" -- but no framework anywhere in this SDK
            // (searched across every PrivateFrameworks .tbd) declares a "Prompt.Component" nested
            // type under ANY module, including TokenGeneration (where "Prompt" itself genuinely
            // lives). This is a residual, unresolvable ABI gap -- same class of issue as the
            // "Generable" protocol reference diagnosed but never fixed in an earlier session
            // (Stage D "graceful degradation", per the dependency-stub-member-enrichment plan,
            // was never implemented). The exact qualifier surviving into fileContent varies by
            // which build pass rendered it (PromptKit.Prompt.Component.Value or, after
            // requalifyBareForeignTypeNames "corrects" it, TokenGeneration.Prompt.Component.Value)
            // -- rather than chase that qualifier, replace either broken reference text with a
            // self-contained local placeholder type, avoiding any ambiguity about which external
            // module's "Prompt" to extend. This MUST run before the extraImports qualifier scan
            // below -- otherwise that scan still sees the bare "PromptKit.Prompt..." text and
            // emits a spurious "import PromptKit" even though the reference is gone afterward,
            // which is what was producing the real PromptKit<->TokenGenerationCore import cycle.
            // Only the bare return-type reference is broken -- "Prompt.Component.Value" is a
            // real, legitimately-declared nested type (see PromptKit.swift's own "public enum
            // Value" under "public struct Component"), and a FURTHER-qualified reference like
            // "...Value.CustomData" (Value's own nested type) must be left alone. A negative
            // lookahead for a trailing "." restricts the replacement to the bare reference.
            for badRef in ["PromptKit.Prompt.Component.Value", "TokenGeneration.Prompt.Component.Value"] {
                if let badRefRegex = try? NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: badRef) + "(?!\\.[A-Za-z])") {
                    let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                    fileContent = badRefRegex.stringByReplacingMatches(in: fileContent, range: nsRange, withTemplate: "SelfAttentionValuePlaceholder")
                }
            }
            if fileContent.containsWord("SelfAttentionValuePlaceholder") {
                fileContent += "\npublic enum SelfAttentionValuePlaceholder {}\n"
            }
            var circularModules = Set([currentModule])
            if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
                circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
            }
            if mod == "GenerativeFunctionsFoundation" {
                if !circularModules.contains("PromptKit") {
                    fileContent = fileContent.replacingOccurrences(
                        of: "public struct ChatMessageResponse<A>: ChatLanguageModelResponse, ChatLanguageModelResponseBase {\n    public var content: A { get { fatalError() } }\n}",
                        with: "public struct ChatMessageResponse<A>: ChatLanguageModelResponse, ChatLanguageModelResponseBase {\n    public var content: A { get { fatalError() } }\n    public var role: PromptKit.ChatMessageRole { get { fatalError() } }\n}"
                    )
                }
            }

            // A stub type's conformance/generic-bound list can reference a THIRD module's
            // type by its qualified name (e.g. "GenerativeFunctionsFoundation.
            // ChatLanguageModelResponseStringStream" showing up while stubbing
            // GenerativeModels, because one of GenerativeModels' own real types conforms to a
            // protocol declared in yet another dependency) without that module ever being
            // discovered as a top-level dependency of THIS stub — only "import Foundation" is
            // ever written unconditionally. Scan the fully-assembled body text for any
            // "Qualifier.Identifier" reference and add a matching import for every distinct
            // capitalized qualifier that isn't Swift/Foundation/this module itself, so the
            // stub actually resolves the cross-module type instead of failing "cannot find
            // type 'X' in scope".
            // Collect every type name this stub itself declares, at any nesting depth, so the
            // qualifier scan below doesn't mistake a nested-type path (e.g.
            // "Prompt.MediaCollectionAttachment.AudioSamples") for a module name and emit a
            // bogus "import AudioSamples" — StubNode.generateSwift's own keyword-escaping
            // (main.swift, "public \(kindKeyword) \(escapedName)...") can backtick-quote a name,
            // so match that optional form too and strip the backticks back off.
            var selfDeclaredStubTypeNames = Set<String>()
            if let declRegex = try? NSRegularExpression(pattern: "public (?:struct|enum|class|protocol) (`[A-Za-z0-9_]+`|[A-Za-z0-9_]+)", options: []) {
                let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                for m in declRegex.matches(in: fileContent, options: [], range: nsRange) {
                    if let range = Range(m.range(at: 1), in: fileContent) {
                        selfDeclaredStubTypeNames.insert(String(fileContent[range]).replacingOccurrences(of: "`", with: ""))
                    }
                }
            }
            // The qualifier must not be preceded by a "." — otherwise a long dotted chain like
            // "BiomeStreams.LibraryArtifact.DataArtifact.Type" gets matched twice by a plain
            // \b-anchored scan (NSRegularExpression matches don't overlap): once correctly for
            // "BiomeStreams", then again starting fresh at "DataArtifact.Type", misreading the
            // nested-type segment "DataArtifact" as if it were its own top-level module
            // qualifier. A "(?<!\\.)" lookbehind restricts matches to the true first segment of
            // each dotted chain.
            var extraImports = Set<String>()
            if let regex = try? NSRegularExpression(pattern: "(?<!\\.)\\b([A-Z][A-Za-z0-9_]*)\\.[A-Z][A-Za-z0-9_]*", options: []) {
                let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                let matches = regex.matches(in: fileContent, options: [], range: nsRange)
                for m in matches {
                    if let range = Range(m.range(at: 1), in: fileContent) {
                        let qualifier = String(fileContent[range])
                        // A bare generic placeholder can appear immediately before a dotted
                        // member/metatype access ("A.Type", "A.Element", "GenericA.Type") in a
                        // real method signature — that's a type-parameter reference, not a
                        // module-qualified type, and must not be treated as an import target.
                        // Covers both this generator's own two placeholder-naming conventions:
                        // the short "A"/"B"/"C"... form (StubNode's own placeholders) and the
                        // "GenericA"/"GenericB"... form (Model.swift's disambiguation rename,
                        // used when a placeholder collides with an in-scope name).
                        let isGenericPlaceholder = (qualifier.count <= 3 &&
                            qualifier.first?.isUppercase == true &&
                            qualifier.dropFirst().allSatisfy { $0.isNumber }) ||
                            (qualifier.hasPrefix("Generic") && qualifier.count <= 9 &&
                             qualifier.dropFirst("Generic".count).allSatisfy { $0.isUppercase || $0.isNumber })
                        // A bare capitalized identifier before a dot can also be a real
                        // Swift/Foundation top-level type (e.g. "Locale.LanguageCode",
                        // "Locale.Language") rather than a module qualifier — Foundation is
                        // always imported unconditionally (main.swift, "import Foundation\n\n"),
                        // so these resolve without any extra import. Only treat the qualifier as
                        // an import target if it's an actual private framework on disk;
                        // otherwise the name is either already visible (Swift/Foundation, or a
                        // sibling type in this same stub) or is a mis-parsed placeholder.
                        let qualifierIsPrivateFramework = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(qualifier).framework") ||
                                                           FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(qualifier).framework") ||
                                                           FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/Frameworks/\(qualifier).framework")
                        if qualifier != "Swift", qualifier != "Foundation", qualifier != mod,
                           qualifier != currentModule,
                           !(circularModules.contains(mod) && circularModules.contains(qualifier)),
                           !isGenericPlaceholder, !selfDeclaredStubTypeNames.contains(qualifier),
                           qualifierIsPrivateFramework {
                            extraImports.insert(qualifier)
                        }
                    }
                }
            }
            // A real member's conformance list can reference a cross-module PROTOCOL by its
            // bare (unqualified) name -- Model.swift's inheritsList-cleaning (TypeNode.init)
            // permanently strips a protocol's module qualifier whenever that protocol's dotted
            // name is present in parser.discoveredProtocols, on the assumption it'll be visible
            // in whatever file the type is finally rendered into. That assumption fails here: a
            // dependency stub is split one-file-per-module, so a bare protocol name declared in
            // a DIFFERENT dependency's stub file (e.g. PromptKit.PromptComponentValueConvertible
            // referenced bare from GenerativeModelsFoundation's real, Stage-B-enriched
            // SelfAttention) is unresolvable without its own explicit import -- there is no
            // "Qualifier." prefix left for the dotted-qualifier scan above to catch. Recover the
            // owning module from discoveredProtocols' dotted form for every bare protocol name
            // that appears as a whole word in this stub's body.
            if let bareWordRegex = try? NSRegularExpression(pattern: "(?<![A-Za-z0-9_$.])[A-Za-z_][A-Za-z0-9_]*", options: []) {
                let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                var bareWords = Set<String>()
                for m in bareWordRegex.matches(in: fileContent, options: [], range: nsRange) {
                    if let range = Range(m.range, in: fileContent) {
                        bareWords.insert(String(fileContent[range]))
                    }
                }
                for qualifiedProto in parser.discoveredProtocols {
                    guard let dotIdx = qualifiedProto.range(of: ".", options: .backwards) else { continue }
                    let owningModule = String(qualifiedProto[..<dotIdx.lowerBound])
                    let bareName = String(qualifiedProto[dotIdx.upperBound...])
                    guard owningModule != mod, owningModule != "Swift", owningModule != "Foundation",
                          owningModule != currentModule,
                          !(circularModules.contains(mod) && circularModules.contains(owningModule)),
                          !selfDeclaredStubTypeNames.contains(bareName),
                          bareWords.contains(bareName) else { continue }
                    let owningModuleIsPrivateFramework = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(owningModule).framework") ||
                                                          FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(owningModule).framework") ||
                                                          FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/Frameworks/\(owningModule).framework")
                    guard owningModuleIsPrivateFramework else { continue }
                    extraImports.insert(owningModule)
                }
            }
            // Real member signatures can also reference a system-framework type by its bare
            // (unqualified) name — e.g. "CMTime", "CVBuffer", "IOSurface" — which the
            // dotted-qualifier scan above never catches since there's no "Qualifier." prefix.
            // Mirror resolveImports' (main.swift) same bare-name -> framework mappings for the
            // system frameworks these dependency stubs have been observed to need.
            if fileContent.containsWord("IOSurface") { extraImports.insert("IOSurface") }
            if fileContent.containsWord("OSAllocatedUnfairLock") || fileContent.containsWord("Logger") || fileContent.contains("os.") { extraImports.insert("os") }
            if fileContent.containsWord("CVPixelBuffer") || fileContent.containsWord("CVBuffer") { extraImports.insert("CoreVideo") }
            if fileContent.containsWord("CMTime") { extraImports.insert("CoreMedia") }
            if fileContent.containsWord("MPSCommandBuffer") || fileContent.containsWord("MPSDataType") || fileContent.containsWord("MPSGraph") { extraImports.insert("MetalPerformanceShaders") }
            if !extraImports.isEmpty {
                let importLines = extraImports.sorted().map { "import \($0)\n" }.joined()
                fileContent = fileContent.replacingOccurrences(
                    of: "import Foundation\n\n",
                    with: "import Foundation\n" + importLines + "\n")
            }

            // ModelManagerServices.ClientData is returned across an actor-isolation boundary by
            // TokenGeneration.DictationStreamingPromptRequest.next() (an actor's
            // AsyncIteratorProtocol requirement) -- Swift 6 requires that return type be
            // Sendable, or Codable/Hashable is not enough. The real ClientData almost certainly
            // IS Sendable (Foundation.Data and an opaque XPCCodableObject are its only stored
            // properties, both value-semantic), but its .tbd conformance descriptors don't list
            // Sendable explicitly (implicit derivation isn't ABI-visible). Declare it explicitly
            // wherever this stub renders ClientData's own declaration.
            if mod == "ModelManagerServices" {
                fileContent = fileContent.replacingOccurrences(
                    of: "public struct ClientData: Codable, Hashable {",
                    with: "public struct ClientData: Codable, Hashable, Sendable {")
            }

            // Same GenerativeConfigurationProtocol associated-type gap postProcess() already
            // fixes on PromptKit's own primary-target render path (see the
            // `parser.defaultModule == "PromptKit"` block above) -- postProcess() only runs on
            // that path, not here in the dependency-stub assembly loop, so PromptKit-as-a-
            // dependency (e.g. for TokenGenerationCore) needs the identical typealias injection
            // applied to whatever text this loop actually rendered.
            if mod == "ODIE" {
                if !fileContent.contains("public struct _Profiler") {
                    fileContent += "\npublic struct _Profiler {}\n"
                }
                if !fileContent.contains("public struct _Attribute") {
                    fileContent += "\npublic struct _Attribute {}\n"
                }
            }

            if mod == "PromptKit" {
                fileContent = fileContent.replacingOccurrences(
                    of: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {",
                    with: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = ChatMessagesPrompt\n    public typealias PromptContentType = Swift.String")
                fileContent = fileContent.replacingOccurrences(
                    of: "public struct CompletionPrompt: Codable, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByStringInterpolation, Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {",
                    with: "public struct CompletionPrompt: Codable, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByStringInterpolation, Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = CompletionPrompt\n    public typealias PromptContentType = Swift.String")
            }

            // `Network.NWConnection.ConnectionProgressReport` is a genuine ABI-confirmed nested
            // type (its members are all real, demangled .tbd symbols), but it's absent from the
            // SDK's own shipped Network.swiftinterface -- library-evolution-hidden or simply not
            // yet reflected there. Any dependency stub referencing it via a plain "import Network"
            // (Network isn't itself a dependency stub -- it's a real system framework we never
            // rebuild) fails with "not a member type of class 'Network.NWConnection'". Declare it
            // locally as an extension, mirroring the shape generateAll() already synthesizes when
            // Network itself is the primary target (main.swift's "Fix 6" NWConnection-extension
            // handling) -- legal since a real class can gain a nested type via an extension in a
            // downstream module, and the real interface has no conflicting declaration to clash with.
            if fileContent.containsWord("ConnectionProgressReport") && mod != "Network" {
                fileContent = fileContent.replacingOccurrences(
                    of: "import Foundation\n",
                    with: "import Foundation\nimport Network\n")
                fileContent += """

                extension Network.NWConnection {
                    public struct ConnectionProgressReport: Codable, CustomStringConvertible, Equatable {
                        public var isMakingProgress: Swift.Bool { fatalError() }
                        public var reportedAt: Foundation.Date { fatalError() }
                        public var description: Swift.String { fatalError() }
                        public var elapsedTime: Swift.Duration { fatalError() }
                        public var isConnected: Swift.Bool { fatalError() }
                        public var rttEstimate: Swift.Duration { fatalError() }
                        public var isLowQuality: Swift.Bool { fatalError() }
                        public var completionEstimate: Swift.Duration { fatalError() }
                        public var completionEstimateRemaining: Swift.Duration { fatalError() }
                        public var isActive: Swift.Bool { fatalError() }
                        public var startedAt: Foundation.Date { fatalError() }
                        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
                        public init(from decoder: Swift.Decoder) throws { fatalError() }
                        public func encode(to encoder: Swift.Encoder) throws {}
                    }
                }

                """
            }

            // injectDefaultArguments/simplifyType's default-value fallback (Model.swift) emits
            // "= dummyDefaultValue()" for a parameter with no reconstructable literal default.
            // generateAll() (the primary-target path) declares this generic helper once in its
            // own output — but a Swift default-argument thunk's mangled symbol always resolves
            // the default EXPRESSION in the declaring type's OWN module, so a dependency stub
            // using this fallback needs its own local copy, not a cross-module import (which
            // wouldn't satisfy the thunk's symbol lookup even if it compiled).
            if fileContent.contains("dummyDefaultValue()") {
                fileContent += "\npublic func dummyDefaultValue<T>() -> T { fatalError() }\n"
            }

            fileContentsByModule[mod] = fileContent
        }

        // Apply every hoist rename (collected across ALL modules above) to every module's
        // generated text — a protocol hoisted out of ITS OWN module's nested path (e.g.
        // BiomeStreams.LibraryArtifact.DataArtifact -> BiomeStreams.DataArtifact) can be
        // referenced by a DIFFERENT module's stub (e.g. IntelligencePlatformLibrary) using the
        // original nested path, which no longer exists once hoisted.
        for (mod, content) in fileContentsByModule {
            var updated = content
            for rename in allHoistedProtocolRenames {
                guard let moduleSegment = rename.originalDottedPath.components(separatedBy: ".").first else { continue }
                let newPath = "\(moduleSegment).\(rename.name)"
                if updated.contains(rename.originalDottedPath) {
                    updated = updated.replacingOccurrences(of: rename.originalDottedPath, with: newPath)
                }
                let unqualifiedOriginalPath = String(rename.originalDottedPath.dropFirst(moduleSegment.count + 1))
                if !unqualifiedOriginalPath.isEmpty {
                    if mod == moduleSegment {
                        updated = updated.replacingOccurrences(of: unqualifiedOriginalPath, with: rename.name)
                    } else {
                        updated = updated.replacingOccurrences(of: unqualifiedOriginalPath, with: newPath)
                    }
                }
            }
            let filePath = "\(outputDir)/\(mod).swift"
            do {
                try updated.write(toFile: filePath, atomically: true, encoding: .utf8)
                if ConfigManager.verbose { print("Generated stub source for \(mod) at \(filePath)", to: &Self.standardError) }
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
            if ConfigManager.verbose { print("Generated empty stub for \(modName) at \(filePath)", to: &Self.standardError) }
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
