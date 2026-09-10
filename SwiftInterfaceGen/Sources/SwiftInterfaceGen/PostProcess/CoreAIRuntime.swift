import Foundation

extension SwiftInterfaceGen {
    static func postProcessCoreAIRuntime(_ code: String, parser: Parser) -> String {
        var c = code
            // _AllRange conforms to NDArray.RangeExpression (confirmed via a real conformance
            // descriptor symbol, `_$s13CoreAIRuntime9_AllRangeVAA7NDArrayV0D10ExpressionAAMc`)
            // but has no `relative(to:)` witness anywhere in the ABI at all — not on _AllRange
            // itself, nor on any of RangeExpression's other conformers (Int, ClosedRange<Int>),
            // meaning the real implementation is satisfied by an `@inline(__always)`/generic
            // default that never emits its own exported symbol. Give the protocol a default
            // implementation instead of guessing at per-conformer bodies: `_AllRange`
            // represents "the entire range" so returning the input unchanged is the only
            // semantically valid default reachable at all sites (each real conformer's actual
            // behavior differs, but none of it is ABI-visible to reconstruct).
            c += "\nextension NDArray.RangeExpression {\n    public func relative(to range: Range<Swift.Int>) -> Range<Swift.Int> { return range }\n}\n"

            // InferenceFunction.Inputs.insert<A>/MutableViews.insert<A> take an
            // A: ViewRepresentable/MutableViewRepresentable generic parameter that is ALSO
            // constrained `A: ~Copyable` (confirmed via swift-demangle -expand on the real
            // symbol: "insert<A where A: ...ViewRepresentable, A: ~Swift.Copyable>"). Two
            // gaps against that ABI:
            // 1. ViewRepresentable/MutableViewRepresentable are declared plain (implicitly
            //    `: Copyable`), so a conformer can never also be `~Copyable` — the protocols
            //    themselves must opt out of the implicit Copyable requirement.
            // 2. A noncopyable-typed parameter needs an explicit ownership convention
            //    (borrowing/consuming/inout); the demangled signature text doesn't carry
            //    calling-convention detail, so the generator emits a bare, unannotated
            //    parameter, which Swift rejects for any ~Copyable type. The real convention here
            //    is by-value read-only access (insert() doesn't mutate the argument, only the
            //    receiver), so `borrowing` is used for insert()'s immutable `A: ~Copyable` param,
            //    matching every other read-only Span/PixelBuffer-family
            //    noncopyable-parameter fixup already applied elsewhere in this generator.
            c = c.replacingOccurrences(
                of: "public protocol ViewRepresentable: Sendable {",
                with: "public protocol ViewRepresentable: Sendable, ~Copyable {")
            c = c.replacingOccurrences(
                of: "public protocol MutableViewRepresentable: Sendable {",
                with: "public protocol MutableViewRepresentable: Sendable, ~Copyable {")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_ arg1: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_ arg1: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_ arg1: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_ arg1: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable,  GenericA: ~Copyable {}")
            c = c.replacingOccurrences(
                of: "public func insert<GenericA>(_: GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}",
                with: "public func insert<GenericA>(_: borrowing GenericA, for: Swift.String) -> () where GenericA: InferenceValue.ViewRepresentable, GenericA: ~Copyable {}")
        return c
    }
}
