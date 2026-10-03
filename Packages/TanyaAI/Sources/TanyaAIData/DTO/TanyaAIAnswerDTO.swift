import Foundation

struct TanyaAIAnswerDTO: Decodable {
    let messageIdentifier: String
    let text: String?
    let options: [TanyaAIChoiceDTO]?
    let image: TanyaAIAnswerImageDTO?
    let actions: [TanyaAIActionButtonDTO]?
    let isAnswered: Bool?
}

struct TanyaAIAnswerImageDTO: Decodable {
    let imageURL: String
    let caption: String?
    let aspectRatio: Double?
    let accessibilityText: String?
}
