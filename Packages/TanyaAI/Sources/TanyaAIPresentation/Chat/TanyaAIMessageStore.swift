import TanyaAIDomain

struct TanyaAIMessageStore {
    private var messagesByIdentifier: [String: TanyaAIMessageItemViewModel]
    private var approvalsByIdentifier: [String: TanyaAIMessageItemViewModel] = [:]

    init(welcomeMessage: TanyaAIMessageItemViewModel) {
        messagesByIdentifier = [welcomeMessage.id: welcomeMessage]
    }

    mutating func append(_ message: TanyaAIMessageItemViewModel) {
        messagesByIdentifier[message.id] = message
    }

    mutating func indexApproval(
        _ content: TanyaAIMessageContent,
        message: TanyaAIMessageItemViewModel
    ) {
        guard case .approval(let approval) = content else {
            return
        }
        approvalsByIdentifier[approval.approvalIdentifier] = message
    }

    func message(identifier: String) -> TanyaAIMessageItemViewModel? {
        messagesByIdentifier[identifier]
    }

    func approval(identifier: String) -> TanyaAIMessageItemViewModel? {
        approvalsByIdentifier[identifier]
    }
}
