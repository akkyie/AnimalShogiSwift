@testable import AnimalShogi
import XCTest

final class StateTests: XCTestCase {
    func testReceived() {
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
}
