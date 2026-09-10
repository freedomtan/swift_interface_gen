import Foundation

extension SwiftInterfaceGen {
    static func postProcessCreateML(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix: MLDataColumn<A>/MLUntypedColumn declare ==/!= but are missing the ordering
            // operators (>, <, >=, <=) entirely -- added directly, matching the existing ==/!=
            // overload shape (3 overloads each: column-column, column-scalar, scalar-column).
            // Confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public struct MLDataColumn<A>: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible {",
                with: """
                public struct MLDataColumn<A>: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible where A: MLDataValueConvertible {
                    public static func >(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >=(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >=(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func >=(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <=(_ arg1: MLDataColumn<A>, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <=(_ arg1: MLDataColumn<A>, _ arg2: A) -> MLDataColumn<Swift.Bool> { fatalError() }
                    public static func <=(_ arg1: A, _ arg2: MLDataColumn<A>) -> MLDataColumn<Swift.Bool> { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public struct MLUntypedColumn: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible {",
                with: """
                public struct MLUntypedColumn: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable, CustomStringConvertible {
                    public static func >(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func >(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func >(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func <(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func >=(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func >=(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func >=(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <=(_ arg1: MLUntypedColumn, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                    public static func <=(_ arg1: MLUntypedColumn, _ arg2: any MLDataValueConvertible) -> MLUntypedColumn { fatalError() }
                    public static func <=(_ arg1: any MLDataValueConvertible, _ arg2: MLUntypedColumn) -> MLUntypedColumn { fatalError() }
                """)

            // Fix: MLRegressorMetrics/MLClassifierMetrics/MLObjectDetectorMetrics's static
            // __evaluation(on:...) factory methods are entirely missing. Added directly,
            // confirmed via a minimal repro to produce exact byte-for-byte matches.
            c = c.replacingOccurrences(
                of: "public struct MLRegressorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {",
                with: """
                public struct MLRegressorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {
                    public static func __evaluation(on: MLDataTable, targetColumn: Swift.String, predictionColumn: Swift.String) throws -> MLRegressorMetrics { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public struct MLClassifierMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {",
                with: """
                public struct MLClassifierMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {
                    public static func __evaluation(on: MLDataTable, labelColumn: Swift.String, predictionColumn: Swift.String, classes: [Swift.String]) throws -> MLClassifierMetrics { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public struct MLObjectDetectorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {",
                with: """
                public struct MLObjectDetectorMetrics: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible {
                    public static func __evaluation(on: MLDataTable, imageColumn: Swift.String, annotationColumn: Swift.String, predictionColumn: Swift.String, classes: [Swift.String]) throws -> MLObjectDetectorMetrics { fatalError() }
                """)

            // Fix: `extension Array where Element: MLDataValueConvertible`/`extension Dictionary
            // where Key: ..., Value: ...` add the protocol's members conditionally but never
            // declare the conformance itself (`: MLDataValueConvertible` is missing from the
            // extension header) -- same "retroactive conditional conformance never declared" gap
            // fixed for SwiftData's Array/Optional:RelationshipCollection earlier this session.
            // Their witness tables remain unfixable (established generic-conformance pattern).
            c = c.replacingOccurrences(
                of: "extension Array where Element: MLDataValueConvertible {",
                with: "extension Array: MLDataValueConvertible where Element: MLDataValueConvertible {")
            c = c.replacingOccurrences(
                of: "extension Dictionary where Key: MLDataValueConvertible,  Value: MLDataValueConvertible {",
                with: "extension Dictionary: MLDataValueConvertible where Key: MLDataValueConvertible,  Value: MLDataValueConvertible {")

            // The generic conditional conformance witness tables are not emitted by swiftc,
            // but are present in CreateML.tbd. Emit @_silgen_name stubs so first-pass dylib exports them.
            c += """

@_silgen_name("$sSayxG8CreateML22MLDataValueConvertibleA2bCRzlWP")
func _stub_array_MLDataValueConvertible_WP() { fatalError() }

@_silgen_name("$sSDyxq_G8CreateML22MLDataValueConvertibleA2bCRzAbCR_rlWP")
func _stub_dictionary_MLDataValueConvertible_WP() { fatalError() }

"""

            // Fix: MLDataColumn<A> is missing its own `A: MLDataValueConvertible` bound (confirmed
            // via the real swiftinterface header -- restored above, alongside the >/</>=/<=
            // operators). The generator already renders every "A =="-constrained member
            // (arithmetic operators, aggregates, the cross-type `init(column:)`) correctly in
            // their own constrained extensions -- restoring just the missing base-struct bound is
            // enough for their mangled symbols to become correct too, confirmed via a minimal
            // repro to produce exact byte-for-byte matches for all of them.
        return c
    }
}
