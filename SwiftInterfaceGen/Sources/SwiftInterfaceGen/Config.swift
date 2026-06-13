import Foundation

struct GeneratorConfig: Codable {
    var systemModules: [String] = ["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC", "__C"]
    var fundamentalShims: [String] = [
        "NSCoder", "NSZone", "NSXPCConnection", "CoherenceToken", "UAFAssetSetConsistencyToken",
        "PlaceholderA1", "PlaceholderB1", "A", "B", "A1", "B1", "C1", "D1", "A2", "IOSurface",
        "ResourceBundle", "ResourceBundleIdentifier", "CatalogResourceResult", "CatalogResource",
        "CatalogAsset", "AppleIntelligenceReporting", "ModelManagerServices", "GenerativeFunctionsInstrumentation",
        "CMTime", "UUID", "CVBufferRef", "XPC", "Network", "FeatureFlags", "ResourceMetadata",
        "UAFSubscriptionDownloadStatus", "GenericA", "GenericB", "GenericC", "GenericD",
        "GMAvailabilityStatus", "NSUserDefaults", "OS_os_activity", "os_activity_flag_t"
    ]
    var missingNestedTypes: [String] = [
        "Module", "Options", "SharedBytecode", "TargetSpecification", "BinaryGenerator", 
        "CompiledBytecodeConfig", "BreakpointLocation", "Buffer", "MLIRDumpConfiguration", 
        "ResourceBlobManager", "CompilationContext", "TargetInformation", "Profiler",
        "AppleIntelligenceError", "AppleIntelligenceErrorCategory", "FeatureFlagsKey"
    ]
    var protocolShims: [String] = [
        "ChatLanguageModelResponse", "ChatLanguageModelProviding", "ChatLanguageModelProvidingStreamable",
        "ChatMessageResponse", "CompletionResponse", "CompletionLanguageModelProviding",
        "CompletionLanguageModelResponse", "CompletionLanguageModelProvidingStreamable"
    ]
    var forceGenerics: [String: Int] = [
        "Tensor": 1,
        "TensorRequirements": 1,
        "BFloat16": 1,
        "CatalogAsset": 2
    ]
    var simpleReplacements: [String: String] = [
        "TestCatalog.Resource.ResourceMetadata": "ResourceMetadata",
        "Catalog.Resource.ResourceMetadata": "ResourceMetadata"
    ]
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