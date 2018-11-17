@testable import AnimalShogi
import XCTest

final class BoardTests: XCTestCase {
    func testPositions() {
        let board = Board()

        let positions = board.positions
        XCTAssertEqual(positions.count, 3 * 4)
    }

    func testPieces() {
        let board = Board()

        XCTAssertEqual(board.pieces, [
            [0, 0]: "k",
            [1, 0]: "l",
            [2, 0]: "z",
            [1, 1]: "h",
            [1, 2]: "H",
            [0, 3]: "Z",
            [1, 3]: "L",
            [2, 3]: "K",
        ])
    }

    func testGetSet() {
        let original = Board()
        var board = original
        for position in board.positions {
            board[position] = board[position]
        }
        XCTAssertEqual(board, original)

        for position in board.positions {
            board[position] = nil
        }
        XCTAssertEqual(board.pieces.count, 0)
    }

    func testMove() {
        let original = Board()
        var board = Board()
        var from: Position = [1, 2]
        var to: Position = [1, 1]
        var piece = board[from]

        XCTAssertNoThrow(try board.move(turn: .black, from: from, to: to, isPromoted: false))
        XCTAssertEqual(board[from], nil)
        XCTAssertEqual(board[to], piece)
        XCTAssertEqual(board.blackCaptured, [.hiyoko])
        XCTAssertEqual(board.whiteCaptured, [])

        from = [1, 1]
        to = [1, 0]
        XCTAssertNoThrow(try board.move(turn: .black, from: from, to: to, isPromoted: true))
        XCTAssertEqual(board[from], nil)
        XCTAssertEqual(board[to], piece?.promoted(on: to))

        board = Board()
        from = [1, 1]
        to = [1, 2]
        piece = "h"
        XCTAssertNoThrow(try board.move(turn: .white, from: from, to: to, isPromoted: false))
        XCTAssertEqual(board[from], nil)
        XCTAssertEqual(board[to], piece)
        XCTAssertEqual(board.blackCaptured, [])
        XCTAssertEqual(board.whiteCaptured, [.hiyoko])

        board = Board()
        from = [1, 2]
        to = [1, 1]
        XCTAssertThrowsError(try board.move(turn: .white, from: from, to: to, isPromoted: false)) { error in
            XCTAssertEqual(error as? Board.Error, Board.Error.pieceNotMine(at: from))
        }
        XCTAssertEqual(board, original)

        board = Board()
        from = [0, 1]
        XCTAssertThrowsError(try board.move(turn: .black, from: from, to: to, isPromoted: false)) { error in
            XCTAssertEqual(error as? Board.Error, Board.Error.pieceNotFound(at: from))
        }
        XCTAssertEqual(board, original)

        board = Board()
        from = [0, 3]
        XCTAssertThrowsError(try board.move(turn: .black, from: from, to: to, isPromoted: true)) { error in
            XCTAssertEqual(error as? Board.Error, Board.Error.pieceNotPromotable(at: to))
        }
        XCTAssertEqual(board, original)
    }

    func testDrop() {
        var board = Board()
        var from: Position = [1, 2]
        var to: Position = [1, 1]
        var piece = board[from]

        XCTAssertNoThrow(try board.move(turn: .black, from: from, to: to, isPromoted: false))
        XCTAssertEqual(board[from], nil)
        XCTAssertEqual(board[to], piece)
        XCTAssertEqual(board.blackCaptured, [.hiyoko])
        XCTAssertEqual(board.whiteCaptured, [])

        to = [1, 3]
        XCTAssertThrowsError(try board.drop(turn: .black, kind: .hiyoko, to: to)) { error in
            XCTAssertEqual(error as? Board.Error, .pieceAlreadyExists(at: to))
        }
        XCTAssertEqual(board.blackCaptured, [.hiyoko])
        XCTAssertEqual(board.whiteCaptured, [])

        to = [0, 1]
        XCTAssertNoThrow(try board.drop(turn: .black, kind: .hiyoko, to: to))
        XCTAssertEqual(board[from], nil)
        XCTAssertEqual(board[to], piece)
        XCTAssertEqual(board.blackCaptured, [])
        XCTAssertEqual(board.whiteCaptured, [])

        board = Board()
        XCTAssertThrowsError(try board.drop(turn: .black, kind: .hiyoko, to: [0, 2])) { error in
            XCTAssertEqual(error as? Board.Error, .pieceNotCaptured(kind: .hiyoko))
        }

        board = Board()
        from = [1, 1]
        to = [1, 2]
        piece = board[from]
        XCTAssertNoThrow(try board.move(turn: .white, from: from, to: to, isPromoted: false))
        XCTAssertEqual(board[from], nil)
        XCTAssertEqual(board[to], piece)
        XCTAssertEqual(board.blackCaptured, [])
        XCTAssertEqual(board.whiteCaptured, [.hiyoko])

        to = [1, 3]
        XCTAssertThrowsError(try board.drop(turn: .white, kind: .hiyoko, to: to)) { error in
            XCTAssertEqual(error as? Board.Error, .pieceAlreadyExists(at: to))
        }
        XCTAssertEqual(board.blackCaptured, [])
        XCTAssertEqual(board.whiteCaptured, [.hiyoko])

        to = [0, 1]
        XCTAssertNoThrow(try board.drop(turn: .white, kind: .hiyoko, to: to))
        XCTAssertEqual(board[from], nil)
        XCTAssertEqual(board[to], piece)
        XCTAssertEqual(board.blackCaptured, [])
        XCTAssertEqual(board.whiteCaptured, [])

        board = Board()
        XCTAssertThrowsError(try board.drop(turn: .white, kind: .hiyoko, to: [0, 2])) { error in
            XCTAssertEqual(error as? Board.Error, .pieceNotCaptured(kind: .hiyoko))
        }
    }

    func testDescription() {
        let board = Board()
        XCTAssertEqual(board.description, """
        |k|l|z|
        | |h| |
        | |H| |
        |Z|L|K|
        """)
    }
}
