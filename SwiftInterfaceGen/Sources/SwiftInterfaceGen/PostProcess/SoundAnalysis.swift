import Foundation

extension SwiftInterfaceGen {
    static func postProcessSoundAnalysis(_ code: String, parser: Parser) -> String {
        var c = code
            c = c.replacingOccurrences(of: "public typealias __C_SNRequest = SNRequest", with: "")
            c = c.replacingOccurrences(of: "public typealias __C_SNResult = SNResult", with: "")
            c = c.replacingOccurrences(of: "public typealias __C_AVAudioSession = AVAudioSession", with: "")
            c = c.replacingOccurrences(of: "public typealias __C_AVAudioSession.CategoryOptions = AVAudioSession.CategoryOptions", with: "")
            c = c.replacingOccurrences(of: "@nonobjc public convenience init() { fatalError() }", with: "@nonobjc public override convenience init() { fatalError() }")
            c = c.replaceWord("SNRequest", with: "Any")
            c = c.replaceWord("SNResult", with: "Any")
            c = c.replaceWord("MLMultiArray", with: "Any")
            c = c.replaceWord("SHSignature", with: "Any")
            // Fix: MLMultiArray/SHSignature are blanket-replaced with `Any` above (needed
            // elsewhere in this file where the real type genuinely can't be resolved), but the
            // real ABI mangles these specific properties as `__C.MLMultiArray`/`__C.SHSignature`
            // (confirmed via swift-demangle) -- reinstate the real (now bridge-header-forward-
            // declared, see generateExports) type for exactly these known property sites.
            for (old, new) in [
                ("public var exemplar: Any { get { fatalError() } set {} }",
                 "public var exemplar: MLMultiArray { get { fatalError() } set {} }"),
                ("public var trainingDataEmbeddings: [Any] { get { return [] } set {} }",
                 "public var trainingDataEmbeddings: [MLMultiArray] { get { return [] } set {} }"),
                ("public var validationDataEmbeddings: [Any] { get { return [] } set {} }",
                 "public var validationDataEmbeddings: [MLMultiArray] { get { return [] } set {} }"),
                ("public var data: Any { get { fatalError() } set {} }",
                 "public var data: MLMultiArray { get { fatalError() } set {} }"),
                ("public var exemplarEmbedding: Any { get { fatalError() } set {} }",
                 "public var exemplarEmbedding: MLMultiArray { get { fatalError() } set {} }"),
                ("public final var signature: Any { get { fatalError() } set {} }",
                 "public final var signature: SHSignature { get { fatalError() } set {} }"),
                ("public final var featureVector: Any { get { fatalError() } set {} }",
                 "public final var featureVector: MLMultiArray { get { fatalError() } set {} }"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Fix: SNRequest/SNResult are blanket-replaced with `Any` above (needed elsewhere
            // where the real type genuinely can't be resolved), but SNResultsCollector's 3
            // delegate-style methods mangle their params as real ObjC-*protocol* existentials
            // `any __C.SNRequest`/`any __C.SNResult` (confirmed via `swift-demangle -expand`:
            // the params are a `ProtocolList`, not a class reference) -- same "reinstate the
            // real bridge-header type at known sites" pattern as the MLMultiArray/SHSignature
            // fix above, but as an existential since SNRequest/SNResult are protocols, not
            // classes (unlike MLMultiArray/SHSignature).
            c = c.replacingOccurrences(
                of: "public final func request(_ arg1: Any, didProduce: Any) -> () {}",
                with: "public final func request(_ arg1: any SNRequest, didProduce: any SNResult) -> () {}")
            c = c.replacingOccurrences(
                of: "public final func requestDidComplete(_ arg1: Any) -> () {}",
                with: "public final func requestDidComplete(_ arg1: any SNRequest) -> () {}")
            c = c.replacingOccurrences(
                of: "public final func request(_ arg1: Any, didFailWithError: any Error) -> () {}",
                with: "public final func request(_ arg1: any SNRequest, didFailWithError: any Error) -> () {}")
            c = c.replacingOccurrences(of: "GenericA.Result", with: "Any")
            c = c.replacingOccurrences(of: "GenericA.Arg", with: "Any")
            c = c.replacingOccurrences(of: "public static func automaticallyNotifiesObservers(forKey:", with: "public override static func automaticallyNotifiesObservers(forKey:")
            c = c.replacingOccurrences(of: "public struct AnyPublisher<A, B>:", with: "public struct AnyPublisher<A, B: Swift.Error>:")
            c = c.replacingOccurrences(of: "public struct AnySubject<A, B>:", with: "public struct AnySubject<A, B: Swift.Error>:")
            c = c.replacingOccurrences(of: "public enum Completion<A>:", with: "public enum Completion<A: Swift.Error>:")
            // Completion<A>'s Codable/Hashable conformances are each individually CONDITIONAL
            // in the real ABI (confirmed via swift-demangle -expand on their conformance
            // descriptors: "where A: Swift.Encodable"/"Decodable"/"Hashable"), not the single
            // unconditional "Codable, Hashable" the generator infers from the TBD's flat
            // conformance list.
            c = c.replacingOccurrences(of: "public enum Completion<A: Swift.Error>: Codable, Hashable, @unchecked Sendable", with: "public enum Completion<A: Swift.Error>: @unchecked Sendable")
            c = c.replacingOccurrences(of: "public enum Completion<A: Swift.Error>: Codable, @unchecked Sendable", with: "public enum Completion<A: Swift.Error>: @unchecked Sendable")
            // Fix: unlike hash(into:)/==, which stay correct either as an unconditional member
            // or duplicated into the extension, encode(to:)/init(from:) mangle as EXTENSION
            // members in the real ABI (confirmed via swift-demangle: "(extension in
            // SoundAnalysis):...Completion< where A: Swift.Encodable>.encode(to:)") -- leaving
            // them as unconditional members of the enum body (as originally generated) produces
            // a type-mangled symbol instead, which never matches. Remove them from the base body
            // and move them into their respective conditional extensions, matching the pattern
            // used for RawRepresentableWrapper's identical Encodable/Decodable/Hashable shape.
            c = c.replacingOccurrences(
                of: "public init(from decoder: any Swift.Decoder) throws { fatalError() }\n        public func encode(to encoder: Swift.Encoder) throws { fatalError() }\n        public func hash(into hasher: inout Hasher) { fatalError() }\n    }",
                with: "public func hash(into hasher: inout Hasher) { fatalError() }\n    }")
            c = c.replacingOccurrences(
                of: "extension PubSub.Completion where A: Equatable {\n    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }\n}",
                with: """
                extension PubSub.Completion: Swift.Equatable where A: Swift.Equatable {
                    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }
                }
                extension PubSub.Completion: Swift.Hashable where A: Swift.Hashable {
                    public func hash(into hasher: inout Hasher) { fatalError() }
                }
                extension PubSub.Completion: Swift.Encodable where A: Swift.Encodable {
                    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                }
                extension PubSub.Completion: Swift.Decodable where A: Swift.Decodable {
                    public init(from decoder: any Swift.Decoder) throws { fatalError() }
                }
                """)
            c = c.replacingOccurrences(of: "public struct RawRepresentableWrapper<A>:", with: "public struct RawRepresentableWrapper<A: RawRepresentable>:")
            // Same conditional-conformance shape as Completion<A> above, but keyed off
            // A.RawValue (confirmed via swift-demangle -expand: "where A.RawValue: Swift.X")
            // rather than A itself.
            c = c.replacingOccurrences(
                of: "public struct RawRepresentableWrapper<A: RawRepresentable>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct RawRepresentableWrapper<A: RawRepresentable>: @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: """
                public struct RawRepresentableWrapper<A: RawRepresentable>: @unchecked Sendable {
                    public init(_ arg1: A) { fatalError() }
                    public var rawValue: A.RawValue { get { fatalError() } }
                    public var value: A { get { fatalError() } }
                    public init(from decoder: any Swift.Decoder) throws { fatalError() }
                    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                    public func hash(into hasher: inout Hasher) { fatalError() }
                }
                """,
                with: """
                public struct RawRepresentableWrapper<A: RawRepresentable>: @unchecked Sendable {
                    public init(_ arg1: A) { fatalError() }
                    public var rawValue: A.RawValue { get { fatalError() } }
                    public var value: A { get { fatalError() } }
                }
                extension RawRepresentableWrapper: Swift.Equatable where A.RawValue: Swift.Equatable {
                    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
                }
                extension RawRepresentableWrapper: Swift.Hashable where A.RawValue: Swift.Hashable {
                    public func hash(into hasher: inout Hasher) { fatalError() }
                }
                extension RawRepresentableWrapper: Swift.Encodable where A.RawValue: Swift.Encodable {
                    public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                }
                extension RawRepresentableWrapper: Swift.Decodable where A.RawValue: Swift.Decodable {
                    public init(from decoder: any Swift.Decoder) throws { fatalError() }
                }
                """)
            c = c.removeAnyConstraintsFromWhereClause()

            // Fix: SNDetectSoundActionsRequest/SNDetectSoundRequest/_SNClassifySoundRequest are
            // real native Swift classes (their required ABI symbols mangle with the SoundAnalysis
            // module prefix, not "__C."/"(extension in ...)"), but the parser never emits their
            // base class declaration at all -- only an "ObjC Extension (bridge-header required)"
            // extension on a type that doesn't exist, which the generator's isObjcBridged
            // detection wrongly classified as ObjC-imported. Confirmed via minimal repro that
            // declaring them as plain native classes (not ObjC-bridge extensions) reproduces the
            // required symbols almost exactly. Two remaining wrinkles, also confirmed via repro:
            // (1) a `coder:`-taking init produces an unwanted resilience dispatch thunk + method
            // descriptor UNLESS marked `@objc dynamic`, which suppresses both; (2) any additional
            // designated initializer causes NSObject's inherited bare `init()` to also become
            // exported (not part of the real ABI) UNLESS it's given a `private override init()`
            // to explicitly claim/hide it. A third gap, "method lookup function for X", was left
            // unresolved at the time of this fix (see the later _typeMetadataAnchor fix in this
            // block for the root cause and resolution: `final`-only members don't need a vtable
            // slot, so Swift elides the whole class-metadata suite unless a non-final member
            // exists -- SNDetectSoundRequest/_SNClassifySoundRequest already have one (`copy`),
            // but SNDetectSoundActionsRequest's bare `override init()` doesn't).
            c = c.replacingOccurrences(
                of: """
                // --- ObjC Extension (bridge-header required) ---
                extension SNDetectSoundActionsRequest {
                    @nonobjc public override convenience init() { fatalError() }
                    public struct __deallocating_deinit: Codable, Hashable, @unchecked Sendable {
                        public init(from decoder: any Swift.Decoder) throws { fatalError() }
                        public func encode(to encoder: Swift.Encoder) throws { fatalError() }
                        public func hash(into hasher: inout Hasher) { fatalError() }
                        public static func ==(_ lhs: __deallocating_deinit, _ rhs: __deallocating_deinit) -> Bool { fatalError() }
                    }
                }
                // --- End ObjC Extension ---
                """,
                with: """
                open class SNDetectSoundActionsRequest: NSObject {
                    public override init() { super.init() }
                    private var _typeMetadataAnchor: Int = 0
                }
                """)
            // Member order within these two extension bodies is nondeterministic across
            // generator runs (same class of issue as elsewhere this session), so extract each
            // whole extension body via a structural span match rather than assuming a fixed
            // member sequence, then rebuild the class unconditionally with the fixed member set
            // (both extensions always contain exactly the same members every run -- only their
            // relative order varies).
            for typeName in ["SNDetectSoundRequest", "_SNClassifySoundRequest"] {
                if let re = try? NSRegularExpression(pattern: "(// --- ObjC Extension \\(bridge-header required\\) ---\\n)?extension \(typeName) \\{[\\s\\S]*?\\n\\}\\n(// --- End ObjC Extension ---\\n)?"),
                   let m = re.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
                   let fullRange = Range(m.range, in: c) {
                    let descriptionMember = typeName == "SNDetectSoundRequest"
                        ? "    public override var description: Swift.String { get { fatalError() } }\n"
                        : ""
                    let replacement = """
                    public class \(typeName): NSObject {
                        public static var supportsSecureCoding: Swift.Bool { get { fatalError() } }
                        private override init() { super.init() }
                    \(descriptionMember)    public func copy(with: NSZone?) -> Any { fatalError() }
                        public override var hash: Swift.Int { get { fatalError() } }
                        public override func isEqual(_ arg1: Any?) -> Swift.Bool { fatalError() }
                        public func encode(with: NSCoder) -> () {}
                        @objc dynamic public convenience init?(coder: NSCoder) { fatalError() }
                    }

                    """
                    c.replaceSubrange(fullRange, with: replacement)
                }
            }
            // The bogus placeholder for the now-genuinely-declared _SNClassifySoundRequest above
            // -- same "phantom auto-generated duplicate" pattern as CryptoKit's XWingMLKEM768X and
            // CoreML's __C_MLComputeDeviceProtocol this session; confirmed unreferenced elsewhere.
            c = c.replacingOccurrences(
                of: "public struct __C_SNClassifySoundRequest: Hashable, Codable, Sendable {}",
                with: "")
            c = c.replacingOccurrences(
                of: "public struct _SNClassifySoundRequest: Hashable, Sendable {}",
                with: "")

            // Fix: SNFileServer/SNFileItem/SNFileSystem/SNCopyFilesRequest/etc. (~20 classes) are
            // real native NSObject subclasses whose real ABI requires the full class-metadata
            // symbol suite (type metadata accessor, nominal type descriptor, class metadata base
            // offset, method lookup function, type metadata, __deallocating_deinit), but the
            // generator renders them with either no members at all beyond `override init()`, or
            // (SNMovieRemixFinalResult only) only `final` members -- and `final` members don't
            // need a vtable slot, so Swift elides the whole metadata suite including the method
            // lookup function. Confirmed via minimal repro (-enable-library-evolution
            // -language-mode 6, matching verify_public.py's flags): adding any single *non-final*
            // member forces Swift to materialize the metadata suite; a `private var` reproduces
            // exactly the required symbol set with no side effects, since it exports no public
            // symbol of its own. This was the "method lookup function for X" mystery documented
            // as an unresolved gap in the SNDetectSoundActionsRequest/SNDetectSoundRequest/
            // _SNClassifySoundRequest fix earlier this session.
            for name in ["SNFileServer", "SNFileItem", "SNFileSystem", "SNCopyFilesRequest",
                         "SNCorrelateAudioRequest", "SNDeleteFilesRequest",
                         "SNDiscoverFileServerRequest", "SNFileCopyingResult",
                         "SNFileDeletionResult", "SNFileListingResult",
                         "SNFileServerDiscoveryResult", "SNFileServerInfo",
                         "SNLanguageAlignedAVFuser", "SNListFilesRequest",
                         "SNMovieRemixDSPParameter", "SNMovieRemixRequest",
                         "SNMovieRemixSession", "SNSystemAudioAnalyzer", "_SNAudioFileAnalyzer"] {
                let withInit = "@objc(\(name)) @_fixed_layout open class \(name): NSObject {\n    public override init() { super.init() }\n"
                let withoutInit = "@objc(\(name)) @_fixed_layout open class \(name): NSObject {\n"
                if c.contains(withInit) {
                    c = c.replacingOccurrences(
                        of: withInit,
                        with: withInit + "    private var _typeMetadataAnchor: Int = 0\n")
                } else {
                    c = c.replacingOccurrences(
                        of: withoutInit,
                        with: withoutInit + "    private var _typeMetadataAnchor: Int = 0\n")
                }
            }
            c = c.replacingOccurrences(
                of: "@objc(SNMovieRemixFinalResult) @_fixed_layout open class SNMovieRemixFinalResult: NSObject {\n    public override init() { super.init() }\n",
                with: "@objc(SNMovieRemixFinalResult) @_fixed_layout open class SNMovieRemixFinalResult: NSObject {\n    public override init() { super.init() }\n    private var _typeMetadataAnchor: Int = 0\n")

            // Fix: the real ABI has `_OBJC_CLASS_$_SNKShotLabel`/`_OBJC_METACLASS_$_SNKShotLabel`
            // and the same pair for SNTimeDurationConstraint, but both names are already declared
            // as native Swift enums here (with separate, differently-named ObjC-bridging
            // companion classes) -- same "hidden private ObjC-bridging shadow class sharing a
            // public value type's runtime name" pattern as CoreML's MLModelStructure/
            // MLOptimizationHints fix this session.
            c += "\n@objc(SNKShotLabel) open class _SNKShotLabelObjCShadow: NSObject {}\n"
            c += "@objc(SNTimeDurationConstraint) open class _SNTimeDurationConstraintObjCShadow: NSObject {}\n"

            c += """


            open class AVAudioSession: NSObject {
                public struct Category: Hashable, RawRepresentable { public var rawValue: Swift.String; public init(rawValue: Swift.String) { self.rawValue = rawValue } }
                public struct Mode: Hashable, RawRepresentable { public var rawValue: Swift.String; public init(rawValue: Swift.String) { self.rawValue = rawValue } }
                public struct CategoryOptions: OptionSet, Sendable { public var rawValue: Swift.UInt; public init(rawValue: Swift.UInt) { self.rawValue = rawValue } }
            }
            """

            // Fix: the real ABI's generic `run<A>` overloads constrain `A`'s associated types
            // (`A.Element ==`, `A.Failure ==`) and the `runLocally` overloads' `any Publisher`
            // existential param constrains its associated types too (`Failure ==`, `Output ==`)
            // -- omitting these equality constraints changes the mangled generic signature, so
            // the generator's unconstrained defaults never match the real symbols.
            for (old, new) in [
                ("public func run<A>(_ arg1: CLAP.AudioRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.AudioSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: CLAP.AudioRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.AudioSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, Int64), A.Failure == Error { fatalError() }"),
                ("public func run<A>(_ arg1: CLAP.DetectorHeadRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.DetectorHeadSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: CLAP.DetectorHeadRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.DetectorHeadSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, Int64), A.Failure == Error { fatalError() }"),
                ("public func run<A>(_ arg1: CLAP.TextRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.TextSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: CLAP.TextRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> CLAP.TextSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, Int64), A.Failure == Error { fatalError() }"),
                ("public func run<A>(_ arg1: ClosedCaptioningRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> ClosedCaptioningSession where A: AsyncSequence { fatalError() }",
                 "public func run<A>(_ arg1: ClosedCaptioningRequest, audioFormat: AVAudioFormat, audioBuffers: A) throws -> ClosedCaptioningSession where A: AsyncSequence, A.Element == (AVAudioPCMBuffer, CMTime), A.Failure == Error { fatalError() }"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Fix: the `runLocally` overloads' `any Publisher` existential param is already
            // generated with the correct same-type constraints (confirmed via debug tracing:
            // `any Publisher<Self.Failure == Error, Self.Output == AVAudioPCMBuffer>`), but the
            // later generic `stripConstrainedExistentialGenerics` pass (which runs on ALL
            // frameworks to strip invalid `any Protocol<X == Y>` syntax) blindly erases the whole
            // `<...>` clause since it contains `==` -- it doesn't know Publisher supports Swift's
            // primary-associated-type sugar (`any Publisher<Output, Failure>`), unlike the
            // Sequence/Collection/AsyncSequence family already special-cased via
            // `knownPrimaryAssociatedTypes`. Convert to the sugared positional form here, before
            // that pass runs, instead of extending the general-purpose table for one protocol.
            for (old, new) in [
                ("any Publisher<Self.Failure == Error, Self.Output == AVAudioPCMBuffer>",
                 "any Publisher<AVAudioPCMBuffer, Error>"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Fix: PubSub.AnySubject.fromCombine/toCombine's `any Subject<...>` existential
            // param/return has the same shape as the runLocally/Publisher fix above -- generated
            // with the correct constraints (`Self.Failure == B, ` + the `___SAME_TYPE_A___`
            // marker for the primary-associated-type placeholder, confirmed via debug tracing),
            // but stripConstrainedExistentialGenerics erases the whole clause since Subject
            // (like Publisher) isn't in the `knownPrimaryAssociatedTypes` table even though it
            // does support `any Subject<Output, Failure>` sugar. Convert directly, before both
            // the marker-resolution pass and the strip pass run.
            c = c.replacingOccurrences(
                of: "any Subject<Self.Failure == B, ___SAME_TYPE_A___>",
                with: "any Subject<A, B>")

            // Fix: GenericThrowingClosureAudioDataAnalysisReceiver is generated as a completely
            // empty protocol -- its one requirement (a generic `run` method) never made it into
            // the interface at all. Confirmed via `swift-demangle -expand`: the requirement is
            // `associatedtype Arg`/`associatedtype Result` plus `func run<A1>(_ arg1: Arg, _
            // arg2: A1.Type) throws -> Result where A1: DependencyADAMAudioDataReceiver`.
            c = c.replacingOccurrences(
                of: "public protocol GenericThrowingClosureAudioDataAnalysisReceiver {\n}",
                with: """
                public protocol GenericThrowingClosureAudioDataAnalysisReceiver {
                    associatedtype Arg
                    associatedtype Result
                    func run<A1>(_ arg1: Arg, _ arg2: A1.Type) throws -> Result where A1: DependencyADAMAudioDataReceiver
                }
                """)
            // Fix: AudioDataAnalysisProviderProtocol.withAudioDataAnalysis (and its
            // AudioDataAnalysisProvider concrete implementation) is missing a same-type
            // constraint tying its second generic param to the first's `Arg` associated type,
            // and its return type is erased to `Any` instead of the first param's `Result`
            // (confirmed via swift-demangle -expand: `<A, B where A: ...Receiver, B ==
            // A.Arg>(B, A) throws -> A.Result`).
            c = c.replacingOccurrences(
                of: "func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> Any where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver",
                with: "func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> GenericA.Result where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver, GenericB == GenericA.Arg")
            c = c.replacingOccurrences(
                of: "public func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> Any where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver { fatalError() }",
                with: "public func withAudioDataAnalysis<GenericA, GenericB>(_ arg1: GenericB, _ arg2: GenericA) throws -> GenericA.Result where GenericA: GenericThrowingClosureAudioDataAnalysisReceiver, GenericB == GenericA.Arg { fatalError() }")
            // Fix: toAnyAsyncIterator()/toAnyAsyncSequence() are real extensions this module adds
            // to the stdlib's AsyncIteratorProtocol/AsyncSequence (confirmed via swift-demangle:
            // "(extension in SoundAnalysis):Swift.AsyncIteratorProtocol.toAnyAsyncIterator() ->
            // SoundAnalysis.AnyAsyncIterator<A.Element>"), but the generator never emits them at
            // all.
            c += """

            extension AsyncIteratorProtocol {
                public func toAnyAsyncIterator() -> AnyAsyncIterator<Element> { fatalError() }
            }
            extension AsyncSequence {
                public func toAnyAsyncSequence() -> AnyAsyncSequence<Element> { fatalError() }
            }
            """
        return c
    }
}
