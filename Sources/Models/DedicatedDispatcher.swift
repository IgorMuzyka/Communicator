
public protocol DedicatedDispatcher {

	associatedtype DedicatedPeer
	associatedtype DedicatedDriver: Driver where DedicatedDriver.Peer == DedicatedPeer

	typealias DedicatedQueue = Queue<DedicatedPeer>

	var queue: DedicatedQueue? { get }

	init(proxy: DedicatedPeer, queue: DedicatedQueue?)

	func dispatch(task: Task<DedicatedPeer>, to receiver: DedicatedPeer, from sender: DedicatedPeer)
	func handle(packet: Packet, from senderIdentifier: DedicatedPeer.Identifier)

	func peer(for identifier: DedicatedPeer.Identifier) -> DedicatedPeer?
}
