import DesignKit
import Foundation

public struct ResponseMetric: Equatable, Decodable {
    public let title: String
    public let value: String
    public let change: String?
    public let isPositive: Bool?
    public let information: ResponseAction?
}

public struct ResponseSummary: Equatable, Decodable {
    public let title: String
    public let subtitle: String?
    public let detail: String?
    public let symbolName: String?
    public let fields: [SummaryField]
}

public struct ResponseAction: Equatable, Decodable {
    public enum Intent: String, Decodable { case prompt, destination, edit, authorization }
    public let identifier: String
    public let title: String
    public let intent: Intent
    public let target: String
    public let symbolName: String?
}

public struct WelcomeConfiguration: Equatable {
    public let title: String
    public let subtitle: String
    public let sectionTitle: String
    public let actions: [QuickActionData]

    public init(title: String, subtitle: String, sectionTitle: String, actions: [QuickActionData]) {
        self.title = title
        self.subtitle = subtitle
        self.sectionTitle = sectionTitle
        self.actions = actions
    }
}
