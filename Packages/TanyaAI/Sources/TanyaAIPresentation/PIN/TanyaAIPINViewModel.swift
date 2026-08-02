import Combine
import Foundation
import TanyaAIContracts
import TanyaAIDomain

public final class TanyaAIPINViewModel: ObservableObject {
    @Published public private(set) var pin = ""
    @Published public private(set) var isSubmitting = false
    @Published public private(set) var errorMessage: String?

    public let approval: TanyaAIApprovalPayload
    public var onOutput: ((TanyaAIPINOutput) -> Void)?

    private let authorizationService: TanyaAIAuthorizationService
    private var activeRequest: TanyaAICancellable?

    public init(
        approval: TanyaAIApprovalPayload,
        authorizationService: TanyaAIAuthorizationService
    ) {
        self.approval = approval
        self.authorizationService = authorizationService
    }

    public var canSubmit: Bool {
        pin.count == 6 && pin.allSatisfy { $0.isNumber } && !isSubmitting
    }

    public func appendDigit(_ digit: Int) {
        guard (0...9).contains(digit), pin.count < 6, !isSubmitting else {
            return
        }
        errorMessage = nil
        pin.append(String(digit))
        if pin.count == 6 {
            submit()
        }
    }

    public func deleteLastDigit() {
        guard !pin.isEmpty, !isSubmitting else {
            return
        }
        errorMessage = nil
        pin.removeLast()
    }

    public func submit() {
        guard canSubmit else {
            errorMessage = "Enter a 6-digit PIN."
            return
        }

        let submittedPIN = pin
        pin = ""
        errorMessage = nil
        isSubmitting = true
        onOutput?(.started)

        let request = TanyaAIAuthorizationRequest(
            approvalIdentifier: approval.approvalIdentifier,
            transactionIdentifier: approval.transactionIdentifier,
            challengeIdentifier: approval.challengeIdentifier,
            expiresAt: approval.expiresAt
        )
        activeRequest = authorizationService.authorize(
            request: request,
            pin: submittedPIN,
            completion: { [weak self] result in
                self?.performOnMain {
                    self?.handle(result)
                }
            }
        )
    }

    public func cancel() {
        guard !isSubmitting else {
            return
        }
        clearSensitiveState()
        onOutput?(.cancel)
    }

    public func clearSensitiveState() {
        pin = ""
        errorMessage = nil
    }

    deinit {
        activeRequest?.cancel()
        pin = ""
    }

    private func handle(
        _ result: Result<TanyaAIAuthorizationResult, Error>
    ) {
        activeRequest = nil
        isSubmitting = false
        switch result {
        case .success(let authorizationResult):
            onOutput?(.completed(authorizationResult))
        case .failure:
            errorMessage = "The PIN was not accepted. Please try again."
        }
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
