import XCTest
@testable import Slab

final class SlabTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Slab().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
