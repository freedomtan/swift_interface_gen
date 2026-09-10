import Foundation

extension SwiftInterfaceGen {
    static func postProcessNetworkPart1(_ code: String, parser: Parser) -> String {
        var c = code
            let networkConformancesToStrip: Set<String> = [
                "NetworkProtocolOptions", "BottomProtocolHandler", "LowerProtocolHandler",
                "OutboundDatagramHandler", "OutboundStreamHandler",
            ]
            // Process line by line: for type declaration lines (struct/class/protocol/enum/actor),
            // strip only the problematic conformances from the inheritance list (after the colon).
            let networkLines = c.components(separatedBy: "\n")
            var networkFixed = [String]()
            // Group 4 must swallow everything to end-of-line after the opening "{" (e.g. a
            // trailing "}" closing a same-line empty body like "... Sendable {}") — matching
            // only " {" and discarding the rest silently truncated single-line declarations,
            // leaving their closing brace missing (manifested as cascading "expected '}' in
            // struct" errors for the __C_* stub structs, which are emitted as one-liners).
            // The modifier prefix allows any order/combination of @_fixed_layout/public/open/
            // final (nested classes like "@_fixed_layout final public class BridgeInstance"
            // put final before public) — a fixed-order alternation missed those lines entirely,
            // leaving their BottomProtocolHandler/LowerProtocolHandler/etc. conformances
            // unstripped (manifested as "does not conform to protocol" errors).
            // The type-name group must swallow a generic parameter list's own "<...>" as one
            // unit (e.g. "LowerHarness<A: LowerProtocolLinkage>") — a bare "\S+" stops at the
            // FIRST colon in the line, which is the one inside "<A: LowerProtocolLinkage>" once a
            // constrained generic param is present, not the real inheritance-list colon that
            // follows the closing ">". That misparse leaves the inheritance list's first entry
            // reading "LowerProtocolLinkage>: BottomProtocolHandler" instead of
            // "BottomProtocolHandler", which then fails to match networkConformancesToStrip.
            let typeHeaderRegex = try? NSRegularExpression(
                pattern: "^(\\s*(?:@_fixed_layout\\s+|public\\s+|open\\s+|final\\s+)+(?:struct|class|protocol|enum|actor|extension)\\s+[^\\s:<]+(?:<[^>]*>)?)(:)(.*?)( \\{.*|$)", options: [])
            for line in networkLines {
                var fixedLine = line
                if let regex = typeHeaderRegex,
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                    // Extract the part before the colon, the inheritance list, and the trailing brace
                    if let prefixRange = Range(match.range(at: 1), in: line),
                       let colonRange = Range(match.range(at: 2), in: line),
                       let listRange = Range(match.range(at: 3), in: line),
                       let suffixRange = Range(match.range(at: 4), in: line) {
                        let prefix = String(line[prefixRange])
                        let list = String(line[listRange])
                        let suffix = String(line[suffixRange])
                        // Parse the conformance list and remove the problematic ones
                        var conformances = list.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        conformances.removeAll { networkConformancesToStrip.contains($0) }
                        if conformances.isEmpty {
                            fixedLine = prefix + suffix
                        } else {
                            fixedLine = prefix + ": " + conformances.joined(separator: ", ") + suffix
                        }
                        _ = colonRange // suppress warning
                    }
                }
                networkFixed.append(fixedLine)
            }
            c = networkFixed.joined(separator: "\n")
            // A protocol default-implementation extension constrained `where Self: ~Copyable`
            // (e.g. OneToOneStreamProtocol's real getOutboundStreamDataRoomAvailable(_:), whose
            // symbol demangles to "(extension in Network):Network.OneToOneStreamProtocol< where
            // A: ~Swift.Copyable>...") only compiles if the protocol ITSELF opts out of the
            // implicit `Self: Copyable` requirement (confirmed via a minimal swiftc repro:
            // `protocol Foo {}; extension Foo where Self: ~Copyable {}` fails with "'Self'
            // required to be 'Copyable'"; adding `~Copyable` to Foo's own declaration fixes it).
            // Swift requires every protocol in an inheritance chain to agree on this, so
            // transitively close over ancestors too (e.g. OneToOneStreamProtocol:
            // OneToOneDatapathProtocol: OneToOneProtocolHandler: ...: ProtocolInstance all need
            // it, even though only some of them have their own `~Copyable`-constrained
            // extension). This used to strip the whole extension instead, silently dropping
            // every default-implementation method it provided (the majority of Network's
            // first-pass stub count).
            var needsCopyable = Set<String>()
            if let extRegex = try? NSRegularExpression(
                pattern: "extension\\s+(\\S+)\\s+where\\s+Self\\s*:\\s*~Copyable[^{]*\\{", options: []) {
                let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                for m in extRegex.matches(in: c, options: [], range: nsRange) {
                    if let r = Range(m.range(at: 1), in: c) {
                        needsCopyable.insert(String(c[r]))
                    }
                }
            }
            if !needsCopyable.isEmpty {
                var ancestors = [String: [String]]()
                if let declRegex = try? NSRegularExpression(
                    pattern: "public protocol (\\S+?)(?:<[^>]*>)?(?:\\s*:\\s*([^{]+))?\\s*\\{", options: []) {
                    let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                    for m in declRegex.matches(in: c, options: [], range: nsRange) {
                        guard let nameRange = Range(m.range(at: 1), in: c) else { continue }
                        let protoName = String(c[nameRange])
                        var protoAncestors = [String]()
                        if m.range(at: 2).location != NSNotFound, let listRange = Range(m.range(at: 2), in: c) {
                            protoAncestors = String(c[listRange]).components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        }
                        ancestors[protoName] = protoAncestors
                    }
                }
                var frontier = Array(needsCopyable)
                while let protoName = frontier.popLast() {
                    for ancestor in ancestors[protoName] ?? [] where !needsCopyable.contains(ancestor) {
                        needsCopyable.insert(ancestor)
                        frontier.append(ancestor)
                    }
                }
                for protoName in needsCopyable {
                    let withInheritance = "public protocol \(protoName): "
                    if let range = c.range(of: withInheritance) {
                        c.insert(contentsOf: "~Copyable, ", at: range.upperBound)
                    } else if let range = c.range(of: "public protocol \(protoName) {") {
                        c.replaceSubrange(range, with: "public protocol \(protoName): ~Copyable {")
                    }
                }
            }
            // BottomProtocolHandler/OneToOneProtocolHandler's own `upper` requirement really has
            // type `Self.UpperProtocol` (confirmed via swift-demangle -expand on
            // BottomProtocolHandler.upper's dispatch thunk: "A.UpperProtocol", A = Self) --
            // real, ABI-confirmed associated types genuinely missing from both protocols' own
            // reconstruction (unrelated to the ~Copyable fix above), rendered as the generic
            // `Any` fallback instead. Without it, every constrained extension on either protocol
            // referencing `Self.UpperProtocol` (e.g. "where Self.UpperProtocol ==
            // InboundDatagramLinkage") fails with "'UpperProtocol' is not a member type of type
            // 'Self'", forcing those default implementations to fall back to stubs.
            for protoName in ["BottomProtocolHandler", "OneToOneProtocolHandler"] {
                for header in ["public protocol \(protoName): ~Copyable, ", "public protocol \(protoName): "] {
                    if let colonEnd = c.range(of: header)?.upperBound,
                       let braceRange = c.range(of: " {\n", range: colonEnd..<c.endIndex) {
                        c.insert(contentsOf: "    associatedtype UpperProtocol: UpperProtocolLinkage\n", at: braceRange.upperBound)
                        break
                    }
                }
            }
            c = c.replacingOccurrences(of: "var upper: Any { get set }", with: "var upper: UpperProtocol { get set }")
            // Strip a spurious ", Self: ~Copyable" tacked onto an otherwise-valid constrained
            // extension (e.g. "extension TopProtocolHandler where Self.LowerProtocol ==
            // OutboundDatagramLinkage,  Self: ~Copyable {") -- UNLESS the extension's own
            // protocol is one we just declared `~Copyable` above (needsCopyable), in which case
            // the combined constraint is real ABI (the mangled symbol only matches when BOTH
            // clauses are present on the same extension, confirmed empirically:
            // OneToOneProtocolHandler.invokeReceiveDatagrams(maximumDatagramCount:) still needed
            // a stub after dropping just the ~Copyable clause here, even though the method itself
            // rendered fine) and dropping it would leave the extension real but ABI-mismatched.
            // For every OTHER protocol (never declared ~Copyable), the whole extension is valid
            // once this one clause is dropped; stripping the entire extension here would throw
            // away real default-method bodies.
            if let spuriousRegex = try? NSRegularExpression(
                pattern: "extension\\s+(\\S+)\\s+where\\s+([^{]*?),\\s*Self:\\s*~Copyable\\s*\\{", options: []) {
                let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                var replacements: [(Range<String.Index>, String)] = []
                for m in spuriousRegex.matches(in: c, options: [], range: nsRange) {
                    guard let fullRange = Range(m.range, in: c),
                          let nameRange = Range(m.range(at: 1), in: c),
                          let restRange = Range(m.range(at: 2), in: c) else { continue }
                    let protoName = String(c[nameRange])
                    guard !needsCopyable.contains(protoName) else { continue }
                    replacements.append((fullRange, "extension \(protoName) where \(c[restRange]) {"))
                }
                for (range, replacement) in replacements.reversed() {
                    c.replaceSubrange(range, with: replacement)
                }
            }
            // Deserializer<A>/SerializerSpanFactory/InPlaceSerializer<A>: several extensions and
            // static methods relax their generic parameter to `~Copyable`/`~Escapable` (e.g.
            // "extension Deserializer where A: ~Copyable, A: ~Escapable", Serializer.serialize's
            // "where GenericA: ~Copyable, GenericA: ~Escapable" — confirmed as real ABI via
            // `swift-demangle -expand` on Serializer.serialize's mangled symbol), but the
            // generic parameter these relax was declared as a plain unconstrained placeholder
            // (implicitly Copyable & Escapable), making the relaxation self-contradictory. Add
            // `~Copyable & ~Escapable` directly to the declarations so the relaxation is valid.
            c = c.replacingOccurrences(
                of: "public struct Deserializer<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct Deserializer<A: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public struct InPlaceSerializer<A>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct InPlaceSerializer<A: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public protocol SerializerSpanFactory {",
                with: "public protocol SerializerSpanFactory: ~Copyable, ~Escapable {")
            c = c.replacingOccurrences(
                of: "public protocol DeserializerSpanFactory {",
                with: "public protocol DeserializerSpanFactory: ~Copyable, ~Escapable {")
            // Once ~Escapable is on the protocol, a method returning a ~Escapable type
            // (RawSpan?/MutableRawSpan?) needs an explicit lifetime-dependence attribute — the
            // compiler can't infer one for a protocol requirement. "borrow self" matches the
            // real semantics (the returned span only stays valid while the factory instance
            // does); conformers don't need to redeclare the attribute themselves.
            c = c.replacingOccurrences(
                of: "    func nextSpan() -> RawSpan?",
                with: "    @_lifetime(borrow self)\n    func nextSpan() -> RawSpan?")
            c = c.replacingOccurrences(
                of: "    func nextMutableSpan() -> MutableRawSpan?",
                with: "    @_lifetime(borrow self)\n    func nextMutableSpan() -> MutableRawSpan?")
            // Same class of bug as Deserializer/Serializer above: StreamDeserializer<A, B, C>'s
            // A and C are both relaxed to ~Copyable/~Escapable by its own extensions (never B),
            // and StreamDeserializerState (used as a constraint on A in one of those
            // extensions) needs the same ~Copyable relaxation for the same reason.
            c = c.replacingOccurrences(
                of: "public struct StreamDeserializer<A, B, C>: Codable, Hashable, @unchecked Sendable {",
                with: "public struct StreamDeserializer<A: ~Copyable, B, C: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public protocol StreamDeserializerState {",
                with: "public protocol StreamDeserializerState: ~Copyable {")
        return c
    }

    static func postProcessNetworkPart2(_ code: String, parser: Parser) -> String {
        var c = code
            // Fix Swift 3 renamed types used in __C_ typealiases
            c = c.replacingOccurrences(of: "NSURLSessionTask", with: "URLSessionTask")
            c = c.replacingOccurrences(of: "NSURLSessionConfiguration", with: "URLSessionConfiguration")
            c = c.replacingOccurrences(of: "OS_dispatch_data", with: "__DispatchData")
            // MessageProtocol's real ABI declares `associatedtype Metadata` and every
            // requirement uses `Self.Metadata` (confirmed via `swift-demangle -expand` on the
            // protocol's dispatch-thunk symbols — e.g. send's witness type is literally
            // "metadata: A.Metadata"), but the generic-placeholder eraser replaced every
            // `Self.Metadata` in the protocol's own declaration with `Any` (it can't tell an
            // associated-type-of-Self reference from an unresolvable demangler path — same
            // class of bug as the ActorSystem `Self.ActorID == Act.ID` fix above). The
            // extension's default implementations already use the correct `Self.Metadata`
            // form, so once the protocol itself declares the associated type, every conformer's
            // ContentType/Metadata/LegacyMessage becomes inferable from receive/map alone, and
            // the extension's defaults satisfy send/makeIncomingMessage/mapLegacy even where a
            // conformer's own overloads (using `Any` or a concrete non-Metadata type from a
            // separate generator bug) don't match.
            // Member order inside the protocol body is not stable across generator runs
            // (dictionary iteration order), so a whole-block exact-string match is fragile —
            // scope the "metadata: Any" -> "metadata: Self.Metadata" replacement and the
            // associatedtype insertion to just this protocol's brace range instead.
            if let headerRange = c.range(of: "public protocol MessageProtocol: OneToOneProtocol {") {
                var depth = 1
                var idx = headerRange.upperBound
                var bodyEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { bodyEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                var body = String(c[headerRange.upperBound..<bodyEnd])
                body = body.replacingOccurrences(of: "metadata: Any", with: "metadata: Self.Metadata")
                body += "    associatedtype Metadata\n"
                c.replaceSubrange(headerRange.upperBound..<bodyEnd, with: body)
            }
            // StreamProtocol's real ABI likewise declares `associatedtype Metadata` (confirmed
            // via `swift-demangle` on its dispatch-thunk symbols, e.g. send's parameter type
            // demangles as "metadata: A.Metadata") and every requirement already correctly uses
            // `Self.Metadata` (no `Any`-erasure to fix here, unlike MessageProtocol above) — the
            // only missing piece is the associatedtype declaration itself.
            if let headerRange = c.range(of: "public protocol StreamProtocol: OneToOneProtocol {") {
                var depth = 1
                var idx = headerRange.upperBound
                var bodyEnd = idx
                while idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 }
                    else if c[idx] == "}" { depth -= 1; if depth == 0 { bodyEnd = idx; break } }
                    idx = c.index(after: idx)
                }
                let body = String(c[headerRange.upperBound..<bodyEnd]) + "    associatedtype Metadata\n"
                c.replaceSubrange(headerRange.upperBound..<bodyEnd, with: body)
            }
            // JSON's generic-parameter discovery missed its own declaration — every member
            // (map/receive/send/mapLegacy/Metadata) references "JSON<A>" but the struct itself
            // was emitted non-generic ("public struct JSON: MessageProtocol, ..."), confirmed
            // generic via the ABI (every real use site is "JSON<A>", e.g. Connection1's
            // receiveOnce/receiveMessage symbols demangle to JSON<A>).
            c = c.replacingOccurrences(
                of: "public struct JSON: MessageProtocol, OneToOneProtocol {",
                with: "public struct JSON<A>: MessageProtocol, OneToOneProtocol {")
            // JSON.receive's real ABI returns "content: A" (JSON's own generic parameter, per
            // `swift-demangle`), not a second unrelated `Any` — same generic-placeholder-erasure
            // bug as elsewhere in this file, just on a bound-generic-self reference instead of
            // an associated type.
            c = c.replacingOccurrences(
                of: "public static func receive<GenericA>(connection: GenericA) async throws -> (content: Any, metadata: JSON<Any>.Metadata) where GenericA: ConnectionProtocol { fatalError() }",
                with: "public static func receive<GenericA>(connection: GenericA) async throws -> (content: A, metadata: JSON<A>.Metadata) where GenericA: ConnectionProtocol { fatalError() }")
            // StreamDeserializationBuilder is the @resultBuilder type for StreamDeserializer.
            // The generator emitted it as a plain non-generic struct, but its sole extension
            // uses `A` and `C` freely (as in StreamDeserializer<A, Any, C>), producing 20
            // "cannot find type 'A' in scope" errors.  Fix: add `@resultBuilder` and make
            // the declaration generic <A: ~Copyable, C: ~Copyable & ~Escapable> to match.
            c = c.replacingOccurrences(
                of: "public struct StreamDeserializationBuilder: Codable, Hashable, @unchecked Sendable {",
                with: "@resultBuilder public struct StreamDeserializationBuilder<A: ~Copyable, C: ~Copyable & ~Escapable>: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: StreamDeserializationBuilder, _ rhs: StreamDeserializationBuilder) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: StreamDeserializationBuilder<A, C>, _ rhs: StreamDeserializationBuilder<A, C>) -> Bool { fatalError() }")
            c = c.replacingOccurrences(
                of: "extension StreamDeserializationBuilder {",
                with: "extension StreamDeserializationBuilder where A: StreamDeserializerState {")
            // Fix 9: `TLVFramer` is a non-final class conforming to `NWProtocolFramerImplementation`
            // which requires `init(framer:)`.  Protocol init requirements must be `required` in
            // non-final classes.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class TLVFramer: NWProtocolFramerImplementation {\n    public init(framer: NWProtocolFramer.Instance)",
                with: "@_fixed_layout public class TLVFramer: NWProtocolFramerImplementation {\n    public required init(framer: NWProtocolFramer.Instance)")
            // Fix 10: `NetworkBrowser<A>.RunResult` is a plain (non-generic) enum, but the
            // `run<GenericA>` method was emitted with `RunResult<GenericA>` — strip the type arg.
            c = c.replacingOccurrences(
                of: "NetworkBrowser<A>.RunResult<GenericA>",
                with: "NetworkBrowser<A>.RunResult")
            // discoveredNestedGenericPairs (Parser.swift's precompute()) sees the real ABI's
            // "NetworkBrowser<A>.RunResult<A1>" case-witness symbols and correctly records
            // RunResult as taking 1 own generic param — but this codebase's established
            // workaround (above) keeps RunResult itself non-generic and instead lets its
            // `finish(_:)` payload fall back to the global opaque `A1` placeholder struct.
            // Undo the now-generic declaration/use-sites this produces so that workaround still
            // applies cleanly.
            c = c.replacingOccurrences(
                of: "public enum RunResult<B>: Codable, Hashable, @unchecked Sendable {",
                with: "public enum RunResult: Codable, Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: RunResult<Any>, _ rhs: RunResult<Any>) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: RunResult, _ rhs: RunResult) -> Bool { fatalError() }")
            // Fix 11: `QUIC.TLS` (nested) and top-level `TLS` are two different structs.
            // `PeerAuthentication` lives in the top-level `TLS`; methods inside `QUIC.TLS` reference
            // `TLS.PeerAuthentication` which Swift resolves as `QUIC.TLS.PeerAuthentication` — but
            // that nested type doesn't exist.  The struct declaration line is stable and unique;
            // inject a typealias right after the opening brace.
            c = c.replacingOccurrences(
                of: "    public struct TLS: Codable, Hashable, @unchecked Sendable {\n",
                with: "    public struct TLS: Codable, Hashable, @unchecked Sendable {\n        public typealias PeerAuthentication = Network.TLS.PeerAuthentication\n")
            // Fix 12: Same demangler artifact as fix 8 but for `MultiplexingPath`.
            // `Self.Path.MultiplexingPath.ParentProtocol` → `Self.Path.ParentProtocol`.
            c = c.replacingOccurrences(
                of: "Self == Self.Path.MultiplexingPath.ParentProtocol",
                with: "Self == Self.Path.ParentProtocol")
            // Fix 8: The demangler emits `Self.Flow.MultiplexedFlow.ParentProtocol` (and the
            // `SecondaryFlow` variant) as extension constraints.  `MultiplexedFlow` here is the
            // *protocol* the flow conforms to, not a nested type — Swift can't resolve it as a
            // member type on `Self.Flow`.  The real semantic is `Self == Self.Flow.ParentProtocol`
            // (since `MultiplexedFlow` declares `associatedtype ParentProtocol: ManyToManyProtocolHandler`).
            // Strip the spurious `.MultiplexedFlow` path component from both variants.
            c = c.replacingOccurrences(
                of: "Self == Self.Flow.MultiplexedFlow.ParentProtocol",
                with: "Self == Self.Flow.ParentProtocol")
            c = c.replacingOccurrences(
                of: "Self == Self.SecondaryFlow.MultiplexedFlow.ParentProtocol",
                with: "Self == Self.SecondaryFlow.ParentProtocol")
            // Fix 7: `Frame` is `~Copyable`, so all parameters of type `Frame` must specify
            // ownership.  Three sites omit the keyword:
            //   1. `init(frame: Frame)` — borrowing (init just reads the frame to copy data)
            //   2. `peekFirstFrame<GenericA>(_ arg1: (Frame) -> GenericA)` — closure takes Frame
            //      by borrowing reference
            //   3. `iterateImmutableFrames(_ arg1: (Frame) -> Bool)` — same
            c = c.replacingOccurrences(of: "public init(frame: Frame)", with: "public init(frame: borrowing Frame)")
            c = c.replacingOccurrences(
                of: "public func peekFirstFrame<GenericA>(_ arg1: (Frame) -> GenericA)",
                with: "public func peekFirstFrame<GenericA>(_ arg1: (borrowing Frame) -> GenericA)")
            c = c.replacingOccurrences(
                of: "public func iterateImmutableFrames(_ arg1: (Frame) -> Swift.Bool)",
                with: "public func iterateImmutableFrames(_ arg1: (borrowing Frame) -> Swift.Bool)")
            // Fix 6: `NWBrowser`, `NWConnection`, and `NWParameters` are NSObject subclasses.
            // Their first extension blocks emit `public final var debugDescription` without
            // `override`, and `NWParameters` emits `convenience init()` without `override`.
            // Use a brace-depth-aware pass to only patch inside the FIRST matching extension.
            do {
                var lines = c.components(separatedBy: "\n")
                var inNWClass = ""
                var depth = 0
                var firstSeenForClass = Set<String>()
                for i in 0..<lines.count {
                    let line = lines[i]
                    let stripped = line.trimmingCharacters(in: .whitespaces)
                    // Track entering/leaving extension blocks
                    let opens = line.filter { $0 == "{" }.count
                    let closes = line.filter { $0 == "}" }.count
                    if depth == 0 {
                        if stripped.hasPrefix("extension NWBrowser") { inNWClass = "NWBrowser"; depth += opens - closes; continue }
                        if stripped.hasPrefix("extension NWConnection") { inNWClass = "NWConnection"; depth += opens - closes; continue }
                        if stripped.hasPrefix("extension NWParameters") { inNWClass = "NWParameters"; depth += opens - closes; continue }
                        inNWClass = ""
                    } else {
                        depth += opens - closes
                        if depth <= 0 { depth = 0; inNWClass = "" }
                    }
                    guard !inNWClass.isEmpty else { continue }
                    // Only patch the first occurrence of debugDescription in each class
                    if line.contains("public final var debugDescription: Swift.String") && !line.contains("override") {
                        if !firstSeenForClass.contains(inNWClass + ".debugDescription") {
                            firstSeenForClass.insert(inNWClass + ".debugDescription")
                            lines[i] = line.replacingOccurrences(
                                of: "public final var debugDescription:",
                                with: "public final override var debugDescription:")
                        }
                    }
                    if line.contains("@nonobjc public convenience init()") && !line.contains("override") {
                        lines[i] = line.replacingOccurrences(
                            of: "@nonobjc public convenience init()",
                            with: "@nonobjc public override convenience init()")
                    }
                }
                c = lines.joined(separator: "\n")
            }
            // Three protocols use `Self.UpperProtocol` without declaring the associatedtype,
            // and member ordering in the generated output varies across runs so we can't match
            // the full protocol body. Use stable anchor strings instead.
            // 1. BottomProtocolHandler: its extensions constrain `Self.UpperProtocol == Inbound*`
            //    but the protocol body only has `var upper: Any`.  Insert the associatedtype
            //    right after the opening brace, and retype `var upper: Any` → `Self.UpperProtocol`.
            c = c.replacingOccurrences(
                of: "public protocol BottomProtocolHandler: OutboundDataHandler {\n",
                with: "public protocol BottomProtocolHandler: OutboundDataHandler {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // Replace the erased `var upper: Any` with the properly typed version. Member
            // ordering in the generated output varies across runs, so locate the protocol body's
            // own brace span first and only replace `var upper: Any` WITHIN that span — a plain
            // whole-file replacingOccurrences would also hit LowerHarness's real class property
            // (same "var upper: Any" text, different declaration) elsewhere in the file.
            if let bodyStart = c.range(of: "public protocol BottomProtocolHandler: OutboundDataHandler {\n"),
               let bodyEnd = c.range(of: "\n}", range: bodyStart.upperBound..<c.endIndex) {
                let body = String(c[bodyStart.upperBound..<bodyEnd.lowerBound])
                let fixedBody = body.replacingOccurrences(
                    of: "var upper: Any { get set }",
                    with: "var upper: Self.UpperProtocol { get set }")
                c.replaceSubrange(bodyStart.upperBound..<bodyEnd.lowerBound, with: fixedBody)
            }
            // 2. MultiplexedFlow: insert `associatedtype UpperProtocol` after the opening brace.
            c = c.replacingOccurrences(
                of: "public protocol MultiplexedFlow: LoggableProtocol {\n",
                with: "public protocol MultiplexedFlow: LoggableProtocol {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // 3. ManyToManyProtocolHandler: insert `associatedtype UpperProtocol` right after
            //    its opening brace (stable position, not dependent on member order).
            c = c.replacingOccurrences(
                of: "public protocol ManyToManyProtocolHandler: ListenerHandler, LoggableProtocol {\n",
                with: "public protocol ManyToManyProtocolHandler: ListenerHandler, LoggableProtocol {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // OneToOneProtocolHandler extensions also constrain Self.UpperProtocol — same fix.
            c = c.replacingOccurrences(
                of: "public protocol OneToOneProtocolHandler: InboundDataHandler, LoggableProtocol, OutboundDataHandler {\n",
                with: "public protocol OneToOneProtocolHandler: InboundDataHandler, LoggableProtocol, OutboundDataHandler {\n    associatedtype UpperProtocol: UpperProtocolLinkage\n")
            // ProtocolLinkage's `associatedtype PairedLinkage` is narrowed at every level of the
            // Inbound/Outbound/Upper/Lower/Listener/Flow linkage hierarchy (confirmed via
            // `swift-demangle` on each protocol's "associated conformance descriptor" symbol,
            // e.g. InboundDataLinkage.ProtocolLinkage.PairedLinkage: OutboundDataLinkage) — but
            // the generator emitted each narrowing as an orphaned nested protocol inside its own
            // throwaway "<Name>_Network { public protocol ProtocolLinkage { associatedtype
            // PairedLinkage: ... } }" wrapper struct instead of directly in the real protocol's
            // body, so the narrowing never actually applies. Move each into its real protocol.
            for (protoName, pairedType) in [
                ("InboundDataLinkage", "OutboundDataLinkage"),
                ("InboundFlowLinkage", "ListenerLinkage"),
                ("ListenerLinkage", "InboundFlowLinkage"),
                ("LowerProtocolLinkage", "UpperProtocolLinkage"),
                ("OutboundDataLinkage", "InboundDataLinkage"),
                ("UpperProtocolLinkage", "LowerProtocolLinkage"),
            ] {
                if let r = c.range(of: "public protocol \(protoName): ") {
                    if let braceEnd = c.range(of: " {", range: r.upperBound..<c.endIndex) {
                        c.insert(contentsOf: "\n    associatedtype PairedLinkage: \(pairedType)", at: braceEnd.upperBound)
                    }
                }
            }
            // LowerProtocolLinkage.invokeAttachUpperProtocol's real ABI returns `Self` (its
            // dispatch-thunk demangles to "...) throws(NetworkError) -> A" where A is the
            // protocol's own Self placeholder), but the generic-placeholder eraser replaced it
            // with `Any` on every conformer (DatagramListenerLinkage/OutboundDatagramLinkage/
            // OutboundStreamLinkage/StreamListenerLinkage) — `Self` is safe to substitute
            // directly since it resolves per-conforming-type automatically.
            c = c.replacingOccurrences(
                of: "public func invokeAttachUpperProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Any { fatalError() }",
                with: "public func invokeAttachUpperProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Self { fatalError() }")
            // ListenerLinkage's own two requirements have the identical `Any`-erasure bug:
            // their dispatch thunks demangle to "-> A.PairedLinkage.DataLinkage" (A is the
            // protocol's own Self), i.e. the real return type projects through the associated
            // type chain (PairedLinkage: InboundFlowLinkage, which declares `associatedtype
            // DataLinkage: OutboundDataLinkage`), not a bare erased `Any`.
            c = c.replacingOccurrences(
                of: "func invokeAttachUpperProtocolToExistingFlow(_ arg1: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> Any",
                with: "func invokeAttachUpperProtocolToExistingFlow(_ arg1: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> Self.PairedLinkage.DataLinkage")
            c = c.replacingOccurrences(
                of: "func invokeAttachUpperProtocolToNewFlow(_ arg1: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Any",
                with: "func invokeAttachUpperProtocolToNewFlow(_ arg1: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Self.PairedLinkage.DataLinkage")
            // Same `Any`-erasure bug on the default-implementation extension and on both
            // concrete conformers (DatagramListenerLinkage/StreamListenerLinkage), which have
            // no associated types so the placeholder resolves to a concrete type on each.
            c = c.replacingOccurrences(
                of: "extension ListenerLinkage {\n    public func invokeAttachUpperProtocolToExistingFlow(_ arg1: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> Any { fatalError() }\n    public func invokeAttachUpperProtocolToNewFlow(_ arg1: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Any { fatalError() }\n}",
                with: "extension ListenerLinkage {\n    public func invokeAttachUpperProtocolToExistingFlow(_ arg1: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> Self.PairedLinkage.DataLinkage { fatalError() }\n    public func invokeAttachUpperProtocolToNewFlow(_ arg1: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Self.PairedLinkage.DataLinkage { fatalError() }\n}")
            for (structName, dataLinkage) in [
                ("DatagramListenerLinkage", "OutboundDatagramLinkage"),
                ("StreamListenerLinkage", "OutboundStreamLinkage"),
            ] {
                if let bodyStart = c.range(of: "public struct \(structName): ListenerLinkage, LowerProtocolLinkage, ProtocolLinkage {\n"),
                   let bodyEnd = c.range(of: "\n}", range: bodyStart.upperBound..<c.endIndex) {
                    let body = String(c[bodyStart.upperBound..<bodyEnd.lowerBound])
                    let fixedBody = body
                        .replacingOccurrences(
                            of: "func invokeAttachUpperProtocolToExistingFlow(_ arg1: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> Any",
                            with: "func invokeAttachUpperProtocolToExistingFlow(_ arg1: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> \(dataLinkage)")
                        .replacingOccurrences(
                            of: "func invokeAttachUpperProtocolToNewFlow(_ arg1: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> Any",
                            with: "func invokeAttachUpperProtocolToNewFlow(_ arg1: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> \(dataLinkage)")
                    c.replaceSubrange(bodyStart.upperBound..<bodyEnd.lowerBound, with: fixedBody)
                }
            }
            // None of the 8 concrete *Linkage structs declare their own PairedLinkage
            // typealias, and nothing in their member signatures pins it down uniquely (the
            // members that DO reference the paired type, e.g. InboundDatagramLinkage's own
            // deliver* methods don't mention it at all — only sibling types like
            // OutboundDatagramLinkage's attachUpper* methods reference it by name), so it's
            // not inferable. Add explicit typealiases; pairing follows the Datagram<->Datagram/
            // Stream<->Stream naming convention consistently used throughout this hierarchy.
            for (name, paired) in [
                ("InboundDatagramLinkage", "OutboundDatagramLinkage"),
                ("InboundStreamLinkage", "OutboundStreamLinkage"),
                ("InboundDatagramFlowLinkage", "DatagramListenerLinkage"),
                ("InboundStreamFlowLinkage", "StreamListenerLinkage"),
                ("OutboundDatagramLinkage", "InboundDatagramLinkage"),
                ("OutboundStreamLinkage", "InboundStreamLinkage"),
                ("DatagramListenerLinkage", "InboundDatagramFlowLinkage"),
                ("StreamListenerLinkage", "InboundStreamFlowLinkage"),
            ] {
                if let r = c.range(of: "public struct \(name): "), let braceEnd = c.range(of: " {", range: r.upperBound..<c.endIndex) {
                    c.insert(contentsOf: "\n    public typealias PairedLinkage = \(paired)", at: braceEnd.upperBound)
                }
            }
            // Configuration/Connection1-5/Listener1-6's second generic parameter `B` is a real
            // parameter pack, not a plain type — confirmed via `swift-demangle -expand` on their
            // ABI symbols (e.g. Connection1.init(to:using:) demangles to
            // "Configuration<A, Pack{repeat B}>", and the == operator to
            // "(Connection1<A, Pack{repeat B}>, Connection1<A, Pack{repeat B}>) -> Bool"). The
            // generator emitted the declaration as plain `<A, B>` and every use of "repeat B"
            // without the required "each" binding — hence "pack expansion 'B' must contain at
            // least one pack reference". Also erased every *bound* two-argument use site's
            // second slot to a bare `Any` (e.g. "Connection1<A, Any>", "Connection1<TLV, Any>")
            // since a pack argument list can't collapse to one placeholder name the same way a
            // plain generic can.
            for name in ["Configuration", "Connection1", "Connection2", "Connection3", "Connection4", "Connection5", "Listener1", "Listener2", "Listener3", "Listener4", "Listener5", "Listener6", "Listener7", "SendProgress"] {
                c = c.replacingOccurrences(of: "\(name)<A, B>", with: "\(name)<A, each B>")
                // Bound two-argument use sites: "<X, Any>" -> "<X, repeat each B>" for any first
                // argument (the class's own `A`, or a concrete type substituted for it, e.g.
                // "Connection1<TLV, Any>" inside a `where A == TLV` method).
                if let regex = try? NSRegularExpression(pattern: "\(name)<([^,<>]+), Any>", options: []) {
                    c = regex.stringByReplacingMatches(
                        in: c, range: NSRange(c.startIndex..<c.endIndex, in: c),
                        withTemplate: "\(name)<$1, repeat each B>")
                }
            }
            c = c.replacingOccurrences(of: "repeat B)", with: "repeat each B)")
            c = c.replacingOccurrences(of: "repeat B,", with: "repeat each B,")
            // NWParametersBuilder<A, B>'s `B` is also a pack (its own init(auto:)/init(_:) use
            // "repeat B", fixed by the two global replacements above). Its declaration and its
            // own two static `parameters(...)` factory methods (which return
            // "NWParametersBuilder<A, Any>" from *inside* NWParametersBuilder's own body, where
            // `B` is in scope) need "<A, each B>"/"<A, repeat each B>" respectively — but the 26
            // other "NWParametersBuilder<A, Any>" occurrences are all *external* call sites
            // (e.g. inside Connection6<A>/Connection7<A>/NWListener<A>) that each declare their
            // own local pack under a different name, always "A1" per a sibling
            // "() -> (A, repeat A1)" init in the very same type — confirmed by checking every
            // occurrence's surrounding declaration. Fix the struct's own declaration and its
            // two internal call sites first (unique strings), then treat every remaining
            // occurrence as an external call site using "A1".
            c = c.replacingOccurrences(of: "NWParametersBuilder<A, B>", with: "NWParametersBuilder<A, each B>")
            c = c.replacingOccurrences(
                of: "public static func parameters(initialParameters: NWParameters, _: () -> (A, repeat each B)) -> NWParametersBuilder<A, Any> { fatalError() }",
                with: "public static func parameters(initialParameters: NWParameters, _: () -> (A, repeat each B)) -> NWParametersBuilder<A, repeat each B> { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func parameters(_ arg1: () -> (A, repeat each B)) -> NWParametersBuilder<A, Any> { fatalError() }",
                with: "public static func parameters(_ arg1: () -> (A, repeat each B)) -> NWParametersBuilder<A, repeat each B> { fatalError() }")
            // Of the remaining call sites, only lines that also declare a local `<A1>` pack (a
            // sibling "() -> (A, repeat A1)" init in the same type) can use "repeat A1"; the
            // rest (NetworkListener<A>, withNetworkConnection<A>, NetworkConnection<A>
            // extensions — none of which declare any pack at all) collapse the argument to a
            // plain "NWParametersBuilder<A>", matching the already-valid empty-pack usage seen
            // elsewhere (e.g. "Configuration<A>").
            // A pre-existing bug (present in the raw generator output before any of this file's
            // Network fixes): these `init<A1>(..., using: () -> (A, repeat A1)) where A1: ...`
            // overloads already used "repeat A1" without ever binding "<A1>" as "<each A1>" —
            // the per-signature pack-detection pass in Model.swift didn't catch it because A1
            // isn't one of the placeholders ["A"..."G"] it scans for. Fix both the generic
            // parameter list and the repeat-expression on any line matching this pattern before
            // deciding whether a given NWParametersBuilder<A, Any> call site can reuse "A1".
            let networkParamsBuilderLines = c.components(separatedBy: "\n").map { line -> String in
                var fixedLine = line
                if fixedLine.contains("<A1>") && fixedLine.contains("repeat A1") {
                    fixedLine = fixedLine.replacingOccurrences(of: "<A1>", with: "<each A1>")
                    fixedLine = fixedLine.replacingOccurrences(of: "repeat A1", with: "repeat each A1")
                    // The `where A1: Protocol` constraint also references the pack itself and
                    // needs the same "repeat each" expansion keyword as any other pack
                    // reference — "where A1: X" is invalid once A1 is a pack, it must read
                    // "where repeat each A1: X".
                    fixedLine = fixedLine.replacingOccurrences(of: "where A1: ", with: "where repeat each A1: ")
                }
                guard fixedLine.contains("NWParametersBuilder<A, Any>") else { return fixedLine }
                if fixedLine.contains("<each A1>") {
                    return fixedLine.replacingOccurrences(of: "NWParametersBuilder<A, Any>", with: "NWParametersBuilder<A, repeat each A1>")
                }
                return fixedLine.replacingOccurrences(of: "NWParametersBuilder<A, Any>", with: "NWParametersBuilder<A>")
            }
            c = networkParamsBuilderLines.joined(separator: "\n")
            // After the NWParametersBuilder<A, Any> → NWParametersBuilder<A> collapse above,
            // lines like `init<A1>(to:, using: NWParametersBuilder<A>) where A1: NetworkProtocolOptions`
            // now have an orphaned `<A1>` generic param that never appears in the parameter
            // types — only in the (now-stale) where clause.  The compiler flags these as
            // [#NoUsage].  Strip the param and where clause entirely.
            c = c.components(separatedBy: "\n").map { line -> String in
                guard line.contains("<A1>") && line.contains("NWParametersBuilder") &&
                      !line.contains("repeat") && line.contains("where A1:") else { return line }
                var l = line
                l = l.replacingOccurrences(of: "<A1>", with: "")
                // Strip trailing " where A1: SomeProtocol" or " where A1: P1,  A1: P2"
                if let whereRange = l.range(of: " where A1:") {
                    l = String(l[..<whereRange.lowerBound]) + " { fatalError() }"
                    // Remove duplicate " { fatalError() } { fatalError() }" if present
                    l = l.replacingOccurrences(of: " { fatalError() } { fatalError() }", with: " { fatalError() }")
                    // Same for throws variants
                    l = l.replacingOccurrences(of: " throws { fatalError() } { fatalError() }", with: " throws { fatalError() }")
                }
                return l
            }.joined(separator: "\n")
            // Same pre-existing "repeat X without each" bug as above, on the `GenericA,
            // GenericB` placeholder pair Model.swift's generic-rename pass produces for
            // originally-anonymous type parameters, plus ProtocolStackBuilder.buildBlock where
            // the pack name itself was erased to a bare "Any" (confirmed via `swift-demangle
            // -expand`: real signature is "buildBlock<A, each B>(A, repeat each B) -> (A, repeat
            // each B)").
            c = c.replacingOccurrences(
                of: "public final func prependProtocols<GenericA, GenericB>(_ arg1: () -> (GenericA, repeat GenericB)) -> Connection7<GenericA> where GenericA: OneToOneProtocol,  GenericB: NetworkProtocolOptions { fatalError() }",
                with: "public final func prependProtocols<GenericA, each GenericB>(_ arg1: () -> (GenericA, repeat each GenericB)) -> Connection7<GenericA> where GenericA: OneToOneProtocol, repeat each GenericB: NetworkProtocolOptions { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func template<GenericA, GenericB>(_ arg1: @escaping () -> (GenericA, repeat GenericB)) -> () -> NWParametersBuilder<GenericA, Any> where GenericA: NetworkProtocolOptions,  GenericB: NetworkProtocolOptions { fatalError() }",
                with: "public static func template<GenericA, each GenericB>(_ arg1: @escaping () -> (GenericA, repeat each GenericB)) -> () -> NWParametersBuilder<GenericA, repeat each GenericB> where GenericA: NetworkProtocolOptions, repeat each GenericB: NetworkProtocolOptions { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func buildBlock(_ arg1: Any, _ arg2: repeat Any) -> (Any, repeat Any) { fatalError() }",
                with: "public static func buildBlock<GenericA, each GenericB>(_ arg1: GenericA, _ arg2: repeat each GenericB) -> (GenericA, repeat each GenericB) { fatalError() }")
            // NWActorID/NetworkActorID: DistributedActorSystem.ActorID requires `Hashable,
            // Sendable`; the generator only sees the demangled Codable/CustomStringConvertible/
            // Hashable conformances (Sendable is implicit-only in the ABI, no witness table
            // entry to detect it from).
            c = c.replacingOccurrences(
                of: "public struct NWActorID: Codable, CustomStringConvertible, Hashable {",
                with: "public struct NWActorID: Codable, CustomStringConvertible, Hashable, Sendable {")
            c = c.replacingOccurrences(
                of: "public struct NetworkActorID: Codable, CustomStringConvertible, Hashable {",
                with: "public struct NetworkActorID: Codable, CustomStringConvertible, Hashable, Sendable {")
            // NWActivity/NWFileTransferDelegate are held in TaskLocal<...>, which requires its
            // Value to be Sendable — same ABI-invisibility issue as above.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class NWActivity: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Equatable {",
                with: "@_fixed_layout public class NWActivity: CustomDebugStringConvertible, CustomPlaygroundDisplayConvertible, CustomStringConvertible, Equatable, @unchecked Sendable {")
            c = c.replacingOccurrences(
                of: "public protocol NWFileTransferDelegate {",
                with: "public protocol NWFileTransferDelegate: Sendable {")
            // Distributed.DistributedActorSystem conformances (NWActorSystem/NetworkActorSystem):
            // 1. recordArgument/recordReturnType/decodeNextArgument witness `mutating func`
            //    protocol requirements (their conforming types are structs) — the generator
            //    emits plain `func`, which the compiler treats as a non-matching candidate.
            c = c.replacingOccurrences(
                of: "public func recordArgument<GenericA>(_ arg1: Distributed.RemoteCallArgument<GenericA>) throws -> () where GenericA: Decodable,  GenericA: Encodable {}",
                with: "public mutating func recordArgument<GenericA>(_ arg1: Distributed.RemoteCallArgument<GenericA>) throws -> () where GenericA: Decodable,  GenericA: Encodable {}")
            c = c.replacingOccurrences(
                of: "public func recordReturnType<GenericA>(_ arg1: GenericA.Type) throws -> () where GenericA: Decodable,  GenericA: Encodable {}",
                with: "public mutating func recordReturnType<GenericA>(_ arg1: GenericA.Type) throws -> () where GenericA: Decodable,  GenericA: Encodable {}")
            c = c.replacingOccurrences(
                of: "public func decodeNextArgument<GenericA>() throws -> GenericA where GenericA: Decodable,  GenericA: Encodable { fatalError() }",
                with: "public mutating func decodeNextArgument<GenericA>() throws -> GenericA where GenericA: Decodable,  GenericA: Encodable { fatalError() }")
            // 2. remoteCall/remoteCallVoid's real ABI constrains `Self.ActorID == Act.ID`
            //    (visible in the demangled symbol), but the generic-placeholder eraser drops it
            //    since it can't tell an associated-type-of-Self reference from an unresolvable
            //    demangler path — leaving these as "missing witness for protocol requirement".
            c = c.replacingOccurrences(
                of: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable { fatalError() }",
                with: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable, GenericA.ID == NWActorID { fatalError() }")
            c = c.replacingOccurrences(
                of: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error {}",
                with: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NWActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error, GenericA.ID == NWActorID {}")
            c = c.replacingOccurrences(
                of: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable { fatalError() }",
                with: "public final func remoteCall<GenericA, GenericB, GenericC>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type, returning: GenericC.Type) async throws -> GenericC where GenericA: Distributed.DistributedActor,  GenericB: Error,  GenericC: Decodable,  GenericC: Encodable, GenericA.ID == NetworkActorID { fatalError() }")
            c = c.replacingOccurrences(
                of: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error {}",
                with: "public final func remoteCallVoid<GenericA, GenericB>(on: GenericA, target: Distributed.RemoteCallTarget, invocation: inout NetworkActorSystemInvocationEncoder, throwing: GenericB.Type) async throws -> () where GenericA: Distributed.DistributedActor,  GenericB: Error, GenericA.ID == NetworkActorID {}")
            // 3. None of the 4 protocols' associated types (ActorID/InvocationEncoder/
            //    InvocationDecoder/ResultHandler on DistributedActorSystem,
            //    SerializationRequirement on all 4) can be inferred without an explicit
            //    typealias — nothing in the generated members' signatures pins them down
            //    uniquely (e.g. `resolve`'s `GenericA.Type` is generic, not concretely
            //    NWActorID). Missing inference cascades into "missing witness" for every
            //    requirement, even ones with a correctly-typed candidate already present.
            //    The class must also be `final` — DistributedActorSystem requires Sendable,
            //    and a non-final class can't conform to Sendable.
            for (systemName, idName, encName, decName, resultName) in [
                ("NWActorSystem", "NWActorID", "NWActorSystemInvocationEncoder", "NWActorSystemInvocationDecoder", "NWActorSystemResultHandler"),
                ("NetworkActorSystem", "NetworkActorID", "NetworkActorSystemInvocationEncoder", "NetworkActorSystemInvocationDecoder", "NetworkActorSystemResultHandler"),
            ] {
                c = c.replacingOccurrences(
                    of: "@_fixed_layout public class \(systemName): Distributed.DistributedActorSystem {",
                    with: """
                    @_fixed_layout final public class \(systemName): Distributed.DistributedActorSystem {
                        public typealias ActorID = \(idName)
                        public typealias InvocationEncoder = \(encName)
                        public typealias InvocationDecoder = \(decName)
                        public typealias ResultHandler = \(resultName)
                        public typealias SerializationRequirement = Codable
                    """)
                c = c.replacingOccurrences(
                    of: "public struct \(encName): Distributed.DistributedTargetInvocationEncoder {",
                    with: "public struct \(encName): Distributed.DistributedTargetInvocationEncoder {\n    public typealias SerializationRequirement = Codable")
                c = c.replacingOccurrences(
                    of: "public struct \(decName): Distributed.DistributedTargetInvocationDecoder {",
                    with: "public struct \(decName): Distributed.DistributedTargetInvocationDecoder {\n    public typealias SerializationRequirement = Codable")
                c = c.replacingOccurrences(
                    of: "public struct \(resultName): Distributed.DistributedTargetInvocationResultHandler {",
                    with: "public struct \(resultName): Distributed.DistributedTargetInvocationResultHandler {\n    public typealias SerializationRequirement = Codable")
            }
            // `@escaping @isolated(any) @Sendable` on a closure parameter is rejected by
            // Swift 6 with "'@escaping' only applies to function types" — the `@isolated(any)`
            // attribute makes the closure type non-function from the compiler's perspective in
            // this position. Strip `@isolated(any)` globally from Network (our stubs don't need
            // isolation semantics, and the ABI shape is preserved without it).
            c = c.replacingOccurrences(of: "@escaping @isolated(any) @Sendable", with: "@escaping @Sendable")
            c = c.replacingOccurrences(of: "@isolated(any) @Sendable", with: "@Sendable")
            // nw_storage_* are free C-wrapper functions. Their closure parameters were
            // emitted with two problems:
            // 1. Double `@escaping @escaping` (generator adds @escaping, C demangle adds another)
            // 2. `@convention(block) (...)` — some params (OS_nw_array, DispatchData, etc.) are
            //    not ObjC-representable so they can't be block params.
            // Fix: strip @escaping @convention(block) broadly from any @escaping @escaping pattern
            // so the closure becomes a plain Swift function type.
            if let regex = try? NSRegularExpression(
                pattern: #"@escaping @escaping @convention\(block\) "#,
                options: [])
            {
                c = regex.stringByReplacingMatches(
                    in: c,
                    range: NSRange(c.startIndex..<c.endIndex, in: c),
                    withTemplate: "")
            }
            // Also strip standalone double @escaping (without @convention(block))
            c = c.replacingOccurrences(of: "@escaping @escaping ", with: "@escaping ")
            // NetworkBrowser.run<GenericA> takes an `async throws` closure — `@escaping` on
            // an `async` closure parameter is invalid in Swift 6 in this position.  Drop it.
            c = c.replacingOccurrences(
                of: "@escaping @Sendable ([Any]) async throws ->",
                with: "@Sendable ([Any]) async throws ->")
            // Fix: every OS_nw_*/OS_sec_* "C/system type" is a real ObjC *protocol* in the real
            // ABI (Apple's os_object-style `OS_OBJECT_DECL` types, e.g. `nw_parameters_t` ==
            // `NSObject<OS_nw_parameters> *`), not a class -- confirmed via swift-demangle on
            // every stub referencing one: each mangles as a `ProtocolList`/existential ("_p"
            // suffix), never a class reference ("C" suffix). Same root cause as SoundAnalysis's
            // SNRequest/SNResult fix. Rename every bare reference to the existential form; the
            // types themselves are forward-declared as real `@protocol`s in the bridge header
            // (see the Network-specific block in `writeGeneratedFiles`/generateExports above),
            // not declared here as native Swift protocols -- a native declaration would mangle
            // under the Network module instead of `__C` and never match.
            for name in ["OS_nw_application_id", "OS_nw_array", "OS_nw_browse_descriptor",
                         "OS_nw_connection", "OS_nw_connection_group",
                         "OS_nw_connection_progress_report", "OS_nw_content_context",
                         "OS_nw_context", "OS_nw_endpoint", "OS_nw_error", "OS_nw_frame",
                         "OS_nw_group_descriptor", "OS_nw_interface", "OS_nw_listener",
                         "OS_nw_parameters", "OS_nw_path", "OS_nw_path_monitor",
                         "OS_nw_protocol_definition", "OS_nw_protocol_metadata",
                         "OS_nw_protocol_options", "OS_nw_proxy_config", "OS_nw_txt_record",
                         "OS_sec_identity", "OS_sec_protocol_metadata", "OS_sec_protocol_options",
                         "OS_sec_trust"] {
                c = c.replaceWord(name, with: "any \(name)")
            }
            // Fix: tls_ciphersuite_t/tls_ciphersuite_group_t/tls_protocol_version_t mangle as
            // `Security.tls_ciphersuite_t` etc. in the real ABI (confirmed via swift-demangle:
            // `kind=Structure, Module="__C"` -- a real ClangImporter-bridged struct from
            // Security's headers, per Network's own .swiftinterface: "Security::tls_ciphersuite_t"),
            // not a native Swift struct. Removed the native shadow declarations (previously
            // `public struct tls_ciphersuite_t {}` etc. below) now that `<Security/Security.h>`
            // is imported above -- the real bridged types resolve on their own.
            c += """

            // --- Auto-generated stubs for C/system types ---
            public struct ether_addr {}

            """
            // DatagramUpperHarness/StreamUpperHarness/UpperHarness<A> conform to the
            // Top(Datagram|Stream)Protocol/TopDatapathProtocol/TopProtocolHandler/
            // InboundDataHandler/UpperProtocolHandler hierarchy, but the generator only
            // discovered the members that are actually exported for each class — several
            // requirements (context/eventManager/reference on ProtocolInstance, the
            // ProtocolInstanceReference-taking overloads of handleConnectedEvent/
            // handleDisconnectedEvent/handleNetworkProtocolEvent/handleInboundDataAvailableEvent/
            // handleOutboundRoomAvailableEvent on UpperProtocolHandler/InboundDataHandler, plus
            // attachLowerProtocol and associatedtype LowerProtocol) have no ABI symbol of their
            // own on these specific classes (same root cause as elsewhere in this file: a
            // protocol requirement satisfied only via default behavior with nothing exported per
            // conforming type). Add the missing stub members, matching the exact signatures used
            // by every other working conformer of the same protocols in this file.
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class DatagramUpperHarness: InboundDatagramHandler, TopDatagramProtocol {",
                with: """
                @_fixed_layout public class DatagramUpperHarness: InboundDatagramHandler, TopDatagramProtocol {
                    public typealias LowerProtocol = OutboundDatagramLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public final var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public final var reference: ProtocolInstanceReference { get { fatalError() } }
                    public final var lower: OutboundDatagramLinkage { get { fatalError() } set {} }
                    public func handleConnectedEvent() -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleDisconnectedEvent(error: NetworkError?) -> () {}
                    public func handleDisconnectedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: NetworkProtocolEvent) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleInboundDataAvailableEvent() -> () {}
                    public func handleInboundDataAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleOutboundRoomAvailableEvent() -> () {}
                    public func handleOutboundRoomAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func attachLowerDatagramProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class StreamUpperHarness: InboundStreamHandler, TopStreamProtocol {",
                with: """
                @_fixed_layout public class StreamUpperHarness: InboundStreamHandler, TopStreamProtocol {
                    public typealias LowerProtocol = OutboundStreamLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public final var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public final var reference: ProtocolInstanceReference { get { fatalError() } }
                    public final var lower: OutboundStreamLinkage { get { fatalError() } set {} }
                    public func handleConnectedEvent() -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleDisconnectedEvent(error: NetworkError?) -> () {}
                    public func handleDisconnectedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: NetworkProtocolEvent) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleInboundDataAvailableEvent() -> () {}
                    public func handleInboundDataAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleOutboundRoomAvailableEvent() -> () {}
                    public func handleOutboundRoomAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleInboundAbortedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleOutboundAbortedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func attachLowerStreamProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                """)
            // Fix: TLS/DTLS/QUIC.TLS's cipher-suite/version-negotiation configuration methods
            // (minVersion/maxVersion/version(min:max:)/cipherSuites/appendCipherSuite/
            // cipherSuiteGroups) are entirely missing from the generated interface -- the parser
            // couldn't resolve their `Security.tls_ciphersuite_t`/`tls_protocol_version_t`/
            // `tls_ciphersuite_group_t` parameter types (real ClangImporter-bridged structs from
            // Security's headers, confirmed via swift-demangle and Network's own .swiftinterface:
            // "Security::tls_ciphersuite_t") and silently dropped the methods rather than
            // rendering a stub. Add them directly, qualified with the Security module name so
            // they resolve now that `<Security/Security.h>` is imported above.
            c = c.replacingOccurrences(
                of: "public func version() -> TLS { fatalError() }",
                with: """
                public func version() -> TLS { fatalError() }
                    public func minVersion(_ arg1: Security.tls_protocol_version_t) -> TLS { fatalError() }
                    public func maxVersion(_ arg1: Security.tls_protocol_version_t) -> TLS { fatalError() }
                    public func version(min: Security.tls_protocol_version_t?, max: Security.tls_protocol_version_t?) -> TLS { fatalError() }
                    public func cipherSuites(_ arg1: [Security.tls_ciphersuite_t]) -> TLS { fatalError() }
                    public func appendCipherSuite(_ arg1: Security.tls_ciphersuite_t) -> TLS { fatalError() }
                    public func cipherSuiteGroups(_ arg1: [Security.tls_ciphersuite_group_t]) -> TLS { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public func version() -> DTLS { fatalError() }",
                with: """
                public func version() -> DTLS { fatalError() }
                    public func version(min: Security.tls_protocol_version_t?, max: Security.tls_protocol_version_t?) -> DTLS { fatalError() }
                    public func cipherSuites(_ arg1: [Security.tls_ciphersuite_t]) -> DTLS { fatalError() }
                    public func cipherSuiteGroups(_ arg1: [Security.tls_ciphersuite_group_t]) -> DTLS { fatalError() }
                """)
            c = c.replacingOccurrences(
                of: "public func earlyDataEnabled(_ arg1: Swift.Bool) -> QUIC { fatalError() }",
                with: """
                public func earlyDataEnabled(_ arg1: Swift.Bool) -> QUIC { fatalError() }
                        public func cipherSuites(_ arg1: [Security.tls_ciphersuite_t]) -> QUIC { fatalError() }
                        public func appendCipherSuite(_ arg1: Security.tls_ciphersuite_t) -> QUIC { fatalError() }
                        public func ciphersuiteGroups(_ arg1: [Security.tls_ciphersuite_group_t]) -> QUIC { fatalError() }
                """)
            // UpperHarness<A>'s lowerProtocol init parameter and `lower` property are both
            // typed `A.PairedLinkage` in the real ABI (`swift-demangle -expand` on the init
            // symbol resolves the parameter type to exactly that dependent member type) — the
            // generator's own generic-constraint inference (Model.swift's
            // placeholdersNeedingProtocolLinkage) now derives `A: UpperProtocolLinkage` and
            // renders the init param/`lower` property with the correct type directly, so this
            // anchor only needs to add the ProtocolInstanceReference-taking overloads and
            // LowerProtocol typealias that have no ABI symbol of their own on this class (same
            // root cause as DatagramUpperHarness/StreamUpperHarness above).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class UpperHarness<A: UpperProtocolLinkage>: InboundDataHandler, LoggableProtocol, ProtocolInstance, TopDatapathProtocol, TopProtocolHandler, UpperHarnessProtocol, UpperProtocolHandler {",
                with: """
                @_fixed_layout public class UpperHarness<A: UpperProtocolLinkage>: InboundDataHandler, LoggableProtocol, ProtocolInstance, TopDatapathProtocol, TopProtocolHandler, UpperHarnessProtocol, UpperProtocolHandler {
                    public typealias LowerProtocol = A.PairedLinkage
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleDisconnectedEvent(_ arg1: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func handleNetworkProtocolEvent(_ arg1: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleInboundDataAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleOutboundRoomAvailableEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                """)
            // ConnectionProtocol requires `associatedtype ApplicationProtocolType: NetworkProtocolOptions`,
            // but no concrete type in the generated output conforms to NetworkProtocolOptions (it's only
            // ever used as a generic constraint), and the classes' own generic param `A` is bound to types
            // (WebSocket, TLV, JSON<GenericA>, UDP, DTLS, ...) that don't conform either. Since there's no
            // real per-instance application-protocol-options value being modeled here (the ABI doesn't
            // surface one), synthesize a trivial always-absent conformer and alias every ConnectionProtocol
            // conformer's ApplicationProtocolType to it.
            c += """

            public struct _NoApplicationProtocolOptions: NetworkProtocolOptions {
                public typealias BelowProtocol = Never
                public typealias ProtocolStorage = DefaultProtocolStorage
                public typealias Metadata = _NoApplicationProtocolMetadata
                public var belowProtocol: Never { fatalError() }
                public func configure(parameters: any OS_nw_parameters) -> () {}
                public func configureNestedStack(parameters: any OS_nw_parameters) -> () {}
                public func reconfigureNestedStack(connection: any OS_nw_connection) -> () {}
            }
            public struct _NoApplicationProtocolMetadata: NetworkMetadataProtocol {
                public static func fromContentContext(context: NWConnection.ContentContext?, isComplete: Swift.Bool) -> Self? { return nil }
                public func toContentContext() -> NWConnection.ContentContext { fatalError() }
            }

            """
            for decl in [
                "@_fixed_layout public class Connection1<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection2<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection3<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection4<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection5<A, each B>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection6<A>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class Connection7<A>: ConnectionProtocol, Hashable, Identifiable {",
                "@_fixed_layout public class NetworkChannel<A>: ConnectionProtocol, CustomDebugStringConvertible, Hashable, Identifiable {",
            ] {
                c = c.replacingOccurrences(
                    of: decl,
                    with: decl + "\n    public typealias ApplicationProtocolType = _NoApplicationProtocolOptions")
            }
            // NetworkJSONCoder/NetworkPropertyListCoder conform to NetworkCoder, whose
            // makeDecoder()/makeEncoder() requirements return associatedtypes constrained to
            // NetworkDecoder/NetworkEncoder. Foundation's JSONDecoder/JSONEncoder/
            // PropertyListDecoder/PropertyListEncoder satisfy those protocols' requirements
            // structurally but have no declared conformance in the generated output.
            c += """

            extension JSONDecoder: NetworkDecoder {}
            extension JSONEncoder: NetworkEncoder {}
            extension PropertyListDecoder: NetworkDecoder {}
            extension PropertyListEncoder: NetworkEncoder {}

            """
            // InboundFlowLinkage adds `associatedtype DataLinkage: OutboundDataLinkage` on top of
            // its parent InboundFlowLinkage's own PairedLinkage requirement; both concrete
            // conformers are missing the DataLinkage typealias (the generator only discovered
            // PairedLinkage's exported symbol, not DataLinkage's, since it has no separate
            // per-type ABI representation).
            c = c.replacingOccurrences(
                of: """
                public struct InboundDatagramFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = DatagramListenerLinkage
                """,
                with: """
                public struct InboundDatagramFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = DatagramListenerLinkage
                    public typealias DataLinkage = OutboundDatagramLinkage
                """)
            c = c.replacingOccurrences(
                of: """
                public struct InboundStreamFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = StreamListenerLinkage
                """,
                with: """
                public struct InboundStreamFlowLinkage: InboundFlowLinkage, ProtocolLinkage, UpperProtocolLinkage {
                    public typealias PairedLinkage = StreamListenerLinkage
                    public typealias DataLinkage = OutboundStreamLinkage
                """)
            // Coder<A, B, C> conforms to NetworkProtocolOptions but is missing BelowProtocol and
            // ProtocolStorage typealiases (no per-type exported ABI symbol for either). Its own
            // `belowProtocol` property is already typed `any NetworkProtocolOptions`, so
            // BelowProtocol matches that; ProtocolStorage reuses the same DefaultProtocolStorage
            // stub used by every other NetworkProtocolOptions conformer.
            c = c.replacingOccurrences(
                of: "public struct Coder<A, B, C>: MessageProtocol, NetworkProtocolOptions, OneToOneProtocol {",
                with: """
                public struct Coder<A, B, C>: MessageProtocol, NetworkProtocolOptions, OneToOneProtocol {
                    public typealias BelowProtocol = any NetworkProtocolOptions
                    public typealias ProtocolStorage = DefaultProtocolStorage
                """)
            // MultiplexedDatagramFlow/MultiplexedStreamFlow<A> conform to MultiplexedFlow, which
            // declares `associatedtype ParentProtocol: ManyToManyProtocolHandler` inferred from
            // the `parent` init parameter and `parentProtocol` property (both typed `A`) — so `A`
            // itself must be constrained to ManyToManyProtocolHandler. Also missing `context`
            // (ProtocolInstance, no per-type ABI symbol) and `required` on the memberwise init
            // (a protocol initializer requirement can only be satisfied by a required init on a
            // non-final class).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexedDatagramFlow<A>: AutomaticUpperDatagramProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {\n    public init(parent: A, inbound: Swift.Bool) { fatalError() }",
                with: """
                @_fixed_layout public class MultiplexedDatagramFlow<A: ManyToManyProtocolHandler>: AutomaticUpperDatagramProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public required init(parent: A, inbound: Swift.Bool) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexedStreamFlow<A>: AutomaticUpperStreamProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {\n    public init(parent: A, inbound: Swift.Bool) { fatalError() }",
                with: """
                @_fixed_layout public class MultiplexedStreamFlow<A: ManyToManyProtocolHandler>: AutomaticUpperStreamProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public required init(parent: A, inbound: Swift.Bool) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                """)
            // MultiplexingDatagramPath<A> conforms to MultiplexingPath/UpperProtocolHandler:
            // same ParentProtocol-inference issue on `A` as above, plus missing `context`,
            // `LowerProtocol` typealias, and the UpperProtocolHandler handle*/attachLowerProtocol
            // requirements (only the Datagram-specific attachLowerDatagramProtocol overload had
            // its own exported symbol).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexingDatagramPath<A>: AutomaticLowerDatagramProcessing, InboundDataHandler, InboundDatagramHandler, MultiplexingDatapathPath, MultiplexingPath, ProtocolInstance, ProtocolInstanceContainer, UpperProtocolHandler {\n    public init(parent: A) { fatalError() }",
                with: """
                @_fixed_layout public class MultiplexingDatagramPath<A: ManyToManyProtocolHandler>: AutomaticLowerDatagramProcessing, InboundDataHandler, InboundDatagramHandler, MultiplexingDatapathPath, MultiplexingPath, ProtocolInstance, ProtocolInstanceContainer, UpperProtocolHandler {
                    public typealias LowerProtocol = OutboundDatagramLinkage
                    public required init(parent: A) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleNetworkProtocolEvent(_: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleDisconnectedEvent(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                """)
            // NewFlowHarness<A, B> conforms to UpperProtocolHandler; its `listenerProtocol` init
            // parameter is typed `A.PairedLinkage` in the real ABI (confirmed via
            // `swift-demangle -expand` on the init symbol, same dependent-member pattern as the
            // UpperHarness<A> fix in Network fix 13). The generator's own generic-constraint
            // inference (Model.swift's placeholdersNeedingProtocolLinkage) now derives
            // `A: UpperProtocolLinkage` and renders the init param with the correct type
            // directly, so this anchor only needs to supply the missing LowerProtocol typealias
            // (no ABI symbol of its own on this class — same root cause as UpperHarness<A>
            // above).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class NewFlowHarness<A: UpperProtocolLinkage, B>: InboundFlowHandler, LoggableProtocol, ProtocolInstance, UpperProtocolHandler {",
                with: """
                @_fixed_layout public class NewFlowHarness<A: UpperProtocolLinkage, B>: InboundFlowHandler, LoggableProtocol, ProtocolInstance, UpperProtocolHandler {
                    public typealias LowerProtocol = A.PairedLinkage
                """)
            // QUICDatagramFlow/QUICPath are internal SPI helper classes (no public .swiftinterface
            // entry) referenced only via QUICConnection's multiplexedSecondaryFlows/
            // multiplexingPaths dictionaries; the generator captured only their exported members,
            // not their conformances to MultiplexedFlow/MultiplexingPath (needed for
            // QUICConnection's own HeterogeneousManyToManyProtocolHandler/ManyToManyProtocolHandler
            // conformance to be able to infer SecondaryFlow/Path). Added the missing conformances
            // and stub members, matching the shape of every other MultiplexedFlow/MultiplexingPath
            // conformer already fixed elsewhere in this file.
            // Header-only matches (not the whole class body) since member declaration order
            // inside these classes isn't guaranteed stable across generator runs.
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class QUICDatagramFlow {",
                with: """
                @_fixed_layout final public class QUICDatagramFlow: MultiplexedDatapathFlow {
                    public typealias UpperProtocol = InboundDatagramLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public var log: NetworkLoggerState { get { fatalError() } set {} }
                    public final var parentProtocol: QUICConnection { get { fatalError() } set {} }
                    public final var identifier: MultiplexedFlowIdentifier { get { fatalError() } }
                    public final var upper: InboundDatagramLinkage { get { fatalError() } set {} }
                    public var upperReceiveQueue: FrameArray { get { fatalError() } set {} }
                    public var upperSendQueue: FrameArray { get { fatalError() } set {} }
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class QUICPath: Equatable {",
                with: """
                @_fixed_layout final public class QUICPath: Equatable, MultiplexingDatapathPath {
                    public typealias LowerProtocol = OutboundDatagramLinkage
                    public final var context: NetworkContext { get { fatalError() } }
                    public var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public final var identifier: Swift.Int { get { fatalError() } }
                    public final var lower: OutboundDatagramLinkage { get { fatalError() } set {} }
                    public final var parentProtocol: QUICConnection { get { fatalError() } }
                    public final var pathIsPrimary: Swift.Bool { get { fatalError() } set {} }
                    public func attachLowerProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func handleConnectedEvent(_ arg1: ProtocolInstanceReference) -> () {}
                    public func handleNetworkProtocolEvent(_: ProtocolInstanceReference, event: NetworkProtocolEvent) -> () {}
                    public func handleDisconnectedEvent(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public required init(parent: QUICConnection) { fatalError() }
                """)
            // QUICConnection conforms to HeterogeneousManyToManyProtocolHandler/
            // ManyToManyProtocolHandler/StreamListenerHandler/HeterogeneousListenerHandler.
            // Its Flow/SecondaryFlow/Path/UpperProtocol/SecondaryUpperProtocol associatedtypes
            // are inferable now that QUICStreamInstance/QUICDatagramFlow/QUICPath conform to the
            // right protocols, but still need explicit typealiases (the properties alone leave
            // ambiguity between candidate inferences), plus the ListenerHandler/
            // StreamListenerHandler/ManyToManyProtocolHandler requirements that have no per-type
            // exported ABI symbol (they're satisfied only via default/inherited behavior on the
            // real type).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class QUICConnection: HeterogeneousListenerHandler, HeterogeneousManyToManyProtocolHandler, ListenerHandler, LoggableProtocol, ManyToManyApplicationDatagramProtocol, ManyToManyApplicationStreamProtocol, ManyToManyDatapathProtocol, ManyToManyOutboundDatagramProtocol, ManyToManyProtocolHandler, ProtocolInstance, ProtocolInstanceContainer, StreamListenerHandler, TimerSchedulable {",
                with: """
                @_fixed_layout public class QUICConnection: HeterogeneousListenerHandler, HeterogeneousManyToManyProtocolHandler, ListenerHandler, LoggableProtocol, ManyToManyApplicationDatagramProtocol, ManyToManyApplicationStreamProtocol, ManyToManyDatapathProtocol, ManyToManyOutboundDatagramProtocol, ManyToManyProtocolHandler, ProtocolInstance, ProtocolInstanceContainer, StreamListenerHandler, TimerSchedulable {
                    public typealias UpperProtocol = InboundStreamFlowLinkage
                    public typealias SecondaryUpperProtocol = InboundDatagramFlowLinkage
                    public typealias Flow = QUICStreamInstance
                    public typealias SecondaryFlow = QUICDatagramFlow
                    public typealias Path = QUICPath
                    public func attachUpperProtocolToExistingFlow<GenericA>(_: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> GenericA where GenericA: LowerProtocolLinkage { fatalError() }
                    public func attachUpperProtocolToNewFlow<GenericA>(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> GenericA where GenericA: LowerProtocolLinkage { fatalError() }
                    public func handleDisconnectedEvent(path: Swift.Int, error: NetworkError?) -> () {}
                    public func performInitialSetupIfNeeded(remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func handleNetworkProtocolEvent(path: Swift.Int, event: NetworkProtocolEvent) -> HandleNetworkEventResult { fatalError() }
                    public func teardownIfPossible() -> () {}
                    public func handleConnectedEvent(path: Swift.Int) -> () {}
                    public func attachLowerProtocolForNewPath(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> () {}
                    public func validate(inbound: ProtocolInstanceReference, _: Swift.String) throws(ProtocolInstanceError) -> () {}
                    public func attachNewStreamFlowProtocol(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> StreamListenerLinkage { fatalError() }
                    public func attachUpperStreamProtocolToExistingFlow(_: ProtocolInstanceReference, flowReference: ProtocolInstanceReference) throws(NetworkError) -> OutboundStreamLinkage { fatalError() }
                    public func attachUpperStreamProtocolToNewFlow(_: ProtocolInstanceReference, remote: Endpoint?, local: Endpoint?, parameters: Parameters?, path: PathProperties?) throws(NetworkError) -> OutboundStreamLinkage { fatalError() }
                """)
            // QUICStreamInstance conforms to EarlyDataStreamFlow/UnidirectionalAbortingStreamFlow,
            // which pull in MultiplexedFlow/LoggableProtocol/ProtocolInstance/
            // OutboundStreamEarlyDataHandler requirements that have no per-type exported ABI
            // symbol on this specific class.
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class QUICStreamInstance: EarlyDataStreamFlow, OutboundStreamEarlyDataHandler, OutboundStreamUnidirectionalAbortHandler, UnidirectionalAbortingStreamFlow {\n    public init(parent: QUICConnection, inbound: Swift.Bool) { fatalError() }",
                with: """
                @_fixed_layout final public class QUICStreamInstance: EarlyDataStreamFlow, OutboundStreamEarlyDataHandler, OutboundStreamUnidirectionalAbortHandler, UnidirectionalAbortingStreamFlow {
                    public typealias UpperProtocol = InboundStreamLinkage
                    public init(parent: QUICConnection, inbound: Swift.Bool) { fatalError() }
                    public final var context: NetworkContext { get { fatalError() } }
                    public var eventManager: ProtocolEventManager { get { fatalError() } set {} }
                    public var log: NetworkLoggerState { get { fatalError() } set {} }
                    public final var parentProtocol: QUICConnection { get { fatalError() } set {} }
                    public final var identifier: MultiplexedFlowIdentifier { get { fatalError() } }
                    public final var upper: InboundStreamLinkage { get { fatalError() } set {} }
                    public var upperReceiveQueue: FrameArray { get { fatalError() } set {} }
                    public var upperSendQueue: FrameArray { get { fatalError() } set {} }
                    public func sendEarlyStreamData(_: ProtocolInstanceReference, streamData: __owned FrameArray) throws(NetworkError) -> () {}
                    public func abortOutbound(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                    public func abortInbound(_: ProtocolInstanceReference, error: NetworkError?) -> () {}
                """)
            // MultiplexedStreamFlow<A>/MultiplexedDatagramFlow<A> both already implement every
            // member OutboundStreamHandler/OutboundDatagramHandler and LowerProtocolHandler
            // require (via their existing OutboundDataHandler/MultiplexedFlow/ProtocolInstance
            // conformances' default implementations), but the conformances themselves were never
            // restated -- same conformance-restatement gap as many earlier fixes this session
            // (confirmed via swift-demangle: e.g. `protocol conformance descriptor for
            // Network.MultiplexedStreamFlow<A> : Network.OutboundStreamHandler`). Adding
            // LowerProtocolHandler alone (bare, without an explicit `typealias UpperProtocol`)
            // broke MultiplexedFlow's ALREADY-working conformance -- both protocols declare an
            // identically-named `associatedtype UpperProtocol: UpperProtocolLinkage`, and neither
            // protocol's own requirements ever use `Self.UpperProtocol` anywhere, so there's no
            // signature Swift can infer a witness from; when two simultaneously-added protocols
            // share a nameable-but-unwitnessable associated type like this, Swift's inference
            // fails for the class as a whole rather than just leaving it ambiguous. Fixed by
            // adding the explicit `public typealias UpperProtocol = ...` other sibling
            // Multiplexed*Flow classes already declare (confirmed via minimal repro against the
            // real generated interface, standalone-compiled with the same flags verify_public.py
            // uses, before porting this fix here).
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexedStreamFlow<A: ManyToManyProtocolHandler>: AutomaticUpperStreamProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {",
                with: """
                @_fixed_layout public class MultiplexedStreamFlow<A: ManyToManyProtocolHandler>: AutomaticUpperStreamProcessing, LoggableProtocol, LowerProtocolHandler, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, OutboundStreamHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public typealias UpperProtocol = InboundStreamLinkage
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class MultiplexedDatagramFlow<A: ManyToManyProtocolHandler>: AutomaticUpperDatagramProcessing, LoggableProtocol, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {",
                with: """
                @_fixed_layout public class MultiplexedDatagramFlow<A: ManyToManyProtocolHandler>: AutomaticUpperDatagramProcessing, LoggableProtocol, LowerProtocolHandler, MultiplexedDatapathFlow, MultiplexedFlow, OutboundDataHandler, OutboundDatagramHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public typealias UpperProtocol = InboundDatagramLinkage
                """)
            // Same conformance-restatement + associated-type-collision fix as
            // MultiplexedStreamFlow/MultiplexedDatagramFlow above, for
            // BridgeStreamProtocol.BridgeInstance: it already implements every member
            // LowerProtocolHandler/BottomProtocolHandler/OutboundStreamHandler require, but never
            // restates the conformances, and LowerProtocolHandler/BottomProtocolHandler both
            // declare the same unwitnessable `associatedtype UpperProtocol: UpperProtocolLinkage`
            // -- confirmed via the same minimal-repro-against-the-real-generated-interface
            // technique used for the fix above.
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class BridgeInstance: BottomStreamProtocol, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {",
                with: """
                @_fixed_layout final public class BridgeInstance: BottomProtocolHandler, BottomStreamProtocol, LowerProtocolHandler, OutboundDataHandler, OutboundStreamHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public typealias UpperProtocol = InboundStreamLinkage
                """)
            // Same fix again for BridgeDatagramProtocol.BridgeInstance (the datagram sibling of
            // BridgeStreamProtocol.BridgeInstance above) -- identical missing
            // LowerProtocolHandler/BottomProtocolHandler/OutboundDatagramHandler conformances and
            // the same UpperProtocol associated-type collision.
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class BridgeInstance: BottomDatagramProtocol, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer, TimerSchedulable {",
                with: """
                @_fixed_layout final public class BridgeInstance: BottomDatagramProtocol, BottomProtocolHandler, LowerProtocolHandler, OutboundDataHandler, OutboundDatagramHandler, ProtocolInstance, ProtocolInstanceContainer, TimerSchedulable {
                    public typealias UpperProtocol = InboundDatagramLinkage
                """)
            // Same conformance-restatement pattern, 3 more concrete (non-generic-witness-table-
            // blocked) sites found by surveying Network's remaining stubs for other
            // LowerProtocolHandler/BottomProtocolHandler/OutboundDatagramHandler gaps: each already
            // implements every required member via existing conformances' defaults, just never
            // restates the conformance -- confirmed compiling clean (0 errors) via the same
            // minimal-repro-against-the-real-generated-interface technique.
            c = c.replacingOccurrences(
                of: "@_fixed_layout final public class ChannelProtocol: LoggableProtocol, OutboundDataHandler, ProtocolInstance, ProtocolInstanceContainer {",
                with: """
                @_fixed_layout final public class ChannelProtocol: LoggableProtocol, LowerProtocolHandler, OutboundDataHandler, OutboundDatagramHandler, ProtocolInstance, ProtocolInstanceContainer {
                    public typealias UpperProtocol = InboundDatagramLinkage
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class LowerHarness<A: LowerProtocolLinkage>: LoggableProtocol, OutboundDataHandler, ProtocolInstance {",
                with: """
                @_fixed_layout public class LowerHarness<A: LowerProtocolLinkage>: BottomProtocolHandler, LoggableProtocol, LowerProtocolHandler, OutboundDataHandler, ProtocolInstance {
                    public typealias UpperProtocol = A.PairedLinkage
                """)
            c = c.replacingOccurrences(
                of: "@_fixed_layout public class QUICConnection: HeterogeneousListenerHandler, HeterogeneousManyToManyProtocolHandler, ListenerHandler, LoggableProtocol, ManyToManyApplicationDatagramProtocol, ManyToManyApplicationStreamProtocol, ManyToManyDatapathProtocol, ManyToManyOutboundDatagramProtocol, ManyToManyProtocolHandler, ProtocolInstance, ProtocolInstanceContainer, StreamListenerHandler, TimerSchedulable {",
                with: "@_fixed_layout public class QUICConnection: HeterogeneousListenerHandler, HeterogeneousManyToManyProtocolHandler, ListenerHandler, LoggableProtocol, LowerProtocolHandler, ManyToManyApplicationDatagramProtocol, ManyToManyApplicationStreamProtocol, ManyToManyDatapathProtocol, ManyToManyOutboundDatagramProtocol, ManyToManyProtocolHandler, ProtocolInstance, ProtocolInstanceContainer, StreamListenerHandler, TimerSchedulable {")
        return c
    }
}
