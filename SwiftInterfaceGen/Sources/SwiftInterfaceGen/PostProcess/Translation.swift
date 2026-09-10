import Foundation

extension SwiftInterfaceGen {
    static func postProcessTranslationPart1(_ code: String, parser: Parser) -> String {
        var c = code
            // TranslationSession's `textSessionDelegate` property is real ABI (confirmed via
            // swift-demangle: getter/setter/modify/property-descriptor all present) but never
            // rendered at all. A minimal repro confirms `(any _LTTextSessionDelegate)?` produces
            // an exact match to the real "So..._p" existential-protocol-typed symbols.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class TranslationSession {",
                with: "@_fixed_layout public class TranslationSession {\n    public var textSessionDelegate: (any _LTTextSessionDelegate)?")
            // LanguageAvailability.supportedLanguages / TranslationSession.isReady both render as
            // plain synchronous computed getters, but their real ABI needs "async function
            // pointer to dispatch thunk of ...getter" symbols -- confirmed via a minimal repro
            // that only a `{ get async }` accessor produces those (their signatures otherwise
            // match already).
            c = c.replacingOccurrences(
                of: "public var supportedLanguages: [Locale.Language] { get { return [] } }",
                with: "public var supportedLanguages: [Locale.Language] { get async { return [] } }")
            c = c.replacingOccurrences(
                of: "public var isReady: Swift.Bool { get { fatalError() } }",
                with: "public var isReady: Swift.Bool { get async { fatalError() } }")
        return c
    }

    static func postProcessTranslationPart2(_ code: String, parser: Parser) -> String {
        var c = code
            // _LTTextSessionDelegate needs the @objc-protocol bridge-header forward-declaration
            // added in generateExports (this file's writeGeneratedFiles/bridge-header logic), not
            // the generic native-Swift-struct placeholder the "undeclared SPI type" fallback just
            // above renders for any bare underscore-prefixed identifier -- must run after that
            // fallback since it runs unconditionally for any bare `_LTTextSessionDelegate`
            // reference still in `c` at this point, re-adding the struct if stripped earlier.
            c = c.replacingOccurrences(
                of: "public struct _LTTextSessionDelegate: Hashable, Sendable {}",
                with: "")
        return c
    }
}
