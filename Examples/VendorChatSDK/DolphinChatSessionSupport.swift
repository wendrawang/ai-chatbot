import Foundation
// import imi_dolphin_livechat_ios

extension DolphinChatSessionAdapter {
    /// Everything `setupConnection` and `onSendMessage` need.
    struct Configuration {
        let baseUrl: String
        let clientId: String
        /// Spelled as the SDK spells it.
        let clientSecrect: String
        let enableGetQueue: Bool
        /// Passed straight through as the SDK's `dataUser` argument.
        let dataUser: Any

        init(
            baseUrl: String,
            clientId: String,
            clientSecrect: String,
            enableGetQueue: Bool = false,
            dataUser: Any
        ) {
            self.baseUrl = baseUrl
            self.clientId = clientId
            self.clientSecrect = clientSecrect
            self.enableGetQueue = enableGetQueue
            self.dataUser = dataUser
        }
    }
}

/// How to read a `DolphinMessage`.
///
/// The SDK documentation names the type but not its fields, so this is the one
/// place to adjust after opening the framework header in Xcode. Three
/// one-liners, for example:
///
///     DolphinMessageMapper(
///         identifier: { $0.messageId ?? UUID().uuidString },
///         text: { $0.message },
///         payload: { $0.payload as? [String: Any] }
///     )
///
/// `payload` may return nil when the deployment cannot attach rich content:
/// the adapter then falls back to reading the JSON envelope out of the text.
struct DolphinMessageMapper {
    let identifier: (DolphinMessage) -> String
    let text: (DolphinMessage) -> String?
    let payload: (DolphinMessage) -> [String: Any]?

    init(
        identifier: @escaping (DolphinMessage) -> String,
        text: @escaping (DolphinMessage) -> String?,
        payload: @escaping (DolphinMessage) -> [String: Any]? = { _ in nil }
    ) {
        self.identifier = identifier
        self.text = text
        self.payload = payload
    }
}
