
import TypePreservingCodingAdapter

public protocol Payload: Codable {

    var typePreservingStrategy: Wrap.Strategy { get }
}
