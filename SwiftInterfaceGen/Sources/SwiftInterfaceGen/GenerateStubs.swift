import Foundation

extension SwiftInterfaceGen {
    static func generateStubs(outputCode: String, currentModule: String, outputDir: String, parser: Parser) {
        try? outputCode.write(toFile: "/tmp/finalCode_\(currentModule)_first_run.swift", atomically: true, encoding: .utf8)
        var externalTypes = [String: [(typeName: String, isProtocol: Bool, genericCount: Int)]]()

        // Primary-associated-type protocols (e.g. "protocol Source<Stream>") mangle each
        // constrained-existential use site with the associated type's REAL name (e.g. "any
        // Source<Self.Stream == A>" mangles distinguishing "Stream", not just its position) —
        // stubbing the protocol with a generic "associatedtype A" placeholder produces a
        // same-position but differently-named associated type, which mangles differently and
        // never matches the real ABI symbol. Parser.swift's simplifyType recovers the real name
        // from "Self.<Name> == A>" while it's still present (before erasure/marker-replacement)
        // and records it in parser.primaryAssociatedTypeNames, keyed by the protocol's short
        // name — read it here so the stub declares "associatedtype <Name>" under the same
        // placeholder position instead of a bare "A".
        let primaryAssociatedTypeNames = parser.primaryAssociatedTypeNames
        var selfDeclaredExtensionTypes = Set<String>(parser.selfDeclaredExternalExtensionPaths)
        let outputLines = outputCode.components(separatedBy: .newlines)
        var activeExtPrefix: String? = nil
        var currentDepth = 0

        for line in outputLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if currentDepth == 0 && trimmed.hasPrefix("extension ") {
                let afterExt = trimmed.dropFirst("extension ".count).trimmingCharacters(in: .whitespaces)
                let header = afterExt.components(separatedBy: CharacterSet(charactersIn: " :{")).first ?? ""
                if header.contains(".") {
                    let mod = header.components(separatedBy: ".")[0]
                    if mod != currentModule {
                        activeExtPrefix = header
                    }
                }
            }
            
            let opens = line.filter { $0 == "{" }.count
            let closes = line.filter { $0 == "}" }.count
            currentDepth += (opens - closes)
            
            if let extPrefix = activeExtPrefix, currentDepth > 0 {
                if trimmed.hasPrefix("public enum ") || trimmed.hasPrefix("public struct ") ||
                   trimmed.hasPrefix("public class ") || trimmed.hasPrefix("public typealias ") ||
                   trimmed.hasPrefix("enum ") || trimmed.hasPrefix("struct ") ||
                   trimmed.hasPrefix("class ") || trimmed.hasPrefix("typealias ") {
                    let words = trimmed.components(separatedBy: CharacterSet.whitespaces.union(CharacterSet(charactersIn: ":<({")))
                    let keywords: Set<String> = ["public", "private", "fileprivate", "internal", "enum", "struct", "class", "typealias", "@unchecked", "Sendable", "@objc", "final", "indirect", ""]
                    let nonKeyWords = words.filter { !keywords.contains($0) }
                    if let nestedName = nonKeyWords.first {
                        let fullPath = "\(extPrefix).\(nestedName)"
                        selfDeclaredExtensionTypes.insert(fullPath)
                    }
                }
            }
            
            if currentDepth == 0 {
                activeExtPrefix = nil
            }
        }

        var constraintTypes = Set<String>()
        // 1. Parse 'where' constraints
        let localWherePattern = "where\\s+([^\\{]+)"
        if let regex = try? NSRegularExpression(pattern: localWherePattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    let constraintsStr = String(outputCode[range])
                    let individual = constraintsStr.components(separatedBy: ",")
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(":") {
                            let parts = trimmed.components(separatedBy: ":")
                            if parts.count == 2 {
                                let constraint = parts[1].replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                constraintTypes.insert(constraint)
                            }
                        }
                    }
                }
            }
        }
        // 2. Parse generic parameter lists `<...>`
        let localGenericListPattern = "<([^>]+)>"
        if let regex = try? NSRegularExpression(pattern: localGenericListPattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    let listStr = String(outputCode[range])
                    let individual = listStr.components(separatedBy: ",")
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(":") {
                            let parts = trimmed.components(separatedBy: ":")
                            if parts.count == 2 {
                                let constraint = parts[1].replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                constraintTypes.insert(constraint)
                            }
                        }
                    }
                }
            }
        }

        // A nested type literally named `Type` (or another Swift keyword) demangles/renders
        // backtick-escaped ("ToolDefinition.`Type`"), which the bare identifier character class
        // below doesn't match — missing it here means it's never added to externalTypes and
        // the dependency stub omits it entirely, e.g. "extension ...ToolDefinition.`Type` {"
        // referencing a `Type` that was never stubbed. Allow an optional backtick-quoted segment
        // anywhere in the dotted path.
        let identifierSegment = "(?:[a-zA-Z0-9_$]+|`[a-zA-Z0-9_$]+`)"
        // No trailing \b: a path ending in a backtick-quoted segment (e.g. "Foo.`Type`") has a
        // non-word character on both sides of that final backtick, so \b never matches there.
        let pathPattern = "\\b([A-Z][a-zA-Z0-9_$]*\\.\(identifierSegment)(?:\\.\(identifierSegment))*)"
        if let regex = try? NSRegularExpression(pattern: pathPattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            // Hoisted out of the match loop -- rebuilding a full Character array of the entire
            // (often 1MB+) generated file on EVERY match (this pattern alone can match thousands
            // of dotted-path references in a large file) turns this into an O(n*k) scan that was
            // measured taking 40+ seconds on ModelCatalog's ~1MB output. Building it once is O(n).
            let chars = Array(outputCode)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    // Strip backticks so a keyword-named segment ("`Type`") matches the plain
                    // "Type"/"Protocol"/... names generateSwift()'s own escaping check looks for
                    // — StubNode tree-building and re-escaping on emit stay in sync this way.
                    let typeName = String(outputCode[range]).replacingOccurrences(of: "`", with: "")

                    var isProtocol = false
                    let startIdx = m.range(at: 1).location
                    if startIdx >= 4 {
                        let prevRange = NSRange(location: startIdx - 4, length: 4)
                        if let r = Range(prevRange, in: outputCode) {
                            let prevStr = String(outputCode[r])
                            if prevStr == "any " || prevStr.hasSuffix("any\t") {
                                isProtocol = true
                            }
                        }
                    }

                    var genericCount = 0
                    let endIdx = m.range(at: 1).location + m.range(at: 1).length
                    if endIdx < outputCode.count {
                        var scan = endIdx
                        while scan < chars.count && chars[scan].isWhitespace {
                            scan += 1
                        }
                        if scan < chars.count && chars[scan] == "<" {
                            var depth = 1
                            var commas = 0
                            scan += 1
                            while scan < chars.count && depth > 0 {
                                if chars[scan] == "<" { depth += 1 }
                                else if chars[scan] == ">" { depth -= 1 }
                                else if chars[scan] == "," && depth == 1 { commas += 1 }
                                scan += 1
                            }
                            if depth == 0 {
                                genericCount = commas + 1
                            }
                        }
                    }
                    
                    let parts = typeName.components(separatedBy: ".")
                    let mod = parts[0]
                    let sdkRoot = ConfigManager.sdkRoot
                    var isPrivateFw = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(mod).framework") ||
                                      FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(mod).framework")
                    // Also recognize pseudo-module names like `KnownFw_Suffix` (e.g.
                    // `IntelligencePlatformLibrary_AppleInternal`), which are private submodules
                    // not present as standalone .framework bundles.
                    if !isPrivateFw, let underIdx = mod.firstIndex(of: "_") {
                        let baseMod = String(mod[mod.startIndex..<underIdx])
                        if FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(baseMod).framework") ||
                           FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(baseMod).framework") {
                            isPrivateFw = true
                        }
                    }
                    // Skip types the current module itself declares via extension on another
                    // module's type (e.g. TokenGeneration.Prompt.RenderedPromptFragment,
                    // injected by our own stdlibTypeExtensions mechanism) — these aren't real
                    // members of that external module, so stubbing them here would re-declare
                    // them and create a genuine ambiguous-lookup conflict with our own
                    // extension-injected declaration.
                    let isSelfDeclaredExtension = selfDeclaredExtensionTypes.contains {
                        typeName == $0 || typeName.hasPrefix($0 + ".")
                    }
                    if isPrivateFw && mod != currentModule && !isSelfDeclaredExtension {
                        var isProto = isProtocol
                        if constraintTypes.contains(typeName) || constraintTypes.contains(parts.dropFirst().joined(separator: ".")) {
                            isProto = true
                        }
                        externalTypes[mod, default: []].append((typeName: typeName, isProtocol: isProto, genericCount: genericCount))
                    }
                }
            }
        }
        
        var queue = [String]()
        for (mod, items) in externalTypes {
            for item in items {
                var cleanName = item.typeName
                if cleanName.hasPrefix("\(mod).") {
                    cleanName = String(cleanName.dropFirst(mod.count + 1))
                }
                queue.append("\(mod).\(cleanName)")
            }
        }
        var visited = Set(queue)
        var qIndex = 0
        while qIndex < queue.count {
            let fullTypeName = queue[qIndex]
            qIndex += 1
            
            let parts = fullTypeName.components(separatedBy: ".")
            let mod = parts[0]
            let path = Array(parts.dropFirst())
            
            if let node = parser.findTypeNode(module: mod, path: path) {
                for conf in node.conformances {
                    let cleanConf = conf.replacingOccurrences(of: "any ", with: "")
                    let confParts = cleanConf.components(separatedBy: ".")
                    guard confParts.count >= 2 else { continue }
                    let confMod = confParts[0]
                    
                    let sdkRoot = ConfigManager.sdkRoot
                    let isPrivate = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(confMod).framework") ||
                                    FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(confMod).framework")
                    
                    if isPrivate && confMod != currentModule {
                        let confName = confParts.dropFirst().joined(separator: ".")
                        let fullConfName = "\(confMod).\(confName)"
                        let isSelfDeclaredExt = selfDeclaredExtensionTypes.contains {
                            fullConfName == $0 || fullConfName.hasPrefix($0 + ".")
                        }
                        if !visited.contains(fullConfName) && !isSelfDeclaredExt {
                            visited.insert(fullConfName)
                            queue.append(fullConfName)
                            
                            var isProto = false
                            if let confNode = parser.findTypeNode(module: confMod, path: Array(confParts.dropFirst())) {
                                isProto = (confNode.kind == "protocol")
                            } else {
                                isProto = confName.contains("Representable") || confName.contains("Protocol") || confName.contains("Delegate")
                            }
                            externalTypes[confMod, default: []].append((typeName: fullConfName, isProtocol: isProto, genericCount: 0))
                        }
                    }
                }
            }
        }
        
        var protocolAssociatedTypes = [String: Set<String>]()
        
        let declPattern = "(class|struct|enum|protocol)\\s+([a-zA-Z0-9_$]+)\\s*(?:<[^>]+>)?\\s*:\\s*([^{]+)"
        if let regex = try? NSRegularExpression(pattern: declPattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let kindRange = Range(m.range(at: 1), in: outputCode),
                   let listRange = Range(m.range(at: 3), in: outputCode) {
                    let kind = String(outputCode[kindRange])
                    let listStr = String(outputCode[listRange])
                    let inherits = listStr.components(separatedBy: ",")
                    for (idx, item) in inherits.enumerated() {
                        let cleanItem = item.trimmingCharacters(in: .whitespacesAndNewlines)
                        if kind == "struct" || kind == "enum" || kind == "protocol" || idx > 0 {
                            let cleanProto = cleanItem.replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            protocolAssociatedTypes[cleanProto] = protocolAssociatedTypes[cleanProto] ?? Set<String>()
                        }
                    }
                }
            }
        }
        // Scan "extension Module.TypeName where TypeName.AssocType == X" patterns to extract
        // associated types for external protocols used as extension targets.
        let extWherePattern = "extension\\s+([A-Za-z_][A-Za-z0-9_.]+)\\s+where\\s+([A-Za-z_][A-Za-z0-9_.]+)\\.([A-Za-z_][A-Za-z0-9_]+)"
        if let regex = try? NSRegularExpression(pattern: extWherePattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let typeRange = Range(m.range(at: 1), in: outputCode),
                   let assocRange = Range(m.range(at: 3), in: outputCode) {
                    let typeName = String(outputCode[typeRange])
                    let assocName = String(outputCode[assocRange])
                    let shortName = typeName.components(separatedBy: ".").last ?? typeName
                    protocolAssociatedTypes[typeName, default: []].insert(assocName)
                    protocolAssociatedTypes[shortName, default: []].insert(assocName)
                }
            }
        }

        let wherePattern = "where\\s+([^\\{]+)"
        if let regex = try? NSRegularExpression(pattern: wherePattern, options: []) {
            let nsRange = NSRange(outputCode.startIndex..<outputCode.endIndex, in: outputCode)
            let matches = regex.matches(in: outputCode, options: [], range: nsRange)
            for m in matches {
                if let range = Range(m.range(at: 1), in: outputCode) {
                    let constraintsStr = String(outputCode[range])
                    let individual = constraintsStr.components(separatedBy: ",")
                    var typeToProtocol = [String: String]()
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(":") {
                            let subParts = trimmed.components(separatedBy: ":")
                            if subParts.count == 2 {
                                let lhs = subParts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                                let rhs = subParts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                                if lhs.count <= 3 {
                                    let cleanProto = rhs.replacingOccurrences(of: "any ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                    typeToProtocol[lhs] = cleanProto
                                }
                            }
                        }
                    }
                    for c in individual {
                        let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.contains(".") {
                            var clean = trimmed.replacingOccurrences(of: ":", with: " ")
                            clean = clean.replacingOccurrences(of: "==", with: " ")
                            let firstWord = clean.components(separatedBy: " ").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            if firstWord.contains(".") {
                                let subParts = firstWord.components(separatedBy: ".")
                                if subParts.count == 2 {
                                    let lhs = subParts[0]
                                    let rhs = subParts[1]
                                    if let proto = typeToProtocol[lhs] {
                                        protocolAssociatedTypes[proto, default: []].insert(rhs)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let fm = FileManager.default
        try? fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)

        // Pre-load type kind info from dependency TBD files so StubNode gets the correct
        // struct/enum/class keyword instead of defaulting to struct.
        let sdkRoot = ConfigManager.sdkRoot
        let tbdSearchPaths = [
            "\(sdkRoot)/System/Library/PrivateFrameworks",
            "\(sdkRoot)/System/Library/SubFrameworks",
            "\(sdkRoot)/System/Library/Frameworks"
        ]

        // Loading a dependency's own .tbd and enriching it with real members (below) can reveal
        // that one of its real member signatures references a THIRD module's type/protocol that
        // was never part of the original externalTypes scan (nothing in the target's own
        // interface ever mentioned it) — e.g. IntelligencePlatformLibrary's real members
        // reference BiomeStreams.DataResource, but BiomeStreams was never otherwise discovered
        // as a dependency of TokenGenerationCore. Loop: load+enrich every currently-known
        // module, scan the newly-enriched real member signatures for private-framework type
        // references, add any newly-discovered ones to externalTypes, and repeat until a full
        // pass finds nothing new (fixed point) or a safety cap is hit — mirroring
        // orchestrate.py's own build_framework rescan loop (max_rescan_passes), which solves a
        // structurally similar "discovered too late" problem one level up, at the process level.
        var processedTbdModules = Set<String>()
        let maxTransitiveDepth = 10
        for _ in 0..<maxTransitiveDepth {
            let modsToLoad = Set(externalTypes.keys).subtracting(processedTbdModules)
            if modsToLoad.isEmpty { break }

            for mod in modsToLoad {
                processedTbdModules.insert(mod)
                var tbdContent: String? = nil
                for searchPath in tbdSearchPaths {
                    let paths = [
                        "\(searchPath)/\(mod).framework/\(mod).tbd",
                        "\(searchPath)/\(mod).framework/Versions/A/\(mod).tbd",
                        "\(searchPath)/\(mod).framework/Versions/Current/\(mod).tbd"
                    ]
                    for p in paths {
                        if let c = try? String(contentsOfFile: p, encoding: .utf8) {
                            tbdContent = c; break
                        }
                    }
                    if tbdContent != nil { break }
                }
                guard let content = tbdContent else { continue }
                // A dependency's own .tbd can itself be a multi-document file if IT has
                // reexported-libraries (e.g. GenerativeFunctionsFoundation.tbd's second document
                // is actually PromptKit's re-exported symbol table, install-name and all).
                // Scanning the whole raw file (as opposed to just this dependency's own first
                // document) misattributes a reexported library's real, standalone symbols to
                // this dependency -- e.g. GenerativeFunctionsFoundation.tbd's doc2 exports
                // PromptKit.RecursiveSchema.Options's nominal-type-descriptor symbol as a
                // genuine current export, making it look like GenerativeFunctionsFoundation's
                // own ABI proof the type is real there, when it's actually only real in
                // PromptKit's document. Isolate this dependency's own first document exactly
                // like main.swift's `ownDocument` does for the primary target (line ~35).
                let ownDepDocument = content.components(separatedBy: "--- !tapi-tbd").dropFirst().first.map { "--- !tapi-tbd" + $0 } ?? content
                let depSymbols = extractSymbols(from: ownDepDocument)
                var depDemangledMap: [(mangled: String, demangled: String)] = []
                for sym in depSymbols {
                    if let dem = demangle(symbol: sym) {
                        depDemangledMap.append((mangled: sym, demangled: dem))
                    }
                }
                parser.discoverNominalTypes(demangledMap: depDemangledMap, currentModule: mod)
                // A dependency's own real members can reference an ObjC class (mangled "So...C",
                // e.g. IntelligencePlatformLibrary's BMSQLColumn) that's only ever registered via
                // this same objc-classes:-scanning mechanism (used at real-target-processing time
                // for the primary target and its depth-1 reexported libraries, main.swift ~51/60)
                // — without it, the class is genuinely undeclared anywhere and the enriched
                // member referencing it fails to compile. Register under "__C" (matching the
                // reexported-library convention) so it's visible bare, unqualified, exactly like
                // any other ObjC-bridged type.
                registerObjcClasses(from: content, parser: parser, module: "__C")

                // Additionally run this dependency's own symbols through the SAME
                // precompute/default-argument-prepass/parse pipeline used for the real target
                // (processSymbols), so its real members land in TypeNode.members instead of
                // being silently dropped. parse() gates member routing on
                // `getTopLevelModule(for: node) == primaryTargetModule` (Parser.swift) — with
                // primaryTargetModule/defaultModule still pointing at the top-level target,
                // every declaration native to this dependency looks "external" and never
                // reaches `.members`. Temporarily repoint both (defaultModule is read
                // pervasively by TypeNode.generateCode, not just primaryTargetModule) at the
                // dependency while processing its symbols, then restore.
                //
                // Known accepted gap: processSymbols() no-ops if parser.processedModules
                // already contains `mod` (e.g. it was already pulled in once as a depth-1
                // reexported library of the real target, under the WRONG primaryTargetModule) —
                // such a dependency silently falls back to the empty-skeleton stub below rather
                // than being force-reprocessed, since forcing a second pass over accumulating
                // parser state (tbdSymbols, symbolEscapingMap, defaultArgMap) not designed for
                // multiple passes over one module risks corrupting it in ways that are harder to
                // reason about than the empty-skeleton fallback this replaces.
                if !parser.processedModules.contains(mod) {
                    let savedPrimaryTarget = parser.primaryTargetModule
                    let savedDefaultModule = parser.defaultModule
                    let savedPrecomputeModule = parser.currentPrecomputeModule
                    // ownTbdSymbols only gets populated at depth 0 (processSymbols) -- but this
                    // call is always depth 1, so a member/extension this dependency's own real
                    // ABI moved via @_originallyDefinedIn (e.g. PromptKit's RecursiveSchema.
                    // Options.init(rawValue:), which really lives in PromptKit's OWN .tbd, not
                    // GenerativeFunctionsFoundation's) never satisfies originallyDefinedInExtensions'
                    // `ownTbdSymbols.contains(mangled)` check here, even though primaryTargetModule
                    // is correctly repointed at `mod` a few lines below. Temporarily add this
                    // dependency's own symbols so that check succeeds for symbols genuinely
                    // exported by `mod`'s own .tbd, then restore -- must not leak into the real
                    // target's own ownTbdSymbols, which drives Stage F's cross-target movedFromModule
                    // detection for OTHER modules and would misfire if left polluted.
                    let savedOwnTbdSymbols = parser.ownTbdSymbols
                    parser.ownTbdSymbols.formUnion(depSymbols)
                    parser.primaryTargetModule = mod
                    parser.defaultModule = mod
                    processSymbols(depSymbols, parser: parser, module: mod, depth: 1)
                    parser.primaryTargetModule = savedPrimaryTarget
                    parser.defaultModule = savedDefaultModule
                    parser.currentPrecomputeModule = savedPrecomputeModule
                    parser.ownTbdSymbols = savedOwnTbdSymbols
                }
            }

            // Scan every enriched module's real member signatures AND conformances for
            // private-framework type references not yet in externalTypes, using the same
            // dotted-path pattern used to scan the target's own interface further up this
            // function — this replaces the old one-shot conformance-only BFS (which only ever
            // walked the ORIGINAL externalTypes, before any dependency enrichment existed) by
            // running every pass against the current, growing externalTypes set instead.
            var foundNewTypeInThisPass = false
            func collectMemberSignatureText(_ node: TypeNode) -> String {
                var text = node.conformances.joined(separator: "\n") + "\n"
                for member in node.members.values {
                    switch member {
                    case .initializer(let s): text += s + "\n"
                    case .method(_, let s, _): text += s + "\n"
                    case .property(_, let t, _, _): text += t + "\n"
                    case .enumCase(_, let payload, _): text += (payload ?? "") + "\n"
                    case .associatedType(let s): text += s + "\n"
                    case .other: break
                    }
                }
                for nested in node.nestedTypes.values {
                    text += collectMemberSignatureText(nested)
                }
                return text
            }
            for mod in Set(externalTypes.keys) {
                guard let modNode = parser.modules[mod] else { continue }
                for topType in modNode.nestedTypes.values {
                    let text = collectMemberSignatureText(topType)
                    guard !text.isEmpty else { continue }
                    // The type-name capture (group 2) allows a leading underscore (e.g.
                    // GenerativeFunctions._StreamSanitizer) -- Swift's ABI-internal protocol
                    // naming convention prefixes some real, publicly-referenceable protocols
                    // with "_", and requiring an uppercase first character silently excluded
                    // them from transitive discovery, leaving the referencing module's own
                    // conformance unresolvable.
                    if let regex = try? NSRegularExpression(pattern: "(?<!\\.)\\b([A-Z][a-zA-Z0-9_$]*)\\.(_?[A-Z][a-zA-Z0-9_]*(?:\\._?[A-Z][a-zA-Z0-9_]*)*)", options: []) {
                        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
                        for m in regex.matches(in: text, options: [], range: nsRange) {
                            guard let modRange = Range(m.range(at: 1), in: text),
                                  let restRange = Range(m.range(at: 2), in: text) else { continue }
                            let refMod = String(text[modRange])
                            guard refMod != mod, refMod != currentModule, refMod != "Swift", refMod != "Foundation" else { continue }
                            let isPrivateFw = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(refMod).framework") ||
                                              FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(refMod).framework")
                            guard isPrivateFw else { continue }
                            // Keep the FULL dotted path (e.g. "BiomeStreams.LibraryArtifact.
                            // DataArtifact"), matching how the original target-interface scan
                            // (pathPattern, above) captures nested-type references — a namespace-
                            // only type like LibraryArtifact can have zero symbols of its own
                            // (no nominal type descriptor), existing purely as a path prefix for
                            // its real nested case-types, so truncating to the first segment
                            // would stub an empty, disconnected LibraryArtifact and never
                            // discover DataArtifact/Table as their own StubNode entries.
                            let fullPath = String(text[restRange])
                            let fullTypeName = "\(refMod).\(fullPath)"
                            let isSelfDeclaredExt = selfDeclaredExtensionTypes.contains {
                                fullTypeName == $0 || fullTypeName.hasPrefix($0 + ".")
                            }
                            let alreadyKnown = (externalTypes[refMod] ?? []).contains { $0.typeName == fullTypeName }
                            if !alreadyKnown && !isSelfDeclaredExt {
                                var isProto = false
                                if let confNode = parser.findTypeNode(module: refMod, path: fullPath.components(separatedBy: ".")) {
                                    isProto = (confNode.kind == "protocol")
                                }
                                externalTypes[refMod, default: []].append((typeName: fullTypeName, isProtocol: isProto, genericCount: 0))
                                foundNewTypeInThisPass = true
                            }
                        }
                    }
                }
            }
            if !foundNewTypeInThisPass && modsToLoad.isEmpty { break }
        }

        // Collected across ALL modules' hoists below — a protocol hoisted out of ITS OWN
        // module's nested path (e.g. BiomeStreams.LibraryArtifact.DataArtifact ->
        // BiomeStreams.DataArtifact) must also be rewritten wherever a DIFFERENT module's stub
        // (e.g. IntelligencePlatformLibrary) references the original nested path, so the rename
        // is applied as a final pass over every generated fileContent, after all modules have
        // been processed and all hoists are known.
        var allHoistedProtocolRenames = [(originalDottedPath: String, name: String)]()
        var fileContentsByModule = [String: String]()

        for (mod, items) in externalTypes {
            if ConfigManager.verbose { print("Stubbing: \(mod) has \(items.count) items: \(items.map { $0.typeName })", to: &Self.standardError) }
            var fileContent = "import Foundation\n\n"
            let root = StubNode(name: mod)
            for item in items {
                let parts = item.typeName.components(separatedBy: ".")
                var current = root
                var pathSoFar = [String]()
                for part in parts.dropFirst() {
                    pathSoFar.append(part)
                    if current.nested[part] == nil {
                        let node = StubNode(name: part)
                        node.originalPath = pathSoFar
                        if let typeNode = parser.findTypeNode(module: mod, path: pathSoFar) {
                            node.kind = typeNode.kind
                            node.conformances = typeNode.conformances.compactMap { conf in
                                let clean = conf.hasPrefix(mod + ".") ? String(conf.dropFirst(mod.count + 1)) : conf
                                let noAny = clean.replacingOccurrences(of: "any ", with: "")
                                
                                let rawNoAny = conf.replacingOccurrences(of: "any ", with: "")
                                let isSwift = rawNoAny.hasPrefix("Swift.") || ["Equatable", "Hashable", "Codable", "Decodable", "Encodable", "Sendable", "Error", "CustomStringConvertible", "Comparable", "Sequence", "Collection", "Strideable", "Numeric", "SignedNumeric", "AdditiveArithmetic", "FloatingPoint", "BinaryFloatingPoint", "LosslessStringConvertible", "CaseIterable", "RawRepresentable", "CodingKey", "LocalizedError"].contains(noAny)
                                let isFoundation = rawNoAny.hasPrefix("Foundation.")
                                
                                if isSwift || isFoundation {
                                    var baseName = noAny
                                    if baseName.hasPrefix("Swift.") {
                                        baseName = String(baseName.dropFirst(6))
                                    }
                                    if baseName.hasPrefix("Foundation.") {
                                        baseName = String(baseName.dropFirst(11))
                                    }
                                    let whitelist = ["Equatable", "Hashable", "Codable", "Decodable", "Encodable", "Sendable", "Error"]
                                    if whitelist.contains(baseName) {
                                        return baseName
                                    } else {
                                        return nil
                                    }
                                }
                                
                                if noAny.contains("ExpressibleBy") {
                                    return nil
                                }
                                // A still dot-qualified conformance (e.g. "GenerativeFunctionsFoundation.
                                // ChatLanguageModelResponseStringStreamString") whose owning module is
                                // circular relative to `mod` is exactly as unresolvable here as the
                                // bare-name case handled below -- this memberless StubNode fallback
                                // never goes through renderEnrichedType's own circular-line filter, so
                                // without this check a genuinely circular qualified reference survives
                                // verbatim into the stub (confirmed via TokenGeneration.Token, whose
                                // GenerativeFunctionsFoundation-qualified conformance list compiled fine
                                // in isolation but failed once GenerativeFunctionsFoundation joined the
                                // detected stub-import cycle and its own dependency stub -- which this
                                // Token reference needs -- stopped being importable here).
                                if let dotIdx = noAny.range(of: ".", options: .backwards) {
                                    let owningModule = String(noAny[..<dotIdx.lowerBound])
                                    if owningModule != mod {
                                        var circularModules = Set([currentModule])
                                        if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
                                            circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
                                        }
                                        if circularModules.contains(owningModule) {
                                            return nil
                                        }
                                    }
                                }
                                // Filter out conformances to protocols defined in the target module
                                // (currentModule). simplifyType strips the currentModule prefix, so
                                // e.g. TokenGenerationCore.XPCRevivable becomes bare XPCRevivable
                                // which doesn't exist when compiling this dependency stub in isolation.
                                if !noAny.contains(".") || noAny.hasPrefix(currentModule + ".") {
                                    if let targetModule = parser.modules[currentModule] {
                                        let shortName = noAny.components(separatedBy: ".").last ?? noAny
                                        if let protoNode = targetModule.nestedTypes[shortName], protoNode.kind == "protocol" {
                                            return nil
                                        }
                                    }
                                }
                                // This memberless StubNode fallback path (its type had no real
                                // members/nested types, so renderEnrichedType's own circular
                                // filter -- which only ever runs on real enriched member/decl
                                // text -- never gets a chance to see this conformance at all) can
                                // still carry a bare protocol name whose owning module differs
                                // from `mod` -- e.g. GenerativeModelsFoundation.SelfAttention
                                // conforming to PromptKit.PromptComponentValueConvertible, already
                                // stripped bare by Model.swift's discoveredProtocols-driven
                                // qualifier stripping. If that owning module is circular relative
                                // to `mod` (PromptKit imports GenerativeModelsFoundation, so a
                                // GenerativeModelsFoundation stub can't import PromptKit back),
                                // drop the conformance exactly like renderEnrichedType does for
                                // circular bare protocol references on a real-enriched type.
                                if !noAny.contains("."), noAny != "AnyObject",
                                   let qualifiedMatch = parser.discoveredProtocols.first(where: { $0.hasSuffix("." + noAny) }) {
                                    let owningModule = String(qualifiedMatch.dropLast(noAny.count + 1))
                                    if owningModule != mod {
                                        var circularModules = Set([currentModule])
                                        if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
                                            circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
                                        }
                                        if circularModules.contains(owningModule) {
                                            return nil
                                        }
                                    }
                                }
                                return noAny
                            }
                        }
                        // AppleIntelligenceReporting's BiomeEventReporter.lazySource<A>/
                        // lazySourceInternal<A> declare "where A: Stream" (confirmed via real
                        // ABI mangling — see the comment at the "lazySource<A> {" replacement
                        // above), and every concrete Stream-typed generic argument (Availability,
                        // Buddy, MobileAsset, etc., all nested under
                        // IntelligencePlatformLibrary(_AppleInternal).Library/InternalLibrary.
                        // Streams...) must conform to Stream NATIVELY in this stub module, not
                        // via a retroactive extension declared in AppleIntelligenceReporting —
                        // a cross-module retroactive conformance forces an extra protocol-
                        // witness-table mangling substitution the real ABI doesn't have.
                        if currentModule == "AppleIntelligenceReporting",
                           (mod == "IntelligencePlatformLibrary" || mod == "IntelligencePlatformLibrary_AppleInternal"),
                           ["Availability", "Buddy", "MobileAsset", "MobileAssetVerbose", "ModelCatalog",
                            "SoftwareUpdateController", "UnifiedAssetFramework", "Step", "InstrumentationEvent",
                            "ModelIO"].contains(part) {
                            node.conformances.append("Stream")
                            // If this type ends up rendered from real, enriched member data
                            // (generateCode(), not this StubNode's own generateSwift()), the
                            // conformance injected above onto the StubNode never reaches the
                            // actual output — generateCode() reads TypeNode.conformances, a
                            // separate set. Mirror the injection onto the real TypeNode too.
                            if let realTypeNode = parser.findTypeNode(module: mod, path: pathSoFar) {
                                realTypeNode.conformances.insert("Stream")
                            }
                        }
                        // IntelligencePlatformLibrary_AppleInternal.InternalLibrary.Streams.
                        // AppleIntelligence.Reporting.ModelIO has zero real ABI ground truth
                        // anywhere (this synthetic module has no real .tbd at all), so
                        // parser.findTypeNode above never resolves a kind for it and it falls
                        // through to StubNode's "struct" default — but the real symbol mangles
                        // this whole namespace-only path as "O" (enum), matching the sibling
                        // IntelligencePlatformLibrary module's real, ABI-confirmed convention
                        // for the exact same "Library.Streams.AppleIntelligence.Reporting.*"
                        // hierarchy (which DOES have real .tbd data proving it's enums). Match
                        // that established convention for the corresponding _AppleInternal path
                        // instead of defaulting to struct.
                        if currentModule == "AppleIntelligenceReporting",
                           mod == "IntelligencePlatformLibrary_AppleInternal",
                           ["InternalLibrary", "Streams", "AppleIntelligence", "Reporting", "ModelIO"].contains(part),
                           node.kind == "struct" {
                            node.kind = "enum"
                        }
                        current.nested[part] = node
                    }
                    current = current.nested[part]!
                }
                if item.isProtocol || current.kind == "protocol" {
                    current.isProtocol = true
                }
                current.genericCount = max(current.genericCount, item.genericCount)
            }
            
            var topLevelProtocols = [StubNode]()
            var topLevelTypes = [StubNode]()

            for child in root.nested.values {
                let fullPath = "\(mod).\(child.name)"
                if child.isProtocol || child.kind == "protocol" || protocolAssociatedTypes[fullPath] != nil ||
                   ["Visitor", "Decoder", "Encoder", "Message", "Enum", "Stream"].contains(child.name) ||
                   child.name.hasSuffix("Protocol") || child.name.hasSuffix("Providing") || child.name.hasSuffix("Delegate") {
                    child.isProtocol = true
                    if !topLevelProtocols.contains(where: { $0.name == child.name }) {
                        topLevelProtocols.append(child)
                    }
                } else {
                    topLevelTypes.append(child)
                }
            }

            // Swift never permits a type declaration nested inside a protocol body (unlike
            // struct/class/enum, which can all nest each other and protocols freely) — a
            // protocol-kind StubNode discovered several nesting levels deep (e.g.
            // BiomeStreams.LibraryArtifact.DataArtifact, a protocol nested under the
            // namespace-only enum LibraryArtifact) must be hoisted out to a top-level
            // declaration instead of staying in its parent's `nested` dict, or the emitted stub
            // fails to compile ("type 'X' cannot be nested in protocol"/"cannot be nested in
            // struct" etc. for whatever nests it). Walk every top-level type's descendants,
            // remove any protocol-kind node from its parent, and promote it into
            // topLevelProtocols under its own top-level StubNode name (StubNode.name is only
            // the LEAF segment, so promoted protocols keep their real short name — a same-named
            // collision across two different nesting paths is deduplicated by name).
            func hoistNestedProtocols(_ node: StubNode, pathSoFar: [String]) {
                for (key, child) in node.nested {
                    let childPath = pathSoFar + [child.name]
                    if child.isProtocol || child.kind == "protocol" {
                        node.nested.removeValue(forKey: key)
                        if !topLevelProtocols.contains(where: { $0.name == child.name }) {
                            topLevelProtocols.append(child)
                        }
                        allHoistedProtocolRenames.append((originalDottedPath: "\(mod).\(childPath.joined(separator: "."))", name: child.name))
                    } else {
                        hoistNestedProtocols(child, pathSoFar: childPath)
                    }
                }
            }
            for t in topLevelTypes {
                hoistNestedProtocols(t, pathSoFar: [t.name])
            }
            
            for proto in topLevelProtocols.sorted(by: { $0.name < $1.name }) {
                let lookupPath = proto.originalPath.isEmpty ? [proto.name] : proto.originalPath
                if let realNode = parser.findTypeNode(module: mod, path: lookupPath), !realNode.members.isEmpty {
                    let code = renderEnrichedType(realNode, mod: mod, currentModule: currentModule, parser: parser, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
                    fileContent += code + "\n"
                } else {
                    let fullPath = "\(mod).\(proto.name)"
                var genericDecl = ""
                var assocDecl = ""
                var placeholderNames = Set<String>()
                if proto.genericCount > 0 {
                    let placeholders = ["A", "B", "C", "D", "E"]
                    let count = min(proto.genericCount, placeholders.count)
                    var names = Array(placeholders[..<count])
                    // A single-primary-associated-type protocol's real name (recovered from
                    // real usage sites — see primaryAssociatedTypeNames) must be used verbatim:
                    // the mangled ABI symbol encodes the associated type's actual declared name,
                    // not just its position, so a bare "A" placeholder here would never match.
                    if count == 1, let realName = primaryAssociatedTypeNames[proto.name] {
                        names = [realName]
                    }
                    genericDecl = "<" + names.joined(separator: ", ") + ">"
                    placeholderNames = Set(names)
                    for name in names {
                        assocDecl += "    associatedtype \(name)\n"
                    }
                }
                fileContent += "public protocol \(proto.name)\(genericDecl) {\n"
                fileContent += assocDecl
                if let assocTypes = protocolAssociatedTypes[fullPath] {
                    for assoc in assocTypes.sorted() {
                        if !placeholderNames.contains(assoc) {
                            fileContent += "    associatedtype \(assoc)\n"
                        }
                    }
                }
                if proto.name == "Stream" {
                    fileContent += "    associatedtype EventType\n"
                }
                fileContent += "}\n\n"
                }
            }
            
            for t in topLevelTypes.sorted(by: { $0.name < $1.name }) {
                // If this dependency was additionally run through the real parse() pipeline
                // above, its TypeNode carries real members/nested types (generateCode()
                // self-recurses into nestedTypes, so a single top-level call renders the whole
                // nested tree) — render those instead of StubNode's empty-skeleton fallback, so
                // the stub's ABI shape actually matches the real dependency.
                if let realNode = parser.findTypeNode(module: mod, path: [t.name]), (!realNode.members.isEmpty || !realNode.nestedTypes.isEmpty) {
                    let code = renderEnrichedType(realNode, mod: mod, currentModule: currentModule, parser: parser, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
                    fileContent += code + "\n"
                } else {
                    fileContent += t.generateSwift(depth: 0) + "\n"
                }
            }

            // Enriching a type with real members (above) can surface a bare reference to a
            // SIBLING type/protocol declared in this SAME module (mod) that was never part of
            // the original externalTypes scan, because nothing in the target's own interface
            // ever mentioned it as dotted "mod.Foo" text — e.g. IntelligencePlatformLibrary's
            // real StreamResource protocol, referenced bare ("any StreamResource.Type") from an
            // enriched member, with no other type in this stub ever conforming to or importing
            // it. Do a same-module closure pass: scan the assembled body for bare capitalized
            // identifiers not already declared here, and if parser has real (enriched) data for
            // that name under `mod`, emit its declaration too. This does not reach into a THIRD
            // module's own incomplete stub (that cross-module case is a distinct, larger problem
            // — see the import-inference comment below, which papers over it with a plain
            // "import Qualifier" instead of a real declaration).
            var knownStubTypeNames = Set(topLevelTypes.map { $0.name } + topLevelProtocols.map { $0.name })
            var closurePassBudget = 20
            while closurePassBudget > 0 {
                closurePassBudget -= 1
                var newlyFound = [String]()
                var newlyFoundObjc = [String]()
                var newlyFoundOpaqueStruct = [String]()
                // A same-module reference discovered via the enrichment pass (renderEnrichedType)
                // can be permanently baked into its cached signature string as "mod.Name" — the
                // TypeNode's member-signature text is computed once under whatever defaultModule
                // was active at first parse and reused verbatim (see requalifyBareForeignTypeNames'
                // header comment for the general shape of this caching quirk) — so a bare-identifier
                // scan alone misses it. Allow an optional "<mod>." qualifier directly before the
                // identifier without excluding it (unlike a genuinely foreign "OtherMod.Name",
                // which must stay excluded so this pass doesn't reach into a third module's stub).
                let qualifiedModPrefix = "(?:\(NSRegularExpression.escapedPattern(for: mod))\\.)?"
                if let bareIdentRegex = try? NSRegularExpression(pattern: "(?<![.A-Za-z0-9_])\(qualifiedModPrefix)([A-Z][A-Za-z0-9_]*)\\b", options: []) {
                    let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                    for m in bareIdentRegex.matches(in: fileContent, options: [], range: nsRange) {
                        if let range = Range(m.range(at: 1), in: fileContent) {
                            let name = String(fileContent[range])
                            guard !knownStubTypeNames.contains(name), name != mod, name != "Swift", name != "Foundation" else { continue }
                            // These bare names are real system-framework types that get a real
                            // "import <Framework>" below (mirroring resolveImports) rather than
                            // an opaque local placeholder — declaring both would be ambiguous.
                            let hasRealSystemFrameworkImport = ["IOSurface", "OSAllocatedUnfairLock", "CVPixelBuffer", "CVBuffer", "CMTime"].contains(name)
                            if hasRealSystemFrameworkImport {
                                knownStubTypeNames.insert(name)
                            } else if parser.systemTypes.contains(name) {
                                // A real TypeNode can exist under `mod` for a bare name that's
                                // ALSO a genuine Swift/Foundation system type (e.g. ModelCatalog's
                                // own ABI declares a "ModelCatalog.NSNumber" class purely because
                                // its symbols return the real Foundation.NSNumber under that
                                // qualifier — not because ModelCatalog owns a distinct NSNumber).
                                // Declaring a local stub here would collide with the real
                                // Foundation type already visible via "import Foundation"
                                // ("'NSNumber' is ambiguous for type lookup"). Leave it as the
                                // real system type; no stub, no import needed.
                                knownStubTypeNames.insert(name)
                            } else if parser.findTypeNode(module: mod, path: [name]) != nil {
                                // Any other real TypeNode discovered under this module qualifies,
                                // not just ones with real members or protocols -- a bare-
                                // referenced sibling type can be a genuine, real ABI type with NO
                                // members at all (e.g. ODIE.SharedMutableBytes, an opaque
                                // `@objc deinit`-only class referenced from
                                // Tensor.SharedStorageBacking.bytes), and skipping it here left
                                // the stub referencing a type it never declares ("cannot find
                                // type 'SharedMutableBytes' in scope"). generateCode()/
                                // renderEnrichedType() already render a memberless type correctly
                                // as an empty `class/struct/enum Name {}`.
                                newlyFound.append(name)
                            } else if parser.findTypeNode(module: "__C", path: [name]) != nil {
                                // A bare ObjC class (registered under "__C" above) referenced by
                                // an enriched member — no Swift-visible declaration exists
                                // anywhere for it beyond its bare name, so a minimal opaque
                                // placeholder is the correct (not just expedient) fix here, not
                                // a workaround: this mirrors how the real target itself renders
                                // an ObjC-bridged type it can't otherwise describe.
                                newlyFoundObjc.append(name)
                            } else if name == "XPCCodableObject" {
                                // Real ABI-visible (via swift-demangle) as XPC.XPCCodableObject,
                                // but XPC has no swiftinterface/tbd in this SDK at all — the type
                                // is genuinely undeclared anywhere reachable. generateAll() (the
                                // primary-target path) already falls back to a local opaque
                                // struct for this exact case; mirror that here for the dependency-
                                // stub path, which never went through that fallback.
                                newlyFoundOpaqueStruct.append(name)
                            }
                        }
                    }
                }
                if newlyFound.isEmpty && newlyFoundObjc.isEmpty && newlyFoundOpaqueStruct.isEmpty { break }
                for name in Set(newlyFoundObjc) {
                    knownStubTypeNames.insert(name)
                    fileContent += "public class \(name) {}\n"
                }
                for name in Set(newlyFoundOpaqueStruct) {
                    knownStubTypeNames.insert(name)
                    fileContent += "public struct \(name): Hashable, Codable, Sendable {}\n"
                }
                for name in Set(newlyFound) {
                    if knownStubTypeNames.contains(name) { continue }
                    knownStubTypeNames.insert(name)
                    let declPattern = "(?:^|\\n)(?:@[A-Za-z0-9_]+\\s+)*(?:public\\s+|open\\s+)?(?:protocol|struct|class|enum|typealias)\\s+\(name)\\b"
                    if fileContent.range(of: declPattern, options: .regularExpression) != nil { continue }
                    guard let realNode = parser.findTypeNode(module: mod, path: [name]) else { continue }
                    if realNode.kind == "protocol" {
                        fileContent += "public protocol \(name) {}\n"
                    } else {
                        let code = renderEnrichedType(realNode, mod: mod, currentModule: currentModule, parser: parser, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
                        fileContent += code + "\n"
                    }
                }
            }

            // GenerativeModelsFoundation.SelfAttention.toValue()'s real ABI return type demangles
            // as "PromptKit.Prompt.Component.Value" -- but no framework anywhere in this SDK
            // (searched across every PrivateFrameworks .tbd) declares a "Prompt.Component" nested
            // type under ANY module, including TokenGeneration (where "Prompt" itself genuinely
            // lives). This is a residual, unresolvable ABI gap -- same class of issue as the
            // "Generable" protocol reference diagnosed but never fixed in an earlier session
            // (Stage D "graceful degradation", per the dependency-stub-member-enrichment plan,
            // was never implemented). The exact qualifier surviving into fileContent varies by
            // which build pass rendered it (PromptKit.Prompt.Component.Value or, after
            // requalifyBareForeignTypeNames "corrects" it, TokenGeneration.Prompt.Component.Value)
            // -- rather than chase that qualifier, replace either broken reference text with a
            // self-contained local placeholder type, avoiding any ambiguity about which external
            // module's "Prompt" to extend. This MUST run before the extraImports qualifier scan
            // below -- otherwise that scan still sees the bare "PromptKit.Prompt..." text and
            // emits a spurious "import PromptKit" even though the reference is gone afterward,
            // which is what was producing the real PromptKit<->TokenGenerationCore import cycle.
            // Only the bare return-type reference is broken -- "Prompt.Component.Value" is a
            // real, legitimately-declared nested type (see PromptKit.swift's own "public enum
            // Value" under "public struct Component"), and a FURTHER-qualified reference like
            // "...Value.CustomData" (Value's own nested type) must be left alone. A negative
            // lookahead for a trailing "." restricts the replacement to the bare reference.
            for badRef in ["PromptKit.Prompt.Component.Value", "TokenGeneration.Prompt.Component.Value"] {
                if let badRefRegex = try? NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: badRef) + "(?!\\.[A-Za-z])") {
                    let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                    fileContent = badRefRegex.stringByReplacingMatches(in: fileContent, range: nsRange, withTemplate: "SelfAttentionValuePlaceholder")
                }
            }
            if fileContent.containsWord("SelfAttentionValuePlaceholder") {
                fileContent += "\npublic enum SelfAttentionValuePlaceholder {}\n"
            }
            var circularModules = Set([currentModule])
            if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
                circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
            }
            if mod == "GenerativeFunctionsFoundation" {
                if !circularModules.contains("PromptKit") {
                    fileContent = fileContent.replacingOccurrences(
                        of: "public struct ChatMessageResponse<A>: ChatLanguageModelResponse, ChatLanguageModelResponseBase {\n    public var content: A { get { fatalError() } }\n}",
                        with: "public struct ChatMessageResponse<A>: ChatLanguageModelResponse, ChatLanguageModelResponseBase {\n    public var content: A { get { fatalError() } }\n    public var role: PromptKit.ChatMessageRole { get { fatalError() } }\n}"
                    )
                }
            }

            // A stub type's conformance/generic-bound list can reference a THIRD module's
            // type by its qualified name (e.g. "GenerativeFunctionsFoundation.
            // ChatLanguageModelResponseStringStream" showing up while stubbing
            // GenerativeModels, because one of GenerativeModels' own real types conforms to a
            // protocol declared in yet another dependency) without that module ever being
            // discovered as a top-level dependency of THIS stub — only "import Foundation" is
            // ever written unconditionally. Scan the fully-assembled body text for any
            // "Qualifier.Identifier" reference and add a matching import for every distinct
            // capitalized qualifier that isn't Swift/Foundation/this module itself, so the
            // stub actually resolves the cross-module type instead of failing "cannot find
            // type 'X' in scope".
            // Collect every type name this stub itself declares, at any nesting depth, so the
            // qualifier scan below doesn't mistake a nested-type path (e.g.
            // "Prompt.MediaCollectionAttachment.AudioSamples") for a module name and emit a
            // bogus "import AudioSamples" — StubNode.generateSwift's own keyword-escaping
            // (main.swift, "public \(kindKeyword) \(escapedName)...") can backtick-quote a name,
            // so match that optional form too and strip the backticks back off.
            var selfDeclaredStubTypeNames = Set<String>()
            if let declRegex = try? NSRegularExpression(pattern: "public (?:struct|enum|class|protocol) (`[A-Za-z0-9_]+`|[A-Za-z0-9_]+)", options: []) {
                let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                for m in declRegex.matches(in: fileContent, options: [], range: nsRange) {
                    if let range = Range(m.range(at: 1), in: fileContent) {
                        selfDeclaredStubTypeNames.insert(String(fileContent[range]).replacingOccurrences(of: "`", with: ""))
                    }
                }
            }
            // The qualifier must not be preceded by a "." — otherwise a long dotted chain like
            // "BiomeStreams.LibraryArtifact.DataArtifact.Type" gets matched twice by a plain
            // \b-anchored scan (NSRegularExpression matches don't overlap): once correctly for
            // "BiomeStreams", then again starting fresh at "DataArtifact.Type", misreading the
            // nested-type segment "DataArtifact" as if it were its own top-level module
            // qualifier. A "(?<!\\.)" lookbehind restricts matches to the true first segment of
            // each dotted chain.
            var extraImports = Set<String>()
            if let regex = try? NSRegularExpression(pattern: "(?<!\\.)\\b([A-Z][A-Za-z0-9_]*)\\.[A-Z][A-Za-z0-9_]*", options: []) {
                let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                let matches = regex.matches(in: fileContent, options: [], range: nsRange)
                for m in matches {
                    if let range = Range(m.range(at: 1), in: fileContent) {
                        let qualifier = String(fileContent[range])
                        // A bare generic placeholder can appear immediately before a dotted
                        // member/metatype access ("A.Type", "A.Element", "GenericA.Type") in a
                        // real method signature — that's a type-parameter reference, not a
                        // module-qualified type, and must not be treated as an import target.
                        // Covers both this generator's own two placeholder-naming conventions:
                        // the short "A"/"B"/"C"... form (StubNode's own placeholders) and the
                        // "GenericA"/"GenericB"... form (Model.swift's disambiguation rename,
                        // used when a placeholder collides with an in-scope name).
                        let isGenericPlaceholder = (qualifier.count <= 3 &&
                            qualifier.first?.isUppercase == true &&
                            qualifier.dropFirst().allSatisfy { $0.isNumber }) ||
                            (qualifier.hasPrefix("Generic") && qualifier.count <= 9 &&
                             qualifier.dropFirst("Generic".count).allSatisfy { $0.isUppercase || $0.isNumber })
                        // A bare capitalized identifier before a dot can also be a real
                        // Swift/Foundation top-level type (e.g. "Locale.LanguageCode",
                        // "Locale.Language") rather than a module qualifier — Foundation is
                        // always imported unconditionally (main.swift, "import Foundation\n\n"),
                        // so these resolve without any extra import. Only treat the qualifier as
                        // an import target if it's an actual private framework on disk;
                        // otherwise the name is either already visible (Swift/Foundation, or a
                        // sibling type in this same stub) or is a mis-parsed placeholder.
                        let qualifierIsPrivateFramework = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(qualifier).framework") ||
                                                           FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(qualifier).framework") ||
                                                           FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/Frameworks/\(qualifier).framework")
                        if qualifier != "Swift", qualifier != "Foundation", qualifier != mod,
                           qualifier != currentModule,
                           !(circularModules.contains(mod) && circularModules.contains(qualifier)),
                           !isGenericPlaceholder, !selfDeclaredStubTypeNames.contains(qualifier),
                           qualifierIsPrivateFramework {
                            extraImports.insert(qualifier)
                        }
                    }
                }
            }
            // A real member's conformance list can reference a cross-module PROTOCOL by its
            // bare (unqualified) name -- Model.swift's inheritsList-cleaning (TypeNode.init)
            // permanently strips a protocol's module qualifier whenever that protocol's dotted
            // name is present in parser.discoveredProtocols, on the assumption it'll be visible
            // in whatever file the type is finally rendered into. That assumption fails here: a
            // dependency stub is split one-file-per-module, so a bare protocol name declared in
            // a DIFFERENT dependency's stub file (e.g. PromptKit.PromptComponentValueConvertible
            // referenced bare from GenerativeModelsFoundation's real, Stage-B-enriched
            // SelfAttention) is unresolvable without its own explicit import -- there is no
            // "Qualifier." prefix left for the dotted-qualifier scan above to catch. Recover the
            // owning module from discoveredProtocols' dotted form for every bare protocol name
            // that appears as a whole word in this stub's body.
            if let bareWordRegex = try? NSRegularExpression(pattern: "(?<![A-Za-z0-9_$.])[A-Za-z_][A-Za-z0-9_]*", options: []) {
                let nsRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
                var bareWords = Set<String>()
                for m in bareWordRegex.matches(in: fileContent, options: [], range: nsRange) {
                    if let range = Range(m.range, in: fileContent) {
                        bareWords.insert(String(fileContent[range]))
                    }
                }
                for qualifiedProto in parser.discoveredProtocols {
                    guard let dotIdx = qualifiedProto.range(of: ".", options: .backwards) else { continue }
                    let owningModule = String(qualifiedProto[..<dotIdx.lowerBound])
                    let bareName = String(qualifiedProto[dotIdx.upperBound...])
                    guard owningModule != mod, owningModule != "Swift", owningModule != "Foundation",
                          owningModule != currentModule,
                          !(circularModules.contains(mod) && circularModules.contains(owningModule)),
                          !selfDeclaredStubTypeNames.contains(bareName),
                          bareWords.contains(bareName) else { continue }
                    let owningModuleIsPrivateFramework = FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/PrivateFrameworks/\(owningModule).framework") ||
                                                          FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/SubFrameworks/\(owningModule).framework") ||
                                                          FileManager.default.fileExists(atPath: "\(sdkRoot)/System/Library/Frameworks/\(owningModule).framework")
                    guard owningModuleIsPrivateFramework else { continue }
                    extraImports.insert(owningModule)
                }
            }
            // Real member signatures can also reference a system-framework type by its bare
            // (unqualified) name — e.g. "CMTime", "CVBuffer", "IOSurface" — which the
            // dotted-qualifier scan above never catches since there's no "Qualifier." prefix.
            // Mirror resolveImports' (main.swift) same bare-name -> framework mappings for the
            // system frameworks these dependency stubs have been observed to need.
            if fileContent.containsWord("IOSurface") { extraImports.insert("IOSurface") }
            if fileContent.containsWord("OSAllocatedUnfairLock") || fileContent.containsWord("Logger") || fileContent.contains("os.") { extraImports.insert("os") }
            if fileContent.containsWord("CVPixelBuffer") || fileContent.containsWord("CVBuffer") { extraImports.insert("CoreVideo") }
            if fileContent.containsWord("CMTime") { extraImports.insert("CoreMedia") }
            if fileContent.containsWord("MPSCommandBuffer") || fileContent.containsWord("MPSDataType") || fileContent.containsWord("MPSGraph") { extraImports.insert("MetalPerformanceShaders") }
            if !extraImports.isEmpty {
                let importLines = extraImports.sorted().map { "import \($0)\n" }.joined()
                fileContent = fileContent.replacingOccurrences(
                    of: "import Foundation\n\n",
                    with: "import Foundation\n" + importLines + "\n")
            }

            // ModelManagerServices.ClientData is returned across an actor-isolation boundary by
            // TokenGeneration.DictationStreamingPromptRequest.next() (an actor's
            // AsyncIteratorProtocol requirement) -- Swift 6 requires that return type be
            // Sendable, or Codable/Hashable is not enough. The real ClientData almost certainly
            // IS Sendable (Foundation.Data and an opaque XPCCodableObject are its only stored
            // properties, both value-semantic), but its .tbd conformance descriptors don't list
            // Sendable explicitly (implicit derivation isn't ABI-visible). Declare it explicitly
            // wherever this stub renders ClientData's own declaration.
            if mod == "ModelManagerServices" {
                fileContent = fileContent.replacingOccurrences(
                    of: "public struct ClientData: Codable, Hashable {",
                    with: "public struct ClientData: Codable, Hashable, Sendable {")
            }

            // Same GenerativeConfigurationProtocol associated-type gap postProcess() already
            // fixes on PromptKit's own primary-target render path (see the
            // `parser.defaultModule == "PromptKit"` block above) -- postProcess() only runs on
            // that path, not here in the dependency-stub assembly loop, so PromptKit-as-a-
            // dependency (e.g. for TokenGenerationCore) needs the identical typealias injection
            // applied to whatever text this loop actually rendered.
            if mod == "ODIE" {
                if !fileContent.contains("public struct _Profiler") {
                    fileContent += "\npublic struct _Profiler {}\n"
                }
                if !fileContent.contains("public struct _Attribute") {
                    fileContent += "\npublic struct _Attribute {}\n"
                }
            }

            if mod == "PromptKit" {
                fileContent = fileContent.replacingOccurrences(
                    of: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {",
                    with: "public struct ChatMessagesPrompt: ChatMessagesPromptConvertible, Codable, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = ChatMessagesPrompt\n    public typealias PromptContentType = Swift.String")
                fileContent = fileContent.replacingOccurrences(
                    of: "public struct CompletionPrompt: Codable, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByStringInterpolation, Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {",
                    with: "public struct CompletionPrompt: Codable, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByStringInterpolation, Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, GenerativeConfigurationProtocol, PromptMode {\n    public typealias PromptType = CompletionPrompt\n    public typealias PromptContentType = Swift.String")
            }

            // `Network.NWConnection.ConnectionProgressReport` is a genuine ABI-confirmed nested
            // type (its members are all real, demangled .tbd symbols), but it's absent from the
            // SDK's own shipped Network.swiftinterface -- library-evolution-hidden or simply not
            // yet reflected there. Any dependency stub referencing it via a plain "import Network"
            // (Network isn't itself a dependency stub -- it's a real system framework we never
            // rebuild) fails with "not a member type of class 'Network.NWConnection'". Declare it
            // locally as an extension, mirroring the shape generateAll() already synthesizes when
            // Network itself is the primary target (main.swift's "Fix 6" NWConnection-extension
            // handling) -- legal since a real class can gain a nested type via an extension in a
            // downstream module, and the real interface has no conflicting declaration to clash with.
            if fileContent.containsWord("ConnectionProgressReport") && mod != "Network" {
                fileContent = fileContent.replacingOccurrences(
                    of: "import Foundation\n",
                    with: "import Foundation\nimport Network\n")
                fileContent += """

                extension Network.NWConnection {
                    public struct ConnectionProgressReport: Codable, CustomStringConvertible, Equatable {
                        public var isMakingProgress: Swift.Bool { fatalError() }
                        public var reportedAt: Foundation.Date { fatalError() }
                        public var description: Swift.String { fatalError() }
                        public var elapsedTime: Swift.Duration { fatalError() }
                        public var isConnected: Swift.Bool { fatalError() }
                        public var rttEstimate: Swift.Duration { fatalError() }
                        public var isLowQuality: Swift.Bool { fatalError() }
                        public var completionEstimate: Swift.Duration { fatalError() }
                        public var completionEstimateRemaining: Swift.Duration { fatalError() }
                        public var isActive: Swift.Bool { fatalError() }
                        public var startedAt: Foundation.Date { fatalError() }
                        public static func == (lhs: Self, rhs: Self) -> Swift.Bool { fatalError() }
                        public init(from decoder: Swift.Decoder) throws { fatalError() }
                        public func encode(to encoder: Swift.Encoder) throws {}
                    }
                }

                """
            }

            // injectDefaultArguments/simplifyType's default-value fallback (Model.swift) emits
            // "= dummyDefaultValue()" for a parameter with no reconstructable literal default.
            // generateAll() (the primary-target path) declares this generic helper once in its
            // own output — but a Swift default-argument thunk's mangled symbol always resolves
            // the default EXPRESSION in the declaring type's OWN module, so a dependency stub
            // using this fallback needs its own local copy, not a cross-module import (which
            // wouldn't satisfy the thunk's symbol lookup even if it compiled).
            if fileContent.contains("dummyDefaultValue()") {
                fileContent += "\npublic func dummyDefaultValue<T>() -> T { fatalError() }\n"
            }

            fileContentsByModule[mod] = fileContent
        }

        // Apply every hoist rename (collected across ALL modules above) to every module's
        // generated text — a protocol hoisted out of ITS OWN module's nested path (e.g.
        // BiomeStreams.LibraryArtifact.DataArtifact -> BiomeStreams.DataArtifact) can be
        // referenced by a DIFFERENT module's stub (e.g. IntelligencePlatformLibrary) using the
        // original nested path, which no longer exists once hoisted.
        for (mod, content) in fileContentsByModule {
            var updated = content
            for rename in allHoistedProtocolRenames {
                guard let moduleSegment = rename.originalDottedPath.components(separatedBy: ".").first else { continue }
                let newPath = "\(moduleSegment).\(rename.name)"
                if updated.contains(rename.originalDottedPath) {
                    updated = updated.replacingOccurrences(of: rename.originalDottedPath, with: newPath)
                }
                let unqualifiedOriginalPath = String(rename.originalDottedPath.dropFirst(moduleSegment.count + 1))
                if !unqualifiedOriginalPath.isEmpty {
                    if mod == moduleSegment {
                        updated = updated.replacingOccurrences(of: unqualifiedOriginalPath, with: rename.name)
                    } else {
                        updated = updated.replacingOccurrences(of: unqualifiedOriginalPath, with: newPath)
                    }
                }
            }
            let filePath = "\(outputDir)/\(mod).swift"
            do {
                try updated.write(toFile: filePath, atomically: true, encoding: .utf8)
                if ConfigManager.verbose { print("Generated stub source for \(mod) at \(filePath)", to: &Self.standardError) }
            } catch {
                print("Error: Could not write stub file to \(filePath)", to: &Self.standardError)
            }
        }

        // Emit minimal empty stubs for private-framework modules that were discovered
        // (via discoveredNamespaces) but have no referenced types in the interface
        // (e.g. GenerativeModelsFoundation) — their import line still requires the
        // module to exist at compile time.
        let systemMods: Set<String> = ["Swift", "Foundation", "ObjectiveC", "Dispatch", "os",
            "Metal", "CoreGraphics", "CoreVideo", "IOSurface", "MetricKit", "Combine",
            "Synchronization", "CoreMedia", "XPC", "CoreAI", "UniformTypeIdentifiers"]
        for modName in parser.discoveredNamespaces {
            guard modName != currentModule && !externalTypes.keys.contains(modName) else { continue }
            guard !systemMods.contains(modName) else { continue }
            // Only emit if it's a private framework in the SDK
            var tbdExists = false
            for searchPath in tbdSearchPaths {
                let p = "\(searchPath)/\(modName).framework/\(modName).tbd"
                if FileManager.default.fileExists(atPath: p) { tbdExists = true; break }
                let p2 = "\(searchPath)/\(modName).framework/Versions/A/\(modName).tbd"
                if FileManager.default.fileExists(atPath: p2) { tbdExists = true; break }
            }
            guard tbdExists else { continue }
            let filePath = "\(outputDir)/\(modName).swift"
            guard !FileManager.default.fileExists(atPath: filePath) else { continue }
            let emptyStub = "import Foundation\n// Empty stub for \(modName)\n"
            try? emptyStub.write(toFile: filePath, atomically: true, encoding: .utf8)
            if ConfigManager.verbose { print("Generated empty stub for \(modName) at \(filePath)", to: &Self.standardError) }
        }
    }

    class StubNode {
        var name: String
        var originalPath: [String] = []
        var isProtocol: Bool = false
        var kind: String = "struct"
        var genericCount: Int = 0
        var nested: [String: StubNode] = [:]
        var conformances: [String] = []
        
        init(name: String) {
            self.name = name
        }
        
        func generateSwift(depth: Int) -> String {
            let indent = String(repeating: "    ", count: depth)
            var params = ""
            if genericCount > 0 {
                let placeholders = ["A", "B", "C", "D", "E", "F"]
                let p = (0..<genericCount).map { $0 < placeholders.count ? placeholders[$0] : "A\($0)" }
                params = "<\(p.joined(separator: ", "))>"
            }
            
            var kindKeyword = "struct"
            if isProtocol || kind == "protocol" {
                kindKeyword = "protocol"
            } else if kind == "enum" {
                kindKeyword = "enum"
            } else if kind == "class" {
                kindKeyword = "class"
            }
            
            var inheritance = ""
            if kindKeyword == "protocol" {
                let uniqueConformances = Array(Set(conformances)).sorted()
                if !uniqueConformances.isEmpty {
                    inheritance = ": " + uniqueConformances.joined(separator: ", ")
                }
            } else {
                var uniqueConformances = Set<String>(conformances)
                let isNonCopyable = uniqueConformances.contains("~Copyable") || uniqueConformances.contains("any ~Copyable")
                if kindKeyword == "struct" || kindKeyword == "enum" {
                    if !isNonCopyable {
                        uniqueConformances.insert("Codable")
                        uniqueConformances.insert("Hashable")
                    }
                    uniqueConformances.insert("Sendable")
                }
                // Codable already implies Decodable + Encodable — declaring both is a
                // redundant-conformance error. This must run AFTER the unconditional
                // `insert("Codable")` above (not just the original, possibly-Codable-less
                // `conformances` check before it), since that insertion is exactly what can
                // introduce the redundancy in the first place.
                if uniqueConformances.contains("Codable") {
                    uniqueConformances.remove("Decodable")
                    uniqueConformances.remove("Encodable")
                }
                if kindKeyword == "class" {
                    if !uniqueConformances.contains("Sendable") && !uniqueConformances.contains("@unchecked Sendable") {
                        uniqueConformances.insert("@unchecked Sendable")
                    }
                }
                if isNonCopyable {
                    uniqueConformances.remove("Codable")
                    uniqueConformances.remove("Decodable")
                    uniqueConformances.remove("Encodable")
                    uniqueConformances.remove("Hashable")
                    uniqueConformances.remove("Equatable")
                }
                let sortedConformances = uniqueConformances.sorted()
                if !sortedConformances.isEmpty {
                    inheritance = ": " + sortedConformances.joined(separator: ", ")
                }
            }
            
            let escapedName = ["Type", "Protocol", "Self", "self"].contains(name) ? "`\(name)`" : name
            var s = "\(indent)public \(kindKeyword) \(escapedName)\(params)\(inheritance) {\n"
            if kindKeyword == "struct" || kindKeyword == "class" {
                s += "\(indent)    public init() {}\n"
            } else if kindKeyword == "enum" {
                s += "\(indent)    case case0\n"
            }
            // Satisfy Stream's "associatedtype EventType" requirement for types injected with
            // a native Stream conformance (see the AppleIntelligenceReporting lazySource<A>
            // conformance hook in generateStubs) — the requirement's actual associated type is
            // never referenced elsewhere in these stub types, so "Any" is a valid witness.
            if conformances.contains("Stream") {
                s += "\(indent)    public typealias EventType = Any\n"
            }
            if conformances.contains(where: { $0.contains("ChatLanguageModelResponseStringStreamString") || $0.contains("CompletionLanguageModelResponseStringStreamString") }) {
                s += "\(indent)    public var text: Swift.String { get { fatalError() } }\n"
            }
            
            for child in nested.values.sorted(by: { $0.name < $1.name }) {
                s += child.generateSwift(depth: depth + 1)
            }
            s += "\(indent)}\n"
            return s
        }
    }
}
