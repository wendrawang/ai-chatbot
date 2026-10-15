import Foundation
import TanyaAIDomain

extension TanyaAIStreamEventDecoder {
    func decodeResponse(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(ResponseDTO.self, from: data)
        guard !payload.messageIdentifier.isEmpty else { throw CocoaError(.coderReadCorrupt) }
        return .content(messageIdentifier: payload.messageIdentifier, content: .response(payload.response))
    }
}

private struct ResponseDTO: Decodable {
    let messageIdentifier: String
    let response: ResponsePayload
}
