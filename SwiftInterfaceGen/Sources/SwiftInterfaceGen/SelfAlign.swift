import Foundation

extension SwiftInterfaceGen {
    static func selfAlignInterface(code: String, parser: Parser, tbdPath: String) -> String {
        let tempDir = NSTemporaryDirectory() + "self_align_\(UUID().uuidString)"
        guard (try? FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: true)) != nil else {
            fputs("Error creating self-align temp dir at \(tempDir)\n", stderr)
            return code
        }
        let keepTempDir = ProcessInfo.processInfo.environment["SELF_ALIGN_KEEP_TEMP"] != nil
        defer { if !keepTempDir { try? FileManager.default.removeItem(atPath: tempDir) } }
        if keepTempDir { fputs("Self-alignment: keeping temp dir \(tempDir)\n", stderr) }

        let tempInterfacePath = tempDir + "/_self_align_interface.swift"
        let tempDylibPath = tempDir + "/_self_align_dylib.dylib"

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
        
        // Mirror verify_public.py's own bridge-header/bridge-object handling (Cat F): a
        // hand-written ObjC bridge header/implementation, if present alongside the generator
        // in the current working directory, named "<Module>Interface_bridge.h"/".m".
        let bridgeH = "\(parser.defaultModule)Interface_bridge.h"
        let bridgeM = "\(parser.defaultModule)Interface_bridge.m"
        var extraCompileFlags: [String] = []
        var extraObjs: [String] = []
        if FileManager.default.fileExists(atPath: bridgeH) {
            extraCompileFlags = ["-import-objc-header", bridgeH]
            if FileManager.default.fileExists(atPath: bridgeM) {
                let bridgeO = tempDir + "/bridge.o"
                let clangProcess = Process()
                clangProcess.executableURL = URL(fileURLWithPath: "/usr/bin/clang")
                clangProcess.arguments = ["-c", bridgeM, "-o", bridgeO, "-isysroot", sdkRoot, "-fobjc-arc"]
                do {
                    try clangProcess.run()
                    clangProcess.waitUntilExit()
                    if clangProcess.terminationStatus == 0 {
                        extraObjs.append(bridgeO)
                    } else {
                        fputs("Warning: Self-alignment bridge.m compile failed, returning unaligned code.\n", stderr)
                        return code
                    }
                } catch {
                    fputs("Error compiling self-align bridge.m: \(error)\n", stderr)
                    return code
                }
            }
        }

        // Compile temp dylib, matching verify_public.py's real first-pass compile flags
        // (-undefined dynamic_lookup + -install_name are required for many frameworks to link
        // cleanly against symbols only resolvable at real-dylib load time).
        let installName = "/System/Library/Frameworks/\(parser.defaultModule).framework/Versions/A/\(parser.defaultModule)"
        // Isolated per-call frameworks dir -- see emitEmptyStubFramework's comment for why this
        // must never be the persistent repo-root LocalFrameworks/.
        let selfAlignFrameworksDir = tempDir + "/LocalFrameworks"
        try? FileManager.default.createDirectory(atPath: selfAlignFrameworksDir, withIntermediateDirectories: true)
        var alreadyStubbedModules = Set<String>()
        var compileSucceeded = false
        for attempt in 1...5 {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
            process.arguments = [
                "-emit-library",
                "-o", tempDylibPath,
                tempInterfacePath,
                "-enable-library-evolution",
                "-module-name", parser.defaultModule,
                "-F", selfAlignFrameworksDir,
                "-sdk", sdkRoot,
                "-language-mode", "6",
                "-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup",
                "-Xlinker", "-not_for_dyld_shared_cache",
                "-Xlinker", "-install_name", "-Xlinker", installName,
                "-enable-experimental-feature", "NonescapableTypes",
                "-enable-experimental-feature", "Lifetimes"
            ] + extraCompileFlags + extraObjs

            let errPipe = Pipe()
            process.standardError = errPipe
            if ConfigManager.verbose { fputs("Self-alignment: compiling (attempt \(attempt)) with \(process.arguments ?? [])\n", stderr) }
            do {
                try process.run()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                if process.terminationStatus == 0 {
                    compileSucceeded = true
                    break
                }
                let errText = String(data: errData, encoding: .utf8) ?? ""
                // A framework the generated interface imports (a private SDK dependency, e.g.
                // Speech's "AudioAnalytics" or HealthKit's "Coherence") may not yet exist under
                // -F LocalFrameworks -- synthesize a trivial empty-stub .framework for it (same
                // idea as verify_public.py's own emit_empty_stub()) so `import X` resolves, then
                // retry. Caps at 5 attempts so a genuinely unfixable compile error still falls
                // back to returning the code unaligned instead of looping forever.
                let missingModules = extractMissingModules(errText).subtracting(alreadyStubbedModules)
                if missingModules.isEmpty {
                    fputs("Warning: Self-alignment compilation failed, returning unaligned code.\n\(errText)\n", stderr)
                    return code
                }
                for m in missingModules {
                    emitEmptyStubFramework(moduleName: m, sdkRoot: sdkRoot, frameworksDir: selfAlignFrameworksDir)
                }
                alreadyStubbedModules.formUnion(missingModules)
            } catch {
                fputs("Error compiling temp dylib: \(error)\n", stderr)
                return code
            }
        }
        if !compileSucceeded {
            fputs("Warning: Self-alignment compilation still failing after stubbing dependencies, returning unaligned code.\n", stderr)
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
        
        let tbdContent = (try? String(contentsOfFile: tbdPath, encoding: .utf8)) ?? ""
        let expectedSymbols = filteredExportSymbols(currentModule: parser.defaultModule, tbdContent: tbdContent, parser: parser)

        var missing = [String]()
        for s in expectedSymbols {
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
        
        return alignedCode
    }
}
