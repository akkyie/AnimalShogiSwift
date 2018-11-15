@testable import AnimalShogi
import XCTest

final class BoardTests: XCTestCase {
    func testInitialization() {
        let board = Board()

        XCTAssertEqual(board.pieces, [
            [0, 0]: Piece.white(.kirin),
            [1, 0]: Piece.white(.lion),
            [2, 0]: Piece.white(.zou),
            [1, 1]: Piece.white(.hiyoko),
            [1, 2]: Piece.black(.hiyoko),
            [0, 3]: Piece.black(.zou),
            [1, 3]: Piece.black(.lion),
            [2, 3]: Piece.black(.kirin),
        ])
    }

    func testMovablePoints() {
        let testcases: [(Position, Set<Position>, UInt)] = [
            ([0, 0], [[0, 1]], #line), // .theirs(.kirin)
            ([1, 0], [[0, 1], [2, 1]], #line), // .theirs(.lion)
            ([2, 0], [], #line), // .theirs(.zou)
            ([0, 1], [], #line), // nil
            ([1, 1], [[1, 2]], #line), // .theirs(.hiyoko)
            ([2, 1], [], #line), // nil
            ([0, 2], [], #line), // nil
            ([1, 2], [[1, 1]], #line), // .theirs(.hiyoko)
            ([2, 2], [], #line), // nil
            ([0, 3], [], #line), // .ours(.zou)
            ([1, 3], [[0, 2], [2, 2]], #line), // .theirs(.lion)
            ([2, 3], [[2, 2]], #line), // .ours(.kirin)
        ]

        let board = Board()
        for (position, expected, line) in testcases {
            let points = board.movablePoints(from: position)
            XCTAssertEqual(points, expected, "from: \(position)", line: line)
        }
    }
}
