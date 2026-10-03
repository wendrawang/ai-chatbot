import Foundation

/// A backend confirmation reference; the host obtains its own PIN challenge.
public struct ConfirmationPayload: Equatable, Decodable {

    public typealias Field = ConfirmationField

    public let confirmationIdentifier: String
    public let fields: [Field]

    enum CodingKeys: String, CodingKey {
        case confirmationIdentifier = "confirmation_id"
        case fields
    }
}

public struct ConfirmationField: Equatable, Decodable {
    public let key: String
    public let label: String
    public let value: String
    public let rawValue: Decimal?

    enum CodingKeys: String, CodingKey {
        case key, label, value
        case rawValue = "raw_value"
    }
}
