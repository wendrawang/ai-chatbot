import Foundation
import ImSDK_Plus_Swift

/// Own this at app scope, not inside the chat screen.
final class TencentChatLifecycle {
    static let shared = TencentChatLifecycle()

    private let manager = V2TIMManager.shared
    private(set) var isInitialized = false

    private init() {}

    func initialize(sdkAppID: Int32) -> Bool {
        guard !isInitialized else { return true }
        isInitialized = manager.initSDK(sdkAppID: sdkAppID, config: V2TIMSDKConfig())
        return isInitialized
    }

    func login(
        userID: String,
        userSig: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard isInitialized else {
            completion(.failure(TencentChatError.notInitialized))
            return
        }
        if let currentUserID = manager.getLoginUser(),
           manager.getLoginStatus() == .V2TIM_STATUS_LOGINED {
            guard currentUserID == userID else {
                completion(.failure(TencentChatError.accountSwitchRequiresLogout))
                return
            }
            completion(.success(()))
            return
        }
        guard manager.getLoginStatus() != .V2TIM_STATUS_LOGINING else {
            completion(.failure(TencentChatError.loginAlreadyInProgress))
            return
        }
        manager.login(userID: userID, userSig: userSig, succ: {
            completion(.success(()))
        }, fail: { code, message in
            completion(.failure(TencentChatError.sdk(code: Int(code), message: message)))
        })
    }

    func logout(completion: @escaping () -> Void) {
        guard manager.getLoginUser() != nil else {
            completion()
            return
        }
        manager.logout(succ: completion, fail: { _, _ in completion() })
    }
}

enum TencentChatError: Error {
    case notInitialized
    case notLoggedIn
    case accountSwitchRequiresLogout
    case loginAlreadyInProgress
    case messageCreationFailed
    case sdk(code: Int, message: String?)
}
