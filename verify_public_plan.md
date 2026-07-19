# verify_public.py — Fix Plan

## Overview

`verify_public.py` tests `swift-interface-gen` against public SDK Swift frameworks
(those with both a `.tbd` and a real `.swiftinterface`) as ground truth. The default run
uses a curated 18-framework baseline (`--frameworks` to pick specific ones, `--all` for
all ~193 discovered).

**Status as of branch `using_public_framework_as_groundtruth`**: **10/18 PASS**.

---

## ✅ PASSING (10/18)

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

Each of these was root-caused and fixed via real-tbd-vs-real-swiftinterface comparison —
see git log on this branch for the individual fix commits and their detailed messages
(each documents the specific root cause: shadowed nested types, mis-demangled associated
types, Swift-3 renamed C types, missing generic-parameter detection, etc.).

## ❌ REMAINING (8/18), smallest first

### Charts (2021 symbols)
First error: `type 'AnyChartContent' does not conform to protocol 'ChartContent'`, plus a
long tail (`AreaMark`, `BarMark`, `LineMark`, `PointMark`, `RectangleMark`, `RuleMark`,
`SectorMark`, ... all fail the same way). `ChartContent` is `@_typeEraser(AnyChartContent)`
and `@MainActor`-isolated; conforming mark types get their `body`/`Body` requirement
synthesized incorrectly by our generator (bare `Any` return type, which can't satisfy an
associated-type-typed protocol requirement). This needs proper result-builder /
type-eraser-aware associated-type synthesis, likely a non-trivial addition to Model.swift's
protocol-fallback logic. Also has smaller issues: `SPAngle` type not found, `_ScaleRangeOutputs`/
`_PrimitivePlottableKind` wrongly treated as generic, `AnyChartSymbolShape`/
`BasicChartSymbolShape` MainActor-isolation conformance errors, a `ChartBinRange<A>` not
conforming to `RangeExpression`, and a pack-expansion error. Likely the largest single
investigation remaining in the curated set — plan to split into sub-fixes.

### SoundAnalysis (2302 symbols)
Not yet investigated this session — needs a fresh root-cause pass.

### Speech (3323 symbols)
Not yet investigated this session — needs a fresh root-cause pass.

### CreateML (3849 symbols)
Not yet investigated this session — needs a fresh root-cause pass.

### GameKit (4680 symbols)
Not yet investigated this session — needs a fresh root-cause pass.

### HealthKit (5084 symbols)
Not yet investigated this session — needs a fresh root-cause pass.

### Vision (10163 symbols)
First error: `type 'AlignFaceRectanglesRequest' does not conform to protocol 'VisionRequest'`.
Also has ObjC bridge-header issues: `AVDepthData` forward-declared-only unavailability, and
`VNBarcodeSymbology` not found in scope (likely needs the CoreImage/Vision ObjC bridge header
extended). Large framework (10k+ symbols) — expect multiple distinct root causes bundled
together, similar to SwiftData/CryptoKit.

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
