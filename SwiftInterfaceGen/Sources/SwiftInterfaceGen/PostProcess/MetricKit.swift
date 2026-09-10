import Foundation

extension SwiftInterfaceGen {
    static func postProcessMetricKit(_ code: String, parser: Parser) -> String {
        var c = code
            // AverageStatistics<DimensionType> and Histogram<DimensionType> both require
            // DimensionType: Foundation.Dimension (all MetricKit unit types are Dimension subclasses).
            c = c.replacingOccurrences(of: "public struct AverageStatistics<A>:",
                                        with: "public struct AverageStatistics<A: Foundation.Dimension>:")
            c = c.replacingOccurrences(of: "public struct Histogram<A>:",
                                        with: "public struct Histogram<A: Foundation.Dimension>:")
            // SignalBars is a Dimension subclass — override the NSObject base class with Dimension.
            // The real arm64e swiftinterface declares it `final public class SignalBars :
            // Foundation::Dimension, @unchecked Swift::Sendable` (confirmed via swift-demangle:
            // its baseUnit() override needs the concrete return type, same as the other two
            // Dimension subclasses below, which only compiles/mangles correctly on a final class
            // -- `open` and `final` can't both apply), not `open` as this rendered previously.
            if let regex = try? NSRegularExpression(
                pattern: "(?:public |open |@_fixed_layout )*(?:class|open class) SignalBars:\\s*NSObject", options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "final public class SignalBars: Foundation.Dimension")
            }
            // Foundation.Dimension already conforms to NSCoding, so remove the redundant
            // NSCoding conformance from SignalBars's inheritance list.
            c = c.replacingOccurrences(of: "final public class SignalBars: Foundation.Dimension, NSCoding",
                                        with: "final public class SignalBars: Foundation.Dimension")
            // After substituting Dimension as parent, encode(with:) is now an override of
            // Foundation.Dimension's NSCoding conformance — mark it accordingly. `open` isn't
            // legal on a final class's member.
            c = c.replacingOccurrences(of: "open func encode(with coder: NSCoder) {}",
                                        with: "public override func encode(with coder: NSCoder) {}")
            // required init?(coder:) must call super.init(coder:) since Foundation.Dimension
            // is the new base class and its designated initializers must be called.
            c = c.replacingOccurrences(of: "public required init?(coder: NSCoder) {}",
                                        with: "public required init?(coder: NSCoder) { super.init(coder: coder) }")
            // HitchTimeRatio is likewise a Dimension subclass (real module: `final public class
            // HitchTimeRatio: Foundation.Dimension`) — Parser.swift sets its baseClass
            // accordingly, but the ABI-driven class-header text still renders it with the
            // NSObject/NSCoding-subclass shape (redundant NSCoding conformance, non-`open`
            // visibility+finality). Apply the same header substitution SignalBars needed above.
            if let regex = try? NSRegularExpression(
                pattern: "@_fixed_layout open class HitchTimeRatio:\\s*NSObject,\\s*NSCoding", options: []) {
                c = regex.stringByReplacingMatches(
                    in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "@_fixed_layout final public class HitchTimeRatio: Foundation.Dimension")
            }
            // Parser.swift's simplifyType() unconditionally rewrites every Dimension subclass's
            // `baseUnit()` override return type to `-> Self`, matching Foundation.Dimension's own
            // `open class func baseUnit() -> Self` declaration -- correct for `open` subclasses,
            // but AveragePixelLuminance/HitchTimeRatio/SignalBars are all `final` here, and the
            // real arm64e swiftinterface prints their overrides with the concrete return type
            // (e.g. "-> MetricKit.AveragePixelLuminance"), not `Self` (for a final class the two
            // are equivalent at the source level, but they mangle differently: `-> Self` adds a
            // dynamic-Self "XD" marker a minimal repro confirms the real symbols don't have).
            // All three classes render this override with byte-identical text, so a plain
            // replacingOccurrences(of:with:) (which replaces every match at once) can't target
            // each one with its own class name -- match each occurrence together with its
            // nearest-preceding class header instead, via a lazy multiline span.
            for finalUnitType in ["AveragePixelLuminance", "HitchTimeRatio", "SignalBars"] {
                if let regex = try? NSRegularExpression(
                    pattern: "(final public class \(finalUnitType): Foundation\\.Dimension[\\s\\S]*?)public override static func baseUnit\\(\\) -> Self \\{ fatalError\\(\\) \\}",
                    options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "$1public override static func baseUnit() -> \(finalUnitType) { fatalError() }")
                }
            }
            // MetricResult.hitchTime's real ABI enum-case constructor has an unlabeled associated
            // value (confirmed via swift-demangle -expand: its LabelList is empty), but the
            // generator renders it with a `hitchTime:` label -- a minimal repro confirms a
            // labeled single-payload case mangles differently ("V_t" tuple-with-label shape)
            // from an unlabeled one, which is what the real symbol has.
            c = c.replacingOccurrences(
                of: "case hitchTime(hitchTime: HitchTimeMetric)",
                with: "case hitchTime(HitchTimeMetric)")
            // mxSignpost(_:dso:log:name:signpostID:_:_:) -- the raw C-level signpost function
            // taking an os_signpost_type_t and a raw os_log_t -- is real ABI (confirmed via
            // swift-demangle) but never rendered at all; only its higher-level Swift wrappers
            // (mxSignpostAnimationIntervalBegin etc.) are. Add it directly: `OSSignpostType`/
            // `OSLog` are Swift's renamed-in-Swift-3 surface names for the same underlying
            // ObjC/C types the real symbol mangles as ("__C.os_signpost_type_t"/"__C.OS_os_log"),
            // confirmed via a minimal repro to produce an exact match.
            c += """

public func mxSignpost(_ type: OSSignpostType, dso: UnsafeRawPointer, log: OSLog, name: StaticString, signpostID: OSSignpostID, _ arg1: StaticString, _ arg2: [CVarArg]) -> () {}

"""
        return c
    }
}
