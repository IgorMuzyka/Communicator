
public protocol Proxy: Interface {

    typealias Handler = (Data, Identifier) -> Void

    var handler: Handler! { get set }

    init(identifier: Identifier)
}
