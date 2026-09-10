import Foundation

extension SwiftInterfaceGen {
    static func postProcessMetalPerformanceShadersGraph(_ code: String, parser: Parser) -> String {
        var c = code
            // `counter`'s real ABI (confirmed by grepping the .tbd directly) exports THREE
            // distinct symbols: "vau" (addressor), "vpZ" (raw storage), and "vrZ" (read-borrow
            // accessor) -- Parser.swift's generic stored-static-property handling (silgenSymbols)
            // already emits manual @_silgen_name stubs for "vau" and "vpZ" unconditionally, from
            // parsing the real ABI, independent of how (or whether) this property gets rendered
            // here. The default computed-getter rendering doesn't compile at all (Atomic is a
            // move-only-adjacent type Swift requires `let`, not `var { get }`), and giving it a
            // real initializer (`= .init(0)`) to satisfy that instead backfires for "vpZ"
            // specifically: this toolchain's codegen for such a static let always claims that
            // exact storage-symbol name too (confirmed via nm: as local/private "b"/bss, not
            // exported), colliding with -- and getting linker-renamed away from -- the manual
            // stub's identical name, so neither definition ends up correctly exported either way
            // (it does naturally produce a correctly-exported "vau" and "vrZ" though, with no
            // competing manual duplicate for either). Since nothing else in this generated file
            // references `counter`, simplest fix is to drop the property declaration entirely
            // (avoiding the initializer's "vpZ" collision) and add a manual stub for "vrZ" too
            // (which, unlike "vpZ", has no existing Parser.swift-side mechanism, since it's not
            // one of the two mangled shapes that mechanism recognizes) so all three end up
            // satisfied via manual stubs alone, with no natural declaration competing with any of
            // them.
            c = c.replacingOccurrences(
                of: #"\n\s*public static var counter: (?:Synchronization\.)?Atomic<.*?>.*"#,
                with: "",
                options: .regularExpression)
            c += """

@_silgen_name("$s28MetalPerformanceShadersGraph22MPSGraphDelegateKernelC7counter15Synchronization6AtomicVys6UInt32VGvrZ")
func _stub_counter_vrZ() { fatalError() }

"""
            // Model.swift's own `required` synthesis (isRequired, for a non-final class
            // conforming to a protocol) can already have prepended "required " to this exact
            // initializer -- blindly prepending a second one here produces the illegal
            // "required required public init(...)" (duplicate modifier). Only add it when
            // missing.
            c = c.replacingOccurrences(
                of: "public init(_ arg1: ODIE.DelegateProgramArguments)",
                with: "required public init(_ arg1: ODIE.DelegateProgramArguments)")
            c = c.replacingOccurrences(
                of: "required required public init(_ arg1: ODIE.DelegateProgramArguments)",
                with: "required public init(_ arg1: ODIE.DelegateProgramArguments)")
            // MPSGraphDelegate.Weak<A>'s `value: A?` field-offset symbol only exists in the real
            // ABI ("direct field offset for ...Weak.value : A?") because A is class-constrained
            // (verified via a minimal repro: an unconstrained generic class property gets no
            // direct offset at all under library evolution, needing generic metadata instead --
            // adding `A: AnyObject` alone, without even a `weak` qualifier on the property,
            // reproduces the exact real mangled symbol).
            c = c.replacingOccurrences(
                of: "public class Weak<A> {",
                with: "public class Weak<A: AnyObject> {")
            // Executables.init's `mpsExecutable`/`ndxRuntimeBase` defaults and
            // MPSGraphDelegateKernel.init's `executable`/`adapterExecutable`/
            // `executableExecutionDescriptor` params are all real ObjC class-typed optionals
            // that the generator renders with an explicit `borrowing` keyword (copied verbatim
            // from the swiftinterface's printed ownership annotation) -- but swift-demangle on
            // the real ABI symbols shows no ownership modifier ("...CSg_..." not "...CSgh_...";
            // confirmed via a minimal repro that explicit `borrowing` on a plain copyable
            // class-optional parameter adds an "h" ownership-convention marker the mangler
            // doesn't otherwise emit for the implicit default convention). The interface printer
            // annotation reflects the implicit default calling convention, not an explicit
            // source-level keyword, so re-emitting it as literal `borrowing` changes the mangled
            // signature of the initializer and all its default-argument thunks. Strip it here
            // (RawSpan/RawSpan-typed params elsewhere in this module are unaffected -- those
            // genuinely require explicit borrowing and aren't in the stub list).
            c = c.replacingOccurrences(
                of: "mpsExecutable: borrowing MPSGraphExecutable?",
                with: "mpsExecutable: MPSGraphExecutable?")
            c = c.replacingOccurrences(
                of: "executable: borrowing MPSGraphExecutable?, adapterExecutable: borrowing MPSGraphExecutable?",
                with: "executable: MPSGraphExecutable?, adapterExecutable: MPSGraphExecutable?")
            c = c.replacingOccurrences(
                of: "executableExecutionDescriptor: borrowing MPSGraphExecutableExecutionDescriptor?",
                with: "executableExecutionDescriptor: MPSGraphExecutableExecutionDescriptor?")
            // reorderInputsAndOutputs<A>'s outputIsInOut closure param renders with an explicit
            // `@escaping` the generator added -- but swift-demangle on the real ABI symbol shows
            // the non-escaping closure-type marker "XE" (confirmed via a minimal repro: default,
            // non-@escaping closures mangle with "XE"; @escaping ones mangle as a plain thick
            // closure with no "X" marker at all -- the reverse of what the keyword's name
            // suggests). Drop the erroneously-added `@escaping`.
            c = c.replacingOccurrences(
                of: "outputIsInOut: @escaping (Swift.Int) -> Swift.Bool) -> (reorderedInputs: [A], reorderedOutputs: [A])",
                with: "outputIsInOut: (Swift.Int) -> Swift.Bool) -> (reorderedInputs: [A], reorderedOutputs: [A])")
            // MPSGraphDelegateError's real ABI has init(from:)/encode(to:) members implying real
            // Codable conformance (confirmed via swift-demangle: separate Encodable and Decodable
            // conformance descriptors both exist), but the generator only emits the bare
            // default-implementation members without restating the conformance -- same
            // conformance-restatement gap already fixed for Charts/HealthKit/Combine types this
            // session.
            c = c.replacingOccurrences(
                of: "public enum MPSGraphDelegateError: Error {",
                with: "public enum MPSGraphDelegateError: Codable, Error {")
            // delegateLogger's real ABI (confirmed by grepping the .tbd directly) exports exactly
            // two symbols: "vau" (addressor) and "vp" (raw storage) -- no getter at all. The
            // generator renders any top-level `os.Logger`-typed global as a computed get-only
            // `var { get { fatalError() } }`, which produces neither. Giving it a real
            // initializer instead (`@MainActor public let delegateLogger: Logger = Logger()`)
            // does naturally produce a correctly-present "vau", but for "vp" specifically hits
            // the exact same collision as counter's "vpZ" above: nm shows Swift's own synthesized
            // storage for the constant claims that exact name as a local "b" (bss) symbol -- and
            // --compare's own extractDylibSymbols() explicitly excludes "b"-type symbols from
            // counting as present (main.swift's `symType != "b"` filter), so even though the name
            // exists in the dylib's symbol table, it never satisfies the comparison; a second,
            // manually `@_silgen_name`-tagged declaration of the identical name doesn't help
            // either, since the two same-named definitions just collide and one gets
            // linker-renamed away (confirmed via nm: "...Vvp.6"). Fixed the same way as counter:
            // drop the property declaration entirely (nothing else in this file references
            // delegateLogger) so no natural definition of either symbol competes with a manual
            // stub, then force both missing symbols directly.
            c = c.replacingOccurrences(
                of: "public var delegateLogger: Logger { get { fatalError() } }",
                with: "")
            c += """

@_silgen_name("$s28MetalPerformanceShadersGraph14delegateLogger2os0F0Vvau")
func _stub_delegateLogger_vau() { fatalError() }

@_silgen_name("$s28MetalPerformanceShadersGraph14delegateLogger2os0F0Vvp")
func _stub_delegateLogger_vp() { fatalError() }

"""
            // Executables.init's `mpsExecutable`/`ndxRuntimeBase` default-argument generator
            // thunks (args 0 and 2 -- kernelCache's arg 1, a non-trivial `[:]` dictionary literal,
            // already renders fine) never get emitted by this toolchain: a minimal repro
            // confirms plain `nil`-literal defaults for Optional<ObjC class> params produce no
            // default-argument-generator symbol at all under library evolution (the literal gets
            // inlined at every call site instead), yet the real ABI has genuine, separate
            // generator-function symbols for both -- almost certainly because the real framework
            // was built by an older Swift compiler whose codegen rules for trivial defaults
            // differed. Force both missing symbols directly.
            c += """

@_silgen_name("$s28MetalPerformanceShadersGraph16MPSGraphDelegateC11ExecutablesV13mpsExecutable11kernelCache14ndxRuntimeBaseAESo0eI0CSg_SDyAC06KernelK3KeyVAC4WeakCy_AA0efO0CGGSo0E10NDXRuntimeCSgtcfcfA_")
func _stub_ExecutablesV_defaultArg0() { fatalError() }

@_silgen_name("$s28MetalPerformanceShadersGraph16MPSGraphDelegateC11ExecutablesV13mpsExecutable11kernelCache14ndxRuntimeBaseAESo0eI0CSg_SDyAC06KernelK3KeyVAC4WeakCy_AA0efO0CGGSo0E10NDXRuntimeCSgtcfcfA1_")
func _stub_ExecutablesV_defaultArg2() { fatalError() }

"""
            // Array.init(Span<Element>) is a real retroactive extension MetalPerformanceShadersGraph
            // adds to Swift.Array (confirmed via swift-demangle: "(extension in
            // MetalPerformanceShadersGraph):Swift.Array.init(Swift.Span<A>) -> [A]") that the
            // generator never renders at all (Array is a stdlib type, not one of this module's
            // own nominal types, so the normal per-type extension-rendering path never reaches
            // it).
            c += """

extension Array {
    public init(_ span: Swift.Span<Element>) { fatalError() }
}

"""
        return c
    }
}
