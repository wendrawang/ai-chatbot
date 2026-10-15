import Foundation

/// Change this one format to adjust the conversation date separator.
public enum ChatDateFormat {
    public static let timestamp = "d MMM yyyy, HH:mm"

    static func string(from date: Date, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = .current
        formatter.dateFormat = timestamp
        return formatter.string(from: date)
    }
}
