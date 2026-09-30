import imi_dolphin_livechat_ios

/// Build from the host environment before presenting chat. Do not log credentials.
struct ThreeDolphinsConfiguration {
    let baseURL: String
    let clientIdentifier: String
    let clientSecret: String
    let botIdentifier: String

    /// Call once for the active environment, on the main thread, before makeHost.
    /// Argument labels match the supplied iOS guide; verify against the installed SDK.
    func configure() {
        Connector.shared.setupConnection(
            baseUrl: baseURL,
            clientId: clientIdentifier,
            clientSecret: clientSecret,
            botId: botIdentifier
        )
    }
}
