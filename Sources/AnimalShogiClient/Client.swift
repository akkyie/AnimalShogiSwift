import AnimalShogi
import Foundation
import Network
import Willow

@available(OSX 10.14, *)
final class Client {
    let connection: Connection
    let logger: Logger
    let brain: Brain

    private var state: State = .waitingBeginSummary

    init<T: Brain>(connection: Connection, logger: Logger, brain: T, completion: @escaping (Error?) -> Void) {
        self.connection = connection
        self.logger = logger
        self.brain = brain

        connection.handler = { [weak self, connection] result in
            guard let sself = self else {
                logger.errorMessage("self has already released")
                return
            }

            guard case let .data(data) = result else {
                if case let .error(error) = result {
                    logger.errorMessage("\(error)")
                    completion(error)
                    return
                } else {
                    completion(nil)
                    return
                }
            }

            guard let response = String(data: data, encoding: .ascii) else {
                logger.debugMessage("invalid response: \(data)")
                return
            }

            let oldState = sself.state
            for line in response.split(separator: "\n").map(String.init) {
                guard let message = Message(line: line) else {
                    logger.debugMessage("invalid line: \(line)")
                    continue
                }

                logger.debugMessage("received message: \(message)")

                guard let state = sself.state.received(message: message) else {
                    logger.debugMessage("invalid message: \(message), state: \(sself.state)")
                    continue
                }

                logger.debugMessage("new state: \(state)")

                sself.state = state
            }


            if case .ended = sself.state {
                completion(nil)
                return
            }

            brain.handleStateChange(to: sself.state, from: oldState) { message in
                logger.debugMessage("sending: \(message)")
                connection.send(data: String(message).data(using: .ascii)!)
            }
        }
    }

    func start() {
        connection.start()
    }
}
