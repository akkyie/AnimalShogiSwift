import AnimalShogi
import Foundation
import NIO

final class MessageHandler: ChannelInboundHandler, ChannelOutboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ServerMessage
    typealias OutboundIn = ClientMessage
    typealias OutboundOut = ByteBuffer

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        guard buffer.readableBytes > 0 else {
            assertionFailure()
            return
        }

        let string = buffer.readString(length: buffer.readableBytes)!
        let message = ServerMessage(line: string)
        dump(message, name: "Incoming Message")
        ctx.fireChannelRead(wrapInboundOut(message))
    }

    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let message = unwrapOutboundIn(data)
        dump(message, name: "Outgoing Message")

        guard let data = String(message).data(using: .utf8), data.count > 0 else {
            assertionFailure()
            return
        }

        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.write(bytes: data)
        ctx.writeAndFlush(wrapOutboundOut(buffer), promise: promise)
    }
}
