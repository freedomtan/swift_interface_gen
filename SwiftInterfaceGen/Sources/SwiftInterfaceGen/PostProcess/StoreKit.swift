import Foundation

extension SwiftInterfaceGen {
    static func postProcessStoreKit(_ code: String, parser: Parser) -> String {
        var c = code

            // Fix: Storefront._locale's real ABI additionally needs a "read" coroutine accessor
            // (confirmed via swift-demangle: "Storefront._locale.read"), alongside the getter the
            // generator already renders correctly. A plain `get` never produces one -- a minimal
            // repro showed only an explicit `_read { ... }` accessor body (the underscored,
            // library-internal coroutine-accessor syntax) makes the compiler synthesize both the
            // getter thunk AND the read accessor from a single declaration.
            c = c.replacingOccurrences(
                of: "public var _locale: Locale { get { fatalError() } }",
                with: "public var _locale: Locale { _read { fatalError() } }")

            // Fix: StoreProductManager.{CollectionObserver,SingleObserver,SubscriptionGroupObserver}
            // manually fake a "_proj_X" placeholder property for the real "$state"/"$error"/
            // "$storage" property-wrapper projections instead of using @Published (whose
            // projectedValue is compiler-synthesized and can't be spelled directly -- "$state" is
            // not a legal manually-declared identifier). Real ABI for each "$foo" has ONLY a
            // getter + property descriptor, no setter/modify, which a plain `@Published var` also
            // doesn't produce (that gives get+set+modify for both the property and its
            // projection) -- `private(set)` on the @Published property is what narrows it down to
            // match (confirmed via a minimal repro).
            // Each "_proj_X"/real-property pair is removed/rewritten as two INDEPENDENT
            // replacements, not one combined adjacent-lines match -- CollectionObserver declares
            // both "_proj_error" and "_proj_storage" back-to-back BEFORE either real property
            // (not interleaved pairwise), so a match requiring the two lines to be adjacent only
            // happened to work for SingleObserver/SubscriptionGroupObserver (which each have only
            // one such property).
            c = c.replacingOccurrences(
                of: "public final var _proj_storage: Published<[StoreProductManager.CollectionObserver.Storage]>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var storage: [StoreProductManager.CollectionObserver.Storage] { get { return [] } }",
                with: "@Published public final private(set) var storage: [StoreProductManager.CollectionObserver.Storage] = []")
            c = c.replacingOccurrences(
                of: "public final var _proj_error: Published<Error?>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var error: Error? { get { return nil } }",
                with: "@Published public final private(set) var error: Error? = nil")
            c = c.replacingOccurrences(
                of: "public final var _proj_state: Published<SingleObserver.Storage>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var state: SingleObserver.Storage { get { fatalError() } }",
                with: "@Published public final private(set) var state: SingleObserver.Storage = .loading")
            c = c.replacingOccurrences(
                of: "public final var _proj_state: Published<SubscriptionGroupObserver.Storage>.Publisher { get { fatalError() } }\n",
                with: "")
            c = c.replacingOccurrences(
                of: "public final var state: SubscriptionGroupObserver.Storage { get { fatalError() } }",
                with: "@Published public final private(set) var state: SubscriptionGroupObserver.Storage = .loading")

            // Fix: VerificationResult<A>'s real ABI conditionally conforms to Hashable/Equatable
            // (confirmed via swift-demangle: separate "<A where A: Swift.Hashable> ... :
            // Swift.Hashable" and "<A where A: Swift.Equatable> ... : Swift.Equatable" conformance
            // descriptors), but the generator declares Hashable unconditionally on the enum's own
            // header, and the existing "where A: Equatable" extension never restates the
            // conformance at all -- same conformance-restatement gap fixed elsewhere this session,
            // plus needing to move Hashable off the base declaration entirely (confirmed via a
            // minimal repro: an unconditional base Hashable conformance produces a different,
            // unconstrained conformance-descriptor shape even when a conditional Equatable
            // extension coexists).
            c = c.replacingOccurrences(
                of: "public enum VerificationResult<A>: Hashable, @unchecked Sendable {",
                with: "public enum VerificationResult<A>: @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "extension VerificationResult where A: CustomDebugStringConvertible {",
                with: "extension VerificationResult: CustomDebugStringConvertible where A: CustomDebugStringConvertible {")
            c = c.replacingOccurrences(
                of: "extension VerificationResult where A: Equatable {\n    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }\n}",
                with: "extension VerificationResult: Equatable where A: Equatable {\n    public static func == (lhs: Self, rhs: Self) -> Swift.Bool { true }\n}\nextension VerificationResult: Hashable where A: Hashable {\n    public func hash(into hasher: inout Hasher) { }\n    public var hashValue: Int { 0 }\n}")

            // Fix: several real ABI members are entirely missing from the generator's output
            // (confirmed via swift-demangle, each verified via a minimal repro to produce an
            // exact match).
            c += """

extension Foundation.DateComponents {
    public init(subscriptionPeriod: Product.SubscriptionPeriod) { self.init() }
}
extension Foundation.Data {
    public init?(_ arg1: BackingValue) { nil }
}
extension Foundation.Date {
    public init?(_ arg1: BackingValue) { nil }
}
extension Foundation.UUID {
    public init?(_ arg1: BackingValue) { nil }
}
extension Foundation.Locale.Currency {
    public init?(_ arg1: BackingValue) { nil }
}
extension Swift.BinaryFloatingPoint {
    public init?(_ arg1: BackingValue) { nil }
}
extension Swift.BinaryInteger {
    public init?(_ arg1: BackingValue) { nil }
}

"""
            // Fix: BackingValue.value(atKeyPath:sentinel:transform:)'s `sentinel` param renders
            // with an added `@escaping` -- but the real ABI (confirmed via swift-demangle) has no
            // ownership/escaping marker on it at all, matching the "erroneously-added @escaping"
            // gap already fixed for MetalPerformanceShadersGraph's reorderInputsAndOutputs.
            c = c.replacingOccurrences(
                of: "sentinel: @escaping @autoclosure () -> GenericA",
                with: "sentinel: @autoclosure () -> GenericA")

            // Fix: many properties across StoreKit render as plain synchronous computed
            // properties, but their real ABI needs "async function pointer" symbols -- same
            // "{ get async }" gap already fixed for Translation/Vision/Speech (confirmed via a
            // minimal repro that only a `{ get async }` accessor produces those). All occurrence
            // counts verified via grep -c to match the stub list's entry count exactly before
            // blanket-replacing.
            for (from, to) in [
                ("public var latestTransaction: VerificationResult<Transaction>? { get { return nil } }",
                 "public var latestTransaction: VerificationResult<Transaction>? { get async { return nil } }"),
                ("public static var _accountType: AppStore.AccountType { get { fatalError() } }",
                 "public static var _accountType: AppStore.AccountType { get async { fatalError() } }"),
                ("public static var canMakePaymentsAsync: Swift.Bool { get { fatalError() } }",
                 "public static var canMakePaymentsAsync: Swift.Bool { get async { fatalError() } }"),
                ("public static var ageRatingCode: Swift.Int? { get { return nil } }",
                 "public static var ageRatingCode: Swift.Int? { get async { return nil } }"),
                ("public static var canMakePaymentsAsyncUsableFromInline: Swift.Bool { get { fatalError() } }",
                 "public static var canMakePaymentsAsyncUsableFromInline: Swift.Bool { get async { fatalError() } }"),
                ("public static var shared: VerificationResult<AppTransaction> { get { fatalError() } }",
                 "public static var shared: VerificationResult<AppTransaction> { get async { fatalError() } }"),
                ("public static var canOpen: Swift.Bool { get { fatalError() } }",
                 "public static var canOpen: Swift.Bool { get async { fatalError() } }"),
                ("public static var canPresent: Swift.Bool { get { fatalError() } }",
                 "public static var canPresent: Swift.Bool { get async { fatalError() } }"),
                ("public static var isEligible: Swift.Bool { get { fatalError() } }",
                 "public static var isEligible: Swift.Bool { get async { fatalError() } }"),
                ("public static var eligibleURLs: [URL]? { get { return nil } }",
                 "public static var eligibleURLs: [URL]? { get async { return nil } }"),
                ("public static var isAvailable: Swift.Bool { get { fatalError() } }",
                 "public static var isAvailable: Swift.Bool { get async { fatalError() } }"),
                ("public var currentEntitlement: VerificationResult<Transaction>? { get { return nil } }",
                 "public var currentEntitlement: VerificationResult<Transaction>? { get async { return nil } }"),
                ("public static var currentOrder: [Product.PromotionInfo] { get { return [] } }",
                 "public static var currentOrder: [Product.PromotionInfo] { get async { return [] } }"),
                ("public var contingentPrices: [Product.ContingentPriceInfo] { get { return [] } }",
                 "public var contingentPrices: [Product.ContingentPriceInfo] { get async { return [] } }"),
                ("public var isEligibleForIntroOffer: Swift.Bool { get { fatalError() } }",
                 "public var isEligibleForIntroOffer: Swift.Bool { get async { fatalError() } }"),
                ("public var status: [Product.SubscriptionInfo.Status] { get { return [] } }",
                 "public var status: [Product.SubscriptionInfo.Status] { get async { return [] } }"),
                ("public static var current: Storefront? { get { return nil } }",
                 "public static var current: Storefront? { get async { return nil } }"),
                ("public var subscriptionStatus: Product.SubscriptionInfo.Status? { get { return nil } }",
                 "public var subscriptionStatus: Product.SubscriptionInfo.Status? { get async { return nil } }"),
            ] {
                c = c.replacingOccurrences(of: from, with: to)
            }

            // Fix: Message.acknowledge(bundleID:message:offer:overrideAuditToken:logKey:) and
            // Product.PurchaseOption.clientOverride(auditToken:) are real ABI (confirmed via
            // swift-demangle) but never rendered at all; both take/pass a real `audit_token_t`
            // (from Darwin, confirmed resolvable via a minimal repro) not otherwise imported here.
            c = c.replacingOccurrences(
                of: "public struct Message: Hashable {",
                with: "public struct Message: Hashable {\n    public static func acknowledge(bundleID: Swift.String?, message: Message.Reason, offer: Product.SubscriptionOffer, overrideAuditToken: audit_token_t?, logKey: Swift.String) async {}")
            // Product's own PurchaseOption is a distinct nested type from the other
            // (identically-textually-headed) PurchaseOption elsewhere in this file -- anchor on
            // Product's own unique header via a lazy multiline span, same technique as
            // MetricKit's baseUnit fix.
            if let regex = try? NSRegularExpression(
                pattern: "(public struct Product: CustomDebugStringConvertible, Hashable, Identifiable \\{[\\s\\S]*?public struct PurchaseOption: CustomDebugStringConvertible, Hashable \\{\\n)",
                options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "$1        public static func clientOverride(auditToken: audit_token_t) -> PurchaseOption { fatalError() }\n")
            }
            c = c.replacingOccurrences(
                of: "import Foundation",
                with: "import Darwin\nimport Foundation")
        return c
    }
}
