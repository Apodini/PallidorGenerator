import XCTest
import OpenAPIKit
@testable import PallidorGenerator

class APITests: XCTestCase {

    var sut : APIConverter?
    
    func testParseTypeAliasResultMethod() {
        initSUT(resource: .lufthansa)
        let test = sut!.getOperation("getPassengerFlights", in: "Flightschedules")!
        XCTAssertEqual(test.description, readResult(.LH_GetPassengerFlights))
    }
    
    func testParseDefaultResultMethod() {
        initSUT(resource: .petstore)
        let test = sut!.getOperation("addPet", in: "Pet")!
        XCTAssertEqual(test.description, readResult(.Pet_addPet))
    }
    
    func testParseSimpleResultMethod() {
        initSUT(resource: .petstore)
        let test = sut!.getOperation("updatePetWithForm", in: "Pet")!
        XCTAssertEqual(test.description, readResult(.Pet_updatePetWithForm))
    }
    
    func testParseSimpleEndpointMethod() {
        initSUT(resource: .petstore)
        let test = sut!.getEndpoint("Pet")!
        XCTAssertEqual(test.description, readResult(.Pet_Endpoint))
    }
    
    private func initSUT(resource: Resources) {
        let apiSpec = readResource(resource)
        TypeAliases.parse(resolvedDoc: apiSpec!)
        sut = APIConverter(apiSpec!)
        sut!.parse()
    }
    
    override func tearDown() {
        TypeAliases.store = [String:String]()
        OpenAPIErrorModel.errorTypes = Set<String>()
    }
    
    static var allTests = [
        ("testParseTypeAliasResultMethod", testParseTypeAliasResultMethod),
        ("testParseDefaultResultMethod", testParseDefaultResultMethod),
        ("testParseSimpleResultMethod", testParseSimpleResultMethod),
        ("testParseSimpleEndpointMethod", testParseSimpleEndpointMethod)
    ]

}
