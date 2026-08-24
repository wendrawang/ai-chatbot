import Foundation
import TanyaAI

/// Builds an authenticated `URLRequest` for one Tanya AI stream.
///
/// Implement this with the existing networking stack: base URL resolution,
/// headers, tracing identifiers, and token refresh all stay in the host. The
/// completion shape allows an asynchronous token refresh before the request
/// is sent.
protocol HostTanyaAIRequestFactory: AnyObject {
    func makeRequest(
        path: String,
        body: Data,
        requestIdentifier: String,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    )
}

/// Forwards server-trust challenges to the existing pinning validator.
protocol HostTanyaAISecurityDelegate: AnyObject {
    func handle(
        _ challenge: URLAuthenticationChallenge,
        completion: @escaping (
            URLSession.AuthChallengeDisposition,
            URLCredential?
        ) -> Void
    )
}

/// Server-sent events transport backed by `URLSession`.
///
/// A completion-handler data task buffers the whole response, so streaming
/// needs the delegate API. If the host networking layer already exposes a
/// streaming request, wrap that instead of this class.
final class HostTanyaAIStreamingTransport:
    NSObject,
    TanyaAIStreamingTransport,
    URLSessionDataDelegate {

    private let requestFactory: HostTanyaAIRequestFactory
    private weak var securityDelegate: HostTanyaAISecurityDelegate?
    private let lock = NSLock()
    private var handlers: [Int: Handlers] = [:]
    private lazy var session = URLSession(
        configuration: sessionConfiguration,
        delegate: self,
        delegateQueue: nil
    )
    private let sessionConfiguration: URLSessionConfiguration

    init(
        requestFactory: HostTanyaAIRequestFactory,
        sessionConfiguration: URLSessionConfiguration,
        securityDelegate: HostTanyaAISecurityDelegate?
    ) {
        self.requestFactory = requestFactory
        self.sessionConfiguration = sessionConfiguration
        self.securityDelegate = securityDelegate
    }

    deinit {
        // URLSession retains its delegate until it is invalidated.
        session.invalidateAndCancel()
    }

    @discardableResult
    func stream(
        _ request: TanyaAIStreamRequest,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        let cancellable = HostTanyaAIStreamCancellable()

        requestFactory.makeRequest(
            path: request.path,
            body: request.body,
            requestIdentifier: request.requestIdentifier
        ) { [weak self] result in
            guard let self, cancellable.isCancelled == false else {
                return
            }
            switch result {
            case .success(let urlRequest):
                self.start(
                    urlRequest,
                    cancellable: cancellable,
                    onData: onData,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return cancellable
    }

    private func start(
        _ request: URLRequest,
        cancellable: HostTanyaAIStreamCancellable,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let task = session.dataTask(with: request)
        store(
            Handlers(onData: onData, completion: completion),
            for: task.taskIdentifier
        )
        cancellable.adopt(task)
        task.resume()
    }

    // MARK: - URLSessionDataDelegate

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            finish(
                taskIdentifier: dataTask.taskIdentifier,
                result: .failure(HostTanyaAIStreamError.status(statusCode))
            )
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        // The feature's ViewModels hop to the main queue themselves, so the
        // delegate queue is a valid delivery queue.
        handlers(for: dataTask.taskIdentifier)?.onData(data)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error, (error as? URLError)?.code == .cancelled {
            removeHandlers(for: task.taskIdentifier)
            return
        }
        finish(
            taskIdentifier: task.taskIdentifier,
            result: error.map { .failure($0) } ?? .success(())
        )
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (
            URLSession.AuthChallengeDisposition,
            URLCredential?
        ) -> Void
    ) {
        guard let securityDelegate else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        securityDelegate.handle(challenge, completion: completionHandler)
    }

    // MARK: - Handler storage

    private struct Handlers {
        let onData: (Data) -> Void
        let completion: (Result<Void, Error>) -> Void
    }

    private func store(_ value: Handlers, for taskIdentifier: Int) {
        lock.lock()
        handlers[taskIdentifier] = value
        lock.unlock()
    }

    private func handlers(for taskIdentifier: Int) -> Handlers? {
        lock.lock()
        defer { lock.unlock() }
        return handlers[taskIdentifier]
    }

    @discardableResult
    private func removeHandlers(for taskIdentifier: Int) -> Handlers? {
        lock.lock()
        defer { lock.unlock() }
        return handlers.removeValue(forKey: taskIdentifier)
    }

    private func finish(
        taskIdentifier: Int,
        result: Result<Void, Error>
    ) {
        removeHandlers(for: taskIdentifier)?.completion(result)
    }
}

enum HostTanyaAIStreamError: Error {
    case status(Int)
}

/// Cancels the request whether or not the task already started.
final class HostTanyaAIStreamCancellable: TanyaAICancellable {
    private let lock = NSLock()
    private var task: URLSessionTask?
    private var cancelled = false

    var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cancelled
    }

    func adopt(_ task: URLSessionTask) {
        lock.lock()
        if cancelled {
            lock.unlock()
            task.cancel()
            return
        }
        self.task = task
        lock.unlock()
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let pendingTask = task
        task = nil
        lock.unlock()
        pendingTask?.cancel()
    }
}
