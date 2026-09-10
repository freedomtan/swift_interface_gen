import Foundation

extension SwiftInterfaceGen {
    static func postProcessInternalSwiftProtobuf(_ code: String, parser: Parser) -> String {
        var c = code
            // Message.isEqualTo(message:)'s real ABI mangling is a self-referencing
            // existential (`AaB_p` -> "any Message", confirmed via swift-demangle on the
            // protocol's own dispatch-thunk symbol: "Message.isEqualTo(message:
            // InternalSwiftProtobuf.Message) -> Bool"), not `Self`. The generic-placeholder
            // eraser can't distinguish that shape from an ordinary `Self`-typed requirement, so
            // it rendered the protocol requirement as `message: Self` and every per-conformer
            // witness/the _MessageImplementationBase extension default as `message: any
            // Message` — neither of which satisfies the OTHER: a `Self`-typed requirement
            // needs a `Self`-typed witness, so `any Message` witnesses failed "does not conform
            // to protocol 'Message'" on every single Google_Protobuf_* type (~90 conformers).
            // Fix: rewrite both sides to the real ABI shape, bare `Message` (an implicit
            // existential in this position, verified via a minimal standalone repro).
            c = c.replacingOccurrences(
                of: "func isEqualTo(message: Self) -> Swift.Bool",
                with: "func isEqualTo(message: Message) -> Swift.Bool")
            c = c.replacingOccurrences(
                of: "public func isEqualTo(message: any Message) -> Swift.Bool { fatalError() }",
                with: "public func isEqualTo(message: Message) -> Swift.Bool { fatalError() }")
            // Same self-referencing-existential shape, same fix, for
            // AnyExtensionField.isEqual(other:) across all 10 *ExtensionField conformers
            // (confirmed via swift-demangle: the real requirement is "isEqual(other:
            // InternalSwiftProtobuf.AnyExtensionField) -> Bool", not Self).
            c = c.replacingOccurrences(
                of: "func isEqual(other: Self) -> Swift.Bool",
                with: "func isEqual(other: AnyExtensionField) -> Swift.Bool")
            c = c.replacingOccurrences(
                of: "public func isEqual(other: any AnyExtensionField) -> Swift.Bool { fatalError() }",
                with: "public func isEqual(other: AnyExtensionField) -> Swift.Bool { fatalError() }")
        return c
    }
}
