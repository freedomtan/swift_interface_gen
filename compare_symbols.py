import sys
import os
import subprocess
import re

def extract_tbd_symbols(tbd_path):
    if not os.path.exists(tbd_path):
        print(f"Error: {tbd_path} not found.")
        return set()
    with open(tbd_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    symbols = set()
    for token in re.findall(r'[\w\$]+', content):
        if token.startswith('_$s') or token.startswith('_OBJC_CLASS_$_') or token.startswith('_OBJC_METACLASS_$_') or token.startswith('_OBJC_IVAR_$_'):
            symbols.add(token)
    return symbols

def extract_dylib_symbols(dylib_path):
    if not os.path.exists(dylib_path):
        print(f"Error: {dylib_path} not found.")
        return set()
    try:
        out = subprocess.check_output(['nm', '-gU', dylib_path]).decode('utf-8')
        symbols = set()
        for line in out.splitlines():
            parts = line.strip().split()
            if len(parts) >= 3:
                sym = parts[2]
                symbols.add(sym)
            elif len(parts) == 2:
                sym = parts[1]
                symbols.add(sym)
        return symbols
    except Exception as e:
        print(f"Error running nm: {e}")
        return set()

def demangle_batch(symbols):
    if not symbols:
        return {}
    try:
        # Run swift-demangle in batch
        # We slice it to prevent too long command line arguments if symbols count is huge
        sym_list = list(symbols)
        chunk_size = 500
        mapping = {}
        for k in range(0, len(sym_list), chunk_size):
            chunk = sym_list[k:k+chunk_size]
            out = subprocess.check_output(['xcrun', 'swift-demangle'] + chunk).decode('utf-8')
            for line in out.splitlines():
                if ' ---> ' in line:
                    parts = line.split(' ---> ')
                    mangled = parts[0].strip()
                    demangled = parts[1].strip()
                    if mangled.startswith('_'):
                        mapping[mangled] = demangled
        return mapping
    except Exception as e:
        print(f"Error demangling: {e}")
        return {}

def main():
    if len(sys.argv) < 3:
        print("Usage: python compare_symbols.py <tbd_path> <dylib_path> [aliases_output_path]")
        sys.exit(1)
    
    tbd_path = sys.argv[1]
    dylib_path = sys.argv[2]
    aliases_output_path = sys.argv[3] if len(sys.argv) > 3 else None
    
    tbd_syms = extract_tbd_symbols(tbd_path)
    dylib_syms = extract_dylib_symbols(dylib_path)
    
    print(f"Total symbols in TBD: {len(tbd_syms)}")
    print(f"Total symbols in Dylib: {len(dylib_syms)}")
    
    def normalize(sym):
        if sym.startswith('_'):
            return sym[1:]
        return sym
        
    normalized_tbd = {normalize(s): s for s in tbd_syms}
    normalized_dylib = {normalize(s): s for s in dylib_syms}
    
    missing = []
    for norm_sym, orig_sym in normalized_tbd.items():
        if norm_sym not in normalized_dylib:
            missing.append(orig_sym)
            
    extra = []
    for norm_sym, orig_sym in normalized_dylib.items():
        if norm_sym not in normalized_tbd:
            extra.append(orig_sym)
            
    print("\n--- Missing Symbols (in TBD but not in Dylib) ---")
    print(f"Count: {len(missing)}")
    for s in sorted(missing)[:50]:
        print(f"  {s}")
    if len(missing) > 50:
        print(f"  ... and {len(missing) - 50} more")
        
    print("\n--- Extra Symbols (in Dylib but not in TBD) ---")
    print(f"Count: {len(extra)}")
    for s in sorted(extra)[:50]:
        print(f"  {s}")
    if len(extra) > 50:
        print(f"  ... and {len(extra) - 50} more")

    if aliases_output_path:
        print(f"\nGenerating alias flags to {aliases_output_path}...")
        demangled_map = demangle_batch(set(missing) | set(extra))
        
        demangled_to_extra = {}
        for extra_sym in extra:
            dem_extra = demangled_map.get(extra_sym)
            if dem_extra:
                demangled_to_extra[dem_extra] = extra_sym
                
        alias_flags = []
        for miss_sym in missing:
            dem_miss = demangled_map.get(miss_sym)
            if dem_miss and dem_miss in demangled_to_extra:
                extra_sym = demangled_to_extra[dem_miss]
                alias_flags.append(f"-Xlinker -alias -Xlinker {extra_sym} -Xlinker {miss_sym}")
                
        with open(aliases_output_path, 'w', encoding='utf-8') as f:
            f.write(" ".join(alias_flags))
        print(f"Generated {len(alias_flags)} symbol aliases.")

if __name__ == '__main__':
    main()
