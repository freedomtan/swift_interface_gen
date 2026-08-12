import Foundation

class Parser {
    var modules: [String: TypeNode] = [:]
    var defaultModule: String = ""
    var primaryTargetModule: String = ""
    let swiftKeywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
        "func", "import", "init", "inout", "internal", "let", "open", "operator",
        "private", "protocol", "public", "reinit", "static", "struct", "subscript",
        "typealias", "var", "break", "case", "continue", "default", "defer",
        "do", "else", "fallthrough", "for", "guard", "if", "in", "is", "repeat",
        "return", "switch", "where", "while", "as", "Any", "AnyObject", "catch",
        "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws",
        "true", "try", "Type", "Protocol", "Array", "Dictionary", "Set", "String", "Int", "Bool", "Double", "Float", "AnyHashable"
    ]

    var discoveredGenerics = [String: Int]() // [DottedType: Count]
    // Precise pair-keyed record of a nested type's OWN generic-ness, populated only from a
    // literal "Outer<...>.Inner<...>" chained-application text match (see precompute()) — keyed
    // on "OuterShortName.InnerShortName" so it never collides with an unrelated type elsewhere
    // that happens to share the same bare inner short name (e.g. HealthKit has both a genuinely
    // generic Foo.Iterator<X> and a non-generic Bar.Iterator with zero own params — a bare-name
    // fallback keyed only on "Iterator" can't distinguish them; this can).
    var discoveredNestedGenericPairs = [String: Int]() // ["Outer.Inner": count]
    // Nodes seen via a bare "nominal type descriptor for X" symbol with no other context —
    // candidates for the Hashable/Codable/Sendable default-conformance fallback, applied only
    // if the node still has zero real conformances once all symbols have been parsed.
    var needsDefaultConformanceFallback: [ObjectIdentifier: TypeNode] = [:]
    var discoveredProtocols = Set<String>() // [DottedType]
    var discoveredNamespaces = Set<String>()
    var discoveredConcreteTypes = Set<String>()
    // [InternalNodeName: (ExtendedTypeModule, StdlibTypeName, DisplayName)] — types like
    // "Publisher" that are declared inside a "(extension in <currentModule>)" on some other
    // module's type (e.g. Swift.Optional, or TokenGeneration.Prompt / PromptKit.Prompt). The
    // internal node name is disambiguated per (module, type) pair (e.g. both Optional and
    // Result gain a same-named "Publisher", and unrelated modules can each have their own
    // same-named "Prompt") so it never collides in the nestedTypes dictionary; DisplayName is
    // the real bare name to render at emission time.
    // Populated by discoverNominalTypes; used by generateAll to emit
    // `extension <Module>.<StdlibType> { struct <DisplayName> { ... } }` instead of a plain
    // top-level declaration, and by findOrCreateType to route a member's parent type to the
    // same node.
    var stdlibTypeExtensions = [String: (module: String, stdlibType: String, displayName: String)]()
    // Full dotted paths (e.g. "TokenGeneration.Prompt.RenderedPromptFragment") of types the
    // CURRENT module declares via extension on another module's type — these are emitted as
    // part of the current module's own output (see stdlibTypeExtensions above), so they must
    // NOT be re-declared as stub members of that other module when generating dependency stubs
    // (main.swift's generateStubs), which would create a genuine ambiguous-lookup conflict
    // between the real stub and our own extension-injected declaration.
    var selfDeclaredExternalExtensionPaths = Set<String>()
    // Real name of a primary-associated-type protocol's associated type (e.g. "Source" -> "Stream"),
    // recovered from "any Source<Self.Stream == A>" constrained-existential usages by
    // simplifyType before that text is erased/marker-replaced. --generate-stubs (main.swift) needs
    // this because the stub's "associatedtype A" placeholder must be renamed to the real name —
    // otherwise the stub's mangled ABI symbol never matches the real framework's.
    var primaryAssociatedTypeNames = [String: String]()
    var processedModules = Set<String>()
    var currentPrecomputeModule = "ModelCatalog"
    var frameworkInterfaceCache: [String: String] = [:]
    var namespaceFrameworkCache: [String: Bool] = [:]
    var frameworkDefinedTypesCache: [String: Set<String>] = [:]
    
    struct SystemTypesSet {
        let base: Set<String>
        func contains(_ member: String) -> Bool {
            if base.contains(member) { return true }
            if member == "InlineArray" { return true }
            if member.hasPrefix("MTL") { return true }
            if member.hasPrefix("CV") { return true }
            if member.hasPrefix("CG") { return true }
            if member.hasPrefix("CM") { return true }
            return false
        }
    }
    
    let systemTypes = SystemTypesSet(base: [
        "Bool", "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
        "Double", "Float", "Float16", "CGFloat", "Void", "Any", "Self", "Set", "Array", "Dictionary",
        "Optional", "URL", "Data", "Hasher", "Error", "Decoder", "Encoder", "Never",
        // Range types require Comparable constraints — never alias with <Any>
        "Range", "ClosedRange", "PartialRangeFrom", "PartialRangeThrough", "PartialRangeUpTo",
        "UnsafeRawBufferPointer", "UnsafeMutableRawBufferPointer",
        "UnsafeMutableRawPointer", "UnsafeRawPointer",
        "UnsafePointer", "UnsafeMutablePointer",
        "UnsafeBufferPointer", "UnsafeMutableBufferPointer",
        "URLResponse",
        "URLSession", "HTTPURLResponse", "String", "Character", "ClosedRange", "Range", "Selector",
        "NSObject", "Sendable", "Equatable", "Hashable", "Codable", "Decodable", "Encodable", "Identifiable", "BitwiseCopyable", "Copyable", "Escapable",
        "AnyObject", "Comparable", "Sequence", "IteratorProtocol", "CaseIterable", "RawRepresentable", "RangeExpression",
        "Result", "KeyValuePairs", "Locale", "TimeZone", "Calendar", "Notification", "NotificationCenter",
        "Bundle", "RunLoop", "ProcessInfo", "Process", "LanguageCode", "StaticString",
        "AnySequence", "FloatingPointRoundingRule", "Task", "Mutex", "CustomStringConvertible", "CustomDebugStringConvertible", "CodingKey",
        "ExpressibleByExtendedGraphemeClusterLiteral", "ExpressibleByStringLiteral", "ExpressibleByUnicodeScalarLiteral",
        "ExpressibleByIntegerLiteral", "ExpressibleByFloatLiteral", "ExpressibleByBooleanLiteral",
        "ExpressibleByNilLiteral", "ExpressibleByArrayLiteral", "ExpressibleByDictionaryLiteral",
        "LocalizedError", "CustomNSError", "Logger", "NSXPCConnection", "NSXPCInterface", "Protocol", "NSCopying",
        "Swift", "Foundation", "CoreFoundation", "Metal", "IOSurface", "CoreGraphics", "CoreVideo", "CoreMedia", "CoreImage", "CoreML", "Dispatch", "os", "ObjectiveC", "Synchronization",
        "Strideable", "AdditiveArithmetic", "BinaryFloatingPoint", "FloatingPoint", "FloatingPointSign", "Numeric", "SignedNumeric", "BinaryInteger", "FixedWidthInteger", "SignedInteger", "UnsignedInteger",
        "MTLDevice", "MTLBuffer", "MTLTexture", "IOSurfaceRef", "CVBufferRef", "CVBuffer",
        "Span", "MutableSpan", "RawSpan", "MutableRawSpan",
        // Additional System Types to prevent shadowing and matching issues:
        "NSNumber", "NSCoder", "Date", "DispatchQueue", "URLComponents", "UUID", "NSZone", "AnyHashable", "UTType", "Decimal", "IndexSet", "URLRequest", "URLSessionTask", "OS_dispatch_queue",
        "AsyncStream", "AsyncThrowingStream",
        "NSCoding", "NSSecureCoding", "NSObjectProtocol",
        "OptionSet", "SetAlgebra",
        // Additional Standard Swift Library and Foundation Types/Protocols:
        "Collection", "BidirectionalCollection", "RandomAccessCollection", "MutableCollection", "RangeReplaceableCollection",
        "AsyncSequence", "AsyncIteratorProtocol",
        "CVarArg",
        "LosslessStringConvertible",
        "TextOutputStream", "TextOutputStreamable",
        "ExpressibleByStringInterpolation", "StringInterpolationProtocol",
        "CommandLine",
        "Mirror", "MirrorPath", "CustomReflectable",
        "KeyPath", "WritableKeyPath", "ReferenceWritableKeyPath", "PartialKeyPath", "AnyKeyPath",
        "Unicode", "UnicodeScalar", "UTF8", "UTF16", "UTF32",
        "EmptyCollection", "Repeated", "Slice", "Zip2Sequence",
        "ObjectIdentifier",
        "NSMutableCopying",
        "URLQueryItem",
        "Measurement", "Unit", "Dimension",
        "Operation", "OperationQueue",
        "Thread", "Timer",
        "CharacterSet",
        "JSONEncoder", "JSONDecoder", "PropertyListEncoder", "PropertyListDecoder",
        "AttributedString", "AttributedStringKey", "AttributedSubstring",
        "FileHandle", "Pipe",
        "NSPredicate", "NSSortDescriptor",
        // Swift error types that must resolve to stdlib, not local stubs
        "CancellationError", "DecodingError", "EncodingError",
        // Foundation / AppKit ObjC-bridged types that must use system types, not local stubs
        "NSError", "NSException",
        "NSView", "NSViewController", "NSWindow", "NSColor", "NSFont", "NSImage",
        "NSVisualEffectView", "NSCollectionView", "NSCollectionViewItem", "NSCollectionViewLayout",
        "NSCollectionViewLayoutAttributes", "NSCollectionLayoutItem", "NSCollectionLayoutSection",
        "NSDirectionalEdgeInsets", "NSValidatedUserInterfaceItem", "NSParagraphStyle",
        "NSResponder", "NSEvent", "NSMenu", "NSMenuItem", "NSAlert"
    ])
    
    var defaultArguments = [String: Set<Int>]()
    
    func splitTopLevelCommas(_ s: String) -> [String] {
        var result = [String]()
        var current = ""
        var depth = 0
        let chars = Array(s)
        var idx = 0
        while idx < chars.count {
            let ch = chars[idx]
            if ch == "(" || ch == "<" || ch == "[" {
                depth += 1
                current.append(ch)
            } else if ch == ")" || ch == ">" || ch == "]" {
                if ch == ">" && idx > 0 && chars[idx - 1] == "-" {
                    // Ignore ->
                } else {
                    depth -= 1
                }
                current.append(ch)
            } else if ch == "," && depth == 0 {
                result.append(current)
                current = ""
            } else {
                current.append(ch)
            }
            idx += 1
        }
        if !current.isEmpty {
            result.append(current)
        }
        return result
    }

    // Finds the function's own top-level " -> " (the one right after its own parameter
    // list closes, at paren/angle/bracket depth 0) rather than the LAST " -> " in the
    // string, which is wrong whenever the return type is itself a function type (e.g.
    // `(Int) -> (String) -> Bool` — searching backwards would find the inner arrow and
    // truncate the signature's own return type down to just "Bool").
    static func topLevelArrowRange(in s: String) -> Range<String.Index>? {
        var depth = 0
        var idx = s.startIndex
        while idx < s.endIndex {
            let ch = s[idx]
            if ch == "(" || ch == "[" { depth += 1 }
            else if ch == ")" || ch == "]" { depth -= 1 }
            else if ch == "<" { depth += 1 }
            else if ch == ">" {
                let isArrowHead = idx > s.startIndex && s[s.index(before: idx)] == "-"
                if !isArrowHead { depth -= 1 }
            }
            if depth == 0, ch == "-", s.index(after: idx) < s.endIndex, s[s.index(after: idx)] == ">" {
                let arrowStart = idx > s.startIndex && s[s.index(before: idx)] == " " ? s.index(before: idx) : idx
                let arrowEnd = s.index(idx, offsetBy: 2)
                return arrowStart..<arrowEnd
            }
            idx = s.index(after: idx)
        }
        return nil
    }

    private var scannedLocalSwiftFiles = false
    var tbdSymbols = Set<String>()
    // Symbols that belong to the primary target's OWN .tbd document specifically (depth 0
    // in processSymbols), excluding symbols pulled in from `reexported-libraries:` (depth 1+).
    // A reexporting framework's real Mach-O binary satisfies those via an LC_REEXPORT_DYLIB
    // load command forwarding to the actual dependency dylib — it never locally defines them
    // — so the exports file (which becomes -exported_symbols_list) must only demand the
    // target's own symbols, not the flattened union of everything it reexports.
    var ownTbdSymbols = Set<String>()
    var nonFinalClasses = Set<String>()
    // "TypeName:ProtocolName" entries for Mc conformance descriptors found in TBD symbols.
    var conformancesFromTBD = Set<String>()
    var referencedModules = Set<String>()
    var symbolEscapingMap: [String: [Int: Bool]] = [:]
    // Maps base function mangled symbol → set of parameter indices that have default values
    var defaultArgMap: [String: Set<Int>] = [:]

    init() {}

    func precompute(demangled: String) {
        func countTopLevelCommas(in s: String) -> Int {
            var commas = 0
            var depth = 0
            var parenDepth = 0
            for char in s {
                if char == "<" { depth += 1 }
                else if char == ">" { depth -= 1 }
                else if char == "(" { parenDepth += 1 }
                else if char == ")" { parenDepth -= 1 }
                else if char == "," {
                    if depth == 0 && parenDepth == 0 {
                        commas += 1
                    }
                }
            }
            return commas + 1
        }

        // Infer generic types and their max parameter count using fully qualified names
        let genericTypes = demangled.scanGenericTypeApplications()
        for (name, params) in genericTypes {
            let shortName = name.components(separatedBy: ".").last!
            // Skip standard library types and single-letter generic parameter placeholders
            if shortName.count == 1 || ["Optional", "Array", "Dictionary", "Set",
                "UnsafePointer", "UnsafeMutablePointer", "UnsafeRawPointer", "UnsafeMutableRawPointer",
                "UnsafeBufferPointer", "UnsafeMutableBufferPointer", "UnsafeRawBufferPointer", "UnsafeMutableRawBufferPointer"].contains(shortName) {
                continue
            }
            
            let count = countTopLevelCommas(in: params)
            let currentMax = discoveredGenerics[name] ?? 0
            discoveredGenerics[name] = max(currentMax, count)
        }

        // Precisely record a chained "Outer<...>.Inner<...>" nested generic APPLICATION as an
        // exact (OuterShortName, InnerShortName) pair — scanGenericTypeApplications() only
        // records the bare "Inner" name for the second application (its name-backtrack stops at
        // the ">" boundary), which is too ambiguous to safely mark an unrelated same-named type
        // generic elsewhere (see markGenericRecursive's comment). Matching the literal adjacency
        // "...>.Word<" directly recovers the true owning outer type for this specific pair.
        if let pairRegex = try? NSRegularExpression(pattern: "([A-Z][A-Za-z0-9_$]*)<[^<>]*>\\.([A-Z][A-Za-z0-9_$]*)<([^<>]*(?:<[^<>]*>[^<>]*)*)>", options: []) {
            let nsRange = NSRange(demangled.startIndex..<demangled.endIndex, in: demangled)
            for m in pairRegex.matches(in: demangled, options: [], range: nsRange) {
                guard let outerRange = Range(m.range(at: 1), in: demangled),
                      let innerRange = Range(m.range(at: 2), in: demangled),
                      let paramsRange = Range(m.range(at: 3), in: demangled) else { continue }
                let outer = String(demangled[outerRange])
                let inner = String(demangled[innerRange])
                let params = String(demangled[paramsRange])
                let count = countTopLevelCommas(in: params)
                let key = "\(outer).\(inner)"
                let currentMax = discoveredNestedGenericPairs[key] ?? 0
                discoveredNestedGenericPairs[key] = max(currentMax, count)
            }
        }

        // Infer namespaces and verify they actually exist as frameworks in the SDK
        let namespaces = demangled.scanNamespaces()
        for ns in namespaces {
            if !["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC", "__C"].contains(ns) {
                let isFramework: Bool
                if let cached = namespaceFrameworkCache[ns] {
                    isFramework = cached
                } else {
                    let path1 = "\(ConfigManager.sdkRoot)/System/Library/PrivateFrameworks/\(ns).framework"
                    let path2 = "\(ConfigManager.sdkRoot)/System/Library/SubFrameworks/\(ns).framework"
                    let exists = FileManager.default.fileExists(atPath: path1) || FileManager.default.fileExists(atPath: path2)
                    namespaceFrameworkCache[ns] = exists
                    isFramework = exists
                }
                if isFramework {
                    discoveredNamespaces.insert(ns)
                }
            }
        }
        
        // Infer protocols and concrete types
        let prefixes = [
            "nominal type descriptor for ",
            "type metadata for ",
            "protocol descriptor for "
        ]
        for prefix in prefixes {
            if demangled.hasPrefix(prefix) {
                let name = demangled.replacingOccurrences(of: prefix, with: "")
                let cleanName = cleanType(name)
                let shortName = cleanName.components(separatedBy: ".").last!
                if prefix == "protocol descriptor for " {
                    discoveredProtocols.insert(cleanName)
                } else {
                    discoveredConcreteTypes.insert(shortName)
                }
            }
        }
        let protocols = demangled.scanProtocols()
        for proto in protocols {
            discoveredProtocols.insert(proto)
        }
    }

    private func demangle(_ symbol: String) -> String? {
        return SwiftInterfaceGen.demangle(symbol: symbol)
    }

    private func stripGenerics(_ s: String) -> String {
        var result = ""
        var depth = 0
        for char in s {
            if char == "<" {
                depth += 1
            } else if char == ">" {
                depth = max(0, depth - 1)
            } else if depth == 0 {
                result.append(char)
            }
        }
        return result
    }

    private func extractClassPath(fromTjTq demangled: String) -> String? {
        var path = demangled
        if path.hasPrefix("dispatch thunk of ") {
            path = String(path.dropFirst("dispatch thunk of ".count))
        } else if path.hasPrefix("method descriptor for ") {
            path = String(path.dropFirst("method descriptor for ".count))
        } else {
            return nil
        }
        
        if let colonIndex = path.range(of: " : ") {
            path = String(path[..<colonIndex.lowerBound])
        }
        
        if let parenIndex = path.firstIndex(of: "(") {
            path = String(path[..<parenIndex])
        }
        
        path = stripGenerics(path)
        
        var parts = path.components(separatedBy: ".")
        if parts.isEmpty { return nil }
        
        // Remove trailing accessor markers if present
        if let last = parts.last, ["getter", "setter", "modify", "read"].contains(last) {
            parts.removeLast()
        }
        
        // Remove the member name (method name, property name, subscript, or init)
        if !parts.isEmpty {
            parts.removeLast()
        }
        
        return parts.joined(separator: ".")
    }


    private func escapeKeyword(_ name: String) -> String {
        if swiftKeywords.contains(name) {
            return "`\(name)`"
        }
        return name
    }

    func setKind(_ kind: String, for node: TypeNode, force: Bool = false) {
        if force {
            if node.kind != kind {
                node.kind = kind
            }
        } else if node.kind == "unknown" || node.kind == "struct" {
             if kind == "class" || kind == "enum" || kind == "protocol" {
                 node.kind = kind
             }
        }
        if ["struct", "class", "enum"].contains(node.kind) {
            discoveredConcreteTypes.insert(node.name)
        }
    }

    /// Returns the set of protocol short names that are safe to keep an `any` prefix.
    /// A name is "safe" if it IS a known protocol but does NOT also appear as a concrete type short name
    /// at any nesting level. This prevents `any AppleDeviceTracking` (which is shadowed by the
    /// concrete nested struct) while allowing `any ResourceBundle` (which has no same-named
    /// concrete type in discoveredConcreteTypes at any nesting level that causes shadowing issues).
    /// NOTE: ResourceBundle IS in discoveredConcreteTypes because of Catalog.ResourceBundle enum,
    /// so we compare the full protocol path depth vs the concrete type to decide.
    func unambiguousProtocolShortNames() -> Set<String> {
        // Use discoveredConcreteTypes (short names of ALL concrete types at any depth)
        // A protocol short name P is "safe" if NOT in discoveredConcreteTypes.
        var result = Set<String>()
        for proto in discoveredProtocols {
            let shortName = proto.components(separatedBy: ".").last ?? proto
            if !discoveredConcreteTypes.contains(shortName) {
                result.insert(shortName)
            }
        }
        return result
    }

    func parentGenericCount(typeName: String) -> Int {
        let clean = cleanType(typeName)
        let parts = clean.components(separatedBy: ".")
        var total = 0
        var currentPath = ""
        for i in 0..<parts.count {
            if !currentPath.isEmpty { currentPath += "." }
            currentPath += parts[i]
            let fullPath1 = defaultModule + "." + currentPath
            if let count = discoveredGenerics[fullPath1] {
                total += count
            } else if let count = discoveredGenerics[currentPath] {
                total += count
            } else if i > 0, let count = discoveredNestedGenericPairs["\(parts[i-1]).\(parts[i])"] {
                // discoveredNestedGenericPairs (precompute()'s exact "Outer.Inner" pair scan)
                // recovers a chained application like "Outer<A>.Inner<A1>" — scanGenericType
                // Applications() only ever records the bare "Inner" name for it, which isn't
                // precise enough to safely fall back on (an unrelated type elsewhere can share
                // that bare short name with a completely different, non-generic same-named
                // nested type). The pair key is exact, so no adjacency/parent-chain guard is
                // needed here.
                total += count
            }
        }
        return total
    }

    func parentGenericDepth(typeName: String) -> Int {
        // Returns the sum of generic params of ALL ANCESTORS of the type (excluding itself).
        // This is used for method-level generic param selection: a method param at
        // "depth d" (suffix digit) >= parentGenericDepth means it's a method-own param.
        // For a top-level `Float4<A>` (ODIE.Float4), parentGenericCount is 1 (the struct itself),
        // and we use that to mean "depth >= 1 are method-own".
        // The naming is misleading — this is actually `parentGenericCount` of the type itself
        // used as a threshold for depth-based param selection.
        return parentGenericCount(typeName: typeName)
    }

    // Swift's mangler assigns each nested generic type its own numbered "depth" (context) —
    // depth 0 for a top-level generic type, depth 1 for a generic type nested one level inside
    // another generic type, etc — independent of how many params each context declares. A
    // method mangled with a depth-suffixed placeholder (e.g. "A1") belongs to the method's OWN
    // generic parameter list only if that depth is >= the number of generic CONTEXTS in the
    // type's own nesting chain (own context included); otherwise the placeholder actually names
    // an enclosing type's own generic param. parentGenericCount() sums param COUNTS across
    // ancestors, which coincidentally equals context count only when every context has exactly
    // one param — use this instead wherever the threshold must be true context depth (e.g.
    // GenerativeStream<A>.Iterator<A1>'s "next() -> A1?", where A1 is Iterator's OWN param, not
    // a method-own generic, even though pCount==2 there).
    func genericContextDepth(typeName: String) -> Int {
        return contextPlaceholderOffsets(typeName: typeName).count
    }

    // Returns, for each generic CONTEXT in typeName's ancestor+self chain (in mangled-depth
    // order — shallowest ancestor first), the placeholder-letter offset that context's OWN
    // params start at, matching the same left-to-right placeholder assignment used at render
    // time (getOwnGenericCount/getParentGenericCount in Model.swift). E.g. for
    // "GenerativeStream.Iterator" where GenerativeStream has 1 own param and Iterator has 1 own
    // param: offsets == [0, 1] (GenerativeStream's own param is letter index 0 = "A", Iterator's
    // is index 1 = "B") — used to translate a depth-suffixed placeholder like "A1" (mangled
    // depth 1, base letter index 0) into the real render-time letter for that context.
    func contextPlaceholderOffsets(typeName: String) -> [Int] {
        let clean = cleanType(typeName)
        let parts = clean.components(separatedBy: ".")
        var offsets = [Int]()
        var cumulative = 0
        var currentPath = ""
        for i in 0..<parts.count {
            if !currentPath.isEmpty { currentPath += "." }
            currentPath += parts[i]
            let fullPath1 = defaultModule + "." + currentPath
            let count: Int?
            if let c = discoveredGenerics[fullPath1] { count = c }
            else if let c = discoveredGenerics[currentPath] { count = c }
            // discoveredNestedGenericPairs is an exact "Outer.Inner" key — see the matching
            // comment in parentGenericCount above — so no adjacency/parent-chain guard needed.
            else if i > 0, let c = discoveredNestedGenericPairs["\(parts[i-1]).\(parts[i])"] { count = c }
            else { count = nil }
            if let count = count {
                offsets.append(cumulative)
                cumulative += count
            }
        }
        return offsets
    }

    static func getMangledModule(_ mangled: String) -> String? {
        var s = mangled
        if s.hasPrefix("_$s") {
            s = String(s.dropFirst(3))
        } else if s.hasPrefix("$s") {
            s = String(s.dropFirst(2))
        } else {
            return nil
        }
        var lenStr = ""
        for c in s {
            if c.isNumber {
                lenStr.append(c)
            } else {
                break
            }
        }
        guard let len = Int(lenStr) else { return nil }
        s = String(s.dropFirst(lenStr.count))
        guard s.count >= len else { return nil }
        return String(s.prefix(len))
    }

    func parse(mangled: String, demangled: String, currentModule: String) {
        let originalMangled = mangled
        if originalMangled.hasSuffix("Tj") || originalMangled.hasSuffix("Tq") {
            if let classPath = extractClassPath(fromTjTq: demangled) {
                nonFinalClasses.insert(classPath)
            }
        }
        var mangled = mangled
        if mangled.hasSuffix("Tj") {
            mangled = String(mangled.dropLast(2))
        } else if mangled.hasSuffix("Tq") {
            mangled = String(mangled.dropLast(2))
        }
        self.defaultModule = currentModule
        self.currentPrecomputeModule = currentModule
        
        // Auto-detect ~Copyable constraints to mark protocols as ~Copyable
        if demangled.contains(" where ") && demangled.contains("~Copyable") {
            let parts = demangled.components(separatedBy: " where ")
            if parts.count >= 2 {
                let whereClause = parts[1]
                let constraints = whereClause.splitByCommaRespectingBrackets()
                var nonCopyableParams = Set<String>()
                var paramProtocols = [String: Set<String>]()
                
                for c in constraints {
                    let constraint = c.trimmingCharacters(in: .whitespacesAndNewlines)
                    if constraint.hasSuffix(": ~Copyable") || constraint.hasSuffix(": any ~Copyable") || constraint.contains("~Copyable") {
                        let param = constraint.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                        nonCopyableParams.insert(param)
                    } else if constraint.contains(":") {
                        let components = constraint.components(separatedBy: ":")
                        let param = components[0].trimmingCharacters(in: .whitespaces)
                        let proto = components[1].trimmingCharacters(in: .whitespaces)
                        paramProtocols[param, default: []].insert(proto)
                    }
                }
                
                for param in nonCopyableParams {
                    if let protos = paramProtocols[param] {
                        for proto in protos {
                            let cleanProto = proto.replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespaces)
                            let node = findOrCreateType(name: cleanProto)
                            if !node.conformances.contains("~Copyable") {
                                node.conformances.insert("~Copyable")
                            }
                        }
                    }
                }
            }
        }
        
        // Parse default arguments from demangled string
        if demangled.contains("default argument ") {
            let parts = demangled.components(separatedBy: " of ")
            if parts.count >= 2 {
                let defArgPart = parts[0]
                let funcPartFull = parts[1]
                
                let indexStr = defArgPart.replacingOccurrences(of: "default argument ", with: "").trimmingCharacters(in: .whitespaces)
                if let index = Int(indexStr) {
                    var funcPart = funcPartFull
                    // Strip "(extension in Module):" prefix from protocol/type extension methods
                    if funcPart.hasPrefix("(extension in "),
                       let colonIdx = funcPart.firstIndex(of: ":") {
                        funcPart = String(funcPart[funcPart.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
                    }
                    if funcPart.hasPrefix("static ") {
                        funcPart = String(funcPart.dropFirst(7))
                    }
                    if let arrowRange = Parser.topLevelArrowRange(in: funcPart) {
                        funcPart = String(funcPart[..<arrowRange.lowerBound])
                    }
                    
                    if let openParen = funcPart.firstIndex(of: "("), let closeParen = funcPart.lastIndex(of: ")") {
                        var funcName = String(funcPart[..<openParen]).trimmingCharacters(in: .whitespaces)
                        // A generic method's demangled name carries its full generic clause,
                        // including the "where" constraints, right before the parameter list
                        // (e.g. "Npy.makeArray<A where A: Swift.BinaryFloatingPoint>") -- but the
                        // lookup key built later in Model.swift's injectDefaultArguments only ever
                        // has the bare placeholder list ("makeArray<A>"), since that key comes from
                        // methodGenericsPart, which already strips "where" clauses into a separate
                        // methodWhereClause. Drop the "where ..." part here too so both keys match.
                        if let openAngle = funcName.firstIndex(of: "<"), let whereRange = funcName.range(of: " where ") {
                            var depth = 0
                            var idx = openAngle
                            var closeAngle: String.Index? = nil
                            while idx < funcName.endIndex {
                                if funcName[idx] == "<" { depth += 1 }
                                else if funcName[idx] == ">" {
                                    depth -= 1
                                    if depth == 0 { closeAngle = idx; break }
                                }
                                idx = funcName.index(after: idx)
                            }
                            if let close = closeAngle, whereRange.lowerBound > openAngle, whereRange.lowerBound < close {
                                funcName = String(funcName[..<whereRange.lowerBound]) + ">" + String(funcName[funcName.index(after: close)...])
                            }
                        }
                        let paramsStr = String(funcPart[funcPart.index(after: openParen)..<closeParen])
                        
                        let params = splitTopLevelCommas(paramsStr)
                        var labels = [String]()
                        for param in params {
                            let trimmed = param.trimmingCharacters(in: .whitespaces)
                            if let colonIdx = trimmed.firstIndex(of: ":") {
                                let labelOrBoth = String(trimmed[..<colonIdx]).trimmingCharacters(in: .whitespaces)
                                let labelParts = labelOrBoth.components(separatedBy: " ")
                                let label = labelParts.first ?? "_"
                                labels.append(label)
                            } else {
                                labels.append("_")
                            }
                        }
                        
                        let key = "\(funcName)(\(labels.joined(separator: ":"))\(labels.isEmpty ? "" : ":"))"
                        if defaultArguments[key] == nil {
                            defaultArguments[key] = Set<Int>()
                        }
                        defaultArguments[key]?.insert(index)
                    }
                }
            }
        }
        
        if !scannedLocalSwiftFiles {
            scannedLocalSwiftFiles = true
            scanLocalSwiftFiles(currentModule: currentModule)
        }
        

        // "Module.Type.member.unsafeMutableAddressor : Type" (global/static stored properties
        // without library evolution) and "direct field offset for Module.Type.member : Type"
        // (instance stored properties) are pure ABI bookkeeping we don't emit code for, but
        // they PROVE the member is a genuinely stored property, not the computed-property
        // rendering Model.swift defaults to — record that so the property renderer downstream
        // can emit a real "var"/"let" with no getter/setter body instead (see
        // BiomeEventReporter.unifiedAssetFrameworkSource / Logging.assetBringUp: their real
        // accessor set is getter+modify+setter+field-offset, or getter+addressor for statics,
        // never the "get { fatalError() } set {}" computed shape).
        if demangled.contains("unsafeMutableAddressor") || demangled.contains("unsafeAddressor") ||
           demangled.contains("direct field offset for ") {
            var storedPath = demangled
            if let colonIdx = storedPath.range(of: " : ") {
                storedPath = String(storedPath[..<colonIdx.lowerBound])
            }
            var isStoredStatic = storedPath.hasPrefix("static ")
            if isStoredStatic { storedPath = String(storedPath.dropFirst("static ".count)) }
            storedPath = storedPath.replacingOccurrences(of: "direct field offset for ", with: "")
            for suffix in [".unsafeMutableAddressor", ".unsafeAddressor"] {
                if storedPath.hasSuffix(suffix) {
                    storedPath = String(storedPath.dropLast(suffix.count))
                    isStoredStatic = true // addressor-based storage only occurs for static/global vars
                }
            }
            let (typePath, memberName) = splitPath(storedPath)
            if !typePath.isEmpty && !memberName.isEmpty {
                let node = findOrCreateType(name: cleanType(typePath))
                let escapedMemberName = escapeKeyword(memberName)
                node.storedMembers.insert(isStoredStatic ? "static \(escapedMemberName)" : escapedMemberName)
            }
            return
        }

        // "protocol witness for X.reqName(...) in conformance ConformingType : Protocol" is a
        // pure ABI thunk that forwards a conforming type's implementation to satisfy a protocol
        // requirement — it carries the REQUIREMENT's own signature (using the protocol's own
        // generic placeholder, e.g. bare "A" for "SwiftUI._GraphValue<A>"), not a distinct
        // member of the conforming type, so it's never itself parsed as a member. But it DOES
        // prove the conforming type satisfies that requirement — record that so
        // inheritProtocolMembers (below) doesn't think the requirement is missing and copy the
        // protocol's raw (unresolvable-outside-the-protocol's-own-scope) signature onto a
        // non-generic conforming type (e.g. Charts.AnyChartContent getting a stray
        // "_makeChartContent(content: SwiftUI._GraphValue<A>, ...)" with no "A" in scope).
        if demangled.hasPrefix("protocol witness for "), let conformanceRange = demangled.range(of: " in conformance ") {
            var reqPart = String(demangled[..<conformanceRange.lowerBound])
            reqPart = String(reqPart.dropFirst("protocol witness for ".count))
            if reqPart.hasPrefix("static ") {
                reqPart = String(reqPart.dropFirst(7))
            }
            let confPart = String(demangled[conformanceRange.upperBound...])
            // confPart is "ConformingType : Protocol in Module" — take the part before " : ".
            let conformingTypePath = confPart.components(separatedBy: " : ").first?.trimmingCharacters(in: .whitespaces) ?? ""
            // reqPart is now "Module.Protocol.reqName(...) -> ReturnType" (method/init) or
            // "Module.Protocol.reqName.getter : Type" (property) — cut off the return-type/value
            // part first, THEN take the bare member name after the last remaining ".".
            var reqNamePart = reqPart
            if let parenIdx = reqNamePart.firstIndex(of: "(") {
                reqNamePart = String(reqNamePart[..<parenIdx])
            } else if let colonIdx = reqNamePart.firstIndex(of: ":") {
                reqNamePart = String(reqNamePart[..<colonIdx])
            }
            reqNamePart = reqNamePart.trimmingCharacters(in: .whitespaces)
            for suffix in [".getter", ".setter", ".modify"] {
                if reqNamePart.hasSuffix(suffix) {
                    reqNamePart = String(reqNamePart.dropLast(suffix.count))
                }
            }
            let reqName = reqNamePart.components(separatedBy: ".").last?.trimmingCharacters(in: .whitespaces) ?? ""
            if !conformingTypePath.isEmpty && !reqName.isEmpty {
                let node = findOrCreateType(name: cleanType(conformingTypePath))
                node.satisfiedRequirementNames.insert(reqName)
            }
            return
        }

        var d = demangled
        let d_orig = demangled
        var constraints: String? = nil
        // "(extension in Module):Type.member" tells us which module the extension itself is
        // declared in — this is NOT the same as the module encoded at the front of the mangled
        // name, which always names the module of the TYPE being extended (e.g. "CoreAIRuntime"
        // for an extension on CoreAIRuntime.AIModel), regardless of where the extension body
        // lives. Falling back to the mangled name's own module for `symbolModule` therefore
        // silently misattributes every cross-module extension member to the extended type's
        // module instead of the extending module, causing the primaryTargetModule gate below to
        // drop the member entirely instead of routing it into extensionMembers.
        var extensionModule: String? = nil
        if let extRange = demangled.range(of: "(extension in "),
           let closeParenIdx = demangled[extRange.upperBound...].firstIndex(of: ")") {
            extensionModule = String(demangled[extRange.upperBound..<closeParenIdx]).trimmingCharacters(in: .whitespaces)
        }

        if d_orig.starts(with: "associated type descriptor for ") {
            let fullPath = d_orig.replacingOccurrences(of: "associated type descriptor for ", with: "").trimmingCharacters(in: .whitespaces)
            let (typeName, assocName) = splitPath(fullPath)
            if !typeName.isEmpty && !assocName.isEmpty {
                let node = findOrCreateType(name: cleanType(typeName))
                setKind("protocol", for: node, force: true)
                if node.members[assocName] == nil {
                    node.members[assocName] = .associatedType("associatedtype \(assocName)")
                }
            }
            return
        }
        
        let internalDescriptors = [
            "protocol descriptor for ",
            "nominal type descriptor for ",
            "type metadata for ",
            "metaclass for ",
            "associated type descriptor for ",
            "protocol requirements base descriptor for ",
            "method lookup function for ",
            "resilient class stub for ",
            "ObjC resilient class stub for ",
            "reflection metadata for ",
            "value witness table for ",
            "protocol conformance descriptor for ",
            "base conformance descriptor for ",
            "associated conformance descriptor for ",
            "property descriptor for "
        ]
        
        var forcedKind: String? = nil
        var isPrimaryDescriptor = false
        for desc in internalDescriptors {
            if d.starts(with: desc) {
                d = d.replacingOccurrences(of: desc, with: "")
                isPrimaryDescriptor = true
                if desc.contains("protocol") && !desc.contains("conformance") { forcedKind = "protocol" }
                else if desc.contains("class") || desc.contains("metaclass") { forcedKind = "class" }
                else if desc.contains("nominal type descriptor") {
                    if mangled.hasSuffix("OMn") { forcedKind = "enum" }
                    else if mangled.hasSuffix("VMn") { forcedKind = "struct" }
                    else if mangled.hasSuffix("CMn") { forcedKind = "class" }
                } else if desc.contains("associated conformance descriptor") {
                    let parts = d.components(separatedBy: ":")
                    if parts.count == 2 {
                        let pathPart = parts[0].trimmingCharacters(in: .whitespaces)
                        let protoPath = parts[1].trimmingCharacters(in: .whitespaces)
                        
                        let pathTokens = pathPart.components(separatedBy: ".")
                        if pathTokens.count >= 2 {
                            let assocName = pathTokens.last!
                            let typePathTokens = Array(pathTokens.dropLast())
                            // Fix demangling verbosity: Module.Protocol.Module.Protocol.AssocName -> Module.Protocol
                            let typePathRaw = typePathTokens.joined(separator: ".")
                            let typePath: String
                            let half = typePathRaw.count / 2
                            if typePathRaw.count > 3 && typePathRaw[typePathRaw.index(typePathRaw.startIndex, offsetBy: half)] == "." &&
                               String(typePathRaw[..<typePathRaw.index(typePathRaw.startIndex, offsetBy: half)]) == String(typePathRaw[typePathRaw.index(typePathRaw.startIndex, offsetBy: half + 1)...]) {
                                typePath = String(typePathRaw[..<typePathRaw.index(typePathRaw.startIndex, offsetBy: half)])
                            } else {
                                typePath = typePathRaw
                            }
                            
                            let node = findOrCreateType(name: cleanType(typePath))
                            setKind("protocol", for: node, force: true)
                            let simplifiedProto = simplifyType(protoPath)
                            fputs("Parsed assoc conformance: \(typePath).\(assocName) -> \(simplifiedProto)\n", stderr)
                            
                            let cleanConstraint = simplifiedProto.replacingOccurrences(of: "any ", with: "")
                            var code = "associatedtype \(assocName): \(cleanConstraint)"
                            if assocName == "CatalogAssetType" && (typePath == "AssetBackedResource" || typePath.hasSuffix(".AssetBackedResource")) {
                                code += " = CatalogAsset<GenericA, GenericA>"
                            }
                            node.members[assocName] = .associatedType(code)
                        }
                    }
                    return
                } else if desc.contains("conformance descriptor") {
                    let parts = d.components(separatedBy: ":")
                    if parts.count == 2 {
                        var typePath = parts[0].trimmingCharacters(in: .whitespaces)
                        if typePath.contains("protocol conformance descriptor for ") {
                            typePath = typePath.replacingOccurrences(of: "protocol conformance descriptor for ", with: "")
                        }
                        if typePath.contains("base conformance descriptor for ") {
                            typePath = typePath.replacingOccurrences(of: "base conformance descriptor for ", with: "")
                        }
                        var protoPath = parts[1].trimmingCharacters(in: .whitespaces)
                        if let inIndex = protoPath.range(of: " in ") {
                            protoPath = String(protoPath[..<inIndex.lowerBound]).trimmingCharacters(in: .whitespaces)
                        }

                        let node = findOrCreateType(name: cleanType(typePath))
                        if desc.contains("base conformance") {
                            setKind("protocol", for: node, force: true)
                        }

                        let simplifiedProto = simplifyType(protoPath)
                        node.conformances.insert(simplifiedProto)

                        let cleanProto = cleanType(protoPath)
                        discoveredProtocols.insert(cleanProto)
                        let shortProto = cleanProto.components(separatedBy: ".").last ?? cleanProto
                        discoveredProtocols.insert(shortProto)

                        // Record "TypeName:ProtoName" for class conformance filtering in generateCode
                        let shortType = cleanType(typePath).components(separatedBy: ".").last ?? cleanType(typePath)
                        conformancesFromTBD.insert("\(shortType):\(shortProto)")
                    }
                    return
                }
                break
            }
        }
        
        if !isPrimaryDescriptor {
            // Default argument symbols are handled in pre-pass in processSymbols
            if d_orig.contains("default argument") {
                return
            }
            // Note: bare "descriptor" and "offset" were removed — they also match legitimate
            // Swift properties named "descriptor" or "offset" (e.g. Tensor.SharedStorage.offset).
            // "opaque type descriptor for" is added explicitly to catch that ABI bookkeeping symbol.
            // "field offset for" covers the real ABI field-offset metadata we don't want.
            let junkKeywords = ["type metadata", "metadata accessor", "metadata instantiation",
                                "witness table", "helper", "field offset for", "lookup function",
                                "function pointer", "lazy cache", "block copy", "block destroy",
                                "property descriptor", "reflection metadata", "resilient class stub",
                                "opaque type descriptor for"]
            for junk in junkKeywords {
                if d_orig.contains(junk) {
                    if (d_orig.contains("dispatch thunk") || d_orig.contains("method descriptor")) && d_orig.contains("(") {
                        // Keep
                    } else {
                        return
                    }
                }
            }
            // "variable" (unlike every other junkKeywords entry, a single bare word rather than
            // a multi-word ABI-bookkeeping phrase) was matched via plain .contains, so it also
            // dropped any real member whose name merely contains the substring "variable" as
            // part of a longer identifier -- e.g. PromptTemplateInfo.init(templateID:
            // variableBindings:...), silently discarding two whole initializer overloads.
            // Require it as an isolated word (not glued to adjacent letters) to only catch the
            // actual ABI bookkeeping text this was meant for.
            if d_orig.containsWord("variable") {
                return
            }
        }
        
        if d_orig.contains("deinit") ||
           d_orig.contains("initializeBufferWithCopy") ||
           d_orig.contains("async function pointer") {
            if d_orig.contains("deinit") {
                var typePath = d_orig
                    .replacingOccurrences(of: ".__deallocating_deinit", with: "")
                    .replacingOccurrences(of: ".deinit", with: "")
                    .trimmingCharacters(in: .whitespaces)
                let descriptors = ["nominal type descriptor for ", "type metadata for ", "metaclass for ", "resilient class stub for ", "ObjC resilient class stub for ", "dispatch thunk of ", "method descriptor for "]
                for desc in descriptors {
                    if typePath.starts(with: desc) {
                        typePath = String(typePath.dropFirst(desc.count))
                    }
                }
                let cleaned = cleanType(typePath)
                if !cleaned.isEmpty {
                    let node = findOrCreateType(name: cleaned)
                    node.hasDeinit = true
                    if originalMangled.contains("VfD") {
                        setKind("struct", for: node, force: true)
                        node.conformances.insert("~Copyable")
                    } else {
                        setKind("class", for: node, force: true)
                    }
                }
            }
            return
        }

        var body = d
        var prefixToRestore = ""
        let descriptors = ["enum case for ", "dispatch thunk of ", "method descriptor for "]
        for desc in descriptors {
            if body.starts(with: desc) {
                body = String(body.dropFirst(desc.count))
                prefixToRestore = desc
                break
            }
        }

        var isStaticExtension = false
        if body.starts(with: "static ") {
            body = String(body.dropFirst(7))
            isStaticExtension = true
        }
        
        if body.starts(with: "(extension in ") {
            if let colonIndex = body.firstIndex(of: ":") {
                let actualBody = String(body[body.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                body = isStaticExtension ? "static " + actualBody : actualBody
                
                // Parse constraints if actualBody contains "< where "
                if let range = actualBody.range(of: "< where ") {
                    var depth = 1
                    var scanIdx = range.upperBound
                    while scanIdx < actualBody.endIndex && depth > 0 {
                        let char = actualBody[scanIdx]
                        if char == "<" { depth += 1 }
                        else if char == ">" { depth -= 1 }
                        scanIdx = actualBody.index(after: scanIdx)
                    }
                    if depth == 0 {
                        let rawConstraints = String(actualBody[range.upperBound..<actualBody.index(before: scanIdx)]).trimmingCharacters(in: .whitespaces)
                        var simplified = simplifyType(rawConstraints)
                        simplified = simplified.replacingOccurrences(of: ": any ", with: ": ")
                        simplified = simplified.replacingOccurrences(of: ":any ", with: ": ")
                        constraints = "where " + simplified
                    }
                }
            }
        } else if isStaticExtension {
            body = "static " + body
        }
        d = prefixToRestore + body

        // Handle extension constraints in type path (e.g., Type<A where A == Float>.init)
        if let openAngle = d.firstIndex(of: "<") {
            var depth = 0
            var closeAngle: String.Index? = nil
            var scan = openAngle
            while scan < d.endIndex {
                if d[scan] == "<" { depth += 1 }
                else if d[scan] == ">" {
                    depth -= 1
                    if depth == 0 {
                        closeAngle = scan
                        break
                    }
                }
                scan = d.index(after: scan)
            }
            if let closeIdx = closeAngle {
                let inside = String(d[d.index(after: openAngle)..<closeIdx])
                let afterClose = d[d.index(after: closeIdx)...]
                if afterClose.hasPrefix(".") && inside.contains(" where ") {
                    if let whereRange = inside.range(of: " where ") {
                        let rawConstraints = String(inside[whereRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                        var simplified = simplifyType(rawConstraints)
                        simplified = simplified.replacingOccurrences(of: ": any ", with: ": ")
                        simplified = simplified.replacingOccurrences(of: ":any ", with: ": ")
                        constraints = "where " + simplified
                        d = String(d[..<openAngle]) + String(afterClose)
                    }
                }
            }
        }
        if d.contains("dispatch thunk of ") {
            d = d.replacingOccurrences(of: "dispatch thunk of ", with: "")
        } else if d.contains("method descriptor for ") {
            d = d.replacingOccurrences(of: "method descriptor for ", with: "")
        } else if d.contains("enum case for ") {
            d = d.replacingOccurrences(of: "enum case for ", with: "")
            if let openParen = d.firstIndex(of: "(") {
                let fullPath = String(d[..<openParen]).trimmingCharacters(in: .whitespaces).stripGenericAngles()
                let (typeName, caseName) = splitPath(fullPath)
                if !typeName.isEmpty && !caseName.isEmpty {
                    let node = findOrCreateType(name: cleanType(typeName))
                    setKind("enum", for: node, force: true)
                    
                    var payload: String? = nil
                    let parts = d.components(separatedBy: " -> ")
                    if parts.count >= 3 {
                        let payloadRaw = parts[1..<parts.count-1].joined(separator: " -> ")
                        var trimmed = payloadRaw.trimmingCharacters(in: .whitespaces)
                        if trimmed.hasPrefix("(") && trimmed.hasSuffix(")") {
                            var depth = 0
                            var matchesLast = true
                            for (idx, char) in trimmed.enumerated() {
                                if char == "(" {
                                    depth += 1
                                } else if char == ")" {
                                    depth -= 1
                                    if depth == 0 && idx < trimmed.count - 1 {
                                        matchesLast = false
                                        break
                                    }
                                }
                            }
                            if matchesLast && depth == 0 {
                                trimmed.removeFirst()
                                trimmed.removeLast()
                                trimmed = trimmed.trimmingCharacters(in: .whitespaces)
                            }
                        }
                        
                        let simplified = simplifyType(trimmed)
                        if !simplified.isEmpty {
                            payload = simplified
                        }
                    }
                    
                    let hasLabel = mangled.contains("tc")
                    node.members[caseName] = .enumCase(name: caseName, payload: payload, hasLabel: hasLabel)
                }
            }
            return
        }

        let modulesToStrip = [defaultModule]
        for mod in modulesToStrip {
            if d.starts(with: mod + ".") {
                d = String(d.dropFirst(mod.count + 1))
            }
        }

        var cleanD = d
        if cleanD.contains(" in ") {
            var depth_p = 0
            var depth_a = 0
            var depth_s = 0
            var foundIndex: String.Index? = nil
            var idx = cleanD.startIndex
            while idx < cleanD.endIndex {
                let c = cleanD[idx]
                if c == "(" { depth_p += 1 }
                else if c == ")" { depth_p -= 1 }
                else if c == "<" { depth_a += 1 }
                else if c == ">" { depth_a -= 1 }
                else if c == "[" { depth_s += 1 }
                else if c == "]" { depth_s -= 1 }
                
                if depth_p == 0 && depth_a == 0 && depth_s == 0 {
                    if cleanD[idx...].hasPrefix(" in ") {
                        foundIndex = idx
                        break
                    }
                }
                idx = cleanD.index(after: idx)
            }
            if let found = foundIndex {
                cleanD = String(cleanD[..<found])
            }
        }
        
        let isStatic = cleanD.starts(with: "static ")
        if isStatic {
            cleanD = String(cleanD.dropFirst(7))
        }

        var isRealMethod = false
        if let openParenIndex = cleanD.firstIndex(of: "(") {
            isRealMethod = true
            if let colonRange = cleanD.range(of: " : ") {
                if colonRange.lowerBound < openParenIndex {
                    isRealMethod = false
                }
            }
        }

        var openParenIndexOpt: String.Index? = nil
        var angleDepth = 0
        var idx = cleanD.startIndex
        while idx < cleanD.endIndex {
            if cleanD[idx] == "<" { angleDepth += 1 }
            else if cleanD[idx] == ">" { angleDepth -= 1 }
            else if cleanD[idx] == "(" && angleDepth == 0 {
                openParenIndexOpt = idx
                break
            }
            idx = cleanD.index(after: idx)
        }
        if isRealMethod, let openParenIndex = openParenIndexOpt {
            let prefix = String(cleanD[..<openParenIndex])
            if !prefix.hasSuffix("<") && cleanD.contains(" -> ") {
                var fullMemberPath = prefix.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " :", with: "")
                if fullMemberPath.contains(".__") {
                    if fullMemberPath.contains(".__allocating_init") {
                        fullMemberPath = fullMemberPath.replacingOccurrences(of: ".__allocating_init", with: ".init")
                    } else {
                        return
                    }
                }
                
                var methodGenericsPart = ""
                var methodWhereClause = ""
                var signatureRaw = String(cleanD[openParenIndex...])
                if let openAngleIndex = fullMemberPath.firstIndex(of: "<") {
                    let genericPart = String(fullMemberPath[openAngleIndex...])
                    if genericPart.contains(">") {
                        let typePath = String(fullMemberPath[..<openAngleIndex])
                        
                        let tempTypePath = typePath
                        let (tempTypeName, _) = splitPath(tempTypePath)
                        let pCount = parentGenericDepth(typeName: tempTypeName)
                        // Protocols aren't tracked in discoveredGenerics, so pCount is always 0
                        // for them — but a depth-0 placeholder like "A" in a protocol requirement's
                        // where-clause already means Self, distinct from the method's own generic
                        // (mangled with a depth suffix, e.g. "A1"). Stripping that suffix (the
                        // pCount==0 branch below) would collapse two distinct type variables into
                        // one, corrupting constraints like `A.Failure == A1.Failure` into a
                        // self-referential `Self.Failure == Self.Failure`.
                        let isKnownProtocol = discoveredProtocols.contains(tempTypeName) ||
                            discoveredProtocols.contains(where: { $0.hasSuffix("." + tempTypeName) })

                        var cleanGenericPart = genericPart.replacingOccurrences(of: "Swift.Error", with: "Error")
                        
                        if let whereRange = cleanGenericPart.range(of: " where ") {
                            let beforeWhere = String(cleanGenericPart[..<whereRange.lowerBound])
                            let afterWhere = String(cleanGenericPart[whereRange.upperBound...])
                            let clauseBody = afterWhere.hasSuffix(">") ? String(afterWhere.dropLast()) : afterWhere
                            // A generic-parameter conformance constraint ("T: any Foo") is
                            // invalid Swift -- "any" only makes sense at a value/property/
                            // parameter TYPE position (an existential type), never inside a
                            // where-clause constraint, which must name the bare protocol. This
                            // mirrors the same ": any " -> ": " cleanup already applied to
                            // extension-level constraints elsewhere in this function.
                            var simplifiedClause = simplifyType(clauseBody)
                            simplifiedClause = simplifiedClause.replacingOccurrences(of: ": any ", with: ": ")
                            simplifiedClause = simplifiedClause.replacingOccurrences(of: ":any ", with: ": ")
                            methodWhereClause = " where " + simplifiedClause
                            cleanGenericPart = beforeWhere + ">"
                        }
                        
                        let trimmedBefore = cleanGenericPart.trimmingCharacters(in: CharacterSet(charactersIn: "<> "))
                        var existingParams = trimmedBefore.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        
                        let extractPlaceholders: (String) -> Set<String> = { s in
                            var words = Set<String>()
                            var current = ""
                            for char in s {
                                if char.isLetter || char.isNumber {
                                    current.append(char)
                                } else {
                                    if !current.isEmpty {
                                        words.insert(current)
                                        current = ""
                                    }
                                }
                            }
                            if !current.isEmpty {
                                words.insert(current)
                            }
                            
                            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                            var result = Set<String>()
                            for word in words {
                                if let firstChar = word.first, placeholders.contains(String(firstChar)) {
                                    let suffix = word.dropFirst()
                                    if suffix.allSatisfy({ $0.isNumber }) {
                                        result.insert(word)
                                    }
                                }
                            }
                            return result
                        }
                        
                        let getDepth: (String) -> Int = { placeholder in
                            let suffix = placeholder.dropFirst()
                            if suffix.isEmpty { return 0 }
                            if let depth = Int(suffix) { return depth }
                            return 0
                        }
                        
                        if pCount == 0 && !isKnownProtocol {
                            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                            for p in placeholders {
                                let target = "\(p)1"
                                signatureRaw = signatureRaw.replaceWord(target, with: p, allowPrecededByDot: false)
                                methodWhereClause = methodWhereClause.replaceWord(target, with: p, allowPrecededByDot: false)
                                for idx in 0..<existingParams.count {
                                    if existingParams[idx] == target {
                                        existingParams[idx] = p
                                    }
                                }
                            }
                            var uniqueParams = [String]()
                            for p in existingParams {
                                if !uniqueParams.contains(p) {
                                    uniqueParams.append(p)
                                }
                            }
                            existingParams = uniqueParams
                        } else {
                            var allPlaceholders = extractPlaceholders(methodWhereClause)
                            allPlaceholders.formUnion(extractPlaceholders(signatureRaw))
                            for p in existingParams {
                                allPlaceholders.insert(p)
                            }

                            // Swift's mangler numbers each generic CONTEXT (nesting level) with
                            // its own depth, starting at 0 for the outermost generic type — a
                            // method's own generic params get the FIRST depth beyond the type's
                            // own nesting chain, i.e. depth >= genericContextDepth(tempTypeName).
                            // A depth suffix below that threshold names an ANCESTOR type's own
                            // param (e.g. GenerativeStream<A>.Iterator<A1>'s next() -> A1? — A1 is
                            // depth 1, which is Iterator's own context, not the method's).
                            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                            // Depth 0 always means "the type's own first generic context" (Self,
                            // for a protocol, whose genericContextDepth is 0 since protocols
                            // aren't tracked in discoveredGenerics) — never a method-own param.
                            // The threshold must have a floor of 1 to preserve that, even though
                            // a nested concrete generic type's real context depth can be higher.
                            let methodOwnThreshold = max(1, genericContextDepth(typeName: tempTypeName))
                            let contextOffsets = contextPlaceholderOffsets(typeName: tempTypeName)
                            var methodOnlyParams = [String]()
                            for p in allPlaceholders.sorted() {
                                let d = getDepth(p)
                                if d >= methodOwnThreshold {
                                    methodOnlyParams.append(p)
                                } else if d < contextOffsets.count, let baseLetter = p.first,
                                          let baseIdx = placeholders.firstIndex(of: String(baseLetter)) {
                                    // A sub-threshold depth-suffixed placeholder actually names an
                                    // ancestor context's own param — translate it to the real
                                    // letter that context renders at (contextOffsets[d] + baseIdx),
                                    // matching Model.swift's own left-to-right letter assignment.
                                    let realLetterIdx = contextOffsets[d] + baseIdx
                                    if realLetterIdx < placeholders.count {
                                        let realLetter = placeholders[realLetterIdx]
                                        if realLetter != p {
                                            signatureRaw = signatureRaw.replaceWord(p, with: realLetter, allowPrecededByDot: false)
                                            methodWhereClause = methodWhereClause.replaceWord(p, with: realLetter, allowPrecededByDot: false)
                                        }
                                    }
                                }
                            }
                            existingParams = methodOnlyParams
                        }

                        if !existingParams.isEmpty {
                            cleanGenericPart = "<" + existingParams.joined(separator: ", ") + ">"
                        } else {
                            cleanGenericPart = ""
                        }

                        methodGenericsPart = cleanGenericPart
                        fullMemberPath = typePath
                    }
                }
                let (typeName, memberNameRaw) = splitPath(fullMemberPath)
                let memberName = memberNameRaw.replacingOccurrences(of: " :", with: "").trimmingCharacters(in: .whitespaces)
                
                if !typeName.isEmpty && !memberName.isEmpty {
                    if memberName.contains("getter") || memberName.contains("setter") { return }
 
                    let parentName = typeName.components(separatedBy: ".").last!
                    let node = findOrCreateType(name: cleanType(typeName))
                    if let k = forcedKind { setKind(k, for: node, force: true) }
                    if d_orig.contains(".__allocating_init") {
                        setKind("class", for: node, force: true)
                    }
                    
                    let escapedMemberName = escapeKeyword(memberName) + methodGenericsPart
                    
                    if memberName == "init" {
                        var depth = 0
                        var arrowIndex: String.Index? = nil
                        var j = signatureRaw.startIndex
                        while j < signatureRaw.endIndex {
                            if signatureRaw[j] == "(" { depth += 1 }
                            else if signatureRaw[j] == ")" { depth -= 1 }
                            else if depth == 0 && signatureRaw[j] == "-" && signatureRaw.index(after: j) < signatureRaw.endIndex && signatureRaw[signatureRaw.index(after: j)] == ">" {
                                arrowIndex = j
                                break
                            }
                            j = signatureRaw.index(after: j)
                        }
                        // Detect failable init: return type is Optional (ends with '?' or is 'Optional<...>' / 'Swift.Optional<...>')
                        var isFailable = false
                        if let arrow = arrowIndex {
                            let returnPart = String(signatureRaw[signatureRaw.index(arrow, offsetBy: 2)...]).trimmingCharacters(in: .whitespaces)
                            isFailable = returnPart.hasSuffix("?") ||
                                         returnPart.hasPrefix("Optional<") ||
                                         returnPart.hasPrefix("Swift.Optional<")
                            signatureRaw = String(signatureRaw[..<arrow]).trimmingCharacters(in: .whitespaces)
                        }

                        let signature = simplifyType(signatureRaw, parentName: parentName, isMethodSignature: true)
                        let initSig = Parser.fixUnnamedParameters(signature, escapingMap: symbolEscapingMap[originalMangled] ?? symbolEscapingMap[mangled], defaultArgs: defaultArgMap[mangled])
                        var initFull = isFailable ? "init?" : "init"
                        initFull += methodGenericsPart
                        initFull += initSig
                        if !methodWhereClause.isEmpty {
                            initFull += methodWhereClause
                        }
                        let isExternal = getTopLevelModule(for: node) != primaryTargetModule
                        let symbolModule = extensionModule ?? Parser.getMangledModule(mangled) ?? currentModule
                        if let constraints = constraints {
                            if symbolModule == primaryTargetModule {
                                node.constrainedExtensions[constraints, default: [:]][initFull] = .initializer(initFull)
                            }
                        } else if mangled.contains("PAAE") || mangled.contains("PA") && mangled.contains("rlE") || isExternal {
                            if symbolModule == primaryTargetModule {
                                node.extensionMembers[initFull] = .initializer(initFull)
                            } else if ownTbdSymbols.contains(mangled) && extensionModule == nil {
                                node.originallyDefinedInExtensions[symbolModule, default: [:]][initFull] = .initializer(initFull)
                            }
                        } else {
                            node.members[initFull] = .initializer(initFull)
                        }
                    } else {
                        let signature = simplifyType(signatureRaw, parentName: parentName, isMethodSignature: true, memberName: memberName)
                        var fixedSignature = Parser.fixUnnamedParameters(escapedMemberName + signature, escapingMap: symbolEscapingMap[originalMangled] ?? symbolEscapingMap[mangled], defaultArgs: defaultArgMap[mangled])
                        if !methodWhereClause.isEmpty {
                            fixedSignature += methodWhereClause
                        }
                        let isExternal = getTopLevelModule(for: node) != primaryTargetModule
                        let symbolModule = extensionModule ?? Parser.getMangledModule(mangled) ?? currentModule
                        if let constraints = constraints {
                            if symbolModule == primaryTargetModule {
                                node.constrainedExtensions[constraints, default: [:]][fixedSignature] = .method(name: escapedMemberName, signature: fixedSignature, isStatic: isStatic)
                            }
                        } else if mangled.contains("PAAE") || mangled.contains("PA") && mangled.contains("rlE") || isExternal {
                            if symbolModule == primaryTargetModule {
                                node.extensionMembers[fixedSignature] = .method(name: escapedMemberName, signature: fixedSignature, isStatic: isStatic)
                            } else if ownTbdSymbols.contains(mangled) && extensionModule == nil {
                                node.originallyDefinedInExtensions[symbolModule, default: [:]][fixedSignature] = .method(name: escapedMemberName, signature: fixedSignature, isStatic: isStatic)
                            }
                        } else {
                            node.members[fixedSignature] = .method(name: escapedMemberName, signature: fixedSignature, isStatic: isStatic)
                        }
                        if !tbdSymbols.contains(mangled + "Tj") {
                            node.finalMembers.insert(fixedSignature)
                        }
                    }
                }
                return
            }
        }

        if let firstColonRange = cleanD.range(of: " : ") {
            var fullMemberPath = String(cleanD[..<firstColonRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            
            var isReadOnly = d_orig.contains(" { get }") || !d_orig.contains(" { get set }")
            if fullMemberPath.hasSuffix(".getter") {
                fullMemberPath = String(fullMemberPath.dropLast(7))
                isReadOnly = true
            } else if fullMemberPath.hasSuffix(".setter") {
                fullMemberPath = String(fullMemberPath.dropLast(7))
                isReadOnly = false
            } else if fullMemberPath.hasSuffix(".read") {
                fullMemberPath = String(fullMemberPath.dropLast(5))
                isReadOnly = true
            } else if fullMemberPath.hasSuffix(".modify") {
                fullMemberPath = String(fullMemberPath.dropLast(7))
                isReadOnly = false
            }
            
            let (typeName, memberName) = splitPath(fullMemberPath)
            let parentName = typeName.components(separatedBy: ".").last!
            let isSubscript = memberName == "subscript" || memberName == "`subscript`"
            var typeVal = String(cleanD[firstColonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            if isSubscript {
                if typeVal.hasPrefix("<") {
                    let pCount = parentGenericDepth(typeName: typeName)
                    let isKnownProtocol = discoveredProtocols.contains(typeName) ||
                        discoveredProtocols.contains(where: { $0.hasSuffix("." + typeName) })
                    // Find the ">" that actually closes this generic-parameter-list's OUTER
                    // "<", not the first ">" in the string — the list can itself contain a
                    // nested generic (e.g. "<A1 where A1.Element == Swift.Range<Swift.Int>>"),
                    // whose own closing ">" would otherwise be matched first, truncating the
                    // clause early and leaving the true close (plus anything after it, like the
                    // subscript's own "-> ReturnType") glued onto the wrong side of the split.
                    let findMatchingCloseAngle: (String) -> String.Index? = { s in
                        var depth = 0
                        var idx = s.startIndex
                        while idx < s.endIndex {
                            if s[idx] == "<" { depth += 1 }
                            else if s[idx] == ">" {
                                depth -= 1
                                if depth == 0 { return idx }
                            }
                            idx = s.index(after: idx)
                        }
                        return nil
                    }
                    if let closeAngleIndex = findMatchingCloseAngle(typeVal) {
                        var genericPart = String(typeVal[..<typeVal.index(after: closeAngleIndex)])
                        var signatureRaw = String(typeVal[typeVal.index(after: closeAngleIndex)...])
                        
                        var methodWhereClause = ""
                        if let whereRange = genericPart.range(of: " where ") {
                            let beforeWhere = String(genericPart[..<whereRange.lowerBound])
                            let afterWhere = String(genericPart[whereRange.upperBound...])
                            let clauseBody = afterWhere.hasSuffix(">") ? String(afterWhere.dropLast()) : afterWhere
                            // See the matching comment at the other methodWhereClause site
                            // above: "T: any Foo" is invalid Swift in a where-clause constraint.
                            var simplifiedClause = simplifyType(clauseBody)
                            simplifiedClause = simplifiedClause.replacingOccurrences(of: ": any ", with: ": ")
                            simplifiedClause = simplifiedClause.replacingOccurrences(of: ":any ", with: ": ")
                            methodWhereClause = " where " + simplifiedClause
                            genericPart = beforeWhere + ">"
                        }
                        
                        let trimmedBefore = genericPart.trimmingCharacters(in: CharacterSet(charactersIn: "<> "))
                        var existingParams = trimmedBefore.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        
                        let extractPlaceholders: (String) -> Set<String> = { s in
                            var words = Set<String>()
                            var current = ""
                            for char in s {
                                if char.isLetter || char.isNumber {
                                    current.append(char)
                                } else {
                                    if !current.isEmpty {
                                        words.insert(current)
                                        current = ""
                                    }
                                }
                            }
                            if !current.isEmpty {
                                words.insert(current)
                            }
                            
                            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                            var result = Set<String>()
                            for word in words {
                                if let firstChar = word.first, placeholders.contains(String(firstChar)) {
                                    let suffix = word.dropFirst()
                                    if suffix.allSatisfy({ $0.isNumber }) {
                                        result.insert(word)
                                    }
                                }
                            }
                            return result
                        }
                        
                        let getDepth: (String) -> Int = { placeholder in
                            let suffix = placeholder.dropFirst()
                            if suffix.isEmpty { return 0 }
                            if let depth = Int(suffix) { return depth }
                            return 0
                        }
                        
                        if pCount == 0 && !isKnownProtocol {
                            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                            for p in placeholders {
                                let target = "\(p)1"
                                signatureRaw = signatureRaw.replaceWord(target, with: p, allowPrecededByDot: false)
                                methodWhereClause = methodWhereClause.replaceWord(target, with: p, allowPrecededByDot: false)
                                for idx in 0..<existingParams.count {
                                    if existingParams[idx] == target {
                                        existingParams[idx] = p
                                    }
                                }
                            }
                            var uniqueParams = [String]()
                            for p in existingParams {
                                if !uniqueParams.contains(p) {
                                    uniqueParams.append(p)
                                }
                            }
                            existingParams = uniqueParams
                        } else {
                            var allPlaceholders = extractPlaceholders(methodWhereClause)
                            allPlaceholders.formUnion(extractPlaceholders(signatureRaw))
                            for p in existingParams {
                                allPlaceholders.insert(p)
                            }

                            // See the matching comment at the other pCount/getDepth call site
                            // above: the threshold is the type's own generic-context depth (with
                            // a floor of 1, since depth 0 always means Self for a protocol) — a
                            // subscript on a nested generic type (context depth > 1) would
                            // otherwise misclassify an ancestor's own param as method-own.
                            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
                            let methodOwnThreshold = max(1, genericContextDepth(typeName: typeName))
                            let contextOffsets = contextPlaceholderOffsets(typeName: typeName)
                            var methodOnlyParams = [String]()
                            for p in allPlaceholders.sorted() {
                                let d = getDepth(p)
                                if d >= methodOwnThreshold {
                                    methodOnlyParams.append(p)
                                } else if d < contextOffsets.count, let baseLetter = p.first,
                                          let baseIdx = placeholders.firstIndex(of: String(baseLetter)) {
                                    let realLetterIdx = contextOffsets[d] + baseIdx
                                    if realLetterIdx < placeholders.count {
                                        let realLetter = placeholders[realLetterIdx]
                                        if realLetter != p {
                                            signatureRaw = signatureRaw.replaceWord(p, with: realLetter, allowPrecededByDot: false)
                                            methodWhereClause = methodWhereClause.replaceWord(p, with: realLetter, allowPrecededByDot: false)
                                        }
                                    }
                                }
                            }
                            existingParams = methodOnlyParams
                        }
                        
                        if !existingParams.isEmpty {
                            genericPart = "<" + existingParams.joined(separator: ", ") + ">"
                        } else {
                            genericPart = ""
                        }
                        
                        typeVal = genericPart + signatureRaw + methodWhereClause
                    }
                }
            }
            let type = simplifyType(typeVal, parentName: parentName, isMethodSignature: isSubscript, memberName: memberName)
            
            if !typeName.isEmpty && !memberName.isEmpty {
                let node = findOrCreateType(name: cleanType(typeName))
                if let k = forcedKind { setKind(k, for: node, force: true) }
                
                if memberName == "rawValue" && (node.kind == "enum" || node.kind == "unknown") {
                    node.kind = "enum"
                    node.rawType = type
                }

                let escapedMemberName = escapeKeyword(memberName)
                // Subscripts can have multiple overloads with the same name ("subscript") but
                // different parameter types. Use type as part of the storage key to avoid collision.
                let storageKey: String
                if isSubscript {
                    storageKey = "\(escapedMemberName)[\(type)]"
                } else if isStatic {
                    storageKey = "static \(escapedMemberName)"
                } else {
                    storageKey = escapedMemberName
                }
                let isExternal = getTopLevelModule(for: node) != primaryTargetModule
                let symbolModule = extensionModule ?? Parser.getMangledModule(mangled) ?? currentModule
                if let constraints = constraints {
                    if symbolModule == primaryTargetModule {
                        node.constrainedExtensions[constraints, default: [:]][storageKey] = .property(name: escapedMemberName, type: type, isReadOnly: isReadOnly, isStatic: isStatic)
                    }
                } else if mangled.contains("PAAE") || mangled.contains("PA") && mangled.contains("rlE") || isExternal {
                    if symbolModule == primaryTargetModule {
                        node.extensionMembers[storageKey] = .property(name: escapedMemberName, type: type, isReadOnly: isReadOnly, isStatic: isStatic)
                    } else if ownTbdSymbols.contains(mangled) && extensionModule == nil {
                        node.originallyDefinedInExtensions[symbolModule, default: [:]][storageKey] = .property(name: escapedMemberName, type: type, isReadOnly: isReadOnly, isStatic: isStatic)
                    }
                } else {
                    node.members[storageKey] = .property(name: escapedMemberName, type: type, isReadOnly: isReadOnly, isStatic: isStatic)
                }
                // "property descriptor for ..." symbols (mangled suffix "pMV") carry the
                // property's key-path metadata, not a dispatch entry — they NEVER have a
                // corresponding "Tj" dispatch-thunk variant, even for a genuinely non-final
                // class property whose real getter/setter/modify accessors DO have one. Since
                // `finalMembers` is only ever added to (never removed from) across every
                // symbol naming this same property, letting the descriptor symbol run this
                // check would unconditionally mark the property final — poisoning it even when
                // every accessor symbol correctly determined otherwise. Confirmed via a live
                // trace on ModelCatalog's CoreMLRankingModelBundle.Builder.rankingModel: vg/vs/vM
                // (getter/setter/modify) all correctly saw hasTj=true (their own dispatch thunks
                // exist), but vpMV (the descriptor) saw hasTj=false and forced `final` anyway.
                if !originalMangled.hasSuffix("pMV") && !tbdSymbols.contains(mangled + "Tj") {
                    node.finalMembers.insert(storageKey)
                }
            }
            return
        }

        if !cleanD.contains("(") && !cleanD.contains(":") {
            let typeNameRaw = cleanType(cleanD.trimmingCharacters(in: .whitespaces))
            if typeNameRaw.isEmpty || typeNameRaw.contains(" ") || typeNameRaw.contains(":") { return }
            
            let typeName = typeNameRaw
            if let lastPart = typeName.components(separatedBy: ".").last, 
               let firstChar = lastPart.first, firstChar.isLowercase {
                if typeName.contains(".") { return }
            }

            let node = findOrCreateType(name: typeName)
            if let k = forcedKind { setKind(k, for: node, force: true) }
            
            if mangled.hasSuffix("VMn") { setKind("struct", for: node, force: true) }
            else if mangled.hasSuffix("CMn") { setKind("class", for: node, force: true) }
            else if mangled.hasSuffix("OMn") { setKind("enum", for: node, force: true) }
            else if mangled.hasSuffix("Mp") { setKind("protocol", for: node, force: true) }
            else if node.kind == "unknown" || node.kind == "struct" {
                if mangled.hasSuffix("V") { setKind("struct", for: node) }
                else if mangled.hasSuffix("C") { setKind("class", for: node) }
                else if mangled.hasSuffix("O") { setKind("enum", for: node) }
                else if mangled.hasSuffix("P") { setKind("protocol", for: node) }
            }
            
            if node.kind != "protocol" && node.kind != "class" {
                // Don't insert Hashable/Codable/Sendable here directly — this "nominal type
                // descriptor for X" symbol exists for EVERY struct/enum, including ones with
                // real, different (or zero) conformances (e.g. TipKit.TipView only conforms to
                // SwiftUI.View), so unconditionally injecting these produced conformances the
                // real ABI never had. Only mark the node as a candidate; a deferred pass after
                // all symbols are parsed applies the fallback ONLY if the node still has no
                // conformances of its own by then (see needsDefaultConformanceFallback below).
                needsDefaultConformanceFallback[ObjectIdentifier(node)] = node
            }
            return
        }
    }

    private func findOrCreateType(name: String) -> TypeNode {
        if name.contains("<") { fputs("findOrCreateType with <: \(name)\n", stderr) }
        var parts = name.components(separatedBy: ".")
        // Members of a type like "Publisher" that discoverNominalTypes recognized as declared
        // inside a "(extension in <defaultModule>)" on some other module's type (e.g.
        // Swift.Optional, or TokenGeneration.Prompt) route here as
        // "<Module>.<Type>.Publisher.<member>" — redirect to the same disambiguated internal
        // node name discoverNominalTypes registered the extension declaration under (see
        // stdlibTypeExtensions), so the type's members land on that same node.
        if parts.count >= 3 {
            let nestedPath = parts.dropFirst(2).joined(separator: ".")
            let candidateInternalName = "__StdlibExt_\(parts[0])_\(parts[1])_" + nestedPath
            if stdlibTypeExtensions[candidateInternalName] != nil {
                parts = [defaultModule, candidateInternalName]
            }
        }
        if parts[0] == "__C" && parts.count > 1 {
            if let defaultMod = modules[defaultModule] {
                var current = defaultMod
                var found = true
                for part in parts.dropFirst() {
                    if let nextNode = current.nestedTypes[part] {
                        current = nextNode
                    } else {
                        found = false
                        break
                    }
                }
                if found {
                    parts[0] = defaultModule
                }
            }
        }

        var isTopLevel = isModuleAvailable(parts[0]) || parts[0] == "__C" || parts[0] == defaultModule || modules[parts[0]] != nil
        if isTopLevel && parts[0] != defaultModule && parts[0] != "__C" {
            if modules[defaultModule]?.nestedTypes[parts[0]] != nil {
                isTopLevel = false
            }
        }
        if !isTopLevel {
            parts.insert(defaultModule, at: 0)
        }
        
        if parts[0] != defaultModule && parts[0] != "Swift" && parts[0] != "__C" && isModuleAvailable(parts[0]) {
            referencedModules.insert(parts[0])
        }
        
        let moduleName = parts[0]
        
        // Skip creating nodes for generic placeholders
        if let last = parts.last, Parser.isGenericPlaceholder(last) {
            let current = TypeNode(name: name)
            return current
        }



        if modules[moduleName] == nil {
            modules[moduleName] = TypeNode(name: moduleName)
        }
        
        var current = modules[moduleName]!
        for part in parts.dropFirst() {
            if current.nestedTypes[part] == nil {
                let newNode = TypeNode(name: part)
                newNode.parent = current
                current.nestedTypes[part] = newNode
            }
            current = current.nestedTypes[part]!
        }
        return current
    }

    func getTopLevelModule(for node: TypeNode) -> String {
        var current = node
        while let p = current.parent {
            current = p
        }
        return current.name
    }

    private func splitPath(_ path: String) -> (String, String) {
        var depth = 0
        var idx = path.endIndex
        while idx > path.startIndex {
            idx = path.index(before: idx)
            let ch = path[idx]
            if ch == ">" { depth += 1 }
            else if ch == "<" { depth -= 1 }
            else if ch == "." && depth == 0 {
                if idx > path.startIndex {
                    let prevIdx = path.index(before: idx)
                    if path[prevIdx] == "." {
                        let memberName = String(path[idx...])
                        let typeName = String(path[..<prevIdx])
                        return (typeName, memberName)
                    }
                }
                let memberName = String(path[path.index(after: idx)...])
                let typeName = String(path[..<idx])
                return (typeName, memberName)
            }
        }
        return (defaultModule, path)
    }

    private func cleanType(_ name: String) -> String {
        var n = name.stripGenericAngles().stripLongNumbers()
        
        n = n.replacingOccurrences(of: "\\(extension in [^)]+\\):", with: "", options: .regularExpression)
        
        if n.hasSuffix(".Array") && n != "Swift.Array" && !n.hasPrefix("Swift.") { n = n.replacingOccurrences(of: ".Array", with: ".JSONArray") }
        if n.hasSuffix(".Dictionary") && n != "Swift.Dictionary" && !n.hasPrefix("Swift.") { n = n.replacingOccurrences(of: ".Dictionary", with: ".JSONDictionary") }
        if n.hasSuffix(".Object") && n != "Swift.Object" && !n.hasPrefix("Swift.") { n = n.replacingOccurrences(of: ".Object", with: ".JSONObject") }
        if n.hasSuffix(".String") && n.contains("JSONSchema") && n != "Swift.String" && !n.hasPrefix("Swift.") { n = n.replacingOccurrences(of: ".String", with: ".JSONString") }

        return n
    }

    static func isGenericPlaceholder(_ s: String) -> Bool {
        if s.hasPrefix("Generic") { return true }
        if s.count == 1 {
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            return placeholders.contains(s)
        }
        if s.count > 1 {
            let first = String(s.first!)
            let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
            if placeholders.contains(first) {
                let suffix = s.dropFirst()
                return suffix.allSatisfy { $0.isNumber }
            }
        }
        return false
    }

    static func fixInlineArrayValGenerics(_ input: String) -> String {
        var result = input
        var searchStart = result.startIndex
        while let range = result[searchStart...].range(of: "InlineArray<") {
            let startIdx = range.upperBound
            var depth = 1
            var commaIdx: String.Index? = nil
            var scanIdx = startIdx
            while scanIdx < result.endIndex {
                let char = result[scanIdx]
                if char == "<" {
                    depth += 1
                } else if char == ">" {
                    depth -= 1
                    if depth == 0 {
                        break
                    }
                } else if char == "," && depth == 1 {
                    commaIdx = scanIdx
                }
                scanIdx = result.index(after: scanIdx)
            }
            
            if depth == 0, let comma = commaIdx {
                let firstArg = result[startIdx..<comma].trimmingCharacters(in: .whitespaces)
                let secondArgStart = result.index(after: comma)
                let secondArg = result[secondArgStart..<scanIdx].trimmingCharacters(in: .whitespaces)
                if secondArg == "Int" || secondArg == "Swift.Int" {
                    if Parser.isGenericPlaceholder(firstArg) {
                        searchStart = scanIdx
                        continue
                    }
                    result.replaceSubrange(startIdx..<scanIdx, with: "1, \(firstArg)")
                    let newLen = 3 + firstArg.count
                    searchStart = result.index(startIdx, offsetBy: newLen + 1, limitedBy: result.endIndex) ?? result.endIndex
                    continue
                }
            }
            searchStart = scanIdx
        }
        return result
    }

    func isNestedTypeName(_ name: String, in node: TypeNode) -> Bool {
        if node.name == name { return true }
        for child in node.nestedTypes.values {
            if isNestedTypeName(name, in: child) { return true }
        }
        return false
    }
    
    func isTypeDefinedInFramework(_ name: String) -> Bool {
        guard let moduleNode = modules[defaultModule] else { return false }
        for child in moduleNode.nestedTypes.values {
            if isNestedTypeName(name, in: child) { return true }
        }
        return false
    }

    func simplifyType(_ type: String, parentName: String? = nil, isMethodSignature: Bool = false, memberName: String? = nil) -> String {
        var t = Parser.fixInlineArrayValGenerics(type)
        if isMethodSignature && memberName == "baseUnit" {
            if let range = t.range(of: "->") {
                t = String(t[..<range.lowerBound]) + "-> Self"
            }
        }
        t = t.replacingOccurrences(of: "CVBufferRef", with: "CVBuffer")
        t = t.replacingOccurrences(of: "CMSampleBufferRef", with: "CMSampleBuffer")
        // Demangled text carries this as "__C.NSInputStream"/"__C.NSOutputStream" (the __C.
        // qualifier is stripped later in this function, further down), so this rename must
        // tolerate a preceding dot to actually match.
        t = t.replaceWord("NSInputStream", with: "InputStream", allowPrecededByDot: true)
        t = t.replaceWord("NSOutputStream", with: "OutputStream", allowPrecededByDot: true)
        t = t.replaceWord("Decoder", with: "Swift.Decoder", allowPrecededByDot: false)
        t = t.replaceWord("Encoder", with: "Swift.Encoder", allowPrecededByDot: false)
        t = t.replaceWord("FormatStyle", with: "Foundation.FormatStyle", allowPrecededByDot: false)
        t = t.replaceWord("Slice", with: "Swift.Slice", allowPrecededByDot: false)
        t = t.replacingOccurrences(of: "any (Swift\\.)?AsyncSequence<[^>]+>", with: "any AsyncSequence", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\(extension in [^)]+\\):", with: "", options: .regularExpression)
        
        // Simplify protocol-qualified associated type paths from the demangler
        // (e.g. A.Swift.BinaryFloatingPoint.RawSignificand -> A.RawSignificand)
        let protoPattern = "(?:BinaryFloatingPoint|RawRepresentable|Collection|Publisher|Subscriber|Sequence|RangeExpression|Scheduler|MLTensorScalar|MLTensorRangeExpression|MutableCollection|RandomAccessCollection|BidirectionalCollection|Numeric|Equatable|Hashable|Comparable|Identifiable|Codable|Decodable|Encodable|Sendable|Error)"
        t = t.replacingOccurrences(
            of: "\\b(Self|[A-Z][0-9]?)((?:\\.[A-Za-z0-9_]+)*)\\.\(protoPattern)\\.([A-Za-z0-9_]+)\\b",
            with: "$1$2.$3",
            options: .regularExpression
        )

        // For each discovered protocol, add 'any' prefix when used as an existential type.
        // Track which ones are "ambiguous" (also have a concrete type with the same short name)
        // so we can preserve their module prefix to avoid Swift shadowing inside nested type bodies.
        var ambiguousAnyPlaceholders: [(placeholder: String, fullQualified: String)] = []
        let words = discoveredProtocols.filter { t.contains($0) }.sorted(by: { $0.count > $1.count })
        for p in words {
             let shortName = p.components(separatedBy: ".").last ?? p
             let isAmbiguous = discoveredConcreteTypes.contains(shortName)
             if isAmbiguous {
                 // Replace with a placeholder that won't be touched by module stripping.
                 // Restore with FULLY QUALIFIED 'any ModuleName.ProtocolName' after stripping
                 // to bypass Swift name shadowing inside nested type bodies.
                 // E.g., in Catalog.Resource.AppleDeviceTracking's body, bare 'AppleDeviceTracking'
                 // shadows the protocol, so we need 'any ModelCatalog.AppleDeviceTracking'.
                  let placeholder = "___ANY_PROTO_\(shortName)___"
                  t = t.replaceWord(p, with: placeholder, allowPrecededByDot: false)
                  // p is the fully qualified name (e.g., ModelCatalog.AppleDeviceTracking)
                  let fullQualified: String
                  if !defaultModule.isEmpty && p.hasPrefix(defaultModule + ".") {
                      let suffix = p.dropFirst(defaultModule.count)
                      fullQualified = "any ___SHIELDED_\(defaultModule)___\(suffix)"
                  } else {
                      fullQualified = "any \(p)"
                  }
                  ambiguousAnyPlaceholders.append((placeholder: placeholder, fullQualified: fullQualified))
             } else {
                 t = t.replaceWord(p, with: "any \(p)", allowPrecededByDot: false)
             }
        }
        
        if t.contains("<") || t.contains("[") {
            t = t.stripGenericFromSequence()
            t = t.stripModuleBeforeSubscriptOrGeneric()
        }
        
        // Strip available module prefixes from the type name
        let chars = Array(t)
        let n = chars.count
        var idx = 0
        var scannedWords = Set<String>()
        while idx < n {
            if chars[idx].isLetter || chars[idx] == "_" {
                let start = idx
                while idx < n && (chars[idx].isLetter || chars[idx].isNumber || chars[idx] == "_") {
                    idx += 1
                }
                let word = String(chars[start..<idx])
                if idx < n && chars[idx] == "." {
                    if idx + 1 < n && chars[idx+1].isLetter {
                        if start == 0 || chars[start-1] != "." {
                            scannedWords.insert(word)
                        }
                    }
                }
            } else {
                idx += 1
            }
        }
        for word in scannedWords {
            if word == "__C" {
                // Real bridged ObjC types are conventionally UpperCamelCase and become directly
                // visible once the "__C." qualifier is stripped (e.g. "__C.CMTime" -> "CMTime").
                // A lowercase/snake_case name after "__C." (e.g. "__C.ccec_cp") is a private C
                // struct/typedef with no Swift-visible declaration at all — stripping the prefix
                // there just produces an unresolvable bare name ("cannot find type 'ccec_cp' in
                // scope"). Leave "__C." in place for those so removePrivateObjCTypeReferences
                // (postProcess) can recognize and drop the whole member instead.
                var result = t
                var startSearch = result.startIndex
                let target = "__C."
                while let range = result.range(of: target, range: startSearch..<result.endIndex) {
                    let isWordCharBefore: Bool
                    if range.lowerBound > result.startIndex {
                        let prevChar = result[result.index(before: range.lowerBound)]
                        isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
                    } else {
                        isWordCharBefore = false
                    }
                    let followedByLowercase = range.upperBound < result.endIndex && result[range.upperBound].isLowercase
                    if !isWordCharBefore && !followedByLowercase {
                        result.replaceSubrange(range, with: "")
                        startSearch = range.lowerBound
                    } else {
                        startSearch = range.upperBound
                    }
                }
                t = result
            } else if word != "Swift" && word != defaultModule && isModuleAvailable(word) {
                let isLocalType = modules[defaultModule]?.nestedTypes[word] != nil
                if !isLocalType {
                    let systemModules: Set<String> = [
                        "Swift", "Foundation", "ObjectiveC", "os", "Dispatch", "Metal", "CoreGraphics",
                        "CoreVideo", "CoreMedia", "IOSurface", "UniformTypeIdentifiers", "XPC", "Synchronization",
                        "MetricKit", "Combine"
                    ]
                    if !systemModules.contains(word) {
                        referencedModules.insert(word)
                    } else {
                        var shouldStrip = true
                        let dotTarget = word + "."
                        if t.contains(dotTarget) {
                            var startSearch = t.startIndex
                            while let range = t.range(of: dotTarget, range: startSearch..<t.endIndex) {
                                let afterDot = range.upperBound
                                var endIdx = afterDot
                                while endIdx < t.endIndex && (t[endIdx].isLetter || t[endIdx].isNumber || t[endIdx] == "_") {
                                    endIdx = t.index(after: endIdx)
                                }
                                let qualifiedType = String(t[afterDot..<endIdx])
                                if ["FormatStyle", "Slice", "Decoder", "Encoder"].contains(qualifiedType) {
                                    shouldStrip = false
                                    break
                                }
                                if !qualifiedType.isEmpty && isTypeDefinedInFramework(qualifiedType) {
                                    shouldStrip = false
                                    break
                                }
                                startSearch = range.upperBound
                            }
                        }
                        if shouldStrip {
                            t = t.replaceWordDot(word, with: "")
                        }
                        referencedModules.insert(word)
                    }
                }
            }
        }
        
        if t.contains("OS_dispatch_queue") {
            t = t.replacingOccurrences(of: "OS_dispatch_queue", with: "DispatchQueue")
        }
        if t.contains("NSOperatingSystemVersion") {
            t = t.replacingOccurrences(of: "NSOperatingSystemVersion", with: "OperatingSystemVersion")
        }

        t = t.stripLongNumbers()
        t = t.stripNumbersAfterParen()

        var frameworks = Array(discoveredNamespaces)
        if !frameworks.contains(defaultModule) && !defaultModule.isEmpty {
            frameworks.append(defaultModule)
        }
        for mod in frameworks {
             if t.contains(mod) {
                  if mod == defaultModule {
                      t = t.replaceWordDot(mod, with: "")
                  } else if isModuleAvailable(mod) {
                      // Keep the qualified module name prefix for available modules
                  } else {
                      t = t.replaceWordDot(mod, with: "\(mod)_")
                  }
             }
        }
        
        // Restore ambiguous any-protocol placeholders with FULLY QUALIFIED form (e.g., any ModelCatalog.X)
        // This is necessary for protocols that share a short name with a nested concrete type.
        // E.g., ModelCatalog.AppleDeviceTracking (protocol) vs Catalog.Resource.AppleDeviceTracking (struct):
        // inside Catalog.Resource.AppleDeviceTracking's body, bare 'AppleDeviceTracking' resolves to
        // the concrete struct, so we use 'any ModelCatalog.AppleDeviceTracking' for disambiguation.
        for (placeholder, fullQualified) in ambiguousAnyPlaceholders {
            t = t.replacingOccurrences(of: placeholder, with: fullQualified)
        }
        
        if t.contains(".") {
            // Shield Swift standard types from JSON conversion
            t = t.replacingOccurrences(of: "Swift.String", with: "___SWIFT_SHIELDED_String___")
            t = t.replacingOccurrences(of: "Swift.Dictionary", with: "___SWIFT_SHIELDED_Dictionary___")
            t = t.replacingOccurrences(of: "Swift.Array", with: "___SWIFT_SHIELDED_Array___")
            t = t.replacingOccurrences(of: "Swift.Object", with: "___SWIFT_SHIELDED_Object___")
            
            t = t.replaceDotWord(word: "Array", replacement: ".JSONArray")
            t = t.replaceDotWord(word: "Dictionary", replacement: ".JSONDictionary")
            t = t.replaceDotWord(word: "Object", replacement: ".JSONObject")
            t = t.replaceDotWord(word: "String", replacement: ".JSONString")
            
            t = t.replacingOccurrences(of: "___SWIFT_SHIELDED_String___", with: "Swift.String")
            t = t.replacingOccurrences(of: "___SWIFT_SHIELDED_Dictionary___", with: "Swift.Dictionary")
            t = t.replacingOccurrences(of: "___SWIFT_SHIELDED_Array___", with: "Swift.Array")
            t = t.replacingOccurrences(of: "___SWIFT_SHIELDED_Object___", with: "Swift.Object")
        }

        var prevT = ""
        while prevT != t {
            prevT = t
            t = t.replacingOccurrences(of: "any any ", with: "any ")
        }

        if t.contains("Optional") {
            t = t.replacingOccurrences(of: "Optional<", with: "___OPT_T___")
            t = t.replaceWordWithoutGeneric("Optional", with: "Optional<Any>")
            t = t.replacingOccurrences(of: "___OPT_T___", with: "Optional<")
        }

        if t.contains("Dictionary") {
            t = t.replaceWordWithoutGeneric("Dictionary", with: "[AnyHashable: Any]")
        }
        if t.contains("Array") {
            t = t.replaceWordWithoutGeneric("Array", with: "[Any]")
        }
        
        while prevT != t {
            prevT = t
            t = t.stripModuleBeforeSubscriptOrGeneric()
            t = t.stripModuleBeforeAngle()
        }
        t = t.replacingOccurrences(of: ".[", with: "[")

        if t.contains("async") {
            t = t.replacingOccurrences(of: "(async throws)", with: "async throws")
            t = t.replacingOccurrences(of: "(async)", with: "async")
        }
        if t.contains("throws") {
            t = t.replacingOccurrences(of: "(throws)", with: "throws")
        }
        
        if t.contains("extension") {
            t = t.stripExtensionInParens()
            t = t.replaceExtensionParensWithAny()
        }
        if t.contains("==") {
            t = t.replacingOccurrences(of: "== String>", with: ">")
            // Constrained existentials against a primary-associated-type protocol (e.g. "any
            // Source<Self.Stream == A>", from IntelligencePlatformLibrary.Source<Stream>) carry
            // real information in "Self.<assoc> == A" — it says the existential's primary
            // associated type equals the enclosing generic param A, so it reconstructs validly
            // as "Source<A>". Stripping straight to "== A>" -> ">" (as used to happen) throws
            // that away, leaving main.swift's postProcess erasure with nothing to reconstruct
            // "Source<A>" from, so it always fell back to "Source<Any>" (compiles, but mismatches
            // the real ABI symbol -> assembly stub). Replace the whole "Self.<assoc> == A>" span
            // (not just "== A>") with a marker main.swift's postProcess resolves to "A>", since
            // leaving "Self.<assoc> " in front of the marker would produce invalid syntax.
            let (replaced, foundAssocNames) = t.replaceSelfAssociatedTypeSameTypeAWithMarker()
            t = replaced
            for (proto, assocName) in foundAssocNames {
                primaryAssociatedTypeNames[proto] = assocName
            }
            // A constrained existential whose same-type RHS is a CONCRETE type (e.g. "any
            // Swift.Sequence<Self.Swift.Sequence.Element == Swift.Int>", from
            // ContiguousBitSet.init(_:)) isn't handled by the marker replacement above (which
            // only fires for the placeholder "A") — reconstruct it as primary-associated-type
            // sugar ("any Swift.Sequence<Swift.Int>") before stripConstrainedExistentialGenerics
            // (main.swift postProcess) would otherwise erase the whole clause.
            t = t.replaceConcretePrimaryAssociatedTypeConstraint()
        }
        if t.contains("some") {
            // `some` opaque-return types demangle with no reconstructable underlying-protocol
            // info, so this can only ever be a heuristic fallback. `body`/`makeBody` are the
            // SwiftUI View-protocol requirement names (View.body, ViewModifier/ViewStyle-family
            // .makeBody(configuration:)) — using the generic `Sendable` fallback there produces
            // a type that satisfies Sendable but not the actual `Body: View` associated-type
            // bound the conforming type is required to satisfy.
            let shortMemberName = memberName?.components(separatedBy: "(").first
            let replacement = (shortMemberName == "body" || shortMemberName == "makeBody") ? "some SwiftUI.View" : "some Sendable"
            t = t.replaceWord("some", with: replacement)
        }
        
        if t.contains("set {") {
            t = String(t.components(separatedBy: "set {").first!).trimmingCharacters(in: .whitespaces)
        }
        // Find the first `{` that is NOT inside a `<...>` generic clause.
        // `Pack{A}` is a parameter pack type where `{A}` is inside `<Pack{A}>` —
        // truncating there would corrupt the signature.
        var braceOutsideGeneric: String.Index? = nil
        var angleDepth = 0
        for idx in t.indices {
            switch t[idx] {
            case "<": angleDepth += 1
            case ">": if angleDepth > 0 { angleDepth -= 1 }
            case "{": if angleDepth == 0 { braceOutsideGeneric = idx; break }
            default: break
            }
            if braceOutsideGeneric != nil { break }
        }
        if let brace = braceOutsideGeneric {
            t = String(t[..<brace]).trimmingCharacters(in: .whitespaces)
        }
        // Remove `}` that are NOT inside `<...>` generics (e.g. stray braces from body fragments).
        // `Pack{A}` braces inside `<...>` must be preserved for the Pack-fix regex in postProcess.
        var cleaned = ""
        var adepth = 0
        for ch in t {
            switch ch {
            case "<": adepth += 1; cleaned.append(ch)
            case ">": if adepth > 0 { adepth -= 1 }; cleaned.append(ch)
            case "}": if adepth > 0 { cleaned.append(ch) } // inside <...>: keep; outside: drop
            default: cleaned.append(ch)
            }
        }
        t = cleaned

        if t.contains("& any ") {
            t = t.replacingOccurrences(of: "& any ", with: "& ")
        }

        // Parenthesize optional existentials: 'any Protocol?' -> '(any Protocol)?'
        if t.contains("any ") {
            t = t.replacingOccurrences(
                of: #"any\s+([a-zA-Z0-9_.]+)([\?!])"#,
                with: "(any $1)$2",
                options: .regularExpression
            )
        }

        if isMethodSignature {
            return stripLabelsFromMethodSignature(t)
        } else {
            let stripped = stripFunctionTypeLabels(t)
            return Parser.escapeClosures(in: stripped, isTopLevelParameter: false)
        }
    }

    static func fixUnnamedParameters(_ sig: String, isSubscript: Bool = false, escapingMap: [Int: Bool]? = nil, defaultArgs: Set<Int>? = nil) -> String {
        guard let openParen = sig.firstIndex(of: "(") else { return sig }
        let prefix = sig[..<sig.index(after: openParen)]
        let rest = String(sig[sig.index(after: openParen)...])
        
        var depth = 0
        var matchingIndex: String.Index? = nil
        for (idx, char) in rest.enumerated() {
            if char == "(" { depth += 1 }
            else if char == ")" {
                if depth == 0 {
                    matchingIndex = rest.index(rest.startIndex, offsetBy: idx)
                    break
                }
                depth -= 1
            }
        }
        guard let closeParen = matchingIndex else { return sig }
        
        let paramsPart = rest[..<closeParen]
        let suffix = rest[closeParen...]
        
        var paramList = [String]()
        var current = ""
        var pDepth = 0
        var aDepth = 0
        var sDepth = 0
        
        let chars = Array(paramsPart)
        var idx = 0
        while idx < chars.count {
            let c = chars[idx]
            if c == "(" { pDepth += 1 }
            else if c == ")" { pDepth -= 1 }
            else if c == "[" { sDepth += 1 }
            else if c == "]" { sDepth -= 1 }
            else if c == "<" { aDepth += 1 }
            else if c == ">" {
                if idx > 0 && chars[idx - 1] == "-" {
                    // Ignore ->
                } else {
                    aDepth -= 1
                }
            }
            
            if c == "," && pDepth == 0 && aDepth == 0 && sDepth == 0 {
                paramList.append(current)
                current = ""
            } else {
                current.append(c)
            }
            idx += 1
        }
        paramList.append(current)

        var newParams = [String]()
        var unnamedCount = 1
        for (paramIndex, p) in paramList.enumerated() {
            let trimmed = p.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            var hasLabel = false
            var depth_p = 0
            var depth_a = 0
            var depth_s = 0
            var colonIdx: String.Index? = nil
            for (index, char) in trimmed.enumerated() {
                if char == "(" { depth_p += 1 }
                else if char == ")" { depth_p -= 1 }
                else if char == "<" { depth_a += 1 }
                else if char == ">" { depth_a -= 1 }
                else if char == "[" { depth_s += 1 }
                else if char == "]" { depth_s -= 1 }
                else if char == ":" && depth_p == 0 && depth_a == 0 && depth_s == 0 {
                    hasLabel = true
                    colonIdx = trimmed.index(trimmed.startIndex, offsetBy: index)
                    break
                }
            }

            var labelPart = ""
            var typePart = trimmed
            var labelName = ""
            if hasLabel, let cIdx = colonIdx {
                labelName = String(trimmed[..<cIdx]).trimmingCharacters(in: .whitespaces)
                labelPart = labelName + ": "
                typePart = String(trimmed[trimmed.index(after: cIdx)...]).trimmingCharacters(in: .whitespaces)
            }

            let isEsc = escapingMap?[paramIndex] ?? true
            var escapedType = Parser.escapeClosures(in: typePart, isTopLevelParameter: true, isEscaping: isEsc)
            
            let cleanType = escapedType.trimmingCharacters(in: .whitespaces)
            let isSpanType = cleanType.contains("Span") && !cleanType.contains("SpanContext")
            let isNoncopyableType = isSpanType || cleanType.contains("Executable") || cleanType.contains("PixelBuffer")
            let hasOwnership = cleanType.hasPrefix("borrowing ") || cleanType.hasPrefix("consuming ") || cleanType.hasPrefix("inout ") || cleanType.hasPrefix("__shared ") || cleanType.hasPrefix("__owned ")
            if isNoncopyableType && !hasOwnership {
                escapedType = "borrowing " + escapedType
            }

            if isSubscript {
                if hasLabel && labelName != "_" {
                    newParams.append("\(labelName) arg\(unnamedCount): \(escapedType)")
                } else {
                    newParams.append("_ arg\(unnamedCount): \(escapedType)")
                }
                unnamedCount += 1
            } else {
                if !hasLabel && trimmed != "()" {
                    newParams.append("_ arg\(unnamedCount): " + escapedType)
                    unnamedCount += 1
                } else {
                    newParams.append(labelPart + escapedType)
                }
            }
        }
        return String(prefix) + newParams.joined(separator: ", ") + String(suffix)
    }
    
    func isModuleAvailable(_ name: String) -> Bool {
        if name == "OS" { return false }
        if ["Swift", "Foundation", "ObjectiveC"].contains(name) { return true }
        let sdkRoot = ConfigManager.sdkRoot
        
        // 1. Check if name is in usr/lib/swift (standard library modules)
        let swiftLibPaths = [
            "\(sdkRoot)/usr/lib/swift/\(name).swiftmodule",
            "\(sdkRoot)/usr/lib/swift/libswift\(name).tbd"
        ]
        for path in swiftLibPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // 2. Check if name is a framework with a Modules directory containing a swiftmodule or modulemap
        let frameworkPaths = [
            "\(sdkRoot)/System/Library/Frameworks/\(name).framework",
            "\(sdkRoot)/System/Library/PrivateFrameworks/\(name).framework",
            "\(sdkRoot)/System/Library/SubFrameworks/\(name).framework",
            "LocalFrameworks/\(name).framework"
        ]
        for fwPath in frameworkPaths {
            let modulesPath = "\(fwPath)/Modules"
            let tbdPath = "\(fwPath)/\(name).tbd"
            let tbdPathA = "\(fwPath)/Versions/A/\(name).tbd"
            let tbdPathCurrent = "\(fwPath)/Versions/Current/\(name).tbd"
            if FileManager.default.fileExists(atPath: modulesPath) ||
               FileManager.default.fileExists(atPath: tbdPath) ||
               FileManager.default.fileExists(atPath: tbdPathA) ||
               FileManager.default.fileExists(atPath: tbdPathCurrent) {
                return true
            }
        }
        
        // 3. Built-in system modules
        let system = ["Swift", "Foundation", "CoreFoundation", "UniformTypeIdentifiers", "os", "ObjectiveC", "CoreVideo", "CoreMedia", "IOSurface", "__C"]
        if system.contains(name) {
            return true
        }
        
        return false
    }

    func genericParamsString(for node: TypeNode) -> String {
        if !node.isGeneric { return "" }
        var count = 1
        let fullPath1 = defaultModule + "." + node.name
        let fullPath2 = node.name
        if let inferredCount = discoveredGenerics[fullPath1] {
            count = inferredCount
        } else if let inferredCount = discoveredGenerics[fullPath2] {
            count = inferredCount
        }
        let placeholders = ["A", "B", "C", "D", "E", "F", "G"]
        var params = [String]()
        for i in 0..<count {
            if i < placeholders.count {
                params.append(placeholders[i])
            } else {
                params.append("A\(i)")
            }
        }
        return "<\(params.joined(separator: ", "))>"
    }
    
    private func getFrameworkInterfaceContent(module: String) -> String {
        if let cached = frameworkInterfaceCache[module] {
            return cached
        }
        var mergedContent = ""
        let sdkRoot = ConfigManager.sdkRoot
        let searchDirs = [
            "\(sdkRoot)/System/Library/Frameworks/\(module).framework/Modules/\(module).swiftmodule",
            "\(sdkRoot)/System/Library/PrivateFrameworks/\(module).framework/Modules/\(module).swiftmodule",
            "\(sdkRoot)/System/Library/SubFrameworks/\(module).framework/Modules/\(module).swiftmodule",
            "LocalFrameworks/\(module).framework/Modules/\(module).swiftmodule"
        ]
        
        for dir in searchDirs {
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir) else { continue }
            for file in files {
                if file.hasSuffix(".swiftinterface") {
                    let path = "\(dir)/\(file)"
                    if let content = try? String(contentsOfFile: path, encoding: .utf8) {
                        mergedContent += content + "\n"
                    }
                }
            }
        }
        frameworkInterfaceCache[module] = mergedContent
        return mergedContent
    }

    func getFrameworkDefinedTypes(module: String) -> Set<String> {
        if let cached = frameworkDefinedTypesCache[module] {
            return cached
        }
        let content = getFrameworkInterfaceContent(module: module)
        let defined = content.scanFrameworkDefinedTypes()
        frameworkDefinedTypesCache[module] = defined
        return defined
    }

    func isTypeDefinedInFramework(module: String, typeName: String) -> Bool {
        if module == "Swift" || module == "__C" {
            return systemTypes.contains(typeName)
        }
        let systemModules: Set<String> = [
            "Swift", "Foundation", "ObjectiveC", "Dispatch", 
            "Metal", "IOSurface", "CoreGraphics", "CoreVideo", 
            "CoreMedia", "CoreImage", "CoreML", "UniformTypeIdentifiers"
        ]
        if systemModules.contains(module) {
            return true
        }
        return getFrameworkDefinedTypes(module: module).contains(typeName)
    }

    func applyTypeFixups() {
        // Deferred Hashable/Codable/Sendable fallback: only apply to nodes that were seen via a
        // bare "nominal type descriptor for X" symbol AND still have zero real conformances
        // after all symbols were parsed. Applying this unconditionally at parse time (the old
        // behavior) injected these conformances onto every struct/enum regardless of its real
        // ABI conformances — e.g. TipKit.TipView only conforms to SwiftUI.View in reality, but
        // got Codable/Hashable/Sendable added anyway, producing invalid Decodable-conformance
        // codegen ("crosses into main actor-isolated code").
        for node in needsDefaultConformanceFallback.values {
            if node.conformances.isEmpty {
                node.conformances.insert("Hashable")
                node.conformances.insert("Codable")
                node.conformances.insert("Sendable")
            }
        }

        if defaultModule == "MetricKit" {
            if let node = modules["MetricKit"]?.nestedTypes["AveragePixelLuminance"] {
                node.baseClass = "Foundation.Dimension"
            }
            // HitchTimeRatio is a Foundation.Dimension subclass in the real module (per the
            // real .swiftinterface), same as AveragePixelLuminance/SignalBars — the ABI alone
            // (no NSObject-vs-Dimension distinction visible from symbols) makes the generator
            // default it to a plain NSObject/NSCoding subclass instead.
            if let node = modules["MetricKit"]?.nestedTypes["HitchTimeRatio"] {
                node.baseClass = "Foundation.Dimension"
            }
        }

        if defaultModule == "Network" {
            if let node = modules["Network"]?.nestedTypes["ActorSystemError"] {
                node.conformances.remove("Distributed.DistributedActorSystemError")
                node.conformances.remove("DistributedActorSystemError")
            }
        }

        if defaultModule == "CryptoKit" {
            // CorecryptoSupportedNISTCurve/CorecryptoSupportedMLKEMKEM are internal-only
            // conformances (present as ABI witness-table symbols in the TBD, but never declared
            // in the real public .swiftinterface) whose associated-type requirements (H,
            // curveType, publicKeyType, etc.) can't be satisfied from public API alone. Must be
            // removed here (before inheritProtocolMembers runs) rather than via a later
            // postProcess string replace on the declaration line — inheritProtocolMembers would
            // otherwise still copy the stripped protocol's own requirements (e.g.
            // `createPublicKey(...) -> Self.publicKeyType`) onto these types as real members.
            // These are demangled as "any CorecryptoSupportedNISTCurve"/"any
            // CorecryptoSupportedMLKEMKEM" (existential form), not the bare protocol name, so
            // filter by substring rather than exact Set.remove.
            for curveName in ["P256", "P384", "P521"] {
                if let node = modules["CryptoKit"]?.nestedTypes[curveName] {
                    node.conformances = node.conformances.filter { !$0.contains("CorecryptoSupportedNISTCurve") }
                }
            }
            for kemName in ["MLKEM1024", "MLKEM768"] {
                if let node = modules["CryptoKit"]?.nestedTypes[kemName] {
                    node.conformances = node.conformances.filter { !$0.contains("CorecryptoSupportedMLKEMKEM") }
                }
            }
        }

        if defaultModule == "ModelCatalog" {
            // Fix VisionModelBase
            if let node = modules["ModelCatalog"]?.nestedTypes["VisionModelBase"] {
                node.members["id"] = .property(name: "id", type: "String", isReadOnly: true, isStatic: false)
                node.members["inferenceProviders"] = .property(name: "inferenceProviders", type: "Set<InferenceProvider>", isReadOnly: true, isStatic: false)
                node.members["cost"] = .property(name: "cost", type: "CostProfile", isReadOnly: true, isStatic: false)
                node.members["executionContexts"] = .property(name: "executionContexts", type: "Set<ExecutionContext>", isReadOnly: false, isStatic: false)
            }
            // Fix VoicesOverridesBase
            if let node = modules["ModelCatalog"]?.nestedTypes["VoicesOverridesBase"] {
                node.members["id"] = .property(name: "id", type: "String", isReadOnly: true, isStatic: false)
                node.members["inferenceProviders"] = .property(name: "inferenceProviders", type: "Set<InferenceProvider>", isReadOnly: true, isStatic: false)
                node.members["cost"] = .property(name: "cost", type: "CostProfile", isReadOnly: true, isStatic: false)
                node.members["executionContexts"] = .property(name: "executionContexts", type: "Set<ExecutionContext>", isReadOnly: false, isStatic: false)
            }
            // Fix AssetBackedVoicesOverridesBase
            if let node = modules["ModelCatalog"]?.nestedTypes["AssetBackedVoicesOverridesBase"] {
                node.members["id"] = .property(name: "id", type: "String", isReadOnly: true, isStatic: false)
                node.members["inferenceProviders"] = .property(name: "inferenceProviders", type: "Set<InferenceProvider>", isReadOnly: true, isStatic: false)
                node.members["cost"] = .property(name: "cost", type: "CostProfile", isReadOnly: true, isStatic: false)
                node.members["executionContexts"] = .property(name: "executionContexts", type: "Set<ExecutionContext>", isReadOnly: false, isStatic: false)
            }
            // Fix XPCServiceClientConnection
            if let node = modules["ModelCatalog"]?.nestedTypes["XPCServiceClientConnection"] {
                node.members["typealias Service"] = .associatedType("public typealias Service = A")
                node.members["callAsyncSignature"] = .method(name: "call", signature: "call<GenericA>(_ arg1: (Any, (Optional<GenericA>, Optional<Error>) -> ()) -> ()) async throws -> GenericA", isStatic: false)
            }
            // Fix BidirectionalXPCServiceClientConnection
            if let node = modules["ModelCatalog"]?.nestedTypes["BidirectionalXPCServiceClientConnection"] {
                node.members["typealias LocalService"] = .associatedType("public typealias LocalService = A")
                node.members["typealias RemoteService"] = .associatedType("public typealias RemoteService = B")
            }
            // Fix CatalogService
            if let node = modules["ModelCatalog"]?.nestedTypes["CatalogService"] {
                node.members["typealias Interface"] = .associatedType("public typealias Interface = Any")
                node.members["customize"] = .method(name: "customize", signature: "customize(serverInterface: NSXPCInterface) -> ()", isStatic: true)
            }
            // Fix LLMAdapterBase
            if let node = modules["ModelCatalog"]?.nestedTypes["LLMAdapterBase"] {
                node.members["dependencies"] = .property(name: "dependencies", type: "Array<any ManagedResource>", isReadOnly: true, isStatic: false)
                node.members["runtimeInformation"] = .property(name: "runtimeInformation", type: "Array<ManagedRuntimeInformation>", isReadOnly: true, isStatic: false)
            }
            // Fix LLMModelBase
            if let node = modules["ModelCatalog"]?.nestedTypes["LLMModelBase"] {
                node.members["dependencies"] = .property(name: "dependencies", type: "Array<any ManagedResource>", isReadOnly: true, isStatic: false)
                node.members["runtimeInformation"] = .property(name: "runtimeInformation", type: "Array<ManagedRuntimeInformation>", isReadOnly: true, isStatic: false)
            }
        }
        
        // Auto-detect NSObject subclasses: any class with an init(coder: NSCoder) member is an
        // NSObject subclass conforming to NSCoding. Mark them so Model.swift emits the correct
        // `open class X: NSObject, NSCoding` declaration with `required init?(coder:)`.
        // This is essential because library-evolution mode only generates dispatch thunks (Tj)
        // for `open` classes, and NSCoding requires the `required` designation.
        func markNSObjectSubclasses(node: TypeNode) {
            if node.kind == "class" && node.baseClass == nil {
                let hasCoderInit = node.members.values.contains {
                    if case .initializer(let s) = $0, (s.contains("init(coder:") || s.contains("init?(coder:")) { return true }
                    return false
                }
                if hasCoderInit {
                    node.baseClass = "NSObject"
                    node.conformances.insert("NSCoding")
                    // Ensure the coder init uses the required init?(coder:) form
                    // Remove plain init(coder:) and let Model.swift emit the required form
                    let keysToRemove = node.members.keys.filter {
                        if case .initializer(let s) = node.members[$0]!, (s.contains("init(coder:") || s.contains("init?(coder:")) { return true }
                        return false
                    }
                    for k in keysToRemove { node.members.removeValue(forKey: k) }
                }
            }
            for nested in node.nestedTypes.values {
                markNSObjectSubclasses(node: nested)
            }
        }
        for module in modules.values {
            for type in module.nestedTypes.values {
                markNSObjectSubclasses(node: type)
            }
        }
        
        // Automatically inherit protocol members for conforming concrete types if they are missing
        func findTypeNode(byName name: String) -> TypeNode? {
            var cleanName = name.trimmingCharacters(in: .whitespaces)
            if cleanName.hasPrefix("any ") {
                cleanName = String(cleanName.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            } else if cleanName.hasPrefix("some ") {
                cleanName = String(cleanName.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            }
            let shortName = cleanName.components(separatedBy: ".").last ?? cleanName
            for module in modules.values {
                if let node = module.nestedTypes[shortName] {
                    return node
                }
            }
            return nil
        }

        func inheritProtocolMembers(node: TypeNode) {
            if node.kind == "struct" || node.kind == "enum" {
                for conf in node.conformances {
                    if let protoNode = findTypeNode(byName: conf), protoNode.kind == "protocol" {
                        for (memberKey, memberVal) in protoNode.members {
                            let nameToCheck: String
                            switch memberVal {
                            case .property(let n, _, _, _):
                                nameToCheck = n
                            case .method(let n, _, _):
                                nameToCheck = n
                            default:
                                continue
                            }
                            
                            var hasMember = false
                            for existingVal in node.members.values {
                                switch existingVal {
                                case .property(let n, _, _, _):
                                    if n == nameToCheck { hasMember = true }
                                case .method(let n, _, _):
                                    if n == nameToCheck { hasMember = true }
                                default:
                                    break
                                }
                            }
                            for existingVal in node.extensionMembers.values {
                                switch existingVal {
                                case .property(let n, _, _, _):
                                    if n == nameToCheck { hasMember = true }
                                case .method(let n, _, _):
                                    if n == nameToCheck { hasMember = true }
                                default:
                                    break
                                }
                            }
                            
                            if !hasMember && !node.satisfiedRequirementNames.contains(nameToCheck) {
                                // The demangler encodes a protocol requirement's implicit `Self`
                                // generic parameter as a bare placeholder ("A") when the
                                // protocol itself isn't generic (e.g. Charts.ChartContent's
                                // `_makeChartContent(content: _GraphValue<Self>, ...)` demangles
                                // with "Self" replaced by "A"). That's fine inside the protocol's
                                // own declaration (where "A" IS in scope, standing for Self), but
                                // copying the raw signature verbatim onto a non-generic
                                // conforming struct/enum leaves "A" referring to nothing.
                                // Scoped to Charts only: a blanket "any bare A means Self"
                                // substitution is unsound in general — some protocols
                                // legitimately use "A" as an associated-type placeholder in a
                                // requirement copied verbatim (e.g. ModelCatalog's
                                // AssetBackedResource.CatalogAssetType), and rewriting those to
                                // the conforming type's name breaks their real semantics.
                                var resolvedVal = memberVal
                                if defaultModule == "Charts" {
                                    let protoEnclosing = protoNode.getEnclosingPath()
                                    let protoRelativeName = protoEnclosing.isEmpty ? protoNode.name : protoEnclosing + "." + protoNode.name
                                    let protoIsGeneric = discoveredGenerics[defaultModule + "." + protoRelativeName] != nil || discoveredGenerics[protoRelativeName] != nil
                                    if !protoIsGeneric {
                                        let selfName = node.name
                                        switch memberVal {
                                        case .method(let n, let sig, let isStatic):
                                            resolvedVal = .method(name: n, signature: sig.replaceWord("A", with: selfName), isStatic: isStatic)
                                        case .property(let n, let t, let isReadOnly, let isStatic):
                                            resolvedVal = .property(name: n, type: t.replaceWord("A", with: selfName), isReadOnly: isReadOnly, isStatic: isStatic)
                                        default:
                                            break
                                        }
                                    }
                                }
                                node.members[memberKey] = resolvedVal
                            }
                        }
                    }
                }
            }
            for child in node.nestedTypes.values {
                inheritProtocolMembers(node: child)
            }
        }

        for module in modules.values {
            for type in module.nestedTypes.values {
                inheritProtocolMembers(node: type)
            }
        }

        // Automatically set OptionSet conforming types to struct
        func fixOptionSets(node: TypeNode) {
            if node.hasConformance("OptionSet") || node.hasConformance("SetAlgebra") {
                node.kind = "struct"
            }
            for nested in node.nestedTypes.values {
                fixOptionSets(node: nested)
            }
        }
        for module in modules.values {
            for type in module.nestedTypes.values {
                fixOptionSets(node: type)
            }
        }
    }

    // Marks node and its nested types isGeneric based on discoveredGenerics (populated by
    // precompute() from real generic-type-application usages seen anywhere in this module's
    // symbols). Uses defaultModule as one of its two lookup key forms, so the caller must have
    // defaultModule already pointing at the module `node` actually belongs to.
    func markGenericRecursive(node: TypeNode) {
        let enclosing = node.getEnclosingPath()
        let relativeName = enclosing.isEmpty ? node.name : enclosing + "." + node.name
        let fullPath1 = defaultModule + "." + relativeName
        let fullPath2 = relativeName
        // scanGenericTypeApplications() stops its name-backtrack at a `>` boundary, so a chained
        // application like "GenerativeStream<A>.Iterator<A1>" only ever records the bare nested
        // name ("Iterator"), never the qualified "GenerativeStream.Iterator" path. Fall back to
        // discoveredNestedGenericPairs (precompute()'s exact "Outer.Inner" pair scan) for nested
        // types so real independent generic-ness on a nested type isn't lost. This is precise —
        // keyed on the EXACT immediate-parent-plus-self pair, not just node.name — so it can't
        // collide with an unrelated type elsewhere sharing the same short name (e.g. HealthKit
        // has both a genuinely non-generic HKAnchoredObjectQueryDescriptor.Result and some other
        // unrelated *.Result<T> elsewhere; a bare "Result" lookup can't tell them apart, but the
        // pair key "HKAnchoredObjectQueryDescriptor.Result" can).
        let pairKey = "\(node.parent?.name ?? "").\(node.name)"
        let pairMatch = !enclosing.isEmpty && discoveredNestedGenericPairs[pairKey] != nil
        if discoveredGenerics[fullPath1] != nil || discoveredGenerics[fullPath2] != nil || pairMatch {
             if !node.name.hasPrefix("JSON") {
                  node.isGeneric = true
             }
        }
        for nested in node.nestedTypes.values {
            markGenericRecursive(node: nested)
        }
    }

    func generateAll() -> String {
        applyTypeFixups()

        // systemTypes is defined as class member

        fputs("discoveredProtocols: \(discoveredProtocols)\n", stderr)
        // Set all referenced but undefined types to struct
        func defaultUnknownTypes(node: TypeNode) {
            if node.kind == "unknown" {
                node.kind = "struct"
                discoveredConcreteTypes.insert(node.name)
            }
            for nested in node.nestedTypes.values {
                defaultUnknownTypes(node: nested)
            }
        }
        for module in modules.values {
            for type in module.nestedTypes.values {
                defaultUnknownTypes(node: type)
            }
        }

        let shimHeader = ""
        var output = shimHeader
        var definedTypes = Set<String>()

        let sortedModuleNames = modules.keys.sorted()
        
        // Phase 1: Generate type/class/enum declarations
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC", "__C"].contains(moduleName) { continue }
            if moduleName != defaultModule && isModuleAvailable(moduleName) {
                continue
            }
            guard let module = modules[moduleName] else { continue }
            
            for type in module.nestedTypes.values {
                markGenericRecursive(node: type)
            }
            
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            for type in sortedTypes {
                if moduleName == "__C" && systemTypes.contains(type.name) {
                    continue
                }
                let flattenedName = "\(moduleName)_\(type.name)"
                if definedTypes.contains(flattenedName) { continue }
                
                definedTypes.insert(flattenedName)
                let actualName = (moduleName == defaultModule) ? type.name : flattenedName
                if moduleName == defaultModule, let extInfo = stdlibTypeExtensions[type.name] {
                    // Qualify with the extended type's own module (e.g. "TokenGeneration.Prompt"
                    // vs "PromptKit.Prompt") so extending two same-named types from different
                    // modules doesn't produce an ambiguous bare "extension Prompt {". "__C" isn't
                    // a real importable module though (see the "__C." stripping convention in
                    // simplifyType) — an ObjC-bridged type like HKAttachment becomes directly
                    // visible under its bare name, so qualifying with "__C." here would produce
                    // "cannot find type '__C' in scope".
                    let extPrefix = extInfo.module == "__C" ? "" : "\(extInfo.module)."
                    output += "extension \(extPrefix)\(extInfo.stdlibType) {\n"
                    // Replace any bare outer generic-param placeholders (A, B, C…) with Any.
                    // These come from the enclosing stdlib type's own type params (e.g. Optional<Wrapped>
                    // or Result<Success, Failure>), which are not in scope inside the inner struct.
                    var body = type.generateCode(indent: "    ", nameOverride: extInfo.displayName, parser: self)
                    let replacementForB = (extInfo.stdlibType == "Result") ? "any Swift.Error" : "Any"
                    body = body.replaceWord("A", with: "Any", allowPrecededByDot: false, allowFollowedByDot: false)
                    body = body.replaceWord("B", with: replacementForB, allowPrecededByDot: false, allowFollowedByDot: false)
                    for bare in ["C", "D"] {
                        body = body.replaceWord(bare, with: "Any", allowPrecededByDot: false, allowFollowedByDot: false)
                    }
                    output += body + "\n"
                    output += "}\n\n"
                } else {
                    output += type.generateCode(indent: "", nameOverride: actualName, parser: self) + "\n\n"
                }
            }
        }

        // Generate top-level (global) members of the default module
        if let defaultModNode = modules[defaultModule] {
            let sortedMembers = defaultModNode.members.values.sorted(by: { 
                switch ($0, $1) {
                case (.property(let n1, _, _, _), .property(let n2, _, _, _)): return n1 < n2
                case (.method(let n1, _, _), .method(let n2, _, _)): return n1 < n2
                default: return false
                }
            })
            for member in sortedMembers {
                switch member {
                case .method(_, let sig, _):
                    var cleanedSig = sig.replacingOccurrences(of: " infix", with: "")
                    // `prefix`/`postfix` are real declaration-site keywords Swift requires on
                    // a unary operator function (e.g. `prefix func -(_: Duration) -> Duration`
                    // for negation) — unlike `infix`, which needs no keyword since it's the
                    // default. Demangled text carries " prefix(...)"/" postfix(...)" as part of
                    // the function name/signature text, not as a separate declaration modifier,
                    // so it must be extracted and re-emitted as a `public prefix func .../public
                    // postfix func ...` declaration instead of being silently dropped (dropping
                    // it produces "prefix unary operator missing 'prefix' modifier").
                    var operatorModifier = ""
                    if cleanedSig.contains(" prefix(") {
                        cleanedSig = cleanedSig.replacingOccurrences(of: " prefix(", with: "(")
                        operatorModifier = "prefix "
                    } else if cleanedSig.contains(" postfix(") {
                        cleanedSig = cleanedSig.replacingOccurrences(of: " postfix(", with: "(")
                        operatorModifier = "postfix "
                    }
                    cleanedSig = cleanedSig.replaceGenericPlaceholderPathsWithAny()
                    cleanedSig = Parser.fixUnnamedParameters(cleanedSig)
                    var returnType = "Void"
                    if let arrowRange = Parser.topLevelArrowRange(in: cleanedSig) {
                        returnType = String(cleanedSig[arrowRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                    let defaultVal = TypeNode.defaultReturnValue(for: returnType)
                    let body = defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }"
                    let finalBody = defaultVal == "fatalError()" ? "{ fatalError() }" : body
                    output += "public \(operatorModifier)func \(cleanedSig) \(finalBody)\n\n"
                    
                case .property(let n, let t, let isReadOnly, _):
                    var cleanT = t.replaceGenericPlaceholderPathsWithAny()
                    if let brace = cleanT.firstIndex(of: "{") {
                        cleanT = String(cleanT[..<brace]).trimmingCharacters(in: .whitespaces)
                    }
                    cleanT = cleanT.replacingOccurrences(of: "}", with: "")
                    
                    let defaultVal = TypeNode.defaultReturnValue(for: cleanT)
                    let getter = defaultVal == "fatalError()" ? "{ fatalError() }" : (defaultVal.isEmpty ? "{}" : "{ return \(defaultVal) }")
                    let suffix = isReadOnly ? "{ get \(getter) }" : "{ get \(getter) set {} }"
                    output += "public var \(n): \(cleanT) \(suffix)\n\n"
                    
                default:
                    break
                }
            }
        }
        
        // Phase 2: Generate type extensions
        for moduleName in sortedModuleNames {
            guard let module = modules[moduleName] else { continue }
            // Skip system/standard modules and non-default modules without extension members.
            // Exception: external private framework modules that have extension members added
            // by the current defaultModule (e.g. toAIR* properties on IPL enums).
            let systemAndStandardModules: Set<String> = [
                "Swift", "Foundation", "ObjectiveC", "XPC", "UnifiedAssetFramework", "__C",
                "CoreAI", "Dispatch", "os", "Metal", "CoreGraphics", "CoreVideo", "IOSurface",
                "MetricKit", "Combine", "Synchronization", "CoreMedia"
            ]
            // Constrained extensions (e.g. "extension Dictionary where Key == OS, Value ==
            // SemanticVersion") on a stdlib/system type are always safe to emit even though the
            // module itself is in the skip set above — the "could be a protocol" risk that
            // motivated skipping these modules doesn't apply to well-known stdlib structs/enums
            // like Swift.Dictionary.
            let hasConstrainedExtensions = module.nestedTypes.values.contains { !$0.constrainedExtensions.isEmpty }
            if systemAndStandardModules.contains(moduleName) && !hasConstrainedExtensions { continue }
            // For external available modules, only emit extensions when they contain read-only
            // computed properties (toX converters) — not operators or methods, which can fail
            // when the external type turns out to be a protocol — UNLESS the type's real kind
            // is already known (struct/class/enum), in which case that risk doesn't apply (see
            // the matching, more detailed comment on the per-type check below).
            let hasReadOnlyPropertyExtensions = module.nestedTypes.values.contains { node in
                node.kind == "struct" || node.kind == "class" || node.kind == "enum" ||
                node.extensionMembers.values.contains {
                    if case .property(_, _, let isReadOnly, _) = $0 { return isReadOnly }
                    return false
                }
            }
            if moduleName != defaultModule && isModuleAvailable(moduleName) && !hasReadOnlyPropertyExtensions && !hasConstrainedExtensions {
                continue
            }
            let isExternalAvailable = moduleName != defaultModule && isModuleAvailable(moduleName)
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            for type in sortedTypes {
                // For external available modules, only emit types that have read-only property
                // extensions — UNLESS the type's real kind has already been discovered
                // (struct/class/enum, from parsing the dependency module's own ABI symbols, as
                // happens for an explicitly declared dependency like CoreAIRuntime for
                // CoreAIDelegates). The read-only-property-only restriction guards against
                // emitting operators/methods/inits when the external type's kind is unknown to
                // us and could turn out to be a protocol, where those forms don't compile — see
                // commit 24a767e — but that risk doesn't apply once the kind is known.
                let kindIsKnown = type.kind == "struct" || type.kind == "class" || type.kind == "enum"
                if isExternalAvailable && !kindIsKnown && type.constrainedExtensions.isEmpty {
                    let hasROP = type.extensionMembers.values.contains {
                        if case .property(_, _, let isReadOnly, _) = $0 { return isReadOnly }
                        return false
                    }
                    if !hasROP { continue }
                    type.extensionMembers = type.extensionMembers.filter {
                        if case .property(_, _, let isReadOnly, _) = $0.value { return isReadOnly }
                        return false
                    }
                }
                let flattenedName = "\(moduleName)_\(type.name)"
                if !definedTypes.contains(flattenedName) && type.extensionMembers.isEmpty && type.constrainedExtensions.isEmpty { continue }

                // Emitting "extension Module.Type" requires the module to have a real,
                // compilable .swiftinterface confirming Type actually exists there (e.g.
                // Coherence ships only a .tbd with ABI symbols, no .swiftinterface — its types
                // can't be confirmed real, and "extension Coherence.CRContext" then fails with
                // "no type named 'CRContext' in module 'Coherence'"). Skip such a module/type
                // entirely rather than guessing.
                if isExternalAvailable && moduleName != "Swift" && moduleName != "__C" &&
                   !isTypeDefinedInFramework(module: moduleName, typeName: type.name) {
                    continue
                }

                let pathPrefix: String
                if moduleName == "Swift" {
                    pathPrefix = "Swift"
                } else if moduleName == "__C" {
                    pathPrefix = ""
                } else if moduleName == defaultModule {
                    pathPrefix = ""
                } else if isModuleAvailable(moduleName) {
                    // External available module — use dot-qualified path so extensions are
                    // emitted as "extension ModuleName.TypeName { ... }"
                    pathPrefix = moduleName
                } else {
                    pathPrefix = "\(moduleName)_"
                }
                output += type.generateExtensions(defaultModule: defaultModule, parser: self, path: pathPrefix)
            }
        }

        // Phase 3: Generate namespace and convenient typealiases
        for moduleName in sortedModuleNames {
            if ["Swift", "Foundation", "ObjectiveC", "__C"].contains(moduleName) { continue }
            if moduleName != defaultModule && isModuleAvailable(moduleName) {
                continue
            }
            if moduleName == defaultModule { continue }
            
            guard let module = modules[moduleName] else { continue }
            let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
            if sortedTypes.isEmpty { continue }

            output += "public enum \(moduleName)_Namespace {\n"
            for type in sortedTypes {
                let flattenedName = "\(moduleName)_\(type.name)"
                if !definedTypes.contains(flattenedName) { continue }
                output += "    public typealias \(type.name) = \(flattenedName)\n"
            }
            output += "}\n\n"
            
            if !definedTypes.contains(moduleName) {
                output += "public typealias \(moduleName) = \(moduleName)_Namespace\n"
            }
            
            if moduleName == "__C" {
                for type in sortedTypes {
                    let flattenedName = "\(moduleName)_\(type.name)"
                    if !definedTypes.contains(flattenedName) { continue }
                    output += "public typealias \(type.name) = \(flattenedName)\n"
                }
            }
        }
        
        // Phase 4: Generate generic typealiases mapping flattened names to imported module types, OR stubs if missing
        for moduleName in sortedModuleNames {
            if moduleName == defaultModule { continue }
            guard let module = modules[moduleName] else { continue }
            
            if isModuleAvailable(moduleName) {
                // Types whose generic parameters have Comparable/other constraints can't be
                // aliased with <Any> — skip them entirely in Phase 4.
                let constrainedGenericTypes: Set<String> = [
                    "Range", "ClosedRange", "PartialRangeFrom", "PartialRangeThrough", "PartialRangeUpTo"
                ]
                let sortedTypes = module.nestedTypes.values.sorted(by: { $0.name < $1.name })
                for type in sortedTypes {
                    if constrainedGenericTypes.contains(type.name) { continue }
                    let flattenedName = "\(moduleName)_\(type.name)"
                    if !definedTypes.contains(flattenedName) {
                        definedTypes.insert(flattenedName)
                        let gps = genericParamsString(for: type)
                        
                        // Check if type is publicly defined in the SDK or Local framework modules
                        // HealthKit's ObjC bridge header (main.swift) declares HKDataCacheContext/
                        // HKDataCacheProviding/HKWorkoutMetricsDelegate as real @protocol
                        // declarations (they have no Swift-visible ABI symbol at all) — skip the
                        // stub-struct fallback below for them so the bridged protocol declaration
                        // is what "HKDataCacheProviding" resolves to, not a conflicting struct.
                        let hkBridgedProtocolNames: Set<String> = [
                            "HKDataCacheContext", "HKDataCacheProviding", "HKWorkoutMetricsDelegate"
                        ]
                        if defaultModule == "HealthKit" && moduleName == "__C" && hkBridgedProtocolNames.contains(type.name) {
                            // no-op: real declaration comes from the bridge header
                        } else if isTypeDefinedInFramework(module: moduleName, typeName: type.name) {
                            if moduleName == "__C" {
                                output += "public typealias \(flattenedName)\(gps) = \(type.name)\(gps)\n"
                            } else {
                                output += "public typealias \(flattenedName)\(gps) = \(moduleName).\(type.name)\(gps)\n"
                            }
                        } else {
                            // Leak/Missing type in dependency - generate local stub to compile
                            output += "public struct \(flattenedName)\(gps): Hashable, Codable, Sendable {}\n"
                            // Some "__C" types (real ObjC classes/protocols with no Swift-visible
                            // declaration anywhere in the TBD — not even an objc-classes: entry,
                            // e.g. HealthKit's HKDataCacheContext/HKDataCacheProviding, only ever
                            // seen inside another symbol's signature) are referenced elsewhere in
                            // the generated code under their bare ObjC name, not the flattened
                            // "__C_Name" stub name — expose the stub under that bare name too.
                            // Scoped to defaultModule == "HealthKit" (not every undeclared "__C"
                            // type in any framework) because the bare name can otherwise collide
                            // with an unrelated real system type declared elsewhere (e.g.
                            // MetricKit references Foundation.UnitConverter, which isn't itself
                            // declared in MetricKit's own TBD and would get shadowed by a
                            // same-named stub struct here if this applied unconditionally).
                            if defaultModule == "HealthKit" && moduleName == "__C" {
                                output += "public typealias \(type.name)\(gps) = \(flattenedName)\(gps)\n"
                            }
                            // Same root cause, different module: any framework can reference bare
                            // XPCCodableObject (Vision's Serialization.decode/encode; also seen
                            // enriching dependency stubs like ModelManagerServices), but the type
                            // doesn't exist anywhere in the real XPC module (checked its
                            // swiftinterface directly) — it's ABI-visible only inside each
                            // framework's own private declarations. Not scoped to a specific
                            // defaultModule since the type is genuinely absent from XPC everywhere.
                            if moduleName == "XPC" && type.name == "XPCCodableObject" {
                                output += "public typealias \(type.name)\(gps) = \(flattenedName)\(gps)\n"
                            }
                        }
                    }
                }
            }
        }

        // Find all referenced but undefined types and generate stubs
        var stubs = ""
        let referenced = output.scanReferencedTypes()
        var referencedTypes = Set<String>()
        var protocolRefTypes = Set<String>()
        var genericCounts = [String: Int]()
        
        for item in referenced {
            referencedTypes.insert(item.typeName)
            if item.isProtocol {
                protocolRefTypes.insert(item.typeName)
            }
            if item.genericCount > 0 {
                let currentMax = genericCounts[item.typeName] ?? 0
                genericCounts[item.typeName] = max(currentMax, item.genericCount)
            }
        }
        
        // Find all defined types in output
        let allDefinedInOutput = output.scanFrameworkDefinedTypes()
        
        let sortedTypes = referencedTypes.sorted()
        for type in sortedTypes {
            if Parser.isGenericPlaceholder(type) { continue }
            if ["Type", "Element", "Protocol"].contains(type) { continue }
            if systemTypes.contains(type) || type == defaultModule || type == "___SHIELDED_\(defaultModule)___" || discoveredNamespaces.contains(type) || isModuleAvailable(type) || ["CatalogAssetType", "LocalService", "RemoteService", "Service", "ModelType", "TokenizerType", "Interface"].contains(type) || modules["__C"]?.nestedTypes[type] != nil { continue }
            if type.count == 1 { continue }
            if type.hasPrefix("JSON") { continue }
            
            // Check if defined
            var isDefined = allDefinedInOutput.contains(type)
            if !isDefined {
                if let node = modules[defaultModule]?.nestedTypes[type], node.isObjcBridged {
                    isDefined = true
                }
            }
            if !isDefined {
                var searchModules = discoveredNamespaces
                for rm in referencedModules {
                    searchModules.insert(rm)
                }
                for ns in searchModules {
                    if ns != defaultModule && isModuleAvailable(ns) {
                        if isTypeDefinedInFramework(module: ns, typeName: type) {
                            isDefined = true
                            break
                        }
                    }
                }
            }
            if !isDefined {
                // Check if used with "any", ends with "_P", or is in discoveredProtocols
                let flatDiscoveredProtocols = Set(discoveredProtocols.map { $0.replacingOccurrences(of: ".", with: "_") })
                // If the type is a namespace prefix for a known protocol (e.g. `Mod.Source` in discoveredProtocols)
                // then `type` is a namespace/module, not a protocol itself – skip protocol classification.
                let isNamespacePrefixForProtocol = discoveredProtocols.contains(where: { $0.hasPrefix(type + ".") })
                let isProtocolRef = !isNamespacePrefixForProtocol && (
                                    protocolRefTypes.contains(type) || 
                                    type.hasSuffix("_P") || 
                                    discoveredProtocols.contains(type) || 
                                    flatDiscoveredProtocols.contains(type) || 
                                    discoveredProtocols.contains(where: { $0.hasSuffix("." + type) }))
                // If the type is a namespace prefix for a known protocol (e.g. `Mod.Source` in discoveredProtocols)
                // then `type` is an external module/namespace – skip generating any local stub for it.
                if isNamespacePrefixForProtocol {
                    // Skip: this is an external module prefix, not a local type to stub
                } else if isProtocolRef {
                    stubs += "public protocol \(type) {}\n"
                } else {
                    // Check if used as generic in the output
                    let gc = genericCounts[type] ?? 0
                    if gc > 0 {
                        let placeholders = ["T", "U", "V", "W", "X", "Y", "Z"]
                        var params = [String]()
                        for j in 0..<gc {
                            params.append(j < placeholders.count ? placeholders[j] : "T\(j)")
                        }
                        stubs += "public struct \(type)<\(params.joined(separator: ", "))>: Hashable, Codable, Sendable {}\n"
                    } else {
                        stubs += "public struct \(type): Hashable, Codable, Sendable {}\n"
                    }
                }
            }
        }
        output += "\n" + stubs

        return output
    }

    private func scanLocalSwiftFiles(currentModule: String) {
        let fm = FileManager.default
        var filesToScan = [String]()
        
        // 1. Scan tmp_stubs_<currentModule> if it exists
        let stubsDir = "tmp_stubs_\(currentModule)"
        if let subFiles = try? fm.contentsOfDirectory(atPath: stubsDir) {
            for sf in subFiles {
                if sf.hasSuffix(".swift") {
                    filesToScan.append("\(stubsDir)/\(sf)")
                }
            }
        }
        
        // 2. Scan root directory files starting with test_<currentModule>
        if let rootFiles = try? fm.contentsOfDirectory(atPath: fm.currentDirectoryPath) {
            for rf in rootFiles {
                if rf.hasSuffix(".swift") && !rf.hasSuffix("Interface.swift") {
                    let lowerRF = rf.lowercased()
                    let lowerMod = currentModule.lowercased()
                    if lowerRF.contains(lowerMod) || lowerRF == "main.swift" {
                        filesToScan.append(rf)
                    }
                }
            }
        }
        
        func countTopLevelCommas(in s: String) -> Int {
            var commas = 0
            var depth = 0
            var parenDepth = 0
            for char in s {
                if char == "<" { depth += 1 }
                else if char == ">" { depth -= 1 }
                else if char == "(" { parenDepth += 1 }
                else if char == ")" { parenDepth -= 1 }
                else if char == "," {
                    if depth == 0 && parenDepth == 0 {
                        commas += 1
                    }
                }
            }
            return commas + 1
        }
        
        for file in filesToScan {
            guard let content = try? String(contentsOfFile: file, encoding: .utf8) else { continue }
            
            let genericTypes = content.scanGenericTypeApplications()
            for (typeName, params) in genericTypes {
                let shortName = typeName.components(separatedBy: ".").last!
                guard let firstChar = shortName.first, firstChar.isUppercase else { continue }
                
                if ["Optional", "Array", "Dictionary", "Set", "UnsafePointer", "UnsafeMutablePointer", "UnsafeRawPointer", "UnsafeMutableRawPointer"].contains(shortName) {
                    continue
                }
                
                let count = countTopLevelCommas(in: params)
                let fullPath = currentModule + "." + typeName
                let currentMax = discoveredGenerics[fullPath] ?? 0
                discoveredGenerics[fullPath] = max(currentMax, count)
                let currentShortMax = discoveredGenerics[typeName] ?? 0
                discoveredGenerics[typeName] = max(currentShortMax, count)
            }
        }
    }

    func discoverNominalTypes(demangledMap: [(mangled: String, demangled: String)], currentModule: String) {
        for (mangled, demangled) in demangledMap {
            var path = ""
            var kind = "unknown"
            
            if demangled.hasPrefix("nominal type descriptor for ") {
                path = demangled.replacingOccurrences(of: "nominal type descriptor for ", with: "")
                if mangled.hasSuffix("OMn") { kind = "enum" }
                else if mangled.hasSuffix("VMn") { kind = "struct" }
                else if mangled.hasSuffix("CMn") { kind = "class" }
            } else if demangled.hasPrefix("type metadata for ") {
                path = demangled.replacingOccurrences(of: "type metadata for ", with: "")
                if mangled.hasSuffix("ON") { kind = "enum" }
                else if mangled.hasSuffix("VN") { kind = "struct" }
                else if mangled.hasSuffix("CN") { kind = "class" }
            } else if demangled.hasPrefix("protocol descriptor for ") {
                path = demangled.replacingOccurrences(of: "protocol descriptor for ", with: "")
                kind = "protocol"
            } else if demangled.contains("enum case for ") {
                let d = demangled.replacingOccurrences(of: "enum case for ", with: "")
                if let openParen = d.firstIndex(of: "(") {
                    let fullPath = String(d[..<openParen]).trimmingCharacters(in: .whitespaces).stripGenericAngles()
                    let parts = fullPath.components(separatedBy: ".")
                    if parts.count >= 2 {
                        path = parts.dropLast().joined(separator: ".")
                        kind = "enum"
                    } else {
                        continue
                    }
                } else {
                    continue
                }
            } else {
                continue
            }
            
            // "(extension in Combine):Swift.Optional.Publisher" declares a brand-new nested
            // type (Publisher) inside an extension the CURRENT module adds to another module's
            // type (Optional) — this must be emitted as part of the current module's own output
            // (`extension Swift.Optional { struct Publisher {...} }`), not filed under the
            // extended type's own module namespace, where it would either silently vanish
            // (Swift/Foundation are never emitted) or collide with another module's same-named
            // extended type (e.g. TokenGeneration.Prompt vs PromptKit.Prompt both gaining
            // extensions). Route it to currentModule and record the base type being extended,
            // including ITS module, for the emission pass.
            var extendedTypeModule: String? = nil
            var extendedStdlibType: String? = nil
            var displayName: String? = nil
            if path.hasPrefix("(extension in "), let colonIdx = path.firstIndex(of: ":") {
                let extModule = String(path[path.index(path.startIndex, offsetBy: "(extension in ".count)..<path.index(before: colonIdx)])
                path = String(path[path.index(after: colonIdx)...])
                let pathParts = path.components(separatedBy: ".")
                // pathParts[0] is the module the extended type itself belongs to (e.g.
                // "Swift" or "TokenGeneration"), pathParts[1] is the type being extended (e.g.
                // "Optional" or "Prompt"), and the remainder is the new nested type's path
                // (e.g. "Publisher").
                if extModule == currentModule, pathParts.count >= 3 {
                    extendedTypeModule = pathParts[0]
                    extendedStdlibType = pathParts[1]
                    let nestedPath = pathParts.dropFirst(2).joined(separator: ".")
                    displayName = pathParts.last
                    selfDeclaredExternalExtensionPaths.insert(pathParts.joined(separator: "."))
                    // Multiple (module, type) pairs can be extended with a same-named nested
                    // type (e.g. both Optional and Result gain a "Publisher", or unrelated
                    // modules each have their own "Prompt"), so the internal node name must
                    // stay unique per (extended-type-module, extended-type) pair.
                    path = currentModule + "." + "__StdlibExt_\(pathParts[0])_\(pathParts[1])_" + nestedPath
                }
            } else if let inIndex = path.range(of: " in ") {
                path = String(path[..<inIndex.lowerBound])
            }

            let parts = path.components(separatedBy: ".")
            guard parts.count >= 2 else { continue }

            let module = parts[0]
            if module != currentModule {
                discoveredNamespaces.insert(module)
            }

            let typePath = Array(parts[1...])

            let node = findOrCreateDiscoveredTypePath(module: module, path: typePath)
            setKind(kind, for: node, force: true)
            if let typeModule = extendedTypeModule, let stdlibType = extendedStdlibType, let display = displayName {
                stdlibTypeExtensions[node.name] = (typeModule, stdlibType, display)
            }
        }
    }

    func findOrCreateDiscoveredTypePath(module: String, path: [String]) -> TypeNode {
        if modules[module] == nil {
            modules[module] = TypeNode(name: module)
        }
        
        var current = modules[module]!
        for part in path {
            if current.nestedTypes[part] == nil {
                let newNode = TypeNode(name: part)
                newNode.parent = current
                current.nestedTypes[part] = newNode
            }
            current = current.nestedTypes[part]!
        }
        return current
    }

    private func stripFunctionTypeLabels(_ t: String) -> String {
        var result = ""
        var i = t.startIndex
        while i < t.endIndex {
            if t[i] == "(" {
                // Find matching parenthesis
                var depth = 0
                var j = i
                var found = false
                while j < t.endIndex {
                    if t[j] == "(" {
                        depth += 1
                    } else if t[j] == ")" {
                        depth -= 1
                        if depth == 0 {
                            found = true
                            break
                        }
                    }
                    j = t.index(after: j)
                }
                if found {
                    let inner = String(t[t.index(after: i)..<j])
                    let after = String(t[t.index(after: j)...])
                    
                    // Check if this paren is followed by -> (possibly with throws, async, etc.)
                    let trimmedAfter = after.trimmingCharacters(in: .whitespaces)
                    let isFuncType: Bool
                    if trimmedAfter.hasPrefix("->") {
                        isFuncType = true
                    } else if trimmedAfter.hasPrefix("throws") || trimmedAfter.hasPrefix("async") {
                        // Check if it has -> after throws/async
                        var k = trimmedAfter.startIndex
                        var hasArrow = false
                        while k < trimmedAfter.endIndex {
                            if trimmedAfter[k...].hasPrefix("->") {
                                hasArrow = true
                                break
                            }
                            k = trimmedAfter.index(after: k)
                        }
                        isFuncType = hasArrow
                    } else {
                        isFuncType = false
                    }
                    
                    if isFuncType {
                        // This is a function type!
                        // Recursively clean the inner parameters
                        let cleanedInner = cleanFuncParams(inner)
                        // Also recursively clean the after part (since it contains the return type and rest)
                        let cleanedAfter = stripFunctionTypeLabels(after)
                        result += "(" + cleanedInner + ")" + cleanedAfter
                        return result
                    } else {
                        // Not a function type paren (could be a tuple or grouping)
                        // Recursively clean inside and continue
                        let cleanedInner = stripFunctionTypeLabels(inner)
                        result += "(" + cleanedInner + ")"
                        i = t.index(after: j)
                        continue
                    }
                }
            }
            result.append(t[i])
            i = t.index(after: i)
        }
        return result
    }

    private func cleanFuncParams(_ s: String) -> String {
        // Split s by commas at depth 0 of nested structures
        var params = [String]()
        var current = ""
        var pDepth = 0
        var aDepth = 0
        var sDepth = 0
        var i = s.startIndex
        while i < s.endIndex {
            let c = s[i]
            if c == "(" { pDepth += 1 }
            else if c == ")" { pDepth -= 1 }
            else if c == "<" { aDepth += 1 }
            else if c == ">" { aDepth -= 1 }
            else if c == "[" { sDepth += 1 }
            else if c == "]" { sDepth -= 1 }
            
            if c == "," && pDepth == 0 && aDepth == 0 && sDepth == 0 {
                params.append(current)
                current = ""
            } else {
                current.append(c)
            }
            i = s.index(after: i)
        }
        params.append(current)
        
        // Clean each param
        let cleanedParams = params.map { param -> String in
            let trimmed = param.trimmingCharacters(in: .whitespaces)
            // Find colon at depth 0 in this parameter
            var colonIndex: String.Index? = nil
            var pDepth = 0
            var aDepth = 0
            var sDepth = 0
            var j = trimmed.startIndex
            while j < trimmed.endIndex {
                let c = trimmed[j]
                if c == "(" { pDepth += 1 }
                else if c == ")" { pDepth -= 1 }
                else if c == "<" { aDepth += 1 }
                else if c == ">" { aDepth -= 1 }
                else if c == "[" { sDepth += 1 }
                else if c == "]" { sDepth -= 1 }
                
                if c == ":" && pDepth == 0 && aDepth == 0 && sDepth == 0 {
                    colonIndex = j
                    break
                }
                j = trimmed.index(after: j)
            }
            
            if let colon = colonIndex {
                // Strip label and recursively clean the type part
                let typePart = String(trimmed[trimmed.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
                return stripFunctionTypeLabels(typePart)
            } else {
                return stripFunctionTypeLabels(trimmed)
            }
        }
        
        return cleanedParams.joined(separator: ", ")
    }

    private func stripLabelsFromMethodSignature(_ t: String) -> String {
        var openParenIdx: String.Index? = nil
        var genericDepth = 0
        for (idx, char) in t.enumerated() {
            if char == "<" {
                genericDepth += 1
            } else if char == ">" {
                genericDepth = max(0, genericDepth - 1)
            } else if char == "(" && genericDepth == 0 {
                openParenIdx = t.index(t.startIndex, offsetBy: idx)
                break
            }
        }
        
        guard let openParen = openParenIdx else { return stripFunctionTypeLabels(t) }
        
        // Find matching parenthesis for the top-level parameters
        var depth = 0
        var matchingIndex: String.Index? = nil
        let rest = String(t[t.index(after: openParen)...])
        for (idx, char) in rest.enumerated() {
            if char == "(" {
                depth += 1
            } else if char == ")" {
                if depth == 0 {
                    matchingIndex = rest.index(rest.startIndex, offsetBy: idx)
                    break
                }
                depth -= 1
            }
        }
        guard let closeParen = matchingIndex else { return stripFunctionTypeLabels(t) }
        
        let prefix = String(t[..<openParen]) + "("
        let paramsPart = String(rest[..<closeParen])
        let afterPart = String(rest[rest.index(after: closeParen)...])
        
        let cleanedAfter = stripFunctionTypeLabels(afterPart)
        let cleanedParams = cleanMethodParams(paramsPart)
        
        return prefix + cleanedParams + ")" + cleanedAfter
    }

    private func cleanMethodParams(_ s: String) -> String {
        var params = [String]()
        var current = ""
        var pDepth = 0
        var aDepth = 0
        var sDepth = 0
        var i = s.startIndex
        while i < s.endIndex {
            let c = s[i]
            if c == "(" { pDepth += 1 }
            else if c == ")" { pDepth -= 1 }
            else if c == "<" { aDepth += 1 }
            else if c == ">" { aDepth -= 1 }
            else if c == "[" { sDepth += 1 }
            else if c == "]" { sDepth -= 1 }
            
            if c == "," && pDepth == 0 && aDepth == 0 && sDepth == 0 {
                params.append(current)
                current = ""
            } else {
                current.append(c)
            }
            i = s.index(after: i)
        }
        params.append(current)
        
        let cleaned = params.map { param -> String in
            let trimmed = param.trimmingCharacters(in: .whitespaces)
            var colonIndex: String.Index? = nil
            var pDepth = 0
            var aDepth = 0
            var sDepth = 0
            var j = trimmed.startIndex
            while j < trimmed.endIndex {
                let c = trimmed[j]
                if c == "(" { pDepth += 1 }
                else if c == ")" { pDepth -= 1 }
                else if c == "<" { aDepth += 1 }
                else if c == ">" { aDepth -= 1 }
                else if c == "[" { sDepth += 1 }
                else if c == "]" { sDepth -= 1 }
                
                if c == ":" && pDepth == 0 && aDepth == 0 && sDepth == 0 {
                    colonIndex = j
                    break
                }
                j = trimmed.index(after: j)
            }
            
            if let colon = colonIndex {
                let labelPart = String(trimmed[..<colon]).trimmingCharacters(in: .whitespaces)
                let typePart = String(trimmed[trimmed.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
                let cleanedType = stripFunctionTypeLabels(typePart)
                return labelPart + ": " + cleanedType
            } else {
                return stripFunctionTypeLabels(trimmed)
            }
        }
        return cleaned.joined(separator: ", ")
    }

    static func isNonOptionalFunctionType(_ typeStr: String) -> Bool {
        let clean = typeStr.trimmingCharacters(in: .whitespaces)
        if clean.hasSuffix("?") || clean.hasPrefix("Optional<") || clean.hasSuffix("!") {
            return false
        }
        var depth_p = 0
        var depth_a = 0
        var depth_s = 0
        var i = clean.index(before: clean.endIndex)
        while i >= clean.startIndex {
            let c = clean[i]
            if c == ")" { depth_p += 1 }
            else if c == "(" { depth_p -= 1 }
            else if c == ">" { depth_a += 1 }
            else if c == "<" { depth_a -= 1 }
            else if c == "]" { depth_s += 1 }
            else if c == "[" { depth_s -= 1 }
            else if c == ">" && i > clean.startIndex && clean[clean.index(before: i)] == "-" {
                if depth_p == 0 && depth_a == 0 && depth_s == 0 {
                    return true
                }
            }
            if i == clean.startIndex { break }
            i = clean.index(before: i)
        }
        return false
    }

    static func escapeClosures(in typeStr: String, isTopLevelParameter: Bool = false, isEscaping: Bool = true) -> String {
        let trimmed = typeStr.trimmingCharacters(in: .whitespaces)
        
        if trimmed.hasSuffix("?") || trimmed.hasPrefix("Optional<") || trimmed.hasSuffix("!") {
            if trimmed.hasSuffix("?") {
                let inner = String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)
                let processedInner = escapeClosures(in: inner, isTopLevelParameter: isTopLevelParameter, isEscaping: isEscaping)
                // The demangler prints a whole-closure-is-Optional type as a bare trailing "?"
                // with no enclosing parens, e.g. "(String) -> Int?" -- this actually means
                // "the closure itself is Optional", not "the closure's return type is
                // Optional", so the "?" must bind to the whole (parenthesized) closure type.
                if isNonOptionalFunctionType(inner) {
                    return "(" + processedInner + ")?"
                }
                return processedInner + "?"
            }
            if trimmed.hasSuffix("!") {
                let inner = String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)
                let processedInner = escapeClosures(in: inner, isTopLevelParameter: isTopLevelParameter, isEscaping: isEscaping)
                if isNonOptionalFunctionType(inner) {
                    return "(" + processedInner + ")!"
                }
                return processedInner + "!"
            }
            if trimmed.hasPrefix("Optional<") && trimmed.hasSuffix(">") {
                let inner = String(trimmed.dropFirst(9).dropLast()).trimmingCharacters(in: .whitespaces)
                return "Optional<" + escapeClosures(in: inner, isTopLevelParameter: isTopLevelParameter, isEscaping: isEscaping) + ">"
            }
        }
        
        var depth_p = 0
        var depth_a = 0
        var depth_s = 0
        var arrowIdx: String.Index? = nil
        
        var i = trimmed.index(before: trimmed.endIndex)
        while i >= trimmed.startIndex {
            let c = trimmed[i]
            if c == ">" && i > trimmed.startIndex && trimmed[trimmed.index(before: i)] == "-" {
                if depth_p == 0 && depth_a == 0 && depth_s == 0 {
                    arrowIdx = trimmed.index(before: i)
                    break
                }
                i = trimmed.index(before: i)
            }
            else if c == ")" { depth_p += 1 }
            else if c == "(" { depth_p -= 1 }
            else if c == ">" { depth_a += 1 }
            else if c == "<" { depth_a -= 1 }
            else if c == "]" { depth_s += 1 }
            else if c == "[" { depth_s -= 1 }
            if i == trimmed.startIndex { break }
            i = trimmed.index(before: i)
        }
        
        guard let arrow = arrowIdx else {
            if let openAngle = trimmed.firstIndex(of: "<"), trimmed.hasSuffix(">") {
                let prefix = trimmed[..<openAngle]
                let inner = String(trimmed[trimmed.index(after: openAngle)..<trimmed.index(before: trimmed.endIndex)])
                var args = [String]()
                var current = ""
                var pD = 0
                var aD = 0
                var sD = 0
                for c in inner {
                    if c == "(" { pD += 1 }
                    else if c == ")" { pD -= 1 }
                    else if c == "<" { aD += 1 }
                    else if c == ">" { aD -= 1 }
                    else if c == "[" { sD += 1 }
                    else if c == "]" { sD -= 1 }
                    if c == "," && pD == 0 && aD == 0 && sD == 0 {
                        args.append(current)
                        current = ""
                    } else {
                        current.append(c)
                    }
                }
                args.append(current)
                let escapedArgs = args.map { escapeClosures(in: $0) }
                return "\(prefix)<\(escapedArgs.joined(separator: ", "))>"
            }
            return trimmed
        }
        
        var leftPart = String(trimmed[..<arrow]).trimmingCharacters(in: .whitespaces)
        let rightPart = String(trimmed[trimmed.index(arrow, offsetBy: 2)...]).trimmingCharacters(in: .whitespaces)
        
        var throwsModifier = ""
        while true {
            if leftPart.hasSuffix("throws") {
                leftPart = String(leftPart.dropLast(6)).trimmingCharacters(in: .whitespaces)
                throwsModifier = "throws " + throwsModifier
            } else if leftPart.hasSuffix("async") {
                leftPart = String(leftPart.dropLast(5)).trimmingCharacters(in: .whitespaces)
                throwsModifier = "async " + throwsModifier
            } else if leftPart.hasSuffix("rethrows") {
                leftPart = String(leftPart.dropLast(8)).trimmingCharacters(in: .whitespaces)
                throwsModifier = "rethrows " + throwsModifier
            } else {
                break
            }
        }
        if !throwsModifier.isEmpty {
            throwsModifier = throwsModifier.trimmingCharacters(in: .whitespaces) + " "
        }
        
        var attrs = ""
        var paramsString = leftPart
        if leftPart.hasSuffix(")") {
            var depth = 0
            var paramStartIdx: String.Index? = nil
            var i = leftPart.index(before: leftPart.endIndex)
            while i >= leftPart.startIndex {
                let c = leftPart[i]
                if c == ")" {
                    depth += 1
                } else if c == "(" {
                    depth -= 1
                    if depth == 0 {
                        paramStartIdx = i
                        break
                    }
                }
                if i == leftPart.startIndex { break }
                i = leftPart.index(before: i)
            }
            if let startIdx = paramStartIdx {
                attrs = String(leftPart[..<startIdx]).trimmingCharacters(in: .whitespaces)
                if !attrs.isEmpty {
                    attrs = attrs + " "
                }
                paramsString = String(leftPart[startIdx...]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        var enclosingParens = false
        if paramsString.hasPrefix("(") && paramsString.hasSuffix(")") {
            var depth = 0
            var matchedLast = true
            let paramsChars = Array(paramsString)
            for (idx, char) in paramsChars.enumerated() {
                if char == "(" {
                    depth += 1
                } else if char == ")" {
                    depth -= 1
                    if depth == 0 && idx < paramsChars.count - 1 {
                        matchedLast = false
                        break
                    }
                }
            }
            if depth == 0 && matchedLast {
                enclosingParens = true
            }
        }
        
        if enclosingParens {
            paramsString.removeFirst()
            paramsString.removeLast()
        } else {
            let escaped = escapeClosures(in: paramsString)
            let isFunc = escaped.contains("->")
            let isOpt: Bool
            if isFunc {
                isOpt = escaped.hasPrefix("Optional<") || escaped.hasSuffix(")?") || escaped.hasSuffix(")?!")
            } else {
                isOpt = escaped.hasSuffix("?") || escaped.hasPrefix("Optional<") || escaped.hasSuffix("!")
            }
            let hasEsc = escaped.contains("@escaping")
            let escPrefix = (isFunc && !isOpt && !hasEsc && isEscaping) ? "@escaping " : ""
            let finalType = attrs + escPrefix + escaped + " " + throwsModifier + "-> " + escapeClosures(in: rightPart)
            return (isTopLevelParameter && isEscaping) ? "@escaping " + finalType : finalType
        }
        
        var paramList = [String]()
        var current = ""
        var pD = 0
        var aD = 0
        var sD = 0
        for c in paramsString {
            if c == "(" { pD += 1 }
            else if c == ")" { pD -= 1 }
            else if c == "<" { aD += 1 }
            else if c == ">" { aD -= 1 }
            else if c == "[" { sD += 1 }
            else if c == "]" { sD -= 1 }
            if c == "," && pD == 0 && aD == 0 && sD == 0 {
                paramList.append(current)
                current = ""
            } else {
                current.append(c)
            }
        }
        paramList.append(current)
        
        var escapedParams = [String]()
        for p in paramList {
            let trimmedP = p.trimmingCharacters(in: .whitespaces)
            if trimmedP.isEmpty { continue }
            
            var label = ""
            var type = trimmedP
            var pD2 = 0
            var aD2 = 0
            var sD2 = 0
            for (index, char) in trimmedP.enumerated() {
                if char == "(" { pD2 += 1 }
                else if char == ")" { pD2 -= 1 }
                else if char == "<" { aD2 += 1 }
                else if char == ">" { aD2 -= 1 }
                else if char == "[" { sD2 += 1 }
                else if char == "]" { sD2 -= 1 }
                if char == ":" && pD2 == 0 && aD2 == 0 && sD2 == 0 {
                    let cIdx = trimmedP.index(trimmedP.startIndex, offsetBy: index)
                    label = String(trimmedP[..<cIdx]) + ": "
                    type = String(trimmedP[trimmedP.index(after: cIdx)...]).trimmingCharacters(in: .whitespaces)
                    break
                }
            }
            
            let escapedType = escapeClosures(in: type)
            let cleanEscType = escapedType.trimmingCharacters(in: .whitespaces)
            let isFunc = cleanEscType.contains("->")
            let isOpt: Bool
            if isFunc {
                isOpt = cleanEscType.hasPrefix("Optional<") || cleanEscType.hasSuffix(")?") || cleanEscType.hasSuffix(")?!")
            } else {
                isOpt = cleanEscType.hasSuffix("?") || cleanEscType.hasPrefix("Optional<") || cleanEscType.hasSuffix("!")
            }
            let hasEsc = cleanEscType.contains("@escaping")
            
            let finalType: String
            if isFunc && !isOpt && !hasEsc {
                finalType = "@escaping " + cleanEscType
            } else {
                finalType = cleanEscType
            }
            escapedParams.append(label + finalType)
        }
        
        let finalType = attrs + "(" + escapedParams.joined(separator: ", ") + ") " + throwsModifier + "-> " + escapeClosures(in: rightPart)
        return (isTopLevelParameter && isEscaping) ? "@escaping " + finalType : finalType
    }

    func findTypeNode(module: String, path: [String]) -> TypeNode? {
        guard let root = modules[module] else { return nil }
        var current = root
        for part in path {
            if let child = current.nestedTypes[part] {
                current = child
            } else {
                return nil
            }
        }
        return current
    }

    func isConcreteTypeNonGeneric(shortName: String) -> Bool {
        // Collects EVERY node across every module sharing this short name, not just the first —
        // multiple unrelated types can share a short name (e.g. CoreAIRuntime has both a generic
        // NDArrayDescriptor.MutableView<A> and a non-generic InferenceValue.MutableView). Only
        // the first match used to be checked, so which one "won" depended on nondeterministic
        // dictionary iteration order over modules.values — when the generic one won, this
        // wrongly reported the UNRELATED non-generic type as "not concrete-non-generic" too,
        // causing applyDiscoveredGenerics' bare-word scan to inject a bogus "<Any>" onto every
        // bare occurrence of the short name, including the genuinely non-generic type's own
        // synthesized `==` operator (producing an uncompilable "MutableView<Any>" reference to
        // a type declared with no generic parameters at all).
        func collect(node: TypeNode, into results: inout [Bool]) {
            if node.name == shortName {
                results.append(node.isGeneric)
            }
            for child in node.nestedTypes.values {
                collect(node: child, into: &results)
            }
        }
        var results = [Bool]()
        for module in modules.values {
            for type in module.nestedTypes.values {
                collect(node: type, into: &results)
            }
        }
        guard !results.isEmpty else { return false }
        // If every same-named node agrees, trust that verdict. If they disagree (the ambiguous
        // multi-type case), return true ("treat as non-generic concrete") so the caller SKIPS
        // adding this short name to flatGenerics/shortGenerics entirely — the bare-word scan
        // must never touch a short name that's ambiguous between a generic and a non-generic
        // type, since it can't tell which occurrence is which.
        return results.allSatisfy { !$0 } || (results.contains(true) && results.contains(false))
    }
}

