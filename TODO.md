# Reconstructed Private Framework Pipeline TODO

## Completed Tasks
- [x] Align exported dynamic library symbols (`nm`/`dyld_info -exports` matching original `.tbd` symbols 100%) via the assembly-based `stubs_{name}.s` compiler/linker pipeline.
- [x] Implement target-isolated dynamic stub generation directories (`tmp_stubs_{name}`) to prevent dependency-resolution overwrite conflicts.
- [x] Solve namespace conflicts when nested structures match external module names (e.g. `ModelCatalog.Model.ResourceBundle.TokenGeneration`).

## Future Improvements

### 1. Build & Pipeline Optimization
- [ ] **Dependency Build Caching:** Cache built local frameworks under `LocalFrameworks/` and skip compiling them if their corresponding `.tbd` file and generator source have not changed.
- [ ] **Parallel Compilation:** Build independent branches of the framework dependency graph concurrently to speed up multi-framework compilation runs.
- [ ] **Auto-Cleanup Flag:** Add a `--clean` command-line option to `orchestrate.py` to automatically remove target-specific temporary stub directories (like `tmp_stubs_{name}`) after successful runs.

### 2. Generator Improvements
- [ ] **Associated Type & Protocol Requirement Reconstructor:** Extract associated types and required members from external protocols to generate more complete stub definitions, reducing compilation layout errors.
- [ ] **Cross-SDK Recompilation Support:** Extend the SDK search paths and target compilation commands to support compiling mock private frameworks for iOS, iPadOS, watchOS, and tvOS simulators.
- [ ] **Optimized Swift ABI Nominal Type Classification:** Enhance the nominal type lookup logic to better classify enums, classes, and protocols, especially in obscure generic constraints.
