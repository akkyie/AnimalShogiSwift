import Foundation

public final class Client {
    public enum Event: Equatable {
        case message(ClientMessage)
        case end(GameResult, isIllegal: Bool)
        case error(Error)
    }

    public enum Error: Swift.Error, Equatable {
        case unknown(NSError)
        case decodingMessage
        case board(Board.Error)
        case invalidResponse(Data)
        case invalidMessage(ServerMessage, state: ProtocolState)
        case gameNotStarted(message: ServerMessage, state: ProtocolState)
    }

    public typealias EventHandler = (Event) -> Void
    public typealias SendMessage = (ClientMessage) throws -> Void

    public let brain: Brain

    public private(set) var board: Board?

    private var state: ProtocolState = .waitingBeginSummary

    public init(brain: Brain) {
        self.brain = brain
    }

    public func handle(message: ServerMessage, onEvent send: EventHandler) {
        if let state = state.received(message: message) {
            self.state = state
        }

        guard let summary = state.summary else {
            return
        }

        if case .starting = state, board == nil {
            send(.message(.agree))

            let board = Board()
            self.board = board

            return
        }

        if case .start = message, let board = self.board, summary.turn == .black {
            brain.handleBoardChange(summary: summary, board: board, sendMessage: { send(.message($0)) })
            return
        }

        guard !state.hasEnded else {
            if case let .ended(_, isIllegal, result) = state {
                send(.end(result, isIllegal: isIllegal))
            }
            return
        }

        guard var board = board else {
            send(.error(.gameNotStarted(message: message, state: state)))
            return
        }

        do {
            let hasOppositeMoved: Bool

            switch message {
            case let .moved(turn, from, to, isPromoted):
                hasOppositeMoved = turn != summary.turn
                try board.move(turn: turn, from: from, to: to, isPromoted: isPromoted)
            case let .dropped(turn, kind, to):
                hasOppositeMoved = turn != summary.turn
                try board.drop(turn: turn, kind: kind, to: to)
            default:
                send(.error(.invalidMessage(message, state: state)))
                return
            }
            self.board = board

            if hasOppositeMoved {
                brain.handleBoardChange(summary: summary, board: board, sendMessage: { send(.message($0)) })
            }
        } catch let error as Board.Error {
            send(.error(.board(error)))
        } catch {
            send(.error(.unknown(error as NSError)))
        }
    }
}
