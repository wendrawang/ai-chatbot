import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Host adapter. SDK calls follow the supplied iOS guide; payload mapping is injected.
final class ThreeDolphinsChatSessionAdapter: TanyaAIChatSession {
    typealias MessageMapper = (Notification) throws -> [TanyaAIChatSessionEvent]

    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    private let profile: DolphinProfile
    private let mapMessage: MessageMapper
    private let silentGreeting: String?
    private var observers: [NSObjectProtocol] = []
    private var isActive = false
    private var isGreetingSent = false
    private var isConnectionReported = false

    init(
        profile: DolphinProfile,
        silentGreeting: String? = nil,
        mapMessage: @escaping MessageMapper
    ) {
        self.profile = profile
        self.silentGreeting = silentGreeting
        self.mapMessage = mapMessage
    }

    func connect() {
        onMain { [self] in
            guard isActive == false else { return }
            isActive = true
            observe(notificationConnectionStatus) { [weak self] notification in
                self?.receiveStatus(notification)
            }
            observe(notificationMessage) { [weak self] notification in
                self?.receiveMessage(notification)
            }
            Connector.shared.constructConnector(profile: profile)
        }
    }

    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) {
        onMain { [self] in
            guard isActive else { return }
            // The guide does not define dataUser or correlation semantics.
            Connector.shared.onSendMessage(messages: text)
        }
    }

    func disconnect() {
        onMain { [self] in
            guard isActive else { return }
            isActive = false
            observers.forEach(NotificationCenter.default.removeObserver)
            observers.removeAll()
            Connector.shared.endActiveSession()
            isConnectionReported = false
            isGreetingSent = false
        }
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    private func receiveStatus(_ notification: Notification) {
        guard isActive, let status = notification.object as? Int else { return }
        switch status {
        case 2:
            reportConnected()
        case 4, 5:
            isConnectionReported = false
            let failure: Error? = status == 5 ? ThreeDolphinsAdapterError.connectionFailed : nil
            onEvent?(.disconnected(failure))
        case 6:
            onEvent?(.failed(ThreeDolphinsAdapterError.attachmentFailed))
        default:
            break
        }
    }

    private func reportConnected() {
        guard isConnectionReported == false else { return }
        isConnectionReported = true
        onEvent?(.connected)
        guard isActive, isGreetingSent == false, let silentGreeting,
              silentGreeting.isEmpty == false else { return }
        isGreetingSent = true
        Connector.shared.onSendMessage(messages: silentGreeting)
    }

    private func receiveMessage(_ notification: Notification) {
        guard isActive else { return }
        do {
            for event in try mapMessage(notification) {
                onEvent?(event)
            }
        } catch {
            onEvent?(.failed(error))
        }
    }

    private func observe(_ name: String, handler: @escaping (Notification) -> Void) {
        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: name),
            object: nil,
            queue: .main,
            using: handler
        )
        observers.append(observer)
    }

    private func onMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}

enum ThreeDolphinsAdapterError: LocalizedError {
    case connectionFailed
    case attachmentFailed
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .connectionFailed: return "Koneksi chat gagal. Silakan coba kembali."
        case .attachmentFailed: return "Lampiran gagal dikirim."
        case .invalidPayload: return "Format pesan chat tidak sesuai."
        }
    }
}
