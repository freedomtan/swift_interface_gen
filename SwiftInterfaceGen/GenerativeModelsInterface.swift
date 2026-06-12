import Foundation
import CoreFoundation
import UniformTypeIdentifiers
import os
import ObjectiveC

// Shim for missing types
public typealias NSCoder = Foundation.NSCoder
public typealias NSZone = Foundation.NSZone
public typealias NSXPCConnection = Foundation.NSXPCConnection
public struct CoherenceToken: Hashable, Codable, Sendable {}
public struct UAFAssetSetConsistencyToken: Hashable, Codable, Sendable {}

public protocol AnyProtocol {}
public struct PlaceholderA1: AnyProtocol, Hashable, Codable, Sendable { 
    public struct Interface {} 
    public struct C {}
    public struct M {}
    public struct ModelType {}
    public struct TokenizerType {}
    public struct RemoteService { public struct Interface {} }
    public struct Service { public struct Interface {} }
    public struct Builder: Hashable, Codable, Sendable {}
}
public struct PlaceholderB1: AnyProtocol, Hashable, Codable, Sendable { public struct Interface {} }

public typealias A = PlaceholderA1
public typealias B = PlaceholderB1
public typealias A1 = PlaceholderA1
public typealias B1 = PlaceholderB1
public typealias C1 = PlaceholderA1
public typealias D1 = PlaceholderA1
public typealias A2 = PlaceholderA1

// Shim for missing frameworks
public enum AppleIntelligenceReporting {
    public struct AppleIntelligenceErrorCategory: Hashable, Codable, Sendable {}
    public struct AppleIntelligenceError: Hashable, Codable, Sendable {}
}
public struct UAFSubscriptionDownloadStatus: Hashable, Codable, Sendable {}
public enum FeatureFlags {
    public struct FeatureFlagsKey: Hashable, Codable, Sendable {}
}

public struct ConnectionState: Hashable, Codable, Sendable {}
public struct CatalogResourceResult: Hashable, Codable, Sendable {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws { fatalError() }
}
public struct RawGuardrailResult: Hashable, Codable, Sendable {}
public struct RawAvailableUseCases: Hashable, Codable, Sendable {}
public struct UseCaseStatuses: Hashable, Codable, Sendable {}
public struct SafetyFailure: Hashable, Codable, Sendable {}
public protocol CatalogResource: Hashable { var id: String { get } }

public struct CatalogAsset<T, U>: Hashable, Codable, Sendable {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws { fatalError() }
}
public struct ResourceBundleIdentifier<T>: Hashable, Codable, Sendable { 
    public let rawValue: String; public init(rawValue: String) { self.rawValue = rawValue }
    public var id: String { rawValue }
}
public struct SupportedArgument<T>: Hashable, Codable, Sendable {}
public struct OverrideHint<T>: Hashable, Codable, Sendable {}

public protocol AssetBackedResource { func fetchAsset() throws -> CatalogAsset<Any, Any> }

public struct ResourceConfiguration: Hashable, Codable, Sendable { public let id: String; public init(id: String) { self.id = id } }
public struct GuardrailResultInfo: Hashable, Codable, Sendable {}
public struct ResourceMetadata: Hashable, Codable, Sendable {}
public struct ExecutionContext: Hashable, Codable, Sendable {}
public struct ResourceVariantResolverArgument: Hashable, Codable, Sendable {}
public struct InferenceProvider: Hashable, Codable, Sendable {}
public struct UseCaseIdentifier: Hashable, Codable, Sendable {
    public struct DownloadCondition {
        public struct Identifier: Hashable, Codable, Sendable {}
    }
}
public protocol LLMAdapter {}
public protocol LLMModel {}
public protocol ManagedResource {}
public protocol ResourceBundle: Hashable {}
public struct ResourceBundle_Builder: Hashable, Codable, Sendable {}

public protocol ResourceBundleContainer {}
public protocol ResourceContainer {}
public protocol ResourceInformation {}
public protocol SafetyFailureWrapper {}
public protocol UseCaseStatusesWrapper {}
public protocol InitializableFromExistingConnection {}
public protocol ServiceConnectionProtocol {}
public protocol SubscriptionManagerProviding {}
public protocol XPCService {}

// Additional GenerativeModels shims
public enum GenerativeFunctions {
    public struct _GenerativeFunctionOverridableInternals_ChatMessagesPrompt: Hashable, Codable, Sendable {}
    public struct _GenerativeFunctionOverridableInternals_CompletionPrompt: Hashable, Codable, Sendable {}
}
public struct GenerativeFunctionsTool: Hashable, Codable, Sendable {
    public struct Function: Hashable, Codable, Sendable {}
}
public struct GenerativeFunctionsToolChoice: Hashable, Codable, Sendable {}
public struct GenerativeFunctionsInstrumentation: Hashable, Codable, Sendable {
    public struct EventReporter: Hashable, Codable, Sendable {}
    public struct GenerativeFunctionInstrumenter: Hashable, Codable, Sendable {}
}
public struct GenerativeModelsStringResponseSanitizerWithConfiguration: Hashable, Codable, Sendable {}
public struct TokenStream<T>: Hashable, Codable, Sendable {}
public struct Prompt: Hashable, Codable, Sendable {
    public struct SpecialToken: Hashable, Codable, Sendable {}
    public struct ToolCall: Hashable, Codable, Sendable {}
    public struct ToolResult: Hashable, Codable, Sendable {}
    public struct ResponseFormat: Hashable, Codable, Sendable {}
    public struct Component: Hashable, Codable, Sendable {
        public struct Value: Hashable, Codable, Sendable {}
    }
    public struct Rendering: Hashable, Codable, Sendable {}
    public struct MediaSegment: Hashable, Codable, Sendable {}
    public struct Turn: Hashable, Codable, Sendable {
        public struct Segment: Hashable, Codable, Sendable {}
    }
    public struct ToolCallResult: Hashable, Codable, Sendable {}
}
public struct AttachmentTokenizer: Hashable, Codable, Sendable {}
public struct PromptPreprocessingTemplateVersion: Hashable, Codable, Sendable {}
public struct TokenizedPromptModule: Hashable, Codable, Sendable {}
public struct PromptModule: Hashable, Codable, Sendable {}
public struct TokenizedStaticPromptTemplatePrefix: Hashable, Codable, Sendable {}
public struct PromptRequest: Hashable, Codable, Sendable {}
public struct Grammar: Hashable, Codable, Sendable {}
public struct ThoughtBudget: Hashable, Codable, Sendable {}
public struct ChatMessageRole: Hashable, Codable, Sendable {}
public struct TokenGenerator: Hashable, Codable, Sendable {}
public struct SamplingParameters: Hashable, Codable, Sendable {}
public struct SpecialToken: Hashable, Codable, Sendable {}
public enum InternalSwiftProtobuf {
    public struct UnknownStorage: Hashable, Codable, Sendable {}
}
public struct GenerativeFunctionsToolType: Hashable, Codable, Sendable {}
public struct GenerativeFunctionsToolDefinition: Hashable, Codable, Sendable {}
public struct GenerativeModelsAccessGroup: Hashable, Codable, Sendable {}
public struct GenerativeModelsSecurityLevel: Hashable, Codable, Sendable {}
public struct PromptCompletionStream: Hashable, Codable, Sendable {}
public enum ModelManagerServices {
    public struct InferenceProviderRequestConfiguration: Hashable, Codable, Sendable {}
    public struct InferenceError: Hashable, Codable, Sendable {}
    public struct Session: Hashable, Codable, Sendable {}
    public struct ClientData: Hashable, Codable, Sendable {}
}
public struct GenerativeModelsDocumentResource: Hashable, Codable, Sendable {}
public struct GenerativeModelsDocumentRegistration: Hashable, Codable, Sendable {
    public struct InternalStatus: Hashable, Codable, Sendable {}
    public struct Status: Hashable, Codable, Sendable {}
}
public struct GenerativeModelsCloudGuardrails: Hashable, Codable, Sendable {}
public struct GenerativeFunctionsSchema: Hashable, Codable, Sendable {}
public struct GenerativeModelsMetricData: Hashable, Codable, Sendable {}
public struct GenerativeModelsModelBundleInfoForSanitizer: Hashable, Codable, Sendable {}
public struct GenerativeModelsStringRenderedPromptSanitizerRunnerConfiguration: Hashable, Codable, Sendable {}
public struct GenerativeModelsStringResponseSanitizerRunnerConfiguration: Hashable, Codable, Sendable {}
public struct GenerativeModelsSafetyRequestConfiguration: Hashable, Codable, Sendable {}
public struct GenerativeModelsModelManagerSessionWrapper: Hashable, Codable, Sendable {}
public struct GenerativeModelsCachedSafetyModelsWrapper: Hashable, Codable, Sendable {}
public struct GenerativeModelsStringRenderedPromptSanitizerRunnerProtocol: Hashable, Codable, Sendable {}
public struct GenerativeModelsStringResponseSanitizerRunnerProtocol: Hashable, Codable, Sendable {}
public struct LLMBundle: Hashable, Codable, Sendable {
    public struct Builder: Hashable, Codable, Sendable {}
}
public struct JsonValueContainer: Hashable, Codable, Sendable {}
public struct GenerativeModelsReadDataResponse: Hashable, Codable, Sendable {}
public struct GenerativeModelsDocumentResourceIdentifier: Hashable, Codable, Sendable {}
public struct CatalogClient: Hashable, Codable, Sendable {}
public struct AssetBackedLLMBundle: Hashable, Codable, Sendable {
    public struct Builder: Hashable, Codable, Sendable {}
}
public struct ResourceBundleQuery: Hashable, Codable, Sendable {}
public struct GenerativeModelsPromptTemplate: Hashable, Codable, Sendable {
    public struct ModelBundleID: Hashable, Codable, Sendable {}
}
public typealias IOSurface = PlaceholderA1
public struct GenerativeFunctionsTemplateVariableBinding: Hashable, Codable, Sendable {}
public struct GenerativeFunctionsFileGenerationParameters: Hashable, Codable, Sendable {}
public struct GenerativeFunctionsGenerationSchema: Hashable, Codable, Sendable {
    public struct Choice: Hashable, Codable, Sendable {}
    public struct Field: Hashable, Codable, Sendable {}
    public struct StringConstraint: Hashable, Codable, Sendable {}
}
public struct OSAllocatedUnfairLock<T>: Hashable, Codable, Sendable {}
public struct GenerativeModelsMetricProvider: Hashable, Codable, Sendable {}
public struct GenerativeModelsPDUnit: Hashable, Codable, Sendable {}
public struct GenerativeModelsModelBundleIdentifier: Hashable, Codable, Sendable {}
public typealias GenericA = PlaceholderA1
public typealias GenericA1 = PlaceholderA1
public struct GenerativeFunctionsGenerativeError: Hashable, Codable, Sendable {}
public struct InferenceResponse: Hashable, Codable, Sendable {
    public struct Moderation: Hashable, Codable, Sendable {
        public struct Category: Hashable, Codable, Sendable {}
        public struct Probability: Hashable, Codable, Sendable {}
    }
    public struct Annotation: Hashable, Codable, Sendable {
        public struct `Type`: Hashable, Codable, Sendable {}
    }
    public struct AudioContent: Hashable, Codable, Sendable {}
    public struct FileContent: Hashable, Codable, Sendable {}
    public struct FinishReason: Hashable, Codable, Sendable {}
    public struct ImageContent: Hashable, Codable, Sendable {}
    public struct ModelInformation: Hashable, Codable, Sendable {}
    public struct PromptRendering: Hashable, Codable, Sendable {}
    public struct Usage: Hashable, Codable, Sendable {}
}
public struct ModelCatalogStub: Hashable, Codable, Sendable {
    public struct AssetKey: Hashable, Codable, Sendable {}
}
public struct GenerativeFunctionsImageGenerationParameters: Hashable, Codable, Sendable {
    public struct Count: Hashable, Codable, Sendable {}
    public struct Detail: Hashable, Codable, Sendable {}
    public struct Shape: Hashable, Codable, Sendable {}
    public struct Size: Hashable, Codable, Sendable {}
}
public struct GenerativeFunctionsJSONSchema: Hashable, Codable, Sendable {}
public enum Network {
    public struct NetworkType: Hashable, Codable, Sendable {}
}
public struct _LoadedUseCaseConfigurations<T>: Hashable, Codable, Sendable {}
public struct _UseCaseConfiguration: Hashable, Codable, Sendable {}
public enum GenerativeModelsAvailability {
    public struct Parameters: Hashable, Codable, Sendable {}
    public struct Availability: Hashable, Codable, Sendable {
        public struct RestrictedInfo: Hashable, Codable, Sendable {
            public struct RestrictedReason: Hashable, Codable, Sendable {}
        }
        public struct UnavailableInfo: Hashable, Codable, Sendable {
            public struct UnavailableReason: Hashable, Codable, Sendable {}
        }
    }
    public struct ReasonsAssociatedWithOSEligibilityInput: Hashable, Codable, Sendable {}
    public struct EnhancedSiriChangeSequence: Hashable, Codable, Sendable {}
    public struct EnhancedSiriWaitlistStatus: Hashable, Codable, Sendable {}
    public struct Notifications: Hashable, Codable, Sendable {}
    public struct Partner: Hashable, Codable, Sendable {}
}
public struct GenerativeFunctionsOSEligibilityState: Hashable, Codable, Sendable {}
public struct GMAvailabilityStatus: Hashable, Codable, Sendable {}
public struct ToolDescription: Hashable, Codable, Sendable {}
public enum XPC {
    public struct XPCCodableObject: Hashable, Codable, Sendable {}
}
public struct GenerativeModelsFailureTracking: Hashable, Codable, Sendable {
    public struct Failure: Hashable, Codable, Sendable {
        public struct Severity: Hashable, Codable, Sendable {}
    }
    public struct FailureRecord<T>: Hashable, Codable, Sendable {}
}
public struct GenerativeConfigurationKey: Hashable, Codable, Sendable {}
public struct FileGenerationParameters {
    public static func ==(_: GenerativeFunctionsFileGenerationParameters, _: GenerativeFunctionsFileGenerationParameters) -> Bool18446744073709550616 { fatalError() }
    public static func ==(_: GenerativeFunctionsFileGenerationParameters, _: GenerativeFunctionsFileGenerationParameters) -> Bool { fatalError() }
}

public struct GenerationSchema {
    public struct Choice {
        public static func ==(_: GenerativeFunctionsGenerationSchema.Choice, _: GenerativeFunctionsGenerationSchema.Choice) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsGenerationSchema.Choice, _: GenerativeFunctionsGenerationSchema.Choice) -> Bool { fatalError() }
    }
    public struct Field {
        public static func ==(_: GenerativeFunctionsGenerationSchema.Field, _: GenerativeFunctionsGenerationSchema.Field) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsGenerationSchema.Field, _: GenerativeFunctionsGenerationSchema.Field) -> Bool { fatalError() }
    }
    public struct StringConstraint {
        public static func ==(_: GenerativeFunctionsGenerationSchema.StringConstraint, _: GenerativeFunctionsGenerationSchema.StringConstraint) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsGenerationSchema.StringConstraint, _: GenerativeFunctionsGenerationSchema.StringConstraint) -> Bool18446744073709550616 { fatalError() }
    }
    public static var excludeOrder: CodingUserInfoKey { get { fatalError() } }
    public static func ==(_: GenerativeFunctionsGenerationSchema, _: GenerativeFunctionsGenerationSchema) -> Bool18446744073709550616 { fatalError() }
    public static func ==(_: GenerativeFunctionsGenerationSchema, _: GenerativeFunctionsGenerationSchema) -> Bool { fatalError() }
}

public struct ImageGenerationParameters {
    public struct Count {
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Count, _: GenerativeFunctionsImageGenerationParameters.Count) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Count, _: GenerativeFunctionsImageGenerationParameters.Count) -> Bool { fatalError() }
    }
    public struct Detail {
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Detail, _: GenerativeFunctionsImageGenerationParameters.Detail) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Detail, _: GenerativeFunctionsImageGenerationParameters.Detail) -> Bool18446744073709550616 { fatalError() }
    }
    public struct Shape {
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Shape, _: GenerativeFunctionsImageGenerationParameters.Shape) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Shape, _: GenerativeFunctionsImageGenerationParameters.Shape) -> Bool18446744073709550616 { fatalError() }
    }
    public struct Size {
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Size, _: GenerativeFunctionsImageGenerationParameters.Size) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsImageGenerationParameters.Size, _: GenerativeFunctionsImageGenerationParameters.Size) -> Bool18446744073709550616 { fatalError() }
    }
    public static func ==(_: GenerativeFunctionsImageGenerationParameters, _: GenerativeFunctionsImageGenerationParameters) -> Bool18446744073709550616 { fatalError() }
    public static func ==(_: GenerativeFunctionsImageGenerationParameters, _: GenerativeFunctionsImageGenerationParameters) -> Bool { fatalError() }
}

public struct JSONSchema {
    public struct AnyOf {
        public static func ==(_: GenerativeFunctionsJSONSchema.AnyOf, _: GenerativeFunctionsJSONSchema.AnyOf) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.AnyOf, _: GenerativeFunctionsJSONSchema.AnyOf) -> Bool { fatalError() }
    }
    public struct Array {
        public static func ==(_: GenerativeFunctionsJSONSchema.[Any], _: GenerativeFunctionsJSONSchema.[Any]) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.[Any], _: GenerativeFunctionsJSONSchema.[Any]) -> Bool { fatalError() }
    }
    public struct Boolean {
        public static func ==(_: GenerativeFunctionsJSONSchema.Boolean, _: GenerativeFunctionsJSONSchema.Boolean) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Boolean, _: GenerativeFunctionsJSONSchema.Boolean) -> Bool { fatalError() }
    }
    public struct Constant {
        public static func ==(_: GenerativeFunctionsJSONSchema.Constant, _: GenerativeFunctionsJSONSchema.Constant) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Constant, _: GenerativeFunctionsJSONSchema.Constant) -> Bool { fatalError() }
    }
    public struct Dictionary {
        public static func ==(_: GenerativeFunctionsJSONSchema.[AnyHashable: Any], _: GenerativeFunctionsJSONSchema.[AnyHashable: Any]) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.[AnyHashable: Any], _: GenerativeFunctionsJSONSchema.[AnyHashable: Any]) -> Bool18446744073709550616 { fatalError() }
    }
    public struct Integer {
        public static func ==(_: GenerativeFunctionsJSONSchema.Integer, _: GenerativeFunctionsJSONSchema.Integer) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Integer, _: GenerativeFunctionsJSONSchema.Integer) -> Bool { fatalError() }
    }
    public struct Null {
        public static func ==(_: GenerativeFunctionsJSONSchema.Null, _: GenerativeFunctionsJSONSchema.Null) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Null, _: GenerativeFunctionsJSONSchema.Null) -> Bool { fatalError() }
    }
    public struct Number {
        public static func ==(_: GenerativeFunctionsJSONSchema.Number, _: GenerativeFunctionsJSONSchema.Number) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Number, _: GenerativeFunctionsJSONSchema.Number) -> Bool { fatalError() }
    }
    public struct Object {
        public static func ==(_: GenerativeFunctionsJSONSchema.Object, _: GenerativeFunctionsJSONSchema.Object) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Object, _: GenerativeFunctionsJSONSchema.Object) -> Bool18446744073709550616 { fatalError() }
    }
    public struct Property {
        public static func ==(_: GenerativeFunctionsJSONSchema.Property, _: GenerativeFunctionsJSONSchema.Property) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Property, _: GenerativeFunctionsJSONSchema.Property) -> Bool18446744073709550616 { fatalError() }
    }
    public struct Reference {
        public static func ==(_: GenerativeFunctionsJSONSchema.Reference, _: GenerativeFunctionsJSONSchema.Reference) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.Reference, _: GenerativeFunctionsJSONSchema.Reference) -> Bool18446744073709550616 { fatalError() }
        public static var root: String { get { fatalError() } }
    }
    public struct String {
        public static func ==(_: GenerativeFunctionsJSONSchema.String, _: GenerativeFunctionsJSONSchema.String) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsJSONSchema.String, _: GenerativeFunctionsJSONSchema.String) -> Bool { fatalError() }
    }
    public static func ==(_: GenerativeFunctionsJSONSchema, _: GenerativeFunctionsJSONSchema) -> Bool18446744073709550616 { fatalError() }
    public static func ==(_: GenerativeFunctionsJSONSchema, _: GenerativeFunctionsJSONSchema) -> Bool { fatalError() }
}

public struct RecursiveSchema {
    public struct Field {
        public static func ==(_: GenerativeFunctionsRecursiveSchema.Field, _: GenerativeFunctionsRecursiveSchema.Field) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsRecursiveSchema.Field, _: GenerativeFunctionsRecursiveSchema.Field) -> Bool { fatalError() }
    }
    public struct Kind {
        public static func ==(_: GenerativeFunctionsRecursiveSchema.Kind, _: GenerativeFunctionsRecursiveSchema.Kind) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsRecursiveSchema.Kind, _: GenerativeFunctionsRecursiveSchema.Kind) -> Bool { fatalError() }
    }
    public struct Options {
        public static var includeFormatEnum: GenerativeFunctionsRecursiveSchema.Options { get { fatalError() } }
    }
    public static func ==(_: GenerativeFunctionsRecursiveSchema, _: GenerativeFunctionsRecursiveSchema) -> Bool { fatalError() }
    public static func ==(_: GenerativeFunctionsRecursiveSchema, _: GenerativeFunctionsRecursiveSchema) -> Bool18446744073709550616 { fatalError() }
}

public struct Schema {
    public struct Field {
        public static func ==(_: GenerativeFunctionsSchema.Field, _: GenerativeFunctionsSchema.Field) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsSchema.Field, _: GenerativeFunctionsSchema.Field) -> Bool18446744073709550616 { fatalError() }
    }
    public static func ==(_: GenerativeFunctionsSchema, _: GenerativeFunctionsSchema) -> Bool { fatalError() }
    public static func ==(_: GenerativeFunctionsSchema, _: GenerativeFunctionsSchema) -> Bool18446744073709550616 { fatalError() }
}

public struct ToolDefinition {
    public struct Function {
        public static func ==(_: GenerativeFunctionsToolDefinition.Function, _: GenerativeFunctionsToolDefinition.Function) -> Bool { fatalError() }
        public static func ==(_: GenerativeFunctionsToolDefinition.Function, _: GenerativeFunctionsToolDefinition.Function) -> Bool18446744073709550616 { fatalError() }
    }
    public struct `Type` {
        public static func ==(_: GenerativeFunctionsToolDefinition.Type, _: GenerativeFunctionsToolDefinition.Type) -> Bool18446744073709550616 { fatalError() }
        public static func ==(_: GenerativeFunctionsToolDefinition.Type, _: GenerativeFunctionsToolDefinition.Type) -> Bool { fatalError() }
    }
    public static var browser: GenerativeFunctionsToolDefinition { get { fatalError() } }
    public static func ==(_: GenerativeFunctionsToolDefinition, _: GenerativeFunctionsToolDefinition) -> Bool18446744073709550616 { fatalError() }
    public static func function(name: String, description: String, parameters: GenerativeFunctionsSchema) -> GenerativeFunctionsToolDefinition18446744073709550616 { fatalError() }
    public static func ==(_: GenerativeFunctionsToolDefinition, _: GenerativeFunctionsToolDefinition) -> Bool { fatalError() }
    public static func function(name: String, description: String, parameters: GenerativeFunctionsSchema) -> GenerativeFunctionsToolDefinition { fatalError() }
    public static func imageGenerationTool(parameters: GenerativeFunctionsImageGenerationParameters) -> GenerativeFunctionsToolDefinition18446744073709550616 { fatalError() }
    public static func fileGenerationTool(parameters: GenerativeFunctionsFileGenerationParameters) -> GenerativeFunctionsToolDefinition { fatalError() }
    public static func imageGenerationTool(parameters: GenerativeFunctionsImageGenerationParameters) -> GenerativeFunctionsToolDefinition { fatalError() }
    public static var imageGenerator: GenerativeFunctionsToolDefinition { get { fatalError() } }
    public static func fileGenerationTool(parameters: GenerativeFunctionsFileGenerationParameters) -> GenerativeFunctionsToolDefinition18446744073709550616 { fatalError() }
}

public struct AccessGroup {
    public init(rawValue: String) { fatalError() }
    public var rawValue: String { get { fatalError() } }
}

public class AnyGenerationGuides {
    public init(string: Optional<StringGuides>, integer: Optional<IntegerGuides>, double: Optional<DoubleGuides>, array: Optional<ArrayGuides>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var integer: Optional<IntegerGuides> { get { fatalError() } }
    public func merging(_: Optional<AnyGenerationGuides>) -> AnyGenerationGuides { fatalError() }
    public var array: Optional<ArrayGuides> { get { fatalError() } }
    public var double: Optional<DoubleGuides> { get { fatalError() } }
    public var string: Optional<StringGuides> { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct AppendToolError {
    public var errorCode: Int { get { fatalError() } }
}

public struct ArrayGuides {
    public init(minimumCount: Optional<Int>, maximumCount: Optional<Int>, element: Optional<AnyGenerationGuides>) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct Assistant {
    public init(_: () async throws -> Prompt) async throws { fatalError() }
    public init(_: Prompt) { fatalError() }
    public init(_: () throws -> Prompt) throws { fatalError() }
    public var thoughtContent: Optional<Prompt> { get { fatalError() } set { fatalError() } }
    public func thoughtContent(_: Prompt) -> Assistant { fatalError() }
    public func toChatMessagePrompt() -> ChatMessagePrompt { fatalError() }
    public var prompt: Prompt { get { fatalError() } }
    public var thoughts: Optional<Thoughts> { get { fatalError() } set { fatalError() } }
    public func locale(_: Optional<Locale>) -> ChatMessagePrompt { fatalError() }
    public func thoughtContent(content: String) -> Assistant { fatalError() }
}

public struct AudioEmbeddingKeys {
}

public struct AudioFormat {
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct AudioFormat18446744073709550616 {
}

public struct AutomationJSON {
    public struct DecoderConfig {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct InputPromptType {
        public init(rawValue: String) { fatalError() }
        public var rawValue: String { get { fatalError() } }
    }
    public struct InputSafetyConfiguration {
        public struct Guardrails {
            public init(from: Decoder) throws { fatalError() }
            public init(ovs: Bool, textSanitization: Bool) { fatalError() }
            public var ovs: Bool { get { fatalError() } }
            public var textSanitization: Bool { get { fatalError() } }
            public func encode(to: Encoder) throws -> () { fatalError() }
        }
        public struct LanguageRecognizer {
            public init(language: Array<Locale.LanguageCode>, topK: Int) { fatalError() }
            public init(from: Decoder) throws { fatalError() }
            public var language: Array<Locale.LanguageCode> { get { fatalError() } }
            public func encode(to: Encoder) throws -> () { fatalError() }
            public var topK: Int { get { fatalError() } }
        }
        public struct LanguageScriptValidator {
            public init(from: Decoder) throws { fatalError() }
            public init(script: Array<Locale>, isEmojiAllowed: Bool) { fatalError() }
            public func encode(to: Encoder) throws -> () { fatalError() }
            public var isEmojiAllowed: Bool { get { fatalError() } }
            public var script: Array<Locale> { get { fatalError() } }
        }
        public init(from: Decoder) throws { fatalError() }
        public var guardrails: Optional<AutomationJSON.InputSafetyConfiguration.Guardrails> { get { fatalError() } }
        public var languageScriptValidator: Optional<AutomationJSON.InputSafetyConfiguration.LanguageScriptValidator> { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var denyListIdentifier: Optional<String> { get { fatalError() } }
        public var languageRecognizer: Optional<AutomationJSON.InputSafetyConfiguration.LanguageRecognizer> { get { fatalError() } }
    }
    public struct OutputSafetyConfiguration {
        public struct Guardrails {
            public init(ovs: Bool, textSanitization: Bool) { fatalError() }
            public init(from: Decoder) throws { fatalError() }
            public func encode(to: Encoder) throws -> () { fatalError() }
            public var ovs: Bool { get { fatalError() } }
            public var textSanitization: Bool { get { fatalError() } }
        }
        public init(from: Decoder) throws { fatalError() }
        public var denyListIdentifier: Optional<String> { get { fatalError() } }
        public var guardrails: Optional<AutomationJSON.OutputSafetyConfiguration.Guardrails> { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct ParameterizedPrompt {
        public init(from: Decoder) throws { fatalError() }
        public init(prompt: String, inputPromptType: AutomationJSON.InputPromptType, locale: Optional<String>, inputVariableBindings: Optional<Dictionary<String, String>>, inputImageVariableBindings: Optional<Dictionary<String, Array<String>>>, inputRichVariableBindings: Optional<Dictionary<String, Array<AutomationJSON.RichVariableBinding>>>, samplingStrategyConfiguration: Optional<AutomationJSON.SamplingStrategyConfiguration>, temperature: Optional<Double>, frequencyPenalty: Optional<Double>, lengthPenalty: Optional<Double>, stopSequence: Optional<String>, maxTokens: Optional<Int>, randomSeed: Optional<Int>, promptLookupDraftSteps: Optional<Int>, speculativeSampling: Optional<Bool>, tokenHealing: Optional<Bool>, speculativeDecoding: Optional<Bool>, isOpportunistic: Optional<Bool>, schema: Optional<String>, grammar: Optional<String>, schemaIdentifier: Optional<String>, grammarIdentifier: Optional<String>, dynamicPartsOfGrammars: Optional<String>, constrainedDecodingDisabled: Optional<Bool>, timeout: Optional<Double>, useHighQualityImageTokenization: Optional<Bool>, maxImagePixels: Optional<Int>, inputSafetyConfiguration: Optional<AutomationJSON.InputSafetyConfiguration>, outputSafetyConfiguration: Optional<AutomationJSON.OutputSafetyConfiguration>, output: Optional<String>, renderedPrompt: Optional<AutomationJSON.RenderedPrompt>, promptTokenIDs: Optional<Array<Int>>, outputTokenIDs: Optional<Array<Int>>, outputAudioFilePaths: Optional<Array<String>>, userAudioTranscriptContent: Optional<String>, userData: Optional<JSON>, priorInferenceOutput: Optional<String>, computeMeanTokenEntropy: Optional<Bool>) { fatalError() }
        public var computeMeanTokenEntropy: Optional<Bool> { get { fatalError() } }
        public var dynamicPartsOfGrammars: Optional<String> { get { fatalError() } }
        public var frequencyPenalty: Optional<Double> { get { fatalError() } }
        public var inputRichVariableBindings: Optional<Dictionary<String, Array<AutomationJSON.RichVariableBinding>>> { get { fatalError() } }
        public var meanTokenEntropy: Optional<Float> { get { fatalError() } set { fatalError() } }
        public var output: Optional<String> { get { fatalError() } set { fatalError() } }
        public var temperature: Optional<Double> { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var constrainedDecodingDisabled: Optional<Bool> { get { fatalError() } }
        public var grammar: Optional<String> { get { fatalError() } }
        public var grammarIdentifier: Optional<String> { get { fatalError() } }
        public var inputImageVariableBindings: Optional<Dictionary<String, Array<String>>> { get { fatalError() } }
        public var inputPromptType: AutomationJSON.InputPromptType { get { fatalError() } }
        public var inputSafetyConfiguration: Optional<AutomationJSON.InputSafetyConfiguration> { get { fatalError() } }
        public var inputVariableBindings: Optional<Dictionary<String, String>> { get { fatalError() } }
        public var isOpportunistic: Optional<Bool> { get { fatalError() } }
        public var lengthPenalty: Optional<Double> { get { fatalError() } }
        public var locale: Optional<String> { get { fatalError() } }
        public var maxImagePixels: Optional<Int> { get { fatalError() } }
        public var maxTokens: Optional<Int> { get { fatalError() } }
        public var outputAudioFilePaths: Optional<Array<String>> { get { fatalError() } set { fatalError() } }
        public var outputSafetyConfiguration: Optional<AutomationJSON.OutputSafetyConfiguration> { get { fatalError() } }
        public var outputTokenIDs: Optional<Array<Int>> { get { fatalError() } set { fatalError() } }
        public var priorInferenceOutput: Optional<String> { get { fatalError() } }
        public var prompt: String { get { fatalError() } }
        public var promptLookupDraftSteps: Optional<Int> { get { fatalError() } }
        public var promptTokenIDs: Optional<Array<Int>> { get { fatalError() } set { fatalError() } }
        public var randomSeed: Optional<Int> { get { fatalError() } }
        public var renderedPrompt: Optional<AutomationJSON.RenderedPrompt> { get { fatalError() } set { fatalError() } }
        public var samplingStrategyConfiguration: Optional<AutomationJSON.SamplingStrategyConfiguration> { get { fatalError() } }
        public var schema: Optional<String> { get { fatalError() } }
        public var schemaIdentifier: Optional<String> { get { fatalError() } }
        public var speculativeDecoding: Optional<Bool> { get { fatalError() } }
        public var speculativeSampling: Optional<Bool> { get { fatalError() } }
        public var stopSequence: Optional<String> { get { fatalError() } }
        public var timeout: Optional<Double> { get { fatalError() } }
        public var tokenHealing: Optional<Bool> { get { fatalError() } }
        public var useHighQualityImageTokenization: Optional<Bool> { get { fatalError() } }
        public var userAudioTranscriptContent: Optional<String> { get { fatalError() } set { fatalError() } }
        public var userData: Optional<JSON> { get { fatalError() } }
    }
    public struct RenderedPrompt {
        public struct Source {
            public init(from: Decoder) throws { fatalError() }
            public init(identifier: String, version: String) { fatalError() }
            public var identifier: String { get { fatalError() } set { fatalError() } }
            public var version: String { get { fatalError() } set { fatalError() } }
            public func encode(to: Encoder) throws -> () { fatalError() }
        }
        public init(from: Decoder) throws { fatalError() }
        public init(originalPrompt: String, renderedString: String, segments: Array<String>, tokenIDs: Array<Int>, userInfo: Dictionary<String, String>, source: AutomationJSON.RenderedPrompt.Source) { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var description: String { get { fatalError() } }
        public var originalPrompt: String { get { fatalError() } }
        public var renderedString: String { get { fatalError() } }
        public var segments: Array<String> { get { fatalError() } }
        public var source: AutomationJSON.RenderedPrompt.Source { get { fatalError() } }
        public var tokenIDs: Array<Int> { get { fatalError() } }
        public var userInfo: Dictionary<String, String> { get { fatalError() } }
    }
    public struct Response {
        public init(content: String) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public var content: String { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct RichVariableBinding {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct Role {
        public init(rawValue: String) { fatalError() }
        public var rawValue: String { get { fatalError() } }
    }
    public struct SamplingStrategyConfiguration {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct Turn {
        public init(from: Decoder) throws { fatalError() }
        public init(role: AutomationJSON.Role, content: AutomationJSON.TurnContent) { fatalError() }
        public init(role: AutomationJSON.Role, content: String) { fatalError() }
        public var content: AutomationJSON.TurnContent { get { fatalError() } }
        public var role: AutomationJSON.Role { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct TurnContent {
        public init(from: Decoder) throws { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct TurnSegment {
        public init(from: Decoder) throws { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public init(from: Decoder) throws { fatalError() }
    public init(input: Array<String>, mode: String, modelBundleId: String) { fatalError() }
    public var constrainedDecodingDisabled: Optional<Bool> { get { fatalError() } }
    public var constraintValidation: Optional<Array<String>> { get { fatalError() } set { fatalError() } }
    public var decoderConfig: Optional<AutomationJSON.DecoderConfig> { get { fatalError() } set { fatalError() } }
    public var dynamicPartsOfGrammars: Optional<Array<String>> { get { fatalError() } }
    public var frequencyPenalty: Optional<Double> { get { fatalError() } }
    public var grammar: Optional<String> { get { fatalError() } }
    public var grammarIdentifier: Optional<String> { get { fatalError() } }
    public var input: Optional<Array<String>> { get { fatalError() } }
    public var inputImageVariableBindings: Optional<Array<Dictionary<String, Array<String>>>> { get { fatalError() } }
    public var inputPromptType: Optional<AutomationJSON.InputPromptType> { get { fatalError() } }
    public var inputRichVariableBindings: Optional<Array<Dictionary<String, Array<AutomationJSON.RichVariableBinding>>>> { get { fatalError() } }
    public var inputSafetyConfiguration: Optional<AutomationJSON.InputSafetyConfiguration> { get { fatalError() } }
    public var inputVariableBindings: Optional<Array<Dictionary<String, String>>> { get { fatalError() } }
    public var isOpportunistic: Optional<Bool> { get { fatalError() } }
    public var iterationCount: Optional<Int> { get { fatalError() } }
    public var lengthPenalty: Optional<Double> { get { fatalError() } }
    public var locale: Optional<String> { get { fatalError() } }
    public var maxImagePixels: Optional<Int> { get { fatalError() } }
    public var maxTokens: Optional<Int> { get { fatalError() } }
    public var meanTokenEntropy: Optional<Array<Float>> { get { fatalError() } set { fatalError() } }
    public var messages: Optional<Array<Array<AutomationJSON.Turn>>> { get { fatalError() } }
    public var mode: String { get { fatalError() } }
    public var modelBundleId: Optional<String> { get { fatalError() } }
    public var output: Optional<Array<String>> { get { fatalError() } set { fatalError() } }
    public var outputSafetyConfiguration: Optional<AutomationJSON.OutputSafetyConfiguration> { get { fatalError() } }
    public var parameterizedPrompts: Optional<Array<AutomationJSON.ParameterizedPrompt>> { get { fatalError() } set { fatalError() } }
    public var prewarm: Optional<Bool> { get { fatalError() } }
    public var prompt: Optional<String> { get { fatalError() } }
    public var promptDelay: Optional<Int> { get { fatalError() } }
    public var promptLookupDraftSteps: Optional<Int> { get { fatalError() } }
    public var randomSeed: Optional<Int> { get { fatalError() } }
    public var renderedPrompts: Optional<Array<Optional<AutomationJSON.RenderedPrompt>>> { get { fatalError() } set { fatalError() } }
    public var responses: Optional<Array<AutomationJSON.Response>> { get { fatalError() } set { fatalError() } }
    public var samplingStrategyConfiguration: Optional<AutomationJSON.SamplingStrategyConfiguration> { get { fatalError() } }
    public var schemaIdentifier: Optional<String> { get { fatalError() } }
    public var speculativeDecoding: Optional<Bool> { get { fatalError() } }
    public var speculativeSampling: Optional<Bool> { get { fatalError() } }
    public var stopSequence: Optional<String> { get { fatalError() } }
    public var temperature: Optional<Double> { get { fatalError() } }
    public var tokenHealing: Optional<Bool> { get { fatalError() } }
    public var useCaseIdentifier: Optional<String> { get { fatalError() } }
    public var useHighQualityImageTokenization: Optional<Bool> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var decoder: Optional<String> { get { fatalError() } }
    public func getOutput() -> Optional<Array<String>> { fatalError() }
    public var schema: Optional<String> { get { fatalError() } }
}

public struct AvailabilityCacheKey {
    public init(useCaseIdentifiers: Array<String>, language: GenerativeModelsAvailability.LanguageOption, additionalCriteria: Bool) { fatalError() }
    public var additionalCriteria: Bool { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var language: GenerativeModelsAvailability.LanguageOption { get { fatalError() } }
    public var useCaseIdentifiers: Array<String> { get { fatalError() } }
    public static func ==(_: AvailabilityCacheKey, _: AvailabilityCacheKey) -> Bool { fatalError() }
}

public class AvailabilityClient {
    public struct ShouldBlockAppleIntelligenceAssetsInput {
        public init() { fatalError() }
        public func inferenceUseCaseBlocklist() -> Dictionary<String, Optional<Set<String>>> { fatalError() }
    }
    public init() { fatalError() }
    public static func shouldBlockAppleIntelligenceAssetsForAnyUser() async throws -> Bool { fatalError() }
    public func updateAll() async throws -> () { fatalError() }
    public static func currentAvailabilitySecureAllUsers(parameters: GenerativeModelsAvailability.Parameters) async throws -> Dictionary<UInt32, GenerativeModelsAvailability> { fatalError() }
    public static func shouldBlockAppleIntelligenceAssetsForAnyUser(useCaseIdentifiers: Array<UseCaseIdentifier>) async throws -> Bool { fatalError() }
    public func currentAvailabilitySecure(parameters: GenerativeModelsAvailability.Parameters) async throws -> GenerativeModelsAvailability { fatalError() }
    public static func shouldNotDownloadOrServeAppleIntelligenceAssetsForAnyUser() async throws -> Bool { fatalError() }
    public static func shouldBlockAppleIntelligenceAssetsForAnyUser(forAnyUseCaseIDs: Set<String>) async throws -> Bool { fatalError() }
}

public class AvailabilityFoundationClient {
    public struct CFUType {
        public init(rawValue: String) { fatalError() }
        public var rawValue: String { get { fatalError() } }
    }
    public struct CloudSubscriptionFeaturesAssetUnavailableReason {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct CloudSubscriptionFeaturesAvailabilityWrapper {
        public struct Availability {
            public struct UnavailabilityInfo {
                public struct UnavailabilityReason {
                    public init(from: Decoder) throws { fatalError() }
                    public func encode(to: Encoder) throws -> () { fatalError() }
                    public var hashValue: Int { get { fatalError() } }
                    public func hash(into: inout Hasher) -> () { fatalError() }
                }
                public init(from: Decoder) throws { fatalError() }
                public init(reasons: Set<GenerativeModelsAvailabilityFoundationClient.CloudSubscriptionFeaturesAvailabilityWrapper.Availability.UnavailabilityInfo.UnavailabilityReason>) { fatalError() }
                public var reasons: Set<GenerativeModelsAvailabilityFoundationClient.CloudSubscriptionFeaturesAvailabilityWrapper.Availability.UnavailabilityInfo.UnavailabilityReason> { get { fatalError() } }
                public func encode(to: Encoder) throws -> () { fatalError() }
            }
            public init(from: Decoder) throws { fatalError() }
            public func encode(to: Encoder) throws -> () { fatalError() }
        }
        public init(availability: GenerativeModelsAvailabilityFoundationClient.CloudSubscriptionFeaturesAvailabilityWrapper.Availability) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public var availability: GenerativeModelsAvailabilityFoundationClient.CloudSubscriptionFeaturesAvailabilityWrapper.Availability { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct ForceWaitlistStatusParameters {
        public struct Status {
            public init(rawValue: String) { fatalError() }
            public var rawValue: String { get { fatalError() } }
        }
        public init(status: Optional<GenerativeModelsAvailabilityFoundationClient.ForceWaitlistStatusParameters.Status>) { fatalError() }
        public var status: Optional<GenerativeModelsAvailabilityFoundationClient.ForceWaitlistStatusParameters.Status> { get { fatalError() } }
    }
    public init() { fatalError() }
    public func updateCSFAccessGranted(for: Dictionary<String, Bool>) async throws -> () { fatalError() }
    public func isUseCaseAccessNotGrantedSecure(useCaseIdentifiersData: Data) throws -> Bool { fatalError() }
    public func updateCFUEngagedDate(for: GenerativeModelsAvailabilityFoundationClient.CFUType, date: Date) async throws -> () { fatalError() }
    public func updateOptInStatus(optedIn: Bool) async throws -> () { fatalError() }
    public func forceWaitlistStatus(_: GenerativeModelsAvailabilityFoundationClient.ForceWaitlistStatusParameters) async throws -> () { fatalError() }
    public func secureWriteCloudSubscriptionFeaturesAvailability(_: GenerativeModelsAvailabilityFoundationClient.CloudSubscriptionFeaturesAvailabilityWrapper) async throws -> () { fatalError() }
    public func updateCSFOptInStatus(optedIn: Bool) async throws -> () { fatalError() }
    public func updateCSFAccessStatus(accessGranted: Bool) async throws -> () { fatalError() }
    public func didShowEnrollmentScreen(useCaseIdentifier: String) async throws -> () { fatalError() }
    public func updateCFUSentDate(for: GenerativeModelsAvailabilityFoundationClient.CFUType, date: Date) async throws -> () { fatalError() }
    public func updateCSFAssetStatus(unavailableReasons: Set<GenerativeModelsAvailabilityFoundationClient.CloudSubscriptionFeaturesAssetUnavailableReason>) async throws -> () { fatalError() }
}

public class AvailabilityInternalClient {
    public init() { fatalError() }
    public func cloudAvailability() async -> Optional<CloudAvailability> { fatalError() }
    public func clearOverrides() async -> () { fatalError() }
    public func removeAll() async -> () { fatalError() }
    public func updateCache(disabledUseCases: Set<String>) async -> () { fatalError() }
    public func setOverride(_: Optional<Any>, forKey: String) async -> () { fatalError() }
    public func updateAll(updateReason: String) async -> () { fatalError() }
    public func fetchDesiredLanguages() async throws -> Array<String> { fatalError() }
    public func getOverrides() async throws -> Dictionary<String, Any> { fatalError() }
}

public struct AvailabilityInternalXPCService {
    public static var entitlementName: String { get { fatalError() } set { fatalError() } }
    public static var interface: Protocol { get { fatalError() } set { fatalError() } }
    public static var logger: Logger { get { fatalError() } set { fatalError() } }
    public static var selectorClasses: KeyValuePairs<(Selector, Int), Set<AnyHashable>> { get { fatalError() } set { fatalError() } }
    public static var serviceName: String { get { fatalError() } set { fatalError() } }
}

public class AvailabilityNotificationObservation {
    public static func ensureCacheInvalidationRegistered() -> () { fatalError() }
}

public struct AvailabilityOverrides {
    public static var allOverrides: Dictionary<String, Any> { get { fatalError() } }
    public static func clear() -> () { fatalError() }
    public static func set(override: Optional<Any>, forKey: String) -> () { fatalError() }
    public static func describe(value: Any, pretty: Bool) -> String { fatalError() }
    public static func override(forKey: String) -> Optional<Any> { fatalError() }
    public static func regularKey(for: String) -> Optional<String> { fatalError() }
    public static func overrideKey(for: String) -> String { fatalError() }
}

public struct AvailabilityResultCache {
    public static func lookup(key: AvailabilityCacheKey) -> (value: Optional<GenerativeModelsAvailability>, generation: UInt64) { fatalError() }
    public static func invalidate() -> () { fatalError() }
    public static func insert(key: AvailabilityCacheKey, value: GenerativeModelsAvailability, ifGeneration: UInt64) -> Bool { fatalError() }
    public static var currentGeneration: UInt64 { get { fatalError() } }
}

public struct AvailabilityStore {
    public struct Availability {
        public init(rawValue: Int) { fatalError() }
        public var description: String { get { fatalError() } }
        public var rawValue: Int { get { fatalError() } }
    }
    public struct EnhancedSiriBootState {
        public static func ==(_: AvailabilityStore.EnhancedSiriBootState, _: AvailabilityStore.EnhancedSiriBootState) -> Bool { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct ReadinessEntry {
        public struct Criteria {
            public func matches(_: A) -> Bool { fatalError() }
            public var description: String { get { fatalError() } }
            public static func ==(_: AvailabilityStore.ReadinessEntry.Criteria, _: AvailabilityStore.ReadinessEntry.Criteria) -> Bool { fatalError() }
            public var debugDescription: String { get { fatalError() } }
        }
        public init(from: Decoder) throws { fatalError() }
        public init(language: AvailabilityStore.ReadinessEntry.Criteria<Locale.LanguageCode>, additionalCriteria: AvailabilityStore.ReadinessEntry.Criteria<Bool>, isReady: Bool) { fatalError() }
        public func matchesRegion(of: GenerativeModelsAvailability.Parameters) -> Bool { fatalError() }
        public static func ==(_: AvailabilityStore.ReadinessEntry, _: AvailabilityStore.ReadinessEntry) -> Bool { fatalError() }
        public var additionalCriteria: AvailabilityStore.ReadinessEntry.Criteria<Bool> { get { fatalError() } set { fatalError() } }
        public var language: AvailabilityStore.ReadinessEntry.Criteria<Locale.LanguageCode> { get { fatalError() } set { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public func matchesLanguage(of: inout GenerativeModelsAvailability.Parameters) -> Bool { fatalError() }
        public var isReady: Bool { get { fatalError() } set { fatalError() } }
    }
    public struct Reason {
        public init(rawValue: Int) { fatalError() }
        public var description: String { get { fatalError() } }
        public var rawValue: Int { get { fatalError() } }
    }
    public struct Secure {
        public static func vmHostAvailability(user: UInt32) -> Bool { fatalError() }
        public static func unavailableReasons(user: UInt32) -> Set<GenerativeModelsAvailability.Availability.UnavailableInfo.UnavailableReason> { fatalError() }
        public static func availability(parameters: GenerativeModelsAvailability.Parameters, user: UInt32) -> GenerativeModelsAvailability.Availability { fatalError() }
        public static func restrictedReasons(user: UInt32) -> Set<GenerativeModelsAvailability.Availability.RestrictedInfo.RestrictedReason> { fatalError() }
        public static func users() -> Array<UInt32> { fatalError() }
    }
    public struct UnifiedReason {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var description: String { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public static func ==(_: AvailabilityStore.UnifiedReason, _: AvailabilityStore.UnifiedReason) -> Bool { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct UseCases {
        public struct AccessControlledUseCase {
            public init(rawValue: String) { fatalError() }
            public static var allCases: Array<AvailabilityStore.UseCases.AccessControlledUseCase> { get { fatalError() } }
            public var rawValue: String { get { fatalError() } }
        }
        public init() { fatalError() }
        public var prettyPrintSimpleJSONSettings: String { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public static var enhancedSiriBootState: AvailabilityStore.EnhancedSiriBootState { get { fatalError() } }
    public static var enhancedSiriWasEverAvailable: Bool { get { fatalError() } }
    public static var foundationModelsCompatibilityVersionsInfo: FoundationModelsCompatibilityVersionsInfo { get { fatalError() } }
    public static var restrictedReasons: Set<GenerativeModelsAvailability.Availability.RestrictedInfo.RestrictedReason> { get { fatalError() } }
    public static var updatedSinceBoot: Bool { get { fatalError() } }
    public static var wasEverAvailable: Bool { get { fatalError() } }
    public static func set(updatedSinceBoot: Bool) -> Bool { fatalError() }
    public static var unavailableReasons: Set<GenerativeModelsAvailability.Availability.UnavailableInfo.UnavailableReason> { get { fatalError() } }
    public static var visualIntelligenceControlWidgetMigrated: Bool { get { fatalError() } }
    public static func hasAppEverBeenInstalled(_: String) -> Bool { fatalError() }
}

public struct AvailabilityXPCService {
}

public struct BindableChatMessagesPrompt {
    public init(name: String) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func toChatMessagesPrompt() -> ChatMessagesPrompt { fatalError() }
}

public struct BindableConfiguration {
    public init(from: Decoder) throws { fatalError() }
    public init(name: String) { fatalError() }
    public var name: String { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct BindableVariable {
    public init(name: String) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var name: String { get { fatalError() } }
    public func toValue() -> Prompt.Component.Value { fatalError() }
}

public struct CachePolicy {
    public struct Kind {
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct Kind18446744073709550616 {
    }
    public init(_: Tokengeneration_Wireformat_CachePolicy) throws { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var kind: CachePolicy.Kind { get { fatalError() } set { fatalError() } }
    public var wireFormat: Tokengeneration_Wireformat_CachePolicy { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct CachePolicy18446744073709550616 {
}

public class CachedSafetyModelsWrapper {
    public init(from: Decoder) throws { fatalError() }
    public init() { fatalError() }
    public func clear() -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var count: Int { get { fatalError() } }
}

public struct CatalogPromptContentTemplate {
    public init(templateID: String, values: Dictionary<String, PromptComponentValueConvertible>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func toValue() -> Prompt.Component.Value { fatalError() }
    public var templateID: String { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var values: Dictionary<String, Prompt.Component.Value> { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct ChatMessagePrompt {
    public init(role: ChatMessageRole, prompt: Prompt, locale: Optional<Locale>) { fatalError() }
    public init(wireFormatBytes: Data) throws { fatalError() }
    public init(role: ChatMessageRole, prompt: () throws -> Prompt) throws { fatalError() }
    public init(rolePrompt: ChatMessageRolePrompt, prompt: Prompt, locale: Optional<Locale>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(role: ChatMessageRole, prompt: Prompt) { fatalError() }
    public var toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>> { get { fatalError() } }
    public func mapStringComponents(_: (String) throws -> String) throws -> ChatMessagePrompt { fatalError() }
    public var user: Optional<ChatMessageRolePrompt.User> { get { fatalError() } }
    public func toChatMessagePrompt() -> ChatMessagePrompt { fatalError() }
    public func mapStringComponents(_: (String) async throws -> String) async throws -> ChatMessagePrompt { fatalError() }
    public var role: ChatMessageRole { get { fatalError() } }
    public func contains(_: Prompt.Component.ValueKind) -> Bool { fatalError() }
    public var assistant: Optional<ChatMessageRolePrompt.Assistant> { get { fatalError() } }
    public var custom: Optional<ChatMessageRolePrompt.Custom> { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var locale: Optional<Locale> { get { fatalError() } set { fatalError() } }
    public var modalities: Optional<Array<Modality>> { get { fatalError() } }
    public var prompt: Prompt { get { fatalError() } set { fatalError() } }
    public var rolePrompt: ChatMessageRolePrompt { get { fatalError() } set { fatalError() } }
    public var system: Optional<ChatMessageRolePrompt.System> { get { fatalError() } }
    public var wireFormatBytes: Data { get { fatalError() } }
    public func compactMapStringComponents(_: (String) throws -> Optional<String>) throws -> ChatMessagePrompt { fatalError() }
    public func compactMapStringComponents(_: (String) async throws -> Optional<String>) async throws -> ChatMessagePrompt { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var responseFormat: Optional<ResponseFormat> { get { fatalError() } }
    public var tool: Optional<ChatMessageRolePrompt.Tool> { get { fatalError() } }
    public var voice: Optional<Voice> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var thoughtBudget: Optional<ThoughtBudget> { get { fatalError() } }
}

public protocol ChatMessagePromptConvertible {
    func toChatMessagePrompt() -> ChatMessagePrompt
}

public struct ChatMessageRolePrompt {
    public struct Assistant {
        public init(thoughts: Optional<Thoughts>) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public init() { fatalError() }
        public init(thoughtContent: Optional<Prompt>) { fatalError() }
        public var thoughtContent: Optional<Prompt> { get { fatalError() } set { fatalError() } }
        public var thoughts: Optional<Thoughts> { get { fatalError() } set { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct Custom {
        public init(from: Decoder) throws { fatalError() }
        public init(roleName: String) { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct System {
        public init(from: Decoder) throws { fatalError() }
        public init(toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>>, modalities: Optional<Array<Modality>>, voice: Optional<Voice>, thoughtBudget: Optional<ThoughtBudget>, prefixID: Optional<String>) { fatalError() }
        public init(toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>>) { fatalError() }
        public init(toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>>, modalities: Optional<Array<Modality>>, voice: Optional<Voice>) { fatalError() }
        public init(toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>>, modalities: Optional<Array<Modality>>, voice: Optional<Voice>, shouldPrependDefaultSystemInstruction: Bool) { fatalError() }
        public init(toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>>, modalities: Optional<Array<Modality>>, voice: Optional<Voice>, thoughtBudget: Optional<ThoughtBudget>) { fatalError() }
        public var modalities: Optional<Array<Modality>> { get { fatalError() } set { fatalError() } }
        public var prefixID: Optional<String> { get { fatalError() } set { fatalError() } }
        public var shouldPrependDefaultSystemInstruction: Bool { get { fatalError() } }
        public var toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>> { get { fatalError() } set { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var thoughtBudget: Optional<ThoughtBudget> { get { fatalError() } set { fatalError() } }
        public var voice: Optional<Voice> { get { fatalError() } set { fatalError() } }
    }
    public struct Tool {
        public init() { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct User {
        public init(from: Decoder) throws { fatalError() }
        public init(responseFormat: Optional<ResponseFormat>) { fatalError() }
        public var responseFormat: Optional<ResponseFormat> { get { fatalError() } set { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ChatMessagesPrompt {
    public init(_: () throws -> ChatMessagesPrompt) throws { fatalError() }
    public init(_: Array<ChatMessagePrompt>) { fatalError() }
    public init(overridableConfigurationStorage: OverridableConfigurationStorage, runnableConfigurationStorage: RunnableConfigurationStorage) { fatalError() }
    public init() { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func contains(_: Prompt.Component.ValueKind) -> Bool { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func mapMessages(_: (ChatMessagePrompt) throws -> ChatMessagePrompt) throws -> ChatMessagesPrompt { fatalError() }
    public func lastMessage(withRole: ChatMessageRole) -> Optional<ChatMessagePrompt> { fatalError() }
    public func compactMapMessages(_: (ChatMessagePrompt) async throws -> Optional<ChatMessagePrompt>) async throws -> ChatMessagesPrompt { fatalError() }
    public func toChatMessagesPrompt() -> ChatMessagesPrompt { fatalError() }
    public func mutateLast(_: ChatMessageRole, _: (ChatMessagePrompt) async throws -> ChatMessagePrompt) async throws -> () { fatalError() }
    public var _overridableConfigurationStorage: OverridableConfigurationStorage { get { fatalError() } set { fatalError() } }
    public func mapStringComponents(_: (String) throws -> String) throws -> ChatMessagesPrompt { fatalError() }
    public func messages(withRole: ChatMessageRole) -> Array<ChatMessagePrompt> { fatalError() }
    public var _runnableConfigurationStorage: RunnableConfigurationStorage { get { fatalError() } set { fatalError() } }
    public func firstMessage(withRole: ChatMessageRole) -> Optional<ChatMessagePrompt> { fatalError() }
    public func compactMapStringComponents(_: (String) throws -> Optional<String>) throws -> ChatMessagesPrompt { fatalError() }
    public var system: Optional<ChatMessageRolePrompt.System> { get { fatalError() } }
    public func joinedStringComponents(separator: String) -> String { fatalError() }
    public var promptRequest: PromptRequest { get { fatalError() } }
    public var toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>> { get { fatalError() } }
    public func filterMessages(_: (ChatMessagePrompt) -> Bool) -> ChatMessagesPrompt { fatalError() }
    public func filterMessages(_: (ChatMessagePrompt) async -> Bool) async -> ChatMessagesPrompt { fatalError() }
    public func compactMapMessages(_: (ChatMessagePrompt) throws -> Optional<ChatMessagePrompt>) throws -> ChatMessagesPrompt { fatalError() }
    public func mapMessages(_: (ChatMessagePrompt) async throws -> ChatMessagePrompt) async throws -> ChatMessagesPrompt { fatalError() }
    public func mapStringComponents(_: (String) async throws -> String) async throws -> ChatMessagesPrompt { fatalError() }
    public func mutateLast(_: ChatMessageRole, _: (ChatMessagePrompt) throws -> ChatMessagePrompt) throws -> () { fatalError() }
    public func compactMapStringComponents(_: (String) async throws -> Optional<String>) async throws -> ChatMessagesPrompt { fatalError() }
    public func locale(_: Optional<Locale>) -> ChatMessagesPrompt { fatalError() }
    public var chatMessages: Array<ChatMessagePrompt> { get { fatalError() } set { fatalError() } }
}

public struct ChatMessagesPromptBuilder {
}

public protocol ChatMessagesPromptConvertible {
    func toChatMessagesPrompt() -> ChatMessagesPrompt
}

public struct ChatPromptAggregator {
    public struct AggregationResult {
        public init(prompt: PromptRequest.PromptVariant.ChatPrompt, newToolCalls: Array<Prompt.ToolCall>) { fatalError() }
        public var newToolCalls: Array<Prompt.ToolCall> { get { fatalError() } set { fatalError() } }
        public var prompt: PromptRequest.PromptVariant.ChatPrompt { get { fatalError() } set { fatalError() } }
    }
    public init(prompt: PromptRequest.PromptVariant.ChatPrompt) { fatalError() }
    public func consume(tokens: String) -> () { fatalError() }
    public func consume(thoughtContent: InferenceOutputDelta.ThoughtContentDelta) -> () { fatalError() }
    public func finish() -> ChatPromptAggregator.AggregationResult { fatalError() }
    public func consume(toolCallDelta: ToolCallParser.FunctionDelta) -> () { fatalError() }
    public func consume(toolOutput: Prompt.ToolResult) -> () { fatalError() }
}

public struct ChatPromptBuilder {
}

public struct Choice {
    public init(sequence: Array<Symbol>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var sequence: Array<Symbol> { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public class ClassificationGenerator {
    public init(configuration: SessionConfiguration) { fatalError() }
    public func classify(prompt: Optional<PromptVariant>, promptTemplateInfo: PromptTemplateInfo, parameters: ClassificationParameters) async throws -> ClassificationResponse { fatalError() }
    public func classify(prompt: PromptRequest, parameters: ClassificationParameters, clientRequestIdentifier: Optional<String>) async throws -> ClassificationResponse { fatalError() }
    public func classify(promptRequest: Optional<PromptRequest>, promptTemplateInfo: PromptTemplateInfo, parameters: ClassificationParameters, clientRequestIdentifier: Optional<String>) async throws -> ClassificationResponse { fatalError() }
    public func classify(promptRequest: Optional<PromptRequest>, promptTemplateInfo: PromptTemplateInfo, parameters: ClassificationParameters) async throws -> ClassificationResponse { fatalError() }
    public var configuration: Optional<SessionConfiguration> { get { fatalError() } }
    public func classify(prompt: PromptRequest, parameters: ClassificationParameters) async throws -> ClassificationResponse { fatalError() }
    public func classify(prompt: PromptVariant, parameters: ClassificationParameters) async throws -> ClassificationResponse { fatalError() }
}

public struct ClassificationParameters {
    public struct ThresholdConfiguration {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct ThresholdConfiguration18446744073709550616 {
    }
    public init(thresholdConfiguration: ClassificationParameters.ThresholdConfiguration, shouldFallbackToDefaultThresholds: Bool) { fatalError() }
    public init(thresholdIdentifier: String, shouldFallbackToDefaultThresholds: Bool) { fatalError() }
    public init() { fatalError() }
    public var shouldFallbackToDefaultThresholds: Bool { get { fatalError() } }
    public var thresholdConfiguration: ClassificationParameters.ThresholdConfiguration { get { fatalError() } }
}

public struct ClassificationParameters18446744073709550616 {
}

public struct ClassificationResponse {
    public init(labels: Dictionary<String, Bool>, modelInformation: ModelInformation, didFallbackToDefaultThresholds: Bool, renderedPrompt: Optional<Prompt.Rendering>) { fatalError() }
    public init(labels: Dictionary<String, Bool>, modelInformation: ModelInformation, didFallbackToDefaultThresholds: Bool) { fatalError() }
    public var didFallbackToDefaultThresholds: Bool { get { fatalError() } }
    public var labels: Dictionary<String, Bool> { get { fatalError() } set { fatalError() } }
    public var modelInformation: ModelInformation { get { fatalError() } set { fatalError() } }
    public var renderedPrompt: Optional<Prompt.Rendering> { get { fatalError() } set { fatalError() } }
}

public struct ClassificationResponse18446744073709550616 {
}

public struct ClassifyPromptRequest {
    public init(from: Decoder) throws { fatalError() }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var parameters: ClassificationParameters { get { fatalError() } }
    public var prompt: PromptRequest { get { fatalError() } set { fatalError() } }
    public var tgPrompt: Prompt { get { fatalError() } set { fatalError() } }
}

public struct ClassifyPromptResponse {
    public init(from: Decoder) throws { fatalError() }
    public init(response: ClassificationResponse) { fatalError() }
    public var response: ClassificationResponse { get { fatalError() } }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ClassifyPromptTemplateRequest {
    public init(from: Decoder) throws { fatalError() }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var prompt: Optional<Prompt> { get { fatalError() } set { fatalError() } }
    public var promptRequest: Optional<PromptRequest> { get { fatalError() } set { fatalError() } }
    public var promptTemplateInfo: PromptTemplateInfo { get { fatalError() } set { fatalError() } }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var parameters: ClassificationParameters { get { fatalError() } }
}

public struct CloudAvailability {
    public init(coder: NSCoder) { fatalError() }
    public init() { fatalError() }
    public init(state: Optional<String>, reasons: Optional<String>, bypass: Bool) { fatalError() }
    public func encode(with: NSCoder) -> () { fatalError() }
    public var bypass: Bool { get { fatalError() } }
    public var reasons: Optional<String> { get { fatalError() } }
    public var state: Optional<String> { get { fatalError() } }
    public static var supportsSecureCoding: Bool { get { fatalError() } set { fatalError() } }
}

public struct CloudGuardrails {
    public struct InputPolicy {
        public init(contentSafetyEnabled: Bool) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var contentSafetyEnabled: Bool { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct InputProcessingPolicy {
        public init(from: Decoder) throws { fatalError() }
        public init(separateImageEnabled: Bool) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var separateImageEnabled: Bool { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public init(inputPolicies: Array<GenerativeModelsCloudGuardrails.InputPolicy>, inputProcessingPolicies: Array<GenerativeModelsCloudGuardrails.InputProcessingPolicy>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var inputPolicies: Array<GenerativeModelsCloudGuardrails.InputPolicy> { get { fatalError() } }
    public var inputProcessingPolicies: Array<GenerativeModelsCloudGuardrails.InputProcessingPolicy> { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct CloudGuardrailsEnvelope {
    public struct InputPolicy {
        public init(from: Decoder) throws { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var contentSafetyEnabled: Bool { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct InputProcessingPolicy {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var separateImageEnabled: Bool { get { fatalError() } }
    }
    public init(sealing: GenerativeModelsCloudGuardrails) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var inputPolicies: Array<CloudGuardrailsEnvelope.InputPolicy> { get { fatalError() } }
    public var inputProcessingPolicies: Array<CloudGuardrailsEnvelope.InputProcessingPolicy> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func unseal() -> GenerativeModelsCloudGuardrails { fatalError() }
}

public struct CompileAdapterRequest {
    public init(from: Decoder) throws { fatalError() }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var dryRun: Bool { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var info: Optional<FoundationModelsExtensionInfo> { get { fatalError() } }
    public var secureIdentifier: String { get { fatalError() } }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
}

public struct CompileAdapterResponse {
    public struct DraftModelCompileResult {
        public init(from: Decoder) throws { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public init(from: Decoder) throws { fatalError() }
    public init(draftModelCompileResult: CompileAdapterResponse.DraftModelCompileResult) { fatalError() }
    public var draftModelCompileResult: CompileAdapterResponse.DraftModelCompileResult { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct CompletePromptRequest {
    public init(wireFormatJsonUTF8Bytes: Data) throws { fatalError() }
    public init(wireFormatBytes: Data) throws { fatalError() }
    public init(_: Tokengeneration_Wireformat_CompletePromptRequest, xpcData: Optional<XPC.XPCDictionary>) throws { fatalError() }
    public var constraints: Optional<Constraints> { get { fatalError() } }
    public var documents: Array<GenerativeModelsDocumentResourceIdentifier> { get { fatalError() } }
    public var parameters: SamplingParameters { get { fatalError() } }
    public var requestConfiguration: RequestConfiguration { get { fatalError() } }
    public var tools: Array<ToolDescription> { get { fatalError() } }
    public var wireFormatBytes: Data { get { fatalError() } }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func wireFormat(xpcData: inout Optional<XPC.XPCDictionary>) -> Tokengeneration_Wireformat_CompletePromptRequest { fatalError() }
    public var deadlineSchedule: Optional<DeadlineSchedule> { get { fatalError() } }
    public var inheritToolDefinitionsFromPrompt: Optional<Bool> { get { fatalError() } }
    public var prompt: Prompt { get { fatalError() } set { fatalError() } }
    public var promptRequest: PromptRequest { get { fatalError() } set { fatalError() } }
    public var toolChoice: Optional<GenerativeFunctionsToolChoice> { get { fatalError() } }
    public var toolDefinitions: Array<GenerativeFunctionsToolDefinition> { get { fatalError() } }
    public var wireFormatJsonUTF8Bytes: Data { get { fatalError() } }
}

public struct CompletePromptResponse {
    public init(completion: PromptCompletion) { fatalError() }
    public init(tokens: Array<Token>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(toolCalls: Array<Prompt.ToolCall>) { fatalError() }
    public var completion: PromptCompletion { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var tokens: Array<Token> { get { fatalError() } }
    public var toolCalls: Array<Prompt.ToolCall> { get { fatalError() } }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
}

public struct CompletePromptResponse18446744073709550616 {
}

public struct CompletePromptResponseElement {
    public init(token: Token) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(_: PromptCompletionEvent) { fatalError() }
    public var event: PromptCompletionEvent { get { fatalError() } }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var token: Token { get { fatalError() } }
}

public struct CompletePromptResponseElement18446744073709550616 {
}

public struct CompletePromptTemplateRequest {
    public init(from: Decoder) throws { fatalError() }
    public var constraints: Optional<Constraints> { get { fatalError() } }
    public var deadlineSchedule: Optional<DeadlineSchedule> { get { fatalError() } }
    public var documents: Array<GenerativeModelsDocumentResourceIdentifier> { get { fatalError() } }
    public var parameters: SamplingParameters { get { fatalError() } }
    public var promptTemplateInfo: PromptTemplateInfo { get { fatalError() } set { fatalError() } }
    public var tools: Array<ToolDescription> { get { fatalError() } }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var prompt: Optional<Prompt> { get { fatalError() } set { fatalError() } }
    public var promptRequest: Optional<PromptRequest> { get { fatalError() } }
    public var toolChoice: Optional<GenerativeFunctionsToolChoice> { get { fatalError() } }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
}

public struct CompletionPrompt {
    public init(stringLiteral: String) { fatalError() }
    public init(_: () async throws -> Prompt) async throws { fatalError() }
    public init(stringInterpolation: Prompt.StringInterpolation) { fatalError() }
    public init(_: Prompt) { fatalError() }
    public init(_: () throws -> Prompt) throws { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(overridableConfigurationStorage: OverridableConfigurationStorage, runnableConfigurationStorage: RunnableConfigurationStorage) { fatalError() }
    public var _runnableConfigurationStorage: RunnableConfigurationStorage { get { fatalError() } set { fatalError() } }
    public var promptRequest: PromptRequest { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var _overridableConfigurationStorage: OverridableConfigurationStorage { get { fatalError() } set { fatalError() } }
    public var prompt: Prompt { get { fatalError() } set { fatalError() } }
}

public struct CompositeInferenceOutputParser {
    public struct ParserOptions {
        public init(rawValue: Int) { fatalError() }
        public var rawValue: Int { get { fatalError() } }
    }
    public init(version: PromptPreprocessingTemplateVersion, parserOptions: CompositeInferenceOutputParser.ParserOptions) { fatalError() }
    public var isOutputParsingInProgress: Bool { get { fatalError() } }
    public func consume(string: String) -> Array<InferenceOutputDelta> { fatalError() }
}

public struct Constraints {
    public init(_: Tokengenerationcore_Wireformat_Constraints) throws { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var wireFormat: Tokengenerationcore_Wireformat_Constraints { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct Constraints18446744073709550616 {
}

public struct ContiguousBitSet {
    public struct Iterator {
        public func next() -> Optional<Int> { fatalError() }
    }
    public init(_: ClosedRange<Int>) { fatalError() }
    public init(_: Range<Int>) { fatalError() }
    public init(reservedCapacity: Int) { fatalError() }
    public init(_: any Sequence) { fatalError() }
    public var count: Int { get { fatalError() } }
    public func formIntersection(_: Range<Int>) -> () { fatalError() }
    public func insert(_: Int) -> () { fatalError() }
    public func forEachValue(_: (Bool) throws -> ()) throws -> () { fatalError() }
    public var first: Optional<Int> { get { fatalError() } }
    public func intersection(_: ContiguousBitSet) -> ContiguousBitSet { fatalError() }
    public func copyStorageWords(to: UnsafeMutablePointer<UInt64>, wordCount: Int) -> Int { fatalError() }
    public func union(_: Range<Int>) -> ContiguousBitSet { fatalError() }
    public var isDense: Bool { get { fatalError() } }
    public func isEquivalent(to: Range<Int>) -> Bool { fatalError() }
    public func makeIterator() -> ContiguousBitSet.Iterator { fatalError() }
    public var isEmpty: Bool { get { fatalError() } }
    public func union(_: ContiguousBitSet) -> ContiguousBitSet { fatalError() }
    public func applyMask(_: inout Array<Float16>, maskValue: Float16) -> () { fatalError() }
    public func remove(_: Int) -> () { fatalError() }
    public func toBytes() -> Data { fatalError() }
    public var last: Optional<Int> { get { fatalError() } }
    public func intersection(_: Range<Int>) -> ContiguousBitSet { fatalError() }
    public func subtracting(_: ContiguousBitSet) -> ContiguousBitSet { fatalError() }
    public func formIntersection(_: ContiguousBitSet) -> () { fatalError() }
    public func update(with: Int) -> () { fatalError() }
    public func makeBooleanMask(count: Optional<Int>) -> ContiguousArray<Bool> { fatalError() }
    public func applyMask(_: UnsafeMutableBufferPointer<Float16>, maskValue: Float16) -> () { fatalError() }
    public func isDisjoint(with: ContiguousBitSet) -> Bool { fatalError() }
    public func formUnion(_: ContiguousBitSet) -> () { fatalError() }
    public func indices() -> Array<Int> { fatalError() }
    public func contains(_: Int) -> Bool { fatalError() }
    public func formUnion(_: Range<Int>) -> () { fatalError() }
}

public struct CountTokensPromptTemplateRequest {
    public init(from: Decoder) throws { fatalError() }
    public var promptRequest: Optional<PromptRequest> { get { fatalError() } }
    public var promptTemplateInfo: PromptTemplateInfo { get { fatalError() } }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var prompt: Optional<Prompt> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct CountTokensRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var prompt: Prompt { get { fatalError() } }
    public var promptRequest: PromptRequest { get { fatalError() } set { fatalError() } }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
}

public struct CountTokensResponse {
    public init(from: Decoder) throws { fatalError() }
    public init(count: Int, renderedPrompt: Optional<Prompt.Rendering>) { fatalError() }
    public var count: Int { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var renderedPrompt: Optional<Prompt.Rendering> { get { fatalError() } }
}

public struct CurrentNetworkConditionsRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct CurrentNetworkConditionsResponse {
    public init(from: Decoder) throws { fatalError() }
    public init(lastConnectionProgressReport: Optional<Network.NWConnection.ConnectionProgressReport>) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var lastConnectionProgressReport: Optional<Network.NWConnection.ConnectionProgressReport> { get { fatalError() } set { fatalError() } }
}

public struct CurrentRateLimitStatusRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var useCaseID: String { get { fatalError() } }
}

public struct CurrentRateLimitStatusResponse {
    public init(from: Decoder) throws { fatalError() }
    public init(rateLimitExceeded: Bool, retryAfter: Optional<Date>) { fatalError() }
    public init(rateLimitExceeded: Bool, retryAfter: Optional<Date>, isApproachingRateLimit: Bool) { fatalError() }
    public var isApproachingRateLimit: Bool { get { fatalError() } }
    public var rateLimitExceeded: Bool { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var retryAfter: Optional<Date> { get { fatalError() } }
}

public protocol CustomChatMessageRole {
}

public struct CustomPromptBuilder {
}

public struct DeadlineSchedule {
    public init(marginTokenCount: Int, period: Double, minDeadlineSeconds: Double, phaseReferenceMCT: Optional<UInt64>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var minDeadlineSeconds: Double { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var marginTokenCount: Int { get { fatalError() } set { fatalError() } }
    public var period: Double { get { fatalError() } set { fatalError() } }
    public var phaseReferenceMCT: Optional<UInt64> { get { fatalError() } set { fatalError() } }
}

public struct DecodingLoop {
    public func consume(_: Int) throws -> RollbackStatus { fatalError() }
    public func nextTokenIDMaskComputation() async throws -> TokenIDMaskComputation { fatalError() }
    public func validate(candidateTokenIDs: Array<Int>) async throws -> Optional<Int> { fatalError() }
    public func nextTokensPossiblyDeterministic() throws -> Bool { fatalError() }
    public func generateNextTokenIDMask() throws -> TokenIDMaskResponse { fatalError() }
}

public struct DeleteDataRequest {
    public init(from: Decoder) throws { fatalError() }
    public var key: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var accessGroup: GenerativeModelsAccessGroup { get { fatalError() } }
    public var auditID: Optional<UInt32> { get { fatalError() } }
}

public struct DenyListUtility {
    public struct DenyList {
        public init(reject: Array<String>, remove: Array<String>, replace: Dictionary<String, String>) { fatalError() }
        public init(reject: Array<String>, remove: Array<String>, replace: Dictionary<String, String>, regexReject: Optional<Array<String>>, regexRemove: Optional<Array<String>>, regexReplace: Optional<Dictionary<String, String>>) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public var regexReplace: Optional<Dictionary<String, String>> { get { fatalError() } }
        public var reject: Array<String> { get { fatalError() } }
        public var remove: Array<String> { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var regexReject: Optional<Array<String>> { get { fatalError() } }
        public var regexRemove: Optional<Array<String>> { get { fatalError() } }
        public var replace: Dictionary<String, String> { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
}

public struct DocumentRegistration {
    public struct InternalStatus {
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct Progress {
        public init(progress: Float, bytes: UInt, totalBytes: UInt) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var bytes: UInt { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var progress: Float { get { fatalError() } }
        public var totalBytes: UInt { get { fatalError() } }
    }
    public struct Status {
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public var hashValue: Int { get { fatalError() } }
    public var internalStatus: GenerativeModelsDocumentRegistration.InternalStatus { get { fatalError() } }
    public var status: GenerativeModelsDocumentRegistration.Status { get { fatalError() } }
    public var url: URL { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct DocumentRegistrationEnvelope {
    public init(sealing: GenerativeModelsDocumentRegistration) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func unseal() -> GenerativeModelsDocumentRegistration { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct DocumentResource {
    public init(_: URL, _: Int32, _: Dictionary<String, String>) { fatalError() }
    public init(url: URL) { fatalError() }
    public var fileDescriptor: Int32 { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var url: URL { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct DocumentResourceIdentifier {
    public init(id: String, url: URL) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(id: String) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var url: URL { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var id: String { get { fatalError() } }
}

public struct DocumentResourceIdentifier18446744073709550616 {
}

public struct DoubleGuides {
    public init(minimum: Optional<Double>, maximum: Optional<Double>) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct DraftAlwaysAcceptRange {
    public init(from: Decoder) throws { fatalError() }
    public init(start: String, end: String, interval: Int) { fatalError() }
    public var end: String { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var start: String { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var interval: Int { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct DraftAlwaysAcceptRange18446744073709550616 {
}

public class EarleyRecognizer {
    public struct RecognizerValidatorCache {
    }
    public struct State {
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public func nextValidTerminalsWithCacheKey() -> (cacheKey: Optional<Int>, nextValidTerminals: Array<TerminalSymbol>) { fatalError() }
    public func validate(validatorCache: inout EarleyRecognizer.RecognizerValidatorCache, string: String, skipFirst: Int) -> Bool { fatalError() }
    public func validate(byteTokenValue: UInt8) -> Bool { fatalError() }
    public func childRecognizer(consumingString: String) -> Optional<EarleyRecognizer> { fatalError() }
    public func childRecognizer(consumingElement: RecognizerElement) -> Optional<EarleyRecognizer> { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func nextValidTerminals() -> Array<TerminalSymbol> { fatalError() }
    public func createValidatorCache() -> EarleyRecognizer.RecognizerValidatorCache { fatalError() }
    public var fullMatch: Bool { get { fatalError() } }
    public func nextTerminalsPotentiallyDeterministic() -> Bool { fatalError() }
    public var specialTokenIDSet: Set<Int> { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var characterSetsUsedInGrammar: Array<CharacterSet> { get { fatalError() } }
    public var debugDescription: String { get { fatalError() } }
    public var lastConsumedElement: Optional<RecognizerElement> { get { fatalError() } }
}

public struct EmbeddingContent {
    public init(content: String) { fatalError() }
    public var content: String { get { fatalError() } set { fatalError() } }
}

public struct EmbeddingGeneration {
    public struct EmbeddingResponse {
        public struct AdditionalInformation {
            public init(usage: EmbeddingGeneration.Usage, didTruncateInput: Bool) { fatalError() }
            public var didTruncateInput: Bool { get { fatalError() } set { fatalError() } }
            public var usage: EmbeddingGeneration.Usage { get { fatalError() } set { fatalError() } }
        }
        public init(embedding: Array<Float>, additionalInformation: EmbeddingGeneration.EmbeddingResponse.AdditionalInformation) { fatalError() }
        public var additionalInformation: EmbeddingGeneration.EmbeddingResponse.AdditionalInformation { get { fatalError() } set { fatalError() } }
        public var embedding: Array<Float> { get { fatalError() } set { fatalError() } }
    }
    public struct Usage {
        public init(tokenCount: Int) { fatalError() }
        public var tokenCount: Int { get { fatalError() } set { fatalError() } }
    }
    public init(embeddings: Array<EmbeddingGeneration.EmbeddingResponse>, modelInformation: InferenceResponse.ModelInformation) { fatalError() }
    public var embeddings: Array<EmbeddingGeneration.EmbeddingResponse> { get { fatalError() } set { fatalError() } }
    public var modelInformation: InferenceResponse.ModelInformation { get { fatalError() } set { fatalError() } }
}

public struct EmbeddingGenerationParameters {
    public init(shouldAutomaticallyTruncateInputContent: Bool) { fatalError() }
    public init(shouldAutomaticallyTruncateInputContent: Bool, outputDimensions: Int) { fatalError() }
    public var outputDimensions: Optional<Int> { get { fatalError() } set { fatalError() } }
    public var shouldAutomaticallyTruncateInputContent: Bool { get { fatalError() } set { fatalError() } }
}

public class EmbeddingGenerator {
    public init(configuration: SessionConfiguration) { fatalError() }
    public func embeddingModelInformation() async throws -> Optional<EmbeddingModelInformation> { fatalError() }
    public func embeddings(for: Array<EmbeddingTask>, parameters: EmbeddingGenerationParameters) async throws -> EmbeddingGeneration { fatalError() }
    public var configuration: Optional<SessionConfiguration> { get { fatalError() } }
}

public struct EmbeddingModelInformation {
    public init(defaultOutputDimensions: Int, modelInformation: InferenceResponse.ModelInformation) { fatalError() }
    public var defaultOutputDimensions: Int { get { fatalError() } set { fatalError() } }
    public var modelInformation: InferenceResponse.ModelInformation { get { fatalError() } set { fatalError() } }
}

public struct EmbeddingModelInformationRequest {
}

public struct EmbeddingModelInformationResponse {
    public init(response: EmbeddingModelInformation) { fatalError() }
    public var response: EmbeddingModelInformation { get { fatalError() } set { fatalError() } }
}

public struct EmbeddingRequestHandler {
    public init(identifier: String, generateEmbeddings: @Sendable (GenerateEmbeddingsRequest, ModelManagerServices.InferenceProviderRequestConfiguration) async throws -> GenerateEmbeddingsResponse, getEmbeddingModelInformation: @Sendable (EmbeddingModelInformationRequest, ModelManagerServices.InferenceProviderRequestConfiguration) async throws -> EmbeddingModelInformationResponse) { fatalError() }
    public var identifier: String { get { fatalError() } }
    public func handleRequest(data: Data, configuration: ModelManagerServices.InferenceProviderRequestConfiguration) async throws -> Data { fatalError() }
}

public struct EmbeddingTask {
    public init(taskType: EmbeddingTaskType, content: EmbeddingContent) { fatalError() }
    public var content: EmbeddingContent { get { fatalError() } set { fatalError() } }
    public var taskType: EmbeddingTaskType { get { fatalError() } set { fatalError() } }
}

public struct EmbeddingTaskType {
    public struct Document {
        public init(title: String) { fatalError() }
        public var title: String { get { fatalError() } set { fatalError() } }
    }
    public struct Query {
        public init() { fatalError() }
    }
}

public protocol EmbeddingTokenKeys {
}

public struct EmbeddingTokenizationConfiguration {
    public init(embeddingStartTokens: Array<Int>, embeddingEndTokens: Array<Int>) { fatalError() }
    public var embeddingEndTokens: Array<Int> { get { fatalError() } }
    public var embeddingStartTokens: Array<Int> { get { fatalError() } }
}

public protocol EnablementCriteriaProtocol {
    var language: Locale.LanguageCode { get }
}

public struct Expression {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var choices: Array<Choice> { get { fatalError() } set { fatalError() } }
}

public struct ExternalParterCredentialStorageError {
    public var errorDescription: Optional<String> { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct ExternalPartnerCredentialStorageXPCClient {
    public init() { fatalError() }
    public func writeData(accessGroup: GenerativeModelsAccessGroup, securityLevel: GenerativeModelsSecurityLevel, key: String, auditID: Optional<UInt32>, data: Data) throws -> () { fatalError() }
    public func deleteData(accessGroup: GenerativeModelsAccessGroup, key: String, auditID: Optional<UInt32>) throws -> () { fatalError() }
}

public struct ExternalPartnerCredentialStorageXPCService {
}

public struct FailureTracking {
    public struct Failure {
        public struct Severity {
            public func hash(into: inout Hasher) -> () { fatalError() }
            public var hashValue: Int { get { fatalError() } }
        }
        public init(useCaseIdentifier: UseCaseIdentifier, onBehalfOfUserIdentifier: UInt32, severity: GenerativeModelsFailureTracking.Failure.Severity) { fatalError() }
        public init(useCaseIdentifier: UseCaseIdentifier, userRequestIdentifier: UUID, onBehalfOfUserIdentifier: UInt32, severity: GenerativeModelsFailureTracking.Failure.Severity) { fatalError() }
        public init(useCaseIdentifier: UseCaseIdentifier) { fatalError() }
        public init(useCaseIdentifier: UseCaseIdentifier, onBehalfOfUserIdentifier: UInt32) { fatalError() }
        public var severity: GenerativeModelsFailureTracking.Failure.Severity { get { fatalError() } }
        public var useCaseIdentifier: UseCaseIdentifier { get { fatalError() } }
        public var userIdentifier: UInt32 { get { fatalError() } }
        public var userRequestIdentifier: UUID { get { fatalError() } }
    }
    public struct FailureRecord {
        public init(from: Decoder) throws { fatalError() }
        public var userRequestIdentifier: Optional<UUID> { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var useCaseIdentifier: String { get { fatalError() } }
    }
    public struct SecureStorage {
        public init(user: UInt32) { fatalError() }
        public func failuresWithCalculatedDate() -> Array<GenerativeModelsFailureTracking.FailureRecord<Date>> { fatalError() }
    }
}

public class FailureTrackingClientProvider {
    public init(catalogClient: CatalogClient) { fatalError() }
    public func record(failure: GenerativeModelsFailureTracking.Failure) async throws -> () { fatalError() }
}

public protocol FailureTrackingClientProviding {
    func record(failure: GenerativeModelsFailureTracking.Failure) async throws -> ()
}

public struct FetchModelMetadataRequest {
}

public struct FetchModelMetadataResponse {
    public init(from: Decoder) throws { fatalError() }
    public init(contextSize: Int) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var contextSize: Int { get { fatalError() } set { fatalError() } }
}

public struct FetchTokenizerMetadataRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct FetchTokenizerMetadataResponse {
    public init(from: Decoder) throws { fatalError() }
    public init(imageTokenizationRecommendations: Optional<ImageTokenizationRecommendations>) { fatalError() }
    public var imageTokenizationRecommendations: Optional<ImageTokenizationRecommendations> { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct FileGenerationParameters18446744073709550616 {
}

public struct FinishReason {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct FinishReason18446744073709550616 {
}

public struct ForcedAvailability {
    public struct Key {
        public init(useCaseID: String, language: String) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public var stringValue: String { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public static func ==(_: ForcedAvailability.Key, _: ForcedAvailability.Key) -> Bool { fatalError() }
        public var language: String { get { fatalError() } set { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var useCaseID: String { get { fatalError() } set { fatalError() } }
    }
    public struct Reason {
        public init(rawValue: String) { fatalError() }
        public init(restrictedReason: GenerativeModelsAvailability.Availability.RestrictedInfo.RestrictedReason) { fatalError() }
        public init(unavailableReason: GenerativeModelsAvailability.Availability.UnavailableInfo.UnavailableReason) { fatalError() }
        public static var allCases: Array<ForcedAvailability.Reason> { get { fatalError() } }
        public func toRestrictedReason() -> Optional<GenerativeModelsAvailability.Availability.RestrictedInfo.RestrictedReason> { fatalError() }
        public func toUnavailableReason() -> Optional<GenerativeModelsAvailability.Availability.UnavailableInfo.UnavailableReason> { fatalError() }
        public var rawValue: String { get { fatalError() } }
    }
    public struct State {
        public init(rawValue: String) { fatalError() }
        public static var allCases: Array<ForcedAvailability.State> { get { fatalError() } }
        public var rawValue: String { get { fatalError() } }
    }
    public init(state: ForcedAvailability.State, reasons: Array<ForcedAvailability.Reason>, policies: Array<GenerativeModelsAvailability.Policy.PolicyOption>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var policies: Array<GenerativeModelsAvailability.Policy.PolicyOption> { get { fatalError() } set { fatalError() } }
    public var state: ForcedAvailability.State { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var reasons: Array<ForcedAvailability.Reason> { get { fatalError() } set { fatalError() } }
}

public struct FoundationModelsCompatibilityVersionsInfo {
    public struct Version {
        public init(baseModelBundleID: String, compatibilityVersion: String) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public static func ==(_: FoundationModelsCompatibilityVersionsInfo.Version, _: FoundationModelsCompatibilityVersionsInfo.Version) -> Bool { fatalError() }
        public var baseModelBundleID: String { get { fatalError() } }
        public var compatibilityVersion: String { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public init(from: Decoder) throws { fatalError() }
    public init(info: Array<FoundationModelsCompatibilityVersionsInfo.Version>) { fatalError() }
    public static func ==(_: FoundationModelsCompatibilityVersionsInfo, _: FoundationModelsCompatibilityVersionsInfo) -> Bool { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var info: Array<FoundationModelsCompatibilityVersionsInfo.Version> { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public static var none: FoundationModelsCompatibilityVersionsInfo { get { fatalError() } }
}

public class FoundationModelsExtensionInfo {
    public init(xpcObject: XPC.XPCCodableObject) { fatalError() }
    public init(fileURL: URL) throws { fatalError() }
    public var adapterWeights: Int32 { get { fatalError() } }
    public var draftMIL: Optional<Int32> { get { fatalError() } }
    public func toXPCObject() -> XPC.XPCCodableObject { fatalError() }
    public var draftWeights: Optional<Int32> { get { fatalError() } }
}

public struct FunctionDescription {
    public init(name: String, usageDescription: String, argumentsSchema: GenerativeFunctionsSchema) { fatalError() }
    public var argumentsSchema: GenerativeFunctionsSchema { get { fatalError() } set { fatalError() } }
    public var name: String { get { fatalError() } set { fatalError() } }
    public var usageDescription: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct GenerateEmbeddingsRequest {
    public var parameters: EmbeddingGenerationParameters { get { fatalError() } set { fatalError() } }
    public var tasks: Array<EmbeddingTask> { get { fatalError() } set { fatalError() } }
}

public struct GenerateEmbeddingsResponse {
    public init(response: EmbeddingGeneration) { fatalError() }
    public var response: EmbeddingGeneration { get { fatalError() } set { fatalError() } }
}

public struct GenerationError {
    public struct Code {
        public init(rawValue: Int) { fatalError() }
        public var rawValue: Int { get { fatalError() } }
    }
    public var errorDescription: Optional<String> { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var category: AppleIntelligenceReporting.AppleIntelligenceErrorCategory { get { fatalError() } }
    public var code: GenerationError.Code { get { fatalError() } }
    public var descriptionWithoutUnderlying: String { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var rawCode: Int { get { fatalError() } }
    public var underlyingErrors: Array<AppleIntelligenceReporting.AppleIntelligenceError> { get { fatalError() } }
}

public struct GenerationOverrides {
    public init() { fatalError() }
    public var beginningPromptToken: Optional<Int> { get { fatalError() } }
    public var useLegacyDetokenizationBuffering: Optional<Bool> { get { fatalError() } }
    public var usePortableLocaleMatching: Optional<Bool> { get { fatalError() } }
}

public struct GenerationSchema18446744073709550616 {
}

public protocol GenerativeConfigurationProtocol {
    init(overridableConfigurationStorage: OverridableConfigurationStorage, runnableConfigurationStorage: RunnableConfigurationStorage)
    var _overridableConfigurationStorage: OverridableConfigurationStorage { get set }
    var _runnableConfigurationStorage: RunnableConfigurationStorage { get set }
}

public struct GenerativeExperiencesSafetyClientRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct GenerativeExperiencesSafetyClientResponse {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct GenerativeModelConfiguration {
    public init(modelConfigurationData: Data) throws { fatalError() }
    public init(modelBundleIdentifier: ResourceBundleIdentifier<AssetBackedLLMBundle>, catalogClient: CatalogClient) throws { fatalError() }
    public init(modelBundleIdentifier: ResourceBundleIdentifier<LLMBundle>, catalogClient: CatalogClient) throws { fatalError() }
    public func tools(for: String) -> Optional<Array<ToolDescription>> { fatalError() }
    public func promptTemplates() -> Optional<Dictionary<String, ModelConfigurationPromptTemplate>> { fatalError() }
    public func samplingParameters(for: String) -> Optional<SamplingParameters> { fatalError() }
    public var loadedConfiguration: Optional<_LoadedUseCaseConfigurations<_UseCaseConfiguration>> { get { fatalError() } }
    public func promptTemplate(for: String) -> Optional<ModelConfigurationPromptTemplate> { fatalError() }
}

public struct GenerativeModelSessionConfiguration {
    public init(identifier: String, handlesSensitiveData: Bool, cachePolicy: CachePolicy) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(identifier: String, locale: Optional<Locale>, handlesSensitiveData: Bool, cachePolicy: CachePolicy) { fatalError() }
    public var handlesSensitiveData: Bool { get { fatalError() } set { fatalError() } }
    public var identifier: String { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var cachePolicy: CachePolicy { get { fatalError() } set { fatalError() } }
    public var locale: Optional<Locale> { get { fatalError() } set { fatalError() } }
}

public protocol GenerativeModelSessionTokenGenerator {
    var model: TokenGenerator { get }
}

public struct GenerativeModelsLogging {
}

public protocol GrammarRecognizer {
    func nextValidTerminalsWithCacheKey() -> (cacheKey: Optional<Int>, nextValidTerminals: Array<TerminalSymbol>)
    var fullMatch: Bool { get }
    func createValidatorCache() -> A.RecognizerCache
    func nextValidTerminals() -> Array<TerminalSymbol>
    func childRecognizer(consumingElement: RecognizerElement) -> Optional
    func childRecognizer(consumingString: String) -> Optional
    var lastConsumedElement: Optional<RecognizerElement> { get }
    var specialTokenIDSet: Set<Int> { get }
    func validate(validatorCache: inout A.RecognizerCache, string: String, skipFirst: Int) -> Bool
    var characterSetsUsedInGrammar: Array<CharacterSet> { get }
    func nextTerminalsPotentiallyDeterministic() -> Bool
}

public struct GuidedGenerationConstraint {
}

public struct GuidedGenerationConstraints {
    public init(schema: GenerativeFunctionsSchema, enableDeterministicTokenRuns: Bool, vocabularyManager: GuidedGenerationVocabularyManager, numberOfParallelTasks: Int) throws { fatalError() }
    public init(grammarString: String, tokenizerPath: String, stopTokenIDs: Array<Int>, numParallelTasks: Optional<Int>) async throws { fatalError() }
    public init(grammar: Grammar, vocabularyManager: GuidedGenerationVocabularyManager, enableDeterministicTokenRuns: Bool, numberOfParallelTasks: Int, suppressionConstraints: Optional<SuppressionConstraints>) { fatalError() }
    public init(grammar: Grammar, vocabularyManager: GuidedGenerationVocabularyManager, enableDeterministicTokenRuns: Bool, numberOfParallelTasks: Int) { fatalError() }
    public init(schema: GenerativeFunctionsSchema, vocabularyManager: GuidedGenerationVocabularyManager, enableDeterministicTokenRuns: Bool, numberOfParallelTasks: Int) { fatalError() }
    public init(grammar: Grammar, vocabularyManager: GuidedGenerationVocabularyManager, enableDeterministicTokenRuns: Bool, numberOfParallelTasks: Int, suppressionConstraints: SuppressionConstraints) { fatalError() }
    public init(schemaString: String, tokenizerPath: String, stopTokenIDs: Array<Int>, numParallelTasks: Optional<Int>) async throws { fatalError() }
    public func possiblyDeterministicTokens(follow: Array<Int>) throws -> Bool { fatalError() }
    public func generateNextTokenIDMask(from: Array<Int>, with: RollbackState) throws -> TokenIDMaskResponse { fatalError() }
    public var vocabularyCount: Int { get { fatalError() } }
    public func startDecodingLoop() -> DecodingLoop { fatalError() }
    public func generateNextTokenIDMaskExhaustively(from: Array<Int>) async throws -> TokenIDMaskResponse { fatalError() }
    public func validate(tokenIDs: Array<Int>) throws -> MatchResult { fatalError() }
    public func generateNextTokenIDMask(atConstraintState: Int) async throws -> TokenIDMaskResponse { fatalError() }
    public func advanceConstraintState(_: Int, consumingToken: Int) -> Int { fatalError() }
    public func generateNextTokenIDMask(from: Array<Int>) async throws -> TokenIDMaskResponse { fatalError() }
    public func nextTokenIDMaskComputation(following: Array<Int>) async throws -> TokenIDMaskComputation { fatalError() }
    public func possiblyDeterministicTokens(atConstraintState: Int) throws -> Bool { fatalError() }
    public func generateNextTokenIDMask(from: Array<Int>) throws -> TokenIDMaskResponse { fatalError() }
    public func validateTokens(from: Array<Int>, candidateTokenIDs: Array<Int>) async throws -> Optional<Int> { fatalError() }
    public func updateRollbackState(_: inout RollbackState, for: Array<Int>) throws -> RollbackStatus { fatalError() }
}

public struct GuidedGenerationError {
}

public struct GuidedGenerationRequestParameters {
    public init(constraint: Optional<GuidedGenerationConstraint>, toolChoice: GenerativeFunctionsToolChoice, thoughtBudget: ThoughtBudget, tools: Array<GenerativeFunctionsToolDefinition>) { fatalError() }
    public init(wireFormatBytes: Data) throws { fatalError() }
    public var constraint: Optional<GuidedGenerationConstraint> { get { fatalError() } }
    public var thoughtBudget: ThoughtBudget { get { fatalError() } }
    public var toolChoice: GenerativeFunctionsToolChoice { get { fatalError() } }
    public var tools: Array<GenerativeFunctionsToolDefinition> { get { fatalError() } }
    public var wireFormatBytes: Data { get { fatalError() } }
}

public protocol GuidedGenerationTokenizer {
    func text(forTokenID: Int) -> String
    var vocabularyCount: Int { get }
    func tokenize(_: String) throws -> Array<Int>
    func detokenize(_: Array<Int>) throws -> String
    func vocabulary() -> Array<String>
    func tokenID(forText: String) -> Int
    var longestTokenLength: Int { get }
    func isByte(tokenID: Int) -> Bool
}

public struct GuidedGenerationVocabularyManager {
    public init(tokenizer: GuidedGenerationTokenizer, stopTokenIDs: Array<Int>) { fatalError() }
    public init(tokenizer: GuidedGenerationTokenizer, stopTokenIDs: Array<Int>, cachedPrefixLookup: VocabularyManager.PrefixLookup) { fatalError() }
    public init(tokenizer: GuidedGenerationTokenizer, stopTokenIDs: Array<Int>, characterSetsUsedInGrammar: Array<CharacterSet>) { fatalError() }
    public var prefixLookUp: VocabularyManager.PrefixLookup { get { fatalError() } }
    public var stopTokenIDs: Array<Int> { get { fatalError() } }
    public func initVocabManager() -> () { fatalError() }
}

public struct ImageEmbeddingKeys {
}

public struct ImageGenerationParameters18446744073709550616 {
}

public struct ImageTokenizationRecommendations {
    public struct DimensionRequirements {
        public struct ExactSizeRequirement {
            public init(pixelWidth: UInt, pixelHeight: UInt) { fatalError() }
            public init(from: Decoder) throws { fatalError() }
            public var pixelHeight: UInt { get { fatalError() } set { fatalError() } }
            public func encode(to: Encoder) throws -> () { fatalError() }
            public var pixelWidth: UInt { get { fatalError() } set { fatalError() } }
        }
        public struct ExactSizeRequirement18446744073709550616 {
        }
        public struct MaxDimensionRequirement {
            public init(from: Decoder) throws { fatalError() }
            public init(dimension: UInt) { fatalError() }
            public var dimension: UInt { get { fatalError() } set { fatalError() } }
            public func encode(to: Encoder) throws -> () { fatalError() }
        }
        public struct MaxDimensionRequirement18446744073709550616 {
        }
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct DimensionRequirements18446744073709550616 {
    }
    public init(from: Decoder) throws { fatalError() }
    public init(dimensions: ImageTokenizationRecommendations.DimensionRequirements, pixelFormat: UInt32) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var dimensions: ImageTokenizationRecommendations.DimensionRequirements { get { fatalError() } set { fatalError() } }
    public var pixelFormat: UInt32 { get { fatalError() } set { fatalError() } }
}

public struct ImageTokenizationRecommendations18446744073709550616 {
}

public struct InferenceOutputDelta {
    public struct TextDelta {
        public init(text: String) { fatalError() }
        public var text: String { get { fatalError() } set { fatalError() } }
    }
    public struct ThoughtContentDelta {
        public init(thoughtID: String, content: String) { fatalError() }
        public var content: String { get { fatalError() } set { fatalError() } }
        public var thoughtID: String { get { fatalError() } set { fatalError() } }
    }
    public struct UserAudioTranscriptionDelta {
        public var transcribedTextDelta: String { get { fatalError() } }
        public var transcriptionId: String { get { fatalError() } }
    }
    public init(wireFormatData: Data) throws { fatalError() }
    public func toWireFormat(candidateIdentifier: String) throws -> Data { fatalError() }
}

public struct InferenceOutputDeltaWireFormatError {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct InferenceRequestHandler {
    public func handleStreamingRequest(data: Data, configuration: ModelManagerServices.InferenceProviderRequestConfiguration) -> AsyncSequence { fatalError() }
    public var identifier: String { get { fatalError() } }
    public func handleRequest(data: Data, configuration: ModelManagerServices.InferenceProviderRequestConfiguration) async throws -> Data { fatalError() }
    public func handleRequest(clientData: ModelManagerServices.ClientData, configuration: ModelManagerServices.InferenceProviderRequestConfiguration) async throws -> Data { fatalError() }
    public func handleStreamingRequest(clientData: ModelManagerServices.ClientData, configuration: ModelManagerServices.InferenceProviderRequestConfiguration) -> AsyncSequence { fatalError() }
}

public struct InferenceResponseCandidateAnnotationEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, annotation: InferenceResponse.Annotation) { fatalError() }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var annotation: InferenceResponse.Annotation { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateAudioEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, audio: InferenceResponse.AudioContent) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var audio: InferenceResponse.AudioContent { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateFileEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, file: InferenceResponse.FileContent) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var file: InferenceResponse.FileContent { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateFinishEvent {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var finishReason: InferenceResponse.FinishReason { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var meanTokenEntropy: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateImageEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, image: InferenceResponse.ImageContent) { fatalError() }
    public var image: InferenceResponse.ImageContent { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateModerationEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, moderation: InferenceResponse.Moderation) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var moderation: InferenceResponse.Moderation { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateOutputTokenIDsEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, outputTokenIDs: Array<Int>) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var outputTokenIDs: Array<Int> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct InferenceResponseCandidateTextDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, textDelta: String) { fatalError() }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var _userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var textDelta: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateThoughtContentDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, thoughtContentIdentifier: String, update: Thoughts) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, thoughtContentIdentifier: String, thoughtContentDelta: String) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var thoughtContentIdentifier: String { get { fatalError() } set { fatalError() } }
    public var update: Thoughts { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var thoughtContentDelta: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateToolCallDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, toolCallIdentifier: String, functionName: String, argumentsDelta: String) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var _userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var argumentsDelta: String { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var functionName: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var toolCallIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateToolResultEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, result: Prompt.ToolResult) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var result: Prompt.ToolResult { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseCandidateUserAudioTranscriptionDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, userAudioTranscriptionIdentifier: String, userAudioTranscriptionDelta: String) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var userAudioTranscriptionDelta: String { get { fatalError() } set { fatalError() } }
    public var userAudioTranscriptionIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseEvent {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct InferenceResponseMetadataEvent {
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct InferenceResponseModelInformationEvent {
    public init(responseIdentifier: String, modelInformation: InferenceResponse.ModelInformation) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var modelInformation: InferenceResponse.ModelInformation { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponsePromptModerationEvent {
    public init(responseIdentifier: String, moderation: InferenceResponse.Moderation) { fatalError() }
    public var moderation: InferenceResponse.Moderation { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct InferenceResponseRenderedPromptEvent {
    public init(responseIdentifier: String, renderedPrompt: InferenceResponse.PromptRendering) { fatalError() }
    public var renderedPrompt: InferenceResponse.PromptRendering { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct InferenceResponseStream {
    public struct Iterator {
        public func next() async throws -> Optional<InferenceResponseEvent> { fatalError() }
    }
    public func makeAsyncIterator() -> InferenceResponseStream.Iterator { fatalError() }
}

public struct InferenceResponseUsageEvent {
    public init(responseIdentifier: String, usage: InferenceResponse.Usage) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var usage: InferenceResponse.Usage { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public protocol InferenceSessionProtocol {
    func request(loggingIdentifier: String, data: Data, xpcData: XPC.XPCCodableObject, requiredAssets: Set<ModelCatalogStub.AssetKey>) async throws -> Data
    func streamingRequest(loggingIdentifier: String, data: Data, xpcData: XPC.XPCCodableObject, requiredAssets: Set<ModelCatalogStub.AssetKey>) -> any AsyncSequence
    func requestPrewarm() throws -> ()
    func requestPrewarm(metadata: Dictionary<String, String>) throws -> ()
    func sendInputStreamUpdate(data: Data) async throws -> ()
    func cancel() -> ()
}

public struct InputDenyListBundle {
    public init(from: Decoder) throws { fatalError() }
    public static func ==(_: InputDenyListBundle, _: InputDenyListBundle) -> Bool { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var identifier: String { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct IntegerGuides {
    public init(minimum: Optional<Int>, maximum: Optional<Int>) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct InternalVariantArguments {
}

public struct InvalidGrammar {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var description: String { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
}

public struct JSON {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct JSONSchema18446744073709550616 {
}

public struct KeychainStore {
    public init(auditID: Optional<UInt32>) { fatalError() }
    public func writeData(accessGroup: GenerativeModelsAccessGroup, key: String, securityLevel: GenerativeModelsSecurityLevel, data: Data) throws -> () { fatalError() }
    public func deleteData(accessGroup: GenerativeModelsAccessGroup, key: String) throws -> () { fatalError() }
}

public struct KnownError {
    public init(generativeError: GenerativeFunctionsGenerativeError) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var generativeError: GenerativeFunctionsGenerativeError { get { fatalError() } }
}

public struct LLMModelBundle {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct LanguageRecognizer {
    public init(from: Decoder) throws { fatalError() }
    public init(supportedLanguageCodes: Set<Locale.LanguageCode>, preferredLanguages: Array<Locale.Language>, topK: Int, tokenThreshold: Int, includeEmojis: Bool, samples: Int, checkOVSIfUnderTokenThreshold: Bool) { fatalError() }
    public init(supportedLanguageCodes: Set<Locale.LanguageCode>, topK: Int, tokenThreshold: Int, includeEmojis: Bool, samples: Int, checkOVSIfUnderTokenThreshold: Bool) { fatalError() }
    public init(supportedLanguages: Set<Locale.Language>, preferredLanguages: Array<Locale.Language>, topK: Int, tokenThreshold: Int, includeEmojis: Bool, samples: Int, checkOVSIfUnderTokenThreshold: Bool) { fatalError() }
    public var checkOVSIfUnderTokenThreshold: Bool { get { fatalError() } }
    public var eventReporter: GenerativeFunctionsInstrumentation.EventReporter { get { fatalError() } }
    public func validate(_: String) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var preferredLanguages: Array<Locale.Language> { get { fatalError() } }
    public var supportedLanguages: Set<Locale.Language> { get { fatalError() } }
    public var tokenThreshold: Int { get { fatalError() } }
    public var topK: Int { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var includeEmojis: Bool { get { fatalError() } }
    public var samples: Int { get { fatalError() } }
    public func validateAndReturnDominantLanguage(_: String) throws -> Optional<Locale.Language> { fatalError() }
    public static func ==(_: LanguageRecognizer, _: LanguageRecognizer) -> Bool { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func validateAndDetectDominantLanguage(_: String) throws -> Optional<Locale.LanguageCode> { fatalError() }
}

public class LanguageRecognizerCachableModel {
    public init(modelConfiguration: LanguageRecognizerModelConfiguration) throws { fatalError() }
    public func prewarm() throws -> () { fatalError() }
    public var modelConfiguration: LanguageRecognizerModelConfiguration { get { fatalError() } }
    public static func privacyApprovedLoggableName() -> StaticString { fatalError() }
}

public struct LanguageRecognizerModelConfiguration {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public static func ==(_: LanguageRecognizerModelConfiguration, _: LanguageRecognizerModelConfiguration) -> Bool { fatalError() }
}

public struct LanguageRecognizerRunner {
    public init() { fatalError() }
    public static func validate(_: String, languageRecognizer: LanguageRecognizer) throws -> () { fatalError() }
}

public protocol LanguageRecognizerRunnerProtocol {
}

public struct LanguageScriptValidator {
    public init(from: Decoder) throws { fatalError() }
    public init(locales: Array<Locale>, isEmojiAllowed: Bool) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var isEmojiAllowed: Bool { get { fatalError() } }
    public static func ==(_: LanguageScriptValidator, _: LanguageScriptValidator) -> Bool { fatalError() }
    public var eventReporter: Optional<GenerativeFunctionsInstrumentation.EventReporter> { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func validate(_: String) throws -> () { fatalError() }
    public var locales: Array<Locale> { get { fatalError() } }
}

public struct LanguageScriptValidatorRunner {
    public init() { fatalError() }
    public static func validate(_: String, languageScriptValidator: LanguageScriptValidator) throws -> () { fatalError() }
}

public protocol LanguageScriptValidatorRunnerProtocol {
}

public struct ListModelsRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ListModelsResponse {
    public init(modelIdentifiers: Array<String>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var modelIdentifiers: Array<String> { get { fatalError() } set { fatalError() } }
}

public struct Lock {
    public init(initialState: A) { fatalError() }
    public func withLock<GenericA>(_: (inout GenericA) -> GenericA) -> GenericA { fatalError() }
}

public struct Log {
}

public struct Logging {
}

public struct LogitMaskComputation {
}

public struct LogitMaskResponse {
}

public protocol MaskProviding {
    func possiblyDeterministicTokens(atConstraintState: Int) throws -> Bool
    func advanceConstraintState(_: Int, consumingToken: Int) -> Int
    func generateNextTokenIDMask(atConstraintState: Int) async throws -> TokenIDMaskResponse
    var vocabularyCount: Int { get }
}

public struct MatchResult {
}

public class Measurement {
    public func stopMeasurement() -> () { fatalError() }
    public func getMeasuredTime() -> Double { fatalError() }
    public func getMeasuredTimeMetric() -> GenerativeModelsMetricData { fatalError() }
    public func startMeasurement() -> () { fatalError() }
    public var metricProvider: GenerativeModelsMetricProvider { get { fatalError() } }
    public var name: String { get { fatalError() } }
}

public protocol Mergeable {
}

public struct MetadataValue {
    public init(from: Decoder) throws { fatalError() }
    public var stringValue: Optional<String> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var jsonData: Optional<Data> { get { fatalError() } }
}

public class MetricAggregator {
    public init() { fatalError() }
    public init(list: Array<GenerativeModelsMetricProvider>) { fatalError() }
    public func runFilters() -> Array<GenerativeModelsMetricData> { fatalError() }
    public func stopCollection() -> () { fatalError() }
    public func setup() -> () { fatalError() }
    public func startCollection(readBackTime: Int) -> () { fatalError() }
}

public struct MetricData {
    public init(unit: GenerativeModelsPDUnit, key: String, value: Any) { fatalError() }
}

public protocol MetricProvider {
    func startCollection(readBackTime: Int) -> ()
    func runFilters() -> Array<GenerativeModelsMetricData>
    func setup() -> ()
    func stopCollection() -> ()
}

public struct Modality {
    public init(from: Decoder) throws { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var type: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct ModelBundle {
    public init(resourceBundleQuery: ResourceBundleQuery) { fatalError() }
    public init(fileURL: URL) throws { fatalError() }
    public init(preverifiedIdentifier: String) { fatalError() }
    public init(identifier: String) { fatalError() }
    public func modelBundleIdentifier(instrumenter: Optional<GenerativeFunctionsInstrumentation.GenerativeFunctionInstrumenter>, catalogClient: CatalogClient) throws -> GenerativeModelsModelBundleIdentifier { fatalError() }
    public var identifier: String { get { fatalError() } }
    public var isFileBased: Bool { get { fatalError() } }
    public var resourceURI: URL { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct ModelBundle18446744073709550616 {
}

public struct ModelBundleIdentifier {
    public init(from: Decoder) throws { fatalError() }
    public var identifier: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ModelBundleInfoForSanitizer {
    public init(from: Decoder) throws { fatalError() }
    public init(resourceURI: URL) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var resourceURI: Optional<URL> { get { fatalError() } }
}

public class ModelCache {
    public protocol CachableModel {
        init(modelConfiguration: A.ModelConfiguration) throws
        func prewarm() throws -> ()
        var modelConfiguration: A.ModelConfiguration { get }
    }
    public func reset() -> () { fatalError() }
}

public protocol ModelCatalogClient {
    func loadPromptTemplate(resourceURI: URL, templateID: String) throws -> Optional<String>
}

public struct ModelConfiguration {
    public struct PrompteTemplateError {
        public init(rawValue: String) { fatalError() }
        public var rawValue: String { get { fatalError() } }
    }
    public init(modelbundleIdentifier: ResourceBundleIdentifier<LLMBundle>, catalogClient: CatalogClient) throws { fatalError() }
    public init(loadedModelConfiguration: Optional<_LoadedModelConfiguration>) { fatalError() }
    public init(modelConfigurationData: Data) throws { fatalError() }
    public init(modelbundleIdentifier: ResourceBundleIdentifier<AssetBackedLLMBundle>, catalogClient: CatalogClient) throws { fatalError() }
    public var promptTemplates: Optional<Dictionary<String, ModelConfigurationPromptTemplate>> { get { fatalError() } }
    public func makeUpdatedConfigurationWithNewPromptTemplates(newPromptTemplates: Optional<Dictionary<String, ModelConfigurationPromptTemplate>>) -> Optional<ModelConfiguration> { fatalError() }
    public var speculativeDecodingDraftTokenCount: Optional<Int> { get { fatalError() } }
    public func promptTemplate(for: String) -> Optional<ModelConfigurationPromptTemplate> { fatalError() }
    public func render(promptTemplate: PromptTemplateInfo) async throws -> PromptRequest { fatalError() }
}

public struct ModelConfigurationPromptTemplate {
    public init(rawTemplateString: String) { fatalError() }
    public var rawTemplateString: String { get { fatalError() } }
}

public protocol ModelConfigurationProtocol {
    func promptTemplate(for: String) -> Optional<ModelConfigurationPromptTemplate>
}

public struct ModelInformation {
    public struct Asset {
        public var hashValue: Int { get { fatalError() } }
        public var identifier: String { get { fatalError() } set { fatalError() } }
        public var version: Optional<String> { get { fatalError() } set { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct Asset18446744073709550616 {
    }
    public init(assets: Array<ModelInformation.Asset>, systemVersion: Optional<String>) { fatalError() }
    public init(identifier: String, version: String, systemVersion: Optional<String>) { fatalError() }
    public var identifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var assets: Array<ModelInformation.Asset> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var systemVersion: Optional<String> { get { fatalError() } set { fatalError() } }
    public var version: String { get { fatalError() } set { fatalError() } }
}

public struct ModelInformation18446744073709550616 {
}

public class ModelManagerSessionWrapper {
    public init(from: Decoder) throws { fatalError() }
    public init(session: Optional<ModelManagerServices.Session>) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var session: OSAllocatedUnfairLock<Optional<ModelManagerServices.Session>> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct NonTerminalSymbol {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var description: String { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: String { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct Npy {
    public struct Header {
        public struct DataType {
            public struct DType {
                public init(rawValue: String) { fatalError() }
                public var rawValue: String { get { fatalError() } }
            }
            public struct Endianness {
                public init(rawValue: String) { fatalError() }
                public var rawValue: String { get { fatalError() } }
            }
            public init(endianness: Npy.Header.DataType.Endianness, dataType: Npy.Header.DataType.DType) { fatalError() }
            public var dataType: Npy.Header.DataType.DType { get { fatalError() } }
            public var description: String { get { fatalError() } }
            public var endianness: Npy.Header.DataType.Endianness { get { fatalError() } }
        }
        public init(dType: Npy.Header.DataType, isFortranOrder: Bool, shape: Array<Int>) { fatalError() }
        public init(from: Data) throws { fatalError() }
        public var dType: Npy.Header.DataType { get { fatalError() } }
        public var isFortranOrder: Bool { get { fatalError() } }
        public var shape: Array<Int> { get { fatalError() } }
    }
    public init(header: Npy.Header, data: Data) { fatalError() }
    public init(from: Data) throws { fatalError() }
    public var data: Data { get { fatalError() } }
    public var header: Npy.Header { get { fatalError() } }
}

public struct OneShotRequest {
}

public struct OpenAIAnyCodable {
    public init(from: Decoder) throws { fatalError() }
    public init(_: Any) { fatalError() }
    public var value: Any { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct OpenAICompletionRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var frequencyPenalty: Optional<Double> { get { fatalError() } }
    public var maxCompletionTokens: Optional<Int> { get { fatalError() } }
    public var maxTokens: Optional<Int> { get { fatalError() } }
    public var messages: Array<OpenAIMessage> { get { fatalError() } }
    public var reasoningEffort: Optional<String> { get { fatalError() } }
    public var seed: Optional<Int> { get { fatalError() } }
    public var stop: Optional<Array<String>> { get { fatalError() } }
    public var temperature: Optional<Double> { get { fatalError() } }
    public var thoughtBudget: Optional<ThoughtBudget> { get { fatalError() } }
    public var tools: Optional<Array<OpenAITool>> { get { fatalError() } }
    public var topP: Optional<Double> { get { fatalError() } }
}

public struct OpenAIContentItem {
    public init(from: Decoder) throws { fatalError() }
    public init(type: String, text: Optional<String>, imageUrl: Optional<OpenAIImageURL>) { fatalError() }
    public var imageUrl: Optional<OpenAIImageURL> { get { fatalError() } }
    public var text: Optional<String> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var type: String { get { fatalError() } }
}

public struct OpenAIConversionError {
    public var errorDescription: Optional<String> { get { fatalError() } }
}

public struct OpenAIFunction {
    public init(from: Decoder) throws { fatalError() }
    public init(name: String, arguments: String) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var arguments: String { get { fatalError() } }
    public var name: String { get { fatalError() } }
}

public struct OpenAIImageURL {
    public init(from: Decoder) throws { fatalError() }
    public init(url: String, detail: Optional<String>) { fatalError() }
    public var detail: Optional<String> { get { fatalError() } }
    public var url: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct OpenAIMessage {
    public init(role: String, content: Optional<OpenAIMessageContent>, toolCalls: Optional<Array<OpenAIToolCall>>, toolCallId: Optional<String>, name: Optional<String>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var name: Optional<String> { get { fatalError() } }
    public var role: String { get { fatalError() } }
    public var toolCalls: Optional<Array<OpenAIToolCall>> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var content: Optional<OpenAIMessageContent> { get { fatalError() } }
    public var toolCallId: Optional<String> { get { fatalError() } }
}

public struct OpenAIMessageContent {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct OpenAITool {
    public init(from: Decoder) throws { fatalError() }
    public init(type: String, function: OpenAIToolFunction) { fatalError() }
    public var function: OpenAIToolFunction { get { fatalError() } }
    public var type: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct OpenAIToolCall {
    public init(id: String, type: String, function: OpenAIFunction) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var id: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var function: OpenAIFunction { get { fatalError() } }
    public var type: String { get { fatalError() } }
}

public struct OpenAIToolFunction {
    public init(name: String, description: Optional<String>, parameters: Optional<Dictionary<String, OpenAIAnyCodable>>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var description: Optional<String> { get { fatalError() } }
    public var name: String { get { fatalError() } }
    public var parameters: Optional<Dictionary<String, OpenAIAnyCodable>> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct OptIn {
    public struct State {
        public init(rawValue: Int) { fatalError() }
        public var rawValue: Int { get { fatalError() } }
    }
    public init() { fatalError() }
    public var allData: Optional<Dictionary<String, Any>> { get { fatalError() } }
    public static var linwoodUpsell: OperatingSystemVersion { get { fatalError() } }
    public static var shared: OptIn { get { fatalError() } }
    public func reset() -> () { fatalError() }
    public var isAutoOptedIn: Bool { get { fatalError() } set { fatalError() } }
    public func getUserDefaults(for: String) -> Optional { fatalError() }
    public static var buddyBundleIdentifiers: Array<String> { get { fatalError() } }
    public var isOptedIn: Bool { get { fatalError() } set { fatalError() } }
    public var lastBuddyOptedChangeVersion: Optional<OperatingSystemVersion> { get { fatalError() } set { fatalError() } }
    public var optedInBuddy: Bool { get { fatalError() } set { fatalError() } }
    public var optedOutBuddy: Bool { get { fatalError() } set { fatalError() } }
    public var state: OptIn.State { get { fatalError() } }
    public var userDefaultsKey: String { get { fatalError() } }
}

public struct OutputDenyListBundle {
    public init(from: Decoder) throws { fatalError() }
    public var identifier: String { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public static func ==(_: OutputDenyListBundle, _: OutputDenyListBundle) -> Bool { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct Overridable {
    public var wrappedValue: Optional<A> { get { fatalError() } }
}

public struct OverridableConfigurationStorage {
    public init(configuration: Dictionary<GenerativeConfigurationKey, Decodable & Encodable>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var configuration: Dictionary<GenerativeConfigurationKey, Decodable & Encodable> { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var mapValue: Optional<(Decodable & Encodable) -> Decodable & Encodable> { get { fatalError() } set { fatalError() } }
}

public struct PDUnit {
    public init(rawValue: String) { fatalError() }
    public var rawValue: String { get { fatalError() } }
}

public class PerfdataWriter {
    public init(filePath: String) throws { fatalError() }
    public func addMetric(metric: GenerativeModelsMetricData, prefix: Optional<String>, moreVariables: Optional<Dictionary<String, Any>>) -> () { fatalError() }
    public func finalize() -> () { fatalError() }
}

public struct PrewarmUrgency {
}

public struct PromptCompletion {
    public struct Aggregator {
        public init() { fatalError() }
        public func finish() -> PromptCompletion { fatalError() }
        public func finish() -> PromptCompletion18446744073709550616 { fatalError() }
        public func receive(event: PromptCompletionEvent) -> () { fatalError() }
    }
    public struct Aggregator18446744073709550616 {
    }
    public struct Annotation {
        public struct `Type` {
            public func hash(into: inout Hasher) -> () { fatalError() }
            public var hashValue: Int { get { fatalError() } }
        }
        public struct Type18446744073709550616 {
        }
        public init(index: Int, type: PromptCompletion.Annotation.Type) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var index: Int { get { fatalError() } set { fatalError() } }
        public var type: PromptCompletion.Annotation.Type { get { fatalError() } set { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct Annotation18446744073709550616 {
    }
    public struct AudioContent {
        public init(data: Data, format: Optional<AudioFormat>) { fatalError() }
        public init(data: Data) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var data: Data { get { fatalError() } }
        public var format: Optional<AudioFormat> { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct AudioContent18446744073709550616 {
    }
    public struct Candidate {
        public init(segments: Array<PromptCompletion.Segment>, toolCalls: Array<Prompt.ToolCall>, finishReason: FinishReason) { fatalError() }
        public var thoughtContents: Array<PromptCompletion.ThoughtContent> { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var finishReason: FinishReason { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var moderation: Optional<PromptCompletion.Moderation> { get { fatalError() } set { fatalError() } }
        public var outputTokenIDs: Optional<Array<Int>> { get { fatalError() } set { fatalError() } }
        public var segments: Array<PromptCompletion.Segment> { get { fatalError() } set { fatalError() } }
        public var toolCalls: Array<Prompt.ToolCall> { get { fatalError() } }
        public var userAudioTranscriptions: Array<PromptCompletion.UserAudioTranscription> { get { fatalError() } }
    }
    public struct Candidate18446744073709550616 {
    }
    public struct Content {
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct Content18446744073709550616 {
    }
    public struct ContentAdvisory {
        public struct Category {
            public func hash(into: inout Hasher) -> () { fatalError() }
            public var hashValue: Int { get { fatalError() } }
        }
        public struct RegulatoryDomain {
            public var hashValue: Int { get { fatalError() } }
            public func hash(into: inout Hasher) -> () { fatalError() }
        }
        public init(category: PromptCompletion.ContentAdvisory.Category, text: Optional<String>) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var category: PromptCompletion.ContentAdvisory.Category { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var text: Optional<String> { get { fatalError() } set { fatalError() } }
    }
    public struct DocumentCitation {
        public init(documentIdentifier: GenerativeModelsDocumentResourceIdentifier) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var documentIdentifier: GenerativeModelsDocumentResourceIdentifier { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct DocumentCitation18446744073709550616 {
    }
    public struct FileContent {
        public init(url: URL, name: String, mimeType: String, size: Int64) { fatalError() }
        public var url: URL { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var mimeType: String { get { fatalError() } }
        public var name: String { get { fatalError() } }
        public var size: Int64 { get { fatalError() } }
    }
    public struct FileContent18446744073709550616 {
    }
    public struct ImageContent {
        public init(data: Data) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var data: Data { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public func imageData() async throws -> Data18446744073709550616 { fatalError() }
        public func imageData() async throws -> Data { fatalError() }
    }
    public struct ImageContent18446744073709550616 {
    }
    public struct Moderation {
        public struct Category {
            public init(identifier: String) { fatalError() }
            public var identifier: String { get { fatalError() } }
            public func hash(into: inout Hasher) -> () { fatalError() }
            public var hashValue: Int { get { fatalError() } }
        }
        public struct Category18446744073709550616 {
        }
        public struct Probability {
            public func hash(into: inout Hasher) -> () { fatalError() }
            public var hashValue: Int { get { fatalError() } }
        }
        public struct Probability18446744073709550616 {
        }
        public init(ratings: Dictionary<PromptCompletion.Moderation.Category, PromptCompletion.Moderation.Probability>) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var ratings: Dictionary<PromptCompletion.Moderation.Category, PromptCompletion.Moderation.Probability> { get { fatalError() } set { fatalError() } }
    }
    public struct Moderation18446744073709550616 {
    }
    public struct Segment {
        public init(content: PromptCompletion.Content) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var content: PromptCompletion.Content { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct Segment18446744073709550616 {
    }
    public struct TextContent {
        public init(value: String, annotations: Array<PromptCompletion.Annotation>) { fatalError() }
        public init(value: String) { fatalError() }
        public var _userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
        public var annotations: Array<PromptCompletion.Annotation> { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var value: String { get { fatalError() } set { fatalError() } }
    }
    public struct TextContent18446744073709550616 {
    }
    public struct ThoughtContent {
        public init(identifier: String, content: String) { fatalError() }
        public init(identifier: String, thoughts: Thoughts) { fatalError() }
        public var identifier: String { get { fatalError() } set { fatalError() } }
        public var thoughts: Thoughts { get { fatalError() } set { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var content: String { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct ThoughtContent18446744073709550616 {
    }
    public struct URLCitation {
        public init(title: String, url: URL) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var title: String { get { fatalError() } set { fatalError() } }
        public var url: URL { get { fatalError() } set { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct URLCitation18446744073709550616 {
    }
    public struct UserAudioTranscription {
        public init(identifier: String, content: String) { fatalError() }
        public var content: String { get { fatalError() } set { fatalError() } }
        public var identifier: String { get { fatalError() } set { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public init(modelInformation: ModelInformation, promptModeration: Optional<PromptCompletion.Moderation>, candidates: Array<PromptCompletion.Candidate>, usage: Usage, renderedPrompt: Optional<Prompt.Rendering>) { fatalError() }
    public init(modelInformation: ModelInformation, candidates: Array<PromptCompletion.Candidate>, usage: Usage) { fatalError() }
    public init(modelInformation: ModelInformation, candidates: Array<PromptCompletion.Candidate>, usage: Usage, renderedPrompt: Optional<Prompt.Rendering>) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidates: Array<PromptCompletion.Candidate> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var meanTokenEntropy: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var modelInformation: ModelInformation { get { fatalError() } set { fatalError() } }
    public var promptModeration: Optional<PromptCompletion.Moderation> { get { fatalError() } set { fatalError() } }
    public var renderedPrompt: Optional<Prompt.Rendering> { get { fatalError() } set { fatalError() } }
    public var usage: Usage { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletion18446744073709550616 {
}

public struct PromptCompletionEnvelope {
    public init(sealing: PromptCompletion, xpcData: inout XPC.XPCDictionary) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(sealing: PromptCompletion) { fatalError() }
    public func unseal(_: XPC.XPCDictionary) -> PromptCompletion { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func unseal() -> PromptCompletion { fatalError() }
}

public protocol PromptCompletionEvent {
}

public protocol PromptCompletionEvent18446744073709550616 {
}

public struct PromptCompletionEventCandidateAnnotation {
    public init(responseIdentifier: String, candidateIdentifier: String, annotation: PromptCompletion.Annotation) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, annotation: PromptCompletion.Annotation) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var annotation: PromptCompletion.Annotation { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateAnnotation18446744073709550616 {
}

public struct PromptCompletionEventCandidateAudioGeneration {
    public init(responseIdentifier: String, candidateIdentifier: String, audio: PromptCompletion.AudioContent) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, audio: PromptCompletion.AudioContent) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, audio: PromptCompletion.AudioContent, streamIdentifier: String) { fatalError() }
    public var audio: PromptCompletion.AudioContent { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var streamIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateAudioGeneration18446744073709550616 {
}

public struct PromptCompletionEventCandidateFileGeneration {
    public init(responseIdentifier: String, candidateIdentifier: String, file: PromptCompletion.FileContent) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, file: PromptCompletion.FileContent) { fatalError() }
    public var file: PromptCompletion.FileContent { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateFileGeneration18446744073709550616 {
}

public struct PromptCompletionEventCandidateFinished {
    public init(responseIdentifier: String, candidateIdentifier: String, finishReason: FinishReason) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var finishReason: FinishReason { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var meanTokenEntropy: Optional<Float> { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateFinished18446744073709550616 {
}

public struct PromptCompletionEventCandidateImageGeneration {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, image: PromptCompletion.ImageContent) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, image: PromptCompletion.ImageContent) { fatalError() }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var image: PromptCompletion.ImageContent { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateImageGeneration18446744073709550616 {
}

public struct PromptCompletionEventCandidateModeration {
    public init(responseIdentifier: String, candidateIdentifier: String, moderation: PromptCompletion.Moderation) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: PromptCompletion.Moderation { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateModeration18446744073709550616 {
}

public struct PromptCompletionEventCandidateOutputTokenIDs {
    public init(responseIdentifier: String, candidateIdentifier: String, outputTokenIDs: Array<Int>) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var outputTokenIDs: Array<Int> { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateOutputTokenIDs18446744073709550616 {
}

public struct PromptCompletionEventCandidateTextDelta {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int, textDelta: String) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, textDelta: String) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var textDelta: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var _userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var segmentIndex: Int { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateTextDelta18446744073709550616 {
}

public struct PromptCompletionEventCandidateThoughtContentDelta {
    public init(responseIdentifier: String, candidateIdentifier: String, thoughtContentIdentifier: String, thoughtContentDelta: String) { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, thoughtContentIdentifier: String, update: Thoughts) { fatalError() }
    public var thoughtContentDelta: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var thoughtContentIdentifier: String { get { fatalError() } set { fatalError() } }
    public var update: Thoughts { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateThoughtContentDelta18446744073709550616 {
}

public struct PromptCompletionEventCandidateToolCallDelta {
    public init(responseIdentifier: String, candidateIdentifier: String, toolCallIdentifier: String, functionName: String, argumentsDelta: String) { fatalError() }
    public var _userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var argumentsDelta: String { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var toolCallIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var functionName: String { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateToolCallDelta18446744073709550616 {
}

public struct PromptCompletionEventCandidateToolResult {
    public init(responseIdentifier: String, candidateIdentifier: String, result: Prompt.ToolResult) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var result: Prompt.ToolResult { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventCandidateToolResult18446744073709550616 {
}

public struct PromptCompletionEventCandidateUserAudioTranscriptionDelta {
    public init(responseIdentifier: String, candidateIdentifier: String, transcriptionId: String, transcriptionTextDelta: String) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var transcriptionId: String { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var transcriptionTextDelta: String { get { fatalError() } }
}

public struct PromptCompletionEventModelInformation {
    public init(responseIdentifier: String, modelInformation: ModelInformation) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var modelInformation: ModelInformation { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventModelInformation18446744073709550616 {
}

public struct PromptCompletionEventPromptModeration {
    public init(responseIdentifier: String, moderation: PromptCompletion.Moderation) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: PromptCompletion.Moderation { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct PromptCompletionEventPromptModeration18446744073709550616 {
}

public struct PromptCompletionEventRenderedPrompt {
    public init(responseIdentifier: String, renderedPrompt: Prompt.Rendering) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var renderedPrompt: Prompt.Rendering { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventRenderedPrompt18446744073709550616 {
}

public struct PromptCompletionEventResponseMetadata {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct PromptCompletionEventResponseMetadata18446744073709550616 {
}

public struct PromptCompletionEventUsage {
    public init(responseIdentifier: String, usage: Usage) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var usage: Usage { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct PromptCompletionEventUsage18446744073709550616 {
}

public struct PromptCompletionEventWireFormat {
}

public struct PromptCompletionStream18446744073709550616 {
}

public struct PromptCompletionStreamElementEnvelope {
    public init(sealing: PromptCompletionEvent, xpcData: inout XPC.XPCDictionary) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(sealing: PromptCompletionEvent) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func unseal() -> PromptCompletionEvent { fatalError() }
    public func unseal(_: XPC.XPCDictionary) -> PromptCompletionEvent { fatalError() }
}

public protocol PromptComponentValueConvertible {
    func toValue() -> Prompt.Component.Value
}

public protocol PromptComponentValueCustomDataConvertible {
}

public protocol PromptComponentValueCustomDataTransformer {
    func render(value: A.CustomDataType) throws -> Prompt
}

public struct PromptContentTemplate {
    public init(from: Decoder) throws { fatalError() }
    public init(templateString: String, values: Dictionary<String, PromptComponentValueConvertible>) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func toValue() -> Prompt.Component.Value { fatalError() }
    public var templateString: String { get { fatalError() } set { fatalError() } }
    public var values: Dictionary<String, Prompt.Component.Value> { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct PromptContentTemplateCatalog {
    public init(promptContentTemplates: Dictionary<String, Dictionary<String, String>>) { fatalError() }
    public var promptContentTemplates: Dictionary<String, Dictionary<String, String>> { get { fatalError() } }
    public func template(forID: String, locale: Optional<Locale>) throws -> String { fatalError() }
}

public struct PromptContentTemplateError {
}

public protocol PromptConvertible {
    func toPrompt() -> Prompt
}

public protocol PromptMode {
}

public protocol PromptPreprocessingTemplateConvention {
    func cacheableSystemPrefixPrompt(locale: Optional<Locale>, tokenTable: Dictionary<Prompt.SpecialToken, Any>, localizationOverrideMap: Dictionary<Prompt.SpecialToken, Dictionary<String, String>>) throws -> Prompt
    var defaultBeginPromptTokenID: Int { get }
    var defaultTokenTable: Dictionary<String, String> { get }
    var supportsMixedToolResponse: Bool { get }
    func buildTGPrompt(turns: Array<Prompt.Turn>) throws -> Prompt
    var substitutionTextForInputTokenText: Dictionary<String, String> { get }
    var supportedThoughtBudgets: Set<ThoughtBudget> { get }
    var thoughtEndToken: Optional<String> { get }
    var thoughtGrammarRules: Optional<Array<Rule>> { get }
    func tokenize(_: String, tokenizer: TokenizerRunnerTokenizer) throws -> Array<Int>
    var defaultStartOfToolCallToken: String { get }
    var defaultStopTokenStrings: Array<String> { get }
    var substitutionTextForOutputTokenText: Dictionary<String, String> { get }
    var toolCallingSpecialTokens: Array<String> { get }
    var toolRenderer: ToolRendering { get }
    func mergeSystemInstructionsIntoTokenTable(tokenTable: Dictionary<SpecialToken, String>, localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>>, systemInstructions: Dictionary<String, String>, systemInstructionsLocalizationSuffixes: Dictionary<String, Dictionary<String, String>>) -> (tokenTable: Dictionary<SpecialToken, String>, localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>>)
    var thoughtStartToken: Optional<String> { get }
    func tokenize(modularPromptFragment: String, tokenizer: TokenizerRunnerTokenizer) throws -> Array<Int>
    var defaultEndOfToolCallToken: String { get }
    var toolCallConverter: Optional<ToolCallConverter> { get }
}

public struct PromptRequestEnvelope {
    public init(sealing: PromptRequest, xpcData: inout XPC.XPCDictionary) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func unseal(_: XPC.XPCDictionary) -> PromptRequest { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public protocol PromptRetrieverProtocol {
    func retrieve(query: String) async throws -> A.RetrievedResult
    var parameters: Dictionary<String, Decodable & Encodable> { get set }
    var topK: Int { get set }
}

public struct PromptTemplate {
    public struct ModelBundleID {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public init(modelBundleID: ResourceBundleIdentifier<LLMBundle>, templateID: String, fallbackPromptTemplateCatalog: Dictionary<String, String>) { fatalError() }
    public init(modelBundleID: ResourceBundleIdentifier<LLMBundle>, templateID: String, fallbackPromptTemplateCatalog: Optional<Dictionary<String, StaticString>>) { fatalError() }
    public init(modelBundleID: ResourceBundleIdentifier<AssetBackedLLMBundle>, templateID: String, fallbackPromptTemplateCatalog: Optional<Dictionary<String, StaticString>>) { fatalError() }
    public init(modelBundleQuery: ResourceBundleQuery, templateID: String, fallbackPromptTemplateCatalog: Optional<Dictionary<String, StaticString>>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var modelBundleID: GenerativeModelsPromptTemplate.ModelBundleID { get { fatalError() } }
    public func loadRawPromptTemplateFromFallbackPromptTemplateCatalog() -> Optional<String> { fatalError() }
    public func toChatMessagePrompt() -> ChatMessagePrompt { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var templateID: String { get { fatalError() } }
}

public struct PromptTemplateHelper {
}

public struct PromptTemplateInfo {
    public struct RichVariableBinding {
        public struct Component {
            public struct Content {
                public struct ImageSurface {
                    public init(surface: IOSurface) { fatalError() }
                    public var surface: IOSurface { get { fatalError() } set { fatalError() } }
                }
                public struct MediaCollection {
                    public init(segments: Array<Prompt.MediaSegment>) { fatalError() }
                    public var segments: Array<Prompt.MediaSegment> { get { fatalError() } set { fatalError() } }
                }
                public struct Text {
                    public init(string: String) { fatalError() }
                    public init(string: String, isSelfAttention: Bool) { fatalError() }
                    public var isSelfAttention: Bool { get { fatalError() } }
                    public var string: String { get { fatalError() } }
                }
            }
            public init(content: PromptTemplateInfo.RichVariableBinding.Component.Content) { fatalError() }
            public var content: PromptTemplateInfo.RichVariableBinding.Component.Content { get { fatalError() } }
        }
        public init(components: Array<PromptTemplateInfo.RichVariableBinding.Component>) { fatalError() }
        public var components: Array<PromptTemplateInfo.RichVariableBinding.Component> { get { fatalError() } }
    }
    public init(templateID: String, richVariableBindings: Dictionary<String, PromptTemplateInfo.RichVariableBinding>, locale: Optional<Locale>) { fatalError() }
    public var instructionsTemplateVariableBindings: Dictionary<String, Array<String>> { get { fatalError() } }
    public var locale: Optional<Locale> { get { fatalError() } }
    public var richInstructionsTemplateVariableBindings: Array<GenerativeFunctionsTemplateVariableBinding> { get { fatalError() } }
    public var richVariableBindings: Dictionary<String, PromptTemplateInfo.RichVariableBinding> { get { fatalError() } }
    public var templateID: String { get { fatalError() } }
}

public struct PromptTokenizationMetadata {
    public init(promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion, tokenTable: Dictionary<SpecialToken, String>, localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>>, systemInstructions: Dictionary<String, String>, systemInstructionsLocalizationSuffixes: Dictionary<String, Dictionary<String, String>>) { fatalError() }
    public var localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>> { get { fatalError() } }
    public var promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion { get { fatalError() } }
    public var systemInstructions: Dictionary<String, String> { get { fatalError() } }
    public var systemInstructionsLocalizationSuffixes: Dictionary<String, Dictionary<String, String>> { get { fatalError() } }
    public var tokenTable: Dictionary<SpecialToken, String> { get { fatalError() } }
}

public struct PromptVariant {
    public var promptRequest: PromptRequest { get { fatalError() } }
}

public struct PromptVariantEnvelope {
    public struct ChatMessagesPromptEnvelope {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct CompletionPromptEnvelope {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public init(sealing: PromptVariant) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct Promptkit_Wireformat_Annotation {
    public struct Promptkit_Wireformat_TypeValueEnum {
    }
    public struct TypeMessage {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var typeValue: Optional<Promptkit_Wireformat_Annotation.Promptkit_Wireformat_TypeValueEnum> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public init(index: Optional<Int32>, type: Optional<Promptkit_Wireformat_Annotation.TypeMessage>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var index: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var type: Optional<Promptkit_Wireformat_Annotation.TypeMessage> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_AssetReference {
    public init(identifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_AttachmentPlaceholder {
    public init() { fatalError() }
    public init(placeholderID: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var placeholderID: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_AudioContent {
    public init(data: Optional<Data>) { fatalError() }
    public init() { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_AudioEmbeddingData {
    public init(data: Optional<Data>, tokenCount: Optional<Int32>, identifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var tokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_AudioFormat {
    public init(rawValue: Int) { fatalError() }
    public init() { fatalError() }
    public var rawValue: Int { get { fatalError() } }
}

public struct Promptkit_Wireformat_AudioSamples {
    public init(format: Optional<Promptkit_Wireformat_AudioFormat>, content: Optional<Promptkit_Wireformat_AudioSamplesContent>, identifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<Promptkit_Wireformat_AudioSamplesContent> { get { fatalError() } set { fatalError() } }
    public var format: Optional<Promptkit_Wireformat_AudioFormat> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_AudioSamplesContent {
    public init() { fatalError() }
    public var audioSamplesContentValues: Optional<Promptkit_Wireformat_AudioSamplesContentEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_AudioSamplesContentEnum {
}

public struct Promptkit_Wireformat_BindableVariable {
    public init() { fatalError() }
    public init(name: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CMTime {
    public init() { fatalError() }
    public init(value: Optional<Int64>, timescale: Optional<Int32>, flags: Optional<UInt32>, epoch: Optional<Int64>) { fatalError() }
    public var epoch: Optional<Int64> { get { fatalError() } set { fatalError() } }
    public var flags: Optional<UInt32> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var timescale: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var value: Optional<Int64> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Candidate {
    public init() { fatalError() }
    public var finishReason: Optional<Promptkit_Wireformat_FinishReason> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: Optional<Promptkit_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var outputTokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var segments: Array<Promptkit_Wireformat_Segment> { get { fatalError() } set { fatalError() } }
    public var thoughtContents: Array<Promptkit_Wireformat_ThoughtContent2> { get { fatalError() } set { fatalError() } }
    public var toolCalls: Array<Promptkit_Wireformat_ToolCall> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateAnnotationEvent {
    public init() { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int32, annotation: Optional<Promptkit_Wireformat_Annotation>) { fatalError() }
    public var annotation: Optional<Promptkit_Wireformat_Annotation> { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int32 { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateAudioEvent {
    public init() { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int32, audio: Optional<Promptkit_Wireformat_AudioContent>) { fatalError() }
    public var audio: Optional<Promptkit_Wireformat_AudioContent> { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int32 { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateFileEvent {
    public init() { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int32, file: Optional<Promptkit_Wireformat_FileContent>) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var file: Optional<Promptkit_Wireformat_FileContent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int32 { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateFinishEvent {
    public init() { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var finishReason: Optional<Promptkit_Wireformat_FinishReason> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var meanTokenEntropy: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateImageEvent {
    public init() { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int32, image: Optional<Promptkit_Wireformat_ImageContent>) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var image: Optional<Promptkit_Wireformat_ImageContent> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int32 { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateModerationEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, moderation: Optional<Promptkit_Wireformat_Moderation>) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: Optional<Promptkit_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateOutputTokenIDsEvent {
    public init() { fatalError() }
    public init(responseIdentifier: String, candidateIdentifier: String, outputTokenIds: Array<Int32>) { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var outputTokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateTextDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, segmentIndex: Int32, textDelta: String, userInfo: Optional<Data>) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var segmentIndex: Int32 { get { fatalError() } set { fatalError() } }
    public var textDelta: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateThoughtContentDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, thoughtContentIdentifier: String, thoughtContentDelta: String, update: Optional<Promptkit_Wireformat_Thoughts>) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var thoughtContentDelta: String { get { fatalError() } set { fatalError() } }
    public var thoughtContentIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var update: Optional<Promptkit_Wireformat_Thoughts> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateToolCallDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, toolCallIdentifier: String, functionName: String, argumentsDelta: String, userInfo: Optional<Data>) { fatalError() }
    public init() { fatalError() }
    public var argumentsDelta: String { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var functionName: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var toolCallIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateToolResultEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, result: Optional<Promptkit_Wireformat_ToolResult>) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var result: Optional<Promptkit_Wireformat_ToolResult> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CandidateUserAudioTranscriptionDeltaEvent {
    public init(responseIdentifier: String, candidateIdentifier: String, userAudioTranscriptionIdentifier: String, userAudioTranscriptionDelta: String) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userAudioTranscriptionDelta: String { get { fatalError() } set { fatalError() } }
    public var userAudioTranscriptionIdentifier: String { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CatalogPromptContentTemplate {
    public init() { fatalError() }
    public init(templateID: Optional<String>, values: Array<Promptkit_Wireformat_TemplateValueEntry>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var templateID: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var values: Array<Promptkit_Wireformat_TemplateValueEntry> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CategoryEnum {
}

public struct Promptkit_Wireformat_ChatMessagePromptV1 {
    public init() { fatalError() }
    public init(rolePrompt: Optional<Promptkit_Wireformat_ChatMessageRolePrompt>, prompt: Optional<Promptkit_Wireformat_Prompt>, locale: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var locale: Optional<String> { get { fatalError() } set { fatalError() } }
    public var prompt: Optional<Promptkit_Wireformat_Prompt> { get { fatalError() } set { fatalError() } }
    public var rolePrompt: Optional<Promptkit_Wireformat_ChatMessageRolePrompt> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ChatMessageRoleEnum {
}

public struct Promptkit_Wireformat_ChatMessageRolePrompt {
    public init() { fatalError() }
    public var chatMessageRoleValues: Optional<Promptkit_Wireformat_ChatMessageRoleEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ChatMessageRolePromptAssistant {
    public init(thoughtContent: Optional<Promptkit_Wireformat_Prompt>, thoughts: Optional<Promptkit_Wireformat_Thoughts>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var thoughtContent: Optional<Promptkit_Wireformat_Prompt> { get { fatalError() } set { fatalError() } }
    public var thoughts: Optional<Promptkit_Wireformat_Thoughts> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ChatMessageRolePromptCustom {
    public init() { fatalError() }
    public init(roleName: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var roleName: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ChatMessageRolePromptSystem {
    public init() { fatalError() }
    public init(toolDefinitions: Array<Promptkit_Wireformat_ToolDefinition>, modalities: Array<Promptkit_Wireformat_Modality>, voice: Optional<Promptkit_Wireformat_Voice>, shouldPrependDefaultSystemInstruction: Optional<Bool>, thoughtBudget: Optional<Promptkit_Wireformat_ThoughtBudget>, prefixID: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var modalities: Array<Promptkit_Wireformat_Modality> { get { fatalError() } set { fatalError() } }
    public var prefixID: Optional<String> { get { fatalError() } set { fatalError() } }
    public var shouldPrependDefaultSystemInstruction: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var thoughtBudget: Optional<Promptkit_Wireformat_ThoughtBudget> { get { fatalError() } set { fatalError() } }
    public var toolDefinitions: Array<Promptkit_Wireformat_ToolDefinition> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var voice: Optional<Promptkit_Wireformat_Voice> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ChatMessageRolePromptTool {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ChatMessageRolePromptUser {
    public init(responseFormat: Optional<Promptkit_Wireformat_ResponseFormat>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseFormat: Optional<Promptkit_Wireformat_ResponseFormat> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ChatPromptV1 {
    public init() { fatalError() }
    public var chatMessagesPromptBindings: Dictionary<String, Promptkit_Wireformat_ChatPromptV1> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var messages: Array<Promptkit_Wireformat_VersionedChatMessagePrompt> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_CompletionPromptV1 {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var prompt: Optional<Promptkit_Wireformat_Prompt> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Content {
    public init() { fatalError() }
    public var contentType: Optional<Promptkit_Wireformat_ContentTypeEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ContentAdvisory {
    public init(category: Optional<Promptkit_Wireformat_ContentAdvisoryCategory>, text: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var category: Optional<Promptkit_Wireformat_ContentAdvisoryCategory> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var text: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ContentAdvisoryCategory {
    public init() { fatalError() }
    public var category: Optional<Promptkit_Wireformat_CategoryEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ContentAdvisoryRegulatoryDomain {
    public init(rawValue: Int) { fatalError() }
    public init() { fatalError() }
    public var rawValue: Int { get { fatalError() } }
}

public struct Promptkit_Wireformat_ContentTypeEnum {
}

public struct Promptkit_Wireformat_CustomData {
    public init() { fatalError() }
    public init(name: Optional<String>, data: Optional<Data>) { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_DocumentCitation {
    public init() { fatalError() }
    public init(documentIdentifier: Optional<Promptkit_Wireformat_DocumentResourceIdentifier>) { fatalError() }
    public var documentIdentifier: Optional<Promptkit_Wireformat_DocumentResourceIdentifier> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_DocumentIdentifier {
    public init() { fatalError() }
    public init(id: Optional<String>, url: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var id: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var url: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_DocumentResourceIdentifier {
    public init(id: Optional<String>, url: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var id: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var url: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_EventTypeEnum {
}

public struct Promptkit_Wireformat_FileContent {
    public init(url: Optional<String>, name: Optional<String>, mimeType: Optional<String>, size: Optional<Int64>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var mimeType: Optional<String> { get { fatalError() } set { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var size: Optional<Int64> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var url: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_FileGenerationParameters {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_FinishReason {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var reason: Optional<Promptkit_Wireformat_ReasonEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_GenerationSchema {
    public init() { fatalError() }
    public var generationSchemaValues: Optional<Promptkit_Wireformat_GenerationSchemaEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_GenerationSchemaChoice {
    public init() { fatalError() }
    public init(identifier: Optional<String>, schema: Optional<Promptkit_Wireformat_GenerationSchema>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var schema: Optional<Promptkit_Wireformat_GenerationSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_GenerationSchemaEnum {
}

public struct Promptkit_Wireformat_GenerationSchemaField {
    public init(name: Optional<String>, description_p: Optional<String>, type: Optional<Promptkit_Wireformat_GenerationSchema>, required: Optional<Bool>) { fatalError() }
    public init() { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var required: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var type: Optional<Promptkit_Wireformat_GenerationSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_GenerationSchemaObject {
    public init() { fatalError() }
    public init(fields: Array<Promptkit_Wireformat_GenerationSchemaField>) { fatalError() }
    public var fields: Array<Promptkit_Wireformat_GenerationSchemaField> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_GenerationSchemaOneOf {
    public init(choices: Array<Promptkit_Wireformat_GenerationSchemaChoice>) { fatalError() }
    public init() { fatalError() }
    public var choices: Array<Promptkit_Wireformat_GenerationSchemaChoice> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_GenerationSchemaString {
    public init(enumerator: Array<String>, constraints: Optional<Promptkit_Wireformat_StringConstraint>) { fatalError() }
    public init() { fatalError() }
    public var constraints: Optional<Promptkit_Wireformat_StringConstraint> { get { fatalError() } set { fatalError() } }
    public var enumerator: Array<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageContent {
    public init(data: Optional<Data>) { fatalError() }
    public init() { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageData {
    public init() { fatalError() }
    public init(format: Optional<Promptkit_Wireformat_ImageFormat>, data: Optional<Data>, identifier: Optional<String>) { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var format: Optional<Promptkit_Wireformat_ImageFormat> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageEmbeddingData {
    public init(encoding: Optional<Promptkit_Wireformat_ImageEmbeddingEncoding>, data: Optional<Data>, tokenCount: Optional<Int32>, signature: Optional<String>, identifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var encoding: Optional<Promptkit_Wireformat_ImageEmbeddingEncoding> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var signature: Optional<String> { get { fatalError() } set { fatalError() } }
    public var tokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageEmbeddingEncoding {
    public init(rawValue: Int) { fatalError() }
    public init() { fatalError() }
    public var rawValue: Int { get { fatalError() } }
}

public struct Promptkit_Wireformat_ImageFormat {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var imageFormatValues: Optional<Promptkit_Wireformat_ImageFormatEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageFormatEnum {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct Promptkit_Wireformat_ImageGenerationCount {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var imageGenerationCountValues: Optional<Promptkit_Wireformat_ImageGenerationCountEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageGenerationCountEnum {
}

public struct Promptkit_Wireformat_ImageGenerationDetail {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var imageGenerationDetailValues: Optional<Promptkit_Wireformat_ImageGenerationDetailEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageGenerationDetailEnum {
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct Promptkit_Wireformat_ImageGenerationParameters {
    public init(size: Optional<Promptkit_Wireformat_ImageGenerationSize>, shape: Optional<Promptkit_Wireformat_ImageGenerationShape>, detail: Optional<Promptkit_Wireformat_ImageGenerationDetail>, count: Optional<Promptkit_Wireformat_ImageGenerationCount>, modelName: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var count: Optional<Promptkit_Wireformat_ImageGenerationCount> { get { fatalError() } set { fatalError() } }
    public var detail: Optional<Promptkit_Wireformat_ImageGenerationDetail> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var modelName: Optional<String> { get { fatalError() } set { fatalError() } }
    public var shape: Optional<Promptkit_Wireformat_ImageGenerationShape> { get { fatalError() } set { fatalError() } }
    public var size: Optional<Promptkit_Wireformat_ImageGenerationSize> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageGenerationShape {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var imageGenerationShapeValues: Optional<Promptkit_Wireformat_ImageGenerationShapeEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageGenerationShapeEnum {
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct Promptkit_Wireformat_ImageGenerationSize {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var imageGenerationSizeValues: Optional<Promptkit_Wireformat_ImageGenerationSizeEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ImageGenerationSizeEnum {
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct Promptkit_Wireformat_ImageSurface {
    public init(pixelData: Optional<Data>, width: Optional<Int32>, height: Optional<Int32>, bytesPerRow: Optional<Int32>, pixelFormat: Optional<Int32>, xpcDataIdentifier: Optional<String>, identifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var bytesPerRow: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var height: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var pixelData: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var pixelFormat: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var width: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var xpcDataIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_InferenceResponse {
    public init() { fatalError() }
    public var candidates: Array<Promptkit_Wireformat_Candidate> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var modelInformation: Optional<Promptkit_Wireformat_ModelInformation> { get { fatalError() } set { fatalError() } }
    public var promptModeration: Optional<Promptkit_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var renderedPrompt: Optional<Promptkit_Wireformat_PromptRendering> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var usage: Optional<Promptkit_Wireformat_Usage> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_InferenceResponseEvent {
    public init() { fatalError() }
    public var eventType: Optional<Promptkit_Wireformat_EventTypeEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchema {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var jsonschemaValues: Optional<Promptkit_Wireformat_JsonschemaEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaAnyOf {
    public init(title: Optional<String>, description_p: Optional<String>, definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema>, anyOf: Array<Promptkit_Wireformat_JSONSchema>) { fatalError() }
    public init() { fatalError() }
    public var anyOf: Array<Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaArray {
    public init() { fatalError() }
    public init(description_p: Optional<String>, definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema>, items: Optional<Promptkit_Wireformat_JSONSchema>, minItems: Optional<Int32>, maxItems: Optional<Int32>) { fatalError() }
    public var definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var items: Optional<Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var maxItems: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var minItems: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaBoolean {
    public init(description_p: Optional<String>, title: Optional<String>, defaultValue: Optional<Bool>) { fatalError() }
    public init() { fatalError() }
    public var defaultValue: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaConstant {
    public init(description_p: Optional<String>, constant: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var constant: Optional<String> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaDictionary {
    public init() { fatalError() }
    public init(description_p: Optional<String>, definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema>, additionalProperties: Optional<Promptkit_Wireformat_JSONSchema>) { fatalError() }
    public var additionalProperties: Optional<Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaInteger {
    public init() { fatalError() }
    public init(description_p: Optional<String>, minimum: Optional<Int32>, maximum: Optional<Int32>, title: Optional<String>, defaultValue: Optional<Int32>) { fatalError() }
    public var defaultValue: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var maximum: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var minimum: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaNull {
    public init(description_p: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaNumber {
    public init() { fatalError() }
    public init(description_p: Optional<String>, minimum: Optional<Double>, maximum: Optional<Double>, title: Optional<String>, defaultValue: Optional<Double>) { fatalError() }
    public var defaultValue: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var maximum: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var minimum: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaObject {
    public init(type: Optional<Promptkit_Wireformat_JSONSchemaType>, title: Optional<String>, description_p: Optional<String>, properties: Dictionary<String, Promptkit_Wireformat_JSONSchema>, definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema>, order: Array<String>, requiredProperties: Array<String>, additionalProperties: Optional<Bool>) { fatalError() }
    public init() { fatalError() }
    public var additionalProperties: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var definitions: Dictionary<String, Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var order: Array<String> { get { fatalError() } set { fatalError() } }
    public var properties: Dictionary<String, Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var requiredProperties: Array<String> { get { fatalError() } set { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var type: Optional<Promptkit_Wireformat_JSONSchemaType> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaProperty {
    public init(name: Optional<String>, description_p: Optional<String>, schema: Optional<Promptkit_Wireformat_JSONSchema>, isOptional: Optional<Bool>, isNullable: Optional<Bool>) { fatalError() }
    public init() { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var isNullable: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var isOptional: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var schema: Optional<Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaReference {
    public init(description_p: Optional<String>, reference: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var reference: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaString {
    public init() { fatalError() }
    public init(title: Optional<String>, description_p: Optional<String>, enumerator: Array<String>, pattern: Optional<String>, defaultValue: Optional<String>) { fatalError() }
    public var defaultValue: Optional<String> { get { fatalError() } set { fatalError() } }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var enumerator: Array<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var pattern: Optional<String> { get { fatalError() } set { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JSONSchemaType {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var jsonschemaTypeValues: Optional<Promptkit_Wireformat_JsonschemaTypeEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_JsonschemaEnum {
}

public struct Promptkit_Wireformat_JsonschemaTypeEnum {
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct Promptkit_Wireformat_MediaCollection {
    public init(segments: Array<Promptkit_Wireformat_MediaSegment>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var segments: Array<Promptkit_Wireformat_MediaSegment> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_MediaSegment {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var mediaSegmentValues: Optional<Promptkit_Wireformat_MediaSegmentEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_MediaSegmentEnum {
}

public struct Promptkit_Wireformat_MetadataEvent {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Modality {
    public init() { fatalError() }
    public init(type: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var type: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ModelInformation {
    public struct Asset {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
        public var version: Optional<String> { get { fatalError() } set { fatalError() } }
    }
    public init(assets: Array<Promptkit_Wireformat_ModelInformation.Asset>, systemVersion: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var assets: Array<Promptkit_Wireformat_ModelInformation.Asset> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var systemVersion: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ModelInformationEvent {
    public init(responseIdentifier: String, modelInformation: Optional<Promptkit_Wireformat_ModelInformation>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var modelInformation: Optional<Promptkit_Wireformat_ModelInformation> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Moderation {
    public struct Category {
        public init(identifier: Optional<String>) { fatalError() }
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct CategoryProbabilityPair {
        public init(key: Optional<Promptkit_Wireformat_Moderation.Category>, value: Promptkit_Wireformat_Moderation.Probability) { fatalError() }
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var key: Optional<Promptkit_Wireformat_Moderation.Category> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
        public var value: Promptkit_Wireformat_Moderation.Probability { get { fatalError() } set { fatalError() } }
    }
    public struct Probability {
        public init() { fatalError() }
        public init(rawValue: Int) { fatalError() }
        public var rawValue: Int { get { fatalError() } }
    }
    public init(ratings: Array<Promptkit_Wireformat_Moderation.CategoryProbabilityPair>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var ratings: Array<Promptkit_Wireformat_Moderation.CategoryProbabilityPair> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PixelBuffer {
    public init(pixelData: Optional<Data>, width: Optional<Int32>, height: Optional<Int32>, bytesPerRow: Optional<Int32>, pixelFormat: Optional<Int32>, xpcDataIdentifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var bytesPerRow: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var height: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var pixelData: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var pixelFormat: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var width: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var xpcDataIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PreprocessedImageData {
    public init(data: Array<Double>, shape: Array<Int32>, identifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var data: Array<Double> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var shape: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Prompt {
    public init() { fatalError() }
    public init(components: Array<Promptkit_Wireformat_PromptComponent>) { fatalError() }
    public var components: Array<Promptkit_Wireformat_PromptComponent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptComponent {
    public init(value: Optional<Promptkit_Wireformat_PromptComponentValue>, priority: Optional<Int32>, privacy: Optional<Promptkit_Wireformat_PromptComponentPrivacy>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var priority: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var privacy: Optional<Promptkit_Wireformat_PromptComponentPrivacy> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var value: Optional<Promptkit_Wireformat_PromptComponentValue> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptComponentCustomData {
    public init() { fatalError() }
    public init(name: Optional<String>, data: Optional<Data>) { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptComponentPrivacy {
    public init() { fatalError() }
    public init(rawValue: Int) { fatalError() }
    public var rawValue: Int { get { fatalError() } }
}

public struct Promptkit_Wireformat_PromptComponentValue {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var valueValues: Optional<Promptkit_Wireformat_ValueEnum> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptContentTemplate {
    public init() { fatalError() }
    public init(templateString: Optional<String>, values: Array<Promptkit_Wireformat_TemplateValueEntry>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var templateString: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var values: Array<Promptkit_Wireformat_TemplateValueEntry> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptModerationEvent {
    public init() { fatalError() }
    public init(responseIdentifier: String, moderation: Optional<Promptkit_Wireformat_Moderation>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: Optional<Promptkit_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptRendering {
    public struct Source {
        public init() { fatalError() }
        public init(identifier: Optional<String>, version: Optional<String>) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
        public var version: Optional<String> { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public init(source: Optional<Promptkit_Wireformat_PromptRendering.Source>, segments: Array<String>, renderedString: Optional<String>, originalPrompt: Optional<String>, tokenIds: Array<Int32>, userInfo: Dictionary<String, String>, detokenizedString: Optional<String>) { fatalError() }
    public var detokenizedString: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var originalPrompt: Optional<String> { get { fatalError() } set { fatalError() } }
    public var renderedString: Optional<String> { get { fatalError() } set { fatalError() } }
    public var segments: Array<String> { get { fatalError() } set { fatalError() } }
    public var source: Optional<Promptkit_Wireformat_PromptRendering.Source> { get { fatalError() } set { fatalError() } }
    public var tokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userInfo: Dictionary<String, String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptRequestV1 {
    public init(prompt: Optional<Promptkit_Wireformat_PromptRequestV1PromptVariant>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var prompt: Optional<Promptkit_Wireformat_PromptRequestV1PromptVariant> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptRequestV1PromptVariant {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var variant: Optional<Promptkit_Wireformat_VariantEnum> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_PromptRequestVersionEnum {
}

public struct Promptkit_Wireformat_Prompts {
    public init() { fatalError() }
    public init(prompts: Array<Promptkit_Wireformat_Prompt>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var prompts: Array<Promptkit_Wireformat_Prompt> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ReasonEnum {
}

public struct Promptkit_Wireformat_RecursiveSchema {
    public init(jsonSchema: Optional<Promptkit_Wireformat_JSONSchema>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var jsonSchema: Optional<Promptkit_Wireformat_JSONSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_RecursiveSchemaField {
    public init(name: Optional<String>, description_p: Optional<String>, isOptional: Optional<Bool>, schema: Optional<Promptkit_Wireformat_RecursiveSchema>) { fatalError() }
    public init() { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var isOptional: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var schema: Optional<Promptkit_Wireformat_RecursiveSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_RecursiveSchemaKindAnyOf {
    public init(name: Optional<String>, schemas: Array<Promptkit_Wireformat_RecursiveSchema>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var schemas: Array<Promptkit_Wireformat_RecursiveSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_RecursiveSchemaKindObject {
    public init() { fatalError() }
    public init(name: Optional<String>, fields: Array<Promptkit_Wireformat_RecursiveSchemaField>) { fatalError() }
    public var fields: Array<Promptkit_Wireformat_RecursiveSchemaField> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_RenderedPromptEvent {
    public init(responseIdentifier: String, renderedPrompt: Optional<Promptkit_Wireformat_PromptRendering>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var renderedPrompt: Optional<Promptkit_Wireformat_PromptRendering> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ResponseFormat {
    public init() { fatalError() }
    public init(kind: Optional<Promptkit_Wireformat_ResponseFormatKind>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var kind: Optional<Promptkit_Wireformat_ResponseFormatKind> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ResponseFormatGrammarDetails {
    public init() { fatalError() }
    public init(name: Optional<String>, description_p: Optional<String>, grammar: Optional<String>) { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var grammar: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ResponseFormatKind {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseFormatKindValues: Optional<Promptkit_Wireformat_ResponseFormatKindEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ResponseFormatKindEnum {
}

public struct Promptkit_Wireformat_ResponseFormatSchemaDetails {
    public init() { fatalError() }
    public init(name: Optional<String>, description_p: Optional<String>, schema: Optional<Promptkit_Wireformat_Schema>) { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var schema: Optional<Promptkit_Wireformat_Schema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Schema {
    public init() { fatalError() }
    public init(type: Optional<Promptkit_Wireformat_GenerationSchema>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var type: Optional<Promptkit_Wireformat_GenerationSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Segment {
    public init(content: Optional<Promptkit_Wireformat_Content>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<Promptkit_Wireformat_Content> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_SelfAttention {
    public init(text: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var text: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_SpecialToken {
    public init() { fatalError() }
    public init(identifier: Optional<String>, overestimatedTokenCount: Optional<Int32>, instance: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var instance: Optional<String> { get { fatalError() } set { fatalError() } }
    public var overestimatedTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_StreamBuffer {
    public init(id: Optional<String>, content: Optional<Promptkit_Wireformat_StreamBufferContent>, isEndOfStream: Optional<Bool>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<Promptkit_Wireformat_StreamBufferContent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var id: Optional<String> { get { fatalError() } set { fatalError() } }
    public var isEndOfStream: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_StreamBufferContent {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var streamBufferContentValues: Optional<Promptkit_Wireformat_StreamBufferContentEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_StreamBufferContentEnum {
}

public struct Promptkit_Wireformat_StringConstraint {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var stringConstraintValues: Optional<Promptkit_Wireformat_StringConstraintEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_StringConstraintEnum {
}

public struct Promptkit_Wireformat_StringConstraintStartsWith {
    public init(oneOf: Array<String>, butNot: Array<String>) { fatalError() }
    public init() { fatalError() }
    public var butNot: Array<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var oneOf: Array<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_TemplateValueEntry {
    public init(key: Optional<String>, value: Optional<Promptkit_Wireformat_PromptComponentValue>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var key: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var value: Optional<Promptkit_Wireformat_PromptComponentValue> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_TextContent {
    public init() { fatalError() }
    public init(value: Optional<String>, annotations: Array<Promptkit_Wireformat_Annotation>) { fatalError() }
    public var annotations: Array<Promptkit_Wireformat_Annotation> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var value: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ThoughtBudget {
    public init() { fatalError() }
    public init(rawValue: Int) { fatalError() }
    public var rawValue: Int { get { fatalError() } }
}

public struct Promptkit_Wireformat_ThoughtContent {
    public init(content: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ThoughtContent2 {
    public init(identifier: Optional<String>, content: Optional<String>, thoughts: Optional<Promptkit_Wireformat_Thoughts>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var thoughts: Optional<Promptkit_Wireformat_Thoughts> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ThoughtSignature {
    public init(signature: Optional<String>, summarizedContent: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var signature: Optional<String> { get { fatalError() } set { fatalError() } }
    public var summarizedContent: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Thoughts {
    public init(kind: Optional<Promptkit_Wireformat_ThoughtsKind>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var kind: Optional<Promptkit_Wireformat_ThoughtsKind> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ThoughtsKind {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var thoughtsKindValues: Optional<Promptkit_Wireformat_ThoughtsKindEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ThoughtsKindEnum {
}

public struct Promptkit_Wireformat_ToolCall {
    public init(id: Optional<String>, content: Optional<Promptkit_Wireformat_ToolCallContent>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<Promptkit_Wireformat_ToolCallContent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var id: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolCallContent {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var toolCallContentValues: Optional<Promptkit_Wireformat_ToolCallContentEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolCallContentEnum {
}

public struct Promptkit_Wireformat_ToolCallFunction {
    public init() { fatalError() }
    public init(name: Optional<String>, arguments: Optional<String>) { fatalError() }
    public var arguments: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolCalls {
    public init(toolCalls: Array<Promptkit_Wireformat_ToolCall>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var toolCalls: Array<Promptkit_Wireformat_ToolCall> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolDefinition {
    public init(type: Optional<Promptkit_Wireformat_ToolDefinitionType>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var type: Optional<Promptkit_Wireformat_ToolDefinitionType> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolDefinitionFunction {
    public init(name: Optional<String>, description_p: Optional<String>, parameters: Optional<Promptkit_Wireformat_GenerationSchema>) { fatalError() }
    public init() { fatalError() }
    public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var parameters: Optional<Promptkit_Wireformat_GenerationSchema> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolDefinitionType {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var toolDefinitionTypeValues: Optional<Promptkit_Wireformat_ToolDefinitionTypeEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolDefinitionTypeEnum {
}

public struct Promptkit_Wireformat_ToolResult {
    public init() { fatalError() }
    public init(id: Optional<String>, content: Optional<Promptkit_Wireformat_ToolResultContent>, output: Optional<Promptkit_Wireformat_Prompt>) { fatalError() }
    public var content: Optional<Promptkit_Wireformat_ToolResultContent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var id: Optional<String> { get { fatalError() } set { fatalError() } }
    public var output: Optional<Promptkit_Wireformat_Prompt> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolResultContent {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var toolResultContentValues: Optional<Promptkit_Wireformat_ToolResultContentEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolResultContentEnum {
}

public struct Promptkit_Wireformat_ToolResultText {
    public init(value: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var value: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ToolResults {
    public init() { fatalError() }
    public init(toolResults: Array<Promptkit_Wireformat_ToolResult>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var toolResults: Array<Promptkit_Wireformat_ToolResult> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_URLCitation {
    public init() { fatalError() }
    public init(title: Optional<String>, url: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var url: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_Usage {
    public init() { fatalError() }
    public init(promptTokenCount: Optional<Int32>, completionTokenCount: Optional<Int32>, cachedTokenCount: Optional<Int32>, thoughtTokenCount: Optional<Int32>) { fatalError() }
    public var cachedTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var completionTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var promptTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var thoughtTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_UsageEvent {
    public init() { fatalError() }
    public init(responseIdentifier: String, usage: Optional<Promptkit_Wireformat_Usage>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: String { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var usage: Optional<Promptkit_Wireformat_Usage> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_UserAudioTranscription {
    public init() { fatalError() }
    public init(identifier: Optional<String>, content: Optional<String>) { fatalError() }
    public var content: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_ValueEnum {
}

public struct Promptkit_Wireformat_VariantEnum {
}

public struct Promptkit_Wireformat_VersionedChatMessagePrompt {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var versionedChatMessagePromptValues: Optional<Promptkit_Wireformat_VersionedChatMessagePromptEnum> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_VersionedChatMessagePromptEnum {
}

public struct Promptkit_Wireformat_VersionedChatPrompt {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var versionedChatPromptValues: Optional<Promptkit_Wireformat_VersionedChatPromptEnum> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_VersionedChatPromptEnum {
}

public struct Promptkit_Wireformat_VersionedCompletionPrompt {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var versionedCompletionPromptValues: Optional<Promptkit_Wireformat_VersionedCompletionPromptEnum> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_VersionedCompletionPromptEnum {
}

public struct Promptkit_Wireformat_VersionedPromptRequest {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var promptRequestVersion: Optional<Promptkit_Wireformat_PromptRequestVersionEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_VideoFrame {
    public init(timing: Optional<Promptkit_Wireformat_CMTime>, content: Optional<Promptkit_Wireformat_VideoFrameContent>, identifier: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<Promptkit_Wireformat_VideoFrameContent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var timing: Optional<Promptkit_Wireformat_CMTime> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_VideoFrameContent {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var videoFrameContentValues: Optional<Promptkit_Wireformat_VideoFrameContentEnum> { get { fatalError() } set { fatalError() } }
}

public struct Promptkit_Wireformat_VideoFrameContentEnum {
}

public struct Promptkit_Wireformat_Voice {
    public init() { fatalError() }
    public init(name: Optional<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct RawPrompt {
    public init(text: String, originalPrompt: String, segments: Array<String>, tokenIDs: Array<Int>) { fatalError() }
    public var originalPrompt: String { get { fatalError() } }
    public var segments: Array<String> { get { fatalError() } }
    public var text: String { get { fatalError() } }
    public var tokenIDs: Array<Int> { get { fatalError() } }
}

public struct ReadDataRequest {
    public init(from: Decoder) throws { fatalError() }
    public var accessGroup: GenerativeModelsAccessGroup { get { fatalError() } }
    public var auditID: Optional<UInt32> { get { fatalError() } }
    public var key: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ReadDataResponse {
    public init(from: Decoder) throws { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct ReadDataResponseWrapper {
    public init(coder: NSCoder) { fatalError() }
    public init() { fatalError() }
    public init(readDataResponse: GenerativeModelsReadDataResponse) { fatalError() }
    public func copy(with: Optional<NSZone>) -> Any { fatalError() }
    public func encode(with: NSCoder) -> () { fatalError() }
    public var description: String { get { fatalError() } }
    public var hash: Int { get { fatalError() } }
}

public struct RecognizerElement {
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct RecursiveSchema18446744073709550616 {
}

public struct RegisterDocumentRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var documents: Array<GenerativeModelsDocumentResource> { get { fatalError() } }
}

public struct RegisterDocumentResponseElement {
    public init(from: Decoder) throws { fatalError() }
    public init(registration: GenerativeModelsDocumentRegistration) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var registration: GenerativeModelsDocumentRegistration { get { fatalError() } }
}

public protocol RenderedPromptSanitizerRunnerProtocol {
}

public struct RequestConfiguration {
    public init(isOpportunistic: Bool) { fatalError() }
    public init(isOpportunistic: Bool, cloudGuardrails: Optional<GenerativeModelsCloudGuardrails>) { fatalError() }
    public var cloudGuardrails: Optional<GenerativeModelsCloudGuardrails> { get { fatalError() } }
    public var isOpportunistic: Bool { get { fatalError() } }
}

public struct RequestConfiguration18446744073709550616 {
}

public struct RequestConfigurationEnvelope {
    public init(sealing: RequestConfiguration) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func unseal() -> RequestConfiguration { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct RequestMetadata {
    public init(invocationIdentifier: String, functionIdentifier: String, clientRequestIdentifier: Optional<String>, userInfo: Dictionary<String, String>) { fatalError() }
    public var clientRequestIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var functionIdentifier: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var invocationIdentifier: String { get { fatalError() } set { fatalError() } }
    public var userInfo: Dictionary<String, String> { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct RequestPayload {
    public init(from: Decoder) throws { fatalError() }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func writeReplayFile(folderPathURL: URL, with: ModelManagerServices.InferenceProviderRequestConfiguration) throws -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func writeReplayFile(with: ModelManagerServices.InferenceProviderRequestConfiguration) throws -> () { fatalError() }
}

public struct RequestPayload18446744073709550616 {
}

public struct ResponseFormat {
    public struct GrammarDetails {
        public init(name: String, description: Optional<String>, grammar: String) { fatalError() }
        public var grammar: String { get { fatalError() } set { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var description: Optional<String> { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var name: String { get { fatalError() } set { fatalError() } }
    }
    public struct Kind {
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct SchemaDetails {
        public init(name: String, description: Optional<String>, schema: GenerativeFunctionsSchema) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var name: String { get { fatalError() } }
        public var schema: GenerativeFunctionsSchema { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var description: Optional<String> { get { fatalError() } }
    }
    public init(kind: ResponseFormat.Kind) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var kind: ResponseFormat.Kind { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct ResponseFormatConvention {
    public init(version: PromptPreprocessingTemplateVersion) throws { fatalError() }
    public func render(format: Prompt.ResponseFormat) throws -> String { fatalError() }
}

public protocol ResponseSanitizerRunnerProtocol {
}

public protocol ResultsWriter {
    func finalize() -> ()
    func addMetric(metric: GenerativeModelsMetricData, prefix: Optional<String>, moreVariables: Optional<Dictionary<String, Any>>) -> ()
}

public struct RollbackState {
    public init() { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct RollbackStatus {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct Rule {
    public init(nonterminal: NonTerminalSymbol, _: Array<Choice>) { fatalError() }
    public init(symbol: String, _: Array<Choice>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var expression: Expression { get { fatalError() } set { fatalError() } }
    public var symbol: NonTerminalSymbol { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var description: String { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
}

public struct RunnableConfigurationStorage {
    public init() { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func set<GenericA>(_: GenerativeConfigurationKey, value: GenericA) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func config<GenericA>(_: GenerativeConfigurationKey, value: GenericA) -> RunnableConfigurationStorage { fatalError() }
    public func value(for: GenerativeConfigurationKey, type: A.Type) -> Optional { fatalError() }
    public func deleteConfig(_: GenerativeConfigurationKey) -> RunnableConfigurationStorage { fatalError() }
}

public class SafetyConfigurationOutputReader {
    public init(useCaseIdentifier: String, onBehalfOfProcessId: Optional<Int32>) { fatalError() }
    public init(bundleId: String, useCaseIdentifier: String, onBehalfOfProcessId: Optional<Int32>) { fatalError() }
}

public struct SafetyRequestConfiguration {
    public init(modelBundleInfo: GenerativeModelsModelBundleInfoForSanitizer, useCaseIdentifier: String, onBehalfOfProcessId: Int32, userRequestIdentifier: UUID) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var stringResponseSanitizerRunnerConfiguration: GenerativeModelsStringResponseSanitizerRunnerConfiguration { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var stringRenderedPromptSanitizerRunnerConfiguration: GenerativeModelsStringRenderedPromptSanitizerRunnerConfiguration { get { fatalError() } }
}

public class SafetySettingProvider {
    public init() { fatalError() }
    public var systemLocales: Array<Locale> { get { fatalError() } }
}

public protocol SafetySettingProviding {
    func localeIdentifier(locale: Locale, includeScript: Bool, includeRegion: Bool) -> Optional<String>
    var systemLocales: Array<Locale> { get }
}

public struct SamplingParameters18446744073709550616 {
}

public struct SamplingParametersEnvelope {
    public init(sealing: SamplingParameters) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func unseal() -> SamplingParameters { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct SamplingStrategy {
    public struct Choice {
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct Choice18446744073709550616 {
    }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var choice: SamplingStrategy.Choice { get { fatalError() } }
}

public struct SamplingStrategy18446744073709550616 {
}

public struct SanitizedText {
    public init(from: Decoder) throws { fatalError() }
    public init(text: String) { fatalError() }
    public var text: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct Schema18446744073709550616 {
}

public struct SecurityLevel {
    public init(rawValue: String) { fatalError() }
    public var rawValue: String { get { fatalError() } }
}

public struct SelfAttention {
    public init(_: String) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func toValue() -> Prompt.Component.Value18446744073709550616 { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var text: String { get { fatalError() } }
    public func toValue() -> Prompt.Component.Value { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct SelfAttention18446744073709550616 {
}

public protocol SemanticSearchIndexable {
    var searchKey: String { get }
}

public struct SensitiveContentSettings {
    public struct Sanitizer {
        public struct SanitizerBackendType {
            public init(from: Decoder) throws { fatalError() }
            public var hashValue: Int { get { fatalError() } }
            public static func ==(_: SensitiveContentSettings.Sanitizer.SanitizerBackendType, _: SensitiveContentSettings.Sanitizer.SanitizerBackendType) -> Bool { fatalError() }
            public func encode(to: Encoder) throws -> () { fatalError() }
            public func hash(into: inout Hasher) -> () { fatalError() }
        }
        public init(from: Decoder) throws { fatalError() }
        public static var offensiveVulgarSensitive: SensitiveContentSettings.Sanitizer { get { fatalError() } }
        public static var textSanitization: SensitiveContentSettings.Sanitizer { get { fatalError() } }
        public static var textSanitizationCode: SensitiveContentSettings.Sanitizer { get { fatalError() } }
        public static func ==(_: SensitiveContentSettings.Sanitizer, _: SensitiveContentSettings.Sanitizer) -> Bool { fatalError() }
        public var sanitizerBackendType: SensitiveContentSettings.Sanitizer.SanitizerBackendType { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public init(sanitizers: Array<SensitiveContentSettings.Sanitizer>) { fatalError() }
    public init(locale: Locale, sanitizers: Array<SensitiveContentSettings.Sanitizer>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var sanitizers: Array<SensitiveContentSettings.Sanitizer> { get { fatalError() } }
    public static func ==(_: SensitiveContentSettings, _: SensitiveContentSettings) -> Bool { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct Serialization {
}

public struct SessionConfiguration {
    public init(identifier: String, groupID: Optional<String>, useCaseID: String, preferredModelBundles: Array<ModelBundle>, handlesSensitiveData: Bool, cachePolicy: CachePolicy, onBehalfOf: Optional<Int>, parentOfOnBehalfOf: Optional<Int>, reportToBiome: Bool, outputAudioFormats: Optional<Array<AudioFormat>>, deadlineSchedule: Optional<DeadlineSchedule>) { fatalError() }
    public init(identifier: String, groupID: Optional<String>, useCaseID: String, preferredModelBundles: Array<ModelBundle>, handlesSensitiveData: Bool, cachePolicy: CachePolicy, onBehalfOf: Optional<Int>, parentOfOnBehalfOf: Optional<Int>, reportToBiome: Bool, outputAudioFormats: Optional<Array<AudioFormat>>) { fatalError() }
    public init(identifier: String, preferredModelBundles: Array<ModelBundle>, handlesSensitiveData: Bool, cachePolicy: CachePolicy) { fatalError() }
    public init(identifier: String, groupID: Optional<String>, useCaseID: String, preferredModelBundles: Array<ModelBundle>, handlesSensitiveData: Bool, cachePolicy: CachePolicy, onBehalfOf: Optional<Int>, parentOfOnBehalfOf: Optional<Int>) { fatalError() }
    public init(identifier: String, useCaseID: String, preferredModelBundles: Array<ModelBundle>, handlesSensitiveData: Bool, cachePolicy: CachePolicy, onBehalfOf: Optional<Int>, parentOfOnBehalfOf: Optional<Int>) { fatalError() }
    public init(identifier: String, useCaseID: String, preferredModelBundles: Array<ModelBundle>, handlesSensitiveData: Bool, cachePolicy: CachePolicy, onBehalfOf: Optional<Int>) { fatalError() }
    public init(identifier: String, groupID: Optional<String>, useCaseID: String, preferredModelBundles: Array<ModelBundle>, handlesSensitiveData: Bool, cachePolicy: CachePolicy, onBehalfOf: Optional<Int>, parentOfOnBehalfOf: Optional<Int>, reportToBiome: Bool) { fatalError() }
    public var deadlineSchedule: Optional<DeadlineSchedule> { get { fatalError() } set { fatalError() } }
    public var handlesSensitiveData: Bool { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: String { get { fatalError() } set { fatalError() } }
    public var onBehalfOfPID: Int { get { fatalError() } set { fatalError() } }
    public var outputAudioFormats: Optional<Array<AudioFormat>> { get { fatalError() } set { fatalError() } }
    public var preferredModelBundles: Array<ModelBundle> { get { fatalError() } set { fatalError() } }
    public var prefferedModelBundles: Array<ModelBundle> { get { fatalError() } set { fatalError() } }
    public var reportToBiome: Bool { get { fatalError() } }
    public var useCaseID: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var cachePolicy: CachePolicy { get { fatalError() } set { fatalError() } }
    public var groupID: Optional<String> { get { fatalError() } set { fatalError() } }
    public var parentOfOnBehalfOfPid: Int { get { fatalError() } set { fatalError() } }
}

public struct SpeculationParameters {
    public init(from: Decoder) throws { fatalError() }
    public init() { fatalError() }
    public var draftAlwaysAcceptRange: Optional<DraftAlwaysAcceptRange> { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var draftSteps: Optional<Int> { get { fatalError() } set { fatalError() } }
    public var earlyReturn: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var earlyReturnProbabilityThreshold: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var secondaryTreeFactor: Optional<Int> { get { fatalError() } set { fatalError() } }
    public var softMatchTolerance: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var treeFactor: Optional<Int> { get { fatalError() } set { fatalError() } }
    public var useMaximumLikelihoodTree: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct SpeculationParameters18446744073709550616 {
}

public struct StopSequenceMonitor {
    public init(stopSequences: Set<String>) { fatalError() }
    public func currentBufferedTokens() -> Array<Token> { fatalError() }
    public func handleOutputToken(_: Token) -> (tokens: Array<Token>, didStopSequenceMatch: Bool) { fatalError() }
    public func handleOutputTokens(_: Array<Token>) -> (tokens: Array<Token>, stopSequence: Optional<String>) { fatalError() }
}

public struct StreamingRequest {
}

public struct StreamingRequestPayload {
    public init(from: Decoder) throws { fatalError() }
    public var xpcData: XPC.XPCDictionary { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func revive(withXpcData: XPC.XPCDictionary) -> () { fatalError() }
    public func writeReplayFile(with: ModelManagerServices.InferenceProviderRequestConfiguration) throws -> () { fatalError() }
    public func writeReplayFile(folderPathURL: URL, with: ModelManagerServices.InferenceProviderRequestConfiguration) throws -> () { fatalError() }
}

public struct StreamingRequestPayload18446744073709550616 {
}

public struct StringGuides {
    public init(anyOf: Optional<Array<String>>) { fatalError() }
    public init(anyOf: Optional<Array<String>>, pattern: Optional<String>) { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct StringRenderedPromptOverridesSanitizationRequest {
    public init(text: String, sanitizerOverrides: StringRenderedPromptSanitizer.DefaultableOverrides, configuration: GenerativeModelsSafetyRequestConfiguration) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var configuration: GenerativeModelsSafetyRequestConfiguration { get { fatalError() } }
    public var sanitizerOverrides: StringRenderedPromptSanitizer.DefaultableOverrides { get { fatalError() } }
    public var text: String { get { fatalError() } }
}

public struct StringRenderedPromptSanitizer {
    public struct DefaultableGuardrails {
        public init(from: Decoder) throws { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public static func ==(_: StringRenderedPromptSanitizer.DefaultableGuardrails, _: StringRenderedPromptSanitizer.DefaultableGuardrails) -> Bool { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public struct DefaultableOverrides {
        public init(from: Decoder) throws { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public static func ==(_: StringRenderedPromptSanitizer.DefaultableOverrides, _: StringRenderedPromptSanitizer.DefaultableOverrides) -> Bool { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct Guardrails {
        public init(sensitiveContentSettings: Optional<SensitiveContentSettings>, languageRecognizer: Optional<LanguageRecognizer>, languageScriptValidator: Optional<LanguageScriptValidator>) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public init(sensitiveContentSettings: SensitiveContentSettings) { fatalError() }
        public var languageRecognizer: Optional<LanguageRecognizer> { get { fatalError() } }
        public var sensitiveContentSettings: Optional<SensitiveContentSettings> { get { fatalError() } }
        public static func ==(_: StringRenderedPromptSanitizer.Guardrails, _: StringRenderedPromptSanitizer.Guardrails) -> Bool { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var languageScriptValidator: Optional<LanguageScriptValidator> { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct Overrides {
        public init(from: Decoder) throws { fatalError() }
        public init(denyList: InputDenyListBundle) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var denyList: Optional<InputDenyListBundle> { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public static func ==(_: StringRenderedPromptSanitizer.Overrides, _: StringRenderedPromptSanitizer.Overrides) -> Bool { fatalError() }
    }
    public struct PrewarmMetadata {
        public init(useCaseIdentifier: String) { fatalError() }
        public init(useCaseIdentifier: String, onBehalfOfProcessId: Int32) { fatalError() }
    }
    public struct ScrubMetadata {
        public init(useCaseIdentifier: String, userRequestIdentifier: UUID, onBehalfOfProcessId: Int32) { fatalError() }
        public init(useCaseIdentifier: String, onBehalfOfProcessId: Int32) { fatalError() }
        public init(useCaseIdentifier: String) { fatalError() }
    }
    public init(overrides: StringRenderedPromptSanitizer.Overrides, guardrails: StringRenderedPromptSanitizer.Guardrails) { fatalError() }
    public init(overrides: StringRenderedPromptSanitizer.Overrides) { fatalError() }
    public init(guardrails: StringRenderedPromptSanitizer.Guardrails) { fatalError() }
    public init(overrides: StringRenderedPromptSanitizer.DefaultableOverrides, guardrails: Optional<StringRenderedPromptSanitizer.Guardrails>, cloudGuardrails: Optional<GenerativeModelsCloudGuardrails>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(overrides: Optional<StringRenderedPromptSanitizer.Overrides>, guardrails: Optional<StringRenderedPromptSanitizer.Guardrails>) { fatalError() }
    public init(overrides: StringRenderedPromptSanitizer.DefaultableOverrides, guardrails: StringRenderedPromptSanitizer.DefaultableGuardrails) { fatalError() }
    public init(overrides: StringRenderedPromptSanitizer.DefaultableOverrides, guardrails: Optional<StringRenderedPromptSanitizer.Guardrails>) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var cachedSafetyModels: GenerativeModelsCachedSafetyModelsWrapper { get { fatalError() } }
    public var guardrails: Optional<StringRenderedPromptSanitizer.Guardrails> { get { fatalError() } }
    public var overrides: StringRenderedPromptSanitizer.DefaultableOverrides { get { fatalError() } }
    public func scrub(_: String) async throws -> String { fatalError() }
    public var cloudGuardrails: Optional<GenerativeModelsCloudGuardrails> { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var modelManagerSession: GenerativeModelsModelManagerSessionWrapper { get { fatalError() } }
    public func cooldown() -> () { fatalError() }
    public static func ==(_: StringRenderedPromptSanitizer, _: StringRenderedPromptSanitizer) -> Bool { fatalError() }
}

public struct StringRenderedPromptSanitizerRunnerConfiguration {
    public init(modelBundleInfo: GenerativeModelsModelBundleInfoForSanitizer, useCaseIdentifier: String, onBehalfOfProcessId: Int32, userRequestIdentifier: UUID) { fatalError() }
    public var modelBundleInfo: GenerativeModelsModelBundleInfoForSanitizer { get { fatalError() } }
    public var onBehalfOfProcessId: Int32 { get { fatalError() } }
    public var useCaseIdentifier: String { get { fatalError() } }
    public var userRequestIdentifier: UUID { get { fatalError() } }
}

public protocol StringRenderedPromptSanitizerRunnerProtocol {
}

public struct StringRenderedPromptSanitizerWithConfiguration {
    public init(stringRenderedPromptSanitizer: StringRenderedPromptSanitizerWithRunner, configuration: GenerativeModelsStringRenderedPromptSanitizerRunnerConfiguration) { fatalError() }
    public var useCaseIdentifier: String { get { fatalError() } }
    public func scrub(_: String) async throws -> String { fatalError() }
}

public struct StringRenderedPromptSanitizerWithRunner {
    public init(sanitizer: StringRenderedPromptSanitizer, runner: GenerativeModelsStringRenderedPromptSanitizerRunnerProtocol.Type) { fatalError() }
    public var runner: GenerativeModelsStringRenderedPromptSanitizerRunnerProtocol.Type { get { fatalError() } }
    public func scrub(_: String, configuration: GenerativeModelsStringRenderedPromptSanitizerRunnerConfiguration) async throws -> String { fatalError() }
    public var sanitizer: StringRenderedPromptSanitizer { get { fatalError() } }
}

public struct StringResponseOverridesSanitizationRequest {
    public init(text: String, sanitizerOverrides: StringResponseSanitizer.DefaultableOverrides, configuration: GenerativeModelsSafetyRequestConfiguration) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var configuration: GenerativeModelsSafetyRequestConfiguration { get { fatalError() } }
    public var sanitizerOverrides: StringResponseSanitizer.DefaultableOverrides { get { fatalError() } }
    public var text: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct StringResponseSanitizer {
    public struct DefaultableGuardrails {
        public init(from: Decoder) throws { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public static func ==(_: StringResponseSanitizer.DefaultableGuardrails, _: StringResponseSanitizer.DefaultableGuardrails) -> Bool { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct DefaultableOverrides {
        public init(from: Decoder) throws { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public static func ==(_: StringResponseSanitizer.DefaultableOverrides, _: StringResponseSanitizer.DefaultableOverrides) -> Bool { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct Guardrails {
        public init(sensitiveContentSettings: SensitiveContentSettings) { fatalError() }
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public var sensitiveContentSettings: SensitiveContentSettings { get { fatalError() } }
        public static func ==(_: StringResponseSanitizer.Guardrails, _: StringResponseSanitizer.Guardrails) -> Bool { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () { fatalError() }
    }
    public struct Overrides {
        public init(from: Decoder) throws { fatalError() }
        public init(denyList: OutputDenyListBundle) { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var denyList: Optional<OutputDenyListBundle> { get { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public static func ==(_: StringResponseSanitizer.Overrides, _: StringResponseSanitizer.Overrides) -> Bool { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
    }
    public struct PrewarmMetadata {
        public init(useCaseIdentifier: String) { fatalError() }
        public init(useCaseIdentifier: String, onBehalfOfProcessId: Int32) { fatalError() }
    }
    public struct ScrubMetadata {
        public init(useCaseIdentifier: String, onBehalfOfProcessId: Int32) { fatalError() }
        public init(useCaseIdentifier: String, userRequestIdentifier: UUID, onBehalfOfProcessId: Int32) { fatalError() }
        public init(useCaseIdentifier: String) { fatalError() }
    }
    public init(guardrails: StringResponseSanitizer.Guardrails) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public init(overrides: Optional<StringResponseSanitizer.Overrides>, guardrails: Optional<StringResponseSanitizer.Guardrails>) { fatalError() }
    public init(overrides: StringResponseSanitizer.Overrides) { fatalError() }
    public init(overrides: StringResponseSanitizer.DefaultableOverrides, guardrails: Optional<StringResponseSanitizer.Guardrails>) { fatalError() }
    public init(overrides: StringResponseSanitizer.Overrides, guardrails: StringResponseSanitizer.Guardrails) { fatalError() }
    public init(overrides: StringResponseSanitizer.DefaultableOverrides, guardrails: StringResponseSanitizer.DefaultableGuardrails) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var overrides: StringResponseSanitizer.DefaultableOverrides { get { fatalError() } }
    public func scrub(_: String) async throws -> String { fatalError() }
    public func cooldown() -> () { fatalError() }
    public var guardrails: Optional<StringResponseSanitizer.Guardrails> { get { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public static func ==(_: StringResponseSanitizer, _: StringResponseSanitizer) -> Bool { fatalError() }
    public var cachedSafetyModels: GenerativeModelsCachedSafetyModelsWrapper { get { fatalError() } }
    public var modelManagerSession: GenerativeModelsModelManagerSessionWrapper { get { fatalError() } }
}

public struct StringResponseSanitizerRunnerConfiguration {
    public init(modelBundleInfo: GenerativeModelsModelBundleInfoForSanitizer, useCaseIdentifier: String, onBehalfOfProcessId: Int32, userRequestIdentifier: UUID) { fatalError() }
    public var modelBundleInfo: GenerativeModelsModelBundleInfoForSanitizer { get { fatalError() } }
    public var onBehalfOfProcessId: Int32 { get { fatalError() } }
    public var useCaseIdentifier: String { get { fatalError() } }
    public var userRequestIdentifier: UUID { get { fatalError() } }
}

public protocol StringResponseSanitizerRunnerProtocol {
}

public struct StringResponseSanitizerWithConfiguration {
    public init(stringResponseSanitizer: StringResponseSanitizerWithRunner, configuration: GenerativeModelsStringResponseSanitizerRunnerConfiguration) { fatalError() }
    public func scrub(_: String) async throws -> String { fatalError() }
    public func _sanitize(_: JsonValueContainer) async throws -> JsonValueContainer { fatalError() }
}

public struct StringResponseSanitizerWithRunner {
    public init(sanitizer: StringResponseSanitizer, runner: GenerativeModelsStringResponseSanitizerRunnerProtocol.Type) { fatalError() }
    public func scrub(_: String, configuration: GenerativeModelsStringResponseSanitizerRunnerConfiguration) async throws -> String { fatalError() }
    public var runner: GenerativeModelsStringResponseSanitizerRunnerProtocol.Type { get { fatalError() } }
    public var sanitizer: StringResponseSanitizer { get { fatalError() } }
}

public struct SuppressionConstraints {
    public init(from: Decoder) throws { fatalError() }
    public init(suppressedStrings: Set<String>) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct Symbol {
    public init(from: Decoder) throws { fatalError() }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var description: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct System {
    public init(_: Prompt) { fatalError() }
    public init(_: () async throws -> Prompt) async throws { fatalError() }
    public init(_: () throws -> Prompt) throws { fatalError() }
    public var shouldPrependDefaultSystemInstruction: Bool { get { fatalError() } set { fatalError() } }
    public var thoughtBudget: Optional<ThoughtBudget> { get { fatalError() } set { fatalError() } }
    public func thoughtBudget(_: Optional<ThoughtBudget>) -> System { fatalError() }
    public var prefixID: Optional<String> { get { fatalError() } set { fatalError() } }
    public var toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>> { get { fatalError() } set { fatalError() } }
    public func toChatMessagePrompt() -> ChatMessagePrompt { fatalError() }
    public func voice(_: Voice) -> System { fatalError() }
    public func modalities(_: Array<Modality>) -> System { fatalError() }
    public var prompt: Prompt { get { fatalError() } }
    public var voice: Optional<Voice> { get { fatalError() } set { fatalError() } }
    public func locale(_: Optional<Locale>) -> ChatMessagePrompt { fatalError() }
    public var modalities: Optional<Array<Modality>> { get { fatalError() } set { fatalError() } }
}

public struct SystemInstructionBuilder {
    public func appending(_: String) -> SystemInstructionBuilder { fatalError() }
    public func toolDefinitions(_: Array<GenerativeFunctionsToolDefinition>) -> SystemInstructionBuilder { fatalError() }
    public func toChatMessagePrompt() -> ChatMessagePrompt { fatalError() }
    public var appendedInstructions: Optional<String> { get { fatalError() } set { fatalError() } }
    public var modalities: Optional<Array<Modality>> { get { fatalError() } set { fatalError() } }
    public var thoughtBudget: Optional<ThoughtBudget> { get { fatalError() } set { fatalError() } }
    public func voice(_: Voice) -> SystemInstructionBuilder { fatalError() }
    public func thoughtBudget(_: Optional<ThoughtBudget>) -> SystemInstructionBuilder { fatalError() }
    public func modalities(_: Array<Modality>) -> SystemInstructionBuilder { fatalError() }
    public var prefixID: String { get { fatalError() } }
    public func locale(_: Optional<Locale>) -> SystemInstructionBuilder { fatalError() }
    public var locale: Optional<Locale> { get { fatalError() } set { fatalError() } }
    public var toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>> { get { fatalError() } set { fatalError() } }
    public var voice: Optional<Voice> { get { fatalError() } set { fatalError() } }
}

public struct SystemRetrievalHandler {
    public static func getSystemRetrievalHandler() -> Optional<SystemRetrievalHandlerProtocol> { fatalError() }
    public static func setSystemRetrievalHandler(_: SystemRetrievalHandlerProtocol) -> () { fatalError() }
}

public protocol SystemRetrievalHandlerProtocol {
    func retrievePersonRelationship(personName: String) async throws -> String
    func retrievePhoneNumberLookup(phone: String) async throws -> String
    func retrieveKnosisResult(kgq: String) async throws -> String
    func retrieveDeviceOwnerName() async throws -> String
    func retrievePreferredName(person: String) async throws -> String
    func retrieveEmailAddressLookup(email: String) async throws -> String
    func retrieveSystemContext(query: String) async throws -> Array<String>
}

public struct SystemRetrievalXPCService {
    public static var entitlementName: String { get { fatalError() } set { fatalError() } }
    public static var interface: Protocol { get { fatalError() } set { fatalError() } }
    public static var logger: Logger { get { fatalError() } set { fatalError() } }
    public static var selectorClasses: KeyValuePairs<(Selector, Int), Set<AnyHashable>> { get { fatalError() } set { fatalError() } }
    public static var serviceName: String { get { fatalError() } set { fatalError() } }
}

public struct TGModes {
    public init(rawValue: String) { fatalError() }
    public var rawValue: String { get { fatalError() } }
}

public struct TerminalSymbol {
    public init(from: Decoder) throws { fatalError() }
    public var description: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func contains(_: Unicode.Scalar) -> Bool { fatalError() }
}

public struct TextSafetyConfigurationRequest {
    public init(resourceId: String) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var resourceId: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct TextSafetyConfigurationResponse {
    public init(from: Decoder) throws { fatalError() }
    public init(configuration: String) { fatalError() }
    public var configuration: String { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ThoughtContent {
    public init(from: Decoder) throws { fatalError() }
    public init(content: String) { fatalError() }
    public var content: String { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ThoughtSignature {
    public init(signature: String, summarizedContent: Optional<String>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var summarizedContent: Optional<String> { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var signature: String { get { fatalError() } set { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct Thoughts {
    public struct Kind {
        public init(from: Decoder) throws { fatalError() }
        public func encode(to: Encoder) throws -> () { fatalError() }
        public func hash(into: inout Hasher) -> () { fatalError() }
        public var hashValue: Int { get { fatalError() } }
    }
    public init(_: Promptkit_Wireformat_Thoughts) throws { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var thoughtContent: Optional<ThoughtContent> { get { fatalError() } }
    public var thoughtSignature: Optional<ThoughtSignature> { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var wireFormat: Promptkit_Wireformat_Thoughts { get { fatalError() } }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var kind: Thoughts.Kind { get { fatalError() } set { fatalError() } }
}

public struct Token {
    public init(text: String) { fatalError() }
    public var text: String { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
}

public struct TokenGeneratationSessionConfigurationEnvelope {
    public init(sealing: TokenGenerationSessionConfiguration) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func unseal() -> TokenGenerationSessionConfiguration { fatalError() }
}

public struct TokenGenerationError {
    public struct Code {
        public init(rawValue: Int) { fatalError() }
        public var rawValue: Int { get { fatalError() } }
    }
    public struct Context {
        public init(debugDescription: String, underlyingError: Optional<Error>, userFacingLocalizedErrorMessage: Optional<String>, userInfo: Dictionary<String, String>) { fatalError() }
        public init(debugDescription: String, underlyingError: Optional<Error>) { fatalError() }
        public init(debugDescription: String, underlyingError: Optional<Error>, userFacingLocalizedErrorMessage: Optional<String>) { fatalError() }
        public var debugDescription: String { get { fatalError() } set { fatalError() } }
        public var underlyingError: Optional<Error> { get { fatalError() } set { fatalError() } }
        public var userFacingLocalizedErrorMessage: Optional<String> { get { fatalError() } set { fatalError() } }
        public var userInfo: Dictionary<String, String> { get { fatalError() } set { fatalError() } }
    }
    public var category: AppleIntelligenceReporting.AppleIntelligenceErrorCategory { get { fatalError() } }
    public var code: TokenGenerationError.Code { get { fatalError() } }
    public var context: TokenGenerationError.Context { get { fatalError() } }
    public var descriptionWithoutUnderlying: String { get { fatalError() } }
    public var errorDescription: Optional<String> { get { fatalError() } }
    public var rawCode: Int { get { fatalError() } }
    public var underlyingErrors: Array<AppleIntelligenceReporting.AppleIntelligenceError> { get { fatalError() } }
    public func toInferenceError() -> ModelManagerServices.InferenceError { fatalError() }
}

public struct TokenGenerationInterfaceVersion {
    public init(major: UInt32, minor: UInt32, patch: UInt32) { fatalError() }
    public var major: UInt32 { get { fatalError() } }
    public var minor: UInt32 { get { fatalError() } }
    public var patch: UInt32 { get { fatalError() } }
}

public struct TokenGenerationSessionConfiguration {
    public init(cachePolicy: CachePolicy, outputAudioFormats: Optional<Array<AudioFormat>>) { fatalError() }
    public var cachePolicy: CachePolicy { get { fatalError() } }
    public var outputAudioFormats: Optional<Array<AudioFormat>> { get { fatalError() } }
}

public struct TokenGeneratorChatResponse {
    public var promptCompletion: PromptCompletion { get { fatalError() } }
    public var role: ChatMessageRole { get { fatalError() } }
}

public struct TokenGeneratorChatResponseGenerableAdditionalInfo {
    public var inferenceResponse: InferenceResponse { get { fatalError() } }
    public var promptCompletion: PromptCompletion { get { fatalError() } }
}

public struct TokenGeneratorChatResponseStringStream {
    public var _generativeFunctionInstrumenter: GenerativeFunctionsInstrumentation.GenerativeFunctionInstrumenter { get { fatalError() } }
    public var _stringResponseSanitizerWithConfiguration: Optional<GenerativeModelsStringResponseSanitizerWithConfiguration> { get { fatalError() } }
    public var events: PromptCompletionStream { get { fatalError() } }
    public var rawStream: TokenStream<String> { get { fatalError() } }
    public var role: ChatMessageRole { get { fatalError() } }
    public var stream: TokenGeneratorChatResponseStringStream { get { fatalError() } }
    public var timeout: Optional<Double> { get { fatalError() } }
}

public struct TokenGeneratorCompletionResponse {
    public var inferenceResponse: InferenceResponse { get { fatalError() } }
    public var promptCompletion: PromptCompletion { get { fatalError() } }
}

public struct TokenGeneratorCompletionResponseOneShotGenerableAdditionalInfo {
    public var inferenceResponse: InferenceResponse { get { fatalError() } }
    public var promptCompletion: PromptCompletion { get { fatalError() } }
}

public struct TokenGeneratorCompletionResponseStringStream {
    public var _generativeFunctionInstrumenter: GenerativeFunctionsInstrumentation.GenerativeFunctionInstrumenter { get { fatalError() } }
    public var _stringResponseSanitizerWithConfiguration: Optional<GenerativeModelsStringResponseSanitizerWithConfiguration> { get { fatalError() } }
    public var events: PromptCompletionStream { get { fatalError() } }
    public var rawStream: TokenStream<String> { get { fatalError() } }
    public var stream: TokenGeneratorCompletionResponseStringStream { get { fatalError() } }
    public var timeout: Optional<Double> { get { fatalError() } }
}

public struct TokenGeneratorResponsePromptCompletionStream {
    public struct AsyncIterator {
        public func next() async throws -> Optional<PromptCompletionEvent> { fatalError() }
    }
    public func makeAsyncIterator() -> TokenGeneratorResponsePromptCompletionStream.AsyncIterator { fatalError() }
    public func collect() async throws -> PromptCompletion { fatalError() }
}

public struct TokenGeneratorResponseStringStreamAsyncIterator {
    public func next() async throws -> Optional<String> { fatalError() }
}

public protocol TokenGeneratorResponseStringStreamAsyncSequence {
    var _generativeFunctionInstrumenter: GenerativeFunctionsInstrumentation.GenerativeFunctionInstrumenter { get }
    var rawStream: TokenStream<String> { get }
    func collect() async throws -> (content: String, tokens: Array<String>)
    var _stringResponseSanitizerWithConfiguration: Optional<GenerativeModelsStringResponseSanitizerWithConfiguration> { get }
    var timeout: Optional<Double> { get }
}

public struct TokenIDMask {
    public init(vocabularySize: Int) { fatalError() }
    public var mask: ContiguousBitSet { get { fatalError() } set { fatalError() } }
    public func booleanMask(ofSize: Int) throws -> ContiguousArray<Bool> { fatalError() }
    public var booleanMask: ContiguousArray<Bool> { get { fatalError() } }
    public func allowedTokenIDs() -> Array<Int> { fatalError() }
    public func copyPackedMask(to: UnsafeMutablePointer<UInt64>, wordCount: Int, totalSize: Int) throws -> () { fatalError() }
}

public struct TokenIDMaskComputation {
}

public struct TokenIDMaskResponse {
}

public class TokenIDToTextConverter {
    public init(tokenizer: TokenizerRunner, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion) { fatalError() }
    public init(tokenizer: TokenizerRunner, replacementTextByTokenText: Dictionary<String, String>, isOneShot: Bool) { fatalError() }
    public init(tokenizer: TokenizerRunner, replacementTextByTokenText: Dictionary<String, String>) { fatalError() }
    public func textsForTokenID(_: Int, isStopTokenID: Bool) throws -> Array<String> { fatalError() }
    public var text: String { get { fatalError() } }
    public func textForTokenID(_: Int, isStopTokenID: Bool) throws -> String { fatalError() }
}

public protocol TokenIDToTextConverterProtocol {
    func textsForTokenID(_: Int, isStopTokenID: Bool) throws -> Array<String>
    var text: String { get }
    func textForTokenID(_: Int, isStopTokenID: Bool) throws -> String
}

public struct Tokengeneration_Wireformat_CachePolicy {
    public struct InMemory {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct Session {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public var cachePolicyValue: Optional<Tokengeneration_Wireformat_CachePolicyValueEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_CachePolicyValueEnum {
}

public struct Tokengeneration_Wireformat_CompletePromptRequest {
    public init() { fatalError() }
    public init(promptRequest: Optional<Promptkit_Wireformat_VersionedPromptRequest>, parameters: Optional<Tokengeneration_Wireformat_SamplingParameters>, toolDefinitions: Array<Promptkit_Wireformat_ToolDefinition>, toolChoice: Optional<Tokengenerationcore_Wireformat_ToolChoice>, constraints: Optional<Tokengenerationcore_Wireformat_Constraints>, tools: Array<Tokengeneration_Wireformat_ToolType>, inheritToolDefinitionsFromPrompt: Optional<Bool>, deadlineSchedule: Optional<Tokengeneration_Wireformat_DeadlineSchedule>) { fatalError() }
    public var constraints: Optional<Tokengenerationcore_Wireformat_Constraints> { get { fatalError() } set { fatalError() } }
    public var deadlineSchedule: Optional<Tokengeneration_Wireformat_DeadlineSchedule> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var inheritToolDefinitionsFromPrompt: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var parameters: Optional<Tokengeneration_Wireformat_SamplingParameters> { get { fatalError() } set { fatalError() } }
    public var promptRequest: Optional<Promptkit_Wireformat_VersionedPromptRequest> { get { fatalError() } set { fatalError() } }
    public var toolChoice: Optional<Tokengenerationcore_Wireformat_ToolChoice> { get { fatalError() } set { fatalError() } }
    public var toolDefinitions: Array<Promptkit_Wireformat_ToolDefinition> { get { fatalError() } set { fatalError() } }
    public var tools: Array<Tokengeneration_Wireformat_ToolType> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_DeadlineSchedule {
    public init() { fatalError() }
    public init(startupTokenCount: Optional<Int32>, period: Optional<Double>, minDeadlineSeconds: Optional<Double>, phaseReferenceMct: Optional<UInt64>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var minDeadlineSeconds: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var period: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var phaseReferenceMct: Optional<UInt64> { get { fatalError() } set { fatalError() } }
    public var startupTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingContent {
    public init() { fatalError() }
    public init(content: Optional<String>) { fatalError() }
    public var content: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingGeneration {
    public struct EmbeddingResponse {
        public struct AdditionalInformation {
            public init(usage: Optional<Tokengeneration_Wireformat_EmbeddingGeneration.Usage>, didTruncateInput: Optional<Bool>) { fatalError() }
            public init() { fatalError() }
            public var didTruncateInput: Optional<Bool> { get { fatalError() } set { fatalError() } }
            public var hashValue: Int { get { fatalError() } }
            public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
            public var usage: Optional<Tokengeneration_Wireformat_EmbeddingGeneration.Usage> { get { fatalError() } set { fatalError() } }
        }
        public init(embedding: Array<Float>, additionalInformation: Optional<Tokengeneration_Wireformat_EmbeddingGeneration.EmbeddingResponse.AdditionalInformation>) { fatalError() }
        public init() { fatalError() }
        public var additionalInformation: Optional<Tokengeneration_Wireformat_EmbeddingGeneration.EmbeddingResponse.AdditionalInformation> { get { fatalError() } set { fatalError() } }
        public var embedding: Array<Float> { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct Usage {
        public init() { fatalError() }
        public init(tokenCount: Optional<Int32>) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var tokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init(embeddings: Array<Tokengeneration_Wireformat_EmbeddingGeneration.EmbeddingResponse>, modelInformation: Optional<Promptkit_Wireformat_ModelInformation>) { fatalError() }
    public init() { fatalError() }
    public var embeddings: Array<Tokengeneration_Wireformat_EmbeddingGeneration.EmbeddingResponse> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var modelInformation: Optional<Promptkit_Wireformat_ModelInformation> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingGenerationParameters {
    public init() { fatalError() }
    public init(outputDimensions: Optional<Int32>, shouldAutomaticallyTruncateInputContent: Optional<Bool>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var outputDimensions: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var shouldAutomaticallyTruncateInputContent: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingModelInformation {
    public init(defaultOutputDimensions: Optional<Int32>, modelInformation: Optional<Promptkit_Wireformat_ModelInformation>) { fatalError() }
    public init() { fatalError() }
    public var defaultOutputDimensions: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var modelInformation: Optional<Promptkit_Wireformat_ModelInformation> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingModelInformationRequest {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingModelInformationResponse {
    public init() { fatalError() }
    public init(response: Optional<Tokengeneration_Wireformat_EmbeddingModelInformation>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var response: Optional<Tokengeneration_Wireformat_EmbeddingModelInformation> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingTask {
    public init() { fatalError() }
    public init(taskType: Optional<Tokengeneration_Wireformat_EmbeddingTaskType>, content: Optional<Tokengeneration_Wireformat_EmbeddingContent>) { fatalError() }
    public var content: Optional<Tokengeneration_Wireformat_EmbeddingContent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var taskType: Optional<Tokengeneration_Wireformat_EmbeddingTaskType> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_EmbeddingTaskType {
    public struct Document {
        public init() { fatalError() }
        public init(title: Optional<String>) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var title: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct Query {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var taskType: Optional<Tokengeneration_Wireformat_TaskTypeEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_GenerateEmbeddingsRequest {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var parameters: Optional<Tokengeneration_Wireformat_EmbeddingGenerationParameters> { get { fatalError() } set { fatalError() } }
    public var tasks: Array<Tokengeneration_Wireformat_EmbeddingTask> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_GenerateEmbeddingsResponse {
    public init(response: Optional<Tokengeneration_Wireformat_EmbeddingGeneration>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var response: Optional<Tokengeneration_Wireformat_EmbeddingGeneration> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_ModelManagerSessionConfiguration {
    public init(modelBundleIdentifier: Optional<String>, sessionUuid: Optional<String>, requestUuid: Optional<String>, isStreaming: Optional<Bool>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var isStreaming: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var modelBundleIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var requestUuid: Optional<String> { get { fatalError() } set { fatalError() } }
    public var sessionUuid: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_RequestMetadata {
    public init() { fatalError() }
    public init(invocationIdentifier: Optional<String>, functionIdentifier: Optional<String>, clientRequestIdentifier: Optional<String>, userInfo: Dictionary<String, String>) { fatalError() }
    public var clientRequestIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var functionIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var invocationIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userInfo: Dictionary<String, String> { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_RequestPayloadEnum {
}

public struct Tokengeneration_Wireformat_SamplingParameters {
    public init(strategy: Optional<Tokengeneration_Wireformat_SamplingStrategy>, temperature: Optional<Double>, frequencyPenalty: Optional<Double>, lengthPenalty: Optional<Double>, maximumTokens: Optional<Int32>, stopSequences: Array<String>, randomSeed: Optional<Int32>, timeout: Optional<Double>, promptLookupDraftSteps: Optional<Int32>, randomSeedInt64: Optional<Int64>, speculativeSampling: Optional<Bool>, tokenHealing: Optional<Bool>, useHighQualityImageTokenization: Optional<Bool>, speculativeDecoding: Optional<Bool>, priorInferenceOutput: Optional<String>, speculationParameters: Optional<Tokengeneration_Wireformat_SpeculationParameters>, maxImagePixels: Optional<Int32>) { fatalError() }
    public init() { fatalError() }
    public var frequencyPenalty: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var lengthPenalty: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var maxImagePixels: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var maximumTokens: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var priorInferenceOutput: Optional<String> { get { fatalError() } set { fatalError() } }
    public var promptLookupDraftSteps: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var randomSeed: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var randomSeedInt64: Optional<Int64> { get { fatalError() } set { fatalError() } }
    public var speculationParameters: Optional<Tokengeneration_Wireformat_SpeculationParameters> { get { fatalError() } set { fatalError() } }
    public var speculativeDecoding: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var speculativeSampling: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var stopSequences: Array<String> { get { fatalError() } set { fatalError() } }
    public var strategy: Optional<Tokengeneration_Wireformat_SamplingStrategy> { get { fatalError() } set { fatalError() } }
    public var temperature: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var timeout: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var tokenHealing: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var useHighQualityImageTokenization: Optional<Bool> { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_SamplingStrategy {
    public struct Argmax {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct NucleusSampling {
        public init(threshold: Optional<Double>) { fatalError() }
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var threshold: Optional<Double> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct TopK {
        public init(count: Optional<Int32>) { fatalError() }
        public init() { fatalError() }
        public var count: Optional<Int32> { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct TopKThenTopP {
        public init(count: Optional<Int32>, threshold: Optional<Double>) { fatalError() }
        public init() { fatalError() }
        public var count: Optional<Int32> { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var threshold: Optional<Double> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var strategy: Optional<Tokengeneration_Wireformat_StrategyEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_SpeculationParameters {
    public init() { fatalError() }
    public init(draftSteps: Optional<Int32>, treeFactor: Optional<Int32>, secondaryTreeFactor: Optional<Int32>, softMatchTolerance: Optional<Float>, earlyReturn: Optional<Bool>, earlyReturnProbabilityThreshold: Optional<Float>, useMaximumLikelihoodTree: Optional<Bool>) { fatalError() }
    public var draftSteps: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var earlyReturn: Optional<Bool> { get { fatalError() } set { fatalError() } }
    public var earlyReturnProbabilityThreshold: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var secondaryTreeFactor: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var softMatchTolerance: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var treeFactor: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var useMaximumLikelihoodTree: Optional<Bool> { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_StrategyEnum {
}

public struct Tokengeneration_Wireformat_TaskTypeEnum {
}

public struct Tokengeneration_Wireformat_TokenGenerationError {
    public init(message: Optional<String>, type: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var message: Optional<String> { get { fatalError() } set { fatalError() } }
    public var type: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_TokenGenerationRequest {
    public init(modelManagerSessionConfiguration: Optional<Tokengeneration_Wireformat_ModelManagerSessionConfiguration>, tokenGenerationSessionConfiguration: Optional<Tokengeneration_Wireformat_TokenGenerationSessionConfiguration>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var modelManagerSessionConfiguration: Optional<Tokengeneration_Wireformat_ModelManagerSessionConfiguration> { get { fatalError() } set { fatalError() } }
    public var requestPayload: Optional<Tokengeneration_Wireformat_RequestPayloadEnum> { get { fatalError() } set { fatalError() } }
    public var tokenGenerationSessionConfiguration: Optional<Tokengeneration_Wireformat_TokenGenerationSessionConfiguration> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_TokenGenerationResponse {
    public init(sessionConfiguration: Optional<Tokengeneration_Wireformat_ModelManagerSessionConfiguration>, response: Optional<Tokengenerationcore_Wireformat_PromptCompletionResponse>, request: Optional<Tokengeneration_Wireformat_TokenGenerationRequest>, error: Optional<Tokengeneration_Wireformat_TokenGenerationError>) { fatalError() }
    public init() { fatalError() }
    public var error: Optional<Tokengeneration_Wireformat_TokenGenerationError> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var request: Optional<Tokengeneration_Wireformat_TokenGenerationRequest> { get { fatalError() } set { fatalError() } }
    public var response: Optional<Tokengenerationcore_Wireformat_PromptCompletionResponse> { get { fatalError() } set { fatalError() } }
    public var sessionConfiguration: Optional<Tokengeneration_Wireformat_ModelManagerSessionConfiguration> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_TokenGenerationSessionConfiguration {
    public init() { fatalError() }
    public init(cachePolicy: Optional<Tokengeneration_Wireformat_CachePolicy>) { fatalError() }
    public var cachePolicy: Optional<Tokengeneration_Wireformat_CachePolicy> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengeneration_Wireformat_ToolEnum {
}

public struct Tokengeneration_Wireformat_ToolType {
    public struct Browser {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct FileGenerationTool {
        public init() { fatalError() }
        public init(parameters: Optional<Promptkit_Wireformat_FileGenerationParameters>) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var parameters: Optional<Promptkit_Wireformat_FileGenerationParameters> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct Function {
        public init(name: Optional<String>, description_p: Optional<String>, parameters: Optional<Promptkit_Wireformat_GenerationSchema>) { fatalError() }
        public init() { fatalError() }
        public var description_p: Optional<String> { get { fatalError() } set { fatalError() } }
        public var hashValue: Int { get { fatalError() } }
        public var name: Optional<String> { get { fatalError() } set { fatalError() } }
        public var parameters: Optional<Promptkit_Wireformat_GenerationSchema> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct ImageGenerationTool {
        public init(parameters: Optional<Promptkit_Wireformat_ImageGenerationParameters>) { fatalError() }
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var parameters: Optional<Promptkit_Wireformat_ImageGenerationParameters> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct ImageGenerator {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct WebSearch {
        public init(locale: Optional<String>) { fatalError() }
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var locale: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var tool: Optional<Tokengeneration_Wireformat_ToolEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_Annotation {
    public struct Tokengenerationcore_Wireformat_TypeValueEnum {
    }
    public struct TypeMessage {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var typeValue: Optional<Tokengenerationcore_Wireformat_Annotation.Tokengenerationcore_Wireformat_TypeValueEnum> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init(index: Optional<Int32>, type: Optional<Tokengenerationcore_Wireformat_Annotation.TypeMessage>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var index: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var type: Optional<Tokengenerationcore_Wireformat_Annotation.TypeMessage> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_AudioContent {
    public init(data: Optional<Data>, format: Optional<Promptkit_Wireformat_AudioFormat>) { fatalError() }
    public init() { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var format: Optional<Promptkit_Wireformat_AudioFormat> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ByteToTokenIDMapping {
    public init(byte: Optional<Int32>, tokenID: Optional<Int32>) { fatalError() }
    public init() { fatalError() }
    public var byte: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var tokenID: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_Candidate {
    public init() { fatalError() }
    public var finishReason: Optional<Tokengenerationcore_Wireformat_FinishReason> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: Optional<Tokengenerationcore_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var outputTokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var segments: Array<Tokengenerationcore_Wireformat_Segment> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateAnnotationEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, annotation: Optional<Tokengenerationcore_Wireformat_Annotation>) { fatalError() }
    public var annotation: Optional<Tokengenerationcore_Wireformat_Annotation> { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateAudioGenerationEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, audio: Optional<Tokengenerationcore_Wireformat_AudioContent>, streamIdentifier: Optional<String>) { fatalError() }
    public var audio: Optional<Tokengenerationcore_Wireformat_AudioContent> { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var streamIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateFileGenerationEvent {
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, file: Optional<Tokengenerationcore_Wireformat_FileContent>) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var file: Optional<Tokengenerationcore_Wireformat_FileContent> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateFinishedEvent {
    public init() { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var finishReason: Optional<Tokengenerationcore_Wireformat_FinishReason> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var meanTokenEntropy: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateImageGenerationEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, image: Optional<Tokengenerationcore_Wireformat_ImageContent>) { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var image: Optional<Tokengenerationcore_Wireformat_ImageContent> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateModerationEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, moderation: Optional<Tokengenerationcore_Wireformat_Moderation>) { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: Optional<Tokengenerationcore_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateOutputTokenIDsEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, outputTokenIds: Array<Int32>) { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var outputTokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateTextDeltaEvent {
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, textDelta: Optional<String>, userInfo: Optional<Data>) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var textDelta: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateThoughtContentDeltaEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, thoughtContentIdentifier: Optional<String>, thoughtContentDelta: Optional<String>, update: Optional<Promptkit_Wireformat_Thoughts>) { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var thoughtContentDelta: Optional<String> { get { fatalError() } set { fatalError() } }
    public var thoughtContentIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var update: Optional<Promptkit_Wireformat_Thoughts> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateToolCallDeltaEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, toolCallIdentifier: Optional<String>, functionName: Optional<String>, argumentsDelta: Optional<String>, userInfo: Optional<Data>) { fatalError() }
    public var argumentsDelta: Optional<String> { get { fatalError() } set { fatalError() } }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var functionName: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var toolCallIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userInfo: Optional<Data> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateToolResultEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, result: Optional<Promptkit_Wireformat_ToolResult>) { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var result: Optional<Promptkit_Wireformat_ToolResult> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CandidateUserAudioTranscriptionDeltaEvent {
    public init(responseIdentifier: Optional<String>, candidateIdentifier: Optional<String>, transcriptionID: Optional<String>, transcriptionTextDelta: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var candidateIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var transcriptionID: Optional<String> { get { fatalError() } set { fatalError() } }
    public var transcriptionTextDelta: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CategoryEnum {
}

public struct Tokengenerationcore_Wireformat_CharacterSetLookup {
    public init() { fatalError() }
    public init(characterSetName: Optional<String>, tokenIds: Array<Int32>) { fatalError() }
    public var characterSetName: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var tokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CharacterSetLookupData {
    public init(accepted: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry>, acceptedAfterStartWord: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry>, recursivelyUsedAccepted: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry>, recursivelyUsedAcceptedAfterStartWord: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry>) { fatalError() }
    public init() { fatalError() }
    public var accepted: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry> { get { fatalError() } set { fatalError() } }
    public var acceptedAfterStartWord: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var recursivelyUsedAccepted: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry> { get { fatalError() } set { fatalError() } }
    public var recursivelyUsedAcceptedAfterStartWord: Array<Tokengenerationcore_Wireformat_CharacterSetLookupEntry> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CharacterSetLookupEntry {
    public init(characterSetName: Optional<String>, logitMask: Optional<Data>, candidateRanks: Array<Int32>) { fatalError() }
    public init() { fatalError() }
    public var candidateRanks: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var characterSetName: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var logitMask: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_CharacterToIntArrayMapping {
    public init(character: Optional<String>, ranks: Array<Int32>) { fatalError() }
    public init() { fatalError() }
    public var character: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var ranks: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ConstraintEnum {
}

public struct Tokengenerationcore_Wireformat_Constraints {
    public struct ConstrainedDecodingDisabled {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public var constraint: Optional<Tokengenerationcore_Wireformat_ConstraintEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_Content {
    public init() { fatalError() }
    public var contentType: Optional<Tokengenerationcore_Wireformat_ContentTypeEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ContentAdvisory {
    public init() { fatalError() }
    public init(category: Optional<Tokengenerationcore_Wireformat_ContentAdvisoryCategory>, text: Optional<String>) { fatalError() }
    public var category: Optional<Tokengenerationcore_Wireformat_ContentAdvisoryCategory> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var text: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ContentAdvisoryCategory {
    public init() { fatalError() }
    public var category: Optional<Tokengenerationcore_Wireformat_CategoryEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ContentAdvisoryRegulatoryDomain {
    public init() { fatalError() }
    public init(rawValue: Int) { fatalError() }
    public var rawValue: Int { get { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ContentTypeEnum {
}

public struct Tokengenerationcore_Wireformat_DocumentCitation {
    public init() { fatalError() }
    public init(documentIdentifier: Optional<Promptkit_Wireformat_DocumentResourceIdentifier>) { fatalError() }
    public var documentIdentifier: Optional<Promptkit_Wireformat_DocumentResourceIdentifier> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_EventTypeEnum {
}

public struct Tokengenerationcore_Wireformat_FileContent {
    public init(url: Optional<String>, name: Optional<String>, mimeType: Optional<String>, size: Optional<Int64>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var mimeType: Optional<String> { get { fatalError() } set { fatalError() } }
    public var name: Optional<String> { get { fatalError() } set { fatalError() } }
    public var size: Optional<Int64> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var url: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_FinishReason {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var reason: Optional<Tokengenerationcore_Wireformat_ReasonEnum> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_GuidedGenerationRequestParameters {
    public init() { fatalError() }
    public init(constraints: Optional<Tokengenerationcore_Wireformat_Constraints>, toolChoice: Optional<Tokengenerationcore_Wireformat_ToolChoice>, thoughtBudget: Optional<Promptkit_Wireformat_ThoughtBudget>, tools: Array<Promptkit_Wireformat_ToolDefinition>) { fatalError() }
    public var constraints: Optional<Tokengenerationcore_Wireformat_Constraints> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var thoughtBudget: Optional<Promptkit_Wireformat_ThoughtBudget> { get { fatalError() } set { fatalError() } }
    public var toolChoice: Optional<Tokengenerationcore_Wireformat_ToolChoice> { get { fatalError() } set { fatalError() } }
    public var tools: Array<Promptkit_Wireformat_ToolDefinition> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ImageContent {
    public init() { fatalError() }
    public init(data: Optional<Data>) { fatalError() }
    public var data: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ModelInformation {
    public struct Asset {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
        public var version: Optional<String> { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public init(assets: Array<Tokengenerationcore_Wireformat_ModelInformation.Asset>, systemVersion: Optional<String>) { fatalError() }
    public var assets: Array<Tokengenerationcore_Wireformat_ModelInformation.Asset> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var systemVersion: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ModelInformationEvent {
    public init(responseIdentifier: Optional<String>, modelInformation: Optional<Tokengenerationcore_Wireformat_ModelInformation>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var modelInformation: Optional<Tokengenerationcore_Wireformat_ModelInformation> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_Moderation {
    public struct Category {
        public init(identifier: Optional<String>) { fatalError() }
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct CategoryProbabilityPair {
        public init(key: Optional<Tokengenerationcore_Wireformat_Moderation.Category>, value: Optional<Tokengenerationcore_Wireformat_Moderation.Probability>) { fatalError() }
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var key: Optional<Tokengenerationcore_Wireformat_Moderation.Category> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
        public var value: Optional<Tokengenerationcore_Wireformat_Moderation.Probability> { get { fatalError() } set { fatalError() } }
    }
    public struct Probability {
        public init(rawValue: Int) { fatalError() }
        public init() { fatalError() }
        public var rawValue: Int { get { fatalError() } }
    }
    public init() { fatalError() }
    public init(ratings: Array<Tokengenerationcore_Wireformat_Moderation.CategoryProbabilityPair>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var ratings: Array<Tokengenerationcore_Wireformat_Moderation.CategoryProbabilityPair> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_PrefixLookup {
    public init() { fatalError() }
    public init(tokenRankings: Array<Tokengenerationcore_Wireformat_TokenRanking>, characterSetLookups: Array<Tokengenerationcore_Wireformat_CharacterSetLookup>, prefixMappings: Array<Tokengenerationcore_Wireformat_PrefixMapping>) { fatalError() }
    public var characterSetLookups: Array<Tokengenerationcore_Wireformat_CharacterSetLookup> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var prefixMappings: Array<Tokengenerationcore_Wireformat_PrefixMapping> { get { fatalError() } set { fatalError() } }
    public var tokenRankings: Array<Tokengenerationcore_Wireformat_TokenRanking> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_PrefixLookupData {
    public init(tokenRanksForPrefix: Array<Tokengenerationcore_Wireformat_CharacterToIntArrayMapping>, startOfWordTokenRanksForPrefix: Array<Tokengenerationcore_Wireformat_CharacterToIntArrayMapping>, characterSetLookup: Optional<Tokengenerationcore_Wireformat_CharacterSetLookupData>, convertedVocabTokens: Array<String>, tokenPrefixesMissingStartOfWordPair: Optional<Data>, sortedTokenIds: Array<Int32>, tokenRanksForSorting: Array<Int32>, utf8CodePointToTokenIdlookup: Array<Tokengenerationcore_Wireformat_ByteToTokenIDMapping>, byteTokenIds: Array<Int32>) { fatalError() }
    public init() { fatalError() }
    public var byteTokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var characterSetLookup: Optional<Tokengenerationcore_Wireformat_CharacterSetLookupData> { get { fatalError() } set { fatalError() } }
    public var convertedVocabTokens: Array<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var sortedTokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var startOfWordTokenRanksForPrefix: Array<Tokengenerationcore_Wireformat_CharacterToIntArrayMapping> { get { fatalError() } set { fatalError() } }
    public var tokenPrefixesMissingStartOfWordPair: Optional<Data> { get { fatalError() } set { fatalError() } }
    public var tokenRanksForPrefix: Array<Tokengenerationcore_Wireformat_CharacterToIntArrayMapping> { get { fatalError() } set { fatalError() } }
    public var tokenRanksForSorting: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var utf8CodePointToTokenIdlookup: Array<Tokengenerationcore_Wireformat_ByteToTokenIDMapping> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_PrefixMapping {
    public init() { fatalError() }
    public init(prefix: Optional<String>, tokenIds: Array<Int32>, remainingStrings: Array<String>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var prefix: Optional<String> { get { fatalError() } set { fatalError() } }
    public var remainingStrings: Array<String> { get { fatalError() } set { fatalError() } }
    public var tokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_PromptCompletionEvent {
    public init() { fatalError() }
    public var eventType: Optional<Tokengenerationcore_Wireformat_EventTypeEnum> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_PromptCompletionResponse {
    public init() { fatalError() }
    public var candidates: Array<Tokengenerationcore_Wireformat_Candidate> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var meanTokenEntropy: Optional<Float> { get { fatalError() } set { fatalError() } }
    public var modelInformation: Optional<Tokengenerationcore_Wireformat_ModelInformation> { get { fatalError() } set { fatalError() } }
    public var promptModeration: Optional<Tokengenerationcore_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var renderedPrompt: Optional<Tokengenerationcore_Wireformat_PromptRendering> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var usage: Optional<Tokengenerationcore_Wireformat_Usage> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_PromptModerationEvent {
    public init() { fatalError() }
    public init(responseIdentifier: Optional<String>, moderation: Optional<Tokengenerationcore_Wireformat_Moderation>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var moderation: Optional<Tokengenerationcore_Wireformat_Moderation> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_PromptRendering {
    public struct Source {
        public init() { fatalError() }
        public init(identifier: Optional<String>, version: Optional<String>) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
        public var version: Optional<String> { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public init(source: Optional<Tokengenerationcore_Wireformat_PromptRendering.Source>, segments: Array<String>, renderedString: Optional<String>, originalPrompt: Optional<String>, tokenIds: Array<Int32>, userInfo: Dictionary<String, String>, detokenizedString: Optional<String>) { fatalError() }
    public var detokenizedString: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var originalPrompt: Optional<String> { get { fatalError() } set { fatalError() } }
    public var renderedString: Optional<String> { get { fatalError() } set { fatalError() } }
    public var segments: Array<String> { get { fatalError() } set { fatalError() } }
    public var source: Optional<Tokengenerationcore_Wireformat_PromptRendering.Source> { get { fatalError() } set { fatalError() } }
    public var tokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var userInfo: Dictionary<String, String> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ReasonEnum {
}

public struct Tokengenerationcore_Wireformat_RenderedPromptEvent {
    public init(responseIdentifier: Optional<String>, renderedPrompt: Optional<Tokengenerationcore_Wireformat_PromptRendering>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var renderedPrompt: Optional<Tokengenerationcore_Wireformat_PromptRendering> { get { fatalError() } set { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ResponseMetadataEvent {
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_Segment {
    public init() { fatalError() }
    public init(content: Optional<Tokengenerationcore_Wireformat_Content>) { fatalError() }
    public var content: Optional<Tokengenerationcore_Wireformat_Content> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_TextContent {
    public init(value: Optional<String>, annotations: Array<Tokengenerationcore_Wireformat_Annotation>) { fatalError() }
    public init() { fatalError() }
    public var annotations: Array<Tokengenerationcore_Wireformat_Annotation> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var value: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ThoughtContent {
    public init() { fatalError() }
    public init(identifier: Optional<String>, thoughts: Optional<Promptkit_Wireformat_Thoughts>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var thoughts: Optional<Promptkit_Wireformat_Thoughts> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_TokenRanking {
    public init() { fatalError() }
    public init(tokenID: Optional<Int32>, rank: Optional<Int32>) { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var rank: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var tokenID: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ToolChoice {
    public struct AllowedFunctions {
        public init() { fatalError() }
        public init(names: Array<String>) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var names: Array<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct Automatic {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct Function {
        public init() { fatalError() }
        public init(name: Optional<String>) { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var name: Optional<String> { get { fatalError() } set { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct None {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public struct Required {
        public init() { fatalError() }
        public var hashValue: Int { get { fatalError() } }
        public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var value: Optional<Tokengenerationcore_Wireformat_ValueEnum> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_URLCitation {
    public init(title: Optional<String>, url: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var title: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var url: Optional<String> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_Usage {
    public init() { fatalError() }
    public init(promptTokenCount: Optional<Int32>, completionTokenCount: Optional<Int32>, cachedTokenCount: Optional<Int32>, thoughtTokenCount: Optional<Int32>) { fatalError() }
    public var cachedTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var completionTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var promptTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var thoughtTokenCount: Optional<Int32> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_UsageEvent {
    public init(responseIdentifier: Optional<String>, usage: Optional<Tokengenerationcore_Wireformat_Usage>) { fatalError() }
    public init() { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var responseIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var usage: Optional<Tokengenerationcore_Wireformat_Usage> { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_UserAudioTranscription {
    public init(identifier: Optional<String>, content: Optional<String>) { fatalError() }
    public init() { fatalError() }
    public var content: Optional<String> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var identifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
}

public struct Tokengenerationcore_Wireformat_ValueEnum {
}

public struct Tokengenerationcore_Wireformat_VocabularyManagerCache {
    public init(cacheKey: Optional<String>, tokenizerIdentifier: Optional<String>, stopTokenIds: Array<Int32>, createdAt: Optional<Double>, version: Optional<Int32>, prefixLookup: Optional<Tokengenerationcore_Wireformat_PrefixLookupData>) { fatalError() }
    public init() { fatalError() }
    public var cacheKey: Optional<String> { get { fatalError() } set { fatalError() } }
    public var createdAt: Optional<Double> { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var prefixLookup: Optional<Tokengenerationcore_Wireformat_PrefixLookupData> { get { fatalError() } set { fatalError() } }
    public var stopTokenIds: Array<Int32> { get { fatalError() } set { fatalError() } }
    public var tokenizerIdentifier: Optional<String> { get { fatalError() } set { fatalError() } }
    public var unknownFields: InternalSwiftProtobuf.UnknownStorage { get { fatalError() } set { fatalError() } }
    public var version: Optional<Int32> { get { fatalError() } set { fatalError() } }
}

public struct TokenizationResult {
    public var description: String { get { fatalError() } }
}

public protocol TokenizerAwareGrammarRecognizer {
    var partialMatch: Bool { get }
    func childRecognizer(consumingTokenID: Int) -> A
    func accepts(tokenIDs: Array<Int>) async -> Array<Int>
    var fullMatch: Bool { get }
    func accepts(tokenID: Int) async -> Bool
}

public class TokenizerRunner {
    public init(tokenizerPath: String, usePortableLocaleMatching: Optional<Bool>) throws { fatalError() }
    public init(tokenizerPath: String, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion, usePortableLocaleMatching: Optional<Bool>) throws { fatalError() }
    public init(tokenizerPath: String) throws { fatalError() }
    public init(tokenizerPath: String, substitutionTextForInputTokenText: Dictionary<String, String>) throws { fatalError() }
    public init() { fatalError() }
    public func detokenize(_: Array<Int>) throws -> String { fatalError() }
    public func tokenize(promptModules: Array<PromptModule>, tokenTable: Dictionary<Prompt.SpecialToken, Any>, shouldInsertEmbeddingStartEndTokens: Bool, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion) throws -> Array<TokenizedPromptModule> { fatalError() }
    public func vocabulary() -> Array<String> { fatalError() }
    public func tokenizeCacheablePromptTemplatePrefix(promptTemplateString: String, locale: Optional<Locale>, tokenTable: Dictionary<SpecialToken, Any>, localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>>, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion) throws -> TokenizedStaticPromptTemplatePrefix { fatalError() }
    public func prefixTokenIDs(forPrefix: String) -> Array<(Int, String)> { fatalError() }
    public func tokenIDs(forRawPrefix: String) -> Array<(Int, String)> { fatalError() }
    public func tokenize(promptModules: Array<PromptModule>, tokenTable: Dictionary<Prompt.SpecialToken, Any>, attachmentTokenizer: Optional<AttachmentTokenizer>, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion) async throws -> Array<TokenizedPromptModule> { fatalError() }
    public func text(forTokenID: Int) -> String { fatalError() }
    public func tokenIDs(forDecodedPrefix: String) -> Array<(Int, String)> { fatalError() }
    public func tokenize(modularPromptFragment: String, promptTemplateProcessingVersion: PromptPreprocessingTemplateVersion) throws -> Array<Int> { fatalError() }
    public var longestTokenLength: Int { get { fatalError() } }
    public func tokenizeModularPrompt(prompt: Prompt, tokenTable: Dictionary<Prompt.SpecialToken, Any>, localizationOverrideMap: Dictionary<Prompt.SpecialToken, Dictionary<String, String>>, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion) throws -> Array<TokenizedPromptModule> { fatalError() }
    public func tokenizeModularPrompt(prompt: PromptRequest, with: PromptTokenizationMetadata, tokenTableOverride: Dictionary<SpecialToken, Any>, localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>>, attachmentTokenizer: AttachmentTokenizer) async throws -> Array<TokenizedPromptModule> { fatalError() }
    public func tokenizeModularPrompt(prompt: PromptRequest, with: PromptTokenizationMetadata, shouldInsertEmbeddingStartEndTokens: Bool) throws -> Array<TokenizedPromptModule> { fatalError() }
    public var vocabularyCount: Int { get { fatalError() } }
    public func tokenizeModularPrompt(prompt: Prompt, tokenTable: Dictionary<Prompt.SpecialToken, Any>, localizationOverrideMap: Dictionary<Prompt.SpecialToken, Dictionary<String, String>>) throws -> Array<TokenizedPromptModule> { fatalError() }
    public func tokenize(prompt: Prompt, tokenTable: Dictionary<Prompt.SpecialToken, Any>) throws -> Array<Int> { fatalError() }
    public func tokenizeModularPrompt(prompt: PromptRequest, tokenTable: Dictionary<SpecialToken, Any>, localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>>, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion) throws -> Array<TokenizedPromptModule> { fatalError() }
    public func tokenizeCacheableSystemPrefix(locale: Optional<Locale>, tokenTable: Dictionary<SpecialToken, Any>, localizationOverrideMap: Dictionary<SpecialToken, Dictionary<String, String>>, promptPreprocessingTemplateVersion: PromptPreprocessingTemplateVersion) throws -> TokenizedStaticPromptTemplatePrefix { fatalError() }
    public func tokenizeModularPrompt(prompt: PromptRequest, with: PromptTokenizationMetadata) throws -> Array<TokenizedPromptModule> { fatalError() }
    public func tokenize(_: String) throws -> Array<Int> { fatalError() }
    public func tokenize(prompt: Prompt, tokenTable: Dictionary<Prompt.SpecialToken, Any>, localizationOverrideMap: Dictionary<Prompt.SpecialToken, Dictionary<String, String>>) throws -> Array<Int> { fatalError() }
    public func isByte(tokenID: Int) -> Bool { fatalError() }
    public func tokenID(forText: String) -> Int { fatalError() }
}

public struct TokenizerRunnerSentencePieceModel {
    public init(modelPath: String) throws { fatalError() }
    public func prefixTokenIDs(forPrefix: String) -> Array<(Int, String)> { fatalError() }
    public func tokenIDs(forRawPrefix: String) -> Array<(Int, String)> { fatalError() }
    public func vocabulary() -> Array<String> { fatalError() }
    public func detokenize(tokenIDs: Array<Int>) throws -> String { fatalError() }
    public func isByte(tokenID: Int) -> Bool { fatalError() }
    public func tokenIDs(forDecodedPrefix: String) -> Array<(Int, String)> { fatalError() }
    public func tokenID(forText: String) -> Int { fatalError() }
    public var longestTokenLength: Int { get { fatalError() } }
    public func text(forTokenID: Int) -> String { fatalError() }
    public var vocabularyCount: Int { get { fatalError() } }
    public func tokenize(text: String) throws -> Optional<Array<Int>> { fatalError() }
    public func tokenizeParallel(text: String) throws -> Optional<Array<Int>> { fatalError() }
}

public protocol TokenizerRunnerTokenizer {
    func detokenize(tokenIDs: Array<Int>) throws -> String
    func tokenIDs(forDecodedPrefix: String) -> Array<(Int, String)>
    var longestTokenLength: Int { get }
    func tokenize(text: String) throws -> Optional<Array<Int>>
    func isByte(tokenID: Int) -> Bool
    var vocabularyCount: Int { get }
    func text(forTokenID: Int) -> String
    func tokenIDs(forRawPrefix: String) -> Array<(Int, String)>
    func tokenID(forText: String) -> Int
    func prefixTokenIDs(forPrefix: String) -> Array<(Int, String)>
    func tokenizeParallel(text: String) throws -> Optional<Array<Int>>
    func vocabulary() -> Array<String>
}

public struct Tool {
    public init(_: () throws -> Prompt) throws { fatalError() }
    public init(_: () async throws -> Prompt) async throws { fatalError() }
    public init(_: Prompt) { fatalError() }
    public var prompt: Prompt { get { fatalError() } }
    public func toChatMessagePrompt() -> ChatMessagePrompt { fatalError() }
}

public struct ToolAwareGuidedGenerationConstraints {
    public init(tools: Optional<Array<GenerativeFunctionsTool.Function>>, toolsVersion: PromptPreprocessingTemplateVersion, toolChoice: GenerativeFunctionsToolChoice, outputGrammar: Optional<Grammar>, vocabularyManager: GuidedGenerationVocabularyManager, enableDeterministicTokenRuns: Bool, numberOfParallelTasks: Int) throws { fatalError() }
    public init(tools: Optional<Array<GenerativeFunctionsTool.Function>>, toolsVersion: PromptPreprocessingTemplateVersion, toolChoice: GenerativeFunctionsToolChoice, outputGrammar: Optional<Grammar>, vocabularyManager: GuidedGenerationVocabularyManager, enableDeterministicTokenRuns: Bool, numberOfParallelTasks: Int, thoughtBudget: ThoughtBudget) throws { fatalError() }
    public var vocabularyCount: Int { get { fatalError() } }
    public func possiblyDeterministicTokens(atConstraintState: Int) throws -> Bool { fatalError() }
    public func advanceConstraintState(_: Int, consumingToken: Int) -> Int { fatalError() }
    public func validateTokens(from: Array<Int>, candidateTokenIDs: Array<Int>) async throws -> Optional<Int> { fatalError() }
    public func validate(tokenIDs: Array<Int>) throws -> MatchResult { fatalError() }
    public func generateNextTokenIDMask(atConstraintState: Int) async throws -> TokenIDMaskResponse { fatalError() }
    public func possiblyDeterministicTokens(follow: Array<Int>) throws -> Bool { fatalError() }
    public func generateNextTokenIDMask(from: Array<Int>) throws -> TokenIDMaskResponse { fatalError() }
}

public protocol ToolCallConverter {
    func consume(_: String) -> String
}

public struct ToolCallParser {
    public struct FunctionDelta {
        public init(toolCallID: String, name: String, arguments: String) { fatalError() }
        public init(toolCallDelta: Prompt.ToolCall) { fatalError() }
        public var arguments: String { get { fatalError() } set { fatalError() } }
        public var name: String { get { fatalError() } set { fatalError() } }
        public var toolCallID: String { get { fatalError() } set { fatalError() } }
    }
    public init(version: PromptPreprocessingTemplateVersion) { fatalError() }
    public var isToolCallInProgress: Bool { get { fatalError() } }
    public func consume(string: String) -> Array<ToolCallParser.FunctionDelta> { fatalError() }
}

public struct ToolChoiceEnvelope {
    public init(sealing: GenerativeFunctionsToolChoice) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func unseal() -> GenerativeFunctionsToolChoice { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ToolDefinition18446744073709550616 {
}

public struct ToolDescriptionEnvelope {
    public init(sealing: ToolDescription) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public func unseal() -> ToolDescription { fatalError() }
}

public protocol ToolRendering {
    func render(toolResult: Prompt.ToolCallResult, toolCallIdToToolCall: Dictionary<String, Prompt.ToolCall>) throws -> Array<Prompt.Turn.Segment>
    func render(functionCalls: Array<Prompt.ToolCall.Function>) -> String
    func render(tools: Array<GenerativeFunctionsTool>) throws -> ToolRenderingResult
}

public struct ToolRenderingResult {
}

public struct ToolResultEnvelope {
    public init(from: Decoder) throws { fatalError() }
    public init(sealing: Prompt.ToolResult, xpcData: inout Optional<XPC.XPCDictionary>) { fatalError() }
    public func unseal(_: Optional<XPC.XPCDictionary>) -> Prompt.ToolResult { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public struct ToolType {
    public var hashValue: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct ToolType18446744073709550616 {
}

public struct Usage {
    public init(cachedTokenCount: Int, promptTokenCount: Int, completionTokenCount: Int) { fatalError() }
    public init(cachedTokenCount: Int, thoughtTokenCount: Int, promptTokenCount: Int, completionTokenCount: Int) { fatalError() }
    public init(promptTokenCount: Int, completionTokenCount: Int) { fatalError() }
    public var cachedTokenCount: Int { get { fatalError() } set { fatalError() } }
    public var completionTokenCount: Int { get { fatalError() } set { fatalError() } }
    public var hashValue: Int { get { fatalError() } }
    public var promptTokenCount: Int { get { fatalError() } set { fatalError() } }
    public var thoughtTokenCount: Int { get { fatalError() } set { fatalError() } }
    public var totalTokenCount: Int { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct Usage18446744073709550616 {
}

public protocol UsecaseConfigurationProtocol {
    func samplingParameters(for: String) -> Optional<SamplingParameters>
    func tools(for: String) -> Optional<Array<ToolDescription>>
}

public struct User {
    public init(_: () async throws -> Prompt) async throws { fatalError() }
    public init(_: () throws -> Prompt) throws { fatalError() }
    public init(_: Prompt) { fatalError() }
    public func toChatMessagePrompt() -> ChatMessagePrompt { fatalError() }
    public func locale(_: Optional<Locale>) -> ChatMessagePrompt { fatalError() }
    public var prompt: Prompt { get { fatalError() } }
    public var responseFormat: Optional<ResponseFormat> { get { fatalError() } set { fatalError() } }
    public var toolDefinitions: Optional<Array<GenerativeFunctionsToolDefinition>> { get { fatalError() } set { fatalError() } }
}

public struct ValidationResult {
    public var acceptedScalars: Array<Unicode.Scalar> { get { fatalError() } }
    public var match: MatchResult { get { fatalError() } }
}

public class VocabularyManager {
    public struct PrefixLookup {
        public init(_: Tokengenerationcore_Wireformat_PrefixLookupData) throws { fatalError() }
        public var wireFormat: Tokengenerationcore_Wireformat_PrefixLookupData { get { fatalError() } }
    }
}

public struct Voice {
    public init(from: Decoder) throws { fatalError() }
    public init(name: String) { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var name: String { get { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
}

public struct WebSearchParameters {
    public init() { fatalError() }
    public init(locale: Optional<Locale>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public var locale: Optional<Locale> { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
}

public protocol WireFormatType {
}

public struct WriteDataRequest {
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var accessGroup: GenerativeModelsAccessGroup { get { fatalError() } }
    public var auditID: Optional<UInt32> { get { fatalError() } }
    public var data: Data { get { fatalError() } }
    public var key: String { get { fatalError() } }
    public var securityLevel: GenerativeModelsSecurityLevel { get { fatalError() } }
}

public protocol XPCRevivable {
    func revive(withXpcData: XPC.XPCDictionary) -> ()
    var xpcData: XPC.XPCDictionary { get }
}

public protocol _ClientInfoProtocol {
    var _model: TokenGenerator { get }
    var trackingConfig: _ClientInfoSessionTrackingConfig { get set }
    var useCaseIdentifier: String { get }
}

public struct _ClientInfoSessionTrackingConfig {
    public init(sessionTrackingConifg: Dictionary<String, String>, _internalSessionTrackingConfig: Dictionary<String, String>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public func encode(to: Encoder) throws -> () { fatalError() }
    public var _internalSessionTrackingConfig: Dictionary<String, String> { get { fatalError() } set { fatalError() } }
    public func hash(into: inout Hasher) -> () { fatalError() }
    public var hashValue: Int { get { fatalError() } }
    public static func ==(_: _ClientInfoSessionTrackingConfig, _: _ClientInfoSessionTrackingConfig) -> Bool { fatalError() }
    public var sessionTrackingConifg: Dictionary<String, String> { get { fatalError() } set { fatalError() } }
}

public struct _GenerativeModelOverrideHelpers {
    public static func _generativeFunctionOverridesCompletionPrompt(_: String) async throws -> Optional<_GenerativeFunctionOverridableInternals_CompletionPrompt> { fatalError() }
    public static func _generativeFunctionOverridesChatMessagesPrompt(_: String) async throws -> Optional<_GenerativeFunctionOverridableInternals_ChatMessagesPrompt> { fatalError() }
}

public class _LoadedModelConfiguration {
    public struct AssetInformation {
        public init(identifier: String, version: String) { fatalError() }
        public var identifier: String { get { fatalError() } }
        public var version: String { get { fatalError() } }
    }
    public init(promptTemplates: Optional<Dictionary<String, ModelConfigurationPromptTemplate>>, speculativeDecodingDraftTokenCount: Optional<Int>, assetInformation: Optional<_LoadedModelConfiguration.AssetInformation>) { fatalError() }
    public init(from: Decoder) throws { fatalError() }
    public var assetInformation: Optional<_LoadedModelConfiguration.AssetInformation> { get { fatalError() } set { fatalError() } }
    public var promptTemplates: Optional<Dictionary<String, ModelConfigurationPromptTemplate>> { get { fatalError() } }
    public var speculativeDecodingDraftTokenCount: Optional<Int> { get { fatalError() } }
}

public struct _OverrideConfigurationHelper {
    public static func grammar(_: String) -> String { fatalError() }
    public static func grammarIdentifier(_: OverrideHint<String>) -> String { fatalError() }
    public static func draftCache(_: OverrideHint<Array<String>>) -> Array<String> { fatalError() }
    public static func responseSanitizer(_: OverrideHint<StringResponseSanitizer>) -> StringResponseSanitizer { fatalError() }
    public static func samplingParameters(_: OverrideHint<SamplingParameters>) -> SamplingParameters { fatalError() }
    public static func schemaIdentifier(_: OverrideHint<String>) -> String { fatalError() }
    public static func samplingParameters(_: SamplingParameters) -> SamplingParameters { fatalError() }
    public static func renderedPromptSanitizer(_: StringRenderedPromptSanitizer) -> StringRenderedPromptSanitizer { fatalError() }
    public static func renderedPromptSanitizer(_: OverrideHint<StringRenderedPromptSanitizer>) -> StringRenderedPromptSanitizer { fatalError() }
    public static func partialGrammar(_: OverrideHint<String>) -> String { fatalError() }
    public static func grammar(_: OverrideHint<String>) -> String { fatalError() }
    public static func draftCache(_: Array<String>) -> Array<String> { fatalError() }
    public static func responseSanitizer(_: StringResponseSanitizer) -> StringResponseSanitizer { fatalError() }
}

extension AnyGenerationGuides: Equatable { public static func == (lhs: AnyGenerationGuides, rhs: AnyGenerationGuides) -> Bool { fatalError() } }
extension AvailabilityClient: Equatable { public static func == (lhs: AvailabilityClient, rhs: AvailabilityClient) -> Bool { fatalError() } }
extension AvailabilityFoundationClient: Equatable { public static func == (lhs: AvailabilityFoundationClient, rhs: AvailabilityFoundationClient) -> Bool { fatalError() } }
extension AvailabilityInternalClient: Equatable { public static func == (lhs: AvailabilityInternalClient, rhs: AvailabilityInternalClient) -> Bool { fatalError() } }
extension AvailabilityNotificationObservation: Equatable { public static func == (lhs: AvailabilityNotificationObservation, rhs: AvailabilityNotificationObservation) -> Bool { fatalError() } }
extension CachedSafetyModelsWrapper: Equatable { public static func == (lhs: CachedSafetyModelsWrapper, rhs: CachedSafetyModelsWrapper) -> Bool { fatalError() } }
extension ClassificationGenerator: Equatable { public static func == (lhs: ClassificationGenerator, rhs: ClassificationGenerator) -> Bool { fatalError() } }
extension EarleyRecognizer: Equatable { public static func == (lhs: EarleyRecognizer, rhs: EarleyRecognizer) -> Bool { fatalError() } }
extension EmbeddingGenerator: Equatable { public static func == (lhs: EmbeddingGenerator, rhs: EmbeddingGenerator) -> Bool { fatalError() } }
extension FailureTrackingClientProvider: Equatable { public static func == (lhs: FailureTrackingClientProvider, rhs: FailureTrackingClientProvider) -> Bool { fatalError() } }
extension FoundationModelsExtensionInfo: Equatable { public static func == (lhs: FoundationModelsExtensionInfo, rhs: FoundationModelsExtensionInfo) -> Bool { fatalError() } }
public struct GenerativeConfigurationProtocol_PromptType {
}

extension GenerativeModelsAvailability.Notifications: Equatable { public static func == (lhs: GenerativeModelsAvailability.Notifications, rhs: GenerativeModelsAvailability.Notifications) -> Bool { fatalError() } }
public struct GrammarRecognizer_RecognizerCache {
}

extension LanguageRecognizerCachableModel: Equatable { public static func == (lhs: LanguageRecognizerCachableModel, rhs: LanguageRecognizerCachableModel) -> Bool { fatalError() } }
extension Measurement: Equatable { public static func == (lhs: Measurement, rhs: Measurement) -> Bool { fatalError() } }
extension MetricAggregator: Equatable { public static func == (lhs: MetricAggregator, rhs: MetricAggregator) -> Bool { fatalError() } }
extension ModelCache: Equatable { public static func == (lhs: ModelCache, rhs: ModelCache) -> Bool { fatalError() } }
public struct CachableModel_ModelConfiguration {
}

extension ModelManagerSessionWrapper: Equatable { public static func == (lhs: ModelManagerSessionWrapper, rhs: ModelManagerSessionWrapper) -> Bool { fatalError() } }
extension PerfdataWriter: Equatable { public static func == (lhs: PerfdataWriter, rhs: PerfdataWriter) -> Bool { fatalError() } }
public struct PromptComponentValueCustomDataTransformer_CustomDataType {
}

public struct PromptMode_PromptContentType {
}

public struct PromptRetrieverProtocol_RetrievedResult {
}

public struct RenderedPromptSanitizerRunnerProtocol_Content {
}

public struct RenderedPromptSanitizerRunnerProtocol_RunnerConfiguration {
}

public struct RenderedPromptSanitizerRunnerProtocol_Sanitizer {
}

public struct ResponseSanitizerRunnerProtocol_Content {
}

public struct ResponseSanitizerRunnerProtocol_RunnerConfiguration {
}

public struct ResponseSanitizerRunnerProtocol_Sanitizer {
}

extension SafetyConfigurationOutputReader: Equatable { public static func == (lhs: SafetyConfigurationOutputReader, rhs: SafetyConfigurationOutputReader) -> Bool { fatalError() } }
extension SafetySettingProvider: Equatable { public static func == (lhs: SafetySettingProvider, rhs: SafetySettingProvider) -> Bool { fatalError() } }
extension TokenGenerator: Equatable { public static func == (lhs: TokenGenerator, rhs: TokenGenerator) -> Bool { fatalError() } }
extension TokenIDToTextConverter: Equatable { public static func == (lhs: TokenIDToTextConverter, rhs: TokenIDToTextConverter) -> Bool { fatalError() } }
extension TokenizerRunner: Equatable { public static func == (lhs: TokenizerRunner, rhs: TokenizerRunner) -> Bool { fatalError() } }
extension VocabularyManager: Equatable { public static func == (lhs: VocabularyManager, rhs: VocabularyManager) -> Bool { fatalError() } }
extension _LoadedModelConfiguration: Equatable { public static func == (lhs: _LoadedModelConfiguration, rhs: _LoadedModelConfiguration) -> Bool { fatalError() } }
extension _LoadedUseCaseConfigurations: Equatable { public static func == (lhs: _LoadedUseCaseConfigurations, rhs: _LoadedUseCaseConfigurations) -> Bool { fatalError() } }
extension _UseCaseConfiguration: Equatable { public static func == (lhs: _UseCaseConfiguration, rhs: _UseCaseConfiguration) -> Bool { fatalError() } }


