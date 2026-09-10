import Foundation

extension SwiftInterfaceGen {
    static func postProcessPromptKit(_ code: String, parser: Parser) -> String {
        var c = code
            // ChatMessagesPrompt/CompletionPrompt conform to GenerativeConfigurationProtocol
            // (associatedtype PromptType: PromptMode) and PromptMode (associatedtype
            // PromptContentType: Decodable) but never got per-conformer typealiases for either
            // associated type — the generator has no per-type ABI signal for them (neither
            // type has its own direct exported symbols; PromptKit.tbd shows only a single,
            // unrelated generic-bound reference to "ChatMessagesPrompt", no ChatMessagesPromptV
            // symbols at all), so the usual "resolve from a real witness" path finds nothing to
            // resolve from. PromptType is self-referential by construction (each of these types
            // IS its own PromptMode), and PromptContentType is satisfied by String (both types
            // are fundamentally string/message-content-based).
            c = c.replacingOccurrences(
                of: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {",
                with: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = ChatMessagesPrompt\n    public typealias PromptContentType = Swift.String")
            c = c.replacingOccurrences(
                of: "public struct CompletionPrompt: Codable, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {",
                with: "public struct CompletionPrompt: Codable, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = CompletionPrompt\n    public typealias PromptContentType = Swift.String")
        return c
    }
}
