#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil

TARGET_FRAMEWORKS = {
    "ModelCatalogRuntime",
    "CoreAICommon",
    "CoreAICompiler",
    "ModelCatalog",
    "ODIE",
    "TokenGenerationCore",
    "CoreAIDelegates",
    "AppleIntelligenceReporting",
    "FeatureFlags",
    "UnifiedAssetFramework"
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

def compile_framework(name, swift_source, is_stub=False, emit_module=True, emit_library=True, use_exports=True, extra_objects=None):
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
            
        if not is_stub:
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
            swift_source, "-enable-library-evolution", "-module-name", name,
            "-F", "LocalFrameworks", "-sdk", SDK_ROOT,
            "-language-mode", "6",
            "-Xlinker", "-not_for_dyld_shared_cache"
        ]
        bridge_h = f"{name}Interface_bridge.h"
        if not is_stub and os.path.exists(bridge_h):
            cmd_lib.extend(["-import-objc-header", bridge_h])

        if install_name:
            cmd_lib.extend(["-Xlinker", "-install_name", "-Xlinker", install_name])
            
        if extra_objects:
            for obj in extra_objects:
                cmd_lib.extend(["-Xlinker", obj])
            
        if not is_stub:
            cmd_lib.extend([
                "-enable-experimental-feature", "NonescapableTypes",
                "-enable-experimental-feature", "Lifetimes"
            ])
            
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

def build_framework(name):
    if name in built:
        return
    if name in building:
        raise Exception(f"Circular dependency detected: {name} in {building}")
    
    building.add(name)
    
    # Target framework
    tbd_path = locate_tbd(name)
    if not tbd_path:
        raise Exception(f"Could not locate TBD file for target framework: {name}")
        
    print(f"\n========================================")
    print(f"Resolving dependencies for Target: {name}")
    print(f"========================================")
    
    # 1. Build swift-interface-gen first
    print("--- Building Generator ---")
    subprocess.check_call([
        "swiftc", "-O", "-parse-as-library",
        "SwiftInterfaceGen/Sources/SwiftInterfaceGen/main.swift",
        "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Parser.swift",
        "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Model.swift",
        "SwiftInterfaceGen/Sources/SwiftInterfaceGen/Config.swift",
        "SwiftInterfaceGen/Sources/SwiftInterfaceGen/String+RegexFree.swift",
        "-o", "./swift-interface-gen"
    ])
    
    # 2. Run generator in stub-generation mode on the target TBD
    tmp_stubs_dir = f"tmp_stubs_{name}"
    if os.path.exists(tmp_stubs_dir):
        shutil.rmtree(tmp_stubs_dir)
    os.makedirs(tmp_stubs_dir, exist_ok=True)
    
    subprocess.check_call([
        "./swift-interface-gen", tbd_path, "--generate-stubs", tmp_stubs_dir
    ])
    
    # 3. Get list of generated stub modules
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

    all_deps_to_build = list(dependencies) + sorted(body_referenced_stubs)
    for dep in all_deps_to_build:
        if dep in TARGET_FRAMEWORKS:
            # Recursively build real target framework first
            build_framework(dep)
        elif dep in stub_modules:
            # Build stub module
            stub_src = f"{tmp_stubs_dir}/{dep}.swift"
            # Scan stub_src for any imports to compile its dependencies first
            stub_deps = []
            with open(stub_src, "r") as sf:
                for line in sf:
                    if line.startswith("import "):
                        sdep = line.split()[1].strip()
                        if sdep not in SYSTEM_MODULES and sdep != dep:
                            stub_deps.append(sdep)
            # Build stub dependencies
            for sdep in stub_deps:
                if sdep in TARGET_FRAMEWORKS:
                    build_framework(sdep)
                elif sdep in stub_modules:
                    build_framework_stub(sdep, f"{tmp_stubs_dir}/{sdep}.swift")
            # Now compile this stub framework itself
            build_framework_stub(dep, stub_src)
            
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
            if "// --- ObjC Extension (bridge-header required) ---" in line:
                skip = True
                continue
            if "// --- End ObjC Extension ---" in line:
                skip = False
                continue
            if not skip:
                f.write(line)
            
    compile_framework(name, interface_module_src, is_stub=False, emit_module=True, emit_library=False)
    os.remove(interface_module_src)
    
    # Phase B: Compile initial dynamic library (without exports list)
    # Keep dummyDefaultValue() defaults so the Swift compiler emits fA_ default-argument
    # accessor symbols natively, reducing the number of assembly stubs needed.
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

def build_framework_stub(name, swift_source):
    if name in built:
        return
    compile_framework(name, swift_source, is_stub=True)
    built.add(name)

def compile_test(target_name, test_file):
    print(f"--- Compiling Test Program for {target_name} ---")
    test_run = f"{target_name}_test_run"
    subprocess.check_call([
        "swiftc", "-F", "LocalFrameworks", test_file,
        "-enable-experimental-feature", "NonescapableTypes",
        "-enable-experimental-feature", "Lifetimes",
        "-sdk", SDK_ROOT, "-language-mode", "6",
        "-o", test_run
    ])
    print("--- Codesigning ---")
    subprocess.check_call(["codesign", "--force", "-s", "-", test_run])
    print("--- Running Test ---")
    env = os.environ.copy()
    env["DYLD_FRAMEWORK_PATH"] = "LocalFrameworks"
    subprocess.check_call([f"./{test_run}"], env=env)

if __name__ == "__main__":
    if "--clean" in sys.argv:
        clean_after = True
        sys.argv.remove("--clean")
        
    if len(sys.argv) < 3:
        print("Usage: ./orchestrate.py <FrameworkName> <TestFile.swift> [--clean]")
        sys.exit(1)
        
    target = sys.argv[1]
    test_file = sys.argv[2]
    
    try:
        build_framework(target)
        compile_test(target, test_file)
        print(f"\nSUCCESS: {target} fully compiled, aligned, and verified passing!")
    except Exception as e:
        print(f"\nFAILURE: {e}", file=sys.stderr)
        sys.exit(1)
