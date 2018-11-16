import AnimalShogi
import Foundation
import Network
import Willow

@available(OSX 10.14, *)
final class Client {
    enum Result {
        case ended(GameResult, isIllegal: Bool)
        case error(Error)
    }

    enum Error: Swift.Error {
        case unknown(Swift.Error?)
        case connection(Swift.Error)
        case board(Board.Error)
        case invalidResponse(Data)
        case invalidMessage(Message, state: ProtocolState)
        case messageNotConvertible(Message)
        case gameNotStarted(message: Message, state: ProtocolState)
    }

    typealias Completion = (Result) -> Void

    let connection: Connection
    let logger: Logger
    let brain: Brain

    var board: Board?

    private var state: ProtocolState = .waitingBeginSummary

    init<T: Brain>(connection: Connection, logger: Logger, brain: T, completion: @escaping Completion) {
        self.connection = connection
        self.logger = logger
        self.brain = brain

        connection.handler = { [unowned self] result in
            guard case let .data(data) = result else {
                if case let .error(error) = result {
                    completion(.error(.connection(error)))
                } else {
                    completion(.error(.unknown(nil)))
                }
                return
            }

            guard let response = String(data: data, encoding: .ascii) else {
                completion(.error(.invalidResponse(data)))
                return
            }

            for line in response.split(separator: "\n").map(String.init) {
                let message = Message(line: line)
                self.handle(message: message, completion: completion)
            }
        }
    }

    func start() {
        connection.start()
    }

    private func handle(message: Message, completion: @escaping Completion) {
        logger.debugMessage("received message: \(message)")

        if let state = state.received(message: message) {
            logger.debugMessage("new state: \(state)")
            self.state = state
        }

        if case .starting = state {
            sendMessage(.agree)
            return
        }

        guard !state.hasEnded else {
            if case let .ended(_, isIllegal, result) = state {
                completion(.ended(result, isIllegal: isIllegal))
            }
            return
        }

        guard state.hasStarted, let summary = state.summary else {
            return
        }

        if case .start = message {
            logger.debugMessage("game started")

            let board = Board()
            self.board = board

            if summary.turn == .black {
                brain.handleBoardChange(summary: summary, board: board, sendMessage: sendMessage)
            }
            return
        }

        guard var board = board else {
            completion(.error(.gameNotStarted(message: message, state: state)))
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
                completion(.error(.invalidMessage(message, state: state)))
                return
            }
            self.board = board

            if hasOppositeMoved {
                brain.handleBoardChange(summary: summary, board: board, sendMessage: sendMessage)
            }
        } catch let error as Board.Error {
            completion(.error(.board(error)))
        } catch let error {
            completion(.error(.unknown(error)))
        }
    }

    private func sendMessage(_ message: Message) {
        guard let data = String(message).data(using: .ascii) else {
            fatalError("message is not convertible: \(message)")
        }

        logger.debugMessage("sending message: \(message)")

        connection.send(data: data)
    }
}
