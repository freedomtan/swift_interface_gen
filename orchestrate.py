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
    "CoreAIDelegates"
}

# Pre-defined system modules that are part of standard SDK
SYSTEM_MODULES = {
    "Swift", "Foundation", "ObjectiveC", "os", "Dispatch", "Metal", "CoreGraphics",
    "CoreVideo", "CoreMedia", "IOSurface", "UniformTypeIdentifiers", "XPC", "Synchronization",
    "MetricKit", "Combine"
}

SDK_ROOT = subprocess.check_output(["xcrun", "--show-sdk-path"]).decode("utf-8").strip()

def locate_tbd(name):
    # Search in SDK PrivateFrameworks and SubFrameworks
    paths = [
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

def compile_framework(name, swift_source, is_stub=False, emit_module=True, emit_library=True, use_exports=True, extra_objects=None):
    print(f"--- Compiling {'Stub ' if is_stub else ''}Framework: {name} ---")
    fw_dir = f"LocalFrameworks/{name}.framework"
    mod_dir = f"{fw_dir}/Modules/{name}.swiftmodule"
    os.makedirs(mod_dir, exist_ok=True)
    
    # 1. Emit Swift module interface
    if emit_module:
        cmd_emit = [
            "swiftc", "-emit-module", "-module-name", name, swift_source,
            "-enable-library-evolution", "-language-mode", "5" if is_stub else "6",
            "-F", "LocalFrameworks", "-sdk", SDK_ROOT,
            "-emit-module-interface-path", f"{mod_dir}/arm64-apple-macos.swiftinterface",
            "-o", f"{mod_dir}/arm64-apple-macos.swiftmodule"
        ]
        if not is_stub:
            cmd_emit.extend([
                "-enable-experimental-feature", "NonescapableTypes",
                "-enable-experimental-feature", "Lifetimes"
            ])
            
        print("Running:", " ".join(cmd_emit))
        subprocess.check_call(cmd_emit)
    
    # 2. Compile dynamic library
    if emit_library:
        cmd_lib = [
            "swiftc", "-emit-library", "-o", f"{fw_dir}/{name}",
            swift_source, "-enable-library-evolution", "-module-name", name,
            "-F", "LocalFrameworks", "-sdk", SDK_ROOT,
            "-language-mode", "5" if is_stub else "6"
        ]
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
                
        print("Running:", " ".join(cmd_lib))
        subprocess.check_call(cmd_lib)

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
    for dep in dependencies:
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
            
    # 7. Compile the target framework itself
    
    # Phase A: Emit interface Swift Module (stubs stripped)
    interface_module_src = f"/tmp/{name}Interface_module.swift"
    with open(interface_file, "r") as f:
        lines = f.readlines()
    with open(interface_module_src, "w") as f:
        for line in lines:
            if "// --- Automatically Generated Self-Alignment Stubs ---" in line:
                break
            f.write(line)
            
    compile_framework(name, interface_module_src, is_stub=False, emit_module=True, emit_library=False)
    os.remove(interface_module_src)
    
    # Phase B: Compile initial dynamic library (without exports list)
    interface_dylib_src = f"/tmp/{name}Interface_dylib.swift"
    with open(interface_file, "r") as f:
        code = f.read()
    code_no_defaults = code.replace(" = dummyDefaultValue()", "")
    with open(interface_dylib_src, "w") as f:
        f.write(code_no_defaults)
        
    compile_framework(name, interface_dylib_src, is_stub=False, emit_module=False, emit_library=True, use_exports=False)
    
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
    compile_framework(name, interface_dylib_src, is_stub=False, emit_module=False, emit_library=True, use_exports=True, extra_objects=[stubs_o])
    
    # Clean up temp files
    os.remove(interface_dylib_src)
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
