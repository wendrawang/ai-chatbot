import Foundation
import TanyaAIDomain

/// Row callbacks supplied by the screen; components own no session policy.
struct TanyaAIMessageRowHandlers {
    var onRetryMessage: (String) -> Void = { _ in }
    var onResponseOption: (String, String, String) -> Void = { _, _, _ in }
    var onResponseAction: (String, ResponseAction) -> Void = { _, _ in }
    var onResponseDocument: (String, String, String) -> Void = { _, _, _ in }
    var onResponseAuthorize: (String, String, String) -> Void = { _, _, _ in }
    var onInlineLink: (URL) -> Void = { _ in }
    var isHostFlowEnabled = false
    var isSendEnabled = false

    static let inert = TanyaAIMessageRowHandlers()
}
