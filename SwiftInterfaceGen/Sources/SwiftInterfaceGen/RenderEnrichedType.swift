import Foundation

extension SwiftInterfaceGen {
    static func pruneSelfDeclaredExtensionTypes(_ node: TypeNode, pathSoFar: String, selfDeclaredExtensionTypes: Set<String>) {
        node.nestedTypes = node.nestedTypes.filter { name, childNode in
            let fullPath = "\(pathSoFar).\(name)"
            let isSelfDeclared = selfDeclaredExtensionTypes.contains {
                fullPath == $0 || fullPath.hasPrefix($0 + ".")
            }
            if isSelfDeclared {
                return false
            }
            pruneSelfDeclaredExtensionTypes(childNode, pathSoFar: fullPath, selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
            return true
        }
    }

    // Renders a real, enriched TypeNode (populated via the state-swapped re-parse in
    // generateStubs) for a dependency stub, instead of StubNode's empty-skeleton fallback.
    // Shared by generateStubs' main per-type emission loop and its same-module closure pass —
    // both need the identical circular-self-reference filter and Stream/EventType handling.
    // Emits ONLY the `@_originallyDefinedIn`-tagged extension blocks a TypeNode carries in
    // originallyDefinedInExtensions -- the one piece of extension-based enrichment genuinely
    // missing from renderEnrichedType's generateCode()-only render (see the comment at its call
    // site below). Deliberately self-contained rather than calling the full generateExtensions():
    // that function ALSO re-renders extensionMembers/constrainedExtensions, which for a protocol
    // would duplicate what generateProtocolDefaultExtension (below) already synthesizes from the
    // protocol's own requirement list, and carries a lot of unrelated machinery (retroactive-
    // conformance suffixes, stdlib placeholder renames, primary-associated-type scoping) this
    // narrow case has no need for -- the members a moved type's real ABI puts here are always
    // simple, already-fully-qualified signatures (see Parser.swift's originallyDefinedInExtensions
    // insert sites), never generic-placeholder-bearing ones. Recurses into nestedTypes so a moved
    // type nested several levels deep (e.g. RecursiveSchema.Options) is covered from a single
    // top-level call, matching generateCode()'s own self-recursing shape.
    static func renderOriginallyDefinedInExtensions(_ node: TypeNode, currentPath: String) -> String {
        var output = ""
        let escapedNodeName = node.escapeKeyword(node.name)
        let nodePath = currentPath.isEmpty ? escapedNodeName : "\(currentPath).\(escapedNodeName)"
        for origModule in node.originallyDefinedInExtensions.keys.sorted() {
            guard let membersMap = node.originallyDefinedInExtensions[origModule], !membersMap.isEmpty else { continue }
            let sortedMembers = membersMap.values.sorted { lhs, rhs in
                if case .initializer = lhs, case .initializer = rhs { return false }
                if case .initializer = lhs { return true }
                if case .initializer = rhs { return false }
                return false
            }
            var extBody = ""
            var emittedAny = false
            for member in sortedMembers {
                switch member {
                case .initializer(let sig):
                    // Used to unconditionally skip init(from:) here on the assumption that
                    // generateCode()'s own Codable-completeness fallback (Model.swift) already
                    // covers it -- but that fallback used to check only a struct/enum's own
                    // `members`, missing this real one living in originallyDefinedInExtensions,
                    // and synthesized a SECOND, wrongly-placed init(from:) directly in the type
                    // body instead (mangling under the moved-from module with no "extension in"
                    // marker, not matching the real ABI). Now that the fallback correctly checks
                    // every container (including this one) and skips synthesis when a real one is
                    // found here, this real member needs to actually be emitted.
                    if node.members.values.contains(where: { if case .initializer(let s) = $0 { return s == sig } else { return false } }) { continue }
                    extBody += "    public \(sig) { fatalError() }\n"
                    emittedAny = true
                case .method(let name, let sig, var isStatic):
                    // `sig` is already the full "name(params) -> ReturnType" text (see
                    // Parser.swift's `fixedSignature = escapedMemberName + signature(...)`) --
                    // do not re-prefix it with `name` again. An operator method's stored sig
                    // carries a literal trailing " infix"/" prefix"/" postfix" marker (mirroring
                    // Model.swift's own generateOneExtension handling of the same MemberKind) --
                    // strip it and force `static`, since Swift requires operator methods be static.
                    let cleanSig = sig.strippingOperatorFixityMarkers()
                    if cleanSig != sig { isStatic = true }
                    if node.members.values.contains(where: { if case .method(let n, let s, let st) = $0 { return (s == sig || s == cleanSig || n == name) && st == isStatic } else { return false } }) { continue }
                    extBody += "    public \(isStatic ? "static " : "")func \(cleanSig) { fatalError() }\n"
                    emittedAny = true
                case .property(let name, let type, let isReadOnly, let isStatic):
                    if node.members.values.contains(where: { if case .property(let n, _, _, let st) = $0 { return n == name && st == isStatic } else { return false } }) { continue }
                    let getter = "{ get { fatalError() }\(isReadOnly ? "" : " set { fatalError() }") }"
                    extBody += "    public \(isStatic ? "static " : "")var \(name): \(type) \(getter)\n"
                    emittedAny = true
                default:
                    break
                }
            }
            if emittedAny {
                output += "@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)\n"
                output += "@_originallyDefinedIn(module: \"\(origModule)\", macOS 10.15)\n"
                output += "extension \(nodePath) {\n"
                output += extBody
                output += "}\n"
            }
        }
        // A nested type literally named "Type" (or another Swift keyword) needs the SAME
        // backtick escaping inside every signature that references it qualified as
        // "...NodeName.Type" -- otherwise Swift parses the unescaped ".Type" suffix as the
        // metatype-of-NodeName expression instead of a reference to this nested type, which
        // silently type-checks wrong everywhere except where an exact-type match is required
        // (e.g. a static == operator's parameter list), where it surfaces as a hard compile
        // error ("member operator '==' must have at least one argument of type '...`Type`'").
        // Escaping only the extension's own header (nodePath) above isn't enough since member
        // signatures elsewhere in this same text can reference the identical qualified path.
        if escapedNodeName != node.name, let re = try? NSRegularExpression(pattern: "\\.\(NSRegularExpression.escapedPattern(for: node.name))\\b(?!`)") {
            let nsRange = NSRange(output.startIndex..<output.endIndex, in: output)
            output = re.stringByReplacingMatches(in: output, range: nsRange, withTemplate: ".`\(node.name)`")
        }
        for nested in node.nestedTypes.values {
            output += renderOriginallyDefinedInExtensions(nested, currentPath: nodePath)
        }
        return output
    }

    static func renderEnrichedType(_ realNode: TypeNode, mod: String, currentModule: String, parser: Parser, selfDeclaredExtensionTypes: Set<String> = []) -> String {
        if !selfDeclaredExtensionTypes.isEmpty {
            pruneSelfDeclaredExtensionTypes(realNode, pathSoFar: "\(mod).\(realNode.name)", selfDeclaredExtensionTypes: selfDeclaredExtensionTypes)
        }
        let savedDefaultModule = parser.defaultModule
        parser.defaultModule = mod
        // generateAll() (the real-target codegen path) always calls markGenericRecursive
        // before rendering, so a type's own real generic-application usages (from
        // discoveredGenerics, populated by precompute()) mark it isGeneric before generateCode()
        // ever runs. This dependency's members were parsed via the same processSymbols/
        // precompute() pipeline (generateStubs' state-swapped re-parse), so discoveredGenerics
        // already has the right entries — but nothing previously called markGenericRecursive
        // for a dependency's own types, so a real generic type like GenerativeStream<A> rendered
        // as if non-generic (no <A> in its header) despite its own real members using <A>.
        parser.markGenericRecursive(node: realNode)
        var code = realNode.generateCode(indent: "", parser: parser)
        // generateCode() only ever renders a type's own `members` (declared inline in its own
        // body) plus, for a protocol specifically, generateProtocolDefaultExtension (below)
        // synthesizes a trivial default-implementation extension straight from the protocol's
        // own requirement list. Neither path ever looks at originallyDefinedInExtensions, so a
        // type whose real ABI moved via @_originallyDefinedIn (e.g. PromptKit's RecursiveSchema.
        // Options.init(rawValue:)/rawValue, really exported under GenerativeFunctionsFoundation's
        // own mangled name) rendered with its base conformance list (RawRepresentable/SetAlgebra/
        // etc.) but none of the real members that satisfy it. Add just that one missing piece --
        // NOT the full generateExtensions() (which also re-renders extensionMembers/
        // constrainedExtensions and would duplicate generateProtocolDefaultExtension's synthesis
        // for protocols).
        let origDefExtCode = renderOriginallyDefinedInExtensions(realNode, currentPath: "")
        if !origDefExtCode.isEmpty {
            code += "\n" + origDefExtCode
        }
        parser.defaultModule = savedDefaultModule
        // simplifyType() (Parser.swift) strips a "defaultModule." prefix from EVERY type
        // reference — not just conformances — PERMANENTLY into this cached TypeNode's stored
        // member-signature strings, using whichever module identity was active the FIRST time
        // this type was parsed/enriched. When the same cached node is rendered again for a
        // DIFFERENT target build (Stage B/C's state-swapped re-parse is reused across multiple
        // target builds), a bare name from that original stripping can be flat-out wrong here —
        // e.g. "Prompt.Component.Value" (originally "PromptKit.Prompt...") rendered while
        // building TokenGenerationCore, where "Prompt" isn't visible unqualified. Conformances
        // are already re-qualified at TRUE render time (TypeNode.generateCode's inheritsList
        // construction, Model.swift) since that list is rebuilt fresh each call; member
        // signatures are cached as flat strings much earlier and can't cheaply get the same
        // treatment, so re-qualify bare foreign-module type names as a text-level pass here
        // instead — bounded to this one rendering path, not a Parser-wide behavior change.
        // Must run BEFORE the circular-module member filter below: a member whose stored
        // signature still has its module prefix stripped (e.g. bare "AnyGenerationGuides"
        // instead of "PromptKit.AnyGenerationGuides") is invisible to that filter's
        // dotted-qualifier check, so a genuinely circular reference would otherwise survive
        // unfiltered as a bare name, then get its qualifier reattached AFTER filtering already
        // ran and let it through uncaught.
        code = requalifyBareForeignTypeNames(code, mod: mod, parser: parser)
        // A member's real signature can genuinely reference the module we're building this
        // stub FOR (currentModule) -- e.g. TokenGeneration.Prompt.renderPromptModules(...)
        // returning [TokenGenerationCore.PromptModule] -- and this stub must compile
        // standalone, before currentModule exists. It can also reference any OTHER real target
        // currently on orchestrate.py's build call stack (SWIFT_INTERFACE_GEN_BUILDING_TARGETS,
        // set by orchestrate.py to its `building` set) -- e.g. while resolving TokenGenerationCore
        // -> PromptKit -> TokenGeneration (a stub), TokenGeneration's own real members can
        // reference TokenGenerationCore itself, which is equally circular (TokenGenerationCore
        // isn't built yet either, since we're still resolving ITS dependencies). Drop just the
        // offending single-line members (every member here renders self-contained on one line,
        // body included) rather than losing the whole type's enrichment.
        var circularModules = Set([currentModule])
        if let buildingEnv = ProcessInfo.processInfo.environment["SWIFT_INTERFACE_GEN_BUILDING_TARGETS"], !buildingEnv.isEmpty {
            circularModules.formUnion(buildingEnv.split(separator: ",").map(String.init))
        }
        let memberLinePrefixes = ["public func ", "public static func ", "public final func ",
                                   "public override func ", "public class func ", "public var ",
                                   "public final var ", "public static var ", "public override var ",
                                   "public let ", "public final let ", "public init", "public required init",
                                   "public convenience init", "public subscript",
                                   "public typealias ", "case ", "nonisolated public ",
                                   "func ", "static func ", "class func ", "mutating func ",
                                   "var ", "let ", "subscript", "init", "associatedtype ", "typealias "]
        let declLinePrefixes = ["public struct ", "public final class ", "public class ",
                                 "public enum ", "@_fixed_layout public class "]
        // TypeNode.init (Model.swift) permanently strips a conformance's module qualifier
        // whenever the protocol's dotted name is present in parser.discoveredProtocols --
        // that includes a protocol declared in a circularModules member, so the dotted-prefix
        // check above ("PromptKit.") never matches; the bare name (e.g.
        // "PromptComponentValueConvertible") is what actually appears in `code`. Recover the
        // owning module for every bare discoveredProtocols entry so a circular bare protocol
        // reference is filtered exactly like a still-qualified one.
        var bareProtocolOwningModule = [String: String]()
        for qualifiedProto in parser.discoveredProtocols {
            guard let dotIdx = qualifiedProto.range(of: ".", options: .backwards) else { continue }
            let owningModule = String(qualifiedProto[..<dotIdx.lowerBound])
            let bareName = String(qualifiedProto[dotIdx.upperBound...])
            // A protocol owned by `mod` itself (the dependency whose stub this is) is a
            // same-module reference, not circular -- e.g. GenerativeFunctionsFoundation's own
            // Tooling.Arguments: GenerableArguments, where GenerableArguments is also declared
            // in GenerativeFunctionsFoundation. Excluding it here mirrors the dotted-qualifier
            // check a few lines up, which already excludes `mod` the same way (`text.contains
            // ("\($0).")` only tests circularModules, and mod is deliberately not a member of
            // that set unless it's ALSO currentModule).
            if circularModules.contains(owningModule), owningModule != mod {
                bareProtocolOwningModule[bareName] = owningModule
            }
        }
        let lineReferencesCircularModule: (String) -> Bool = { text in
            // A dotted reference to `mod` ITSELF (e.g. "GenerativeFunctionsFoundation." while
            // rendering GenerativeFunctionsFoundation's own dependency stub) is never circular —
            // it's just this type's own home module, fully resolvable within the same file.
            // `mod` can still land in `circularModules` (added by orchestrate.py's stub-import-
            // cycle detection when `mod` participates in a cycle with some OTHER module), so it
            // must be excluded here explicitly rather than relying on circularModules' membership
            // alone.
            if circularModules.contains(where: { $0 != mod && text.contains("\($0).") }) { return true }
            for (bareName, owningModule) in bareProtocolOwningModule where owningModule != mod {
                if text.containsWord(bareName) { return true }
            }
            return false
        }
        code = code.split(separator: "\n", omittingEmptySubsequences: false).compactMap { line -> Substring? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard lineReferencesCircularModule(trimmed) else { return line }
            if memberLinePrefixes.contains(where: { trimmed.hasPrefix($0) }) {
                return nil
            }
            // A type's own declaration line (e.g. "public struct PromptTemplate: Codable,
            // PromptKit.ChatMessagePromptConvertible {") can conform to a protocol declared in
            // a circular module -- genuinely circular the same way a member signature can be
            // (this stub compiles standalone before that module exists), but dropping the whole
            // TYPE would lose all its other real enrichment. Strip just the offending
            // comma-separated conformance entries from the inheritance clause instead.
            if declLinePrefixes.contains(where: { trimmed.hasPrefix($0) }), trimmed.hasSuffix("{") {
                guard let colonIdx = line.firstIndex(of: ":") else { return line }
                let head = String(line[..<colonIdx])
                let bodyStart = line.index(after: colonIdx)
                let inheritancePart = String(line[bodyStart..<line.index(before: line.endIndex)])
                let entries = inheritancePart.splitByCommaRespectingBrackets().map { $0.trimmingCharacters(in: .whitespaces) }
                let kept = entries.filter { entry in !lineReferencesCircularModule(entry) }
                if kept.count == entries.count { return line }
                if kept.isEmpty {
                    return Substring(head + " {")
                }
                return Substring(head + ": " + kept.joined(separator: ", ") + " {")
            }
            return line
        }.joined(separator: "\n")
        // Mirrors StubNode.generateSwift's own handling: a type given a native Stream
        // conformance (the AppleIntelligenceReporting lazySource<A> hook, above) needs
        // Stream's "associatedtype EventType" requirement satisfied — generateCode() has no
        // knowledge of this synthetic conformance's associated-type requirement, since it's
        // injected after the type's own real members were already parsed. Any nested type
        // several levels deep can independently gain this conformance (each has its own
        // TypeNode.conformances set), so insert per matching declaration LINE (", Stream {"/
        // ", Stream," in the type's own inheritance clause), not just once for the top type.
        if code.contains(" Stream ") || code.contains(" Stream,") || code.contains(" Stream{") || code.contains(" Stream {") {
            let lines = code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            var result = [String]()
            for line in lines {
                result.append(line)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                let declaresStream = trimmed.range(of: #"\bStream\b"#, options: .regularExpression) != nil &&
                    (trimmed.contains(": ") || trimmed.contains(", ")) && trimmed.hasSuffix("{")
                if declaresStream {
                    let indent = String(line.prefix(while: { $0 == " " }))
                    result.append("\(indent)    public typealias EventType = Any")
                }
            }
            code = result.joined(separator: "\n")
        }
        // generateAll() (the real-target codegen path) always runs postProcess's
        // removePrivateObjCTypeReferences() before writing output — this path renders the same
        // TypeNode.generateCode() output but never went through postProcess, so a member
        // referencing a private/undeclared C typedef left qualified as "__C.snake_case" by
        // simplifyType (e.g. ModelManagerServices.AuditToken.init(__C.audit_token_t)) survives
        // into the stub and fails to compile ("cannot find type '__C' in scope" once __C isn't
        // otherwise visible in a standalone dependency-stub module).
        code = code.removePrivateObjCTypeReferences()
        if !selfDeclaredExtensionTypes.isEmpty {
            let stdlibTypes: Set<String> = [
                "String", "Int", "Double", "Float", "Bool", "UInt", "Int8", "Int16", "Int32", "Int64",
                "UInt8", "UInt16", "UInt32", "UInt64", "Data", "URL", "Error", "Decoder", "Encoder",
                "CodingKey", "Any", "Result", "Optional", "Array", "Dictionary", "Set"
            ]
            for extType in selfDeclaredExtensionTypes {
                let parts = extType.components(separatedBy: ".")
                if parts.count >= 2 {
                    let shortName = parts.suffix(2).joined(separator: ".")
                    let leafName = parts.last!
                    code = code.replacingOccurrences(of: extType, with: "Any")
                    code = code.replacingOccurrences(of: shortName, with: "Any")
                    if !stdlibTypes.contains(leafName) {
                        code = code.replaceWord(leafName, with: "Any")
                    }
                }
            }
        }
        // simplifyType()'s ambiguous-protocol disambiguation (Parser.swift, "any
        // ___SHIELDED_<module>___.Foo") is a TEMPORARY placeholder meant to survive just long
        // enough to bypass module-prefix stripping, then get restored to "any <module>.Foo" by
        // postProcess (main.swift's generateAll() path only) before being written out. This
        // stub-rendering path never went through postProcess, so an unrestored placeholder
        // ("___SHIELDED_ModelCatalog___") can leak straight into the compiled stub as an
        // unresolvable bare type name.
        code = code.replacingOccurrences(of: "___SHIELDED_\(mod)___", with: mod)
        if realNode.kind == "protocol" {
            let extCode = generateProtocolDefaultExtension(code: code, protocolName: realNode.name)
            if !extCode.isEmpty {
                code += "\n" + extCode
            }
        }
        return code
    }

    static func generateProtocolDefaultExtension(code: String, protocolName: String) -> String {
        let lines = code.components(separatedBy: "\n")
        var extMembers = [String]()
        var inProtocol = false
        var depth = 0
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("protocol \(protocolName)") || (trimmed.hasPrefix("public protocol ") && trimmed.contains(protocolName)) {
                inProtocol = true
            }
            if !inProtocol { continue }
            for ch in trimmed {
                if ch == "{" { depth += 1 }
                else if ch == "}" { depth -= 1 }
            }
            if depth == 1 && inProtocol {
                // Inside protocol body
                if trimmed.hasPrefix("static var ") || trimmed.hasPrefix("class var ") || trimmed.hasPrefix("var ") {
                    if let braceIdx = trimmed.firstIndex(of: "{") {
                        let head = String(trimmed[..<braceIdx]).trimmingCharacters(in: .whitespaces)
                        let isReadWrite = trimmed.contains("set")
                        let body = isReadWrite ? "{ get { fatalError() } set { fatalError() } }" : "{ get { fatalError() } }"
                        extMembers.append("    public \(head) \(body)")
                    }
                } else if trimmed.hasPrefix("static func ") || trimmed.hasPrefix("class func ") || trimmed.hasPrefix("func ") {
                    extMembers.append("    public \(trimmed) { fatalError() }")
                } else if trimmed.hasPrefix("static subscript") || trimmed.hasPrefix("subscript") {
                    if let braceIdx = trimmed.firstIndex(of: "{") {
                        let head = String(trimmed[..<braceIdx]).trimmingCharacters(in: .whitespaces)
                        let isReadWrite = trimmed.contains("set")
                        let body = isReadWrite ? "{ get { fatalError() } set { fatalError() } }" : "{ get { fatalError() } }"
                        extMembers.append("    public \(head) \(body)")
                    }
                }
            }
            if depth == 0 && inProtocol {
                inProtocol = false
            }
        }
        if extMembers.isEmpty { return "" }
        return "\nextension \(protocolName) {\n" + extMembers.joined(separator: "\n") + "\n}\n"
    }

    // Scans `code` for a bare (unqualified) capitalized identifier that isn't declared in `mod`
    // itself but IS a real top-level type in some OTHER known module, and qualifies it. Bounded
    // to top-level type names only (not nested paths) to keep false-positive risk low — a nested
    // path segment (e.g. the ".Component" in "Prompt.Component") is left alone since only the
    // leading segment can be an unqualified cross-module reference here.
    static func requalifyBareForeignTypeNames(_ code: String, mod: String, parser: Parser) -> String {
        var result = code
        guard let bareIdentRegex = try? NSRegularExpression(pattern: "(?<![.A-Za-z0-9_])([A-Z][A-Za-z0-9_]*)\\b", options: []) else { return result }
        let ownModuleTypeNames: Set<String> = parser.modules[mod].map { Set($0.nestedTypes.keys) } ?? []
        // Well-known Swift stdlib protocol/attribute names are never legitimately "owned" by
        // some other private-framework module even if that module's own conformance-injection
        // logic (applyTypeFixups etc.) happens to record them against a nestedTypes entry --
        // requalifying "Sendable" would corrupt "@Sendable" attribute syntax into
        // "@Swift.Sendable" (an unknown attribute), and similarly for the others below.
        let stdlibNames: Set<String> = ["Sendable", "Equatable", "Hashable", "Codable", "Decodable",
            "Encodable", "Identifiable", "BitwiseCopyable", "Copyable", "Escapable", "Error",
            "CustomStringConvertible", "CustomDebugStringConvertible", "Comparable", "Sequence",
            "Collection", "Strideable", "Numeric", "SignedNumeric", "AdditiveArithmetic",
            "FloatingPoint", "BinaryFloatingPoint", "LosslessStringConvertible", "CaseIterable",
            "RawRepresentable", "CodingKey", "LocalizedError", "Actor", "AnyObject", "Optional",
            "Array", "Dictionary", "Set", "Result", "Never", "Void",
            "String", "Int", "Double", "Float", "Bool", "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
            "Int8", "Int16", "Int32", "Int64", "Character", "StaticString", "Substring", "Decoder", "Encoder",
            "UUID", "Data", "Date", "URL", "URLRequest", "Locale", "TimeZone", "Calendar", "CharacterSet",
            "Notification", "IndexPath", "IndexSet", "Measurement", "Unit", "Dimension", "Duration",
            // Handled by its own dedicated fallback (the same-module closure pass's
            // newlyFoundOpaqueStruct case, main.swift) -- XPC has no real swiftinterface/tbd in
            // this SDK, so parser.modules["XPC"] can still hold a nestedTypes entry for
            // "XPCCodableObject" purely from a findOrCreateType() call site treating a
            // referenced (not independently declared) path as if it were one; requalifying
            // against that phantom entry produces "XPC.XPCCodableObject", which doesn't exist.
            "XPCCodableObject"]
        // A name this SAME stub file declares (nested at any depth, e.g. "public enum Streams {"
        // inside "public enum BiomeStreams.Streams" from an earlier bug) must never be
        // requalified — replaceWord below has no notion of declaration vs. reference sites and
        // would corrupt "enum Streams {" into "enum BiomeStreams.Streams {" (invalid syntax).
        var selfDeclaredNames = Set<String>()
        // "associatedtype Foo: Bound" is also a DECLARATION, not a reference -- e.g.
        // "associatedtype ModelConfiguration: Hashable" must never become
        // "associatedtype TokenGenerationCore.ModelConfiguration" (invalid: an associated
        // type's own name can never be dotted), even if some OTHER real module happens to
        // separately declare a same-named top-level type.
        if let declRegex = try? NSRegularExpression(pattern: "\\b(?:struct|enum|class|protocol|associatedtype|case) `?([A-Za-z_][A-Za-z0-9_]*)`?", options: []) {
            let declNsRange = NSRange(result.startIndex..<result.endIndex, in: result)
            for m in declRegex.matches(in: result, options: [], range: declNsRange) {
                if let r = Range(m.range(at: 1), in: result) {
                    selfDeclaredNames.insert(String(result[r]))
                }
            }
        }
        var seen = Set<String>()
        let nsRange = NSRange(result.startIndex..<result.endIndex, in: result)
        for m in bareIdentRegex.matches(in: result, options: [], range: nsRange) {
            guard let range = Range(m.range(at: 1), in: result) else { continue }
            let name = String(result[range])
            guard !seen.contains(name), name != mod, name != "Swift", name != "Foundation",
                  !ownModuleTypeNames.contains(name), !selfDeclaredNames.contains(name),
                  !stdlibNames.contains(name) else { continue }
            seen.insert(name)
            // "__C" is the synthetic ObjC-bridge pseudo-module (registerObjcClasses), never a
            // real importable module -- a bare ObjC-bridged name is deliberately left
            // unqualified elsewhere (the same-module closure pass emits a local placeholder
            // class for it), so requalifying against "__C" would break that existing handling.
            guard let owningModule = parser.modules.first(where: { $0.key != mod && $0.key != "__C" && $0.value.nestedTypes[name] != nil })?.key else { continue }
            result = result.replaceWord(name, with: "\(owningModule).\(name)", allowPrecededByDot: false)
        }
        // A reference can also be WRONGLY qualified rather than bare -- e.g. a demangled ABI
        // symbol names a return type "PromptKit.Prompt.Component.Value" because the SYMBOL
        // itself belongs to PromptKit (GenerativeModelsFoundation.SelfAttention.toValue()'s own
        // mangled name embeds that qualifier), even though "Prompt" is actually declared in
        // TokenGeneration (which PromptKit imports/depends on) -- simplifyType's defaultModule
        // stripping never touches this since the qualifier isn't `mod` here, so it survives
        // verbatim into the stub as an unresolvable cross-module reference. Detect a qualifier
        // that isn't a real module owning that type name, and correct it to whichever module
        // actually declares it.
        if let wrongQualifierRegex = try? NSRegularExpression(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\.([A-Z][A-Za-z0-9_]*)\\b", options: []) {
            var corrections = [(wrong: String, right: String)]()
            let wqNsRange = NSRange(result.startIndex..<result.endIndex, in: result)
            for m in wrongQualifierRegex.matches(in: result, options: [], range: wqNsRange) {
                guard let qualRange = Range(m.range(at: 1), in: result),
                      let nameRange = Range(m.range(at: 2), in: result) else { continue }
                let qualifier = String(result[qualRange])
                let name = String(result[nameRange])
                guard qualifier != mod, qualifier != "Swift", qualifier != "Foundation", qualifier != "__C",
                      !stdlibNames.contains(name) else { continue }
                // Only correct a qualifier that's a KNOWN module (real target/dependency) but
                // doesn't itself declare this name -- an unrecognized qualifier could be a
                // legitimate nested-type path segment (e.g. "Outer.Inner"), not a module prefix.
                guard parser.modules[qualifier] != nil, parser.modules[qualifier]?.nestedTypes[name] == nil else { continue }
                guard let rightModule = parser.modules.first(where: { $0.key != qualifier && $0.key != mod && $0.key != "__C" && $0.value.nestedTypes[name] != nil })?.key else { continue }
                corrections.append((wrong: "\(qualifier).\(name)", right: "\(rightModule).\(name)"))
            }
            for (wrong, right) in corrections where wrong != right {
                result = result.replacingOccurrences(of: wrong, with: right)
            }
        }
        return result
    }

}
