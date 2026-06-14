import CoreFoundation
import CoreMedia
import CoreVideo
import Foundation
import IOSurface
import ObjectiveC
import Swift
import UniformTypeIdentifiers
import os
public class Compiler {
    public struct CompilationContext: Codable, Hashable, Sendable {
        public init() {}
        public var debugConfiguration: Compiler.DebugConfiguration { get { fatalError() } set {} }
        public var profiler: CoreAICommon_Profiler { get { fatalError() } set {} }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum CompilationType: Hashable, Sendable {
        case _mock
    }
    public struct CompiledBytecodeConfig: Codable, Hashable, Sendable {
        public init() {}
        public var excludeNonInferenceFunctions: Bool { get { return false } set {} }
        public var replaceGetContextWithConstants: Bool { get { return false } set {} }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct DebugConfiguration: Codable, Hashable, Sendable {
        public struct MLIRDumpConfiguration: Codable, Hashable, Sendable {
            public init(from: Decoder) throws {}
            public init() {}
            public var elideResources: Bool { get { return false } set {} }
            public func hash(into: inout Hasher) -> () {}
            public func encode(to: Encoder) throws -> () {}
            public var includeLocations: Bool { get { return false } set {} }
            public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
            public var bytecode: Bool { get { return false } set {} }
            public var hashValue: Int { get { return 0 } }
        }
        public init() {}
        public var compiledModuleDumpConfiguration: Optional<MLIRDumpConfiguration> { get { return nil } set {} }
        public var enableDebugInfo: Bool { get { return false } set {} }
        public var hashValue: Int { get { return 0 } }
        public var writeDebugInfo: Bool { get { return false } set {} }
        public static func ==(arg1: Self, arg2: Self) -> Bool { return false }
        public var printIRAfterAll: Bool { get { return false } set {} }
        public func hash(into: inout Hasher) -> () {}
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
    }
    public struct DelegateConfiguration: Codable, Hashable, Sendable {
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct Delegates: Codable, Hashable, Sendable {
        public protocol BinaryGenerator {
            func compile(moduleBytecode: _RawSpan, to: URL, with: Compiler.CompilationContext) throws -> Compiler.Delegates.SharedBytecode
            var id: String { get }
            var supportsPartialCompilation: Bool { get }
            func compile(moduleBytecode: _RawSpan, intermediateResult: Optional<URL>, to: URL, with: Compiler.CompilationContext) throws -> Compiler.Delegates.SharedBytecode
            var irConfiguration: Compiler.Delegates.IRConfiguration { get }
            func compile(moduleBytecode: _RawSpan, to: URL, with: Compiler.Delegates.BinaryGeneratorContext) throws -> Compiler.Delegates.SharedBytecode
            func compiledModuleBytecode(from: URL, for: _RawSpan) throws -> Compiler.Delegates.SharedBytecode
        }
        public struct BinaryGeneratorContext: Codable, Hashable, Sendable {
            public protocol ResourceBlobManager {
                func lookupResource(id: String) -> Optional<UnsafeRawBufferPointer>
            }
            public var blobManager: any ResourceBlobManager { get { fatalError() } }
            public var compilationContext: Compiler.CompilationContext { get { fatalError() } }
            public var inputDirectory: Optional<URL> { get { return nil } }
            public init(from decoder: any Decoder) throws {}
            public func encode(to encoder: any Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public struct DebugInfoWriter: Codable, Hashable, Sendable {
            public static func write(bytecode: Compiler.Delegates.SharedBytecode, to: URL, idAttribute: Optional<String>) throws -> () {}
            public init(from decoder: any Decoder) throws {}
            public func encode(to encoder: any Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public struct IRConfiguration: Codable, Hashable, Sendable {
            public init(bytecodeVersion: Int, dialectVersion: Int, dialectEncodingScheme: Int) {}
            public init(bytecodeVersion: Int, dialectVersion: Int, dialectEncodingScheme: Int, supportsPartialCompilation: Bool) {}
            public var bytecodeVersion: Int { get { return 0 } }
            public var dialectEncodingScheme: Int { get { return 0 } }
            public var dialectVersion: Int { get { return 0 } }
            public var perOpVersions: Dictionary<String, UInt32> { get { return [:] } set {} }
            public var supportsExternalResources: Bool { get { return false } set {} }
            public var supportsPartialCompilation: Bool { get { return false } set {} }
            public init(from decoder: any Decoder) throws {}
            public func encode(to encoder: any Encoder) throws { fatalError() }
            public func hash(into hasher: inout Hasher) { fatalError() }
        }
        public enum Plugin: Hashable, Sendable {
            case _mock
        }
        public protocol Segmenter {
            func segment(moduleBytecode: _RawSpan, with: Compiler.CompilationContext) throws -> Compiler.Delegates.SharedBytecode
            var irConfiguration: Compiler.Delegates.IRConfiguration { get }
        }
        public class SharedBytecode {
            public init(bytes: UnsafeRawBufferPointer, deallocator: Optional<(__owned UnsafeRawBufferPointer) -> ()>) {}
            public var bytes: UnsafeRawBufferPointer { get { fatalError() } }
        }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public enum Errors: Hashable, Sendable {
        case _mock
    }
    public enum Module: Hashable, Sendable {
        case _mock
        public func data(version: Int) -> Data { return Data() }
        public func write(to: URL, version: Int) throws -> () {}
        public func write(to: URL) throws -> () {}
    }
    public struct Options: Codable, Hashable, Sendable {
        public init() {}
        public var debugConfiguration: Compiler.DebugConfiguration { get { fatalError() } set {} }
        public var delegatePlugins: Array<Compiler.Delegates.Plugin> { get { return [] } set {} }
        public var enableEncodingFunctions: Bool { get { return false } set {} }
        public var profiler: CoreAICommon_Profiler { get { fatalError() } set {} }
        public var requireFullDelegation: Bool { get { return false } set {} }
        public var resourcesDirectory: Optional<URL> { get { return nil } set {} }
        public var targetSpecification: Optional<Compiler.TargetSpecification> { get { return nil } set {} }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct TargetSpecification: Codable, Hashable, Sendable {
        public init(targetTriple: String, targetSOC: String) {}
        public var compilation: Compiler.CompilationType { get { fatalError() } set {} }
        public var specialization: String { get { return "" } set {} }
        public var targetDelegateOptions: String { get { return "" } set {} }
        public var targetSOC: String { get { return "" } set {} }
        public var targetTriple: String { get { return "" } set {} }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public static func compile(module: Compiler.Module, intermediateResult: Optional<URL>, to: URL, using: Compiler.Options) async throws -> () {}
    public static var latestDialectVersion: Int { get { return 0 } }
    public static func compiledModuleBytecode(from: URL, for: Set<String>, targetSpecification: Optional<Compiler.TargetSpecification>, delegates: Array<Compiler.Delegates.BinaryGenerator>, config: Compiler.CompiledBytecodeConfig) async throws -> Dictionary<String, Compiler.Delegates.SharedBytecode> { return [:] }
    public static func compile(module: Compiler.Module, to: URL, using: Compiler.Options) async throws -> () {}
}
public struct ProgramMetadata: Codable, Hashable, Sendable {
    public enum CompatibilityVersion: Hashable, Sendable {
        case _mock
        public var range: ClosedRange<Int> { get { fatalError() } }
    }
    public struct Feature: Codable, Hashable, Sendable {
        public init(name: String, typeDescription: String) {}
        public var name: String { get { return "" } set {} }
        public var typeDescription: String { get { return "" } set {} }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public struct GraphDescription: Codable, Hashable, Sendable {
        public init(name: String, inputs: Array<ProgramMetadata.Feature>, states: Array<ProgramMetadata.Feature>, outputs: Array<ProgramMetadata.Feature>) {}
        public var inputs: Array<ProgramMetadata.Feature> { get { return [] } set {} }
        public var name: String { get { return "" } set {} }
        public var outputs: Array<ProgramMetadata.Feature> { get { return [] } set {} }
        public var states: Array<ProgramMetadata.Feature> { get { return [] } set {} }
        public init(from decoder: any Decoder) throws {}
        public func encode(to encoder: any Encoder) throws { fatalError() }
        public func hash(into hasher: inout Hasher) { fatalError() }
    }
    public init() {}
    public var compatibilityVersion: Optional<ProgramMetadata.CompatibilityVersion> { get { return nil } }
    public var computeTypes: Array<String> { get { return [] } set {} }
    public var graphDescriptions: Array<ProgramMetadata.GraphDescription> { get { return [] } set {} }
    public var operationDistribution: Array<(String, Int)> { get { return [] } set {} }
    public var storageTypes: Array<(String, Int)> { get { return [] } set {} }
    public var version: Int { get { return 0 } set {} }
    public init(from decoder: any Decoder) throws {}
    public func encode(to encoder: any Encoder) throws { fatalError() }
    public func hash(into hasher: inout Hasher) { fatalError() }
}
extension Compiler: Equatable { public static func == (lhs: Compiler, rhs: Compiler) -> Bool { fatalError() } }
extension Compiler.Delegates.SharedBytecode: Equatable { public static func == (lhs: Compiler.Delegates.SharedBytecode, rhs: Compiler.Delegates.SharedBytecode) -> Bool { fatalError() } }
public struct CoreAICommon_Profiler: Hashable, Codable, Sendable {}
public struct _RawSpan: Hashable, Codable, Sendable {}

