import AnimalShogi
import Commander
import Foundation
import NIO
import NIOExtras

let main = command(
    Option("host", default: "localhost"),
    Option("port", default: 8080)
) { host, port in
    let brain = RandomBrain()
    let client = Client(brain: brain)

    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap = ClientBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            channel.pipeline.addHandlers([
                LineBasedFrameDecoder(),
                MessageHandler(),
                ClientHandler(client: client),
            ], first: true)
        }
    defer {
        try! group.syncShutdownGracefully()
    }

    do {
        let channel = try bootstrap.connect(host: host, port: port).wait()
        print("Connected: \(host):\(port)")

        try channel.closeFuture.wait()
        print("Connection closed: \(host):\(port)")
    } catch {
        print("\(error)")
    }
}

main.run()
