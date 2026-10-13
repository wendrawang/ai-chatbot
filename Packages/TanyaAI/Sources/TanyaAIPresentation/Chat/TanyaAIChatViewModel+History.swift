import TanyaAIDomain

extension TanyaAIChatViewModel {
    func restore(_ restored: [TanyaAIMessage]) {
        textDeltaBuffer.flushAll()
        isRestoring = false
        isHistoryUnavailable = false
        let existing = Dictionary(
            messages.compactMap { message in
                message.remoteIdentifier.map { ($0, message) }
            }, uniquingKeysWith: { first, _ in first })
        var identifiers = Set<String>()
        let snapshot = restored.suffix(TanyaAIMessage.historyLimit).compactMap { item in
            let remoteIdentifier = item.remoteIdentifier ?? item.identifier
            guard identifiers.insert(remoteIdentifier).inserted else { return nil as TanyaAIMessageItemViewModel? }
            guard let current = existing[remoteIdentifier] else { return TanyaAIMessageItemViewModel(message: item) }
            if !isSettledApproval(current.content) { current.update(content: item.content) }
            if current.role == .user { current.setDelivery(.sent) }
            return current
        }
        let outbox = messages.filter {
            ($0.delivery == .pending || $0.delivery == .failed)
                && !identifiers.contains($0.remoteIdentifier ?? $0.identifier)
        }
        messages = snapshot + outbox
        let delivered = Set(snapshot.map(\.identifier))
        pendingSubmissions = pendingSubmissions.filter { !delivered.contains($0.value) }
        messages.dropLast().forEach { $0.consumeOptions() }
        trimMessages()
    }
}
