//
//  SandboxChatService.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 19/10/26.
//

import Foundation
import TanyaAI

/// Peran host untuk sandbox: meniru SSE chat service dan inquiry BE dari fixture JSON lokal.
/// Di host asli, kelas ini membuka koneksi SSE dan memanggil backend.
final class SandboxChatService: TanyaAIService {
    private let script: SandboxScript?
    private let inquiryResponse: Data
    private let isOffline: Bool
    private let onFailure: @Sendable (Error) -> Void

    /// `isOffline` meniru jaringan putus: setiap request gagal dan `onFailure` dipanggil.
    init(isOffline: Bool = false, onFailure: @escaping @Sendable (Error) -> Void = { _ in }) {
        self.isOffline = isOffline
        self.onFailure = onFailure
        script = R.file.chatScriptsJson.url()
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode(SandboxScript.self, from: $0) }
        inquiryResponse = R.file.reviewPortfolioJson.url().flatMap { try? Data(contentsOf: $0) } ?? Data()
    }

    func streamChat(_ request: TanyaAIChatRequest) -> AsyncThrowingStream<TanyaAIServerEvent, Error> {
        guard !isOffline else {
            let error = URLError(.notConnectedToInternet)
            onFailure(error)
            return AsyncThrowingStream { $0.finish(throwing: error) }
        }
        let steps = steps(for: request.text)
        return AsyncThrowingStream { continuation in
            let task = Task {
                for step in steps {
                    try? await Task.sleep(nanoseconds: Self.nanoseconds(step.delay))
                    guard !Task.isCancelled, let data = try? JSONEncoder().encode(step.data) else { break }
                    continuation.yield(TanyaAIServerEvent(name: step.event, data: data))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func inquire(_ intent: TanyaAIIntent) async throws -> Data {
        guard !isOffline else {
            let error = URLError(.notConnectedToInternet)
            onFailure(error)
            throw error
        }
        try await Task.sleep(nanoseconds: Self.nanoseconds(script?.inquiryDelay ?? .zero))
        return inquiryResponse
    }
}

// MARK: - Helpers

private extension SandboxChatService {
    /// Skrip pertama yang kata kuncinya ada di pertanyaan; selain itu skrip teks bebas.
    func steps(for text: String) -> [SandboxScript.Step] {
        guard let script else { return [] }
        let question = text.lowercased()
        let name = script.routes.first { $0.keywords.contains(where: question.contains) }?.script ?? script.fallback
        return script.scripts[name] ?? []
    }

    static func nanoseconds(_ seconds: Double) -> UInt64 {
        UInt64(seconds * Double(NSEC_PER_SEC))
    }
}

/// Fixture `ChatScripts.json`: rute kata kunci ke skrip event SSE dan jeda inquiry.
struct SandboxScript: Decodable {
    struct Route: Decodable {
        let keywords: [String]
        let script: String
    }

    struct Step: Decodable {
        let delay: Double
        let event: String
        let data: JSONValue
    }

    let routes: [Route]
    let fallback: String
    let scripts: [String: [Step]]
    let inquiryDelay: Double
}
