import Foundation

extension SwiftInterfaceGen {
    static func postProcessSwiftDataPart1(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix: BackingData<Model>'s real ABI init requirement is "init(for: Self.Model.Type)"
            // (confirmed via swift-demangle: "BackingData.init(for: A.Model.Type) -> A"), but the
            // generator renders it as "init(for: Any)" -- an unrelated bogus "associatedtype A"
            // (with no real ABI presence at all) sits right above it, suggesting the parser
            // mis-resolved the parameter's associated-type path to a fresh, meaningless
            // placeholder instead of "Self.Model". PersistentModel's init(backingData:)/
            // persistentBackingData similarly need the primary-associated-type-qualified "any
            // BackingData<Self>" existential (confirmed via swift-demangle: "any
            // SwiftData.BackingData<Self.Model == A>"), not the bare unconstrained "any
            // BackingData" the generator renders -- both fixes confirmed via a minimal repro to
            // produce the exact required dispatch-thunk/method-descriptor symbols.
            c = c.replacingOccurrences(
                of: "public protocol BackingData<Model> {\n    associatedtype A\n    init(for: Any)",
                with: "public protocol BackingData<Model> {\n    init(for: Self.Model.Type)")
            // Fix: same missing-second-generic-parameter gap as PersistentModel's getValue/
            // setValue extension methods (see below), but for BackingData's own protocol
            // requirements -- confirmed via a minimal repro to produce the exact required
            // dispatch-thunk/method-descriptor symbols.
            c = c.replacingOccurrences(
                of: "func getValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: RelationshipCollection",
                with: "func getValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")
            c = c.replacingOccurrences(
                of: "func setValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: RelationshipCollection",
                with: "func setValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")

            // Fix: BackingData/PersistentModel's Decodable/Encodable-combined RelationshipCollection
            // overloads have the same missing-second-generic-parameter gap as the plain
            // RelationshipCollection overload above, just with an extra Decodable/Encodable bound --
            // confirmed via a minimal repro that source order "GenericA: Decodable, GenericA:
            // RelationshipCollection, GenericB == GenericA.PersistentElement" produces the exact
            // required dispatch-thunk/method-descriptor symbols (a prior investigation this session
            // wrongly concluded this was uncontrollable from source order).
            c = c.replacingOccurrences(
                of: "func getValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: Decodable,  GenericA: RelationshipCollection",
                with: "func getValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>) -> GenericA where GenericA: Decodable, GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")
            c = c.replacingOccurrences(
                of: "func setValue<GenericA>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: Encodable,  GenericA: RelationshipCollection",
                with: "func setValue<GenericA, GenericB>(forKey: KeyPath<Self.Model, GenericA>, to: GenericA) -> () where GenericA: Encodable, GenericA: RelationshipCollection, GenericB == GenericA.PersistentElement")

            // Fix: [A]/A? (Array/Optional) conditionally conform to RelationshipCollection in
            // the real module (confirmed via swift-demangle: "protocol conformance descriptor
            // for <A where A: PersistentModel> [A] : RelationshipCollection" and "<A where A:
            // Sequence, A.Element: PersistentModel> A? : RelationshipCollection"), but the
            // generator never renders these retroactive stdlib-type conformances at all --
            // confirmed via a minimal repro to produce the exact required conformance-descriptor
            // symbols (RelationshipCollection has no method requirements, only an associated
            // type, so no witness table is needed/emitted for either -- the still-remaining
            // witness-table stubs for these two conformances are a separate, unresolved gap).
            c += """


            extension Array: RelationshipCollection where Element: PersistentModel {
                public typealias PersistentElement = Element
            }
            extension Optional: RelationshipCollection where Wrapped: Sequence, Wrapped.Element: PersistentModel {
                public typealias PersistentElement = Wrapped.Element
            }
            """
            // Fix: HistoryDelete/HistoryInsert/HistoryUpdate/HistoryToken/HistoryTransaction's
            // associated types are missing extra real-ABI bounds (confirmed via swift-demangle:
            // each needs an "associated conformance descriptor ... : Swift.Hashable" that a
            // Comparable-only or Decodable-only bound can't produce, since Hashable isn't implied
            // by either). Each fix is a single-line, order-independent global replace -- member
            // order within these protocol bodies is nondeterministic across generator runs (same
            // root cause as Speech's TimeRangeAttribute/ConfidenceAttribute fix), so an earlier
            // attempt matching adjacent multi-line blocks only fired when two associatedtype
            // lines happened to land in the assumed order, producing a flaky 89-94 stub count
            // across repeated runs. "associatedtype TransactionIdentifier: Comparable" and
            // "associatedtype ChangeIdentifier: Comparable" are intentionally replaced globally
            // (`replaceAll`-equivalent via a single non-anchored match) since the identical fixed
            // text is correct everywhere they appear (HistoryDelete/HistoryInsert/HistoryUpdate).
            c = c.replacingOccurrences(
                of: "associatedtype TransactionIdentifier: Comparable\n",
                with: "associatedtype TransactionIdentifier: Comparable, Hashable\n")
            c = c.replacingOccurrences(
                of: "associatedtype ChangeIdentifier: Comparable\n",
                with: "associatedtype ChangeIdentifier: Comparable, Hashable\n")
            c = c.replacingOccurrences(
                of: "associatedtype TokenType: Decodable\n",
                with: "associatedtype TokenType: Decodable, Encodable, Hashable\n")
            c = c.replacingOccurrences(
                of: "associatedtype TokenType: Identifiable\n",
                with: "associatedtype TokenType: Identifiable, Comparable, Hashable\n")

            for historyType in ["DefaultHistoryDelete", "DefaultHistoryInsert", "DefaultHistoryUpdate"] {
                let protoName = historyType.replacingOccurrences(of: "Default", with: "")
                c = c.replacingOccurrences(
                    of: "public struct \(historyType)<A>: \(protoName) {",
                    with: "public struct \(historyType)<A>: \(protoName) where A: PersistentModel {\n    public typealias Model = A")
            }
            // DataStoreConfiguration requires `associatedtype Store: DataStore where Self ==
            // Self.Store.Configuration`, and DataStore requires `where Self ==
            // Self.Configuration.Store` — a mutually-referential pair the compiler can only
            // resolve if both sides declare the typealias explicitly (DefaultStore's own
            // Configuration is inferred fine from its init(_:migrationPlan:) witness, but
            // ModelConfiguration.Store has no witness to infer from).
            c = c.replacingOccurrences(
                of: "public struct ModelConfiguration: CustomDebugStringConvertible, DataStoreConfiguration, Hashable, Identifiable {",
                with: "public struct ModelConfiguration: CustomDebugStringConvertible, DataStoreConfiguration, Hashable, Identifiable {\n    public typealias Store = DefaultStore")
            // ResultsSection<Element, SectionName> conforms to Identifiable via `id: SectionName`
            // (its own second generic parameter), not the AnyObject-only default `id:
            // ObjectIdentifier`. The generated `id` property already returns `B`; the missing
            // piece is telling the compiler ResultsSection.ID is B, not the ambiguous default.
            // Identifiable.ID requires Hashable, so B needs that bound too (the real module
            // constrains SectionName: Swift.Hashable).
            c = c.replacingOccurrences(
                of: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Identifiable, RandomAccessCollection, Sequence {",
                with: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Identifiable, RandomAccessCollection, Sequence where B: Hashable {\n    public typealias ID = B")
            c = c.replacingOccurrences(
                of: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Equatable, Identifiable, RandomAccessCollection, Sequence {",
                with: "public struct ResultsSection<A, B>: BidirectionalCollection, Collection, Equatable, Identifiable, RandomAccessCollection, Sequence where B: Hashable {\n    public typealias ID = B")
            c = c.replacingOccurrences(
                of: "public struct ResultsSectionCollection<A, B>: BidirectionalCollection, Collection, RandomAccessCollection, Sequence {",
                with: "public struct ResultsSectionCollection<A, B>: BidirectionalCollection, Collection, RandomAccessCollection, Sequence where B: Hashable {")
            // SectionedResults<Element, SectionTitle> wraps [ResultsSection<A, B>] internally,
            // which itself now requires B: Hashable (real module: `where SectionTitle: Hashable`).
            c = c.replacingOccurrences(
                of: "public struct SectionedResults<A, B>: BidirectionalCollection, Collection, Equatable, RandomAccessCollection, Sequence {",
                with: "public struct SectionedResults<A, B>: BidirectionalCollection, Collection, Equatable, RandomAccessCollection, Sequence where B: Hashable {")
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class ResultsObserver<A, B>: CustomDebugStringConvertible, Observation.Observable {",
                with: "@_fixed_layout final public class ResultsObserver<A, B>: CustomDebugStringConvertible, Observation.Observable where B: Hashable {")
            // `_computeSections`'s real constraint is `A == B.Element` (A is B's element type),
            // but replaceGenericPlaceholderPathsWithAny (applied generically to all top-level
            // global function signatures) can't distinguish a meaningful associated-type
            // reference on a generic parameter from an unresolvable demangler placeholder path.
            // An earlier fix assumed this erased "B.Element" to a literal "A == Any" clause, but
            // the constraint is now dropped entirely instead (confirmed via direct inspection of
            // the generated interface) -- restore it by anchoring on the still-present
            // "A: PersistentModel,  B: RandomAccessCollection" pair.
            c = c.replacingOccurrences(
                of: "where A: PersistentModel,  B: RandomAccessCollection,  C: Hashable",
                with: "where A: PersistentModel, A == B.Element, B: RandomAccessCollection, C: Hashable")
            // Also drop the erroneously-added `@escaping` on `resolveSection` (real ABI shows a
            // plain, non-escaping closure type: "resolveSection: (A) -> C?") -- same
            // erroneously-added-@escaping gap already fixed for MetalPerformanceShadersGraph's
            // reorderInputsAndOutputs and StoreKit's BackingValue.value(atKeyPath:), confirmed
            // via a minimal repro.
            c = c.replacingOccurrences(
                of: "resolveSection: @escaping (A) -> C?",
                with: "resolveSection: (A) -> C?")
            // DefaultSerialModelExecutor is non-final but must conform to Sendable (required by
            // SerialExecutor/Executor); the real class declares this via `@unchecked Sendable`.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class DefaultSerialModelExecutor: Executor, ModelExecutor, SerialExecutor, SerialModelExecutor {",
                with: "@_fixed_layout public class DefaultSerialModelExecutor: Executor, ModelExecutor, SerialExecutor, SerialModelExecutor, @unchecked Sendable {")
            // Schema.Index<T>'s nested `Types` enum is itself generic (`enum Types<P> where P:
            // PersistentModel`) in the real module, but our generic-discovery pass never sees a
            // usage that would mark it generic (it's only ever referenced as `Index<T>.Types<T>`,
            // matching the outer class's own parameter), so it's emitted as a plain non-generic
            // enum while still being *referenced* with a `<A1>` argument. Make the declaration
            // generic to match its use sites, using Index's own parameter name.
            c = c.replacingOccurrences(
                of: "public enum Types: Codable, Hashable, @unchecked Sendable {",
                with: "public enum Types<A1>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: Types, _ rhs: Types) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: Types<A1>, _ rhs: Types<A1>) -> Bool { fatalError() }")
        return c
    }

    static func postProcessSwiftDataPart2(_ code: String, parser: Parser) -> String {
        var c = code
            // `BackingData` isn't declared with a primary associated type (`protocol
            // BackingData<Model>`), so constrained-existential usages like `any
            // BackingData<Self.Model == A1>` (left behind above as just `any BackingData`,
            // since stripConstrainedExistentialGenerics drops the whole `<...>` clause) are
            // left with A1 not appearing anywhere in these two extension methods' signatures,
            // which the compiler rejects as an unused generic parameter. BackingData actually
            // DOES have a primary associated type (`protocol BackingData<Model>`, fixed earlier
            // this session), so instead of the unused-parameter workaround this used previously
            // (a phantom `as type: A1.Type` parameter, which doesn't match the real ABI's
            // parameter list), restore the constraint as `any BackingData<A1>` -- BackingData's
            // primary associated type argument -- which both keeps A1 used AND mangles to the
            // exact real ABI shape (confirmed via swift-demangle and a minimal repro).
            c = c.replacingOccurrences(
                of: "public func _generateCurrentClassBackingData<A1>() -> any BackingData where A1: PersistentModel { fatalError() }",
                with: "public func _generateCurrentClassBackingData<A1>() -> any BackingData<A1> where A1: PersistentModel { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func _superClassBackingData<A1>(of: any PersistentModel.Type) -> any BackingData where A1: PersistentModel { fatalError() }",
                with: "public func _superClassBackingData<A1>(of: any PersistentModel.Type) -> any BackingData<A1> where A1: PersistentModel { fatalError() }")
            // `init(backingData:)`/`persistentBackingData` reference `any BackingData<Self.Model
            // == A>` in the real module; here the generic-placeholder-path eraser reduces the
            // constraint to plain `<Any>` (no `==` survives, so stripConstrainedExistentialGenerics
            // above doesn't catch it) rather than dropping it — BackingData has no primary
            // associated type, so any `<...>` on it is invalid.
            c = c.replacingOccurrences(of: "any BackingData<Any>", with: "any BackingData")
            // PersistentModel.init(backingData:)/persistentBackingData reference `any
            // BackingData<Self.Model == A>` in the real module (confirmed via swift-demangle),
            // which needs BackingData's primary associated type argument restored as `<Self>`
            // (PersistentModel's own Self satisfies BackingData's Model bound) -- confirmed via a
            // minimal repro to produce the exact required dispatch-thunk/method-descriptor
            // symbols. This must run after the "any BackingData<Any>" strip right above, since
            // at the point the SwiftData block earlier in postProcess runs, this text is still
            // in its unstripped, generic-placeholder-eraser form and doesn't match yet.
            c = c.replacingOccurrences(
                of: "init(backingData: any BackingData)",
                with: "init(backingData: any BackingData<Self>)")
            c = c.replacingOccurrences(
                of: "var persistentBackingData: any BackingData { get set }",
                with: "var persistentBackingData: any BackingData<Self> { get set }")

            // Fix: PersistentModel.getValue/setValue's RelationshipCollection-bound overloads
            // are missing a second, structurally-required generic parameter tied via `==` to
            // A1.PersistentElement (confirmed via swift-demangle: "getValue<A, B where A1:
            // RelationshipCollection, B1 == A1.PersistentElement>" -- the mangler tracks
            // A1.PersistentElement as its own substitution slot, requiring a second declared
            // generic parameter even though it's otherwise unused in the visible signature).
            // Confirmed via a minimal repro to produce the exact required symbol. The Decodable/
            // Encodable-combined RelationshipCollection overloads need the same B1 parameter,
            // with A1: Decodable/Encodable listed before A1: RelationshipCollection in source --
            // confirmed via a minimal repro that this ordering produces the exact required symbol
            // (a prior investigation this session wrongly concluded the canonical order wasn't
            // controllable from source).
            c = c.replacingOccurrences(
                of: "public func getValue<A1>(forKey: KeyPath<Self, A1>) -> A1 where A1: RelationshipCollection { fatalError() }",
                with: "public func getValue<A1, B1>(forKey: KeyPath<Self, A1>) -> A1 where A1: RelationshipCollection, B1 == A1.PersistentElement { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func setValue<A1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: RelationshipCollection {}",
                with: "public func setValue<A1, B1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: RelationshipCollection, B1 == A1.PersistentElement {}")
            c = c.replacingOccurrences(
                of: "public func getValue<A1>(forKey: KeyPath<Self, A1>) -> A1 where A1: Decodable,  A1: RelationshipCollection { fatalError() }",
                with: "public func getValue<A1, B1>(forKey: KeyPath<Self, A1>) -> A1 where A1: Decodable, A1: RelationshipCollection, B1 == A1.PersistentElement { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func setValue<A1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: Encodable,  A1: RelationshipCollection {}",
                with: "public func setValue<A1, B1>(forKey: KeyPath<Self, A1>, to: A1) -> () where A1: Encodable, A1: RelationshipCollection, B1 == A1.PersistentElement {}")

            // Fix: ResultsObserverDelegate has the same bogus-associatedtype pattern as
            // BackingData -- an unrelated `associatedtype A`/`associatedtype B` pair (no real
            // ABI presence) sits alongside the real Element/SectionTitle associated types, and
            // the protocol isn't declared with them as primary associated types at all.
            // ResultsObserver.delegate's real ABI is `any ResultsObserverDelegate<Self.Element ==
            // A, Self.SectionTitle == B>` (confirmed via swift-demangle), which requires
            // ResultsObserverDelegate<Element, SectionTitle> primary-associated-type syntax on
            // the protocol declaration and `any ResultsObserverDelegate<A, B>` (ResultsObserver's
            // own generic parameters) at the usage site -- confirmed via a minimal repro to
            // produce the exact required symbols.
            c = c.replacingOccurrences(
                of: "public protocol ResultsObserverDelegate {\n    associatedtype A\n    associatedtype B\n",
                with: "public protocol ResultsObserverDelegate<Element, SectionTitle> {\n")
            c = c.replacingOccurrences(
                of: "public final var delegate: (any ResultsObserverDelegate)? { get { return nil } set {} }",
                with: "public final var delegate: (any ResultsObserverDelegate<A, B>)? { get { return nil } set {} }")

            // Fix: DataStoreBatchDeleteRequest<A>/FetchDescriptor<A>/HistoryDescriptor<A>/
            // ResultsObserver<A, B>.predicate|filterBy, plus ModelContext.delete<GenericA>(where:),
            // all render `Foundation.Predicate<Any>` instead of `Foundation.Predicate<{their own
            // generic parameter}>` (confirmed via swift-demangle: real ABI is
            // "Foundation.Predicate<Pack{A}>", since Predicate is declared with a variadic-
            // generic `each Input` and each of these passes its own generic parameter as a
            // single-element pack) -- same generic-placeholder-resolved-as-Any gap seen elsewhere
            // this session, confirmed via a minimal repro to produce the exact required mangled
            // shape. A first attempt globally replaced every "Predicate<Any>" with "Predicate<A>",
            // which broke ModelContext.delete<GenericA>(...) (generic over "GenericA", not "A") --
            // fixed with a targeted per-line replacement instead of a blind global one.
            c = c.replacingOccurrences(of: "Predicate<Any>?, sortBy: [SortDescriptor<A>])", with: "Predicate<A>?, sortBy: [SortDescriptor<A>])")
            c = c.replacingOccurrences(of: "Predicate<Any>?) { fatalError() }", with: "Predicate<A>?) { fatalError() }")
            // Same Predicate<Any>-instead-of-Predicate<A> gap for ResultsObserver's
            // convenience init(filterBy:...) overloads specifically (missed by the targeted
            // replacements above, which didn't anticipate "init(filterBy:" as a distinct call
            // site) -- confirmed via the same swift-demangle evidence and repro as the other
            // Predicate<Any> fixes above.
            c = c.replacingOccurrences(of: "init(filterBy: Predicate<Any>?", with: "init(filterBy: Predicate<A>?")

            // Fix: _SectionExpression<A>'s cases render `Expression<Any, ...>` instead of
            // `Expression<A, ...>` (confirmed via swift-demangle: real ABI is
            // "Foundation.Expression<Pack{A}, Swift.String>", since Expression is declared with
            // a variadic generic `each Input` and this type passes its own generic parameter as
            // a single-element pack) -- same generic-placeholder-resolved-as-Any/Pack gap as the
            // Predicate<Any> fixes above, confirmed via a minimal repro.
            c = c.replacingOccurrences(of: "Expression<Any, Swift.String>", with: "Expression<A, Swift.String>")
            c = c.replacingOccurrences(of: "Expression<Any, Swift.String?>", with: "Expression<A, Swift.String?>")
            // The Expression<A,...> fix alone wasn't enough -- a byte-level symbol comparison
            // (nm on our fp dylib vs the required stub) showed the real enum case constructor
            // additionally mangles in a "where A: PersistentModel" constraint that
            // _SectionExpression<A>'s bare, unconstrained header doesn't carry.
            c = c.replacingOccurrences(
                of: "public enum _SectionExpression<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public enum _SectionExpression<A>: Codable, Hashable, @unchecked Sendable where A: PersistentModel {")

            // Fix: Schema.Index.Types<B>'s `binary`/`rtree` cases reference a bogus top-level
            // "A1" (the generator's auto-generated placeholder struct for an undeclared type,
            // confirmed via grep: "public struct A1: Hashable, Codable, Sendable {}" elsewhere in
            // this file) instead of Types' own generic parameter "B" -- the parser apparently
            // fell through to the undeclared-type stub path instead of binding to the enclosing
            // generic parameter. Confirmed via a minimal repro to produce the exact required
            // "enum case for ...Types.binary/rtree" symbols once corrected to "B".
            c = c.replacingOccurrences(of: "case binary(_: [PartialKeyPath<A1>])", with: "case binary(_: [PartialKeyPath<B>])")
            c = c.replacingOccurrences(of: "case rtree(_: [PartialKeyPath<A1>])", with: "case rtree(_: [PartialKeyPath<B>])")
            // Same byte-level finding as _SectionExpression above: the real enum case
            // constructor symbols additionally mangle in "where A: PersistentModel, B:
            // PersistentModel" constraints that Schema.Index<A>/Types<B>'s bare, unconstrained
            // headers don't carry.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class Index<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty {",
                with: "@_fixed_layout public class Index<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty where A: PersistentModel {")
            c = c.replacingOccurrences(
                of: "public enum Types<B>: Codable, Hashable, @unchecked Sendable {",
                with: "public enum Types<B>: Codable, Hashable, @unchecked Sendable where B: PersistentModel {")
            // Types<B>'s == also wrongly self-references "Types<Any>" instead of "Types<B>"
            // (same bogus-placeholder-Any pattern as the case payloads above) -- harmless before
            // the `where B: PersistentModel` bound was added, but now a hard compile error since
            // Any doesn't conform to PersistentModel.
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: Types<Any>, _ rhs: Types<Any>) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: Types<B>, _ rhs: Types<B>) -> Bool { fatalError() }")
            // Same fix for Schema.Unique<A> (its CodingKeys.constraints case constructor has the
            // identical missing-constraint gap).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class Unique<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty {",
                with: "@_fixed_layout public class Unique<A>: Codable, CustomDebugStringConvertible, Hashable, SchemaProperty where A: PersistentModel {")
            c = c.replacingOccurrences(of: "public var predicate: Predicate<Any>?", with: "public var predicate: Predicate<A>?")
            c = c.replacingOccurrences(of: "public final var filterBy: Predicate<Any>?", with: "public final var filterBy: Predicate<A>?")
            c = c.replacingOccurrences(
                of: "public func delete<GenericA>(model: GenericA.Type, where: Predicate<Any>?, includeSubclasses: Swift.Bool) throws -> () where GenericA: PersistentModel {}",
                with: "public func delete<GenericA>(model: GenericA.Type, where: Predicate<GenericA>?, includeSubclasses: Swift.Bool) throws -> () where GenericA: PersistentModel {}")
            // DefaultStore's HistoryProviding.historyType witness returns
            // `DefaultHistoryTransaction.Type` (a concrete metatype), but the protocol
            // requirement is typed `Any` (another generic-placeholder-path erasure — the real
            // requirement is `Self.HistoryType.Type`). A concrete-type witness can't satisfy a
            // requirement declared as bare `Any`; restore the associated-type-metatype form.
            c = c.replacingOccurrences(
                of: "static var historyType: Any { get }",
                with: "static var historyType: Self.HistoryType.Type { get }")
        return c
    }
}
