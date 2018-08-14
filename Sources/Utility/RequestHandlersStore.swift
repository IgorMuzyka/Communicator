
import TypePreservingCodingAdapter

open class RequestHandlersStore {

    public typealias RequestHandler = (Payload, (Payload) -> Void) -> Void

    private var store = [Signature: RequestHandler]()

    public init() {}

    public func register<GenericRequest: Request>(
        handler: @escaping (
            _ request: GenericRequest,
            _ response: (GenericRequest.Response) -> Void
        ) -> Void
    ) {
        store[Signature(type: GenericRequest.self)] = { request, response in
            guard let request = request as? GenericRequest else { fatalError("impossible mismatch") }
            handler(request, response)
        }
    }

    public func handler(for payload: Payload) -> RequestHandler? {
        return store[Signature(object: payload)]
    }
}
