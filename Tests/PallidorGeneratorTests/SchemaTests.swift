import XCTest
import OpenAPIKit
@testable import PallidorGenerator

class SchemaTests: XCTestCase {

    var sut : SchemaConverter?

    func testParseDefaultSchema() {
        initSUT(resource: .petstore)
        let test = sut!.getSchema(name: "Pet")!
        XCTAssertEqual(test.description, readResult(.Pet))
    }
    
    func testParseComplexSchema() {
        initSUT(resource: .lufthansa)
        let test = sut!.getSchema(name: "FlightAggregate")!
        XCTAssertEqual(test.description, readResult(.FlightAggregate))
    }
    
    func testParseDefaultEnum() {
        initSUT(resource: .lufthansa)
        let test = sut!.getSchema(name: "MessageLevel")!
        XCTAssertEqual(test.description, readResult(.MessageLevel))
    }
    
    func testParseResolvedTypeAliasSchema() {
        initSUT(resource: .lufthansa)
        let test = sut!.getSchema(name: "PeriodOfOperation")!
        XCTAssertEqual(test.description, readResult(.PeriodOfOperation))
    }
    
    func testParseOneOfSchema() {
        initSUT(resource: .wines)
        let test = sut!.getSchema(name: "PaymentInstallmentSchedule")!
        XCTAssertEqual(test.description, readResult(.PaymentInstallmentSchedule))
    }
    
    func testParseAnyOfSchema() {
        initSUT(resource: .wines_any)
        let test = sut!.getSchema(name: "PaymentInstallmentSchedule")!
        XCTAssertEqual(test.description, readResult(.PaymentInstallmentSchedule_Any))
    }
    
    private func initSUT(resource: Resources) {
        let apiSpec = readResource(resource)
        TypeAliases.parse(resolvedDoc: apiSpec!)
        sut = SchemaConverter(apiSpec!)
        sut!.parse()
    }
    
    override func tearDown() {
        TypeAliases.store = [String:String]()
        OpenAPIErrorModel.errorTypes = Set<String>()
    }
    
    static var allTests = [
        ("testParseDefaultSchema", testParseDefaultSchema),
        ("testParseDefaultEnum", testParseDefaultEnum),
        ("testParseComplexSchema", testParseComplexSchema),
        ("testParseResolvedTypeAliasSchema", testParseResolvedTypeAliasSchema),
        ("testParseOneOfSchema", testParseOneOfSchema),
        ("testParseAnyOfSchema", testParseAnyOfSchema)
    ]

}
