import AnimalShogi
import Commander
import Foundation
import Network
import Willow

extension Logger {
    fileprivate static func `for`(_: String) -> Logger {
        return Logger(logLevels: .all, writers: [
            ConsoleWriter(method: .print),
        ])
    }
}

let main = command(
    Option("host", default: "localhost"),
    Option("port", default: 8080)
) { host, port in
    guard #available(OSX 10.14, *) else {
        fatalError("AnimalShogiClient supports macOS >10.12")
    }

    let logger = Logger.for("main")
    let brain = RandomBrain()
    let connection = Connection(host: host, port: port, logger: .for("connection"))
    let client = Client(connection: connection, logger: .for("client"), brain: brain) { result in
        switch result {
        case let .ended(result, isIllegal):
            logger.infoMessage("GAME ENDED: \(result)")
            exit(isIllegal ? 1 : 0)
        case let .error(error):
            logger.errorMessage("ERROR: \(error)")
            exit(1)
        }
    }
    client.start()

    dispatchMain()
}

main.run()
