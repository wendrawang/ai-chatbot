import Foundation
import TanyaAIDomain

extension TanyaAIChatViewModel {
    func submit(_ message: TanyaAIMessageItemViewModel) {
        guard case .text(let text) = message.content else { return }
        let identifier = UUID().uuidString
        pendingSubmissions[identifier] = message.identifier
        message.setDelivery(.pending)
        let remoteIdentifier = repository.sendMessage(text: text, requestIdentifier: identifier)
        if let remoteIdentifier { message.setRemoteIdentifier(remoteIdentifier) }
    }

    func finishSubmission(_ identifier: String, remoteIdentifier: String?, isSuccessful: Bool) {
        guard let rowIdentifier = pendingSubmissions.removeValue(forKey: identifier),
            let message = message(identifier: rowIdentifier)
        else { return }
        if let remoteIdentifier { message.setRemoteIdentifier(remoteIdentifier) }
        message.setDelivery(isSuccessful ? .sent : .failed)
        if !isSuccessful { errorMessage = copy.chat("chat.sendFailed") }
    }

    func failPendingSubmissions() {
        let rows = Array(pendingSubmissions.values)
        pendingSubmissions.removeAll()
        rows.forEach { message(identifier: $0)?.setDelivery(.failed) }
    }
}
