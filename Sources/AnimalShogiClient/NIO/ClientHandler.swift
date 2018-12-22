import AnimalShogi
import Foundation
import NIO

final class ClientHandler: ChannelInboundHandler {
    typealias InboundIn = ServerMessage
    typealias OutboundOut = ClientMessage

    private let client: Client

    public private(set) var board: Board?
    private var state: ProtocolState = .waitingBeginSummary

    init(client: Client) {
        self.client = client
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let message = unwrapInboundIn(data)
        dump(message, name: "Client Received")

        client.handle(message: message) { event in
            switch event {
            case let .message(message):
                ctx.writeAndFlush(wrapOutboundOut(message), promise: nil)
            case let .end(result):
                // let the server close our connection
                // ctx.close(promise: nil)
                dump("\(result)", name: "Game Ended")
            case let .error(error):
                ctx.fireErrorCaught(error)
            }
        }
    }
}
