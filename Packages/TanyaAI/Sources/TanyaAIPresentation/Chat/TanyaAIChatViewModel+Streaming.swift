import Foundation
import TanyaAIDomain

extension TanyaAIChatViewModel {
    func startRequest(_ text: String) {
        let identifier = UUID().uuidString
        activeRequestIdentifier = identifier
        let request = useCase.sendMessage(
            conversationIdentifier: conversationIdentifier,
            text: text,
            onEvent: { [weak self] event in
                self?.performOnMain { [weak self] in
                    guard self?.activeRequestIdentifier == identifier else { return }
                    self?.handle(event)
                }
            },
            completion: { [weak self] result in
                self?.performOnMain { [weak self] in
                    guard self?.activeRequestIdentifier == identifier else { return }
                    self?.handleCompletion(result)
                }
            }
        )
        guard activeRequestIdentifier == identifier else {
            request.cancel()
            return
        }
        activeRequest = request
    }

}
