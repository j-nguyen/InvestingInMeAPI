#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppTests
    testCase(AssetControllerTests.allTests)
])

#endif
