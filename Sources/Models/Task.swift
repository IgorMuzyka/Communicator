
import TypePreservingCodingAdapter

public class Task<Peer> {

	public enum State {

		case created
		case resolved
		case failed
	}

	public typealias Success = (Any) -> Void
	public typealias Failure = (Error) -> Void

	public let packet: Packet
	public let success: Success
	public let failure: Failure
	public let signature: Signature
	public var identifier: Packet.Identifier { return packet.identifier }
	public weak var queue: Queue<Peer>?
	public var receiver: Peer
	public var sender: Peer
	public private(set) var state: State = .created {
		didSet {
			queue?.revoke(task: self)
		}
	}

	public init(signature: Signature, receiver: Peer, sender: Peer, packet: Packet, success: @escaping Success, failure: @escaping Failure) {
		self.packet = packet
		self.success = success
		self.failure = failure
		self.signature = signature
		self.receiver = receiver
		self.sender = sender
	}

	public func resolve(with response: Any) {
		success(response)
		state = .resolved
	}

	public func resolve(with error: Error) {
		failure(error)
		state = .failed
	}
}
