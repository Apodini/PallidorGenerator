import XCTest

import PallidorGeneratorTests

var tests = [XCTestCaseEntry]()
tests += PallidorGenerator.allTests()
tests += APITests.allTests()
tests += SchemaTests.allTests()
XCTMain(tests)
