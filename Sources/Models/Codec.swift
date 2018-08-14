
import TypePreservingCodingAdapter

public protocol Codec {

    var adapter: TypePreservingCodingAdapter { get }

    init()

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func encode<T: Encodable>(_ value: T) throws -> Data
}
