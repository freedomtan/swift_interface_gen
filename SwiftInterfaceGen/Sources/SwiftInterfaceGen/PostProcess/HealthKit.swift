import Foundation

extension SwiftInterfaceGen {
    static func postProcessHealthKitPart1(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix: the demangler renders a metatype-of-composition ("(NSObject &
            // HKDataCacheProviding).Type") as "NSObject & HKDataCacheProviding.Type", which
            // parses as "NSObject & (HKDataCacheProviding.Type)" — invalid, since a protocol
            // composition member can't itself be a metatype. Add the missing parens.
            c = c.replacingOccurrences(
                of: "NSObject & HKDataCacheProviding.Type",
                with: "(NSObject & HKDataCacheProviding).Type")

            // Fix: dozens of HK* types are real ObjC classes, but -- like MLMultiArray/
            // SHSignature in SoundAnalysis earlier this session -- they're only ever referenced
            // as real get/param types, never extended, so isObjcBridged discovery never finds
            // them. Parser.swift's fallback for an undiscovered "__C" type then generates a
            // local native-struct shadow (`public struct __C_HKCategoryType {}` + `public
            // typealias HKCategoryType = __C_HKCategoryType`), which mangles under the HealthKit
            // module instead of `__C`, so every accessor/init referencing it permanently
            // mismatches. Every name below is ALREADY forward-declared as a real `@interface` in
            // the bridge header (found via the standard bridgedTypes discovery path through some
            // other, related symbol) -- so removing just the Swift-side shadow struct/typealias
            // pair is enough for the real bridged declaration to take over (confirmed first for
            // HKCategoryType/HKQuantityType; this generalizes that fix to every other HK* name
            // with the identical shadow-vs-already-bridged shape).
            for name in ["HKCategoryType", "HKQuantityType", "HKActivitySummary", "HKAttachment",
                         "HKAttachmentStore", "HKAudiogramSample",
                         "HKBloodPressureClassificationCategoryData",
                         "HKBloodPressureClassificationEvaluator",
                         "HKBloodPressureClassificationManager", "HKCalendarCache",
                         "HKCategorySample", "HKCharacteristicType", "HKClinicalRecord",
                         "HKClinicalType", "HKCloudSyncManagerRecordTaskRecord", "HKCorrelation",
                         "HKCorrelationType",
                         "HKCyclingPowerZonesConfigurationWrapper",
                         "HKDatabaseAccessibilityAssertion", "HKDocumentType",
                         "HKElectrocardiogram", "HKElectrocardiogramQuery",
                         "HKElectrocardiogramVoltageMeasurement", "HKGAD7Assessment",
                         "HKHealthRecordsStore", "HKHealthStore", "HKHeartbeatSeriesSample",
                         "HKHeartRateSummaryStatistics", "HKHeartRateSummaryStatisticsBucket",
                         "HKKeyValueDomain", "HKLiveWorkoutBuilder", "HKLiveWorkoutZoneUpdate",
                         "HKMCPregnancyDatesFactory", "HKMCPregnancyModel", "HKMedicationDoseEvent",
                         "HKObject", "HKObjectType", "HKPauseRingsSchedule", "HKPHQ9Assessment",
                         "HKQuantity", "HKQuantityDatum", "HKQuantityRange", "HKQuantitySample",
                         "HKQuery", "HKQueryAnchor", "HKQueryDescriptor",
                         "HKQueryServerConfiguration", "HKRollingBaselineConfiguration", "HKSample",
                         "HKSampleType", "HKSampleTypeChange", "HKScoredAssessmentType",
                         "HKSleepDaySummary", "HKSleepDaySummaryCollection",
                         "HKSleepDaySummaryCollectionQuery", "HKSleepDaySummaryQuery",
                         "HKSleepSchedule", "HKSource", "HKStateOfMind", "HKStatistics",
                         "HKStatisticsCollection", "HKUnit", "HKUserAnnotatedMedication",
                         "HKVerifiableClinicalRecord", "HKVisionPrescription", "HKWorkout",
                         "HKWorkoutActivity", "HKWorkoutActivityNodeWrapper", "HKWorkoutBuilder",
                         "HKWorkoutConfiguration", "HKWorkoutRoute",
                         "HKWorkoutZoneConfigurationWrapper", "HKWorkoutZoneDurationWrapper",
                         "HKWorkoutZoneGroupWrapper",
                         "HKWorkoutZoneHeartRateConfigurationSettingsWrapper",
                         "HKWorkoutZoneWrapper", "HKDatabaseAssertionContextType", "HKDayIndexRange",
                         "HKSleepDaySummaryQueryOptions", "HKStatisticsOptions",
                         "HKWorkoutEffortRelationshipQueryOptions", "HKCategoryValueSleepAnalysis",
                         "NSLocale", "_HKQuantityDistributionStyle",
                         "_HKQuantityDistributionOptions", "_HKQuantityDistributionData",
                         "CLLocation"] {
                c = c.replacingOccurrences(
                    of: "public struct __C_\(name): Hashable, Codable, Sendable {}\npublic typealias \(name) = __C_\(name)\n",
                    with: "")
            }

            // HKCurrentActivityCacheQueryResult was left as a native shadow struct in an earlier
            // commit this session because removing it broke
            // HKCurrentActivityCacheQueryDescriptor.results(for:)'s
            // `AsyncStream<HKCurrentActivityCacheQueryResult>` (the shadow struct's incidental
            // Sendable conformance was the only thing making that compile, since the real bridged
            // ObjC class isn't Sendable) -- but keeping the shadow meant `result(for:)` and its
            // async function pointer permanently mismatch the real ABI (confirmed via
            // swift-demangle: `HKCurrentActivityCacheQueryDescriptor.result(for:)` mangles its
            // return type as `__C.HKCurrentActivityCacheQueryResult?`, not the HealthKit-module
            // shadow). Remove the shadow and explicitly mark the real bridged class
            // `@unchecked Sendable` instead, which is what results(for:) actually needs.
            c = c.replacingOccurrences(
                of: "public struct __C_HKCurrentActivityCacheQueryResult: Hashable, Codable, Sendable {}\npublic typealias HKCurrentActivityCacheQueryResult = __C_HKCurrentActivityCacheQueryResult\n",
                with: "extension HKCurrentActivityCacheQueryResult: @unchecked Sendable {}\n")

            // SleepSessionQuery.Descriptor's result(for:) extension is missing a conditional
            // constraint (confirmed via swift-demangle: the real ABI mangles the extension as
            // `SleepSessionQuery.Descriptor< where A == A1>`, i.e. conditioned on the enclosing
            // SleepSessionQuery<A>'s own model type equaling Descriptor<B>'s -- `where A == B`).
            c = c.replacingOccurrences(
                of: "extension SleepSessionQuery.Descriptor {\n    public func result(for: HKHealthStore) async throws -> [A] { return [] }\n}",
                with: "extension SleepSessionQuery.Descriptor where A == B {\n    public func result(for: HKHealthStore) async throws -> [A] { return [] }\n}")

            // Configuration.SampleSubtype's sampleConfiguration and its default-implementation
            // extension render generic parameters as bare `Any` where the real ABI ties them to
            // WithPredicate's PredicatedModelKind associated type (confirmed via swift-demangle:
            // `Configuration.SampleSubtype.sampleConfiguration.getter :
            // HealthKit.SampleBaseConfiguration<A.PredicatedModelKind>`). (SampleBase's own
            // sortDescriptors requirement has the same bug, fixed in place below where it's
            // otherwise handled, to avoid two conflicting fixes racing on the same line -- see
            // the note there.)
            c = c.replacingOccurrences(
                of: "var sampleConfiguration: SampleBaseConfiguration<Any> { get set }",
                with: "var sampleConfiguration: SampleBaseConfiguration<Self.PredicatedModelKind> { get set }")
            if let declRange = c.range(of: "extension Configuration.SampleSubtype {") {
                var depth = 1
                var idx = declRange.upperBound
                while depth > 0 && idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 } else if c[idx] == "}" { depth -= 1 }
                    idx = c.index(after: idx)
                }
                let bodyRange = declRange.lowerBound..<idx
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(of: "<Any>", with: "<Self.PredicatedModelKind>")
                c.replaceSubrange(bodyRange, with: body)
            }

            // NSQualityOfService is another instance of the same "__C" shadow-type fallback
            // (HKQueryAttributes.qualityOfService), but unlike the others, Swift's API notes
            // rename the ObjC enum to bare `QualityOfService` for Swift source -- referencing it
            // as `NSQualityOfService` in Swift source is a hard error ("has been renamed to
            // 'QualityOfService'"), even though the ABI still mangles it as `__C.NSQualityOfService`
            // (confirmed via swift-demangle) since that's the real ObjC symbol name. Rename all
            // uses to the Swift-facing name, then drop the (now similarly-renamed) shadow.
            c = c.replacingOccurrences(of: "NSQualityOfService", with: "QualityOfService")
            // NSPredicateOperatorType is renamed to NSComparisonPredicate.Operator in Swift
            // (obsoleted in Swift 3), same rename-vs-ABI-name split as NSQualityOfService/OSLog
            // earlier this session -- the ABI still mangles under the original ObjC name. Remove
            // the shadow BEFORE renaming remaining uses, since the shadow's own typealias line
            // would otherwise be corrupted into invalid dotted-name syntax by the blanket rename.
            c = c.replacingOccurrences(
                of: "public struct __C_NSPredicateOperatorType: Hashable, Codable, Sendable {}\npublic typealias NSPredicateOperatorType = __C_NSPredicateOperatorType\n",
                with: "")
            c = c.replacingOccurrences(of: "NSPredicateOperatorType", with: "NSComparisonPredicate.Operator")
            c = c.replacingOccurrences(
                of: "public struct __C_QualityOfService: Hashable, Codable, Sendable {}\npublic typealias QualityOfService = __C_QualityOfService\n",
                with: "")

            // HKWorkoutMetric.init(coder:) is NOT failable in the real ABI (confirmed via
            // swift-demangle -expand: return type is the plain HKWorkoutMetric class, not
            // Optional<HKWorkoutMetric>) -- unlike the generic NSCoding boilerplate's
            // `init?(coder:)` that every other NSObject/NSCoding class in this file correctly
            // uses. Fix just this one class.
            if let regex = try? NSRegularExpression(
                pattern: "public required init\\?\\(coder: NSCoder\\) \\{\\}\\n\\}\\n+@_fixed_layout public class HKWorkoutMetricsDataSource", options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "public required init(coder: NSCoder) { fatalError() }\n}\n@_fixed_layout public class HKWorkoutMetricsDataSource")
            }

            // CodableBox<A>/CodableBoxArray<A>/CodableBoxDictionary<A, B> each conditionally
            // conform to Equatable/Hashable (confirmed via their real conformance descriptors),
            // but the generator only emits the bare default-implementation extension without
            // restating "X: Equatable"/"X: Hashable" as the actual conformance -- same gap as
            // the Charts result-builder types fixed in prior commits.
            for (type, param) in [("CodableBox", "A"), ("CodableBoxArray", "A"), ("CodableBoxDictionary", "B"), ("OptionalCodableBox", "A")] {
                c = c.replacingOccurrences(
                    of: "extension \(type) where \(param): Equatable {",
                    with: "extension \(type): Equatable where \(param): Equatable {")
                c = c.replacingOccurrences(
                    of: "extension \(type) where \(param): Hashable {",
                    with: "extension \(type): Hashable where \(param): Hashable {")
            }
            // These box types generically wrap a Codable payload -- the boxed type parameter
            // itself is Codable-constrained on the real struct declaration, not just where the
            // generic-conditional Equatable/Hashable extensions apply. Missing that struct-level
            // bound changes the mangled generic signature of every member (confirmed via a
            // minimal repro: "<A>" vs "<A: Codable>" mangles CodableBox's Hashable extension's
            // hash(into:) as ...SHRzlE... vs the real ABI's ...SHRzrlE...), so every member
            // stayed a stub even once the extension's own conformance/header matched.
            c = c.replacingOccurrences(of: "public struct CodableBox<A>: Codable, DefaultEncodable {", with: "public struct CodableBox<A: Codable>: Codable, DefaultEncodable {")
            c = c.replacingOccurrences(of: "public struct CodableBoxArray<A>: Codable, DefaultEncodable {", with: "public struct CodableBoxArray<A: Codable>: Codable, DefaultEncodable {")
            c = c.replacingOccurrences(of: "public struct CodableBoxDictionary<A: Hashable, B>: Codable, DefaultEncodable {", with: "public struct CodableBoxDictionary<A: Hashable, B: Codable>: Codable, DefaultEncodable {")
            c = c.replacingOccurrences(of: "public struct OptionalCodableBox<A>: Codable {", with: "public struct OptionalCodableBox<A: Codable>: Codable {")
            // Fix: BirthDateType/CategoryType/QuantityType/ScoredAssessmentType<A> conform to
            // SampleType (-> BasicObservableHealthType -> ObservableHealthType, ListHealthType),
            // whose observe(configuration:)/query(configuration:) requirements need
            // ObservationConfigurationKind/ListConfigurationKind: Decodable, and (per SampleType's
            // own associated-conformance requirement) ListConfigurationKind: Configuration.SampleBase
            // specifically. The demangler has no per-type ABI witness for what these associated
            // types actually resolve to (query/observe are satisfied via a default protocol-
            // extension implementation, not a per-conformance witness), so Model.swift emits the
            // bare placeholder `Any` for both — which isn't Decodable, so the compiler can't infer
            // the associated types and conformance fails. Retype to the concrete
            // SampleBaseConfiguration<Self>, the one real type in this module that conforms to
            // Configuration.SampleBase. Scoped per-struct (via struct-declaration boundaries)
            // since the placeholder text is identical across all four conforming structs.
            for (declPrefix, selfType) in [
                ("public struct BirthDateType:", "BirthDateType"),
                ("public struct CategoryType:", "CategoryType"),
                ("public struct QuantityType:", "QuantityType"),
                ("public struct ScoredAssessmentType<A>:", "ScoredAssessmentType<A>"),
            ] {
                guard let declRange = c.range(of: declPrefix) else { continue }
                guard let braceStart = c.range(of: "{", range: declRange.upperBound..<c.endIndex) else { continue }
                var depth = 1
                var idx = braceStart.upperBound
                var braceEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { braceEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                let bodyRange = braceStart.upperBound..<braceEnd
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(
                    of: "public func observe(configuration: Any) -> ObservationDescriptor<Any> { fatalError() }",
                    with: "public func observe(configuration: SampleBaseConfiguration<\(selfType)>) -> ObservationDescriptor<SampleBaseConfiguration<\(selfType)>> { fatalError() }\n    public typealias ObservationConfigurationKind = SampleBaseConfiguration<\(selfType)>")
                body = body.replacingOccurrences(
                    of: "public func query(configuration: Any) -> ListQueryDescriptor<Any, Any> { fatalError() }",
                    with: "public func query(configuration: SampleBaseConfiguration<\(selfType)>) -> ListQueryDescriptor<SampleBaseConfiguration<\(selfType)>, \(selfType)> { fatalError() }\n    public typealias ListConfigurationKind = SampleBaseConfiguration<\(selfType)>\n    public typealias ModelKind = \(selfType)")
                c.replaceSubrange(bodyRange, with: body)
            }

            // Fix: Configuration.WithPredicate.filter/Configuration.SampleBase's predicate and
            // sortDescriptors properties demangle with the bare placeholder "Any" instead of
            // "Self.PredicatedModelKind" (WithPredicate's own associated type) — unlike
            // Configuration.WithSortDescriptor's `sort(_:) -> SortDescriptor<Self.SortedModelKind>`,
            // which the generator DOES resolve correctly. Concrete conformers like
            // SampleBaseConfiguration<A> declare predicate/sortDescriptors typed by their own
            // generic parameter A, not Any, so the "Any" in the protocol requirement never
            // matches and PredicatedModelKind/SampleKind can't be inferred.
            if let declRange = c.range(of: "public protocol WithPredicate: Sendable {"),
               let braceEnd = c.range(of: "\n    }", range: declRange.upperBound..<c.endIndex) {
                let bodyRange = declRange.upperBound..<braceEnd.lowerBound
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(of: "func filter(_ arg1: Predicate<Any>) -> Self", with: "func filter(_ arg1: Predicate<Self.PredicatedModelKind>) -> Self")
                c.replaceSubrange(bodyRange, with: body)
            }
            // Member order inside the generated protocol body isn't stable across runs (varies
            // by internal dictionary iteration order), so patch each member line independently,
            // scoped to inside SampleBase's own declaration body rather than matching the whole
            // block verbatim.
            if let declRange = c.range(of: "public protocol SampleBase: Configuration.WithLimit, Configuration.WithPredicate, Configuration.WithSortDescriptor, Sendable {"),
               let braceEnd = c.range(of: "\n    }", range: declRange.upperBound..<c.endIndex) {
                let bodyRange = declRange.upperBound..<braceEnd.lowerBound
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(of: "var predicate: Predicate<Any>? { get }", with: "var predicate: Predicate<Self.PredicatedModelKind>? { get }")
                // NOTE: sortDescriptors is keyed by PredicatedModelKind, not SortedModelKind,
                // despite the name -- confirmed via swift-demangle:
                // `Configuration.SampleBase.sortDescriptors.getter :
                // [Foundation.SortDescriptor<A.PredicatedModelKind>]`.
                body = body.replacingOccurrences(of: "var sortDescriptors: [SortDescriptor<Any>] { get }", with: "var sortDescriptors: [SortDescriptor<Self.PredicatedModelKind>] { get }")
                c.replaceSubrange(bodyRange, with: body)
            }
            // Fix: ListQueryDescriptor<A, B>/ObservationDescriptor<A> conform to QueryDescriptor,
            // which requires `associatedtype ConfigurationKind: Decodable` satisfied via their
            // own `configuration: A`/`B` property — but the demangler exposes no generic-constraint
            // info for these structs' own declaration (no swiftinterface/header covers this
            // private SPI type), so A/B come through unconstrained and can't satisfy
            // ConfigurationKind: Decodable. Every real construction path for both types is only
            // ever reachable through ListHealthType/ObservableHealthType, whose own
            // ListConfigurationKind/ObservationConfigurationKind associated types ARE constrained
            // to Decodable — so constraining A (and ListQueryDescriptor's A specifically, the
            // configuration type) to Decodable here reflects the real usage without narrowing it
            // incorrectly.
            // QueryDescriptor also requires `associatedtype ModelKind` (unconstrained, no
            // Decodable bound) — ListQueryDescriptor's second generic param B fills that role
            // (matches ListHealthType.query's real return type
            // ListQueryDescriptor<Self.ListConfigurationKind, Self.ModelKind>); ObservationDescriptor
            // has no second param for it at all (ObservableHealthType.observe() never threads a
            // ModelKind through), so pin it to Never — an uninhabited type is a safe placeholder
            // since ObservationDescriptor's real construction path never produces a ModelKind value.
            // Fix: the SleepSessionResultProviding/SleepSessionComparisonProviding/
            // SleepSessionQueryProviding family requires RangeType/ConfigurationType/
            // ComparisonType/ResultType associated types, none of which have a discoverable
            // real-type mapping in the ABI (query/observe-style requirements satisfied via
            // default protocol-extension implementations, not per-conformance witnesses — same
            // root cause as the QueryDescriptor gaps above). Each conformer DOES have a real
            // nested `QueryConfiguration` struct that already conforms to
            // SleepSessionConfigurationProviding (found via the ABI's own protocol conformance
            // descriptors), so ConfigurationType is real; ComparisonType/ResultType map onto
            // the sibling Comparison/base types in the same family, which also have discoverable
            // real conformances. RangeType alone has no real conforming type anywhere in the ABI
            // (nothing implements SleepSessionRangeProviding's `split(_:) -> [Self]`) — use one
            // shared synthetic stub for it everywhere.
            c += "\npublic struct SleepSessionRangeStub: SleepSessionRangeProviding, Codable, Hashable, @unchecked Sendable {\n"
            c += "    public func split(_ arg1: Swift.Int) -> [SleepSessionRangeStub] { fatalError() }\n"
            c += "    public init(from decoder: Swift.Decoder) throws { fatalError() }\n"
            c += "    public func encode(to encoder: Swift.Encoder) throws {}\n"
            c += "}\n"
            for (declPrefix, typealiases) in [
                ("public struct SleepDaySummary:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryComparison"]),
                ("public struct SleepDaySummaryCollection:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryCollectionComparison"]),
                ("public struct SleepDaySummaryComparison:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryComparison", "ResultType = SleepDaySummary"]),
                ("public struct SleepDaySummaryCollectionComparison:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepDaySummaryCollectionComparison", "ResultType = SleepDaySummaryCollection"]),
                ("public struct SleepSession:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepSessionComparison"]),
                ("public struct SleepSessionComparison:", ["RangeType = SleepSessionRangeStub", "ConfigurationType = QueryConfiguration", "ComparisonType = SleepSessionComparison", "ResultType = SleepSession"]),
            ] {
                guard let declRange = c.range(of: declPrefix) else { continue }
                guard let braceStart = c.range(of: "{", range: declRange.upperBound..<c.endIndex) else { continue }
                let insertion = typealiases.map { "    public typealias \($0)\n" }.joined()
                c.insert(contentsOf: "\n" + insertion, at: braceStart.upperBound)
            }
            // Fix: SleepSessionQuery<A> conforms to SleepSessionQueryProviding, whose
            // `associatedtype ResultType: SleepSessionResultProviding` is satisfied by A itself
            // (SleepSessionQuery's own resultsHandler produces [A] and its extension method
            // `SleepSessionResultProviding.makeSessionQueryDescriptor` returns
            // SleepSessionQuery<Self>.Descriptor<Self> — a generic Descriptor<A>, not the
            // non-generic struct the generator emitted since the demangler exposes no
            // per-instantiation ABI witness for a private, purely-generic-internal nested type).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class SleepSessionQuery<A>: SleepSessionQueryProviding {",
                with: "@_fixed_layout public class SleepSessionQuery<A: SleepSessionResultProviding>: SleepSessionQueryProviding {\n    public typealias ResultType = A")
            c = c.replacingOccurrences(
                of: "public struct Descriptor: Codable, Hashable, @unchecked Sendable {",
                with: "public struct Descriptor<B>: Codable, Hashable, @unchecked Sendable {")

            // SleepMetrics/SleepMetrics.Averages/SleepDaySummary.Metrics conform to SleepAverageProviding,
            // whose countProvider/durationProvider requirements resolve to bare `some Sendable` —
            // retype to the real sibling nested types (SleepMetrics.Counts/SleepMetrics.Durations)
            // that actually conform to SleepCountProviding/SleepDurationProviding.
            c = c.replacingOccurrences(
                of: "public var countProvider: some Sendable",
                with: "public var countProvider: SleepMetrics.Counts"
            )
            c = c.replacingOccurrences(
                of: "public var durationProvider: some Sendable",
                with: "public var durationProvider: SleepMetrics.Durations"
            )

            // Fix: QueryDescriptor extensions demangle constraints with redundant protocol wrapper paths like
            // `Self.ConfigurationKind.Configuration.WithPredicate.PredicatedModelKind` instead of
            // `Self.ConfigurationKind.PredicatedModelKind`.
            c = c.replacingOccurrences(
                of: "Configuration.WithPredicate.PredicatedModelKind",
                with: "PredicatedModelKind"
            )
            c = c.replacingOccurrences(
                of: "Configuration.WithSortDescriptor.SortedModelKind",
                with: "SortedModelKind"
            )

            // Fix: HKCurrentActivityCacheQueryDescriptor.results(for:) conforms to
            // HKAsyncSequenceQuery, which requires `associatedtype Sequence: AsyncSequence` — the
            // demangler resolves the opaque return type to bare `some Sendable` (same gap as
            // Speech's `results: some Sendable` needing `some Sendable & AsyncSequence`, fixed
            // there via Model.swift retyping). Retype in place and return a concrete
            // AsyncStream value so the opaque type has a real underlying AsyncSequence.
            c = c.replacingOccurrences(
                of: "public func results(for: HKHealthStore) -> some Sendable { fatalError() }",
                with: "public func results(for: HKHealthStore) -> some Sendable & AsyncSequence { AsyncStream<HKCurrentActivityCacheQueryResult> { _ in } }")

            // CodableBoxDictionary<A, B> conforms to DefaultEncodable, whose `associatedtype T`
            // requirement is satisfied by its own `wrappedValue: [A : B]` — but the compiler
            // can't infer T from a property alone without an explicit typealias.
            c = c.replacingOccurrences(
                of: "public struct CodableBoxDictionary<A, B>: Codable, DefaultEncodable {",
                with: "public struct CodableBoxDictionary<A: Hashable, B>: Codable, DefaultEncodable {\n    public typealias T = [A: B]")
            c = c.replacingOccurrences(
                of: "public struct ListQueryDescriptor<A, B>: ListQueryDescriptorProtocol, QueryDescriptor {",
                with: "public struct ListQueryDescriptor<A: Decodable, B>: ListQueryDescriptorProtocol, QueryDescriptor {\n    public typealias ModelKind = B")
            c = c.replacingOccurrences(
                of: "public struct ObservationDescriptor<A>: ObservationQueryDescriptorProtocol, QueryDescriptor {",
                with: "public struct ObservationDescriptor<A: Decodable>: ObservationQueryDescriptorProtocol, QueryDescriptor {\n    public typealias ModelKind = Never")

            // SampleBaseConfiguration<A>'s own predicate-typed init parameter, predicate
            // property, and filter method also demangle with bare "Any" instead of "A" — same
            // root cause as above, just on the concrete conformer instead of the protocol
            // requirement. Scoped to inside the struct's own body (not a plain global replace)
            // since "Predicate<Any>? { get { return nil } }" also appears verbatim in the
            // unrelated Configuration.SampleSubtype extension, where "A" isn't in scope.
            if let declRange = c.range(of: "public struct SampleBaseConfiguration<A>:"),
               let braceStart = c.range(of: "{", range: declRange.upperBound..<c.endIndex) {
                var depth = 1
                var idx = braceStart.upperBound
                var braceEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { braceEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                let bodyRange = braceStart.upperBound..<braceEnd
                var body = String(c[bodyRange])
                body = body.replacingOccurrences(
                    of: "public init(predicate: Predicate<Any>?, sortDescriptors: [SortDescriptor<A>], limit: Swift.Int?) { fatalError() }",
                    with: "public init(predicate: Predicate<A>?, sortDescriptors: [SortDescriptor<A>], limit: Swift.Int?) { fatalError() }")
                body = body.replacingOccurrences(
                    of: "public func filter(_ arg1: Predicate<Any>) -> SampleBaseConfiguration<A> { fatalError() }",
                    with: "public func filter(_ arg1: Predicate<A>) -> SampleBaseConfiguration<A> { fatalError() }")
                body = body.replacingOccurrences(
                    of: "public var predicate: Predicate<Any>? { get { return nil } }",
                    with: "public var predicate: Predicate<A>? { get { return nil } }")
                c.replaceSubrange(bodyRange, with: body)
            }
            // SampleBaseConfiguration<A>'s own predicate/sortDescriptors/filter are typed by A
            // directly (not Any), so pin its PredicatedModelKind/SortedModelKind/SampleKind to A
            // explicitly — the compiler can't otherwise unify a bare A-typed member against a
            // Self.PredicatedModelKind-typed requirement without a concrete typealias.
            c = c.replacingOccurrences(
                of: "public struct SampleBaseConfiguration<A>: Codable, Configuration.Constructible, Configuration.SampleBase, Configuration.WithLimit, Configuration.WithPredicate, Configuration.WithSortDescriptor {",
                with: "public struct SampleBaseConfiguration<A>: Codable, Configuration.Constructible, Configuration.SampleBase, Configuration.WithLimit, Configuration.WithPredicate, Configuration.WithSortDescriptor {\n    public typealias PredicatedModelKind = A\n    public typealias SortedModelKind = A\n    public typealias SampleKind = A")

            // QueryDescriptorEvaluator's evaluate_list/evaluate_batched/evaluate_iterate/observe
            // requirements all carry a phantom third (resp. second) generic parameter
            // `GenericB == GenericA.ConfigurationKind` in the real ABI (confirmed via
            // swift-demangle -expand: every one of these method/dispatch-thunk/method-descriptor
            // symbols mangles as `evaluate_list<A, B, C where ..., B1 == A1.ConfigurationKind,
            // ...>`/`observe<A, B where ..., B1 == A1.ConfigurationKind>`) that's never referenced
            // in the function's own parameter/return types, so the generator has no way to infer
            // it from the TBD signature alone -- it just affects the generic-parameter depth/count
            // used in mangling. Add it to every requirement in this protocol.
            c = c.replacingOccurrences(
                of: "<GenericA, GenericC>(queryDescriptor: GenericA",
                with: "<GenericA, GenericB, GenericC>(queryDescriptor: GenericA")
            c = c.replacingOccurrences(
                of: "<GenericA>(observationDescriptor: GenericA",
                with: "<GenericA, GenericB>(observationDescriptor: GenericA")
            c = c.replacingOccurrences(
                of: "where GenericA: ListQueryDescriptorProtocol,  GenericC:",
                with: "where GenericA: ListQueryDescriptorProtocol,  GenericB == GenericA.ConfigurationKind,  GenericC:")
            c = c.replacingOccurrences(
                of: "where GenericA: ObservationQueryDescriptorProtocol",
                with: "where GenericA: ObservationQueryDescriptorProtocol,  GenericB == GenericA.ConfigurationKind")

            // SleepSessionQuery<A: SleepSessionResultProviding>'s configuration/range members
            // (and its nested Descriptor<B>/ServerConfiguration<B>'s equivalents) all render as
            // bare `Any`/`Any?`, but the real ABI ties them to SleepSessionResultProviding's
            // ConfigurationType/RangeType associated types (confirmed via swift-demangle: e.g.
            // `SleepSessionQuery.configuration.getter : A.ConfigurationType`,
            // `SleepSessionQuery.Descriptor.configuration.getter : A1.ConfigurationType`) --
            // the associated types themselves are already declared correctly on
            // SleepSessionResultProviding, just never threaded through to these members.
            // Descriptor<B>/ServerConfiguration<B> also need B constrained to
            // SleepSessionResultProviding for the associated-type-qualified members to compile.
            // Member order within a class/struct body isn't deterministic across generator runs
            // (confirmed elsewhere this session), so fix the two nested types via brace-matched
            // substring extraction first -- scoping the "Any"/"Any?" -> B.*Type replacements to
            // just that substring, before they'd otherwise collide with the identical-looking
            // outer SleepSessionQuery<A> members fixed via plain global replace below.
            for (header, genericParam) in [("public struct Descriptor<B>: Codable, Hashable, @unchecked Sendable {", "B"),
                                            ("@_fixed_layout open class ServerConfiguration<B>: NSObject, NSCoding {", "B")] {
                if let declRange = c.range(of: header) {
                    var depth = 1
                    var idx = declRange.upperBound
                    while depth > 0 && idx < c.endIndex {
                        if c[idx] == "{" { depth += 1 } else if c[idx] == "}" { depth -= 1 }
                        idx = c.index(after: idx)
                    }
                    let bodyRange = declRange.lowerBound..<idx
                    var body = String(c[bodyRange])
                    body = body.replacingOccurrences(of: "<B>", with: "<\(genericParam): SleepSessionResultProviding>")
                    body = body.replacingOccurrences(of: "range: Any", with: "range: \(genericParam).RangeType")
                    body = body.replacingOccurrences(of: "configuration: Any", with: "configuration: \(genericParam).ConfigurationType")
                    body = body.replacingOccurrences(of: "Descriptor<Any>", with: "Descriptor<\(genericParam)>")
                    c.replaceSubrange(bodyRange, with: body)
                }
            }
            // SleepSessionQuery<A: SleepSessionResultProviding>'s own top-level configuration/
            // range members are likewise bare `Any`/`Any?`, but the real ABI ties them to
            // SleepSessionResultProviding's ConfigurationType/RangeType associated types
            // (confirmed via swift-demangle: e.g. `SleepSessionQuery.configuration.getter :
            // A.ConfigurationType`). The associated types themselves are already declared
            // correctly on SleepSessionResultProviding, just never threaded through to these
            // members. Safe to do as a plain global replace now that the nested-type copies
            // above no longer read as bare "Any?"/"Any".
            c = c.replacingOccurrences(
                of: "public final var configuration: Any { get { fatalError() } }",
                with: "public final var configuration: A.ConfigurationType { get { fatalError() } }")
            c = c.replacingOccurrences(
                of: "required public init(range: Any?, configuration: Any, resultsHandler: @escaping @Sendable (SleepSessionQuery<A>, Result<[A], any Error>) -> ()) { fatalError() }",
                with: "required public init(range: A.RangeType?, configuration: A.ConfigurationType, resultsHandler: @escaping @Sendable (SleepSessionQuery<A>, Result<[A], any Error>) -> ()) { fatalError() }")
            c = c.replacingOccurrences(
                of: "public final var range: Any? { get { return nil } }",
                with: "public final var range: A.RangeType? { get { return nil } }")
            // SleepSessionQueryProviding's own range/configuration requirements are similarly
            // bare `Any?`/`Any` but the real ABI ties them to
            // ResultType.RangeType?/ResultType.ConfigurationType (confirmed via swift-demangle:
            // `SleepSessionQueryProviding.range.getter : A.ResultType.RangeType?`).
            c = c.replacingOccurrences(
                of: "var range: Any? { get }",
                with: "var range: Self.ResultType.RangeType? { get }")
            c = c.replacingOccurrences(
                of: "var configuration: Any { get }",
                with: "var configuration: Self.ResultType.ConfigurationType { get }")
        return c
    }

    static func postProcessHealthKitPart2(_ code: String, parser: Parser) -> String {
        var c = code
            // _HKQuantityDistributionStyle/_HKQuantityDistributionOptions have real NS_ENUM/
            // NS_OPTIONS bridge-header forward-declarations (added in generateExports), but the
            // generic "undeclared SPI type" fallback just above still renders a colliding native
            // Swift struct for them too, since it only checks for a Swift-source declaration
            // line, not a bridge-header one. Confirmed via a minimal repro that Swift doesn't
            // even raise a redeclaration error for this collision -- the native struct just
            // silently shadows the real ClangImported type at every use site, so it compiles fine
            // but keeps mangling under HealthKit instead of __C. Same fix as Translation's
            // _LTTextSessionDelegate above: strip the redundant native stub after the fallback
            // runs, letting the real bridged declaration resolve instead.
            for name in ["_HKQuantityDistributionStyle", "_HKQuantityDistributionOptions"] {
                c = c.replacingOccurrences(
                    of: "public struct \(name): Hashable, Sendable {}",
                    with: "")
            }
            // A handful of static `os.Logger`/`os.OSSignposter`-typed properties (workouts,
            // types, infrastructure, dataCollection, database, cloudSync, cloudSyncSignposter)
            // were silently dropped entirely (no stub, no declaration at all) instead of being
            // rendered as an extension on the real `Logger` type -- the parser instead emitted a
            // dead, unreferenced placeholder struct `os_Logger` (never used anywhere) as a
            // byproduct of failing to resolve the qualified `os.Logger` extension target. Drop
            // the dead placeholder and add the real extension members directly.
            // ListQueryDescriptor<A, B>.init<A1>/ObservationDescriptor<A>.init<A1> are both
            // missing equality constraints binding their own generic parameters to A1's
            // associated types (confirmed via swift-demangle: e.g.
            // `ListQueryDescriptor.init<A where A == A1.ListConfigurationKind, B ==
            // A1.ModelKind, A1: HealthKit.ListHealthType>`), same phantom-generic-constraint
            // shape as the QueryDescriptorEvaluator fix earlier this session.
            c = c.replacingOccurrences(
                of: "public init<A1>(type: A1, configuration: A) where  A1: ListHealthType { fatalError() }",
                with: "public init<A1>(type: A1, configuration: A) where A1: ListHealthType, A == A1.ListConfigurationKind, B == A1.ModelKind { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A1>(type: A1, configuration: A) where  A1: ObservableHealthType { fatalError() }",
                with: "public init<A1>(type: A1, configuration: A) where A1: ObservableHealthType, A == A1.ObservationConfigurationKind { fatalError() }")
            // ObserverSet<A>/MainActorObserverSet<A>'s loggingCategory init parameter resolved to
            // the usual "__C" shadow-type fallback for `OSLog` (confirmed via swift-demangle:
            // mangles as `__C.OS_os_log`, the real ObjC symbol name -- `OS_os_log` is renamed to
            // bare `OSLog` for Swift source, same rename-vs-ABI-name split as NSQualityOfService
            // above). `<os/log.h>` (imported above) makes the real type visible; just drop the
            // shadow.
            c = c.replacingOccurrences(
                of: "public struct __C_OSLog: Hashable, Codable, Sendable {}\npublic typealias OSLog = __C_OSLog\n",
                with: "")
            // Array<Element: SleepDurationProviding>'s extension provides SleepCountProviding/
            // SleepAverageProviding/SleepDurationProviding(Sequence)'s member implementations,
            // but never restates the conformances themselves -- same "conformance restatement
            // gap" class of bug already fixed for CodableBox/Charts result-builder types earlier
            // this session (confirmed via swift-demangle: real protocol conformance descriptors
            // and witness tables exist for all 6 protocols on `[A] where A: SleepDurationProviding`).
            c = c.replacingOccurrences(
                of: "extension Array where Element: SleepDurationProviding {",
                with: "extension Array: SleepAverageProviding, SleepAverageProvidingSequence, SleepCountProviding, SleepCountProvidingSequence, SleepDurationProviding, SleepDurationProvidingSequence where Element: SleepDurationProviding {")
            // SampleType redeclares ListHealthType's ListConfigurationKind associated type with
            // a stronger bound (confirmed via swift-demangle: `associated conformance descriptor
            // for HealthKit.SampleType.HealthKit.ListHealthType.ListConfigurationKind:
            // HealthKit.Configuration.SampleBase`), but the generator never emitted the
            // restatement.
            c = c.replacingOccurrences(
                of: "public protocol SampleType: BasicObservableHealthType, ListHealthType {\n    associatedtype UnderlyingTypeKind",
                with: "public protocol SampleType: BasicObservableHealthType, ListHealthType {\n    associatedtype ListConfigurationKind: Configuration.SampleBase\n    associatedtype UnderlyingTypeKind")
            // ListHealthType.ListConfigurationKind, ObservableHealthType.
            // ObservationConfigurationKind, and QueryDescriptor.ConfigurationKind are all declared
            // as bound only to `Decodable`, but the real ABI also has an associated conformance
            // descriptor tying each to `Encodable` (confirmed via swift-demangle: e.g.
            // `associated conformance descriptor for
            // HealthKit.ListHealthType.HealthKit.ListHealthType.ListConfigurationKind:
            // Swift.Encodable`) -- i.e. each should be bound to `Codable`, not just `Decodable`.
            c = c.replacingOccurrences(
                of: "associatedtype ListConfigurationKind: Decodable",
                with: "associatedtype ListConfigurationKind: Codable")
            c = c.replacingOccurrences(
                of: "associatedtype ObservationConfigurationKind: Decodable",
                with: "associatedtype ObservationConfigurationKind: Codable")
            c = c.replacingOccurrences(
                of: "associatedtype ConfigurationKind: Decodable",
                with: "associatedtype ConfigurationKind: Codable")
            // ListQueryDescriptor<A: Decodable, B>/ObservationDescriptor<A: Decodable> bind their
            // own generic parameter A to QueryDescriptor.ConfigurationKind, which now (correctly)
            // requires Codable, not just Decodable.
            c = c.replacingOccurrences(
                of: "public struct ListQueryDescriptor<A: Decodable, B>: ListQueryDescriptorProtocol, QueryDescriptor {",
                with: "public struct ListQueryDescriptor<A: Codable, B>: ListQueryDescriptorProtocol, QueryDescriptor {")
            c = c.replacingOccurrences(
                of: "public struct ObservationDescriptor<A: Decodable>: ObservationQueryDescriptorProtocol, QueryDescriptor {",
                with: "public struct ObservationDescriptor<A: Codable>: ObservationQueryDescriptorProtocol, QueryDescriptor {")
            // NOTE: several protocol-witness-table-only stubs remain for generic types'
            // conformances to protocols with associated types (ScoredAssessmentType,
            // CodableBox/CodableBoxArray/CodableBoxDictionary, ListQueryDescriptor,
            // ObservationDescriptor, SampleBaseConfiguration, HKAnchoredObjectQueryDescriptor,
            // HKSampleQueryDescriptor, SleepSessionQuery, Array<SleepDurationProviding>,
            // ClosedRange<SleepDay>) even though their conformance descriptors are correct.
            // Confirmed via a minimal standalone repro (unrelated to this codebase) that plain
            // swiftc NEVER emits an externally-linked witness table symbol for a generic type's
            // conformance to a protocol with an associated type, regardless of -O,
            // -enable-library-evolution, -cross-module-optimization, or forcing an existential
            // usage site -- yet Apple's real compiled dylib exports these symbols (confirmed via
            // HealthKit.tbd). This is a gap between Apple's internal SDK build and local swiftc,
            // not something fixable by changing the generated source. Treat as structurally
            // unfixable, same bucket as opaque-return-type stubs.
            // mergeRanges is missing the constraint tying A.Element to Range<Int> (confirmed via
            // swift-demangle: `mergeRanges<A where A: Swift.Sequence, A.Element ==
            // Swift.Range<Swift.Int>>`), same phantom-constraint-drop pattern as
            // QueryDescriptorEvaluator earlier this session.
            c = c.replacingOccurrences(
                of: "public func mergeRanges<A>(_ arg1: A, gapThreshold: CGFloat) -> [Range<Swift.Int>] where A: Swift.Sequence { return [] }",
                with: "public func mergeRanges<A>(_ arg1: A, gapThreshold: CGFloat) -> [Range<Swift.Int>] where A: Swift.Sequence, A.Element == Range<Swift.Int> { return [] }")
            // QuantityThresholds<A> itself needs A bounded to Decodable & Encodable & Hashable &
            // Sendable directly on the outer struct's own generic parameter -- confirmed via
            // swift-demangle: every nested type's (Edge/Threshold/Bucket) conformance descriptor
            // is unconditional (no "Rzl" conditional-conformance flag), which only typechecks if
            // the bound lives on the outer declaration itself rather than as a per-nested-type
            // "where" clause (each enum case constructor's generic signature restates the bound
            // because it's inherited from the outer environment, not because Edge adds its own).
            c = c.replacingOccurrences(
                of: "public struct QuantityThresholds<A>: Codable, Hashable {",
                with: "public struct QuantityThresholds<A: Decodable & Encodable & Hashable & Sendable>: Codable, Hashable {")
            // HKDatabase.Pruning.Show.PruningRestrictionPredicate.Classification.match's payload
            // has no argument label in the real ABI (confirmed via swift-demangle -expand:
            // LabelList is empty), but the generator emitted a redundant label matching the case
            // name itself (`match(match: ...)` instead of `match(_: ...)`).
            c = c.replacingOccurrences(
                of: "case match(match: HKDatabase.Pruning.Show.PruningRestrictionPredicate)",
                with: "case match(_: HKDatabase.Pruning.Show.PruningRestrictionPredicate)")
            // HKAttachmentDataReader.data's real getter is async (confirmed via swift-demangle:
            // `async function pointer to dispatch thunk of
            // HealthKit.HKAttachmentDataReader.data.getter`), but the generator emitted a
            // synchronous getter.
            c = c.replacingOccurrences(
                of: "public var data: Data { get { return Data() } }",
                with: "public var data: Data { get async { return Data() } }")
            // QueryDescriptor's constrained-extension withOptions/filter both use a bare `Any`
            // instead of the real associated-type-derived parameter type -- same Any-vs-
            // associated-type gap as the SleepSessionQuery fix earlier this session (confirmed
            // via swift-demangle: `withOptions(A.ConfigurationKind.Configuration.WithOptions.
            // OptionsKind) -> A` and `filter(Foundation.Predicate<Pack{A.ModelKind}>) -> A`).
            c = c.replacingOccurrences(
                of: "public func withOptions(_ arg1: Any) -> Self { fatalError() }",
                with: "public func withOptions(_ arg1: Self.ConfigurationKind.OptionsKind) -> Self { fatalError() }")
            c = c.replacingOccurrences(
                of: "public func filter(_ arg1: Predicate<Any>) -> Self { fatalError() }",
                with: "public func filter(_ arg1: Predicate<Self.ModelKind>) -> Self { fatalError() }")
            // SleepSessionQuery<A>.Descriptor<B>'s conformance to HKAsyncQuery (conditional on
            // A == B) was never restated, even though an extension already provides the exact
            // matching result(for:) -> [A] implementation the conformance needs -- confirmed via
            // swift-demangle -expand: DependentGenericSameTypeRequirement ties the outer type's
            // generic param 0 (A) to the nested type's own generic param 0 (B), and the existing
            // extension's inferred Output ([A]) is the only shape that doesn't conflict.
            c = c.replacingOccurrences(
                of: "extension SleepSessionQuery.Descriptor where A == B {",
                with: "extension SleepSessionQuery.Descriptor: HKAsyncQuery where A == B {")
            // SleepCountProvidingSequence/SleepDurationProvidingSequence both refine
            // Sequence, but the real ABI restates Sequence.Element with a stronger bound
            // (confirmed via swift-demangle: `associated conformance descriptor for
            // HealthKit.SleepCountProvidingSequence.Swift.Sequence.Element:
            // HealthKit.SleepDurationProviding`), which the generator never emitted.
            c = c.replacingOccurrences(
                of: "public protocol SleepCountProvidingSequence: Sequence, SleepCountProviding {\n}",
                with: "public protocol SleepCountProvidingSequence: Sequence, SleepCountProviding where Element: SleepDurationProviding {\n}")
            c = c.replacingOccurrences(
                of: "public protocol SleepDurationProvidingSequence: Sequence, SleepDurationProviding {\n}",
                with: "public protocol SleepDurationProvidingSequence: Sequence, SleepDurationProviding where Element: SleepDurationProviding {\n}")
            // CodableBox<A>/OptionalCodableBox<A> are both conditionally Comparable when A:
            // Comparable, but the `<` operator (and the conformance itself) were silently
            // dropped entirely -- confirmed via swift-demangle: e.g.
            // `HealthKit.CodableBox< where A: Swift.Comparable>.< infix(...)`.
            c += """

            extension CodableBox: Comparable where A: Comparable {
                public static func <(lhs: CodableBox<A>, rhs: CodableBox<A>) -> Bool { fatalError() }
            }
            extension OptionalCodableBox: Comparable where A: Comparable {
                public static func <(lhs: OptionalCodableBox<A>, rhs: OptionalCodableBox<A>) -> Bool { fatalError() }
            }

            """
            // ClosedRange<Bound == SleepDay>'s extension provides SecureCodable/
            // SleepSessionRangeProviding's member implementations (split(_:) satisfies
            // SleepSessionRangeProviding; SecureCodable's Codable/Hashable requirements are
            // already satisfied natively by ClosedRange's own conditional conformances when
            // Bound: SleepDay is Codable & Hashable), but never restates the conformances
            // themselves -- same conformance-restatement gap as the Array<SleepDurationProviding>
            // fix above.
            c = c.replacingOccurrences(
                of: "extension ClosedRange where Bound == SleepDay {",
                with: "extension ClosedRange: SecureCodable, SleepSessionRangeProviding where Bound == SleepDay {")
            // DateInterval/DateComponents/Date's whole set of sleep-day-related extension
            // members were silently dropped entirely -- same class of gap as the os.Logger
            // properties and __BridgedLocale.performAsCurrent below, just a much larger cohesive
            // batch (confirmed via swift-demangle: e.g.
            // `Foundation.DateInterval.overlappingSleepDays(in:) -> [HealthKit.SleepDay]`).
            c += """

            extension DateInterval {
                public func overlappingSleepDays(in calendar: Calendar) -> [SleepDay] { return [] }
                public var latestPossibleSleepDay: SleepDay { get { fatalError() } }
                public var earliestPossibleSleepDay: SleepDay { get { fatalError() } }
                public func overlappingDayIndexRange(in calendar: Calendar) -> ClosedRange<DayIndex> { fatalError() }
                public func overlappingSleepDayRange(in calendar: Calendar) -> ClosedRange<SleepDay> { fatalError() }
                public func overlappingMorningIndexRange(in calendar: Calendar) -> ClosedRange<DayIndex> { fatalError() }
                public var cascadeAffectingSleepDayRange: ClosedRange<SleepDay> { get { fatalError() } }
                public func split(_ arg1: Swift.Int) -> [DateInterval] { return [] }
                public func hk_union(with arg1: DateInterval) -> DateInterval { fatalError() }
            }
            extension DateComponents {
                public var clockTimeSafeComponents: DateComponents { get { fatalError() } }
                public var sleepClockTime: SleepClockTime { get { fatalError() } }
                public func applying(_ arg1: SleepClockTime) -> DateComponents { fatalError() }
            }
            extension Date {
                public var latestPossibleSleepDay: SleepDay { get { fatalError() } }
                public var earliestPossibleSleepDay: SleepDay { get { fatalError() } }
                public var latestPossibleDayIndexInAnyTimeZone: DayIndex { get { fatalError() } }
                public var earliestPossibleDayIndexInAnyTimeZone: DayIndex { get { fatalError() } }
                public func sleepDay(in calendar: Calendar) -> SleepDay { fatalError() }
            }

            """
            // __BridgedLocale.performAsCurrent was silently dropped entirely (no stub, no
            // declaration at all) -- same class of gap as the os.Logger properties above.
            c = c.replacingOccurrences(
                of: "public static var currentNSLocale: NSLocale? { get { return nil } }",
                with: "public static var currentNSLocale: NSLocale? { get { return nil } }\n    public static func performAsCurrent(nsLocale: NSLocale, _ arg1: () -> ()) -> () { arg1() }")
            // Foundation.Locale.hk_performAsCurrent/Foundation.Calendar.localGregorianCalendar/
            // CoreGraphics.CGFloat.chartPointGapThreshold were likewise silently dropped entirely
            // -- each is an extension on a real, already-resolvable Foundation/CoreGraphics type,
            // so (unlike Coherence.CRContext below) the parser's unresolved-qualified-extension
            // fallback never even left behind a placeholder struct as a clue.
            c += """

            extension Locale {
                public func hk_performAsCurrent(_ arg1: () throws -> ()) throws -> () { try arg1() }
                public func hk_performAsCurrent(_ arg1: () async throws -> ()) async throws -> () { try await arg1() }
            }
            extension Calendar {
                public static var localGregorianCalendar: Calendar { get { fatalError() } }
            }
            extension CGFloat {
                public static func chartPointGapThreshold(for: CGFloat, chartHeight: CGFloat, cornerRadius: CGFloat) -> CGFloat { fatalError() }
            }

            """
            // Coherence.CRContext.sharedCoherenceContext was also dropped (leaving behind a dead
            // placeholder struct, `Coherence_CRContext`, as a byproduct -- same shape as os_Logger
            // above), but unlike the others this one is NOT fixable here: `CRContext` doesn't
            // exist in the `Coherence` module on this SDK at all (confirmed: "no type named
            // 'CRContext' in module 'Coherence'" even with plain `import Coherence` already
            // present) -- it's presumably a private/internal type not exposed in this SDK's
            // Coherence.swiftinterface. Leave the dead placeholder struct as harmless dead code.
            c = c.replacingOccurrences(
                of: "public struct os_Logger: Hashable, Codable, Sendable {}\n",
                with: """
                extension Logger {
                    public static var workouts: Logger { get { fatalError() } }
                    public static var types: Logger { get { fatalError() } }
                    public static var infrastructure: Logger { get { fatalError() } }
                    public static var dataCollection: Logger { get { fatalError() } }
                    public static var database: Logger { get { fatalError() } }
                    public static var cloudSync: Logger { get { fatalError() } }
                    public static var cloudSyncSignposter: OSSignposter { get { fatalError() } }
                }

                """)
            // _HKQuantityDistributionQueryDescriptor is missing its contextStyle/options
            // properties entirely (only its init takes them as parameters) -- confirmed via
            // swift-demangle: the real ABI has getter/setter/modify/property-descriptor symbols
            // for both.
            c = c.replacingOccurrences(
                of: "public init(quantityType: HKQuantityType, startDate: Date, endDate: Date, contextStyle: _HKQuantityDistributionStyle, predicate: NSPredicate?, anchorDate: Date, intervalComponents: DateComponents, histogramAnchor: HKQuantity?, histogramBucketSize: HKQuantity, options: _HKQuantityDistributionOptions) { fatalError() }",
                with: "public init(quantityType: HKQuantityType, startDate: Date, endDate: Date, contextStyle: _HKQuantityDistributionStyle, predicate: NSPredicate?, anchorDate: Date, intervalComponents: DateComponents, histogramAnchor: HKQuantity?, histogramBucketSize: HKQuantity, options: _HKQuantityDistributionOptions) { fatalError() }\n    public var contextStyle: _HKQuantityDistributionStyle { get { fatalError() } set {} }\n    public var options: _HKQuantityDistributionOptions { get { fatalError() } set {} }")

            // HKWorkoutMetricsDelegate is a native Swift protocol, not an ObjC one (confirmed via
            // swift-demangle -expand: HKWorkoutMetricsDataSource.delegate's getter/setter/modify
            // mangle it under the HealthKit module, not __C) -- but it never emits a demangleable
            // ABI symbol of its own into the TBD, so the parser has nothing to build a node from.
            // Declare it directly (right after HKWorkoutMetricsDataSource's own closing brace,
            // found via brace-matching since member order isn't deterministic) rather than via
            // the bridge header (which would mangle it under __C instead, same mismatch class as
            // the OS_nw_*/SNRequest protocol-not-class fixes).
            if let declRange = c.range(of: "@_fixed_layout public class HKWorkoutMetricsDataSource {") {
                var depth = 1
                var idx = declRange.upperBound
                while depth > 0 && idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 } else if c[idx] == "}" { depth -= 1 }
                    idx = c.index(after: idx)
                }
                c.insert(contentsOf: "\npublic protocol HKWorkoutMetricsDelegate: AnyObject {\n}", at: idx)
            }
        return c
    }
}
