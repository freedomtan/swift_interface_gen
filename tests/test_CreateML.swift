import Combine
import CoreGraphics
import CoreML
import Foundation
import TabularData
public struct DataSourceIssue: Codable, Hashable, @unchecked Sendable {
    public init(identifier: DataSourceIssue.Identifier, description: Swift.String, additionalInfo: [DataSourceIssue.AdditionalInfoKey : Swift.String]) { fatalError() }
    public var url: URL? { get { return nil } set {} }
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public var additionalInfo: [DataSourceIssue.AdditionalInfoKey : Swift.String] { get { return [:] } set {} }
    public var description: Swift.String { get { fatalError() } set {} }
    public var identifier: DataSourceIssue.Identifier { get { fatalError() } set {} }
    public struct AdditionalInfoKey: Codable, Hashable, @unchecked Sendable {
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public static var duration: AdditionalInfoKey { get { fatalError() } }
        public var hashValue: Swift.Int { get { fatalError() } }
        public static var label: AdditionalInfoKey { get { fatalError() } }
        public static var missingField: AdditionalInfoKey { get { fatalError() } }
        public func hash(into: inout Hasher) -> () {}
        public static var sampleRate: AdditionalInfoKey { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public struct Identifier: Codable, Hashable, RawRepresentable, @unchecked Sendable {
        public init(rawValue: Swift.String) { fatalError() }
        public static var incorrectTextEncoding: Identifier { get { fatalError() } }
        public static var invalidAnnotationFile: Identifier { get { fatalError() } }
        public static var invalidAudioDuration: Identifier { get { fatalError() } }
        public static var invalidAudioSampleRate: Identifier { get { fatalError() } }
        public static var invalidLabelName: Identifier { get { fatalError() } }
        public static var missingAnnotationField: Identifier { get { fatalError() } }
        public static var multipleAnnotationFiles: Identifier { get { fatalError() } }
        public static var noAnnotationFile: Identifier { get { fatalError() } }
        public static var noExamplesForLabel: Identifier { get { fatalError() } }
        public static var noValidExample: Identifier { get { fatalError() } }
        public var rawValue: Swift.String { get { fatalError() } set {} }
        public static var unreadableAudioFile: Identifier { get { fatalError() } }
        public static var unreadableImageFile: Identifier { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Identifier, _ rhs: Identifier) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct MLActionClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: MLActionClassifier.DataSource, parameters: MLActionClassifier.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public var modelParameters: MLActionClassifier.ModelParameters { get { fatalError() } }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public static func makeTrainingSession(trainingData: MLActionClassifier.DataSource, parameters: MLActionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLActionClassifier> { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public func evaluation(on: MLActionClassifier.DataSource) throws -> MLClassifierMetrics { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLActionClassifier> { fatalError() }
    public func predictions(from: [URL]) throws -> [[MLActionClassifier.Prediction]] { return [] }
    public static func train(trainingData: MLActionClassifier.DataSource, parameters: MLActionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLActionClassifier> { fatalError() }
    public func prediction(from: URL) throws -> [MLActionClassifier.Prediction] { return [] }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public static func resume(_ arg1: MLTrainingSession<MLActionClassifier>) throws -> MLJob<MLActionClassifier> { fatalError() }
    public var model: MLModel { get { fatalError() } }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case directoryWithVideosAndAnnotation(URL, URL, Swift.String, Swift.String, Swift.String?, Swift.String?)
        case labeledDirectories(labeledDirectories: URL)
        case labeledFiles(labeledFiles: URL)
        case labeledKeypointsData(MLDataTable, Swift.String, Swift.String, Swift.String)
        case labeledKeypointsDataFrame(TabularData.DataFrame, Swift.String, Swift.String, Swift.String)
        case labeledVideoData(MLDataTable, Swift.String, Swift.String, Swift.String?, Swift.String?)
        case labeledVideoDataFrame(TabularData.DataFrame, Swift.String, Swift.String, Swift.String?, Swift.String?)
        public func gatherAnnotatedFileNames() throws -> TabularData.DataFrame? { return nil }
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int, labelColumn: Swift.String) throws -> MLDataTable { fatalError() }
        public func extractKeypoints(targetFrameRate: Swift.Double) throws -> TabularData.DataFrame { fatalError() }
        public func keypointsWithAnnotations(targetFrameRate: Swift.Double) throws -> MLDataTable { fatalError() }
        public func videosWithAnnotations() throws -> MLDataTable { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLActionClassifier.ModelParameters.ValidationData, batchSize: Swift.Int, maximumIterations: Swift.Int, predictionWindowSize: Swift.Int, augmentationOptions: MLActionClassifier.VideoAugmentationOptions, algorithm: MLActionClassifier.ModelParameters.ModelAlgorithmType, targetFrameRate: Swift.Double) { fatalError() }
        public var algorithm: ModelAlgorithmType { get { fatalError() } set {} }
        public var augmentationOptions: MLActionClassifier.VideoAugmentationOptions { get { fatalError() } set {} }
        public var batchSize: Swift.Int { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maximumIterations: Swift.Int { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var predictionWindowSize: Swift.Int { get { fatalError() } set {} }
        public var targetFrameRate: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public enum ModelAlgorithmType: Codable, Hashable, @unchecked Sendable {
            case stgcn
            public func hash(into: inout Hasher) -> () {}
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public var hashValue: Swift.Int { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataSource(_: MLActionClassifier.DataSource)
            case none
            case split(split: MLSplitStrategy)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct Prediction: Codable, Hashable, @unchecked Sendable {
        public var frameRange: Range<Swift.Int> { get { fatalError() } set {} }
        public var results: [(label: Swift.String, confidence: Swift.Double)] { get { return [] } set {} }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Prediction, _ rhs: Prediction) -> Bool { fatalError() }
    }
    public struct VideoAugmentationOptions: Codable, ExpressibleByArrayLiteral, Hashable, OptionSet, RawRepresentable, @unchecked Sendable, SetAlgebra {
        public init(rawValue: Swift.Int) { fatalError() }
        public static var horizontalFlip: VideoAugmentationOptions { get { fatalError() } }
        public var rawValue: Swift.Int { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: VideoAugmentationOptions, _ rhs: VideoAugmentationOptions) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var batchSize: Swift.Int { get { fatalError() } }
        public static var endTimeColumnName: Swift.String { get { fatalError() } }
        public static var featureColumnName: Swift.String { get { fatalError() } }
        public static var labelColumnName: Swift.String { get { fatalError() } }
        public static var maximumIterations: Swift.Int { get { fatalError() } }
        public static var predictionWindowSize: Swift.Int { get { fatalError() } }
        public static var sessionIdColumnName: Swift.String { get { fatalError() } }
        public static var startTimeColumnName: Swift.String { get { fatalError() } }
        public static var targetFrameRate: Swift.Double { get { fatalError() } }
        public static var videoColumnName: Swift.String { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLActionClassifier, _ rhs: MLActionClassifier) -> Bool { fatalError() }
}
public struct MLActivityClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: MLActivityClassifier.DataSource, featureColumns: [Swift.String], labelColumn: Swift.String?, recordingFileColumn: Swift.String?, parameters: MLActivityClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String, parameters: MLActivityClassifier.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public func evaluation(on: MLDataTable, featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String) -> MLClassifierMetrics { fatalError() }
    public func predictions(from: MLDataTable, perWindowPrediction: Swift.Bool?) throws -> [Swift.String] { return [] }
    public static func resume(_ arg1: MLTrainingSession<MLActivityClassifier>) throws -> MLJob<MLActivityClassifier> { fatalError() }
    public var labelColumn: Swift.String { get { fatalError() } set {} }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLActivityClassifier> { fatalError() }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public static func makeTrainingSession(trainingData: MLActivityClassifier.DataSource, featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String, parameters: MLActivityClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLActivityClassifier> { fatalError() }
    public static func train(trainingData: MLActivityClassifier.DataSource, featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String, parameters: MLActivityClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLActivityClassifier> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var description: Swift.String { get { fatalError() } }
    public var recordingFileColumn: Swift.String { get { fatalError() } set {} }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public func evaluation(on: MLActivityClassifier.DataSource, featureColumns: [Swift.String], labelColumn: Swift.String?, recordingFileColumn: Swift.String?) -> MLClassifierMetrics { fatalError() }
    public static func makeTrainingSession(trainingData: MLDataTable, featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String, parameters: MLActivityClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLActivityClassifier> { fatalError() }
    public var modelParameters: MLActivityClassifier.ModelParameters { get { fatalError() } }
    public static func train(trainingData: MLDataTable, featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String, parameters: MLActivityClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLActivityClassifier> { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public func predictions(from: TabularData.DataFrame, perWindowPrediction: Swift.Bool?) throws -> [Swift.String] { return [] }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case dataFrame(_: TabularData.DataFrame)
        case directoryWithDataAndAnnotation(URL, Swift.String, Swift.String, Swift.String, Swift.String)
        case labeledDirectories(labeledDirectories: URL)
        public func gatherAnnotatedFeatures(featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String?) throws -> TabularData.DataFrame { fatalError() }
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int, featureColumns: [Swift.String], labelColumn: Swift.String, recordingFileColumn: Swift.String) throws -> MLDataTable { fatalError() }
        public func labeledSensorData(featureColumns: [Swift.String], labelColumn: Swift.String?, recordingFileColumn: Swift.String?) throws -> MLDataTable { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validationData: MLDataTable?, batchSize: Swift.Int?, maximumIterations: Swift.Int?, predictionWindowSize: Swift.Int?) { fatalError() }
        public init(validationData: MLActivityClassifier.DataSource, batchSize: Swift.Int?, maximumIterations: Swift.Int?, predictionWindowSize: Swift.Int?) { fatalError() }
        public init(validation: MLActivityClassifier.ModelParameters.Validation, batchSize: Swift.Int?, maximumIterations: Swift.Int?, predictionWindowSize: Swift.Int?) { fatalError() }
        public var batchSize: Swift.Int? { get { return nil } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maximumIterations: Swift.Int? { get { return nil } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var predictionWindowSize: Swift.Int? { get { return nil } set {} }
        public var validation: Validation { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum Validation: Codable, Hashable, @unchecked Sendable {
            case dataSource(_: MLActivityClassifier.DataSource)
            case none
            case split(split: MLSplitStrategy)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Validation, _ rhs: Validation) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLActivityClassifier, _ rhs: MLActivityClassifier) -> Bool { fatalError() }
}
public struct MLBoostedTreeClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeClassifier.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLBoostedTreeClassifier> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLBoostedTreeClassifier> { fatalError() }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLBoostedTreeClassifier> { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLBoostedTreeClassifier> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public func evaluation(on: MLDataTable) -> MLClassifierMetrics { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var model: MLModel { get { fatalError() } set {} }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLBoostedTreeClassifier> { fatalError() }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public var modelParameters: MLBoostedTreeClassifier.ModelParameters { get { fatalError() } }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func evaluation(on: TabularData.DataFrame) -> MLClassifierMetrics { fatalError() }
    public static func resume(_ arg1: MLTrainingSession<MLBoostedTreeClassifier>) throws -> MLJob<MLBoostedTreeClassifier> { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validationData: MLDataTable?, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, stepSize: Swift.Double, earlyStoppingRounds: Swift.Int?, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public init(validation: MLBoostedTreeClassifier.ModelParameters.ValidationData, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, stepSize: Swift.Double, earlyStoppingRounds: Swift.Int?, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public var columnSubsample: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var earlyStoppingRounds: Swift.Int? { get { return nil } set {} }
        public var maxDepth: Swift.Int { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var minChildWeight: Swift.Double { get { fatalError() } set {} }
        public var minLossReduction: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var randomSeed: Swift.Int { get { fatalError() } set {} }
        public var rowSubsample: Swift.Double { get { fatalError() } set {} }
        public var stepSize: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLBoostedTreeClassifier, _ rhs: MLBoostedTreeClassifier) -> Bool { fatalError() }
}
public struct MLBoostedTreeRegressor: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeRegressor.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeRegressor.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public static func resume(_ arg1: MLTrainingSession<MLBoostedTreeRegressor>) throws -> MLJob<MLBoostedTreeRegressor> { fatalError() }
    public var modelParameters: MLBoostedTreeRegressor.ModelParameters { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLBoostedTreeRegressor> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public func evaluation(on: MLDataTable) -> MLRegressorMetrics { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLBoostedTreeRegressor> { fatalError() }
    public var trainingMetrics: MLRegressorMetrics { get { fatalError() } }
    public func evaluation(on: TabularData.DataFrame) -> MLRegressorMetrics { fatalError() }
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLBoostedTreeRegressor> { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLBoostedTreeRegressor> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLBoostedTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLBoostedTreeRegressor> { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var validationMetrics: MLRegressorMetrics { get { fatalError() } }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLBoostedTreeRegressor.ModelParameters.ValidationData, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, stepSize: Swift.Double, earlyStoppingRounds: Swift.Int?, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public init(validationData: MLDataTable?, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, stepSize: Swift.Double, earlyStoppingRounds: Swift.Int?, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public var columnSubsample: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var earlyStoppingRounds: Swift.Int? { get { return nil } set {} }
        public var maxDepth: Swift.Int { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var minChildWeight: Swift.Double { get { fatalError() } set {} }
        public var minLossReduction: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var randomSeed: Swift.Int { get { fatalError() } set {} }
        public var rowSubsample: Swift.Double { get { fatalError() } set {} }
        public var stepSize: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLBoostedTreeRegressor, _ rhs: MLBoostedTreeRegressor) -> Bool { fatalError() }
}
public enum MLBoundingBoxAnchor: Codable, Hashable, @unchecked Sendable {
    case bottomLeft
    case center
    case topLeft
    public func hash(into: inout Hasher) -> () {}
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public var hashValue: Swift.Int { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
}
public enum MLBoundingBoxCoordinatesOrigin: Codable, Hashable, @unchecked Sendable {
    case bottomLeft
    case topLeft
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public func hash(into: inout Hasher) -> () {}
    public var hashValue: Swift.Int { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
}
public enum MLBoundingBoxUnits: Codable, Hashable, @unchecked Sendable {
    case normalized
    case pixel
    public func hash(into: inout Hasher) -> () {}
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public var hashValue: Swift.Int { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
}
public struct MLCheckpoint: Codable, Hashable, @unchecked Sendable {
    public init(from: Swift.Decoder) throws { fatalError() }
    public var date: Date { get { fatalError() } set {} }
    public var iteration: Swift.Int { get { fatalError() } set {} }
    public var metrics: [MLProgress.Metric : Any] { get { return [:] } set {} }
    public var url: URL { get { fatalError() } set {} }
    public func encode(to: Swift.Encoder) throws -> () {}
    public var phase: MLPhase { get { fatalError() } set {} }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLCheckpoint, _ rhs: MLCheckpoint) -> Bool { fatalError() }
}
public enum MLClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    case boostedTree(_: MLBoostedTreeClassifier)
    case decisionTree(_: MLDecisionTreeClassifier)
    case logisticRegression(_: MLLogisticRegressionClassifier)
    case randomForest(_: MLRandomForestClassifier)
    case supportVector(_: MLSupportVectorClassifier)
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?) throws { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public var model: MLModel { get { fatalError() } }
    public var targetColumn: Swift.String { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public func evaluation(on: MLDataTable) -> MLClassifierMetrics { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public var featureColumns: [Swift.String] { get { return [] } }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public func evaluation(on: TabularData.DataFrame) -> MLClassifierMetrics { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLClassifier, _ rhs: MLClassifier) -> Bool { fatalError() }
}
public struct MLClassifierMetrics: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(classificationError: Swift.Double, confusion: MLDataTable, precisionRecall: MLDataTable) { fatalError() }
    public var classificationError: Swift.Double { get { fatalError() } }
    public var confusion: MLDataTable { get { fatalError() } }
    public var confusionDataFrame: TabularData.DataFrame { get { fatalError() } }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var error: (any Error)? { get { return nil } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public var precisionRecall: MLDataTable { get { fatalError() } }
    public var precisionRecallDataFrame: TabularData.DataFrame { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLClassifierMetrics, _ rhs: MLClassifierMetrics) -> Bool { fatalError() }
}
public enum MLCreateError: Codable, CustomDebugStringConvertible, CustomNSError, CustomStringConvertible, Error, Hashable, LocalizedError, @unchecked Sendable {
    case cancelled
    case generic(generic: Swift.String)
    case incompatibleParameters(Swift.String, Swift.String, Swift.String)
    case io(io: Swift.String)
    case modifiedTrainingData
    case type(type: Swift.String)
    public var debugDescription: Swift.String { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var errorCode: Swift.Int { get { fatalError() } }
    public var errorDescription: Swift.String? { get { return nil } }
    public static var errorDomain: Swift.String { get { fatalError() } }
    public var errorUserInfo: [Swift.String : Any] { get { return [:] } }
    public var failureReason: Swift.String? { get { return nil } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLCreateError, _ rhs: MLCreateError) -> Bool { fatalError() }
}
public struct MLDataColumn<A>: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init<A1>(_ arg1: A1) where A == A1.Element, A1: Sequence { fatalError() }
    public init() { fatalError() }
    public init(repeating: MLDataValue, count: Swift.Int) { fatalError() }
    public init(repeating: A, count: Swift.Int) { fatalError() }
    public static func == (lhs: A, rhs: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public var count: Swift.Int { get { fatalError() } }
    public var error: Error? { get { return nil } }
    public static func !=(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public subscript<GenericA>(_ arg1: GenericA) -> MLDataColumn<A> where GenericA: RangeExpression, GenericA.Bound == Swift.Int { get { fatalError() } }
    public func map<GenericA>(_ arg1: @escaping (_ arg1: A) -> GenericA?) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public static func >=(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public subscript(_ arg1: Swift.Int) -> A { get { fatalError() } }
    public var customMirror: Mirror { get { fatalError() } }
    public static func == (lhs: Self, rhs: Self) -> MLDataColumn<Swift.Bool> { fatalError() }
    public subscript(_ arg1: Range<Swift.Int>) -> MLDataColumn<A> { get { fatalError() } }
    public subscript(_ arg1: MLUntypedColumn) -> MLDataColumn<A> { get { fatalError() } }
    public var debugDescription: Swift.String { get { fatalError() } }
    public func show() -> any MLStreamingVisualizable { fatalError() }
    public func element(at: Swift.Int) -> A? { return nil }
    public static func >(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public func copy() -> MLDataColumn<A> { fatalError() }
    public func fillMissing(with: A) -> MLDataColumn<A> { fatalError() }
    public func map<GenericA>(to: GenericA.Type) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public static func !=(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
    public func prefix(_ arg1: Swift.Int) -> MLDataColumn<A> { fatalError() }
    public static func <(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public func map<GenericA>(_ arg1: @escaping (_ arg1: A) -> GenericA) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public func suffix(_ arg1: Swift.Int) -> MLDataColumn<A> { fatalError() }
    public func mapMissing<GenericA>(_ arg1: @escaping (_ arg1: A?) -> GenericA?) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public func materialize() throws -> MLDataColumn<A> { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public static func >=(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
    public func dropMissing() -> MLDataColumn<A> { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func <(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
    public static func >(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
    public var isEmpty: Swift.Bool { get { fatalError() } }
    public static func >(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public static func <=(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public static func >=(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public static func <=(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
    public var isValid: Swift.Bool { get { fatalError() } }
    public static func <=(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public func append(contentsOf: MLDataColumn<A>) -> () {}
    public func dropDuplicates() -> MLDataColumn<A> { fatalError() }
    public static func <(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public subscript(_ arg1: MLDataColumn<Swift.Bool>) -> MLDataColumn<A> { get { fatalError() } }
    public static func == (lhs: MLDataColumn<A>, rhs: A) -> MLDataColumn<Swift.Bool> { fatalError() }
    public static func !=(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public func sort(byIncreasingOrder: Swift.Bool) -> MLDataColumn<A> { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public struct MLDataTable: Codable, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(contentsOf: URL, options: MLDataTable.ParsingOptions) throws { fatalError() }
    public init(namedColumns: [Swift.String : MLUntypedColumn]) throws { fatalError() }
    public init() { fatalError() }
    public init(dictionary: [Swift.String : any MLDataValueConvertible]) throws { fatalError() }
    public func suffix(_ arg1: Swift.Int) -> MLDataTable { fatalError() }
    public func prefix(_ arg1: Swift.Int) -> MLDataTable { fatalError() }
    public func intersect<GenericA>(_: GenericA..., of: Swift.String) -> MLDataTable where GenericA: MLDataValueConvertible { fatalError() }
    public func dropMissing() -> MLDataTable { fatalError() }
    public subscript<GenericA>(_ arg1: GenericA) -> MLDataTable where GenericA: any Sequence, GenericA.Element == Swift.String { get { fatalError() } }
    public subscript<GenericA>(_ arg1: Swift.String) -> MLDataColumn<GenericA> where GenericA: any MLDataValueConvertible { get { fatalError() } set {} }
    public var description: Swift.String { get { fatalError() } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public func fillMissing(columnNamed: Swift.String, with: MLDataValue) -> MLDataTable { fatalError() }
    public func addColumn<GenericA>(_: MLDataColumn<GenericA>, named: Swift.String) -> () where GenericA: MLDataValueConvertible {}
    public func sort(columnNamed: Swift.String, byIncreasingOrder: Swift.Bool) -> MLDataTable { fatalError() }
    public subscript<GenericA>(_ arg1: GenericA) -> MLDataTable where GenericA: RangeExpression, GenericA.Bound == Swift.Int { get { fatalError() } }
    public func stratifiedSplitBySequence(proportions: [Swift.Double], by: Swift.String, on: Swift.String, seed: Swift.Int) throws -> MLDataTable { fatalError() }
    public func writeCSV(toFile: Swift.String) throws -> () {}
    public func randomSample(by: Swift.Double, seed: Swift.Int) -> MLDataTable { fatalError() }
    public subscript(_ arg1: MLUntypedColumn) -> MLDataTable { get { fatalError() } }
    public func condense(columnNamed: Swift.String, to: Swift.String) -> MLDataTable { fatalError() }
    public func stratifiedSplit(proportions: [Swift.Double], on: Swift.String, seed: Swift.Int) throws -> MLDataTable { fatalError() }
    public subscript(_ arg1: Swift.String) -> MLUntypedColumn { get { fatalError() } set {} }
    public func pack(columnsNamed: Swift.String..., to: Swift.String, type: MLDataTable.PackType, filling: MLDataValue) -> MLDataTable { fatalError() }
    public func write(toDirectory: Swift.String) throws -> () {}
    public func dropDuplicates() -> MLDataTable { fatalError() }
    public subscript<GenericA>(_ arg1: Swift.String, _ arg2: GenericA.Type) -> MLDataColumn<GenericA>? where GenericA: any MLDataValueConvertible { get { return nil } }
    public func renameColumn(named: Swift.String, to: Swift.String) -> () {}
    public subscript(_ arg1: Range<Swift.Int>) -> MLDataTable { get { fatalError() } }
    public var columnTypes: [Swift.String : MLDataValue.ValueType] { get { return [:] } }
    public func unpack(columnNamed: Swift.String, valueTypes: [MLDataValue.ValueType]?, indexSubset: [Swift.Int]?, keySubset: [Swift.String]?) -> MLDataTable { fatalError() }
    public func map<GenericA>(_ arg1: @escaping (_ arg1: MLDataTable.Row) -> GenericA) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public func removeColumn(named: Swift.String) -> () {}
    public func randomSplit(by: Swift.Double, seed: Swift.Int) -> (MLDataTable, MLDataTable) { fatalError() }
    public func join(with: MLDataTable, on: Swift.String..., type: MLDataTable.JoinType) -> MLDataTable { fatalError() }
    public func exclude<GenericA>(_: GenericA..., of: Swift.String) -> MLDataTable where GenericA: MLDataValueConvertible { fatalError() }
    public var size: (rows: Swift.Int, columns: Swift.Int) { get { fatalError() } }
    public func addColumn(_: MLUntypedColumn, named: Swift.String) -> () {}
    public var columnNames: MLDataTable.ColumnNames { get { fatalError() } }
    public func show() -> any MLStreamingVisualizable { fatalError() }
    public func stratifiedSplit<GenericA>(proportions: [Swift.Double], on: Swift.String, generator: inout GenericA) throws -> MLDataTable where GenericA: RandomNumberGenerator { fatalError() }
    public func map<GenericA>(_ arg1: @escaping (_ arg1: MLDataTable.Row) -> GenericA?) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public func append(contentsOf: MLDataTable) -> () {}
    public subscript(_ arg1: MLDataColumn<Swift.Bool>) -> MLDataTable { get { fatalError() } }
    public func write(to: URL) throws -> () {}
    public var error: Error? { get { return nil } }
    public func writeCSV(to: URL) throws -> () {}
    public func group<GenericA>(columnsNamed: Swift.String..., aggregators: GenericA) -> MLDataTable where GenericA: Sequence, GenericA.Element == Aggregator { fatalError() }
    public func stratifiedSplitBySequence<GenericA>(proportions: [Swift.Double], by: Swift.String, on: Swift.String, generator: inout GenericA) throws -> MLDataTable where GenericA: RandomNumberGenerator { fatalError() }
    public var rows: MLDataTable.Rows { get { fatalError() } }
    public func expand(columnNamed: Swift.String, to: Swift.String) -> MLDataTable { fatalError() }
    public func randomSplitBySequence(proportion: Swift.Double, by: Swift.String, on: Swift.String, seed: Swift.Int) -> (MLDataTable, remaining: MLDataTable) { fatalError() }
    public struct Aggregator: Codable, Hashable, @unchecked Sendable {
        public init(operations: MLDataTable.Aggregator.Operations..., of: Swift.String) { fatalError() }
        public var columnName: Swift.String { get { fatalError() } set {} }
        public var operations: [MLDataTable.Aggregator.Operations] { get { return [] } set {} }
        public enum Operations: Codable, Hashable, @unchecked Sendable {
            case argmax(argmax: Swift.String)
            case argmin(argmin: Swift.String)
            case count
            case dictionaryMerge(dictionaryMerge: Swift.String)
            case distinctCount
            case max
            case mean
            case min
            case randomlySelectOne
            case sequenceMerge
            case stdev
            case sum
            case variance
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: Operations, _ rhs: Operations) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Aggregator, _ rhs: Aggregator) -> Bool { fatalError() }
    }
    public struct ColumnNames: BidirectionalCollection, Codable, Collection, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, RandomAccessCollection, @unchecked Sendable, Sequence {
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public subscript(_ arg1: Swift.Int) -> Swift.String { get { fatalError() } }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var endIndex: Swift.Int { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public var startIndex: Swift.Int { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum JoinType: Codable, Hashable, @unchecked Sendable {
        case inner
        case left
        case outer
        case right
        public func hash(into: inout Hasher) -> () {}
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public var hashValue: Swift.Int { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public enum PackType: Codable, Hashable, @unchecked Sendable {
        case dictionary
        case sequence
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public var hashValue: Swift.Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () {}
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public struct ParsingOptions: Codable, Hashable, @unchecked Sendable {
        public init(containsHeader: Swift.Bool, delimiter: Swift.String, comment: Swift.String, escape: Swift.String, doubleQuote: Swift.Bool, quote: Swift.String, skipInitialSpaces: Swift.Bool, missingValues: [Swift.String], lineTerminator: Swift.String, selectColumns: [Swift.String]?, maxRows: Swift.Int?, skipRows: Swift.Int) { fatalError() }
        public var comment: Swift.String { get { fatalError() } set {} }
        public var containsHeader: Swift.Bool { get { fatalError() } set {} }
        public var delimiter: Swift.String { get { fatalError() } set {} }
        public var doubleQuote: Swift.Bool { get { fatalError() } set {} }
        public var escape: Swift.String { get { fatalError() } set {} }
        public var lineTerminator: Swift.String { get { fatalError() } set {} }
        public var maxRows: Swift.Int? { get { return nil } set {} }
        public var missingValues: [Swift.String] { get { return [] } set {} }
        public var quote: Swift.String { get { fatalError() } set {} }
        public var selectColumns: [Swift.String]? { get { return nil } set {} }
        public var skipInitialSpaces: Swift.Bool { get { fatalError() } set {} }
        public var skipRows: Swift.Int { get { fatalError() } set {} }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ParsingOptions, _ rhs: ParsingOptions) -> Bool { fatalError() }
    }
    public struct Row: Codable, Collection, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable, Sequence {
        public subscript<GenericA>(_ arg1: Swift.String, _ arg2: GenericA.Type) -> GenericA? where GenericA: any MLDataValueConvertible { get { return nil } }
        public var keys: MLDataTable.ColumnNames { get { fatalError() } }
        public func index(after: Swift.Int) -> Swift.Int { fatalError() }
        public var endIndex: Swift.Int { get { fatalError() } }
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public subscript(_ arg1: Swift.String) -> MLDataValue? { get { return nil } }
        public var playgroundDescription: Any { get { fatalError() } }
        public var startIndex: Swift.Int { get { fatalError() } }
        public var values: Values { get { fatalError() } }
        public func index(forKey: Swift.String) -> Swift.Int? { return nil }
        public subscript(_ arg1: Swift.Int) -> (Swift.String, MLDataValue) { get { fatalError() } }
        public var count: Swift.Int { get { fatalError() } }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var isEmpty: Swift.Bool { get { fatalError() } }
        public struct Values: BidirectionalCollection, Codable, Collection, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, RandomAccessCollection, @unchecked Sendable, Sequence {
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public subscript(_ arg1: Swift.Int) -> MLDataValue { get { fatalError() } }
            public var debugDescription: Swift.String { get { fatalError() } }
            public var description: Swift.String { get { fatalError() } }
            public var endIndex: Swift.Int { get { fatalError() } }
            public var playgroundDescription: Any { get { fatalError() } }
            public var startIndex: Swift.Int { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct Rows: BidirectionalCollection, Codable, Collection, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, RandomAccessCollection, @unchecked Sendable, Sequence {
        public subscript(_ arg1: Swift.Int) -> MLDataTable.Row { get { fatalError() } }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var endIndex: Swift.Int { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public var startIndex: Swift.Int { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Rows, _ rhs: Rows) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLDataTable, _ rhs: MLDataTable) -> Bool { fatalError() }
}
public enum MLDataValue: Codable, CustomDebugStringConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    indirect case dictionary(_: MLDataValue.DictionaryType)
    case double(_: Swift.Double)
    case int(_: Swift.Int)
    case invalid
    indirect case multiArray(_: MLDataValue.MultiArrayType)
    indirect case sequence(_: MLDataValue.SequenceType)
    case string(_: Swift.String)
    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
    public var dictionaryValue: MLDataValue.DictionaryType? { get { return nil } }
    public var doubleValue: Swift.Double? { get { return nil } }
    public var intValue: Swift.Int? { get { return nil } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public var type: MLDataValue.ValueType { get { fatalError() } }
    public func hash(into: inout Hasher) -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var hashValue: Swift.Int { get { fatalError() } }
    public var multiArrayValue: MLDataValue.MultiArrayType? { get { return nil } }
    public var sequenceValue: MLDataValue.SequenceType? { get { return nil } }
    public var stringValue: Swift.String? { get { return nil } }
    public struct DictionaryType: Codable, Collection, CustomDebugStringConvertible, CustomStringConvertible, Hashable, MLDataValueConvertible, @unchecked Sendable, Sequence {
        public init(_ arg1: [MLDataValue : MLDataValue]) { fatalError() }
        public init?(from: MLDataValue) { fatalError() }
        public init() { fatalError() }
        public subscript(_ arg1: MLDataValue) -> MLDataValue? { get { return nil } }
        public var count: Swift.Int { get { fatalError() } }
        public static var dataValueType: MLDataValue.ValueType { get { fatalError() } }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var endIndex: Index { get { fatalError() } }
        public var startIndex: Index { get { fatalError() } }
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public subscript(_ arg1: Index) -> (key: MLDataValue, value: MLDataValue) { get { fatalError() } }
        public func index(after: Index) -> Index { fatalError() }
        public var dataValue: MLDataValue { get { fatalError() } }
        public func init(Any) where Any: Sequence, Any ==(MLDataValue, MLDataValue) -> DictionaryType { fatalError() }
        public var isEmpty: Swift.Bool { get { fatalError() } }
        public struct Index: Codable, Comparable, Hashable, @unchecked Sendable {
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public static func <(_ arg1: Index, _ arg2: Index) -> Swift.Bool { fatalError() }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct MultiArrayType: Codable, CustomDebugStringConvertible, CustomStringConvertible, Hashable, MLDataValueConvertible, @unchecked Sendable {
        public init(_ arg1: MLMultiArray) { fatalError() }
        public init?(from: MLDataValue) { fatalError() }
        public init() { fatalError() }
        public init(shape: [Swift.Int]) { fatalError() }
        public subscript(_ arg1: [Swift.Int]) -> Swift.Double { get { fatalError() } }
        public subscript(_ arg1: Swift.Int) -> Swift.Double { get { fatalError() } }
        public var dataValue: MLDataValue { get { fatalError() } }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var mlMultiArray: MLMultiArray { get { fatalError() } }
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public static var dataValueType: MLDataValue.ValueType { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct SequenceType: BidirectionalCollection, Codable, Collection, CustomDebugStringConvertible, CustomStringConvertible, ExpressibleByArrayLiteral, Hashable, MLDataValueConvertible, RandomAccessCollection, @unchecked Sendable, Sequence {
        public init() { fatalError() }
        public init<A>(_ arg1: A) where A: Sequence, A.Element == MLDataValue { fatalError() }
        public init<A>(_ arg1: A) where A: Sequence, A.Element: MLDataValueConvertible { fatalError() }
        public init(arrayLiteral: MLDataValue...) { fatalError() }
        public init?(from: MLDataValue) { fatalError() }
        public var dataValue: MLDataValue { get { fatalError() } }
        public static var dataValueType: MLDataValue.ValueType { get { fatalError() } }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var endIndex: Swift.Int { get { fatalError() } }
        public var startIndex: Swift.Int { get { fatalError() } }
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public subscript(_ arg1: Swift.Int) -> MLDataValue { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum ValueType: Codable, CustomDebugStringConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case dictionary
        case double
        case int
        case invalid
        case multiArray
        case sequence
        case string
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public var description: Swift.String { get { fatalError() } }
        public var hashValue: Swift.Int { get { fatalError() } }
        public func hash(into: inout Hasher) -> () {}
        public var debugDescription: Swift.String { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
}
public protocol MLDataValueConvertible {
    init?(from: MLDataValue)
    init()
    var dataValue: MLDataValue { get }
    static var dataValueType: MLDataValue.ValueType { get }
}
public struct MLDecisionTreeClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeClassifier.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLDecisionTreeClassifier> { fatalError() }
    public func evaluation(on: TabularData.DataFrame) -> MLClassifierMetrics { fatalError() }
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLDecisionTreeClassifier> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLDecisionTreeClassifier> { fatalError() }
    public var modelParameters: MLDecisionTreeClassifier.ModelParameters { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLDecisionTreeClassifier> { fatalError() }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public static func resume(_ arg1: MLTrainingSession<MLDecisionTreeClassifier>) throws -> MLJob<MLDecisionTreeClassifier> { fatalError() }
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLDecisionTreeClassifier> { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func evaluation(on: MLDataTable) -> MLClassifierMetrics { fatalError() }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var description: Swift.String { get { fatalError() } }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validationData: MLDataTable?, maxDepth: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int) { fatalError() }
        public init(validation: MLDecisionTreeClassifier.ModelParameters.ValidationData, maxDepth: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int) { fatalError() }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maxDepth: Swift.Int { get { fatalError() } set {} }
        public var minChildWeight: Swift.Double { get { fatalError() } set {} }
        public var minLossReduction: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var randomSeed: Swift.Int { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLDecisionTreeClassifier, _ rhs: MLDecisionTreeClassifier) -> Bool { fatalError() }
}
public struct MLDecisionTreeRegressor: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeRegressor.ModelParameters) throws { fatalError() }
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeRegressor.ModelParameters) throws { fatalError() }
    public func evaluation(on: MLDataTable) -> MLRegressorMetrics { fatalError() }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLDecisionTreeRegressor> { fatalError() }
    public func evaluation(on: TabularData.DataFrame) -> MLRegressorMetrics { fatalError() }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLDecisionTreeRegressor> { fatalError() }
    public static func resume(_ arg1: MLTrainingSession<MLDecisionTreeRegressor>) throws -> MLJob<MLDecisionTreeRegressor> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var model: MLModel { get { fatalError() } set {} }
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLDecisionTreeRegressor> { fatalError() }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLDecisionTreeRegressor> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLDecisionTreeRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLDecisionTreeRegressor> { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public var modelParameters: MLDecisionTreeRegressor.ModelParameters { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public var trainingMetrics: MLRegressorMetrics { get { fatalError() } }
    public var validationMetrics: MLRegressorMetrics { get { fatalError() } }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLDecisionTreeRegressor.ModelParameters.ValidationData, maxDepth: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int) { fatalError() }
        public init(validationData: MLDataTable?, maxDepth: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int) { fatalError() }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maxDepth: Swift.Int { get { fatalError() } set {} }
        public var minChildWeight: Swift.Double { get { fatalError() } set {} }
        public var minLossReduction: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var randomSeed: Swift.Int { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLDecisionTreeRegressor, _ rhs: MLDecisionTreeRegressor) -> Bool { fatalError() }
}
public struct MLFewShotSoundClassifier: Codable, Hashable, @unchecked Sendable {
    public init(trainingData: MLFewShotSoundClassifier.DataSource, modelParameters: MLFewShotSoundClassifier.ModelParameters) throws { fatalError() }
    public var modelParameters: MLFewShotSoundClassifier.ModelParameters { get { fatalError() } }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } set {} }
    public var validationLoss: Swift.Double { get { fatalError() } set {} }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } set {} }
    public func write(to: URL) throws -> () {}
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case directory(directory: URL)
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, Hashable, @unchecked Sendable {
        public init(maxIterations: Swift.Int, hallucinator: URL, pretrainedModel: URL?) { fatalError() }
        public init(maxIterations: Swift.Int, batchSize: Swift.Int, learningRate: Swift.Float, lossParameters: MLFewShotSoundClassifier.ModelParameters.LossParameters, hallucinator: URL, pretrainedModel: URL?) { fatalError() }
        public var batchSize: Swift.Int { get { fatalError() } set {} }
        public var hallucinator: URL { get { fatalError() } set {} }
        public var learningRate: Swift.Float { get { fatalError() } set {} }
        public var lossParameters: LossParameters { get { fatalError() } set {} }
        public var lossParamters: LossParameters { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var pretrainedModel: URL? { get { return nil } set {} }
        public struct LossParameters: Codable, Hashable, @unchecked Sendable {
            public init(gamma: Swift.Float, epsilon: Swift.Float, alpha: Swift.Float) { fatalError() }
            public var alpha: Swift.Float { get { fatalError() } set {} }
            public var epsilon: Swift.Float { get { fatalError() } set {} }
            public var gamma: Swift.Float { get { fatalError() } set {} }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: LossParameters, _ rhs: LossParameters) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var alpha: Swift.Float { get { fatalError() } }
        public static var batchSize: Swift.Int { get { fatalError() } }
        public static var epsilon: Swift.Float { get { fatalError() } }
        public static var gamma: Swift.Float { get { fatalError() } }
        public static var learningRate: Swift.Float { get { fatalError() } }
        public static var maxIterations: Swift.Int { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLFewShotSoundClassifier, _ rhs: MLFewShotSoundClassifier) -> Bool { fatalError() }
}
public struct MLGazetteer: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(labeledData: MLDataTable, textColumn: Swift.String, labelColumn: Swift.String, parameters: MLGazetteer.ModelParameters) throws { fatalError() }
    public init(dictionary: [Swift.String : [Swift.String]], parameters: MLGazetteer.ModelParameters) throws { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public func predictions(from: [Swift.String]) throws -> [Swift.String] { return [] }
    public func predictions(from: MLDataColumn<Swift.String>) throws -> MLDataColumn<Swift.String> { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public var model: MLModel { get { fatalError() } set {} }
    public func prediction(from: Swift.String) throws -> Swift.String { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var modelParameters: MLGazetteer.ModelParameters { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(language: NLLanguage?) { fatalError() }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var language: NLLanguage? { get { return nil } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLGazetteer, _ rhs: MLGazetteer) -> Bool { fatalError() }
}
public struct MLHandActionClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: MLHandActionClassifier.DataSource, parameters: MLHandActionClassifier.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func makeTrainingSession(trainingData: MLHandActionClassifier.DataSource, parameters: MLHandActionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLHandActionClassifier> { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public var model: MLModel { get { fatalError() } set {} }
    public func evaluation(on: MLHandActionClassifier.DataSource) throws -> MLClassifierMetrics { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLHandActionClassifier> { fatalError() }
    public var modelParameters: MLHandActionClassifier.ModelParameters { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } set {} }
    public static func resume(_ arg1: MLTrainingSession<MLHandActionClassifier>) throws -> MLJob<MLHandActionClassifier> { fatalError() }
    public func predictions(from: [URL]) throws -> [[MLHandActionClassifier.Prediction]] { return [] }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } set {} }
    public func prediction(from: URL) throws -> [MLHandActionClassifier.Prediction] { return [] }
    public static func train(trainingData: MLHandActionClassifier.DataSource, parameters: MLHandActionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLHandActionClassifier> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var playgroundDescription: Any { get { fatalError() } }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case directoryWithVideosAndAnnotation(URL, URL, Swift.String, Swift.String, Swift.String?, Swift.String?)
        case labeledDirectories(labeledDirectories: URL)
        case labeledFiles(labeledFiles: URL)
        case labeledKeypointsData(MLDataTable, Swift.String, Swift.String, Swift.String)
        case labeledKeypointsDataFrame(TabularData.DataFrame, Swift.String, Swift.String, Swift.String)
        case labeledVideoData(MLDataTable, Swift.String, Swift.String, Swift.String?, Swift.String?)
        case labeledVideoDataFrame(TabularData.DataFrame, Swift.String, Swift.String, Swift.String?, Swift.String?)
        public func labeledMedia() throws -> [Swift.String : [URL]] { return [:] }
        public func gatherAnnotatedFileNames() throws -> TabularData.DataFrame? { return nil }
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int, labelColumn: Swift.String) throws -> MLDataTable { fatalError() }
        public func extractKeypoints(targetFrameRate: Swift.Double) throws -> TabularData.DataFrame { fatalError() }
        public func videosWithAnnotations() throws -> MLDataTable { fatalError() }
        public func keypointsWithAnnotations(targetFrameRate: Swift.Double) throws -> MLDataTable { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLHandActionClassifier.ModelParameters.ValidationData, batchSize: Swift.Int, maximumIterations: Swift.Int, predictionWindowSize: Swift.Int, augmentationOptions: MLHandActionClassifier.VideoAugmentationOptions, algorithm: MLHandActionClassifier.ModelParameters.ModelAlgorithmType, targetFrameRate: Swift.Double) { fatalError() }
        public var algorithm: ModelAlgorithmType { get { fatalError() } set {} }
        public var augmentationOptions: MLHandActionClassifier.VideoAugmentationOptions { get { fatalError() } set {} }
        public var batchSize: Swift.Int { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maximumIterations: Swift.Int { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var predictionWindowSize: Swift.Int { get { fatalError() } set {} }
        public var targetFrameRate: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public enum ModelAlgorithmType: Codable, Hashable, @unchecked Sendable {
            case gcn
            public func hash(into: inout Hasher) -> () {}
            public var hashValue: Swift.Int { get { fatalError() } }
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataSource(_: MLHandActionClassifier.DataSource)
            case none
            case split(split: MLSplitStrategy)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct Prediction: Codable, Hashable, @unchecked Sendable {
        public var frameRange: Range<Swift.Int> { get { fatalError() } set {} }
        public var results: [(label: Swift.String, confidence: Swift.Double)] { get { return [] } set {} }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Prediction, _ rhs: Prediction) -> Bool { fatalError() }
    }
    public struct VideoAugmentationOptions: Codable, ExpressibleByArrayLiteral, Hashable, OptionSet, RawRepresentable, @unchecked Sendable, SetAlgebra {
        public init(rawValue: Swift.Int) { fatalError() }
        public static var dropFrames: VideoAugmentationOptions { get { fatalError() } }
        public static var horizontallyFlip: VideoAugmentationOptions { get { fatalError() } }
        public static var interpolateFrames: VideoAugmentationOptions { get { fatalError() } }
        public var rawValue: Swift.Int { get { fatalError() } }
        public static var rotate: VideoAugmentationOptions { get { fatalError() } }
        public static var scale: VideoAugmentationOptions { get { fatalError() } }
        public static var translate: VideoAugmentationOptions { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: VideoAugmentationOptions, _ rhs: VideoAugmentationOptions) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var batchSize: Swift.Int { get { fatalError() } }
        public static var endTimeColumnName: Swift.String { get { fatalError() } }
        public static var featureColumnName: Swift.String { get { fatalError() } }
        public static var labelColumnName: Swift.String { get { fatalError() } }
        public static var maximumIterations: Swift.Int { get { fatalError() } }
        public static var predictionWindowSize: Swift.Int { get { fatalError() } }
        public static var sessionIdColumnName: Swift.String { get { fatalError() } }
        public static var startTimeColumnName: Swift.String { get { fatalError() } }
        public static var targetFrameRate: Swift.Double { get { fatalError() } }
        public static var videoColumnName: Swift.String { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLHandActionClassifier, _ rhs: MLHandActionClassifier) -> Bool { fatalError() }
}
public struct MLHandPoseClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public init(trainingData: MLHandPoseClassifier.DataSource, parameters: MLHandPoseClassifier.ModelParameters) throws { fatalError() }
    public static func makeTrainingSession(trainingData: MLHandPoseClassifier.DataSource, parameters: MLHandPoseClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLHandPoseClassifier> { fatalError() }
    public func evaluation(on: MLHandPoseClassifier.DataSource) throws -> MLClassifierMetrics { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public func predictions(from: [URL]) throws -> [[(label: Swift.String, confidence: Swift.Double)]] { return [] }
    public func prediction(from: URL) throws -> [(label: Swift.String, confidence: Swift.Double)] { return [] }
    public var model: MLModel { get { fatalError() } set {} }
    public var modelParameters: MLHandPoseClassifier.ModelParameters { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } set {} }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public static func resume(_ arg1: MLTrainingSession<MLHandPoseClassifier>) throws -> MLJob<MLHandPoseClassifier> { fatalError() }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } set {} }
    public static func train(trainingData: MLHandPoseClassifier.DataSource, parameters: MLHandPoseClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLHandPoseClassifier> { fatalError() }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLHandPoseClassifier> { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case directoryWithImagesAndAnnotation(URL, URL, Swift.String, Swift.String)
        case labeledDirectories(labeledDirectories: URL)
        case labeledFiles(labeledFiles: URL)
        case labeledImageData(MLDataTable, Swift.String, Swift.String)
        case labeledImageDataFrame(TabularData.DataFrame, Swift.String, Swift.String)
        case labeledKeypointsData(MLDataTable, Swift.String, Swift.String, Swift.String)
        case labeledKeypointsDataFrame(TabularData.DataFrame, Swift.String, Swift.String, Swift.String)
        public func labeledMedia() throws -> [Swift.String : [URL]] { return [:] }
        public func imagesWithAnnotations() throws -> MLDataTable { fatalError() }
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int, labelColumn: Swift.String) throws -> MLDataTable { fatalError() }
        public func gatherAnnotatedFileNames() throws -> TabularData.DataFrame? { return nil }
        public func keypointsWithAnnotations() throws -> MLDataTable { fatalError() }
        public func extractKeypoints() throws -> TabularData.DataFrame { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct ImageAugmentationOptions: Codable, ExpressibleByArrayLiteral, Hashable, OptionSet, RawRepresentable, @unchecked Sendable, SetAlgebra {
        public init(rawValue: Swift.Int) { fatalError() }
        public static var horizontallyFlip: ImageAugmentationOptions { get { fatalError() } }
        public var rawValue: Swift.Int { get { fatalError() } }
        public static var rotate: ImageAugmentationOptions { get { fatalError() } }
        public static var scale: ImageAugmentationOptions { get { fatalError() } }
        public static var translate: ImageAugmentationOptions { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ImageAugmentationOptions, _ rhs: ImageAugmentationOptions) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLHandPoseClassifier.ModelParameters.ValidationData, batchSize: Swift.Int, maximumIterations: Swift.Int, augmentationOptions: MLHandPoseClassifier.ImageAugmentationOptions, algorithm: MLHandPoseClassifier.ModelParameters.ModelAlgorithmType) { fatalError() }
        public var algorithm: ModelAlgorithmType { get { fatalError() } set {} }
        public var augmentationOptions: MLHandPoseClassifier.ImageAugmentationOptions { get { fatalError() } set {} }
        public var batchSize: Swift.Int { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maximumIterations: Swift.Int { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var validation: ValidationData { get { fatalError() } set {} }
        public enum ModelAlgorithmType: Codable, Hashable, @unchecked Sendable {
            case gcn
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public func hash(into: inout Hasher) -> () {}
            public var hashValue: Swift.Int { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataSource(_: MLHandPoseClassifier.DataSource)
            case none
            case split(split: MLSplitStrategy)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var batchSize: Swift.Int { get { fatalError() } }
        public static var featureColumnName: Swift.String { get { fatalError() } }
        public static var imageColumnName: Swift.String { get { fatalError() } }
        public static var labelColumnName: Swift.String { get { fatalError() } }
        public static var maximumIterations: Swift.Int { get { fatalError() } }
        public static var sessionIdColumnName: Swift.String { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLHandPoseClassifier, _ rhs: MLHandPoseClassifier) -> Bool { fatalError() }
}
public protocol MLIdentifier {
    var identifierValue: MLDataValue { get }
}
public struct MLImageClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public init(trainingData: [Swift.String : [URL]], parameters: MLImageClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: MLImageClassifier.DataSource, parameters: MLImageClassifier.ModelParameters) throws { fatalError() }
    public static func makeTrainingSession(trainingData: MLImageClassifier.DataSource, parameters: MLImageClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLImageClassifier> { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public func evaluation(on: [Swift.String : [URL]]) -> MLClassifierMetrics { fatalError() }
    public func prediction(from: CGImageRef) throws -> Swift.String { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public func predictions(from: [URL]) throws -> [Swift.String] { return [] }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public func evaluation(on: MLImageClassifier.DataSource) -> MLClassifierMetrics { fatalError() }
    public var modelParameters: MLImageClassifier.ModelParameters { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public static func train(trainingData: MLImageClassifier.DataSource, parameters: MLImageClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLImageClassifier> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public static func resume(_ arg1: MLTrainingSession<MLImageClassifier>) throws -> MLJob<MLImageClassifier> { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public func prediction(from: URL) throws -> Swift.String { fatalError() }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLImageClassifier> { fatalError() }
    public struct CustomFeatureExtractor: Codable, Hashable, @unchecked Sendable {
        public init(modelPath: URL, outputName: Swift.String?) { fatalError() }
        public var modelPath: URL { get { fatalError() } set {} }
        public var outputName: Swift.String? { get { return nil } set {} }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: CustomFeatureExtractor, _ rhs: CustomFeatureExtractor) -> Bool { fatalError() }
    }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case filesByLabel(_: [Swift.String : [URL]])
        case labeledDirectories(labeledDirectories: URL)
        case labeledFiles(labeledFiles: URL)
        public func stratifiedSplit<GenericA>(proportions: [Swift.Double], generator: inout GenericA) throws -> [[Swift.String : [URL]]] where GenericA: RandomNumberGenerator { return [] }
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int) throws -> [[Swift.String : [URL]]] { return [] }
        public func labeledImages() throws -> [Swift.String : [URL]] { return [:] }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public enum FeatureExtractorType: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case custom(_: MLImageClassifier.CustomFeatureExtractor)
        case scenePrint(scenePrint: Swift.Int?)
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: FeatureExtractorType, _ rhs: FeatureExtractorType) -> Bool { fatalError() }
    }
    public struct ImageAugmentationOptions: Codable, ExpressibleByArrayLiteral, Hashable, OptionSet, RawRepresentable, @unchecked Sendable, SetAlgebra {
        public init(rawValue: Swift.Int) { fatalError() }
        public static var blur: ImageAugmentationOptions { get { fatalError() } }
        public static var crop: ImageAugmentationOptions { get { fatalError() } }
        public static var exposure: ImageAugmentationOptions { get { fatalError() } }
        public static var flip: ImageAugmentationOptions { get { fatalError() } }
        public static var noise: ImageAugmentationOptions { get { fatalError() } }
        public var rawValue: Swift.Int { get { fatalError() } }
        public static var rotation: ImageAugmentationOptions { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ImageAugmentationOptions, _ rhs: ImageAugmentationOptions) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(featureExtractor: MLImageClassifier.FeatureExtractorType, validationData: [Swift.String : [URL]]?, maxIterations: Swift.Int, augmentationOptions: MLImageClassifier.ImageAugmentationOptions) { fatalError() }
        public init(featureExtractor: MLImageClassifier.FeatureExtractorType, validation: MLImageClassifier.ModelParameters.ValidationData, maxIterations: Swift.Int, augmentationOptions: MLImageClassifier.ImageAugmentationOptions) { fatalError() }
        public init(validation: MLImageClassifier.ModelParameters.ValidationData, maxIterations: Swift.Int, augmentation: MLImageClassifier.ImageAugmentationOptions, algorithm: MLImageClassifier.ModelParameters.ModelAlgorithmType) { fatalError() }
        public init(featureExtractor: MLImageClassifier.FeatureExtractorType, validationData: MLImageClassifier.DataSource, maxIterations: Swift.Int, augmentationOptions: MLImageClassifier.ImageAugmentationOptions) { fatalError() }
        public var algorithm: ModelAlgorithmType { get { fatalError() } set {} }
        public var augmentationOptions: MLImageClassifier.ImageAugmentationOptions { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var featureExtractor: MLImageClassifier.FeatureExtractorType { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: [Swift.String : [URL]]? { get { return nil } set {} }
        public enum ClassifierType: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            case logisticRegressor
            case multilayerPerceptron(multilayerPerceptron: [Swift.Int])
            public var description: Swift.String { get { fatalError() } }
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public var hashValue: Swift.Int { get { fatalError() } }
            public func hash(into: inout Hasher) -> () {}
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public enum ModelAlgorithmType: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            case transferLearning(MLImageClassifier.FeatureExtractorType, MLImageClassifier.ModelParameters.ClassifierType)
            public var description: Swift.String { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ModelAlgorithmType, _ rhs: ModelAlgorithmType) -> Bool { fatalError() }
        }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataSource(_: MLImageClassifier.DataSource)
            case dictionary(_: [Swift.String : [URL]])
            case none
            case split(split: MLSplitStrategy)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var algorithm: MLImageClassifier.ModelParameters.ModelAlgorithmType { get { fatalError() } }
        public static var augmentationOptions: MLImageClassifier.ImageAugmentationOptions { get { fatalError() } }
        public static var batchSize: Swift.Int { get { fatalError() } }
        public static var classifier: MLImageClassifier.ModelParameters.ClassifierType { get { fatalError() } }
        public static var featureColumnName: Swift.String { get { fatalError() } }
        public static var labelColumnName: Swift.String { get { fatalError() } }
        public static var maximumIterations: Swift.Int { get { fatalError() } }
        public static var validation: MLImageClassifier.ModelParameters.ValidationData { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLImageClassifier, _ rhs: MLImageClassifier) -> Bool { fatalError() }
}
@_fixed_layout final public class MLJob<A>: Cancellable {
    public final var isCanceled: Swift.Bool { get { fatalError() } }
    public final var result: AnyPublisher<A, any Error> { get { fatalError() } }
    public final func cancel() -> () {}
    public final var checkpoints: AnyPublisher<MLCheckpoint, Never> { get { fatalError() } }
    public final var phase: AnyPublisher<MLPhase, Never> { get { fatalError() } }
    public final var progress: NSProgress { get { fatalError() } }
    public final var startDate: Date { get { fatalError() } }
}
public struct MLLinearRegressor: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLinearRegressor.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLinearRegressor.ModelParameters) throws { fatalError() }
    public static func resume(_ arg1: MLTrainingSession<MLLinearRegressor>) throws -> MLJob<MLLinearRegressor> { fatalError() }
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLinearRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLLinearRegressor> { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public var validationMetrics: MLRegressorMetrics { get { fatalError() } }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public func evaluation(on: TabularData.DataFrame) -> MLRegressorMetrics { fatalError() }
    public var trainingMetrics: MLRegressorMetrics { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLLinearRegressor> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var modelParameters: MLLinearRegressor.ModelParameters { get { fatalError() } }
    public func evaluation(on: MLDataTable) -> MLRegressorMetrics { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLinearRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLLinearRegressor> { fatalError() }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLinearRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLLinearRegressor> { fatalError() }
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLinearRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLLinearRegressor> { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public var description: Swift.String { get { fatalError() } }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validationData: MLDataTable?, maxIterations: Swift.Int, l1Penalty: Swift.Double, l2Penalty: Swift.Double, stepSize: Swift.Double, convergenceThreshold: Swift.Double, featureRescaling: Swift.Bool) { fatalError() }
        public init(validation: MLLinearRegressor.ModelParameters.ValidationData, maxIterations: Swift.Int, l1Penalty: Swift.Double, l2Penalty: Swift.Double, stepSize: Swift.Double, convergenceThreshold: Swift.Double, featureRescaling: Swift.Bool) { fatalError() }
        public var convergenceThreshold: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var featureRescaling: Swift.Bool { get { fatalError() } set {} }
        public var l1Penalty: Swift.Double { get { fatalError() } set {} }
        public var l2Penalty: Swift.Double { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var stepSize: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLLinearRegressor, _ rhs: MLLinearRegressor) -> Bool { fatalError() }
}
public struct MLLogisticRegressionClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLogisticRegressionClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLogisticRegressionClassifier.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLogisticRegressionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLLogisticRegressionClassifier> { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLogisticRegressionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLLogisticRegressionClassifier> { fatalError() }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLogisticRegressionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLLogisticRegressionClassifier> { fatalError() }
    public func evaluation(on: MLDataTable) -> MLClassifierMetrics { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public var modelParameters: MLLogisticRegressionClassifier.ModelParameters { get { fatalError() } }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func evaluation(on: TabularData.DataFrame) -> MLClassifierMetrics { fatalError() }
    public static func resume(_ arg1: MLTrainingSession<MLLogisticRegressionClassifier>) throws -> MLJob<MLLogisticRegressionClassifier> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLLogisticRegressionClassifier> { fatalError() }
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLLogisticRegressionClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLLogisticRegressionClassifier> { fatalError() }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLLogisticRegressionClassifier.ModelParameters.ValidationData, maxIterations: Swift.Int, l1Penalty: Swift.Double, l2Penalty: Swift.Double, stepSize: Swift.Double, convergenceThreshold: Swift.Double, featureRescaling: Swift.Bool) { fatalError() }
        public init(validationData: MLDataTable?, maxIterations: Swift.Int, l1Penalty: Swift.Double, l2Penalty: Swift.Double, stepSize: Swift.Double, convergenceThreshold: Swift.Double, featureRescaling: Swift.Bool) { fatalError() }
        public var convergenceThreshold: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var featureRescaling: Swift.Bool { get { fatalError() } set {} }
        public var l1Penalty: Swift.Double { get { fatalError() } set {} }
        public var l2Penalty: Swift.Double { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var stepSize: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLLogisticRegressionClassifier, _ rhs: MLLogisticRegressionClassifier) -> Bool { fatalError() }
}
public protocol MLMetricValue: CustomStringConvertible {
}
public struct MLModelMetadata: Codable, Hashable, @unchecked Sendable {
    public init(author: Swift.String, shortDescription: Swift.String, license: Swift.String?, version: Swift.String, additional: [Swift.String : Swift.String]?) { fatalError() }
    public var additional: [Swift.String : Swift.String]? { get { return nil } set {} }
    public var author: Swift.String { get { fatalError() } set {} }
    public var license: Swift.String? { get { return nil } set {} }
    public var shortDescription: Swift.String { get { fatalError() } set {} }
    public var version: Swift.String { get { fatalError() } set {} }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLModelMetadata, _ rhs: MLModelMetadata) -> Bool { fatalError() }
}
public struct MLObjectDetector: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: MLObjectDetector.DataSource, parameters: MLObjectDetector.ModelParameters, annotationType: MLObjectDetector.AnnotationType) throws { fatalError() }
    public init(trainingData: MLDataTable, imageColumn: Swift.String, annotationColumn: Swift.String, annotationType: MLObjectDetector.AnnotationType, parameters: MLObjectDetector.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public var model: MLModel { get { fatalError() } }
    public static func train(trainingData: MLObjectDetector.DataSource, annotationType: MLObjectDetector.AnnotationType, parameters: MLObjectDetector.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLObjectDetector> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public static func resume(_ arg1: MLTrainingSession<MLObjectDetector>) throws -> MLJob<MLObjectDetector> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLObjectDetector> { fatalError() }
    public var trainingMetrics: MLObjectDetectorMetrics { get { fatalError() } }
    public var validationMetrics: MLObjectDetectorMetrics { get { fatalError() } }
    public static func makeTrainingSession(trainingData: MLObjectDetector.DataSource, annotationType: MLObjectDetector.AnnotationType, parameters: MLObjectDetector.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLObjectDetector> { fatalError() }
    public func prediction(from: URL) throws -> [MLObjectDetector.ObjectAnnotation] { return [] }
    public func evaluation(on: MLObjectDetector.DataSource) -> MLObjectDetectorMetrics { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func predictions(from: [URL]) throws -> [[MLObjectDetector.ObjectAnnotation]] { return [] }
    public func evaluation(on: MLDataTable, imageColumn: Swift.String, annotationColumn: Swift.String) -> MLObjectDetectorMetrics { fatalError() }
    public var modelParameters: MLObjectDetector.ModelParameters { get { fatalError() } }
    public enum AnnotationType: Codable, Hashable, @unchecked Sendable {
        case boundingBox(MLBoundingBoxUnits, MLBoundingBoxCoordinatesOrigin, MLBoundingBoxAnchor)
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: AnnotationType, _ rhs: AnnotationType) -> Bool { fatalError() }
    }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case directoryWithImages(URL, URL)
        case directoryWithImagesAndJsonAnnotation(directoryWithImagesAndJsonAnnotation: URL)
        case frame(TabularData.DataFrame, Swift.String, Swift.String)
        case table(MLDataTable, Swift.String, Swift.String)
        public func imagesWithObjectAnnotations() throws -> MLDataTable { fatalError() }
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int, annotationColumn: Swift.String) throws -> MLDataTable { fatalError() }
        public func diagnose() -> [DataSourceIssue] { return [] }
        public func gatherAnnotatedFileNames() throws -> TabularData.DataFrame { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validationData: MLObjectDetector.DataSource, batchSize: Swift.Int?, maxIterations: Swift.Int?) throws { fatalError() }
        public init(validation: MLObjectDetector.ModelParameters.ValidationData, batchSize: Swift.Int?, maxIterations: Swift.Int?, gridSize: CGSize, algorithm: MLObjectDetector.ModelParameters.ModelAlgorithmType) { fatalError() }
        public init(validation: MLObjectDetector.ModelParameters.ValidationData, batchSize: Swift.Int?, maxIterations: Swift.Int?) { fatalError() }
        public var algorithm: ModelAlgorithmType { get { fatalError() } set {} }
        public var batchSize: Swift.Int? { get { return nil } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var gridSize: CGSize { get { fatalError() } set {} }
        public var maxIterations: Swift.Int? { get { return nil } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var validation: ValidationData { get { fatalError() } set {} }
        public enum FeatureExtractorType: Codable, Hashable, @unchecked Sendable {
            case objectPrint(objectPrint: Swift.Int)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: FeatureExtractorType, _ rhs: FeatureExtractorType) -> Bool { fatalError() }
        }
        public enum ModelAlgorithmType: Codable, Hashable, @unchecked Sendable {
            case darknetYolo
            case transferLearning(_: MLObjectDetector.ModelParameters.FeatureExtractorType)
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(TabularData.DataFrame, Swift.String, Swift.String)
            case dataSource(_: MLObjectDetector.DataSource)
            case none
            case split(split: MLSplitStrategy)
            case table(MLDataTable, Swift.String, Swift.String)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct ObjectAnnotation: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(label: Swift.String, boundingBox: CGRect, confidence: Swift.Double) { fatalError() }
        public var boundingBox: CGRect { get { fatalError() } set {} }
        public var confidence: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var label: Swift.String { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ObjectAnnotation, _ rhs: ObjectAnnotation) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var sessionParameters: MLTrainingSessionParameters { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLObjectDetector, _ rhs: MLObjectDetector) -> Bool { fatalError() }
}
public struct MLObjectDetectorMetrics: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(averagePrecision: (variedIoU: [Swift.String : Swift.Double], IoU50: [Swift.String : Swift.Double]), meanAveragePrecision: (variedIoU: Swift.Double, IoU50: Swift.Double)) { fatalError() }
    public var averagePrecision: (variedIoU: [Swift.String : Swift.Double], IoU50: [Swift.String : Swift.Double]) { get { fatalError() } }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var error: (any Error)? { get { return nil } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public var meanAveragePrecision: (variedIoU: Swift.Double, IoU50: Swift.Double) { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLObjectDetectorMetrics, _ rhs: MLObjectDetectorMetrics) -> Bool { fatalError() }
}
public enum MLPhase: String, Codable, Hashable, RawRepresentable, @unchecked Sendable {
    case evaluating
    case extractingFeatures
    case inferencing
    case initialized
    case training
    public init?(rawValue: Swift.String) { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLPhase, _ rhs: MLPhase) -> Bool { fatalError() }
}
public struct MLProgress: Codable, Hashable, @unchecked Sendable {
    public init(phase: MLPhase) { fatalError() }
    public init(from: Swift.Decoder) throws { fatalError() }
    public init?(progress: NSProgress) { fatalError() }
    public static var accuracyKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var elapsedTimeKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var itemCountKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var maximumErrorKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var rootMeanSquaredErrorKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var styleLossKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var stylizedImageKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var totalItemCountKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var validationAccuracyKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var validationLossKey: NSProgressUserInfoKey { get { fatalError() } }
    public static var validationMaximumErrorKey: NSProgressUserInfoKey { get { fatalError() } }
    public func encode(to: Swift.Encoder) throws -> () {}
    public static var contentLossKey: NSProgressUserInfoKey { get { fatalError() } }
    public var elapsedTime: Swift.Double { get { fatalError() } set {} }
    public var itemCount: Swift.Int { get { fatalError() } set {} }
    public static var lossKey: NSProgressUserInfoKey { get { fatalError() } }
    public var metrics: [MLProgress.Metric : Any] { get { return [:] } set {} }
    public var phase: MLPhase { get { fatalError() } set {} }
    public static var phaseKey: NSProgressUserInfoKey { get { fatalError() } }
    public var totalItemCount: Swift.Int? { get { return nil } set {} }
    public static var validationRootMeanSquaredErrorKey: NSProgressUserInfoKey { get { fatalError() } }
    public enum Metric: String, CaseIterable, Codable, Hashable, RawRepresentable, @unchecked Sendable {
        case accuracy
        case contentLoss
        case loss
        case maximumError
        case rootMeanSquaredError
        case styleLoss
        case stylizedImageURL
        case validationAccuracy
        case validationLoss
        case validationMaximumError
        case validationRootMeanSquaredError
        public init?(rawValue: Swift.String) { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: Metric, _ rhs: Metric) -> Bool { fatalError() }
    }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLProgress, _ rhs: MLProgress) -> Bool { fatalError() }
}
public struct MLRandomForestClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestClassifier.ModelParameters) throws { fatalError() }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public var modelParameters: MLRandomForestClassifier.ModelParameters { get { fatalError() } }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public static func resume(_ arg1: MLTrainingSession<MLRandomForestClassifier>) throws -> MLJob<MLRandomForestClassifier> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var model: MLModel { get { fatalError() } set {} }
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLRandomForestClassifier> { fatalError() }
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLRandomForestClassifier> { fatalError() }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public func evaluation(on: TabularData.DataFrame) -> MLClassifierMetrics { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public func evaluation(on: MLDataTable) -> MLClassifierMetrics { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public var playgroundDescription: Any { get { fatalError() } }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLRandomForestClassifier> { fatalError() }
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLRandomForestClassifier> { fatalError() }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLRandomForestClassifier> { fatalError() }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLRandomForestClassifier.ModelParameters.ValidationData, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public init(validationData: MLDataTable?, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public var columnSubsample: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maxDepth: Swift.Int { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var minChildWeight: Swift.Double { get { fatalError() } set {} }
        public var minLossReduction: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var randomSeed: Swift.Int { get { fatalError() } set {} }
        public var rowSubsample: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLRandomForestClassifier, _ rhs: MLRandomForestClassifier) -> Bool { fatalError() }
}
public struct MLRandomForestRegressor: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestRegressor.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestRegressor.ModelParameters) throws { fatalError() }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public static func makeTrainingSession(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLRandomForestRegressor> { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLRandomForestRegressor> { fatalError() }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public var modelParameters: MLRandomForestRegressor.ModelParameters { get { fatalError() } }
    public static func resume(_ arg1: MLTrainingSession<MLRandomForestRegressor>) throws -> MLJob<MLRandomForestRegressor> { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public func evaluation(on: MLDataTable) -> MLRegressorMetrics { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public var playgroundDescription: Any { get { fatalError() } }
    public func evaluation(on: TabularData.DataFrame) -> MLRegressorMetrics { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public static func train(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLRandomForestRegressor> { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func makeTrainingSession(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLRandomForestRegressor> { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public var validationMetrics: MLRegressorMetrics { get { fatalError() } }
    public static func train(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLRandomForestRegressor.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLRandomForestRegressor> { fatalError() }
    public var trainingMetrics: MLRegressorMetrics { get { fatalError() } }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLRandomForestRegressor.ModelParameters.ValidationData, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public init(validationData: MLDataTable?, maxDepth: Swift.Int, maxIterations: Swift.Int, minLossReduction: Swift.Double, minChildWeight: Swift.Double, randomSeed: Swift.Int, rowSubsample: Swift.Double, columnSubsample: Swift.Double) { fatalError() }
        public var columnSubsample: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maxDepth: Swift.Int { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var minChildWeight: Swift.Double { get { fatalError() } set {} }
        public var minLossReduction: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var randomSeed: Swift.Int { get { fatalError() } set {} }
        public var rowSubsample: Swift.Double { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLRandomForestRegressor, _ rhs: MLRandomForestRegressor) -> Bool { fatalError() }
}
public struct MLRecommender: Codable, Hashable, @unchecked Sendable {
    public init(trainingData: TabularData.DataFrame, userColumn: Swift.String, itemColumn: Swift.String, ratingColumn: Swift.String?, parameters: MLRecommender.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, userColumn: Swift.String, itemColumn: Swift.String, ratingColumn: Swift.String?, parameters: MLRecommender.ModelParameters) throws { fatalError() }
    public func evaluation(on: TabularData.DataFrame, userColumn: Swift.String, itemColumn: Swift.String, ratingColumn: Swift.String?, cutoffs: [Swift.Int], excludingObserved: Swift.Bool) -> MLRecommenderMetrics { fatalError() }
    public var userIdentifierColumn: Swift.String { get { fatalError() } set {} }
    public func recommendations(fromUsers: [any MLIdentifier], maxCount: Swift.Int, restrictingToItems: [any MLIdentifier]?, excluding: MLDataTable?, excludingObserved: Swift.Bool) throws -> MLDataTable { fatalError() }
    public func getSimilarItems<GenericA>(fromItems: MLDataColumn<GenericA>, maxCount: Swift.Int) throws -> MLDataTable where GenericA: MLDataValueConvertible { fatalError() }
    public var ratingColumn: Swift.String? { get { return nil } set {} }
    public func evaluation(on: MLDataTable, userColumn: Swift.String, itemColumn: Swift.String, ratingColumn: Swift.String?, cutoffs: [Swift.Int], excludingObserved: Swift.Bool) -> MLRecommenderMetrics { fatalError() }
    public var itemIdentifierColumn: Swift.String { get { fatalError() } set {} }
    public var modelParameters: MLRecommender.ModelParameters { get { fatalError() } }
    public func getSimilarItems(fromItems: [any MLIdentifier], maxCount: Swift.Int) throws -> MLDataTable { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public func recommendations<GenericA>(fromUsers: MLDataColumn<GenericA>, maxCount: Swift.Int, restrictingToItems: MLDataColumn<GenericA>?, excluding: MLDataTable?, excludingObserved: Swift.Bool) throws -> MLDataTable where GenericA: MLDataValueConvertible, GenericA: MLIdentifier { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public enum ModelAlgorithmType: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case itemSimilarity(_: MLRecommender.SimilarityType)
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelAlgorithmType, _ rhs: ModelAlgorithmType) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, Hashable, @unchecked Sendable {
        public init(algorithm: MLRecommender.ModelAlgorithmType, threshold: Swift.Double, maxCount: Swift.Int, nearestItems: MLDataTable?, maxSimilarityIterations: Swift.Int) { fatalError() }
        public init(algorithm: MLRecommender.ModelAlgorithmType, threshold: Swift.Double, maxCount: Swift.Int, nearestItemsDataFrame: TabularData.DataFrame?, maxSimilarityIterations: Swift.Int) { fatalError() }
        public var algorithm: MLRecommender.ModelAlgorithmType { get { fatalError() } set {} }
        public var maxCount: Swift.Int { get { fatalError() } set {} }
        public var maxSimilarityIterations: Swift.Int { get { fatalError() } set {} }
        public var nearestItems: MLDataTable? { get { return nil } set {} }
        public var nearestItemsDataFrame: TabularData.DataFrame? { get { return nil } set {} }
        public var threshold: Swift.Double { get { fatalError() } set {} }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public enum SimilarityType: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case cosine
        case jaccard
        case pearson
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public func hash(into: inout Hasher) -> () {}
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public var hashValue: Swift.Int { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLRecommender, _ rhs: MLRecommender) -> Bool { fatalError() }
}
public struct MLRecommenderMetrics: Codable, Hashable, @unchecked Sendable {
    public init(precisionRecall: MLDataTable, excludingObserved: Swift.Bool) { fatalError() }
    public var error: (any Error)? { get { return nil } }
    public var excludingObserved: Swift.Bool { get { fatalError() } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public var precisionRecall: MLDataTable { get { fatalError() } }
    public var precisionRecallDataFrame: TabularData.DataFrame { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLRecommenderMetrics, _ rhs: MLRecommenderMetrics) -> Bool { fatalError() }
}
public enum MLRegressor: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    case boostedTree(_: MLBoostedTreeRegressor)
    case decisionTree(_: MLDecisionTreeRegressor)
    case linear(_: MLLinearRegressor)
    case randomForest(_: MLRandomForestRegressor)
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?) throws { fatalError() }
    public func evaluation(on: TabularData.DataFrame) -> MLRegressorMetrics { fatalError() }
    public var validationMetrics: MLRegressorMetrics { get { fatalError() } }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public var featureColumns: [Swift.String] { get { return [] } }
    public var playgroundDescription: Any { get { fatalError() } }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public var targetColumn: Swift.String { get { fatalError() } }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public var model: MLModel { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func evaluation(on: MLDataTable) -> MLRegressorMetrics { fatalError() }
    public var trainingMetrics: MLRegressorMetrics { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLRegressor, _ rhs: MLRegressor) -> Bool { fatalError() }
}
public struct MLRegressorMetrics: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(maximumError: Swift.Double, rootMeanSquaredError: Swift.Double) { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var error: (any Error)? { get { return nil } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public var maximumError: Swift.Double { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public var rootMeanSquaredError: Swift.Double { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLRegressorMetrics, _ rhs: MLRegressorMetrics) -> Bool { fatalError() }
}
public struct MLSoundClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: [Swift.String : [URL]], parameters: MLSoundClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: MLSoundClassifier.DataSource, parameters: MLSoundClassifier.ModelParameters) throws { fatalError() }
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public func predictions(from: [URL], overlapFactor: Swift.Double, predictionTimeWindowSize: Swift.Double) throws -> [Swift.String] { return [] }
    public func predictions(from: [URL]) throws -> [Swift.String] { return [] }
    public var debugDescription: Swift.String { get { fatalError() } }
    public func evaluation(on: MLSoundClassifier.DataSource) -> MLClassifierMetrics { fatalError() }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func evaluation(on: [Swift.String : [URL]]) -> MLClassifierMetrics { fatalError() }
    public static var _defaultSessionParameters: MLTrainingSessionParameters { get { fatalError() } }
    public var model: MLModel { get { fatalError() } set {} }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public static func extractFeatures(trainingData: MLSoundClassifier.DataSource, parameters: MLSoundClassifier.FeatureExtractionParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLSoundClassifier.DataSource> { fatalError() }
    public var modelParameters: MLSoundClassifier.ModelParameters { get { fatalError() } }
    public static func makeTrainingSession(trainingData: MLSoundClassifier.DataSource, parameters: MLSoundClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLSoundClassifier> { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public static func train(trainingData: MLSoundClassifier.DataSource, parameters: MLSoundClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLSoundClassifier> { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public var description: Swift.String { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLSoundClassifier> { fatalError() }
    public static func train(trainingData: [Swift.String : [URL]], parameters: MLSoundClassifier.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLSoundClassifier> { fatalError() }
    public static func resume(_ arg1: MLTrainingSession<MLSoundClassifier>) throws -> MLJob<MLSoundClassifier> { fatalError() }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case features(MLDataTable, Swift.String, Swift.String, MLSoundClassifier.FeatureExtractionParameters)
        case featuresDataFrame(TabularData.DataFrame, Swift.String, Swift.String, MLSoundClassifier.FeatureExtractionParameters)
        case filesByLabel(_: [Swift.String : [URL]])
        case labeledDirectories(labeledDirectories: URL)
        case labeledFiles(labeledFiles: URL)
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int) throws -> [[Swift.String : [URL]]] { return [] }
        public func stratifiedSplit<GenericA>(proportions: [Swift.Double], generator: inout GenericA) throws -> [[Swift.String : [URL]]] where GenericA: RandomNumberGenerator { return [] }
        public func diagnose() -> [DataSourceIssue] { return [] }
        public func labeledSounds() throws -> [Swift.String : [URL]] { return [:] }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct FeatureExtractionParameters: Codable, Hashable, @unchecked Sendable {
        public init(overlapFactor: Swift.Double, featureExtractor: MLSoundClassifier.ModelParameters.FeatureExtractorType, featureExtractionTimeWindowSize: Swift.Double?) { fatalError() }
        public init(overlapFactor: Swift.Double, featureExtractor: MLSoundClassifier.ModelParameters.FeatureExtractorType) { fatalError() }
        public var featureExtractionTimeWindowSize: Swift.Double { get { fatalError() } set {} }
        public var featureExtractor: MLSoundClassifier.ModelParameters.FeatureExtractorType { get { fatalError() } set {} }
        public var overlapFactor: Swift.Double { get { fatalError() } set {} }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: FeatureExtractionParameters, _ rhs: FeatureExtractionParameters) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLSoundClassifier.ModelParameters.ValidationData, maxIterations: Swift.Int, overlapFactor: Swift.Double, algorithm: MLSoundClassifier.ModelParameters.ModelAlgorithmType, featureExtractionTimeWindowSize: Swift.Double) { fatalError() }
        public init(validation: MLSoundClassifier.ModelParameters.ValidationData, maxIterations: Swift.Int, overlapFactor: Swift.Double, algorithm: MLSoundClassifier.ModelParameters.ModelAlgorithmType) { fatalError() }
        public init(validation: MLSoundClassifier.ModelParameters.ValidationData, maxIterations: Swift.Int, overlapFactor: Swift.Double) { fatalError() }
        public var algorithm: ModelAlgorithmType { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var featureExtractionTimeWindowSize: Swift.Double { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var overlapFactor: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var validation: ValidationData { get { fatalError() } set {} }
        public enum ClassifierType: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            case logisticRegressor
            case multilayerPerceptron(multilayerPerceptron: [Swift.Int])
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public var description: Swift.String { get { fatalError() } }
            public var hashValue: Swift.Int { get { fatalError() } }
            public func hash(into: inout Hasher) -> () {}
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public enum FeatureExtractorType: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            case audioFeaturePrint(MLSoundClassifier.ModelParameters.FeaturePrintType, Swift.Int)
            case vggish(vggish: Swift.Int)
            public var description: Swift.String { get { fatalError() } }
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public enum FeaturePrintType: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            case sound
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public func hash(into: inout Hasher) -> () {}
            public var description: Swift.String { get { fatalError() } }
            public var hashValue: Swift.Int { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        }
        public enum ModelAlgorithmType: Codable, CustomStringConvertible, Hashable, @unchecked Sendable {
            case transferLearning(MLSoundClassifier.ModelParameters.FeatureExtractorType, MLSoundClassifier.ModelParameters.ClassifierType)
            public var description: Swift.String { get { fatalError() } }
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataSource(_: MLSoundClassifier.DataSource)
            case dictionary(_: [Swift.String : [URL]])
            case none
            case split(split: MLSplitStrategy)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var algorithm: MLSoundClassifier.ModelParameters.ModelAlgorithmType { get { fatalError() } }
        public static var batchSize: Swift.Int { get { fatalError() } }
        public static var classifier: MLSoundClassifier.ModelParameters.ClassifierType { get { fatalError() } }
        public static var defaultVGGishTimeWindow: Swift.Double { get { fatalError() } }
        public static var featureColumnName: Swift.String { get { fatalError() } }
        public static var featureExtractor: MLSoundClassifier.ModelParameters.FeatureExtractorType { get { fatalError() } }
        public static var labelColumnName: Swift.String { get { fatalError() } }
        public static var maximumIterations: Swift.Int { get { fatalError() } }
        public static var overlapFactor: Swift.Double { get { fatalError() } }
        public static var validation: MLSoundClassifier.ModelParameters.ValidationData { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLSoundClassifier, _ rhs: MLSoundClassifier) -> Bool { fatalError() }
}
public enum MLSplitStrategy: Codable, Hashable, @unchecked Sendable {
    case automatic
    case fixed(Swift.Double, Swift.Int?)
    public func resolve(count: Swift.Int) -> (ratio: Swift.Double, seed: Swift.Int) { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLSplitStrategy, _ rhs: MLSplitStrategy) -> Bool { fatalError() }
}
public protocol MLStreamingVisualizable: MLVisualizable {
    func nextIteration() -> ()
    var hasFinishedStreaming: Swift.Bool { get }
}
public struct MLStyleTransfer: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(checkpoint: MLCheckpoint) throws { fatalError() }
    public init(trainingData: MLStyleTransfer.DataSource, parameters: MLStyleTransfer.ModelParameters) throws { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func resume(_ arg1: MLTrainingSession<MLStyleTransfer>) throws -> MLJob<MLStyleTransfer> { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public static func restoreTrainingSession(sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLStyleTransfer> { fatalError() }
    public static func makeTrainingSession(trainingData: MLStyleTransfer.DataSource, parameters: MLStyleTransfer.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLTrainingSession<MLStyleTransfer> { fatalError() }
    public static func downloadAssets() throws -> () {}
    public static func train(trainingData: MLStyleTransfer.DataSource, parameters: MLStyleTransfer.ModelParameters, sessionParameters: MLTrainingSessionParameters) throws -> MLJob<MLStyleTransfer> { fatalError() }
    public func stylize(image: CGImageRef) throws -> CGImageRef? { return nil }
    public var debugDescription: Swift.String { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case images(URL, URL, VNImageCropAndScaleOption?)
        public func processImages(textelDensity: Swift.Int, styleImageDestination: URL?, contentImagesDestination: URL?) throws -> (processedStyleImage: URL, processedContentImages: URL) { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(algorithm: MLStyleTransfer.ModelParameters.ModelAlgorithmType, validation: MLStyleTransfer.ModelParameters.ValidationData, maxIterations: Swift.Int, textelDensity: Swift.Int, styleStrength: Swift.Int) { fatalError() }
        public var algorithm: ModelAlgorithmType { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var styleStrength: Swift.Int { get { fatalError() } set {} }
        public var textelDensity: Swift.Int { get { fatalError() } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public enum ModelAlgorithmType: String, Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, RawRepresentable, @unchecked Sendable {
            case cnn
            case cnnLite
            public init?(rawValue: Swift.String) { fatalError() }
            public var debugDescription: Swift.String { get { fatalError() } }
            public var description: Swift.String { get { fatalError() } }
            public var playgroundDescription: Any { get { fatalError() } }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ModelAlgorithmType, _ rhs: ModelAlgorithmType) -> Bool { fatalError() }
        }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case content(_: URL)
            case none
            public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public struct __Constants: Codable, Hashable, @unchecked Sendable {
        public static var inferenceChannels: Swift.Int { get { fatalError() } }
        public static var inferenceHeight: Swift.Int { get { fatalError() } }
        public static var inferenceWidth: Swift.Int { get { fatalError() } }
        public static var styleStrengthRange: Range<Swift.Int> { get { fatalError() } }
        public static var textelDensityRange: Range<Swift.Int> { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Constants, _ rhs: __Constants) -> Bool { fatalError() }
    }
    public struct __Defaults: Codable, Hashable, @unchecked Sendable {
        public static var maxIterations: Swift.Int { get { fatalError() } }
        public static var styleStrength: Swift.Int { get { fatalError() } }
        public static var textelDensity: Swift.Int { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: __Defaults, _ rhs: __Defaults) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLStyleTransfer, _ rhs: MLStyleTransfer) -> Bool { fatalError() }
}
public struct MLSupportVectorClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: TabularData.DataFrame, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLSupportVectorClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, targetColumn: Swift.String, featureColumns: [Swift.String]?, parameters: MLSupportVectorClassifier.ModelParameters) throws { fatalError() }
    public var featureColumns: [Swift.String] { get { return [] } set {} }
    public var targetColumn: Swift.String { get { fatalError() } set {} }
    public func predictions(from: MLDataTable) throws -> MLUntypedColumn { fatalError() }
    public func evaluation(on: MLDataTable) -> MLClassifierMetrics { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public var modelParameters: MLSupportVectorClassifier.ModelParameters { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func predictions(from: TabularData.DataFrame) throws -> TabularData.AnyColumn { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public func evaluation(on: TabularData.DataFrame) -> MLClassifierMetrics { fatalError() }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validation: MLSupportVectorClassifier.ModelParameters.ValidationData, maxIterations: Swift.Int, penalty: Swift.Double, convergenceThreshold: Swift.Double, featureRescaling: Swift.Bool) { fatalError() }
        public init(validationData: MLDataTable?, maxIterations: Swift.Int, penalty: Swift.Double, convergenceThreshold: Swift.Double, featureRescaling: Swift.Bool) { fatalError() }
        public var convergenceThreshold: Swift.Double { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var featureRescaling: Swift.Bool { get { fatalError() } set {} }
        public var maxIterations: Swift.Int { get { fatalError() } set {} }
        public var penalty: Swift.Double { get { fatalError() } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(_: TabularData.DataFrame)
            case none
            case split(split: MLSplitStrategy)
            case table(_: MLDataTable)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLSupportVectorClassifier, _ rhs: MLSupportVectorClassifier) -> Bool { fatalError() }
}
public struct MLTextClassifier: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: [Swift.String : [Swift.String]], parameters: MLTextClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: TabularData.DataFrame, textColumn: Swift.String, labelColumn: Swift.String, parameters: MLTextClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, textColumn: Swift.String, labelColumn: Swift.String, parameters: MLTextClassifier.ModelParameters) throws { fatalError() }
    public init(trainingData: MLTextClassifier.DataSource, parameters: MLTextClassifier.ModelParameters) throws { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public var validationMetrics: MLClassifierMetrics { get { fatalError() } }
    public func evaluation(on: MLDataTable, textColumn: Swift.String, labelColumn: Swift.String) -> MLClassifierMetrics { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public func evaluation(on: MLTextClassifier.DataSource) -> MLClassifierMetrics { fatalError() }
    public func predictions(from: [Swift.String]) throws -> [Swift.String] { return [] }
    public func prediction(from: Swift.String) throws -> Swift.String { fatalError() }
    public func evaluation(on: TabularData.DataFrame, textColumn: Swift.String, labelColumn: Swift.String) -> MLClassifierMetrics { fatalError() }
    public func predictions(from: MLDataColumn<Swift.String>) throws -> MLDataColumn<Swift.String> { fatalError() }
    public func predictionsWithConfidence(from: MLDataColumn<Swift.String>) throws -> MLDataColumn<[Swift.String : Swift.Double]> { fatalError() }
    public func predictionsWithConfidence(from: [Swift.String]) throws -> [[Swift.String : Swift.Double]] { return [] }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func evaluation(on: [Swift.String : [Swift.String]]) -> MLClassifierMetrics { fatalError() }
    public var trainingMetrics: MLClassifierMetrics { get { fatalError() } }
    public func predictionWithConfidence(from: Swift.String) throws -> [Swift.String : Swift.Double] { return [:] }
    public var description: Swift.String { get { fatalError() } }
    public var modelParameters: MLTextClassifier.ModelParameters { get { fatalError() } }
    public enum DataSource: Codable, Hashable, @unchecked Sendable {
        case labeledDirectories(labeledDirectories: URL)
        public func diagnose() -> [DataSourceIssue] { return [] }
        public func labeledTexts() throws -> [Swift.String : [Swift.String]] { return [:] }
        public func stratifiedSplit(proportions: [Swift.Double], seed: Swift.Int, labelColumn: Swift.String, textColumn: Swift.String) throws -> MLDataTable { fatalError() }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: DataSource, _ rhs: DataSource) -> Bool { fatalError() }
    }
    public enum FeatureExtractorType: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case bertEmbedding
        case customEmbedding(_: URL)
        case dynamicEmbedding
        case elmoEmbedding
        case staticEmbedding
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: FeatureExtractorType, _ rhs: FeatureExtractorType) -> Bool { fatalError() }
    }
    public enum ModelAlgorithmType: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case crf(crf: Swift.Int?)
        case maxEnt(maxEnt: Swift.Int?)
        case transferLearning(MLTextClassifier.FeatureExtractorType, Swift.Int?)
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelAlgorithmType, _ rhs: ModelAlgorithmType) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validationData: MLTextClassifier.DataSource, algorithm: MLTextClassifier.ModelAlgorithmType, language: NLLanguage?) { fatalError() }
        public init(validation: MLTextClassifier.ModelParameters.ValidationData, algorithm: MLTextClassifier.ModelAlgorithmType, language: NLLanguage?) { fatalError() }
        public init(validationData: [Swift.String : [Swift.String]], algorithm: MLTextClassifier.ModelAlgorithmType, language: NLLanguage?) { fatalError() }
        public init(validationData: MLDataTable?, algorithm: MLTextClassifier.ModelAlgorithmType, language: NLLanguage?, textColumnValidationData: Swift.String?, labelColumnValidationData: Swift.String?) { fatalError() }
        public var algorithm: MLTextClassifier.ModelAlgorithmType { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var labelColumnValidationData: Swift.String? { get { return nil } set {} }
        public var language: NLLanguage? { get { return nil } set {} }
        public var maxIterations: Swift.Int? { get { return nil } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var textColumnValidationData: Swift.String? { get { return nil } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(TabularData.DataFrame, Swift.String, Swift.String)
            case dataSource(_: MLTextClassifier.DataSource)
            case dictionary(_: [Swift.String : [Swift.String]])
            case none
            case split(split: MLSplitStrategy)
            case table(MLDataTable, Swift.String, Swift.String)
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLTextClassifier, _ rhs: MLTextClassifier) -> Bool { fatalError() }
}
@_fixed_layout final public class MLTrainingSession<A> {
    public final var checkpoints: [MLCheckpoint] { get { return [] } }
    public final var iteration: Swift.Int { get { fatalError() } }
    public final var parameters: MLTrainingSessionParameters { get { fatalError() } }
    public final var phase: MLPhase { get { fatalError() } }
    public final func removeCheckpoints(_ arg1: (MLCheckpoint) -> Swift.Bool) throws -> () {}
    public final var date: Date { get { fatalError() } }
    public final func reuseExtractedFeatures(from: MLTrainingSession<A>) throws -> () {}
}
public struct MLTrainingSessionParameters: Codable, Hashable, @unchecked Sendable {
    public init(sessionDirectory: URL?, reportInterval: Swift.Int, checkpointInterval: Swift.Int, iterations: Swift.Int) { fatalError() }
    public var checkpointInterval: Swift.Int { get { fatalError() } set {} }
    public var iterations: Swift.Int { get { fatalError() } set {} }
    public var reportInterval: Swift.Int { get { fatalError() } set {} }
    public var sessionDirectory: URL? { get { return nil } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLTrainingSessionParameters, _ rhs: MLTrainingSessionParameters) -> Bool { fatalError() }
}
public struct MLUntypedColumn: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(doubles: MLUntypedColumn) { fatalError() }
    public init(_ arg1: Range<Swift.Int>) { fatalError() }
    public init(sequences: MLUntypedColumn) { fatalError() }
    public init<A>(_ arg1: A) where A: Sequence, A.Element == MLDataValue { fatalError() }
    public init(repeating: MLDataValue, count: Swift.Int) { fatalError() }
    public init(multiArrays: MLUntypedColumn) { fatalError() }
    public init(strings: MLUntypedColumn) { fatalError() }
    public init(_ arg1: ClosedRange<Swift.Int>) { fatalError() }
    public init<A>(repeating: A, count: Swift.Int) where A: MLDataValueConvertible { fatalError() }
    public init(dictionaries: MLUntypedColumn) { fatalError() }
    public init<A>(_ arg1: A) where A: Sequence, A.Element: MLDataValueConvertible { fatalError() }
    public init(ints: MLUntypedColumn) { fatalError() }
    public init() { fatalError() }
    public static func <=(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func >(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public func map<GenericA>(_ arg1: @escaping (_ arg1: MLDataValue) -> GenericA) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public subscript(_ arg1: Range<Swift.Int>) -> MLUntypedColumn { get { fatalError() } }
    public static func /(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public func dropDuplicates() -> MLUntypedColumn { fatalError() }
    public static func <=(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func <(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func >=(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public static func == (lhs: any MLDataValueConvertible, rhs: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public var doubles: MLDataColumn<Swift.Double>? { get { return nil } }
    public var isEmpty: Swift.Bool { get { fatalError() } }
    public static func == (lhs: Self, rhs: Self) -> MLUntypedColumn { fatalError() }
    public subscript(_ arg1: Swift.Int) -> MLDataValue { get { fatalError() } }
    public var ints: MLDataColumn<Swift.Int>? { get { return nil } }
    public func suffix(_ arg1: Swift.Int) -> MLUntypedColumn { fatalError() }
    public static func >=(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func *(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public static func -(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public static func !=(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public static func >(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public func materialize() throws -> MLUntypedColumn { fatalError() }
    public static func !=(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public static func &&(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func -(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public subscript(_ arg1: MLUntypedColumn) -> MLUntypedColumn { get { fatalError() } }
    public static func >=(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func >(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public func show() -> any MLStreamingVisualizable { fatalError() }
    public static func <=(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public static func <(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public var dictionaries: MLDataColumn<MLDataValue.DictionaryType>? { get { return nil } }
    public static func +(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public var debugDescription: Swift.String { get { fatalError() } }
    public static func *(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public func prefix(_ arg1: Swift.Int) -> MLUntypedColumn { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public func mapMissing<GenericA>(_ arg1: @escaping (_ arg1: MLDataValue) -> GenericA?) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public func copy() -> MLUntypedColumn { fatalError() }
    public static func ||(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func /(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public func column<GenericA>(type: GenericA.Type) -> MLDataColumn<GenericA>? where GenericA: MLDataValueConvertible { return nil }
    public static func == (lhs: MLUntypedColumn, rhs: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public subscript(_ arg1: MLDataColumn<Swift.Bool>) -> MLUntypedColumn { get { fatalError() } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public static func +(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func /(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func -(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public func fillMissing(with: MLDataValue) -> MLUntypedColumn { fatalError() }
    public subscript<GenericA>(_ arg1: GenericA) -> MLUntypedColumn where GenericA: RangeExpression, GenericA.Bound == Swift.Int { get { fatalError() } }
    public var sequences: MLDataColumn<MLDataValue.SequenceType>? { get { return nil } }
    public static func +(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public var count: Swift.Int { get { fatalError() } }
    public var error: (any Error)? { get { return nil } }
    public func dropMissing() -> MLUntypedColumn { fatalError() }
    public func sort(byIncreasingOrder: Swift.Bool) -> MLUntypedColumn { fatalError() }
    public var customMirror: Mirror { get { fatalError() } }
    public func map<GenericA>(to: GenericA.Type) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public func map<GenericA>(_ arg1: @escaping (_ arg1: MLDataValue) -> GenericA?) -> MLDataColumn<GenericA> where GenericA: MLDataValueConvertible { fatalError() }
    public var type: MLDataValue.ValueType { get { fatalError() } }
    public func append(contentsOf: MLUntypedColumn) -> () {}
    public var multiArrays: MLDataColumn<MLDataValue.MultiArrayType>? { get { return nil } }
    public var strings: MLDataColumn<Swift.String>? { get { return nil } }
    public static func !=(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public static func <(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
    public static func *(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
public protocol MLVisualizable: CustomPlaygroundDisplayConvertible {
    var cgImage: CGImageRef? { get }
}
public struct MLWordEmbedding: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(dictionary: [Swift.String : [Swift.Double]], parameters: MLWordEmbedding.ModelParameters) throws { fatalError() }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public var debugDescription: Swift.String { get { fatalError() } }
    public func contains(_ arg1: Swift.String) -> Swift.Bool { fatalError() }
    public var model: MLModel { get { fatalError() } set {} }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public func vector(for: Swift.String) -> [Swift.Double]? { return nil }
    public var dimension: Swift.Int { get { fatalError() } }
    public var vocabularySize: Swift.Int { get { fatalError() } }
    public func prediction(from: Swift.String, maxCount: Swift.Int, maxDistance: Swift.Double, distanceType: NLDistanceType) throws -> [(text: Swift.String, distance: Swift.Double)] { return [] }
    public var description: Swift.String { get { fatalError() } }
    public var modelParameters: MLWordEmbedding.ModelParameters { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public func distance(between: Swift.String, and: Swift.String, distanceType: NLDistanceType) -> Swift.Double { fatalError() }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(language: NLLanguage?, revision: Swift.Int) { fatalError() }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var language: NLLanguage? { get { return nil } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var revision: Swift.Int { get { fatalError() } set {} }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLWordEmbedding, _ rhs: MLWordEmbedding) -> Bool { fatalError() }
}
public struct MLWordTagger: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public init(trainingData: TabularData.DataFrame, tokenColumn: Swift.String, labelColumn: Swift.String, parameters: MLWordTagger.ModelParameters) throws { fatalError() }
    public init(trainingData: [(tokens: [Swift.String], labels: [Swift.String])], parameters: MLWordTagger.ModelParameters) throws { fatalError() }
    public init(trainingData: MLDataTable, tokenColumn: Swift.String, labelColumn: Swift.String, parameters: MLWordTagger.ModelParameters) throws { fatalError() }
    public func evaluation(on: [(tokens: [Swift.String], labels: [Swift.String])]) -> MLWordTaggerMetrics { fatalError() }
    public var description: Swift.String { get { fatalError() } }
    public var model: MLModel { get { fatalError() } set {} }
    public func predictions(from: MLDataColumn<Swift.String>) throws -> MLDataTable { fatalError() }
    public func write(to: URL, metadata: MLModelMetadata?) throws -> () {}
    public var modelParameters: MLWordTagger.ModelParameters { get { fatalError() } }
    public var trainingMetrics: MLWordTaggerMetrics { get { fatalError() } }
    public func prediction(from: Swift.String) throws -> [Swift.String] { return [] }
    public var debugDescription: Swift.String { get { fatalError() } }
    public func evaluation(on: TabularData.DataFrame, tokenColumn: Swift.String, labelColumn: Swift.String) -> MLWordTaggerMetrics { fatalError() }
    public var playgroundDescription: Any { get { fatalError() } }
    public var validationMetrics: MLWordTaggerMetrics { get { fatalError() } }
    public func predictionWithConfidence(from: [Swift.String]) throws -> [[Swift.String : Swift.Double]] { return [] }
    public func write(toFile: Swift.String, metadata: MLModelMetadata?) throws -> () {}
    public func predictions<GenericA>(from: GenericA) throws -> TabularData.DataFrame where GenericA: Sequence, GenericA.Element == Swift.String { fatalError() }
    public func predictionWithConfidence(from: Swift.String) throws -> [[Swift.String : Swift.Double]] { return [] }
    public func prediction(from: [Swift.String]) throws -> [Swift.String] { return [] }
    public func evaluation(on: MLDataTable, tokenColumn: Swift.String, labelColumn: Swift.String) -> MLWordTaggerMetrics { fatalError() }
    public enum FeatureExtractorType: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case bertEmbedding
        case dynamicEmbedding
        case elmoEmbedding
        public var debugDescription: Swift.String { get { fatalError() } }
        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
        public var description: Swift.String { get { fatalError() } }
        public var hashValue: Swift.Int { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public func hash(into: inout Hasher) -> () {}
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    }
    public enum ModelAlgorithmType: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        case crf(crf: Swift.Int?)
        case transferLearning(MLWordTagger.FeatureExtractorType, Swift.Int)
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var playgroundDescription: Any { get { fatalError() } }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelAlgorithmType, _ rhs: ModelAlgorithmType) -> Bool { fatalError() }
    }
    public struct ModelParameters: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
        public init(validationData: MLDataTable?, algorithm: MLWordTagger.ModelAlgorithmType, language: NLLanguage?, tokenColumnValidationData: Swift.String?, labelColumnValidationData: Swift.String?) { fatalError() }
        public init(validation: MLWordTagger.ModelParameters.ValidationData, algorithm: MLWordTagger.ModelAlgorithmType, language: NLLanguage?) { fatalError() }
        public init(validationData: [(tokens: [Swift.String], labels: [Swift.String])], algorithm: MLWordTagger.ModelAlgorithmType, language: NLLanguage?) { fatalError() }
        public var algorithm: MLWordTagger.ModelAlgorithmType { get { fatalError() } set {} }
        public var debugDescription: Swift.String { get { fatalError() } }
        public var description: Swift.String { get { fatalError() } }
        public var labelColumnValidationData: Swift.String? { get { return nil } set {} }
        public var language: NLLanguage? { get { return nil } set {} }
        public var maxIterations: Swift.Int? { get { return nil } set {} }
        public var playgroundDescription: Any { get { fatalError() } }
        public var tokenColumnValidationData: Swift.String? { get { return nil } set {} }
        public var validation: ValidationData { get { fatalError() } set {} }
        public var validationData: MLDataTable? { get { return nil } set {} }
        public enum ValidationData: Codable, Hashable, @unchecked Sendable {
            case dataFrame(TabularData.DataFrame, Swift.String, Swift.String)
            case none
            case split(split: MLSplitStrategy)
            case table(MLDataTable, Swift.String, Swift.String)
            case tuples(_: [(tokens: [Swift.String], labels: [Swift.String])])
            public init(from decoder: any Swift.Decoder) throws { fatalError() }
            public func encode(to encoder: Swift.Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
            public static func ==(_ lhs: ValidationData, _ rhs: ValidationData) -> Bool { fatalError() }
        }
        public init(from decoder: any Swift.Decoder) throws { fatalError() }
        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
        public static func ==(_ lhs: ModelParameters, _ rhs: ModelParameters) -> Bool { fatalError() }
    }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLWordTagger, _ rhs: MLWordTagger) -> Bool { fatalError() }
}
public struct MLWordTaggerMetrics: Codable, CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Hashable, @unchecked Sendable {
    public var confusion: MLDataTable { get { fatalError() } }
    public var confusionDataFrame: TabularData.DataFrame { get { fatalError() } }
    public var debugDescription: Swift.String { get { fatalError() } }
    public var description: Swift.String { get { fatalError() } }
    public var error: (any Error)? { get { return nil } }
    public var isValid: Swift.Bool { get { fatalError() } }
    public var playgroundDescription: Any { get { fatalError() } }
    public var precisionRecall: MLDataTable { get { fatalError() } }
    public var precisionRecallDataFrame: TabularData.DataFrame { get { fatalError() } }
    public var taggingError: Swift.Double { get { fatalError() } }
    public init(from decoder: any Swift.Decoder) throws { fatalError() }
    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
    public static func ==(_ lhs: MLWordTaggerMetrics, _ rhs: MLWordTaggerMetrics) -> Bool { fatalError() }
}
public var MLCreateErrorDomain: Swift.String { get { fatalError() } }
public func show(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> any MLStreamingVisualizable { fatalError() }
public func show(_ arg1: MLUntypedColumn) -> any MLStreamingVisualizable { fatalError() }
public func show(_ arg1: MLDataTable) -> any MLStreamingVisualizable { fatalError() }
public func show<A, B>(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<B>) -> any MLStreamingVisualizable where A: MLDataValueConvertible, B: MLDataValueConvertible { fatalError() }
public func show<A>(_ arg1: MLDataColumn<A>) -> any MLStreamingVisualizable where A: MLDataValueConvertible { fatalError() }
public func timestampSeed() -> Swift.Int { fatalError() }
extension MLDataColumn where A == MLDataValue.DictionaryType {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
}
extension MLDataColumn where A == MLDataValue.SequenceType {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
}
extension MLDataColumn where A == Swift.Bool {
    public static func ||(_ arg1: MLDataColumn<Swift.Bool>, _ arg2: MLDataColumn<Swift.Bool>) -> MLDataColumn<Swift.Bool> { fatalError() }
    public static func &&(_ arg1: MLDataColumn<Swift.Bool>, _ arg2: MLDataColumn<Swift.Bool>) -> MLDataColumn<Swift.Bool> { fatalError() }
}
extension MLDataColumn where A == Swift.Double {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
    public static func -(_ arg1: MLDataColumn<Swift.Double>, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func *(_ arg1: MLDataColumn<Swift.Double>, _ arg2: Swift.Double) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func *(_ arg1: MLDataColumn<Swift.Double>, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
    public func sum() -> Swift.Double? { return nil }
    public func max() -> Swift.Double? { return nil }
    public static func +(_ arg1: MLDataColumn<Swift.Double>, _ arg2: Swift.Double) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func /(_ arg1: MLDataColumn<Swift.Double>, _ arg2: Swift.Double) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func -(_ arg1: Swift.Double, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func -(_ arg1: MLDataColumn<Swift.Double>, _ arg2: Swift.Double) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func +(_ arg1: Swift.Double, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
    public func min() -> Swift.Double? { return nil }
    public static func /(_ arg1: Swift.Double, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
    public func std() -> Swift.Double? { return nil }
    public func mean() -> Swift.Double? { return nil }
    public func stdev() -> Swift.Double? { return nil }
    public static func /(_ arg1: MLDataColumn<Swift.Double>, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func *(_ arg1: Swift.Double, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
    public static func +(_ arg1: MLDataColumn<Swift.Double>, _ arg2: MLDataColumn<Swift.Double>) -> MLDataColumn<Swift.Double> { fatalError() }
}
extension MLDataColumn where A == Swift.Int {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
    public func stdev() -> Swift.Double? { return nil }
    public static func /(_ arg1: Swift.Int, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func /(_ arg1: MLDataColumn<Swift.Int>, _ arg2: Swift.Int) -> MLDataColumn<Swift.Int> { fatalError() }
    public func mean() -> Swift.Double? { return nil }
    public func max() -> Swift.Int? { return nil }
    public static func /(_ arg1: MLDataColumn<Swift.Int>, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
    public func std() -> Swift.Double? { return nil }
    public static func *(_ arg1: MLDataColumn<Swift.Int>, _ arg2: Swift.Int) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func -(_ arg1: MLDataColumn<Swift.Int>, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func +(_ arg1: Swift.Int, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func -(_ arg1: MLDataColumn<Swift.Int>, _ arg2: Swift.Int) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func *(_ arg1: Swift.Int, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func -(_ arg1: Swift.Int, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
    public func min() -> Swift.Int? { return nil }
    public func sum() -> Swift.Int? { return nil }
    public static func +(_ arg1: MLDataColumn<Swift.Int>, _ arg2: Swift.Int) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func *(_ arg1: MLDataColumn<Swift.Int>, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
    public static func +(_ arg1: MLDataColumn<Swift.Int>, _ arg2: MLDataColumn<Swift.Int>) -> MLDataColumn<Swift.Int> { fatalError() }
}
extension MLDataColumn where A == Swift.String {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
}
extension MLDataColumn where A == [Swift.Double] {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
}
extension MLDataColumn where A == [Swift.Int] {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
}
extension MLDataColumn where A == [Swift.String] {
    public init<A1>(column: MLDataColumn<A1>) where A1: MLDataValueConvertible { fatalError() }
}
public typealias Foundation_URL = Foundation.URL
public typealias Swift_Array = Array
public typealias Swift_Bool = Swift.Bool
public typealias Swift_Decoder = Swift.Decoder
public typealias Swift_Dictionary = Dictionary
public typealias Swift_Double = Swift.Double
public typealias Swift_Encoder = Swift.Encoder
public typealias Swift_Float = Swift.Float
public typealias Swift_Hasher = Hasher
public typealias Swift_Int = Swift.Int
public typealias Swift_Int32 = Swift.Int32
public typealias Swift_Int64 = Swift.Int64
public typealias Swift_Optional = Optional
public struct Swift_RandomNumberGenerator: Hashable, Codable, Sendable {}
public struct Swift_RangeExpression: Hashable, Codable, Sendable {}
public typealias Swift_Sequence = Sequence
public typealias Swift_String = Swift.String
public typealias TabularData_AnyColumn = TabularData.AnyColumn
public typealias TabularData_DataFrame = TabularData.DataFrame
public typealias __C_CGRect = CGRect
public typealias __C_CGSize = CGSize
public typealias __C_MLMultiArray = MLMultiArray
public typealias __C_NLDistanceType = NLDistanceType
public typealias __C_NSProgress = NSProgress
public typealias __C_VNImageCropAndScaleOption = VNImageCropAndScaleOption
public struct AnyColumn: Hashable, Codable, Sendable {}
public struct AnyPublisher<T, U>: Hashable, Codable, Sendable {}
public struct Bound: Hashable, Codable, Sendable {}
public protocol Cancellable {}
public protocol CustomPlaygroundDisplayConvertible {}
public struct DataFrame: Hashable, Codable, Sendable {}
public struct IoU50: Hashable, Codable, Sendable {}
public struct MLModel: Hashable, Codable, Sendable {}
public struct NLLanguage: Hashable, Codable, Sendable {}
public struct NSProgressUserInfoKey: Hashable, Codable, Sendable {}
public struct RandomNumberGenerator: Hashable, Codable, Sendable {}
public struct RangeExpression: Hashable, Codable, Sendable {}

public func dummyDefaultValue<T>() -> T { fatalError() }

public struct GenericA: Hashable, Codable, Sendable {}
public struct GenericB: Hashable, Codable, Sendable {}
public struct GenericC: Hashable, Codable, Sendable {}
public struct GenericD: Hashable, Codable, Sendable {}
public struct A1: Hashable, Codable, Sendable {}
public struct B1: Hashable, Codable, Sendable {}
public struct C1: Hashable, Codable, Sendable {}
public struct D1: Hashable, Codable, Sendable {}

