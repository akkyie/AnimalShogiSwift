@testable import AnimalShogi
import XCTest

final class DumbBrain: Brain {
    func handleBoardChange(summary _: GameSummary, board _: Board, sendMessage _: (ClientMessage) -> Void) {}
}

final class ClientTests: XCTestCase {
    var brain: DumbBrain!
    var client: Client!

    override func setUp() {
        brain = DumbBrain()
        client = Client(brain: brain)
    }

    func testStart() {
        client.handle(message: .beginSummary, onEvent: { event in
            XCTFail("No event should not to be received, but got \(event)")
        })
        client.handle(message: .gameID("test"), onEvent: { event in
            XCTFail("No event should not to be received, but got \(event)")
        })
        client.handle(message: .turn(.black), onEvent: { event in
            XCTFail("No event should not to be received, but got \(event)")
        })
        client.handle(message: .endSummary, onEvent: { (event: Client.Event) in
            switch event {
            case .message(.agree),
                 .message(.login):
                break
            default:
                XCTFail("\(event)")
            }
        })

        // FIXME: Add more tests
    }
}
