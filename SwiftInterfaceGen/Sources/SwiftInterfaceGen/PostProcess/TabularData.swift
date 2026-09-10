import Foundation

extension SwiftInterfaceGen {
    static func postProcessTabularData(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix: ShapedData<A>'s real ABI conditionally conforms to Hashable/Equatable
            // (confirmed via swift-demangle: separate constrained conformance descriptors). The
            // generator already emits the correct conditional "where A: Equatable"/"where A:
            // Hashable" extensions with real hash(into:)/==/hashValue bodies, but ALSO declares
            // Hashable unconditionally on the struct's own header with a DUPLICATE unconditional
            // hash(into:)/== inside the base body -- redundant with (and ambiguous against) the
            // conditional extension members. Removing the unconditional header conformance and
            // duplicate members, and restating the conformance on the extensions (same gap
            // already fixed for StoreKit's VerificationResult<A> and elsewhere this session).
            c = c.replacingOccurrences(
                of: "public struct ShapedData<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct ShapedData<A>: Codable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "extension ShapedData where A: Equatable {",
                with: "extension ShapedData: Equatable where A: Equatable {")
            // Unlike Column/ColumnSlice/DiscontiguousColumnSlice, the generator never emits a
            // separate "extension ShapedData where A: Hashable" -- hash(into:) only ever exists
            // as a duplicate, unconditional member inside the base struct body (removed above
            // along with Hashable on the header). Extract it into a new conditional extension
            // via a structural span match rather than an exact adjacent-member literal, since
            // member order inside the struct body is nondeterministic across generator runs
            // (same root cause as Speech's TimeRangeAttribute/ConfidenceAttribute fix).
            if let structRe = try? NSRegularExpression(
                pattern: "public struct ShapedData<A>: Codable, @unchecked Sendable \\{([\\s\\S]*?)\\n\\}\\n"),
               let m = structRe.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
               let bodyRange = Range(m.range(at: 1), in: c),
               let fullRange = Range(m.range, in: c) {
                let body = String(c[bodyRange])
                let newBody = body.replacingOccurrences(
                    of: "\n    public func hash(into hasher: inout Hasher) { fatalError() }",
                    with: "")
                if newBody != body {
                    let replacement = "public struct ShapedData<A>: Codable, @unchecked Sendable {\(newBody)\n}\nextension ShapedData: Hashable where A: Hashable {\n    public func hash(into hasher: inout Hasher) { fatalError() }\n    public var hashValue: Swift.Int { fatalError() }\n}\n"
                    c.replaceSubrange(fullRange, with: replacement)
                }
            }

            // Fix: same unconditional-Hashable-header + duplicate-hash(into:)/== gap for
            // ColumnSlice<A> and DiscontiguousColumnSlice<A> -- each already has correct
            // conditional "where A: Equatable"/"where A: Hashable" extensions with real bodies.
            for name in ["ColumnSlice", "DiscontiguousColumnSlice"] {
                c = c.replacingOccurrences(
                    of: "    public func hash(into hasher: inout Hasher) { fatalError() }\n    public static func ==(_ lhs: \(name)<A>, _ rhs: \(name)<A>) -> Bool { fatalError() }\n}\n",
                    with: "}\n")
                c = c.replacingOccurrences(
                    of: "extension \(name) where A: Equatable {",
                    with: "extension \(name): Equatable where A: Equatable {")
                c = c.replacingOccurrences(
                    of: "extension \(name) where A: Hashable {",
                    with: "extension \(name): Hashable where A: Hashable {")
            }
            c = c.replacingOccurrences(
                of: "public struct ColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Hashable, MutableCollection, OptionalColumnProtocol, RandomAccessCollection, @unchecked Sendable, Sequence {",
                with: "public struct ColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, MutableCollection, OptionalColumnProtocol, RandomAccessCollection, @unchecked Sendable, Sequence {")
            c = c.replacingOccurrences(
                of: "public struct DiscontiguousColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Hashable, MutableCollection, OptionalColumnProtocol, @unchecked Sendable, Sequence {",
                with: "public struct DiscontiguousColumnSlice<A>: BidirectionalCollection, Codable, Collection, ColumnProtocol, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, MutableCollection, OptionalColumnProtocol, @unchecked Sendable, Sequence {")

            // Fix: Column<A>'s real ABI conditionally conforms to Decodable/Encodable/Equatable/
            // Hashable (confirmed via swift-demangle), but none of the existing per-bound
            // extensions restate the conformance -- same conformance-restatement gap.
            for proto in ["Decodable", "Encodable", "Equatable", "Hashable"] {
                c = c.replacingOccurrences(
                    of: "extension Column where A: \(proto) {",
                    with: "extension Column: \(proto) where A: \(proto) {")
            }

            // Fix: DataFrame.init<A: Sequence>(columns:) where A.Element == AnyColumn is real
            // ABI (confirmed via swift-demangle) but never rendered at all.
            c = c.replacingOccurrences(
                of: "public struct DataFrame: CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, DataFrameProtocol, ExpressibleByDictionaryLiteral, Hashable {",
                with: "public struct DataFrame: CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, DataFrameProtocol, ExpressibleByDictionaryLiteral, Hashable {\n    public init<GenericA>(columns: GenericA) where GenericA: Swift.Sequence, GenericA.Element == AnyColumn { fatalError() }")

            // Fix: {CSV,JSON}ReadingOptions.addDateParseStrategy<A>(_:) is missing the real ABI's
            // ParseInput/ParseOutput associated-type constraints (confirmed via swift-demangle:
            // "A.ParseInput == Swift.String, A.ParseOutput == Foundation.Date").
            c = c.replacingOccurrences(
                of: "public func addDateParseStrategy<GenericA>(_ arg1: GenericA) -> () where GenericA: ParseStrategy {}",
                with: "public func addDateParseStrategy<GenericA>(_ arg1: GenericA) -> () where GenericA: ParseStrategy, GenericA.ParseInput == Swift.String, GenericA.ParseOutput == Foundation.Date {}")

            // Fix: DiscontiguousColumnSlice's UnboundedRange subscript (`x[...]`) IS already
            // rendered, but as `subscript(_ arg1: @escaping (UnboundedRange_) -> ()) -> ...`
            // instead of the correct `subscript(bounds: UnboundedRange) -> ...` -- the shorthand
            // "..." subscript syntax apparently got parsed as if UnboundedRange were a closure
            // parameter. Confirmed via a minimal repro that the plain, non-closure form is what
            // produces the exact required mangled shape.
            c = c.replacingOccurrences(
                of: "public subscript(_ arg1: @escaping (UnboundedRange_) -> ()) -> DiscontiguousColumnSlice<A> { get { fatalError() } set {} }",
                with: "public subscript(bounds: UnboundedRange) -> DiscontiguousColumnSlice<A> { get { fatalError() } set {} }")

            // Fix: ColumnProtocol/OptionalColumnProtocol's arithmetic/comparison operator
            // overloads render their generic associated-type placeholder (Self.Element /
            // Self.WrappedElement) as a bare unconstrained "Any" -- both in the parameter type
            // and in the "Column<Any>" return type -- rather than the real associated type,
            // which changes the mangled generic signature entirely (confirmed via swift-demangle
            // and a minimal repro). Also, ColumnProtocol's Comparable extension only rendered
            // != and == and dropped </<=/>/>= entirely.
            //
            // A minimal repro further showed the (Self, Self.Element)/(Self.Element, Self)
            // overloads for the AdditiveArithmetic bound specifically need to live in a
            // *different* extension shape than the (Self, Self) overload: an unconstrained
            // "extension ColumnProtocol { ... where Self.Element: AdditiveArithmetic }" (the
            // bound restated per-function, not on the extension) mangles to
            // "ColumnProtocol.+ infix< where ...>(A, A.Element)", matching the real ABI, while
            // the same overload declared inside "extension ColumnProtocol where Self.Element:
            // AdditiveArithmetic" mangles to the WRONG "ColumnProtocol< where ...>.+ infix(...)"
            // shape instead. All other bounds (BinaryInteger/Comparable/FloatingPoint/Numeric)
            // do NOT have this quirk -- every overload for those bounds (including the mixed
            // Self/Self.Element ones) already mangles correctly from the plain bound extension,
            // confirmed via a separate minimal repro.
            //
            // Member order within each of these generated extension bodies is nondeterministic
            // across generator runs (same root cause as Speech's TimeRangeAttribute/
            // ConfidenceAttribute fix), so the AdditiveArithmetic restructuring below extracts
            // the whole extension body via a structural span match and edits it with
            // order-independent `contains`/`replacingOccurrences` calls, rather than assuming a
            // fixed member sequence. The non-restructuring fixes (BinaryInteger/FloatingPoint/
            // Numeric/Comparable) are simple global per-line replacements, which are inherently
            // order-independent since they don't depend on adjacent-line context.
            if let re = try? NSRegularExpression(pattern: "extension ColumnProtocol where Self\\.Element: AdditiveArithmetic \\{([\\s\\S]*?)\\n\\}\\n"),
               let m = re.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
               let bodyRange = Range(m.range(at: 1), in: c),
               let fullRange = Range(m.range, in: c) {
                var body = String(c[bodyRange])
                var extracted: [String] = []
                for (old, new) in [
                    ("    public static func +(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                     "    public static func +(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                    ("    public static func +(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                     "    public static func +(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                    ("    public static func -(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                     "    public static func -(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                    ("    public static func -(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                     "    public static func -(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> where Self.Element: AdditiveArithmetic { fatalError() }"),
                ] {
                    if body.contains(old) {
                        body = body.replacingOccurrences(of: "\n" + old, with: "")
                        extracted.append(new)
                    }
                }
                body = body.replacingOccurrences(
                    of: "    public static func +(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                    with: "    public static func +(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }")
                body = body.replacingOccurrences(
                    of: "    public static func -(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                    with: "    public static func -(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }")
                let replacement = "extension ColumnProtocol {\n\(extracted.joined(separator: "\n"))\n}\nextension ColumnProtocol where Self.Element: AdditiveArithmetic {\(body)\n}\n"
                c.replaceSubrange(fullRange, with: replacement)
            }
            for (old, new) in [
                ("    public static func /(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                 "    public static func /(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> { fatalError() }"),
                ("    public static func /(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func /(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func /(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func /(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func *(_ arg1: Any, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func *(_ arg1: Self.Element, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func *(_ arg1: Self, _ arg2: Any) -> Column<Any> { fatalError() }",
                 "    public static func *(_ arg1: Self, _ arg2: Self.Element) -> Column<Self.Element> { fatalError() }"),
                ("    public static func *(_ arg1: Self, _ arg2: Self) -> Column<Any> { fatalError() }",
                 "    public static func *(_ arg1: Self, _ arg2: Self) -> Column<Self.Element> { fatalError() }"),
                ("    public static func !=(_ arg1: Self, _ arg2: Any) -> [Swift.Bool] { return [] }",
                 "    public static func !=(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }"),
                ("    public static func !=(_ arg1: Any, _ arg2: Self) -> [Swift.Bool] { return [] }",
                 "    public static func !=(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }"),
                ("    public static func == (lhs: Self, rhs: Any) -> [Swift.Bool] { fatalError() }",
                 "    public static func == (lhs: Self, rhs: Self.Element) -> [Swift.Bool] { fatalError() }"),
                ("    public static func == (lhs: Any, rhs: Self) -> [Swift.Bool] { fatalError() }",
                 "    public static func == (lhs: Self.Element, rhs: Self) -> [Swift.Bool] { fatalError() }"),
            ] {
                c = c.replacingOccurrences(of: old, with: new)
            }
            // Comparable's real ABI also needs </<=/>/>=, entirely missing from the generator's
            // output -- inserted right after the extension header so this doesn't depend on
            // where the existing != /== members happen to land.
            c = c.replacingOccurrences(
                of: "extension ColumnProtocol where Self.Element: Comparable {\n",
                with: """
                extension ColumnProtocol where Self.Element: Comparable {
                    public static func <(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func <(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }
                    public static func <=(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func <=(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }
                    public static func >(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func >(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }
                    public static func >=(_ arg1: Self, _ arg2: Self.Element) -> [Swift.Bool] { fatalError() }
                    public static func >=(_ arg1: Self.Element, _ arg2: Self) -> [Swift.Bool] { fatalError() }

                """)

            // Fix: the 10 top-level generic operators bridging ColumnProtocol<->
            // OptionalColumnProtocol render their shared-element constraint as a bogus
            // "Any: Numeric, Any == Any" (or similarly nonsensical) requirement instead of
            // "A.Element: Numeric, A.Element == B.WrappedElement" (or the WrappedElement/Element
            // mirror), and return "Column<Any>" instead of "Column<A.Element>"/
            // "Column<A.WrappedElement>" -- same generic-placeholder-resolved-as-Any gap,
            // confirmed via a minimal repro to produce the exact required mangled shape. Note
            // the double space after the first "where" clause comma -- that's how postProcess's
            // multi-constraint "where" rendering actually prints it for these functions.
            // "/" needs TWO real ABI symbols per direction (BinaryInteger- and FloatingPoint-
            // bound), but the generator only ever emits ONE stub per direction (its raw,
            // unfixed "Any"-typed text is byte-identical regardless of bound, so there's only
            // one line to find) -- the single old declaration is replaced with BOTH bound
            // variants as two separate overloads (legal, since a caller's concrete A.Element
            // can't simultaneously satisfy both bounds, so there's no ambiguity).
            struct TopLevelOp { let op: String; let aProto: String; let bProto: String; let aAssoc: String; let bAssoc: String; let bounds: [String] }
            let topLevelOps: [TopLevelOp] = [
                TopLevelOp(op: "*", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["Numeric"]),
                TopLevelOp(op: "*", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["Numeric"]),
                TopLevelOp(op: "+", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "+", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "-", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "-", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["AdditiveArithmetic"]),
                TopLevelOp(op: "/", aProto: "ColumnProtocol", bProto: "OptionalColumnProtocol", aAssoc: "Element", bAssoc: "WrappedElement", bounds: ["BinaryInteger", "FloatingPoint"]),
                TopLevelOp(op: "/", aProto: "OptionalColumnProtocol", bProto: "ColumnProtocol", aAssoc: "WrappedElement", bAssoc: "Element", bounds: ["BinaryInteger", "FloatingPoint"]),
            ]
            for entry in topLevelOps {
                let replacements = entry.bounds.map { bound in
                    "public func \(entry.op)<A, B>(_ arg1: A, _ arg2: B) -> Column<A.\(entry.aAssoc)> where A: \(entry.aProto), B: \(entry.bProto), A.\(entry.aAssoc): \(bound), A.\(entry.aAssoc) == B.\(entry.bAssoc) { fatalError() }"
                }.joined(separator: "\n")
                c = c.replacingOccurrences(
                    of: "public func \(entry.op)<A, B>(_ arg1: A, _ arg2: B) -> Column<Any> where A: \(entry.aProto),  B: \(entry.bProto) { fatalError() }",
                    with: replacements)
            }

            // Fix: OptionalColumnProtocol's AdditiveArithmetic extension already types its
            // mixed Self/Self.WrappedElement overloads correctly, but declares them inside the
            // bound "where Self.WrappedElement: AdditiveArithmetic" extension -- same wrong-
            // mangled-shape issue as ColumnProtocol's mixed overloads, since they already carry
            // the bound as a redundant per-function where clause and just need an unconstrained
            // enclosing extension. The (Self, Self) +/- overloads ARE real ABI too (confirmed via
            // swift-demangle, same "ColumnProtocol< where ...>.op infix(A, A)" bound-extension
            // shape as ColumnProtocol's own (Self, Self) overloads) and are already correctly
            // typed, so they stay behind in the original bound extension. Same order-independent
            // structural extraction as ColumnProtocol's AdditiveArithmetic fix above.
            if let re = try? NSRegularExpression(pattern: "extension OptionalColumnProtocol where Self\\.WrappedElement: AdditiveArithmetic \\{([\\s\\S]*?)\\n\\}\\n"),
               let m = re.firstMatch(in: c, range: NSRange(c.startIndex..., in: c)),
               let bodyRange = Range(m.range(at: 1), in: c),
               let fullRange = Range(m.range, in: c) {
                var body = String(c[bodyRange])
                var extracted: [String] = []
                for old in [
                    "    public static func +(_ arg1: Self, _ arg2: Self.WrappedElement) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                    "    public static func -(_ arg1: Self, _ arg2: Self.WrappedElement) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                    "    public static func +(_ arg1: Self.WrappedElement, _ arg2: Self) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                    "    public static func -(_ arg1: Self.WrappedElement, _ arg2: Self) -> Column<Self.WrappedElement> where Self.WrappedElement: AdditiveArithmetic { fatalError() }",
                ] {
                    if body.contains(old) {
                        body = body.replacingOccurrences(of: "\n" + old, with: "")
                        extracted.append(old)
                    }
                }
                let replacement = "extension OptionalColumnProtocol {\n\(extracted.joined(separator: "\n"))\n}\nextension OptionalColumnProtocol where Self.WrappedElement: AdditiveArithmetic {\(body)\n}\n"
                c.replaceSubrange(fullRange, with: replacement)
            }
        return c
    }
}
