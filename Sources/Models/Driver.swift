
public protocol Driver {

	associatedtype Peer: Interface
    associatedtype DedicatedCodec

    static var codec: DedicatedCodec { get }

    static func deliver(packet: Packet, to receiver: Peer, from sender: Peer) throws
    static func packet(from data: Data) throws -> Packet
}
