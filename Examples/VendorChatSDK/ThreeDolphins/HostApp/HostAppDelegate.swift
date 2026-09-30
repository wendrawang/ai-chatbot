import UIKit

final class HostAppDelegate: NSObject, UIApplicationDelegate {
    private(set) var isChatConfigured = false

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard let configuration = configuration() else { return true }
        configuration.configure()
        isChatConfigured = true
        return true
    }

    private func configuration() -> ThreeDolphinsConfiguration? {
        let bundle = Bundle.main
        guard let baseURL = bundle.object(forInfoDictionaryKey: "LivechatBaseURL") as? String,
              let clientIdentifier = bundle.object(forInfoDictionaryKey: "LivechatClientIdentifier") as? String,
              let clientSecret = bundle.object(forInfoDictionaryKey: "LivechatClientSecret") as? String,
              let botIdentifier = bundle.object(forInfoDictionaryKey: "LivechatBotIdentifier") as? String,
              [baseURL, clientIdentifier, clientSecret, botIdentifier].allSatisfy({ !$0.isEmpty }) else {
            return nil
        }
        return ThreeDolphinsConfiguration(
            baseURL: baseURL,
            clientIdentifier: clientIdentifier,
            clientSecret: clientSecret,
            botIdentifier: botIdentifier
        )
    }
}
