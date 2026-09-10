import Foundation

extension SwiftInterfaceGen {
    static func postProcessModelCatalog(_ code: String, parser: Parser) -> String {
        var c = code
            // GenericA stands in for CatalogAsset<A: AssetMetadata, B: AssetContents>'s erased
            // `A` type argument (that constraint is itself real, hardcoded private-ABI knowledge
            // from Model.swift's generic-placeholder chain, not derivable here). What doesn't
            // need to be hand-typed is the extension's *body* -- AssetMetadata/AssetContents are
            // real, fully-parsed protocol TypeNodes, so their requirements can be rendered
            // directly from parser.modules instead of listed by hand.
            var conformanceBody = ""
            for protocolName in ["AssetMetadata", "AssetContents"] {
                guard let protoNode = parser.findTypeNode(module: parser.defaultModule, path: [protocolName]) else {
                    if ConfigManager.verbose { fputs("Warning: could not find \(protocolName) to synthesize GenericA's conformance body.\n", stderr) }
                    continue
                }
                for member in protoNode.members.values {
                    switch member {
                    case .initializer(let sig):
                        conformanceBody += "    public \(sig) { fatalError() }\n"
                    case .property(let name, let type, let isReadOnly, _):
                        if isReadOnly {
                            conformanceBody += "    public var \(name): \(type) { get { fatalError() } }\n"
                        } else {
                            conformanceBody += "    public var \(name): \(type) { get { fatalError() } set { fatalError() } }\n"
                        }
                    case .method, .associatedType, .enumCase, .other:
                        continue
                    }
                }
            }
            c += "\n\nextension GenericA: AssetMetadata, AssetContents {\n\(conformanceBody)}\n"
        return c
    }
}
