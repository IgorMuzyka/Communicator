
import TypePreservingCodingAdapter

public struct Packet: Codable {

    public typealias Identifier = String

    private enum CodingKeys: CodingKey {

        case identifier
        case payload
    }

    public let identifier: String
    public let payload: Payload

    public init(identifier: Identifier, payload: Payload) {
        self.identifier = identifier
        self.payload = payload
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wrap = try container.decode(Wrap.self, forKey: .payload)

        self.payload = wrap.wrapped as! Payload
        self.identifier = try container.decode(Identifier.self, forKey: .identifier)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let wrap = Wrap(wrapped: payload, strategy: payload.typePreservingStrategy)

        try container.encode(wrap, forKey: .payload)
        try container.encode(identifier, forKey: .identifier)
    }

	public var signature: Signature {
		return Signature(object: payload)
	}
}
