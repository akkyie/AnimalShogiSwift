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

        connection.handler = { [unowned self, connection] result in
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

            let oldState = self.state
            for line in response.split(separator: "\n").map(String.init) {
                guard let message = Message(line: line) else {
                    logger.debugMessage("invalid line: \(line)")
                    continue
                }

                logger.debugMessage("received message: \(message)")

                guard let state = self.state.received(message: message) else {
                    logger.debugMessage("invalid message: \(message), state: \(self.state)")
                    continue
                }

                logger.debugMessage("new state: \(state)")

                self.state = state
            }


            if case .ended = self.state {
                connection.cancel()
                completion(nil)
                return
            }

            brain.handleStateChange(to: self.state, from: oldState) { message in
                logger.debugMessage("sending: \(message)")
                connection.send(data: String(message).data(using: .ascii)!)
            }
        }
    }

    func start() {
        connection.start()
    }
}
