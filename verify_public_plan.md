# verify_public.py — Fix Plan

## Overview

`verify_public.py` tests `swift-interface-gen` against public SDK Swift frameworks
(those with both a `.tbd` and a real `.swiftinterface`) as ground truth. The default run
uses a curated 18-framework baseline (`--frameworks` to pick specific ones, `--all` for
all ~193 discovered).

**Status as of branch `using_public_framework_as_groundtruth`**: **18/18 PASS**.

---

## ✅ PASSING (18/18 — COMPLETE)

Sorted by TBD symbol count (smallest/easiest first):

- NearbyInteraction (31)
- Translation (227)
- TipKit (741)
- CoreML (975)
- MetricKit (1223)
- TabularData (1568)
- SwiftData (1830)
- CryptoKit (1886)
- Combine (2085)
- StoreKit (2156)
- SoundAnalysis (2406)
- Speech (3323)
- CreateML (3849)
- GameKit (4680)
- HealthKit (5087)
- Vision (10163)
- Network (13028)
- Charts (2021)

Each of these was root-rooted and fixed via real-tbd-vs-real-swiftinterface comparison —
see git log on this branch for the individual fix commits and their detailed messages
(each documents the specific root cause: shadowed nested types, mis-demangled associated
types, Swift-3/4 renamed C types, missing generic-parameter detection, etc.).

### GameKit fix detail
Fixes multiple distinct C/ObjC issues:
1. `isTypeDefinedInFramework(module: "__C", ...)` in `Parser.swift` unconditionally returned `true` because `"__C"` was in `systemModules`, causing private/undeclared C types (like `RBSAssertion`, `ACDAccountStore`) to emit circular typealiases (`public typealias __C_RBSAssertion = RBSAssertion`) instead of struct/class stubs, producing "cannot find type in scope" errors. Fixed by checking `systemTypes.contains(typeName)` for `__C`.
2. Added missing AppKit UI system types (`NSView`, `NSViewController`, `NSWindow`, `NSColor`, `NSFont`, `NSImage`, `NSVisualEffectView`, `NSCollectionView`, `NSCollectionViewItem`, `NSCollectionViewLayout`, `NSCollectionViewLayoutAttributes`, `NSCollectionLayoutItem`, `NSCollectionLayoutSection`, `NSDirectionalEdgeInsets`, `NSValidatedUserInterfaceItem`, `NSParagraphStyle`, `NSResponder`, `NSEvent`, `NSMenu`, `NSMenuItem`, `NSAlert`) to `systemTypes` in `Parser.swift`.
3. Added Swift 3/4 C-type renames in `main.swift`: `NSVisualEffectBlendingMode` -> `NSVisualEffectView.BlendingMode`, `NSVisualEffectMaterial` -> `NSVisualEffectView.Material`, `NSCollectionViewItemHighlightState` -> `NSCollectionViewItem.HighlightState`, `NSCollectionViewScrollDirection` -> `NSCollectionView.ScrollDirection`, `NSURLSession*` -> `URLSession*`.
4. Added regex cleanup in `main.swift` for invalid dot-containing `__C_` declarations.
5. Added `Accounts` and `RunningBoardServices` import triggers in `resolveImports()`.

### HealthKit fix detail
1. Resolved `SleepAverageProviding` associated type inference for `countProvider`/`durationProvider` opaque return types by resolving `countProvider` -> `SleepMetrics.Counts` and `durationProvider` -> `SleepMetrics.Durations`.
2. Simplified demangled `QueryDescriptor` extension constraint paths (`Configuration.WithPredicate.PredicatedModelKind` -> `PredicatedModelKind`, `Configuration.WithSortDescriptor.SortedModelKind` -> `SortedModelKind`).

### Vision fix detail
Fixes multiple distinct root causes, all found via TBD symbol demangling (Vision's real
`.swiftinterface` doesn't cover these private/SPI declarations at all):
1. `VisionRequest.associatedtype Result` has no ABI-visible default and no per-conformer
   typealias anywhere across ~50 conforming structs/classes (satisfied only via generic
   `perform<each GenericA>` methods, never a per-conformer witness) — gave the protocol
   itself a default associated-type value (`associatedtype Result = Never`) instead of
   patching every conformer.
2. `VisionRequest.supportedComputeStageDevices` has no default implementation (unlike
   `computeDevice(for:)`/`requireInProcessExecution`, which already had one) and several
   conformers (e.g. `TrackRectangleRequest`) never implement it themselves — added a default
   impl to the existing `extension VisionRequest { ... }` block.
3. `PoseProviding.PoseJointName` used as a Dictionary key but only constrained `: Decodable`
   in the generated code — real ABI requires `Hashable` too; added the constraint.
4. `Attribute<A>.allLabelsAndConfidences: [A : Float]` uses `A` as a Dictionary key with no
   `Hashable` constraint on `A` — added it.
5. `AVDepthData` referenced but never triggered an `AVFoundation` import (the real, non-stub
   declaration); added `AVDepthData` as an import trigger in `resolveImports()`.
6. `CMSampleBufferRef` (Swift 3 renamed to `CMSampleBuffer`) — added to the general
   `simplifyType` rename list (alongside the existing `CVBufferRef` -> `CVBuffer` rename).
7. `XPCCodableObject` referenced bare but doesn't exist anywhere in the real `XPC` module
   (checked its swiftinterface directly) — same class of issue as HealthKit's
   `HKDataCacheContext`/`HKDataCacheProviding`, just in module `XPC` instead of `__C`; exposed
   the flattened stub (`XPC_XPCCodableObject`) under its bare name too.
8. `repeat each GenericA.Result` parses as `repeat (each GenericA.Result)` — invalid, since a
   pack-expansion member access must bind the pack element first (`repeat (each
   GenericA).Result`). The existing pack-detection logic in `Model.swift` did a blind
   `"repeat X"` -> `"repeat each X"` string replace with no awareness of a trailing member
   access; added a parenthesization pass for `repeat each X.` -> `repeat (each X).`.

### Network fix detail
Fixed via ~20 individually-committed root causes (see git log, commits with "Network fix N"
in the message, on this branch), spanning: regex bugs in conformance-stripping
(missing-brace/modifier-order), `Distributed` stdlib module shadowed by a local empty stub,
ActorSystem family (`mutating`, `GenericA.ID` constraints, explicit typealiases),
`MessageProtocol`/`JSON` associatedtype/generic-parameter gaps, the `ProtocolLinkage` family
(`PairedLinkage`/`DataLinkage` typealiases moved out of orphaned nested wrapper structs),
parameter packs (`<A, B>` -> `<A, each B>` across `Connection1-7`/`Configuration`/`Listener1-7`/
`NWParametersBuilder`, plus a pre-existing `<A1>`-pack-detection gap in `Model.swift`),
`~Copyable`/`~Escapable` suppression propagation and `@_lifetime(borrow self)` annotations,
`ConnectionProtocol.ApplicationProtocolType` (synthesized a `_NoApplicationProtocolOptions`
stub since no real conformer exists), `NetworkCoder` retroactive conformances for Foundation's
JSON/PropertyList en/decoders, and finally `QUICConnection`/`QUICStreamInstance`/
`QUICDatagramFlow`/`QUICPath` (internal SPI helper classes with no public
`.swiftinterface` entry, needing synthesized `MultiplexedFlow`/`MultiplexingPath`
conformances so `QUICConnection` could infer its own associated types). Network now PASSes.

### Charts fix detail
**Fully resolved** (commit `b50f214`): the link-stage `@_typeEraser` witness-thunk blocker is
fixed. Charts now PASSes. The earlier compile fixes (commit `2509588`: shadowed `body`/`Body`
types, missing `Never`/`Optional` conformances, `nonisolated` fixes, associated-type and
generic-parameter gaps, `Chart<Content>.init`'s associated-type-chain erasure) handled all
first-pass errors, leaving only the final-link issue.

**Root cause**: `AnyChartContent` is ChartContent's `@_typeEraser` type (confirmed in the
real `.swiftinterface`: `@_typeEraser(AnyChartContent) ... public protocol ChartContent`),
and the real declaration is `@frozen`. Without `@frozen`, AnyChartContent is a resilient
(ABI-non-fixed-layout) struct, and under library evolution its protocol-witness thunks for
`_makeChartContent(content:inputs:)` and the `body` getter get compiled as resilient-access
thunks whose mangled names route through the protocol's own generic-placeholder type rather
than AnyChartContent directly — those two specific thunks then never make it into
`-exported_symbols_list` and come up undefined at final-link time, even though the same code
compiles fine into the first-pass (`-undefined dynamic_lookup`) dylib. This explains why
`verify_public.py`'s first-pass stub count was 0 (no missing symbols detected
pre-export-filtering) while the final link still failed — the symptom was link-stage only,
invisible to the ordinary first-pass-vs-exports comparison.

**Fix**: Added `@frozen` to the generated `AnyChartContent` declaration (alongside the
pre-existing `body`/`_makeChartContent` explicit-member fix from commit `2509588`, still
required separately since protocol-extension defaults aren't reproduced by this generator).
Verified via a minimal standalone repro isolating exactly one variable: compiled a trimmed
ChartContent/AnyChartContent pair matching the generated shape, first without `@frozen`
(reproduced the exact 2 undefined "protocol witness for ..." symbols against a real exports
list extracted from Charts.tbd), then with `@frozen` added and nothing else changed (link
succeeded cleanly).

---

## Working pattern (established, keep following)

For each ERROR framework, smallest-to-largest by TBD symbol count:
1. `python3 verify_public.py --frameworks <Name>` to get the first compile error.
2. Compare against the real `.swiftinterface` (found under
   `$(xcrun --show-sdk-path)/System/Library/Frameworks/<Name>.framework/**/*.swiftinterface`)
   and the real `.tbd` (demangle relevant symbols with `xcrun swift-demangle` to see what
   the ABI actually encodes vs. what our generator produced).
3. Fix in generator source (`Parser.swift`/`Model.swift`/`main.swift`/`String+RegexFree.swift`).
4. Rebuild: see the `clang++`/`swiftc` command in repo memory / recent commit messages
   (NOT `swift build` — stray non-Swift files under `Sources/SwiftInterfaceGen/` break SwiftPM).
5. Re-test the target framework, iterate until it PASSes.
6. Verify no regressions: full curated `python3 verify_public.py`, plus
   `python3 run_regression_tests.py` (9 private targets) and
   `python3 orchestrate.py Combine test_Combine.swift`.
7. Commit with a detailed message covering every root cause fixed and the verification
   results (curated pass count before/after, regression suite status).
