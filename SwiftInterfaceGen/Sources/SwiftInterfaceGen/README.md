# SwiftInterfaceGen — Source Code Architecture

`swift-interface-gen` reconstructs compilable Swift mock libraries directly from Apple SDK `.tbd` (Text-Based Stub) files. The resulting dynamic libraries export exactly the symbols required by each framework's TBD, enabling downstream Swift code to link against and run mock versions of private frameworks without requiring the real system binaries at build time.

---

## Supported Target Frameworks

| Framework | First-pass stubs | Final missing symbols |
|---|---|---|
| ODIE | 0 | 0 |
| CoreAICompiler | 0 | 0 |
| CoreAICommon | 0 | 0 |
| ModelCatalog | 0 | 0 |

Dependency frameworks (auto-generated as stubs by `orchestrate.py`): `AppleIntelligenceReporting`, `FeatureFlags`, `UnifiedAssetFramework`, `CoreAIDelegates`, `TokenGenerationCore`, `ModelCatalogRuntime`.

Generated libraries target **Swift language-mode 6** with experimental features `NonescapableTypes` and `Lifetimes`, matching the real Apple frameworks.

---

## Directory Layout & File Roles

| File | Role |
|---|---|
| **`main.swift`** | CLI entry point. Coordinates TBD parsing, symbol preprocessing, dependency resolution, default-argument mapping, symbol-export-list generation, and final post-processing (de-genericisation, type erasure fixes). Also implements `--compare` mode for symbol-alignment verification and `--generate-stubs` mode for dependency stub synthesis. |
| **`Parser.swift`** | Core parsing engine. Demangles ABI symbols, builds the nominal type tree, resolves protocol conformances, infers generic parameters, and parses member signatures (methods, properties, subscripts, initialisers, enum cases). Contains the `simplifyType` function and the `fixUnnamedParameters` utility. |
| **`Model.swift`** | AST node (`TypeNode`) and code-generation engine. Traverses the type tree and emits compilable Swift declarations with correct conformances, access modifiers, default return values, and subscript overloads. |
| **`Config.swift`** | SDK root resolution and global configuration. |
| **`String+RegexFree.swift`** | Regex-free string utilities: keyword escaping, generic-application stripping, module-prefix manipulation, operator fixups. |

---

## End-to-End Pipeline

```
.tbd file
    │
    ▼
[1] Symbol Extraction          main.swift  extractSymbols()
    Collect all _$s* mangled symbols + _OBJC_CLASS_$_ symbols
    Walk reexported-libraries recursively
    │
    ▼
[2] Default-Argument Mapping   main.swift  processSymbols()
    fA_ / fA0_ / fA1_ … symbols → defaultArgMap[baseSymbol] = Set<argIndex>
    │
    ▼
[3] Nominal Type Discovery     Parser      discoverNominalTypes()
    VMn/OMn/CMn → struct/enum/class kind
    Mp → protocol
    Builds discoveredProtocols + discoveredConcreteTypes
    │
    ▼
[4] Precompute                 Parser      precompute()
    Infer generic parameter counts from demangled applications
    Discover framework namespaces
    │
    ▼
[5] Signature Parsing          Parser      parse()
    For each symbol:
      • enum case for … → enumCase(name, payload)
      • protocol conformance descriptor → node.conformances
      • getter/setter/modify → property(name, type, readOnly, static)
      • subscript getter/setter → property(name="subscript[type]", …)
      • method/function → method(name, signature, static)
      • init / init? → initializer(sig)
      • associated type descriptor → associatedType(decl)
    Where-clause constraints extracted and appended to signatures
    │
    ▼
[6] AST Code Generation        Model       generateAll() / generateCode()
    TypeNode tree → Swift source:
      • Conformances filtered to TBD-declared ones (no blanket Hashable/Codable)
      • Subscript overloads deduplicated by (name, type) key
      • Generic params/where clauses included in init + method declarations
      • dummyDefaultValue() injected at default-argument positions
      • Sendable added to all protocols (Swift 6 strict concurrency)
      • Non-synthesisable conformances stripped from enums with ObjC/Error payloads
      • indirect applied to recursive enums
    │
    ▼
[7] Post-Processing            main.swift  postProcess()
    • Strip module prefixes (ODIE., Swift., Foundation., …)
    • De-genericise Tensor / TensorRequirements → non-generic ABI form
    • Filter stdlib-extension symbols from exports list (_$ss, _$sSf, …)
    • Apply discovered generics, strip invalid generics from protocols/typealiases
    • Inject ResourceBundleIdentifier<T> if missing
    • Final newline cleanup
    │
    ▼
[8] Export List                main.swift
    Write {Framework}_exports.txt from tbdSymbols
    (stdlib-extension symbols filtered out — not producible from Swift source)
    │
    ▼
[9] Output Swift Interface     stdout
    Complete .swift file ready for swiftc -emit-library
```

---

## Two-Pass Compilation & Assembly Stub Alignment

The `orchestrate.py` orchestrator runs a two-pass build to achieve exact symbol alignment:

```
Pass 1 — Compile without exports list
    swiftc -emit-library … (no -exported_symbols_list)
    → LocalFrameworks/{Name}.framework/{Name}  (initial dylib)

Comparison
    swift-interface-gen --compare {Name}_exports.txt initial.dylib stubs_{Name}.s
    → Lists missing symbols; generates .quad 0 stubs for each

clang -c stubs_{Name}.s -o stubs_{Name}.o

Pass 2 — Relink with stubs + enforced exports
    swiftc -emit-library … stubs_{Name}.o
                           -Xlinker -exported_symbols_list {Name}_exports.txt
    → Final dylib with exactly the right symbol table

Verification
    swift-interface-gen --compare {Name}_exports.txt final.dylib /dev/null
    → Count: 0 missing symbols
```

### Why some assembly stubs are still needed

Even with precise interface generation, a small number of symbols cannot be produced from Swift source alone:

| Symbol type | Example | Reason |
|---|---|---|
| `__allocating_init` + dispatch thunks | `CoherentAssetLock.__allocating_init(coherenceTokens:)Tj` | Swift internal class-allocation ABI, not expressible in source |
| Protocol dispatch thunks | `CoherenceTokenProvider.acquireCoherenceToken(…)Tj/Tu/Tq` | vtable dispatch metadata, auto-generated by compiler |
| Extensions on ObjC types | `__C.OS_xpc_object.asAny` | `__C` module extensions require ObjC bridging headers |
| Struct `deinit` | `TensorOffsetSequence.deinit` | Swift emits these for structs with non-trivial cleanup; not writable in source |

`fA_` default-argument accessor symbols are now natively emitted by the Swift compiler via typed constant defaults. The compare step uses `nm -U` (all symbols, including local) so locally-scoped `fA_` thunks are found without requiring assembly stubs.

---

## AST Design (`TypeNode`)

```swift
class TypeNode {
    let name: String
    var kind: String               // "class" | "struct" | "enum" | "protocol" | "unknown"
    var members: [String: MemberKind]          // keyed by signature (subscripts by "subscript[type]")
    var extensionMembers: [String: MemberKind] // PAAE extension members
    var constrainedExtensions: [String: [String: MemberKind]]  // keyed by where-clause
    var nestedTypes: [String: TypeNode]
    var conformances: Set<String>  // Only TBD-declared conformances
    var isGeneric: Bool
    var finalMembers: Set<String>  // Members without dispatch thunk → emit as final
    weak var parent: TypeNode?
}

enum MemberKind {
    case initializer(String)                                    // full decl incl. generic params
    case property(name: String, type: String, isReadOnly: Bool, isStatic: Bool)
    case method(name: String, signature: String, isStatic: Bool)
    case enumCase(name: String, payload: String?, hasLabel: Bool)
    case associatedType(String)
    case other(String)
}
```

---

## Key Design Decisions

### Conformance precision
Default `Hashable`/`Codable`/`Sendable` are **not** blindly added. Conformances come exclusively from `protocol conformance descriptor for` TBD symbols, preventing ~500 extra conformance-descriptor symbols that would mismatch the real binary. Only `Sendable` is added structurally to all protocols (required by Swift 6 strict concurrency).

### Tensor / TensorRequirements de-genericisation
The real ODIE binary exports `Tensor.RawView`, not `Tensor<A>.RawView`. A postProcess step rewrites `struct Tensor<A>` → `struct Tensor` and strips all `<Any>`/`<A>` specialisations throughout, fixing ~170 mangled-symbol mismatches in one pass.

### Subscript overload deduplication
Subscripts share the member name `"subscript"` but can have multiple overloads (e.g. `subscript([Int])` and `subscript(Int...)`). The storage key includes the type signature (`"subscript[([Int]) -> A]"`) to retain all overloads, and the emission dedup key does likewise.

### Default argument injection
`fA_` / `fA0_` … symbols are pre-mapped to their parent function in `processSymbols()`. `Model.swift` injects typed constant defaults at the correct parameter positions via `getDefaultValue(for:)`:

| Parameter type | Emitted default | Produces `fA_`? |
|---|---|---|
| `Bool` | `false` | ✓ |
| `Int`, `Double`, … | `0` | ✓ |
| `String` | `""` | ✓ |
| `Optional<T>` / `T?` | `nil` | ✓ |
| `Array<T>` / `[T]` | `[]` | ✓ |
| `Dictionary<K,V>` / `[K:V]` | `[:]` | ✓ |
| `() -> T` (no-arg closure) | `{ getDefaultValue(T) }` | ✓ |
| `(X) -> T` (single-arg closure) | `{ _ in getDefaultValue(T) }` | ✓ |
| `any Protocol` (existential) | `_Default_Protocol()` (sentinel struct) | ✓ |
| other | `dummyDefaultValue()` | ✗ (assembly stub) |

For protocol existentials, a sentinel struct `_Default_Protocol` is synthesised in a `// --- Protocol Default Sentinels ---` section of the interface file (stripped from Phase A module emit, kept for Phase B dylib compile). The struct body is auto-generated from the protocol's required members.

### `_$ss` / `_$sSf` stdlib-extension filtering
ODIE defines extensions on `~Escapable` Swift stdlib types (`RawSpan`, `MutableRawSpan`) and on `Swift.Float` / `Swift.Double`. These use mangled prefixes `_$ss` and `_$sSf`. They are filtered from the exports list because our mock library cannot provide them — they require the real ODIE runtime. Assembly stubs cover them instead.

---

## `--compare` Mode

```
swift-interface-gen --compare <exports_file> <dylib_path> <stubs_output.s>
```

Reads the expected symbol list from `<exports_file>`, inspects the compiled dylib with `nm -U` (all symbols, including local), and emits `.quad 0` assembly stubs for every symbol truly absent from the dylib into `<stubs_output.s>`. Using `nm -U` ensures Swift-emitted local symbols (such as `fA_` default-argument thunks under `-enable-library-evolution`) count as present and do not generate unnecessary stubs. Also reports extra symbols.

## `--generate-stubs` Mode

```
swift-interface-gen <tbd_path> --generate-stubs <output_dir>
```

Generates minimal Swift stub source files for each dependency framework discovered in `<tbd_path>`'s reexported-libraries list. Used by `orchestrate.py` to auto-synthesise dependency stubs (e.g. `FeatureFlags.swift`, `UnifiedAssetFramework.swift`) without manual maintenance.
