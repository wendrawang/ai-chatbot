import Foundation
import TanyaAIDomain

struct TanyaAIComponentsDTO: Decodable {
    let messageIdentifier: String
    let elements: [TanyaAIComponentDTO]
}

struct TanyaAIComponentDTO: Decodable {
    let type: String
    let text: String?
    let options: [TanyaAIRadioOptionDTO]?
    let title: String?
    let description: String?
    let image: String?
    let label: String?
    let target: String?
    let destinationType: Action.DestinationType?
    let confirmation: ConfirmationPayload?

    enum CodingKeys: String, CodingKey {
        case type, text, options, title, description, image, label, target
        case destinationType = "destination_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        options = try container.decodeIfPresent([TanyaAIRadioOptionDTO].self, forKey: .options)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        target = try container.decodeIfPresent(String.self, forKey: .target)
        destinationType = try container.decodeIfPresent(Action.DestinationType.self, forKey: .destinationType)
        confirmation = type == "confirmation_card" ? try ConfirmationPayload(from: decoder) : nil
    }
}

struct TanyaAIRadioOptionDTO: Decodable {
    let label: String
    let value: String
}
