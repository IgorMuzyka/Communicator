
public class Ticket<Result> {

	public enum State {

		case created(Task)
		case resolved(Result)
		case rejected(Error)
	}

	public typealias Task = (Ticket<Result>) -> Void
	public typealias Success = (Result) -> Void
	public typealias Failure = (Error) -> Void

	internal private(set) var success: Success?
	internal private(set) var failure: Failure?
	internal private(set) var next: Ticket<Any>?

	public private(set) weak var executor: Executor?

	public private(set) var state: State {
		didSet {
			executor?.finished(ticket: self)
		}
	}

	public init(task: @escaping Task) {
		self.state = .created(task)
	}

	@discardableResult
	public func onSuccess(_ execute: @escaping Success) -> Ticket<Result> {
		success = execute
		return self
	}

	@discardableResult
	public func onFailure(_ execute: @escaping Failure) -> Ticket<Result> {
		failure = execute
		return self
	}

	public func resolve(with result: Result) {
		state = .resolved(result)
	}

	public func resolve(with error: Error) {
		state = .rejected(error)
	}

	public func execute(with executor: Executor) {
		guard case let .created(task) = state else { return }

		self.executor = executor

		executor.queue.async {
			task(self)
		}
	}

	internal func executeNext() {
		guard let next = next, let executor = executor else { return }

		next.execute(with: executor)
	}

	internal var failures: [Failure] {
		return [failure].compactMap { $0 } +  (next?.failures ?? [])
	}

	@discardableResult
	public func then<NextResult>(ticket: Ticket<NextResult>) -> Ticket<NextResult> {
		self.next = ticket as? Ticket<Any>
		return ticket
	}
}
