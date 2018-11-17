@testable import AnimalShogi
import XCTest

final class PieceTests: XCTestCase {
    func testInitialization() {
        let testcases: [(Turn, Piece.Kind, String, UInt)] =
            [
                (.black, .hiyoko, "H", #line),
                (.black, .zou, "Z", #line),
                (.black, .kirin, "K", #line),
                (.black, .lion, "L", #line),
                (.black, .niwatori, "N", #line),
                (.white, .hiyoko, "h", #line),
                (.white, .zou, "z", #line),
                (.white, .kirin, "k", #line),
                (.white, .lion, "l", #line),
                (.white, .niwatori, "n", #line),
            ]

        for (turn, kind, string, line) in testcases {
            let piece = Piece(stringLiteral: string)
            XCTAssertEqual(piece.turn, turn, line: line)
            XCTAssertEqual(piece.kind, kind, line: line)
            XCTAssertEqual(piece.description, string, line: line)
        }
    }

    func testPromoted() {
        let testcases: [
            (Turn, Piece.Kind, UInt,
             /* isBlack: */ Bool, /* promoted: */ Piece.Kind?)
        ] = [
            (.black, .hiyoko, #line,
             true, .niwatori),
            (.black, .hiyoko, #line,
             true, .niwatori),
            (.black, .zou, #line,
             true, nil),
            (.black, .kirin, #line,
             true, nil),
            (.black, .lion, #line,
             true, nil),
            (.white, .hiyoko, #line,
             false, .niwatori),
            (.white, .hiyoko, #line,
             false, .niwatori),
        ]

        for (turn, kind, line, isBlack, expectedPromoted) in testcases {
            let piece = Piece(turn: turn, kind: kind)
            XCTAssertEqual(piece.isBlack, isBlack, line: line)
            XCTAssertEqual(piece.kind.promoted, expectedPromoted, line: line)

            if let promoted = piece.kind.promoted {
                XCTAssertEqual(promoted.unpromoted, piece.kind, line: line)
            } else {
                XCTAssertNil(piece.kind.unpromoted, line: line)
            }
        }

        for x in 0 ..< 3 {
            XCTAssertEqual(
                Piece(turn: .black, kind: .hiyoko).promoted(on: [x, 0]),
                Piece(turn: .black, kind: .niwatori)
            )

            XCTAssertEqual(
                Piece(turn: .white, kind: .hiyoko).promoted(on: [x, 3]),
                Piece(turn: .white, kind: .niwatori)
            )
        }
    }
}
