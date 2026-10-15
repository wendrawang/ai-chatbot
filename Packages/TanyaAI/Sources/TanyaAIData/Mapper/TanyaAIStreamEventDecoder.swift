import Foundation
import TanyaAIContracts
import TanyaAIDomain

final class TanyaAIStreamEventDecoder {
    let decoder: JSONDecoder

    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func decode(name: String, json: Data) throws -> TanyaAIStreamEvent? {
        switch TanyaAIEventName(wireName: name) {
        case .response: return try decodeResponse(json)
        case .responseStarted:
            let payload = try decoder.decode(TanyaAIMessageIdentifierDTO.self, from: json)
            return .responseStarted(messageIdentifier: payload.messageIdentifier)
        case .textDelta:
            let payload = try decoder.decode(TanyaAITextDeltaDTO.self, from: json)
            return .textDelta(messageIdentifier: payload.messageIdentifier, text: payload.text)
        case .responseCompleted:
            let payload = try decoder.decode(TanyaAIMessageIdentifierDTO.self, from: json)
            return .responseCompleted(messageIdentifier: payload.messageIdentifier)
        case .heartbeat: return .heartbeat
        case nil: return try decodeUnknown(name: name, json: json)
        }
    }

    private func decodeUnknown(name: String, json: Data) throws -> TanyaAIStreamEvent? {
        guard TanyaAIEventName.isContentName(name) else { return nil }
        let payload = try decoder.decode(TanyaAIUnsupportedContentDTO.self, from: json)
        return .content(messageIdentifier: payload.messageIdentifier, content: .unsupported(payload.fallbackText))
    }
}
