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
    
    func testParseDefaultResultMethodNoAuth() {
        initSUT(resource: .petstore_httpMethodChanged)
        let test = sut!.getOperation("addPet", in: "Pet")!
        // modify "authorization" parameter to be optional.
        // uses authorized result of "addPet" method
        var result = readResult(.Pet_addPet)
        result = result.replacingOccurrences(of: "authorization: HTTPAuthorization = NetworkManager.authorization!", with: "authorization: HTTPAuthorization? = NetworkManager.authorization")
        XCTAssertEqual(test.description, result)
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
    
    func testParseSimpleEndpointMethodChangedHTTPMethod() {
        initSUT(resource: .petstore_httpMethodChanged)
        let test = sut!.getOperation("updatePet", in: "Pet")!
        XCTAssertEqual(test.description, readResult(.Pet_updatePetChangedHTTPMethod))
    }
    
    func testParseSimpleEndpointMinMaxMethod() {
        initSUT(resource: .petstore_minMax)
        let test = sut!.getOperation("getPetById", in: "Pet")!
        XCTAssertEqual(test.description, readResult(.Pet_getPetByIdMinMax))
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
        ("testParseSimpleEndpointMethod", testParseSimpleEndpointMethod),
        ("testParseSimpleEndpointMethodChangedHTTPMethod", testParseSimpleEndpointMethodChangedHTTPMethod),
        ("testParseSimpleEndpointMinMaxMethod", testParseSimpleEndpointMinMaxMethod)
    ]

}
