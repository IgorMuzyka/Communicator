
open class Session<Peer: Interface, GenericConnection>
    where
    GenericConnection: Connection<Peer>
{
    public private(set) var connections = [GenericConnection]()
    public var peers: [Peer] { return connections.map { $0.receiver} }
	public let proxy: Peer

	public required init(proxy: Peer) {
		self.proxy = proxy
	}
    
	open func connect(to peer: Peer) {
		guard shouldConnect(to: peer) else { return }
		
		let connection = prepare(connection: GenericConnection(receiver: peer).prepare())
        connections.append(connection)
    }

	open func prepare(connection: GenericConnection) -> GenericConnection {
        return connection
    }

    open func disconnect(from peer: Peer) {
        guard let index = connections.firstIndex(where: { $0.receiver.identifier == peer.identifier }) else {
            return
        }

        connections.remove(at: index).destroy()
    }

    public func peer(for identifier: Peer.Identifier) -> Peer? {
        return peers.first(where: { $0.identifier == identifier })
    }

	open func shouldConnect(to peer: Peer) -> Bool {
		return !isConnected(to: peer)
	}

	public func isConnected(to peer: Peer) -> Bool {
		guard let _ = index(for: peer) else {
			return false
		}
		return true
	}

	private func index(for peer: Peer) -> Int? {
		return connections.firstIndex(where: { $0.receiver.identifier == peer.identifier })
	}
}
