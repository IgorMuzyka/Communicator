
public class Executor {

	public let queue: DispatchQueue

	public init(queue: DispatchQueue = .main) {
		self.queue = queue
	}

	@discardableResult
	public func execute<Result>(ticket: Ticket<Result>) -> Ticket<Result> {
		ticket.execute(with: self)
		return ticket
	}

	public func finished<Result>(ticket: Ticket<Result>) {
		switch ticket.state {
		case .resolved(let result):
			DispatchQueue.main.async {
				ticket.success?(result)
				ticket.executeNext()
			}
		case .rejected(let error):
			DispatchQueue.main.async {
				ticket.failures.last?(error)
			}
		default: break
		}
	}
}
