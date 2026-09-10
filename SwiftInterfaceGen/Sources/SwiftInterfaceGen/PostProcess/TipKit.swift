import Foundation

extension SwiftInterfaceGen {
    static func postProcessTipKit(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix: TipView<A> is missing its own `A: Tip` bound (confirmed via swift-demangle:
            // dropping this bound changes the generic-signature encoding of every "A == AnyTip"
            // -constrained member declared in the body, silently corrupting their mangled
            // symbols even though they otherwise compile fine). TipView<Content>'s 6
            // "Content == AnyTip"-constrained convenience inits are also entirely missing (the
            // generator only renders the unconstrained-Content overloads). Confirmed via a
            // minimal repro that restoring the `A: Tip` bound plus a member-level trailing
            // `where A == AnyTip` clause declared directly in the struct body (not a constrained
            // extension) produces exact byte-for-byte matches for all 6 required init symbols.
            c = c.replacingOccurrences(
                of: "public struct TipView<A>: SwiftUI.View {",
                with: """
                public struct TipView<A>: SwiftUI.View where A: Tip {
                    public init(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, action: @escaping (Tips.Action) -> () = { _ in }) where A == AnyTip { fatalError() }
                    public init<A1>(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, anchorID: A1, action: @escaping (Tips.Action) -> () = { _ in }) where A == AnyTip, A1: Hashable, A1: Sendable { fatalError() }
                    public init<A1>(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, anchorID: A1) where A == AnyTip, A1: Hashable, A1: Sendable { fatalError() }
                    public init<A1>(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil, anchorTo: A1.Type) where A == AnyTip, A1: TipAnchorKey { fatalError() }
                    public init(_ arg1: (any Tip)?, isPresented: SwiftUI.Binding<Swift.Bool>? = nil, arrowEdge: SwiftUI.Edge? = nil) where A == AnyTip { fatalError() }
                    public init(_ arg1: (any Tip)?, arrowEdge: SwiftUI.Edge? = nil, action: @escaping (Tips.Action) -> () = { _ in }) where A == AnyTip { fatalError() }
                """)

            // Fix: DonatedWithin/DonationFilter/LargestSubset/SmallestSubset (all nested in
            // `extension PredicateExpressions`) render as completely non-generic structs with a
            // bogus `typealias A = Any` -- same generic-arity-discovery-failure pattern as
            // CryptoKit's HKDF fixed earlier this session, since no ABI symbol ever applies a
            // generic argument directly to any of these types outside their own members. Made
            // them properly generic (2 params for DonatedWithin, 3 for the other three) with the
            // real bounds, and added the entirely-missing build_donatedWithin/build_DonationFilter/
            // build_largestSubset/build_smallestSubset static factory functions. Confirmed via a
            // minimal repro to produce exact byte-for-byte matches for all 4 struct/evaluate/
            // conformance-descriptor triples and all 4 build_* functions (their generic
            // conformance witness tables remain unfixable, same established pattern as elsewhere).
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct DonatedWithin: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct DonatedWithin<A, B>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, B.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_donatedWithin<A, B>(_ arg1: B, _ arg2: Tips.DonationTimeRange) -> DonatedWithin<A, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct DonationFilter: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct DonationFilter<A, B, C>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Decodable, B: Encodable, B: Sendable, C: Sendable, C: EventPredicateExpression, C.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_DonationFilter<A, B, C>(_ arg1: B, keyPath: Swift.KeyPath<A, C>, op: PredicateExpressions.DonationFilterOperator, value: C) -> DonationFilter<A, C, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, C: Decodable, C: Encodable, C: Sendable, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct LargestSubset: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct LargestSubset<A, B, C>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Decodable, B: Encodable, B: Hashable, B: Sendable, C: Sendable, C: EventPredicateExpression, C.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_largestSubset<A, B, C>(_ arg1: B, groupedBy: Swift.KeyPath<A, C>) -> LargestSubset<A, C, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, C: Decodable, C: Encodable, C: Hashable, C: Sendable, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)
            c = c.replacingOccurrences(
                of: """
                extension PredicateExpressions {
                    public struct SmallestSubset: EventPredicateExpression, PredicateExpression {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<Any>.Donation] { return [] }
                        public typealias A = Any
                    }
                }
                """,
                with: """
                extension PredicateExpressions {
                    public struct SmallestSubset<A, B, C>: EventPredicateExpression, Sendable where A: Decodable, A: Encodable, A: Sendable, B: Decodable, B: Encodable, B: Hashable, B: Sendable, C: Sendable, C: EventPredicateExpression, C.Output == [Tips.Event<A>.Donation] {
                        public func evaluate(_ arg1: PredicateBindings) throws -> [Tips.Event<A>.Donation] { return [] }
                    }
                    public static func build_smallestSubset<A, B, C>(_ arg1: B, groupedBy: Swift.KeyPath<A, C>) -> SmallestSubset<A, C, B> where A: Decodable, A: Encodable, A: Sendable, B: Sendable, B: EventPredicateExpression, C: Decodable, C: Encodable, C: Hashable, C: Sendable, B.Output == [Tips.Event<A>.Donation] { fatalError() }
                }
                """)

            // Fix: Swift.Sequence's donatedWithin/largestSubset/smallestSubset extension methods
            // are entirely missing. Confirmed via a minimal repro to produce exact byte-for-byte
            // matches for all 3 required symbols.
            c += """


            extension Sequence {
                public func donatedWithin<A>(_ arg1: Tips.DonationTimeRange) -> [Self.Element] where A: Decodable, A: Encodable, A: Sendable, Self.Element == Tips.Event<A>.Donation { fatalError() }
                public func largestSubset<A, B>(groupedBy: Swift.KeyPath<A, B>) -> [Self.Element] where A: Decodable, A: Encodable, A: Sendable, B: Hashable, Self.Element == Tips.Event<A>.Donation { fatalError() }
                public func smallestSubset<A, B>(groupedBy: Swift.KeyPath<A, B>) -> [Self.Element] where A: Decodable, A: Encodable, A: Sendable, B: Hashable, Self.Element == Tips.Event<A>.Donation { fatalError() }
            }
            """

            // Fix: EventPredicateExpression's associated type renders as a bare, unnamed
            // `associatedtype A` instead of the real primary associated type `Output` (confirmed
            // via swift-demangle: "any TipKit.EventPredicateExpression<...Output == Swift.Bool>"
            // requires the protocol to declare `<Output>` as a primary associated type).
            c = c.replacingOccurrences(
                of: "public protocol EventPredicateExpression: Foundation.PredicateExpression {\n    associatedtype A\n}",
                with: "public protocol EventPredicateExpression<Output>: Foundation.PredicateExpression {\n}")

            // Fix: Tips.Rule's 2 inits use unconstrained existentials ("any StandardPredicateExpression",
            // "any EventPredicateExpression") instead of the required `<Bool>`-constrained ones
            // (both protocols declare a primary associated type `Output`, and the real ABI
            // constrains it to Swift.Bool). Confirmed via a minimal repro to produce exact
            // byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public init<A>(_ arg1: Tips.Parameter<A>, _ arg2: (PredicateExpressions.Variable<A>) -> any StandardPredicateExpression) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }",
                with: "public init<A>(_ arg1: Tips.Parameter<A>, _ arg2: (PredicateExpressions.Variable<A>) -> any StandardPredicateExpression<Swift.Bool>) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(_ arg1: Tips.Event<A>, _ arg2: (PredicateExpressions.Variable<Tips.Event<A>>) -> any EventPredicateExpression) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }",
                with: "public init<A>(_ arg1: Tips.Event<A>, _ arg2: (PredicateExpressions.Variable<Tips.Event<A>>) -> any EventPredicateExpression<Swift.Bool>) where A: Decodable,  A: Encodable,  A: Sendable { fatalError() }")

            // Fix: Tips.Event<A> is missing its own bound (A: Decodable, A: Encodable, A: Sendable)
            // and the Sendable conformance -- confirmed via swift-demangle: dropping these
            // silently corrupts the mangled signature of every "A == EmptyDonation"-constrained
            // member declared in the body, same pattern as TipView<A>'s missing `A: Tip` bound
            // above. Confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public struct Event<A>: Identifiable, Tips.RuleInput {",
                with: "public struct Event<A>: Identifiable, Tips.RuleInput, Sendable where A: Decodable, A: Encodable, A: Sendable {")
        return c
    }
}
