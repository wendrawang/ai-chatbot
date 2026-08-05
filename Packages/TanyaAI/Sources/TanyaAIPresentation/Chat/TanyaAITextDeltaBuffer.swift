import Foundation

final class TanyaAITextDeltaBuffer {
    typealias FlushHandler = (String, String) -> Void

    private let flushInterval: TimeInterval
    private let flushHandler: FlushHandler
    private var pendingText: [String: String] = [:]
    private var pendingWork: [String: DispatchWorkItem] = [:]

    init(
        flushInterval: TimeInterval = 0.04,
        flushHandler: @escaping FlushHandler
    ) {
        self.flushInterval = flushInterval
        self.flushHandler = flushHandler
    }

    func append(messageIdentifier: String, text: String) {
        pendingText[messageIdentifier, default: ""].append(text)
        guard pendingWork[messageIdentifier] == nil else {
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.flush(messageIdentifier: messageIdentifier)
        }
        pendingWork[messageIdentifier] = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + flushInterval,
            execute: workItem
        )
    }

    func flushAll() {
        let identifiers = Array(pendingText.keys)
        identifiers.forEach(flush)
    }

    func cancel() {
        pendingWork.values.forEach { $0.cancel() }
        pendingWork.removeAll()
        pendingText.removeAll()
    }

    private func flush(messageIdentifier: String) {
        pendingWork[messageIdentifier]?.cancel()
        pendingWork[messageIdentifier] = nil
        guard let text = pendingText.removeValue(
            forKey: messageIdentifier
        ), !text.isEmpty else {
            return
        }
        flushHandler(messageIdentifier, text)
    }
}
