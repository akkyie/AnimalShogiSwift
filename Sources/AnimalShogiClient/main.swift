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
    Option("host", default: "shogi.keio.app"),
    Option("port", default: 80)
) { host, port in
    guard #available(OSX 10.14, *) else {
        fatalError("AnimalShogiClient supports macOS >10.12")
    }

    let brain = RandomBrain()
    let connection = Connection(host: host, port: port, logger: Logger.for("connection"))
    let client = Client(connection: connection, logger: Logger.for("client"), brain: brain) { error in
        exit(error == nil ? 0 : 1)
    }
    client.start()

    dispatchMain()
}

main.run()
