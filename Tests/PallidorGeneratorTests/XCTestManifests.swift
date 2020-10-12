import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PallidorGeneratorTests.allTests),
        testCase(APITests.allTests),
        testCase(SchemaTests.allTests)
    ]
}
#endif
