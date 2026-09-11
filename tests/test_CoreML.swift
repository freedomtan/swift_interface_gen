import CoreML
import CoreVideo
import Foundation
import Metal
// --- ObjC Extension (bridge-header required) ---
extension CoreMLModelSecurityServiceToClient {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension CoreMLVersion {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleAudioFeatureExtractor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleAudioFeatureExtractorParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleAudioFeatureExtractorSoundPrintParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleGazetteer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleGazetteerParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleImageFeatureExtractor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleImageFeatureExtractorObjectPrintParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleImageFeatureExtractorParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleImageFeatureExtractorScenePrintParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleSoundAnalysisPreprocessing {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleTextClassifier {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleTextClassifierParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleWordEmbedding {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleWordEmbeddingParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleWordTagger {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLAppleWordTaggerParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLArchivingUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLArrayBatchProvider {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLArrayDictionaryFeatureProvider {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLArrayFeatureExtractor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLBackgroundPredictionTask {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLBackgroundTask {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLBatchProviderUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLBayesianProbitRegression {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLCPUComputeDevice {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLCategoricalMapping {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLClassConfidenceThresholding {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLClassifier {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLClassifierResult {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLCloudDeploymentUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLCompiler {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLCompilerOptions {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLCompilerResult {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLComputeBatchDataSource {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLComputeDataSource {
}
// --- End ObjC Extension ---
public enum MLComputeDevice: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
    case cpu(_: MLCPUComputeDevice)
    case gpu(_: MLGPUComputeDevice)
    case neuralEngine(_: MLNeuralEngineComputeDevice)
    public init(device: MLComputeDeviceProtocol) { fatalError() }
    public func hash(into: inout Hasher) -> () {}
    public var description: Swift.String { get { fatalError() } }
    public var hashValue: Swift.Int { get { fatalError() } }
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public static var allComputeDevices: [MLComputeDevice] { get { return [] } }
    public var underlyingDevice: MLComputeDeviceProtocol { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
}
public enum MLComputeError: Codable, Error, Hashable, @unchecked Sendable {
    case computeDeviceUnavailable
    case missingFunciton(_: Swift.String)
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLComputeError, _ rhs: MLComputeError) -> Bool { fatalError() }
}
public struct MLComputeFunction: Codable, Hashable, @unchecked Sendable {
    public init(metalSource: Swift.String, name: Swift.String?) throws { fatalError() }
    public init(library: MLComputeLibrary, name: Swift.String) throws { fatalError() }
    public func callAsFunction(_: repeat Any, outputs: MLTensor.Descriptor..., executionPolicy: MLComputeFunction.ExecutionPolicy) -> [MLTensor] where Any: ArgumentRepresentable { return [] }
    public func callAsFunction(_: repeat Any, output: MLTensor.Descriptor, executionPolicy: MLComputeFunction.ExecutionPolicy) -> MLTensor where Any: ArgumentRepresentable { fatalError() }
    public func callAsFunction(_: repeat Any, executionPolicy: MLComputeFunction.ExecutionPolicy) -> () where Any: ArgumentRepresentable {}
    public func callAsFunction(_: repeat Any, outputs: [MLTensor.Descriptor], executionPolicy: MLComputeFunction.ExecutionPolicy) -> [MLTensor] where Any: ArgumentRepresentable { return [] }
    public struct Argument: Codable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, MLComputeFunction.ArgumentRepresentable, @unchecked Sendable {
        public init(_ arg1: [Swift.Float]) { fatalError() }
        public init(floatLiteral: Swift.Float) { fatalError() }
        public init(_ arg1: [Swift.Float16]) { fatalError() }
        public init(_ arg1: Swift.Int32) { fatalError() }
        public init(_: MTLTexture, sharedEvent: MTLSharedEvent, completionValue: UInt64) { fatalError() }
        public init(_ arg1: [Swift.Int32]) { fatalError() }
        public init(_ arg1: Swift.Float) { fatalError() }
        public init(_ arg1: Swift.Float16) { fatalError() }
        public init(_ arg1: MLTensor) { fatalError() }
        public init(integerLiteral: Swift.Int32) { fatalError() }
        public init(_ arg1: MTLBuffer) { fatalError() }
        public init(_: MTLBuffer, sharedEvent: MTLSharedEvent, completionValue: UInt64) { fatalError() }
        public init(_ arg1: MTLTexture) { fatalError() }
        public var computeFunctionArgument: Argument { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Argument, _ rhs: Argument) -> Bool { fatalError() }
    }
    public protocol ArgumentRepresentable: Sendable {
        var computeFunctionArgument: MLComputeFunction.Argument { get }
    }
    public struct ExecutionPolicy: Codable, Hashable, @unchecked Sendable {
        public init(threadsPerGrid: Swift.Int, threadsPerThreadgroup: Swift.Int) { fatalError() }
        public init(_ arg1: @escaping @Sendable ([MLTensor.Descriptor], [MLTensor.Descriptor], MTLComputePipelineState) -> (threadsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize)) { fatalError() }
        public init(threadsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize) { fatalError() }
        public static var `default`: ExecutionPolicy { get { fatalError() } }
        public static var linearSplit: ExecutionPolicy { get { fatalError() } }
        public static var ndLinearSplit: ExecutionPolicy { get { fatalError() } }
        public static var spatialSplit: ExecutionPolicy { get { fatalError() } }
        public static func custom(_ arg1: @escaping @Sendable ([MLTensor.Descriptor], [MLTensor.Descriptor], MTLComputePipelineState) -> (threadsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize)) -> ExecutionPolicy { fatalError() }
        public static func custom(threadsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize) -> ExecutionPolicy { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ExecutionPolicy, _ rhs: ExecutionPolicy) -> Bool { fatalError() }
    }
    public protocol ScalarArgumentRepresentable: MLComputeFunction.ArgumentRepresentable, MLTensorScalar, Sendable {
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLComputeFunction, _ rhs: MLComputeFunction) -> Bool { fatalError() }
}
public struct MLComputeLibrary: Codable, Hashable, @unchecked Sendable {
    public init(metalSource: Swift.String) throws { fatalError() }
    public init(contentsOf: URL) throws { fatalError() }
    public static var `default`: MLComputeLibrary { get { fatalError() } }
    public subscript(dynamicMember arg1: Swift.String) -> MLComputeFunction { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLComputeLibrary, _ rhs: MLComputeLibrary) -> Bool { fatalError() }
}
// --- ObjC Extension (bridge-header required) ---
extension MLComputePlan {
    public static func load(asset: MLModelAsset, configuration: MLModelConfiguration) async throws -> MLComputePlan { fatalError() }
    public final var modelStructure: MLModelStructure { get { fatalError() } }
    public func estimatedCost(of: MLModelStructure.Program.Operation) -> MLComputePlan.Cost? { return nil }
    public func deviceUsage(for: MLModelStructure.NeuralNetwork.Layer) -> MLComputePlan.DeviceUsage? { return nil }
    public static func load(contentsOf: URL, configuration: MLModelConfiguration) async throws -> MLComputePlan { fatalError() }
    public func deviceUsage(for: MLModelStructure.Program.Operation) -> MLComputePlan.DeviceUsage? { return nil }
    public struct Cost: Codable, Hashable, @unchecked Sendable {
        public var weight: Swift.Double { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Cost, _ rhs: Cost) -> Bool { fatalError() }
    }
    public struct DeviceUsage: Codable, Hashable, @unchecked Sendable {
        public var preferred: MLComputeDevice { get { fatalError() } }
        public func supportState(for: MLComputeDevice) -> SupportState? { return nil }
        public var supported: [MLComputeDevice] { get { return [] } }
        public struct Reason: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            public var hashValue: Swift.Int { get { fatalError() } }
            public func hash(into: inout Hasher) -> () {}
            public var category: Category { get { fatalError() } }
            public var description: Swift.String { get { fatalError() } }
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public enum Category: Int, Codable, CustomStringConvertible, Hashable, RawRepresentable, @unchecked Sendable {
                case liveTensorMemoryFootprintExceededLimit
                case missingAttribute
                case unsupported
                case unsupportedAttribute
                case unsupportedAttributeAxis
                case unsupportedAttributeKernel
                case unsupportedAttributePadding
                case unsupportedInput
                case unsupportedInputDataType
                case unsupportedInputShape
                case unsupportedInputValue
                case unsupportedOperation
                case unsupportedOutput
                case unsupportedOutputDataType
                case unsupportedOutputShape
                case unsupportedOutputValue
                case weightFileSizeExceededLimit
                public init?(rawValue: Swift.Int) { fatalError() }
                public var description: Swift.String { get { fatalError() } }
                public init(from decoder: any Swift.Decoder) throws { fatalError() }
                public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                public func hash(into hasher: inout Hasher) { fatalError() }
                public static func ==(_ lhs: Category, _ rhs: Category) -> Bool { fatalError() }
            }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public enum SupportState: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            case supported
            case unsupported(_: MLComputePlan.DeviceUsage.Reason)
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public func hash(into: inout Hasher) -> () {}
            public var description: Swift.String { get { fatalError() } }
            public var hashValue: Swift.Int { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DeviceUsage, _ rhs: DeviceUsage) -> Bool { fatalError() }
    }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLComputePlanCost {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLComputePlanDeviceUsage {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLComputePlanDeviceUsageSupportInfo {
}
// --- End ObjC Extension ---
public struct MLComputePolicy: Codable, CustomReflectable, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init?(_ arg1: MLGPUComputeDevice) { fatalError() }
    public init(_ arg1: MLCPUComputeDevice) { fatalError() }
    public init(_ arg1: MLComputeUnits) { fatalError() }
    public static func specific(_ arg1: MLCPUComputeDevice) -> MLComputePolicy { fatalError() }
    public static var cpuOnly: MLComputePolicy { get { fatalError() } }
    public static var current: MLComputePolicy { get { fatalError() } }
    public var customMirror: Mirror { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var hashValue: Swift.Int { get { fatalError() } }
    public static func specific(_ arg1: MLGPUComputeDevice) -> MLComputePolicy? { return nil }
    public static var cpuAndGPU: MLComputePolicy { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
}
// --- ObjC Extension (bridge-header required) ---
extension MLCustomModelLoader {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLDefaultCustomLayerFactory {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLDictVectorizer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLDictionaryConstraint {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLDictionaryFeatureProvider {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLE5Engine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFairPlayDecryptSession {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFairPlayDecryptSessionManager {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFairPlayKeyLoadingSession {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFeatureDescription {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFeatureFlags {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFeatureProviderUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFeatureTypeUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFeatureValue {
    @nonobjc public convenience init<A>(shapedArray: MLShapedArray<A>) where A: MLShapedArrayScalar { fatalError() }
    @nonobjc public convenience init(_ arg1: MLSendableFeatureValue) { fatalError() }
    public final func shapedArrayValue<GenericA>(of: GenericA.Type) -> MLShapedArray<GenericA>? where GenericA: MLShapedArrayScalar { return nil }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLFeatureVectorizer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLGKDecisionTree {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLGLMClassification {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLGLMRegression {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLGPUComputeDevice {
}
// --- End ObjC Extension ---
public struct MLIRRepresentation: Codable, Hashable, @unchecked Sendable {
    public init?(of: MLModel) { fatalError() }
    public var sourceIR: Data { get { return Data() } }
    public func executionIRs(for: MLPredictionPlan) async throws -> [Data] { return [] }
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
// --- ObjC Extension (bridge-header required) ---
extension MLIdentity {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLImageConstraint {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLImageSize {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLImageSizeConstraint {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLImputer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLInferenceFrameDataSerialization {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLInternalSettings {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLItemSimilarityRecommender {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLKNearestNeighborsClassifier {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLKey {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLKeyManager {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLLayerExecutionSchedule {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLLayerPath {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLLinkedModel {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLLoader {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLLocalOutlierFactor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLLogging {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMetricKey {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModel {
    public final func prediction(from: MLFeatureProvider, options: MLPredictionOptions) async throws -> MLFeatureProvider { fatalError() }
    public final func makeState() -> MLState { fatalError() }
    public final func newState() -> MLState { fatalError() }
    public final func prediction(from: MLFeatureProvider, using: MLState, options: MLPredictionOptions) async throws -> MLFeatureProvider { fatalError() }
    public static func compileModel(at: URL, completionHandler: @escaping (Result<URL, any Error>) -> ()) -> () {}
    public final func predictions(fromBatch: MLBatchProvider, options: MLPredictionOptions) throws -> MLBatchProvider { fatalError() }
    public final func prediction(from: [Swift.String : MLTensor], using: MLState) async throws -> [Swift.String : MLTensor] { return [:] }
    public static func load(contentsOf: URL, configuration: MLModelConfiguration, completionHandler: @escaping (Result<MLModel, any Error>) -> ()) -> () {}
    public final func prediction(fromFeatures: MLFeatureProvider, options: MLPredictionOptions) throws -> MLFeatureProvider { fatalError() }
    public static func compileModel(at: URL) async throws -> URL { fatalError() }
    public final func prediction(from: [Swift.String : MLTensor]) async throws -> [Swift.String : MLTensor] { return [:] }
    public static func load(contentsOf: URL, configuration: MLModelConfiguration) async throws -> MLModel { fatalError() }
    public static var availableComputeDevices: [MLComputeDevice] { get { return [] } }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelAsset {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelConfiguration {
    public final var optimizationHints: MLOptimizationHints { get { fatalError() } set {} }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelDescription {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelEncryptionUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelErrorUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelExecutionSchedule {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelIOUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelMetadata {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructure {
    case neuralNetwork(_: MLModelStructure.NeuralNetwork)
    case pipeline(_: MLModelStructure.Pipeline)
    case program(_: MLModelStructure.Program)
    case unsupported
    public static func load(asset: MLModelAsset) async throws -> MLModelStructure { fatalError() }
    public static func load(contentsOf: URL) async throws -> MLModelStructure { fatalError() }
    public struct NeuralNetwork: Codable, Hashable, @unchecked Sendable {
        public var layers: [MLModelStructure.NeuralNetwork.Layer] { get { return [] } }
        public struct Layer: Codable, Hashable, @unchecked Sendable {
            public var inputNames: [Swift.String] { get { return [] } }
            public var name: Swift.String { get { fatalError() } }
            public var outputNames: [Swift.String] { get { return [] } }
            public var type: Swift.String { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Layer, _ rhs: Layer) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: NeuralNetwork, _ rhs: NeuralNetwork) -> Bool { fatalError() }
    }
    public struct Pipeline: Codable, Hashable, @unchecked Sendable {
        public var subModelNames: [Swift.String] { get { return [] } }
        public var subModels: [MLModelStructure] { get { return [] } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Pipeline, _ rhs: Pipeline) -> Bool { fatalError() }
    }
    public struct Program: Codable, Hashable, @unchecked Sendable {
        public var functions: [Swift.String : Function] { get { return [:] } }
        public struct Argument: Codable, Hashable, @unchecked Sendable {
            public var bindings: [MLModelStructure.Program.Binding] { get { return [] } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Argument, _ rhs: Argument) -> Bool { fatalError() }
        }
        public enum Binding: Codable, Hashable, @unchecked Sendable {
            case name(_: Swift.String)
            case value(_: MLModelStructure.Program.Value)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Binding, _ rhs: Binding) -> Bool { fatalError() }
        }
        public struct Block: Codable, Hashable, @unchecked Sendable {
            public var inputs: [MLModelStructure.Program.NamedValueType] { get { return [] } }
            public var operations: [MLModelStructure.Program.Operation] { get { return [] } }
            public var outputNames: [Swift.String] { get { return [] } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Block, _ rhs: Block) -> Bool { fatalError() }
        }
        public struct Function: Codable, Hashable, @unchecked Sendable {
            public var block: MLModelStructure.Program.Block { get { fatalError() } }
            public var inputs: [MLModelStructure.Program.NamedValueType] { get { return [] } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Function, _ rhs: Function) -> Bool { fatalError() }
        }
        public struct NamedValueType: Codable, Hashable, @unchecked Sendable {
            public var name: Swift.String { get { fatalError() } }
            public var type: MLModelStructure.Program.ValueType { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: NamedValueType, _ rhs: NamedValueType) -> Bool { fatalError() }
        }
        public struct Operation: Codable, Hashable, @unchecked Sendable {
            public var blocks: [MLModelStructure.Program.Block] { get { return [] } }
            public var inputs: [Swift.String : MLModelStructure.Program.Argument] { get { return [:] } }
            public var operatorName: Swift.String { get { fatalError() } }
            public var outputs: [MLModelStructure.Program.NamedValueType] { get { return [] } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Operation, _ rhs: Operation) -> Bool { fatalError() }
        }
        public struct Value: Codable, Hashable, @unchecked Sendable {
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Value, _ rhs: Value) -> Bool { fatalError() }
        }
        public struct ValueType: Codable, Hashable, @unchecked Sendable {
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValueType, _ rhs: ValueType) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Program, _ rhs: Program) -> Bool { fatalError() }
    }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureNeuralNetwork {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureNeuralNetworkLayer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructurePipeline {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgram {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramArgument {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramBinding {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramBlock {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramFunction {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramNamedValueType {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramOperation {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramValue {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelStructureProgramValueType {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelSwiftEngine {
    @nonobjc public convenience init?(description: MLModelDescription?, configuration: MLModelConfiguration?) { fatalError() }
    public final func prediction(from: MLFeatureProvider) throws -> MLFeatureProvider { fatalError() }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLModelVisionFeaturePrintInfo {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiArray {
    @nonobjc public convenience init<A>(_ arg1: A) throws where A: Collection, A.Element == Swift.Float { fatalError() }
    @nonobjc public convenience init<A>(_ arg1: A) throws where A: Collection, A.Element: FixedWidthInteger { fatalError() }
    @nonobjc public convenience init<A>(_ arg1: A) where A: MLShapedArrayProtocol { fatalError() }
    @nonobjc public convenience init(shape: [Swift.Int], dataType: MLMultiArrayDataType, strides: [Swift.Int]) { fatalError() }
    @nonobjc public convenience init<A>(_ arg1: A) throws where A: Collection, A.Element == Swift.Double { fatalError() }
    public final func withUnsafeBufferPointer<GenericA, GenericB>(ofType: GenericA.Type, _: (_ arg1: UnsafeBufferPointer<GenericA>) throws -> GenericB) throws -> GenericB where GenericA: MLShapedArrayScalar { fatalError() }
    public final func withUnsafeMutableBytes<GenericA>(_ arg1: (UnsafeMutableRawBufferPointer, [Swift.Int]) throws -> GenericA) throws -> GenericA { fatalError() }
    public final func withUnsafeMutableBufferPointer<GenericA, GenericB>(ofType: GenericA.Type, _: (UnsafeMutableBufferPointer<GenericA>, [Swift.Int]) throws -> GenericB) throws -> GenericB where GenericA: MLShapedArrayScalar { fatalError() }
    public final func withUnsafeBytes<GenericA>(_ arg1: (_ arg1: UnsafeRawBufferPointer) throws -> GenericA) throws -> GenericA { fatalError() }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiArrayAsNSArrayWrapper {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiArrayBufferLayout {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiArrayConstraint {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiArrayShapeConstraint {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiArrayUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiFunctionProgramContainer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLMultiFunctionProgramEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNNLayerComputeUnitSelectionUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralEngineComputeDevice {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkCompiler {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkContainer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkMLComputeLayer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkMLComputeUpdateEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkUpdateEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkV1Container {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNeuralNetworkV1Engine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNonMaximumSuppression {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNonMaximumSuppressionParameters {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNormalizer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLNumericConstraint {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLObjectBoundingBoxOutputDescription {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLOneHotEncoder {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLOptimizationHints {
    @nonobjc public override convenience init() { fatalError() }
    public final var hotHandDuration: Swift.Double { get { fatalError() } set {} }
    public final var reshapeFrequency: MLOptimizationHints.ReshapeFrequency { get { fatalError() } set {} }
    public static func == (lhs: MLOptimizationHints, rhs: MLOptimizationHints) -> Swift.Bool { fatalError() }
    public final var specializationStrategy: MLOptimizationHints.SpecializationStrategy { get { fatalError() } set {} }
    public enum ReshapeFrequency: Int, Codable, Hashable, RawRepresentable, @unchecked Sendable {
        case frequent
        case infrequent
        public init?(rawValue: Swift.Int) { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ReshapeFrequency, _ rhs: ReshapeFrequency) -> Bool { fatalError() }
    }
    public enum SpecializationStrategy: Int, Codable, Hashable, RawRepresentable, @unchecked Sendable {
        case `default`
        case fastPrediction
        public init?(rawValue: Swift.Int) { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: SpecializationStrategy, _ rhs: SpecializationStrategy) -> Bool { fatalError() }
    }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLParameterContainer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLParameterDescription {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLParameterKey {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLParameterUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPersistentKeyStorage {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPipeline {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPipelineClassifier {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPipelineLoader {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPipelineRegressor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPipelineUpdateEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPrecisionRecallCurve {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLPredictionOptions {
    public final var intermediateTensorToOutputFeatureMap: [Swift.String : Swift.String] { get { return [:] } set {} }
}
// --- End ObjC Extension ---
public struct MLPredictionPlan: Codable, Hashable, @unchecked Sendable {
    public init(inputShapes: [Swift.String : [Swift.Int]]) { fatalError() }
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public var inputBufferLayouts: [Swift.String : MLMultiArrayBufferLayout] { get { return [:] } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
// --- ObjC Extension (bridge-header required) ---
extension MLPredictionSyncPoint {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLProgramContainer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLProgramContext {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLProgramEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLProgramEvaluationResult {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLProgramEvaluator {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLProgramTrainer {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLProgramTrainingDelta {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLRegressor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLRegressorResult {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSVMEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSVMLoader {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSVREngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSVRLoader {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSaver {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLScaler {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSecureModel {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSecureModelDecryptCredential {
}
// --- End ObjC Extension ---
public struct MLSendableFeatureValue: Codable, CustomDebugStringConvertible, Hashable, @unchecked Sendable {
    public init(_ arg1: [Swift.String]) { fatalError() }
    public init(_ arg1: [Swift.Int : Swift.Double]) { fatalError() }
    public init(undefined: MLFeatureType) { fatalError() }
    public init(_ arg1: Swift.Float16) { fatalError() }
    public init(_ arg1: [Swift.Int : Swift.Int]) { fatalError() }
    public init(_ arg1: Swift.Double) { fatalError() }
    public init(_ arg1: Swift.Int32) { fatalError() }
    public init(_ arg1: Swift.Float) { fatalError() }
    public init(_ arg1: Swift.Int) { fatalError() }
    public init(_ arg1: Swift.String) { fatalError() }
    public init<A>(_ arg1: MLShapedArray<A>) where A: MLShapedArrayScalar { fatalError() }
    public init(_ arg1: [Swift.String : Swift.Int]) { fatalError() }
    public init(_ arg1: [Swift.String : Swift.Double]) { fatalError() }
    public init?(_ arg1: MLFeatureValue) { fatalError() }
    public var float16Value: Swift.Float16? { get { return nil } }
    public var stringValue: Swift.String? { get { return nil } }
    public var type: MLFeatureType { get { fatalError() } }
    public func shapedArrayValue<GenericA>(of: GenericA.Type) -> MLShapedArray<GenericA>? where GenericA: MLShapedArrayScalar { return nil }
    public var stringArrayValue: [Swift.String]? { get { return nil } }
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var doubleValue: Swift.Double? { get { return nil } }
    public var floatValue: Swift.Float? { get { return nil } }
    public var integerDictionaryValue: [Swift.Int : Swift.Double]? { get { return nil } }
    public var integerValue: Swift.Int? { get { return nil } }
    public var isScalar: Swift.Bool { get { fatalError() } }
    public var isShapedArray: Swift.Bool { get { fatalError() } }
    public var isUndefined: Swift.Bool { get { fatalError() } }
    public var stringDictionaryValue: [Swift.String : Swift.Double]? { get { return nil } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
// --- ObjC Extension (bridge-header required) ---
extension MLSequence {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSequenceConstraint {
}
// --- End ObjC Extension ---
public struct MLShapedArray<A>: BidirectionalCollection, Codable, Collection, CustomStringConvertible, ExpressibleByArrayLiteral, Hashable, MLShapedArrayProtocol, MutableCollection, RandomAccessCollection, @unchecked Sendable, Sequence {
    public init(_ arg1: MLMultiArray) { fatalError() }
    public init<A1>(scalars: A1, shape: [Swift.Int]) where A == A1.Element, A1: Sequence { fatalError() }
    public init(data: Data, shape: [Swift.Int]) { fatalError() }
    public init(data: Data, shape: [Swift.Int], strides: [Swift.Int]) { fatalError() }
    public init<A1>(concatenating: A1, alongAxis: Swift.Int) where A == Any, A1: Sequence, A1.Element: MLShapedArrayProtocol { fatalError() }
    public init(bytesNoCopy: UnsafeRawPointer, shape: [Swift.Int], strides: [Swift.Int], deallocator: Data.Deallocator) { fatalError() }
    public init(scalar: A) { fatalError() }
    public init(mutating: CVBuffer, shape: [Swift.Int]) { fatalError() }
    public init<A1>(expandingDimensionsOf: A1, alongAxis: Swift.Int) where A == Any, A1: MLShapedArrayProtocol { fatalError() }
    public init(unsafeUninitializedShape: [Swift.Int], initializingWith: (inout UnsafeMutableBufferPointer<A>, [Swift.Int]) throws -> ()) throws { fatalError() }
    public init<A1>(reshaping: A1, to: [Swift.Int]) where A == Any, A1: MLShapedArrayProtocol { fatalError() }
    public init<A1>(squeezing: A1) where A == Any, A1: MLShapedArrayProtocol { fatalError() }
    public subscript<A1>>(_ arg1: A1) -> MLShapedArraySlice<A> where A1: Collection, A1.Element == Range<Swift.Int -> Any { get { fatalError() } set {} }
    public subscript(_ arg1: Swift.Int) -> MLShapedArraySlice<A> { get { fatalError() } set {} }
    public var shape: [Swift.Int] { get { return [] } }
    public var startIndex: Swift.Int { get { fatalError() } }
    public func withPixelBufferIfAvailable<GenericA>(_ arg1: (_ arg1: CVBuffer) throws -> GenericA) throws -> GenericA? { return nil }
    public var description: Swift.String { get { fatalError() } }
    public func withUnsafeMutableShapedBufferPointer<GenericA>(using: MLShapedArrayBufferLayout, _: (inout UnsafeMutableBufferPointer<A>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA { fatalError() }
    public func changingLayout(to: MLShapedArrayBufferLayout) -> MLShapedArray<A> { fatalError() }
    public func squeezingShape() -> MLShapedArray<A> { fatalError() }
    public var indices: Range<Swift.Int> { get { fatalError() } }
    public func expandingShape(at: Swift.Int) -> MLShapedArray<A> { fatalError() }
    public func withUnsafeShapedBufferPointer<GenericA>(_ arg1: (UnsafeBufferPointer<A>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA { fatalError() }
    public var endIndex: Swift.Int { get { fatalError() } }
    public func transposed(permutation: [Swift.Int]) -> MLShapedArray<A> { fatalError() }
    public func withUnsafeMutableShapedBufferPointer<GenericA>(_ arg1: (inout UnsafeMutableBufferPointer<A>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA { fatalError() }
    public var strides: [Swift.Int] { get { return [] } }
    public func withMutablePixelBufferIfAvailable<GenericA>(_ arg1: (_ arg1: CVBuffer) throws -> GenericA) throws -> GenericA? { return nil }
    public func reshaped(to: [Swift.Int]) -> MLShapedArray<A> { fatalError() }
    public subscript<GenericA>(scalarAt arg1: GenericA) -> A where GenericA: Collection, GenericA.Element == Swift.Int { get { fatalError() } set {} }
    public subscript<GenericA>(_ arg1: GenericA) -> MLShapedArraySlice<A> where GenericA: Collection, GenericA.Element == Swift.Int { get { fatalError() } set {} }
    public func transposed() -> MLShapedArray<A> { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLShapedArray<A>, _ rhs: MLShapedArray<A>) -> Bool { fatalError() }
}
public enum MLShapedArrayBufferLayout: Codable, Hashable, @unchecked Sendable {
    case firstMajorContiguous
    case lastMajorContiguous
    case strides(_: [Swift.Int])
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLShapedArrayBufferLayout, _ rhs: MLShapedArrayBufferLayout) -> Bool { fatalError() }
}
public protocol MLShapedArrayProtocol: ExpressibleByArrayLiteral, MutableCollection, RandomAccessCollection {
    init(bytesNoCopy: UnsafeRawPointer, shape: [Swift.Int], strides: [Swift.Int], deallocator: Data.Deallocator)
    init(unsafeUninitializedShape: [Swift.Int], initializingWith: (inout UnsafeMutableBufferPointer<Self.Scalar>, [Swift.Int]) throws -> ()) throws
    func withUnsafeMutableShapedBufferPointer<GenericA>(_ arg1: (inout UnsafeMutableBufferPointer<Self.Scalar>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA
    func withUnsafeShapedBufferPointer<GenericA>(_ arg1: (UnsafeBufferPointer<Self.Scalar>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA
    var shape: [Swift.Int] { get }
    var strides: [Swift.Int] { get }
    associatedtype Scalar: MLShapedArrayScalar
    subscript(scalarAt arg1: Self) -> Self.Scalar where Self: any Collection, Self.Element == Swift.Int { get set }
    subscript(_ arg1: Self) -> MLShapedArraySlice<Self.Scalar> where Self: any Collection, Self.Element == Swift.Int { get set }
    subscript>(_ arg1: Self) -> MLShapedArraySlice<Self.Scalar> where Self: any Collection, Self.Element == Range<Swift.Int -> Any { get set }
}
public protocol MLShapedArrayRangeExpression {
    func relative(toShapedArrayAxis: Range<Swift.Int>) -> Range<Swift.Int>
}
public protocol MLShapedArrayScalar {
    static var multiArrayDataType: MLMultiArrayDataType { get }
}
public struct MLShapedArraySlice<A>: BidirectionalCollection, Codable, Collection, ExpressibleByArrayLiteral, Hashable, MLShapedArrayProtocol, MutableCollection, RandomAccessCollection, @unchecked Sendable, Sequence {
    public init(scalar: A) { fatalError() }
    public init<A1>(expandingDimensionsOf: A1, alongAxis: Swift.Int) where A == Any, A1: MLShapedArrayProtocol { fatalError() }
    public init(data: Data, shape: [Swift.Int], strides: [Swift.Int]) { fatalError() }
    public init<A1>(concatenating: A1, alongAxis: Swift.Int) where A == Any, A1: Sequence, A1.Element: MLShapedArrayProtocol { fatalError() }
    public init<A1>(scalars: A1, shape: [Swift.Int]) where A == A1.Element, A1: Sequence { fatalError() }
    public init(mutating: CVBuffer, shape: [Swift.Int]) { fatalError() }
    public init(unsafeUninitializedShape: [Swift.Int], initializingWith: (inout UnsafeMutableBufferPointer<A>, [Swift.Int]) throws -> ()) throws { fatalError() }
    public init(bytesNoCopy: UnsafeRawPointer, shape: [Swift.Int], strides: [Swift.Int], deallocator: Data.Deallocator) { fatalError() }
    public init(data: Data, shape: [Swift.Int]) { fatalError() }
    public init<A1>(squeezing: A1) where A == Any, A1: MLShapedArrayProtocol { fatalError() }
    public init(_ arg1: MLMultiArray) { fatalError() }
    public subscript<GenericA>(scalarAt arg1: GenericA) -> A where GenericA: any Collection, GenericA.Element == Swift.Int { get { fatalError() } set {} }
    public subscript<A1>>(_ arg1: A1) -> MLShapedArraySlice<A> where A1: any Collection, A1.Element == Range<Swift.Int -> Any { get { fatalError() } set {} }
    public func reshaped(to: [Swift.Int]) -> MLShapedArraySlice<A> { fatalError() }
    public func withUnsafeMutableShapedBufferPointer<GenericA>(using: MLShapedArrayBufferLayout, _: (inout UnsafeMutableBufferPointer<A>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA { fatalError() }
    public func squeezingShape() -> MLShapedArraySlice<A> { fatalError() }
    public subscript<GenericA>(_ arg1: GenericA) -> MLShapedArraySlice<A> where GenericA: any Collection, GenericA.Element == Swift.Int { get { fatalError() } set {} }
    public func changingLayout(to: MLShapedArrayBufferLayout) -> MLShapedArraySlice<A> { fatalError() }
    public var endIndex: Swift.Int { get { fatalError() } }
    public func transposed(permutation: [Swift.Int]) -> MLShapedArraySlice<A> { fatalError() }
    public var shape: [Swift.Int] { get { return [] } }
    public var startIndex: Swift.Int { get { fatalError() } }
    public func transposed() -> MLShapedArraySlice<A> { fatalError() }
    public func withUnsafeMutableShapedBufferPointer<GenericA>(_ arg1: (inout UnsafeMutableBufferPointer<A>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA { fatalError() }
    public func expandingShape(at: Swift.Int) -> MLShapedArraySlice<A> { fatalError() }
    public func withUnsafeShapedBufferPointer<GenericA>(_ arg1: (UnsafeBufferPointer<A>, [Swift.Int], [Swift.Int]) throws -> GenericA) throws -> GenericA { fatalError() }
    public var strides: [Swift.Int] { get { return [] } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLShapedArraySlice<A>, _ rhs: MLShapedArraySlice<A>) -> Bool { fatalError() }
}
// --- ObjC Extension (bridge-header required) ---
extension MLShufflingBatchProvider {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLState {
    public final func withMultiArray<GenericA>(_ arg1: (_ arg1: MLMultiArray) -> GenericA) throws -> GenericA { fatalError() }
    public final func withMultiArray<GenericA>(for: Swift.String, _: (_ arg1: MLMultiArray) throws -> GenericA) throws -> GenericA { fatalError() }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLStateConstraint {
    public final var bufferShape: [Swift.Int] { get { return [] } }
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLStreamingInputDataSource {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSupervisedOnlineUpdateOptions {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSupportVectorClassifier {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLSupportVectorRegressor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLTask {
}
// --- End ObjC Extension ---
public struct MLTensor: Codable, CustomReflectable, CustomStringConvertible, ExpressibleByArrayLiteral, ExpressibleByBooleanLiteral, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, MLComputeFunction.ArgumentRepresentable, @unchecked Sendable {
    public init(unsafeUninitializedShape: [Swift.Int], scalarType: any MLTensorScalar.Type, initializingWith: (UnsafeMutableRawBufferPointer) throws -> ()) throws { fatalError() }
    public init<A>(_: A, scalarType: A.Type) where A: MLTensorScalar { fatalError() }
    public init(linearSpaceFrom: Swift.Float, through: Swift.Float, count: Swift.Int) { fatalError() }
    public init<A>(ones: [Swift.Int], scalarType: A.Type) where A: MLTensorScalar, A: BinaryFloatingPoint, Any: FixedWidthInteger { fatalError() }
    public init<A>(rangeFrom: A, to: A, by: Any, scalarType: A.Type) where A: MLTensorScalar, A: Strideable { fatalError() }
    public init<A, B>(_: B, scalarType: A.Type) where A: MLTensorScalar, A == B.Element, B: Collection { fatalError() }
    public init(bytesNoCopy: UnsafeRawBufferPointer, shape: [Swift.Int], scalarType: any MLTensorScalar.Type, deallocator: Data.Deallocator) { fatalError() }
    public init<A>(zeros: [Swift.Int], scalarType: A.Type) where A: MLTensorScalar, A: BinaryFloatingPoint, Any: FixedWidthInteger { fatalError() }
    public init(rangeFrom: Swift.Float, to: Swift.Float, by: Swift.Float) { fatalError() }
    public init<A>(ones: [Swift.Int], scalarType: A.Type) where A: MLTensorScalar, A: FixedWidthInteger { fatalError() }
    public init(floatLiteral: Swift.Float) { fatalError() }
    public init(integerLiteral: Swift.Int32) { fatalError() }
    public init<A>(zeros: [Swift.Int], scalarType: A.Type) where A: MLTensorScalar, A: FixedWidthInteger { fatalError() }
    public init<A>(shape: [Swift.Int], scalars: A) where A: Collection, A.Element == Swift.Float { fatalError() }
    public init<A>(randomUniform: [Swift.Int], in: Range<A>, seed: UInt64?, scalarType: A.Type) where A: MLTensorScalar, A: BinaryFloatingPoint { fatalError() }
    public init<A>(linearSpaceFrom: A, through: A, count: Swift.Int, scalarType: A.Type) where A: MLTensorScalar, A: BinaryFloatingPoint { fatalError() }
    public init<A>(_ arg1: A) where A: Collection, A.Element == Swift.Float { fatalError() }
    public init(repeating: Swift.Float, shape: [Swift.Int]) { fatalError() }
    public init<A>(randomUniform: [Swift.Int], in: ClosedRange<A>, seed: UInt64?, scalarType: A.Type) where A: MLTensorScalar, A: BinaryInteger { fatalError() }
    public init(arrayLiteral: MLTensor...) { fatalError() }
    public init<A, B>(shape: [Swift.Int], scalars: B, scalarType: A.Type) where A: MLTensorScalar, A == B.Element, B: Collection { fatalError() }
    public init<A>(_ arg1: A) where A: MLShapedArrayProtocol, Any: MLTensorScalar { fatalError() }
    public init<A>(_: A, alongAxis: Swift.Int) where A: Collection, A.Element == MLTensor { fatalError() }
    public init(booleanLiteral: Swift.Bool) { fatalError() }
    public init<A>(repeating: A, shape: [Swift.Int], scalarType: A.Type) where A: MLTensorScalar { fatalError() }
    public init<A>(randomNormal: [Swift.Int], mean: A, standardDeviation: A, seed: UInt64?, scalarType: A.Type) where A: MLTensorScalar, A: BinaryFloatingPoint { fatalError() }
    public init<A>(_ arg1: A) where A: Collection, A.Element == Swift.Int32 { fatalError() }
    public init<A>(concatenating: A, alongAxis: Swift.Int) where A: Collection, A.Element == MLTensor { fatalError() }
    public init<A>(stacking: A, alongAxis: Swift.Int) where A: Collection, A.Element == MLTensor { fatalError() }
    public init(shape: [Swift.Int], data: Data, scalarType: any MLTensorScalar.Type) { fatalError() }
    public subscript(_ arg1: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }
    public var strides: [Swift.Int] { get { return [] } }
    public func acos() -> MLTensor { fatalError() }
    public func max(alongAxes: [Swift.Int], keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func atanh() -> MLTensor { fatalError() }
    public func all(alongAxes: [Swift.Int], keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: @escaping (UnboundedRange_) -> (), _ arg4: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }
    public func argmin(alongAxis: Swift.Int, keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func squeezingShape() -> MLTensor { fatalError() }
    public static func *=(_ arg1: inout MLTensor, _ arg2: MLTensor) -> () {}
    public var shape: [Swift.Int] { get { return [] } }
    public func cast(like: MLTensor) -> MLTensor { fatalError() }
    public func sin() -> MLTensor { fatalError() }
    public static func *<GenericA>(_ arg1: GenericA, _ arg2: MLTensor) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func clamped(to: ClosedRange<Swift.Float>) -> MLTensor { fatalError() }
    public func max(keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func mean(alongAxes: [Swift.Int], keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func round() -> MLTensor { fatalError() }
    public static func *(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
    public func clamped(to: PartialRangeFrom<Swift.Float>) -> MLTensor { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func %(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
    public func sum(keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func bandPart(lowerBandCount: Swift.Int, upperBandCount: Swift.Int) -> MLTensor { fatalError() }
    public func sum(alongAxes: [Swift.Int], keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public var customMirror: Mirror { get { fatalError() } }
    public func flattened() -> MLTensor { fatalError() }
    public static func /<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func max(alongAxes: Swift.Int..., keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func all(alongAxes: Swift.Int..., keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func atan() -> MLTensor { fatalError() }
    public func min(keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func exp() -> MLTensor { fatalError() }
    public func gathering(atIndices: MLTensor, alongAxis: Swift.Int, batchDimensionCount: Swift.Int) -> MLTensor { fatalError() }
    public func scalars<GenericA>(of: GenericA.Type) async -> [GenericA] where GenericA: MLTensorScalar { return [] }
    public func pow(_ arg1: MLTensor) -> MLTensor { fatalError() }
    public func replacing<GenericA>(with: GenericA, where: MLTensor) -> MLTensor where GenericA: MLTensorScalar { fatalError() }
    public func min(alongAxes: Swift.Int..., keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func replacing(with: MLTensor, atIndices: MLTensor, alongAxis: Swift.Int) -> MLTensor { fatalError() }
    public func transposed(permutation: [Swift.Int]) -> MLTensor { fatalError() }
    public func min(alongAxes: [Swift.Int], keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func mean(alongAxes: Swift.Int..., keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public static func %=(_ arg1: inout MLTensor, _ arg2: MLTensor) -> () {}
    public func expandingShape(at: Swift.Int...) -> MLTensor { fatalError() }
    public func squeezingShape(at: Swift.Int...) -> MLTensor { fatalError() }
    public func log() -> MLTensor { fatalError() }
    public static func +=(_ arg1: inout MLTensor, _ arg2: MLTensor) -> () {}
    public func asin() -> MLTensor { fatalError() }
    public func product(alongAxes: Swift.Int..., keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public subscript(_ arg1: @escaping (UnboundedRange_) -> (), _ arg2: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }
    public var isScalar: Swift.Bool { get { fatalError() } }
    public func withUnsafeBytes<GenericA>(_ arg1: @Sendable (_ arg1: UnsafeRawBufferPointer) throws -> GenericA) async throws -> GenericA where GenericA: Sendable { fatalError() }
    public func tiled(multiples: [Swift.Int]) -> MLTensor { fatalError() }
    public func any(keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public static func /<GenericA>(_ arg1: GenericA, _ arg2: MLTensor) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func product(keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func abs() -> MLTensor { fatalError() }
    public func argmax() -> MLTensor { fatalError() }
    public var rank: Swift.Int { get { fatalError() } }
    public func split(count: Swift.Int, alongAxis: Swift.Int) -> [MLTensor] { return [] }
    public func mean(keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func shapedArray<GenericA>(of: GenericA.Type) async -> MLShapedArray<GenericA> where GenericA: MLShapedArrayScalar, GenericA: MLTensorScalar { fatalError() }
    public func all(keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public var scalarType: any MLTensorScalar.Type { get { fatalError() } }
    public func softmax(alongAxis: Swift.Int) -> MLTensor { fatalError() }
    public static func -<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public static func +<GenericA>(_ arg1: GenericA, _ arg2: MLTensor) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public static func -=(_ arg1: inout MLTensor, _ arg2: MLTensor) -> () {}
    public func expandingShape(at: [Swift.Int]) -> MLTensor { fatalError() }
    public func squareRoot() -> MLTensor { fatalError() }
    public func tanh() -> MLTensor { fatalError() }
    public func cosh() -> MLTensor { fatalError() }
    public static func /(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
    public static func +(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
    public static func -(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
    public func argsort(alongAxis: Swift.Int, descendingOrder: Swift.Bool) -> MLTensor { fatalError() }
    public func any(alongAxes: Swift.Int..., keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func pow<GenericA>(_ arg1: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func reciprocal() -> MLTensor { fatalError() }
    public func matmul(_ arg1: MLTensor) -> MLTensor { fatalError() }
    public func split(sizes: [Swift.Int], alongAxis: Swift.Int) -> [MLTensor] { return [] }
    public func concatenated(with: MLTensor, alongAxis: Swift.Int) -> MLTensor { fatalError() }
    public func sum(alongAxes: Swift.Int..., keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func transposed(permutation: Swift.Int...) -> MLTensor { fatalError() }
    public func floor() -> MLTensor { fatalError() }
    public func argmax(alongAxis: Swift.Int, keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func cumulativeSum(alongAxis: Swift.Int) -> MLTensor { fatalError() }
    public func padded(forSizes: [(before: Swift.Int, after: Swift.Int)], mode: MLTensor.PaddingMode) -> MLTensor { fatalError() }
    public func tan() -> MLTensor { fatalError() }
    public func squared() -> MLTensor { fatalError() }
    public func replacing(with: MLTensor, where: MLTensor) -> MLTensor { fatalError() }
    public func transposed() -> MLTensor { fatalError() }
    public func acosh() -> MLTensor { fatalError() }
    public func reversed(alongAxes: [Swift.Int]) -> MLTensor { fatalError() }
    public func asinh() -> MLTensor { fatalError() }
    public func topK(_ arg1: Swift.Int) -> (values: MLTensor, indices: MLTensor) { fatalError() }
    public func cumulativeProduct(alongAxis: Swift.Int) -> MLTensor { fatalError() }
    public func squeezingShape(at: [Swift.Int]) -> MLTensor { fatalError() }
    public func reshaped(to: [Swift.Int]) -> MLTensor { fatalError() }
    public func reversed(alongAxes: Swift.Int...) -> MLTensor { fatalError() }
    public func unstacked(alongAxis: Swift.Int) -> [MLTensor] { return [] }
    public var computeFunctionArgument: MLComputeFunction.Argument { get { fatalError() } }
    public static func /=(_ arg1: inout MLTensor, _ arg2: MLTensor) -> () {}
    public func clamped(to: PartialRangeThrough<Swift.Float>) -> MLTensor { fatalError() }
    public func replacing<GenericA>(atIndices: MLTensor, with: GenericA, alongAxis: Swift.Int) -> MLTensor where GenericA: MLTensorScalar { fatalError() }
    public static func %<GenericA>(_ arg1: GenericA, _ arg2: MLTensor) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func gathering(atIndices: MLTensor, alongAxis: Swift.Int) -> MLTensor { fatalError() }
    public func sign() -> MLTensor { fatalError() }
    public func padded(forSizes: [(before: Swift.Int, after: Swift.Int)], with: Swift.Float) -> MLTensor { fatalError() }
    public func cast<GenericA>(to: GenericA.Type) -> MLTensor where GenericA: MLTensorScalar { fatalError() }
    public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: (any MLTensorRangeExpression)?, _ arg4: @escaping (UnboundedRange_) -> (), _ arg5: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }
    public func cos() -> MLTensor { fatalError() }
    public func synchronize() async -> () {}
    public func product(alongAxes: [Swift.Int], keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public static func *<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func rsqrt() -> MLTensor { fatalError() }
    public static prefix func -(_ arg1: MLTensor) -> MLTensor { fatalError() }
    public func gathering(atIndices: MLTensor) -> MLTensor { fatalError() }
    public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: @escaping (UnboundedRange_) -> (), _ arg3: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }
    public static func -<GenericA>(_ arg1: GenericA, _ arg2: MLTensor) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func argmin() -> MLTensor { fatalError() }
    public func resized(to: (newHeight: Swift.Int, newWidth: Swift.Int), method: MLTensor.ResizeMethod) -> MLTensor { fatalError() }
    public static func %<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public func any(alongAxes: [Swift.Int], keepRank: Swift.Bool) -> MLTensor { fatalError() }
    public func sinh() -> MLTensor { fatalError() }
    public static func +<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
    public var scalarCount: Swift.Int { get { fatalError() } }
    public func ceil() -> MLTensor { fatalError() }
    public func exp2() -> MLTensor { fatalError() }
    public struct  {
        public static func |(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
        public static prefix func !(_ arg1: MLTensor) -> MLTensor { fatalError() }
        public static func >(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
        public static func ==<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
        public static func !=<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar, GenericA: Numeric { fatalError() }
        public static func <(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
        public static func == (lhs: Self, rhs: Self) -> MLTensor { fatalError() }
        public static func ><A>(_ arg1: MLTensor, _ arg2: A) -> MLTensor where A: MLTensorScalar, A: Numeric { fatalError() }
        public static func <=(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
        public static func &(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
        public static func ^(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
        public static func >=<A>(_ arg1: MLTensor, _ arg2: A) -> MLTensor where A: MLTensorScalar, A: Numeric { fatalError() }
        public static func >=(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
        public static func !=(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
    }
    public struct Descriptor: Codable, CustomDebugStringConvertible, Hashable, @unchecked Sendable {
        public init(like: MLTensor) { fatalError() }
        public init<A>(shape: [Swift.Int], scalarType: A.Type) where A: MLTensorScalar { fatalError() }
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public var hashValue: Swift.Int { get { fatalError() } }
        public var strides: [Swift.Int] { get { return [] } }
        public func hash(into: inout Hasher) -> () {}
        public var debugDescription: Swift.String { get { fatalError() } }
        public var scalarCount: Swift.Int { get { fatalError() } }
        public var scalarType: any MLTensorScalar.Type { get { fatalError() } }
        public var shape: [Swift.Int] { get { return [] } }
        public var size: Swift.Int { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public struct IndexPath: Codable, Hashable, @unchecked Sendable {
        public init(begin: [Swift.Int], end: [Swift.Int], strides: [Swift.Int], beginMask: Swift.Int, endMask: Swift.Int, ellipsisMask: Swift.Int, newAxisMask: Swift.Int, squeezeAxisMask: Swift.Int) { fatalError() }
        public var beginMask: Swift.Int { get { fatalError() } }
        public var ellipsisMask: Swift.Int { get { fatalError() } }
        public var end: [Swift.Int] { get { return [] } }
        public var endMask: Swift.Int { get { fatalError() } }
        public var newAxisMask: Swift.Int { get { fatalError() } }
        public var squeezeAxisMask: Swift.Int { get { fatalError() } }
        public var start: [Swift.Int] { get { return [] } }
        public var strides: [Swift.Int] { get { return [] } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: IndexPath, _ rhs: IndexPath) -> Bool { fatalError() }
    }
    public enum PaddingMode: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
        case constant(_: Swift.Float)
        case reflection
        case symmetric
        public func hash(into: inout Hasher) -> () {}
        public var description: Swift.String { get { fatalError() } }
        public var hashValue: Swift.Int { get { fatalError() } }
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public enum ResizeMethod: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
        case bilinear(bilinear: Swift.Bool)
        case nearestNeighbor
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public var hashValue: Swift.Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () {}
        public var description: Swift.String { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLTensor, _ rhs: MLTensor) -> Bool { fatalError() }
}
public protocol MLTensorRangeExpression {
    var _mlTensorRange: _MLTensorRange { get }
}
public protocol MLTensorScalar {
}
// --- ObjC Extension (bridge-header required) ---
extension MLTreeEnsembleClassifier {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLTreeEnsembleRegressor {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLTreeEnsembleXGBoostClassifier {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLTreeEnsembleXGBoostUpdateEngine {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLUpdateContext {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLUpdateProgressHandlers {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLUpdateProgressHandlersUtils {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLUpdateTask {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLVersionInfo {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLWrappedModel {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension MLWritableWrappedModel {
}
// --- End ObjC Extension ---
// --- ObjC Extension (bridge-header required) ---
extension _MLInternalNLPModelWriter {
}
// --- End ObjC Extension ---
public struct _MLTensorRange: Codable, Hashable, MLTensorRangeExpression, @unchecked Sendable {
    public var _mlTensorRange: _MLTensorRange { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: _MLTensorRange, _ rhs: _MLTensorRange) -> Bool { fatalError() }
}
public func conv2D(_: MLTensor, weight: MLTensor, stride: (y: Swift.Int, x: Swift.Int), padding: (y: Swift.Int, x: Swift.Int), dilation: (y: Swift.Int, x: Swift.Int), groupCount: Swift.Int) -> MLTensor { fatalError() }
public func pointwiseMax(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
public func pointwiseMax<A>(_ arg1: A, _ arg2: MLTensor) -> MLTensor where A: MLTensorScalar, A: Numeric { fatalError() }
public func pointwiseMax<A>(_ arg1: MLTensor, _ arg2: A) -> MLTensor where A: MLTensorScalar, A: Numeric { fatalError() }
public func pointwiseMin(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
public func pointwiseMin<A>(_ arg1: A, _ arg2: MLTensor) -> MLTensor where A: MLTensorScalar, A: Numeric { fatalError() }
public func pointwiseMin<A>(_ arg1: MLTensor, _ arg2: A) -> MLTensor where A: MLTensorScalar, A: Numeric { fatalError() }
public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: @escaping () throws -> A) throws -> A { fatalError() }
public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: @escaping () async throws -> A) async throws -> A { fatalError() }
extension MLComputeFunction.ArgumentRepresentable where Self == MLComputeFunction.Argument {
    public static func float16(_ arg1: Swift.Float16) -> MLComputeFunction.Argument { fatalError() }
    public static func int32Array(_ arg1: [Swift.Int32]) -> MLComputeFunction.Argument { fatalError() }
    public static func float16Array(_ arg1: [Swift.Float16]) -> MLComputeFunction.Argument { fatalError() }
    public static func texture(_: MTLTexture, sharedEvent: MTLSharedEvent, completionValue: UInt64) -> MLComputeFunction.Argument { fatalError() }
    public static func int32(_ arg1: Swift.Int32) -> MLComputeFunction.Argument { fatalError() }
    public static func buffer(_ arg1: MTLBuffer) -> MLComputeFunction.Argument { fatalError() }
    public static func float32(_ arg1: Swift.Float) -> MLComputeFunction.Argument { fatalError() }
    public static func float32Array(_ arg1: [Swift.Float]) -> MLComputeFunction.Argument { fatalError() }
    public static func buffer(_: MTLBuffer, sharedEvent: MTLSharedEvent, completionValue: UInt64) -> MLComputeFunction.Argument { fatalError() }
    public static func texture(_ arg1: MTLTexture) -> MLComputeFunction.Argument { fatalError() }
    public static func tensor(_ arg1: MLTensor) -> MLComputeFunction.Argument { fatalError() }
}
extension MLShapedArray where A: Decodable {
    public init(from: Swift.Decoder) throws { fatalError() }
}
extension MLShapedArray where A: Encodable {
    public func encode(to: Swift.Encoder) throws -> () {}
}
extension MLShapedArray where A: Equatable {
    public static func ==(_ arg1: MLShapedArray<A>, _ arg2: MLShapedArray<A>) -> Swift.Bool { fatalError() }
}
extension MLShapedArrayProtocol {
    public init(repeating: Self.Scalar, shape: [Swift.Int]) { fatalError() }
    public init(converting: MLMultiArray) { fatalError() }
    public init(converting: Self) where Self: MLShapedArrayProtocol { fatalError() }
    public init(bytesNoCopy: UnsafeRawPointer, shape: [Swift.Int], deallocator: Data.Deallocator) { fatalError() }
    public init(arrayLiteral: Self.Scalar...) { fatalError() }
    public init(_ arg1: MLMultiArray) { fatalError() }
    public init(scalars: Self, shape: [Swift.Int]) where Self: Sequence, Self.Scalar == Self.Element { fatalError() }
    public subscript(_ arg1: MLShapedArrayRangeExpression...) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }
    public subscript(_ arg1: Swift.Int) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }
    public subscript(_ arg1: Range<Swift.Int>) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }
    public subscript(_ arg1: @escaping (_ arg1: UnboundedRange_) -> ()) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }
    public subscript(_ arg1: Swift.Int...) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }
    public var scalarCount: Swift.Int { get { fatalError() } }
    public var scalars: [Self.Scalar] { get { return [] } set {} }
    public func index(_: Swift.Int, offsetBy: Swift.Int) -> Swift.Int { fatalError() }
    public func index(after: Swift.Int) -> Swift.Int { fatalError() }
    public subscript(_ arg1: Self) -> MLShapedArraySlice<Self.Scalar> where Self: any Collection, Self.Element == any MLShapedArrayRangeExpression { get { fatalError() } set {} }
    public subscript(_ arg1: any MLShapedArrayRangeExpression) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }
    public var scalar: Self.Scalar? { get { return nil } set {} }
    public func fill(with: Self.Scalar) -> () {}
    public subscript(scalarAt arg1: Swift.Int...) -> Self.Scalar { get { fatalError() } set {} }
    public var count: Swift.Int { get { fatalError() } }
    public var isScalar: Swift.Bool { get { fatalError() } }
    public func fill<A>(with: A) -> () where A: Collection, Self.Scalar == Self.Element {}
}
extension MLShapedArrayProtocol where Self.Scalar: BinaryFloatingPoint, Self.Scalar.BinaryFloatingPoint.RawSignificand: FixedWidthInteger {
    public init(randomScalarsIn: Range<Self.Scalar>, shape: [Swift.Int]) { fatalError() }
    public init(identityMatrixOfSize: Swift.Int) { fatalError() }
}
extension MLShapedArrayProtocol where Self.Scalar: FixedWidthInteger {
    public init(randomScalarsIn: Range<Self.Scalar>, shape: [Swift.Int]) { fatalError() }
    public init(identityMatrixOfSize: Swift.Int) { fatalError() }
}
extension MLShapedArraySlice where A: Decodable {
    public init(from: Swift.Decoder) throws { fatalError() }
}
extension MLShapedArraySlice where A: Encodable {
    public func encode(to: Swift.Encoder) throws -> () {}
}
extension MLShapedArraySlice where A: Equatable {
    public static func ==(_ arg1: MLShapedArraySlice<A>, _ arg2: MLShapedArraySlice<A>) -> Swift.Bool { fatalError() }
}
extension MLTensorRangeExpression where Self == _MLTensorRange {
    public static func partialRangeUpTo(_: PartialRangeThrough<Swift.Int>, stride: Swift.Int) -> any MLTensorRangeExpression { fatalError() }
    public static func partialRangeFrom(_: PartialRangeFrom<Swift.Int>, stride: Swift.Int) -> any MLTensorRangeExpression { fatalError() }
    public static var newAxis: any MLTensorRangeExpression { get { fatalError() } }
    public static func partialRangeUpTo(_: PartialRangeUpTo<Swift.Int>, stride: Swift.Int) -> any MLTensorRangeExpression { fatalError() }
    public static func index(_ arg1: Swift.Int) -> any MLTensorRangeExpression { fatalError() }
    public static var squeezeAxis: any MLTensorRangeExpression { get { fatalError() } }
    public static func closedRange(_: ClosedRange<Swift.Int>, stride: Swift.Int) -> any MLTensorRangeExpression { fatalError() }
    public static func range(_: Range<Swift.Int>, stride: Swift.Int) -> any MLTensorRangeExpression { fatalError() }
    public static var fillAll: any MLTensorRangeExpression { get { fatalError() } }
}
public typealias Foundation_Data = Foundation.Data
public typealias Foundation_URL = Foundation.URL
public typealias Swift_Array = Array
public typealias Swift_BinaryFloatingPoint = BinaryFloatingPoint
public typealias Swift_BinaryInteger = BinaryInteger
public typealias Swift_Bool = Swift.Bool
public typealias Swift_Collection = Collection
public typealias Swift_Decodable = Decodable
public typealias Swift_Decoder = Swift.Decoder
public typealias Swift_Dictionary = Dictionary
public typealias Swift_Double = Swift.Double
public typealias Swift_Encodable = Encodable
public typealias Swift_Encoder = Swift.Encoder
public typealias Swift_Equatable = Equatable
public typealias Swift_Error = Error
public typealias Swift_FixedWidthInteger = FixedWidthInteger
public typealias Swift_Float = Swift.Float
public typealias Swift_Float16 = Swift.Float16
public typealias Swift_Hasher = Hasher
public typealias Swift_Int = Swift.Int
public typealias Swift_Int16 = Swift.Int16
public typealias Swift_Int32 = Swift.Int32
public typealias Swift_Int8 = Swift.Int8
public typealias Swift_Numeric = Numeric
public typealias Swift_Optional = Optional
public typealias Swift_Result = Result
public typealias Swift_Sendable = Sendable
public typealias Swift_Sequence = Sequence
public typealias Swift_Strideable = Strideable
public typealias Swift_String = Swift.String
public typealias Swift_UInt16 = UInt16
public typealias Swift_UInt32 = UInt32
public typealias Swift_UInt64 = UInt64
public typealias Swift_UInt8 = UInt8
public struct Swift_UnboundedRange_: Hashable, Codable, Sendable {}
public typealias Swift_UnsafeBufferPointer = UnsafeBufferPointer
public typealias Swift_UnsafeMutableBufferPointer = UnsafeMutableBufferPointer
public typealias Swift_UnsafeMutableRawBufferPointer = UnsafeMutableRawBufferPointer
public typealias Swift_UnsafeRawBufferPointer = UnsafeRawBufferPointer
public typealias Swift_UnsafeRawPointer = UnsafeRawPointer
public typealias __C_MLBatchProvider = MLBatchProvider
public typealias __C_MLCPUComputeDevice = MLCPUComputeDevice
public typealias __C_MLComputeDeviceProtocol = MLComputeDeviceProtocol
public typealias __C_MLComputeUnits = MLComputeUnits
public typealias __C_MLFeatureProvider = MLFeatureProvider
public typealias __C_MLFeatureType = MLFeatureType
public typealias __C_MLFeatureValue = MLFeatureValue
public typealias __C_MLGPUComputeDevice = MLGPUComputeDevice
public typealias __C_MLModel = MLModel
public typealias __C_MLModelAsset = MLModelAsset
public typealias __C_MLModelCollection = MLModelCollection
public typealias __C_MLModelConfiguration = MLModelConfiguration
public typealias __C_MLModelDescription = MLModelDescription
public typealias __C_MLModelSwiftEngine = MLModelSwiftEngine
public typealias __C_MLMultiArray = MLMultiArray
public typealias __C_MLMultiArrayDataType = MLMultiArrayDataType
public typealias __C_MLNeuralEngineComputeDevice = MLNeuralEngineComputeDevice
public typealias __C_MLPredictionOptions = MLPredictionOptions
public typealias __C_MLState = MLState
public typealias __C_MTLBuffer = MTLBuffer
public typealias __C_MTLComputePipelineState = MTLComputePipelineState
public typealias __C_MTLSharedEvent = MTLSharedEvent
public typealias __C_MTLTexture = MTLTexture
public typealias __C_NSProgress = NSProgress
public struct Deallocator: Hashable, Codable, Sendable {}
public struct End: Hashable, Codable, Sendable {}
public struct Extension: Hashable, Codable, Sendable {}
public struct ObjC: Hashable, Codable, Sendable {}
public struct RawSignificand: Hashable, Codable, Sendable {}
public struct Scalar: Hashable, Codable, Sendable {}
public struct UnboundedRange_: Hashable, Codable, Sendable {}

public func dummyDefaultValue<T>() -> T { fatalError() }

public struct GenericA: Hashable, Codable, Sendable {}
public struct GenericB: Hashable, Codable, Sendable {}
public struct GenericC: Hashable, Codable, Sendable {}
public struct GenericD: Hashable, Codable, Sendable {}
public struct A1: Hashable, Codable, Sendable {}
public struct B1: Hashable, Codable, Sendable {}
public struct C1: Hashable, Codable, Sendable {}
public struct D1: Hashable, Codable, Sendable {}

public struct _MLInternalNLPModelWriter: Hashable, Codable, Sendable {}

