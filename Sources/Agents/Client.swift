
import TypePreservingCodingAdapter

open class Client<Peer, GenericProxy: Proxy, GenericDispatcher>
    where
	GenericDispatcher: DedicatedDispatcher,
	GenericDispatcher.DedicatedPeer == Peer
{
	public typealias GenericQueue = Queue<Peer>

	public enum ClientError: Error {

		case receivedUnexpectedResponseType(expected: Signature, received: Signature)
	}

	public private(set) var proxy = GenericProxy(identifier: "client.loopback")
	public let dispatcher: GenericDispatcher
	public let executor: Executor

	public required init(executor: Executor) {
		self.executor = executor
		self.dispatcher = GenericDispatcher.init(proxy: proxy as! Peer, queue: GenericQueue())
        proxy.handler = handle
    }

	public func ticket<GenericRequest: Request>(for request: GenericRequest, to receiver: Peer) -> Ticket<GenericRequest.Response> {
		return Ticket<GenericRequest.Response>(
			task: { [weak self] ticket in
				self?.send(request: request, to: receiver, success: { response in
					ticket.resolve(with: response)
				}, failure: { error in
					ticket.resolve(with: error)
				})
			})
	}

	private func send<GenericRequest: Request>(
		request: GenericRequest,
		to receiver: Peer,
		success: @escaping (GenericRequest.Response) -> Void,
		failure: @escaping (Error) -> Void
	) {
        let identifier = UUID().uuidString
		let packet = Packet(identifier: identifier, payload: request)
		let signature = Signature(type: GenericRequest.Response.self)
		let task = Task(
			signature: signature,
			receiver: receiver,
			sender: proxy as! Peer,
			packet: packet,
			success: { anyResponse in
				guard let response = anyResponse as? GenericRequest.Response else {
					failure(ClientError.receivedUnexpectedResponseType(expected: signature, received: Signature(object: anyResponse)))
					return
				}
				success(response)
			},
			failure: failure
		)

		dispatcher.dispatch(task: task, to: receiver, from: proxy as! Peer)
    }

    private func handle(data: Data, from senderIdentifier: Peer.Identifier) {
		do {

            let packet = try GenericDispatcher.DedicatedDriver.packet(from: data)
			dispatcher.handle(packet: packet, from: senderIdentifier)
		} catch {
			print("failed to decode packet from data: \(data)")
		}
    }
}
