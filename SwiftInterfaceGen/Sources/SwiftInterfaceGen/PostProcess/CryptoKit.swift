import Foundation

extension SwiftInterfaceGen {
    static func postProcessCryptoKit(_ code: String, parser: Parser) -> String {
        var c = code
            c = c.replacingOccurrences(
                of: "public struct HKDF: Codable, Hashable, @unchecked Sendable {",
                with: "public struct HKDF<A>: Codable, Hashable, @unchecked Sendable where A: HashFunction {")
            c = c.replacingOccurrences(
                of: "public static func extract<GenericA>(inputKeyMaterial: SymmetricKey, salt: GenericA?) -> HashedAuthenticationCode<GenericA> where GenericA: DataProtocol { fatalError() }",
                with: "public static func extract<GenericA>(inputKeyMaterial: SymmetricKey, salt: GenericA?) -> HashedAuthenticationCode<A> where GenericA: DataProtocol { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func extract(inputKeyMaterial: SymmetricKey, salt: borrowing RawSpan?) -> HashedAuthenticationCode<A> { fatalError() }",
                with: "public static func extract(inputKeyMaterial: SymmetricKey, salt: borrowing RawSpan?) -> HashedAuthenticationCode<A> { fatalError() }")
            c = c.replacingOccurrences(
                of: "public static func ==(_ lhs: HKDF, _ rhs: HKDF) -> Bool { fatalError() }",
                with: "public static func ==(_ lhs: HKDF<A>, _ rhs: HKDF<A>) -> Bool { fatalError() }")
            // Fix: the real module's Curve25519 type is misnamed "Curve" both at module scope
            // and inside SecureEnclave (confirmed via swift-demangle: every required symbol says
            // "CryptoKit.Curve25519..." / "CryptoKit.SecureEnclave.Curve25519...", never "Curve"),
            // while a SEPARATE, entirely empty "public enum Curve25519 { ... }" placeholder
            // (auto-generated stub for what the generator treated as an undeclared type) exists
            // alongside it at both scopes -- the parser evidently split the single real
            // "Curve25519" declaration into a correctly-named-but-empty stub and an incorrectly-
            // named-but-populated real one. Remove the empty duplicates and rename the real ones.
            c = c.replacingOccurrences(
                of: "public enum Curve25519 {\n    case _mock\n    public enum KeyAgreement {\n        case _mock\n        public struct PrivateKey {\n        }\n        public struct PublicKey {\n        }\n    }\n    public enum Signing {\n        case _mock\n        public struct PrivateKey {\n        }\n        public struct PublicKey {\n        }\n    }\n}\n",
                with: "")
            c = c.replacingOccurrences(
                of: "    public enum Curve25519 {\n        case _mock\n        public enum KeyAgreement {\n            case _mock\n            public struct PrivateKey {\n            }\n        }\n        public enum Signing {\n            case _mock\n            public struct PrivateKey {\n            }\n        }\n    }\n",
                with: "")
            c = c.replacingOccurrences(of: "public enum Curve: Hashable, @unchecked Sendable {", with: "public enum Curve25519: Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(of: "    public enum Curve: Hashable, @unchecked Sendable {", with: "    public enum Curve25519: Hashable, @unchecked Sendable {")
            c = c.replacingOccurrences(of: "public static func ==(_ lhs: Curve, _ rhs: Curve) -> Bool { fatalError() }", with: "public static func ==(_ lhs: Curve25519, _ rhs: Curve25519) -> Bool { fatalError() }")
            // Fix: AES.GCM.Nonce/ChaChaPoly.Nonce's init(copying:)/init(data:) render their
            // RawSpan parameter with an erroneous `borrowing` keyword copied verbatim from the
            // swiftinterface's printed ownership annotation -- same gap already fixed for
            // MetalPerformanceShadersGraph's Executables.init and Vision's several borrowing
            // params this session: the annotation reflects the implicit default calling
            // convention, not an actual source-level keyword. Confirmed via a minimal repro.
            c = c.replacingOccurrences(of: "init(copying: borrowing RawSpan) throws { fatalError() }", with: "init(copying: RawSpan) throws { fatalError() }")
            c = c.replacingOccurrences(of: "init(data: borrowing RawSpan) throws { fatalError() }", with: "init(data: RawSpan) throws { fatalError() }")
            // Same erroneous-borrowing gap for VRF.VRFPublicKey.init(publicKey:) and
            // SymmetricKey.init(size:initializingWith:)'s closure parameter.
            c = c.replacingOccurrences(
                of: "public init(publicKey: borrowing RawSpan) throws(VRFError) { fatalError() }",
                with: "public init(publicKey: RawSpan) throws(VRFError) { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(size: SymmetricKeySize, initializingWith: borrowing (inout OutputRawSpan) throws (A) -> ()) throws(A) where A: Error { fatalError() }",
                with: "public init<A>(size: SymmetricKeySize, initializingWith: (inout OutputRawSpan) throws (A) -> ()) throws(A) where A: Error { fatalError() }")

            // Fix: XWingMLKEM768X25519 (a post-quantum hybrid KEM) rendered as a completely
            // empty placeholder -- `case _mock` plus three bodyless structs -- instead of the
            // real ~20-member API surface (confirmed via swift-demangle against the full stub
            // list). Filled in by hand, mirroring the sibling Kyber1024/MLKEM768/MLKEM1024 KEM
            // types' established shape (KEMPrivateKey/KEMPublicKey/KEMOneTimePrivateKey, plus the
            // HPKE-specific protocols since this type also needs HPKE interop) and the exact
            // signatures from the demangled stub list.
            c = c.replacingOccurrences(
                of: """
                public enum XWingMLKEM768X25519 {
                    case _mock
                    public struct OneTimePrivateKey {
                    }
                    public struct PrivateKey {
                    }
                    public struct PublicKey {
                    }
                }
                """,
                with: """
                public enum XWingMLKEM768X25519 {
                    case _mock
                    public struct PublicKey: HPKEKEMPublicKey, HPKEPublicKeySerialization, KEMPublicKey {
                        public init<A>(rawRepresentation: A) throws where A: ContiguousBytes { fatalError() }
                        public init<A>(_ arg1: A, kem: HPKE.KEM) throws where A: ContiguousBytes { fatalError() }
                        public func encapsulate() throws -> KEM.EncapsulationResult { fatalError() }
                        public func hpkeRepresentation(kem: HPKE.KEM) throws -> Data { return Data() }
                        public var rawRepresentation: Data { get { return Data() } }
                    }
                    public struct PrivateKey: HPKEKEMPrivateKey, HPKEKEMPrivateKeyGeneration, KEMPrivateKey {
                        public typealias PublicKey = XWingMLKEM768X25519.PublicKey
                        public init() throws { fatalError() }
                        public init<A>(seedRepresentation: A, publicKey: XWingMLKEM768X25519.PublicKey?) throws where A: DataProtocol { fatalError() }
                        public init<A>(integrityCheckedRepresentation: A) throws where A: DataProtocol { fatalError() }
                        public func decapsulate(_ arg1: Data) throws -> SymmetricKey { fatalError() }
                        public var integrityCheckedRepresentation: Data { get { return Data() } }
                        public var publicKey: XWingMLKEM768X25519.PublicKey { get { fatalError() } }
                        public var seedRepresentation: Data { get { return Data() } }
                        public static func generate() throws -> PrivateKey { fatalError() }
                    }
                    public struct OneTimePrivateKey: KEMOneTimePrivateKey {
                        public typealias PublicKey = XWingMLKEM768X25519.PublicKey
                        public var publicKey: XWingMLKEM768X25519.PublicKey { get { fatalError() } }
                        public func decapsulate(_ arg1: Data) throws -> SymmetricKey { fatalError() }
                        public static func generate() throws -> OneTimePrivateKey { fatalError() }
                    }
                }
                """)
            // Fix: HPKE.Recipient/Sender's authenticatedBy/recipientKey params render as bare
            // "Any" instead of the real associated-type reference "A.PublicKey" (confirmed via
            // swift-demangle: DiffieHellmanKeyAgreement declares `associatedtype PublicKey:
            // HPKEDiffieHellmanPublicKey`, and A: HPKEDiffieHellmanPrivateKey inherits it) --
            // same generic-placeholder-resolved-as-Any gap seen elsewhere this session.
            c = c.replacingOccurrences(
                of: "authenticatedBy: Any, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "authenticatedBy: A.PublicKey, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(
                of: "authenticatedBy: Any) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "authenticatedBy: A.PublicKey) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(recipientKey: Any, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "public init<A>(recipientKey: A.PublicKey, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A, presharedKey: SymmetricKey, presharedKeyIdentifier: Data) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(
                of: "public init<A>(recipientKey: Any, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }",
                with: "public init<A>(recipientKey: A.PublicKey, ciphersuite: HPKE.Ciphersuite, info: Data, authenticatedBy: A) throws where A: HPKEDiffieHellmanPrivateKey { fatalError() }")
            c = c.replacingOccurrences(of: "Curve.KeyAgreement", with: "Curve25519.KeyAgreement")
            c = c.replacingOccurrences(of: "Curve.Signing", with: "Curve25519.Signing")

            // Fix: HPKEDiffieHellmanPrivateKey/HPKEKEMPrivateKey render as empty-bodied protocol
            // refinements, but their real ABI needs an "associated conformance descriptor"
            // narrowing the inherited PublicKey associatedtype to the HPKE-specific public-key
            // protocol (DiffieHellmanKeyAgreement.PublicKey -> HPKEDiffieHellmanPublicKey,
            // KEMPrivateKey.PublicKey -> HPKEKEMPublicKey) -- confirmed via a minimal repro that
            // redeclaring the associatedtype with the narrower bound produces exactly this symbol.
            c = c.replacingOccurrences(
                of: "public protocol HPKEDiffieHellmanPrivateKey: DiffieHellmanKeyAgreement {\n}",
                with: "public protocol HPKEDiffieHellmanPrivateKey: DiffieHellmanKeyAgreement {\n    associatedtype PublicKey: HPKEDiffieHellmanPublicKey\n}")
            c = c.replacingOccurrences(
                of: "public protocol HPKEKEMPrivateKey: KEMPrivateKey {\n}",
                with: "public protocol HPKEKEMPrivateKey: KEMPrivateKey {\n    associatedtype PublicKey: HPKEKEMPublicKey\n}")

            // Fix: a bogus, truncated-name duplicate of XWingMLKEM768X25519 ("XWingMLKEM768X",
            // missing the "25519" suffix) is auto-generated alongside our hand-written real type
            // -- no real ABI symbol ever demangles to bare "XWingMLKEM768X" (confirmed by
            // grepping every demangled CryptoKit.tbd symbol), so this is a phantom placeholder,
            // same "bogus auto-generated duplicate" family as the Curve/Curve25519 fix above.
            // It compiled harmlessly as an unconstrained conformance until the associated
            // conformance descriptor fix above required an explicit `PublicKey` witness -- delete
            // the whole phantom block outright via balanced-brace scan (member order inside it is
            // nondeterministic across generator runs, so a literal multi-line match is unsafe).
            if let markerRange = c.range(of: "public enum XWingMLKEM768X: Hashable, @unchecked Sendable {") {
                var depth = 1
                var idx = markerRange.upperBound
                var endIdx: String.Index? = nil
                while idx < c.endIndex {
                    let ch = c[idx]
                    if ch == "{" { depth += 1 } else if ch == "}" {
                        depth -= 1
                        if depth == 0 { endIdx = c.index(after: idx); break }
                    }
                    idx = c.index(after: idx)
                }
                if let endIdx {
                    var removeEnd = endIdx
                    if removeEnd < c.endIndex, c[removeEnd] == "\n" {
                        removeEnd = c.index(after: removeEnd)
                    }
                    c.removeSubrange(markerRange.lowerBound..<removeEnd)
                }
            }

            // Fix: P256/P384/P521 already implement CorecryptoSupportedNISTCurve's requirements
            // (curveType, hash2fieldL) but never declare the conformance itself, and are missing
            // the associatedtype H witness entirely; similarly MLKEM768/MLKEM1024 already
            // implement CorecryptoSupportedMLKEMKEM's requirements (createPublicKey, kemType,
            // unmaskedKemType) but never declare the conformance, missing the associatedtype
            // publicKeyType witness. Confirmed via swift-demangle that both conformances (and
            // their witness tables, since these are concrete, non-generic types -- unlike the
            // generic-conformance witness-table gap seen elsewhere this session) are real ABI.
            for (curve, hashFn) in [("P256", "SHA256"), ("P384", "SHA384"), ("P521", "SHA512")] {
                c = c.replacingOccurrences(
                    of: "public enum \(curve) {",
                    with: "public enum \(curve): CorecryptoSupportedNISTCurve {\n    public typealias H = \(hashFn)")
            }
            for kem in ["MLKEM768", "MLKEM1024"] {
                c = c.replacingOccurrences(
                    of: "public enum \(kem) {",
                    with: "public enum \(kem): CorecryptoSupportedMLKEMKEM {\n    public typealias publicKeyType = \(kem).PublicKey")
            }

            // `SecureEnclave.P256`/`.P384`/`.P521`/`.Curve25519` are distinct nested enums that
            // shadow the top-level `P256`/`P384`/`P521`/`Curve25519` types of the same name. Bare
            // references like `P256.KeyAgreement.PublicKey` written inside SecureEnclave's own
            // nested types resolve to the *enclosing* SecureEnclave.P256 (which has no such
            // nested member) instead of the top-level type the real module actually means. Fully
            // qualify with the module name (unambiguous everywhere, including outside
            // SecureEnclave) so name lookup can't shadow it.
            for curve in ["P256", "P384", "P521", "Curve25519"] {
                c = c.replacingOccurrences(of: "\(curve).KeyAgreement.PublicKey", with: "CryptoKit.\(curve).KeyAgreement.PublicKey")
                c = c.replacingOccurrences(of: "\(curve).Signing.ECDSASignature", with: "CryptoKit.\(curve).Signing.ECDSASignature")
                c = c.replacingOccurrences(of: "\(curve).Signing.PublicKey", with: "CryptoKit.\(curve).Signing.PublicKey")
            }
            // Same shadowing issue for the post-quantum key types nested under SecureEnclave.
            for pqType in ["MLDSA65", "MLDSA87", "MLKEM1024", "MLKEM768"] {
                c = c.replacingOccurrences(of: "\(pqType).PublicKey", with: "CryptoKit.\(pqType).PublicKey")
            }
            // HPKEDiffieHellmanPublicKey requires `associatedtype EphemeralPrivateKey:
            // HPKEDiffieHellmanPrivateKeyGeneration where Self == Self.EphemeralPrivateKey.PublicKey`.
            // The sibling `KeyAgreement.PrivateKey` in the same nested scope satisfies the
            // where-clause (its own `publicKey` property already returns this exact PublicKey
            // type), but the compiler can't infer that witness purely from context — every
            // curve's `KeyAgreement.PublicKey` struct has this identical declaration line, so a
            // single global replace adds the associated-type alias for all of them at once.
            c = c.replacingOccurrences(
                of: "public struct PublicKey: HPKEDiffieHellmanPublicKey, HPKEPublicKeySerialization {",
                with: "public struct PublicKey: HPKEDiffieHellmanPublicKey, HPKEPublicKeySerialization {\n            public typealias EphemeralPrivateKey = PrivateKey")
            // Same associated-type-inference gap as HPKEDiffieHellmanPublicKey above, but for
            // HPKEKEMPublicKey (XWingMLKEM768X's sibling PrivateKey/PublicKey pair).
            c = c.replacingOccurrences(
                of: "public struct PublicKey: HPKEKEMPublicKey, HPKEPublicKeySerialization, KEMPublicKey {",
                with: "public struct PublicKey: HPKEKEMPublicKey, HPKEPublicKeySerialization, KEMPublicKey {\n        public typealias EphemeralPrivateKey = PrivateKey")
            // HashFunction's `associatedtype Digest: Digest` shadows the bound protocol with the
            // associated type's own name — qualify the bound with the module name.
            c = c.replacingOccurrences(of: "associatedtype Digest: Digest", with: "associatedtype Digest: CryptoKit.Digest")
        return c
    }
}
