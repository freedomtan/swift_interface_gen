import Foundation

@main
struct SwiftInterfaceGen {
    static func main() {
        let args = CommandLine.arguments
        if args.count < 2 {
            print("Usage: swift-interface-gen <path_to_tbd>")
            return
        }

        let tbdPath = args[1]
        guard let content = try? String(contentsOfFile: tbdPath, encoding: .utf8) else {
            print("Error: Could not read TBD file at \(tbdPath)")
            return
        }

        let currentModule = (tbdPath as NSString).lastPathComponent.replacingOccurrences(of: ".tbd", with: "")
        let symbols = extractSymbols(from: content)
        
        let parser = Parser()
        
        let reexportedLibraries = extractReexportedLibraries(from: content)
        for lib in reexportedLibraries {
            let libPath = resolveLibraryPath(lib)
            if let libContent = try? String(contentsOfFile: libPath, encoding: .utf8) {
                print("Discovered dependency: \(lib) -> \(libPath)", to: &Self.standardError)
                let libSymbols = extractSymbols(from: libContent)
                let libModule = (lib as NSString).lastPathComponent.replacingOccurrences(of: ".framework", with: "")
                processSymbols(libSymbols, parser: parser, module: libModule)
            }
        }
        
        processSymbols(symbols, parser: parser, module: currentModule)

        let allCode = parser.generateAll()
        print(postProcess(allCode))
    }

    static func processSymbols(_ symbols: [String], parser: Parser, module: String) {
        let count = symbols.count
        print("Found \(count) new symbols in \(module). Demangling...", to: &Self.standardError)
        for (_, mangled) in symbols.enumerated() {
            if let demangled = demangle(symbol: mangled) {
                parser.parse(mangled: mangled, demangled: demangled, currentModule: module)
                
                let knownFrameworks = ["ModelCatalog", "GenerativeFunctionsFoundation", "GenerativeFunctions"]
                for fw in knownFrameworks {
                    if demangled.contains(fw + ".") && fw != module {
                        if parser.modules[fw] == nil {
                             let fwPath = "/Library/Developer/CommandLineTools/SDKs/MacOSX27.0.sdk/System/Library/PrivateFrameworks/\(fw).framework/\(fw).tbd"
                             if let fwContent = try? String(contentsOfFile: fwPath, encoding: .utf8) {
                                 print("Smart-discovered dependency: \(fw) -> \(fwPath)", to: &Self.standardError)
                                 let fwSymbols = extractSymbols(from: fwContent)
                                 processSymbols(fwSymbols, parser: parser, module: fw)
                             }
                        }
                    }
                }
            }
        }
    }

    static func extractSymbols(from tbd: String) -> [String] {
        let pattern = "(_\\$s[a-zA-Z0-9_$]+|_OBJC_CLASS_\\$_[a-zA-Z0-9_$]+)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsRange = NSRange(tbd.startIndex..<tbd.endIndex, in: tbd)
        let matches = regex.matches(in: tbd, options: [], range: nsRange)
        
        var symbols = Set<String>()
        for match in matches {
            if let range = Range(match.range, in: tbd) {
                symbols.insert(String(tbd[range]))
            }
        }
        return Array(symbols).sorted()
    }

    static func extractReexportedLibraries(from tbd: String) -> [String] {
        let pattern = "reexported-libraries:\\s*\\[([^\\]]+)\\]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsRange = NSRange(tbd.startIndex..<tbd.endIndex, in: tbd)
        
        var libs = [String]()
        if let match = regex.firstMatch(in: tbd, options: [], range: nsRange) {
            if let range = Range(match.range(at: 1), in: tbd) {
                let list = String(tbd[range])
                libs = list.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "") }
            }
        }
        return libs
    }

    static func resolveLibraryPath(_ lib: String) -> String {
        let sdkRoot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
        if lib.starts(with: "/System/Library/PrivateFrameworks") {
            let parts = lib.components(separatedBy: "/")
            if let frameworkName = parts.first(where: { $0.hasSuffix(".framework") }) {
                let name = frameworkName.replacingOccurrences(of: ".framework", with: "")
                return "\(sdkRoot)/System/Library/PrivateFrameworks/\(name).framework/\(name).tbd"
            }
        }
        return "\(sdkRoot)\(lib).tbd"
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

    static func postProcess(_ code: String) -> String {
        var c = code
        // Remove redundant module prefixes, but be careful not to create self-referencing typealiases
        let prefixes = ["ModelCatalog.", "GenerativeModelsFoundation.", "GenerativeModels.", "TokenGeneration.", "TokenGenerationCore.", "PromptKit.", "GenerativeFunctionsFoundation.", "GenerativeFunctions.", "ObjectiveC."]
        for p in prefixes {
            c = c.replacingOccurrences(of: p, with: "")
        }
        
        // Handle Foundation and Swift more carefully to avoid "typealias NSCoder = NSCoder"
        c = c.replacingOccurrences(of: ": Foundation.", with: ": ___FOUNDATION___")
        c = c.replacingOccurrences(of: "-> Foundation.", with: "-> ___FOUNDATION___")
        c = c.replacingOccurrences(of: "Array<Foundation.", with: "Array<___FOUNDATION___")
        c = c.replacingOccurrences(of: "Optional<Foundation.", with: "Optional<___FOUNDATION___")
        c = c.replacingOccurrences(of: "= Foundation.", with: "= ___FOUNDATION___")

        c = c.replacingOccurrences(of: "Foundation.", with: "")
        c = c.replacingOccurrences(of: "___FOUNDATION___", with: "Foundation.")
        
        c = c.replacingOccurrences(of: "Swift.", with: "")
        
        // Fix Optional and other generic types without parameters
        c = c.replacingOccurrences(of: "(Optional, ", with: "(Optional<Any>, ")
        c = c.replacingOccurrences(of: "(Optional)", with: "(Optional<Any>)")
        c = c.replacingOccurrences(of: "Optional,", with: "Optional<Any>,")
        c = c.replacingOccurrences(of: "Optional>", with: "Optional<Any>>")
        
        // Handle nested Criteria generic issue
        let criteriaPattern = "\\b([A-Z][a-zA-Z0-9_\\.]*Criteria)([^<a-zA-Z0-9_])"
        let criteriaRegex = try! NSRegularExpression(pattern: criteriaPattern, options: [])
        c = criteriaRegex.stringByReplacingMatches(in: c, options: [], range: NSRange(c.startIndex..., in: c), withTemplate: "$1<Any>$2")
        
        // Fix unnamed parameters
        c = c.replacingOccurrences(of: "(_: ", with: "(arg1: ")
        c = c.replacingOccurrences(of: ", _: ", with: ", arg2: ")
        
        // Ensure literal newlines are handled (hack for the python shim)
        c = c.replacingOccurrences(of: "\n", with: "\\n")

        // Final cleanup of redundant escapes
        let lines = c.components(separatedBy: "\\n")
        var newLines = [String]()
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            newLines.append(line)
        }
        c = newLines.joined(separator: "\\n")
        
        return c
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
