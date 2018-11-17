@testable import AnimalShogi
import XCTest

final class MessageTests: XCTestCase {
    func testInitialization() {
        let testcases: [(String, Message, UInt)] = [
            ("BEGIN Game_Summary", .beginSummary, #line),
            ("END Game_Summary", .endSummary, #line),
            ("Game_ID:20180910-001", .gameID("20180910-001"), #line),
            ("Your_Turn:+", .turn(.black), #line),
            ("Your_Turn:-", .turn(.white), #line),
            ("AGREE", .agree, #line),
            ("START", .start, #line),
            ("Game_ID:20180910-001", .gameID("20180910-001"), #line),
            ("+2c2b", .move(turn: .black, from: [1, 2], to: [1, 1], isPromoted: false), #line),
            ("+2c2b+", .move(turn: .black, from: [1, 2], to: [1, 1], isPromoted: true), #line),
            ("+h*2b", .drop(turn: .black, kind: .hiyoko, to: [1, 1]), #line),
            ("-h*2b", .drop(turn: .white, kind: .hiyoko, to: [1, 1]), #line),
            ("+2c2b,OK", .moved(turn: .black, from: [1, 2], to: [1, 1], isPromoted: false), #line),
            ("-2c2b+,OK", .moved(turn: .white, from: [1, 2], to: [1, 1], isPromoted: true), #line),
            ("+h*2b,OK", .dropped(turn: .black, kind: .hiyoko, to: [1, 1]), #line),
            ("-h*2b,OK", .dropped(turn: .white, kind: .hiyoko, to: [1, 1]), #line),
            ("#GAME_OVER", .gameOver(isIllegal: false), #line),
            ("#ILLEGAL", .gameOver(isIllegal: true), #line),
            ("#WIN", .result(.win), #line),
            ("#DRAW", .result(.draw), #line),
            ("#LOSE", .result(.lose), #line),
            ("asdf", .chat("asdf"), #line),
            ("-2c2b-", .chat("-2c2b-"), #line),
            ("+h*2b+", .chat("+h*2b+"), #line),
        ]

        for (line, expected, lineNumber) in testcases {
            let message = Message(line: line)
            XCTAssertEqual(message, expected, line: lineNumber)
            XCTAssertEqual(String(message), line, line: lineNumber)
        }
    }
}
