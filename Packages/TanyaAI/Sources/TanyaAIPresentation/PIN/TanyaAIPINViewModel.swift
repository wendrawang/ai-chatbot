import Combine
import DesignKit
import Foundation
import TanyaAIContracts
import TanyaAIDomain

public final class TanyaAIPINViewModel: ObservableObject {
    @Published public private(set) var pin = ""
    @Published public private(set) var isSubmitting = false
    @Published public private(set) var errorMessage: String?

    public static let requiredDigitCount = 6

    public let approval: ApprovalPayload
    public var onOutput: ((TanyaAIPINOutput) -> Void)?

    private let authorizationService: TanyaAIAuthorizationService
    private var activeRequest: TanyaAICancellable?

    private let copy: CopyCatalog

    public init(
        approval: ApprovalPayload,
        authorizationService: TanyaAIAuthorizationService,
        copy: CopyCatalog = CopyCatalog()
    ) {
        self.copy = copy
        self.approval = approval
        self.authorizationService = authorizationService
    }

    public var isSubmittable: Bool {
        pin.count == Self.requiredDigitCount && pin.allSatisfy { $0.isNumber } && !isSubmitting
    }

    public func appendDigit(_ digit: Int) {
        guard (0...9).contains(digit), pin.count < Self.requiredDigitCount, !isSubmitting else {
            return
        }
        errorMessage = nil
        pin.append(String(digit))
        if pin.count == Self.requiredDigitCount {
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
        guard isSubmittable else {
            errorMessage = copy.chat("chat.invalidPIN", values: ["count": String(Self.requiredDigitCount)])
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
        let task = authorizationService.authorize(
            request: request,
            pin: submittedPIN,
            completion: { [weak self] result in
                self?.performOnMain { [weak self] in
                    self?.handle(result)
                }
            }
        )
        if isSubmitting {
            activeRequest = task
        } else {
            task.cancel()
        }
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
            errorMessage = copy.chat("chat.rejectedPIN")
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
