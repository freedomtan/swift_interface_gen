import Foundation

extension SwiftInterfaceGen {
    static func postProcessCoreML(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix: `extension ClosedRange/Range where Bound == Swift.Int` add
            // _mlTensorRange/relative(toShapedArrayAxis:) members satisfying
            // MLTensorRangeExpression/MLShapedArrayRangeExpression but never declare either
            // conformance -- same "retroactive conditional conformance never declared" gap fixed
            // repeatedly elsewhere this session. Since Bound == Int makes this a concrete (not
            // generic) conformance, both the conformance descriptor AND witness table are
            // expected and confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "extension ClosedRange where Bound == Swift.Int {",
                with: "extension ClosedRange: MLTensorRangeExpression, MLShapedArrayRangeExpression where Bound == Swift.Int {")
            c = c.replacingOccurrences(
                of: "extension Range where Bound == Swift.Int {",
                with: "extension Range: MLTensorRangeExpression, MLShapedArrayRangeExpression where Bound == Swift.Int {")

            // Fix: `extension MLShapedArray/MLShapedArraySlice where A: Decodable/Encodable/
            // Equatable` add the matching init(from:)/encode(to:)/== members but never declare
            // the conformances themselves -- same "retroactive conditional conformance never
            // declared" gap fixed repeatedly elsewhere this session. Confirmed via a minimal
            // repro that only the conformance descriptors are needed (no witness tables, unlike
            // protocols with real requirement witnessing machinery).
            c = c.replacingOccurrences(
                of: "extension MLShapedArray where A: Decodable {",
                with: "extension MLShapedArray: Decodable where A: Decodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArray where A: Encodable {",
                with: "extension MLShapedArray: Encodable where A: Encodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArray where A: Equatable {",
                with: "extension MLShapedArray: Equatable where A: Equatable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArraySlice where A: Decodable {",
                with: "extension MLShapedArraySlice: Decodable where A: Decodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArraySlice where A: Encodable {",
                with: "extension MLShapedArraySlice: Encodable where A: Encodable {")
            c = c.replacingOccurrences(
                of: "extension MLShapedArraySlice where A: Equatable {",
                with: "extension MLShapedArraySlice: Equatable where A: Equatable {")

            // Fix: withMLTensorComputePolicy's closure params are declared @escaping, but the
            // real ABI mangles them as non-escaping (`XE`, not `c`) -- confirmed via minimal
            // repro that dropping @escaping alone produces exact byte-for-byte matches for both
            // overloads and the async variant's async function pointer.
            c = c.replacingOccurrences(
                of: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: @escaping () throws -> A) throws -> A { fatalError() }",
                with: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: () throws -> A) throws -> A { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: @escaping () async throws -> A) async throws -> A { fatalError() }",
                with: "public func withMLTensorComputePolicy<A>(_ arg1: MLComputePolicy, _ arg2: () async throws -> A) async throws -> A { fatalError() }")

            // Fix: MLTensor is missing the .>/.</.>=/.<= comparison operators entirely (both the
            // MLTensor-MLTensor overload and the generic-scalar overload), while its sibling
            // .==/.!= operators ARE present -- confirmed via minimal repro these are simply
            // missing declarations, adding them alongside .== produces exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public static func .==(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }",
                with: """
                public static func .==(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .>(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .><GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                    public static func .<(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .<<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                    public static func .>=(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .>=<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                    public static func .<=(_ arg1: MLTensor, _ arg2: MLTensor) -> MLTensor { fatalError() }
                    public static func .<=<GenericA>(_ arg1: MLTensor, _ arg2: GenericA) -> MLTensor where GenericA: MLTensorScalar,  GenericA: Numeric { fatalError() }
                """)

            // Fix: MLTensor.init(rangeFrom:to:by:scalarType:)'s `by` param is declared as `Any`
            // instead of the real `A.Stride` (A: Strideable) -- confirmed via minimal repro that
            // using the correct associated-type produces an exact byte-for-byte match.
            c = c.replacingOccurrences(
                of: "public init<A>(rangeFrom: A, to: A, by: Any, scalarType: A.Type) where A: MLTensorScalar,  A: Strideable { fatalError() }",
                with: "public init<A>(rangeFrom: A, to: A, by: A.Stride, scalarType: A.Type) where A: MLTensorScalar,  A: Strideable { fatalError() }")

            // Fix: MLTensor's 4 UnboundedRange-taking subscripts. 3 of the 4 leading-Range-count
            // variants (1/2/3 leading `(any MLTensorRangeExpression)?` params before the closure)
            // exist but declare the closure param `@escaping`, which mangles as a plain function
            // type (`c`) instead of the real noescape shape (`XE`); the 4th variant (0 leading
            // ranges, i.e. just the closure + trailing variadic) is missing outright. Confirmed
            // via minimal repro that dropping @escaping on the 3 existing ones, and adding the
            // missing 4th with the same non-escaping shape, produces exact byte-for-byte matches
            // for all 4.
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: (any MLTensorRangeExpression)?, _ arg4: @escaping (UnboundedRange_) -> (), _ arg5: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: (any MLTensorRangeExpression)?, _ arg4: (UnboundedRange_) -> (), _ arg5: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: @escaping (UnboundedRange_) -> (), _ arg4: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (any MLTensorRangeExpression)?, _ arg3: (UnboundedRange_) -> (), _ arg4: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: @escaping (UnboundedRange_) -> (), _ arg3: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (any MLTensorRangeExpression)?, _ arg2: (UnboundedRange_) -> (), _ arg3: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: @escaping (UnboundedRange_) -> (), _ arg2: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }",
                with: "public subscript(_ arg1: (UnboundedRange_) -> (), _ arg2: (any MLTensorRangeExpression)?...) -> MLTensor { get { fatalError() } }")

            // Fix: MLIRRepresentation.sourceIR is declared as a synchronous getter, but the real
            // ABI requires an async getter (hence the missing async function pointer symbol) --
            // confirmed via minimal repro that `get async` alone produces an exact byte-for-byte
            // match for both the getter and its async function pointer.
            c = c.replacingOccurrences(
                of: "public var sourceIR: Data { get { return Data() } }",
                with: "public var sourceIR: Data { get async { return Data() } }")

            // Fix: MLShapedArrayProtocol's UnboundedRange-taking subscript declares its closure
            // param `@escaping` -- same bug as MLTensor's equivalent subscripts above, mangling
            // as a plain function type (`c`) instead of the real noescape shape (`XE`). Confirmed
            // via minimal repro that dropping @escaping produces exact byte-for-byte matches for
            // the getter, setter, AND modify accessor.
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: @escaping (UnboundedRange_) -> ()) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }",
                with: "public subscript(_ arg1: (UnboundedRange_) -> ()) -> MLShapedArraySlice<Self.Scalar> { get { fatalError() } set {} }")

            // Fix: the real ABI has `_OBJC_CLASS_$_MLModelStructure`/`_OBJC_METACLASS_$_MLModelStructure`
            // and the same pair for MLOptimizationHints, but the real .swiftinterface shows both
            // names as genuine Swift value types (enum/struct) with no ObjC class at all -- these
            // ObjC symbols belong to a private, non-public-API ObjC-bridging implementation class
            // that happens to share the same runtime name. Confirmed via minimal repro that a
            // hidden `@objc(Name) open class` with a DIFFERENT Swift-visible identifier can coexist
            // with the public enum/struct of the same runtime name and produces the exact required
            // linker symbols without conflicting with the public declaration.
            c = c.replacingOccurrences(
                of: "public enum MLModelStructure: Codable, Hashable, @unchecked Sendable {",
                with: """
                @objc(MLModelStructure) open class _MLModelStructureObjCShadow: NSObject {}
                public enum MLModelStructure: Codable, Hashable, @unchecked Sendable {
                """)
            c = c.replacingOccurrences(
                of: "public struct MLOptimizationHints: Equatable {",
                with: """
                @objc(MLOptimizationHints) open class _MLOptimizationHintsObjCShadow: NSObject {}
                public struct MLOptimizationHints: Equatable {
                """)
            // NOTE: MLComputePlan is missing its metaclass/deinit symbols (has no declared
            // initializer and is only ever constructed via static factory methods). Tried adding
            // an explicit `override init()` (both `private` and `public`), matching the
            // SoundAnalysis "final-only members don't need a vtable" pattern from earlier this
            // session, but neither reproduced the missing symbols -- root cause not yet found;
            // left as a documented open item rather than force an ineffective change.
            // MLComputeDeviceProtocol is a real Objective-C *protocol*, not a class -- but the
            // bridge header forward-declared it as `@interface MLComputeDeviceProtocol : NSObject`
            // (fixed above to `@protocol ... <NSObject>`), and every Swift-source use of the bare
            // name needs `any` now that it's an existential (confirmed via swift-demangle: the
            // real ABI mangles it as `__C.MLComputeDeviceProtocol_p`, the "_p" suffix marking an
            // existential, not a plain class reference). The dead, unused
            // `__C_MLComputeDeviceProtocol` native shadow struct is also removed.
            c = c.replacingOccurrences(of: "public struct __C_MLComputeDeviceProtocol: Hashable, Codable, Sendable {}", with: "")
            c = c.replacingOccurrences(
                of: "public init(device: MLComputeDeviceProtocol) { fatalError() }",
                with: "public init(device: any MLComputeDeviceProtocol) { fatalError() }")
            c = c.replacingOccurrences(
                of: "public var underlyingDevice: MLComputeDeviceProtocol { get { fatalError() } }",
                with: "public var underlyingDevice: any MLComputeDeviceProtocol { get { fatalError() } }")
        return c
    }
}
