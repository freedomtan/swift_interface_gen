import Foundation

extension SwiftInterfaceGen {
    static func postProcessCharts(_ code: String, parser: Parser) -> String {
        var c = code
            // AnyChartSymbolShape/BasicChartSymbolShape conform to ChartSymbolShape (which
            // requires SwiftUI.Shape's nonisolated `path(in:)`). Our synthesized init/path
            // witnesses default to the enclosing (main-actor-inferred) isolation, which the
            // compiler rejects as a data-race-unsafe conformance; the real module marks them
            // `nonisolated` explicitly.
            c = c.replacingOccurrences(
                of: "public init(_ arg1: any ChartSymbolShape) { fatalError() }",
                with: "nonisolated public init(_ arg1: any ChartSymbolShape) { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func path(in: CGRect) -> SwiftUI.Path { fatalError() }",
                with: "nonisolated public func path(in: CGRect) -> SwiftUI.Path { fatalError() }")
            c = c.replacingOccurrences(
                of: "public var perceptualUnitRect: CGRect { get { fatalError() } }",
                with: "nonisolated public var perceptualUnitRect: CGRect { get { fatalError() } }")
            // SPAngle (Chart3DPose.azimuth/inclination) is a private C type with no public
            // Swift declaration anywhere (not even bridged via __C. — the demangler resolves it
            // to a bare capitalized name that looks like a real bridged ObjC type, but it isn't
            // one). Stub it out.
            c += "\npublic struct SPAngle: Hashable, Sendable {}\n"
            // Same private-C-type gap as SPAngle above, but for Chart3DContentModifier's
            // symbolRotation(_:) parameter.
            c += "\npublic struct SPRotation3D: Hashable, Sendable {}\n"
            // Foundation.Date retroactively conforms to Plottable/PrimitivePlottableProtocol in
            // the real module (confirmed via its conformance-descriptor symbols in the .tbd:
            // "Date: Charts.Plottable"/"Date: Charts.PrimitivePlottableProtocol") -- needed by
            // PlottableProjection's "where B.PrimitivePlottable == Date" extension above. Our
            // parser never discovers extensions on external Foundation types, so this conformance
            // (and the one real member it needs beyond PrimitivePlottableProtocol's own default
            // init?(primitivePlottable:)/primitivePlottable implementations) has to be hand-added.
            c += "\nextension Foundation.Date: Plottable, PrimitivePlottableProtocol {\n    public static var _primitivePlottableKind: _PrimitivePlottableKind<Foundation.Date> { fatalError() }\n}\n"
            // AnyChartContent's `_makeChartContent`/`body` witnesses are satisfied via a
            // "protocol witness for ..." ABI thunk, but ChartContent's own default-extension
            // implementation for them is never emitted by this generator (protocol-extension
            // defaults aren't reproduced, only concrete-type extensions), so AnyChartContent
            // itself needs the members explicitly.
            //
            // AnyChartContent is also ChartContent's `@_typeEraser` type (confirmed in the real
            // .swiftinterface: `@_typeEraser(AnyChartContent) ... public protocol ChartContent`)
            // and is declared `@frozen` there. Under library evolution, a non-@frozen resilient
            // struct's protocol-witness thunks (for `_makeChartContent`/`body`, specifically) get
            // compiled as indirect/resilient-access thunks that reference the *protocol's*
            // generic-placeholder mangling rather than AnyChartContent's own — and those never
            // make it into `-exported_symbols_list`, leaving them undefined at final-link time
            // even though they compile fine into the first-pass (`-undefined dynamic_lookup`)
            // dylib. Adding `@frozen` makes the compiler emit direct witness-thunk symbols
            // instead, matching the real ABI. Verified via a minimal standalone repro: removing
            // `@frozen` alone reproduces the exact 2 undefined "protocol witness for ..." symbols
            // seen here; adding it back alone (no other change) fixes the link.
            c = c.replacingOccurrences(
                of: "public struct AnyChartContent: ChartContent {",
                with: "@frozen\npublic struct AnyChartContent: ChartContent {\n    public var body: Never { fatalError() }\n    public static func _makeChartContent(content: SwiftUI._GraphValue<AnyChartContent>, inputs: _ChartContentInputs) -> _ChartContentOutputs { fatalError() }")
            // The real module declares `extension Optional: ChartContent/AxisContent/AxisMark/
            // Chart3DContent/ContourContent where Wrapped: <same protocol>` so that optional
            // chart content (`if let ... { SomeMark(...) }`) participates directly in the
            // result-builder chain. Now that stripBogusArrayExtensionStructs() no longer deletes
            // half the file (see its doc comment), the generator's ordinary constrained-extension
            // machinery DOES discover and emit these members from the demangled symbols after
            // all -- it just renders the header as bare "extension Optional where Wrapped: X"
            // without restating "Swift.Optional: X", so the retroactive conformance itself never
            // gets declared. Add it via a header-only textual patch rather than a full duplicate
            // block (a previous version of this fixup duplicated the members outright, which
            // caused "invalid redeclaration" once the real extensions stopped being deleted).
            for proto in ["AxisContent", "AxisMark", "Chart3DContent", "ChartContent", "ContourContent"] {
                c = c.replacingOccurrences(
                    of: "extension Optional where Wrapped: \(proto) {",
                    with: "extension Swift.Optional: \(proto) where Wrapped: \(proto) {")
            }
            // The Vectorized*PlotContent<Data> family (Area/Bar/Line/Point/Rectangle/Rule/
            // Sector) all conform to VectorizedChartContent, which requires `associatedtype
            // DataElement`; the real module resolves it to `Data.Element` (also requiring
            // `Data: RandomAccessCollection`) — neither is visible from the ABI alone.
            for plotKind in ["Area", "Bar", "Line", "Point", "Rectangle", "Rule", "Sector"] {
                c = c.replacingOccurrences(
                    of: "public struct Vectorized\(plotKind)PlotContent<A>: ChartContent, VectorizedChartContent {",
                    with: "public struct Vectorized\(plotKind)PlotContent<A>: ChartContent, VectorizedChartContent where A: RandomAccessCollection {\n    public typealias DataElement = A.Element")
            }
            // ChartBinRange<Bound> requires `Bound: Comparable` (RangeExpression's own
            // associatedtype bound) — not visible from the ABI alone.
            c = c.replacingOccurrences(
                of: "public struct ChartBinRange<A>: RangeExpression {",
                with: "public struct ChartBinRange<A>: RangeExpression where A: Comparable {")
            // NumberBins<Value>'s own generic parameter feeds ChartBinRange<Value>'s subscript,
            // so it needs the same Comparable bound (the real module also requires Numeric).
            c = c.replacingOccurrences(
                of: "public struct NumberBins<A>: Collection, Equatable, Sequence {",
                with: "public struct NumberBins<A>: Collection, Equatable, Sequence where A: Comparable, A: Numeric {")
            // BuilderTuple<A> is really a parameter-pack type (`struct BuilderTuple<each T>` in
            // the real, internal-only module) — its own generic parameter needs the `each`
            // marker to match the `(repeat A)` tuple type used in its members.
            c = c.replacingOccurrences(
                of: "public struct BuilderTuple<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct BuilderTuple<each A>: Sendable {")
            c = c.replacingOccurrences(
                of: "public init(elements: (repeat A)) { fatalError() }\n    public var elements: (repeat A) { get { fatalError() } set {} }\n    public init(from decoder: any Swift.Decoder) throws { fatalError() }\n    public func encode(to encoder: Swift.Encoder) throws { fatalError() }\n    public func hash(into hasher: inout Hasher) { fatalError() }\n    public static func ==(_ lhs: BuilderTuple<A>, _ rhs: BuilderTuple<A>) -> Bool { fatalError() }",
                with: "public init(elements: (repeat each A)) { fatalError() }\n    public var elements: (repeat each A) { get { fatalError() } }")
            // BuilderTuple's own constrained default-implementation extensions (e.g.
            // "extension BuilderTuple where A: ChartContent") hit the same parameter-pack gap:
            // a `where` clause constraining a pack's element type needs "repeat each A: Protocol",
            // not the ordinary generic "A: Protocol" the constrained-extension renderer emits.
            for proto in ["AxisContent", "AxisMark", "Chart3DContent", "ChartContent", "ContourContent"] {
                c = c.replacingOccurrences(
                    of: "extension BuilderTuple where A: \(proto) {",
                    with: "extension BuilderTuple where repeat each A: \(proto) {")
            }
            // Same missing-retroactive-conformance-restatement gap as Optional/Never/BuilderTuple
            // above, for the rest of Charts's result-builder plumbing: each of these types has a
            // real conformance descriptor per protocol (confirmed via the .tbd) but the generator
            // only emits the bare "extension X where <param>: Y" default-implementation block.
            for (type, protos) in [
                ("BuilderConditional", ["AxisContent", "AxisMark", "Chart3DContent", "ChartContent", "ContourContent"]),
                ("BuilderPair", ["AxisContent", "AxisMark", "ChartContent"]),
            ] {
                for proto in protos {
                    c = c.replacingOccurrences(
                        of: "extension \(type) where A: \(proto),  B: \(proto) {",
                        with: "extension \(type): \(proto) where A: \(proto),  B: \(proto) {")
                }
            }
            // BarPlot/RectanglePlot/SectorPlot's `body` renders as `some SwiftUI.View`, which
            // can't satisfy ChartContent's "associatedtype Body: ChartContent" (an opaque View
            // isn't a ChartContent-conforming nominal type) -- so restating ": ChartContent"
            // here doesn't type-check; their conformance descriptor's ChartContent/
            // VectorizedChartContent requirements stay an accepted, unreproducible stub.
            // ChartModifiedContent<A, B>'s real conformance forwards to whichever protocol A
            // itself is (SwiftUI's ModifiedContent<Content, Modifier>: Content shape) -- but
            // Swift doesn't support conforming to a generic parameter as if it were a protocol
            // name ("extension X: A" is rejected as "inheritance from non-protocol type 'A'"),
            // so this one has no source-level fix either; also left as an accepted stub.
            // PlottableProjection<A, B>'s own declaration has no bound on B, so a constrained
            // extension referencing "B.PrimitivePlottable" can't resolve it as an associated
            // type -- the real constraint also requires B: Plottable (PrimitivePlottable is
            // Plottable's own associated type).
            c = c.replacingOccurrences(
                of: "extension PlottableProjection where B.PrimitivePlottable == Date {",
                with: "extension PlottableProjection where B: Plottable, B.PrimitivePlottable == Date {")
            // Chart<Content>.init(_:content:)'s real constraint is
            // `Content == ForEach<Data, Data.Element.ID, C>` (an associated-type chain through
            // Data.Element's Identifiable conformance), which the generic-placeholder-path
            // eraser can't resolve and erases to a self-contradictory bare `Any`.
            c = c.replacingOccurrences(
                of: "where A == SwiftUI.ForEach<A1, Any, B1>,  A1: RandomAccessCollection,  B1: ChartContent,  A1.Element: Identifiable",
                with: "where A == SwiftUI.ForEach<A1, A1.Element.ID, B1>,  A1: RandomAccessCollection,  B1: ChartContent,  A1.Element: Identifiable")
            c = c.replacingOccurrences(
                of: "where A == SwiftUI.ForEach<A1, Any, B1>,  A1: RandomAccessCollection,  B1: Chart3DContent,  A1.Element: Identifiable",
                with: "where A == SwiftUI.ForEach<A1, A1.Element.ID, B1>,  A1: RandomAccessCollection,  B1: Chart3DContent,  A1.Element: Identifiable")
            // ValueAlignedChartScrollTargetBehavior conforms to ChartScrollTargetBehavior, which
            // itself extends SwiftUI.ScrollTargetBehavior — the redundant explicit
            // `SwiftUI.ScrollTargetBehavior` conformance forces its `updateTarget(context:)`
            // requirement (typed with SwiftUI's own ScrollTargetBehaviorContext) to apply
            // directly instead of through ChartScrollTargetBehavior's default implementation,
            // conflicting with the witness typed for ChartScrollTargetBehavior's own
            // ChartScrollTargetBehaviorContext requirement.
            c = c.replacingOccurrences(
                of: "public struct ValueAlignedChartScrollTargetBehavior: ChartScrollTargetBehavior, SwiftUI.ScrollTargetBehavior {",
                with: "public struct ValueAlignedChartScrollTargetBehavior: ChartScrollTargetBehavior {")
            // ChartScrollTargetBehavior : SwiftUI.ScrollTargetBehavior requires
            // `updateTarget(context: Self.TargetContext)`; ValueAlignedChartScrollTargetBehavior
            // only implements the Charts-specific ChartScrollTargetBehaviorContext overload — the
            // real module also provides a ScrollTargetBehaviorContext overload via
            // ChartScrollTargetBehavior's own default extension (never emitted since we don't
            // generate protocol-extension defaults), which is what actually satisfies
            // SwiftUI.ScrollTargetBehavior's requirement. Add it directly.
            c = c.replacingOccurrences(
                of: "public func updateTarget(_ arg1: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n}",
                with: "public func updateTarget(_ arg1: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n    public func updateTarget(_ target: inout SwiftUI.ScrollTarget, context: SwiftUI.ScrollTargetBehaviorContext) -> () {}\n}")
            c = c.replacingOccurrences(
                of: "public func updateTarget(_: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n}",
                with: "public func updateTarget(_: inout SwiftUI.ScrollTarget, context: ChartScrollTargetBehaviorContext) -> () {}\n    public func updateTarget(_ target: inout SwiftUI.ScrollTarget, context: SwiftUI.ScrollTargetBehaviorContext) -> () {}\n}")
        return c
    }
}
