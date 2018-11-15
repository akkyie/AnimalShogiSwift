@testable import AnimalShogi
import XCTest

final class MessageTests: XCTestCase {
    func testInitialization() {
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

    func testDescription() {
        let testcases: [(String, String, UInt)] = [
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
}
