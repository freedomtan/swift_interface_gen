import XCTest
@testable import SwiftInterfaceGen

final class SwiftInterfaceGenTests: XCTestCase {
    func testParserBasic() throws {
        let parser = Parser()
        
        // Mock some symbols
        parser.parse(mangled: "_$s12ModelCatalog7UseCaseV", demangled: "ModelCatalog.UseCase")
        parser.parse(mangled: "_$s12ModelCatalog7UseCaseV10identifierAA0cD10IdentifierVvg", 
                     demangled: "ModelCatalog.UseCase.identifier.getter : ModelCatalog.UseCaseIdentifier")
        
        let output = parser.generateAll()
        XCTAssertTrue(output.contains("struct UseCase"))
        XCTAssertTrue(output.contains("var identifier: ModelCatalog.UseCaseIdentifier { get }"))
    }
    
    func testProtocol() throws {
        let parser = Parser()
        parser.parse(mangled: "_$s12ModelCatalog8LLMModelMp", demangled: "protocol descriptor for ModelCatalog.LLMModel")
        
        let output = parser.generateAll()
        XCTAssertTrue(output.contains("protocol LLMModel"))
    }
}
