import Foundation

extension SwiftInterfaceGen {
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

    // Extensions on Swift stdlib types (e.g. RawSpan, Float, Double, Int, etc.) defined in this
    // module use mangled names starting with _$ss, _$sSf, etc. -- we can't define extensions on
    // ~Escapable stdlib types or system primitive types, so those (and any cross-module-extension
    // symbol not attributable to this module) get filtered from the expected-export set. Shared
    // by main()'s <module>_exports.txt writer and selfAlignInterface(), which must diff against
    // this same filtered set rather than raw parser.tbdSymbols (which also includes depth-1
    // reexported-library symbols that were never expected to be exported by this module).
    static func filteredExportSymbols(currentModule: String, tbdContent: String, parser: Parser) -> [String] {
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
        let ownObjcClasses = extractObjcClasses(from: tbdContent)
        for cls in ownObjcClasses {
            if !cls.hasPrefix("_Tt") {
                filteredExports.append("_OBJC_CLASS_$_\(cls)")
                filteredExports.append("_OBJC_METACLASS_$_\(cls)")
            }
        }
        filteredExports.sort()
        return filteredExports
    }

    static func extractMissingModules(_ text: String) -> Set<String> {
        var result = Set<String>()
        let marker = "no such module '"
        var searchRange = text.startIndex..<text.endIndex
        while let markerRange = text.range(of: marker, range: searchRange) {
            let afterMarker = markerRange.upperBound
            guard let closeRange = text.range(of: "'", range: afterMarker..<text.endIndex) else { break }
            result.insert(String(text[afterMarker..<closeRange.lowerBound]))
            searchRange = closeRange.upperBound..<text.endIndex
        }
        return result
    }

    // Mirrors verify_public.py's emit_empty_stub(): a minimal Swift module (source, .swiftmodule,
    // .swiftinterface, dylib) under <frameworksDir>/<moduleName>.framework/ so `import
    // <moduleName>` resolves for a private SDK dependency the self-align compile can't otherwise
    // see (no real declarations, but selfAlignInterface only needs the import to succeed, not the
    // dependency's own symbols to be complete). Always written into selfAlignInterface's own
    // per-call temp frameworks dir, never the persistent repo-root LocalFrameworks/ -- that
    // directory is shared with orchestrate.py's private-target builds and can contain a
    // same-named module (e.g. Combine) that legitimately shadows the real SDK one for private
    // targets but must never shadow it here (confirmed: SoundAnalysis's self-align compile broke
    // as soon as LocalFrameworks/Combine.framework was rebuilt by an unrelated `orchestrate.py
    // Combine` run, because -F search order let our own hand-generated Combine -- which doesn't
    // emit primary-associated-type syntax for Publisher/Subject -- shadow the real one).
    static func emitEmptyStubFramework(moduleName: String, sdkRoot: String, frameworksDir: String) {
        let fw = "\(frameworksDir)/\(moduleName).framework"

        // If a real, already-built framework for this module exists in the project's own
        // persistent LocalFrameworks/ (built by orchestrate.py's private-target pipeline, e.g.
        // FeatureFlags), copy it in read-only rather than synthesizing an empty stub -- an empty
        // stub would be missing every real declaration (e.g. HealthKit's real
        // `FeatureFlags.FeatureFlagsKey` conformance), causing spurious "no type named X in
        // module" errors. Mirrors verify_public.py's own emit_empty_stub().
        let persistentFw = "LocalFrameworks/\(moduleName).framework"
        if FileManager.default.fileExists(atPath: persistentFw) {
            try? FileManager.default.copyItem(atPath: persistentFw, toPath: fw)
            if FileManager.default.fileExists(atPath: fw) { return }
        }

        let modDir = "\(fw)/Modules/\(moduleName).swiftmodule"
        guard (try? FileManager.default.createDirectory(atPath: modDir, withIntermediateDirectories: true)) != nil else { return }

        let srcPath = NSTemporaryDirectory() + "_empty_stub_\(moduleName)_\(UUID().uuidString).swift"
        guard (try? "// empty stub for \(moduleName)\n".write(toFile: srcPath, atomically: true, encoding: .utf8)) != nil else { return }
        defer { try? FileManager.default.removeItem(atPath: srcPath) }

        let iface = "\(modDir)/arm64-apple-macos.swiftinterface"
        let modFile = "\(modDir)/arm64-apple-macos.swiftmodule"
        let emitModule = Process()
        emitModule.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
        emitModule.arguments = [
            "-emit-module", "-module-name", moduleName, srcPath,
            "-enable-library-evolution", "-language-mode", "6",
            "-sdk", sdkRoot,
            "-emit-module-interface-path", iface, "-o", modFile
        ]
        try? emitModule.run()
        emitModule.waitUntilExit()

        let lib = "\(fw)/\(moduleName)"
        let emitLib = Process()
        emitLib.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
        emitLib.arguments = [
            "-emit-library", "-o", lib, srcPath,
            "-enable-library-evolution", "-module-name", moduleName,
            "-sdk", sdkRoot, "-language-mode", "6",
            "-Xlinker", "-install_name",
            "-Xlinker", "/System/Library/Frameworks/\(moduleName).framework/\(moduleName)",
            "-Xlinker", "-not_for_dyld_shared_cache"
        ]
        try? emitLib.run()
        emitLib.waitUntilExit()
    }

}
