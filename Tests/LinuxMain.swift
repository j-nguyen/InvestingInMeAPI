#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppTests
    testCase(AssetControllerTests.allTests),
    testCase(ConnectionControllerTests.allTests),
    testCase(FeaturedProjectControllerTests.allTests),
    testCase(ProjectControllerTests.allTests),
    testCase(NotificationControllerTests.allTests)
])

#endif
