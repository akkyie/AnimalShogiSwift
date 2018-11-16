@testable import AnimalShogi
import XCTest

final class PositionTests: XCTestCase {
    func testDescription() {
        let testcases: [(String, Position?, String?, UInt)] = [
            ("1a", Position(x: 0, y: 0), "1a (0, 0)", #line),
            ("3d", Position(x: 2, y: 3), "3d (2, 3)", #line),
            ("1a", Position(x: 0, y: 0), "1a (0, 0)", #line),
            ("3d", Position(x: 2, y: 3), "3d (2, 3)", #line),
            ("1e", nil, nil, #line),
            ("4a", nil, nil, #line),
            ("asdf", nil, nil, #line),
        ]

        for (string, expected, debugDescription, line) in testcases {
            let position = Position(string)
            XCTAssertEqual(position, expected, line: line)
            if let position = position {
                XCTAssertEqual(position.description, string, line: line)
                XCTAssertEqual(position.debugDescription, debugDescription, line: line)
            }
        }
    }
}
