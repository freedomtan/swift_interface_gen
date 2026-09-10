import Foundation

extension SwiftInterfaceGen {
    static func postProcessVision(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix: VisionRequest declares `associatedtype Result` with no ABI-visible default
            // and no per-conformer typealias anywhere (satisfied only via the generic
            // `perform<each GenericA>` methods on VisionRequestHandler, never a per-conformer
            // ABI witness) — ~50 structs conform to VisionRequest, so give the protocol itself
            // a default associated-type value (Swift resolves an unconstrained associatedtype
            // to its default when no conformer supplies one) instead of patching every
            // conformer individually.
            if let declRange = c.range(of: "public protocol VisionRequest: CustomStringConvertible, Hashable {"),
               let braceEnd = c.range(of: "\n}", range: declRange.upperBound..<c.endIndex) {
                let bodyRange = declRange.upperBound..<braceEnd.lowerBound
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(of: "associatedtype Result", with: "associatedtype Result = Never")
                c.replaceSubrange(bodyRange, with: body)
            }
            // Fix: not every VisionRequest conformer implements
            // `supportedComputeStageDevices: [ComputeStage : [MLComputeDevice]]` (e.g.
            // TrackRectangleRequest has no ABI witness for it at all) — unlike
            // computeDevice(for:)/requireInProcessExecution, which the generator already found
            // a default `extension VisionRequest { ... }` implementation for, this one has no
            // default anywhere either. Add one so non-implementing conformers still compile.
            if let declRange = c.range(of: "extension VisionRequest {"),
               let braceEnd = c.range(of: "\n}", range: declRange.upperBound..<c.endIndex) {
                c.insert(contentsOf: "\n    public var supportedComputeStageDevices: [ComputeStage : [CoreML.MLComputeDevice]] { get { [:] } }", at: braceEnd.lowerBound)
            }

            // Fix: Attribute<A>'s allLabelsAndConfidences is [A : Float] (A used as a Dictionary
            // key), but A has no Hashable constraint on the struct's own declaration.
            c = c.replacingOccurrences(
                of: "public struct Attribute<A>: Codable, CustomStringConvertible, Hashable {",
                with: "public struct Attribute<A: Hashable>: Codable, CustomStringConvertible, Hashable {")

            // Fix: PoseProviding.PoseJointName is used as a Dictionary key
            // ([Self.PoseJointName : Joint]) but only declared `: Decodable` — the real ABI
            // shows PoseJointName: Hashable too (found via the P0B9JointNameAC_SH conformance
            // requirement symbol), just not resolved by the demangler-driven associated-type
            // extraction here.
            c = c.replacingOccurrences(
                of: "associatedtype PoseJointName: Decodable",
                with: "associatedtype PoseJointName: Decodable, Hashable")
            // Fix: PoseProviding's real ABI also has associated conformance descriptors for
            // PoseJointName: RawRepresentable/Encodable and PoseJointsGroupName: RawRepresentable
            // (confirmed via swift-demangle) that the current bounds (Decodable/Hashable and
            // CaseIterable respectively) don't cover.
            c = c.replacingOccurrences(
                of: "associatedtype PoseJointName: Decodable, Hashable",
                with: "associatedtype PoseJointName: Decodable, Encodable, Hashable, RawRepresentable")
            c = c.replacingOccurrences(
                of: "associatedtype PoseJointsGroupName: CaseIterable",
                with: "associatedtype PoseJointsGroupName: CaseIterable, RawRepresentable")
            // Fix: GenerateIterativeSegmentationRequest.init(seedScribbleBuffer:_:) and
            // OpticalFlowObservation/PixelBufferObservation's init?(_:VNPixelBufferObservation)
            // all render their sole class-typed parameter with an explicit `borrowing` keyword
            // copied verbatim from the swiftinterface's printed ownership annotation -- same
            // "the annotation reflects the implicit default convention, not a real source-level
            // keyword" gap already fixed for MetalPerformanceShadersGraph's Executables.init:
            // re-emitting it literally adds an "h" ownership-convention marker the real mangled
            // symbols don't have (confirmed via a minimal repro).
            c = c.replacingOccurrences(
                of: "seedScribbleBuffer: borrowing CVReadOnlyPixelBuffer",
                with: "seedScribbleBuffer: CVReadOnlyPixelBuffer")
            c = c.replacingOccurrences(
                of: "init?(_ arg1: borrowing VNPixelBufferObservation) { fatalError() }",
                with: "init?(_ arg1: VNPixelBufferObservation) { fatalError() }")
            // Fix: DownloadableAssetsRequest.assetStatus (and its GenerateIterativeSegmentationRequest
            // conformance) render as plain synchronous computed properties, but their real ABI
            // needs "async function pointer" symbols -- same "{ get async }" gap already fixed
            // for Translation's isReady/supportedLanguages (confirmed via a minimal repro that
            // only a `{ get async }` accessor produces those).
            c = c.replacingOccurrences(
                of: "var assetStatus: DownloadableAssetsRequestStatus { get }",
                with: "var assetStatus: DownloadableAssetsRequestStatus { get async }")
            c = c.replacingOccurrences(
                of: "public final var assetStatus: DownloadableAssetsRequestStatus { get { fatalError() } }",
                with: "public final var assetStatus: DownloadableAssetsRequestStatus { get async { fatalError() } }")
            // Fix: VisionRequestIntrospectionManager.LogLevel's real ABI has a standalone,
            // hand-written `>=` operator (confirmed via swift-demangle: "static ...LogLevel.>=
            // infix" -- a minimal repro shows Comparable's synthesized default `>=`/`<=`/`>` are
            // plain stdlib protocol-extension methods with no per-conformer ABI symbol at all, so
            // this can't be from Comparable conformance; it must be a real, separate declaration),
            // but the generator never rendered it.
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: LogLevel, _ rhs: LogLevel) -> Bool { fatalError() }\n    }\n    public struct VisionRequestEntry:",
                with: "public static func ==(_ lhs: LogLevel, _ rhs: LogLevel) -> Bool { fatalError() }\n        public static func >= (lhs: LogLevel, rhs: LogLevel) -> Bool { fatalError() }\n    }\n    public struct VisionRequestEntry:")
            // Fix: Locale.Language.encodeCustom(to:)/createProperty(from:) are real ABI (confirmed
            // via swift-demangle) but never rendered at all. Neither has a protocol-conformance-
            // descriptor or witness-table symbol alongside it, so they're plain free-standing
            // members of a retroactive extension, not a protocol requirement -- add them directly
            // (confirmed via a minimal repro to produce an exact match).
            c += """

extension Locale.Language {
    public func encodeCustom(to encoder: Swift.Encoder) throws {}
    public static func createProperty(from: Any) throws -> Locale.Language { fatalError() }
}

"""
            // Accepted, documented-unfixable gap (4 remaining stubs): Serialization.decode/
            // encode and VisionInferenceProvider.requestOneShotInternal all reference
            // XPC.XPCCodableObject, and the real ABI genuinely mangles it as belonging to module
            // XPC -- but this SDK's real XPC module doesn't export that type at all (confirmed:
            // `import XPC; XPC.XPCCodableObject` fails to resolve even in isolation). Our local
            // opaque-struct fallback for it mangles under Vision's own module instead, which
            // can't be changed from declaration syntax alone. Forcing the correct module-
            // qualified mangling would require pulling "XPC" out of verify_public.py's
            // SYSTEM_MODULES (so a local per-target stub gets built instead of resolving the
            // real system module) and hand-populating that stub with XPCCodableObject -- but XPC
            // is shared with Network, which genuinely depends on the REAL module's XPCDictionary
            // (confirmed still resolving today), so a global SYSTEM_MODULES change would silently
            // swap Network's real XPC resolution for an empty one too. Left as-is rather than
            // diverging from real-module groundtruth for a 4-stub gain.
        return c
    }
}
