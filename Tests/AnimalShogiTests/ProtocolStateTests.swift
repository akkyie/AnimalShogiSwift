@testable import AnimalShogi
import XCTest

final class StateTests: XCTestCase {
    func testReceived() {
        let summary = GameSummary(id: "asdf", turn: .black)

        let testcases: [(
            ProtocolState, /* line: */ UInt,
            Message,
            ProtocolState?,
            /* hasStarted: */ Bool?, /* hasEnded: */ Bool?, /* summary: */ GameSummary?
        )] = [
            (.waitingBeginSummary, #line,
             .beginSummary,
             .waitingID,
             false, false, nil),

            (.waitingID, #line,
             .gameID("asdf"),
             .waitingTurn(id: "asdf"),
             false, false, nil),

            (.waitingTurn(id: "asdf"), #line,
             .turn(.black),
             .waitingEndSummary(summary),
             false, false, summary),

            (.waitingTurn(id: "asdf"), #line,
             .turn(.white),
             .waitingEndSummary(GameSummary(id: "asdf", turn: .white)),
             false, false, GameSummary(id: "asdf", turn: .white)),

            (.waitingEndSummary(summary), #line,
             .endSummary,
             .starting(summary: summary),
             false, false, summary),

            (.starting(summary: summary), #line,
             .start,
             .started(summary: summary),
             true, false, summary),

            (.started(summary: summary), #line,
             .gameOver(isIllegal: false),
             .waitingResult(summary: summary, isIllegal: false),
             true, true, summary),

            (.started(summary: summary), #line,
             .gameOver(isIllegal: true),
             .waitingResult(summary: summary, isIllegal: true),
             true, true, summary),

            (.waitingResult(summary: summary, isIllegal: false), #line,
             .result(.lose),
             .ended(summary: summary, isIllegal: false, result: .lose),
             true, true, summary),

            (.waitingResult(summary: summary, isIllegal: false), #line,
             .result(.win),
             .ended(summary: summary, isIllegal: false, result: .win),
             true, true, summary),

            (.waitingResult(summary: summary, isIllegal: false), #line,
             .result(.draw),
             .ended(summary: summary, isIllegal: false, result: .draw),
             true, true, summary),

            (.waitingBeginSummary, #line,
             .gameID("asdf"),
             nil,
             nil, nil, nil),
        ]

        for (before, line, message, expected, hasStarted, hasEnded, summary) in testcases {
            let after = before.received(message: message)
            XCTAssertEqual(after, expected, line: line)
            XCTAssertEqual(after?.hasStarted, hasStarted, line: line)
            XCTAssertEqual(after?.hasEnded, hasEnded, line: line)
            XCTAssertEqual(after?.summary, summary, line: line)
        }
    }
}
