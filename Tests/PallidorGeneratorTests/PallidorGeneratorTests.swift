import XCTest
import PathKit
import OpenAPIKit
@testable import PallidorGenerator

final class PallidorGeneratorTests: XCTestCase {
    
    var sut : MetaModelConverter?
    
    func testGenerateErrorModel() {
        initSUT(resource: .lufthansa)
        XCTAssertEqual(OpenAPIErrorModel.errorTypes.first!, "ErrorResponse")
    }
    
    private func initSUT(resource: Resources) {
        let apiSpec = readResource(resource)
        TypeAliases.parse(resolvedDoc: apiSpec!)
        var schemas = SchemaConverter(apiSpec!)
        schemas.parse()
        var apis = APIConverter(apiSpec!)
        apis.parse()
        sut = MetaModelConverter()
    }
    
    static var allTests = [
        ("testGenerateErrorModel", testGenerateErrorModel)
    ]

}
