import Foundation

extension SwiftInterfaceGen {
    static func postProcessAppleIntelligenceReporting(_ code: String, parser: Parser) -> String {
        var c = code
            // Restore the header constraint the real class declares (confirmed via its own
            // ABI: lazySource.source's mangled type is "any Source<Self.Stream == A>", which
            // only a constrained "class lazySource<A> where A: Stream" produces) and restore
            // sendEvent's real parameter type. The earlier attempt to do this (commit 395cc88)
            // also declared the Stream conformance as a RETROACTIVE extension in THIS module
            // ("extension IntelligencePlatformLibrary.Foo: IntelligencePlatformLibrary.Stream")
            // — a cross-module conformance forces Swift to mangle every lazySource<Foo>
            // instantiation with an extra protocol-witness-table substitution path (confirmed
            // via isolated testing: same-module conformance mangles clean, cross-module
            // retroactive conformance adds "...AiG6StreamAAyHCg_G..."), which is what caused
            // the regression from 26 to 65 stubs and led to reverting this constraint entirely.
            // Fix: declare the conformance where the type itself lives instead — the
            // "stubTypeConformances" hook below injects it directly into the
            // IntelligencePlatformLibrary(_AppleInternal) stub's own StubNode, so the
            // conformance is native to that module, matching the real ABI's mangling.
            c = c.replacingOccurrences(
                of: "class lazySource<A> {",
                with: "class lazySource<A> where A: IntelligencePlatformLibrary.Stream {"
            )
            c = c.replacingOccurrences(
                of: "class lazySourceInternal<A> {",
                with: "class lazySourceInternal<A> where A: IntelligencePlatformLibrary_AppleInternal.Stream {"
            )
            c = c.replacingOccurrences(
                of: "func sendEvent(_ arg1: Any)",
                with: "func sendEvent(_ arg1: A.EventType)")
        return c
    }
}
