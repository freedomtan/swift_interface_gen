import Foundation

struct GeneratorConfig {
    var systemModules: [String] = ["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC", "CoreVideo", "CoreMedia", "IOSurface", "__C", "Synchronization"]
    var fundamentalShims: [String] = []
    var missingNestedTypes: [String] = []
    var protocolShims: [String] = []
    var forceGenerics: [String: Int] = [:]
    var simpleReplacements: [String: String] = [:]
}

class ConfigManager {
    static var shared = GeneratorConfig()
    
    static func load(from path: String?) {
        // No-op to preserve command-line compatibility without config.json
    }
}