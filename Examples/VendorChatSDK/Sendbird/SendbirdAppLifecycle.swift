import Foundation
import SendbirdChatSDK
import UIKit

/// The three Sendbird calls that belong to the application, not to the chat.
///
/// Putting any of them inside the chat screen is the most common way this
/// integration goes wrong: `connect` is a network round trip that also carries
/// push and presence for the whole app, and `disconnect` closes all of it.
enum SendbirdAppLifecycle {
    /// Local configuration only, no network. Call from
    /// `application(_:didFinishLaunchingWithOptions:)`.
    static func initializeSDK(applicationId: String, appVersion: String) {
        SendbirdChat.initialize(
            params: InitParams(
                applicationId: applicationId,
                isLocalCachingEnabled: true,
                logLevel: .error,
                appVersion: appVersion
            )
        )
    }

    /// Call once the customer has a session - the same place the rest of the
    /// app learns who is signed in. Not when the chat opens.
    static func connect(
        userId: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        SendbirdChat.connect(userId: userId) { user, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let user else {
                completion(.failure(SendbirdAdapterError.notSignedIn))
                return
            }
            registerPendingPushToken()
            completion(.success(user))
        }
    }

    /// The only place `SendbirdChat.disconnect` may be called.
    ///
    /// Also tell the composition to forget its channel, so the next customer
    /// to sign in on this device does not continue someone else's
    /// conversation.
    static func disconnect(
        composition: SendbirdTanyaAIComposition,
        completion: @escaping () -> Void
    ) {
        composition.startNewConversation()
        SendbirdChat.disconnect(completionHandler: completion)
    }

    private static func registerPendingPushToken() {
        guard let token = SendbirdChat.getPendingPushToken() else {
            return
        }
        SendbirdChat.registerDevicePushTokenForMultiDevicePush(token) { _, _ in
            // Report through the app's own logging; a failure here must not
            // block sign-in.
        }
    }
}
