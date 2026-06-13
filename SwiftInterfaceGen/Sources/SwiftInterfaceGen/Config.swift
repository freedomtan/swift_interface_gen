import Foundation

struct GeneratorConfig: Codable {
    var systemModules: [String] = []
    var fundamentalShims: [String] = []
    var missingNestedTypes: [String] = []
    var protocolShims: [String] = []
    var forceGenerics: [String: Int] = [:]
    var simpleReplacements: [String: String] = [:]
}

class ConfigManager {
    static var shared = GeneratorConfig()
    
    static func load(from path: String?) {
        guard let path = path, let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return
        }
        if let config = try? JSONDecoder().decode(GeneratorConfig.self, from: data) {
            shared = config
        }
    }
}