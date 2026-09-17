import SwiftUI

/// Standalone example entry point. Do not add a second @main to an existing app.
@main
struct HostExampleApp: App {
    @UIApplicationDelegateAdaptor(HostAppDelegate.self) private var appDelegate
    @StateObject private var session = HostUserSession()

    var body: some Scene {
        WindowGroup {
            HostRootView(session: session, isChatConfigured: appDelegate.isChatConfigured)
                .onOpenURL { address in
                    session.open(address)
                }
        }
    }
}
