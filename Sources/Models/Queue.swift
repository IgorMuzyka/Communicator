
public class Queue<Peer> {

	public typealias TimeoutHandler = (Task<Peer>) -> Void

	var timeoutHandler: TimeoutHandler?

	private var queue = [Task<Peer>]()

	public func issue(task: Task<Peer>) {
		task.queue = self
		queue.append(task)
		scheduleTimeoutTimer(for: task)
	}

	@discardableResult
	public func revoke(task: Task<Peer>) -> Task<Peer>? {
		guard let index = index(for: task) else { return nil }
		return queue.remove(at: index)
	}

	public func task(for packet: Packet) -> Task<Peer>? {
		return queue.first { $0.identifier == packet.identifier }
	}

	private func index(for task: Task<Peer>) -> Int? {
		return queue.firstIndex(where: { $0.identifier == task.identifier })
	}

	private func scheduleTimeoutTimer(for task: Task<Peer>) {
		#warning("hardcoded timeout! should delegate to some configuration for the dispatcher")
		Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [weak self] in
			self?.checkIfTaskIsResolved(task: task, timer: $0)
		}
	}

	private func checkIfTaskIsResolved(task: Task<Peer>, timer: Timer) {
		guard let handler = timeoutHandler else { return }
		guard let issuedTask = revoke(task: task) else { return }

		handler(issuedTask)
	}
}
