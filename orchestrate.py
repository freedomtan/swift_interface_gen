#!/usr/bin/env python3
import glob
import os
import sys
import subprocess
import shutil

TARGET_FRAMEWORKS = {
    "ModelCatalogRuntime",
    "CoreAICommon",
    "CoreAICompiler",
    "CoreAIAsset",
    "CoreAIRuntime",
    "ModelCatalog",
    "ODIE",
    "TokenGenerationCore",
    "CoreAIDelegates",
    "AppleIntelligenceReporting",
    "FeatureFlags",
    "UnifiedAssetFramework",
    "InternalSwiftProtobuf",
    "PromptKit",
}

# Pre-defined system modules that are part of standard SDK
SYSTEM_MODULES = {
    "Swift", "Foundation", "ObjectiveC", "os", "Dispatch", "Metal", "CoreGraphics",
    "CoreVideo", "CoreMedia", "IOSurface", "UniformTypeIdentifiers", "XPC", "Synchronization",
    "MetricKit", "Combine", "CoreAI"
}

SDK_ROOT = subprocess.check_output(["xcrun", "--show-sdk-path"]).decode("utf-8").strip()

def locate_tbd(name):
    # Search in SDK Frameworks, PrivateFrameworks and SubFrameworks
    paths = [
        f"{SDK_ROOT}/System/Library/Frameworks/{name}.framework/{name}.tbd",
        f"{SDK_ROOT}/System/Library/Frameworks/{name}.framework/Versions/A/{name}.tbd",
        f"{SDK_ROOT}/System/Library/Frameworks/{name}.framework/Versions/Current/{name}.tbd",
        f"{SDK_ROOT}/System/Library/PrivateFrameworks/{name}.framework/{name}.tbd",
        f"{SDK_ROOT}/System/Library/PrivateFrameworks/{name}.framework/Versions/A/{name}.tbd",
        f"{SDK_ROOT}/System/Library/PrivateFrameworks/{name}.framework/Versions/Current/{name}.tbd",
        f"{SDK_ROOT}/System/Library/SubFrameworks/{name}.framework/{name}.tbd",
        f"{SDK_ROOT}/System/Library/SubFrameworks/{name}.framework/Versions/A/{name}.tbd",
        f"{SDK_ROOT}/System/Library/SubFrameworks/{name}.framework/Versions/Current/{name}.tbd",
    ]
    for p in paths:
        if os.path.exists(p):
            return p
    return None

def extract_install_name(tbd_path):
    if not tbd_path or not os.path.exists(tbd_path):
        return None
    with open(tbd_path, "r", encoding="utf-8") as f:
        for line in f:
            if "install-name:" in line:
                parts = line.split("install-name:")
                if len(parts) > 1:
                    val = parts[1].strip()
                    if (val.startswith("'") and val.endswith("'")) or (val.startswith('"') and val.endswith('"')):
                        val = val[1:-1]
                    return val
    return None

def compile_framework(name, swift_source, is_stub=False, emit_module=True, emit_library=True, use_exports=True, extra_objects=None, library_evolution=True):
    print(f"--- Compiling {'Stub ' if is_stub else ''}Framework: {name} ---")
    fw_dir = f"LocalFrameworks/{name}.framework"
    mod_dir = f"{fw_dir}/Modules/{name}.swiftmodule"
    os.makedirs(mod_dir, exist_ok=True)
    
    # 1. Emit Swift module interface
    if emit_module:
        cmd_emit = [
            "swiftc", "-emit-module", "-module-name", name, swift_source,
            "-enable-library-evolution", "-language-mode", "6",
            "-F", "LocalFrameworks", "-sdk", SDK_ROOT,
            "-emit-module-interface-path", f"{mod_dir}/arm64-apple-macos.swiftinterface",
            "-o", f"{mod_dir}/arm64-apple-macos.swiftmodule"
        ]
        bridge_h = f"{name}Interface_bridge.h"
        if not is_stub and os.path.exists(bridge_h):
            cmd_emit.append("-import-underlying-module")

        # Stage B/C dependency-stub enrichment can render real members using
        # ~Escapable types (Span) and @_lifetime annotations -- the real framework's
        # own interface isn't stub-vs-real-aware about which features it needs, so
        # these flags must be enabled unconditionally, not just for `not is_stub`.
        cmd_emit.extend([
            "-enable-experimental-feature", "NonescapableTypes",
            "-enable-experimental-feature", "Lifetimes"
        ])

        print("Running:", " ".join(cmd_emit))
        subprocess.check_call(cmd_emit)
    
    # 2. Compile dynamic library
    if emit_library:
        tbd_path = locate_tbd(name)
        install_name = extract_install_name(tbd_path) if tbd_path else None
        
        lib_dest_path = f"{fw_dir}/{name}"
        symlink_needed = False
        subpath = None
        
        if install_name:
            framework_marker = f"/{name}.framework/"
            if framework_marker in install_name:
                subpath = install_name.split(framework_marker)[1]
                if subpath != name:
                    lib_dest_path = f"{fw_dir}/{subpath}"
                    symlink_needed = True
                    
        if symlink_needed and subpath:
            os.makedirs(os.path.dirname(lib_dest_path), exist_ok=True)
            
        cmd_lib = [
            "swiftc", "-emit-library", "-o", lib_dest_path,
            swift_source, "-module-name", name,
            "-F", "LocalFrameworks", "-sdk", SDK_ROOT,
            "-language-mode", "6",
            "-Xlinker", "-not_for_dyld_shared_cache"
        ]
        if library_evolution:
            cmd_lib.insert(cmd_lib.index("-module-name"), "-enable-library-evolution")
        bridge_h = f"{name}Interface_bridge.h"
        if not is_stub and os.path.exists(bridge_h):
            cmd_lib.extend(["-import-objc-header", bridge_h])

        if install_name:
            cmd_lib.extend(["-Xlinker", "-install_name", "-Xlinker", install_name])
            
        if extra_objects:
            for obj in extra_objects:
                cmd_lib.extend(["-Xlinker", obj])
            
        cmd_lib.extend([
            "-enable-experimental-feature", "NonescapableTypes",
            "-enable-experimental-feature", "Lifetimes"
        ])

        if not is_stub:
            # Linker flags for symbol matching
            if use_exports:
                exports_file = f"{name}_exports.txt"
                if os.path.exists(exports_file):
                    cmd_lib.extend(["-Xlinker", "-exported_symbols_list", "-Xlinker", exports_file])
            else:
                # Phase B: initial build without exports list.
                # Allow undefined symbols so the dylib builds even when our stub frameworks
                # don't export all the symbols the real frameworks do (they'll be resolved at
                # runtime from the system private frameworks via DYLD_FRAMEWORK_PATH).
                cmd_lib.extend(["-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup"])
                
        print("Running:", " ".join(cmd_lib))
        subprocess.check_call(cmd_lib)
        
        if symlink_needed and subpath:
            symlink_path = f"{fw_dir}/{name}"
            if os.path.exists(symlink_path) or os.path.islink(symlink_path):
                if os.path.isdir(symlink_path) and not os.path.islink(symlink_path):
                    shutil.rmtree(symlink_path)
                else:
                    os.remove(symlink_path)
            os.symlink(subpath, symlink_path)

built = set()
building = set()
clean_after = False
keep_stubs = False
skip_built_deps = True
generator_built_this_process = False

# PostProcess/*.swift holds postProcess()'s per-module fixup functions, one file per module
# (see main.swift's postProcess() for the call sites) -- globbed rather than listed by name so
# adding a new module's file here doesn't also require editing this list.
POSTPROCESS_SOURCES = sorted(glob.glob("SwiftInterfaceGen/Sources/SwiftInterfaceGen/PostProcess/*.swift"))

GENERATOR_SOURCES = [
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/main.swift",
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Parser.swift",
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Model.swift",
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Config.swift",
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/String+RegexFree.swift",
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/TreeNode.swift",
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/GenerateStubs.swift",
    "SwiftInterfaceGen/Sources/SwiftInterfaceGen/DemangleWrapper.cpp",
] + POSTPROCESS_SOURCES

def ensure_generator_built():
    """build_framework() is called once per resolved real-framework dependency -- for a
    target with several real-framework dependencies (e.g. TokenGenerationCore resolves 6),
    that reissued the ~20s swiftc -O generator rebuild up to 7x in a single orchestrate.py
    invocation, and again on every subsequent invocation (e.g. once per target in
    run_regression_tests.py's 9-target loop), even though the generator's own sources hadn't
    changed. Rebuild only if the binary is missing/stale relative to its sources -- both within
    this process (generator_built_this_process) and across process invocations (mtime check)."""
    global generator_built_this_process
    if generator_built_this_process:
        return
    generator_bin = "./swift-interface-gen"
    needs_build = not os.path.exists(generator_bin)
    if not needs_build:
        bin_mtime = os.path.getmtime(generator_bin)
        needs_build = any(
            os.path.exists(src) and os.path.getmtime(src) > bin_mtime
            for src in GENERATOR_SOURCES
        )
    if needs_build:
        print("--- Building Generator ---")
        subprocess.check_call([
            "clang++", "-O3", "-std=c++11", "-c",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/DemangleWrapper.cpp",
            "-o", "SwiftInterfaceGen/Sources/SwiftInterfaceGen/DemangleWrapper.o"
        ])
        subprocess.check_call([
            "swiftc", "-O", "-parse-as-library",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/main.swift",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Parser.swift",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Model.swift",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Config.swift",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/String+RegexFree.swift",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/TreeNode.swift",
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/GenerateStubs.swift",
        ] + POSTPROCESS_SOURCES + [
            "SwiftInterfaceGen/Sources/SwiftInterfaceGen/DemangleWrapper.o",
            "-lc++",
            "-o", generator_bin
        ])
    else:
        print("--- Skipping generator build: up to date ---")
    generator_built_this_process = True

def is_framework_fully_built(name):
    """Check whether name's framework is already present in LocalFrameworks from a prior
    run, so build_framework can skip rebuilding it. A Swift framework needs its dylib +
    swiftmodule; a pure-ObjC framework (see is_pure_objc in build_framework) only ever gets
    a module.modulemap, never a swiftmodule, so that alone is accepted as "has a Swift side"."""
    fw_dir = f"LocalFrameworks/{name}.framework"
    mod_path = f"{fw_dir}/Modules/{name}.swiftmodule/arm64-apple-macos.swiftmodule"
    modulemap_path = f"{fw_dir}/Modules/module.modulemap"
    if not os.path.exists(mod_path) and not os.path.exists(modulemap_path):
        return False

    direct = f"{fw_dir}/{name}"
    if os.path.exists(direct) or os.path.islink(direct):
        return True

    # The dylib may live under a different subpath (e.g. Versions/A/Name) per the TBD's
    # install-name, with `name` only present as a symlink to it.
    tbd_path = locate_tbd(name)
    install_name = extract_install_name(tbd_path) if tbd_path else None
    if install_name:
        framework_marker = f"/{name}.framework/"
        if framework_marker in install_name:
            subpath = install_name.split(framework_marker)[1]
            if os.path.exists(f"{fw_dir}/{subpath}"):
                return True
    return False

def build_framework(name, is_target=False):
    if name in built:
        return
    if name in building:
        raise Exception(f"Circular dependency detected: {name} in {building}")

    if skip_built_deps and not is_target and is_framework_fully_built(name):
        print(f"--- Skipping {name}: already built in LocalFrameworks (use --force-rebuild-deps to rebuild) ---")
        built.add(name)
        return

    building.add(name)
    
    # Target framework
    tbd_path = locate_tbd(name)
    if not tbd_path:
        raise Exception(f"Could not locate TBD file for target framework: {name}")
        
    print(f"\n========================================")
    print(f"Resolving dependencies for Target: {name}")
    print(f"========================================")
    
    # 1. Build swift-interface-gen first (skipped if already up to date)
    ensure_generator_built()

    # 2. Run generator in stub-generation mode on the target TBD
    tmp_stubs_dir = f"tmp_stubs_{name}"
    if os.path.exists(tmp_stubs_dir):
        shutil.rmtree(tmp_stubs_dir)
    os.makedirs(tmp_stubs_dir, exist_ok=True)
    
    # The generator's dependency-stub enrichment (renderEnrichedType) filters out a member/
    # conformance line that circularly references the module it's building stubs FOR
    # (currentModule) -- but a real cross-target ABI cycle (e.g. TokenGenerationCore's own
    # dependency chain reaches back into TokenGenerationCore via PromptKit/TokenGeneration) needs
    # the SAME filter applied against every target currently on the build call stack, not just
    # the innermost one. Pass the whole `building` set so the generator can filter against all of it.
    stub_gen_env = dict(os.environ)
    stub_gen_env["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"] = ",".join(sorted(building))
    subprocess.check_call([
        "./swift-interface-gen", tbd_path, "--generate-stubs", tmp_stubs_dir
    ], env=stub_gen_env)

    # 3. Get list of generated stub modules
    stub_files = [f for f in os.listdir(tmp_stubs_dir) if f.endswith(".swift")]
    stub_modules = [f[:-6] for f in stub_files]

    # Swift doesn't support mutually-importing modules at all -- enrichment (real members
    # instead of empty skeletons) can surface a genuine import CYCLE purely among dependency
    # stub modules themselves (e.g. GenerativeModelsFoundation -> GenerativeModels ->
    # TokenGeneration -> GenerativeModelsFoundation), distinct from the target/currentModule
    # cycle case above. Detect it by building a directed graph of stub modules' own "import"
    # lines and running cycle detection; any module found in a cycle gets added to the SAME
    # circular-module env var and the stub scan is re-run so the generator strips those
    # back-references too, exactly like it already does for `building`.
    def find_stub_import_cycles():
        graph = {}
        for f in stub_files:
            mod = f[:-6]
            deps = set()
            with open(f"{tmp_stubs_dir}/{f}", "r") as sf:
                for line in sf:
                    if line.startswith("import "):
                        d = line.split()[1].strip()
                        if d in stub_modules and d != mod:
                            deps.add(d)
            graph[mod] = deps
        in_cycle = set()
        visited = set()
        stack = []
        on_stack = set()
        def dfs(node):
            visited.add(node)
            stack.append(node)
            on_stack.add(node)
            for nxt in graph.get(node, ()):
                if nxt in on_stack:
                    cycle_start = stack.index(nxt)
                    in_cycle.update(stack[cycle_start:])
                elif nxt not in visited:
                    dfs(nxt)
            stack.pop()
            on_stack.remove(node)
        for node in graph:
            if node not in visited:
                dfs(node)
        return in_cycle

    while True:
        cyclic_stub_modules = find_stub_import_cycles()
        current_targets = set(stub_gen_env.get("SWIFT_INTERFACE_GEN_BUILDING_TARGETS", "").split(","))
        new_cycles = cyclic_stub_modules - current_targets
        if not new_cycles:
            break
        all_cyclic = sorted(building | cyclic_stub_modules | current_targets)
        all_cyclic = [c for c in all_cyclic if c]
        print(f"  Detected stub-module import cycle: {sorted(new_cycles)} -- regenerating with back-references stripped")
        stub_gen_env["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"] = ",".join(all_cyclic)
        shutil.rmtree(tmp_stubs_dir)
        os.makedirs(tmp_stubs_dir, exist_ok=True)
        subprocess.check_call([
            "./swift-interface-gen", tbd_path, "--generate-stubs", tmp_stubs_dir
        ], env=stub_gen_env)
        stub_files = [f for f in os.listdir(tmp_stubs_dir) if f.endswith(".swift")]
        stub_modules = [f[:-6] for f in stub_files]
    
    # 4. Run the generator to output the interface file
    interface_file = f"{name}Interface.swift"
    with open(interface_file, "w") as f:
        subprocess.check_call(["./swift-interface-gen", tbd_path], stdout=f)
        
    # 5. Parse imports from the top of the generated interface file
    dependencies = []
    with open(interface_file, "r") as f:
        for line in f:
            if line.startswith("import "):
                dep = line.split()[1].strip()
                if dep != name and dep not in SYSTEM_MODULES:
                    dependencies.append(dep)
            elif not line.strip() or line.startswith("//"):
                continue
            else:
                break
                
    print(f"Detected dependencies for {name}: {dependencies}")
    
    # 6. Recursively build all dependency modules
    # Also collect stub modules referenced in the interface body (e.g. IntelligencePlatformLibrary_AppleInternal)
    # that do not appear as top-level imports but are used as module prefixes.
    body_referenced_stubs = set()
    with open(interface_file, "r") as f:
        interface_body = f.read()
    import re as _re
    for mod in stub_modules:
        if mod not in dependencies:
            # Check if the interface body references ModuleName. anywhere
            if _re.search(r'\b' + _re.escape(mod) + r'\.', interface_body):
                body_referenced_stubs.add(mod)
    if body_referenced_stubs:
        print(f"  Also building body-referenced stub modules: {sorted(body_referenced_stubs)}")

    # Build a stub's own dependencies TRANSITIVELY, not just one level deep -- a stub whose
    # real members were enriched (state-swapped re-parse) can import another stub module that
    # itself imports a THIRD stub module (e.g. PromptKit -> GenerativeModelsFoundation ->
    # GenerativeModels -> GenerativeFunctionsInstrumentation), and the third module's stub file
    # already exists on disk (the generator's own transitive-discovery loop found and stubbed
    # it) but was never built here because only dep's own direct imports were ever scanned.
    def build_stub_and_its_deps(dep, stub_src, visiting=None):
        if visiting is None:
            visiting = set()
        if dep in visiting:
            return
        visiting.add(dep)
        stub_deps = []
        with open(stub_src, "r") as sf:
            for line in sf:
                if line.startswith("import "):
                    sdep = line.split()[1].strip()
                    if sdep not in SYSTEM_MODULES and sdep != dep:
                        stub_deps.append(sdep)
        for sdep in stub_deps:
            if sdep == name:
                continue
            if sdep in TARGET_FRAMEWORKS:
                build_framework(sdep)
            elif sdep in stub_modules:
                build_stub_and_its_deps(sdep, f"{tmp_stubs_dir}/{sdep}.swift", visiting)
        build_framework_stub(dep, stub_src)

    all_deps_to_build = list(dependencies) + sorted(body_referenced_stubs)
    for dep in all_deps_to_build:
        if dep == name:
            continue
        if dep in TARGET_FRAMEWORKS:
            # Recursively build real target framework first
            build_framework(dep)
        elif dep in stub_modules:
            build_stub_and_its_deps(dep, f"{tmp_stubs_dir}/{dep}.swift")

    # 6.4 Some extensions on purely-synthetic submodules (e.g. IntelligencePlatformLibrary_
    # AppleInternal, which has no real .framework/.swiftinterface anywhere in the SDK) are only
    # emitted once the generator's isTypeDefinedInFramework check can see that submodule's
    # .swiftinterface under LocalFrameworks/ -- which doesn't exist until the loop above just
    # built it as a stub. The FIRST --generate-stubs scan (step 2, before any dependency stub
    # existed) therefore never saw those extensions and never stubbed the types they reference,
    # so the stub built above can be missing members the target's real interface needs. Re-scan
    # now that dependency stubs exist, and rebuild any stub whose new reference scope is richer
    # (build_framework_stub already does this comparison).
    #
    # A single rescan pass isn't always enough: isTypeDefinedInFramework for a NESTED type (e.g.
    # TokenGeneration.PromptCompletion.Candidate) checks that nested type's name against the
    # dependency's stub .swiftinterface already on disk under LocalFrameworks/ -- but that stub
    # was itself built from a scan that predates discovering "Candidate" is needed, so it doesn't
    # declare "Candidate" yet, so the extension referencing it keeps getting dropped and the
    # rescanned item list never grows to include it either. Rebuilding the stub with the richer
    # scan output doesn't help until the SDK-driven generator step actually re-derives the target's
    # own interface using this newly-rebuilt stub as its isTypeDefinedInFramework source. Loop:
    # rescan, rebuild any richer stub, then rescan again against the just-rebuilt stubs, until a
    # full pass finds nothing new to rebuild (fixed point) or a safety cap is hit.
    max_rescan_passes = 6
    for rescan_pass in range(max_rescan_passes):
        stale_tmp_stubs_dir = f"{tmp_stubs_dir}_prescan"
        if os.path.exists(stale_tmp_stubs_dir):
            shutil.rmtree(stale_tmp_stubs_dir)
        shutil.move(tmp_stubs_dir, stale_tmp_stubs_dir)
        os.makedirs(tmp_stubs_dir, exist_ok=True)
        subprocess.check_call([
            "./swift-interface-gen", tbd_path, "--generate-stubs", tmp_stubs_dir
        ], env=stub_gen_env)
        rescanned_stub_files = [f for f in os.listdir(tmp_stubs_dir) if f.endswith(".swift")]
        any_rebuilt = False
        for f in rescanned_stub_files:
            dep = f[:-6]
            if dep in TARGET_FRAMEWORKS or dep not in stub_modules or dep not in built:
                continue
            new_path = f"{tmp_stubs_dir}/{f}"
            old_path = f"{stale_tmp_stubs_dir}/{f}"
            with open(new_path, "r") as nf:
                new_content = nf.read()
            old_content = ""
            if os.path.exists(old_path):
                with open(old_path, "r") as of:
                    old_content = of.read()
            # build_framework_stub's own staleness check compares against stub_sources_built[dep],
            # which still points at THIS SAME path (tmp_stubs_dir was recreated in place, not
            # renamed) -- so it would read the just-written NEW content as both "prior" and "new"
            # and never detect a change. Compare against the preserved pre-rescan copy directly and
            # force the rebuild here instead.
            if new_content != old_content and len(new_content) > len(old_content):
                print(f"--- Rebuilding stub {dep}: post-dependency rescan found a richer reference scope ({new_path}) [pass {rescan_pass + 1}] ---")
                built.discard(dep)
                build_framework_stub(dep, new_path)
                any_rebuilt = True
        shutil.rmtree(stale_tmp_stubs_dir)
        if not any_rebuilt:
            break

    # 6.5 Re-run generator to get final aligned interface with all dependencies present in LocalFrameworks
    print(f"--- Re-generating Aligned Interface for {name} ---")
    with open(interface_file, "w") as f:
        subprocess.check_call(["./swift-interface-gen", tbd_path], stdout=f)
            
    # Detect ObjC bridge files generated by the generator and set up a framework module map.
    # This is the correct way to expose ObjC types to library-evolution Swift modules
    # (bridging headers are incompatible with -emit-module-interface-path).
    bridge_header_file = f"{name}Interface_bridge.h"
    bridge_impl   = f"{name}Interface_bridge.m"
    bridge_o      = f"{name}Interface_bridge.o"
    bridge_extra_objects = []
    if os.path.exists(bridge_header_file):
        print(f"--- Setting up ObjC framework module map for {name} ---")
        fw_headers_dir = f"LocalFrameworks/{name}.framework/Headers"
        fw_modules_dir = f"LocalFrameworks/{name}.framework/Modules"
        os.makedirs(fw_headers_dir, exist_ok=True)
        os.makedirs(fw_modules_dir, exist_ok=True)
        # Copy bridge header as framework umbrella header (makes ObjC types visible via -F)
        shutil.copy(bridge_header_file, f"{fw_headers_dir}/{name}.h")
        # Create module map so the Swift compiler finds the ObjC types as part of this framework
        module_map = (
            f"framework module {name} {{\n"
            f"  umbrella header \"{name}.h\"\n"
            f"  export *\n"
            f"  module * {{ export * }}\n"
            f"}}\n"
        )
        with open(f"{fw_modules_dir}/module.modulemap", "w") as mf:
            mf.write(module_map)
        # Compile the ObjC implementation to provide runtime class symbols
        subprocess.check_call([
            "clang", "-c", bridge_impl,
            "-isysroot", SDK_ROOT,
            "-fobjc-arc",
            f"-I{fw_headers_dir}",
            "-o", bridge_o
        ])
        bridge_extra_objects = [bridge_o]
        print(f"  ObjC framework headers and bridge compiled.")
        
    # Check if the framework is pure ObjC (i.e. has 0 Swift symbols)
    is_pure_objc = False
    exports_file = f"{name}_exports.txt"
    if os.path.exists(exports_file):
        with open(exports_file, "r") as ef:
            lines = ef.readlines()
            has_swift_symbols = any(line.strip().startswith("_$s") for line in lines)
            if not has_swift_symbols:
                is_pure_objc = True
                
    if is_pure_objc:
        print(f"--- {name} has no Swift symbols. Building as pure ObjC framework. ---")
        tbd_path = locate_tbd(name)
        install_name = extract_install_name(tbd_path) if tbd_path else None
        
        fw_dir = f"LocalFrameworks/{name}.framework"
        lib_dest_path = f"{fw_dir}/{name}"
        symlink_needed = False
        subpath = None
        
        if install_name:
            framework_marker = f"/{name}.framework/"
            if framework_marker in install_name:
                subpath = install_name.split(framework_marker)[1]
                if subpath != name:
                    lib_dest_path = f"{fw_dir}/{subpath}"
                    symlink_needed = True
                    
        if symlink_needed and subpath:
            os.makedirs(os.path.dirname(lib_dest_path), exist_ok=True)
            
        cmd_lib = [
            "clang", "-dynamiclib", "-o", lib_dest_path,
        ] + bridge_extra_objects + [
            "-isysroot", SDK_ROOT,
            "-framework", "Foundation",
        ]
        if install_name:
            cmd_lib.extend(["-install_name", install_name])
            
        print("Running:", " ".join(cmd_lib))
        subprocess.check_call(cmd_lib)
        
        if symlink_needed and subpath:
            symlink_path = f"{fw_dir}/{name}"
            if os.path.exists(symlink_path) or os.path.islink(symlink_path):
                if os.path.isdir(symlink_path) and not os.path.islink(symlink_path):
                    shutil.rmtree(symlink_path)
                else:
                    os.remove(symlink_path)
            os.symlink(subpath, symlink_path)
            
        if os.path.exists(exports_file):
            os.remove(exports_file)
            
        built.add(name)
        building.remove(name)
        return

    # 7. Compile the target framework itself
    
    # Phase A: Emit interface Swift Module (stubs stripped)
    interface_module_src = f"/tmp/{name}Interface_module.swift"
    with open(interface_file, "r") as f:
        lines = f.readlines()
    with open(interface_module_src, "w") as f:
        skip = False
        for line in lines:
            if "// --- Automatically Generated Self-Alignment Stubs ---" in line:
                break
            if "// --- Protocol Default Sentinels (dylib-only, stripped for module emit) ---" in line:
                break
            if "// --- ObjC Extension (bridge-header required) ---" in line:
                skip = True
                continue
            if "// --- End ObjC Extension ---" in line:
                skip = False
                continue
            if not skip:
                # Strip protocol existential sentinel defaults (= _Default_Foo()) like dummyDefaultValue()
                import re as _re2
                line = _re2.sub(r' = _Default_[A-Za-z_][A-Za-z0-9_]*\(\)', '', line)
                f.write(line)
            
    compile_framework(name, interface_module_src, is_stub=False, emit_module=True, emit_library=False)
    os.remove(interface_module_src)
    
    # Phase B: Compile initial dynamic library (without exports list)
    # Keep library-evolution enabled to match the final build.
    interface_dylib_src = interface_file
    compile_framework(name, interface_dylib_src, is_stub=False, emit_module=False, emit_library=True, use_exports=False, extra_objects=bridge_extra_objects)
    
    # Phase C: Compare and generate assembly stubs
    exports_file = f"{name}_exports.txt"
    stubs_s = f"stubs_{name}.s"
    stubs_o = f"stubs_{name}.o"
    if os.path.exists(stubs_s):
        os.remove(stubs_s)
    if os.path.exists(stubs_o):
        os.remove(stubs_o)
        
    print("--- Comparing and Generating Assembly Stubs ---")
    subprocess.check_call([
        "./swift-interface-gen", "--compare", exports_file, f"LocalFrameworks/{name}.framework/{name}", stubs_s
    ])
    
    # Assemble stubs.s to stubs.o using clang
    print("--- Assembling Stubs ---")
    subprocess.check_call(["clang", "-c", stubs_s, "-o", stubs_o])
    
    # Phase D: Re-compile dynamic library linking assembly stubs and using exports list
    compile_framework(name, interface_dylib_src, is_stub=False, emit_module=False, emit_library=True, use_exports=True, extra_objects=[stubs_o] + bridge_extra_objects)

    # Clean up temp files (interface_dylib_src is now the original interface file, do not delete it)
    if not keep_stubs:
        if os.path.exists(stubs_s):
            os.remove(stubs_s)
        if os.path.exists(stubs_o):
            os.remove(stubs_o)
        
    # Phase E: Final Symbol Alignment Verification
    print("--- Comparing Symbols (Verification) ---")
    dummy_stubs = "dummy_stubs.s"
    if os.path.exists(dummy_stubs):
        os.remove(dummy_stubs)
        
    subprocess.check_call([
        "./swift-interface-gen", "--compare", exports_file, f"LocalFrameworks/{name}.framework/{name}", dummy_stubs
    ])
    
    if os.path.exists(dummy_stubs):
        os.remove(dummy_stubs)
    if os.path.exists(exports_file):
        os.remove(exports_file)
        
    if clean_after:
        tmp_stubs_dir = f"tmp_stubs_{name}"
        if os.path.exists(tmp_stubs_dir):
            shutil.rmtree(tmp_stubs_dir)
            print(f"--- Cleaned up temporary stubs directory for {name} ---")
            
    built.add(name)
    building.remove(name)

# Tracks which stub-module source file (if any) actually got compiled for each name, so a
# later, richer stub request for the same module (e.g. GenerativeModelsFoundation needed only
# as an empty placeholder by TokenGenerationCore's own --generate-stubs scan, but needed with
# real declarations by PromptKit's separately-scoped scan, since each target's --generate-stubs
# run only knows about the types ITS OWN interface references) can detect that the previously
# built stub is a strict subset and rebuild with the union instead of silently keeping the
# narrower one — `built`/`is_framework_fully_built`-style caching alone can't tell "already
# built" apart from "already built, but too narrow for this new caller".
stub_sources_built = {}

def _split_top_level_decls(source_text):
    """Split a generated stub source into (imports, {decl_name: decl_text}). Each top-level
    decl is a contiguous run of lines starting at a `public protocol|struct|enum|class NAME`
    header (optionally preceded by attribute lines like @available/@_originallyDefinedIn) and
    ending when brace depth returns to 0. A top-level `extension Foo { ... }` block (e.g. the
    generator's own renderOriginallyDefinedInExtensions output) is captured the same way, keyed
    as "extension Foo" so it never collides with -- and is never dropped in favor of -- a same-
    named type declaration. Two independent --generate-stubs scans of the same dependency module
    (one per calling target, each only seeing the types ITS OWN interface references) can produce
    two files with disjoint declarations -- e.g. one scan's output declares `Schema`/
    `ToolDefinition` and never mentions `ChatLanguageModelResponseStringStream`, while another's
    does the reverse. Neither is a subset of the other, so a single file can't just be swapped
    for the "richer" one; the two must be merged by decl name."""
    import re as _re3
    imports = set()
    decls = {}
    lines = source_text.splitlines(keepends=True)
    header_re = _re3.compile(r'^public (?:protocol|struct|enum|class|final class)\s+`?([A-Za-z_][A-Za-z0-9_]*)`?')
    ext_re = _re3.compile(r'^extension\s+([A-Za-z_][A-Za-z0-9_.`]*)')
    attr_re = _re3.compile(r'^@[A-Za-z_]')
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("import "):
            imports.add(line.strip())
            i += 1
            continue
        # Attribute lines (@available, @_originallyDefinedIn, ...) immediately preceding a
        # decl/extension header belong to that same decl -- they must not be scanned as
        # standalone lines (the `else: i += 1` branch below would silently drop them one at a
        # time, and the decl's own depth tracking would never see them either).
        j = i
        while j < len(lines) and attr_re.match(lines[j]):
            j += 1
        m = header_re.match(lines[j]) if j < len(lines) else None
        em = ext_re.match(lines[j]) if j < len(lines) else None
        if m or em:
            name = m.group(1) if m else "extension " + em.group(1)
            start = i
            depth = 0
            k = j
            while k < len(lines):
                depth += lines[k].count("{") - lines[k].count("}")
                k += 1
                if depth <= 0:
                    break
            text = "".join(lines[start:k])
            decls[name] = decls.get(name, "") + text
            i = k
        else:
            i += 1
    return imports, decls

def _merge_stub_sources(prior_text, new_text):
    """Union two stub sources by top-level declaration name (see _split_top_level_decls).
    When both sources declare the same name, keep whichever version is textually longer, as a
    proxy for "more members scanned in"."""
    prior_imports, prior_decls = _split_top_level_decls(prior_text)
    new_imports, new_decls = _split_top_level_decls(new_text)
    merged_imports = sorted(prior_imports | new_imports)
    merged_decls = dict(prior_decls)
    changed = False
    for name, text in new_decls.items():
        if name not in merged_decls:
            merged_decls[name] = text
            changed = True
        elif len(text) > len(merged_decls[name]):
            merged_decls[name] = text
            changed = True
    if not changed:
        return None
    body = "\n".join(merged_imports) + "\n\n" + "\n".join(merged_decls[n] for n in merged_decls)
    return body

def build_framework_stub(name, swift_source):
    if name in built:
        with open(swift_source, "r") as f:
            new_content = f.read()
        prior_source = stub_sources_built.get(name)
        if prior_source is not None:
            with open(prior_source, "r") as f:
                prior_content = f.read()
            if new_content == prior_content:
                return
            merged = _merge_stub_sources(prior_content, new_content)
            if merged is None:
                return
            # Written to a dedicated, stable directory rather than alongside either source --
            # both tmp_stubs_<Target> dirs are transient and get moved/rmtree'd by the per-target
            # rescan loop (see section 6.4 above), which would otherwise sweep this file away.
            os.makedirs("tmp_stubs_merged", exist_ok=True)
            merged_path = f"tmp_stubs_merged/{name}.merged.swift"
            with open(merged_path, "w") as f:
                f.write(merged)
            print(f"--- Rebuilding stub {name}: merged reference scope from ({prior_source}) and ({swift_source}) into {merged_path} ---")
            built.discard(name)
            swift_source = merged_path
        else:
            return
    compile_framework(name, swift_source, is_stub=True)
    stub_sources_built[name] = swift_source
    built.add(name)

def compile_test(target_name, test_file):
    print(f"--- Compiling Test Program for {target_name} ---")
    test_run = f"{target_name}_test_run"
    local_fw_abs = os.path.abspath("LocalFrameworks")
    subprocess.check_call([
        "swiftc", "-F", "LocalFrameworks", test_file,
        "-enable-experimental-feature", "NonescapableTypes",
        "-enable-experimental-feature", "Lifetimes",
        "-sdk", SDK_ROOT, "-language-mode", "6",
        "-Xlinker", "-rpath", "-Xlinker", local_fw_abs,
        "-o", test_run
    ])
    print("--- Codesigning ---")
    subprocess.check_call(["codesign", "--force", "-s", "-", test_run])
    print("--- Running Test ---")
    subprocess.check_call([f"./{test_run}"])

if __name__ == "__main__":
    if "--clean" in sys.argv:
        clean_after = True
        sys.argv.remove("--clean")
    if "--keep-stubs" in sys.argv:
        keep_stubs = True
        sys.argv.remove("--keep-stubs")
    if "--force-rebuild-deps" in sys.argv:
        skip_built_deps = False
        sys.argv.remove("--force-rebuild-deps")

    if len(sys.argv) < 3:
        print("Usage: ./orchestrate.py <FrameworkName> <TestFile.swift> [--clean] [--keep-stubs] [--force-rebuild-deps]")
        sys.exit(1)
        
    target = sys.argv[1]
    test_file = sys.argv[2]
    
    try:
        build_framework(target, is_target=True)
        compile_test(target, test_file)
        print(f"\nSUCCESS: {target} fully compiled, aligned, and verified passing!")
    except Exception as e:
        print(f"\nFAILURE: {e}", file=sys.stderr)
        sys.exit(1)
