import AnimalShogi
import Foundation
import Network
import Willow

public enum Result {
    case data(Data)
    case error(Error)
}

@available(OSX 10.14, *)
public final class Connection {
    public typealias Handler = (Result) -> Void

    public var handler: Handler?
    public let logger: Logger
    public let queue: DispatchQueue

    private let connection: NWConnection

    public init(host: String, port: Int, logger: Logger, queue: DispatchQueue = .main) {
        guard let port = NWEndpoint.Port(rawValue: UInt16(port)) else {
            fatalError("Port is out of range")
        }

        self.queue = queue
        self.logger = logger

        let endpoint = NWEndpoint.hostPort(host: .init(host), port: port)
        connection = NWConnection(to: endpoint, using: .tcp)

        connection.stateUpdateHandler = { [logger, unowned self] connectionState in
            queue.async {
                logger.debugMessage("connection is \(connectionState)")
                switch connectionState {
                case let .waiting(error),
                     let .failed(error):
                    self.handler?(.error(error))
                case .ready:
                    self.receive()
                default:
                    break
                }
            }
        }
    }

    deinit {
        connection.forceCancel()
    }

    public func start() {
        queue.async { [connection, queue] in
            connection.start(queue: queue)
        }
    }

    public func cancel() {
        queue.async { [connection] in
            connection.cancel()
        }
    }

    public func send(data: Data) {
        queue.async { [connection, logger] in
            logger.errorMessage("sending: \(data)")
            connection.send(content: data, completion: .contentProcessed { error in
                logger.errorMessage("send: \(error?.debugDescription ?? "ok")")
            })
        }
    }

    private func receive() {
        queue.async { [unowned self] in
            self.connection.receive(
                minimumIncompleteLength: 1,
                maximumLength: 255,
                completion: self.received
            )
        }
    }

    private func received(data: Data?, context: NWConnection.ContentContext?, isComplete: Bool, error _: NWError?) {
        guard let data = data else {
            receive()
            return
        }

        handler?(.data(data))

        if !isComplete {
            receive()
        }
    }
}
