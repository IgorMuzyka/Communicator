
import TypePreservingCodingAdapter

open class Server<Peer, GenericProxy: Proxy, GenericDispatcher>
    where
	GenericDispatcher: DedicatedDispatcher,
	GenericDispatcher.DedicatedPeer == Peer
{
    public struct ServerError: Error, Codable {

        public let packet: Packet
        public let message: String

        public init(packet: Packet, message: String) {
            self.packet = packet
            self.message = message
        }
    }

    public private(set) var proxy = GenericProxy(identifier: "server.loopback")
    public let dispatcher: GenericDispatcher
    public let handlers = RequestHandlersStore()

    public init() {
        self.dispatcher = GenericDispatcher.init(proxy: proxy as! Peer, queue: nil)
        proxy.handler = handle
    }

    private func handle(data: Data, senderIdentifier: Peer.Identifier) {
        guard let sender = dispatcher.peer(for: senderIdentifier) else {
            print("no peer connected for sender identifier: \(senderIdentifier)")
            return
        }

        do {
            let packet = try GenericDispatcher.DedicatedDriver.packet(from: data)
            handle(packet: packet, from: sender)
        } catch {
            print("failed to decode packet for data: \(data)")
        }
    }

    private func handle(packet: Packet, from sender: Peer) {
        guard let handler = handlers.handler(for: packet.payload) else {
            let response = ServerError(packet: packet, message: "Server has no handler for this packet") as! Payload
            reply(with: response, for: packet, to: sender)
            return
        }

        handler(packet.payload, { [weak self] response in
            guard let `self` = self else {
                print("server no longer available at the moment when response handler finished")
                return
            }
            self.reply(with: response, for: packet, to: sender)
        })
    }

    private func reply(with response: Payload, for requestPacket: Packet, to receiver: Peer) {
        let identifier = requestPacket.identifier
        let packet = Packet(identifier: identifier, payload: response)
        let signature = Signature(object: response)
        let task = Task(
			signature: signature,
			receiver: receiver,
			sender: proxy as! Peer,
			packet: packet,
			success: { _ in },
			failure: { _ in }
		)

        dispatcher.dispatch(task: task, to: receiver, from: proxy as! Peer)
    }
}
