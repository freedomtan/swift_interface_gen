import Foundation

struct GeneratorConfig {}

class ConfigManager {
    static var shared = GeneratorConfig()
    
    static var sdkRoot: String = {
        if let envSdk = ProcessInfo.processInfo.environment["SDKROOT"] {
            return envSdk
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["--show-sdk-path"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        return trimmed
                    }
                }
            }
        } catch {}
        return "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
    }()
    
    static func load(from path: String?) {
        // No-op to preserve command-line compatibility without config.json
    }
}