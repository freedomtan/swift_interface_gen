#include <string>
#include <cstring>
#include <dlfcn.h>

namespace llvm {
  struct StringRef {
    const char *Data;
    size_t Length;
  };
}

typedef void (*ContextCtor)(void*);
typedef void (*ContextDtor)(void*);
typedef void* (*DemangleSymbolAsNode)(void*, llvm::StringRef);
typedef std::string (*GetNodeTreeAsString)(void*);
typedef void (*ContextClear)(void*);
typedef size_t (*GetDemangledName)(const char*, char*, size_t);

static ContextCtor contextCtor = nullptr;
static ContextDtor contextDtor = nullptr;
static DemangleSymbolAsNode demangleSymbolAsNode = nullptr;
static GetNodeTreeAsString getNodeTreeAsString = nullptr;
static ContextClear contextClear = nullptr;
static GetDemangledName getDemangledName = nullptr;
static void* dylibHandle = nullptr;

static bool loadDemangler() {
  if (dylibHandle) return true;
  
  // List of candidate paths
  const char* paths[] = {
    "/Applications/Xcode-beta.app/Contents/Frameworks/libswiftDemangle.dylib",
    "/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libswiftDemangle.dylib",
    "/Applications/Xcode.app/Contents/Frameworks/libswiftDemangle.dylib",
    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libswiftDemangle.dylib",
    "/usr/lib/libswiftDemangle.dylib"
  };
  
  for (const char* path : paths) {
    dylibHandle = dlopen(path, RTLD_LAZY);
    if (dylibHandle) break;
  }
  
  if (!dylibHandle) return false;
  
  contextCtor = (ContextCtor)dlsym(dylibHandle, "_ZN5swift8Demangle7ContextC1Ev");
  contextDtor = (ContextDtor)dlsym(dylibHandle, "_ZN5swift8Demangle7ContextD1Ev");
  demangleSymbolAsNode = (DemangleSymbolAsNode)dlsym(dylibHandle, "_ZN5swift8Demangle7Context20demangleSymbolAsNodeEN4llvm9StringRefE");
  getNodeTreeAsString = (GetNodeTreeAsString)dlsym(dylibHandle, "_ZN5swift8Demangle19getNodeTreeAsStringEPNS0_4NodeE");
  contextClear = (ContextClear)dlsym(dylibHandle, "_ZN5swift8Demangle7Context5clearEv");
  getDemangledName = (GetDemangledName)dlsym(dylibHandle, "swift_demangle_getDemangledName");
  
  return contextCtor && contextDtor && demangleSymbolAsNode && getNodeTreeAsString && contextClear && getDemangledName;
}

static thread_local std::string lastFlat;
static thread_local std::string lastAST;

extern "C" const char* swift_demangle_flat(const char* symbol) {
  if (!loadDemangler()) return nullptr;
  char buf[4096];
  size_t len = getDemangledName(symbol, buf, sizeof(buf) - 1);
  if (len > 0) {
    lastFlat = std::string(buf, len);
  } else {
    lastFlat = symbol;
  }
  return lastFlat.c_str();
}

extern "C" const char* swift_demangle_ast(const char* symbol) {
  if (!loadDemangler()) return nullptr;
  
  char contextBuf[512];
  memset(contextBuf, 0, sizeof(contextBuf));
  contextCtor(contextBuf);
  
  llvm::StringRef symRef;
  symRef.Data = symbol;
  symRef.Length = strlen(symbol);
  
  void* node = demangleSymbolAsNode(contextBuf, symRef);
  if (node) {
    lastAST = getNodeTreeAsString(node);
  } else {
    lastAST = "";
  }
  
  contextDtor(contextBuf);
  return lastAST.empty() ? nullptr : lastAST.c_str();
}
