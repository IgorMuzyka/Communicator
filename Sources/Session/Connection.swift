
open class Connection<Peer: Interface> {

	public var receiver: Peer

	public required init(receiver: Peer) {
		self.receiver = receiver
	}

	@discardableResult
	open func prepare() -> Self {
		return self
	}

	@discardableResult
	open func destroy() -> Self {
		return self
	}
}
