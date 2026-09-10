import Foundation

extension SwiftInterfaceGen {
    static func postProcessCombine(_ code: String, parser: Parser) -> String {
        var c = code
            // Dozens of Publishers.X<...> types (CombineLatest, Zip, Merge, Drop, Retry, ...)
            // conditionally conform to Equatable in the real ABI (confirmed via each type's own
            // conformance descriptor), but the generator only emits the bare default-
            // implementation extension for the `==` witness without restating
            // "Publishers.X: Equatable" as the actual conformance -- same gap fixed for Charts'
            // result-builder types and HealthKit's CodableBox family in prior commits, just
            // recurring identically ~30 times here. Handled generally (only add the conformance
            // when EVERY constraint in the where-clause is an Equatable bound) rather than
            // per-name, since a per-name list would need constant upkeep as Publishers grows.
            if let regex = try? NSRegularExpression(pattern: "extension Publishers\\.(\\w+) where ([^{]+)\\{") {
                let nsRange = NSRange(c.startIndex..<c.endIndex, in: c)
                var replacements: [(Range<String.Index>, String)] = []
                var candidatesByName: [String: [(range: Range<String.Index>, clause: String, hasDottedConstraint: Bool)]] = [:]
                for m in regex.matches(in: c, options: [], range: nsRange) {
                    guard let fullRange = Range(m.range, in: c),
                          let nameRange = Range(m.range(at: 1), in: c),
                          let clauseRange = Range(m.range(at: 2), in: c) else { continue }
                    let name = String(c[nameRange])
                    let clause = String(c[clauseRange])
                    let constraints = clause.trimmingCharacters(in: .whitespaces)
                        .components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    guard !constraints.isEmpty, constraints.allSatisfy({ $0.hasSuffix(": Equatable") }) else { continue }
                    let hasDotted = constraints.contains { $0.dropLast(": Equatable".count).contains(".") }
                    candidatesByName[name, default: []].append((fullRange, clause, hasDotted))
                }
                // Swift forbids two conformances to the same protocol on one type even under
                // different conditional bounds -- when a type has more than one all-Equatable
                // extension (e.g. Publishers.Sequence has both "A: Equatable" and the unrelated,
                // non-conforming "A.Element: Equatable" default-implementation block), only the
                // bare-param form matches the real conformance descriptor's own bound; prefer it.
                for (name, candidates) in candidatesByName {
                    let chosen = candidates.count > 1 ? candidates.filter { !$0.hasDottedConstraint } : candidates
                    for c2 in chosen {
                        replacements.append((c2.range, "extension Publishers.\(name): Equatable where \(c2.clause){"))
                    }
                }
                for (range, replacement) in replacements.sorted(by: { $0.0.lowerBound > $1.0.lowerBound }) {
                    c.replaceSubrange(range, with: replacement)
                }
            }
            // Optional<Wrapped>.Publisher lost its generic parameter entirely -- every member
            // uses a bare `Any` instead of threading `Wrapped` (the name automatically available
            // inside `extension Optional { ... }`), confirmed via swift-demangle: e.g.
            // `Swift.Optional.Publisher.map<A>((A) -> A1) -> A1?.Publisher` uses the outer
            // Optional's own generic param (A/Wrapped), not Any. Result<Success,Failure>.Publisher
            // has the identical bug, but that type isn't part of the real ABI surface in this SDK
            // (absent from the exports list entirely), so it's left alone.
            // Subscribers.Demand's Comparable conformance only synthesizes `<(Demand, Demand)`,
            // but the real ABI has 10 more explicit comparison overloads mixing Demand and Int
            // operands, plus the Demand/Demand >,>=,<= that Comparable's synthesized defaults
            // don't produce standalone exported symbols for (confirmed via swift-demangle: e.g.
            // `static Combine.Subscribers.Demand.> infix(Combine.Subscribers.Demand, Swift.Int)
            // -> Swift.Bool`).
            c = c.replacingOccurrences(
                of: "public static func <(_ lhs: Demand, _ rhs: Demand) -> Bool { fatalError() }",
                with: """
                public static func <(_ lhs: Demand, _ rhs: Demand) -> Bool { fatalError() }
                        public static func <(_ lhs: Demand, _ rhs: Swift.Int) -> Bool { fatalError() }
                        public static func <(_ lhs: Swift.Int, _ rhs: Demand) -> Bool { fatalError() }
                        public static func >(_ lhs: Demand, _ rhs: Demand) -> Bool { fatalError() }
                        public static func >(_ lhs: Demand, _ rhs: Swift.Int) -> Bool { fatalError() }
                        public static func >(_ lhs: Swift.Int, _ rhs: Demand) -> Bool { fatalError() }
                        public static func >=(_ lhs: Demand, _ rhs: Demand) -> Bool { fatalError() }
                        public static func >=(_ lhs: Demand, _ rhs: Swift.Int) -> Bool { fatalError() }
                        public static func >=(_ lhs: Swift.Int, _ rhs: Demand) -> Bool { fatalError() }
                        public static func <=(_ lhs: Demand, _ rhs: Demand) -> Bool { fatalError() }
                        public static func <=(_ lhs: Demand, _ rhs: Swift.Int) -> Bool { fatalError() }
                        public static func <=(_ lhs: Swift.Int, _ rhs: Demand) -> Bool { fatalError() }
                """)
            if let declRange = c.range(of: "extension Optional {\n    public struct Publisher: Combine.Publisher {") {
                var depth = 1
                var idx = declRange.upperBound
                while depth > 0 && idx < c.endIndex {
                    if c[idx] == "{" { depth += 1 } else if c[idx] == "}" { depth -= 1 }
                    idx = c.index(after: idx)
                }
                let bodyRange = declRange.lowerBound..<idx
                var body = String(c[bodyRange])
                body = body.replaceWord("Any", with: "Wrapped")
                c.replaceSubrange(bodyRange, with: body)
            }
        return c
    }
}
