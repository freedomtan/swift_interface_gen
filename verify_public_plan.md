# verify_public.py — Fix Plan

## Overview

`verify_public.py` tests `swift-interface-gen` against public SDK Swift frameworks
(those with both a `.tbd` and a real `.swiftinterface`) as ground truth. The default run
uses a curated 18-framework baseline (`--frameworks` to pick specific ones, `--all` for
all ~193 discovered).

**Status as of branch `using_public_framework_as_groundtruth`**: **16/18 PASS**.

---

## ✅ PASSING (16/18)

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

## ❌ REMAINING (2/18), smallest first

### Charts (2021 symbols)
**Mostly fixed** (commit `2509588`): all ~15 first-pass compile errors are resolved (shadowed
`body`/`Body` types on AreaMark/LineMark/PointMark/etc. retyped to `Swift.Never`, missing
`Never`/`Optional` ChartContent-family conformances added, `nonisolated` fixes for
ChartSymbolShape, `SPAngle`/`ChartBinRange`/`NumberBins`/`BuilderTuple`/Vectorized*PlotContent
associated-type and generic-parameter fixes, `ValueAlignedChartScrollTargetBehavior`'s
redundant-conformance conflict, `Chart<Content>.init`'s associated-type-chain erasure).

**Remaining blocker**: `AnyChartContent` (ChartContent's `@_typeEraser` type) compiles fine
into the first-pass dylib but its `_makeChartContent`/`body` witness-thunk symbols vanish
under `-exported_symbols_list` at the final-link stage, leaving 2 undefined symbols. This
looks like a Swift compiler ABI-emission quirk specific to `@_typeEraser`-synthesized
conformances (the witness thunk's mangled name uses the protocol's own generic placeholder
`x` rather than `AnyChartContent`, and gets dropped entirely once the exports allowlist is
applied) — investigated but not resolved; needs deeper linker/ABI investigation or an
upstream Swift bug report. Charts still reports ERROR, not PASS.

### Network (13024 symbols)
Largest framework in the curated set; already has substantial special-casing in
`main.swift`'s `postProcess` (`NetworkProtocolOptions`/`BottomProtocolHandler` conformance
stripping, `~Copyable` extension stripping, ~25 stub declarations for `OS_nw_*`/`OS_sec_*`/
`tls_*` C types). Not yet passing — needs a fresh root-cause pass to see what's left.

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
