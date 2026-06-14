import CoreFoundation
import CoreMedia
import CoreVideo
import Dispatch
import Foundation
import IOSurface
import ObjectiveC
import Swift
import UniformTypeIdentifiers
import os
public struct AJAXConfiguration: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public init(url: URL, modelName: String, endPromptToken: String) {}
    public var endPromptToken: String { get { return "" } }
    public var modelName: String { get { return "" } }
    public var url: URL { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public class AcquireCoherenceTokenResponse {
    public init() {}
    public init(tokens: Dictionary<String, UAFAssetSetConsistencyToken>) {}
    public init(coder: NSCoder) {}
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func encode(with: NSCoder) -> () {}
    public static var tokenKey: String { get { return "" } }
}
public protocol AdaptableLLMModel {
}
public protocol AppleDeviceTracking {
}
public struct AppleDeviceTrackingAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleDeviceTrackingAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleDeviceTrackingBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AppleDeviceTrackingBase, arg2: AppleDeviceTrackingBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AppleEmbeddingModel {
}
public struct AppleEmbeddingModelAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleEmbeddingModelAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleEmbeddingModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: AppleEmbeddingModelBase, arg2: AppleEmbeddingModelBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AppleEmbeddingModelEncoder {
}
public struct AppleEmbeddingModelEncoderAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleEmbeddingModelEncoderAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleEmbeddingModelEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AppleEmbeddingModelEncoderBase, arg2: AppleEmbeddingModelEncoderBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AppleEmbeddingModelTokenizer {
}
public struct AppleEmbeddingModelTokenizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleEmbeddingModelTokenizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AppleEmbeddingModelTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AppleEmbeddingModelTokenizerBase, arg2: AppleEmbeddingModelTokenizerBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public enum Arguments: Hashable, Sendable {
    public enum IsIFPEnabled: Hashable, Sendable {
        public enum Value: Hashable, Sendable {
            case _mock
        }
        case _mock
        public static var argument: Arguments.VariantResolverArgument { get { fatalError() } }
    }
    public enum Language: Hashable, Sendable {
        public enum Value: Hashable, Sendable {
            case _mock
        }
        case _mock
        public static var argument: Arguments.VariantResolverArgument { get { fatalError() } }
    }
    public enum UseDefault: Hashable, Sendable {
        public enum Value: Hashable, Sendable {
            case _mock
        }
        case _mock
        public static var argument: Arguments.VariantResolverArgument { get { fatalError() } }
    }
    public struct VariantResolverArgument: Codable, Hashable, Sendable {
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public var excludeFromUAFUsageAliases: Bool { get { return false } }
        public var validValues: Array<String> { get { return [] } }
        public func hash(into: inout Hasher) -> () {}
        public var hashValue: Int { get { return 0 } }
        public var internallyResolved: Bool { get { return false } }
        public var name: String { get { return "" } }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
    }
    case _mock
    public static func argument(named: String) -> Optional<Arguments.VariantResolverArgument> { return nil }
    public static var allArguments: Array<Arguments.VariantResolverArgument> { get { return [] } }
}
public protocol AssetBackedAppleDeviceTracking {
}
public struct AssetBackedAppleDeviceTrackingBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedAppleDeviceTrackingBase, arg2: AssetBackedAppleDeviceTrackingBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedAppleEmbeddingModel {
}
public struct AssetBackedAppleEmbeddingModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedAppleEmbeddingModelBase, arg2: AssetBackedAppleEmbeddingModelBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedAppleEmbeddingModelEncoder {
}
public struct AssetBackedAppleEmbeddingModelEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedAppleEmbeddingModelEncoderBase, arg2: AssetBackedAppleEmbeddingModelEncoderBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedAppleEmbeddingModelTokenizer {
}
public struct AssetBackedAppleEmbeddingModelTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AssetBackedAppleEmbeddingModelTokenizerBase, arg2: AssetBackedAppleEmbeddingModelTokenizerBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedBloomFilterTokenInputDenyList {
}
public struct AssetBackedBloomFilterTokenInputDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedBloomFilterTokenInputDenyListBase, arg2: AssetBackedBloomFilterTokenInputDenyListBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedCoreMLRankingModelBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func rankingModel(arg1: Optional<any AssetBackedRankingModel>) -> Builder { fatalError() }
        public var rankingModel: Optional<any AssetBackedRankingModel> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func build() throws -> AssetBackedCoreMLRankingModelBundle { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedCoreMLRankingModelBundle.Builder) throws -> ()) throws {}
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rankingModel: any AssetBackedRankingModel { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public func encode(to: Encoder) throws -> () {}
    public static func ==(arg1: AssetBackedCoreMLRankingModelBundle, arg2: AssetBackedCoreMLRankingModelBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var id: ResourceBundleIdentifier<AssetBackedCoreMLRankingModelBundle> { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
}
public struct AssetBackedDefaultOverridesBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var defaultDenyList: Optional<any AssetBackedModelConfigurationReplacement> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func defaultDenyList(arg1: Optional<any AssetBackedModelConfigurationReplacement>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedDefaultOverridesBundle { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (AssetBackedDefaultOverridesBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func encode(to: Encoder) throws -> () {}
    public var defaultDenyList: any AssetBackedModelConfigurationReplacement { get { fatalError() } }
    public static func ==(arg1: AssetBackedDefaultOverridesBundle, arg2: AssetBackedDefaultOverridesBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedDefaultOverridesBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
}
public protocol AssetBackedDiffusionAdapter {
}
public struct AssetBackedDiffusionAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedDiffusionAdapterBase, arg2: AssetBackedDiffusionAdapterBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedDiffusionBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func baseModel(arg1: Optional<any AssetBackedDiffusionModel>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedDiffusionBundle { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var adapter: Optional<any AssetBackedDiffusionAdapter> { get { return nil } set {} }
        public func adapter(arg1: Optional<any AssetBackedDiffusionAdapter>) -> Builder { fatalError() }
        public var baseModel: Optional<any AssetBackedDiffusionModel> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedDiffusionBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public static func ==(arg1: AssetBackedDiffusionBundle, arg2: AssetBackedDiffusionBundle) -> Bool { return false }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
    public var adapter: Optional<any AssetBackedDiffusionAdapter> { get { return nil } }
    public var baseModel: any AssetBackedDiffusionModel { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var trialNamespace: Optional<String> { get { return nil } }
}
public protocol AssetBackedDiffusionModel {
}
public struct AssetBackedDiffusionModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedDiffusionModelBase, arg2: AssetBackedDiffusionModelBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedDisabledUseCaseList {
}
public struct AssetBackedDisabledUseCaseListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedDisabledUseCaseListBase, arg2: AssetBackedDisabledUseCaseListBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedEmbeddingDenyList {
}
public struct AssetBackedEmbeddingDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedEmbeddingDenyListBase, arg2: AssetBackedEmbeddingDenyListBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedEmbeddingPreprocessor {
}
public struct AssetBackedEmbeddingPreprocessorBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: AssetBackedEmbeddingPreprocessorBase, arg2: AssetBackedEmbeddingPreprocessorBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedGenerativeShortcutsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var baseModel: Optional<any AssetBackedGenerativeShortcutsModel> { get { return nil } set {} }
        public func build() throws -> AssetBackedGenerativeShortcutsBundle { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func baseModel(arg1: Optional<any AssetBackedGenerativeShortcutsModel>) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedGenerativeShortcutsBundle.Builder) throws -> ()) throws {}
    public var id: ResourceBundleIdentifier<AssetBackedGenerativeShortcutsBundle> { get { fatalError() } }
    public static func ==(arg1: AssetBackedGenerativeShortcutsBundle, arg2: AssetBackedGenerativeShortcutsBundle) -> Bool { return false }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var baseModel: any AssetBackedGenerativeShortcutsModel { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var rawID: String { get { return "" } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
}
public protocol AssetBackedGenerativeShortcutsModel {
}
public struct AssetBackedGenerativeShortcutsModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedGenerativeShortcutsModelBase, arg2: AssetBackedGenerativeShortcutsModelBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedHandwritingSynthesizer {
}
public struct AssetBackedHandwritingSynthesizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AssetBackedHandwritingSynthesizerBase, arg2: AssetBackedHandwritingSynthesizerBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedImageCuratedPrompts {
}
public struct AssetBackedImageCuratedPromptsBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedImageCuratedPromptsBase, arg2: AssetBackedImageCuratedPromptsBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedImageFilter {
}
public struct AssetBackedImageFilterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: AssetBackedImageFilterBase, arg2: AssetBackedImageFilterBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedImageMagicCleanUp {
}
public struct AssetBackedImageMagicCleanUpBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedImageMagicCleanUpBase, arg2: AssetBackedImageMagicCleanUpBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedImageScaler {
}
public struct AssetBackedImageScalerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedImageScalerBase, arg2: AssetBackedImageScalerBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedImageSpatialPhotosRelive {
}
public struct AssetBackedImageSpatialPhotosReliveBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedImageSpatialPhotosReliveBase, arg2: AssetBackedImageSpatialPhotosReliveBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedImageSpatialPhotosReliveBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var fovestimator: Optional<any AssetBackedImageSpatialPhotosRelive> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func location(arg1: Optional<any AssetBackedImageSpatialPhotosRelive>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func fovestimator(arg1: Optional<any AssetBackedImageSpatialPhotosRelive>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var location: Optional<any AssetBackedImageSpatialPhotosRelive> { get { return nil } set {} }
        public func build() throws -> AssetBackedImageSpatialPhotosReliveBundle { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedImageSpatialPhotosReliveBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func hash(into: inout Hasher) -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var fovestimator: any AssetBackedImageSpatialPhotosRelive { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedImageSpatialPhotosReliveBundle, arg2: AssetBackedImageSpatialPhotosReliveBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var id: ResourceBundleIdentifier<AssetBackedImageSpatialPhotosReliveBundle> { get { fatalError() } }
    public var location: any AssetBackedImageSpatialPhotosRelive { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
}
public protocol AssetBackedImageTokenizer {
}
public protocol AssetBackedImageTokenizerAdapter {
}
public struct AssetBackedImageTokenizerAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AssetBackedImageTokenizerAdapterBase, arg2: AssetBackedImageTokenizerAdapterBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedImageTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedImageTokenizerBase, arg2: AssetBackedImageTokenizerBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedLLMAdapter {
}
public struct AssetBackedLLMAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedLLMAdapterBase, arg2: AssetBackedLLMAdapterBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var llmModel: AssetBackedLLMModelBase { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedLLMAdapterMetadataOverride {
}
public struct AssetBackedLLMAdapterMetadataOverrideBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedLLMAdapterMetadataOverrideBase, arg2: AssetBackedLLMAdapterMetadataOverrideBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedLLMBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func imageTokenizer(arg1: Optional<any AssetBackedImageTokenizer>) -> Builder { fatalError() }
        public func baseModel(arg1: Optional<any AssetBackedLLMModel>) -> Builder { fatalError() }
        public func tokenizer(arg1: Optional<any AssetBackedTokenizer>) -> Builder { fatalError() }
        public var adapter: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public var baseModel: Optional<any AssetBackedLLMModel> { get { return nil } set {} }
        public var draftModel: Optional<any AssetBackedLLMDraftModel> { get { return nil } set {} }
        public var embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func draftModel(arg1: Optional<any AssetBackedLLMDraftModel>) -> Builder { fatalError() }
        public var imageTokenizer: Optional<any AssetBackedImageTokenizer> { get { return nil } set {} }
        public var speechTokenizer: Optional<any AssetBackedSpeechTokenizer> { get { return nil } set {} }
        public func embeddingPreprocessor(arg1: Optional<any AssetBackedEmbeddingPreprocessor>) -> Builder { fatalError() }
        public func adapter(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func imageTokenizerAdapter(arg1: Optional<any AssetBackedImageTokenizerAdapter>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var speechDetokenizer: Optional<any AssetBackedSpeechDetokenizer> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride> { get { return nil } set {} }
        public func speechTokenizer(arg1: Optional<any AssetBackedSpeechTokenizer>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedLLMBundle { fatalError() }
        public var imageTokenizerAdapter: Optional<any AssetBackedImageTokenizerAdapter> { get { return nil } set {} }
        public func speechDetokenizer(arg1: Optional<any AssetBackedSpeechDetokenizer>) -> Builder { fatalError() }
        public var tokenizer: Optional<any AssetBackedTokenizer> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func adapterMetadataOverride(arg1: Optional<any AssetBackedLLMAdapterMetadataOverride>) -> Builder { fatalError() }
    }
    public init(id: ResourceBundleIdentifier<LLMBundle>, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<ImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(configurationIdentifier: String, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, serverWorkflowEnabled: Bool) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(id: ResourceBundleIdentifier<AssetBackedLLMBundle>, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, serverWorkflowEnabled: Bool) {}
    public init(from: Decoder) throws {}
    public init(id: ResourceBundleIdentifier<AssetBackedLLMBundle>, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>) {}
    public init(configurationIdentifier: String, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>) {}
    public init(configurationIdentifier: String, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>) {}
    public init(configurationIdentifier: String, build: (AssetBackedLLMBundle.Builder) throws -> ()) throws {}
    public init(id: ResourceBundleIdentifier<AssetBackedLLMBundle>, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<any AssetBackedImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(id: ResourceBundleIdentifier<LLMBundle>, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(id: ResourceBundleIdentifier<LLMBundle>, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool) {}
    public init(id: ResourceBundleIdentifier<AssetBackedLLMBundle>, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<any AssetBackedImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<ImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(configurationIdentifier: String, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<any AssetBackedImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(configurationIdentifier: String, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<any AssetBackedImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(id: ResourceBundleIdentifier<AssetBackedLLMBundle>, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(id: ResourceBundleIdentifier<LLMBundle>, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<ImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(id: ResourceBundleIdentifier<AssetBackedLLMBundle>, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>) {}
    public init(id: ResourceBundleIdentifier<AssetBackedLLMBundle>, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool) {}
    public init(configurationIdentifier: String, tokenizer: any AssetBackedTokenizer, baseModel: any AssetBackedLLMModel, adapter: Optional<any AssetBackedLLMAdapter>, draftModel: Optional<any AssetBackedLLMDraftModel>, imageTokenizer: Optional<any AssetBackedImageTokenizer>, embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor>, adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, imageTokenizerAdapter: Optional<ImageTokenizerAdapter>, serverWorkflowEnabled: Bool, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(id: ResourceBundleIdentifier<LLMBundle>, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>) {}
    public var adapter: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var imageTokenizerAdapter: Optional<any AssetBackedImageTokenizerAdapter> { get { return nil } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var tokenizer: any AssetBackedTokenizer { get { fatalError() } }
    public static func ==(arg1: AssetBackedLLMBundle, arg2: AssetBackedLLMBundle) -> Bool { return false }
    public var embeddingPreprocessor: Optional<any AssetBackedEmbeddingPreprocessor> { get { return nil } }
    public var speechDetokenizer: Optional<any AssetBackedSpeechDetokenizer> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var baseModel: any AssetBackedLLMModel { get { fatalError() } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var draftModel: Optional<any AssetBackedLLMDraftModel> { get { return nil } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
    public var imageTokenizer: Optional<any AssetBackedImageTokenizer> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var adapterMetadataOverride: Optional<any AssetBackedLLMAdapterMetadataOverride> { get { return nil } }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var rawID: String { get { return "" } }
    public var speechTokenizer: Optional<any AssetBackedSpeechTokenizer> { get { return nil } }
    public var trialNamespace: Optional<String> { get { return nil } }
}
public struct AssetBackedLLMCompileDraftBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var draftModel: Optional<any AssetBackedLLMDraftModel> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func draftModel(arg1: Optional<any AssetBackedLLMDraftModel>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedLLMCompileDraftBundle { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (AssetBackedLLMCompileDraftBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public var draftModel: any AssetBackedLLMDraftModel { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var id: ResourceBundleIdentifier<AssetBackedLLMCompileDraftBundle> { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedLLMCompileDraftBundle, arg2: AssetBackedLLMCompileDraftBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
}
public struct AssetBackedLLMDraftBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var draftModel: Optional<any AssetBackedLLMDraftModel> { get { return nil } set {} }
        public var tokenizer: Optional<any AssetBackedTokenizer> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func tokenizer(arg1: Optional<any AssetBackedTokenizer>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func build() throws -> AssetBackedLLMDraftBundle { fatalError() }
        public func draftModel(arg1: Optional<any AssetBackedLLMDraftModel>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (AssetBackedLLMDraftBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedLLMDraftBundle, arg2: AssetBackedLLMDraftBundle) -> Bool { return false }
    public var id: ResourceBundleIdentifier<AssetBackedLLMDraftBundle> { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func encode(to: Encoder) throws -> () {}
    public var draftModel: any AssetBackedLLMDraftModel { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var rawID: String { get { return "" } }
    public var tokenizer: any AssetBackedTokenizer { get { fatalError() } }
}
public protocol AssetBackedLLMDraftModel {
}
public struct AssetBackedLLMDraftModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedLLMDraftModelBase, arg2: AssetBackedLLMDraftModelBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedLLMModel {
}
public struct AssetBackedLLMModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedLLMModelBase, arg2: AssetBackedLLMModelBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var tokenizer: AssetBackedTokenizerBase { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedModelConfigurationReplacement {
}
public struct AssetBackedModelConfigurationReplacementBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedModelConfigurationReplacementBase, arg2: AssetBackedModelConfigurationReplacementBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedMotion {
}
public protocol AssetBackedMotionAdapter {
}
public struct AssetBackedMotionAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedMotionAdapterBase, arg2: AssetBackedMotionAdapterBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedMotionBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AssetBackedMotionBase, arg2: AssetBackedMotionBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedMotionBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func adapter(arg1: Optional<any AssetBackedMotionAdapter>) -> Builder { fatalError() }
        public func baseModel(arg1: Optional<any AssetBackedMotion>) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func build() throws -> AssetBackedMotionBundle { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var adapter: Optional<any AssetBackedMotionAdapter> { get { return nil } set {} }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var baseModel: Optional<any AssetBackedMotion> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (AssetBackedMotionBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var id: ResourceBundleIdentifier<AssetBackedMotionBundle> { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedMotionBundle, arg2: AssetBackedMotionBundle) -> Bool { return false }
    public var adapter: Optional<any AssetBackedMotionAdapter> { get { return nil } }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var baseModel: any AssetBackedMotion { get { fatalError() } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
}
public protocol AssetBackedPCCGenericInference {
}
public struct AssetBackedPCCGenericInferenceBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedPCCGenericInferenceBase, arg2: AssetBackedPCCGenericInferenceBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedPCCGenericInferenceBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func build() throws -> AssetBackedPCCGenericInferenceBundle { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var pccGenericInference: Optional<any AssetBackedPCCGenericInference> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func pccGenericInference(arg1: Optional<any AssetBackedPCCGenericInference>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (AssetBackedPCCGenericInferenceBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedPCCGenericInferenceBundle> { get { fatalError() } }
    public var pccGenericInference: any AssetBackedPCCGenericInference { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedPCCGenericInferenceBundle, arg2: AssetBackedPCCGenericInferenceBundle) -> Bool { return false }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public func hash(into: inout Hasher) -> () {}
}
public protocol AssetBackedPromptAllowList {
}
public struct AssetBackedPromptAllowListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: AssetBackedPromptAllowListBase, arg2: AssetBackedPromptAllowListBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedRankingModel {
}
public struct AssetBackedRankingModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedRankingModelBase, arg2: AssetBackedRankingModelBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedResource<A> {
    associatedtype A
    associatedtype CatalogAssetType
    var subscription: AssetSubscription { get }
    func fetchLockedAsset(with: CoherentAssetLock) throws -> Self.CatalogAssetType
    func fetchLockedAsset(with: AssetLock) throws -> Self.CatalogAssetType
    func fetchAsset() throws -> Self.CatalogAssetType
    func fetchLockedAsset(with: CoherentAssetLock, options: FetchAssetOptions) throws -> Self.CatalogAssetType
    func mapLockedAsset(with: CoherentAssetLock) async throws -> ()
}
public protocol AssetBackedResourceBundle {
    var assetBackedResources: Array<any AssetBackedResource> { get }
}
public protocol AssetBackedSafetyOutputConfiguration {
}
public struct AssetBackedSafetyOutputConfigurationBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedSafetyOutputConfigurationBase, arg2: AssetBackedSafetyOutputConfigurationBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedSafetyOutputConfigurationBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func configuration(arg1: Optional<any AssetBackedSafetyOutputConfiguration>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var configuration: Optional<any AssetBackedSafetyOutputConfiguration> { get { return nil } set {} }
        public func build() throws -> AssetBackedSafetyOutputConfigurationBundle { fatalError() }
    }
    public init(configurationIdentifier: String, build: (AssetBackedSafetyOutputConfigurationBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public var configurationIdentifier: String { get { return "" } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public static func ==(arg1: AssetBackedSafetyOutputConfigurationBundle, arg2: AssetBackedSafetyOutputConfigurationBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configuration: any AssetBackedSafetyOutputConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedSafetyOutputConfigurationBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var rawID: String { get { return "" } }
}
public struct AssetBackedSanitizerBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func build() throws -> AssetBackedSanitizerBundle { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedSanitizerBundle.Builder) throws -> ()) throws {}
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public static func ==(arg1: AssetBackedSanitizerBundle, arg2: AssetBackedSanitizerBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedSanitizerBundle> { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
}
public protocol AssetBackedSecureAnalytics {
}
public struct AssetBackedSecureAnalyticsBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AssetBackedSecureAnalyticsBase, arg2: AssetBackedSecureAnalyticsBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedSecureAnalyticsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func baseModel(arg1: Optional<any AssetBackedSecureAnalytics>) -> Builder { fatalError() }
        public var baseModel: Optional<any AssetBackedSecureAnalytics> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func build() throws -> AssetBackedSecureAnalyticsBundle { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
    }
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedSecureAnalyticsBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedSecureAnalyticsBundle, arg2: AssetBackedSecureAnalyticsBundle) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var baseModel: any AssetBackedSecureAnalytics { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedSecureAnalyticsBundle> { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var serverWorkflowEnabled: Bool { get { return false } }
}
public protocol AssetBackedServerConfiguration {
}
public struct AssetBackedServerConfigurationBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedServerConfigurationBase, arg2: AssetBackedServerConfigurationBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionANFREncoder {
}
public struct AssetBackedServerDiffusionANFREncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: AssetBackedServerDiffusionANFREncoderBase, arg2: AssetBackedServerDiffusionANFREncoderBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionAdapter {
}
public struct AssetBackedServerDiffusionAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedServerDiffusionAdapterBase, arg2: AssetBackedServerDiffusionAdapterBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionAlphaMaskDecoder {
}
public struct AssetBackedServerDiffusionAlphaMaskDecoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedServerDiffusionAlphaMaskDecoderBase, arg2: AssetBackedServerDiffusionAlphaMaskDecoderBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionAutoEncoder {
}
public struct AssetBackedServerDiffusionAutoEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedServerDiffusionAutoEncoderBase, arg2: AssetBackedServerDiffusionAutoEncoderBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedServerDiffusionBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func textencoder(arg1: Optional<any AssetBackedServerDiffusionTextEncoder>) -> Builder { fatalError() }
        public var safetyAdapterMiscSafety: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public var synthid: Optional<any AssetBackedServerDiffusionSynthID> { get { return nil } set {} }
        public func vaeEncoder(arg1: Optional<any AssetBackedServerDiffusionVAEEncoder>) -> Builder { fatalError() }
        public func safetyBaseModel(arg1: Optional<any AssetBackedLLMModel>) -> Builder { fatalError() }
        public var safetyImageTokenizer: Optional<any AssetBackedImageTokenizer> { get { return nil } set {} }
        public var tokenizer: Optional<any AssetBackedServerDiffusionTokenizer> { get { return nil } set {} }
        public func tokenizer(arg1: Optional<any AssetBackedServerDiffusionTokenizer>) -> Builder { fatalError() }
        public var anfrEncoder: Optional<any AssetBackedServerDiffusionANFREncoder> { get { return nil } set {} }
        public func safetyTokenizer(arg1: Optional<any AssetBackedTokenizer>) -> Builder { fatalError() }
        public var vaeEncoder: Optional<any AssetBackedServerDiffusionVAEEncoder> { get { return nil } set {} }
        public func alphaMaskDecoder(arg1: Optional<any AssetBackedServerDiffusionAlphaMaskDecoder>) -> Builder { fatalError() }
        public func safetyPreprocessorAdapter(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public func anfrEncoder(arg1: Optional<any AssetBackedServerDiffusionANFREncoder>) -> Builder { fatalError() }
        public var imageTokenizer: Optional<any AssetBackedServerDiffusionImageTokenizer> { get { return nil } set {} }
        public var safetyTokenizer: Optional<any AssetBackedTokenizer> { get { return nil } set {} }
        public func vaeDecoder(arg1: Optional<any AssetBackedServerDiffusionVAEDecoder>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func build() throws -> AssetBackedServerDiffusionBundle { fatalError() }
        public func safetyAdapterMultimodalInput(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public func safetyAdapterPromptRewrite(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public var alphaMaskDecoder: Optional<any AssetBackedServerDiffusionAlphaMaskDecoder> { get { return nil } set {} }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var diffusionAdapter: Optional<any AssetBackedServerDiffusionAdapter> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var safetyBaseModel: Optional<any AssetBackedLLMModel> { get { return nil } set {} }
        public var safetyPreprocessorAdapter: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func safetyAdapterMiscSafety(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func diffusionAdapter(arg1: Optional<any AssetBackedServerDiffusionAdapter>) -> Builder { fatalError() }
        public var noisePredictor: Optional<any AssetBackedServerDiffusionNoisePredictor> { get { return nil } set {} }
        public var safetyAdapterPromptRewrite: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public func noisePredictor(arg1: Optional<any AssetBackedServerDiffusionNoisePredictor>) -> Builder { fatalError() }
        public func safetyImageTokenizer(arg1: Optional<any AssetBackedImageTokenizer>) -> Builder { fatalError() }
        public func imageTokenizer(arg1: Optional<any AssetBackedServerDiffusionImageTokenizer>) -> Builder { fatalError() }
        public func safetyPostprocessorAdapter(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public var safetyAdapterMultimodalInput: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public var safetyPostprocessorAdapter: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public var vaeDecoder: Optional<any AssetBackedServerDiffusionVAEDecoder> { get { return nil } set {} }
        public func synthid(arg1: Optional<any AssetBackedServerDiffusionSynthID>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var textencoder: Optional<any AssetBackedServerDiffusionTextEncoder> { get { return nil } set {} }
    }
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedServerDiffusionBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public var configurationIdentifier: String { get { return "" } }
    public var vaeDecoder: any AssetBackedServerDiffusionVAEDecoder { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public var alphaMaskDecoder: Optional<any AssetBackedServerDiffusionAlphaMaskDecoder> { get { return nil } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var diffusionAdapter: Optional<any AssetBackedServerDiffusionAdapter> { get { return nil } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedServerDiffusionBundle> { get { fatalError() } }
    public var imageTokenizer: Optional<any AssetBackedServerDiffusionImageTokenizer> { get { return nil } }
    public var noisePredictor: any AssetBackedServerDiffusionNoisePredictor { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var safetyAdapterMultimodalInput: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var safetyBaseModel: Optional<any AssetBackedLLMModel> { get { return nil } }
    public var safetyImageTokenizer: Optional<any AssetBackedImageTokenizer> { get { return nil } }
    public var safetyPostprocessorAdapter: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var safetyPreprocessorAdapter: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var safetyTokenizer: Optional<any AssetBackedTokenizer> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var synthid: Optional<any AssetBackedServerDiffusionSynthID> { get { return nil } }
    public var textencoder: any AssetBackedServerDiffusionTextEncoder { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedServerDiffusionBundle, arg2: AssetBackedServerDiffusionBundle) -> Bool { return false }
    public var anfrEncoder: Optional<any AssetBackedServerDiffusionANFREncoder> { get { return nil } }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var safetyAdapterMiscSafety: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var safetyAdapterPromptRewrite: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var tokenizer: any AssetBackedServerDiffusionTokenizer { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public var vaeEncoder: Optional<any AssetBackedServerDiffusionVAEEncoder> { get { return nil } }
}
public protocol AssetBackedServerDiffusionImageTokenizer {
}
public struct AssetBackedServerDiffusionImageTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: AssetBackedServerDiffusionImageTokenizerBase, arg2: AssetBackedServerDiffusionImageTokenizerBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionNoisePredictor {
}
public struct AssetBackedServerDiffusionNoisePredictorBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: AssetBackedServerDiffusionNoisePredictorBase, arg2: AssetBackedServerDiffusionNoisePredictorBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionSynthID {
}
public struct AssetBackedServerDiffusionSynthIDBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedServerDiffusionSynthIDBase, arg2: AssetBackedServerDiffusionSynthIDBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionTextEncoder {
}
public struct AssetBackedServerDiffusionTextEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedServerDiffusionTextEncoderBase, arg2: AssetBackedServerDiffusionTextEncoderBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionTokenizer {
}
public struct AssetBackedServerDiffusionTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: AssetBackedServerDiffusionTokenizerBase, arg2: AssetBackedServerDiffusionTokenizerBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedServerDiffusionV10Bundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func textencoder(arg1: Optional<any AssetBackedServerDiffusionTextEncoder>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var textencoder: Optional<any AssetBackedServerDiffusionTextEncoder> { get { return nil } set {} }
        public func autoencoder(arg1: Optional<any AssetBackedServerDiffusionAutoEncoder>) -> Builder { fatalError() }
        public var noisePredictor: Optional<any AssetBackedServerDiffusionNoisePredictor> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func noisePredictor(arg1: Optional<any AssetBackedServerDiffusionNoisePredictor>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedServerDiffusionV10Bundle { fatalError() }
        public func tokenizer(arg1: Optional<any AssetBackedServerDiffusionTokenizer>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var autoencoder: Optional<any AssetBackedServerDiffusionAutoEncoder> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var tokenizer: Optional<any AssetBackedServerDiffusionTokenizer> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedServerDiffusionV10Bundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var autoencoder: any AssetBackedServerDiffusionAutoEncoder { get { fatalError() } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var tokenizer: any AssetBackedServerDiffusionTokenizer { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedServerDiffusionV10Bundle, arg2: AssetBackedServerDiffusionV10Bundle) -> Bool { return false }
    public var configurationIdentifier: String { get { return "" } }
    public var id: ResourceBundleIdentifier<AssetBackedServerDiffusionV10Bundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var noisePredictor: any AssetBackedServerDiffusionNoisePredictor { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var textencoder: any AssetBackedServerDiffusionTextEncoder { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
    public var serverWorkflowEnabled: Bool { get { return false } }
}
public struct AssetBackedServerDiffusionV11_1Bundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var alphaMaskDecoder: Optional<any AssetBackedServerDiffusionAlphaMaskDecoder> { get { return nil } set {} }
        public var diffusionAdapter: Optional<any AssetBackedServerDiffusionAdapter> { get { return nil } set {} }
        public var vaeDecoder: Optional<any AssetBackedServerDiffusionVAEDecoder> { get { return nil } set {} }
        public func diffusionAdapter(arg1: Optional<any AssetBackedServerDiffusionAdapter>) -> Builder { fatalError() }
        public var vaeEncoder: Optional<any AssetBackedServerDiffusionVAEEncoder> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var noisePredictor: Optional<any AssetBackedServerDiffusionNoisePredictor> { get { return nil } set {} }
        public func safetyAdapterMiscSafety(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedServerDiffusionV11_1Bundle { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func alphaMaskDecoder(arg1: Optional<any AssetBackedServerDiffusionAlphaMaskDecoder>) -> Builder { fatalError() }
        public func textencoder(arg1: Optional<any AssetBackedServerDiffusionTextEncoder>) -> Builder { fatalError() }
        public func safetyTokenizer(arg1: Optional<any AssetBackedTokenizer>) -> Builder { fatalError() }
        public func safetyAdapterPromptRewrite(arg1: Optional<any AssetBackedLLMAdapter>) -> Builder { fatalError() }
        public func noisePredictor(arg1: Optional<any AssetBackedServerDiffusionNoisePredictor>) -> Builder { fatalError() }
        public func safetyBaseModel(arg1: Optional<any AssetBackedLLMModel>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var safetyAdapterMiscSafety: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public var safetyBaseModel: Optional<any AssetBackedLLMModel> { get { return nil } set {} }
        public func tokenizer(arg1: Optional<any AssetBackedServerDiffusionTokenizer>) -> Builder { fatalError() }
        public var textencoder: Optional<any AssetBackedServerDiffusionTextEncoder> { get { return nil } set {} }
        public var tokenizer: Optional<any AssetBackedServerDiffusionTokenizer> { get { return nil } set {} }
        public func vaeEncoder(arg1: Optional<any AssetBackedServerDiffusionVAEEncoder>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var anfrEncoder: Optional<any AssetBackedServerDiffusionANFREncoder> { get { return nil } set {} }
        public var safetyAdapterPromptRewrite: Optional<any AssetBackedLLMAdapter> { get { return nil } set {} }
        public var safetyImageTokenizer: Optional<any AssetBackedImageTokenizer> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func anfrEncoder(arg1: Optional<any AssetBackedServerDiffusionANFREncoder>) -> Builder { fatalError() }
        public var safetyTokenizer: Optional<any AssetBackedTokenizer> { get { return nil } set {} }
        public func safetyImageTokenizer(arg1: Optional<any AssetBackedImageTokenizer>) -> Builder { fatalError() }
        public func vaeDecoder(arg1: Optional<any AssetBackedServerDiffusionVAEDecoder>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
    }
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedServerDiffusionV11_1Bundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public static func ==(arg1: AssetBackedServerDiffusionV11_1Bundle, arg2: AssetBackedServerDiffusionV11_1Bundle) -> Bool { return false }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var noisePredictor: any AssetBackedServerDiffusionNoisePredictor { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var alphaMaskDecoder: Optional<any AssetBackedServerDiffusionAlphaMaskDecoder> { get { return nil } }
    public var anfrEncoder: Optional<any AssetBackedServerDiffusionANFREncoder> { get { return nil } }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var diffusionAdapter: Optional<any AssetBackedServerDiffusionAdapter> { get { return nil } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedServerDiffusionV11_1Bundle> { get { fatalError() } }
    public var safetyAdapterMiscSafety: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var safetyAdapterPromptRewrite: Optional<any AssetBackedLLMAdapter> { get { return nil } }
    public var safetyBaseModel: Optional<any AssetBackedLLMModel> { get { return nil } }
    public var safetyImageTokenizer: Optional<any AssetBackedImageTokenizer> { get { return nil } }
    public var safetyTokenizer: Optional<any AssetBackedTokenizer> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var textencoder: any AssetBackedServerDiffusionTextEncoder { get { fatalError() } }
    public var tokenizer: any AssetBackedServerDiffusionTokenizer { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public var vaeDecoder: any AssetBackedServerDiffusionVAEDecoder { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var vaeEncoder: Optional<any AssetBackedServerDiffusionVAEEncoder> { get { return nil } }
}
public protocol AssetBackedServerDiffusionVAEDecoder {
}
public struct AssetBackedServerDiffusionVAEDecoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedServerDiffusionVAEDecoderBase, arg2: AssetBackedServerDiffusionVAEDecoderBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedServerDiffusionVAEEncoder {
}
public struct AssetBackedServerDiffusionVAEEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedServerDiffusionVAEEncoderBase, arg2: AssetBackedServerDiffusionVAEEncoderBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedSpeechDetokenizer {
}
public struct AssetBackedSpeechDetokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedSpeechDetokenizerBase, arg2: AssetBackedSpeechDetokenizerBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedSpeechTokenizer {
}
public struct AssetBackedSpeechTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: AssetBackedSpeechTokenizerBase, arg2: AssetBackedSpeechTokenizerBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedThirdPartyProviderConfiguration {
}
public struct AssetBackedThirdPartyProviderConfigurationBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AssetBackedThirdPartyProviderConfigurationBase, arg2: AssetBackedThirdPartyProviderConfigurationBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedTokenInputDenyList {
}
public struct AssetBackedTokenInputDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedTokenInputDenyListBase, arg2: AssetBackedTokenInputDenyListBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedTokenInputDenyListBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func build() throws -> AssetBackedTokenInputDenyListBundle { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var embeddingDenyList: Optional<any AssetBackedEmbeddingDenyList> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func tokenInputDenyList(arg1: Optional<any AssetBackedTokenInputDenyList>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var tokenInputDenyList: Optional<any AssetBackedTokenInputDenyList> { get { return nil } set {} }
        public func embeddingDenyList(arg1: Optional<any AssetBackedEmbeddingDenyList>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (AssetBackedTokenInputDenyListBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedTokenInputDenyListBundle, arg2: AssetBackedTokenInputDenyListBundle) -> Bool { return false }
    public var embeddingDenyList: any AssetBackedEmbeddingDenyList { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var id: ResourceBundleIdentifier<AssetBackedTokenInputDenyListBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var rawID: String { get { return "" } }
    public var tokenInputDenyList: any AssetBackedTokenInputDenyList { get { fatalError() } }
}
public struct AssetBackedTokenInputDenyListWithDefaultsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func defaultDenyList(arg1: Optional<any AssetBackedModelConfigurationReplacement>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func tokenInputDenyList(arg1: Optional<any AssetBackedTokenInputDenyList>) -> Builder { fatalError() }
        public var defaultDenyList: Optional<any AssetBackedModelConfigurationReplacement> { get { return nil } set {} }
        public var embeddingDenyList: Optional<any AssetBackedEmbeddingDenyList> { get { return nil } set {} }
        public var tokenInputDenyList: Optional<any AssetBackedTokenInputDenyList> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func embeddingDenyList(arg1: Optional<any AssetBackedEmbeddingDenyList>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedTokenInputDenyListWithDefaultsBundle { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedTokenInputDenyListWithDefaultsBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var defaultDenyList: any AssetBackedModelConfigurationReplacement { get { fatalError() } }
    public var embeddingDenyList: any AssetBackedEmbeddingDenyList { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedTokenInputDenyListWithDefaultsBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var tokenInputDenyList: any AssetBackedTokenInputDenyList { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedTokenInputDenyListWithDefaultsBundle, arg2: AssetBackedTokenInputDenyListWithDefaultsBundle) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func encode(to: Encoder) throws -> () {}
}
public protocol AssetBackedTokenOutputDenyList {
}
public struct AssetBackedTokenOutputDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: AssetBackedTokenOutputDenyListBase, arg2: AssetBackedTokenOutputDenyListBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedTokenOutputDenyListBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var tokenOutputDenyList: Optional<any AssetBackedTokenOutputDenyList> { get { return nil } set {} }
        public func embeddingDenyList(arg1: Optional<any AssetBackedEmbeddingDenyList>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func tokenOutputDenyList(arg1: Optional<any AssetBackedTokenOutputDenyList>) -> Builder { fatalError() }
        public var embeddingDenyList: Optional<any AssetBackedEmbeddingDenyList> { get { return nil } set {} }
        public func build() throws -> AssetBackedTokenOutputDenyListBundle { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (AssetBackedTokenOutputDenyListBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var tokenOutputDenyList: any AssetBackedTokenOutputDenyList { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var id: ResourceBundleIdentifier<AssetBackedTokenOutputDenyListBundle> { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public static func ==(arg1: AssetBackedTokenOutputDenyListBundle, arg2: AssetBackedTokenOutputDenyListBundle) -> Bool { return false }
    public var configurationIdentifier: String { get { return "" } }
    public var embeddingDenyList: any AssetBackedEmbeddingDenyList { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
}
public struct AssetBackedTokenOutputDenyListWithDefaultsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var tokenOutputDenyList: Optional<any AssetBackedTokenOutputDenyList> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var defaultDenyList: Optional<any AssetBackedModelConfigurationReplacement> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func build() throws -> AssetBackedTokenOutputDenyListWithDefaultsBundle { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func defaultDenyList(arg1: Optional<any AssetBackedModelConfigurationReplacement>) -> Builder { fatalError() }
        public func tokenOutputDenyList(arg1: Optional<any AssetBackedTokenOutputDenyList>) -> Builder { fatalError() }
        public var embeddingDenyList: Optional<any AssetBackedEmbeddingDenyList> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func embeddingDenyList(arg1: Optional<any AssetBackedEmbeddingDenyList>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (AssetBackedTokenOutputDenyListWithDefaultsBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var tokenOutputDenyList: any AssetBackedTokenOutputDenyList { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var embeddingDenyList: any AssetBackedEmbeddingDenyList { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<AssetBackedTokenOutputDenyListWithDefaultsBundle> { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public static func ==(arg1: AssetBackedTokenOutputDenyListWithDefaultsBundle, arg2: AssetBackedTokenOutputDenyListWithDefaultsBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var configurationIdentifier: String { get { return "" } }
    public var defaultDenyList: any AssetBackedModelConfigurationReplacement { get { fatalError() } }
}
public protocol AssetBackedTokenOutputRetainList {
}
public struct AssetBackedTokenOutputRetainListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: AssetBackedTokenOutputRetainListBase, arg2: AssetBackedTokenOutputRetainListBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedTokenOutputRetainListBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func build() throws -> AssetBackedTokenOutputRetainListBundle { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var tokenOutputRetainList: Optional<any AssetBackedTokenOutputRetainList> { get { return nil } set {} }
        public func tokenOutputRetainList(arg1: Optional<any AssetBackedTokenOutputRetainList>) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedTokenOutputRetainListBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var id: ResourceBundleIdentifier<AssetBackedTokenOutputRetainListBundle> { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var tokenOutputRetainList: any AssetBackedTokenOutputRetainList { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: AssetBackedTokenOutputRetainListBundle, arg2: AssetBackedTokenOutputRetainListBundle) -> Bool { return false }
}
public protocol AssetBackedTokenizer {
}
public struct AssetBackedTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedTokenizerBase, arg2: AssetBackedTokenizerBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedTranslateFMAsset {
}
public struct AssetBackedTranslateFMAssetBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: AssetBackedTranslateFMAssetBase, arg2: AssetBackedTranslateFMAssetBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol AssetBackedVisionModel {
}
public struct AssetBackedVisionModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetBackedVisionModelBase, arg2: AssetBackedVisionModelBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedVisionModelBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func recognizeanimals(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public var foregroundinstancesegmentation: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public var recognizeanimals: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public func build() throws -> AssetBackedVisionModelBundle { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func detectbarcodes(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public var personinstancesegmentation: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public var personsegmentation: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func foregroundinstancesegmentation(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public var masktracker: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public func personsegmentation(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public func personinstancesegmentation(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public func masktracker(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public func facelandmarks(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var facecapturequality: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public var facelandmarks: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public var humanrectangles: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var smudgedetection: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public func humanrectangles(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public func smudgedetection(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public func facecapturequality(arg1: Optional<any AssetBackedVisionModel>) -> Builder { fatalError() }
        public var detectbarcodes: Optional<any AssetBackedVisionModel> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (AssetBackedVisionModelBundle.Builder) throws -> ()) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var detectbarcodes: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var facelandmarks: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var humanrectangles: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var id: ResourceBundleIdentifier<AssetBackedVisionModelBundle> { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var facecapturequality: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var foregroundinstancesegmentation: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var masktracker: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var personinstancesegmentation: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var personsegmentation: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var smudgedetection: Optional<any AssetBackedVisionModel> { get { return nil } }
    public static func ==(arg1: AssetBackedVisionModelBundle, arg2: AssetBackedVisionModelBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var recognizeanimals: Optional<any AssetBackedVisionModel> { get { return nil } }
    public var trialNamespace: Optional<String> { get { return nil } }
}
public protocol AssetBackedVoicesOverrides {
}
public struct AssetBackedVoicesOverridesBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: AssetBackedVoicesOverridesBase, arg2: AssetBackedVoicesOverridesBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetBackedVoicesOverridesBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var voicesOverrides: Optional<any AssetBackedVoicesOverrides> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func build() throws -> AssetBackedVoicesOverridesBundle { fatalError() }
        public func voicesOverrides(arg1: Optional<any AssetBackedVoicesOverrides>) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (AssetBackedVoicesOverridesBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any AssetBackedResource>) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public var voicesOverrides: any AssetBackedVoicesOverrides { get { fatalError() } }
    public static func ==(arg1: AssetBackedVoicesOverridesBundle, arg2: AssetBackedVoicesOverridesBundle) -> Bool { return false }
    public var assetBackedResources: Array<any AssetBackedResource> { get { return [] } }
    public var id: ResourceBundleIdentifier<AssetBackedVoicesOverridesBundle> { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
}
public protocol AssetContents {
    init(baseURL: URL)
    var baseURL: URL { get }
}
public struct AssetLock: Codable, Hashable, Sendable {
    public init() throws {}
    public init(resources: Array<any AssetBackedResource>) throws {}
    public static func lockAllResources() async throws -> AssetLock { fatalError() }
    public var id: String { get { return "" } }
    public static func lockResources(arg1: Array<any AssetBackedResource>) async throws -> AssetLock { fatalError() }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public enum AssetManagerShared: Hashable, Sendable {
    public struct UsageAliasSubscription: Codable, Hashable, Sendable {
        public init(name: String, value: String) {}
        public var arguments: Dictionary<String, String> { get { return [:] } }
        public var name: String { get { return "" } }
        public var subscriptionName: String { get { return "" } }
        public var value: String { get { return "" } }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    case _mock
    public static func usageAliasSubscriptions(for: UseCaseIdentifier, usageAliasValuesForUsageAlias: Dictionary<String, Array<String>>) -> Optional<Array<AssetManagerShared.UsageAliasSubscription>> { return nil }
    public static var subscriberID: String { get { return "" } }
    public static func usageAliasSubscription(useCaseIdentifier: UseCaseIdentifier, arguments: Dictionary<String, String>) -> AssetManagerShared.UsageAliasSubscription { fatalError() }
    public static func unredactArguments(arg1: Dictionary<String, String>) -> Dictionary<String, String> { return [:] }
    public static func usageAliasSubscription(useCaseIdentifier: UseCaseIdentifier, usageAliasValue: String) -> AssetManagerShared.UsageAliasSubscription { fatalError() }
}
public protocol AssetMetadata {
}
public struct AssetSetStatus: Codable, Hashable, Sendable {
    public static func ==(arg1: AssetSetStatus, arg2: AssetSetStatus) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AssetSetSubscription: Codable, Hashable, Sendable {
    public init(name: String, assetSets: Dictionary<String, Dictionary<String, String>>, usageAliases: Dictionary<String, String>, expiration: Optional<Date>) {}
    public var assetSets: Dictionary<String, Dictionary<String, String>> { get { return [:] } }
    public var expiration: Optional<Date> { get { return nil } }
    public var name: String { get { return "" } }
    public var usageAliases: Dictionary<String, String> { get { return [:] } }
    public static func ==(arg1: AssetSetSubscription, arg2: AssetSetSubscription) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AssetSpecificationVersion: Codable, Hashable, Sendable {
    public init(major: UInt, minor: UInt, patch: UInt) {}
    public var major: UInt { get { return 0 } }
    public static func ==(arg1: AssetSpecificationVersion, arg2: AssetSpecificationVersion) -> Bool { return false }
    public var minor: UInt { get { return 0 } }
    public var number: String { get { return "" } }
    public var patch: UInt { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AssetSubscription: Codable, Hashable, Sendable {
    public var assetSetName: String { get { return "" } }
    public var requestResourcesKey: Optional<RequestResourcesKey> { get { return nil } }
    public static func ==(arg1: AssetSubscription, arg2: AssetSubscription) -> Bool { return false }
    public func status() -> AssetSubscriptionStatus { fatalError() }
    public var description: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var subscriberID: String { get { return "" } }
    public var subscriptionName: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct AssetSubscriptionInformation: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public init(subscriberID: String, subscriptionName: String, assetSetName: String) {}
    public init(subscriberID: String, subscriptionName: String, assetSetName: String, ttl: Optional<Int>, requestResourcesKey: Optional<RequestResourcesKey>) {}
    public static func ==(arg1: AssetSubscriptionInformation, arg2: AssetSubscriptionInformation) -> Bool { return false }
    public var requestResourcesKey: Optional<RequestResourcesKey> { get { return nil } }
    public var subscriberID: String { get { return "" } }
    public var subscriptionName: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var assetSetName: String { get { return "" } }
    public var ttl: Optional<Int> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
}
public enum AssetSubscriptionStatus: Hashable, Sendable {
    case _mock
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetSubscriptionStatus, arg2: AssetSubscriptionStatus) -> Bool { return false }
}
public enum AssetSubscriptionStatusPendingReason: Hashable, Sendable {
    case _mock
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: AssetSubscriptionStatusPendingReason, arg2: AssetSubscriptionStatusPendingReason) -> Bool { return false }
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
}
public struct AssetVersion: Codable, Hashable, Sendable {
    public init(versionString: String) {}
    public static func ==(arg1: AssetVersion, arg2: AssetVersion) -> Bool { return false }
    public var number: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct AvailableUseCases: Codable, Hashable, Sendable {
    public struct AvailableUseCase: Codable, Hashable, Sendable {
        public var useCaseIdentifier: UseCaseIdentifier { get { fatalError() } }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public var assetsReady: Bool { get { return false } }
        public var language: SupportedArgument<Locale.LanguageCode> { get { fatalError() } }
        public var missingAssets: Optional<Array<String>> { get { return nil } }
        public var presentAssets: Optional<Array<String>> { get { return nil } }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public init(availableUseCases: Array<AvailableUseCases.AvailableUseCase>) {}
    public var availableUseCases: Array<AvailableUseCases.AvailableUseCase> { get { return [] } }
    public static func ==(arg1: AvailableUseCases, arg2: AvailableUseCases) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public class AvailableUseCasesWrapper {
    public init(coder: NSCoder) {}
    public init(rawAvailableUseCases: RawAvailableUseCases) {}
    public init() {}
    public var hash: Int { get { return 0 } }
    public static var rawAvailableUseCasesKey: String { get { return "" } }
    public func copy(with: Optional<NSZone>) -> Any { fatalError() }
    public var description: String { get { return "" } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func encode(with: NSCoder) -> () {}
}
public protocol BidirectionalServiceConnectionProtocol {
    func getCurrentConnectionState() -> ConnectionState
    func call(arg1: (Any) -> GenericA) throws -> GenericA
    func call(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) async throws -> GenericA
    func call(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) throws -> GenericA
    associatedtype RemoteService
    associatedtype LocalService
}
public class BidirectionalXPCServiceClientConnection<A, B> {
    public init(localObject: Any, delegate: any BidirectionalXPCServiceClientConnectionDelegate) throws {}
    public init(existingConnection: NSXPCConnection, localObject: Any, delegate: any BidirectionalXPCServiceClientConnectionDelegate) throws {}
    public func call<GenericA>(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) async throws -> GenericA { fatalError() }
    public func call<GenericA>(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) throws -> GenericA { fatalError() }
    public func call<GenericA>(arg1: (Any) -> GenericA) throws -> GenericA { fatalError() }
    public func getCurrentConnectionState() -> ConnectionState { fatalError() }
}
public protocol BidirectionalXPCServiceClientConnectionDelegate {
    func xpcBidirectionalConnectionWasInvalidated() -> ()
    func xpcBidirectionalConnectionIsAllowed() throws -> ()
}
public protocol BloomFilterTokenInputDenyList {
}
public struct BloomFilterTokenInputDenyListAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct BloomFilterTokenInputDenyListAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct BloomFilterTokenInputDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: BloomFilterTokenInputDenyListBase, arg2: BloomFilterTokenInputDenyListBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct BundlePolicy: Codable, Hashable, Sendable {
    public init(unentitledUseCases: Array<String>, unentitledGatedByFoundationModels: Bool, entitlementOverride: Optional<String>, foregroundInferenceOnly: Bool, effectiveUseCaseForLocalDevelopment: Optional<String>, effectiveUseCaseForDistribution: Optional<String>, effectiveUseCaseForTestFlight: Optional<String>, alwaysAllowUnentitled: Bool) {}
    public init(unentitledUseCases: Array<String>, unentitledGatedByFoundationModels: Bool, entitlementOverride: Optional<String>, foregroundInferenceOnly: Bool, effectiveUseCaseForLocalDevelopment: Optional<String>, effectiveUseCaseForDistribution: Optional<String>, effectiveUseCaseForTestFlight: Optional<String>) {}
    public init(unentitledUseCases: Array<String>, unentitledGatedByFoundationModels: Bool, entitlementOverride: Optional<String>, foregroundInferenceOnly: Bool) {}
    public init(from: Decoder) throws {}
    public init(unentitledUseCases: Array<String>, unentitledGatedByFoundationModels: Bool, entitlementOverride: Optional<String>, foregroundInferenceOnly: Bool, effectiveUseCaseForLocalDevelopment: Optional<String>, effectiveUseCaseForDistribution: Optional<String>, effectiveUseCaseForTestFlight: Optional<String>, alwaysAllowUnentitled: Bool, blockSideloadedApps: Bool) {}
    public var alwaysAllowUnentitled: Bool { get { return false } }
    public var blockSideloadedApps: Bool { get { return false } }
    public var entitlementOverride: Optional<String> { get { return nil } }
    public var foregroundInferenceOnly: Bool { get { return false } }
    public var unentitledUseCases: Array<String> { get { return [] } }
    public static func ==(arg1: BundlePolicy, arg2: BundlePolicy) -> Bool { return false }
    public var effectiveUseCaseForDistribution: Optional<String> { get { return nil } }
    public var effectiveUseCaseForLocalDevelopment: Optional<String> { get { return nil } }
    public var unentitledGatedByFoundationModels: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
    public var effectiveUseCaseForTestFlight: Optional<String> { get { return nil } }
    public var hashValue: Int { get { return 0 } }
}
public struct Capabilities: Codable, Hashable, Sendable {
    public enum Accessories: Hashable, Sendable {
        case _mock
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public var hashValue: Int { get { return 0 } }
        public func hash(into: inout Hasher) -> () {}
    }
    public enum FacialHair: Hashable, Sendable {
        case _mock
        public var hashValue: Int { get { return 0 } }
        public func hash(into: inout Hasher) -> () {}
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
    }
    public enum Hair: Hashable, Sendable {
        case _mock
        public func hash(into: inout Hasher) -> () {}
        public var hashValue: Int { get { return 0 } }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
    }
    public enum Headwear: Hashable, Sendable {
        case _mock
        public var hashValue: Int { get { return 0 } }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public func hash(into: inout Hasher) -> () {}
    }
    public enum ImageAspectRatio: Hashable, Sendable {
        case _mock
        public var hashValue: Int { get { return 0 } }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public func hash(into: inout Hasher) -> () {}
    }
    public struct ImageGeneration: Codable, Hashable, Sendable {
        public init(supported: Bool, maxTextInputLength: Int, maxInputFileSize: Int, supportsAspectRatios: Array<Capabilities.ImageAspectRatio>, supportsSizes: Array<Capabilities.ImageSize>, supportsFormats: Array<UTType>, supportsMultipleInput: Bool, supportsMultipleOutput: Bool, supportsStyles: Array<Capabilities.Style>, supportsThemes: Array<Capabilities.Theme>, supportsHair: Array<Capabilities.Hair>, supportsFacialHair: Array<Capabilities.FacialHair>, supportsHeadWear: Array<Capabilities.Headwear>, supportsAccessories: Array<Capabilities.Accessories>) {}
        public var maxInputFileSize: Int { get { return 0 } }
        public var maxTextInputLength: Int { get { return 0 } }
        public var supported: Bool { get { return false } }
        public var supportsAccessories: Array<Capabilities.Accessories> { get { return [] } }
        public var supportsAspectRatios: Array<Capabilities.ImageAspectRatio> { get { return [] } }
        public var supportsFacialHair: Array<Capabilities.FacialHair> { get { return [] } }
        public var supportsFormats: Array<UTType> { get { return [] } }
        public var supportsHair: Array<Capabilities.Hair> { get { return [] } }
        public var supportsHeadWear: Array<Capabilities.Headwear> { get { return [] } }
        public var supportsMultipleInput: Bool { get { return false } }
        public var supportsMultipleOutput: Bool { get { return false } }
        public var supportsSizes: Array<Capabilities.ImageSize> { get { return [] } }
        public var supportsStyles: Array<Capabilities.Style> { get { return [] } }
        public var supportsThemes: Array<Capabilities.Theme> { get { return [] } }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum ImageSize: Hashable, Sendable {
        case _mock
        public func hash(into: inout Hasher) -> () {}
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public var hashValue: Int { get { return 0 } }
    }
    public enum Style: Hashable, Sendable {
        case _mock
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public func hash(into: inout Hasher) -> () {}
        public var hashValue: Int { get { return 0 } }
    }
    public struct TextGeneration: Codable, Hashable, Sendable {
        public init(supported: Bool, maxInputLength: Int, supportsFormats: Array<UTType>, supportsLocales: Array<Locale>) {}
        public var maxInputLength: Int { get { return 0 } }
        public var supported: Bool { get { return false } }
        public var supportsFormats: Array<UTType> { get { return [] } }
        public var supportsLocales: Array<Locale> { get { return [] } }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum Theme: Hashable, Sendable {
        case _mock
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public func hash(into: inout Hasher) -> () {}
        public var hashValue: Int { get { return 0 } }
    }
    public init(textGeneration: Capabilities.TextGeneration, imageGeneration: Capabilities.ImageGeneration) {}
    public var imageGeneration: Capabilities.ImageGeneration { get { fatalError() } }
    public var textGeneration: Capabilities.TextGeneration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public enum Catalog: Hashable, Sendable {
    public enum AppleDeviceTracking: Hashable, Sendable {
        case _mock
    }
    public enum CoreML: Hashable, Sendable {
        public enum RankingModel: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum Diffusion: Hashable, Sendable {
        public enum Adapter: Hashable, Sendable {
            case _mock
        }
        public enum Model: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum DisabledUseCaseList: Hashable, Sendable {
        case _mock
    }
    public enum DynamicFramework: Hashable, Sendable {
        case _mock
    }
    public enum Embedding: Hashable, Sendable {
        public enum AppleEmbeddingModel: Hashable, Sendable {
            public enum Encoder: Hashable, Sendable {
                case _mock
            }
            public enum Tokenizer: Hashable, Sendable {
                case _mock
            }
            case _mock
        }
        case _mock
    }
    public enum EmbeddingDenyList: Hashable, Sendable {
        case _mock
    }
    public enum EmbeddingPreprocessor: Hashable, Sendable {
        case _mock
    }
    public enum GenerativeShortcuts: Hashable, Sendable {
        public enum Model: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum HandwritingSynthesizer: Hashable, Sendable {
        case _mock
    }
    public enum ImageCuratedPrompts: Hashable, Sendable {
        case _mock
    }
    public enum ImageFilter: Hashable, Sendable {
        case _mock
    }
    public enum ImageInpainter: Hashable, Sendable {
        case _mock
    }
    public enum ImageMagicCleanUp: Hashable, Sendable {
        case _mock
    }
    public enum ImageScaler: Hashable, Sendable {
        case _mock
    }
    public enum ImageSegmenter: Hashable, Sendable {
        case _mock
    }
    public enum ImageSpatialPhotosRelive: Hashable, Sendable {
        case _mock
    }
    public enum ImageTokenizer: Hashable, Sendable {
        case _mock
    }
    public enum ImageTokenizerAdapter: Hashable, Sendable {
        case _mock
    }
    public enum LLM: Hashable, Sendable {
        public enum AJAX: Hashable, Sendable {
            case _mock
        }
        public enum Adapter: Hashable, Sendable {
            case _mock
        }
        public enum AdapterMetadataOverride: Hashable, Sendable {
            case _mock
        }
        public enum DraftModel: Hashable, Sendable {
            case _mock
        }
        public enum Model: Hashable, Sendable {
            case _mock
        }
        public enum ServerConfiguration: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum ModelConfigurationReplacement: Hashable, Sendable {
        case _mock
    }
    public enum Motion: Hashable, Sendable {
        public enum Adapter: Hashable, Sendable {
            case _mock
        }
        public enum Model: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum PCCGenericInference: Hashable, Sendable {
        case _mock
    }
    public enum PromptAllowList: Hashable, Sendable {
        case _mock
    }
    public enum Resource: Hashable, Sendable {
        public enum AppleDeviceTracking: Hashable, Sendable {
            case _mock
            public static func IPhoneTracker() -> any AssetBackedAppleDeviceTracking { fatalError() }
            public static func MacbookTracker() -> AppleDeviceTracking { fatalError() }
            public static func Detector(variant: String) throws -> any AssetBackedAppleDeviceTracking { fatalError() }
            public static func MacbookTracker(variant: String) throws -> AppleDeviceTracking { fatalError() }
            public static func IPhoneTracker(variant: String) throws -> any AssetBackedAppleDeviceTracking { fatalError() }
            public static func MagicKeyboardTracker() -> AppleDeviceTracking { fatalError() }
            public static func Detector() -> any AssetBackedAppleDeviceTracking { fatalError() }
            public static func MagicKeyboardTracker(variant: String) throws -> AppleDeviceTracking { fatalError() }
        }
        public enum CoreML: Hashable, Sendable {
            public enum RankingModel: Hashable, Sendable {
                case _mock
                public static func ConcertsRanking(variant: String) throws -> any AssetBackedRankingModel { fatalError() }
                public static func ConcertsRanking() -> any AssetBackedRankingModel { fatalError() }
            }
            case _mock
        }
        public enum Diffusion: Hashable, Sendable {
            public enum Adapter: Hashable, Sendable {
                case _mock
                public static func MessagesBackgrounds(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Sketch(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedSketch(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedEmoji(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func SkinToneEmoji(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedScribble(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedScribble() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Scribble() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Animation() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Illustration() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedEmoji() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Refiner(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedAnimation(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Emoji(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Sketch() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedSketch() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Animation(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Emoji() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedIllustration() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Scribble(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedIllustration(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func SkinToneEmoji() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func PersonalizedAnimation() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Illustration(variant: String) throws -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func MessagesBackgrounds() -> any AssetBackedDiffusionAdapter { fatalError() }
                public static func Refiner() -> any AssetBackedDiffusionAdapter { fatalError() }
            }
            public enum Model: Hashable, Sendable {
                case _mock
                public static func VisualGenerationBase(variant: String) throws -> any AssetBackedDiffusionModel { fatalError() }
                public static func VisualGenerationBase() -> any AssetBackedDiffusionModel { fatalError() }
            }
            case _mock
        }
        public enum DisabledUseCaseList: Hashable, Sendable {
            case _mock
            public static func All(variant: String) throws -> any AssetBackedDisabledUseCaseList { fatalError() }
            public static func All() -> any AssetBackedDisabledUseCaseList { fatalError() }
        }
        public enum Embedding: Hashable, Sendable {
            public enum AppleEmbeddingModel: Hashable, Sendable {
                public enum Encoder: Hashable, Sendable {
                    case _mock
                    public static func AEMMd8Encoder(variant: String) throws -> any AssetBackedAppleEmbeddingModelEncoder { fatalError() }
                    public static func AEMMd7Encoder(variant: String) throws -> any AssetBackedAppleEmbeddingModelEncoder { fatalError() }
                    public static func AEMMd8Encoder() -> any AssetBackedAppleEmbeddingModelEncoder { fatalError() }
                    public static func AEMMd7Encoder() -> any AssetBackedAppleEmbeddingModelEncoder { fatalError() }
                    public static func AEMMd9Encoder() -> any AssetBackedAppleEmbeddingModelEncoder { fatalError() }
                    public static func AEMMd9Encoder(variant: String) throws -> any AssetBackedAppleEmbeddingModelEncoder { fatalError() }
                }
                public enum Tokenizer: Hashable, Sendable {
                    case _mock
                    public static func AEMMd8Tokenizer() -> any AssetBackedAppleEmbeddingModelTokenizer { fatalError() }
                    public static func AEMMd9Tokenizer() -> any AssetBackedAppleEmbeddingModelTokenizer { fatalError() }
                    public static func AEMMd7Tokenizer() -> any AssetBackedAppleEmbeddingModelTokenizer { fatalError() }
                    public static func AEMMd9Tokenizer(variant: String) throws -> any AssetBackedAppleEmbeddingModelTokenizer { fatalError() }
                    public static func AEMMd7Tokenizer(variant: String) throws -> any AssetBackedAppleEmbeddingModelTokenizer { fatalError() }
                    public static func AEMMd8Tokenizer(variant: String) throws -> any AssetBackedAppleEmbeddingModelTokenizer { fatalError() }
                }
                case _mock
                public static func AEMMd7() -> any AssetBackedAppleEmbeddingModel { fatalError() }
                public static func AEMMd8(variant: String) throws -> any AssetBackedAppleEmbeddingModel { fatalError() }
                public static func AEMMd8() -> any AssetBackedAppleEmbeddingModel { fatalError() }
                public static func AEMMd7(variant: String) throws -> any AssetBackedAppleEmbeddingModel { fatalError() }
                public static func AEMMd9(variant: String) throws -> any AssetBackedAppleEmbeddingModel { fatalError() }
                public static func AEMMd9() -> any AssetBackedAppleEmbeddingModel { fatalError() }
            }
            case _mock
        }
        public enum EmbeddingDenyList: Hashable, Sendable {
            case _mock
            public static func All(variant: String) throws -> any AssetBackedEmbeddingDenyList { fatalError() }
            public static func All() -> any AssetBackedEmbeddingDenyList { fatalError() }
        }
        public enum EmbeddingPreprocessor: Hashable, Sendable {
            case _mock
            public static func StructuralIntegrityCustomizedEmbeddingPreprocessor(variant: String) throws -> any AssetBackedEmbeddingPreprocessor { fatalError() }
            public static func MiscSafetyCustomizedEmbeddingPreprocessor() -> any AssetBackedEmbeddingPreprocessor { fatalError() }
            public static func StructuralIntegrityCustomizedEmbeddingPreprocessor() -> any AssetBackedEmbeddingPreprocessor { fatalError() }
            public static func AFMPlusEmbeddingPreprocessor(variant: String) throws -> any AssetBackedEmbeddingPreprocessor { fatalError() }
            public static func PrepubescentSafetyCustomizedEmbeddingPreprocessor() -> any AssetBackedEmbeddingPreprocessor { fatalError() }
            public static func PrepubescentSafetyCustomizedEmbeddingPreprocessor(variant: String) throws -> any AssetBackedEmbeddingPreprocessor { fatalError() }
            public static func AFMPlusEmbeddingPreprocessor() -> any AssetBackedEmbeddingPreprocessor { fatalError() }
            public static func MiscSafetyCustomizedEmbeddingPreprocessor(variant: String) throws -> any AssetBackedEmbeddingPreprocessor { fatalError() }
        }
        public enum GenerativeShortcuts: Hashable, Sendable {
            public enum Model: Hashable, Sendable {
                case _mock
                public static func ShortcutsGeneratorToolRetrieval() -> any AssetBackedGenerativeShortcutsModel { fatalError() }
                public static func ShortcutsGeneratorToolRetrieval(variant: String) throws -> any AssetBackedGenerativeShortcutsModel { fatalError() }
            }
            case _mock
        }
        public enum HandwritingSynthesizer: Hashable, Sendable {
            case _mock
            public static func HandwritingSynthesis() -> any AssetBackedHandwritingSynthesizer { fatalError() }
            public static func HandwritingSynthesis(variant: String) throws -> any AssetBackedHandwritingSynthesizer { fatalError() }
            public static func HandwritingSynthesisMultilingual(variant: String) throws -> any AssetBackedHandwritingSynthesizer { fatalError() }
            public static func HandwritingSynthesisMultilingual() -> any AssetBackedHandwritingSynthesizer { fatalError() }
        }
        public enum ImageCuratedPrompts: Hashable, Sendable {
            case _mock
            public static func All(variant: String) throws -> any AssetBackedImageCuratedPrompts { fatalError() }
            public static func All() -> any AssetBackedImageCuratedPrompts { fatalError() }
        }
        public enum ImageFilter: Hashable, Sendable {
            case _mock
            public static func Conditioning(variant: String) throws -> any AssetBackedImageFilter { fatalError() }
            public static func Conditioning() -> any AssetBackedImageFilter { fatalError() }
        }
        public enum ImageInpainter: Hashable, Sendable {
            case _mock
        }
        public enum ImageMagicCleanUp: Hashable, Sendable {
            case _mock
            public static func GenerativeEditsMagicCleanUp() -> any AssetBackedImageMagicCleanUp { fatalError() }
            public static func GenerativeEditsMagicCleanUp(variant: String) throws -> any AssetBackedImageMagicCleanUp { fatalError() }
        }
        public enum ImageScaler: Hashable, Sendable {
            case _mock
            public static func GenerativePlaygroundsUpscaler() -> any AssetBackedImageScaler { fatalError() }
            public static func GenerativePlaygroundsUpscaler(variant: String) throws -> any AssetBackedImageScaler { fatalError() }
        }
        public enum ImageSegmenter: Hashable, Sendable {
            case _mock
        }
        public enum ImageSpatialPhotosRelive: Hashable, Sendable {
            case _mock
            public static func FOVEstimatorBuiltin() -> ImageSpatialPhotosRelive { fatalError() }
            public static func SpatialPhotosReliveBuiltin() -> ImageSpatialPhotosRelive { fatalError() }
            public static func FOVEstimatorMain(variant: String) throws -> any AssetBackedImageSpatialPhotosRelive { fatalError() }
            public static func SpatialPhotosReliveMain() -> any AssetBackedImageSpatialPhotosRelive { fatalError() }
            public static func FOVEstimatorBuiltin(variant: String) throws -> ImageSpatialPhotosRelive { fatalError() }
            public static func SpatialPhotosReliveMain(variant: String) throws -> any AssetBackedImageSpatialPhotosRelive { fatalError() }
            public static func FOVEstimatorMain() -> any AssetBackedImageSpatialPhotosRelive { fatalError() }
            public static func SpatialPhotosReliveBuiltin(variant: String) throws -> ImageSpatialPhotosRelive { fatalError() }
        }
        public enum ImageTokenizer: Hashable, Sendable {
            case _mock
            public static func ServerV2AFMImageTokenizer() -> ImageTokenizer { fatalError() }
            public static func AFMImageTokenizer300M() -> any AssetBackedImageTokenizer { fatalError() }
            public static func InstructServerSmallImageTokenizer() -> ImageTokenizer { fatalError() }
            public static func InstructServerSmallImageTokenizer(variant: String) throws -> ImageTokenizer { fatalError() }
            public static func AFMImageEncoder() -> any AssetBackedImageTokenizer { fatalError() }
            public static func InstructServerV2ImageTokenizerZap() -> ImageTokenizer { fatalError() }
            public static func AFMImageTokenizerServer() -> ImageTokenizer { fatalError() }
            public static func AFMImageTokenizer300M(variant: String) throws -> any AssetBackedImageTokenizer { fatalError() }
            public static func AFMImageEncoder(variant: String) throws -> any AssetBackedImageTokenizer { fatalError() }
            public static func ServerV2AFMImageTokenizer(variant: String) throws -> ImageTokenizer { fatalError() }
            public static func InstructServerV2ImageTokenizerZap(variant: String) throws -> ImageTokenizer { fatalError() }
            public static func AFMImageTokenizerServer(variant: String) throws -> ImageTokenizer { fatalError() }
        }
        public enum ImageTokenizerAdapter: Hashable, Sendable {
            case _mock
            public static func VoiceControlAIV2() -> any AssetBackedImageTokenizerAdapter { fatalError() }
            public static func VoiceControlAIV2(variant: String) throws -> any AssetBackedImageTokenizerAdapter { fatalError() }
        }
        public enum LLM: Hashable, Sendable {
            public enum AJAX: Hashable, Sendable {
                case _mock
            }
            public enum Adapter: Hashable, Sendable {
                case _mock
                public static func MMGuardSafetyGuardrail(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV18() -> any LLMAdapter { fatalError() }
                public static func OpenEndedExtractServer(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SmallMessagesReplyWatch() -> any AssetBackedLLMAdapter { fatalError() }
                public static func BulletsTransform() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ContextAwareness() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2SummarizeShortcuts() -> any LLMAdapter { fatalError() }
                public static func Voice2() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PlannerV8(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MailReplyLongFormBasic() -> any AssetBackedLLMAdapter { fatalError() }
                public static func LWPlannerV4() -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV4(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func Nutrition(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func FMAPI(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2ProfessionalTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ShortcutsUseModelActionPro(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SmartNaming(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV18(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AFMTextInstruct3BThirdParty() -> any AssetBackedLLMAdapter { fatalError() }
                public static func UIGrounding() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV17(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2IntelligentPassCreation(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2STXMultimodal() -> any LLMAdapter { fatalError() }
                public static func SafariPhishingClassification(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2AgeEstimation(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2ConciseToneExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2TakeawaysTransformExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ShortcutsUseModelActionPro() -> any LLMAdapter { fatalError() }
                public static func BulletsTransform(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ResponseGenerationV8() -> any LLMAdapter { fatalError() }
                public static func OpenEndedReflection(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AutonamingMessages() -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2_ShortOutput() -> any LLMAdapter { fatalError() }
                public static func ServerV2PromptRewrite(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWPlannerV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SafetyNSFW() -> any LLMAdapter { fatalError() }
                public static func MMGuardSafetyGuardrail() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ASRNaturalDictationSpeech() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PlannerV7() -> any LLMAdapter { fatalError() }
                public static func RemindersSuggestActionItems(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ShortcutsUseModelAction() -> any LLMAdapter { fatalError() }
                public static func ServerV2ImagePlaygroundMultimodalInputSafety(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2Autograder(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2StructuralIntegrity() -> any LLMAdapter { fatalError() }
                public static func ADMPromptRewriting(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2VisualIntelligenceSuggestedQuestions(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SafariSafeBrowsing(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SafariPhishingClassification() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosLibraryUnderstandingT2T() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ConciseTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func FinancialInsights(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func JournalMomentsClassification() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesTitle() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PrepubescentSafetyPCC(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedToneQueryResponseV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MessagesActionSmall(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits() -> any LLMAdapter { fatalError() }
                public static func ServerV2SummarizationTextSummarizer() -> any LLMAdapter { fatalError() }
                public static func PhotosCommon(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func FullPayloadCorrection() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ICloudMailEventExtraction(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ADMBackgroundPrompt() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationAssetCurationV2() -> any LLMAdapter { fatalError() }
                public static func ServerV2MailProfileCreationExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func VIContentClassifier(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PlannerV5(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func OpenEndedSchema(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func JournalMomentsReflection(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ConciseTone() -> any LLMAdapter { fatalError() }
                public static func ServerV2ChangePasswordForMe() -> any LLMAdapter { fatalError() }
                public static func Voice2(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PCCTest() -> any LLMAdapter { fatalError() }
                public static func SmartAppActions(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2BulletsTransform(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationGlobalTraitsV3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2HKSVProcessingCaptionsPro() -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV12(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ASRAFMDictation(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerFitnessWorkoutVoice() -> any LLMAdapter { fatalError() }
                public static func JournalFollowUpPrompts() -> any LLMAdapter { fatalError() }
                public static func SearchQueryUnderstandingServer(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func StructuredExtraction() -> any AssetBackedLLMAdapter { fatalError() }
                public static func AutonamingMessages(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ResponseGenerationV6(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerTakeawaysTransform(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PCCTestFast(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2FriendlyTone() -> any LLMAdapter { fatalError() }
                public static func RemindersSuggestActionItems() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ProfessionalTone() -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServer(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SafetyGuardrail() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PromptRewrite(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SearchQueryUnderstandingServer() -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationStorytellerV2() -> any LLMAdapter { fatalError() }
                public static func LLMSiriDevice(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2TakeawaysTransform(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedExtractWorkflow(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SummarizationTextSummarizerExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SummarizeShortcuts(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func TextSummarizer(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func VoiceControlAIV2(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ProfessionalTone(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2RemindersAutoCategorizeList() -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding3b(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PCCTestPro() -> any LLMAdapter { fatalError() }
                public static func ShortcutsAskAFMAction3B() -> any AssetBackedLLMAdapter { fatalError() }
                public static func VideoCaption() -> any AssetBackedLLMAdapter { fatalError() }
                public static func LLMSiriDevice() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerDescribeYourEdit() -> any LLMAdapter { fatalError() }
                public static func StructuredExtraction(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV2() -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV19() -> any LLMAdapter { fatalError() }
                public static func PCCInteractPro(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2WritingQuestionAnswerExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWPlannerV3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SafariTabGroupTopic(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV6() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2HomeKitSummaryNotifications(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationStorytellerV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SketchCaptioning(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func RemindersAutoCategorizeListOnDevice() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationOutlier3b() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerStructuredExtraction(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerTablesTransform(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV15() -> any LLMAdapter { fatalError() }
                public static func ServerMailReplyQA(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PlannerV9(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MessagesUserRequest() -> any LLMAdapter { fatalError() }
                public static func Summarization(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func LWPlannerV2() -> any LLMAdapter { fatalError() }
                public static func ServerV2FriendlyToneExperiment1() -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SafariMagicExtensions() -> any LLMAdapter { fatalError() }
                public static func GenerativeShortcuts() -> any LLMAdapter { fatalError() }
                public static func PCCInteractFast() -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcuts(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PromptRewrite() -> any LLMAdapter { fatalError() }
                public static func NotifyMeWhen(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2PrepubescentSafety() -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment5(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SummarizationTextSummarizer(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PrepubescentSafetyCustomized() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ProofreadingReview() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PlannerV9() -> any LLMAdapter { fatalError() }
                public static func PCCInteractFast(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func NotifyMeWhen() -> any LLMAdapter { fatalError() }
                public static func ContextAwareness(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2SiriVisualIntelligence(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV13() -> any LLMAdapter { fatalError() }
                public static func SmallMessagesReplyWatch(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ImagePlaygroundMultimodalInputSafety() -> any LLMAdapter { fatalError() }
                public static func ServerSmallActionValidator() -> any LLMAdapter { fatalError() }
                public static func ServerTakeawaysTransform() -> any LLMAdapter { fatalError() }
                public static func PrepubescentSafety() -> any AssetBackedLLMAdapter { fatalError() }
                public static func BaseAdapter() -> any LLMAdapter { fatalError() }
                public static func FullPayloadCorrection(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ConciseToneExperiment1() -> any LLMAdapter { fatalError() }
                public static func GroundedVisualIntelligenceContentClassifier(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2OpenEndedCompose(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedExtract(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PersonalizedSmartReply(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2OpenEndedComposeExperiment1() -> any LLMAdapter { fatalError() }
                public static func OpenEndedSchema() -> any LLMAdapter { fatalError() }
                public static func FriendlyTone(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2OpenEndedInteraction() -> any LLMAdapter { fatalError() }
                public static func ServerV2Autograder() -> any LLMAdapter { fatalError() }
                public static func STXMultimodal() -> any LLMAdapter { fatalError() }
                public static func ShortcutsAskAFMAction(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MagicRewrite() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PlannerV4() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ResponseGeneration(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SmartNaming() -> any AssetBackedLLMAdapter { fatalError() }
                public static func StructuralIntegrityCustomized(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWOnDevicePlannerV1() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2HKSVProcessingCaptions() -> any LLMAdapter { fatalError() }
                public static func PrepubescentSafetyCustomized(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerProofreadingReview(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV2() -> any LLMAdapter { fatalError() }
                public static func SearchQueryUnderstandingOnDevice() -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment4() -> any LLMAdapter { fatalError() }
                public static func OpenEndedInteraction() -> any LLMAdapter { fatalError() }
                public static func MMSafety() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MiscSafetyCustomized() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerConciseTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MailReplyQA(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServer() -> any LLMAdapter { fatalError() }
                public static func OpenEndedTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func EmojiKeywordExtraction() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ModelAbuseGuardrail() -> any LLMAdapter { fatalError() }
                public static func ServerMailReplyLongFormRewrite(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment1() -> any LLMAdapter { fatalError() }
                public static func ProofreadingReview(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ResponseGenerationV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func InstructServerAutograder() -> any LLMAdapter { fatalError() }
                public static func ServerV2ICloudMailEventExtraction() -> any LLMAdapter { fatalError() }
                public static func SpeechToSpeech() -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedCompose() -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding() -> any LLMAdapter { fatalError() }
                public static func ServerMailReplyQA() -> any LLMAdapter { fatalError() }
                public static func Planner() -> any LLMAdapter { fatalError() }
                public static func PlannerV3() -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2() -> any LLMAdapter { fatalError() }
                public static func ServerV2ShortcutsAskAFMActionV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PlannerV3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesTitle(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func FitnessSummary() -> any AssetBackedLLMAdapter { fatalError() }
                public static func BaseAdapter(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ADMPromptAnalyzer() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ADMPromptAnalyzer(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2TablesTransformExperiment1() -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationQueryUnderstandingV3() -> any LLMAdapter { fatalError() }
                public static func TextEventExtraction() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2JournalFollowUpPrompts() -> any LLMAdapter { fatalError() }
                public static func StructuralIntegrity(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV3() -> any LLMAdapter { fatalError() }
                public static func ServerV2ProfessionalToneExperiment1() -> any LLMAdapter { fatalError() }
                public static func ASRAFMDictation() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2AntiSpoofing() -> any LLMAdapter { fatalError() }
                public static func ServerSmallIPIClassifier(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ActionValidator(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ShortcutsAskAFMActionV2() -> any LLMAdapter { fatalError() }
                public static func ServerV2InsightAgents(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PCCInteractWKA() -> any LLMAdapter { fatalError() }
                public static func OpenEndedTone() -> any LLMAdapter { fatalError() }
                public static func ADMBackgroundPrompt(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PromptAnalysis() -> any LLMAdapter { fatalError() }
                public static func ADMPromptRewriting() -> any AssetBackedLLMAdapter { fatalError() }
                public static func OpenEndedToneQueryResponse(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PlannerV8() -> any LLMAdapter { fatalError() }
                public static func ServerMagicRewrite() -> any LLMAdapter { fatalError() }
                public static func ServerMailReplyLongFormRewrite() -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationStorytellerV2() -> any LLMAdapter { fatalError() }
                public static func SummarizeShortcuts(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func StructuralExtraction(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2SketchCaptioning() -> any LLMAdapter { fatalError() }
                public static func ServerV2PrepubescentSafety(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV8(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func Summarization() -> any AssetBackedLLMAdapter { fatalError() }
                public static func SearchQueryUnderstandingServerV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2VisualIntelligenceNutrition() -> any LLMAdapter { fatalError() }
                public static func ServerPersonalizedSmartReply() -> any LLMAdapter { fatalError() }
                public static func Safety(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func TakeawaysTransform(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV16() -> any LLMAdapter { fatalError() }
                public static func ServerV2ICloudMailSemanticSearch() -> any LLMAdapter { fatalError() }
                public static func TablesTransform() -> any AssetBackedLLMAdapter { fatalError() }
                public static func LLMSiriPCC(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func FriendlyTone() -> any AssetBackedLLMAdapter { fatalError() }
                public static func InstructFMApiGeneric() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV21(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedInteractionExperiment1() -> any LLMAdapter { fatalError() }
                public static func SearchQueryUnderstandingServerV2() -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV7(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ConversationTitleSummarization() -> any LLMAdapter { fatalError() }
                public static func ServerV2ICloudMailOrderBundling(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SmartAppActions() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ConciseTone(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedReflection() -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV13(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits3b(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func SuggestRecipeItems() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2JournalFollowUpPrompts(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerBulletsTransform(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWOnDevicePlannerV1(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment3() -> any LLMAdapter { fatalError() }
                public static func PlannerV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func FMAPICli() -> any LLMAdapter { fatalError() }
                public static func TextPersonExtraction() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2VisualIntelligenceNutrition(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2MiscSafety() -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func UIPreviews(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func NewsTopicSummarization() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PCCTestPro(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2ICloudMailOrderBundling() -> any LLMAdapter { fatalError() }
                public static func ServerV2BulletsTransformExperiment1() -> any LLMAdapter { fatalError() }
                public static func ServerProofreadingReview() -> any LLMAdapter { fatalError() }
                public static func ServerV2VisualIntelligenceSuggestedQuestions() -> any LLMAdapter { fatalError() }
                public static func ServerV2BulletsTransform() -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV16(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func VoiceControlAIV2() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2InsightAgents() -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV2() -> any LLMAdapter { fatalError() }
                public static func LWPlannerV5() -> any LLMAdapter { fatalError() }
                public static func UrgencyClassification() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MessagesUserRequest(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWPlannerV4(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2TakeawaysTransformExperiment1() -> any LLMAdapter { fatalError() }
                public static func AFMTextInstruct3BThirdParty(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func SuperAutofillMultimodal() -> any LLMAdapter { fatalError() }
                public static func PCCInteractPro() -> any LLMAdapter { fatalError() }
                public static func TextEventExtraction(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2HKSVProcessingCaptions(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2FitnessWorkoutVoice(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func VIContentClassifier() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ShortcutsAskAFMActionV2() -> any LLMAdapter { fatalError() }
                public static func JournalMomentsClassification(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ShortcutsAskAFMAction3BV2(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func TextPersonExtraction(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func TextExpert(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func SiriTTSVoiceNatural() -> any LLMAdapter { fatalError() }
                public static func MessagesAction(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationOutlier3b(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func MMGuardSafetyGuardrail3B(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationStorytellerV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWPlannerV5(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func Voice() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationGlobalTraitsV3() -> any LLMAdapter { fatalError() }
                public static func MessagesReply() -> any AssetBackedLLMAdapter { fatalError() }
                public static func NewsTopicSummarization(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func MMGuardSafetyGuardrailServer(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func TablesTransform(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV12() -> any LLMAdapter { fatalError() }
                public static func ServerV2TablesTransform(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func DescribeYourEdit(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func InstructServerAutograder(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func InstructBaseAdapter(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2AgeVerification() -> any LLMAdapter { fatalError() }
                public static func PrepubescentSafetyPCC() -> any LLMAdapter { fatalError() }
                public static func ServerV2STXMultimodal(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func StructuralIntegrity() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerFriendlyTone() -> any LLMAdapter { fatalError() }
                public static func PhotosLibraryUnderstandingT2T(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerMagicRewrite(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AccessibilityMagnifier(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationGlobalTraitsV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV15(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2TakeawaysTransform() -> any LLMAdapter { fatalError() }
                public static func GenerativeShortcuts(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AutoTagger() -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment4(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2HomeKitSummaryNotifications() -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationStoryteller3b() -> any AssetBackedLLMAdapter { fatalError() }
                public static func JournalMomentsReflection() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2SummarizationTextSummarizerExperiment1() -> any LLMAdapter { fatalError() }
                public static func OpenEndedInteraction(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PromptAnalysis(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosLibraryUnderstandingMM(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func MessagesActionSmall() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ProofreadingExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWPlannerV1() -> any LLMAdapter { fatalError() }
                public static func ResponseGeneration() -> any LLMAdapter { fatalError() }
                public static func ADMPeopleGrounding(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV19(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PlannerV2() -> any LLMAdapter { fatalError() }
                public static func TextGuardSafetyGuardrail(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2AgeVerification(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func LWPCCInteract() -> any LLMAdapter { fatalError() }
                public static func RemindersAutoCategorizeList() -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationStoryteller3b(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func MailReplyQA() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2MailProfileCreation() -> any LLMAdapter { fatalError() }
                public static func UIPreviews() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MagicRewrite(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PrepubescentSafety(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ICloudMailSemanticSearch(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment2() -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedTone() -> any LLMAdapter { fatalError() }
                public static func ServerV2CalendarMagicComposeBackwardPass() -> any LLMAdapter { fatalError() }
                public static func ServerV2AccessibilityReaderAI(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func VoiceControlAI(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationAssetCuration(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedExtract300m() -> any AssetBackedLLMAdapter { fatalError() }
                public static func IPIClassifier() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ProofreadingExperiment1() -> any LLMAdapter { fatalError() }
                public static func PCCInteractWKA(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2AgeEstimation() -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV5(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func OpenEndedExtract3B(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func MessagesReply(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func LLMSiriPCC() -> any LLMAdapter { fatalError() }
                public static func VideoCaption(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func FMAPICli(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func FactualConsistencyClassifier() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV20() -> any LLMAdapter { fatalError() }
                public static func PlannerV6(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ResponseGenerationV5() -> any AssetBackedLLMAdapter { fatalError() }
                public static func SummarizeShortcuts() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationStoryteller() -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedInteractionExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2SafariSafeBrowsing() -> any LLMAdapter { fatalError() }
                public static func MailReply() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MMGuardSafetyGuardrailServer() -> any LLMAdapter { fatalError() }
                public static func ADMPeopleGrounding() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2IntelligentPassCreation() -> any LLMAdapter { fatalError() }
                public static func UrgencyClassification(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func AutoTagger(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2AccessibilityReaderAI() -> any LLMAdapter { fatalError() }
                public static func FinancialInsights() -> any LLMAdapter { fatalError() }
                public static func SuggestRecipeItems(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func TamalePOI(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func MiscSafety(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2MailProfileCreation(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2TablesTransformExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ContextProgram() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MMTExpert() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ContextProgram(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2OpenEndedInteraction(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func FactualConsistencyClassifier(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2TablesTransform() -> any LLMAdapter { fatalError() }
                public static func ServerV2SiriVisualIntelligence() -> any LLMAdapter { fatalError() }
                public static func SafetyNSFW(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ActionValidator() -> any AssetBackedLLMAdapter { fatalError() }
                public static func LWPlannerV1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MachineTranslation(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func VoiceControlAI() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcuts() -> any LLMAdapter { fatalError() }
                public static func ServerV2SafariTabGroupTopic() -> any LLMAdapter { fatalError() }
                public static func ServerV2FriendlyTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MailReplyLongFormRewrite(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV21() -> any LLMAdapter { fatalError() }
                public static func FMAPI() -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MessagesReplyWatch() -> any AssetBackedLLMAdapter { fatalError() }
                public static func InstructBaseAdapter() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerPQAVerification() -> any LLMAdapter { fatalError() }
                public static func ConversationTitleSummarization(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationV2() -> any LLMAdapter { fatalError() }
                public static func ServerPQAVerification(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerBulletsTransform() -> any LLMAdapter { fatalError() }
                public static func GroundedVisualIntelligenceContentClassifier() -> any AssetBackedLLMAdapter { fatalError() }
                public static func DescribeYourEdit() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ConciseTone() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MailReplyLongFormBasic(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV14(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedExtractServer() -> any LLMAdapter { fatalError() }
                public static func LWPlannerV3() -> any LLMAdapter { fatalError() }
                public static func ServerV2FitnessWorkoutVoice() -> any LLMAdapter { fatalError() }
                public static func MiscSafetyCustomized(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func IPIClassifier(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerStructuredExtraction() -> any LLMAdapter { fatalError() }
                public static func ServerV2PromptRewrite() -> any LLMAdapter { fatalError() }
                public static func MMSafety(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PlannerV4(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2ProfessionalToneExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedExtract() -> any LLMAdapter { fatalError() }
                public static func StructuralExtraction() -> any AssetBackedLLMAdapter { fatalError() }
                public static func Safety() -> any AssetBackedLLMAdapter { fatalError() }
                public static func TamalePOI() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2CalendarMagicComposeBackwardPass(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedCompose() -> any LLMAdapter { fatalError() }
                public static func PlannerV5() -> any AssetBackedLLMAdapter { fatalError() }
                public static func OpenEndedToneQueryResponse() -> any LLMAdapter { fatalError() }
                public static func TextGuardSafetyGuardrail() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ASRNaturalDictationSpeech(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerSmallIPIClassifier() -> any LLMAdapter { fatalError() }
                public static func ServerV2Proofreading(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SummarizationTextSummarizer(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesis(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func RemindersAutoCategorizeListOnDevice(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func JournalFollowUpPrompts(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PlannerV6() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerSmallActionValidator(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PlannerV7(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MessagesAction() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PCCTest(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ShortcutsAskAFMAction() -> any LLMAdapter { fatalError() }
                public static func ServerV2SafariMagicExtensions(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2ProfessionalTone() -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func TextExpert() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2WritingQuestionAnswer(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerProfessionalTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func StructuralIntegrityPCC() -> any LLMAdapter { fatalError() }
                public static func MMGuardSafetyGuardrail3B() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PQAVerification() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosCommon() -> any LLMAdapter { fatalError() }
                public static func ServerDescribeYourEdit(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ImagePlaygroundEditSuggestions(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2HKSVProcessingCaptionsPro(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SiriTTSVoiceNatural(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2BulletsTransformExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2OpenEndedComposeExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SearchQueryUnderstandingOnDevice(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerProfessionalTone() -> any LLMAdapter { fatalError() }
                public static func ServerV2ShortcutsUseModelAction(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV7() -> any LLMAdapter { fatalError() }
                public static func UIGrounding(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV17() -> any LLMAdapter { fatalError() }
                public static func MachineTranslation() -> any AssetBackedLLMAdapter { fatalError() }
                public static func STXMultimodal(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func StructuralIntegrityCustomized() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MiscSafety() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MiscSafetyPCC() -> any LLMAdapter { fatalError() }
                public static func FitnessSummary(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2_ShortOutput(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func Nutrition() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding3b() -> any AssetBackedLLMAdapter { fatalError() }
                public static func SpeechToSpeech(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationAssetCuration() -> any LLMAdapter { fatalError() }
                public static func MMTExpert(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV3() -> any LLMAdapter { fatalError() }
                public static func AccessibilityMagnifier() -> any LLMAdapter { fatalError() }
                public static func ServerV2StructuralIntegrity(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerMailReplyLongFormBasic(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ModelAbuseGuardrail(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedExtractWorkflow() -> any LLMAdapter { fatalError() }
                public static func ServerV2WritingQuestionAnswerExperiment1() -> any LLMAdapter { fatalError() }
                public static func LWPCCInteract(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func SuperAutofillMultimodal(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV14() -> any LLMAdapter { fatalError() }
                public static func ImagePlaygroundEditSuggestions() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2MailProfileCreationExperiment1() -> any LLMAdapter { fatalError() }
                public static func ServerV2FriendlyToneExperiment1(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerConciseTone() -> any LLMAdapter { fatalError() }
                public static func MiscSafetyPCC(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2AntiSpoofing(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerFitnessWorkoutVoice(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2WritingQuestionAnswer() -> any LLMAdapter { fatalError() }
                public static func ResponseGenerationV3() -> any LLMAdapter { fatalError() }
                public static func ServerPersonalizedSmartReply(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedExtract300m(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ShortcutsAskAFMAction3B(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func SummarizationTextSummarizer() -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationGlobalTraitsV2() -> any LLMAdapter { fatalError() }
                public static func ServerV2Proofreading() -> any LLMAdapter { fatalError() }
                public static func AnswerSynthesis() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ResponseGenerationV4() -> any AssetBackedLLMAdapter { fatalError() }
                public static func TextSummarizer() -> any AssetBackedLLMAdapter { fatalError() }
                public static func AnswerSynthesisServerV2Experiment5() -> any LLMAdapter { fatalError() }
                public static func PhotosLibraryUnderstandingMM() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits3b() -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerV2AccessibilityMagnifier() -> any LLMAdapter { fatalError() }
                public static func ServerMailReplyLongFormBasic() -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationQueryUnderstandingV3(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2PhotosMemoriesCreationAssetCurationV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2AccessibilityMagnifier(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2MiscSafety(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2GenerativeShortcutsV20(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ShortcutsAskAFMActionV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func EmojiKeywordExtraction(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func Planner(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func MessagesReplyWatch(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PersonalizedSmartReply() -> any AssetBackedLLMAdapter { fatalError() }
                public static func OpenEndedToneQueryResponseV2() -> any LLMAdapter { fatalError() }
                public static func MailReplyLongFormRewrite() -> any AssetBackedLLMAdapter { fatalError() }
                public static func MailReply(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func OpenEndedCompose(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func OpenEndedExtract3B() -> any AssetBackedLLMAdapter { fatalError() }
                public static func RemindersAutoCategorizeList(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func InstructFMApiGeneric(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerFriendlyTone(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PCCTestFast() -> any LLMAdapter { fatalError() }
                public static func SafetyGuardrail(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func ServerTablesTransform() -> any LLMAdapter { fatalError() }
                public static func TakeawaysTransform() -> any AssetBackedLLMAdapter { fatalError() }
                public static func StructuralIntegrityPCC(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2ChangePasswordForMe(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ShortcutsAskAFMAction3BV2() -> any AssetBackedLLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationStoryteller(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func ServerV2RemindersAutoCategorizeList(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV2(variant: String) throws -> any LLMAdapter { fatalError() }
                public static func Voice(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
                public static func PQAVerification(variant: String) throws -> any AssetBackedLLMAdapter { fatalError() }
            }
            public enum AdapterMetadataOverride: Hashable, Sendable {
                case _mock
                public static func SafariMagicExtensionsAppStoreSearchTerms() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SafariTabGroupTopic() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func HoldAssistWaitTime() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func HoldAssistWaitTime(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func ContentTagger() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func HomeKitSummaryNotifications(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func RemindersGroceryList(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func ContentTagger(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func PhotosMemoriesTitle(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SafariTabGroupTopic(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SafariClusterValidation() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func ShortcutsAskAFMAction3B(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SafariClusterValidation(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func ShortcutsAskAFMAction3B() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func PhotosMemoriesTitle() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SiriUserExperienceAnalysis() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func HomeKitSummaryNotifications() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SafariNotifyMeWhenSuggestions(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SafariNotifyMeWhenSuggestions() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SafariMagicExtensionsAppStoreSearchTerms(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func RemindersGroceryList() -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
                public static func SiriUserExperienceAnalysis(variant: String) throws -> any AssetBackedLLMAdapterMetadataOverride { fatalError() }
            }
            public enum DraftModel: Hashable, Sendable {
                case _mock
                public static func PersonalizedSmartReply() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationOutlier3b() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ADMPromptRewriting() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerStructuredExtraction(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationV2() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV3(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func TablesTransform() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func AnswerSynthesisServer() -> any LLMDraftModel { fatalError() }
                public static func CodeLMLargeV5(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func RemindersAutoCategorizeList(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func MailReplyLongFormBasic() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerMailReplyLongFormBasic(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ResponseGeneration(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func RemindersAutoCategorizeList() -> any LLMDraftModel { fatalError() }
                public static func ServerBulletsTransform() -> any LLMDraftModel { fatalError() }
                public static func ConciseTone(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PromptRewrite() -> any LLMDraftModel { fatalError() }
                public static func SuggestRecipeItems() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func UIPreviews(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMLargeV2(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func Textunderstanding(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SearchQueryUnderstandingOnDevice() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMLargeV3() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func InstructFMApiGeneric(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerFitnessWorkoutVoice() -> any LLMDraftModel { fatalError() }
                public static func FriendlyTone() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func MagicRewrite() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func RemindersAutoCategorizeListOnDevice() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLM(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedInteraction(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PlannerV6() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func LWPlannerV1(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func MailReplyLongFormBasic(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func JournalFollowUpPrompts(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func BulletsTransform() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerTablesTransform(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding3b() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func TextPersonExtraction(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerTakeawaysTransform() -> any LLMDraftModel { fatalError() }
                public static func MessagesReply() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV8() -> any LLMDraftModel { fatalError() }
                public static func JournalMomentsReflection() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedInteraction() -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtractServer(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ResponseGenerationV4(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGeneration() -> any LLMDraftModel { fatalError() }
                public static func MessagesReply(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMAction3BV2(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SummarizeShortcuts(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func LWPlannerV2() -> any LLMDraftModel { fatalError() }
                public static func OpenEndedSchema(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func MachineTranslation(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV5() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func GenerativeShortcuts(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func SummarizeShortcuts() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMSmallV5(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMLargeV1() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMAction() -> any LLMDraftModel { fatalError() }
                public static func ServerProfessionalTone(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func TakeawaysTransform() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits3b() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMSmallV2() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMSmallV3() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerConciseTone() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV3() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding3b(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedSchema() -> any LLMDraftModel { fatalError() }
                public static func MailReply() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV4(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func LWPlannerV1() -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtractServer() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV3(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func Textunderstanding() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func LWPlannerV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits() -> any LLMDraftModel { fatalError() }
                public static func ServerTakeawaysTransform(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func FriendlyTone(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func JournalMomentsClassification() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV6(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerMagicRewrite(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ConciseTone() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SearchQueryUnderstandingServer() -> any LLMDraftModel { fatalError() }
                public static func LWOnDevicePlannerV1() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationStoryteller3b() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV3(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ResponseGenerationV4() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedTone() -> any LLMDraftModel { fatalError() }
                public static func AFMTextInstruct3BThirdParty() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func SummarizationTextSummarizer() -> any LLMDraftModel { fatalError() }
                public static func InstructFMApiThirdPartyCompileDraft() -> any LLMDraftModel { fatalError() }
                public static func CodeLMSmallV3(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func Summarization() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV3(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PlannerV7(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func InstructServerV2DraftZap() -> any LLMDraftModel { fatalError() }
                public static func ServerPersonalizedSmartReply(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ServerMailReplyLongFormRewrite() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ResponseGenerationV6() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func AnswerSynthesisServer(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV2() -> any LLMDraftModel { fatalError() }
                public static func TextExpert() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerBulletsTransform(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PlannerV8(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func InstructFMApiThirdPartyCompileDraft(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ServerProofreadingReview() -> any LLMDraftModel { fatalError() }
                public static func MailReplyQA(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationStoryteller() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationStoryteller(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationStorytellerV2() -> any LLMDraftModel { fatalError() }
                public static func LWOnDevicePlannerV1(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMV1ANE3B(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func TextPersonExtraction() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func InstructBaseDraftModel() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func Summarization(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMAction3BV2() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func MMTExpert(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMAction(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func SafetyGuardrail() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PromptAnalysis(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ResponseGenerationV2() -> any LLMDraftModel { fatalError() }
                public static func JournalMomentsReflection(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SuperAutofillMultimodal(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PlannerV5(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV7(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosCommon(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ProofreadingReview(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func STXMultimodal() -> any LLMDraftModel { fatalError() }
                public static func JournalMomentsClassification(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SuggestRecipeItems(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV7() -> any LLMDraftModel { fatalError() }
                public static func AutonamingMessages() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func RemindersSuggestActionItems(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationStorytellerV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func STXMultimodal(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ResponseGenerationV5(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMSmallV1(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func TextSummarizer() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV6(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedReflection() -> any LLMDraftModel { fatalError() }
                public static func MagicRewrite(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SmartAppActions() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtract3B() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func TextEventExtraction(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PersonalizedSmartReply(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMAction3B(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func AnswerSynthesis() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosCommon() -> any LLMDraftModel { fatalError() }
                public static func PlannerV2() -> any LLMDraftModel { fatalError() }
                public static func PlannerV5() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMSmallV5() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func InstructServerV2DraftModel() -> any LLMDraftModel { fatalError() }
                public static func Planner(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func MMTExpert() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMLargeV1(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerMailReplyLongFormRewrite(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func GenerativeShortcuts() -> any LLMDraftModel { fatalError() }
                public static func MailReplyLongFormRewrite() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMV1ANE3B() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func LLMSiriDevice() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedCompose(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func SafetyGuardrail(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedTone(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ServerMailReplyQA() -> any LLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMActionV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationStoryteller3b(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func MailReplyLongFormRewrite(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ProfessionalTone(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func LLMSiriPCC(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV2() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesTitle(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMSmallV2(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func InstructFMApiGeneric() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerFriendlyTone(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func CodeLMLargeV2() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV3() -> any LLMDraftModel { fatalError() }
                public static func MessagesUserRequest() -> any LLMDraftModel { fatalError() }
                public static func ServerMailReplyQA(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func MailReplyQA() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerStructuredExtraction() -> any LLMDraftModel { fatalError() }
                public static func AFMTextInstruct3BThirdParty(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedCompose() -> any LLMDraftModel { fatalError() }
                public static func TextExpert(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMLargeV3(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV3() -> any LLMDraftModel { fatalError() }
                public static func LLMSiriDevice(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV8(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func MessagesAction(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func StructuredExtraction() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ProofreadingReview() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func MailReply(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ADMPromptRewriting(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func TakeawaysTransform(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func LLMSiriPCC() -> any LLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMAction3B() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func OpenEndedReflection(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func SearchQueryUnderstandingOnDevice(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func NewsTopicSummarization() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMLargeV4(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerProofreadingReview(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ServerFriendlyTone() -> any LLMDraftModel { fatalError() }
                public static func ServerPersonalizedSmartReply() -> any LLMDraftModel { fatalError() }
                public static func CodeLMSmallV1() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SearchQueryUnderstandingServer(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationAssetCuration() -> any LLMDraftModel { fatalError() }
                public static func CodeLM() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PromptAnalysis() -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtract3B(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func NewsTopicSummarization(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func AnswerSynthesis(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func RemindersAutoCategorizeListOnDevice(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits3b(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV8() -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtract300m() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesTitle() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func TextEventExtraction() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerMailReplyLongFormBasic() -> any LLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding() -> any LLMDraftModel { fatalError() }
                public static func JournalFollowUpPrompts() -> any LLMDraftModel { fatalError() }
                public static func UIPreviews() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerMagicRewrite() -> any LLMDraftModel { fatalError() }
                public static func ServerTablesTransform() -> any LLMDraftModel { fatalError() }
                public static func ServerConciseTone(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ServerProfessionalTone() -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtractWorkflow(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtract300m(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV3() -> any LLMDraftModel { fatalError() }
                public static func StructuredExtraction(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ShortcutsAskAFMActionV2() -> any LLMDraftModel { fatalError() }
                public static func OpenEndedExtractWorkflow() -> any LLMDraftModel { fatalError() }
                public static func CodeLMSmallV4(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SuperAutofillMultimodal() -> any LLMDraftModel { fatalError() }
                public static func SummarizationTextSummarizer(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ProfessionalTone() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func MachineTranslation() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV9(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func CodeLMLargeV5() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PlannerV9() -> any LLMDraftModel { fatalError() }
                public static func InstructBaseDraftModel(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func CodeLMLargeV4() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func SmartAppActions(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ContextProgram(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func AutonamingMessages(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationOutlier3b(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func TextSummarizer(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ResponseGenerationV2(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func CodeLMSmallV4() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func MessagesUserRequest(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func RemindersSuggestActionItems() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func InstructServerV2DraftModel(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func TablesTransform(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func BulletsTransform(variant: String) throws -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PhotosMemoriesCreationAssetCuration(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func MessagesAction() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func PromptRewrite(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func ContextProgram() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func ServerFitnessWorkoutVoice(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func Planner() -> any LLMDraftModel { fatalError() }
                public static func PlannerV4() -> any AssetBackedLLMDraftModel { fatalError() }
                public static func InstructServerV2DraftZap(variant: String) throws -> any LLMDraftModel { fatalError() }
                public static func PlannerV7() -> any LLMDraftModel { fatalError() }
            }
            public enum Model: Hashable, Sendable {
                case _mock
                public static func DistilledMessagesAction(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMV4() -> any AssetBackedLLMModel { fatalError() }
                public static func MMTExpert() -> any AssetBackedLLMModel { fatalError() }
                public static func PQAVerificationBase() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMSmallV3(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMLargeV3() -> any AssetBackedLLMModel { fatalError() }
                public static func PQAVerificationBase(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func NLRouterBase() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMLargeV2() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMV3() -> any AssetBackedLLMModel { fatalError() }
                public static func GMSPrototypeEmbeddingsBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func CodeLMSmallV1() -> any AssetBackedLLMModel { fatalError() }
                public static func PhotosMemoriesCreationBase() -> any LLMModel { fatalError() }
                public static func CodeLMSmallV5(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMSmallV1(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMLargeV1() -> any AssetBackedLLMModel { fatalError() }
                public static func GMSPrototypeEmbeddingsBase() -> any LLMModel { fatalError() }
                public static func InstructServerBase() -> any LLMModel { fatalError() }
                public static func CodeLM(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMLargeV5(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func AFMTextInstruct85MBase(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func SpeechToSpeechBase() -> any LLMModel { fatalError() }
                public static func CodeLMSmallV2() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMLargeV1(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func DistilledMessagesReply() -> any AssetBackedLLMModel { fatalError() }
                public static func DistilledMessagesAction() -> any AssetBackedLLMModel { fatalError() }
                public static func InstructServerV2BasePro() -> any LLMModel { fatalError() }
                public static func SummarizationTextSummarizerAjaxBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func CodeLMExperimental() -> any AssetBackedLLMModel { fatalError() }
                public static func InstructServerV2BaseZap() -> any LLMModel { fatalError() }
                public static func PhotosMemoriesCreationBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func CodeLMV3(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMSafetyGuardrail() -> any AssetBackedLLMModel { fatalError() }
                public static func DistilledMessagesReply(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func AFMTextInstruct300MBase() -> any AssetBackedLLMModel { fatalError() }
                public static func TextEventExtractionClassifier(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func AFMTextInstruct3BBase(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMSmallV5() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeSafetyGuardrail(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func ExternalSearchPartner(variant: String) throws -> any LLMModel { fatalError() }
                public static func CodeLMSmallV3() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMSmallV4(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMV4(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMLargeV5() -> any AssetBackedLLMModel { fatalError() }
                public static func VisualGenerationQueryHandlingLite(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMV2() -> any AssetBackedLLMModel { fatalError() }
                public static func GMSPrototypeBase() -> any LLMModel { fatalError() }
                public static func AFMTextInstruct3BBase() -> any AssetBackedLLMModel { fatalError() }
                public static func FoundationModelsPlatformBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func MMTExpert(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMV1ANE3B(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func SpeechSynthesisV7() -> any LLMModel { fatalError() }
                public static func VisualGenerationQueryHandlingLite() -> any AssetBackedLLMModel { fatalError() }
                public static func SpeechToSpeechBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func CodeLMSmallV4() -> any AssetBackedLLMModel { fatalError() }
                public static func InstructServerV2BasePro(variant: String) throws -> any LLMModel { fatalError() }
                public static func TextEventExtractionClassifier() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMLargeV3(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func SummarizationTextSummarizerAjaxBase() -> any LLMModel { fatalError() }
                public static func CodeLMLargeV2(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func SpeechSynthesisV7(variant: String) throws -> any LLMModel { fatalError() }
                public static func CodeLMLargeV4() -> any AssetBackedLLMModel { fatalError() }
                public static func InstructServerSmallBase() -> any LLMModel { fatalError() }
                public static func InstructServerBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func FoundationModelsPlatformBase() -> any LLMModel { fatalError() }
                public static func ExternalSearchPartner() -> any LLMModel { fatalError() }
                public static func CodeLMLargeV4(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func GMSPrototypeBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func ChatGPT() -> any LLMModel { fatalError() }
                public static func CodeSafetyGuardrail() -> any AssetBackedLLMModel { fatalError() }
                public static func InstructServerV2BaseZap(variant: String) throws -> any LLMModel { fatalError() }
                public static func NLRouterBase(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMSafetyGuardrail(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMExperimental(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func InstructServerV2PlannerBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func SummarizationTextSummarizerBase(variant: String) throws -> any LLMModel { fatalError() }
                public static func InstructServerV2PlannerBase() -> any LLMModel { fatalError() }
                public static func AFMTextInstruct85MBase() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMSmallV2(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func AFMTextInstruct300MBase(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func SummarizationTextSummarizerBase() -> any LLMModel { fatalError() }
                public static func CodeLM() -> any AssetBackedLLMModel { fatalError() }
                public static func CodeLMV1ANE3B() -> any AssetBackedLLMModel { fatalError() }
                public static func ChatGPT(variant: String) throws -> any LLMModel { fatalError() }
                public static func CodeLMV2(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func InstructServerSmallBase(variant: String) throws -> any LLMModel { fatalError() }
            }
            public enum ServerConfiguration: Hashable, Sendable {
                case _mock
                public static func PlannerV9() -> any AssetBackedServerConfiguration { fatalError() }
                public static func SearchQueryUnderstandingServer() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedToneBase(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedReflection(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerPQAVerification(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func LLMSiriPCC(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedSchema() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMagicRewrite(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func LWPlannerV4(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func LWPlannerV1(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SpeechToSpeech(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ShortcutsAskAFMActionV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationStoryteller() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerProfessionalTone(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerTablesTransform(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV9(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerV2MiscSafety(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerFriendlyTone() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedToneQueryResponse() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV8() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGeneration(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationBase(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerV2PromptRewrite() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationStorytellerV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func NLRouterBase() -> any AssetBackedServerConfiguration { fatalError() }
                public static func MessagesUserRequest() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerDescribeYourEdit() -> any AssetBackedServerConfiguration { fatalError() }
                public static func SearchQueryUnderstandingServer(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SafetyNSFW(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMailReplyLongFormBasic() -> any AssetBackedServerConfiguration { fatalError() }
                public static func STXMultimodal(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerFriendlyTone(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerBulletsTransform(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV7() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedCompose() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosCommon(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SuperAutofillMultimodal(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGeneration() -> any AssetBackedServerConfiguration { fatalError() }
                public static func JournalFollowUpPrompts(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedTone() -> any AssetBackedServerConfiguration { fatalError() }
                public static func MMGuardSafetyGuardrailServer() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerV2MiscSafety() -> any AssetBackedServerConfiguration { fatalError() }
                public static func SpeechToSpeech() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerV2PromptRewrite(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMailReplyLongFormRewrite() -> any AssetBackedServerConfiguration { fatalError() }
                public static func StructuralIntegrityPCC(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedToneBase() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedCompose(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerProfessionalTone() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV3(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerProofreadingReview(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosCommon() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstandingV3() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerTakeawaysTransform() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV7() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV8() -> any AssetBackedServerConfiguration { fatalError() }
                public static func MMGuardSafetyGuardrailServer(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func AnswerSynthesisServer(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PromptAnalysis() -> any AssetBackedServerConfiguration { fatalError() }
                public static func MessagesUserRequest(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationBase() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV3() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV3(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SpeechSynthesisV7Base() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedToneQueryResponse(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerSmallIPIClassifier(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func InstructServerBase(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMailReplyQA() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV7(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func AnswerSynthesisServer() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerTakeawaysTransform(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationAssetCuration(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding() -> any AssetBackedServerConfiguration { fatalError() }
                public static func InstructServerAutograder() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PrepubescentSafetyPCC() -> any AssetBackedServerConfiguration { fatalError() }
                public static func SummarizationTextSummarizer(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SummarizationTextSummarizer() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedExtractServerText(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerFitnessWorkoutVoice() -> any AssetBackedServerConfiguration { fatalError() }
                public static func MiscSafetyPCC(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func MiscSafetyPCC() -> any AssetBackedServerConfiguration { fatalError() }
                public static func SummarizationTextSummarizerAjaxBase() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMailReplyLongFormBasic(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func Planner() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMailReplyQA(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PrepubescentSafetyPCC(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SuperAutofillMultimodal() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationStoryteller(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func JournalFollowUpPrompts() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedToneQueryResponseV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func VisualIntelligence() -> any AssetBackedServerConfiguration { fatalError() }
                public static func NLRouterBase(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerDescribeYourEdit(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func GenerativeShortcuts(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ShortcutsAskAFMActionV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func LWPlannerV1() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedToneQueryResponseV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedSchema(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ShortcutsAskAFMAction(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PrivateCloudResearchAdapter(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func RemindersAutoCategorizeList(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func FinancialInsights(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerPersonalizedSmartReply() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerSmallActionValidator() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMagicRewrite() -> any AssetBackedServerConfiguration { fatalError() }
                public static func AccessibilityMagnifier(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedExtractServer(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func AccessibilityMagnifier() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedExtractWorkflow() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerConciseTone(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PromptRewrite(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func LLMSiriPCC() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ModelAbuseGuardrail() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerV2ImagePlaygroundMultimodalInputSafety() -> any AssetBackedServerConfiguration { fatalError() }
                public static func StructuralIntegrityPCC() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerPersonalizedSmartReply(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SummarizationTextSummarizerAjaxBase(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraitsV3(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerStructuredExtraction() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerSmallIPIClassifier() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedComposeWorkflow(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PromptRewrite() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedInteraction(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PrivateCloudResearchAdapter() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerProofreadingReview() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ModelAbuseGuardrail(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func InstructServerBase() -> any AssetBackedServerConfiguration { fatalError() }
                public static func LWPlannerV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerSmallActionValidator(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerTablesTransform() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedComposeWorkflow() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationStorytellerV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedInteraction() -> any AssetBackedServerConfiguration { fatalError() }
                public static func SafetyNSFW() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV8(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func RemindersAutoCategorizeList() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits() -> any AssetBackedServerConfiguration { fatalError() }
                public static func GenerativeShortcuts() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV3() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PromptAnalysis(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV2(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedExtractWorkflow(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func FinancialInsights() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerMailReplyLongFormRewrite(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerV2ImagePlaygroundMultimodalInputSafety(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV3(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func VisualIntelligence(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func STXMultimodal() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerStructuredExtraction(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func LWPlannerV4() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ShortcutsAskAFMAction() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedTone(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV3() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV7(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func SpeechSynthesisV7Base(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerBulletsTransform() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedExtractServerText() -> any AssetBackedServerConfiguration { fatalError() }
                public static func Planner(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerPQAVerification() -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedReflection() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerConciseTone() -> any AssetBackedServerConfiguration { fatalError() }
                public static func InstructServerAutograder(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func OpenEndedExtractServer() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ResponseGenerationV2() -> any AssetBackedServerConfiguration { fatalError() }
                public static func PhotosMemoriesCreationAssetCuration() -> any AssetBackedServerConfiguration { fatalError() }
                public static func ServerFitnessWorkoutVoice(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func PlannerV8(variant: String) throws -> any AssetBackedServerConfiguration { fatalError() }
                public static func LWPlannerV2() -> any AssetBackedServerConfiguration { fatalError() }
            }
            case _mock
        }
        public enum ModelConfigurationReplacement: Hashable, Sendable {
            case _mock
            public static func All(variant: String) throws -> any AssetBackedModelConfigurationReplacement { fatalError() }
            public static func All() -> any AssetBackedModelConfigurationReplacement { fatalError() }
        }
        public enum Motion: Hashable, Sendable {
            public enum Adapter: Hashable, Sendable {
                case _mock
                public static func CoreMotionCalorimetryFMPredictedWRMets(variant: String) throws -> any AssetBackedMotionAdapter { fatalError() }
                public static func CoreMotionCalorimetryReducedEmbeddings() -> any AssetBackedMotionAdapter { fatalError() }
                public static func MotionAnomalyFMAdapter() -> any AssetBackedMotionAdapter { fatalError() }
                public static func CoreMotionCalorimetryFMPredictedWRMets() -> any AssetBackedMotionAdapter { fatalError() }
                public static func CoreMotionCalorimetryReducedEmbeddings(variant: String) throws -> any AssetBackedMotionAdapter { fatalError() }
                public static func MotionAnomalyFMAdapter(variant: String) throws -> any AssetBackedMotionAdapter { fatalError() }
            }
            public enum Model: Hashable, Sendable {
                case _mock
                public static func Pednet(variant: String) throws -> Motion { fatalError() }
                public static func MotionAnomalyFM(variant: String) throws -> any AssetBackedMotion { fatalError() }
                public static func Pednet() -> Motion { fatalError() }
                public static func CoreMotionIMUFoundationModel() -> any AssetBackedMotion { fatalError() }
                public static func CoreMotionIMUFoundationModel(variant: String) throws -> any AssetBackedMotion { fatalError() }
                public static func MotionAnomalyFM() -> any AssetBackedMotion { fatalError() }
            }
            case _mock
        }
        public enum PCCGenericInference: Hashable, Sendable {
            case _mock
            public static func PCCInferenceProvider() -> PCCGenericInference { fatalError() }
            public static func PCCInferenceProvider(variant: String) throws -> PCCGenericInference { fatalError() }
        }
        public enum PromptAllowList: Hashable, Sendable {
            case _mock
            public static func DeltaLexiconInputPromptAllowList(variant: String) throws -> any AssetBackedPromptAllowList { fatalError() }
            public static func DeltaLexiconInputPromptAllowList() -> any AssetBackedPromptAllowList { fatalError() }
        }
        public struct ResourceMetadata: Codable, Hashable, Sendable {
            public init(from decoder: any Decoder) throws {}
            public func encode(to encoder: Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public enum SafetyOutputConfiguration: Hashable, Sendable {
            case _mock
            public static func SafetyOutputConfiguration(variant: String) throws -> any AssetBackedSafetyOutputConfiguration { fatalError() }
            public static func SafetyOutputConfigurationNSFW(variant: String) throws -> any AssetBackedSafetyOutputConfiguration { fatalError() }
            public static func SafetyOutputConfigurationNSFW() -> any AssetBackedSafetyOutputConfiguration { fatalError() }
            public static func SafetyOutputConfigurationMMGuard(variant: String) throws -> any AssetBackedSafetyOutputConfiguration { fatalError() }
            public static func SafetyOutputConfigurationMMGuard() -> any AssetBackedSafetyOutputConfiguration { fatalError() }
            public static func SafetyOutputConfiguration() -> any AssetBackedSafetyOutputConfiguration { fatalError() }
        }
        public enum SecureAnalytics: Hashable, Sendable {
            public enum Model: Hashable, Sendable {
                case _mock
                public static func IntegrityDiagnoseModel() -> SecureAnalytics { fatalError() }
                public static func IntegrityDiagnoseModel(variant: String) throws -> SecureAnalytics { fatalError() }
            }
            case _mock
        }
        public enum ServerDiffusion: Hashable, Sendable {
            public enum ANFREncoder: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionANFREncoder() -> any ServerDiffusionANFREncoder { fatalError() }
                public static func ServerDiffusionANFREncoderLargeImage() -> any ServerDiffusionANFREncoder { fatalError() }
                public static func ServerDiffusionANFREncoderV11_1() -> any ServerDiffusionANFREncoder { fatalError() }
                public static func ServerDiffusionANFREncoderV11_1(variant: String) throws -> any ServerDiffusionANFREncoder { fatalError() }
                public static func ServerDiffusionANFREncoder(variant: String) throws -> any ServerDiffusionANFREncoder { fatalError() }
                public static func ServerDiffusionANFREncoderLargeImage(variant: String) throws -> any ServerDiffusionANFREncoder { fatalError() }
            }
            public enum Adapter: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionOutpaintingSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDrawingConditioner(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionUpResolution(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDirectManipulationLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDrawingConditionerLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionSpatialReframingSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionPersonalization() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDirectManipulation(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDirectManipulationLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDrawingConditionerSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDrawingConditionerSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionSpatialReframing() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionInpaintingLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionMessagesBackground() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDirectManipulationSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionUpResolutionLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionSpatialReframingLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionUpResolutionLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionPersonalizationLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionPersonalizationSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionMessagesBackgroundSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionInpaintingSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionOutpainting(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionInpaintingLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionPersonalizationSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionMessagesBackgroundLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionMessagesBackgroundSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionUpResolution() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDirectManipulation() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionSpatialReframingSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDrawingConditionerLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionOutpaintingLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDirectManipulationSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionInpainting() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionInpainting(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionMessagesBackgroundLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionDrawingConditioner() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionPersonalization(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionMessagesBackground(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionOutpaintingLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionOutpainting() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionSpatialReframingLargeImage() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionInpaintingSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionOutpaintingSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionSpatialReframing(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionUpResolutionSmallV11_1() -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionPersonalizationLargeImage(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
                public static func ServerDiffusionUpResolutionSmallV11_1(variant: String) throws -> any ServerDiffusionAdapter { fatalError() }
            }
            public enum AlphaMaskDecoder: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionAlphaMaskDecoderLargeImage() -> any ServerDiffusionAlphaMaskDecoder { fatalError() }
                public static func ServerDiffusionAlphaMaskDecoderV11_1(variant: String) throws -> any ServerDiffusionAlphaMaskDecoder { fatalError() }
                public static func ServerDiffusionAlphaMaskDecoder(variant: String) throws -> any ServerDiffusionAlphaMaskDecoder { fatalError() }
                public static func ServerDiffusionAlphaMaskDecoderV11_1() -> any ServerDiffusionAlphaMaskDecoder { fatalError() }
                public static func ServerDiffusionAlphaMaskDecoder() -> any ServerDiffusionAlphaMaskDecoder { fatalError() }
                public static func ServerDiffusionAlphaMaskDecoderLargeImage(variant: String) throws -> any ServerDiffusionAlphaMaskDecoder { fatalError() }
            }
            public enum AutoEncoder: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionAutoEncoder(variant: String) throws -> any ServerDiffusionAutoEncoder { fatalError() }
                public static func ServerDiffusionAutoEncoderV10(variant: String) throws -> any ServerDiffusionAutoEncoder { fatalError() }
                public static func ServerDiffusionAutoEncoder() -> any ServerDiffusionAutoEncoder { fatalError() }
                public static func ServerDiffusionAutoEncoderV10() -> any ServerDiffusionAutoEncoder { fatalError() }
            }
            public enum ImageTokenizer: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionTextGuidedEditImageTokenizer() -> any ServerDiffusionImageTokenizer { fatalError() }
                public static func ServerDiffusionTextGuidedEditImageTokenizer(variant: String) throws -> any ServerDiffusionImageTokenizer { fatalError() }
            }
            public enum NoisePredictor: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionNoisePredictorV10(variant: String) throws -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionNoisePredictorV11_1() -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionTextGuidedEditNoisePredictor() -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionNoisePredictorLargeImage(variant: String) throws -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionNoisePredictor(variant: String) throws -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionNoisePredictorV10() -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionNoisePredictorLargeImage() -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionTextGuidedEditNoisePredictor(variant: String) throws -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionNoisePredictorV11_1(variant: String) throws -> any ServerDiffusionNoisePredictor { fatalError() }
                public static func ServerDiffusionNoisePredictor() -> any ServerDiffusionNoisePredictor { fatalError() }
            }
            public enum SynthID: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionSynthID() -> any ServerDiffusionSynthID { fatalError() }
                public static func ServerDiffusionSynthID(variant: String) throws -> any ServerDiffusionSynthID { fatalError() }
                public static func ServerDiffusionSynthIDLargeImage() -> any ServerDiffusionSynthID { fatalError() }
                public static func ServerDiffusionSynthIDLargeImage(variant: String) throws -> any ServerDiffusionSynthID { fatalError() }
            }
            public enum TextEncoder: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionTextEncoderLargeImage(variant: String) throws -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextEncoderLargeImage() -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextEncoderV11_1(variant: String) throws -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextGuidedEditTextEncoder(variant: String) throws -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextGuidedEditTextEncoder() -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextEncoder() -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextEncoderV10(variant: String) throws -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextEncoder(variant: String) throws -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextEncoderV10() -> any ServerDiffusionTextEncoder { fatalError() }
                public static func ServerDiffusionTextEncoderV11_1() -> any ServerDiffusionTextEncoder { fatalError() }
            }
            public enum Tokenizer: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionTokenizerLargeImage() -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTokenizerV10(variant: String) throws -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTokenizer(variant: String) throws -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTokenizer() -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTokenizerV10() -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTokenizerV11_1() -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTextGuidedEditTokenizer(variant: String) throws -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTextGuidedEditTokenizer() -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTokenizerV11_1(variant: String) throws -> any ServerDiffusionTokenizer { fatalError() }
                public static func ServerDiffusionTokenizerLargeImage(variant: String) throws -> any ServerDiffusionTokenizer { fatalError() }
            }
            public enum VAEDecoder: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionSpatialReframingVAEDecoder(variant: String) throws -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionVAEDecoder(variant: String) throws -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionVAEDecoder() -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionVAEDecoderV11_1(variant: String) throws -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionVAEDecoderV11_1() -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionSpatialReframingVAEDecoderV11_1() -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionSpatialReframingVAEDecoderV11_1(variant: String) throws -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionSpatialReframingVAEDecoder() -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionSpatialReframingVAEDecoderLargeImage(variant: String) throws -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionVAEDecoderLargeImage(variant: String) throws -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionVAEDecoderLargeImage() -> any ServerDiffusionVAEDecoder { fatalError() }
                public static func ServerDiffusionSpatialReframingVAEDecoderLargeImage() -> any ServerDiffusionVAEDecoder { fatalError() }
            }
            public enum VAEEncoder: Hashable, Sendable {
                case _mock
                public static func ServerDiffusionVAEEncoderLargeImage() -> any ServerDiffusionVAEEncoder { fatalError() }
                public static func ServerDiffusionVAEEncoderV11_1() -> any ServerDiffusionVAEEncoder { fatalError() }
                public static func ServerDiffusionVAEEncoder(variant: String) throws -> any ServerDiffusionVAEEncoder { fatalError() }
                public static func ServerDiffusionVAEEncoder() -> any ServerDiffusionVAEEncoder { fatalError() }
                public static func ServerDiffusionVAEEncoderV11_1(variant: String) throws -> any ServerDiffusionVAEEncoder { fatalError() }
                public static func ServerDiffusionVAEEncoderLargeImage(variant: String) throws -> any ServerDiffusionVAEEncoder { fatalError() }
            }
            case _mock
        }
        public enum SpeechDetokenizer: Hashable, Sendable {
            case _mock
            public static func SpeechDetokenizerV1() -> any AssetBackedSpeechDetokenizer { fatalError() }
            public static func SpeechSynthesisSpeechDetokenizer(variant: String) throws -> SpeechDetokenizer { fatalError() }
            public static func SpeechDetokenizerV1(variant: String) throws -> any AssetBackedSpeechDetokenizer { fatalError() }
            public static func SpeechSynthesisSpeechDetokenizer() -> SpeechDetokenizer { fatalError() }
        }
        public enum SpeechTokenizer: Hashable, Sendable {
            case _mock
            public static func SpeechTokenizerV1(variant: String) throws -> any AssetBackedSpeechTokenizer { fatalError() }
            public static func SpeechTokenizerV1() -> any AssetBackedSpeechTokenizer { fatalError() }
            public static func SpeechSynthesisSpeechTokenizer(variant: String) throws -> SpeechTokenizer { fatalError() }
            public static func SpeechSynthesisSpeechTokenizer() -> SpeechTokenizer { fatalError() }
        }
        public enum ThirdPartyProviderConfiguration: Hashable, Sendable {
            case _mock
            public static func ThirdPartyProviderConfiguration() -> any AssetBackedThirdPartyProviderConfiguration { fatalError() }
            public static func ThirdPartyProviderConfiguration(variant: String) throws -> any AssetBackedThirdPartyProviderConfiguration { fatalError() }
        }
        public enum TokenInputDenyList: Hashable, Sendable {
            public enum BloomFilterTokenInputDenyList: Hashable, Sendable {
                case _mock
                public static func VisualGenerationSafetyInputDenyList(variant: String) throws -> any AssetBackedBloomFilterTokenInputDenyList { fatalError() }
                public static func VisualGenerationSafetyInputDenyList() -> any AssetBackedBloomFilterTokenInputDenyList { fatalError() }
            }
            case _mock
            public static func SafariMagicExtensionsInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func JournalFollowUpPromptsInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SafariMagicExtensionsInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualGenerationBaseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedComposeCompositionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationStoryTitleInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedInteractionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingQuestionAnswerInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedSchemaInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ClipCaptioningInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func CodeIntelligenceBaseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitSafariTabGroupTopicInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsFriendlyToneInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationGlobalTraitInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SuperAutofillMultimodalInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationBaseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func AccessibilityMagnifierInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsTablesTransformInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedComposeInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitVisualPromptInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedReflectionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ImagePlaygroundEditSuggestionsInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedComposeInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneBaseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsComposeRecentsSummariesInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitBaseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantCommonInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationBaseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedComposeCompositionPayloadDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ICloudMailEventExtractionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func STXMultimodalReceiptInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ProofreadingInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationGlobalTraitInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func AskGenerativeModelActionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsMagicRewriteInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsTablesTransformInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsProfessionalToneInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryOnDemandInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func AccessibilityReaderAIInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SafariSafeBrowsingInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplyLongFormQAInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MessagesReplyBaseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PersonalizedSmartReplyNicknamesInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func CalendarMagicComposeBackwardPassInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ADMBackgroundPromptInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryProactiveInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsComposeInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedExtractInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func FoundationModelsFrameworkApiInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsFriendlyToneInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SmartNamingInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VoiceControlAIV2InputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsMagicRewriteInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUUrgencyInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedComposeCompositionPayloadDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func AskGenerativeModelActionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeFallbackInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToContactsInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ShortcutsAskAFMActionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplySnippetInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToContactsInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplyLongFormRewriteInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceNutritionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SafariClusterValidationInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func IPIClassifierInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ShortcutsAskAFMAction3BInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitTextAssistantInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SafariSafeBrowsingInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ClipCaptioningInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedExtractInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsComposeInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ProofreadingInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsBulletsTransformInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsTakeawaysTransformInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SketchCaptioningInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SketchCaptioningInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func JournalFollowUpPromptsInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VoiceControlAIV2InputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplySnippetInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsBulletsTransformInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplyLongFormBasicInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitTextAssistantInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantVisualIntelligenceCameraInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeShortcutsInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneBaseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceNutritionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MessagesReplyWatchInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ADMBackgroundPromptInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SemanticSearchInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MessagesActionBaseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func STXMultimodalReceiptInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ICloudMailEventExtractionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func IntelligentPassCreationInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplyLongFormQAInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func STXMultimodalHealthDataInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ShortcutsAskAFMAction3BInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SafariClusterValidationInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsProofreadingReviewInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsTakeawaysTransformInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantMediaQAInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ChangePasswordForMeInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func STXMultimodalHealthDataInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SemanticSearchInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingQuestionAnswerPayloadDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationUserQueryInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func CalendarMagicComposeBackwardPassInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MessagesActionBaseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantMediaQAInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToCalendarInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SmartNamingInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ChangePasswordForMeInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitVisualPromptInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsConciseToneInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantVisualIntelligenceCameraInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MessagesReplyWatchInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MessagesReplyBaseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func NotificationCoalescingInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitBaseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsProofreadingReviewInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PersonalizedSmartReplyNicknamesInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedComposeCompositionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToCalendarInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedReflectionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUUrgencyInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplyLongFormBasicInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsConciseToneInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ShortcutsAskAFMActionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitSafariTabGroupTopicInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PersonalizedSmartReplyInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func CodeIntelligenceBaseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantCompositionInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func NotificationCoalescingInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsComposeRecentsSummariesInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func IPIClassifierInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeFallbackInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsProfessionalToneInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryOnDemandInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ServerV2VisualIntelligenceSuggestedQuestionsInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func NotifyMeWhenInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SuperAutofillMultimodalInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeShortcutsInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseV2InputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func IntelligentPassCreationInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func MailReplyLongFormRewriteInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ServerV2VisualIntelligenceSuggestedQuestionsInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func FoundationModelsFrameworkApiInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingQuestionAnswerPayloadDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantCommonInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func NotifyMeWhenInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualGenerationBaseInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func AccessibilityReaderAIInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PersonalizedSmartReplyInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VoiceControlAIInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func ImagePlaygroundEditSuggestionsInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationStoryTitleInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitVisualIntelligenceCameraInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitVisualIntelligenceCameraInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VisualIntelligenceInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func AccessibilityMagnifierInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingQuestionAnswerInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedSchemaInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func GenerativeAssistantCompositionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryProactiveInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func VoiceControlAIInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func PhotosMemoriesCreationUserQueryInputDenyList(variant: String) throws -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func OpenEndedInteractionInputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseV2InputDenyList() -> any AssetBackedTokenInputDenyList { fatalError() }
        }
        public enum TokenOutputDenyList: Hashable, Sendable {
            case _mock
            public static func PhotosMemoriesCreationUserQueryOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ShortcutsAskAFMAction3BOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MessagesReplyBaseOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MessagesActionBaseOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitBaseOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeShortcutsOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func AskGenerativeModelActionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedSchemaOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantCompositionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUUrgencyOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MessagesReplyWatchOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsComposeOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantMediaQAOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantCommonOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationGlobalTraitOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseV2OutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SketchCaptioningOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToContactsOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsProofreadingReviewOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ChangePasswordForMeOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsTablesTransformOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func IntelligentPassCreationOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SketchCaptioningOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SafariSafeBrowsingOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationBaseOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsBulletsTransformOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func IntelligentPassCreationOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplySnippetOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ADMBackgroundPromptOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingQuestionAnswerOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryOnDemandOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VoiceControlAIOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ShortcutsAskAFMActionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PersonalizedSmartReplyOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantVisualIntelligenceCameraOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func CodeIntelligenceBaseOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsProfessionalToneOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func CodeIntelligenceBaseOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationUserQueryOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsComposeRecentsSummariesOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsComposeRecentsSummariesOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ServerV2VisualIntelligenceSuggestedQuestionsOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SuperAutofillMultimodalOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func AccessibilityReaderAIOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationMusicSongIdOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationStoryTitleOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ChangePasswordForMeOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func JournalFollowUpPromptsOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsConciseToneOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VoiceControlAIV2OutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsProfessionalToneOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeFallbackOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceNutritionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryProactiveOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ClipCaptioningOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedSchemaOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ICloudMailEventExtractionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitVisualPromptOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func JournalFollowUpPromptsOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedComposeOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsProofreadingReviewOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ShortcutsAskAFMActionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func FoundationModelsFrameworkApiOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsTakeawaysTransformOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitVisualPromptOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsMagicRewriteOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseV2OutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantCommonOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsFriendlyToneOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedReflectionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ProofreadingOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SafariMagicExtensionsOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func AccessibilityReaderAIOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitTextAssistantOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitSafariTabGroupTopicOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ShortcutsAskAFMAction3BOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneBaseOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SafariSafeBrowsingOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitVisualIntelligenceCameraOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedComposeOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedInteractionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func STXMultimodalReceiptOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedComposeCompositionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsBulletsTransformOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsTakeawaysTransformOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationSensitiveOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationGlobalTraitOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ProofreadingOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantVisualIntelligenceCameraOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneQueryResponseOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PersonalizedSmartReplyOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func NotificationCoalescingOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplyLongFormQAOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ImagePlaygroundEditSuggestionsOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitBaseOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func STXMultimodalHealthDataOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplyLongFormBasicOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsMagicRewriteOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplySnippetOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VoiceControlAIOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SafariClusterValidationOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedExtractOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneBaseOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func CalendarMagicComposeBackwardPassOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationMusicSongIdOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MessagesActionBaseOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func NotifyMeWhenOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedReflectionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ImagePlaygroundEditSuggestionsOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func CalendarMagicComposeBackwardPassOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitVisualIntelligenceCameraOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUUrgencyOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToCalendarOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MessagesReplyBaseOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ClipCaptioningOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplyLongFormRewriteOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func NotifyMeWhenOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsFriendlyToneOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationStoryTitleOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ADMBackgroundPromptOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func AskGenerativeModelActionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func AccessibilityMagnifierOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationSensitiveOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplyLongFormQAOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedExtractOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PersonalizedSmartReplyNicknamesOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryOnDemandOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingQuestionAnswerOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceNutritionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantCompositionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ServerV2VisualIntelligenceSuggestedQuestionsOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToCalendarOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeShortcutsOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitSafariTabGroupTopicOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PersonalizedSmartReplyNicknamesOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplyLongFormRewriteOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsComposeOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsTablesTransformOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SmartNamingOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func PhotosMemoriesCreationBaseOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MessagesReplyWatchOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedComposeCompositionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func ICloudMailEventExtractionOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantKnowledgeFallbackOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VoiceControlAIV2OutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsOpenEndedToneOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitTextAssistantOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func VisualIntelligenceStructuredExtractionAddToContactsOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SafariClusterValidationOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func GenerativeAssistantMediaQAOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func FoundationModelsFrameworkApiOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SmartNamingOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func AccessibilityMagnifierOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SuperAutofillMultimodalOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func WritingToolsConciseToneOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func STXMultimodalReceiptOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func MailReplyLongFormBasicOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SafariMagicExtensionsOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func NotificationCoalescingOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func OpenEndedInteractionOutputDenyList(variant: String) throws -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func STXMultimodalHealthDataOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
            public static func SummarizationKitCUSummaryProactiveOutputDenyList() -> any AssetBackedTokenOutputDenyList { fatalError() }
        }
        public enum TokenOutputRetainList: Hashable, Sendable {
            case _mock
            public static func ProofreadingRetainList(variant: String) throws -> any AssetBackedTokenOutputRetainList { fatalError() }
            public static func STXSafetyWordList(variant: String) throws -> any AssetBackedTokenOutputRetainList { fatalError() }
            public static func STXSafetyWordList() -> any AssetBackedTokenOutputRetainList { fatalError() }
            public static func ProofreadingRetainList() -> any AssetBackedTokenOutputRetainList { fatalError() }
        }
        public enum Tokenizer: Hashable, Sendable {
            case _mock
            public static func GMSPrototypeEmbeddingsDummyTokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func CodeLMLargeV3Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func AFMTextInstruct300MTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func AFMTextInstructEnglish49k(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func DistilledMessagesReplyTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMLargeV5Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func InstructServerTokenizer() -> Tokenizer { fatalError() }
            public static func DistilledMessagesActionTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func AFMTextInstructEnglish49k() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSmallV5Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeSafetyGuardrailTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSmallV1Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMLargeV3Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMLargeV1Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func InstructServerV2TokenizerPro(variant: String) throws -> Tokenizer { fatalError() }
            public static func ChatGPTTokenizer() -> Tokenizer { fatalError() }
            public static func InstructServerV2Tokenizer() -> Tokenizer { fatalError() }
            public static func InstructServerV2TokenizerPro() -> Tokenizer { fatalError() }
            public static func CodeLMTokenizerExperimental(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeSafetyGuardrailTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func InstructServerTokenizerTTS() -> Tokenizer { fatalError() }
            public static func CodeLMSmallV3Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMLargeV5Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSmallV2Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func FoundationModelsPlatformDummyTokenizer() -> Tokenizer { fatalError() }
            public static func CodeLMSmallV3Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMLargeV2Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func InstructServerTokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func CodeLMSmallV4Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func DistilledMessagesActionTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSafetyGuardrailTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSmallV5Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSmallV1Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMTokenizerV4() -> any AssetBackedTokenizer { fatalError() }
            public static func AFMTextInstruct85MTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func GMSPrototypeDummyTokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func InstructServerV2TokenizerZap() -> Tokenizer { fatalError() }
            public static func ExternalSearchPartnerDummyTokenizer() -> Tokenizer { fatalError() }
            public static func InstructServerSmallTokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func InstructServerV2Tokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func CodeLMLargeV4Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func ExternalSearchPartnerDummyTokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func TextEventExtractionClassifierTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func InstructServerSmallTokenizer() -> Tokenizer { fatalError() }
            public static func CodeLMTokenizerV2(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSmallV2Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func NLRouterTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func MMTExpert(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMLargeV1Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMTokenizerV3() -> any AssetBackedTokenizer { fatalError() }
            public static func ChatGPTTokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func InstructServerTokenizerTTS(variant: String) throws -> Tokenizer { fatalError() }
            public static func TextEventExtractionClassifierTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMV1ANE3BTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMV1ANE3BTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func FoundationModelsPlatformDummyTokenizer(variant: String) throws -> Tokenizer { fatalError() }
            public static func CodeLMSafetyGuardrailTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func DistilledMessagesReplyTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func GMSPrototypeEmbeddingsDummyTokenizer() -> Tokenizer { fatalError() }
            public static func AFMTextInstruct85MTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func AFMTextInstruct300MTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMTokenizerV4(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func GMSPrototypeDummyTokenizer() -> Tokenizer { fatalError() }
            public static func CodeLMLargeV4Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func MMTExpert() -> any AssetBackedTokenizer { fatalError() }
            public static func InstructServerV2TokenizerZap(variant: String) throws -> Tokenizer { fatalError() }
            public static func CodeLMTokenizerV2() -> any AssetBackedTokenizer { fatalError() }
            public static func VisualGenerationQueryHandlingLiteTokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMSmallV4Tokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMLargeV2Tokenizer() -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func VisualGenerationQueryHandlingLiteTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMTokenizerV3(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
            public static func CodeLMTokenizerExperimental() -> any AssetBackedTokenizer { fatalError() }
            public static func NLRouterTokenizer(variant: String) throws -> any AssetBackedTokenizer { fatalError() }
        }
        public enum TranslateFM: Hashable, Sendable {
            case _mock
            public static func SequoiaMMAlignmentModel(variant: String) throws -> any AssetBackedTranslateFMAsset { fatalError() }
            public static func SequoiaMMPhrasebookAsset(variant: String) throws -> any AssetBackedTranslateFMAsset { fatalError() }
            public static func TranslateFMMachineTranslationAlignmentModel() -> any AssetBackedTranslateFMAsset { fatalError() }
            public static func TranslateFMMachineTranslationPhrasebookAsset() -> any AssetBackedTranslateFMAsset { fatalError() }
            public static func SequoiaMMPhrasebookAsset() -> any AssetBackedTranslateFMAsset { fatalError() }
            public static func TranslateFMMachineTranslationPhrasebookAsset(variant: String) throws -> any AssetBackedTranslateFMAsset { fatalError() }
            public static func TranslateFMMachineTranslationAlignmentModel(variant: String) throws -> any AssetBackedTranslateFMAsset { fatalError() }
            public static func SequoiaMMAlignmentModel() -> any AssetBackedTranslateFMAsset { fatalError() }
        }
        public enum VisionModel: Hashable, Sendable {
            case _mock
            public static func HumanRectangles() -> VisionModel { fatalError() }
            public static func FaceCaptureQuality() -> VisionModel { fatalError() }
            public static func FaceCaptureQuality(variant: String) throws -> VisionModel { fatalError() }
            public static func FaceLandmarks(variant: String) throws -> VisionModel { fatalError() }
            public static func HumanRectangles(variant: String) throws -> VisionModel { fatalError() }
            public static func PersonInstanceSegmentation(variant: String) throws -> VisionModel { fatalError() }
            public static func DetectBarcodes(variant: String) throws -> VisionModel { fatalError() }
            public static func DetectBarcodes() -> VisionModel { fatalError() }
            public static func MaskTracker(variant: String) throws -> VisionModel { fatalError() }
            public static func RecognizeAnimals() -> VisionModel { fatalError() }
            public static func PersonSegmentation() -> VisionModel { fatalError() }
            public static func SmudgeDetection(variant: String) throws -> VisionModel { fatalError() }
            public static func PersonSegmentation(variant: String) throws -> VisionModel { fatalError() }
            public static func ForegroundInstanceSegmentation(variant: String) throws -> VisionModel { fatalError() }
            public static func PersonInstanceSegmentation() -> VisionModel { fatalError() }
            public static func FaceLandmarks() -> VisionModel { fatalError() }
            public static func ForegroundInstanceSegmentation() -> VisionModel { fatalError() }
            public static func SmudgeDetection() -> VisionModel { fatalError() }
            public static func MaskTracker() -> VisionModel { fatalError() }
            public static func RecognizeAnimals(variant: String) throws -> VisionModel { fatalError() }
        }
        public enum VoicesOverrides: Hashable, Sendable {
            case _mock
            public static func TTSVoicesOverrides() -> VoicesOverrides { fatalError() }
            public static func TTSVoicesOverrides(variant: String) throws -> VoicesOverrides { fatalError() }
        }
        case _mock
        public static var allResourceConfigurationIDs: Set<String> { get { return [] } }
        public static var allResourceConfigurationIDsAllPlatforms: Set<String> { get { return [] } }
        public static var allResources: Array<any CatalogResource> { get { return [] } }
        public static var blockedInSensitiveRegionVariants: Dictionary<String, Array<String>> { get { return [:] } }
        public static var resourceMetadata: Dictionary<String, ResourceMetadata> { get { return [:] } }
        public static var usageTypesForAssetSet: Dictionary<String, Array<String>> { get { return [:] } }
        public static func fetchAllResources() -> Array<any CatalogResource> { return [] }
        public static var usageAliasValuesForUsageAlias: Dictionary<String, Array<String>> { get { return [:] } }
        public static var variantResolverMappings: Dictionary<String, Dictionary<String, Dictionary<ResourceVariantResolverArgument, Array<String>>>> { get { return [:] } }
        public static var variants: Dictionary<String, Array<String>> { get { return [:] } }
    }
    public enum ResourceBundle: Hashable, Sendable {
        public enum CoreML: Hashable, Sendable {
            public enum RankingModel: Hashable, Sendable {
                case _mock
                public static var ConcertsRankingID: ResourceBundleIdentifier<AssetBackedCoreMLRankingModelBundle> { get { fatalError() } }
                public static func ConcertsRanking() throws -> AssetBackedCoreMLRankingModelBundle { fatalError() }
                public static var ConcertsRankingConfigurationID: String { get { return "" } }
            }
            case _mock
        }
        public enum GenerativeShortcuts: Hashable, Sendable {
            case _mock
            public static var ShortcutsGeneratorToolRetrievalConfigurationID: String { get { return "" } }
            public static func ShortcutsGeneratorToolRetrieval() throws -> AssetBackedGenerativeShortcutsBundle { fatalError() }
            public static var ShortcutsGeneratorToolRetrievalID: ResourceBundleIdentifier<AssetBackedGenerativeShortcutsBundle> { get { fatalError() } }
        }
        public enum ImageSpatialPhotosRelive: Hashable, Sendable {
            case _mock
            public static var SpatialPhotosReliveBuiltinConfigurationID: String { get { return "" } }
            public static var SpatialPhotosReliveBuiltinID: ResourceBundleIdentifier<ImageSpatialPhotosReliveBundle> { get { fatalError() } }
            public static var SpatialPhotosReliveMainID: ResourceBundleIdentifier<AssetBackedImageSpatialPhotosReliveBundle> { get { fatalError() } }
            public static func SpatialPhotosReliveBuiltin() throws -> ImageSpatialPhotosReliveBundle { fatalError() }
            public static func SpatialPhotosReliveMain() throws -> AssetBackedImageSpatialPhotosReliveBundle { fatalError() }
            public static var SpatialPhotosReliveMainConfigurationID: String { get { return "" } }
        }
        public enum Motion: Hashable, Sendable {
            case _mock
            public static var CoreMotionCalorimetryReducedEmbeddingsID: ResourceBundleIdentifier<AssetBackedMotionBundle> { get { fatalError() } }
            public static var CoreMotionPednetFoundationModelID: ResourceBundleIdentifier<MotionBundle> { get { fatalError() } }
            public static func CoreMotionCalorimetryReducedEmbeddings() throws -> AssetBackedMotionBundle { fatalError() }
            public static func CoreMotionPednetFoundationModel() throws -> MotionBundle { fatalError() }
            public static var CoreMotionCalorimetryReducedEmbeddingsConfigurationID: String { get { return "" } }
            public static var CoreMotionIMUFoundationModelID: ResourceBundleIdentifier<AssetBackedMotionBundle> { get { fatalError() } }
            public static var CoreMotionPednetFoundationModelConfigurationID: String { get { return "" } }
            public static func MotionAnomalyFMAdapter() throws -> AssetBackedMotionBundle { fatalError() }
            public static func CoreMotionIMUFoundationModel() throws -> AssetBackedMotionBundle { fatalError() }
            public static var CoreMotionCalorimetryFMPredictedWRMetsConfigurationID: String { get { return "" } }
            public static var CoreMotionCalorimetryFMPredictedWRMetsID: ResourceBundleIdentifier<AssetBackedMotionBundle> { get { fatalError() } }
            public static var CoreMotionIMUFoundationModelConfigurationID: String { get { return "" } }
            public static var MotionAnomalyFMAdapterConfigurationID: String { get { return "" } }
            public static var MotionAnomalyFMAdapterID: ResourceBundleIdentifier<AssetBackedMotionBundle> { get { fatalError() } }
            public static func CoreMotionCalorimetryFMPredictedWRMets() throws -> AssetBackedMotionBundle { fatalError() }
        }
        public enum Overrides: Hashable, Sendable {
            public enum DefaultOverrides: Hashable, Sendable {
                case _mock
                public static var DefaultOverridesOnlyConfigurationID: String { get { return "" } }
                public static func DefaultOverridesOnly() throws -> AssetBackedDefaultOverridesBundle { fatalError() }
                public static var DefaultOverridesOnlyID: ResourceBundleIdentifier<AssetBackedDefaultOverridesBundle> { get { fatalError() } }
            }
            public enum TokenInputDenyList: Hashable, Sendable {
                case _mock
                public static var TokenInputDenyListTemplateID: ResourceBundleIdentifier<AssetBackedTokenInputDenyListBundle> { get { fatalError() } }
                public static func TokenInputDenyListTemplate() throws -> AssetBackedTokenInputDenyListBundle { fatalError() }
                public static var TokenInputDenyListTemplateConfigurationID: String { get { return "" } }
            }
            public enum TokenInputDenyListWithDefaults: Hashable, Sendable {
                case _mock
                public static var TokenInputDenyListTemplateConfigurationID: String { get { return "" } }
                public static var TokenInputDenyListTemplateID: ResourceBundleIdentifier<AssetBackedTokenInputDenyListWithDefaultsBundle> { get { fatalError() } }
                public static func TokenInputDenyListTemplate() throws -> AssetBackedTokenInputDenyListWithDefaultsBundle { fatalError() }
            }
            public enum TokenOutputDenyList: Hashable, Sendable {
                case _mock
                public static var TokenOutputDenyListTemplateID: ResourceBundleIdentifier<AssetBackedTokenOutputDenyListBundle> { get { fatalError() } }
                public static func TokenOutputDenyListTemplate() throws -> AssetBackedTokenOutputDenyListBundle { fatalError() }
                public static var TokenOutputDenyListTemplateConfigurationID: String { get { return "" } }
            }
            public enum TokenOutputDenyListWithDefaults: Hashable, Sendable {
                case _mock
                public static var TokenOutputDenyListWithDefaultsTemplateConfigurationID: String { get { return "" } }
                public static var TokenOutputDenyListWithDefaultsTemplateID: ResourceBundleIdentifier<AssetBackedTokenOutputDenyListWithDefaultsBundle> { get { fatalError() } }
                public static func TokenOutputDenyListWithDefaultsTemplate() throws -> AssetBackedTokenOutputDenyListWithDefaultsBundle { fatalError() }
            }
            public enum TokenOutputRetainList: Hashable, Sendable {
                case _mock
                public static func TokenOutputRetainListWithDefaultsTemplate() throws -> AssetBackedTokenOutputRetainListBundle { fatalError() }
                public static var TokenOutputRetainListWithDefaultsTemplateConfigurationID: String { get { return "" } }
                public static var TokenOutputRetainListWithDefaultsTemplateID: ResourceBundleIdentifier<AssetBackedTokenOutputRetainListBundle> { get { fatalError() } }
                public static func TokenOutputRetainListStructureExtractionSafetyWordList() throws -> AssetBackedTokenOutputRetainListBundle { fatalError() }
                public static var TokenOutputRetainListStructureExtractionSafetyWordListConfigurationID: String { get { return "" } }
                public static var TokenOutputRetainListStructureExtractionSafetyWordListID: ResourceBundleIdentifier<AssetBackedTokenOutputRetainListBundle> { get { fatalError() } }
            }
            case _mock
        }
        public enum PCCGenericInference: Hashable, Sendable {
            case _mock
            public static var EchoAgentID: ResourceBundleIdentifier<PCCGenericInferenceBundle> { get { fatalError() } }
            public static var FMServiceEmbeddingV1ConfigurationID: String { get { return "" } }
            public static func FMServiceEmbeddingV1() throws -> PCCGenericInferenceBundle { fatalError() }
            public static var EchoAgentConfigurationID: String { get { return "" } }
            public static var FMServiceEmbeddingV1ID: ResourceBundleIdentifier<PCCGenericInferenceBundle> { get { fatalError() } }
            public static var FMServiceVLUV1ID: ResourceBundleIdentifier<PCCGenericInferenceBundle> { get { fatalError() } }
            public static func EchoAgent() throws -> PCCGenericInferenceBundle { fatalError() }
            public static var FMServiceVLUV1ConfigurationID: String { get { return "" } }
            public static var HKSVProcessingAgentID: ResourceBundleIdentifier<PCCGenericInferenceBundle> { get { fatalError() } }
            public static func FMServiceVLUV1() throws -> PCCGenericInferenceBundle { fatalError() }
            public static var HKSVProcessingAgentProConfigurationID: String { get { return "" } }
            public static var HKSVProcessingAgentProID: ResourceBundleIdentifier<PCCGenericInferenceBundle> { get { fatalError() } }
            public static func HKSVProcessingAgent() throws -> PCCGenericInferenceBundle { fatalError() }
            public static var HKSVProcessingAgentConfigurationID: String { get { return "" } }
            public static func HKSVProcessingAgentPro() throws -> PCCGenericInferenceBundle { fatalError() }
        }
        public enum SafetyOutputConfiguration: Hashable, Sendable {
            case _mock
            public static func SafetyOutputConfigurationNSFW() throws -> AssetBackedSafetyOutputConfigurationBundle { fatalError() }
            public static var SafetyOutputConfigurationConfigurationID: String { get { return "" } }
            public static var SafetyOutputConfigurationID: ResourceBundleIdentifier<AssetBackedSafetyOutputConfigurationBundle> { get { fatalError() } }
            public static var SafetyOutputConfigurationNSFWConfigurationID: String { get { return "" } }
            public static var SafetyOutputConfigurationNSFWID: ResourceBundleIdentifier<AssetBackedSafetyOutputConfigurationBundle> { get { fatalError() } }
            public static func SafetyOutputConfiguration() throws -> AssetBackedSafetyOutputConfigurationBundle { fatalError() }
            public static func SafetyOutputConfigurationMMGuard() throws -> AssetBackedSafetyOutputConfigurationBundle { fatalError() }
            public static var SafetyOutputConfigurationMMGuardConfigurationID: String { get { return "" } }
            public static var SafetyOutputConfigurationMMGuardID: ResourceBundleIdentifier<AssetBackedSafetyOutputConfigurationBundle> { get { fatalError() } }
        }
        public enum Sanitizer: Hashable, Sendable {
            case _mock
        }
        public enum SecureAnalytics: Hashable, Sendable {
            case _mock
            public static var IntegrityDiagnoseModelConfigurationID: String { get { return "" } }
            public static func IntegrityDiagnoseModel() throws -> SecureAnalyticsBundle { fatalError() }
            public static var IntegrityDiagnoseModelID: ResourceBundleIdentifier<SecureAnalyticsBundle> { get { fatalError() } }
        }
        public enum TokenGeneration: Hashable, Sendable {
            public enum LLM: Hashable, Sendable {
                case _mock
                public static func SmartAppActions() throws -> AssetBackedLLMBundle { fatalError() }
                public static var LWOnDevicePlannerV1ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ChatGPT() throws -> LLMBundle { fatalError() }
                public static var PlannerV6ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func JournalFollowUpPrompts() throws -> LLMBundle { fatalError() }
                public static func PhotosMemoriesCreationStoryteller3b() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2FriendlyToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ResponseGenerationV2() throws -> LLMBundle { fatalError() }
                public static var CodeLMV4ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var FitnessWorkoutVoiceV1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var JournalMomentsClassificationConfigurationID: String { get { return "" } }
                public static func FactualConsistencyClassifier() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2GenerativeShortcutsV13ConfigurationID: String { get { return "" } }
                public static var ServerV2PrepubescentSafetyID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2VisualIntelligenceNutritionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func RemindersGroceryList() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerProofreadingReview() throws -> LLMBundle { fatalError() }
                public static func IntelligentRoutingRoomClassification() throws -> AssetBackedLLMBundle { fatalError() }
                public static var FoundationModelsPlatformID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var LWPlannerV5ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var MailReplyLongFormRewriteConfigurationID: String { get { return "" } }
                public static var ServerProofreadingReviewConfigurationID: String { get { return "" } }
                public static var ServerV2BulletsTransformID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2MailProfileCreationExperiment1ConfigurationID: String { get { return "" } }
                public static var ServerV2MailProfileCreationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2MiscSafetyConfigurationID: String { get { return "" } }
                public static var SiriTTSVoiceNaturalID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var TextExpertConfigurationID: String { get { return "" } }
                public static func OpenEndedExtract3B() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PhotosMemoriesCreationAssetCurationOutlier3bConfigurationID: String { get { return "" } }
                public static var VisualIntelligenceConfigurationID: String { get { return "" } }
                public static func MessagesReplyWatch() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2GenerativeShortcutsV13() throws -> LLMBundle { fatalError() }
                public static var PCCInteractProID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PlannerV7ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2GenerativeShortcutsV16() throws -> LLMBundle { fatalError() }
                public static var DistilledMessagesReplyConfigurationID: String { get { return "" } }
                public static var GMSPrototypeEmbeddingsConfigurationID: String { get { return "" } }
                public static var ServerV2PhotosMemoriesCreationGlobalTraitsV2ConfigurationID: String { get { return "" } }
                public static var ServerV2WritingQuestionAnswerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2ImagePlaygroundMultimodalInputSafety() throws -> LLMBundle { fatalError() }
                public static var ActionValidatorConfigurationID: String { get { return "" } }
                public static var FactualConsistencyClassifierID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PQAVerificationBaseID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerProfessionalToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2SummarizeShortcutsConfigurationID: String { get { return "" } }
                public static func MiscSafety() throws -> AssetBackedLLMBundle { fatalError() }
                public static var OpenEndedToneQueryResponseConfigurationID: String { get { return "" } }
                public static var VIContentClassifierID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func HoldAssistWaitTime() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AFMTextInstruct3BThirdPartyConfigurationID: String { get { return "" } }
                public static var GMSPrototypeConfigurationID: String { get { return "" } }
                public static var ServerMailReplyQAID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV12ConfigurationID: String { get { return "" } }
                public static var ServerV2PhotosMemoriesCreationQueryUnderstandingV3ConfigurationID: String { get { return "" } }
                public static var SiriUserExperienceAnalysisID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func VoiceControlAI() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MessagesReplyWatchConfigurationID: String { get { return "" } }
                public static var ServerV2IntelligentPassCreationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2SketchCaptioningConfigurationID: String { get { return "" } }
                public static func ServerV2HKSVProcessingCaptionsPro() throws -> LLMBundle { fatalError() }
                public static var ServerV2AgeVerificationConfigurationID: String { get { return "" } }
                public static func FoundationModelsPlatform() throws -> LLMBundle { fatalError() }
                public static var InstructFMApiGenericID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func OpenEndedExtractWorkflow() throws -> LLMBundle { fatalError() }
                public static var ProofreadingReviewID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SafariNotifyMeWhenSuggestionsConfigurationID: String { get { return "" } }
                public static var SafariTabGroupTopicID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func LWPlannerV2() throws -> LLMBundle { fatalError() }
                public static func OpenEndedToneQueryResponseV2() throws -> LLMBundle { fatalError() }
                public static var OpenEndedComposeWorkflowConfigurationID: String { get { return "" } }
                public static var STXMultimodalConfigurationID: String { get { return "" } }
                public static var STXMultimodalID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerBulletsTransformID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV14ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ProofreadingExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func TextEventExtraction() throws -> AssetBackedLLMBundle { fatalError() }
                public static var FriendlyToneID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2CalendarMagicComposeBackwardPassID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2FitnessWorkoutVoiceID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2HKSVProcessingCaptionsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ICloudMailEventExtractionConfigurationID: String { get { return "" } }
                public static func CodeLMLargeV3() throws -> AssetBackedLLMBundle { fatalError() }
                public static var GMSPrototypeID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var OpenEndedComposeID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationStoryteller3bID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PrepubescentSafetyCustomizedID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ResponseGenerationV5ConfigurationID: String { get { return "" } }
                public static var ServerV2ConciseToneConfigurationID: String { get { return "" } }
                public static var ServerV2FitnessWorkoutVoiceConfigurationID: String { get { return "" } }
                public static var ServerV2InsightAgentsConfigurationID: String { get { return "" } }
                public static var ServerV2VisualIntelligenceSuggestedQuestionsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func SafariPhishingClassification() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ADMPeopleGroundingID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ActionValidatorID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var NutritionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PlannerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2BulletsTransformConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV17ConfigurationID: String { get { return "" } }
                public static func MagicRewrite() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MachineTranslationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationGlobalTraitsConfigurationID: String { get { return "" } }
                public static var ServerStructuredExtractionConfigurationID: String { get { return "" } }
                public static var ServerV2ImagePlaygroundMultimodalInputSafetyConfigurationID: String { get { return "" } }
                public static func AnswerSynthesisServerV2Experiment3() throws -> LLMBundle { fatalError() }
                public static var ServerTakeawaysTransformID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var TextGuardSafetyGuardrailID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func SafariTabGroupTopic() throws -> AssetBackedLLMBundle { fatalError() }
                public static var LWPlannerV4ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ASRNaturalDictationSpeech() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MessagesActionSmallID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var MiscSafetyCustomizedID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2SketchCaptioningID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PlannerV5() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ADMPromptAnalyzerID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2OpenEndedInteractionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func AnswerSynthesis() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMConfigurationID: String { get { return "" } }
                public static var MailReplyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV18ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV19ConfigurationID: String { get { return "" } }
                public static var ServerV2SummarizeShortcutsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2HKSVProcessingCaptions() throws -> LLMBundle { fatalError() }
                public static var AutonamingMessagesID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func PhotosMemoriesCreationAssetCurationOutlier3b() throws -> AssetBackedLLMBundle { fatalError() }
                public static var VoiceID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerProfessionalTone() throws -> LLMBundle { fatalError() }
                public static var ASRAFMDictationConfigurationID: String { get { return "" } }
                public static func MMGuardSafetyGuardrail3B() throws -> AssetBackedLLMBundle { fatalError() }
                public static var FMAPICliConfigurationID: String { get { return "" } }
                public static var MessagesActionSmallConfigurationID: String { get { return "" } }
                public static var PhotosLibraryUnderstandingMMID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerFriendlyToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ShortcutsUseModelActionPro() throws -> LLMBundle { fatalError() }
                public static func ResponseGenerationV8() throws -> LLMBundle { fatalError() }
                public static var DistilledMessagesActionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ImagePlaygroundEditSuggestionsConfigurationID: String { get { return "" } }
                public static var OpenEndedInteractionConfigurationID: String { get { return "" } }
                public static var ServerV2TakeawaysTransformConfigurationID: String { get { return "" } }
                public static func ResponseGenerationV5() throws -> AssetBackedLLMBundle { fatalError() }
                public static var FullPayloadCorrectionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SuggestRecipeItemsConfigurationID: String { get { return "" } }
                public static func StructuralIntegrity() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PlannerV9ConfigurationID: String { get { return "" } }
                public static func OpenEndedExtractServer() throws -> LLMBundle { fatalError() }
                public static func ServerV2ProfessionalToneExperiment1() throws -> LLMBundle { fatalError() }
                public static func PCCTestFast() throws -> LLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment4ConfigurationID: String { get { return "" } }
                public static var MessagesReplyConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationTitle3bConfigurationID: String { get { return "" } }
                public static var RemindersSuggestActionItemsConfigurationID: String { get { return "" } }
                public static var ServerV2FriendlyToneConfigurationID: String { get { return "" } }
                public static var ServerV2OpenEndedComposeID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PrepubescentSafetyCustomized() throws -> AssetBackedLLMBundle { fatalError() }
                public static func PhotosLibraryUnderstandingMM() throws -> AssetBackedLLMBundle { fatalError() }
                public static func Voice2() throws -> AssetBackedLLMBundle { fatalError() }
                public static func AutonamingMessages() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PrepubescentSafetyConfigurationID: String { get { return "" } }
                public static var SafetyNSFWID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func CodeLMLargeV5() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ShortcutsAskAFMAction3BV2() throws -> AssetBackedLLMBundle { fatalError() }
                public static func Safety() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MessagesReplyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationGlobalTraitsV3ConfigurationID: String { get { return "" } }
                public static var SafariClusterValidationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2AutograderID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2HomeKitSummaryNotificationsConfigurationID: String { get { return "" } }
                public static var ServerV2STXMultimodalID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2SiriVisualIntelligenceID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2WritingQuestionAnswerExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func SummarizationTextSummarizer() throws -> LLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment4ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var LWOnDevicePlannerV1ConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationStorytellerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2GenerativeShortcutsV18() throws -> LLMBundle { fatalError() }
                public static func ServerV2OpenEndedTone() throws -> LLMBundle { fatalError() }
                public static func ServerV2FriendlyToneExperiment1() throws -> LLMBundle { fatalError() }
                public static var LLMSiriDeviceID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ConciseTone() throws -> AssetBackedLLMBundle { fatalError() }
                public static func PhotosMemoriesCreationAssetCurationV2() throws -> LLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2OpenEndedInteractionConfigurationID: String { get { return "" } }
                public static func FitnessSummary() throws -> AssetBackedLLMBundle { fatalError() }
                public static func AutoTagger() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2ICloudMailSemanticSearch() throws -> LLMBundle { fatalError() }
                public static var ServerMailReplyLongFormBasicConfigurationID: String { get { return "" } }
                public static func ServerV2STXMultimodal() throws -> LLMBundle { fatalError() }
                public static func ResponseGenerationV3() throws -> LLMBundle { fatalError() }
                public static func ServerV2CalendarMagicComposeBackwardPass() throws -> LLMBundle { fatalError() }
                public static func ServerV2StructuralIntegrity() throws -> LLMBundle { fatalError() }
                public static var LWPlannerV3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationAssetCurationConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationStorytellerConfigurationID: String { get { return "" } }
                public static func SafetyNSFW() throws -> LLMBundle { fatalError() }
                public static var CodeLMSafetyGuardrailConfigurationID: String { get { return "" } }
                public static var PlannerV8ConfigurationID: String { get { return "" } }
                public static var SummarizationConfigurationID: String { get { return "" } }
                public static func VisualIntelligence() throws -> LLMBundle { fatalError() }
                public static func Voice() throws -> AssetBackedLLMBundle { fatalError() }
                public static func PlannerV3() throws -> LLMBundle { fatalError() }
                public static var FullPayloadCorrectionConfigurationID: String { get { return "" } }
                public static var OpenEndedExtractServerTextID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerSmallActionValidatorID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2BulletsTransformExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var UrgencyClassificationConfigurationID: String { get { return "" } }
                public static func StructuralExtraction() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ConciseToneConfigurationID: String { get { return "" } }
                public static var FMAPIConfigurationID: String { get { return "" } }
                public static var ServerV2MailProfileCreationConfigurationID: String { get { return "" } }
                public static var VIContentClassifierConfigurationID: String { get { return "" } }
                public static func PhotosLibraryUnderstandingT2T() throws -> AssetBackedLLMBundle { fatalError() }
                public static func JournalMomentsClassification() throws -> AssetBackedLLMBundle { fatalError() }
                public static func InstructServerBase() throws -> LLMBundle { fatalError() }
                public static var AFMTextInstruct3BThirdPartySDID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ASRNaturalDictationSpeechConfigurationID: String { get { return "" } }
                public static var CodeLMLargeV3ConfigurationID: String { get { return "" } }
                public static var PrepubescentSafetyCustomizedConfigurationID: String { get { return "" } }
                public static var ServerV2TakeawaysTransformID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func RemindersSuggestActionItems() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2TablesTransformExperiment1ConfigurationID: String { get { return "" } }
                public static func CodeLMV3() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PCCTestFastConfigurationID: String { get { return "" } }
                public static var PromptAnalysisID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2OpenEndedComposeExperiment1() throws -> LLMBundle { fatalError() }
                public static var NotifyMeWhenConfigurationID: String { get { return "" } }
                public static var OpenEndedInteractionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2AgeEstimation() throws -> LLMBundle { fatalError() }
                public static var CodeLMLargeV4ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var CodeLMV4ConfigurationID: String { get { return "" } }
                public static var ServerV2PhotosMemoriesCreationAssetCurationV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func MMGuardSafetyGuardrail() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2TakeawaysTransform() throws -> LLMBundle { fatalError() }
                public static var PhotosMemoriesCreationStorytellerV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PhotosCommon() throws -> LLMBundle { fatalError() }
                public static var InstructFMApiGenericConfigurationID: String { get { return "" } }
                public static var ModelAbuseGuardrailID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func SearchQueryUnderstandingServer() throws -> LLMBundle { fatalError() }
                public static var ServerV2TablesTransformConfigurationID: String { get { return "" } }
                public static var UIPreviewsConfigurationID: String { get { return "" } }
                public static func ServerV2MailProfileCreation() throws -> LLMBundle { fatalError() }
                public static func CodeLMV4() throws -> AssetBackedLLMBundle { fatalError() }
                public static func FullPayloadCorrection() throws -> AssetBackedLLMBundle { fatalError() }
                public static var BulletsTransformID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ResponseGenerationV3ConfigurationID: String { get { return "" } }
                public static var ServerV2PhotosMemoriesCreationAssetCurationV2ConfigurationID: String { get { return "" } }
                public static func SmallMessagesReplyWatch() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AnswerSynthesisID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var AnswerSynthesisServerV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2BulletsTransformExperiment1ConfigurationID: String { get { return "" } }
                public static func SiriUserExperienceAnalysis() throws -> AssetBackedLLMBundle { fatalError() }
                public static func OpenEndedSchema() throws -> LLMBundle { fatalError() }
                public static var AutoTaggerID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PQAVerificationBaseConfigurationID: String { get { return "" } }
                public static var ServerV2ShortcutsAskAFMActionV2ConfigurationID: String { get { return "" } }
                public static var SummarizationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func AFMTextInstruct3BThirdParty() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ModelAbuseGuardrail() throws -> LLMBundle { fatalError() }
                public static var InstructServerAutograderID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerTablesTransform() throws -> LLMBundle { fatalError() }
                public static var FitnessSummaryConfigurationID: String { get { return "" } }
                public static var OpenEndedToneBaseConfigurationID: String { get { return "" } }
                public static var ResponseGenerationV6ConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV18ConfigurationID: String { get { return "" } }
                public static var ServerV2OpenEndedInteractionExperiment1ConfigurationID: String { get { return "" } }
                public static var ServerV2SafariTabGroupTopicID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func MailReplyLongFormBasic() throws -> AssetBackedLLMBundle { fatalError() }
                public static var SpeechToSpeechID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func Nutrition() throws -> AssetBackedLLMBundle { fatalError() }
                public static var GenerativeShortcutsConfigurationID: String { get { return "" } }
                public static var IPIClassifierConfigurationID: String { get { return "" } }
                public static var OpenEndedExtractWorkflowConfigurationID: String { get { return "" } }
                public static var ServerV2MiscSafetyID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerMagicRewrite() throws -> LLMBundle { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding() throws -> LLMBundle { fatalError() }
                public static var CodeLMV1ANE3BConfigurationID: String { get { return "" } }
                public static var DescribeYourEditID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationGlobalTraits3bID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2OpenEndedToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2ProofreadingExperiment1() throws -> LLMBundle { fatalError() }
                public static var ServerV2GenerativeShortcutsV20ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PlannerV7() throws -> LLMBundle { fatalError() }
                public static var FoundationModelsPlatformConfigurationID: String { get { return "" } }
                public static var ShortcutsUseModelActionProConfigurationID: String { get { return "" } }
                public static func AnswerSynthesisServerV2() throws -> LLMBundle { fatalError() }
                public static func ResponseGenerationV6() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ResponseGenerationV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func CodeLMSmallV1() throws -> AssetBackedLLMBundle { fatalError() }
                public static var TextEventExtractionClassifierConfigurationID: String { get { return "" } }
                public static func PhotosMemoriesCreationGlobalTraitsV2() throws -> LLMBundle { fatalError() }
                public static func ServerPQAVerification() throws -> LLMBundle { fatalError() }
                public static var PhotosLibraryUnderstandingT2TConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV21ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2StructuralIntegrityID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func HomeKitSummaryNotifications() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMExperimentalID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var CodeLMSmallV5ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationQueryUnderstandingV3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var RemindersAutoCategorizeListConfigurationID: String { get { return "" } }
                public static func PhotosMemoriesCreationGlobalTraitsV3() throws -> LLMBundle { fatalError() }
                public static func ServerMailReplyLongFormRewrite() throws -> LLMBundle { fatalError() }
                public static var NewsTopicSummarizationConfigurationID: String { get { return "" } }
                public static func ServerV2SafariTabGroupTopic() throws -> LLMBundle { fatalError() }
                public static func ExternalSearchPartner() throws -> LLMBundle { fatalError() }
                public static var MessagesActionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var VoiceConfigurationID: String { get { return "" } }
                public static func ServerV2SketchCaptioning() throws -> LLMBundle { fatalError() }
                public static var RemindersAutoCategorizeListOnDeviceID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsConfigurationID: String { get { return "" } }
                public static func PCCInteractPro() throws -> LLMBundle { fatalError() }
                public static var TamalePOIConfigurationID: String { get { return "" } }
                public static func SuggestRecipeItems() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2_ShortOutputID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var OpenEndedComposeConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationQueryUnderstanding3bID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var RemindersSuggestActionItemsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func CodeSafetyGuardrail() throws -> AssetBackedLLMBundle { fatalError() }
                public static var OpenEndedToneQueryResponseV1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerDescribeYourEditID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var VoiceControlAIID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerV2TablesTransform() throws -> LLMBundle { fatalError() }
                public static var ProfessionalToneID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func VoiceControlAIV2() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMV3ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosCommonID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2PhotosMemoriesCreationQueryUnderstandingV3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ShortcutsAskAFMAction3BConfigurationID: String { get { return "" } }
                public static var StructuralIntegrityConfigurationID: String { get { return "" } }
                public static func MachineTranslation() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2SafariMagicExtensionsConfigurationID: String { get { return "" } }
                public static var ServerV2TablesTransformExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PhotosMemoriesCreationAssetCuration() throws -> LLMBundle { fatalError() }
                public static var ServerV2ProofreadingID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func CodeLMLargeV4() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2OpenEndedCompose() throws -> LLMBundle { fatalError() }
                public static func ServerV2PhotosMemoriesCreationGlobalTraitsV2() throws -> LLMBundle { fatalError() }
                public static var CodeLMExperimentalConfigurationID: String { get { return "" } }
                public static var LLMSiriDeviceConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationQueryUnderstandingV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var TakeawaysTransformConfigurationID: String { get { return "" } }
                public static func PlannerV2() throws -> LLMBundle { fatalError() }
                public static var GroundedVisualIntelligenceContentClassifierID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func MailReply() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2SafariMagicExtensionsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PhotosMemoriesCreationStoryteller() throws -> LLMBundle { fatalError() }
                public static var ContentTaggerConfigurationID: String { get { return "" } }
                public static var NutritionConfigurationID: String { get { return "" } }
                public static func ContentTagger() throws -> AssetBackedLLMBundle { fatalError() }
                public static var SmartAppActionsConfigurationID: String { get { return "" } }
                public static var SummarizationTextSummarizerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func SpeechSynthesisV7Base() throws -> LLMBundle { fatalError() }
                public static func ServerV2FriendlyTone() throws -> LLMBundle { fatalError() }
                public static var OpenEndedExtract300mConfigurationID: String { get { return "" } }
                public static var ServerTablesTransformConfigurationID: String { get { return "" } }
                public static func EmojiKeywordExtraction() throws -> AssetBackedLLMBundle { fatalError() }
                public static var DeviceSummarizationTextSummarizerID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var MiscSafetyConfigurationID: String { get { return "" } }
                public static func ServerSmallActionValidator() throws -> LLMBundle { fatalError() }
                public static var ServerV2ImagePlaygroundMultimodalInputSafetyID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var UIGroundingConfigurationID: String { get { return "" } }
                public static func FitnessWorkoutVoiceV1() throws -> LLMBundle { fatalError() }
                public static func CodeLMV1ANE3B() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMWithDraftConfigurationID: String { get { return "" } }
                public static var GMSPrototypeEmbeddingsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PCCInteractWKAConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationQueryUnderstandingV2ConfigurationID: String { get { return "" } }
                public static var PlannerV4ConfigurationID: String { get { return "" } }
                public static var ResponseGenerationV3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SearchQueryUnderstandingServerConfigurationID: String { get { return "" } }
                public static var ServerV2AccessibilityMagnifierConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV16ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2InsightAgentsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ProfessionalToneConfigurationID: String { get { return "" } }
                public static var ShortcutsAskAFMActionV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PhotosMemoriesCreationTitle3b() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ResponseGenerationV2ConfigurationID: String { get { return "" } }
                public static func ServerV2Autograder() throws -> LLMBundle { fatalError() }
                public static var PhotosMemoriesCreationAssetCurationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV21ConfigurationID: String { get { return "" } }
                public static func ServerV2ConciseTone() throws -> LLMBundle { fatalError() }
                public static func OpenEndedExtract300m() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2OpenEndedComposeExperiment1ConfigurationID: String { get { return "" } }
                public static func SuperAutofillMultimodal() throws -> LLMBundle { fatalError() }
                public static func ServerV2GenerativeShortcutsV21() throws -> LLMBundle { fatalError() }
                public static var AccessibilityMagnifierConfigurationID: String { get { return "" } }
                public static var AnswerSynthesisServerV2_ShortOutputConfigurationID: String { get { return "" } }
                public static var JournalFollowUpPromptsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PersonalizedSmartReplyConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV16ConfigurationID: String { get { return "" } }
                public static func ServerV2GenerativeShortcutsV19() throws -> LLMBundle { fatalError() }
                public static func ContextProgram() throws -> AssetBackedLLMBundle { fatalError() }
                public static var SmallMessagesReplyWatchID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func VideoCaption() throws -> AssetBackedLLMBundle { fatalError() }
                public static func StructuredExtraction() throws -> AssetBackedLLMBundle { fatalError() }
                public static func CodeLMExperimental() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PCCInteractFastConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationAssetCurationV2ConfigurationID: String { get { return "" } }
                public static var PlannerV3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func CodeLM() throws -> AssetBackedLLMBundle { fatalError() }
                public static func MessagesReply() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2RemindersAutoCategorizeListID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func TextPersonExtraction() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMSmallV1ConfigurationID: String { get { return "" } }
                public static var CodeLMSmallV2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var DeviceSummarizationTextSummarizerConfigurationID: String { get { return "" } }
                public static var ServerV2ICloudMailSemanticSearchID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2SummarizationTextSummarizerExperiment1ConfigurationID: String { get { return "" } }
                public static var TakeawaysTransformID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var TextEventExtractionClassifierID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func CodeLMLargeV1() throws -> AssetBackedLLMBundle { fatalError() }
                public static var EmojiKeywordExtractionConfigurationID: String { get { return "" } }
                public static func FMServiceLWV1() throws -> LLMBundle { fatalError() }
                public static func ConversationTitleSummarization() throws -> LLMBundle { fatalError() }
                public static var CodeLMLargeV4ConfigurationID: String { get { return "" } }
                public static func SpeechToSpeech() throws -> LLMBundle { fatalError() }
                public static func ShortcutsAskAFMActionV2() throws -> LLMBundle { fatalError() }
                public static func RemindersAutoCategorizeListOnDevice() throws -> AssetBackedLLMBundle { fatalError() }
                public static var RemindersSuggestActionItemsV2ConfigurationID: String { get { return "" } }
                public static var ServerMailReplyQAConfigurationID: String { get { return "" } }
                public static var SiriUserExperienceAnalysisConfigurationID: String { get { return "" } }
                public static func ServerV2VisualIntelligenceSuggestedQuestions() throws -> LLMBundle { fatalError() }
                public static var PhotosMemoriesCreationStorytellerV2ConfigurationID: String { get { return "" } }
                public static var SafetyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerPQAVerificationConfigurationID: String { get { return "" } }
                public static var ServerV2IntelligentPassCreationConfigurationID: String { get { return "" } }
                public static func AnswerSynthesisServerV2Experiment1() throws -> LLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var CodeLMSmallV1ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var CodeLMSmallV4ConfigurationID: String { get { return "" } }
                public static var FMAPIID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SearchQueryUnderstandingOnDeviceConfigurationID: String { get { return "" } }
                public static var SpeechSynthesisV7BaseID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SuperAutofillMultimodalConfigurationID: String { get { return "" } }
                public static func PlannerV4() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PlannerV2ConfigurationID: String { get { return "" } }
                public static var ServerMailReplyLongFormRewriteID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ShortcutsAskAFMActionConfigurationID: String { get { return "" } }
                public static func STXMultimodal() throws -> LLMBundle { fatalError() }
                public static func ServerV2BulletsTransform() throws -> LLMBundle { fatalError() }
                public static var AccessibilityMagnifierID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SummarizationTextSummarizerConfigurationID: String { get { return "" } }
                public static func ShortcutsAskAFMAction() throws -> LLMBundle { fatalError() }
                public static func ServerV2GenerativeShortcuts() throws -> LLMBundle { fatalError() }
                public static func ShortcutsAskAFMAction3B() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MagicRewriteID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var OpenEndedComposeWorkflowID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ShortcutsAskAFMAction3BV2ConfigurationID: String { get { return "" } }
                public static func ADMPromptRewriting() throws -> AssetBackedLLMBundle { fatalError() }
                public static func AFMTextInstruct3BBase() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMWithDraftID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ContentTaggerID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ImagePlaygroundEditSuggestionsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var LWPlannerV1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var MMGuardSafetyGuardrailID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var OpenEndedExtract3BConfigurationID: String { get { return "" } }
                public static var SafariMagicExtensionsAppStoreSearchTermsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerMailReplyLongFormBasicID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2AntiSpoofingConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV17ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var StructuralIntegrityCustomizedID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerTakeawaysTransform() throws -> LLMBundle { fatalError() }
                public static var SafariClusterValidationConfigurationID: String { get { return "" } }
                public static func RemindersAutoCategorizeList() throws -> LLMBundle { fatalError() }
                public static var ASRAFMDictationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var AnswerSynthesisServerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var CodeLMLargeV1ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var CodeLMLargeV2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var DescribeYourEditConfigurationID: String { get { return "" } }
                public static func ResponseGenerationV4() throws -> AssetBackedLLMBundle { fatalError() }
                public static var SpeechToSpeechConfigurationID: String { get { return "" } }
                public static func ActionValidator() throws -> AssetBackedLLMBundle { fatalError() }
                public static var FinancialInsightsConfigurationID: String { get { return "" } }
                public static var HoldAssistWaitTimeID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV19ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func SummarizationTextSummarizerAjaxBase() throws -> LLMBundle { fatalError() }
                public static var MailReplyQAID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func CodeLMSmallV2() throws -> AssetBackedLLMBundle { fatalError() }
                public static func PhotosMemoriesCreationGlobalTraits3b() throws -> AssetBackedLLMBundle { fatalError() }
                public static func Summarization() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2SafariSafeBrowsing() throws -> LLMBundle { fatalError() }
                public static var JournalMomentsReflectionConfigurationID: String { get { return "" } }
                public static var LWPlannerV1ConfigurationID: String { get { return "" } }
                public static var MMGuardSafetyGuardrail3BID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var MMSafetyConfigurationID: String { get { return "" } }
                public static var MessagesReplyWatchID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ModelAbuseGuardrailConfigurationID: String { get { return "" } }
                public static var NLRouterBaseConfigurationID: String { get { return "" } }
                public static var OpenEndedToneConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationGlobalTraitsV2ConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationQueryUnderstandingConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesTitleID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PrepubescentSafetyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ProfessionalToneConfigurationID: String { get { return "" } }
                public static var RemindersGroceryListID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SafariTabGroupTopicConfigurationID: String { get { return "" } }
                public static var ServerV2AccessibilityMagnifierID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2AccessibilityReaderAIID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ShortcutsAskAFMAction3BID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var StructuralExtractionConfigurationID: String { get { return "" } }
                public static var SuggestRecipeItemsV2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var TextEventExtractionConfigurationID: String { get { return "" } }
                public static var VoiceControlAIV2ConfigurationID: String { get { return "" } }
                public static func ServerV2OpenEndedInteractionExperiment1() throws -> LLMBundle { fatalError() }
                public static func LWPlannerV1() throws -> LLMBundle { fatalError() }
                public static var PersonalizedSmartReplyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var StructuralIntegrityCustomizedConfigurationID: String { get { return "" } }
                public static func ServerV2MiscSafety() throws -> LLMBundle { fatalError() }
                public static var InstructServerAutograderConfigurationID: String { get { return "" } }
                public static var PlannerV5ConfigurationID: String { get { return "" } }
                public static var ServerProofreadingReviewID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ConciseToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2MailProfileCreationExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func OpenEndedToneQueryResponseV1() throws -> LLMBundle { fatalError() }
                public static var IntelligentRoutingRoomClassificationConfigurationID: String { get { return "" } }
                public static func CodeLMSafetyGuardrail() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeSafetyGuardrailConfigurationID: String { get { return "" } }
                public static var OpenEndedToneBaseID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2RemindersAutoCategorizeListConfigurationID: String { get { return "" } }
                public static func ServerV2Proofreading() throws -> LLMBundle { fatalError() }
                public static func CodeLMSmallV3() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2PhotosMemoriesCreationStorytellerV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ProfessionalTone() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AutoTaggerConfigurationID: String { get { return "" } }
                public static var ResponseGenerationV4ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ResponseGenerationV7ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2PhotosMemoriesCreationGlobalTraitsV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var VisualGenerationQueryHandlingLiteID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func PCCInteractWKA() throws -> LLMBundle { fatalError() }
                public static var ContextProgramID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var NotifyMeWhenID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var OpenEndedReflectionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PQAVerificationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationAssetCurationV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2SummarizationTextSummarizerConfigurationID: String { get { return "" } }
                public static func PhotosMemoriesCreationQueryUnderstandingV2() throws -> LLMBundle { fatalError() }
                public static var ConciseToneID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var MachineTranslationConfigurationID: String { get { return "" } }
                public static var PQAVerificationConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationQueryUnderstanding3bConfigurationID: String { get { return "" } }
                public static var ResponseGenerationV7ConfigurationID: String { get { return "" } }
                public static func PhotosMemoriesCreationGlobalTraits() throws -> LLMBundle { fatalError() }
                public static var ADMPromptAnalyzerConfigurationID: String { get { return "" } }
                public static var SmartNamingID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerV2WritingQuestionAnswer() throws -> LLMBundle { fatalError() }
                public static func LWOnDevicePlannerV1() throws -> AssetBackedLLMBundle { fatalError() }
                public static func SafariClusterValidation() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MessagesActionConfigurationID: String { get { return "" } }
                public static var ServerSmallIPIClassifierConfigurationID: String { get { return "" } }
                public static var VoiceControlAIConfigurationID: String { get { return "" } }
                public static func ServerV2OpenEndedExtract() throws -> LLMBundle { fatalError() }
                public static var PhotosMemoriesCreationGlobalTraits3bConfigurationID: String { get { return "" } }
                public static var ServerSmallIPIClassifierID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func DistilledMessagesReply() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MagicRewriteConfigurationID: String { get { return "" } }
                public static var OpenEndedExtractText3BID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PCCTestConfigurationID: String { get { return "" } }
                public static var ServerV2ProfessionalToneExperiment1ConfigurationID: String { get { return "" } }
                public static func SiriTTSVoiceNatural() throws -> LLMBundle { fatalError() }
                public static var ContextAwarenessID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2SummarizationTextSummarizerExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var StructuralExtractionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerV2IntelligentPassCreation() throws -> LLMBundle { fatalError() }
                public static func ProofreadingReview() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2PhotosMemoriesCreationGlobalTraitsV3() throws -> LLMBundle { fatalError() }
                public static var PlannerV9ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var RemindersSuggestActionItemsV2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func PlannerV8() throws -> LLMBundle { fatalError() }
                public static func InstructFMApiGeneric() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PhotosMemoriesCreationGlobalTraitsV3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV13ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ICloudMailOrderBundlingID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func AccessibilityMagnifier() throws -> LLMBundle { fatalError() }
                public static func ServerV2JournalFollowUpPrompts() throws -> LLMBundle { fatalError() }
                public static var CodeLMLargeV1ConfigurationID: String { get { return "" } }
                public static var CodeLMSafetyGuardrailID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ExternalSearchPartnerConfigurationID: String { get { return "" } }
                public static var LWPlannerV4ConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationQueryUnderstandingV3ConfigurationID: String { get { return "" } }
                public static var PlannerV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ImagePlaygroundEditSuggestions() throws -> AssetBackedLLMBundle { fatalError() }
                public static var OpenEndedToneQueryResponseID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SearchQueryUnderstandingOnDeviceID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerMagicRewriteConfigurationID: String { get { return "" } }
                public static func ServerV2SummarizeShortcuts() throws -> LLMBundle { fatalError() }
                public static func LLMSiriDevice() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PromptRewriteConfigurationID: String { get { return "" } }
                public static func ServerV2BulletsTransformExperiment1() throws -> LLMBundle { fatalError() }
                public static var PCCTestFastID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func TablesTransform() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PCCTestProConfigurationID: String { get { return "" } }
                public static var ServerV2StructuralIntegrityConfigurationID: String { get { return "" } }
                public static var StructuredExtractionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func VisualGenerationQueryHandlingLite() throws -> AssetBackedLLMBundle { fatalError() }
                public static func AnswerSynthesisServerV2Experiment2() throws -> LLMBundle { fatalError() }
                public static var CodeLMLargeV3ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ExternalSearchPartnerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var FitnessSummaryID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var GroundedVisualIntelligenceContentClassifierConfigurationID: String { get { return "" } }
                public static var InstructServerBaseConfigurationID: String { get { return "" } }
                public static var IntelligentRoutingRoomClassificationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var OpenEndedExtractServerConfigurationID: String { get { return "" } }
                public static var ServerV2ChangePasswordForMeID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var StructuralIntegrityID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SummarizationTextSummarizerAjaxBaseID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var TablesTransformConfigurationID: String { get { return "" } }
                public static func ServerV2SiriVisualIntelligence() throws -> LLMBundle { fatalError() }
                public static func AFMTextInstruct3BThirdPartySD() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2GenerativeShortcutsV14ConfigurationID: String { get { return "" } }
                public static func PlannerV6() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ADMPeopleGroundingConfigurationID: String { get { return "" } }
                public static var VideoCaptionConfigurationID: String { get { return "" } }
                public static func ServerV2PhotosMemoriesCreationQueryUnderstandingV3() throws -> LLMBundle { fatalError() }
                public static func TextGuardSafetyGuardrail() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ADMPromptRewritingID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var OpenEndedExtract300mID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2SummarizationTextSummarizerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SpeechSynthesisV7BaseConfigurationID: String { get { return "" } }
                public static func LLMSiriPCC() throws -> LLMBundle { fatalError() }
                public static func Planner() throws -> LLMBundle { fatalError() }
                public static var FMServiceLWV1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2TablesTransformID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func OpenEndedInteraction() throws -> LLMBundle { fatalError() }
                public static var ASRNaturalDictationSpeechID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ChatGPTID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var LWPCCInteractID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PCCInteractProConfigurationID: String { get { return "" } }
                public static var PhotosCommonConfigurationID: String { get { return "" } }
                public static var TablesTransformID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var UrgencyClassificationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func TamalePOI() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2STXMultimodalConfigurationID: String { get { return "" } }
                public static func FinancialInsights() throws -> LLMBundle { fatalError() }
                public static var ADMBackgroundPromptID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerProfessionalToneConfigurationID: String { get { return "" } }
                public static var TextGuardSafetyGuardrailConfigurationID: String { get { return "" } }
                public static func SafariNotifyMeWhenSuggestions() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2GenerativeShortcutsV17() throws -> LLMBundle { fatalError() }
                public static func ServerStructuredExtraction() throws -> LLMBundle { fatalError() }
                public static var HomeKitSummaryNotificationsConfigurationID: String { get { return "" } }
                public static var MailReplyQAConfigurationID: String { get { return "" } }
                public static var OpenEndedExtractServerTextConfigurationID: String { get { return "" } }
                public static var PhotosMemoriesCreationGlobalTraitsV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ResponseGenerationV5ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2OpenEndedToneConfigurationID: String { get { return "" } }
                public static var ServerV2SiriVisualIntelligenceConfigurationID: String { get { return "" } }
                public static var SuggestRecipeItemsV2ConfigurationID: String { get { return "" } }
                public static var SummarizeShortcutsConfigurationID: String { get { return "" } }
                public static func OpenEndedComposeWorkflow() throws -> LLMBundle { fatalError() }
                public static func ServerBulletsTransform() throws -> LLMBundle { fatalError() }
                public static var AFMTextInstruct3BBaseID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func StructuralIntegrityCustomized() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2WritingQuestionAnswerExperiment1() throws -> LLMBundle { fatalError() }
                public static func OpenEndedCompose() throws -> LLMBundle { fatalError() }
                public static var CodeLMSmallV4ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func LWPlannerV5() throws -> LLMBundle { fatalError() }
                public static var ServerV2HKSVProcessingCaptionsProID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ICloudMailSemanticSearchConfigurationID: String { get { return "" } }
                public static func ADMBackgroundPrompt() throws -> AssetBackedLLMBundle { fatalError() }
                public static func SearchQueryUnderstandingServerV2() throws -> LLMBundle { fatalError() }
                public static func ADMPromptAnalyzer() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment2ConfigurationID: String { get { return "" } }
                public static func PCCTest() throws -> LLMBundle { fatalError() }
                public static var CodeLMID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func FMAPI() throws -> LLMBundle { fatalError() }
                public static var AFMTextInstruct3BBaseConfigurationID: String { get { return "" } }
                public static var AFMTextInstruct3BThirdPartySDConfigurationID: String { get { return "" } }
                public static var AutonamingMessagesConfigurationID: String { get { return "" } }
                public static var FactualConsistencyClassifierConfigurationID: String { get { return "" } }
                public static var LWPlannerV3ConfigurationID: String { get { return "" } }
                public static var MailReplyConfigurationID: String { get { return "" } }
                public static var ServerV2AgeVerificationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2WritingQuestionAnswerConfigurationID: String { get { return "" } }
                public static func CodeLMSmallV5() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment3ConfigurationID: String { get { return "" } }
                public static var PCCInteractFastID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SmartAppActionsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func PhotosMemoriesCreationQueryUnderstandingV3() throws -> LLMBundle { fatalError() }
                public static func ServerV2PhotosMemoriesCreationAssetCurationV2() throws -> LLMBundle { fatalError() }
                public static var RemindersGroceryListConfigurationID: String { get { return "" } }
                public static var ServerV2SafariTabGroupTopicConfigurationID: String { get { return "" } }
                public static func PCCTestPro() throws -> LLMBundle { fatalError() }
                public static func NLRouterBase() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2FriendlyToneExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var VisualGenerationQueryHandlingLiteConfigurationID: String { get { return "" } }
                public static func ServerV2SafariMagicExtensions() throws -> LLMBundle { fatalError() }
                public static var CodeLMLargeV5ConfigurationID: String { get { return "" } }
                public static var CodeLMSmallV3ConfigurationID: String { get { return "" } }
                public static var CodeLMV2ConfigurationID: String { get { return "" } }
                public static var DistilledMessagesReplyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var OpenEndedExtractText3BConfigurationID: String { get { return "" } }
                public static var PromptAnalysisConfigurationID: String { get { return "" } }
                public static var SuggestRecipeItemsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerFitnessWorkoutVoice() throws -> LLMBundle { fatalError() }
                public static var ServerFriendlyToneConfigurationID: String { get { return "" } }
                public static var ServerV2FriendlyToneExperiment1ConfigurationID: String { get { return "" } }
                public static func SummarizeShortcuts() throws -> AssetBackedLLMBundle { fatalError() }
                public static var GenerativeShortcutsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func OpenEndedToneBase() throws -> LLMBundle { fatalError() }
                public static var CodeLMV3ConfigurationID: String { get { return "" } }
                public static var ConversationTitleSummarizationConfigurationID: String { get { return "" } }
                public static var HoldAssistWaitTimeConfigurationID: String { get { return "" } }
                public static var MMGuardSafetyGuardrailConfigurationID: String { get { return "" } }
                public static var SafetyGuardrailID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerSmallActionValidatorConfigurationID: String { get { return "" } }
                public static func InstructServerAutograder() throws -> LLMBundle { fatalError() }
                public static var FMAPICliID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PrepubescentSafety() throws -> AssetBackedLLMBundle { fatalError() }
                public static var LLMSiriPCCConfigurationID: String { get { return "" } }
                public static var PromptRewriteID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SafetyGuardrailConfigurationID: String { get { return "" } }
                public static var SummarizationTextSummarizerAjaxBaseConfigurationID: String { get { return "" } }
                public static func PromptAnalysis() throws -> LLMBundle { fatalError() }
                public static func GMSPrototypeEmbeddings() throws -> LLMBundle { fatalError() }
                public static var CodeLMLargeV2ConfigurationID: String { get { return "" } }
                public static var MessagesUserRequestID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SafariPhishingClassificationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2ProofreadingExperiment1ConfigurationID: String { get { return "" } }
                public static func PQAVerificationBase() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerTablesTransformID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2AutograderConfigurationID: String { get { return "" } }
                public static var TamalePOIID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerV2PhotosMemoriesCreationStorytellerV2() throws -> LLMBundle { fatalError() }
                public static var ResponseGenerationV6ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerFitnessWorkoutVoiceConfigurationID: String { get { return "" } }
                public static func ServerV2TablesTransformExperiment1() throws -> LLMBundle { fatalError() }
                public static var ServerV2PhotosMemoriesCreationGlobalTraitsV3ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func OpenEndedTone() throws -> LLMBundle { fatalError() }
                public static var OpenEndedExtract3BID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2OpenEndedExtractConfigurationID: String { get { return "" } }
                public static func GMSPrototype() throws -> LLMBundle { fatalError() }
                public static var LWPlannerV5ConfigurationID: String { get { return "" } }
                public static var MMTExpertID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosLibraryUnderstandingMMConfigurationID: String { get { return "" } }
                public static var RemindersAutoCategorizeListOnDeviceConfigurationID: String { get { return "" } }
                public static var SafariMagicExtensionsAppStoreSearchTermsConfigurationID: String { get { return "" } }
                public static var SmartNamingConfigurationID: String { get { return "" } }
                public static var SummarizeShortcutsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerPersonalizedSmartReply() throws -> LLMBundle { fatalError() }
                public static func PhotosMemoriesCreationQueryUnderstanding3b() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerMailReplyLongFormBasic() throws -> LLMBundle { fatalError() }
                public static var AnswerSynthesisConfigurationID: String { get { return "" } }
                public static func OpenEndedExtractText3B() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMSmallV5ConfigurationID: String { get { return "" } }
                public static var ProofreadingReviewConfigurationID: String { get { return "" } }
                public static var ServerPersonalizedSmartReplyID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2HomeKitSummaryNotificationsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ProfessionalToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ResponseGeneration() throws -> LLMBundle { fatalError() }
                public static var ServerV2AntiSpoofingID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2AntiSpoofing() throws -> LLMBundle { fatalError() }
                public static func DescribeYourEdit() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment5ConfigurationID: String { get { return "" } }
                public static var SmallMessagesReplyWatchConfigurationID: String { get { return "" } }
                public static var StructuredExtractionConfigurationID: String { get { return "" } }
                public static func UIGrounding() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2SummarizationTextSummarizer() throws -> LLMBundle { fatalError() }
                public static var ChatGPTConfigurationID: String { get { return "" } }
                public static var MiscSafetyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SafetyConfigurationID: String { get { return "" } }
                public static var ServerV2ChangePasswordForMeConfigurationID: String { get { return "" } }
                public static var VideoCaptionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func LWPlannerV3() throws -> LLMBundle { fatalError() }
                public static func ServerV2ProfessionalTone() throws -> LLMBundle { fatalError() }
                public static var FitnessWorkoutVoiceV1ConfigurationID: String { get { return "" } }
                public static var JournalMomentsReflectionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PlannerV5ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerV2ConciseToneExperiment1() throws -> LLMBundle { fatalError() }
                public static var OpenEndedSchemaConfigurationID: String { get { return "" } }
                public static var ServerV2OpenEndedComposeExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func TextExpert() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AFMTextInstruct3BThirdPartyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var LWPCCInteractConfigurationID: String { get { return "" } }
                public static var ServerConciseToneConfigurationID: String { get { return "" } }
                public static var ServerV2AccessibilityReaderAIConfigurationID: String { get { return "" } }
                public static var ServerV2CalendarMagicComposeBackwardPassConfigurationID: String { get { return "" } }
                public static var ServerV2ShortcutsUseModelActionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var TextPersonExtractionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func VIContentClassifier() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ADMBackgroundPromptConfigurationID: String { get { return "" } }
                public static var AnswerSynthesisServerV2Experiment5ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PlannerV6ConfigurationID: String { get { return "" } }
                public static var ServerConciseToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func OpenEndedExtractServerText() throws -> LLMBundle { fatalError() }
                public static func ServerV2ShortcutsUseModelAction() throws -> LLMBundle { fatalError() }
                public static func IPIClassifier() throws -> AssetBackedLLMBundle { fatalError() }
                public static var OpenEndedReflectionConfigurationID: String { get { return "" } }
                public static func ServerV2RemindersAutoCategorizeList() throws -> LLMBundle { fatalError() }
                public static func MiscSafetyCustomized() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeSafetyGuardrailID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SearchQueryUnderstandingServerV2ConfigurationID: String { get { return "" } }
                public static func PCCInteractFast() throws -> LLMBundle { fatalError() }
                public static var ContextAwarenessConfigurationID: String { get { return "" } }
                public static var LWPlannerV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ICloudMailOrderBundlingConfigurationID: String { get { return "" } }
                public static var ServerV2VisualIntelligenceNutritionConfigurationID: String { get { return "" } }
                public static var VoiceControlAIV2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func LWPlannerV4() throws -> LLMBundle { fatalError() }
                public static var MailReplyLongFormBasicConfigurationID: String { get { return "" } }
                public static var PCCTestID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PlannerConfigurationID: String { get { return "" } }
                public static var ResponseGenerationV8ConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV20ConfigurationID: String { get { return "" } }
                public static var ServerV2ShortcutsAskAFMActionV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2HomeKitSummaryNotifications() throws -> LLMBundle { fatalError() }
                public static var PCCTestProID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2OpenEndedComposeConfigurationID: String { get { return "" } }
                public static var TextPersonExtractionConfigurationID: String { get { return "" } }
                public static func UIPreviews() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMLargeV5ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func UrgencyClassification() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2InsightAgents() throws -> LLMBundle { fatalError() }
                public static var MMSafetyID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesTitleConfigurationID: String { get { return "" } }
                public static var ServerDescribeYourEditConfigurationID: String { get { return "" } }
                public static var ServerV2TakeawaysTransformExperiment1ConfigurationID: String { get { return "" } }
                public static var ShortcutsAskAFMAction3BV2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var TextEventExtractionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerV2GenerativeShortcutsV12() throws -> LLMBundle { fatalError() }
                public static func NewsTopicSummarization() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ADMPromptRewritingConfigurationID: String { get { return "" } }
                public static var ServerV2AgeEstimationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerDescribeYourEdit() throws -> LLMBundle { fatalError() }
                public static func PersonalizedSmartReply() throws -> AssetBackedLLMBundle { fatalError() }
                public static var MailReplyLongFormRewriteID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var UIPreviewsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func AnswerSynthesisServerV2Experiment4() throws -> LLMBundle { fatalError() }
                public static var PhotosMemoriesCreationStoryteller3bConfigurationID: String { get { return "" } }
                public static var ServerV2PromptRewriteConfigurationID: String { get { return "" } }
                public static func ServerV2FitnessWorkoutVoice() throws -> LLMBundle { fatalError() }
                public static var SearchQueryUnderstandingServerV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerPersonalizedSmartReplyConfigurationID: String { get { return "" } }
                public static func DistilledMessagesAction() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerFitnessWorkoutVoiceID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ContextAwareness() throws -> AssetBackedLLMBundle { fatalError() }
                public static func FMAPICli() throws -> LLMBundle { fatalError() }
                public static var MMTExpertConfigurationID: String { get { return "" } }
                public static func ServerV2ChangePasswordForMe() throws -> LLMBundle { fatalError() }
                public static var OpenEndedToneID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2PromptRewrite() throws -> LLMBundle { fatalError() }
                public static var BulletsTransformConfigurationID: String { get { return "" } }
                public static var ConversationTitleSummarizationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var EmojiKeywordExtractionID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var JournalFollowUpPromptsConfigurationID: String { get { return "" } }
                public static var MMGuardSafetyGuardrailServerConfigurationID: String { get { return "" } }
                public static var PhotosLibraryUnderstandingT2TID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationGlobalTraitsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationQueryUnderstandingID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PlannerV7ConfigurationID: String { get { return "" } }
                public static var ServerV2ConciseToneExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func MMGuardSafetyGuardrailServer() throws -> LLMBundle { fatalError() }
                public static var ServerV2ProfessionalToneExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func TakeawaysTransform() throws -> AssetBackedLLMBundle { fatalError() }
                public static func OpenEndedToneQueryResponse() throws -> LLMBundle { fatalError() }
                public static func GroundedVisualIntelligenceContentClassifier() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2SummarizationTextSummarizerExperiment1() throws -> LLMBundle { fatalError() }
                public static var JournalMomentsClassificationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var MMGuardSafetyGuardrail3BConfigurationID: String { get { return "" } }
                public static var MiscSafetyCustomizedConfigurationID: String { get { return "" } }
                public static var NewsTopicSummarizationID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SiriTTSVoiceNaturalConfigurationID: String { get { return "" } }
                public static var UIGroundingID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerSmallIPIClassifier() throws -> LLMBundle { fatalError() }
                public static func CodeLMSmallV4() throws -> AssetBackedLLMBundle { fatalError() }
                public static var RemindersAutoCategorizeListID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerConciseTone() throws -> LLMBundle { fatalError() }
                public static var OpenEndedToneQueryResponseV2ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func SuggestRecipeItemsV2() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PCCInteractWKAID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationBaseID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ShortcutsAskAFMActionV2ConfigurationID: String { get { return "" } }
                public static func AnswerSynthesisServer() throws -> LLMBundle { fatalError() }
                public static func CodeLMWithDraft() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PlannerV8ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2HKSVProcessingCaptionsConfigurationID: String { get { return "" } }
                public static var ServerV2HKSVProcessingCaptionsProConfigurationID: String { get { return "" } }
                public static var VisualIntelligenceID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func MessagesUserRequest() throws -> LLMBundle { fatalError() }
                public static func PromptRewrite() throws -> LLMBundle { fatalError() }
                public static var ServerV2AgeEstimationConfigurationID: String { get { return "" } }
                public static var ServerV2OpenEndedInteractionExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func NotifyMeWhen() throws -> LLMBundle { fatalError() }
                public static func ServerV2AccessibilityMagnifier() throws -> LLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2Experiment1ConfigurationID: String { get { return "" } }
                public static var MailReplyLongFormBasicID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var OpenEndedExtractServerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ConciseToneExperiment1ConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2PhotosMemoriesCreationGlobalTraitsV3ConfigurationID: String { get { return "" } }
                public static func RemindersSuggestActionItemsV2() throws -> AssetBackedLLMBundle { fatalError() }
                public static func AnswerSynthesisServerV2_ShortOutput() throws -> LLMBundle { fatalError() }
                public static func ServerV2ShortcutsAskAFMActionV2() throws -> LLMBundle { fatalError() }
                public static var PhotosMemoriesCreationAssetCurationOutlier3bID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2ICloudMailEventExtractionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func TextEventExtractionClassifier() throws -> AssetBackedLLMBundle { fatalError() }
                public static func MailReplyLongFormRewrite() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerMagicRewriteID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ResponseGenerationV7() throws -> LLMBundle { fatalError() }
                public static var OpenEndedExtractWorkflowID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func SafetyGuardrail() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2VisualIntelligenceNutrition() throws -> LLMBundle { fatalError() }
                public static func MessagesActionSmall() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2GenerativeShortcutsV20() throws -> LLMBundle { fatalError() }
                public static func SmartNaming() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerTakeawaysTransformConfigurationID: String { get { return "" } }
                public static var ServerV2GenerativeShortcutsV12ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2ICloudMailOrderBundling() throws -> LLMBundle { fatalError() }
                public static var PlannerV3ConfigurationID: String { get { return "" } }
                public static var Voice2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func ServerV2AccessibilityReaderAI() throws -> LLMBundle { fatalError() }
                public static func AnswerSynthesisServerV2Experiment5() throws -> LLMBundle { fatalError() }
                public static var IPIClassifierID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerV2ShortcutsUseModelActionConfigurationID: String { get { return "" } }
                public static func PhotosMemoriesCreationBase() throws -> LLMBundle { fatalError() }
                public static func FriendlyTone() throws -> AssetBackedLLMBundle { fatalError() }
                public static func CodeLMLargeV2() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ContextProgramConfigurationID: String { get { return "" } }
                public static var DistilledMessagesActionConfigurationID: String { get { return "" } }
                public static var InstructServerBaseID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2ProofreadingConfigurationID: String { get { return "" } }
                public static func ServerV2AgeVerification() throws -> LLMBundle { fatalError() }
                public static var AnswerSynthesisServerConfigurationID: String { get { return "" } }
                public static var CodeLMSmallV3ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var CodeLMV2ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var MMGuardSafetyGuardrailServerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2PromptRewriteID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var TextExpertID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var Voice2ConfigurationID: String { get { return "" } }
                public static func PlannerV9() throws -> LLMBundle { fatalError() }
                public static func OpenEndedReflection() throws -> LLMBundle { fatalError() }
                public static func ServerV2TakeawaysTransformExperiment1() throws -> LLMBundle { fatalError() }
                public static func ServerV2OpenEndedInteraction() throws -> LLMBundle { fatalError() }
                public static func ServerFriendlyTone() throws -> LLMBundle { fatalError() }
                public static var LLMSiriPCCID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationTitle3bID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ResponseGenerationConfigurationID: String { get { return "" } }
                public static var ResponseGenerationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2JournalFollowUpPromptsConfigurationID: String { get { return "" } }
                public static var ShortcutsAskAFMActionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func BulletsTransform() throws -> AssetBackedLLMBundle { fatalError() }
                public static var FriendlyToneConfigurationID: String { get { return "" } }
                public static var ResponseGenerationV4ConfigurationID: String { get { return "" } }
                public static var ServerV2PhotosMemoriesCreationStorytellerV2ConfigurationID: String { get { return "" } }
                public static func SafariMagicExtensionsAppStoreSearchTerms() throws -> AssetBackedLLMBundle { fatalError() }
                public static var NLRouterBaseID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var OpenEndedToneQueryResponseV1ConfigurationID: String { get { return "" } }
                public static var OpenEndedToneQueryResponseV2ConfigurationID: String { get { return "" } }
                public static var ServerV2JournalFollowUpPromptsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2SafariSafeBrowsingID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func JournalMomentsReflection() throws -> AssetBackedLLMBundle { fatalError() }
                public static func GenerativeShortcuts() throws -> LLMBundle { fatalError() }
                public static var HomeKitSummaryNotificationsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static func DeviceSummarizationTextSummarizer() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2GenerativeShortcutsV15ConfigurationID: String { get { return "" } }
                public static func ServerMailReplyQA() throws -> LLMBundle { fatalError() }
                public static func MailReplyQA() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerV2OpenEndedExtractID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2ICloudMailEventExtraction() throws -> LLMBundle { fatalError() }
                public static var ServerBulletsTransformConfigurationID: String { get { return "" } }
                public static func PQAVerification() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ServerV2GenerativeShortcutsV14() throws -> LLMBundle { fatalError() }
                public static var MessagesUserRequestConfigurationID: String { get { return "" } }
                public static var SafariNotifyMeWhenSuggestionsID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var SafetyNSFWConfigurationID: String { get { return "" } }
                public static var SearchQueryUnderstandingServerID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2GenerativeShortcutsV15ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ServerV2SafariSafeBrowsingConfigurationID: String { get { return "" } }
                public static var ServerV2WritingQuestionAnswerExperiment1ConfigurationID: String { get { return "" } }
                public static func ServerV2MailProfileCreationExperiment1() throws -> LLMBundle { fatalError() }
                public static func SearchQueryUnderstandingOnDevice() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ASRAFMDictation() throws -> AssetBackedLLMBundle { fatalError() }
                public static func PhotosMemoriesCreationStorytellerV2() throws -> LLMBundle { fatalError() }
                public static func MMSafety() throws -> AssetBackedLLMBundle { fatalError() }
                public static func ADMPeopleGrounding() throws -> AssetBackedLLMBundle { fatalError() }
                public static var ServerStructuredExtractionID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func LWPCCInteract() throws -> LLMBundle { fatalError() }
                public static var CodeLMV1ANE3BID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var FinancialInsightsID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func CodeLMV2() throws -> AssetBackedLLMBundle { fatalError() }
                public static var PlannerV4ID: ResourceBundleIdentifier<AssetBackedLLMBundle> { get { fatalError() } }
                public static var ServerPQAVerificationID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var SuperAutofillMultimodalID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func PhotosMemoriesTitle() throws -> AssetBackedLLMBundle { fatalError() }
                public static var AnswerSynthesisServerV2ConfigurationID: String { get { return "" } }
                public static var ResponseGenerationV8ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func MessagesAction() throws -> AssetBackedLLMBundle { fatalError() }
                public static var CodeLMSmallV2ConfigurationID: String { get { return "" } }
                public static var FMServiceLWV1ConfigurationID: String { get { return "" } }
                public static var SafariPhishingClassificationConfigurationID: String { get { return "" } }
                public static var ServerV2TakeawaysTransformExperiment1ID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var ShortcutsUseModelActionProID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static func ServerV2PrepubescentSafety() throws -> LLMBundle { fatalError() }
                public static var LWPlannerV2ConfigurationID: String { get { return "" } }
                public static var OpenEndedSchemaID: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
                public static var PhotosMemoriesCreationBaseConfigurationID: String { get { return "" } }
                public static var ServerMailReplyLongFormRewriteConfigurationID: String { get { return "" } }
                public static var ServerV2PrepubescentSafetyConfigurationID: String { get { return "" } }
                public static func ServerV2GenerativeShortcutsV15() throws -> LLMBundle { fatalError() }
                public static var ServerV2VisualIntelligenceSuggestedQuestionsConfigurationID: String { get { return "" } }
                public static func MMTExpert() throws -> AssetBackedLLMBundle { fatalError() }
            }
            public enum LLMCompileDraft: Hashable, Sendable {
                case _mock
                public static var InstructFMApiThirdPartyCompileDraftConfigurationID: String { get { return "" } }
                public static func InstructFMApiThirdPartyCompileDraft() throws -> LLMCompileDraftBundle { fatalError() }
                public static var InstructFMApiThirdPartyCompileDraftID: ResourceBundleIdentifier<LLMCompileDraftBundle> { get { fatalError() } }
            }
            public enum LLMDraft: Hashable, Sendable {
                case _mock
                public static var TextPersonExtractionDraftConfigurationID: String { get { return "" } }
                public static func TextPersonExtractionDraft() throws -> AssetBackedLLMDraftBundle { fatalError() }
                public static var OpenEndedExtract300mDraftID: ResourceBundleIdentifier<AssetBackedLLMDraftBundle> { get { fatalError() } }
                public static func TextEventExtractionDraft() throws -> AssetBackedLLMDraftBundle { fatalError() }
                public static func TextunderstandingDraft() throws -> AssetBackedLLMDraftBundle { fatalError() }
                public static var TextEventExtractionDraftID: ResourceBundleIdentifier<AssetBackedLLMDraftBundle> { get { fatalError() } }
                public static var TextunderstandingDraftConfigurationID: String { get { return "" } }
                public static var TextunderstandingDraftID: ResourceBundleIdentifier<AssetBackedLLMDraftBundle> { get { fatalError() } }
                public static func OpenEndedExtract300mDraft() throws -> AssetBackedLLMDraftBundle { fatalError() }
                public static var OpenEndedExtract300mDraftConfigurationID: String { get { return "" } }
                public static var TextEventExtractionDraftConfigurationID: String { get { return "" } }
                public static var TextPersonExtractionDraftID: ResourceBundleIdentifier<AssetBackedLLMDraftBundle> { get { fatalError() } }
            }
            case _mock
        }
        public enum VisionModel: Hashable, Sendable {
            case _mock
            public static func HumanRectangles() throws -> VisionModelBundle { fatalError() }
            public static var FaceCaptureQualityID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var HumanRectanglesConfigurationID: String { get { return "" } }
            public static var PersonSegmentationID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var RecognizeAnimalsConfigurationID: String { get { return "" } }
            public static func FaceCaptureQuality() throws -> VisionModelBundle { fatalError() }
            public static var DetectBarcodesID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var FaceLandmarksID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var ForegroundInstanceSegmentationConfigurationID: String { get { return "" } }
            public static var ForegroundInstanceSegmentationID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var HumanRectanglesID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var MaskTrackerConfigurationID: String { get { return "" } }
            public static var MaskTrackerID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var PersonInstanceSegmentationID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static var SmudgeDetectionID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static func ForegroundInstanceSegmentation() throws -> VisionModelBundle { fatalError() }
            public static var DetectBarcodesConfigurationID: String { get { return "" } }
            public static func PersonSegmentation() throws -> VisionModelBundle { fatalError() }
            public static var FaceLandmarksConfigurationID: String { get { return "" } }
            public static var PersonInstanceSegmentationConfigurationID: String { get { return "" } }
            public static func MaskTracker() throws -> VisionModelBundle { fatalError() }
            public static var SmudgeDetectionConfigurationID: String { get { return "" } }
            public static func SmudgeDetection() throws -> VisionModelBundle { fatalError() }
            public static var RecognizeAnimalsID: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
            public static func PersonInstanceSegmentation() throws -> VisionModelBundle { fatalError() }
            public static var FaceCaptureQualityConfigurationID: String { get { return "" } }
            public static var PersonSegmentationConfigurationID: String { get { return "" } }
            public static func DetectBarcodes() throws -> VisionModelBundle { fatalError() }
            public static func FaceLandmarks() throws -> VisionModelBundle { fatalError() }
            public static func RecognizeAnimals() throws -> VisionModelBundle { fatalError() }
        }
        public enum VisualGeneration: Hashable, Sendable {
            public enum Diffusion: Hashable, Sendable {
                case _mock
                public static func Emoji() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var PersonalizedIllustrationID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static func Sketch() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var EmojiID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var PersonalizedEmojiConfigurationID: String { get { return "" } }
                public static var PersonalizedScribbleConfigurationID: String { get { return "" } }
                public static var RefinerConfigurationID: String { get { return "" } }
                public static func Scribble() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static func PersonalizedSketch() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static func Animation() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static func Refiner() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var MessagesBackgroundsID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var PersonalizedEmojiID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var PersonalizedSketchID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var ScribbleID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var SketchID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static func PersonalizedScribble() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var AnimationConfigurationID: String { get { return "" } }
                public static var PersonalizedIllustrationConfigurationID: String { get { return "" } }
                public static var PersonalizedScribbleID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var ScribbleConfigurationID: String { get { return "" } }
                public static var SkinToneEmojiConfigurationID: String { get { return "" } }
                public static func Illustration() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var SketchConfigurationID: String { get { return "" } }
                public static func SkinToneEmoji() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var AnimationID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var IllustrationConfigurationID: String { get { return "" } }
                public static var PersonalizedSketchConfigurationID: String { get { return "" } }
                public static func PersonalizedIllustration() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var DiffusionBaseID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var EmojiConfigurationID: String { get { return "" } }
                public static var MessagesBackgroundsConfigurationID: String { get { return "" } }
                public static var SkinToneEmojiID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static func PersonalizedAnimation() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static func PersonalizedEmoji() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var PersonalizedAnimationConfigurationID: String { get { return "" } }
                public static var RefinerID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static func MessagesBackgrounds() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static func DiffusionBase() throws -> AssetBackedDiffusionBundle { fatalError() }
                public static var DiffusionBaseConfigurationID: String { get { return "" } }
                public static var IllustrationID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
                public static var PersonalizedAnimationID: ResourceBundleIdentifier<AssetBackedDiffusionBundle> { get { fatalError() } }
            }
            public enum ServerDiffusion: Hashable, Sendable {
                case _mock
                public static var ServerDiffusionInpaintingLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionPersonalizationGenmojiLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionTextGuidedEditConfigurationID: String { get { return "" } }
                public static func ServerDiffusionUpResolution() throws -> ServerDiffusionBundle { fatalError() }
                public static func ServerDiffusionTextToImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionDirectManipulationLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionDrawingConditionerConfigurationID: String { get { return "" } }
                public static var ServerDiffusionInpaintingID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionMessagesBackgroundID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionOutpaintingLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionOutpaintingLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionSpatialReframingLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionTextToImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionTextToImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionUpResolutionID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static func ServerDiffusionPersonalizationGenmojiLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionUpResolutionLargeImageConfigurationID: String { get { return "" } }
                public static func ServerDiffusionTextToImageLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionDrawingConditionerLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionPersonalizationGenmojiLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionPersonalizationLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static func ServerDiffusionDrawingConditioner() throws -> ServerDiffusionBundle { fatalError() }
                public static func ServerDiffusionDrawingConditionerLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionGenmojiConfigurationID: String { get { return "" } }
                public static var ServerDiffusionInpaintingConfigurationID: String { get { return "" } }
                public static var ServerDiffusionPersonalizationGenmojiID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionSpatialReframingLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionTextGuidedEditID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static func ServerDiffusionGenmojiLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static func ServerDiffusionTextGuidedEdit() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionDrawingConditionerID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionPersonalizationLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionSpatialReframingID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionUpResolutionLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static func ServerDiffusionDirectManipulationLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionMessagesBackgroundLargeImageConfigurationID: String { get { return "" } }
                public static func ServerDiffusionPersonalizationLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionDirectManipulationLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static func ServerDiffusionDirectManipulation() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionDirectManipulationConfigurationID: String { get { return "" } }
                public static func ServerDiffusionOutpaintingLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionUpResolutionConfigurationID: String { get { return "" } }
                public static func ServerDiffusionInpaintingLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionDrawingConditionerLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionOutpaintingID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionPersonalizationConfigurationID: String { get { return "" } }
                public static func ServerDiffusionSpatialReframingLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionOutpaintingConfigurationID: String { get { return "" } }
                public static func ServerDiffusionMessagesBackground() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionMessagesBackgroundConfigurationID: String { get { return "" } }
                public static func ServerDiffusionGenmoji() throws -> ServerDiffusionBundle { fatalError() }
                public static func ServerDiffusionPersonalization() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionMessagesBackgroundLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionTextToImageLargeImageConfigurationID: String { get { return "" } }
                public static func ServerDiffusionUpResolutionLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionGenmojiID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionGenmojiLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionGenmojiLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionInpaintingLargeImageConfigurationID: String { get { return "" } }
                public static var ServerDiffusionPersonalizationID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static func ServerDiffusionPersonalizationGenmoji() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionDirectManipulationID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static var ServerDiffusionTextToImageLargeImageID: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
                public static func ServerDiffusionSpatialReframing() throws -> ServerDiffusionBundle { fatalError() }
                public static var ServerDiffusionPersonalizationGenmojiConfigurationID: String { get { return "" } }
                public static var ServerDiffusionSpatialReframingConfigurationID: String { get { return "" } }
                public static func ServerDiffusionOutpainting() throws -> ServerDiffusionBundle { fatalError() }
                public static func ServerDiffusionMessagesBackgroundLargeImage() throws -> ServerDiffusionBundle { fatalError() }
                public static func ServerDiffusionInpainting() throws -> ServerDiffusionBundle { fatalError() }
            }
            public enum ServerDiffusionV10: Hashable, Sendable {
                case _mock
                public static var ServerDiffusionV10BaseID: ResourceBundleIdentifier<ServerDiffusionV10Bundle> { get { fatalError() } }
                public static func ServerDiffusionV10Base() throws -> ServerDiffusionV10Bundle { fatalError() }
                public static var ServerDiffusionV10BaseConfigurationID: String { get { return "" } }
            }
            public enum ServerDiffusionV11_1: Hashable, Sendable {
                case _mock
                public static var ServerDiffusionV11_1DirectManipulationSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static func ServerDiffusionV11_1UpResolutionSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static var ServerDiffusionV11_1BaseID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static var ServerDiffusionV11_1MessagesBackgroundSmallConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1SpatialReframingSmallConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1SpatialReframingSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static var ServerDiffusionV11_1UpResolutionSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static func ServerDiffusionV11_1SpatialReframingSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static func ServerDiffusionV11_1PersonalizationGenmoji() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static var ServerDiffusionV11_1BaseConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1DrawingConditionerSmallConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1MessagesBackgroundSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static func ServerDiffusionV11_1DrawingConditionerSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static var ServerDiffusionV11_1DrawingConditionerSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static var ServerDiffusionV11_1GenmojiConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1PersonalizationGenmojiConfigurationID: String { get { return "" } }
                public static func ServerDiffusionV11_1OutpaintingSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static var ServerDiffusionV11_1InpaintingSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static var ServerDiffusionV11_1OutpaintingSmallConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1PersonalizationGenmojiID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static var ServerDiffusionV11_1UpResolutionSmallConfigurationID: String { get { return "" } }
                public static func ServerDiffusionV11_1PersonalizationSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static func ServerDiffusionV11_1Base() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static func ServerDiffusionV11_1Genmoji() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static func ServerDiffusionV11_1MessagesBackgroundSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static func ServerDiffusionV11_1DirectManipulationSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static func ServerDiffusionV11_1InpaintingSmall() throws -> ServerDiffusionV11_1Bundle { fatalError() }
                public static var ServerDiffusionV11_1DirectManipulationSmallConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1GenmojiID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static var ServerDiffusionV11_1InpaintingSmallConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1OutpaintingSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
                public static var ServerDiffusionV11_1PersonalizationSmallConfigurationID: String { get { return "" } }
                public static var ServerDiffusionV11_1PersonalizationSmallID: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
            }
            case _mock
        }
        public enum VoicesOverrides: Hashable, Sendable {
            case _mock
            public static var TTSVoicesOverridesConfigurationID: String { get { return "" } }
            public static func TTSVoicesOverrides() throws -> VoicesOverridesBundle { fatalError() }
            public static var TTSVoicesOverridesID: ResourceBundleIdentifier<VoicesOverridesBundle> { get { fatalError() } }
        }
        case _mock
        public static func createResourceBundleVariant(configurationIdentifier: String, resourceVariants: Dictionary<String, String>) throws -> Optional<any ResourceBundle_P> { return nil }
        public static func deserialize(json: Dictionary<String, Any>, resourceBundleType: String, resources: Array<any CatalogResource>, assetBacked: Bool) throws -> any ResourceBundle_P { fatalError() }
        public static var allBundleResourceConfigurationIDs: Dictionary<String, Dictionary<String, String>> { get { return [:] } }
        public static func fetchAllResourceBundles() -> Array<any ResourceBundle_P> { return [] }
    }
    public enum SafetyOutputConfiguration: Hashable, Sendable {
        case _mock
    }
    public enum Sanitizer: Hashable, Sendable {
        case _mock
    }
    public enum SecureAnalytics: Hashable, Sendable {
        public enum Model: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum ServerDiffusion: Hashable, Sendable {
        public enum ANFREncoder: Hashable, Sendable {
            case _mock
        }
        public enum Adapter: Hashable, Sendable {
            case _mock
        }
        public enum AlphaMaskDecoder: Hashable, Sendable {
            case _mock
        }
        public enum AutoEncoder: Hashable, Sendable {
            case _mock
        }
        public enum ImageTokenizer: Hashable, Sendable {
            case _mock
        }
        public enum NoisePredictor: Hashable, Sendable {
            case _mock
        }
        public enum SynthID: Hashable, Sendable {
            case _mock
        }
        public enum TextEncoder: Hashable, Sendable {
            case _mock
        }
        public enum Tokenizer: Hashable, Sendable {
            case _mock
        }
        public enum VAEDecoder: Hashable, Sendable {
            case _mock
        }
        public enum VAEEncoder: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum SpeechDetokenizer: Hashable, Sendable {
        case _mock
    }
    public enum SpeechTokenizer: Hashable, Sendable {
        case _mock
    }
    public enum ThirdPartyProviderConfiguration: Hashable, Sendable {
        case _mock
    }
    public enum TokenInputDenyList: Hashable, Sendable {
        public enum BloomFilterTokenInputDenyList: Hashable, Sendable {
            case _mock
        }
        case _mock
    }
    public enum TokenOutputDenyList: Hashable, Sendable {
        case _mock
    }
    public enum TokenOutputRetainList: Hashable, Sendable {
        case _mock
    }
    public enum Tokenizer: Hashable, Sendable {
        case _mock
    }
    public enum TranslateFM: Hashable, Sendable {
        case _mock
    }
    public enum VisionModel: Hashable, Sendable {
        case _mock
    }
    public enum VoicesOverrides: Hashable, Sendable {
        case _mock
    }
    case _mock
    public static func resource(for: String) throws -> Optional<any CatalogResource> { return nil }
    public static func resourceInformation(for: String) throws -> ResourceInformation { fatalError() }
    public static func createFoundationModelsResourceBundleQuery(model: Optional<String>, url: Optional<URL>, orchestrator: Optional<String>) throws -> ResourceBundleQuery { fatalError() }
    public static var modelManagerForegroundOvercommitBudget: UInt64 { get { return 0 } }
    public static func requestResource(identifier: String) throws -> CatalogResourceResult { fatalError() }
    public static var generativeExperiencesReadinessNotificationName: String { get { return "" } }
    public static func createPrototypeModelID(modelName: String) -> ResourceBundleIdentifier<LLMBundle> { fatalError() }
    public static func register(resource: any CatalogResource) -> () {}
    public static func monitorGenerativeExperiencesReadiness(on: Optional<DispatchQueue>) -> AsyncStream<Bool> { fatalError() }
    public static func managedResource(for: String) throws -> Optional<any ManagedResource> { return nil }
    public static func notifyGenerativeExperiencesReady() -> () {}
    public static func requestDownload(for: Array<any AssetBackedResource>, on: Optional<DispatchQueue>) throws -> AsyncStream<RequestDownloadProgressInformation> { fatalError() }
    public static func formatInferenceID(from: String) throws -> String { return "" }
    public static func monitorUpdates(for: Array<any AssetBackedResource>, on: Optional<DispatchQueue>) throws -> AsyncStream<Array<any AssetBackedResource>> { fatalError() }
    public static func releaseResource(identifier: String) throws -> CatalogResourceResult { fatalError() }
    public static var modelManagerDefaultMemoryBudget: UInt64 { get { return 0 } }
    public static func createPrototypeEmbeddingsResourceBundleQuery(modelName: String) throws -> ResourceBundleQuery { fatalError() }
    public static var resourcesLookup: Dictionary<String, any CatalogResource> { get { return [:] } set {} }
    public static func isIFPEnabled() -> Bool { return false }
}
public struct CatalogAsset<A, B>: Codable, Hashable, Sendable {
    public init(specificationVersion: AssetSpecificationVersion, contents: B, mobileAssetMetadata: Dictionary<String, String>, coherentAssetLock: CoherentAssetLock, shouldUnlockOnDeinit: Bool) {}
    public init(specificationVersion: AssetSpecificationVersion, contents: B, mobileAssetMetadata: Dictionary<String, String>, coherentAssetLock: CoherentAssetLock) {}
    public init(specificationVersion: AssetSpecificationVersion, contents: B, mobileAssetMetadata: Dictionary<String, String>, assetLock: AssetLock) {}
    public var contents: B { get { fatalError() } }
    public var description: String { get { return "" } }
    public var mobileAssetMetadata: Dictionary<String, String> { get { return [:] } }
    public var reportedDownloadSize: Int64 { get { return 0 } }
    public var specificationVersion: AssetSpecificationVersion { get { fatalError() } }
    public var version: AssetVersion { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public protocol CatalogAssetProtocol {
    init(specificationVersion: AssetSpecificationVersion, metadata: Self.M, contents: Self.C, mobileAssetMetadata: Dictionary<String, String>, assetLock: AssetLock)
    init(specificationVersion: AssetSpecificationVersion, contents: Self.C, mobileAssetMetadata: Dictionary<String, String>, coherentAssetLock: CoherentAssetLock, shouldUnlockOnDeinit: Bool)
    init(specificationVersion: AssetSpecificationVersion, contents: Self.C, mobileAssetMetadata: Dictionary<String, String>, coherentAssetLock: CoherentAssetLock)
    init(specificationVersion: AssetSpecificationVersion, contents: Self.C, mobileAssetMetadata: Dictionary<String, String>, assetLock: AssetLock)
    var specificationVersion: AssetSpecificationVersion { get }
    associatedtype M
    var contents: Self.C { get }
    var displayVersion: Optional<AssetVersion> { get }
    var mobileAssetMetadata: Dictionary<String, String> { get }
    var version: AssetVersion { get }
    associatedtype C
    var reportedDownloadSize: Int64 { get }
}
public class CatalogClient {
    public init() {}
    public func availableUseCases() async throws -> AvailableUseCases { fatalError() }
    public func resourceBundles() throws -> Array<any ResourceBundle_P> { return [] }
    public func useCaseResourceAvailability(by: Array<UseCaseIdentifier>) async throws -> Dictionary<UseCaseIdentifier, UseCaseAvailabilityInfo> { return [:] }
    public func downloadStatus(forSubscriber: String, subscriptionName: String) throws -> DownloadStatus { fatalError() }
    public func xpcConnectionIsAllowed() throws -> () {}
    public func requestDownloadForSettings() throws -> AsyncStream<Double> { fatalError() }
    public func removeSideload(resource: String) throws -> () {}
    public func regulatoryDomains() throws -> Array<String> { return [] }
    public static func generativeExperienceEssentialResourcesStatus() -> ResourceReadinessStatus { fatalError() }
    public func availableUseCases(useCaseIdentifiers: Array<UseCaseIdentifier>, includeAssetsInformation: Bool) async throws -> AvailableUseCases { fatalError() }
    public func resources() throws -> Array<any CatalogResource> { return [] }
    public func releaseResources(for: RequestResourcesKey) throws -> () {}
    public func subscribersForUseCases(useCaseIdentifiers: Array<String>) -> Dictionary<String, Array<String>> { return [:] }
    public func requestResource(identifier: String) throws -> NSNumber { fatalError() }
    public func requestDownloadForUseCases(useCases: RequestDownloadUseCases) -> AsyncStream<UseCaseDownloadProgress> { fatalError() }
    public static func assetDeliveryReady() -> Bool { return false }
    public func generativeExperiencesEssentialResourcesReady() async throws -> Bool { return false }
    public func sideload(container: ResourceContainer, assetURL: Optional<URL>) throws -> NSNumber { fatalError() }
    public func queryResource(with: URL) throws -> Optional<any CatalogResource> { return nil }
    public func resourceInformation(identifier: String) throws -> ResourceInformation { fatalError() }
    public func removeSideload(resourceBundle: String) throws -> () {}
    public func useCasesStatus(useCaseIdentifiers: Array<UseCaseIdentifier>) async throws -> UseCaseStatuses { fatalError() }
    public func resourceBundle(for: String) throws -> Optional<any ResourceBundle_P> { return nil }
    public func acquireCoherenceToken(identifiers: Set<String>) throws -> AcquireCoherenceTokenResponse { fatalError() }
    public func formatInferenceID(from: String) throws -> String { return "" }
    public func donateSafetyFailure(safetyFailure: SafetyFailure) async throws -> () {}
    public func acquireCoherenceToken(identifiers: Set<String>) async throws -> AcquireCoherenceTokenResponse { fatalError() }
    public func resourceStatus(identifier: String) throws -> StatusResponse { fatalError() }
    public static func canAccessService() -> Bool { return false }
    public func queryResourceBundle(with: URL) throws -> Optional<any ResourceBundle_P> { return nil }
    public func resource(for: String) throws -> Optional<any CatalogResource> { return nil }
    public func supportedLanguagesAndRegions(resourceBundleQuery: ResourceBundleQuery) async throws -> SupportedLanguagesAndRegions { fatalError() }
    public func sideload(resource: any CatalogResource) throws -> () {}
    public func safetyFailures(userIdentifier: UInt32) async throws -> Data { return Data() }
    public func sideload(resourceBundle: any ResourceBundle_P) throws -> () {}
    public func siriResourceAvailability() throws -> SiriResourceAvailabilityInfo { fatalError() }
    public func donateSafetyFailure(useCaseIdentifier: UseCaseIdentifier, userIdentifier: UInt32) async throws -> () {}
    public func enableTestResources() throws -> Bool { return false }
    public func requestResources(for: RequestResourcesKey) throws -> () {}
    public func desiredUseCaseIdentifiersSettings() -> Array<String> { return [] }
    public func donateGenerativeGuardrailResult(guardrailResultInfo: GuardrailResultInfo) async throws -> () {}
    public func releaseResource(identifier: String) throws -> NSNumber { fatalError() }
}
public protocol CatalogClientProtocol {
    func queryResourceBundle(with: URL) throws -> Optional<any ResourceBundle_P>
    func requestDownloadForSettings() throws -> AsyncStream<Double>
    func queryResource(with: ResourceQuery) throws -> Optional<any CatalogResource>
    func resource(for: String) throws -> Optional<any CatalogResource>
    func regulatoryDomains() async throws -> Array<String>
    func resourceBundle(for: String) throws -> Optional<any ResourceBundle_P>
    func resourceStatus(identifier: String) throws -> StatusResponse
    func formatInferenceID(from: String) throws -> String
    func acquireCoherenceToken(identifiers: Set<String>) async throws -> AcquireCoherenceTokenResponse
    func donateSafetyFailure(useCaseIdentifier: UseCaseIdentifier, userIdentifier: UInt32) async throws -> ()
    func availableUseCases() async throws -> AvailableUseCases
    func donateSafetyFailure(safetyFailure: SafetyFailure) async throws -> ()
    func generativeExperiencesEssentialResourcesReady() async throws -> Bool
    func queryResourceBundle(with: ResourceBundleQuery) throws -> Optional<any ResourceBundle_P>
    func releaseResource(identifier: String) throws -> NSNumber
    func requestResource(identifier: String) throws -> NSNumber
    func queryResource(with: URL) throws -> Optional<any CatalogResource>
    func useCaseResourceAvailability(by: Array<UseCaseIdentifier>) async throws -> Dictionary<UseCaseIdentifier, UseCaseAvailabilityInfo>
    func resources() throws -> Array<any CatalogResource>
    func releaseResources(for: RequestResourcesKey) throws -> ()
    func resourceInformation(identifier: String) throws -> ResourceInformation
    func requestDownloadForUseCases(useCases: RequestDownloadUseCases) -> AsyncStream<UseCaseDownloadProgress>
    func enableTestResources() throws -> Bool
    func availableUseCases(useCaseIdentifiers: Array<String>, includeAssetsInformation: Bool) async throws -> AvailableUseCases
    func useCasesStatus(useCaseIdentifiers: Array<UseCaseIdentifier>) async throws -> UseCaseStatuses
    func requestResources(for: RequestResourcesKey) throws -> ()
    func resourceBundles() throws -> Array<any ResourceBundle_P>
    func supportedLanguagesAndRegions(resourceBundleQuery: ResourceBundleQuery) async throws -> SupportedLanguagesAndRegions
    func donateGenerativeGuardrailResult(guardrailResultInfo: GuardrailResultInfo) async throws -> ()
    func siriResourceAvailability() throws -> SiriResourceAvailabilityInfo
}
public enum CatalogErrors: Hashable, Sendable {
    public enum AssetErrors: Hashable, Sendable {
        case _mock
        public var errorDescription: Optional<String> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
    }
    public enum AvailabilityError: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public func hash(into: inout Hasher) -> () {}
        public var hashValue: Int { get { return 0 } }
    }
    public enum ConfigurationError: Hashable, Sendable {
        case _mock
        public var errorDescription: Optional<String> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
    }
    public enum DownloadError: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public var errorDescription: String { get { return "" } }
    }
    public enum InferenceIDError: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public var errorDescription: String { get { return "" } }
    }
    public enum QueryError: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public var errorDescription: Optional<String> { get { return nil } }
    }
    public enum RequestResourceError: Hashable, Sendable {
        case _mock
        public var descriptionWithoutUnderlying: String { get { return "" } }
        public var errorDescription: Optional<String> { get { return nil } }
        public var rawCode: Int { get { return 0 } }
        public var underlyingErrors: Array<AppleIntelligenceReporting_AppleIntelligenceError> { get { return [] } }
        public func encode(to: Encoder) throws -> () {}
        public var category: AppleIntelligenceReporting_AppleIntelligenceErrorCategory { get { fatalError() } }
        public var errorCode: Int { get { return 0 } }
    }
    public enum SerializationError: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public var errorDescription: Optional<String> { get { return nil } }
    }
    public enum SideloadError: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public var errorDescription: Optional<String> { get { return nil } }
    }
    public enum TokenStoreError: Hashable, Sendable {
        case _mock
        public var errorDescription: Optional<String> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
    }
    public enum UsageLookupError: Hashable, Sendable {
        case _mock
        public var errorDescription: Optional<String> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
    }
    public enum VariantError: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public var errorDescription: Optional<String> { get { return nil } }
    }
    case _mock
}
public class CatalogIndex {
    public init(sideloadURL: URL) {}
    public func updateSideloadedAssets() -> () {}
    public var resourceBundles: Array<any ResourceBundle_P> { get { return [] } }
    public static func essentialResources(sideLoadUrl: URL) -> Array<any AssetBackedResource> { return [] }
    public var sideloadedResources: Array<any CatalogResource> { get { return [] } set {} }
    public var staticResourceBundles: Array<any ResourceBundle_P> { get { return [] } }
    public static func uafUsageTypesForAssetSet(assetSetName: String) throws -> Optional<Dictionary<String, String>> { return nil }
    public func resourceBundle(for: String) throws -> Optional<any ResourceBundle_P> { return nil }
    public var sideloadURL: URL { get { fatalError() } }
    public var sideloadedResourceBundles: Array<any ResourceBundle_P> { get { return [] } set {} }
    public var testResources: Array<any CatalogResource> { get { return [] } }
    public static func resolveResourceQueryURIComponents(uri: URL, variantResolverMappings: Dictionary<String, Dictionary<String, Dictionary<ResourceVariantResolverArgument, Array<String>>>>, isIFPEnabledOverride: Optional<Bool>) throws -> (configurationIdentifier: String, variant: String) { fatalError() }
    public func resource(for: String) -> Optional<any CatalogResource> { return nil }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public static func resolveResourceQueryURI(uri: URL, variantResolverMappings: Dictionary<String, Dictionary<String, Dictionary<ResourceVariantResolverArgument, Array<String>>>>, isIFPEnabledOverride: Optional<Bool>) throws -> String { return "" }
    public static func essentialResources() -> Array<any AssetBackedResource> { return [] }
    public var staticResources: Array<any CatalogResource> { get { return [] } }
    public func resources(with: Array<UseCaseIdentifier>) -> Array<any AssetBackedResource> { return [] }
    public static func notReady(resources: Array<any AssetBackedResource>, lock: AssetLock) -> Bool { return false }
    public static func notReady(resources: Array<any AssetBackedResource>, coherentAssetLock: CoherentAssetLock) -> Bool { return false }
    public static func resolveResourceBundleQueryURI(uri: URL) throws -> String { return "" }
}
public protocol CatalogResource<A> {
    associatedtype A
    var assetBacked: Bool { get }
    var configurationIdentifier: String { get }
    var dependentResourceIDs: Array<String> { get }
    var id: String { get }
    var inferenceProviders: Set<InferenceProvider> { get }
    var platforms: Array<Platform> { get }
    var preconditions: Array<Precondition> { get }
    var sideloaded: Bool { get }
    var tags: Array<Tag> { get }
    var useCases: Array<UseCase> { get }
    var variant: String { get }
    var vmInferenceProviders: Set<InferenceProvider> { get }
}
public enum CatalogResourceResult: Hashable, Sendable {
    case _mock
}
public enum CatalogService: Hashable, Sendable {
    case _mock
    public static var entitlementName: String { get { return "" } set {} }
    public static var interface: Protocol { get { fatalError() } set {} }
    public static var logger: Logger { get { fatalError() } set {} }
    public static var otherAcceptedEntitlementNames: Set<String> { get { return [] } set {} }
    public static var requestSelectorClasses: KeyValuePairs<(Selector, Int), Set<AnyHashable>> { get { fatalError() } set {} }
    public static var responseSelectorClasses: KeyValuePairs<(Selector, Int), Set<AnyHashable>> { get { fatalError() } set {} }
    public static var serviceName: String { get { return "" } set {} }
}
public class CoherentAssetLock {
    public protocol CoherenceTokenProvider {
        func acquireCoherenceToken(identifiers: Set<String>) async throws -> Dictionary<String, UAFAssetSetConsistencyToken>
    }
    public init(coherenceTokens: Dictionary<String, UAFAssetSetConsistencyToken>) {}
    public func updateAvailable() async -> Bool { return false }
    public static func createUnlockedAssetLock(resources: Array<String>, client: CatalogClient) throws -> CoherentAssetLock { fatalError() }
    public func withLock(closure: () throws -> ()) throws -> () {}
    public static func createUnlockedAssetLock(resources: Array<String>) throws -> CoherentAssetLock { fatalError() }
    public func unlock() -> () {}
    public func lock() throws -> () {}
    public func withLock(closure: () async throws -> ()) async throws -> () {}
    public func withLock(closure: () async throws -> Any) async throws -> Any { fatalError() }
    public func withLock(closure: () throws -> Any) throws -> Any { fatalError() }
    public static func createUnlockedAssetLock(resources: Array<String>) async throws -> CoherentAssetLock { fatalError() }
    public static var sharedCoherenceTokenProvider: Optional<CoherentAssetLock.CoherenceTokenProvider> { get { return nil } set {} }
    public func markAssetsExpired() async throws -> () {}
    public static func createUnlockedAssetLock(resources: Array<String>, client: CatalogClient) async throws -> CoherentAssetLock { fatalError() }
    public func isLocked() -> Bool { return false }
}
public protocol ConfigurationBasedResource {
    init(configuration: ResourceConfiguration, variant: String) throws
    init(configuration: ResourceConfiguration) throws
    var configuration: ResourceConfiguration { get }
    var variant: String { get }
}
public enum ConnectionState: Hashable, Sendable {
    case _mock
    public static func ==(arg1: ConnectionState, arg2: ConnectionState) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
}
public struct CoreMLRankingModelBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var rankingModel: Optional<RankingModel> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func build() throws -> CoreMLRankingModelBundle { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func rankingModel(arg1: Optional<RankingModel>) -> Builder { fatalError() }
    }
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (CoreMLRankingModelBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var id: ResourceBundleIdentifier<CoreMLRankingModelBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rankingModel: RankingModel { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: CoreMLRankingModelBundle, arg2: CoreMLRankingModelBundle) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func encode(to: Encoder) throws -> () {}
    public func hash(into: inout Hasher) -> () {}
}
public protocol CoreMLRankingModelBundleProtocol {
}
public struct CostProfile: Codable, Hashable, Sendable {
    public init(onDeviceMemory: Int, cacheable: Bool, dynamicModeAllowed: Bool, energyEfficientMode: Bool, avoidUnload: Bool, unentitledGatedByFoundationModels: Bool, unentitledUseCases: Array<String>, powerCost: Int, preferUnload: Bool, immediatelyUnload: Bool, excludeFromAnalytics: Bool) {}
    public init(onDeviceMemory: Int, cacheable: Bool, dynamicModeAllowed: Bool, energyEfficientMode: Bool, avoidUnload: Bool, unentitledGatedByFoundationModels: Bool, unentitledUseCases: Array<String>, powerCost: Int, preferUnload: Bool) {}
    public init(onDeviceMemory: Int, cacheable: Bool, dynamicModeAllowed: Bool, energyEfficientMode: Bool, avoidUnload: Bool, unentitledGatedByFoundationModels: Bool, unentitledUseCases: Array<String>) {}
    public init(onDeviceMemory: Int, cacheable: Bool, dynamicModeAllowed: Bool, energyEfficientMode: Bool, avoidUnload: Bool) {}
    public init(onDeviceMemory: Int) {}
    public init(onDeviceMemory: Int, cacheable: Bool, dynamicModeAllowed: Bool, energyEfficientMode: Bool, avoidUnload: Bool, unentitledGatedByFoundationModels: Bool, unentitledUseCases: Array<String>, powerCost: Int) {}
    public init(onDeviceMemory: Int, cacheable: Bool, dynamicModeAllowed: Bool, energyEfficientMode: Bool, avoidUnload: Bool, unentitledGatedByFoundationModels: Bool, unentitledUseCases: Array<String>, powerCost: Int, preferUnload: Bool, immediatelyUnload: Bool) {}
    public init(onDeviceMemory: Int, cacheable: Bool, dynamicModeAllowed: Bool, energyEfficientMode: Bool) {}
    public init(from: Decoder) throws {}
    public var avoidUnload: Bool { get { return false } }
    public var dynamicModeAllowed: Bool { get { return false } }
    public var excludeFromAnalytics: Bool { get { return false } }
    public var hashValue: Int { get { return 0 } }
    public var immediatelyUnload: Bool { get { return false } }
    public var onDeviceMemory: Int { get { return 0 } }
    public var preferUnload: Bool { get { return false } }
    public var unentitledGatedByFoundationModels: Bool { get { return false } }
    public var unentitledUseCases: Array<String> { get { return [] } }
    public static func ==(arg1: CostProfile, arg2: CostProfile) -> Bool { return false }
    public var cacheable: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var energyEfficientMode: Bool { get { return false } }
    public var powerCost: Int { get { return 0 } }
    public func encode(to: Encoder) throws -> () {}
}
public struct DateProvider: Codable, Hashable, Sendable {
    public func now() -> Date { fatalError() }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public protocol DateProviding {
    func now() -> Date
}
public struct DefaultOverridesBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var defaultDenyList: Optional<ModelConfigurationReplacement> { get { return nil } set {} }
        public func build() throws -> DefaultOverridesBundle { fatalError() }
        public func defaultDenyList(arg1: Optional<ModelConfigurationReplacement>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (DefaultOverridesBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<DefaultOverridesBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: DefaultOverridesBundle, arg2: DefaultOverridesBundle) -> Bool { return false }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var defaultDenyList: ModelConfigurationReplacement { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
}
public protocol DefaultOverridesBundleProtocol {
}
public protocol DeviceSpecialTokensMapProtocol {
    var stopTokenInt: Optional<Int> { get }
    var stopTokenInts: Optional<Array<Int>> { get }
    var stopTokenStr: Optional<String> { get }
    var stopTokenStrings: Optional<Array<String>> { get }
}
public protocol DiffusionAdapter {
}
public struct DiffusionAdapterAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct DiffusionAdapterAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct DiffusionAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: DiffusionAdapterBase, arg2: DiffusionAdapterBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct DiffusionBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func adapter(arg1: Optional<any DiffusionAdapter>) -> Builder { fatalError() }
        public var adapter: Optional<any DiffusionAdapter> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var baseModel: Optional<any DiffusionModel> { get { return nil } set {} }
        public func baseModel(arg1: Optional<any DiffusionModel>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func build() throws -> DiffusionBundle { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
    }
    public init(id: ResourceBundleIdentifier<DiffusionBundle>, baseModel: any DiffusionModel, adapter: Optional<any DiffusionAdapter>, bundlePolicy: BundlePolicy) {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, baseModel: any DiffusionModel, adapter: Optional<any DiffusionAdapter>, bundlePolicy: BundlePolicy) {}
    public init(configurationIdentifier: String, build: (DiffusionBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public var baseModel: any DiffusionModel { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var id: ResourceBundleIdentifier<DiffusionBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func encode(to: Encoder) throws -> () {}
    public var adapter: Optional<any DiffusionAdapter> { get { return nil } }
    public var hashValue: Int { get { return 0 } }
    public var rawID: String { get { return "" } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: DiffusionBundle, arg2: DiffusionBundle) -> Bool { return false }
}
public protocol DiffusionBundleProtocol {
}
public protocol DiffusionModel {
}
public struct DiffusionModelAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct DiffusionModelAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct DiffusionModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: DiffusionModelBase, arg2: DiffusionModelBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol DisabledUseCaseList {
}
public struct DisabledUseCaseListAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct DisabledUseCaseListAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct DisabledUseCaseListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: DisabledUseCaseListBase, arg2: DisabledUseCaseListBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public enum DownloadStatus: Hashable, Sendable {
    case _mock
    public func assetSubscriptionStatus() -> AssetSubscriptionStatus { fatalError() }
    public static func fromUAFDownloadStatus(uafDownloadStatus: UAFSubscriptionDownloadStatus) -> DownloadStatus { fatalError() }
}
public protocol EmbeddingDenyList {
}
public struct EmbeddingDenyListAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct EmbeddingDenyListAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct EmbeddingDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: EmbeddingDenyListBase, arg2: EmbeddingDenyListBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol EmbeddingPreprocessor {
}
public struct EmbeddingPreprocessorAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct EmbeddingPreprocessorAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct EmbeddingPreprocessorBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: EmbeddingPreprocessorBase, arg2: EmbeddingPreprocessorBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct ExecutionContext: Codable, Hashable, Sendable {
    public static func ==(arg1: ExecutionContext, arg2: ExecutionContext) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ExplicityRequestible {
    var explicitRequestUsage: String { get }
}
public struct ExternalModelProvider: Codable, Hashable, Sendable {
    public struct Restrictions: Codable, Hashable, Sendable {
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public var allowedForSensitiveRegion: Bool { get { return false } }
        public var ipDisabledCountryCodes: Array<String> { get { return [] } }
        public var userLocaleDisabledCountryCodes: Array<String> { get { return [] } }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public static func ==(arg1: ExternalModelProvider, arg2: ExternalModelProvider) -> Bool { return false }
    public static var allProviders: Array<ExternalModelProvider> { get { return [] } }
    public static var chatGPT: ExternalModelProvider { get { fatalError() } }
    public var identifier: String { get { return "" } }
    public var providerSettingsUseCaseIdentifier: UseCaseIdentifier { get { fatalError() } }
    public var restrictions: ExternalModelProvider.Restrictions { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct FetchAssetOptions: Codable, Hashable, Sendable {
    public init() {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public enum GenerativePlaygroundFFKey: Hashable, Sendable {
    case _mock
    public var domain: StaticString { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: GenerativePlaygroundFFKey, arg2: GenerativePlaygroundFFKey) -> Bool { return false }
    public var feature: StaticString { get { return "" } }
    public var hashValue: Int { get { return 0 } }
}
public struct GenerativeShortcutsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func build() throws -> GenerativeShortcutsBundle { fatalError() }
        public func baseModel(arg1: Optional<any GenerativeShortcutsModel>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var baseModel: Optional<any GenerativeShortcutsModel> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (GenerativeShortcutsBundle.Builder) throws -> ()) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: GenerativeShortcutsBundle, arg2: GenerativeShortcutsBundle) -> Bool { return false }
    public var baseModel: any GenerativeShortcutsModel { get { fatalError() } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<GenerativeShortcutsBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
}
public protocol GenerativeShortcutsBundleProtocol {
}
public protocol GenerativeShortcutsModel {
}
public struct GenerativeShortcutsModelAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct GenerativeShortcutsModelAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct GenerativeShortcutsModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: GenerativeShortcutsModelBase, arg2: GenerativeShortcutsModelBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct GuardrailResultInfo: Codable, Hashable, Sendable {
    public enum InstanceType: Hashable, Sendable {
        case _mock
    }
    public init(markedUnsafe: Bool, useCaseIdentifier: String, instanceType: GuardrailResultInfo.InstanceType) {}
    public init(markedUnsafe: Bool, useCaseIdentifier: String, instanceType: GuardrailResultInfo.InstanceType, userRequestID: UUID) {}
    public var instanceType: GuardrailResultInfo.InstanceType { get { fatalError() } }
    public var markedUnsafe: Bool { get { return false } }
    public var useCaseIdentifier: String { get { return "" } }
    public var userRequestID: UUID { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public class GuardrailResultWrapper {
    public init(coder: NSCoder) {}
    public init(guardrailResult: RawGuardrailResult) {}
    public init() {}
    public var description: String { get { return "" } }
    public var guardrailResult: RawGuardrailResult { get { fatalError() } }
    public static var guardrailResultKey: String { get { return "" } }
    public var hash: Int { get { return 0 } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func copy(with: Optional<NSZone>) -> Any { fatalError() }
    public func encode(with: NSCoder) -> () {}
}
public protocol HandwritingSynthesizer {
}
public struct HandwritingSynthesizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct HandwritingSynthesizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct HandwritingSynthesizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: HandwritingSynthesizerBase, arg2: HandwritingSynthesizerBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ImageCuratedPrompts {
}
public struct ImageCuratedPromptsAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageCuratedPromptsAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageCuratedPromptsBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: ImageCuratedPromptsBase, arg2: ImageCuratedPromptsBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ImageFilter {
}
public struct ImageFilterAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageFilterAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageFilterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public static func ==(arg1: ImageFilterBase, arg2: ImageFilterBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ImageMagicCleanUp {
}
public struct ImageMagicCleanUpAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageMagicCleanUpAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageMagicCleanUpBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: ImageMagicCleanUpBase, arg2: ImageMagicCleanUpBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ImageScaler {
}
public struct ImageScalerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageScalerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageScalerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: ImageScalerBase, arg2: ImageScalerBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ImageSpatialPhotosRelive {
}
public struct ImageSpatialPhotosReliveAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageSpatialPhotosReliveAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageSpatialPhotosReliveBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: ImageSpatialPhotosReliveBase, arg2: ImageSpatialPhotosReliveBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct ImageSpatialPhotosReliveBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func location(arg1: Optional<ImageSpatialPhotosRelive>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func build() throws -> ImageSpatialPhotosReliveBundle { fatalError() }
        public func fovestimator(arg1: Optional<ImageSpatialPhotosRelive>) -> Builder { fatalError() }
        public var fovestimator: Optional<ImageSpatialPhotosRelive> { get { return nil } set {} }
        public var location: Optional<ImageSpatialPhotosRelive> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
    }
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (ImageSpatialPhotosReliveBundle.Builder) throws -> ()) throws {}
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: ImageSpatialPhotosReliveBundle, arg2: ImageSpatialPhotosReliveBundle) -> Bool { return false }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var fovestimator: ImageSpatialPhotosRelive { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public var location: ImageSpatialPhotosRelive { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var id: ResourceBundleIdentifier<ImageSpatialPhotosReliveBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
}
public protocol ImageSpatialPhotosReliveBundleProtocol {
}
public protocol ImageTokenizer {
}
public protocol ImageTokenizerAdapter {
}
public struct ImageTokenizerAdapterAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageTokenizerAdapterAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageTokenizerAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: ImageTokenizerAdapterBase, arg2: ImageTokenizerAdapterBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct ImageTokenizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageTokenizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ImageTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: ImageTokenizerBase, arg2: ImageTokenizerBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct InferenceProvider: Codable, Hashable, Sendable {
    public enum InferenceProviderOptions: Hashable, Sendable {
        case _mock
    }
    public init(id: String, hostedOnServerOverride: Optional<Bool>) {}
    public init(from: Decoder) throws {}
    public static var AJAXInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var CoreMotionFoundationModelInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var GenerativeExperiencesInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var PCCAgentClient: InferenceProvider { get { fatalError() } }
    public static var PrototypeEmbeddingProvider: InferenceProvider { get { fatalError() } }
    public static var PrototypeInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var SIDInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var VisionInferenceProvider: InferenceProvider { get { fatalError() } }
    public var hostedOnServer: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public static var CoreMotionPednetV1InferenceProvider: InferenceProvider { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static var EmbeddingPreprocessorInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var HostInference: InferenceProvider { get { fatalError() } }
    public static var TokenGenerationInference: InferenceProvider { get { fatalError() } }
    public static func ==(arg1: InferenceProvider, arg2: InferenceProvider) -> Bool { return false }
    public static var AlchemistInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var ExternalLanguageModelProvider: InferenceProvider { get { fatalError() } }
    public static var ExternalSearchPartnerInferenceProvider: InferenceProvider { get { fatalError() } }
    public static var PrivateMLClient: InferenceProvider { get { fatalError() } }
    public static var VisualGenerationInference: InferenceProvider { get { fatalError() } }
    public static var VisualGenerationServerInference: InferenceProvider { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: String { get { return "" } }
}
public protocol InitializableFromExistingConnection {
    init(existingConnection: NSXPCConnection, localObject: Any) throws
    associatedtype Service
}
public protocol LLMAJAXModel {
}
public struct LLMAJAXModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public init(inner: ManagedResourceBase) {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: LLMAJAXModelBase, arg2: LLMAJAXModelBase) -> Bool { return false }
    public var inner: ManagedResourceBase { get { fatalError() } }
    public var preconditions: Array<Precondition> { get { return [] } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol LLMAdapter {
    var llmModel: Self.ModelType { get }
    associatedtype ModelType
}
public struct LLMAdapterAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMAdapterAssetMetadata: Codable, Hashable, Sendable {
    public struct ClassifierDefaultOutputClass: Codable, Hashable, Sendable {
        public init(tokenId: Int) {}
        public init(from: Decoder) throws {}
        public func encode(to: Encoder) throws -> () {}
        public var tokenId: Int { get { return 0 } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct ClassifierMetadata: Codable, Hashable, Sendable {
        public init(defaultOutputClass: LLMAdapterAssetMetadata.ClassifierDefaultOutputClass, outputClasses: Array<LLMAdapterAssetMetadata.ClassifierOutputClass>, outputClassesPerThreshold: Optional<Dictionary<String, Array<LLMAdapterAssetMetadata.ClassifierOutputClass>>>) {}
        public init(from: Decoder) throws {}
        public var outputClassesPerThreshold: Optional<Dictionary<String, Array<LLMAdapterAssetMetadata.ClassifierOutputClass>>> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var defaultOutputClass: LLMAdapterAssetMetadata.ClassifierDefaultOutputClass { get { fatalError() } }
        public var outputClasses: Array<LLMAdapterAssetMetadata.ClassifierOutputClass> { get { return [] } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct ClassifierOutputClass: Codable, Hashable, Sendable {
        public init(tokenId: Int, tokenProbabilityThreshold: Double) {}
        public init(from: Decoder) throws {}
        public var tokenId: Int { get { return 0 } }
        public var tokenProbabilityThreshold: Double { get { return 0 } }
        public func encode(to: Encoder) throws -> () {}
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DeviceLocalization: Codable, Hashable, Sendable {
        public init(localeInstruction: Optional<Dictionary<String, String>>, localeInstructionInjectionLocation: Optional<Dictionary<String, String>>, chatRoleSystem: Optional<Dictionary<String, String>>, chatRoleSystemDefault: Optional<Dictionary<String, String>>, chatRoleAssistant: Optional<Dictionary<String, String>>, chatRoleUser: Optional<Dictionary<String, String>>, chatComponentTurnend: Optional<Dictionary<String, String>>) {}
        public init(from: Decoder) throws {}
        public var chatComponentTurnend: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleAssistant: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleSystemDefault: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleUser: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstruction: Optional<Dictionary<String, String>> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var chatRoleSystem: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstructionInjectionLocation: Optional<Dictionary<String, String>> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DeviceSpecialTokensMap: Codable, Hashable, Sendable {
        public init(from: Decoder) throws {}
        public init(startPromptToken: Optional<Int>, startPromptTokenStr: Optional<String>, endPromptToken: Optional<String>, endPromptTokenInt: Optional<Int>, chatRoleSystem: Optional<String>, chatRoleUser: Optional<String>, chatRoleAssistant: Optional<String>, chatRoleTool: Optional<String>, chatComponentTurnend: Optional<String>, chatRoleSystemDefault: Optional<String>, stopTokenInt: Optional<Int>, stopTokenStr: Optional<String>, stopTokenInts: Optional<Array<Int>>, stopTokenStrings: Optional<Array<String>>, startExecutableStr: Optional<String>, startExecutableInt: Optional<Int>, endExecutableStr: Optional<String>, endExecutableInt: Optional<Int>, startImageTokenInt: Optional<Int>, startImageTokenStr: Optional<String>, endImageTokenInt: Optional<Int>, endImageTokenStr: Optional<String>, startAudioTokenInt: Optional<Int>, startAudioTokenStr: Optional<String>, endAudioTokenInt: Optional<Int>, endAudioTokenStr: Optional<String>) {}
        public var chatComponentTurnend: Optional<String> { get { return nil } }
        public var chatRoleAssistant: Optional<String> { get { return nil } }
        public var chatRoleSystem: Optional<String> { get { return nil } }
        public var chatRoleSystemDefault: Optional<String> { get { return nil } }
        public var chatRoleTool: Optional<String> { get { return nil } }
        public var chatRoleUser: Optional<String> { get { return nil } }
        public var endAudioTokenInt: Optional<Int> { get { return nil } }
        public var endAudioTokenStr: Optional<String> { get { return nil } }
        public var endExecutableInt: Optional<Int> { get { return nil } }
        public var endExecutableStr: Optional<String> { get { return nil } }
        public var endImageTokenInt: Optional<Int> { get { return nil } }
        public var endPromptToken: Optional<String> { get { return nil } }
        public var endPromptTokenInt: Optional<Int> { get { return nil } }
        public var startAudioTokenStr: Optional<String> { get { return nil } }
        public var startExecutableInt: Optional<Int> { get { return nil } }
        public var startExecutableStr: Optional<String> { get { return nil } }
        public var startImageTokenInt: Optional<Int> { get { return nil } }
        public var startImageTokenStr: Optional<String> { get { return nil } }
        public var startPromptToken: Optional<Int> { get { return nil } }
        public var startPromptTokenStr: Optional<String> { get { return nil } }
        public var stopTokenInt: Optional<Int> { get { return nil } }
        public var stopTokenInts: Optional<Array<Int>> { get { return nil } }
        public var stopTokenStr: Optional<String> { get { return nil } }
        public var stopTokenStrings: Optional<Array<String>> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var endImageTokenStr: Optional<String> { get { return nil } }
        public var startAudioTokenInt: Optional<Int> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DraftMetadata: Codable, Hashable, Sendable {
        public init(draftSteps: Optional<Int>, draftIsAdaptive: Optional<Bool>, draftTreeFactor: Optional<Int>, draftSecondaryTreeFactor: Optional<Int>, draftSoftMatchTolerance: Optional<Double>, draftTreeMaxPaths: Optional<Int>, draftUseRejectionSampling: Optional<Bool>, draftUseMaximumLikelihoodTree: Optional<Bool>, draftEarlyReturn: Optional<Bool>, draftEarlyReturnProbabilityThreshold: Optional<Double>, speculativeSampling: Optional<Bool>, speculativeStreamingModel: Optional<Bool>, streamMaximumGamma: Optional<Int>, speculativeDecodeType: Optional<String>, temperature: Optional<Double>, streamSeparateWeights: Optional<Bool>, streamUseRejectionSampling: Optional<Bool>, streamLayerId: Optional<Int>, streamLossWeight: Optional<Double>, streamTreeFactor: Optional<Int>) {}
        public init(from: Decoder) throws {}
        public var draftEarlyReturn: Optional<Bool> { get { return nil } }
        public var draftIsAdaptive: Optional<Bool> { get { return nil } }
        public var draftSteps: Optional<Int> { get { return nil } }
        public var draftTreeMaxPaths: Optional<Int> { get { return nil } }
        public var speculativeSampling: Optional<Bool> { get { return nil } }
        public var streamLayerId: Optional<Int> { get { return nil } }
        public var streamTreeFactor: Optional<Int> { get { return nil } }
        public var streamUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var temperature: Optional<Double> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var draftEarlyReturnProbabilityThreshold: Optional<Double> { get { return nil } }
        public var draftSecondaryTreeFactor: Optional<Int> { get { return nil } }
        public var draftSoftMatchTolerance: Optional<Double> { get { return nil } }
        public var draftTreeFactor: Optional<Int> { get { return nil } }
        public var draftUseMaximumLikelihoodTree: Optional<Bool> { get { return nil } }
        public var draftUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var speculativeDecodeType: Optional<String> { get { return nil } }
        public var speculativeStreamingModel: Optional<Bool> { get { return nil } }
        public var streamLossWeight: Optional<Double> { get { return nil } }
        public var streamMaximumGamma: Optional<Int> { get { return nil } }
        public var streamSeparateWeights: Optional<Bool> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum LoraRank: Hashable, Sendable {
        case _mock
    }
    public enum ModelType: Hashable, Sendable {
        case _mock
    }
    public enum PromptPreprocessingTemplateVersion: Hashable, Sendable {
        case _mock
    }
    public init(from: Decoder) throws {}
    public init(modelType: LLMAdapterAssetMetadata.ModelType, rank: Optional<Int>, type: Optional<LLMAdapterAssetMetadata.LoraRank>, backboneSignature: String, adapterSignature: String, speculativeStreamCount: Optional<Int>, speculativeStreamingDefaultParameters: Optional<LLMAdapterAssetMetadata.DraftMetadata>, localization: Optional<LLMAdapterAssetMetadata.DeviceLocalization>, userDefinedFields: Optional<Dictionary<String, String>>, classifierMetadata: Optional<LLMAdapterAssetMetadata.ClassifierMetadata>, specialTokensMap: Optional<LLMAdapterAssetMetadata.DeviceSpecialTokensMap>, prewarmForConstrainedDecoding: Optional<Bool>, allowPromptFallback: Optional<Bool>, rollbackStrings: Optional<Array<String>>, imageTokenizationMode: Optional<String>, imageTokenizerMaxImagePixels: Optional<Int>, modularPromptFragments: Optional<Array<String>>, modularPromptOffset: Optional<Int>, promptPreprocessingTemplateVersion: Optional<LLMAdapterAssetMetadata.PromptPreprocessingTemplateVersion>, promptTemplates: Optional<Dictionary<String, String>>, disableSpecDecoding: Optional<Bool>, systemInstructions: Optional<Dictionary<String, String>>, systemInstructionsLocalizationSuffixes: Optional<Dictionary<String, Dictionary<String, String>>>, promptContentTemplates: Optional<Dictionary<String, Dictionary<String, String>>>) {}
    public var adapterSignature: String { get { return "" } }
    public var allowPromptFallback: Optional<Bool> { get { return nil } }
    public var backboneSignature: String { get { return "" } }
    public var classifierMetadata: Optional<LLMAdapterAssetMetadata.ClassifierMetadata> { get { return nil } }
    public var disableSpecDecoding: Optional<Bool> { get { return nil } }
    public var imageTokenizationMode: Optional<String> { get { return nil } }
    public var imageTokenizerMaxImagePixels: Optional<Int> { get { return nil } }
    public var localization: Optional<LLMAdapterAssetMetadata.DeviceLocalization> { get { return nil } }
    public var modelType: LLMAdapterAssetMetadata.ModelType { get { fatalError() } }
    public var modularPromptFragments: Optional<Array<String>> { get { return nil } }
    public var prewarmForConstrainedDecoding: Optional<Bool> { get { return nil } }
    public var promptContentTemplates: Optional<Dictionary<String, Dictionary<String, String>>> { get { return nil } }
    public var promptPreprocessingTemplateVersion: Optional<LLMAdapterAssetMetadata.PromptPreprocessingTemplateVersion> { get { return nil } }
    public var promptTemplates: Optional<Dictionary<String, String>> { get { return nil } }
    public var rank: Optional<Int> { get { return nil } }
    public var rollbackStrings: Optional<Array<String>> { get { return nil } }
    public var specialTokensMap: Optional<LLMAdapterAssetMetadata.DeviceSpecialTokensMap> { get { return nil } }
    public var speculativeStreamCount: Optional<Int> { get { return nil } }
    public var speculativeStreamingDefaultParameters: Optional<LLMAdapterAssetMetadata.DraftMetadata> { get { return nil } }
    public var systemInstructions: Optional<Dictionary<String, String>> { get { return nil } }
    public var systemInstructionsLocalizationSuffixes: Optional<Dictionary<String, Dictionary<String, String>>> { get { return nil } }
    public var type: Optional<LLMAdapterAssetMetadata.LoraRank> { get { return nil } }
    public var userDefinedFields: Optional<Dictionary<String, String>> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var modularPromptOffset: Optional<Int> { get { return nil } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(inner: ManagedResourceBase) {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var inner: ManagedResourceBase { get { fatalError() } }
    public var llmModel: LLMModelBase { get { fatalError() } }
    public var preconditions: Array<Precondition> { get { return [] } }
    public static func ==(arg1: LLMAdapterBase, arg2: LLMAdapterBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol LLMAdapterMetadataOverride {
}
public struct LLMAdapterMetadataOverrideAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMAdapterMetadataOverrideAssetMetadata: Codable, Hashable, Sendable {
    public struct ClassifierDefaultOutputClass: Codable, Hashable, Sendable {
        public init(tokenId: Int) {}
        public init(from: Decoder) throws {}
        public func encode(to: Encoder) throws -> () {}
        public var tokenId: Int { get { return 0 } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct ClassifierMetadata: Codable, Hashable, Sendable {
        public init(from: Decoder) throws {}
        public init(defaultOutputClass: LLMAdapterMetadataOverrideAssetMetadata.ClassifierDefaultOutputClass, outputClasses: Array<LLMAdapterMetadataOverrideAssetMetadata.ClassifierOutputClass>, outputClassesPerThreshold: Optional<Dictionary<String, Array<LLMAdapterMetadataOverrideAssetMetadata.ClassifierOutputClass>>>) {}
        public var defaultOutputClass: LLMAdapterMetadataOverrideAssetMetadata.ClassifierDefaultOutputClass { get { fatalError() } }
        public var outputClasses: Array<LLMAdapterMetadataOverrideAssetMetadata.ClassifierOutputClass> { get { return [] } }
        public var outputClassesPerThreshold: Optional<Dictionary<String, Array<LLMAdapterMetadataOverrideAssetMetadata.ClassifierOutputClass>>> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct ClassifierOutputClass: Codable, Hashable, Sendable {
        public init(tokenId: Int, tokenProbabilityThreshold: Double) {}
        public init(from: Decoder) throws {}
        public var tokenId: Int { get { return 0 } }
        public var tokenProbabilityThreshold: Double { get { return 0 } }
        public func encode(to: Encoder) throws -> () {}
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DeviceLocalization: Codable, Hashable, Sendable {
        public init(localeInstruction: Optional<Dictionary<String, String>>, localeInstructionInjectionLocation: Optional<Dictionary<String, String>>, chatRoleSystem: Optional<Dictionary<String, String>>, chatRoleSystemDefault: Optional<Dictionary<String, String>>, chatRoleAssistant: Optional<Dictionary<String, String>>, chatRoleUser: Optional<Dictionary<String, String>>, chatComponentTurnend: Optional<Dictionary<String, String>>) {}
        public init(from: Decoder) throws {}
        public func encode(to: Encoder) throws -> () {}
        public var chatComponentTurnend: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleAssistant: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleSystem: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleSystemDefault: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleUser: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstruction: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstructionInjectionLocation: Optional<Dictionary<String, String>> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DeviceSpecialTokensMap: Codable, Hashable, Sendable {
        public init(from: Decoder) throws {}
        public init(startPromptToken: Optional<Int>, startPromptTokenStr: Optional<String>, endPromptToken: Optional<String>, endPromptTokenInt: Optional<Int>, chatRoleSystem: Optional<String>, chatRoleUser: Optional<String>, chatRoleAssistant: Optional<String>, chatRoleTool: Optional<String>, chatComponentTurnend: Optional<String>, chatRoleSystemDefault: Optional<String>, stopTokenInt: Optional<Int>, stopTokenStr: Optional<String>, stopTokenInts: Optional<Array<Int>>, stopTokenStrings: Optional<Array<String>>, startExecutableStr: Optional<String>, startExecutableInt: Optional<Int>, endExecutableStr: Optional<String>, endExecutableInt: Optional<Int>, startImageTokenInt: Optional<Int>, startImageTokenStr: Optional<String>, endImageTokenInt: Optional<Int>, endImageTokenStr: Optional<String>, startAudioTokenInt: Optional<Int>, startAudioTokenStr: Optional<String>, endAudioTokenInt: Optional<Int>, endAudioTokenStr: Optional<String>) {}
        public var endPromptTokenInt: Optional<Int> { get { return nil } }
        public var startExecutableInt: Optional<Int> { get { return nil } }
        public var startImageTokenInt: Optional<Int> { get { return nil } }
        public var startPromptToken: Optional<Int> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var chatComponentTurnend: Optional<String> { get { return nil } }
        public var chatRoleAssistant: Optional<String> { get { return nil } }
        public var chatRoleSystem: Optional<String> { get { return nil } }
        public var chatRoleSystemDefault: Optional<String> { get { return nil } }
        public var chatRoleTool: Optional<String> { get { return nil } }
        public var chatRoleUser: Optional<String> { get { return nil } }
        public var endAudioTokenInt: Optional<Int> { get { return nil } }
        public var endAudioTokenStr: Optional<String> { get { return nil } }
        public var endExecutableInt: Optional<Int> { get { return nil } }
        public var endExecutableStr: Optional<String> { get { return nil } }
        public var endImageTokenInt: Optional<Int> { get { return nil } }
        public var endImageTokenStr: Optional<String> { get { return nil } }
        public var endPromptToken: Optional<String> { get { return nil } }
        public var startAudioTokenInt: Optional<Int> { get { return nil } }
        public var startAudioTokenStr: Optional<String> { get { return nil } }
        public var startExecutableStr: Optional<String> { get { return nil } }
        public var startImageTokenStr: Optional<String> { get { return nil } }
        public var startPromptTokenStr: Optional<String> { get { return nil } }
        public var stopTokenInt: Optional<Int> { get { return nil } }
        public var stopTokenInts: Optional<Array<Int>> { get { return nil } }
        public var stopTokenStr: Optional<String> { get { return nil } }
        public var stopTokenStrings: Optional<Array<String>> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DraftMetadata: Codable, Hashable, Sendable {
        public init(draftSteps: Optional<Int>, draftIsAdaptive: Optional<Bool>, draftTreeFactor: Optional<Int>, draftSecondaryTreeFactor: Optional<Int>, draftSoftMatchTolerance: Optional<Double>, draftTreeMaxPaths: Optional<Int>, draftUseRejectionSampling: Optional<Bool>, draftUseMaximumLikelihoodTree: Optional<Bool>, draftEarlyReturn: Optional<Bool>, draftEarlyReturnProbabilityThreshold: Optional<Double>, speculativeSampling: Optional<Bool>, speculativeStreamingModel: Optional<Bool>, streamMaximumGamma: Optional<Int>, speculativeDecodeType: Optional<String>, temperature: Optional<Double>, streamSeparateWeights: Optional<Bool>, streamUseRejectionSampling: Optional<Bool>, streamLayerId: Optional<Int>, streamLossWeight: Optional<Double>, streamTreeFactor: Optional<Int>) {}
        public init(from: Decoder) throws {}
        public var draftEarlyReturn: Optional<Bool> { get { return nil } }
        public var draftEarlyReturnProbabilityThreshold: Optional<Double> { get { return nil } }
        public var draftIsAdaptive: Optional<Bool> { get { return nil } }
        public var draftSecondaryTreeFactor: Optional<Int> { get { return nil } }
        public var draftSoftMatchTolerance: Optional<Double> { get { return nil } }
        public var draftSteps: Optional<Int> { get { return nil } }
        public var draftTreeFactor: Optional<Int> { get { return nil } }
        public var draftUseMaximumLikelihoodTree: Optional<Bool> { get { return nil } }
        public var draftUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var speculativeDecodeType: Optional<String> { get { return nil } }
        public var speculativeSampling: Optional<Bool> { get { return nil } }
        public var speculativeStreamingModel: Optional<Bool> { get { return nil } }
        public var streamLayerId: Optional<Int> { get { return nil } }
        public var streamLossWeight: Optional<Double> { get { return nil } }
        public var streamMaximumGamma: Optional<Int> { get { return nil } }
        public var streamSeparateWeights: Optional<Bool> { get { return nil } }
        public var streamTreeFactor: Optional<Int> { get { return nil } }
        public var streamUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var temperature: Optional<Double> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var draftTreeMaxPaths: Optional<Int> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum LoraRank: Hashable, Sendable {
        case _mock
    }
    public enum ModelType: Hashable, Sendable {
        case _mock
    }
    public enum PromptPreprocessingTemplateVersion: Hashable, Sendable {
        case _mock
    }
    public init(from: Decoder) throws {}
    public init(modelType: LLMAdapterMetadataOverrideAssetMetadata.ModelType, rank: Optional<Int>, type: Optional<LLMAdapterMetadataOverrideAssetMetadata.LoraRank>, backboneSignature: String, adapterSignature: String, speculativeStreamCount: Optional<Int>, speculativeStreamingDefaultParameters: Optional<LLMAdapterMetadataOverrideAssetMetadata.DraftMetadata>, localization: Optional<LLMAdapterMetadataOverrideAssetMetadata.DeviceLocalization>, userDefinedFields: Optional<Dictionary<String, String>>, classifierMetadata: Optional<LLMAdapterMetadataOverrideAssetMetadata.ClassifierMetadata>, specialTokensMap: Optional<LLMAdapterMetadataOverrideAssetMetadata.DeviceSpecialTokensMap>, prewarmForConstrainedDecoding: Optional<Bool>, allowPromptFallback: Optional<Bool>, rollbackStrings: Optional<Array<String>>, imageTokenizationMode: Optional<String>, imageTokenizerMaxImagePixels: Optional<Int>, modularPromptFragments: Optional<Array<String>>, modularPromptOffset: Optional<Int>, promptPreprocessingTemplateVersion: Optional<LLMAdapterMetadataOverrideAssetMetadata.PromptPreprocessingTemplateVersion>, promptTemplates: Optional<Dictionary<String, String>>, disableSpecDecoding: Optional<Bool>, systemInstructions: Optional<Dictionary<String, String>>, systemInstructionsLocalizationSuffixes: Optional<Dictionary<String, Dictionary<String, String>>>, promptContentTemplates: Optional<Dictionary<String, Dictionary<String, String>>>) {}
    public var adapterSignature: String { get { return "" } }
    public var backboneSignature: String { get { return "" } }
    public var disableSpecDecoding: Optional<Bool> { get { return nil } }
    public var imageTokenizerMaxImagePixels: Optional<Int> { get { return nil } }
    public var prewarmForConstrainedDecoding: Optional<Bool> { get { return nil } }
    public var promptTemplates: Optional<Dictionary<String, String>> { get { return nil } }
    public var systemInstructionsLocalizationSuffixes: Optional<Dictionary<String, Dictionary<String, String>>> { get { return nil } }
    public var userDefinedFields: Optional<Dictionary<String, String>> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var allowPromptFallback: Optional<Bool> { get { return nil } }
    public var classifierMetadata: Optional<LLMAdapterMetadataOverrideAssetMetadata.ClassifierMetadata> { get { return nil } }
    public var imageTokenizationMode: Optional<String> { get { return nil } }
    public var localization: Optional<LLMAdapterMetadataOverrideAssetMetadata.DeviceLocalization> { get { return nil } }
    public var modelType: LLMAdapterMetadataOverrideAssetMetadata.ModelType { get { fatalError() } }
    public var modularPromptFragments: Optional<Array<String>> { get { return nil } }
    public var modularPromptOffset: Optional<Int> { get { return nil } }
    public var promptContentTemplates: Optional<Dictionary<String, Dictionary<String, String>>> { get { return nil } }
    public var promptPreprocessingTemplateVersion: Optional<LLMAdapterMetadataOverrideAssetMetadata.PromptPreprocessingTemplateVersion> { get { return nil } }
    public var rank: Optional<Int> { get { return nil } }
    public var rollbackStrings: Optional<Array<String>> { get { return nil } }
    public var specialTokensMap: Optional<LLMAdapterMetadataOverrideAssetMetadata.DeviceSpecialTokensMap> { get { return nil } }
    public var speculativeStreamCount: Optional<Int> { get { return nil } }
    public var speculativeStreamingDefaultParameters: Optional<LLMAdapterMetadataOverrideAssetMetadata.DraftMetadata> { get { return nil } }
    public var systemInstructions: Optional<Dictionary<String, String>> { get { return nil } }
    public var type: Optional<LLMAdapterMetadataOverrideAssetMetadata.LoraRank> { get { return nil } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMAdapterMetadataOverrideBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: LLMAdapterMetadataOverrideBase, arg2: LLMAdapterMetadataOverrideBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct LLMBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var imageTokenizer: Optional<ImageTokenizer> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func imageTokenizerAdapter(arg1: Optional<ImageTokenizerAdapter>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func tokenizer(arg1: Optional<Tokenizer>) -> Builder { fatalError() }
        public func adapterMetadataOverride(arg1: Optional<any LLMAdapterMetadataOverride>) -> Builder { fatalError() }
        public var adapter: Optional<any LLMAdapter> { get { return nil } set {} }
        public var imageTokenizerAdapter: Optional<ImageTokenizerAdapter> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var baseModel: Optional<any LLMModel> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var speechTokenizer: Optional<SpeechTokenizer> { get { return nil } set {} }
        public func speechDetokenizer(arg1: Optional<SpeechDetokenizer>) -> Builder { fatalError() }
        public var embeddingPreprocessor: Optional<EmbeddingPreprocessor> { get { return nil } set {} }
        public var tokenizer: Optional<Tokenizer> { get { return nil } set {} }
        public func build() throws -> LLMBundle { fatalError() }
        public func draftModel(arg1: Optional<any LLMDraftModel>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var speechDetokenizer: Optional<SpeechDetokenizer> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride> { get { return nil } set {} }
        public func baseModel(arg1: Optional<any LLMModel>) -> Builder { fatalError() }
        public func embeddingPreprocessor(arg1: Optional<EmbeddingPreprocessor>) -> Builder { fatalError() }
        public var draftModel: Optional<any LLMDraftModel> { get { return nil } set {} }
        public func adapter(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public func speechTokenizer(arg1: Optional<SpeechTokenizer>) -> Builder { fatalError() }
        public func imageTokenizer(arg1: Optional<ImageTokenizer>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (LLMBundle.Builder) throws -> ()) throws {}
    public init(id: ResourceBundleIdentifier<LLMBundle>, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool, bundlePolicy: BundlePolicy, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, bundlePolicy: BundlePolicy, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(configurationIdentifier: String, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, serverWorkflowEnabled: Bool, bundlePolicy: BundlePolicy, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(id: ResourceBundleIdentifier<LLMBundle>, tokenizer: Tokenizer, baseModel: any LLMModel, adapter: Optional<any LLMAdapter>, draftModel: Optional<any LLMDraftModel>, imageTokenizer: Optional<ImageTokenizer>, embeddingPreprocessor: Optional<EmbeddingPreprocessor>, adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride>, bundlePolicy: BundlePolicy, trialNamespace: Optional<String>, modelInterfaceName: Optional<String>) {}
    public init(from: Decoder) throws {}
    public var adapter: Optional<any LLMAdapter> { get { return nil } }
    public var adapterMetadataOverride: Optional<any LLMAdapterMetadataOverride> { get { return nil } }
    public var draftModel: Optional<any LLMDraftModel> { get { return nil } }
    public var embeddingPreprocessor: Optional<EmbeddingPreprocessor> { get { return nil } }
    public var imageTokenizerAdapter: Optional<ImageTokenizerAdapter> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var speechDetokenizer: Optional<SpeechDetokenizer> { get { return nil } }
    public var tokenizer: Tokenizer { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: LLMBundle, arg2: LLMBundle) -> Bool { return false }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<LLMBundle> { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var baseModel: any LLMModel { get { fatalError() } }
    public var imageTokenizer: Optional<ImageTokenizer> { get { return nil } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var speechTokenizer: Optional<SpeechTokenizer> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
}
public protocol LLMBundleProtocol {
}
public struct LLMCompileDraftBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func draftModel(arg1: Optional<any LLMDraftModel>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func build() throws -> LLMCompileDraftBundle { fatalError() }
        public var draftModel: Optional<any LLMDraftModel> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (LLMCompileDraftBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public var id: ResourceBundleIdentifier<LLMCompileDraftBundle> { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public static func ==(arg1: LLMCompileDraftBundle, arg2: LLMCompileDraftBundle) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var draftModel: any LLMDraftModel { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
}
public protocol LLMCompileDraftBundleProtocol {
}
public struct LLMDraftBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func draftModel(arg1: Optional<any LLMDraftModel>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var tokenizer: Optional<Tokenizer> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func tokenizer(arg1: Optional<Tokenizer>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var draftModel: Optional<any LLMDraftModel> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func build() throws -> LLMDraftBundle { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (LLMDraftBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public static func ==(arg1: LLMDraftBundle, arg2: LLMDraftBundle) -> Bool { return false }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func encode(to: Encoder) throws -> () {}
    public var id: ResourceBundleIdentifier<LLMDraftBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var tokenizer: Tokenizer { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var draftModel: any LLMDraftModel { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
}
public protocol LLMDraftBundleProtocol {
}
public protocol LLMDraftModel {
}
public struct LLMDraftModelAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMDraftModelAssetMetadata: Codable, Hashable, Sendable {
    public struct ANEExtendInfo: Codable, Hashable, Sendable {
        public init(type: String, ctxLen: Int, seqLen: Int) {}
        public init(from: Decoder) throws {}
        public var type: String { get { return "" } }
        public func encode(to: Encoder) throws -> () {}
        public var ctxLen: Int { get { return 0 } }
        public var seqLen: Int { get { return 0 } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DeviceSpecialTokensMap: Codable, Hashable, Sendable {
        public init(startPromptToken: Optional<Int>, startPromptTokenStr: Optional<String>, endPromptToken: Optional<String>, endPromptTokenInt: Optional<Int>, chatRoleSystem: Optional<String>, chatRoleUser: Optional<String>, chatRoleAssistant: Optional<String>, chatRoleTool: Optional<String>, chatComponentTurnend: Optional<String>, chatRoleSystemDefault: Optional<String>, stopTokenInt: Optional<Int>, stopTokenStr: Optional<String>, stopTokenInts: Optional<Array<Int>>, stopTokenStrings: Optional<Array<String>>, startExecutableStr: Optional<String>, startExecutableInt: Optional<Int>, endExecutableStr: Optional<String>, endExecutableInt: Optional<Int>, startImageTokenInt: Optional<Int>, startImageTokenStr: Optional<String>, endImageTokenInt: Optional<Int>, endImageTokenStr: Optional<String>, startAudioTokenInt: Optional<Int>, startAudioTokenStr: Optional<String>, endAudioTokenInt: Optional<Int>, endAudioTokenStr: Optional<String>) {}
        public init(from: Decoder) throws {}
        public func encode(to: Encoder) throws -> () {}
        public var chatComponentTurnend: Optional<String> { get { return nil } }
        public var chatRoleAssistant: Optional<String> { get { return nil } }
        public var chatRoleSystem: Optional<String> { get { return nil } }
        public var chatRoleSystemDefault: Optional<String> { get { return nil } }
        public var chatRoleTool: Optional<String> { get { return nil } }
        public var chatRoleUser: Optional<String> { get { return nil } }
        public var endAudioTokenInt: Optional<Int> { get { return nil } }
        public var endAudioTokenStr: Optional<String> { get { return nil } }
        public var endExecutableInt: Optional<Int> { get { return nil } }
        public var endExecutableStr: Optional<String> { get { return nil } }
        public var endImageTokenInt: Optional<Int> { get { return nil } }
        public var endImageTokenStr: Optional<String> { get { return nil } }
        public var endPromptToken: Optional<String> { get { return nil } }
        public var endPromptTokenInt: Optional<Int> { get { return nil } }
        public var startAudioTokenInt: Optional<Int> { get { return nil } }
        public var startAudioTokenStr: Optional<String> { get { return nil } }
        public var startExecutableInt: Optional<Int> { get { return nil } }
        public var startExecutableStr: Optional<String> { get { return nil } }
        public var startImageTokenInt: Optional<Int> { get { return nil } }
        public var startImageTokenStr: Optional<String> { get { return nil } }
        public var startPromptToken: Optional<Int> { get { return nil } }
        public var startPromptTokenStr: Optional<String> { get { return nil } }
        public var stopTokenInt: Optional<Int> { get { return nil } }
        public var stopTokenInts: Optional<Array<Int>> { get { return nil } }
        public var stopTokenStr: Optional<String> { get { return nil } }
        public var stopTokenStrings: Optional<Array<String>> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DraftMetadata: Codable, Hashable, Sendable {
        public init(draftSteps: Optional<Int>, draftIsAdaptive: Optional<Bool>, draftTreeFactor: Optional<Int>, draftSecondaryTreeFactor: Optional<Int>, draftSoftMatchTolerance: Optional<Double>, draftTreeMaxPaths: Optional<Int>, draftUseRejectionSampling: Optional<Bool>, draftUseMaximumLikelihoodTree: Optional<Bool>, draftEarlyReturn: Optional<Bool>, draftEarlyReturnProbabilityThreshold: Optional<Double>, speculativeSampling: Optional<Bool>, speculativeStreamingModel: Optional<Bool>, streamMaximumGamma: Optional<Int>, speculativeDecodeType: Optional<String>, temperature: Optional<Double>, streamSeparateWeights: Optional<Bool>, streamUseRejectionSampling: Optional<Bool>, streamLayerId: Optional<Int>, streamLossWeight: Optional<Double>, streamTreeFactor: Optional<Int>) {}
        public init(from: Decoder) throws {}
        public var draftSteps: Optional<Int> { get { return nil } }
        public var speculativeDecodeType: Optional<String> { get { return nil } }
        public var streamLossWeight: Optional<Double> { get { return nil } }
        public var streamSeparateWeights: Optional<Bool> { get { return nil } }
        public var streamTreeFactor: Optional<Int> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var draftEarlyReturn: Optional<Bool> { get { return nil } }
        public var draftEarlyReturnProbabilityThreshold: Optional<Double> { get { return nil } }
        public var draftIsAdaptive: Optional<Bool> { get { return nil } }
        public var draftSecondaryTreeFactor: Optional<Int> { get { return nil } }
        public var draftSoftMatchTolerance: Optional<Double> { get { return nil } }
        public var draftTreeFactor: Optional<Int> { get { return nil } }
        public var draftTreeMaxPaths: Optional<Int> { get { return nil } }
        public var draftUseMaximumLikelihoodTree: Optional<Bool> { get { return nil } }
        public var draftUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var speculativeSampling: Optional<Bool> { get { return nil } }
        public var speculativeStreamingModel: Optional<Bool> { get { return nil } }
        public var streamLayerId: Optional<Int> { get { return nil } }
        public var streamMaximumGamma: Optional<Int> { get { return nil } }
        public var streamUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var temperature: Optional<Double> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public init(from: Decoder) throws {}
    public init(modelType: String, modelConfig: Optional<String>, backboneSignature: Optional<String>, e5FunctionNameMap: Optional<Dictionary<String, LLMDraftModelAssetMetadata.ANEExtendInfo>>, defaultParameters: Optional<LLMDraftModelAssetMetadata.DraftMetadata>, specialTokensMap: Optional<LLMDraftModelAssetMetadata.DeviceSpecialTokensMap>, prewarmForConstrainedDecoding: Optional<Bool>, rollbackStrings: Optional<Array<String>>) {}
    public var modelConfig: Optional<String> { get { return nil } }
    public var prewarmForConstrainedDecoding: Optional<Bool> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var backboneSignature: Optional<String> { get { return nil } }
    public var defaultParameters: Optional<LLMDraftModelAssetMetadata.DraftMetadata> { get { return nil } }
    public var e5FunctionNameMap: Optional<Dictionary<String, LLMDraftModelAssetMetadata.ANEExtendInfo>> { get { return nil } }
    public var modelType: String { get { return "" } }
    public var rollbackStrings: Optional<Array<String>> { get { return nil } }
    public var specialTokensMap: Optional<LLMDraftModelAssetMetadata.DeviceSpecialTokensMap> { get { return nil } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMDraftModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(inner: ManagedResourceBase) {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var preconditions: Array<Precondition> { get { return [] } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var inner: ManagedResourceBase { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: LLMDraftModelBase, arg2: LLMDraftModelBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol LLMModel {
    associatedtype TokenizerType
    var tokenizer: Self.TokenizerType { get }
}
public struct LLMModelAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMModelAssetMetadata: Codable, Hashable, Sendable {
    public struct ANEExtendInfo: Codable, Hashable, Sendable {
        public init(from: Decoder) throws {}
        public init(type: String, adapterType: Optional<String>, ctxLen: Int, seqLen: Int) {}
        public func encode(to: Encoder) throws -> () {}
        public var adapterType: Optional<String> { get { return nil } }
        public var ctxLen: Int { get { return 0 } }
        public var seqLen: Int { get { return 0 } }
        public var type: String { get { return "" } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DeviceLocalization: Codable, Hashable, Sendable {
        public init(localeInstruction: Optional<Dictionary<String, String>>, localeInstructionInjectionLocation: Optional<Dictionary<String, String>>, chatRoleSystem: Optional<Dictionary<String, String>>, chatRoleSystemDefault: Optional<Dictionary<String, String>>, chatRoleAssistant: Optional<Dictionary<String, String>>, chatRoleUser: Optional<Dictionary<String, String>>, chatComponentTurnend: Optional<Dictionary<String, String>>) {}
        public init(from: Decoder) throws {}
        public var chatComponentTurnend: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleAssistant: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleSystem: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleSystemDefault: Optional<Dictionary<String, String>> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var chatRoleUser: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstruction: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstructionInjectionLocation: Optional<Dictionary<String, String>> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DeviceSpecialTokensMap: Codable, Hashable, Sendable {
        public init(startPromptToken: Optional<Int>, startPromptTokenStr: Optional<String>, endPromptToken: Optional<String>, endPromptTokenInt: Optional<Int>, chatRoleSystem: Optional<String>, chatRoleUser: Optional<String>, chatRoleAssistant: Optional<String>, chatRoleTool: Optional<String>, chatComponentTurnend: Optional<String>, chatRoleSystemDefault: Optional<String>, stopTokenInt: Optional<Int>, stopTokenStr: Optional<String>, stopTokenInts: Optional<Array<Int>>, stopTokenStrings: Optional<Array<String>>, startExecutableStr: Optional<String>, startExecutableInt: Optional<Int>, endExecutableStr: Optional<String>, endExecutableInt: Optional<Int>, startImageTokenInt: Optional<Int>, startImageTokenStr: Optional<String>, endImageTokenInt: Optional<Int>, endImageTokenStr: Optional<String>, startAudioTokenInt: Optional<Int>, startAudioTokenStr: Optional<String>, endAudioTokenInt: Optional<Int>, endAudioTokenStr: Optional<String>) {}
        public init(from: Decoder) throws {}
        public var chatComponentTurnend: Optional<String> { get { return nil } }
        public var chatRoleAssistant: Optional<String> { get { return nil } }
        public var chatRoleSystemDefault: Optional<String> { get { return nil } }
        public var chatRoleUser: Optional<String> { get { return nil } }
        public var endAudioTokenStr: Optional<String> { get { return nil } }
        public var endExecutableInt: Optional<Int> { get { return nil } }
        public var endImageTokenStr: Optional<String> { get { return nil } }
        public var endPromptToken: Optional<String> { get { return nil } }
        public var endPromptTokenInt: Optional<Int> { get { return nil } }
        public var startAudioTokenStr: Optional<String> { get { return nil } }
        public var startExecutableInt: Optional<Int> { get { return nil } }
        public var startExecutableStr: Optional<String> { get { return nil } }
        public var startImageTokenStr: Optional<String> { get { return nil } }
        public var stopTokenInt: Optional<Int> { get { return nil } }
        public var stopTokenInts: Optional<Array<Int>> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var chatRoleSystem: Optional<String> { get { return nil } }
        public var chatRoleTool: Optional<String> { get { return nil } }
        public var endAudioTokenInt: Optional<Int> { get { return nil } }
        public var endExecutableStr: Optional<String> { get { return nil } }
        public var endImageTokenInt: Optional<Int> { get { return nil } }
        public var startAudioTokenInt: Optional<Int> { get { return nil } }
        public var startImageTokenInt: Optional<Int> { get { return nil } }
        public var startPromptToken: Optional<Int> { get { return nil } }
        public var startPromptTokenStr: Optional<String> { get { return nil } }
        public var stopTokenStr: Optional<String> { get { return nil } }
        public var stopTokenStrings: Optional<Array<String>> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DraftMetadata: Codable, Hashable, Sendable {
        public init(draftSteps: Optional<Int>, draftIsAdaptive: Optional<Bool>, draftTreeFactor: Optional<Int>, draftSecondaryTreeFactor: Optional<Int>, draftSoftMatchTolerance: Optional<Double>, draftTreeMaxPaths: Optional<Int>, draftUseRejectionSampling: Optional<Bool>, draftUseMaximumLikelihoodTree: Optional<Bool>, draftEarlyReturn: Optional<Bool>, draftEarlyReturnProbabilityThreshold: Optional<Double>, speculativeSampling: Optional<Bool>, speculativeStreamingModel: Optional<Bool>, streamMaximumGamma: Optional<Int>, speculativeDecodeType: Optional<String>, temperature: Optional<Double>, streamSeparateWeights: Optional<Bool>, streamUseRejectionSampling: Optional<Bool>, streamLayerId: Optional<Int>, streamLossWeight: Optional<Double>, streamTreeFactor: Optional<Int>) {}
        public init(from: Decoder) throws {}
        public var draftEarlyReturn: Optional<Bool> { get { return nil } }
        public var draftEarlyReturnProbabilityThreshold: Optional<Double> { get { return nil } }
        public var draftSteps: Optional<Int> { get { return nil } }
        public var draftTreeFactor: Optional<Int> { get { return nil } }
        public var draftUseMaximumLikelihoodTree: Optional<Bool> { get { return nil } }
        public var draftUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var speculativeStreamingModel: Optional<Bool> { get { return nil } }
        public var streamLayerId: Optional<Int> { get { return nil } }
        public var streamLossWeight: Optional<Double> { get { return nil } }
        public var streamMaximumGamma: Optional<Int> { get { return nil } }
        public var streamSeparateWeights: Optional<Bool> { get { return nil } }
        public var streamTreeFactor: Optional<Int> { get { return nil } }
        public var streamUseRejectionSampling: Optional<Bool> { get { return nil } }
        public var temperature: Optional<Double> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public var draftIsAdaptive: Optional<Bool> { get { return nil } }
        public var draftSecondaryTreeFactor: Optional<Int> { get { return nil } }
        public var draftSoftMatchTolerance: Optional<Double> { get { return nil } }
        public var draftTreeMaxPaths: Optional<Int> { get { return nil } }
        public var speculativeDecodeType: Optional<String> { get { return nil } }
        public var speculativeSampling: Optional<Bool> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum LoraRank: Hashable, Sendable {
        case _mock
    }
    public enum ModelVersion: Hashable, Sendable {
        case _mock
    }
    public enum PromptPreprocessingTemplateVersion: Hashable, Sendable {
        case _mock
    }
    public init(from: Decoder) throws {}
    public init(modelType: String, modelVersion: Optional<LLMModelAssetMetadata.ModelVersion>, promptPreprocessingTemplateVersion: Optional<LLMModelAssetMetadata.PromptPreprocessingTemplateVersion>, contextLength: Optional<Int>, modelConfig: Optional<String>, backboneSignature: Optional<String>, adapterTypeToSignatureMapping: Optional<Dictionary<String, String>>, adapterTypeToSymbolMapping: Optional<Dictionary<String, String>>, e5FunctionNameMap: Optional<Dictionary<String, LLMModelAssetMetadata.ANEExtendInfo>>, specialTokensMap: Optional<LLMModelAssetMetadata.DeviceSpecialTokensMap>, localization: Optional<LLMModelAssetMetadata.DeviceLocalization>, defaultParameters: Optional<LLMModelAssetMetadata.DraftMetadata>, prewarmForConstrainedDecoding: Optional<Bool>, customClientMetadata: Optional<Dictionary<String, String>>, allowPromptFallback: Optional<Bool>, imageNormalizationFactor: Optional<Double>) {}
    public var adapterTypeToSignatureMapping: Optional<Dictionary<String, String>> { get { return nil } }
    public var allowPromptFallback: Optional<Bool> { get { return nil } }
    public var customClientMetadata: Optional<Dictionary<String, String>> { get { return nil } }
    public var e5FunctionNameMap: Optional<Dictionary<String, LLMModelAssetMetadata.ANEExtendInfo>> { get { return nil } }
    public var imageNormalizationFactor: Optional<Double> { get { return nil } }
    public var modelConfig: Optional<String> { get { return nil } }
    public var modelVersion: Optional<LLMModelAssetMetadata.ModelVersion> { get { return nil } }
    public var promptPreprocessingTemplateVersion: Optional<LLMModelAssetMetadata.PromptPreprocessingTemplateVersion> { get { return nil } }
    public var specialTokensMap: Optional<LLMModelAssetMetadata.DeviceSpecialTokensMap> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var adapterTypeToSymbolMapping: Optional<Dictionary<String, String>> { get { return nil } }
    public var backboneSignature: Optional<String> { get { return nil } }
    public var contextLength: Optional<Int> { get { return nil } }
    public var defaultParameters: Optional<LLMModelAssetMetadata.DraftMetadata> { get { return nil } }
    public var localization: Optional<LLMModelAssetMetadata.DeviceLocalization> { get { return nil } }
    public var modelType: String { get { return "" } }
    public var prewarmForConstrainedDecoding: Optional<Bool> { get { return nil } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct LLMModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(inner: ManagedResourceBase) {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var inner: ManagedResourceBase { get { fatalError() } }
    public var preconditions: Array<Precondition> { get { return [] } }
    public var tokenizer: TokenizerBase { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: LLMModelBase, arg2: LLMModelBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public class LocalCatalogClient {
    public init(resources: Array<any CatalogResource>, resourceBundles: Array<any ResourceBundle_P>, statusBlock: (String) throws -> StatusResponse, informationBlock: (String) throws -> ResourceInformation) {}
    public func resourceInformation(identifier: String) throws -> ResourceInformation { fatalError() }
    public func resourceBundle(for: String) throws -> Optional<any ResourceBundle_P> { return nil }
    public func resourceStatus(identifier: String) throws -> StatusResponse { fatalError() }
    public func resource(for: String) throws -> Optional<any CatalogResource> { return nil }
    public func releaseResources(for: RequestResourcesKey) throws -> () {}
    public func releaseResource(identifier: String) throws -> NSNumber { fatalError() }
    public func requestResource(identifier: String) throws -> NSNumber { fatalError() }
    public func requestResources(for: RequestResourcesKey) throws -> () {}
    public func resourceBundles() throws -> Array<any ResourceBundle_P> { return [] }
    public func stubUseCaseResourceAvailability(for: UseCaseIdentifier, info: UseCaseAvailabilityInfo) -> () {}
    public func useCaseResourceAvailability(by: Array<UseCaseIdentifier>) async throws -> Dictionary<UseCaseIdentifier, UseCaseAvailabilityInfo> { return [:] }
    public func resources() throws -> Array<any CatalogResource> { return [] }
    public func stubSiriResourceAvailability(availability: SiriResourceAvailabilityInfo) -> () {}
    public func siriResourceAvailability() throws -> SiriResourceAvailabilityInfo { fatalError() }
    public func formatInferenceID(from: String) throws -> String { return "" }
    public func enableTestResources() throws -> Bool { return false }
}
public protocol ManagedResource<A> {
    associatedtype A
    var cost: CostProfile { get }
    var dependencies: Array<any ManagedResource> { get }
    var executionContexts: Set<ExecutionContext> { get set }
    var runtimeInformation: Array<ManagedRuntimeInformation> { get }
}
public struct ManagedResourceBase: Codable, Hashable, Sendable {
    public init(id: String, dependentResourceIDs: Array<String>, runtimeInformation: Array<ManagedRuntimeInformation>) {}
    public init(from: Decoder) throws {}
    public var vmInferenceProviders: Set<InferenceProvider> { get { return [] } }
    public func hash(into: inout Hasher) -> () {}
    public var assetBacked: Bool { get { return false } }
    public var dependencies: Array<any ManagedResource> { get { return [] } }
    public var dependentResourceIDs: Array<String> { get { return [] } }
    public var executionContexts: Set<ExecutionContext> { get { return [] } set {} }
    public var hashValue: Int { get { return 0 } }
    public var id: String { get { return "" } }
    public var inferenceProviders: Set<InferenceProvider> { get { return [] } }
    public var preconditions: Array<Precondition> { get { return [] } }
    public var runtimeInformation: Array<ManagedRuntimeInformation> { get { return [] } }
    public var sideloaded: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var cost: CostProfile { get { fatalError() } }
    public static func ==(arg1: ManagedResourceBase, arg2: ManagedResourceBase) -> Bool { return false }
}
public struct ManagedRuntimeInformation: Codable, Hashable, Sendable {
    public init(inferenceProvider: InferenceProvider, vmInferenceProvider: Optional<InferenceProvider>, cost: CostProfile, instanceID: Optional<String>) {}
    public init(from: Decoder) throws {}
    public init(inferenceProvider: InferenceProvider, cost: CostProfile) {}
    public init(inferenceProvider: InferenceProvider, cost: CostProfile, instanceID: Optional<String>) {}
    public var hashValue: Int { get { return 0 } }
    public var vmInferenceProvider: Optional<InferenceProvider> { get { return nil } }
    public static func ==(arg1: ManagedRuntimeInformation, arg2: ManagedRuntimeInformation) -> Bool { return false }
    public var inferenceProvider: InferenceProvider { get { fatalError() } }
    public var instanceID: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var cost: CostProfile { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
}
public struct MobileGestaltProvider: Codable, Hashable, Sendable {
    public init() {}
    public var deviceMemorySize: Int64 { get { return 0 } }
    public var regionCode: Optional<String> { get { return nil } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public protocol MobileGestaltProviding {
    var deviceMemorySize: Int64 { get }
    var regionCode: Optional<String> { get }
}
public enum ModelCatalogFeatureFlags: Hashable, Sendable {
    case _mock
    public func hash(into: inout Hasher) -> () {}
    public static func isAssetCoherenceEnabled() -> Bool { return false }
    public var domain: StaticString { get { return "" } }
    public static func ==(arg1: ModelCatalogFeatureFlags, arg2: ModelCatalogFeatureFlags) -> Bool { return false }
    public static func isEnablePreBuddyDownloadsEnabled() -> Bool { return false }
    public var feature: StaticString { get { return "" } }
    public var hashValue: Int { get { return 0 } }
}
public protocol ModelConfigurationReplacement {
}
public struct ModelConfigurationReplacementAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ModelConfigurationReplacementAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ModelConfigurationReplacementBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: ModelConfigurationReplacementBase, arg2: ModelConfigurationReplacementBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol Motion {
}
public protocol MotionAdapter {
}
public struct MotionAdapterAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct MotionAdapterAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct MotionAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: MotionAdapterBase, arg2: MotionAdapterBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct MotionAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct MotionAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct MotionBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: MotionBase, arg2: MotionBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct MotionBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var baseModel: Optional<Motion> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func baseModel(arg1: Optional<Motion>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var adapter: Optional<any MotionAdapter> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func build() throws -> MotionBundle { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func adapter(arg1: Optional<any MotionAdapter>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (MotionBundle.Builder) throws -> ()) throws {}
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var adapter: Optional<any MotionAdapter> { get { return nil } }
    public var baseModel: Motion { get { fatalError() } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<MotionBundle> { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public static func ==(arg1: MotionBundle, arg2: MotionBundle) -> Bool { return false }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
}
public protocol MotionBundleProtocol {
}
public enum MultiBaseModel: Hashable, Sendable {
    case _mock
    public static func formatDefaultBaseModelInferenceID(from: String) throws -> String { return "" }
}
public enum Obfuscation: Hashable, Sendable {
    case _mock
}
public protocol PCCGenericInference {
}
public struct PCCGenericInferenceAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct PCCGenericInferenceAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct PCCGenericInferenceBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: PCCGenericInferenceBase, arg2: PCCGenericInferenceBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct PCCGenericInferenceBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func build() throws -> PCCGenericInferenceBundle { fatalError() }
        public func pccGenericInference(arg1: Optional<PCCGenericInference>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var pccGenericInference: Optional<PCCGenericInference> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
    }
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (PCCGenericInferenceBundle.Builder) throws -> ()) throws {}
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<PCCGenericInferenceBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: PCCGenericInferenceBundle, arg2: PCCGenericInferenceBundle) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var pccGenericInference: PCCGenericInference { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
}
public protocol PCCGenericInferenceBundleProtocol {
}
public struct ParameterizedUseCase: Codable, Hashable, Sendable {
    public struct SettingsAppleIntelligenceDiffusionDownloadArguments: Codable, Hashable, Sendable {
        public init(languageCode: Locale.LanguageCode) {}
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct SettingsAppleIntelligenceDownloadArguments: Codable, Hashable, Sendable {
        public init(languageCode: Locale.LanguageCode) {}
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct SiriDownloadArguments: Codable, Hashable, Sendable {
        public init() {}
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct SpatialPhotosReliveMainDownloadArguments: Codable, Hashable, Sendable {
        public init() {}
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public static func genericUseCase(useCaseIdentifier: UseCaseIdentifier, arguments: Dictionary<String, String>) -> ParameterizedUseCase { fatalError() }
    public static func settingsAppleIntelligenceDiffusion(arg1: ParameterizedUseCase.SettingsAppleIntelligenceDiffusionDownloadArguments) -> ParameterizedUseCase { fatalError() }
    public static func spatialPhotosReliveMain(arg1: ParameterizedUseCase.SpatialPhotosReliveMainDownloadArguments) -> ParameterizedUseCase { fatalError() }
    public static func settingsAppleIntelligence(arg1: ParameterizedUseCase.SettingsAppleIntelligenceDownloadArguments) -> ParameterizedUseCase { fatalError() }
    public static func siri(arg1: ParameterizedUseCase.SiriDownloadArguments) -> ParameterizedUseCase { fatalError() }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public enum PartnerCapabilities: Hashable, Sendable {
    case _mock
    public static func ChatGPT() -> Capabilities { fatalError() }
}
public struct Platform: Codable, Hashable, Sendable {
    public enum PlatformType: Hashable, Sendable {
        case _mock
    }
    public init(from: Decoder) throws {}
    public init(platformType: Platform.PlatformType, version: String) {}
    public var hashValue: Int { get { return 0 } }
    public var platformType: Platform.PlatformType { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: Platform, arg2: Platform) -> Bool { return false }
    public func encode(to: Encoder) throws -> () {}
    public var version: String { get { return "" } }
}
public struct Precondition: Codable, Hashable, Sendable {
    public enum PreconditionType: Hashable, Sendable {
        case _mock
        public var usages: Dictionary<String, String> { get { return [:] } }
    }
    public init(from: Decoder) throws {}
    public static func ==(arg1: Precondition, arg2: Precondition) -> Bool { return false }
    public static var aneHardwareEligible: Precondition { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var preconditionType: Precondition.PreconditionType { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
    public static var generativeExperiencesHardwareEligible: Precondition { get { fatalError() } }
}
public protocol PromptAllowList {
}
public struct PromptAllowListAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct PromptAllowListAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct PromptAllowListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: PromptAllowListBase, arg2: PromptAllowListBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol RankingModel {
}
public struct RankingModelAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct RankingModelAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct RankingModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: RankingModelBase, arg2: RankingModelBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol RateLimiting {
    func shouldAllow(key: String) -> (allowed: Bool, lastAllowed: Optional<Date>)
}
public struct RawAvailableUseCases: Codable, Hashable, Sendable {
    public struct RawAvailableUseCase: Codable, Hashable, Sendable {
        public init(useCaseIdentifier: UseCaseIdentifier, arguments: Dictionary<String, String>, presentAssets: Optional<Array<String>>, missingAssets: Optional<Array<String>>, assetsReady: Bool) {}
        public init(from: Decoder) throws {}
        public func hash(into: inout Hasher) -> () {}
        public func encode(to: Encoder) throws -> () {}
        public var hashValue: Int { get { return 0 } }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
    }
    public init(from: Decoder) throws {}
    public init(rawAvailableUseCases: Set<RawAvailableUseCases.RawAvailableUseCase>) {}
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: RawAvailableUseCases, arg2: RawAvailableUseCases) -> Bool { return false }
    public func encode(to: Encoder) throws -> () {}
}
public struct RawGuardrailResult: Codable, Hashable, Sendable {
    public enum InstanceType: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public func hash(into: inout Hasher) -> () {}
        public var hashValue: Int { get { return 0 } }
    }
    public init(from: Decoder) throws {}
    public init(markedUnsafe: Bool, usecaseIdentifier: String, instanceType: RawGuardrailResult.InstanceType, userRequestID: UUID) {}
    public static func ==(arg1: RawGuardrailResult, arg2: RawGuardrailResult) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var instanceType: RawGuardrailResult.InstanceType { get { fatalError() } }
    public var markedUnsafe: Bool { get { return false } }
    public var usecaseIdentifier: String { get { return "" } }
    public var userRequestID: UUID { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
}
public struct RequestDownloadProgressInformation: Codable, Hashable, Sendable {
    public var bytesCompleted: Int { get { return 0 } }
    public var progress: Double { get { return 0 } }
    public var resourceIDs: Array<String> { get { return [] } }
    public var status: AssetSubscriptionStatus { get { fatalError() } }
    public var totalBytes: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct RequestDownloadUseCases: Codable, Hashable, Sendable {
    public init(parameterizedUseCases: Array<ParameterizedUseCase>) {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public enum RequestResourcesKey: Hashable, Sendable {
    case _mock
    public static func deprecatedKeys() -> Array<RequestResourcesKey> { return [] }
    public var usageKey: String { get { return "" } }
}
public struct ResourceBase: Codable, Hashable, Sendable {
    public init(id: String, dependentResourceIDs: Array<String>) {}
    public init(from: Decoder) throws {}
    public var preconditions: Array<Precondition> { get { return [] } }
    public var sideloaded: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var assetBacked: Bool { get { return false } }
    public var dependentResourceIDs: Array<String> { get { return [] } }
    public var id: String { get { return "" } }
    public var inferenceProviders: Set<InferenceProvider> { get { return [] } }
    public var vmInferenceProviders: Set<InferenceProvider> { get { return [] } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: ResourceBase, arg2: ResourceBase) -> Bool { return false }
}
public protocol ResourceBundle {
    var bundlePolicy: BundlePolicy { get }
    var configurationIdentifier: String { get }
    var id: ResourceBundleIdentifier<Any> { get }
    var modelInterfaceName: Optional<String> { get }
    var rawID: String { get }
    var resources: Array<any CatalogResource> { get }
    var serverWorkflowEnabled: Bool { get }
    var trialNamespace: Optional<String> { get }
}
public class ResourceBundleContainer {
    public init() {}
    public init(coder: NSCoder) {}
    public init(resourceBundleData: Data, resourceBundleType: String, assetBacked: Bool) {}
    public var assetBacked: Bool { get { return false } }
    public static var assetBackedKey: String { get { return "" } }
    public static var resourceBundleDataKey: String { get { return "" } }
    public static func from(resourceBundle: Optional<any ResourceBundle_P>) throws -> ResourceBundleContainer { fatalError() }
    public var description: String { get { return "" } }
    public var resourceBundleType: String { get { return "" } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func encode(with: NSCoder) -> () {}
    public func toResourceBundle() throws -> Optional<any ResourceBundle_P> { return nil }
    public var resourceBundleData: Data { get { return Data() } }
    public static var resourceBundleTypeKey: String { get { return "" } }
}
public struct ResourceBundleIdentifier<A>: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public init(stringLiteral: String) {}
    public var id: String { get { return "" } }
    public static func ==(arg1: ResourceBundleIdentifier<GenericA>, arg2: String) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
    public var description: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: String, arg2: ResourceBundleIdentifier<GenericA>) -> Bool { return false }
    public static func ==(arg1: ResourceBundleIdentifier<GenericA>, arg2: ResourceBundleIdentifier<GenericA>) -> Bool { return false }
}
public struct ResourceBundleQuery: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, languageCode: Optional<Locale.LanguageCode>, otherArguments: Optional<Dictionary<String, String>>) throws {}
    public init(uri: URL) throws {}
    public init(configurationIdentifier: String, arguments: Optional<Dictionary<String, String>>) throws {}
    public static func ==(arg1: ResourceBundleQuery, arg2: ResourceBundleQuery) -> Bool { return false }
    public func encode(to: Encoder) throws -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public func toURI() throws -> URL { fatalError() }
    public var hashValue: Int { get { return 0 } }
    public func addArguments(arg1: Dictionary<String, String>, shouldOverride: Bool) throws -> ResourceBundleQuery { fatalError() }
    public func hash(into: inout Hasher) -> () {}
}
public struct ResourceConfiguration: Codable, Hashable, Sendable {
    public init(resourceType: String, sourceName: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>) {}
    public init(resourceType: String, sourceName: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>, useCases: Optional<Array<UseCase>>, platforms: Optional<Array<Platform>>, dynamicVariants: Optional<Bool>) {}
    public init(resourceType: String, sourceName: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>, tags: Optional<Array<Tag>>, useCases: Optional<Array<UseCase>>, platforms: Optional<Array<Platform>>) {}
    public init(resourceType: String, sourceName: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>, useCases: Optional<Array<UseCase>>, platforms: Optional<Array<Platform>>, dynamicVariants: Optional<Bool>, stripGenericFromAssetSpecifier: Optional<Bool>) {}
    public init(resourceType: String, sourceName: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>, platforms: Optional<Array<Platform>>) {}
    public init(resourceType: String, sourceName: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>, tags: Optional<Array<Tag>>, platforms: Optional<Array<Platform>>) {}
    public init(resourceType: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>) {}
    public init(from: Decoder) throws {}
    public init(resourceType: String, sourceName: String, id: String, dependentResourceIDs: Array<String>, preconditions: Array<Precondition>, runtimeInformation: Optional<Array<ManagedRuntimeInformation>>, assetBacked: Bool, assetSubscriptionInformation: Optional<AssetSubscriptionInformation>, useCases: Optional<Array<UseCase>>, platforms: Optional<Array<Platform>>) {}
    public var assetBacked: Bool { get { return false } }
    public var dependentResourceIDs: Array<String> { get { return [] } }
    public var platforms: Optional<Array<Platform>> { get { return nil } }
    public var preconditions: Array<Precondition> { get { return [] } }
    public var useCases: Optional<Array<UseCase>> { get { return nil } }
    public static func ==(arg1: ResourceConfiguration, arg2: ResourceConfiguration) -> Bool { return false }
    public var assetSubscriptionInformation: Optional<AssetSubscriptionInformation> { get { return nil } }
    public var dynamicVariants: Optional<Bool> { get { return nil } }
    public var hostedInAsset: Optional<String> { get { return nil } }
    public var resourceType: String { get { return "" } }
    public var sourceName: String { get { return "" } }
    public func encode(to: Encoder) throws -> () {}
    public var tags: Optional<Array<Tag>> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var id: String { get { return "" } }
    public var runtimeInformation: Optional<Array<ManagedRuntimeInformation>> { get { return nil } }
    public var sideloaded: Bool { get { return false } }
    public var stripGenericFromAssetSpecifier: Optional<Bool> { get { return nil } }
}
public class ResourceContainer {
    public init(coder: NSCoder) {}
    public init() {}
    public init(resourceData: Data, resourceType: String, assetBacked: Bool) {}
    public var resourceData: Data { get { return Data() } }
    public func toResource() throws -> Optional<any CatalogResource> { return nil }
    public var assetBacked: Bool { get { return false } }
    public static var resourceDataKey: String { get { return "" } }
    public var resourceType: String { get { return "" } }
    public static var resourceTypeKey: String { get { return "" } }
    public static func from(resource: Optional<any CatalogResource>) throws -> ResourceContainer { fatalError() }
    public var description: String { get { return "" } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func encode(with: NSCoder) -> () {}
    public static var assetBackedKey: String { get { return "" } }
}
public class ResourceInformation {
    public init() {}
    public init(coder: NSCoder) {}
    public func encode(with: NSCoder) -> () {}
    public var location: Optional<URL> { get { return nil } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
}
public struct ResourceQuery: Codable, Hashable, Sendable {
    public init(configurationIdentifier: String, arguments: Optional<Dictionary<String, String>>) throws {}
    public var hashValue: Int { get { return 0 } }
    public func toURI() throws -> URL { fatalError() }
    public static func ==(arg1: ResourceQuery, arg2: ResourceQuery) -> Bool { return false }
    public var configurationIdentifier: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public enum ResourceReadinessStatus: Hashable, Sendable {
    case _mock
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: ResourceReadinessStatus, arg2: ResourceReadinessStatus) -> Bool { return false }
}
public enum ResourceStatus: Hashable, Sendable {
    case _mock
}
public struct ResourceStatusOutput: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public var assetSet: Optional<String> { get { return nil } }
    public var coherenceGlyph: Optional<String> { get { return nil } }
    public var displayVersion: Optional<String> { get { return nil } }
    public var experimentID: Optional<String> { get { return nil } }
    public var glyph: String { get { return "" } }
    public func encode(to: Encoder) throws -> () {}
    public var gmEssential: Bool { get { return false } }
    public var variant: String { get { return "" } }
    public func description(useCaseIdentifier: Optional<UseCaseIdentifier>, withAssetSet: Bool) -> String { return "" }
    public static var legend: Dictionary<String, String> { get { return [:] } }
    public var percent: Optional<Double> { get { return nil } }
    public var resourceID: String { get { return "" } }
    public var resourceType: Optional<String> { get { return nil } }
    public var size: Optional<Int64> { get { return nil } }
    public var sourceName: Optional<String> { get { return nil } }
    public var useCases: Array<UseCase> { get { return [] } }
    public var version: Optional<String> { get { return nil } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ResourceVariantResolverArgument: Codable, Hashable, Sendable {
    public init(name: String, featureFlagsKey: Optional<String>, featureFlagValueProvider: (FeatureFlags_FeatureFlagsKey) -> Bool, ifpValueProvider: () -> Bool) {}
    public var name: String { get { return "" } }
    public func ifpValue() -> Optional<Bool> { return nil }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public func featureFlagValue() -> Optional<Bool> { return nil }
    public static func ==(arg1: ResourceVariantResolverArgument, arg2: ResourceVariantResolverArgument) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct SafetyFailure: Codable, Hashable, Sendable {
    public init(useCaseIdentifier: UseCaseIdentifier, userIdentifier: UInt32) {}
    public init(from: Decoder) throws {}
    public init(useCaseIdentifier: UseCaseIdentifier, userIdentifier: UInt32, userRequestIdentifier: UUID) {}
    public var userIdentifier: UInt32 { get { return 0 } }
    public static func ==(arg1: SafetyFailure, arg2: SafetyFailure) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
    public var useCaseIdentifier: UseCaseIdentifier { get { fatalError() } }
    public var userRequestIdentifier: UUID { get { fatalError() } }
}
public class SafetyFailureWrapper {
    public init() {}
    public init(coder: NSCoder) {}
    public init(safetyFailure: SafetyFailure) {}
    public var description: String { get { return "" } }
    public func encode(with: NSCoder) -> () {}
    public var safetyFailure: SafetyFailure { get { fatalError() } }
    public static var safetyFailureKey: String { get { return "" } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func copy(with: Optional<NSZone>) -> Any { fatalError() }
    public var hash: Int { get { return 0 } }
}
public protocol SafetyOutputConfiguration {
}
public struct SafetyOutputConfigurationAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SafetyOutputConfigurationAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SafetyOutputConfigurationBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: SafetyOutputConfigurationBase, arg2: SafetyOutputConfigurationBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct SafetyOutputConfigurationBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func configuration(arg1: Optional<SafetyOutputConfiguration>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var configuration: Optional<SafetyOutputConfiguration> { get { return nil } set {} }
        public func build() throws -> SafetyOutputConfigurationBundle { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (SafetyOutputConfigurationBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public static func ==(arg1: SafetyOutputConfigurationBundle, arg2: SafetyOutputConfigurationBundle) -> Bool { return false }
    public var configurationIdentifier: String { get { return "" } }
    public var rawID: String { get { return "" } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: SafetyOutputConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<SafetyOutputConfigurationBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
}
public protocol SafetyOutputConfigurationBundleProtocol {
}
public struct SanitizerBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func build() throws -> SanitizerBundle { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (SanitizerBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var id: ResourceBundleIdentifier<SanitizerBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: SanitizerBundle, arg2: SanitizerBundle) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
}
public protocol SanitizerBundleProtocol {
}
public protocol SecureAnalytics {
}
public struct SecureAnalyticsAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SecureAnalyticsAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SecureAnalyticsBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: SecureAnalyticsBase, arg2: SecureAnalyticsBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct SecureAnalyticsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func baseModel(arg1: Optional<SecureAnalytics>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func build() throws -> SecureAnalyticsBundle { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var baseModel: Optional<SecureAnalytics> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (SecureAnalyticsBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(from: Decoder) throws {}
    public var baseModel: SecureAnalytics { get { fatalError() } }
    public var id: ResourceBundleIdentifier<SecureAnalyticsBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: SecureAnalyticsBundle, arg2: SecureAnalyticsBundle) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configurationIdentifier: String { get { return "" } }
}
public protocol SecureAnalyticsBundleProtocol {
}
public protocol ServerConfiguration {
}
public struct ServerConfigurationAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerConfigurationAssetMetadata: Codable, Hashable, Sendable {
    public struct CloudLocalization: Codable, Hashable, Sendable {
        public init(localeInstruction: Optional<Dictionary<String, String>>, localeInstructionInjectionLocation: Optional<Dictionary<String, String>>, chatRoleSystem: Optional<Dictionary<String, String>>, chatRoleSystemDefault: Optional<Dictionary<String, String>>, chatRoleAssistant: Optional<Dictionary<String, String>>, chatRoleUser: Optional<Dictionary<String, String>>, chatComponentTurnend: Optional<Dictionary<String, String>>, userDefinedFields: Optional<Dictionary<String, Dictionary<String, String>>>, chatRoleDeveloperStaticInstructions: Optional<Dictionary<String, String>>) {}
        public init(from: Decoder) throws {}
        public var chatComponentTurnend: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleAssistant: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleDeveloperStaticInstructions: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleSystem: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleSystemDefault: Optional<Dictionary<String, String>> { get { return nil } }
        public var chatRoleUser: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstruction: Optional<Dictionary<String, String>> { get { return nil } }
        public var localeInstructionInjectionLocation: Optional<Dictionary<String, String>> { get { return nil } }
        public var userDefinedFields: Optional<Dictionary<String, Dictionary<String, String>>> { get { return nil } }
        public func encode(to: Encoder) throws -> () {}
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct MLMConfig: Codable, Hashable, Sendable {
        public init(contextLen: Int, inputTokenCountEstimate: Optional<Int>, heuristicInputTokenCount: Optional<Int>) {}
        public init(from: Decoder) throws {}
        public var contextLen: Int { get { return 0 } }
        public func encode(to: Encoder) throws -> () {}
        public var heuristicInputTokenCount: Optional<Int> { get { return nil } }
        public var inputTokenCountEstimate: Optional<Int> { get { return nil } }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public init(mlmConfig: ServerConfigurationAssetMetadata.MLMConfig, localization: Optional<ServerConfigurationAssetMetadata.CloudLocalization>) {}
    public init(from: Decoder) throws {}
    public var localization: Optional<ServerConfigurationAssetMetadata.CloudLocalization> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var mlmConfig: ServerConfigurationAssetMetadata.MLMConfig { get { fatalError() } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerConfigurationBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: ServerConfigurationBase, arg2: ServerConfigurationBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionANFREncoder {
}
public struct ServerDiffusionANFREncoderAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionANFREncoderAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionANFREncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: ServerDiffusionANFREncoderBase, arg2: ServerDiffusionANFREncoderBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionAdapter {
}
public struct ServerDiffusionAdapterAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionAdapterAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionAdapterBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: ServerDiffusionAdapterBase, arg2: ServerDiffusionAdapterBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionAlphaMaskDecoder {
}
public struct ServerDiffusionAlphaMaskDecoderAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionAlphaMaskDecoderAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionAlphaMaskDecoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: ServerDiffusionAlphaMaskDecoderBase, arg2: ServerDiffusionAlphaMaskDecoderBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionAutoEncoder {
}
public struct ServerDiffusionAutoEncoderAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionAutoEncoderAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionAutoEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: ServerDiffusionAutoEncoderBase, arg2: ServerDiffusionAutoEncoderBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct ServerDiffusionBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var anfrEncoder: Optional<any ServerDiffusionANFREncoder> { get { return nil } set {} }
        public var safetyPreprocessorAdapter: Optional<any LLMAdapter> { get { return nil } set {} }
        public func alphaMaskDecoder(arg1: Optional<any ServerDiffusionAlphaMaskDecoder>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var safetyPostprocessorAdapter: Optional<any LLMAdapter> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func synthid(arg1: Optional<any ServerDiffusionSynthID>) -> Builder { fatalError() }
        public func safetyAdapterPromptRewrite(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public func safetyImageTokenizer(arg1: Optional<ImageTokenizer>) -> Builder { fatalError() }
        public func diffusionAdapter(arg1: Optional<any ServerDiffusionAdapter>) -> Builder { fatalError() }
        public var imageTokenizer: Optional<any ServerDiffusionImageTokenizer> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var safetyAdapterMiscSafety: Optional<any LLMAdapter> { get { return nil } set {} }
        public var safetyAdapterPromptRewrite: Optional<any LLMAdapter> { get { return nil } set {} }
        public var safetyTokenizer: Optional<Tokenizer> { get { return nil } set {} }
        public func anfrEncoder(arg1: Optional<any ServerDiffusionANFREncoder>) -> Builder { fatalError() }
        public func vaeEncoder(arg1: Optional<any ServerDiffusionVAEEncoder>) -> Builder { fatalError() }
        public var safetyImageTokenizer: Optional<ImageTokenizer> { get { return nil } set {} }
        public func safetyAdapterMiscSafety(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public func safetyPostprocessorAdapter(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public func safetyTokenizer(arg1: Optional<Tokenizer>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var tokenizer: Optional<any ServerDiffusionTokenizer> { get { return nil } set {} }
        public func tokenizer(arg1: Optional<any ServerDiffusionTokenizer>) -> Builder { fatalError() }
        public var alphaMaskDecoder: Optional<any ServerDiffusionAlphaMaskDecoder> { get { return nil } set {} }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var diffusionAdapter: Optional<any ServerDiffusionAdapter> { get { return nil } set {} }
        public var vaeDecoder: Optional<any ServerDiffusionVAEDecoder> { get { return nil } set {} }
        public func safetyBaseModel(arg1: Optional<any LLMModel>) -> Builder { fatalError() }
        public func textencoder(arg1: Optional<any ServerDiffusionTextEncoder>) -> Builder { fatalError() }
        public func build() throws -> ServerDiffusionBundle { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var textencoder: Optional<any ServerDiffusionTextEncoder> { get { return nil } set {} }
        public func noisePredictor(arg1: Optional<any ServerDiffusionNoisePredictor>) -> Builder { fatalError() }
        public var synthid: Optional<any ServerDiffusionSynthID> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var safetyBaseModel: Optional<any LLMModel> { get { return nil } set {} }
        public func vaeDecoder(arg1: Optional<any ServerDiffusionVAEDecoder>) -> Builder { fatalError() }
        public func safetyAdapterMultimodalInput(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public func imageTokenizer(arg1: Optional<any ServerDiffusionImageTokenizer>) -> Builder { fatalError() }
        public var safetyAdapterMultimodalInput: Optional<any LLMAdapter> { get { return nil } set {} }
        public func safetyPreprocessorAdapter(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public var noisePredictor: Optional<any ServerDiffusionNoisePredictor> { get { return nil } set {} }
        public var vaeEncoder: Optional<any ServerDiffusionVAEEncoder> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (ServerDiffusionBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public var safetyAdapterMultimodalInput: Optional<any LLMAdapter> { get { return nil } }
    public var safetyPreprocessorAdapter: Optional<any LLMAdapter> { get { return nil } }
    public var safetyTokenizer: Optional<Tokenizer> { get { return nil } }
    public var textencoder: any ServerDiffusionTextEncoder { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public var alphaMaskDecoder: Optional<any ServerDiffusionAlphaMaskDecoder> { get { return nil } }
    public var diffusionAdapter: Optional<any ServerDiffusionAdapter> { get { return nil } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<ServerDiffusionBundle> { get { fatalError() } }
    public var imageTokenizer: Optional<any ServerDiffusionImageTokenizer> { get { return nil } }
    public var noisePredictor: any ServerDiffusionNoisePredictor { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var safetyAdapterMiscSafety: Optional<any LLMAdapter> { get { return nil } }
    public var safetyAdapterPromptRewrite: Optional<any LLMAdapter> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var tokenizer: any ServerDiffusionTokenizer { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public var vaeEncoder: Optional<any ServerDiffusionVAEEncoder> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var anfrEncoder: Optional<any ServerDiffusionANFREncoder> { get { return nil } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var safetyBaseModel: Optional<any LLMModel> { get { return nil } }
    public var safetyImageTokenizer: Optional<ImageTokenizer> { get { return nil } }
    public var safetyPostprocessorAdapter: Optional<any LLMAdapter> { get { return nil } }
    public var vaeDecoder: any ServerDiffusionVAEDecoder { get { fatalError() } }
    public static func ==(arg1: ServerDiffusionBundle, arg2: ServerDiffusionBundle) -> Bool { return false }
    public var synthid: Optional<any ServerDiffusionSynthID> { get { return nil } }
}
public protocol ServerDiffusionBundleProtocol {
}
public protocol ServerDiffusionImageTokenizer {
}
public struct ServerDiffusionImageTokenizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionImageTokenizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionImageTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: ServerDiffusionImageTokenizerBase, arg2: ServerDiffusionImageTokenizerBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionNoisePredictor {
}
public struct ServerDiffusionNoisePredictorAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionNoisePredictorAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionNoisePredictorBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: ServerDiffusionNoisePredictorBase, arg2: ServerDiffusionNoisePredictorBase) -> Bool { return false }
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionSynthID {
}
public struct ServerDiffusionSynthIDAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionSynthIDAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionSynthIDBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: ServerDiffusionSynthIDBase, arg2: ServerDiffusionSynthIDBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionTextEncoder {
}
public struct ServerDiffusionTextEncoderAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionTextEncoderAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionTextEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: ServerDiffusionTextEncoderBase, arg2: ServerDiffusionTextEncoderBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionTokenizer {
}
public struct ServerDiffusionTokenizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionTokenizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: ServerDiffusionTokenizerBase, arg2: ServerDiffusionTokenizerBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct ServerDiffusionV10Bundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func build() throws -> ServerDiffusionV10Bundle { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func textencoder(arg1: Optional<any ServerDiffusionTextEncoder>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func noisePredictor(arg1: Optional<any ServerDiffusionNoisePredictor>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var textencoder: Optional<any ServerDiffusionTextEncoder> { get { return nil } set {} }
        public func autoencoder(arg1: Optional<any ServerDiffusionAutoEncoder>) -> Builder { fatalError() }
        public var autoencoder: Optional<any ServerDiffusionAutoEncoder> { get { return nil } set {} }
        public var noisePredictor: Optional<any ServerDiffusionNoisePredictor> { get { return nil } set {} }
        public var tokenizer: Optional<any ServerDiffusionTokenizer> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func tokenizer(arg1: Optional<any ServerDiffusionTokenizer>) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (ServerDiffusionV10Bundle.Builder) throws -> ()) throws {}
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: ServerDiffusionV10Bundle, arg2: ServerDiffusionV10Bundle) -> Bool { return false }
    public var autoencoder: any ServerDiffusionAutoEncoder { get { fatalError() } }
    public var noisePredictor: any ServerDiffusionNoisePredictor { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<ServerDiffusionV10Bundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var textencoder: any ServerDiffusionTextEncoder { get { fatalError() } }
    public var tokenizer: any ServerDiffusionTokenizer { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
}
public protocol ServerDiffusionV10BundleProtocol {
}
public struct ServerDiffusionV11_1Bundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var safetyAdapterMiscSafety: Optional<any LLMAdapter> { get { return nil } set {} }
        public func safetyTokenizer(arg1: Optional<Tokenizer>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func safetyAdapterMiscSafety(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var noisePredictor: Optional<any ServerDiffusionNoisePredictor> { get { return nil } set {} }
        public var vaeDecoder: Optional<any ServerDiffusionVAEDecoder> { get { return nil } set {} }
        public func tokenizer(arg1: Optional<any ServerDiffusionTokenizer>) -> Builder { fatalError() }
        public var safetyAdapterPromptRewrite: Optional<any LLMAdapter> { get { return nil } set {} }
        public var vaeEncoder: Optional<any ServerDiffusionVAEEncoder> { get { return nil } set {} }
        public func vaeDecoder(arg1: Optional<any ServerDiffusionVAEDecoder>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var safetyBaseModel: Optional<any LLMModel> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func noisePredictor(arg1: Optional<any ServerDiffusionNoisePredictor>) -> Builder { fatalError() }
        public func build() throws -> ServerDiffusionV11_1Bundle { fatalError() }
        public var anfrEncoder: Optional<any ServerDiffusionANFREncoder> { get { return nil } set {} }
        public var safetyImageTokenizer: Optional<ImageTokenizer> { get { return nil } set {} }
        public func textencoder(arg1: Optional<any ServerDiffusionTextEncoder>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func safetyBaseModel(arg1: Optional<any LLMModel>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func safetyAdapterPromptRewrite(arg1: Optional<any LLMAdapter>) -> Builder { fatalError() }
        public var alphaMaskDecoder: Optional<any ServerDiffusionAlphaMaskDecoder> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func diffusionAdapter(arg1: Optional<any ServerDiffusionAdapter>) -> Builder { fatalError() }
        public var textencoder: Optional<any ServerDiffusionTextEncoder> { get { return nil } set {} }
        public func alphaMaskDecoder(arg1: Optional<any ServerDiffusionAlphaMaskDecoder>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var tokenizer: Optional<any ServerDiffusionTokenizer> { get { return nil } set {} }
        public func anfrEncoder(arg1: Optional<any ServerDiffusionANFREncoder>) -> Builder { fatalError() }
        public func safetyImageTokenizer(arg1: Optional<ImageTokenizer>) -> Builder { fatalError() }
        public func vaeEncoder(arg1: Optional<any ServerDiffusionVAEEncoder>) -> Builder { fatalError() }
        public var diffusionAdapter: Optional<any ServerDiffusionAdapter> { get { return nil } set {} }
        public var safetyTokenizer: Optional<Tokenizer> { get { return nil } set {} }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (ServerDiffusionV11_1Bundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public var id: ResourceBundleIdentifier<ServerDiffusionV11_1Bundle> { get { fatalError() } }
    public var textencoder: any ServerDiffusionTextEncoder { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public var noisePredictor: any ServerDiffusionNoisePredictor { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var alphaMaskDecoder: Optional<any ServerDiffusionAlphaMaskDecoder> { get { return nil } }
    public var anfrEncoder: Optional<any ServerDiffusionANFREncoder> { get { return nil } }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var safetyAdapterMiscSafety: Optional<any LLMAdapter> { get { return nil } }
    public var safetyAdapterPromptRewrite: Optional<any LLMAdapter> { get { return nil } }
    public var safetyBaseModel: Optional<any LLMModel> { get { return nil } }
    public var safetyImageTokenizer: Optional<ImageTokenizer> { get { return nil } }
    public var safetyTokenizer: Optional<Tokenizer> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public var vaeDecoder: any ServerDiffusionVAEDecoder { get { fatalError() } }
    public var vaeEncoder: Optional<any ServerDiffusionVAEEncoder> { get { return nil } }
    public static func ==(arg1: ServerDiffusionV11_1Bundle, arg2: ServerDiffusionV11_1Bundle) -> Bool { return false }
    public var diffusionAdapter: Optional<any ServerDiffusionAdapter> { get { return nil } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var tokenizer: any ServerDiffusionTokenizer { get { fatalError() } }
}
public protocol ServerDiffusionV11_1BundleProtocol {
}
public protocol ServerDiffusionVAEDecoder {
}
public struct ServerDiffusionVAEDecoderAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionVAEDecoderAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionVAEDecoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: ServerDiffusionVAEDecoderBase, arg2: ServerDiffusionVAEDecoderBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServerDiffusionVAEEncoder {
}
public struct ServerDiffusionVAEEncoderAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionVAEEncoderAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ServerDiffusionVAEEncoderBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public static func ==(arg1: ServerDiffusionVAEEncoderBase, arg2: ServerDiffusionVAEEncoderBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol ServiceConnectionProtocol {
    func call(arg1: (Any) -> GenericA) throws -> GenericA
    func call(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) throws -> GenericA
    associatedtype Service
    func call(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) async throws -> GenericA
}
public enum Sideload: Hashable, Sendable {
    case _mock
    public static var defaultSideloadAssetsURL: URL { get { fatalError() } }
    public static func addResourceBundle(container: ResourceBundleContainer, to: URL) throws -> () {}
    public static var defaultSideloadResourcesURL: URL { get { fatalError() } }
    public static func fetchResourceBundles(at: URL, resources: Array<any CatalogResource>) throws -> Array<any ResourceBundle_P> { return [] }
    public static func removeResourceBundle(for: String, from: URL) throws -> () {}
    public static func addResource(container: ResourceContainer, to: URL) throws -> () {}
    public static func removeResource(for: String, from: URL) throws -> () {}
    public static func fetchResources(at: URL) throws -> Array<any CatalogResource> { return [] }
}
public class SiriResourceAvailabilityInfo {
    public init(coder: NSCoder) {}
    public init(enoughStorage: Bool, diskSpaceRequired: Int64) {}
    public init() {}
    public var description: String { get { return "" } }
    public var diskSpaceRequired: Int64 { get { return 0 } set {} }
    public var enoughStorage: Bool { get { return false } set {} }
    public static var enoughStorageKey: String { get { return "" } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func encode(with: NSCoder) -> () {}
    public static var diskSpaceRequiredKey: String { get { return "" } }
}
public protocol SpeechDetokenizer {
}
public struct SpeechDetokenizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SpeechDetokenizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SpeechDetokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: SpeechDetokenizerBase, arg2: SpeechDetokenizerBase) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol SpeechTokenizer {
}
public struct SpeechTokenizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SpeechTokenizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct SpeechTokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: SpeechTokenizerBase, arg2: SpeechTokenizerBase) -> Bool { return false }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public class StatusResponse {
    public init(status: ResourceStatus) {}
    public init(coder: NSCoder) {}
    public init() {}
    public func encode(with: NSCoder) -> () {}
    public var status: ResourceStatus { get { fatalError() } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
}
public struct StopToken: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public static func ==(arg1: StopToken, arg2: StopToken) -> Bool { return false }
    public var intValue: Optional<Int> { get { return nil } set {} }
    public var stringValue: Optional<String> { get { return nil } set {} }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public class SubscriptionManagerProvider {
    public init() {}
    public func updateAssets(subscribers: Dictionary<String, Array<String>>, detailedProgress: Optional<(AssetSetStatus) -> ()>) async -> () {}
}
public protocol SubscriptionManagerProviding {
    func updateAssets(subscribers: Dictionary<String, Array<String>>, detailedProgress: Optional<(AssetSetStatus) -> ()>) async -> ()
}
public enum SupportedArgument<A>: Hashable, Sendable {
    case _mock
    public static func ==(arg1: SupportedArgument<GenericA>, arg2: SupportedArgument<GenericA>) -> Bool { return false }
}
public struct SupportedLanguagesAndRegions: Codable, Hashable, Sendable {
    public struct SupportedLanguageAndRegion: Codable, Hashable, Sendable {
        public var language: SupportedArgument<Locale.LanguageCode> { get { fatalError() } }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public var supportedLanguagesAndRegions: Array<SupportedLanguagesAndRegions.SupportedLanguageAndRegion> { get { return [] } }
    public static func ==(arg1: SupportedLanguagesAndRegions, arg2: SupportedLanguagesAndRegions) -> Bool { return false }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public enum Tag: Hashable, Sendable {
    case _mock
}
public enum TestCatalog: Hashable, Sendable {
    public enum Resource: Hashable, Sendable {
        public enum LLM: Hashable, Sendable {
            public enum Model: Hashable, Sendable {
                case _mock
                public static func TestAsset2(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func TestAsset1() -> any AssetBackedLLMModel { fatalError() }
                public static func TestAsset1(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func TestAsset2() -> any AssetBackedLLMModel { fatalError() }
                public static func TestAsset3(variant: String) throws -> any AssetBackedLLMModel { fatalError() }
                public static func TestAsset3() -> any AssetBackedLLMModel { fatalError() }
            }
            case _mock
        }
        public struct ResourceMetadata: Codable, Hashable, Sendable {
            public init(from decoder: any Decoder) throws {}
            public func encode(to encoder: Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        case _mock
        public static var allResourceConfigurationIDs: Set<String> { get { return [] } }
        public static var allResources: Array<any CatalogResource> { get { return [] } }
        public static var blockedInSensitiveRegionVariants: Dictionary<String, Array<String>> { get { return [:] } }
        public static var variantResolverMappings: Dictionary<String, Dictionary<String, Dictionary<ResourceVariantResolverArgument, Array<String>>>> { get { return [:] } }
        public static var variants: Dictionary<String, Array<String>> { get { return [:] } }
        public static func fetchAllResources() -> Array<any CatalogResource> { return [] }
        public static var allResourceConfigurationIDsAllPlatforms: Set<String> { get { return [] } }
        public static var resourceMetadata: Dictionary<String, ResourceMetadata> { get { return [:] } }
        public static var usageAliasValuesForUsageAlias: Dictionary<String, Array<String>> { get { return [:] } }
        public static var usageTypesForAssetSet: Dictionary<String, Array<String>> { get { return [:] } }
    }
    case _mock
}
public protocol ThirdPartyProviderConfiguration {
}
public struct ThirdPartyProviderConfigurationAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ThirdPartyProviderConfigurationAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public init(modelVersion: Optional<String>) {}
    public var modelVersion: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct ThirdPartyProviderConfigurationBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: ThirdPartyProviderConfigurationBase, arg2: ThirdPartyProviderConfigurationBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public class TokenBucketInMemoryRateLimiter {
    public init(interval: Double, dateProvider: any DateProviding) {}
    public func shouldAllow(key: String) -> (allowed: Bool, lastAllowed: Optional<Date>) { fatalError() }
}
public protocol TokenGenerationResource {
}
public protocol TokenInputDenyList {
}
public struct TokenInputDenyListAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenInputDenyListAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenInputDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: TokenInputDenyListBase, arg2: TokenInputDenyListBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct TokenInputDenyListBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func tokenInputDenyList(arg1: Optional<TokenInputDenyList>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var embeddingDenyList: Optional<EmbeddingDenyList> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func embeddingDenyList(arg1: Optional<EmbeddingDenyList>) -> Builder { fatalError() }
        public func build() throws -> TokenInputDenyListBundle { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var tokenInputDenyList: Optional<TokenInputDenyList> { get { return nil } set {} }
    }
    public init(configurationIdentifier: String, build: (TokenInputDenyListBundle.Builder) throws -> ()) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(from: Decoder) throws {}
    public var configurationIdentifier: String { get { return "" } }
    public var embeddingDenyList: EmbeddingDenyList { get { fatalError() } }
    public static func ==(arg1: TokenInputDenyListBundle, arg2: TokenInputDenyListBundle) -> Bool { return false }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<TokenInputDenyListBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var tokenInputDenyList: TokenInputDenyList { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var rawID: String { get { return "" } }
}
public protocol TokenInputDenyListBundleProtocol {
}
public struct TokenInputDenyListWithDefaultsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var defaultDenyList: Optional<ModelConfigurationReplacement> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var embeddingDenyList: Optional<EmbeddingDenyList> { get { return nil } set {} }
        public func tokenInputDenyList(arg1: Optional<TokenInputDenyList>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var tokenInputDenyList: Optional<TokenInputDenyList> { get { return nil } set {} }
        public func defaultDenyList(arg1: Optional<ModelConfigurationReplacement>) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func build() throws -> TokenInputDenyListWithDefaultsBundle { fatalError() }
        public func embeddingDenyList(arg1: Optional<EmbeddingDenyList>) -> Builder { fatalError() }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (TokenInputDenyListWithDefaultsBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public var embeddingDenyList: EmbeddingDenyList { get { fatalError() } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func hash(into: inout Hasher) -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public static func ==(arg1: TokenInputDenyListWithDefaultsBundle, arg2: TokenInputDenyListWithDefaultsBundle) -> Bool { return false }
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var defaultDenyList: ModelConfigurationReplacement { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<TokenInputDenyListWithDefaultsBundle> { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var tokenInputDenyList: TokenInputDenyList { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
}
public protocol TokenInputDenyListWithDefaultsBundleProtocol {
}
public protocol TokenOutputDenyList {
}
public struct TokenOutputDenyListAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenOutputDenyListAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenOutputDenyListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: TokenOutputDenyListBase, arg2: TokenOutputDenyListBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct TokenOutputDenyListBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func build() throws -> TokenOutputDenyListBundle { fatalError() }
        public var embeddingDenyList: Optional<EmbeddingDenyList> { get { return nil } set {} }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public var tokenOutputDenyList: Optional<TokenOutputDenyList> { get { return nil } set {} }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func tokenOutputDenyList(arg1: Optional<TokenOutputDenyList>) -> Builder { fatalError() }
        public func embeddingDenyList(arg1: Optional<EmbeddingDenyList>) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (TokenOutputDenyListBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public var id: ResourceBundleIdentifier<TokenOutputDenyListBundle> { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: TokenOutputDenyListBundle, arg2: TokenOutputDenyListBundle) -> Bool { return false }
    public var configurationIdentifier: String { get { return "" } }
    public var hashValue: Int { get { return 0 } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var embeddingDenyList: EmbeddingDenyList { get { fatalError() } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var tokenOutputDenyList: TokenOutputDenyList { get { fatalError() } }
}
public protocol TokenOutputDenyListBundleProtocol {
}
public struct TokenOutputDenyListWithDefaultsBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func build() throws -> TokenOutputDenyListWithDefaultsBundle { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public var embeddingDenyList: Optional<EmbeddingDenyList> { get { return nil } set {} }
        public func embeddingDenyList(arg1: Optional<EmbeddingDenyList>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func tokenOutputDenyList(arg1: Optional<TokenOutputDenyList>) -> Builder { fatalError() }
        public var defaultDenyList: Optional<ModelConfigurationReplacement> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func defaultDenyList(arg1: Optional<ModelConfigurationReplacement>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var tokenOutputDenyList: Optional<TokenOutputDenyList> { get { return nil } set {} }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
    }
    public init(configurationIdentifier: String, build: (TokenOutputDenyListWithDefaultsBundle.Builder) throws -> ()) throws {}
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public var id: ResourceBundleIdentifier<TokenOutputDenyListWithDefaultsBundle> { get { fatalError() } }
    public static func ==(arg1: TokenOutputDenyListWithDefaultsBundle, arg2: TokenOutputDenyListWithDefaultsBundle) -> Bool { return false }
    public var rawID: String { get { return "" } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var defaultDenyList: ModelConfigurationReplacement { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var tokenOutputDenyList: TokenOutputDenyList { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var embeddingDenyList: EmbeddingDenyList { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
}
public protocol TokenOutputDenyListWithDefaultsBundleProtocol {
}
public protocol TokenOutputRetainList {
}
public struct TokenOutputRetainListAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenOutputRetainListAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenOutputRetainListBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: TokenOutputRetainListBase, arg2: TokenOutputRetainListBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct TokenOutputRetainListBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public func build() throws -> TokenOutputRetainListBundle { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func tokenOutputRetainList(arg1: Optional<TokenOutputRetainList>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var tokenOutputRetainList: Optional<TokenOutputRetainList> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (TokenOutputRetainListBundle.Builder) throws -> ()) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var tokenOutputRetainList: TokenOutputRetainList { get { fatalError() } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: TokenOutputRetainListBundle, arg2: TokenOutputRetainListBundle) -> Bool { return false }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<TokenOutputRetainListBundle> { get { fatalError() } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
}
public protocol TokenOutputRetainListBundleProtocol {
}
public protocol Tokenizer {
}
public struct TokenizerAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenizerAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public init(substitutionTextForInputTokenText: Optional<Dictionary<String, String>>, substitutionTextForOutputTokenText: Optional<Dictionary<String, String>>) {}
    public var substitutionTextForInputTokenText: Optional<Dictionary<String, String>> { get { return nil } }
    public func encode(to: Encoder) throws -> () {}
    public var substitutionTextForOutputTokenText: Optional<Dictionary<String, String>> { get { return nil } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TokenizerBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public init(inner: ManagedResourceBase) {}
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var inner: ManagedResourceBase { get { fatalError() } }
    public var variant: String { get { return "" } }
    public static func ==(arg1: TokenizerBase, arg2: TokenizerBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public protocol TranslateFMAsset {
}
public struct TranslateFMAssetAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TranslateFMAssetAssetMetadata: Codable, Hashable, Sendable {
    public init(modelVersion: Optional<String>) {}
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var modelVersion: Optional<String> { get { return nil } }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct TranslateFMAssetBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var variant: String { get { return "" } }
    public static func ==(arg1: TranslateFMAssetBase, arg2: TranslateFMAssetBase) -> Bool { return false }
    public var hashValue: Int { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct UseCase: Codable, Hashable, Sendable {
    public enum AssetRequired: Hashable, Sendable {
        case _mock
        public func encode(to: Encoder) throws -> () {}
        public func hash(into: inout Hasher) -> () {}
        public var hashValue: Int { get { return 0 } }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
    }
    public init(from: Decoder) throws {}
    public init(identifier: UseCaseIdentifier, assetRequired: UseCase.AssetRequired) {}
    public static func ==(arg1: UseCase, arg2: UseCase) -> Bool { return false }
    public var assetRequired: UseCase.AssetRequired { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var identifier: UseCaseIdentifier { get { fatalError() } }
    public var isOptional: Bool { get { return false } }
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
}
public class UseCaseAvailabilityInfo {
    public init(coder: NSCoder) {}
    public init() {}
    public init(resourcesReady: Bool, enoughStorage: Bool, diskSpaceRequired: UInt64) {}
    public var description: String { get { return "" } }
    public var diskSpaceRequired: UInt64 { get { return 0 } set {} }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public func encode(with: NSCoder) -> () {}
    public var enoughStorage: Bool { get { return false } set {} }
    public static var enoughStorageKey: String { get { return "" } }
    public var resourcesReady: Bool { get { return false } set {} }
}
public struct UseCaseDownloadProgress: Codable, Hashable, Sendable {
    public var assetSubscriptionStatus: AssetSubscriptionStatus { get { fatalError() } }
    public var bytesDownloaded: UInt { get { return 0 } }
    public var progress: Double { get { return 0 } }
    public var totalBytes: UInt { get { return 0 } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct UseCaseIdentifier: Codable, Hashable, Sendable {
    public struct DownloadCondition: Codable, Hashable, Sendable {
        public enum Identifier: Hashable, Sendable {
            case _mock
        }
        public init(identifier: UseCaseIdentifier.DownloadCondition.Identifier, sql: String) {}
        public var identifier: Identifier { get { fatalError() } }
        public var sql: String { get { return "" } }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum Metadata: Hashable, Sendable {
        public enum Availability: Hashable, Sendable {
            case _mock
            public static func strictAssetAvailability(for: UseCaseIdentifier) -> Bool { return false }
            public static func externalModelProviders(for: UseCaseIdentifier) -> Array<ExternalModelProvider> { return [] }
        }
        public enum Configuration: Hashable, Sendable {
            case _mock
            public static func downloadCondition(for: UseCaseIdentifier) -> Optional<UseCaseIdentifier.DownloadCondition> { return nil }
        }
        public enum Disablement: Hashable, Sendable {
            case _mock
            public static func disabledRegions(for: UseCaseIdentifier) -> Optional<Array<String>> { return nil }
            public static func disabledLanguages(for: UseCaseIdentifier) -> Optional<Array<String>> { return nil }
        }
        public enum Enablement: Hashable, Sendable {
            public struct Criteria: Codable, Hashable, Sendable {
                public static var allPossibleCriteria: Array<Self> { get { return [] } }
                public var argumentDictionaryRepresentation: Dictionary<String, String> { get { return [:] } }
                public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
                public var hashValue: Int { get { return 0 } }
                public var language: Locale.LanguageCode { get { fatalError() } }
                public func hash(into: inout Hasher) -> () {}
                public init(from decoder: any Decoder) throws {}
                public func encode(to encoder: Encoder) throws { fatalError() }
            }
            case _mock
            public static func enabledCriteria(for: UseCaseIdentifier) -> Optional<Array<Criteria>> { return nil }
        }
        public enum Platform: Hashable, Sendable {
            case _mock
            public static func isAvailableOnCurrentPlatform(arg1: UseCaseIdentifier, isSensitiveRegion: Bool) -> Bool { return false }
            public static func isAvailableOnAllPlatforms(arg1: UseCaseIdentifier) -> Bool { return false }
            public static func isAvailableOnCurrentPlatformWithEnforcement(arg1: UseCaseIdentifier, isSensitiveRegion: Bool) -> Bool { return false }
            public static func platformFilteredUseCases(isSensitiveRegion: Bool) -> Array<UseCaseIdentifier> { return [] }
        }
        public enum Safety: Hashable, Sendable {
            case _mock
            public static func isDonationBlocked(for: UseCaseIdentifier) -> Bool { return false }
        }
        case _mock
    }
    public init(rawValue: String) {}
    public init(from: Decoder) throws {}
    public static func ==(arg1: UseCaseIdentifier, arg2: UseCaseIdentifier) -> Bool { return false }
    public static var aSRNaturalDictation: UseCaseIdentifier { get { fatalError() } }
    public static var accessibilityLiveRecognition: UseCaseIdentifier { get { fatalError() } }
    public static var accessibilityMagnifier: UseCaseIdentifier { get { fatalError() } }
    public static var actionSmartNaming: UseCaseIdentifier { get { fatalError() } }
    public static var automatedAutogradingVisualGeneration: UseCaseIdentifier { get { fatalError() } }
    public static var automatedTaggingGeneric: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsProShortcutsAskAFMActionAutomatedImage: UseCaseIdentifier { get { fatalError() } }
    public static var creatorStudioVisualGenerationUpres: UseCaseIdentifier { get { fatalError() } }
    public static var financialInsights: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceOutro: UseCaseIdentifier { get { fatalError() } }
    public static var fullPayloadCorrection: UseCaseIdentifier { get { fatalError() } }
    public static var generativeAssistantKnowledgeFallback: UseCaseIdentifier { get { fatalError() } }
    public static var messagesSmartReply: UseCaseIdentifier { get { fatalError() } }
    public static var safariClusterValidation: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMessagesReply: UseCaseIdentifier { get { fatalError() } }
    public static var textUnderstandingBackgroundImagePrompt: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelPersonSegmentation: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundAnimationStyleScribble: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundSketchPersonalizedSketch: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImageCreatorAPICreationBase3p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundImageWand1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundSheetAPICreationBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationKeyboardEmojiGenerator: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPhotosEditUpres1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPostersOutfill1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenContactsPostersCreationPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public static var aSRDictationDescribeYourEdit: UseCaseIdentifier { get { fatalError() } }
    public static var accessibilityImageDescriptions: UseCaseIdentifier { get { fatalError() } }
    public static var accessibilityImageExplorer: UseCaseIdentifier { get { fatalError() } }
    public static var accessibilityReaderAI: UseCaseIdentifier { get { fatalError() } }
    public static var allCases: Array<UseCaseIdentifier> { get { return [] } }
    public static var answerSynthesisServerV2: UseCaseIdentifier { get { fatalError() } }
    public static var answerSynthesisServerV2Experiment1: UseCaseIdentifier { get { fatalError() } }
    public static var answerSynthesisServerV2Experiment2: UseCaseIdentifier { get { fatalError() } }
    public static var answerSynthesisServerV2Experiment3: UseCaseIdentifier { get { fatalError() } }
    public static var answerSynthesisServerV2Experiment4: UseCaseIdentifier { get { fatalError() } }
    public static var answerSynthesisServerV2Experiment5: UseCaseIdentifier { get { fatalError() } }
    public static var answerSynthesisServerV2ShortOutput: UseCaseIdentifier { get { fatalError() } }
    public static var antiSpoofingAgeEstimation: UseCaseIdentifier { get { fatalError() } }
    public static var antiSpoofingAgeVerification: UseCaseIdentifier { get { fatalError() } }
    public static var appleDeviceTracking: UseCaseIdentifier { get { fatalError() } }
    public static var askMontaraAction: UseCaseIdentifier { get { fatalError() } }
    public static var autoTagger: UseCaseIdentifier { get { fatalError() } }
    public static var automatedAutogradingGenmoji: UseCaseIdentifier { get { fatalError() } }
    public static var automatedAutogradingSummarizationEmail: UseCaseIdentifier { get { fatalError() } }
    public static var automatedRemindersAutoCategorization: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsProShortcutsAskAFMAction: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsProShortcutsAskAFMActionAutomated: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsProShortcutsAskAFMActionImage: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsZapFMCLI: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsZapShortcutsAskAFMAction: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsZapShortcutsAskAFMActionAutomated: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsZapShortcutsAskAFMActionAutomatedImage: UseCaseIdentifier { get { fatalError() } }
    public static var automationToolsZapShortcutsAskAFMActionImage: UseCaseIdentifier { get { fatalError() } }
    public static var calendarMagicComposeBackwardPass: UseCaseIdentifier { get { fatalError() } }
    public static var classificationClassifyMailMessage: UseCaseIdentifier { get { fatalError() } }
    public static var classificationClassifyTextMessage: UseCaseIdentifier { get { fatalError() } }
    public static var classificationClassifyTextMessageThread: UseCaseIdentifier { get { fatalError() } }
    public static var classificationClassifyUserNotification: UseCaseIdentifier { get { fatalError() } }
    public static var conversationTitleSummarization: UseCaseIdentifier { get { fatalError() } }
    public static var coreMotionCrashDetection: UseCaseIdentifier { get { fatalError() } }
    public static var coreMotionFitness: UseCaseIdentifier { get { fatalError() } }
    public static var creatorStudioVisualGenerationInfill: UseCaseIdentifier { get { fatalError() } }
    public static var creatorStudioVisualGenerationOutfill: UseCaseIdentifier { get { fatalError() } }
    public static var deviceExpertContextualRewrite: UseCaseIdentifier { get { fatalError() } }
    public static var fMCLIPCCAppleInternal: UseCaseIdentifier { get { fatalError() } }
    public static var fMCLIPCCPublic: UseCaseIdentifier { get { fatalError() } }
    public static var fMFrameworkOnDeviceAppleInternal: UseCaseIdentifier { get { fatalError() } }
    public static var fMFrameworkOnDevicePublic: UseCaseIdentifier { get { fatalError() } }
    public static var fMFrameworkPCCAppleInternal: UseCaseIdentifier { get { fatalError() } }
    public static var fMFrameworkPCCDeveloper: UseCaseIdentifier { get { fatalError() } }
    public static var fMFrameworkPCCPublic: UseCaseIdentifier { get { fatalError() } }
    public static var fMFrameworkPCCTestFlight: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceBreakthrough: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceCompanionBreakthrough: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceCompanionIntro: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceCompanionOutro: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceCompanionSplit: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceIntro: UseCaseIdentifier { get { fatalError() } }
    public static var fitnessIntelligenceWorkoutVoiceSplit: UseCaseIdentifier { get { fatalError() } }
    public static var foundationModels: UseCaseIdentifier { get { fatalError() } }
    public static var foundationModelsPrototyping: UseCaseIdentifier { get { fatalError() } }
    public static var gVICC: UseCaseIdentifier { get { fatalError() } }
    public static var generativeAssistantComposition: UseCaseIdentifier { get { fatalError() } }
    public static var generativeAssistantKnowledge: UseCaseIdentifier { get { fatalError() } }
    public static var generativeAssistantMediaQA: UseCaseIdentifier { get { fatalError() } }
    public static var generativeAssistantVisualIntelligenceCamera: UseCaseIdentifier { get { fatalError() } }
    public static var generativeEditCleanUp: UseCaseIdentifier { get { fatalError() } }
    public static var generativeLearningPlatformInsightAgents: UseCaseIdentifier { get { fatalError() } }
    public static var genmojiEmojiKeywordExtraction: UseCaseIdentifier { get { fatalError() } }
    public static var handwritingSynthesis: UseCaseIdentifier { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public static var homeKitCaptionsCamera: UseCaseIdentifier { get { fatalError() } }
    public static var homeKitDocumentationSearch: UseCaseIdentifier { get { fatalError() } }
    public static var homeKitSearchCamera: UseCaseIdentifier { get { fatalError() } }
    public static var homeKitSearchDocumentation: UseCaseIdentifier { get { fatalError() } }
    public static var homeKitSummaryNotifications: UseCaseIdentifier { get { fatalError() } }
    public static var iCloudMailEventExtraction: UseCaseIdentifier { get { fatalError() } }
    public static var iCloudMailOrderBundling: UseCaseIdentifier { get { fatalError() } }
    public static var iCloudMailSemanticSearch: UseCaseIdentifier { get { fatalError() } }
    public var id: String { get { return "" } }
    public static var imagePlaygroundEditSuggestions: UseCaseIdentifier { get { fatalError() } }
    public static var imageUnderstandingSTXMultimodal: UseCaseIdentifier { get { fatalError() } }
    public static var intelligenceThirdPartyProviderConfiguration: UseCaseIdentifier { get { fatalError() } }
    public static var journalingFollowUpPrompts: UseCaseIdentifier { get { fatalError() } }
    public static var machineTranslation: UseCaseIdentifier { get { fatalError() } }
    public static var machineTranslationMessagesTranslation: UseCaseIdentifier { get { fatalError() } }
    public static var machineTranslationPublicAPITranslate: UseCaseIdentifier { get { fatalError() } }
    public static var mediaAnalysisEmbeddingMigrationMd7: UseCaseIdentifier { get { fatalError() } }
    public static var mediaAnalysisEmbeddingMigrationMd8: UseCaseIdentifier { get { fatalError() } }
    public static var mediaAnalysisEmbeddingMigrationMd9: UseCaseIdentifier { get { fatalError() } }
    public static var mediaAnalysisVideoCaption: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationAssetCuration: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationAssetCurationOutlier: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationAutonamingMessages: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationGlobalTraits: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationLibraryUnderstanding: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationPromptSuggestions: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationQueryUnderstanding: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationStoryteller: UseCaseIdentifier { get { fatalError() } }
    public static var memoryCreationTitle: UseCaseIdentifier { get { fatalError() } }
    public static var musicConcertsRanking: UseCaseIdentifier { get { fatalError() } }
    public static var pCCInternalTest: UseCaseIdentifier { get { fatalError() } }
    public static var paperKitImageGeneration: UseCaseIdentifier { get { fatalError() } }
    public static var passwordsChangePasswordForMe: UseCaseIdentifier { get { fatalError() } }
    public static var passwordsChangePasswordForMeSupervisor: UseCaseIdentifier { get { fatalError() } }
    public static var photosSemanticSearch: UseCaseIdentifier { get { fatalError() } }
    public static var remindersIntelligentReminderExtraction: UseCaseIdentifier { get { fatalError() } }
    public static var safariMagicExtensions: UseCaseIdentifier { get { fatalError() } }
    public static var safariMagicExtensionsAppStoreSearchTerms: UseCaseIdentifier { get { fatalError() } }
    public static var safariMagicExtensionsCodeReview: UseCaseIdentifier { get { fatalError() } }
    public static var safariMagicExtensionsCreationPolicy: UseCaseIdentifier { get { fatalError() } }
    public static var safariMagicExtensionsRefinement: UseCaseIdentifier { get { fatalError() } }
    public static var safariNotifyMeWhen: UseCaseIdentifier { get { fatalError() } }
    public static var safariNotifyMeWhenNodeSelection: UseCaseIdentifier { get { fatalError() } }
    public static var safariNotifyMeWhenShortcuts: UseCaseIdentifier { get { fatalError() } }
    public static var safariNotifyMeWhenSuggestions: UseCaseIdentifier { get { fatalError() } }
    public static var safariNotifyMeWhenValidatePersonalPrivacyPolicy: UseCaseIdentifier { get { fatalError() } }
    public static var safariNotifyMeWhenValidatePrivateBrowsingAccessibility: UseCaseIdentifier { get { fatalError() } }
    public static var safariSafeBrowsing: UseCaseIdentifier { get { fatalError() } }
    public static var safariURLPhishingClassification: UseCaseIdentifier { get { fatalError() } }
    public static var safetyCodeIntelligence: UseCaseIdentifier { get { fatalError() } }
    public static var safetyNSFWClassification: UseCaseIdentifier { get { fatalError() } }
    public static var safetyOutputClassification: UseCaseIdentifier { get { fatalError() } }
    public static var searchQueryUnderstandingServerV2: UseCaseIdentifier { get { fatalError() } }
    public static var secureAnalytics: UseCaseIdentifier { get { fatalError() } }
    public static var settingsAppleIntelligence: UseCaseIdentifier { get { fatalError() } }
    public static var settingsAppleIntelligenceAnalytics: UseCaseIdentifier { get { fatalError() } }
    public static var settingsAppleIntelligenceDiffusion: UseCaseIdentifier { get { fatalError() } }
    public static var settingsAppleIntelligenceDiffusionAnalytics: UseCaseIdentifier { get { fatalError() } }
    public static var settingsAppleIntelligencePartnerChatGPT: UseCaseIdentifier { get { fatalError() } }
    public static var settingsAppleIntelligencePrivateCloudCompute: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsAskAFMAction: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsAskAFMAction3B: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsAskAFMActionAutomated: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsAskAFMActionAutomatedImage: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsAskAFMActionImage: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsGenerativeShortcuts: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsPlanner: UseCaseIdentifier { get { fatalError() } }
    public static var shortcutsUIGrounding: UseCaseIdentifier { get { fatalError() } }
    public static var siriActionValidator: UseCaseIdentifier { get { fatalError() } }
    public static var siriAppleIntelligence: UseCaseIdentifier { get { fatalError() } }
    public static var siriConversation: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationGenerativePlayground: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeUserNotificationThread: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMailReplyLongFormRewrite: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionOpenEndedSchema: UseCaseIdentifier { get { fatalError() } }
    public static var textUnderstandingTextPersonExtraction: UseCaseIdentifier { get { fatalError() } }
    public static var viStructuredExtractionHealthData: UseCaseIdentifier { get { fatalError() } }
    public static var viStructuredExtractionReceipt: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelRecognizeAnimals: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundEmojiEmoji: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundEmojiPersonalizedEmoji: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundIllustrationIllustration: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundSketchSketch: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenmojiBase3p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenmojiPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImageCreatorAPIImageWand1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundSheetAPICreationPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenContactsPostersCreationBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceCameraVisualLookup: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceStructuredExtractionAddToContacts: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceSuggestedQuestions: UseCaseIdentifier { get { fatalError() } }
    public static var writingToolsMailProfileCreation: UseCaseIdentifier { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static var siriEnhancedSiriDisablement: UseCaseIdentifier { get { fatalError() } }
    public static var siriNLRouter: UseCaseIdentifier { get { fatalError() } }
    public static var siriPlanner: UseCaseIdentifier { get { fatalError() } }
    public static var siriPlannerAppInteract: UseCaseIdentifier { get { fatalError() } }
    public static var siriPlannerDirectResponseOutputGuardrail: UseCaseIdentifier { get { fatalError() } }
    public static var siriPlannerDirectResponseOutputGuardrailU18: UseCaseIdentifier { get { fatalError() } }
    public static var siriPromptInjectionClassifier: UseCaseIdentifier { get { fatalError() } }
    public static var siriTTSVoiceNatural: UseCaseIdentifier { get { fatalError() } }
    public static var siriTextSummarization: UseCaseIdentifier { get { fatalError() } }
    public static var siriUserExperienceAnalysis: UseCaseIdentifier { get { fatalError() } }
    public static var siriVisualIntelligence: UseCaseIdentifier { get { fatalError() } }
    public static var siriVoice: UseCaseIdentifier { get { fatalError() } }
    public static var siriVoice2: UseCaseIdentifier { get { fatalError() } }
    public static var smartActionsHoldAssistWaitTime: UseCaseIdentifier { get { fatalError() } }
    public static var spatialPhotosReliveBuiltin: UseCaseIdentifier { get { fatalError() } }
    public static var spatialPhotosReliveMain: UseCaseIdentifier { get { fatalError() } }
    public static var speechToSpeech: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationAccessibilityReader: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationBrailleAccessLiveCaptions: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationMagicPaper: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationNotesAudioTranscript: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationNotesAudioTranscriptOnDemand: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSafariReader: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSafariTabGroupTopic: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeMailMessage: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeMailMessageOnDemand: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeMailMessageThread: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeMailMessageThreadOnDemand: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeShortcuts: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeTextMessage: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeTextMessageThread: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationSummarizeUserNotification: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationTextAssistant: UseCaseIdentifier { get { fatalError() } }
    public static var summarizationVisualIntelligenceCamera: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionBulletsTransform: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionConciseTone: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionFriendlyTone: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMagicRewrite: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMailReply: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMailReplyLongFormBasic: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMailReplyQA: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMessagesAction: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionMessagesUserRequest: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionOpenEndedCompose: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionOpenEndedInteraction: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionOpenEndedTone: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionProfessionalTone: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionProofreadingReview: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionSuperAutofill: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionTablesTransform: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionTakeawaysTransform: UseCaseIdentifier { get { fatalError() } }
    public static var textCompositionTextExpert: UseCaseIdentifier { get { fatalError() } }
    public static var textUnderstandingMessagesSmartRepliesProfileExtraction: UseCaseIdentifier { get { fatalError() } }
    public static var textUnderstandingStructuredExtraction: UseCaseIdentifier { get { fatalError() } }
    public static var textUnderstandingTextEventExtraction: UseCaseIdentifier { get { fatalError() } }
    public static var translationSafetyAlerts: UseCaseIdentifier { get { fatalError() } }
    public static var translationSystemTextOndevice: UseCaseIdentifier { get { fatalError() } }
    public static var translationTranslateAppTextOndevice: UseCaseIdentifier { get { fatalError() } }
    public static var useCaseDisablement: UseCaseIdentifier { get { fatalError() } }
    public static var viContentClassifier: UseCaseIdentifier { get { fatalError() } }
    public static var viStructuredExtractionAddToCalendar: UseCaseIdentifier { get { fatalError() } }
    public static var viStructuredExtractionAddToContacts: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelDetectBarcode: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelFaceCaptureQuality: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelFaceLandmarks: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelForegroundInstanceSegmentation: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelHumanRectangles: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelMaskTracker: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelPersonInstanceSegmentation: UseCaseIdentifier { get { fatalError() } }
    public static var visionModelSmudgeDetection: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationADMPromptAnalyzer: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlayground: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundAnimationAnimation: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundAnimationPersonalizedAnimation: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundIllustrationPersonalizedIllustration: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundIllustrationStyleScribble: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundMessagesBackgroundMessagesBackgrounds: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenerativePlaygroundSketchStyleScribble: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenmojiBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationGenmojiPersonalized3p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImageCreatorAPICreationBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImageCreatorAPICreationPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImageCreatorAPICreationPersonalized3p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImageCreatorAPIImageWand3p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundCreationBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundCreationPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundCreationRevision1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundDirectManipulation1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundMessagesBackgrounds1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundMultimodalInputSafety: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundSheetAPICreationBase3p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundSheetAPICreationPersonalized3p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationImagePlaygroundSheetAPIImageWand1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationKeyboardEmojiGeneratorEmojiEmoji: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationKeyboardEmojiGeneratorEmojiPersonalizedEmoji: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationMessagesBackgrounds: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPhotosEditInfill1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPhotosEditOutfill1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPhotosEditSpatialReframing1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenContactsAvatarsCreationBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenContactsAvatarsCreationPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenGenmojiBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenGenmojiPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenImagePlaygroundCreationBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenImagePlaygroundCreationPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenWallpaperCreationBase1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPreGenWallpaperCreationPersonalized1p: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPromptAnalysis: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationPromptRewrite: UseCaseIdentifier { get { fatalError() } }
    public static var visualGenerationSketchCaptioning: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceCameraImageSearch: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceIntelligentPassCreation: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceNutrition: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceStructuredExtractionAddToCalendar: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceStructuredExtractionHealthData: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceStructuredExtractionReceipt: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceTamale: UseCaseIdentifier { get { fatalError() } }
    public static var visualIntelligenceVIContentClassifier: UseCaseIdentifier { get { fatalError() } }
    public static var voiceControlAIProduction: UseCaseIdentifier { get { fatalError() } }
    public static var walletReceiptLinking: UseCaseIdentifier { get { fatalError() } }
    public static var writingTools: UseCaseIdentifier { get { fatalError() } }
    public static var writingToolsCompose: UseCaseIdentifier { get { fatalError() } }
    public static var writingToolsComposeRecentsSummaries: UseCaseIdentifier { get { fatalError() } }
    public static var writingToolsProofreading: UseCaseIdentifier { get { fatalError() } }
    public static var writingToolsQuestionAnswer: UseCaseIdentifier { get { fatalError() } }
}
public class UseCaseIdentifierWrapper {
    public init() {}
    public init(coder: NSCoder) {}
    public init(useCaseIdentifier: UseCaseIdentifier) {}
    public func encode(with: NSCoder) -> () {}
    public var description: String { get { return "" } }
    public static var useCaseIdentifierKey: String { get { return "" } }
    public func copy(with: Optional<NSZone>) -> Any { fatalError() }
    public var hash: Int { get { return 0 } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public var useCaseIdentifier: UseCaseIdentifier { get { fatalError() } }
}
public struct UseCaseStatus: Codable, Hashable, Sendable {
    public init(downloadStatus: AssetSubscriptionStatus) {}
    public init(from: Decoder) throws {}
    public var downloadStatus: AssetSubscriptionStatus { get { fatalError() } }
    public func encode(to: Encoder) throws -> () {}
    public static func ==(arg1: UseCaseStatus, arg2: UseCaseStatus) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
}
public struct UseCaseStatuses: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public init(assetDeliverySuspended: Bool, additionalSpaceRequired: UInt64, statuses: Dictionary<UseCaseIdentifier, UseCaseStatus>) {}
    public var statuses: Dictionary<UseCaseIdentifier, UseCaseStatus> { get { return [:] } }
    public func hash(into: inout Hasher) -> () {}
    public func encode(to: Encoder) throws -> () {}
    public var assetDeliverySuspended: Bool { get { return false } }
    public static func ==(arg1: UseCaseStatuses, arg2: UseCaseStatuses) -> Bool { return false }
    public var additionalSpaceRequired: UInt64 { get { return 0 } }
    public var hashValue: Int { get { return 0 } }
}
public class UseCaseStatusesWrapper {
    public init(useCaseStatuses: UseCaseStatuses) {}
    public init() {}
    public init(coder: NSCoder) {}
    public var hash: Int { get { return 0 } }
    public static var supportsSecureCoding: Bool { get { return false } set {} }
    public static var useCaseStatusesKey: String { get { return "" } }
    public func encode(with: NSCoder) -> () {}
    public var description: String { get { return "" } }
    public func copy(with: Optional<NSZone>) -> Any { fatalError() }
    public var useCaseStatuses: UseCaseStatuses { get { fatalError() } }
}
public enum VariantHelpers: Hashable, Sendable {
    case _mock
    public static func isResourceBundleQueryURIResolved(uri: URL) -> Bool { return false }
    public static func createResourceIdentifier(with: String, variant: String) -> String { return "" }
}
public protocol VisionModel {
}
public struct VisionModelAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct VisionModelAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct VisionModelBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration) throws {}
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public static func ==(arg1: VisionModelBase, arg2: VisionModelBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct VisionModelBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func personsegmentation(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public var facelandmarks: Optional<VisionModel> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public func foregroundinstancesegmentation(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public var recognizeanimals: Optional<VisionModel> { get { return nil } set {} }
        public func build() throws -> VisionModelBundle { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
        public var personinstancesegmentation: Optional<VisionModel> { get { return nil } set {} }
        public func masktracker(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func facecapturequality(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func recognizeanimals(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public func smudgedetection(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public var humanrectangles: Optional<VisionModel> { get { return nil } set {} }
        public func facelandmarks(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public func detectbarcodes(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var facecapturequality: Optional<VisionModel> { get { return nil } set {} }
        public var personsegmentation: Optional<VisionModel> { get { return nil } set {} }
        public func personinstancesegmentation(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public var detectbarcodes: Optional<VisionModel> { get { return nil } set {} }
        public var foregroundinstancesegmentation: Optional<VisionModel> { get { return nil } set {} }
        public var masktracker: Optional<VisionModel> { get { return nil } set {} }
        public var smudgedetection: Optional<VisionModel> { get { return nil } set {} }
        public func humanrectangles(arg1: Optional<VisionModel>) -> Builder { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
    }
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(from: Decoder) throws {}
    public init(configurationIdentifier: String, build: (VisionModelBundle.Builder) throws -> ()) throws {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var masktracker: Optional<VisionModel> { get { return nil } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var personsegmentation: Optional<VisionModel> { get { return nil } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var smudgedetection: Optional<VisionModel> { get { return nil } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public func hash(into: inout Hasher) -> () {}
    public var configurationIdentifier: String { get { return "" } }
    public var detectbarcodes: Optional<VisionModel> { get { return nil } }
    public var foregroundinstancesegmentation: Optional<VisionModel> { get { return nil } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public func encode(to: Encoder) throws -> () {}
    public var hashValue: Int { get { return 0 } }
    public var humanrectangles: Optional<VisionModel> { get { return nil } }
    public var rawID: String { get { return "" } }
    public var recognizeanimals: Optional<VisionModel> { get { return nil } }
    public static func ==(arg1: VisionModelBundle, arg2: VisionModelBundle) -> Bool { return false }
    public var facecapturequality: Optional<VisionModel> { get { return nil } }
    public var facelandmarks: Optional<VisionModel> { get { return nil } }
    public var id: ResourceBundleIdentifier<VisionModelBundle> { get { fatalError() } }
    public var personinstancesegmentation: Optional<VisionModel> { get { return nil } }
}
public protocol VisionModelBundleProtocol {
}
public protocol VoicesOverrides {
}
public struct VoicesOverridesAssetContents: Codable, Hashable, Sendable {
    public init(baseURL: URL) {}
    public var baseURL: URL { get { fatalError() } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct VoicesOverridesAssetMetadata: Codable, Hashable, Sendable {
    public init(from: Decoder) throws {}
    public func encode(to: Encoder) throws -> () {}
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct VoicesOverridesBase: Codable, Hashable, Sendable {
    public init(configuration: ResourceConfiguration, variant: String) throws {}
    public init(configuration: ResourceConfiguration) throws {}
    public var configuration: ResourceConfiguration { get { fatalError() } }
    public static func ==(arg1: VoicesOverridesBase, arg2: VoicesOverridesBase) -> Bool { return false }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var variant: String { get { return "" } }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: Encoder) throws { fatalError() }
}
public struct VoicesOverridesBundle: Codable, Hashable, Sendable {
    public class Builder {
        public init(configurationIdentifier: String) {}
        public func trialNamespace(arg1: Optional<String>) -> Builder { fatalError() }
        public func bundlePolicy(arg1: BundlePolicy) -> Builder { fatalError() }
        public func voicesOverrides(arg1: Optional<VoicesOverrides>) -> Builder { fatalError() }
        public func serverWorkflowEnabled(arg1: Bool) -> Builder { fatalError() }
        public var bundlePolicy: BundlePolicy { get { fatalError() } set {} }
        public var serverWorkflowEnabled: Bool { get { return false } set {} }
        public func build() throws -> VoicesOverridesBundle { fatalError() }
        public var trialNamespace: Optional<String> { get { return nil } set {} }
        public var voicesOverrides: Optional<VoicesOverrides> { get { return nil } set {} }
        public func modelInterfaceName(arg1: Optional<String>) -> Builder { fatalError() }
        public var modelInterfaceName: Optional<String> { get { return nil } set {} }
    }
    public init(from: Decoder) throws {}
    public init(with: Dictionary<String, Any>, resources: Array<any CatalogResource>) throws {}
    public init(configurationIdentifier: String, build: (VoicesOverridesBundle.Builder) throws -> ()) throws {}
    public func encode(to: Encoder) throws -> () {}
    public var bundlePolicy: BundlePolicy { get { fatalError() } }
    public var configurationIdentifier: String { get { return "" } }
    public var rawID: String { get { return "" } }
    public var resources: Array<any CatalogResource> { get { return [] } }
    public var serverWorkflowEnabled: Bool { get { return false } }
    public var voicesOverrides: VoicesOverrides { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Int { get { return 0 } }
    public var id: ResourceBundleIdentifier<VoicesOverridesBundle> { get { fatalError() } }
    public var modelInterfaceName: Optional<String> { get { return nil } }
    public var trialNamespace: Optional<String> { get { return nil } }
    public static func ==(arg1: VoicesOverridesBundle, arg2: VoicesOverridesBundle) -> Bool { return false }
}
public protocol VoicesOverridesBundleProtocol {
}
public protocol XPCService {
    static var entitlementName: String { get }
    static var logger: Logger { get }
    static var otherAcceptedEntitlementNames: Set<String> { get }
    static var requestSelectorClasses: KeyValuePairs<(Selector, Int), Set<AnyHashable>> { get }
    static var responseSelectorClasses: KeyValuePairs<(Selector, Int), Set<AnyHashable>> { get }
    static func customize(serverInterface: NSXPCInterface) -> ()
    associatedtype Interface
    static var interface: Protocol { get }
    static var serviceName: String { get }
}
public class XPCServiceClientConnection<A> {
    public init(delegate: any XPCServiceClientConnectionDelegate) {}
    public func call<GenericA>(arg1: (Any) -> GenericA) throws -> GenericA { fatalError() }
    public func call<GenericA>(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) throws -> GenericA { fatalError() }
    public func callAsync<GenericA>(arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) async throws -> GenericA { fatalError() }
}
public protocol XPCServiceClientConnectionDelegate {
    func xpcConnectionIsAllowed() throws -> ()
}
public enum XPCServiceError: Hashable, Sendable {
    case _mock
    public var hashValue: Int { get { return 0 } }
    public func hash(into: inout Hasher) -> () {}
    public static func ==(arg1: XPCServiceError, arg2: XPCServiceError) -> Bool { return false }
}
extension AcquireCoherenceTokenResponse: Equatable { public static func == (lhs: AcquireCoherenceTokenResponse, rhs: AcquireCoherenceTokenResponse) -> Bool { fatalError() } }
extension AssetBackedCoreMLRankingModelBundle.Builder: Equatable { public static func == (lhs: AssetBackedCoreMLRankingModelBundle.Builder, rhs: AssetBackedCoreMLRankingModelBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedDefaultOverridesBundle.Builder: Equatable { public static func == (lhs: AssetBackedDefaultOverridesBundle.Builder, rhs: AssetBackedDefaultOverridesBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedDiffusionBundle.Builder: Equatable { public static func == (lhs: AssetBackedDiffusionBundle.Builder, rhs: AssetBackedDiffusionBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedGenerativeShortcutsBundle.Builder: Equatable { public static func == (lhs: AssetBackedGenerativeShortcutsBundle.Builder, rhs: AssetBackedGenerativeShortcutsBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedImageSpatialPhotosReliveBundle.Builder: Equatable { public static func == (lhs: AssetBackedImageSpatialPhotosReliveBundle.Builder, rhs: AssetBackedImageSpatialPhotosReliveBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedLLMBundle.Builder: Equatable { public static func == (lhs: AssetBackedLLMBundle.Builder, rhs: AssetBackedLLMBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedLLMCompileDraftBundle.Builder: Equatable { public static func == (lhs: AssetBackedLLMCompileDraftBundle.Builder, rhs: AssetBackedLLMCompileDraftBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedLLMDraftBundle.Builder: Equatable { public static func == (lhs: AssetBackedLLMDraftBundle.Builder, rhs: AssetBackedLLMDraftBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedMotionBundle.Builder: Equatable { public static func == (lhs: AssetBackedMotionBundle.Builder, rhs: AssetBackedMotionBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedPCCGenericInferenceBundle.Builder: Equatable { public static func == (lhs: AssetBackedPCCGenericInferenceBundle.Builder, rhs: AssetBackedPCCGenericInferenceBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedSafetyOutputConfigurationBundle.Builder: Equatable { public static func == (lhs: AssetBackedSafetyOutputConfigurationBundle.Builder, rhs: AssetBackedSafetyOutputConfigurationBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedSanitizerBundle.Builder: Equatable { public static func == (lhs: AssetBackedSanitizerBundle.Builder, rhs: AssetBackedSanitizerBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedSecureAnalyticsBundle.Builder: Equatable { public static func == (lhs: AssetBackedSecureAnalyticsBundle.Builder, rhs: AssetBackedSecureAnalyticsBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedServerDiffusionBundle.Builder: Equatable { public static func == (lhs: AssetBackedServerDiffusionBundle.Builder, rhs: AssetBackedServerDiffusionBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedServerDiffusionV10Bundle.Builder: Equatable { public static func == (lhs: AssetBackedServerDiffusionV10Bundle.Builder, rhs: AssetBackedServerDiffusionV10Bundle.Builder) -> Bool { fatalError() } }
extension AssetBackedServerDiffusionV11_1Bundle.Builder: Equatable { public static func == (lhs: AssetBackedServerDiffusionV11_1Bundle.Builder, rhs: AssetBackedServerDiffusionV11_1Bundle.Builder) -> Bool { fatalError() } }
extension AssetBackedTokenInputDenyListBundle.Builder: Equatable { public static func == (lhs: AssetBackedTokenInputDenyListBundle.Builder, rhs: AssetBackedTokenInputDenyListBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedTokenInputDenyListWithDefaultsBundle.Builder: Equatable { public static func == (lhs: AssetBackedTokenInputDenyListWithDefaultsBundle.Builder, rhs: AssetBackedTokenInputDenyListWithDefaultsBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedTokenOutputDenyListBundle.Builder: Equatable { public static func == (lhs: AssetBackedTokenOutputDenyListBundle.Builder, rhs: AssetBackedTokenOutputDenyListBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedTokenOutputDenyListWithDefaultsBundle.Builder: Equatable { public static func == (lhs: AssetBackedTokenOutputDenyListWithDefaultsBundle.Builder, rhs: AssetBackedTokenOutputDenyListWithDefaultsBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedTokenOutputRetainListBundle.Builder: Equatable { public static func == (lhs: AssetBackedTokenOutputRetainListBundle.Builder, rhs: AssetBackedTokenOutputRetainListBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedVisionModelBundle.Builder: Equatable { public static func == (lhs: AssetBackedVisionModelBundle.Builder, rhs: AssetBackedVisionModelBundle.Builder) -> Bool { fatalError() } }
extension AssetBackedVoicesOverridesBundle.Builder: Equatable { public static func == (lhs: AssetBackedVoicesOverridesBundle.Builder, rhs: AssetBackedVoicesOverridesBundle.Builder) -> Bool { fatalError() } }
extension AvailableUseCasesWrapper: Equatable { public static func == (lhs: AvailableUseCasesWrapper, rhs: AvailableUseCasesWrapper) -> Bool { fatalError() } }
extension BidirectionalXPCServiceClientConnection<Any, Any>: Equatable { public static func == (lhs: BidirectionalXPCServiceClientConnection<Any, Any>, rhs: BidirectionalXPCServiceClientConnection<Any, Any>) -> Bool { fatalError() } }
extension CatalogClient: Equatable { public static func == (lhs: CatalogClient, rhs: CatalogClient) -> Bool { fatalError() } }
extension CatalogIndex: Equatable { public static func == (lhs: CatalogIndex, rhs: CatalogIndex) -> Bool { fatalError() } }
extension CoherentAssetLock: Equatable { public static func == (lhs: CoherentAssetLock, rhs: CoherentAssetLock) -> Bool { fatalError() } }
extension CoreMLRankingModelBundle.Builder: Equatable { public static func == (lhs: CoreMLRankingModelBundle.Builder, rhs: CoreMLRankingModelBundle.Builder) -> Bool { fatalError() } }
extension DefaultOverridesBundle.Builder: Equatable { public static func == (lhs: DefaultOverridesBundle.Builder, rhs: DefaultOverridesBundle.Builder) -> Bool { fatalError() } }
extension DiffusionBundle.Builder: Equatable { public static func == (lhs: DiffusionBundle.Builder, rhs: DiffusionBundle.Builder) -> Bool { fatalError() } }
extension GenerativeShortcutsBundle.Builder: Equatable { public static func == (lhs: GenerativeShortcutsBundle.Builder, rhs: GenerativeShortcutsBundle.Builder) -> Bool { fatalError() } }
extension GuardrailResultWrapper: Equatable { public static func == (lhs: GuardrailResultWrapper, rhs: GuardrailResultWrapper) -> Bool { fatalError() } }
extension ImageSpatialPhotosReliveBundle.Builder: Equatable { public static func == (lhs: ImageSpatialPhotosReliveBundle.Builder, rhs: ImageSpatialPhotosReliveBundle.Builder) -> Bool { fatalError() } }
extension LLMBundle.Builder: Equatable { public static func == (lhs: LLMBundle.Builder, rhs: LLMBundle.Builder) -> Bool { fatalError() } }
extension LLMCompileDraftBundle.Builder: Equatable { public static func == (lhs: LLMCompileDraftBundle.Builder, rhs: LLMCompileDraftBundle.Builder) -> Bool { fatalError() } }
extension LLMDraftBundle.Builder: Equatable { public static func == (lhs: LLMDraftBundle.Builder, rhs: LLMDraftBundle.Builder) -> Bool { fatalError() } }
extension LocalCatalogClient: Equatable { public static func == (lhs: LocalCatalogClient, rhs: LocalCatalogClient) -> Bool { fatalError() } }
extension MotionBundle.Builder: Equatable { public static func == (lhs: MotionBundle.Builder, rhs: MotionBundle.Builder) -> Bool { fatalError() } }
extension PCCGenericInferenceBundle.Builder: Equatable { public static func == (lhs: PCCGenericInferenceBundle.Builder, rhs: PCCGenericInferenceBundle.Builder) -> Bool { fatalError() } }
extension ResourceBundleContainer: Equatable { public static func == (lhs: ResourceBundleContainer, rhs: ResourceBundleContainer) -> Bool { fatalError() } }
extension ResourceContainer: Equatable { public static func == (lhs: ResourceContainer, rhs: ResourceContainer) -> Bool { fatalError() } }
extension ResourceInformation: Equatable { public static func == (lhs: ResourceInformation, rhs: ResourceInformation) -> Bool { fatalError() } }
extension SafetyFailureWrapper: Equatable { public static func == (lhs: SafetyFailureWrapper, rhs: SafetyFailureWrapper) -> Bool { fatalError() } }
extension SafetyOutputConfigurationBundle.Builder: Equatable { public static func == (lhs: SafetyOutputConfigurationBundle.Builder, rhs: SafetyOutputConfigurationBundle.Builder) -> Bool { fatalError() } }
extension SanitizerBundle.Builder: Equatable { public static func == (lhs: SanitizerBundle.Builder, rhs: SanitizerBundle.Builder) -> Bool { fatalError() } }
extension SecureAnalyticsBundle.Builder: Equatable { public static func == (lhs: SecureAnalyticsBundle.Builder, rhs: SecureAnalyticsBundle.Builder) -> Bool { fatalError() } }
extension ServerDiffusionBundle.Builder: Equatable { public static func == (lhs: ServerDiffusionBundle.Builder, rhs: ServerDiffusionBundle.Builder) -> Bool { fatalError() } }
extension ServerDiffusionV10Bundle.Builder: Equatable { public static func == (lhs: ServerDiffusionV10Bundle.Builder, rhs: ServerDiffusionV10Bundle.Builder) -> Bool { fatalError() } }
extension ServerDiffusionV11_1Bundle.Builder: Equatable { public static func == (lhs: ServerDiffusionV11_1Bundle.Builder, rhs: ServerDiffusionV11_1Bundle.Builder) -> Bool { fatalError() } }
extension SiriResourceAvailabilityInfo: Equatable { public static func == (lhs: SiriResourceAvailabilityInfo, rhs: SiriResourceAvailabilityInfo) -> Bool { fatalError() } }
extension StatusResponse: Equatable { public static func == (lhs: StatusResponse, rhs: StatusResponse) -> Bool { fatalError() } }
extension SubscriptionManagerProvider: Equatable { public static func == (lhs: SubscriptionManagerProvider, rhs: SubscriptionManagerProvider) -> Bool { fatalError() } }
extension TokenBucketInMemoryRateLimiter: Equatable { public static func == (lhs: TokenBucketInMemoryRateLimiter, rhs: TokenBucketInMemoryRateLimiter) -> Bool { fatalError() } }
extension TokenInputDenyListBundle.Builder: Equatable { public static func == (lhs: TokenInputDenyListBundle.Builder, rhs: TokenInputDenyListBundle.Builder) -> Bool { fatalError() } }
extension TokenInputDenyListWithDefaultsBundle.Builder: Equatable { public static func == (lhs: TokenInputDenyListWithDefaultsBundle.Builder, rhs: TokenInputDenyListWithDefaultsBundle.Builder) -> Bool { fatalError() } }
extension TokenOutputDenyListBundle.Builder: Equatable { public static func == (lhs: TokenOutputDenyListBundle.Builder, rhs: TokenOutputDenyListBundle.Builder) -> Bool { fatalError() } }
extension TokenOutputDenyListWithDefaultsBundle.Builder: Equatable { public static func == (lhs: TokenOutputDenyListWithDefaultsBundle.Builder, rhs: TokenOutputDenyListWithDefaultsBundle.Builder) -> Bool { fatalError() } }
extension TokenOutputRetainListBundle.Builder: Equatable { public static func == (lhs: TokenOutputRetainListBundle.Builder, rhs: TokenOutputRetainListBundle.Builder) -> Bool { fatalError() } }
extension UseCaseAvailabilityInfo: Equatable { public static func == (lhs: UseCaseAvailabilityInfo, rhs: UseCaseAvailabilityInfo) -> Bool { fatalError() } }
extension UseCaseIdentifierWrapper: Equatable { public static func == (lhs: UseCaseIdentifierWrapper, rhs: UseCaseIdentifierWrapper) -> Bool { fatalError() } }
extension UseCaseStatusesWrapper: Equatable { public static func == (lhs: UseCaseStatusesWrapper, rhs: UseCaseStatusesWrapper) -> Bool { fatalError() } }
extension VisionModelBundle.Builder: Equatable { public static func == (lhs: VisionModelBundle.Builder, rhs: VisionModelBundle.Builder) -> Bool { fatalError() } }
extension VoicesOverridesBundle.Builder: Equatable { public static func == (lhs: VoicesOverridesBundle.Builder, rhs: VoicesOverridesBundle.Builder) -> Bool { fatalError() } }
extension XPCServiceClientConnection<Any>: Equatable { public static func == (lhs: XPCServiceClientConnection<Any>, rhs: XPCServiceClientConnection<Any>) -> Bool { fatalError() } }
public struct ADMBackgroundPrompt: Hashable, Codable, Sendable {}
public struct ADMBackgroundPromptConfigurationID: Hashable, Codable, Sendable {}
public struct ADMBackgroundPromptID: Hashable, Codable, Sendable {}
public struct ADMBackgroundPromptInputDenyList: Hashable, Codable, Sendable {}
public struct ADMBackgroundPromptOutputDenyList: Hashable, Codable, Sendable {}
public struct ADMPeopleGrounding: Hashable, Codable, Sendable {}
public struct ADMPeopleGroundingConfigurationID: Hashable, Codable, Sendable {}
public struct ADMPeopleGroundingID: Hashable, Codable, Sendable {}
public struct ADMPromptAnalyzer: Hashable, Codable, Sendable {}
public struct ADMPromptAnalyzerConfigurationID: Hashable, Codable, Sendable {}
public struct ADMPromptAnalyzerID: Hashable, Codable, Sendable {}
public struct ADMPromptRewriting: Hashable, Codable, Sendable {}
public struct ADMPromptRewritingConfigurationID: Hashable, Codable, Sendable {}
public struct ADMPromptRewritingID: Hashable, Codable, Sendable {}
public struct AEMMd7: Hashable, Codable, Sendable {}
public struct AEMMd7Encoder: Hashable, Codable, Sendable {}
public struct AEMMd7Tokenizer: Hashable, Codable, Sendable {}
public struct AEMMd8: Hashable, Codable, Sendable {}
public struct AEMMd8Encoder: Hashable, Codable, Sendable {}
public struct AEMMd8Tokenizer: Hashable, Codable, Sendable {}
public struct AEMMd9: Hashable, Codable, Sendable {}
public struct AEMMd9Encoder: Hashable, Codable, Sendable {}
public struct AEMMd9Tokenizer: Hashable, Codable, Sendable {}
public struct AFMImageEncoder: Hashable, Codable, Sendable {}
public struct AFMImageTokenizer300M: Hashable, Codable, Sendable {}
public struct AFMImageTokenizerServer: Hashable, Codable, Sendable {}
public struct AFMPlusEmbeddingPreprocessor: Hashable, Codable, Sendable {}
public struct AFMTextInstruct300MBase: Hashable, Codable, Sendable {}
public struct AFMTextInstruct300MTokenizer: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BBase: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BBaseConfigurationID: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BBaseID: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BThirdParty: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BThirdPartyConfigurationID: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BThirdPartyID: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BThirdPartySD: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BThirdPartySDConfigurationID: Hashable, Codable, Sendable {}
public struct AFMTextInstruct3BThirdPartySDID: Hashable, Codable, Sendable {}
public struct AFMTextInstruct85MBase: Hashable, Codable, Sendable {}
public struct AFMTextInstruct85MTokenizer: Hashable, Codable, Sendable {}
public struct AFMTextInstructEnglish49k: Hashable, Codable, Sendable {}
public struct AJAXInferenceProvider: Hashable, Codable, Sendable {}
public struct ASRAFMDictation: Hashable, Codable, Sendable {}
public struct ASRAFMDictationConfigurationID: Hashable, Codable, Sendable {}
public struct ASRAFMDictationID: Hashable, Codable, Sendable {}
public struct ASRNaturalDictationSpeech: Hashable, Codable, Sendable {}
public struct ASRNaturalDictationSpeechConfigurationID: Hashable, Codable, Sendable {}
public struct ASRNaturalDictationSpeechID: Hashable, Codable, Sendable {}
public struct AccessibilityMagnifier: Hashable, Codable, Sendable {}
public struct AccessibilityMagnifierConfigurationID: Hashable, Codable, Sendable {}
public struct AccessibilityMagnifierID: Hashable, Codable, Sendable {}
public struct AccessibilityMagnifierInputDenyList: Hashable, Codable, Sendable {}
public struct AccessibilityMagnifierOutputDenyList: Hashable, Codable, Sendable {}
public struct AccessibilityReaderAIInputDenyList: Hashable, Codable, Sendable {}
public struct AccessibilityReaderAIOutputDenyList: Hashable, Codable, Sendable {}
public struct ActionValidator: Hashable, Codable, Sendable {}
public struct ActionValidatorConfigurationID: Hashable, Codable, Sendable {}
public struct ActionValidatorID: Hashable, Codable, Sendable {}
public struct AlchemistInferenceProvider: Hashable, Codable, Sendable {}
public struct All: Hashable, Codable, Sendable {}
public struct Animation: Hashable, Codable, Sendable {}
public struct AnimationConfigurationID: Hashable, Codable, Sendable {}
public struct AnimationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesis: Hashable, Codable, Sendable {}
public struct AnswerSynthesisConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServer: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2ConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment1: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment1ID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment2: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment2ConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment2ID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment3: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment3ConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment3ID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment4: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment4ConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment4ID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment5: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment5ConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2Experiment5ID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2ID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2_ShortOutput: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2_ShortOutputConfigurationID: Hashable, Codable, Sendable {}
public struct AnswerSynthesisServerV2_ShortOutputID: Hashable, Codable, Sendable {}
public struct AnyHashable: Hashable, Codable, Sendable {}
public struct AppleIntelligenceReporting_AppleIntelligenceError: Hashable, Codable, Sendable {}
public struct AppleIntelligenceReporting_AppleIntelligenceErrorCategory: Hashable, Codable, Sendable {}
public struct AskGenerativeModelActionInputDenyList: Hashable, Codable, Sendable {}
public struct AskGenerativeModelActionOutputDenyList: Hashable, Codable, Sendable {}
public struct AsyncStream<T>: Hashable, Codable, Sendable {}
public struct AutoTagger: Hashable, Codable, Sendable {}
public struct AutoTaggerConfigurationID: Hashable, Codable, Sendable {}
public struct AutoTaggerID: Hashable, Codable, Sendable {}
public struct AutonamingMessages: Hashable, Codable, Sendable {}
public struct AutonamingMessagesConfigurationID: Hashable, Codable, Sendable {}
public struct AutonamingMessagesID: Hashable, Codable, Sendable {}
public struct BaseAdapter: Hashable, Codable, Sendable {}
public struct BulletsTransform: Hashable, Codable, Sendable {}
public struct BulletsTransformConfigurationID: Hashable, Codable, Sendable {}
public struct BulletsTransformID: Hashable, Codable, Sendable {}
public struct CalendarMagicComposeBackwardPassInputDenyList: Hashable, Codable, Sendable {}
public struct CalendarMagicComposeBackwardPassOutputDenyList: Hashable, Codable, Sendable {}
public struct CatalogAssetType: Hashable, Codable, Sendable {}
public struct ChangePasswordForMeInputDenyList: Hashable, Codable, Sendable {}
public struct ChangePasswordForMeOutputDenyList: Hashable, Codable, Sendable {}
public struct ChatGPT: Hashable, Codable, Sendable {}
public struct ChatGPTConfigurationID: Hashable, Codable, Sendable {}
public struct ChatGPTID: Hashable, Codable, Sendable {}
public struct ChatGPTTokenizer: Hashable, Codable, Sendable {}
public struct ClipCaptioningInputDenyList: Hashable, Codable, Sendable {}
public struct ClipCaptioningOutputDenyList: Hashable, Codable, Sendable {}
public struct CodeIntelligenceBaseInputDenyList: Hashable, Codable, Sendable {}
public struct CodeIntelligenceBaseOutputDenyList: Hashable, Codable, Sendable {}
public struct CodeLM: Hashable, Codable, Sendable {}
public struct CodeLMConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMExperimental: Hashable, Codable, Sendable {}
public struct CodeLMExperimentalConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMExperimentalID: Hashable, Codable, Sendable {}
public struct CodeLMID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV1: Hashable, Codable, Sendable {}
public struct CodeLMLargeV1ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV1ID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV1Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMLargeV2: Hashable, Codable, Sendable {}
public struct CodeLMLargeV2ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV2ID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV2Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMLargeV3: Hashable, Codable, Sendable {}
public struct CodeLMLargeV3ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV3ID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV3Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMLargeV4: Hashable, Codable, Sendable {}
public struct CodeLMLargeV4ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV4ID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV4Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMLargeV5: Hashable, Codable, Sendable {}
public struct CodeLMLargeV5ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV5ID: Hashable, Codable, Sendable {}
public struct CodeLMLargeV5Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMSafetyGuardrail: Hashable, Codable, Sendable {}
public struct CodeLMSafetyGuardrailConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMSafetyGuardrailID: Hashable, Codable, Sendable {}
public struct CodeLMSafetyGuardrailTokenizer: Hashable, Codable, Sendable {}
public struct CodeLMSmallV1: Hashable, Codable, Sendable {}
public struct CodeLMSmallV1ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV1ID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV1Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMSmallV2: Hashable, Codable, Sendable {}
public struct CodeLMSmallV2ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV2ID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV2Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMSmallV3: Hashable, Codable, Sendable {}
public struct CodeLMSmallV3ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV3ID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV3Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMSmallV4: Hashable, Codable, Sendable {}
public struct CodeLMSmallV4ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV4ID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV4Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMSmallV5: Hashable, Codable, Sendable {}
public struct CodeLMSmallV5ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV5ID: Hashable, Codable, Sendable {}
public struct CodeLMSmallV5Tokenizer: Hashable, Codable, Sendable {}
public struct CodeLMTokenizer: Hashable, Codable, Sendable {}
public struct CodeLMTokenizerExperimental: Hashable, Codable, Sendable {}
public struct CodeLMTokenizerV2: Hashable, Codable, Sendable {}
public struct CodeLMTokenizerV3: Hashable, Codable, Sendable {}
public struct CodeLMTokenizerV4: Hashable, Codable, Sendable {}
public struct CodeLMV1ANE3B: Hashable, Codable, Sendable {}
public struct CodeLMV1ANE3BConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMV1ANE3BID: Hashable, Codable, Sendable {}
public struct CodeLMV1ANE3BTokenizer: Hashable, Codable, Sendable {}
public struct CodeLMV2: Hashable, Codable, Sendable {}
public struct CodeLMV2ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMV2ID: Hashable, Codable, Sendable {}
public struct CodeLMV3: Hashable, Codable, Sendable {}
public struct CodeLMV3ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMV3ID: Hashable, Codable, Sendable {}
public struct CodeLMV4: Hashable, Codable, Sendable {}
public struct CodeLMV4ConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMV4ID: Hashable, Codable, Sendable {}
public struct CodeLMWithDraft: Hashable, Codable, Sendable {}
public struct CodeLMWithDraftConfigurationID: Hashable, Codable, Sendable {}
public struct CodeLMWithDraftID: Hashable, Codable, Sendable {}
public struct CodeSafetyGuardrail: Hashable, Codable, Sendable {}
public struct CodeSafetyGuardrailConfigurationID: Hashable, Codable, Sendable {}
public struct CodeSafetyGuardrailID: Hashable, Codable, Sendable {}
public struct CodeSafetyGuardrailTokenizer: Hashable, Codable, Sendable {}
public struct ConcertsRanking: Hashable, Codable, Sendable {}
public struct ConcertsRankingConfigurationID: Hashable, Codable, Sendable {}
public struct ConcertsRankingID: Hashable, Codable, Sendable {}
public struct ConciseTone: Hashable, Codable, Sendable {}
public struct ConciseToneConfigurationID: Hashable, Codable, Sendable {}
public struct ConciseToneID: Hashable, Codable, Sendable {}
public struct Conditioning: Hashable, Codable, Sendable {}
public struct ContentTagger: Hashable, Codable, Sendable {}
public struct ContentTaggerConfigurationID: Hashable, Codable, Sendable {}
public struct ContentTaggerID: Hashable, Codable, Sendable {}
public struct ContextAwareness: Hashable, Codable, Sendable {}
public struct ContextAwarenessConfigurationID: Hashable, Codable, Sendable {}
public struct ContextAwarenessID: Hashable, Codable, Sendable {}
public struct ContextProgram: Hashable, Codable, Sendable {}
public struct ContextProgramConfigurationID: Hashable, Codable, Sendable {}
public struct ContextProgramID: Hashable, Codable, Sendable {}
public struct ConversationTitleSummarization: Hashable, Codable, Sendable {}
public struct ConversationTitleSummarizationConfigurationID: Hashable, Codable, Sendable {}
public struct ConversationTitleSummarizationID: Hashable, Codable, Sendable {}
public struct CoreMotionCalorimetryFMPredictedWRMets: Hashable, Codable, Sendable {}
public struct CoreMotionCalorimetryFMPredictedWRMetsConfigurationID: Hashable, Codable, Sendable {}
public struct CoreMotionCalorimetryFMPredictedWRMetsID: Hashable, Codable, Sendable {}
public struct CoreMotionCalorimetryReducedEmbeddings: Hashable, Codable, Sendable {}
public struct CoreMotionCalorimetryReducedEmbeddingsConfigurationID: Hashable, Codable, Sendable {}
public struct CoreMotionCalorimetryReducedEmbeddingsID: Hashable, Codable, Sendable {}
public struct CoreMotionFoundationModelInferenceProvider: Hashable, Codable, Sendable {}
public struct CoreMotionIMUFoundationModel: Hashable, Codable, Sendable {}
public struct CoreMotionIMUFoundationModelConfigurationID: Hashable, Codable, Sendable {}
public struct CoreMotionIMUFoundationModelID: Hashable, Codable, Sendable {}
public struct CoreMotionPednetFoundationModel: Hashable, Codable, Sendable {}
public struct CoreMotionPednetFoundationModelConfigurationID: Hashable, Codable, Sendable {}
public struct CoreMotionPednetFoundationModelID: Hashable, Codable, Sendable {}
public struct CoreMotionPednetV1InferenceProvider: Hashable, Codable, Sendable {}
public protocol Date {}
public struct DefaultOverridesOnly: Hashable, Codable, Sendable {}
public struct DefaultOverridesOnlyConfigurationID: Hashable, Codable, Sendable {}
public struct DefaultOverridesOnlyID: Hashable, Codable, Sendable {}
public struct DeltaLexiconInputPromptAllowList: Hashable, Codable, Sendable {}
public struct DescribeYourEdit: Hashable, Codable, Sendable {}
public struct DescribeYourEditConfigurationID: Hashable, Codable, Sendable {}
public struct DescribeYourEditID: Hashable, Codable, Sendable {}
public struct DetectBarcodes: Hashable, Codable, Sendable {}
public struct DetectBarcodesConfigurationID: Hashable, Codable, Sendable {}
public struct DetectBarcodesID: Hashable, Codable, Sendable {}
public struct Detector: Hashable, Codable, Sendable {}
public struct DeviceSummarizationTextSummarizer: Hashable, Codable, Sendable {}
public struct DeviceSummarizationTextSummarizerConfigurationID: Hashable, Codable, Sendable {}
public struct DeviceSummarizationTextSummarizerID: Hashable, Codable, Sendable {}
public struct DiffusionBase: Hashable, Codable, Sendable {}
public struct DiffusionBaseConfigurationID: Hashable, Codable, Sendable {}
public struct DiffusionBaseID: Hashable, Codable, Sendable {}
public struct DispatchQueue: Hashable, Codable, Sendable {}
public struct DistilledMessagesAction: Hashable, Codable, Sendable {}
public struct DistilledMessagesActionConfigurationID: Hashable, Codable, Sendable {}
public struct DistilledMessagesActionID: Hashable, Codable, Sendable {}
public struct DistilledMessagesActionTokenizer: Hashable, Codable, Sendable {}
public struct DistilledMessagesReply: Hashable, Codable, Sendable {}
public struct DistilledMessagesReplyConfigurationID: Hashable, Codable, Sendable {}
public struct DistilledMessagesReplyID: Hashable, Codable, Sendable {}
public struct DistilledMessagesReplyTokenizer: Hashable, Codable, Sendable {}
public struct EchoAgent: Hashable, Codable, Sendable {}
public struct EchoAgentConfigurationID: Hashable, Codable, Sendable {}
public struct EchoAgentID: Hashable, Codable, Sendable {}
public struct EmbeddingPreprocessorInferenceProvider: Hashable, Codable, Sendable {}
public struct Emoji: Hashable, Codable, Sendable {}
public struct EmojiConfigurationID: Hashable, Codable, Sendable {}
public struct EmojiID: Hashable, Codable, Sendable {}
public struct EmojiKeywordExtraction: Hashable, Codable, Sendable {}
public struct EmojiKeywordExtractionConfigurationID: Hashable, Codable, Sendable {}
public struct EmojiKeywordExtractionID: Hashable, Codable, Sendable {}
public struct ExternalLanguageModelProvider: Hashable, Codable, Sendable {}
public struct ExternalSearchPartner: Hashable, Codable, Sendable {}
public struct ExternalSearchPartnerConfigurationID: Hashable, Codable, Sendable {}
public struct ExternalSearchPartnerDummyTokenizer: Hashable, Codable, Sendable {}
public struct ExternalSearchPartnerID: Hashable, Codable, Sendable {}
public struct ExternalSearchPartnerInferenceProvider: Hashable, Codable, Sendable {}
public struct FMAPI: Hashable, Codable, Sendable {}
public struct FMAPICli: Hashable, Codable, Sendable {}
public struct FMAPICliConfigurationID: Hashable, Codable, Sendable {}
public struct FMAPICliID: Hashable, Codable, Sendable {}
public struct FMAPIConfigurationID: Hashable, Codable, Sendable {}
public struct FMAPIID: Hashable, Codable, Sendable {}
public struct FMServiceEmbeddingV1: Hashable, Codable, Sendable {}
public struct FMServiceEmbeddingV1ConfigurationID: Hashable, Codable, Sendable {}
public struct FMServiceEmbeddingV1ID: Hashable, Codable, Sendable {}
public struct FMServiceLWV1: Hashable, Codable, Sendable {}
public struct FMServiceLWV1ConfigurationID: Hashable, Codable, Sendable {}
public struct FMServiceLWV1ID: Hashable, Codable, Sendable {}
public struct FMServiceVLUV1: Hashable, Codable, Sendable {}
public struct FMServiceVLUV1ConfigurationID: Hashable, Codable, Sendable {}
public struct FMServiceVLUV1ID: Hashable, Codable, Sendable {}
public struct FOVEstimatorBuiltin: Hashable, Codable, Sendable {}
public struct FOVEstimatorMain: Hashable, Codable, Sendable {}
public struct FaceCaptureQuality: Hashable, Codable, Sendable {}
public struct FaceCaptureQualityConfigurationID: Hashable, Codable, Sendable {}
public struct FaceCaptureQualityID: Hashable, Codable, Sendable {}
public struct FaceLandmarks: Hashable, Codable, Sendable {}
public struct FaceLandmarksConfigurationID: Hashable, Codable, Sendable {}
public struct FaceLandmarksID: Hashable, Codable, Sendable {}
public struct FactualConsistencyClassifier: Hashable, Codable, Sendable {}
public struct FactualConsistencyClassifierConfigurationID: Hashable, Codable, Sendable {}
public struct FactualConsistencyClassifierID: Hashable, Codable, Sendable {}
public struct FeatureFlags_FeatureFlagsKey: Hashable, Codable, Sendable {}
public struct FinancialInsights: Hashable, Codable, Sendable {}
public struct FinancialInsightsConfigurationID: Hashable, Codable, Sendable {}
public struct FinancialInsightsID: Hashable, Codable, Sendable {}
public struct FitnessSummary: Hashable, Codable, Sendable {}
public struct FitnessSummaryConfigurationID: Hashable, Codable, Sendable {}
public struct FitnessSummaryID: Hashable, Codable, Sendable {}
public struct FitnessWorkoutVoiceV1: Hashable, Codable, Sendable {}
public struct FitnessWorkoutVoiceV1ConfigurationID: Hashable, Codable, Sendable {}
public struct FitnessWorkoutVoiceV1ID: Hashable, Codable, Sendable {}
public struct ForegroundInstanceSegmentation: Hashable, Codable, Sendable {}
public struct ForegroundInstanceSegmentationConfigurationID: Hashable, Codable, Sendable {}
public struct ForegroundInstanceSegmentationID: Hashable, Codable, Sendable {}
public struct FoundationModelsFrameworkApiInputDenyList: Hashable, Codable, Sendable {}
public struct FoundationModelsFrameworkApiOutputDenyList: Hashable, Codable, Sendable {}
public struct FoundationModelsPlatform: Hashable, Codable, Sendable {}
public struct FoundationModelsPlatformBase: Hashable, Codable, Sendable {}
public struct FoundationModelsPlatformConfigurationID: Hashable, Codable, Sendable {}
public struct FoundationModelsPlatformDummyTokenizer: Hashable, Codable, Sendable {}
public struct FoundationModelsPlatformID: Hashable, Codable, Sendable {}
public struct FriendlyTone: Hashable, Codable, Sendable {}
public struct FriendlyToneConfigurationID: Hashable, Codable, Sendable {}
public struct FriendlyToneID: Hashable, Codable, Sendable {}
public struct FullPayloadCorrection: Hashable, Codable, Sendable {}
public struct FullPayloadCorrectionConfigurationID: Hashable, Codable, Sendable {}
public struct FullPayloadCorrectionID: Hashable, Codable, Sendable {}
public struct GMSPrototype: Hashable, Codable, Sendable {}
public struct GMSPrototypeBase: Hashable, Codable, Sendable {}
public struct GMSPrototypeConfigurationID: Hashable, Codable, Sendable {}
public struct GMSPrototypeDummyTokenizer: Hashable, Codable, Sendable {}
public struct GMSPrototypeEmbeddings: Hashable, Codable, Sendable {}
public struct GMSPrototypeEmbeddingsBase: Hashable, Codable, Sendable {}
public struct GMSPrototypeEmbeddingsConfigurationID: Hashable, Codable, Sendable {}
public struct GMSPrototypeEmbeddingsDummyTokenizer: Hashable, Codable, Sendable {}
public struct GMSPrototypeEmbeddingsID: Hashable, Codable, Sendable {}
public struct GMSPrototypeID: Hashable, Codable, Sendable {}
public struct GenerativeAssistantCommonInputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantCommonOutputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantCompositionInputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantCompositionOutputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantKnowledgeFallbackInputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantKnowledgeFallbackOutputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantKnowledgeInputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantKnowledgeOutputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantMediaQAInputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantMediaQAOutputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantVisualIntelligenceCameraInputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeAssistantVisualIntelligenceCameraOutputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeEditsMagicCleanUp: Hashable, Codable, Sendable {}
public struct GenerativeExperiencesInferenceProvider: Hashable, Codable, Sendable {}
public struct GenerativePlaygroundsUpscaler: Hashable, Codable, Sendable {}
public struct GenerativeShortcutsConfigurationID: Hashable, Codable, Sendable {}
public struct GenerativeShortcutsID: Hashable, Codable, Sendable {}
public struct GenerativeShortcutsInputDenyList: Hashable, Codable, Sendable {}
public struct GenerativeShortcutsOutputDenyList: Hashable, Codable, Sendable {}
public struct GenericA: Hashable, Codable, Sendable {}
public struct GroundedVisualIntelligenceContentClassifier: Hashable, Codable, Sendable {}
public struct GroundedVisualIntelligenceContentClassifierConfigurationID: Hashable, Codable, Sendable {}
public struct GroundedVisualIntelligenceContentClassifierID: Hashable, Codable, Sendable {}
public struct HKSVProcessingAgent: Hashable, Codable, Sendable {}
public struct HKSVProcessingAgentConfigurationID: Hashable, Codable, Sendable {}
public struct HKSVProcessingAgentID: Hashable, Codable, Sendable {}
public struct HKSVProcessingAgentPro: Hashable, Codable, Sendable {}
public struct HKSVProcessingAgentProConfigurationID: Hashable, Codable, Sendable {}
public struct HKSVProcessingAgentProID: Hashable, Codable, Sendable {}
public struct HandwritingSynthesis: Hashable, Codable, Sendable {}
public struct HandwritingSynthesisMultilingual: Hashable, Codable, Sendable {}
public struct HoldAssistWaitTime: Hashable, Codable, Sendable {}
public struct HoldAssistWaitTimeConfigurationID: Hashable, Codable, Sendable {}
public struct HoldAssistWaitTimeID: Hashable, Codable, Sendable {}
public struct HomeKitSummaryNotifications: Hashable, Codable, Sendable {}
public struct HomeKitSummaryNotificationsConfigurationID: Hashable, Codable, Sendable {}
public struct HomeKitSummaryNotificationsID: Hashable, Codable, Sendable {}
public struct HostInference: Hashable, Codable, Sendable {}
public struct HumanRectangles: Hashable, Codable, Sendable {}
public struct HumanRectanglesConfigurationID: Hashable, Codable, Sendable {}
public struct HumanRectanglesID: Hashable, Codable, Sendable {}
public struct ICloudMailEventExtractionInputDenyList: Hashable, Codable, Sendable {}
public struct ICloudMailEventExtractionOutputDenyList: Hashable, Codable, Sendable {}
public struct IPIClassifier: Hashable, Codable, Sendable {}
public struct IPIClassifierConfigurationID: Hashable, Codable, Sendable {}
public struct IPIClassifierID: Hashable, Codable, Sendable {}
public struct IPIClassifierInputDenyList: Hashable, Codable, Sendable {}
public struct IPhoneTracker: Hashable, Codable, Sendable {}
public struct Illustration: Hashable, Codable, Sendable {}
public struct IllustrationConfigurationID: Hashable, Codable, Sendable {}
public struct IllustrationID: Hashable, Codable, Sendable {}
public struct ImagePlaygroundEditSuggestions: Hashable, Codable, Sendable {}
public struct ImagePlaygroundEditSuggestionsConfigurationID: Hashable, Codable, Sendable {}
public struct ImagePlaygroundEditSuggestionsID: Hashable, Codable, Sendable {}
public struct ImagePlaygroundEditSuggestionsInputDenyList: Hashable, Codable, Sendable {}
public struct ImagePlaygroundEditSuggestionsOutputDenyList: Hashable, Codable, Sendable {}
public struct InstructBaseAdapter: Hashable, Codable, Sendable {}
public struct InstructBaseDraftModel: Hashable, Codable, Sendable {}
public struct InstructFMApiGeneric: Hashable, Codable, Sendable {}
public struct InstructFMApiGenericConfigurationID: Hashable, Codable, Sendable {}
public struct InstructFMApiGenericID: Hashable, Codable, Sendable {}
public struct InstructFMApiThirdPartyCompileDraft: Hashable, Codable, Sendable {}
public struct InstructFMApiThirdPartyCompileDraftConfigurationID: Hashable, Codable, Sendable {}
public struct InstructFMApiThirdPartyCompileDraftID: Hashable, Codable, Sendable {}
public struct InstructServerAutograder: Hashable, Codable, Sendable {}
public struct InstructServerAutograderConfigurationID: Hashable, Codable, Sendable {}
public struct InstructServerAutograderID: Hashable, Codable, Sendable {}
public struct InstructServerBase: Hashable, Codable, Sendable {}
public struct InstructServerBaseConfigurationID: Hashable, Codable, Sendable {}
public struct InstructServerBaseID: Hashable, Codable, Sendable {}
public struct InstructServerSmallBase: Hashable, Codable, Sendable {}
public struct InstructServerSmallImageTokenizer: Hashable, Codable, Sendable {}
public struct InstructServerSmallTokenizer: Hashable, Codable, Sendable {}
public struct InstructServerTokenizer: Hashable, Codable, Sendable {}
public struct InstructServerTokenizerTTS: Hashable, Codable, Sendable {}
public struct InstructServerV2BasePro: Hashable, Codable, Sendable {}
public struct InstructServerV2BaseZap: Hashable, Codable, Sendable {}
public struct InstructServerV2DraftModel: Hashable, Codable, Sendable {}
public struct InstructServerV2DraftZap: Hashable, Codable, Sendable {}
public struct InstructServerV2ImageTokenizerZap: Hashable, Codable, Sendable {}
public struct InstructServerV2PlannerBase: Hashable, Codable, Sendable {}
public struct InstructServerV2Tokenizer: Hashable, Codable, Sendable {}
public struct InstructServerV2TokenizerPro: Hashable, Codable, Sendable {}
public struct InstructServerV2TokenizerZap: Hashable, Codable, Sendable {}
public struct IntegrityDiagnoseModel: Hashable, Codable, Sendable {}
public struct IntegrityDiagnoseModelConfigurationID: Hashable, Codable, Sendable {}
public struct IntegrityDiagnoseModelID: Hashable, Codable, Sendable {}
public struct IntelligentPassCreationInputDenyList: Hashable, Codable, Sendable {}
public struct IntelligentPassCreationOutputDenyList: Hashable, Codable, Sendable {}
public struct IntelligentRoutingRoomClassification: Hashable, Codable, Sendable {}
public struct IntelligentRoutingRoomClassificationConfigurationID: Hashable, Codable, Sendable {}
public struct IntelligentRoutingRoomClassificationID: Hashable, Codable, Sendable {}
public struct Interface: Hashable, Codable, Sendable {}
public struct JournalFollowUpPrompts: Hashable, Codable, Sendable {}
public struct JournalFollowUpPromptsConfigurationID: Hashable, Codable, Sendable {}
public struct JournalFollowUpPromptsID: Hashable, Codable, Sendable {}
public struct JournalFollowUpPromptsInputDenyList: Hashable, Codable, Sendable {}
public struct JournalFollowUpPromptsOutputDenyList: Hashable, Codable, Sendable {}
public struct JournalMomentsClassification: Hashable, Codable, Sendable {}
public struct JournalMomentsClassificationConfigurationID: Hashable, Codable, Sendable {}
public struct JournalMomentsClassificationID: Hashable, Codable, Sendable {}
public struct JournalMomentsReflection: Hashable, Codable, Sendable {}
public struct JournalMomentsReflectionConfigurationID: Hashable, Codable, Sendable {}
public struct JournalMomentsReflectionID: Hashable, Codable, Sendable {}
public struct LLMSiriDevice: Hashable, Codable, Sendable {}
public struct LLMSiriDeviceConfigurationID: Hashable, Codable, Sendable {}
public struct LLMSiriDeviceID: Hashable, Codable, Sendable {}
public struct LLMSiriPCC: Hashable, Codable, Sendable {}
public struct LLMSiriPCCConfigurationID: Hashable, Codable, Sendable {}
public struct LLMSiriPCCID: Hashable, Codable, Sendable {}
public struct LWOnDevicePlannerV1: Hashable, Codable, Sendable {}
public struct LWOnDevicePlannerV1ConfigurationID: Hashable, Codable, Sendable {}
public struct LWOnDevicePlannerV1ID: Hashable, Codable, Sendable {}
public struct LWPCCInteract: Hashable, Codable, Sendable {}
public struct LWPCCInteractConfigurationID: Hashable, Codable, Sendable {}
public struct LWPCCInteractID: Hashable, Codable, Sendable {}
public struct LWPlannerV1: Hashable, Codable, Sendable {}
public struct LWPlannerV1ConfigurationID: Hashable, Codable, Sendable {}
public struct LWPlannerV1ID: Hashable, Codable, Sendable {}
public struct LWPlannerV2: Hashable, Codable, Sendable {}
public struct LWPlannerV2ConfigurationID: Hashable, Codable, Sendable {}
public struct LWPlannerV2ID: Hashable, Codable, Sendable {}
public struct LWPlannerV3: Hashable, Codable, Sendable {}
public struct LWPlannerV3ConfigurationID: Hashable, Codable, Sendable {}
public struct LWPlannerV3ID: Hashable, Codable, Sendable {}
public struct LWPlannerV4: Hashable, Codable, Sendable {}
public struct LWPlannerV4ConfigurationID: Hashable, Codable, Sendable {}
public struct LWPlannerV4ID: Hashable, Codable, Sendable {}
public struct LWPlannerV5: Hashable, Codable, Sendable {}
public struct LWPlannerV5ConfigurationID: Hashable, Codable, Sendable {}
public struct LWPlannerV5ID: Hashable, Codable, Sendable {}
public struct LocalService: Hashable, Codable, Sendable {}
public struct Logger: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrail: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrail3B: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrail3BConfigurationID: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrail3BID: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrailConfigurationID: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrailID: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrailServer: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrailServerConfigurationID: Hashable, Codable, Sendable {}
public struct MMGuardSafetyGuardrailServerID: Hashable, Codable, Sendable {}
public struct MMSafety: Hashable, Codable, Sendable {}
public struct MMSafetyConfigurationID: Hashable, Codable, Sendable {}
public struct MMSafetyID: Hashable, Codable, Sendable {}
public struct MMTExpert: Hashable, Codable, Sendable {}
public struct MMTExpertConfigurationID: Hashable, Codable, Sendable {}
public struct MMTExpertID: Hashable, Codable, Sendable {}
public struct MacbookTracker: Hashable, Codable, Sendable {}
public struct MachineTranslation: Hashable, Codable, Sendable {}
public struct MachineTranslationConfigurationID: Hashable, Codable, Sendable {}
public struct MachineTranslationID: Hashable, Codable, Sendable {}
public struct MagicKeyboardTracker: Hashable, Codable, Sendable {}
public struct MagicRewrite: Hashable, Codable, Sendable {}
public struct MagicRewriteConfigurationID: Hashable, Codable, Sendable {}
public struct MagicRewriteID: Hashable, Codable, Sendable {}
public struct MailReply: Hashable, Codable, Sendable {}
public struct MailReplyConfigurationID: Hashable, Codable, Sendable {}
public struct MailReplyID: Hashable, Codable, Sendable {}
public struct MailReplyLongFormBasic: Hashable, Codable, Sendable {}
public struct MailReplyLongFormBasicConfigurationID: Hashable, Codable, Sendable {}
public struct MailReplyLongFormBasicID: Hashable, Codable, Sendable {}
public struct MailReplyLongFormBasicInputDenyList: Hashable, Codable, Sendable {}
public struct MailReplyLongFormBasicOutputDenyList: Hashable, Codable, Sendable {}
public struct MailReplyLongFormQAInputDenyList: Hashable, Codable, Sendable {}
public struct MailReplyLongFormQAOutputDenyList: Hashable, Codable, Sendable {}
public struct MailReplyLongFormRewrite: Hashable, Codable, Sendable {}
public struct MailReplyLongFormRewriteConfigurationID: Hashable, Codable, Sendable {}
public struct MailReplyLongFormRewriteID: Hashable, Codable, Sendable {}
public struct MailReplyLongFormRewriteInputDenyList: Hashable, Codable, Sendable {}
public struct MailReplyLongFormRewriteOutputDenyList: Hashable, Codable, Sendable {}
public struct MailReplyQA: Hashable, Codable, Sendable {}
public struct MailReplyQAConfigurationID: Hashable, Codable, Sendable {}
public struct MailReplyQAID: Hashable, Codable, Sendable {}
public struct MailReplySnippetInputDenyList: Hashable, Codable, Sendable {}
public struct MailReplySnippetOutputDenyList: Hashable, Codable, Sendable {}
public struct MaskTracker: Hashable, Codable, Sendable {}
public struct MaskTrackerConfigurationID: Hashable, Codable, Sendable {}
public struct MaskTrackerID: Hashable, Codable, Sendable {}
public struct MessagesAction: Hashable, Codable, Sendable {}
public struct MessagesActionBaseInputDenyList: Hashable, Codable, Sendable {}
public struct MessagesActionBaseOutputDenyList: Hashable, Codable, Sendable {}
public struct MessagesActionConfigurationID: Hashable, Codable, Sendable {}
public struct MessagesActionID: Hashable, Codable, Sendable {}
public struct MessagesActionSmall: Hashable, Codable, Sendable {}
public struct MessagesActionSmallConfigurationID: Hashable, Codable, Sendable {}
public struct MessagesActionSmallID: Hashable, Codable, Sendable {}
public struct MessagesBackgrounds: Hashable, Codable, Sendable {}
public struct MessagesBackgroundsConfigurationID: Hashable, Codable, Sendable {}
public struct MessagesBackgroundsID: Hashable, Codable, Sendable {}
public struct MessagesReply: Hashable, Codable, Sendable {}
public struct MessagesReplyBaseInputDenyList: Hashable, Codable, Sendable {}
public struct MessagesReplyBaseOutputDenyList: Hashable, Codable, Sendable {}
public struct MessagesReplyConfigurationID: Hashable, Codable, Sendable {}
public struct MessagesReplyID: Hashable, Codable, Sendable {}
public struct MessagesReplyWatch: Hashable, Codable, Sendable {}
public struct MessagesReplyWatchConfigurationID: Hashable, Codable, Sendable {}
public struct MessagesReplyWatchID: Hashable, Codable, Sendable {}
public struct MessagesReplyWatchInputDenyList: Hashable, Codable, Sendable {}
public struct MessagesReplyWatchOutputDenyList: Hashable, Codable, Sendable {}
public struct MessagesUserRequest: Hashable, Codable, Sendable {}
public struct MessagesUserRequestConfigurationID: Hashable, Codable, Sendable {}
public struct MessagesUserRequestID: Hashable, Codable, Sendable {}
public struct MiscSafety: Hashable, Codable, Sendable {}
public struct MiscSafetyConfigurationID: Hashable, Codable, Sendable {}
public struct MiscSafetyCustomized: Hashable, Codable, Sendable {}
public struct MiscSafetyCustomizedConfigurationID: Hashable, Codable, Sendable {}
public struct MiscSafetyCustomizedEmbeddingPreprocessor: Hashable, Codable, Sendable {}
public struct MiscSafetyCustomizedID: Hashable, Codable, Sendable {}
public struct MiscSafetyID: Hashable, Codable, Sendable {}
public struct MiscSafetyPCC: Hashable, Codable, Sendable {}
public struct ModelAbuseGuardrail: Hashable, Codable, Sendable {}
public struct ModelAbuseGuardrailConfigurationID: Hashable, Codable, Sendable {}
public struct ModelAbuseGuardrailID: Hashable, Codable, Sendable {}
public struct MotionAnomalyFM: Hashable, Codable, Sendable {}
public struct MotionAnomalyFMAdapter: Hashable, Codable, Sendable {}
public struct MotionAnomalyFMAdapterConfigurationID: Hashable, Codable, Sendable {}
public struct MotionAnomalyFMAdapterID: Hashable, Codable, Sendable {}
public struct NLRouterBase: Hashable, Codable, Sendable {}
public struct NLRouterBaseConfigurationID: Hashable, Codable, Sendable {}
public struct NLRouterBaseID: Hashable, Codable, Sendable {}
public struct NLRouterTokenizer: Hashable, Codable, Sendable {}
public struct NSCoder: Hashable, Codable, Sendable {}
public struct NSNumber: Hashable, Codable, Sendable {}
public struct NSXPCConnection: Hashable, Codable, Sendable {}
public struct NSXPCInterface: Hashable, Codable, Sendable {}
public struct NSZone: Hashable, Codable, Sendable {}
public struct NewsTopicSummarization: Hashable, Codable, Sendable {}
public struct NewsTopicSummarizationConfigurationID: Hashable, Codable, Sendable {}
public struct NewsTopicSummarizationID: Hashable, Codable, Sendable {}
public struct NotificationCoalescingInputDenyList: Hashable, Codable, Sendable {}
public struct NotificationCoalescingOutputDenyList: Hashable, Codable, Sendable {}
public struct NotifyMeWhen: Hashable, Codable, Sendable {}
public struct NotifyMeWhenConfigurationID: Hashable, Codable, Sendable {}
public struct NotifyMeWhenID: Hashable, Codable, Sendable {}
public struct NotifyMeWhenInputDenyList: Hashable, Codable, Sendable {}
public struct NotifyMeWhenOutputDenyList: Hashable, Codable, Sendable {}
public struct Nutrition: Hashable, Codable, Sendable {}
public struct NutritionConfigurationID: Hashable, Codable, Sendable {}
public struct NutritionID: Hashable, Codable, Sendable {}
public struct OpenEndedCompose: Hashable, Codable, Sendable {}
public struct OpenEndedComposeCompositionInputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedComposeCompositionOutputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedComposeCompositionPayloadDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedComposeConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedComposeID: Hashable, Codable, Sendable {}
public struct OpenEndedComposeInputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedComposeOutputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedComposeWorkflow: Hashable, Codable, Sendable {}
public struct OpenEndedComposeWorkflowConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedComposeWorkflowID: Hashable, Codable, Sendable {}
public struct OpenEndedExtract300m: Hashable, Codable, Sendable {}
public struct OpenEndedExtract300mConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedExtract300mDraft: Hashable, Codable, Sendable {}
public struct OpenEndedExtract300mDraftConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedExtract300mDraftID: Hashable, Codable, Sendable {}
public struct OpenEndedExtract300mID: Hashable, Codable, Sendable {}
public struct OpenEndedExtract3B: Hashable, Codable, Sendable {}
public struct OpenEndedExtract3BConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedExtract3BID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractInputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedExtractOutputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedExtractServer: Hashable, Codable, Sendable {}
public struct OpenEndedExtractServerConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractServerID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractServerText: Hashable, Codable, Sendable {}
public struct OpenEndedExtractServerTextConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractServerTextID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractText3B: Hashable, Codable, Sendable {}
public struct OpenEndedExtractText3BConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractText3BID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractWorkflow: Hashable, Codable, Sendable {}
public struct OpenEndedExtractWorkflowConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedExtractWorkflowID: Hashable, Codable, Sendable {}
public struct OpenEndedInteraction: Hashable, Codable, Sendable {}
public struct OpenEndedInteractionConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedInteractionID: Hashable, Codable, Sendable {}
public struct OpenEndedInteractionInputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedInteractionOutputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedReflection: Hashable, Codable, Sendable {}
public struct OpenEndedReflectionConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedReflectionID: Hashable, Codable, Sendable {}
public struct OpenEndedReflectionInputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedReflectionOutputDenyList: Hashable, Codable, Sendable {}
public struct OpenEndedSchema: Hashable, Codable, Sendable {}
public struct OpenEndedSchemaConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedSchemaID: Hashable, Codable, Sendable {}
public struct OpenEndedTone: Hashable, Codable, Sendable {}
public struct OpenEndedToneBase: Hashable, Codable, Sendable {}
public struct OpenEndedToneBaseConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedToneBaseID: Hashable, Codable, Sendable {}
public struct OpenEndedToneConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedToneID: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponse: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseID: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseV1: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseV1ConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseV1ID: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseV2: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseV2ConfigurationID: Hashable, Codable, Sendable {}
public struct OpenEndedToneQueryResponseV2ID: Hashable, Codable, Sendable {}
public struct PCCAgentClient: Hashable, Codable, Sendable {}
public struct PCCInferenceProvider: Hashable, Codable, Sendable {}
public struct PCCInteractFast: Hashable, Codable, Sendable {}
public struct PCCInteractFastConfigurationID: Hashable, Codable, Sendable {}
public struct PCCInteractFastID: Hashable, Codable, Sendable {}
public struct PCCInteractPro: Hashable, Codable, Sendable {}
public struct PCCInteractProConfigurationID: Hashable, Codable, Sendable {}
public struct PCCInteractProID: Hashable, Codable, Sendable {}
public struct PCCInteractWKA: Hashable, Codable, Sendable {}
public struct PCCInteractWKAConfigurationID: Hashable, Codable, Sendable {}
public struct PCCInteractWKAID: Hashable, Codable, Sendable {}
public struct PCCTest: Hashable, Codable, Sendable {}
public struct PCCTestConfigurationID: Hashable, Codable, Sendable {}
public struct PCCTestFast: Hashable, Codable, Sendable {}
public struct PCCTestFastConfigurationID: Hashable, Codable, Sendable {}
public struct PCCTestFastID: Hashable, Codable, Sendable {}
public struct PCCTestID: Hashable, Codable, Sendable {}
public struct PCCTestPro: Hashable, Codable, Sendable {}
public struct PCCTestProConfigurationID: Hashable, Codable, Sendable {}
public struct PCCTestProID: Hashable, Codable, Sendable {}
public struct PQAVerification: Hashable, Codable, Sendable {}
public struct PQAVerificationBase: Hashable, Codable, Sendable {}
public struct PQAVerificationBaseConfigurationID: Hashable, Codable, Sendable {}
public struct PQAVerificationBaseID: Hashable, Codable, Sendable {}
public struct PQAVerificationConfigurationID: Hashable, Codable, Sendable {}
public struct PQAVerificationID: Hashable, Codable, Sendable {}
public struct Pednet: Hashable, Codable, Sendable {}
public struct PersonInstanceSegmentation: Hashable, Codable, Sendable {}
public struct PersonInstanceSegmentationConfigurationID: Hashable, Codable, Sendable {}
public struct PersonInstanceSegmentationID: Hashable, Codable, Sendable {}
public struct PersonSegmentation: Hashable, Codable, Sendable {}
public struct PersonSegmentationConfigurationID: Hashable, Codable, Sendable {}
public struct PersonSegmentationID: Hashable, Codable, Sendable {}
public struct PersonalizedAnimation: Hashable, Codable, Sendable {}
public struct PersonalizedAnimationConfigurationID: Hashable, Codable, Sendable {}
public struct PersonalizedAnimationID: Hashable, Codable, Sendable {}
public struct PersonalizedEmoji: Hashable, Codable, Sendable {}
public struct PersonalizedEmojiConfigurationID: Hashable, Codable, Sendable {}
public struct PersonalizedEmojiID: Hashable, Codable, Sendable {}
public struct PersonalizedIllustration: Hashable, Codable, Sendable {}
public struct PersonalizedIllustrationConfigurationID: Hashable, Codable, Sendable {}
public struct PersonalizedIllustrationID: Hashable, Codable, Sendable {}
public struct PersonalizedScribble: Hashable, Codable, Sendable {}
public struct PersonalizedScribbleConfigurationID: Hashable, Codable, Sendable {}
public struct PersonalizedScribbleID: Hashable, Codable, Sendable {}
public struct PersonalizedSketch: Hashable, Codable, Sendable {}
public struct PersonalizedSketchConfigurationID: Hashable, Codable, Sendable {}
public struct PersonalizedSketchID: Hashable, Codable, Sendable {}
public struct PersonalizedSmartReply: Hashable, Codable, Sendable {}
public struct PersonalizedSmartReplyConfigurationID: Hashable, Codable, Sendable {}
public struct PersonalizedSmartReplyID: Hashable, Codable, Sendable {}
public struct PersonalizedSmartReplyInputDenyList: Hashable, Codable, Sendable {}
public struct PersonalizedSmartReplyNicknamesInputDenyList: Hashable, Codable, Sendable {}
public struct PersonalizedSmartReplyNicknamesOutputDenyList: Hashable, Codable, Sendable {}
public struct PersonalizedSmartReplyOutputDenyList: Hashable, Codable, Sendable {}
public struct PhotosCommon: Hashable, Codable, Sendable {}
public struct PhotosCommonConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosCommonID: Hashable, Codable, Sendable {}
public struct PhotosLibraryUnderstandingMM: Hashable, Codable, Sendable {}
public struct PhotosLibraryUnderstandingMMConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosLibraryUnderstandingMMID: Hashable, Codable, Sendable {}
public struct PhotosLibraryUnderstandingT2T: Hashable, Codable, Sendable {}
public struct PhotosLibraryUnderstandingT2TConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosLibraryUnderstandingT2TID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCuration: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationOutlier3b: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationOutlier3bConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationOutlier3bID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationV2: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationV2ConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationAssetCurationV2ID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationBase: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationBaseConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationBaseID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationBaseInputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationBaseOutputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitInputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitOutputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraits: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraits3b: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraits3bConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraits3bID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsV2: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsV2ConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsV2ID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsV3: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsV3ConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationGlobalTraitsV3ID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationMusicSongIdOutputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstanding: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstanding3b: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstanding3bConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstanding3bID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingV2: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingV2ConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingV2ID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingV3: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingV3ConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationQueryUnderstandingV3ID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationSensitiveOutputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStoryTitleInputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStoryTitleOutputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStoryteller: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStoryteller3b: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStoryteller3bConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStoryteller3bID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStorytellerConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStorytellerID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStorytellerV2: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStorytellerV2ConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationStorytellerV2ID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationTitle3b: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationTitle3bConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationTitle3bID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationUserQueryInputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesCreationUserQueryOutputDenyList: Hashable, Codable, Sendable {}
public struct PhotosMemoriesTitle: Hashable, Codable, Sendable {}
public struct PhotosMemoriesTitleConfigurationID: Hashable, Codable, Sendable {}
public struct PhotosMemoriesTitleID: Hashable, Codable, Sendable {}
public struct Planner: Hashable, Codable, Sendable {}
public struct PlannerConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerID: Hashable, Codable, Sendable {}
public struct PlannerV2: Hashable, Codable, Sendable {}
public struct PlannerV2ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV2ID: Hashable, Codable, Sendable {}
public struct PlannerV3: Hashable, Codable, Sendable {}
public struct PlannerV3ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV3ID: Hashable, Codable, Sendable {}
public struct PlannerV4: Hashable, Codable, Sendable {}
public struct PlannerV4ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV4ID: Hashable, Codable, Sendable {}
public struct PlannerV5: Hashable, Codable, Sendable {}
public struct PlannerV5ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV5ID: Hashable, Codable, Sendable {}
public struct PlannerV6: Hashable, Codable, Sendable {}
public struct PlannerV6ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV6ID: Hashable, Codable, Sendable {}
public struct PlannerV7: Hashable, Codable, Sendable {}
public struct PlannerV7ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV7ID: Hashable, Codable, Sendable {}
public struct PlannerV8: Hashable, Codable, Sendable {}
public struct PlannerV8ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV8ID: Hashable, Codable, Sendable {}
public struct PlannerV9: Hashable, Codable, Sendable {}
public struct PlannerV9ConfigurationID: Hashable, Codable, Sendable {}
public struct PlannerV9ID: Hashable, Codable, Sendable {}
public struct PrepubescentSafety: Hashable, Codable, Sendable {}
public struct PrepubescentSafetyConfigurationID: Hashable, Codable, Sendable {}
public struct PrepubescentSafetyCustomized: Hashable, Codable, Sendable {}
public struct PrepubescentSafetyCustomizedConfigurationID: Hashable, Codable, Sendable {}
public struct PrepubescentSafetyCustomizedEmbeddingPreprocessor: Hashable, Codable, Sendable {}
public struct PrepubescentSafetyCustomizedID: Hashable, Codable, Sendable {}
public struct PrepubescentSafetyID: Hashable, Codable, Sendable {}
public struct PrepubescentSafetyPCC: Hashable, Codable, Sendable {}
public struct PrivateCloudResearchAdapter: Hashable, Codable, Sendable {}
public struct PrivateMLClient: Hashable, Codable, Sendable {}
public struct ProfessionalTone: Hashable, Codable, Sendable {}
public struct ProfessionalToneConfigurationID: Hashable, Codable, Sendable {}
public struct ProfessionalToneID: Hashable, Codable, Sendable {}
public struct PromptAnalysis: Hashable, Codable, Sendable {}
public struct PromptAnalysisConfigurationID: Hashable, Codable, Sendable {}
public struct PromptAnalysisID: Hashable, Codable, Sendable {}
public struct PromptRewrite: Hashable, Codable, Sendable {}
public struct PromptRewriteConfigurationID: Hashable, Codable, Sendable {}
public struct PromptRewriteID: Hashable, Codable, Sendable {}
public struct ProofreadingInputDenyList: Hashable, Codable, Sendable {}
public struct ProofreadingOutputDenyList: Hashable, Codable, Sendable {}
public struct ProofreadingRetainList: Hashable, Codable, Sendable {}
public struct ProofreadingReview: Hashable, Codable, Sendable {}
public struct ProofreadingReviewConfigurationID: Hashable, Codable, Sendable {}
public struct ProofreadingReviewID: Hashable, Codable, Sendable {}
public struct Protocol: Hashable, Codable, Sendable {}
public struct PrototypeEmbeddingProvider: Hashable, Codable, Sendable {}
public struct PrototypeInferenceProvider: Hashable, Codable, Sendable {}
public struct RecognizeAnimals: Hashable, Codable, Sendable {}
public struct RecognizeAnimalsConfigurationID: Hashable, Codable, Sendable {}
public struct RecognizeAnimalsID: Hashable, Codable, Sendable {}
public struct Refiner: Hashable, Codable, Sendable {}
public struct RefinerConfigurationID: Hashable, Codable, Sendable {}
public struct RefinerID: Hashable, Codable, Sendable {}
public struct RemindersAutoCategorizeList: Hashable, Codable, Sendable {}
public struct RemindersAutoCategorizeListConfigurationID: Hashable, Codable, Sendable {}
public struct RemindersAutoCategorizeListID: Hashable, Codable, Sendable {}
public struct RemindersAutoCategorizeListOnDevice: Hashable, Codable, Sendable {}
public struct RemindersAutoCategorizeListOnDeviceConfigurationID: Hashable, Codable, Sendable {}
public struct RemindersAutoCategorizeListOnDeviceID: Hashable, Codable, Sendable {}
public struct RemindersGroceryList: Hashable, Codable, Sendable {}
public struct RemindersGroceryListConfigurationID: Hashable, Codable, Sendable {}
public struct RemindersGroceryListID: Hashable, Codable, Sendable {}
public struct RemindersSuggestActionItems: Hashable, Codable, Sendable {}
public struct RemindersSuggestActionItemsConfigurationID: Hashable, Codable, Sendable {}
public struct RemindersSuggestActionItemsID: Hashable, Codable, Sendable {}
public struct RemindersSuggestActionItemsV2: Hashable, Codable, Sendable {}
public struct RemindersSuggestActionItemsV2ConfigurationID: Hashable, Codable, Sendable {}
public struct RemindersSuggestActionItemsV2ID: Hashable, Codable, Sendable {}
public struct RemoteService: Hashable, Codable, Sendable {}
public protocol ResourceBundle_P {}
public struct ResponseGeneration: Hashable, Codable, Sendable {}
public struct ResponseGenerationConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV2: Hashable, Codable, Sendable {}
public struct ResponseGenerationV2ConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV2ID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV3: Hashable, Codable, Sendable {}
public struct ResponseGenerationV3ConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV3ID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV4: Hashable, Codable, Sendable {}
public struct ResponseGenerationV4ConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV4ID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV5: Hashable, Codable, Sendable {}
public struct ResponseGenerationV5ConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV5ID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV6: Hashable, Codable, Sendable {}
public struct ResponseGenerationV6ConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV6ID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV7: Hashable, Codable, Sendable {}
public struct ResponseGenerationV7ConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV7ID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV8: Hashable, Codable, Sendable {}
public struct ResponseGenerationV8ConfigurationID: Hashable, Codable, Sendable {}
public struct ResponseGenerationV8ID: Hashable, Codable, Sendable {}
public struct SIDInferenceProvider: Hashable, Codable, Sendable {}
public struct STXMultimodal: Hashable, Codable, Sendable {}
public struct STXMultimodalConfigurationID: Hashable, Codable, Sendable {}
public struct STXMultimodalHealthDataInputDenyList: Hashable, Codable, Sendable {}
public struct STXMultimodalHealthDataOutputDenyList: Hashable, Codable, Sendable {}
public struct STXMultimodalID: Hashable, Codable, Sendable {}
public struct STXMultimodalReceiptInputDenyList: Hashable, Codable, Sendable {}
public struct STXMultimodalReceiptOutputDenyList: Hashable, Codable, Sendable {}
public struct STXSafetyWordList: Hashable, Codable, Sendable {}
public struct SafariClusterValidation: Hashable, Codable, Sendable {}
public struct SafariClusterValidationConfigurationID: Hashable, Codable, Sendable {}
public struct SafariClusterValidationID: Hashable, Codable, Sendable {}
public struct SafariClusterValidationInputDenyList: Hashable, Codable, Sendable {}
public struct SafariClusterValidationOutputDenyList: Hashable, Codable, Sendable {}
public struct SafariMagicExtensionsAppStoreSearchTerms: Hashable, Codable, Sendable {}
public struct SafariMagicExtensionsAppStoreSearchTermsConfigurationID: Hashable, Codable, Sendable {}
public struct SafariMagicExtensionsAppStoreSearchTermsID: Hashable, Codable, Sendable {}
public struct SafariMagicExtensionsInputDenyList: Hashable, Codable, Sendable {}
public struct SafariMagicExtensionsOutputDenyList: Hashable, Codable, Sendable {}
public struct SafariNotifyMeWhenSuggestions: Hashable, Codable, Sendable {}
public struct SafariNotifyMeWhenSuggestionsConfigurationID: Hashable, Codable, Sendable {}
public struct SafariNotifyMeWhenSuggestionsID: Hashable, Codable, Sendable {}
public struct SafariPhishingClassification: Hashable, Codable, Sendable {}
public struct SafariPhishingClassificationConfigurationID: Hashable, Codable, Sendable {}
public struct SafariPhishingClassificationID: Hashable, Codable, Sendable {}
public struct SafariSafeBrowsingInputDenyList: Hashable, Codable, Sendable {}
public struct SafariSafeBrowsingOutputDenyList: Hashable, Codable, Sendable {}
public struct SafariTabGroupTopic: Hashable, Codable, Sendable {}
public struct SafariTabGroupTopicConfigurationID: Hashable, Codable, Sendable {}
public struct SafariTabGroupTopicID: Hashable, Codable, Sendable {}
public struct SafetyConfigurationID: Hashable, Codable, Sendable {}
public struct SafetyGuardrail: Hashable, Codable, Sendable {}
public struct SafetyGuardrailConfigurationID: Hashable, Codable, Sendable {}
public struct SafetyGuardrailID: Hashable, Codable, Sendable {}
public struct SafetyID: Hashable, Codable, Sendable {}
public struct SafetyNSFW: Hashable, Codable, Sendable {}
public struct SafetyNSFWConfigurationID: Hashable, Codable, Sendable {}
public struct SafetyNSFWID: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationConfigurationID: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationID: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationMMGuard: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationMMGuardConfigurationID: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationMMGuardID: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationNSFW: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationNSFWConfigurationID: Hashable, Codable, Sendable {}
public struct SafetyOutputConfigurationNSFWID: Hashable, Codable, Sendable {}
public struct Scribble: Hashable, Codable, Sendable {}
public struct ScribbleConfigurationID: Hashable, Codable, Sendable {}
public struct ScribbleID: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingOnDevice: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingOnDeviceConfigurationID: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingOnDeviceID: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingServer: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingServerConfigurationID: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingServerID: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingServerV2: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingServerV2ConfigurationID: Hashable, Codable, Sendable {}
public struct SearchQueryUnderstandingServerV2ID: Hashable, Codable, Sendable {}
public struct SemanticSearchInputDenyList: Hashable, Codable, Sendable {}
public struct SequoiaMMAlignmentModel: Hashable, Codable, Sendable {}
public struct SequoiaMMPhrasebookAsset: Hashable, Codable, Sendable {}
public struct ServerBulletsTransform: Hashable, Codable, Sendable {}
public struct ServerBulletsTransformConfigurationID: Hashable, Codable, Sendable {}
public struct ServerBulletsTransformID: Hashable, Codable, Sendable {}
public struct ServerConciseTone: Hashable, Codable, Sendable {}
public struct ServerConciseToneConfigurationID: Hashable, Codable, Sendable {}
public struct ServerConciseToneID: Hashable, Codable, Sendable {}
public struct ServerDescribeYourEdit: Hashable, Codable, Sendable {}
public struct ServerDescribeYourEditConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDescribeYourEditID: Hashable, Codable, Sendable {}
public struct ServerDiffusionANFREncoderLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionANFREncoderV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionAlphaMaskDecoderLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionAlphaMaskDecoderV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionAutoEncoderV10: Hashable, Codable, Sendable {}
public struct ServerDiffusionDirectManipulation: Hashable, Codable, Sendable {}
public struct ServerDiffusionDirectManipulationConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDirectManipulationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDirectManipulationLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionDirectManipulationLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDirectManipulationLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDirectManipulationSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionDrawingConditioner: Hashable, Codable, Sendable {}
public struct ServerDiffusionDrawingConditionerConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDrawingConditionerID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDrawingConditionerLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionDrawingConditionerLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDrawingConditionerLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionDrawingConditionerSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionGenmoji: Hashable, Codable, Sendable {}
public struct ServerDiffusionGenmojiConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionGenmojiID: Hashable, Codable, Sendable {}
public struct ServerDiffusionGenmojiLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionGenmojiLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionGenmojiLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionInpainting: Hashable, Codable, Sendable {}
public struct ServerDiffusionInpaintingConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionInpaintingID: Hashable, Codable, Sendable {}
public struct ServerDiffusionInpaintingLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionInpaintingLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionInpaintingLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionInpaintingSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionMessagesBackground: Hashable, Codable, Sendable {}
public struct ServerDiffusionMessagesBackgroundConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionMessagesBackgroundID: Hashable, Codable, Sendable {}
public struct ServerDiffusionMessagesBackgroundLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionMessagesBackgroundLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionMessagesBackgroundLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionMessagesBackgroundSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionNoisePredictorLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionNoisePredictorV10: Hashable, Codable, Sendable {}
public struct ServerDiffusionNoisePredictorV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionOutpainting: Hashable, Codable, Sendable {}
public struct ServerDiffusionOutpaintingConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionOutpaintingID: Hashable, Codable, Sendable {}
public struct ServerDiffusionOutpaintingLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionOutpaintingLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionOutpaintingLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionOutpaintingSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalization: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationGenmoji: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationGenmojiConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationGenmojiID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationGenmojiLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationGenmojiLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationGenmojiLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionPersonalizationSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframing: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingID: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingVAEDecoder: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingVAEDecoderLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionSpatialReframingVAEDecoderV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionSynthIDLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextEncoderLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextEncoderV10: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextEncoderV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextGuidedEdit: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextGuidedEditConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextGuidedEditID: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextGuidedEditImageTokenizer: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextGuidedEditNoisePredictor: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextGuidedEditTextEncoder: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextGuidedEditTokenizer: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextToImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextToImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextToImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextToImageLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextToImageLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionTextToImageLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionTokenizerLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionTokenizerV10: Hashable, Codable, Sendable {}
public struct ServerDiffusionTokenizerV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionUpResolution: Hashable, Codable, Sendable {}
public struct ServerDiffusionUpResolutionConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionUpResolutionID: Hashable, Codable, Sendable {}
public struct ServerDiffusionUpResolutionLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionUpResolutionLargeImageConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionUpResolutionLargeImageID: Hashable, Codable, Sendable {}
public struct ServerDiffusionUpResolutionSmallV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionV10Base: Hashable, Codable, Sendable {}
public struct ServerDiffusionV10BaseConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV10BaseID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1Base: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1BaseConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1BaseID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1DirectManipulationSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1DirectManipulationSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1DirectManipulationSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1DrawingConditionerSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1DrawingConditionerSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1DrawingConditionerSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1Genmoji: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1GenmojiConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1GenmojiID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1InpaintingSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1InpaintingSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1InpaintingSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1MessagesBackgroundSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1MessagesBackgroundSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1MessagesBackgroundSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1OutpaintingSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1OutpaintingSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1OutpaintingSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1PersonalizationGenmoji: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1PersonalizationGenmojiConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1PersonalizationGenmojiID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1PersonalizationSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1PersonalizationSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1PersonalizationSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1SpatialReframingSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1SpatialReframingSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1SpatialReframingSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1UpResolutionSmall: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1UpResolutionSmallConfigurationID: Hashable, Codable, Sendable {}
public struct ServerDiffusionV11_1UpResolutionSmallID: Hashable, Codable, Sendable {}
public struct ServerDiffusionVAEDecoderLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionVAEDecoderV11_1: Hashable, Codable, Sendable {}
public struct ServerDiffusionVAEEncoderLargeImage: Hashable, Codable, Sendable {}
public struct ServerDiffusionVAEEncoderV11_1: Hashable, Codable, Sendable {}
public struct ServerFitnessWorkoutVoice: Hashable, Codable, Sendable {}
public struct ServerFitnessWorkoutVoiceConfigurationID: Hashable, Codable, Sendable {}
public struct ServerFitnessWorkoutVoiceID: Hashable, Codable, Sendable {}
public struct ServerFriendlyTone: Hashable, Codable, Sendable {}
public struct ServerFriendlyToneConfigurationID: Hashable, Codable, Sendable {}
public struct ServerFriendlyToneID: Hashable, Codable, Sendable {}
public struct ServerMagicRewrite: Hashable, Codable, Sendable {}
public struct ServerMagicRewriteConfigurationID: Hashable, Codable, Sendable {}
public struct ServerMagicRewriteID: Hashable, Codable, Sendable {}
public struct ServerMailReplyLongFormBasic: Hashable, Codable, Sendable {}
public struct ServerMailReplyLongFormBasicConfigurationID: Hashable, Codable, Sendable {}
public struct ServerMailReplyLongFormBasicID: Hashable, Codable, Sendable {}
public struct ServerMailReplyLongFormRewrite: Hashable, Codable, Sendable {}
public struct ServerMailReplyLongFormRewriteConfigurationID: Hashable, Codable, Sendable {}
public struct ServerMailReplyLongFormRewriteID: Hashable, Codable, Sendable {}
public struct ServerMailReplyQA: Hashable, Codable, Sendable {}
public struct ServerMailReplyQAConfigurationID: Hashable, Codable, Sendable {}
public struct ServerMailReplyQAID: Hashable, Codable, Sendable {}
public struct ServerPQAVerification: Hashable, Codable, Sendable {}
public struct ServerPQAVerificationConfigurationID: Hashable, Codable, Sendable {}
public struct ServerPQAVerificationID: Hashable, Codable, Sendable {}
public struct ServerPersonalizedSmartReply: Hashable, Codable, Sendable {}
public struct ServerPersonalizedSmartReplyConfigurationID: Hashable, Codable, Sendable {}
public struct ServerPersonalizedSmartReplyID: Hashable, Codable, Sendable {}
public struct ServerProfessionalTone: Hashable, Codable, Sendable {}
public struct ServerProfessionalToneConfigurationID: Hashable, Codable, Sendable {}
public struct ServerProfessionalToneID: Hashable, Codable, Sendable {}
public struct ServerProofreadingReview: Hashable, Codable, Sendable {}
public struct ServerProofreadingReviewConfigurationID: Hashable, Codable, Sendable {}
public struct ServerProofreadingReviewID: Hashable, Codable, Sendable {}
public struct ServerSmallActionValidator: Hashable, Codable, Sendable {}
public struct ServerSmallActionValidatorConfigurationID: Hashable, Codable, Sendable {}
public struct ServerSmallActionValidatorID: Hashable, Codable, Sendable {}
public struct ServerSmallIPIClassifier: Hashable, Codable, Sendable {}
public struct ServerSmallIPIClassifierConfigurationID: Hashable, Codable, Sendable {}
public struct ServerSmallIPIClassifierID: Hashable, Codable, Sendable {}
public struct ServerStructuredExtraction: Hashable, Codable, Sendable {}
public struct ServerStructuredExtractionConfigurationID: Hashable, Codable, Sendable {}
public struct ServerStructuredExtractionID: Hashable, Codable, Sendable {}
public struct ServerTablesTransform: Hashable, Codable, Sendable {}
public struct ServerTablesTransformConfigurationID: Hashable, Codable, Sendable {}
public struct ServerTablesTransformID: Hashable, Codable, Sendable {}
public struct ServerTakeawaysTransform: Hashable, Codable, Sendable {}
public struct ServerTakeawaysTransformConfigurationID: Hashable, Codable, Sendable {}
public struct ServerTakeawaysTransformID: Hashable, Codable, Sendable {}
public struct ServerV2AFMImageTokenizer: Hashable, Codable, Sendable {}
public struct ServerV2AccessibilityMagnifier: Hashable, Codable, Sendable {}
public struct ServerV2AccessibilityMagnifierConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2AccessibilityMagnifierID: Hashable, Codable, Sendable {}
public struct ServerV2AccessibilityReaderAI: Hashable, Codable, Sendable {}
public struct ServerV2AccessibilityReaderAIConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2AccessibilityReaderAIID: Hashable, Codable, Sendable {}
public struct ServerV2AgeEstimation: Hashable, Codable, Sendable {}
public struct ServerV2AgeEstimationConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2AgeEstimationID: Hashable, Codable, Sendable {}
public struct ServerV2AgeVerification: Hashable, Codable, Sendable {}
public struct ServerV2AgeVerificationConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2AgeVerificationID: Hashable, Codable, Sendable {}
public struct ServerV2AntiSpoofing: Hashable, Codable, Sendable {}
public struct ServerV2AntiSpoofingConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2AntiSpoofingID: Hashable, Codable, Sendable {}
public struct ServerV2Autograder: Hashable, Codable, Sendable {}
public struct ServerV2AutograderConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2AutograderID: Hashable, Codable, Sendable {}
public struct ServerV2BulletsTransform: Hashable, Codable, Sendable {}
public struct ServerV2BulletsTransformConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2BulletsTransformExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2BulletsTransformExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2BulletsTransformExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2BulletsTransformID: Hashable, Codable, Sendable {}
public struct ServerV2CalendarMagicComposeBackwardPass: Hashable, Codable, Sendable {}
public struct ServerV2CalendarMagicComposeBackwardPassConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2CalendarMagicComposeBackwardPassID: Hashable, Codable, Sendable {}
public struct ServerV2ChangePasswordForMe: Hashable, Codable, Sendable {}
public struct ServerV2ChangePasswordForMeConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ChangePasswordForMeID: Hashable, Codable, Sendable {}
public struct ServerV2ConciseTone: Hashable, Codable, Sendable {}
public struct ServerV2ConciseToneConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ConciseToneExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2ConciseToneExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ConciseToneExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2ConciseToneID: Hashable, Codable, Sendable {}
public struct ServerV2FitnessWorkoutVoice: Hashable, Codable, Sendable {}
public struct ServerV2FitnessWorkoutVoiceConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2FitnessWorkoutVoiceID: Hashable, Codable, Sendable {}
public struct ServerV2FriendlyTone: Hashable, Codable, Sendable {}
public struct ServerV2FriendlyToneConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2FriendlyToneExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2FriendlyToneExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2FriendlyToneExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2FriendlyToneID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcuts: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV12: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV12ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV12ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV13: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV13ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV13ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV14: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV14ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV14ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV15: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV15ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV15ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV16: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV16ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV16ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV17: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV17ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV17ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV18: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV18ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV18ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV19: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV19ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV19ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV20: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV20ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV20ID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV21: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV21ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2GenerativeShortcutsV21ID: Hashable, Codable, Sendable {}
public struct ServerV2HKSVProcessingCaptions: Hashable, Codable, Sendable {}
public struct ServerV2HKSVProcessingCaptionsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2HKSVProcessingCaptionsID: Hashable, Codable, Sendable {}
public struct ServerV2HKSVProcessingCaptionsPro: Hashable, Codable, Sendable {}
public struct ServerV2HKSVProcessingCaptionsProConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2HKSVProcessingCaptionsProID: Hashable, Codable, Sendable {}
public struct ServerV2HomeKitSummaryNotifications: Hashable, Codable, Sendable {}
public struct ServerV2HomeKitSummaryNotificationsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2HomeKitSummaryNotificationsID: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailEventExtraction: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailEventExtractionConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailEventExtractionID: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailOrderBundling: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailOrderBundlingConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailOrderBundlingID: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailSemanticSearch: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailSemanticSearchConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ICloudMailSemanticSearchID: Hashable, Codable, Sendable {}
public struct ServerV2ImagePlaygroundMultimodalInputSafety: Hashable, Codable, Sendable {}
public struct ServerV2ImagePlaygroundMultimodalInputSafetyConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ImagePlaygroundMultimodalInputSafetyID: Hashable, Codable, Sendable {}
public struct ServerV2InsightAgents: Hashable, Codable, Sendable {}
public struct ServerV2InsightAgentsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2InsightAgentsID: Hashable, Codable, Sendable {}
public struct ServerV2IntelligentPassCreation: Hashable, Codable, Sendable {}
public struct ServerV2IntelligentPassCreationConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2IntelligentPassCreationID: Hashable, Codable, Sendable {}
public struct ServerV2JournalFollowUpPrompts: Hashable, Codable, Sendable {}
public struct ServerV2JournalFollowUpPromptsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2JournalFollowUpPromptsID: Hashable, Codable, Sendable {}
public struct ServerV2MailProfileCreation: Hashable, Codable, Sendable {}
public struct ServerV2MailProfileCreationConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2MailProfileCreationExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2MailProfileCreationExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2MailProfileCreationExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2MailProfileCreationID: Hashable, Codable, Sendable {}
public struct ServerV2MiscSafety: Hashable, Codable, Sendable {}
public struct ServerV2MiscSafetyConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2MiscSafetyID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedCompose: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedComposeConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedComposeExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedComposeExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedComposeExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedComposeID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedExtract: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedExtractConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedExtractID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedInteraction: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedInteractionConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedInteractionExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedInteractionExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedInteractionExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedInteractionID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedTone: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedToneConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2OpenEndedToneID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationAssetCurationV2: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationAssetCurationV2ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationAssetCurationV2ID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationGlobalTraitsV2: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationGlobalTraitsV2ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationGlobalTraitsV2ID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationGlobalTraitsV3: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationGlobalTraitsV3ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationGlobalTraitsV3ID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationQueryUnderstandingV3: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationQueryUnderstandingV3ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationQueryUnderstandingV3ID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationStorytellerV2: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationStorytellerV2ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2PhotosMemoriesCreationStorytellerV2ID: Hashable, Codable, Sendable {}
public struct ServerV2PrepubescentSafety: Hashable, Codable, Sendable {}
public struct ServerV2PrepubescentSafetyConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2PrepubescentSafetyID: Hashable, Codable, Sendable {}
public struct ServerV2ProfessionalTone: Hashable, Codable, Sendable {}
public struct ServerV2ProfessionalToneConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ProfessionalToneExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2ProfessionalToneExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ProfessionalToneExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2ProfessionalToneID: Hashable, Codable, Sendable {}
public struct ServerV2PromptRewrite: Hashable, Codable, Sendable {}
public struct ServerV2PromptRewriteConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2PromptRewriteID: Hashable, Codable, Sendable {}
public struct ServerV2Proofreading: Hashable, Codable, Sendable {}
public struct ServerV2ProofreadingConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ProofreadingExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2ProofreadingExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ProofreadingExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2ProofreadingID: Hashable, Codable, Sendable {}
public struct ServerV2RemindersAutoCategorizeList: Hashable, Codable, Sendable {}
public struct ServerV2RemindersAutoCategorizeListConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2RemindersAutoCategorizeListID: Hashable, Codable, Sendable {}
public struct ServerV2STXMultimodal: Hashable, Codable, Sendable {}
public struct ServerV2STXMultimodalConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2STXMultimodalID: Hashable, Codable, Sendable {}
public struct ServerV2SafariMagicExtensions: Hashable, Codable, Sendable {}
public struct ServerV2SafariMagicExtensionsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SafariMagicExtensionsID: Hashable, Codable, Sendable {}
public struct ServerV2SafariSafeBrowsing: Hashable, Codable, Sendable {}
public struct ServerV2SafariSafeBrowsingConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SafariSafeBrowsingID: Hashable, Codable, Sendable {}
public struct ServerV2SafariTabGroupTopic: Hashable, Codable, Sendable {}
public struct ServerV2SafariTabGroupTopicConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SafariTabGroupTopicID: Hashable, Codable, Sendable {}
public struct ServerV2ShortcutsAskAFMActionV2: Hashable, Codable, Sendable {}
public struct ServerV2ShortcutsAskAFMActionV2ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ShortcutsAskAFMActionV2ID: Hashable, Codable, Sendable {}
public struct ServerV2ShortcutsUseModelAction: Hashable, Codable, Sendable {}
public struct ServerV2ShortcutsUseModelActionConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2ShortcutsUseModelActionID: Hashable, Codable, Sendable {}
public struct ServerV2SiriVisualIntelligence: Hashable, Codable, Sendable {}
public struct ServerV2SiriVisualIntelligenceConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SiriVisualIntelligenceID: Hashable, Codable, Sendable {}
public struct ServerV2SketchCaptioning: Hashable, Codable, Sendable {}
public struct ServerV2SketchCaptioningConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SketchCaptioningID: Hashable, Codable, Sendable {}
public struct ServerV2StructuralIntegrity: Hashable, Codable, Sendable {}
public struct ServerV2StructuralIntegrityConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2StructuralIntegrityID: Hashable, Codable, Sendable {}
public struct ServerV2SummarizationTextSummarizer: Hashable, Codable, Sendable {}
public struct ServerV2SummarizationTextSummarizerConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SummarizationTextSummarizerExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2SummarizationTextSummarizerExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SummarizationTextSummarizerExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2SummarizationTextSummarizerID: Hashable, Codable, Sendable {}
public struct ServerV2SummarizeShortcuts: Hashable, Codable, Sendable {}
public struct ServerV2SummarizeShortcutsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2SummarizeShortcutsID: Hashable, Codable, Sendable {}
public struct ServerV2TablesTransform: Hashable, Codable, Sendable {}
public struct ServerV2TablesTransformConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2TablesTransformExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2TablesTransformExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2TablesTransformExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2TablesTransformID: Hashable, Codable, Sendable {}
public struct ServerV2TakeawaysTransform: Hashable, Codable, Sendable {}
public struct ServerV2TakeawaysTransformConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2TakeawaysTransformExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2TakeawaysTransformExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2TakeawaysTransformExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2TakeawaysTransformID: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceNutrition: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceNutritionConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceNutritionID: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceSuggestedQuestions: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceSuggestedQuestionsConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceSuggestedQuestionsID: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceSuggestedQuestionsInputDenyList: Hashable, Codable, Sendable {}
public struct ServerV2VisualIntelligenceSuggestedQuestionsOutputDenyList: Hashable, Codable, Sendable {}
public struct ServerV2WritingQuestionAnswer: Hashable, Codable, Sendable {}
public struct ServerV2WritingQuestionAnswerConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2WritingQuestionAnswerExperiment1: Hashable, Codable, Sendable {}
public struct ServerV2WritingQuestionAnswerExperiment1ConfigurationID: Hashable, Codable, Sendable {}
public struct ServerV2WritingQuestionAnswerExperiment1ID: Hashable, Codable, Sendable {}
public struct ServerV2WritingQuestionAnswerID: Hashable, Codable, Sendable {}
public struct Service: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3B: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3BConfigurationID: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3BID: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3BInputDenyList: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3BOutputDenyList: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3BV2: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3BV2ConfigurationID: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMAction3BV2ID: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMActionConfigurationID: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMActionID: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMActionInputDenyList: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMActionOutputDenyList: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMActionV2: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMActionV2ConfigurationID: Hashable, Codable, Sendable {}
public struct ShortcutsAskAFMActionV2ID: Hashable, Codable, Sendable {}
public struct ShortcutsGeneratorToolRetrieval: Hashable, Codable, Sendable {}
public struct ShortcutsGeneratorToolRetrievalConfigurationID: Hashable, Codable, Sendable {}
public struct ShortcutsGeneratorToolRetrievalID: Hashable, Codable, Sendable {}
public struct ShortcutsUseModelActionPro: Hashable, Codable, Sendable {}
public struct ShortcutsUseModelActionProConfigurationID: Hashable, Codable, Sendable {}
public struct ShortcutsUseModelActionProID: Hashable, Codable, Sendable {}
public struct SiriTTSVoiceNatural: Hashable, Codable, Sendable {}
public struct SiriTTSVoiceNaturalConfigurationID: Hashable, Codable, Sendable {}
public struct SiriTTSVoiceNaturalID: Hashable, Codable, Sendable {}
public struct SiriUserExperienceAnalysis: Hashable, Codable, Sendable {}
public struct SiriUserExperienceAnalysisConfigurationID: Hashable, Codable, Sendable {}
public struct SiriUserExperienceAnalysisID: Hashable, Codable, Sendable {}
public struct Sketch: Hashable, Codable, Sendable {}
public struct SketchCaptioningInputDenyList: Hashable, Codable, Sendable {}
public struct SketchCaptioningOutputDenyList: Hashable, Codable, Sendable {}
public struct SketchConfigurationID: Hashable, Codable, Sendable {}
public struct SketchID: Hashable, Codable, Sendable {}
public struct SkinToneEmoji: Hashable, Codable, Sendable {}
public struct SkinToneEmojiConfigurationID: Hashable, Codable, Sendable {}
public struct SkinToneEmojiID: Hashable, Codable, Sendable {}
public struct SmallMessagesReplyWatch: Hashable, Codable, Sendable {}
public struct SmallMessagesReplyWatchConfigurationID: Hashable, Codable, Sendable {}
public struct SmallMessagesReplyWatchID: Hashable, Codable, Sendable {}
public struct SmartAppActions: Hashable, Codable, Sendable {}
public struct SmartAppActionsConfigurationID: Hashable, Codable, Sendable {}
public struct SmartAppActionsID: Hashable, Codable, Sendable {}
public struct SmartNaming: Hashable, Codable, Sendable {}
public struct SmartNamingConfigurationID: Hashable, Codable, Sendable {}
public struct SmartNamingID: Hashable, Codable, Sendable {}
public struct SmartNamingInputDenyList: Hashable, Codable, Sendable {}
public struct SmartNamingOutputDenyList: Hashable, Codable, Sendable {}
public struct SmudgeDetection: Hashable, Codable, Sendable {}
public struct SmudgeDetectionConfigurationID: Hashable, Codable, Sendable {}
public struct SmudgeDetectionID: Hashable, Codable, Sendable {}
public struct SpatialPhotosReliveBuiltin: Hashable, Codable, Sendable {}
public struct SpatialPhotosReliveBuiltinConfigurationID: Hashable, Codable, Sendable {}
public struct SpatialPhotosReliveBuiltinID: Hashable, Codable, Sendable {}
public struct SpatialPhotosReliveMain: Hashable, Codable, Sendable {}
public struct SpatialPhotosReliveMainConfigurationID: Hashable, Codable, Sendable {}
public struct SpatialPhotosReliveMainID: Hashable, Codable, Sendable {}
public struct SpeechDetokenizerV1: Hashable, Codable, Sendable {}
public struct SpeechSynthesisSpeechDetokenizer: Hashable, Codable, Sendable {}
public struct SpeechSynthesisSpeechTokenizer: Hashable, Codable, Sendable {}
public struct SpeechSynthesisV7: Hashable, Codable, Sendable {}
public struct SpeechSynthesisV7Base: Hashable, Codable, Sendable {}
public struct SpeechSynthesisV7BaseConfigurationID: Hashable, Codable, Sendable {}
public struct SpeechSynthesisV7BaseID: Hashable, Codable, Sendable {}
public struct SpeechToSpeech: Hashable, Codable, Sendable {}
public struct SpeechToSpeechBase: Hashable, Codable, Sendable {}
public struct SpeechToSpeechConfigurationID: Hashable, Codable, Sendable {}
public struct SpeechToSpeechID: Hashable, Codable, Sendable {}
public struct SpeechTokenizerV1: Hashable, Codable, Sendable {}
public struct StructuralExtraction: Hashable, Codable, Sendable {}
public struct StructuralExtractionConfigurationID: Hashable, Codable, Sendable {}
public struct StructuralExtractionID: Hashable, Codable, Sendable {}
public struct StructuralIntegrity: Hashable, Codable, Sendable {}
public struct StructuralIntegrityConfigurationID: Hashable, Codable, Sendable {}
public struct StructuralIntegrityCustomized: Hashable, Codable, Sendable {}
public struct StructuralIntegrityCustomizedConfigurationID: Hashable, Codable, Sendable {}
public struct StructuralIntegrityCustomizedEmbeddingPreprocessor: Hashable, Codable, Sendable {}
public struct StructuralIntegrityCustomizedID: Hashable, Codable, Sendable {}
public struct StructuralIntegrityID: Hashable, Codable, Sendable {}
public struct StructuralIntegrityPCC: Hashable, Codable, Sendable {}
public struct StructuredExtraction: Hashable, Codable, Sendable {}
public struct StructuredExtractionConfigurationID: Hashable, Codable, Sendable {}
public struct StructuredExtractionID: Hashable, Codable, Sendable {}
public struct SuggestRecipeItems: Hashable, Codable, Sendable {}
public struct SuggestRecipeItemsConfigurationID: Hashable, Codable, Sendable {}
public struct SuggestRecipeItemsID: Hashable, Codable, Sendable {}
public struct SuggestRecipeItemsV2: Hashable, Codable, Sendable {}
public struct SuggestRecipeItemsV2ConfigurationID: Hashable, Codable, Sendable {}
public struct SuggestRecipeItemsV2ID: Hashable, Codable, Sendable {}
public struct Summarization: Hashable, Codable, Sendable {}
public struct SummarizationConfigurationID: Hashable, Codable, Sendable {}
public struct SummarizationID: Hashable, Codable, Sendable {}
public struct SummarizationKitBaseInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitBaseOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUSummaryInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUSummaryOnDemandInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUSummaryOnDemandOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUSummaryOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUSummaryProactiveInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUSummaryProactiveOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUUrgencyInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitCUUrgencyOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitSafariTabGroupTopicInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitSafariTabGroupTopicOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitTextAssistantInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitTextAssistantOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitVisualIntelligenceCameraInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitVisualIntelligenceCameraOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitVisualPromptInputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationKitVisualPromptOutputDenyList: Hashable, Codable, Sendable {}
public struct SummarizationTextSummarizer: Hashable, Codable, Sendable {}
public struct SummarizationTextSummarizerAjaxBase: Hashable, Codable, Sendable {}
public struct SummarizationTextSummarizerAjaxBaseConfigurationID: Hashable, Codable, Sendable {}
public struct SummarizationTextSummarizerAjaxBaseID: Hashable, Codable, Sendable {}
public struct SummarizationTextSummarizerBase: Hashable, Codable, Sendable {}
public struct SummarizationTextSummarizerConfigurationID: Hashable, Codable, Sendable {}
public struct SummarizationTextSummarizerID: Hashable, Codable, Sendable {}
public struct SummarizeShortcuts: Hashable, Codable, Sendable {}
public struct SummarizeShortcutsConfigurationID: Hashable, Codable, Sendable {}
public struct SummarizeShortcutsID: Hashable, Codable, Sendable {}
public struct SuperAutofillMultimodal: Hashable, Codable, Sendable {}
public struct SuperAutofillMultimodalConfigurationID: Hashable, Codable, Sendable {}
public struct SuperAutofillMultimodalID: Hashable, Codable, Sendable {}
public struct SuperAutofillMultimodalInputDenyList: Hashable, Codable, Sendable {}
public struct SuperAutofillMultimodalOutputDenyList: Hashable, Codable, Sendable {}
public struct TTSVoicesOverrides: Hashable, Codable, Sendable {}
public struct TTSVoicesOverridesConfigurationID: Hashable, Codable, Sendable {}
public struct TTSVoicesOverridesID: Hashable, Codable, Sendable {}
public struct TablesTransform: Hashable, Codable, Sendable {}
public struct TablesTransformConfigurationID: Hashable, Codable, Sendable {}
public struct TablesTransformID: Hashable, Codable, Sendable {}
public struct TakeawaysTransform: Hashable, Codable, Sendable {}
public struct TakeawaysTransformConfigurationID: Hashable, Codable, Sendable {}
public struct TakeawaysTransformID: Hashable, Codable, Sendable {}
public struct TamalePOI: Hashable, Codable, Sendable {}
public struct TamalePOIConfigurationID: Hashable, Codable, Sendable {}
public struct TamalePOIID: Hashable, Codable, Sendable {}
public struct TestAsset1: Hashable, Codable, Sendable {}
public struct TestAsset2: Hashable, Codable, Sendable {}
public struct TestAsset3: Hashable, Codable, Sendable {}
public struct TextEventExtraction: Hashable, Codable, Sendable {}
public struct TextEventExtractionClassifier: Hashable, Codable, Sendable {}
public struct TextEventExtractionClassifierConfigurationID: Hashable, Codable, Sendable {}
public struct TextEventExtractionClassifierID: Hashable, Codable, Sendable {}
public struct TextEventExtractionClassifierTokenizer: Hashable, Codable, Sendable {}
public struct TextEventExtractionConfigurationID: Hashable, Codable, Sendable {}
public struct TextEventExtractionDraft: Hashable, Codable, Sendable {}
public struct TextEventExtractionDraftConfigurationID: Hashable, Codable, Sendable {}
public struct TextEventExtractionDraftID: Hashable, Codable, Sendable {}
public struct TextEventExtractionID: Hashable, Codable, Sendable {}
public struct TextExpert: Hashable, Codable, Sendable {}
public struct TextExpertConfigurationID: Hashable, Codable, Sendable {}
public struct TextExpertID: Hashable, Codable, Sendable {}
public struct TextGuardSafetyGuardrail: Hashable, Codable, Sendable {}
public struct TextGuardSafetyGuardrailConfigurationID: Hashable, Codable, Sendable {}
public struct TextGuardSafetyGuardrailID: Hashable, Codable, Sendable {}
public struct TextPersonExtraction: Hashable, Codable, Sendable {}
public struct TextPersonExtractionConfigurationID: Hashable, Codable, Sendable {}
public struct TextPersonExtractionDraft: Hashable, Codable, Sendable {}
public struct TextPersonExtractionDraftConfigurationID: Hashable, Codable, Sendable {}
public struct TextPersonExtractionDraftID: Hashable, Codable, Sendable {}
public struct TextPersonExtractionID: Hashable, Codable, Sendable {}
public struct TextSummarizer: Hashable, Codable, Sendable {}
public struct Textunderstanding: Hashable, Codable, Sendable {}
public struct TextunderstandingDraft: Hashable, Codable, Sendable {}
public struct TextunderstandingDraftConfigurationID: Hashable, Codable, Sendable {}
public struct TextunderstandingDraftID: Hashable, Codable, Sendable {}
public struct TokenGenerationInference: Hashable, Codable, Sendable {}
public struct TokenInputDenyListTemplate: Hashable, Codable, Sendable {}
public struct TokenInputDenyListTemplateConfigurationID: Hashable, Codable, Sendable {}
public struct TokenInputDenyListTemplateID: Hashable, Codable, Sendable {}
public struct TokenOutputDenyListTemplate: Hashable, Codable, Sendable {}
public struct TokenOutputDenyListTemplateConfigurationID: Hashable, Codable, Sendable {}
public struct TokenOutputDenyListTemplateID: Hashable, Codable, Sendable {}
public struct TokenOutputDenyListWithDefaultsTemplate: Hashable, Codable, Sendable {}
public struct TokenOutputDenyListWithDefaultsTemplateConfigurationID: Hashable, Codable, Sendable {}
public struct TokenOutputDenyListWithDefaultsTemplateID: Hashable, Codable, Sendable {}
public struct TokenOutputRetainListStructureExtractionSafetyWordList: Hashable, Codable, Sendable {}
public struct TokenOutputRetainListStructureExtractionSafetyWordListConfigurationID: Hashable, Codable, Sendable {}
public struct TokenOutputRetainListStructureExtractionSafetyWordListID: Hashable, Codable, Sendable {}
public struct TokenOutputRetainListWithDefaultsTemplate: Hashable, Codable, Sendable {}
public struct TokenOutputRetainListWithDefaultsTemplateConfigurationID: Hashable, Codable, Sendable {}
public struct TokenOutputRetainListWithDefaultsTemplateID: Hashable, Codable, Sendable {}
public struct TokenizerType: Hashable, Codable, Sendable {}
public struct TranslateFMMachineTranslationAlignmentModel: Hashable, Codable, Sendable {}
public struct TranslateFMMachineTranslationPhrasebookAsset: Hashable, Codable, Sendable {}
public struct UAFAssetSetConsistencyToken: Hashable, Codable, Sendable {}
public struct UAFSubscriptionDownloadStatus: Hashable, Codable, Sendable {}
public struct UIGrounding: Hashable, Codable, Sendable {}
public struct UIGroundingConfigurationID: Hashable, Codable, Sendable {}
public struct UIGroundingID: Hashable, Codable, Sendable {}
public struct UIPreviews: Hashable, Codable, Sendable {}
public struct UIPreviewsConfigurationID: Hashable, Codable, Sendable {}
public struct UIPreviewsID: Hashable, Codable, Sendable {}
public struct UTType: Hashable, Codable, Sendable {}
public struct UUID: Hashable, Codable, Sendable {}
public struct UrgencyClassification: Hashable, Codable, Sendable {}
public struct UrgencyClassificationConfigurationID: Hashable, Codable, Sendable {}
public struct UrgencyClassificationID: Hashable, Codable, Sendable {}
public struct VIContentClassifier: Hashable, Codable, Sendable {}
public struct VIContentClassifierConfigurationID: Hashable, Codable, Sendable {}
public struct VIContentClassifierID: Hashable, Codable, Sendable {}
public struct VideoCaption: Hashable, Codable, Sendable {}
public struct VideoCaptionConfigurationID: Hashable, Codable, Sendable {}
public struct VideoCaptionID: Hashable, Codable, Sendable {}
public struct VisionInferenceProvider: Hashable, Codable, Sendable {}
public struct VisualGenerationBase: Hashable, Codable, Sendable {}
public struct VisualGenerationBaseInputDenyList: Hashable, Codable, Sendable {}
public struct VisualGenerationInference: Hashable, Codable, Sendable {}
public struct VisualGenerationQueryHandlingLite: Hashable, Codable, Sendable {}
public struct VisualGenerationQueryHandlingLiteConfigurationID: Hashable, Codable, Sendable {}
public struct VisualGenerationQueryHandlingLiteID: Hashable, Codable, Sendable {}
public struct VisualGenerationQueryHandlingLiteTokenizer: Hashable, Codable, Sendable {}
public struct VisualGenerationSafetyInputDenyList: Hashable, Codable, Sendable {}
public struct VisualGenerationServerInference: Hashable, Codable, Sendable {}
public struct VisualIntelligence: Hashable, Codable, Sendable {}
public struct VisualIntelligenceConfigurationID: Hashable, Codable, Sendable {}
public struct VisualIntelligenceID: Hashable, Codable, Sendable {}
public struct VisualIntelligenceInputDenyList: Hashable, Codable, Sendable {}
public struct VisualIntelligenceNutritionInputDenyList: Hashable, Codable, Sendable {}
public struct VisualIntelligenceNutritionOutputDenyList: Hashable, Codable, Sendable {}
public struct VisualIntelligenceOutputDenyList: Hashable, Codable, Sendable {}
public struct VisualIntelligenceStructuredExtractionAddToCalendarInputDenyList: Hashable, Codable, Sendable {}
public struct VisualIntelligenceStructuredExtractionAddToCalendarOutputDenyList: Hashable, Codable, Sendable {}
public struct VisualIntelligenceStructuredExtractionAddToContactsInputDenyList: Hashable, Codable, Sendable {}
public struct VisualIntelligenceStructuredExtractionAddToContactsOutputDenyList: Hashable, Codable, Sendable {}
public protocol Voice {}
public struct Voice2: Hashable, Codable, Sendable {}
public struct Voice2ConfigurationID: Hashable, Codable, Sendable {}
public struct Voice2ID: Hashable, Codable, Sendable {}
public struct VoiceConfigurationID: Hashable, Codable, Sendable {}
public struct VoiceControlAI: Hashable, Codable, Sendable {}
public struct VoiceControlAIConfigurationID: Hashable, Codable, Sendable {}
public struct VoiceControlAIID: Hashable, Codable, Sendable {}
public struct VoiceControlAIInputDenyList: Hashable, Codable, Sendable {}
public struct VoiceControlAIOutputDenyList: Hashable, Codable, Sendable {}
public struct VoiceControlAIV2: Hashable, Codable, Sendable {}
public struct VoiceControlAIV2ConfigurationID: Hashable, Codable, Sendable {}
public struct VoiceControlAIV2ID: Hashable, Codable, Sendable {}
public struct VoiceControlAIV2InputDenyList: Hashable, Codable, Sendable {}
public struct VoiceControlAIV2OutputDenyList: Hashable, Codable, Sendable {}
public struct VoiceID: Hashable, Codable, Sendable {}
public struct WritingQuestionAnswerInputDenyList: Hashable, Codable, Sendable {}
public struct WritingQuestionAnswerOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingQuestionAnswerPayloadDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsBulletsTransformInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsBulletsTransformOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsComposeInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsComposeOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsComposeRecentsSummariesInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsComposeRecentsSummariesOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsConciseToneInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsConciseToneOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsFriendlyToneInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsFriendlyToneOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsMagicRewriteInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsMagicRewriteOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedSchemaInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedSchemaOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneBaseInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneBaseOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneQueryResponseInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneQueryResponseOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneQueryResponseV2InputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsOpenEndedToneQueryResponseV2OutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsProfessionalToneInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsProfessionalToneOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsProofreadingReviewInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsProofreadingReviewOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsTablesTransformInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsTablesTransformOutputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsTakeawaysTransformInputDenyList: Hashable, Codable, Sendable {}
public struct WritingToolsTakeawaysTransformOutputDenyList: Hashable, Codable, Sendable {}

