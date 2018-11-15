@testable import AnimalShogi
import XCTest

final class PositionTests: XCTestCase {
    func testDescription() {
        let testcases: [(String, String, UInt)] = [
            (Position(x: 0, y: 0)!.description, "1a", #line),
            (Position(x: 2, y: 3)!.description, "3d", #line),
            (Position(x: 0, y: 0)!.description, "1a", #line),
            (Position(x: 2, y: 3)!.description, "3d", #line),
        ]

        for (position, expected, line) in testcases {
            XCTAssertEqual(position.description, expected, line: line)
        }
    }
}
