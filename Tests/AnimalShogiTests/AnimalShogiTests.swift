import XCTest
@testable import AnimalShogi

final class AnimalShogiTests: XCTestCase {
    func testMessage() {
        let testcases: [String: Message] = [
            "BEGIN Game_Summary": .beginSummary,
            "END Game_Summary": .endSummary,
            "Game_ID:20180910-001": .gameID("20180910-001"),
            "Your_Turn:+": .turn(isBlack: true),
            "Your_Turn:-": .turn(isBlack: false),
            "AGREE": .agree,
            "START": .start,
            "#GAME_OVER": .gameOver(isIllegal: false),
            "#ILLEGAL_MOVE": .gameOver(isIllegal: true),
            "#WIN": .result(.win),
            "#DRAW": .result(.draw),
            "#LOSE": .result(.lose),
        ]

        for (line, expected) in testcases {
            XCTAssertEqual(Message(line: line), expected, "line: \(line)")
        }
    }

    func testMovablePoints() {
        let testcases: [Position: Set<Position>] = [
            [0, 0]: [[0, 1]],         // .theirs(.kirin)
            [1, 0]: [[0, 1], [2, 1]], // .theirs(.lion)
            [2, 0]: [],               // .theirs(.zou)
            [0, 1]: [],               // nil
            [1, 1]: [[1, 2]],         // .theirs(.hiyoko)
            [2, 1]: [],               // nil
            [0, 2]: [],               // nil
            [1, 2]: [[1, 1]],         // .theirs(.hiyoko)
            [2, 2]: [],               // nil
            [0, 3]: [],               // .ours(.zou)
            [1, 3]: [[0, 2], [2, 2]], // .theirs(.lion)
            [2, 3]: [[2, 2]],         // .ours(.kirin)
        ]

        let board = Board()
        for (position, expected) in testcases {
            let points = Piece.movablePoints(from: position, in: board)
            XCTAssertEqual(points, expected, "from: \(position)")
        }
    }

    static var allTests = [
        ("testMessage", testMessage),
    ]
}
