struct TanyaAIMessageIdentifierDTO: Decodable {
    let messageIdentifier: String
}

struct TanyaAITextDeltaDTO: Decodable {
    let messageIdentifier: String
    let text: String
}

struct TanyaAIUnsupportedContentDTO: Decodable {
    let messageIdentifier: String
    let fallbackText: String?
}
