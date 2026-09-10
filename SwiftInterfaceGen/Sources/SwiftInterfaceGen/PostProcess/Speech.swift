import Foundation

extension SwiftInterfaceGen {
    static func postProcessSpeech(_ code: String, parser: Parser) -> String {
        var c = code
            c = c.replacingOccurrences(
                of: "public struct ConfidenceAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {",
                with: "public struct ConfidenceAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {\n        public typealias Value = Double")
            c = c.replacingOccurrences(
                of: "public struct TimeRangeAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {",
                with: "public struct TimeRangeAttribute: AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey {\n        public typealias Value = CMTimeRange")
            // Fix: SpeechModule requires `associatedtype Result: SpeechModuleResult` and
            // `associatedtype Results: AsyncSequence` plus `var results: Self.Results { get }`.
            // Concrete classes expose a nested SpeechModuleResult type (Result or ModuleOutput)
            // and a `results` property typed as `some Sendable & AsyncSequence`. This opaque type
            // does NOT satisfy `var results: Self.Results` because the compiler can't verify
            // `some Sendable & AsyncSequence == AsyncStream<Result>`.
            //
            // Fix strategy:
            //   1. For EndpointDetector (uses ModuleOutput not Result):
            //      inject `typealias Result = ModuleOutput` + `typealias Results = AsyncStream<ModuleOutput>`
            //      before `struct ModuleOutput`.
            //   2. For all other classes (struct Result):
            //      inject `typealias Results = AsyncStream<Result>` before `struct Result`.
            //   3. Change every `results: some Sendable & AsyncSequence { get { return AsyncStream<Never> { _ in } } }`
            //      to `results: Results { get { fatalError() } }` so the property type matches.
            //
            // EndpointDetector: anchor on `struct ModuleOutput`
            c = c.replacingOccurrences(
                of: "    public struct ModuleOutput: CustomStringConvertible, SpeechModuleResult {",
                with: "    public typealias Result = ModuleOutput\n    public typealias Results = AsyncStream<ModuleOutput>\n    public struct ModuleOutput: CustomStringConvertible, SpeechModuleResult {")
            // All other SpeechModule classes: anchor on `struct Result: ... SpeechModuleResult`
            c = c.replacingOccurrences(
                of: "    public struct Result: CustomStringConvertible, SpeechModuleResult",
                with: "    public typealias Results = AsyncStream<Result>\n    public struct Result: CustomStringConvertible, SpeechModuleResult")
            // SpeechDetector has `struct Result: CustomStringConvertible, Hashable, SpeechModuleResult`
            // which is already covered by the Hashable variant below. Handle both variants:
            c = c.replacingOccurrences(
                of: "    public struct Result: CustomStringConvertible, Hashable, SpeechModuleResult",
                with: "    public typealias Results = AsyncStream<Result>\n    public struct Result: CustomStringConvertible, Hashable, SpeechModuleResult")
            // Change `results: some Sendable & AsyncSequence { get { return AsyncStream<Never> { _ in } } }`
            // to `results: Results { get { fatalError() } }` so the type matches `Self.Results`.
            // (This still leaves each class's `results` getter stubbed for ABI-comparison
            // purposes -- the real declaration's opaque `some Sendable & AsyncSequence` return
            // type conceals whatever the real, unreproducible concrete backing type is; our
            // concrete `AsyncStream<Result>` is necessary for this to compile and conform at all,
            // but produces a different, non-opaque mangled shape. Accepted, same
            // "opaque-return-type" category as other frameworks' unfixable stubs this session.)
            c = c.replacingOccurrences(
                of: "    public final var results: some Sendable & AsyncSequence { get { return AsyncStream<Never> { _ in } } }",
                with: "    public final var results: Results { get { fatalError() } }")

            // Fix: AttributeScopes.SpeechAttributes.confidence/timeRange's real ABI type is a
            // BARE top-level `Speech.ConfidenceAttribute`/`Speech.TimeRangeAttribute` (confirmed
            // via swift-demangle -expand: "kind=Structure, kind=Module text=Speech" with no
            // enclosing AttributeScopes) -- a DIFFERENT type from the same-named one nested
            // directly inside SpeechAttributes (used by audioTimeRange/transcriptionConfidence,
            // and already correct). Our generator declared the bare-top-level pair inside
            // `extension AttributeScopes { ... }` though, mangling them as `AttributeScopes.
            // ConfidenceAttribute`/`AttributeScopes.TimeRangeAttribute` -- wrong module path, AND
            // the bare `ConfidenceAttribute`/`TimeRangeAttribute` references in confidence/
            // timeRange's own property declarations get shadowed by SpeechAttributes' own nested
            // same-named types (member lookup finds the sibling nested type before ever reaching
            // module scope), silently compiling to the wrong one. Fixed by un-wrapping the
            // top-level pair out of the `extension AttributeScopes` block entirely, and
            // explicitly module-qualifying confidence/timeRange's declared types to bypass the
            // shadowing (both confirmed via a minimal repro to produce an exact match).
            // Matched structurally (lazy span from the struct's own opening line to its own
            // closing brace, dropping the wrapping "extension AttributeScopes {"/final "}") --
            // NOT as an exact multi-line literal -- because member order/indentation inside this
            // struct isn't stable across generator runs (observed directly: two otherwise-
            // identical invocations of the same binary against the same .tbd produced `name`
            // before `decode` in one run and vice versa in another).
            for structName in ["ConfidenceAttribute", "TimeRangeAttribute"] {
                if let regex = try? NSRegularExpression(
                    pattern: "extension AttributeScopes \\{\\n(\\s*public struct \(structName): AttributedStringKey, DecodableAttributedStringKey, EncodableAttributedStringKey \\{[\\s\\S]*?\\n\\s*\\})\\n\\}",
                    options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "$1")
                }
            }
            c = c.replacingOccurrences(
                of: "public var confidence: ConfidenceAttribute { get { fatalError() } }",
                with: "public var confidence: Speech.ConfidenceAttribute { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "public var timeRange: TimeRangeAttribute { get { fatalError() } }",
                with: "public var timeRange: Speech.TimeRangeAttribute { get { fatalError() } }")

            // Fix: several real ABI members across Speech are entirely missing from the
            // generator's output (confirmed via swift-demangle, and each verified via a minimal
            // repro to produce an exact match).
            c += """

extension AttributedString {
    public func rangeOfTimeRangeAttributes(intersecting: CMTimeRange) -> Range<AttributedString.Index>? { nil }
    public func rangeOfAudioTimeRangeAttributes(intersecting: CMTimeRange) -> Range<AttributedString.Index>? { nil }
}
extension URL {
    public var filesystemPath: String { self.path }
}
extension Locale {
    public var languageRegionLocale: Locale? { nil }
    public var languageRegionLocaleWithReplacement: Locale? { nil }
    public var languageRegionIdentifier: String { "" }
    public var languageRegionIdentifierWithReplacement: String { "" }
}
public func addressDescription<A: AnyObject>(of: A) -> String { "" }

"""

            // Fix: many properties across Speech's module/analyzer/transcriber types render as
            // plain synchronous computed properties, but their real ABI needs "async function
            // pointer" symbols -- same "{ get async }" gap already fixed for Translation's
            // isReady/supportedLanguages and Vision's assetStatus (confirmed via a minimal repro
            // that only a `{ get async }` accessor produces those).
            //
            // Two protocol requirements, each with exactly one occurrence in the file (safe to
            // blanket-replace):
            c = c.replacingOccurrences(
                of: "var availableCompatibleAudioFormats: [AVAudioFormat] { get }",
                with: "var availableCompatibleAudioFormats: [AVAudioFormat] { get async }")
            c = c.replacingOccurrences(
                of: "static var supportedLocales: [Locale] { get }",
                with: "static var supportedLocales: [Locale] { get async }")
            // installedLocales/supportedLocales static vars: exactly 5 identical occurrences each
            // (SpeechTranscriber/Transcriber/DictationTranscriber/NormalizingTranscriber/
            // FoundationModelTranscriber), matching exactly the 5 classes the stub list names for
            // each -- safe to blanket-replace.
            c = c.replacingOccurrences(
                of: "public static var installedLocales: [Locale] { get { return [] } }",
                with: "public static var installedLocales: [Locale] { get async { return [] } }")
            c = c.replacingOccurrences(
                of: "public static var supportedLocales: [Locale] { get { return [] } }",
                with: "public static var supportedLocales: [Locale] { get async { return [] } }")
            // availableCompatibleAudioFormats "final var" shape: 9 classes share byte-identical
            // text, but only 6 need `get async` per the stub list (CommandRecognizer,
            // EndpointDetector, SpeechDetector do NOT) -- anchor each on its own nearest-preceding
            // class header via a lazy multiline span, same technique as MetricKit's baseUnit fix.
            for asyncAudioFormatsClass in ["SpeechTranscriber", "Transcriber", "LanguageDetector", "DictationTranscriber", "NormalizingTranscriber", "FoundationModelTranscriber"] {
                if let regex = try? NSRegularExpression(
                    pattern: "(class \(asyncAudioFormatsClass): [\\s\\S]*?)public final var availableCompatibleAudioFormats: \\[AVAudioFormat\\] \\{ get \\{ return \\[\\] \\} \\}",
                    options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "$1public final var availableCompatibleAudioFormats: [AVAudioFormat] { get async { return [] } }")
                }
            }
            // The rest are all individually unique members (verified via grep -c == 1 each), so
            // no per-class anchoring needed.
            for (from, to) in [
                ("public final var userData: [AnalysisContext.UserDataTag : Sendable] { get { return [:] } }",
                 "public final var userData: [AnalysisContext.UserDataTag : Sendable] { get async { return [:] } }"),
                ("public final var contextualStrings: [AnalysisContext.ContextualStringsTag : [Swift.String]] { get { return [:] } }",
                 "public final var contextualStrings: [AnalysisContext.ContextualStringsTag : [Swift.String]] { get async { return [:] } }"),
                ("public final var context: AnalysisContext { get { fatalError() } }",
                 "public final var context: AnalysisContext { get async { fatalError() } }"),
                ("public final var acousticModelVersion: Swift.String? { get { return nil } }",
                 "public final var acousticModelVersion: Swift.String? { get async { return nil } }"),
                ("public final var modelVersion: Swift.String? { get { return nil } }",
                 "public final var modelVersion: Swift.String? { get async { return nil } }"),
                ("public final var recognitionStatistics: [Swift.String : NSNumber]? { get { return nil } }",
                 "public final var recognitionStatistics: [Swift.String : NSNumber]? { get async { return nil } }"),
                ("public final var compatibleAudioFormats: [AVAudioFormat] { get { return [] } }",
                 "public final var compatibleAudioFormats: [AVAudioFormat] { get async { return [] } }"),
                ("public final var isSpeechProfileUsed: Swift.Bool { get { fatalError() } }",
                 "public final var isSpeechProfileUsed: Swift.Bool { get async { fatalError() } }"),
                ("public final var recognitionUtterenceStatistics: [Swift.String : Swift.String]? { get { return nil } }",
                 "public final var recognitionUtterenceStatistics: [Swift.String : Swift.String]? { get async { return nil } }"),
                ("public static var reservedLocales: [Locale] { get { return [] } }",
                 "public static var reservedLocales: [Locale] { get async { return [] } }"),
                ("public static var allocatedLocales: [Locale] { get { return [] } }",
                 "public static var allocatedLocales: [Locale] { get async { return [] } }"),
                ("public final var supportedLocales: [Locale]? { get { return nil } }",
                 "public final var supportedLocales: [Locale]? { get async { return nil } }"),
                ("public var modelSamplingRates: Set<Swift.Int> { get { fatalError() } }",
                 "public var modelSamplingRates: Set<Swift.Int> { get async { fatalError() } }"),
                ("public var modelTaskNames: [Swift.String] { get { return [] } }",
                 "public var modelTaskNames: [Swift.String] { get async { return [] } }"),
                ("public var modelVersion: Swift.String { get { fatalError() } }",
                 "public var modelVersion: Swift.String { get async { fatalError() } }"),
                ("public var modelQualityType: Swift.String { get { fatalError() } }",
                 "public var modelQualityType: Swift.String { get async { fatalError() } }"),
                ("public var modelRoot: URL { get { fatalError() } }",
                 "public var modelRoot: URL { get async { fatalError() } }"),
            ] {
                c = c.replacingOccurrences(of: from, with: to)
            }
        return c
    }
}
