@testable import AnimalShogi
import XCTest

final class AnimalShogiTests: XCTestCase {
    func testMessage() {
        let testcases: [(String, Message, UInt)] = [
            ("BEGIN Game_Summary", .beginSummary, #line),
            ("END Game_Summary", .endSummary, #line),
            ("Game_ID:20180910-001", .gameID("20180910-001"), #line),
            ("Your_Turn:+", .turn(isBlack: true), #line),
            ("Your_Turn:-", .turn(isBlack: false), #line),
            ("AGREE", .agree, #line),
            ("START", .start, #line),
            ("Game_ID:20180910-001", .gameID("20180910-001"), #line),
            ("+2c2b", .move(from: [1, 2], to: [1, 1], isBlack: true, isPromoted: false), #line),
            ("+2c2b+", .move(from: [1, 2], to: [1, 1], isBlack: true, isPromoted: true), #line),
            ("+2c2b,OK", .moved(from: [1, 2], to: [1, 1], isBlack: true, isPromoted: false), #line),
            ("-2c2b+,OK", .moved(from: [1, 2], to: [1, 1], isBlack: false, isPromoted: true), #line),
            ("#GAME_OVER", .gameOver(isIllegal: false), #line),
            ("#ILLEGAL", .gameOver(isIllegal: true), #line),
            ("#WIN", .result(.win), #line),
            ("#DRAW", .result(.draw), #line),
            ("#LOSE", .result(.lose), #line),
        ]

        for (line, expected, lineNumber) in testcases {
            XCTAssertEqual(
                Message(line: line), expected,
                "line: \(line)", line: lineNumber
            )
        }
    }

    func testState() {
        let testcases: [(State, Message, State, UInt)] = [
            (.waitingBeginSummary, .beginSummary,
             .waitingID, #line),
            (.waitingID, .gameID("asdf"),
             .waitingTurn(id: "asdf"), #line),
            (.waitingTurn(id: "qwer"), .turn(isBlack: false),
             .waitingEndSummary(id: "qwer", isBlack: false), #line),
            (.waitingTurn(id: "zxcv"), .turn(isBlack: true),
             .waitingEndSummary(id: "zxcv", isBlack: true), #line),
            (.waitingEndSummary(id: "asdf", isBlack: true), .endSummary,
             .starting(id: "asdf", isBlack: true), #line),
            (.starting(id: "qwer", isBlack: true), .start,
             .started(id: "qwer", isBlack: true), #line),
            (.started(id: "asdf", isBlack: true), .moved(from: [0, 0], to: [2, 3], isBlack: false, isPromoted: false),
             .moved(id: "asdf", isBlack: false, from: [0, 0], to: [2, 3], isPromoted: false), #line),
            (.started(id: "asdf", isBlack: true), .moved(from: [0, 0], to: [2, 3], isBlack: true, isPromoted: false),
             .moved(id: "asdf", isBlack: true, from: [0, 0], to: [2, 3], isPromoted: false), #line),
            (.moved(id: "zxcv", isBlack: false, from: [0, 0], to: [2, 3], isPromoted: false), .gameOver(isIllegal: true),
             .waitingResult(id: "zxcv", isBlack: false, isIllegal: true), #line),
            (.moved(id: "asdf", isBlack: false, from: [0, 0], to: [2, 3], isPromoted: false), .gameOver(isIllegal: false),
             .waitingResult(id: "asdf", isBlack: false, isIllegal: false), #line),
            (.waitingResult(id: "zxcv", isBlack: true, isIllegal: true), .result(.lose),
             .ended(id: "zxcv", isBlack: true, isIllegal: true, result: .lose), #line),
            (.waitingResult(id: "qwer", isBlack: true, isIllegal: false), .result(.win),
             .ended(id: "qwer", isBlack: true, isIllegal: false, result: .win), #line),
            (.waitingResult(id: "asdf", isBlack: true, isIllegal: false), .result(.draw),
             .ended(id: "asdf", isBlack: true, isIllegal: false, result: .draw), #line),
        ]

        for (state, message, expected, line) in testcases {
            XCTAssertEqual(
                state.received(message: message), expected,
                "\(state) -> \(message) -> \(expected)", line: line
            )
        }
    }

    func testPieces() {
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

    func testDescription() {
        let testcases: [(String, String, UInt)] = [
            (Position(x: 0, y: 0)!.description, "1a", #line),
            (Position(x: 2, y: 3)!.description, "3d", #line),
            (Position(x: 0, y: 0)!.description, "1a", #line),
            (Position(x: 2, y: 3)!.description, "3d", #line),

            (String(Message.beginSummary), "BEGIN Game_Summary", #line),
            (String(Message.gameID("hogefuga")), "hogefuga", #line),
            (String(Message.turn(isBlack: true)), "Your_Turn:+", #line),
            (String(Message.turn(isBlack: false)), "Your_Turn:-", #line),
            (String(Message.endSummary), "END Game_Summary", #line),
            (String(Message.agree), "AGREE", #line),
            (String(Message.start), "START", #line),
            (String(Message.move(from: [0, 1], to: [2, 3], isBlack: true, isPromoted: false)), "+1b3d", #line),
            (String(Message.move(from: [2, 3], to: [0, 1], isBlack: false, isPromoted: false)), "-3d1b", #line),
            (String(Message.moved(from: [0, 1], to: [2, 3], isBlack: true, isPromoted: false)), "+1b3d,OK", #line),
            (String(Message.moved(from: [2, 3], to: [0, 1], isBlack: false, isPromoted: false)), "-3d1b,OK", #line),
            (String(Message.gameOver(isIllegal: false)), "#GAME_OVER", #line),
            (String(Message.gameOver(isIllegal: true)), "#ILLEGAL_MOVE", #line),
            (String(Message.result(.win)), "#WIN", #line),
            (String(Message.result(.draw)), "#DRAW", #line),
            (String(Message.result(.lose)), "#LOSE", #line),
        ]

        for (position, expected, line) in testcases {
            XCTAssertEqual(position.description, expected, line: line)
        }
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
