
open class Dispatcher<Peer, GenericDriver, GenericSession, GenericConnection> : DedicatedDispatcher
	where
    GenericDriver: Driver,
	GenericConnection: Connection<Peer>,
	GenericSession: Session<Peer, GenericConnection>,
    GenericDriver.Peer == Peer
{
	public typealias DedicatedPeer = Peer
	public typealias DedicatedDriver = GenericDriver

	public enum DispatcherError: Error {
		case packetPayloadSignatureMismatchesTaskSignature(packet: Packet, task: Task<Peer>)
	}

	public let queue: DedicatedQueue?
	public let session: GenericSession

	public required init(proxy: DedicatedPeer, queue: DedicatedQueue?) {
		self.session = GenericSession.init(proxy: proxy)
		self.queue = queue
		self.queue?.timeoutHandler = timedOut
	}

	public func dispatch(task: Task<DedicatedPeer>, to receiver: DedicatedPeer, from sender: DedicatedPeer) {
		queue?.issue(task: task)

		do {
			session.connect(to: receiver)

            try GenericDriver.deliver(packet: task.packet, to: receiver, from: sender)
		} catch {
			task.resolve(with: error)
		}
	}

	public func handle(packet: Packet, from senderIdentifier: DedicatedPeer.Identifier) {
		guard let task = queue?.task(for: packet) else {
			print("got response for request which was never sent()")
			return
		}
		resolve(task: task, with: packet, from: senderIdentifier)
	}

	public func peer(for identifier: DedicatedPeer.Identifier) -> Peer? {
		return session.peer(for: identifier)
	}

	private func timedOut(task: Task<Peer>) {
		#warning("implement task reissuing")
	}

	private func resolve(task: Task<Peer>, with packet: Packet, from senderIdentifier: Peer.Identifier) {
		if task.signature == packet.signature {
			task.resolve(with: packet.payload)
		} else if let error = packet.payload as? Error {
			task.resolve(with: error)
		} else {
			task.resolve(with: DispatcherError.packetPayloadSignatureMismatchesTaskSignature(packet: packet, task: task))
		}
	}
}
