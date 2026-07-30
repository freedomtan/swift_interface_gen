# Reconstructed Private Framework Pipeline TODO

## Completed Tasks
- [x] Align exported dynamic library symbols (`nm`/`dyld_info -exports` matching original `.tbd` symbols 100%) via the assembly-based `stubs_{name}.s` compiler/linker pipeline.
- [x] Implement target-isolated dynamic stub generation directories (`tmp_stubs_{name}`) to prevent dependency-resolution overwrite conflicts.
- [x] Solve namespace conflicts when nested structures match external module names (e.g. `ModelCatalog.Model.ResourceBundle.TokenGeneration`).
- [x] Auto-Cleanup Flag: Added a `--clean` command-line option to `orchestrate.py` to automatically remove target-specific temporary stub directories (like `tmp_stubs_{name}`) after successful runs.
- [x] **Eliminate all ModelCatalog first-pass stubs (was 11, then 10, now 0):**
  - Constrained extension `ResourceBundleIdentifier<where A==LLMBundle>.serverConfiguration()` fixed via `<A: ResourceBundle>` generic constraint in `Model.swift`.
  - `fA_` default-argument accessor stubs eliminated by: (a) emitting typed constant defaults (`[]`, `[:]`, `{ false }`, `{ _ in false }`, `_Default_Proto()`) so Swift natively compiles the thunks, and (b) switching `--compare` from `nm -gU` to `nm -U` so locally-scoped thunks are found without assembly stubs.
  - Regression (2074 first-pass stubs) fixed: "property descriptor for ..." symbols (`pMV` suffix) never have their own `Tj` dispatch-thunk variant, so the naive `!tbdSymbols.contains(mangled + "Tj")` final-property check unconditionally poisoned `finalMembers` for every class property via its descriptor symbol alone, overriding correct non-final votes from the property's own getter/setter/modify accessors. Fixed by excluding `pMV` symbols from the final-vote (`Parser.swift`, commit `a12eae2`).
- [x] **TokenGenerationCore's InternalSwiftProtobuf/PromptKit dependency chain compiles cleanly** (commit `5e07d0b`): promoted both to full standalone `orchestrate.py` builds and fixed 7 generator bugs surfaced by full (rather than minimal `--generate-stubs`) generation — see commit message for detail.
- [x] **Public-framework ground-truth verification (`verify_public.py`), curated 18-framework suite: 18/18 PASS** (see `verify_public_plan.md` for per-framework detail).
  - Fixed: NearbyInteraction, Translation, TipKit, CoreML, MetricKit, TabularData, SwiftData, CryptoKit, Combine, StoreKit, SoundAnalysis, Speech, CreateML, GameKit, HealthKit, Vision, Network, Charts.
  - Each fix verified against zero regressions in the 9 private targets (`run_regression_tests.py`) plus Combine (`orchestrate.py`).
  - **All curated frameworks now PASS.** The generator successfully reproduces the ABI and compiles cleanly against real SDK ground truth for the full baseline suite.
- [x] **CoreAIDelegates first-pass stubs reduced from 29 to 3:** root cause was `symbolModule` being derived from the mangled name's own module-length prefix (which always names the module of the type being EXTENDED, not the module the extension itself is declared in) — fixed by extracting the true declaring module from the demangled `(extension in X):` marker. This exposed several pre-existing, unrelated bugs in the shared extension-rendering path (surfaced, not caused, by relaxing the ROP-only/kind-known gates that had been masking them) — all fixed: Combine `Record.Recording` duplicate `init(from:)`, `Publisher.flatMap` bare-`A` erasure, `Publisher.switchToLatest()` multi-hop `Self.Output.Failure` erasure; CoreML/CreateML stdlib-placeholder rename not applied to member bodies (only the constraint header); Network `AsyncSequence` never getting `kind == "protocol"`, and `StreamDeserializer.StepLoopResult` duplicate Hashable witnesses from an unmodeled `~Copyable`-conditional conformance; HealthKit `extension Coherence.CRContext` emitted for a module with no real `.swiftinterface` to confirm the type exists, and `SleepSessionQuery.Descriptor where A == A1` referencing a depth-suffixed placeholder naming a nested type's own generic param that our single-level generic rendering has no name for. The remaining 3 stubs (`AIModel.loadFunction`/`loadFunctionState`) lack the `(extension in ...)` demangled marker entirely despite being real cross-module extension members — a narrow ABI-mangling anomaly, not fixed.

## Future Improvements

### 1. Build & Pipeline Optimization
- [ ] **Dependency Build Caching:** Cache built local frameworks under `LocalFrameworks/` and skip compiling them if their corresponding `.tbd` file and generator source have not changed.
- [ ] **Parallel Compilation:** Build independent branches of the framework dependency graph concurrently to speed up multi-framework compilation runs.

### 2. Generator Improvements
- [ ] **Associated Type & Protocol Requirement Reconstructor:** Extract associated types and required members from external protocols to generate more complete stub definitions, reducing compilation layout errors.
- [ ] **Cross-SDK Recompilation Support:** Extend the SDK search paths and target compilation commands to support compiling mock private frameworks for iOS, iPadOS, watchOS, and tvOS simulators.
- [ ] **Optimized Swift ABI Nominal Type Classification:** Enhance the nominal type lookup logic to better classify enums, classes, and protocols, especially in obscure generic constraints.

## Hardcoded Code Cleanup Candidates

The following hardcoded code blocks should be removed and replaced with dynamic, generic solutions:

1. **Target-Specific Fixups in `applyTypeFixups()` ([Parser.swift:L1322-1369](SwiftInterfaceGen/Sources/SwiftInterfaceGen/Parser.swift#L1322-L1369)):**
   - *Issue:* Hardcodes AST layout fixups (like required properties `id`, `cost`, `inferenceProviders`, etc.) specifically for `ModelCatalog` classes like `VisionModelBase`, `VoicesOverridesBase`, and `XPCServiceClientConnection`.
   - *Fix:* Replace this with a generic **Associated Type & Protocol Requirement Reconstructor** that dynamically resolves conformances, looks up the protocol's signature requirements, and synthesizes missing members.

2. **Hardcoded postProcess Extension Append ([main.swift:L543-549](SwiftInterfaceGen/Sources/SwiftInterfaceGen/main.swift#L543-L549)):**
   - *Issue:* Statically appends a concrete protocol extension `extension GenericA: AssetMetadata, AssetContents` when `defaultModule == "ModelCatalog"`.
   - *Fix:* Dynamically detect conformances on generic placeholders and automatically output their implementations based on the protocol requirements.

3. **Condition-Based Import Resolution ([main.swift:L74-106](SwiftInterfaceGen/Sources/SwiftInterfaceGen/main.swift#L74-L106)):**
   - *Issue:* Hardcodes module name additions based on simple substring occurrences in the generated source (e.g. `if code.contains("MTL") { imports.insert("Metal") }`).
   - *Fix:* Resolve namespace mappings by inspecting the type namespaces from symbols or matching types against known API catalogs.
