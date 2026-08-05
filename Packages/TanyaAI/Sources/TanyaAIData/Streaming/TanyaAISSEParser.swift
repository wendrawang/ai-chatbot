import Foundation

final class TanyaAISSEParser {
    private let lineFeedSeparator = Data([0x0A, 0x0A])
    private let carriageReturnSeparator = Data([0x0D, 0x0A, 0x0D, 0x0A])
    private var buffer = Data()

    func append(_ incomingData: Data) -> [TanyaAISSEEvent] {
        buffer.append(incomingData)

        var parsedEvents: [TanyaAISSEEvent] = []
        while let separatorRange = nextSeparatorRange() {
            let eventData = buffer.subdata(
                in: buffer.startIndex..<separatorRange.lowerBound
            )
            buffer.removeSubrange(
                buffer.startIndex..<separatorRange.upperBound
            )

            if let event = parse(eventData) {
                parsedEvents.append(event)
            }
        }
        return parsedEvents
    }

    func reset() {
        buffer.removeAll(keepingCapacity: false)
    }

    private func parse(_ eventData: Data) -> TanyaAISSEEvent? {
        guard var source = String(data: eventData, encoding: .utf8) else {
            return nil
        }

        source = source.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = source.components(separatedBy: "\n")
        var eventName = "message"
        var dataLines: [String] = []

        for line in lines {
            if line.hasPrefix(":") {
                eventName = "heartbeat"
            } else if line.hasPrefix("event:") {
                eventName = fieldValue(from: line)
            } else if line.hasPrefix("data:") {
                dataLines.append(fieldValue(from: line))
            }
        }

        guard eventName == "heartbeat" || !dataLines.isEmpty else {
            return nil
        }

        let payload = dataLines.joined(separator: "\n")
        return TanyaAISSEEvent(
            name: eventName,
            data: Data(payload.utf8)
        )
    }

    private func nextSeparatorRange() -> Range<Data.Index>? {
        let lineFeedRange = buffer.range(of: lineFeedSeparator)
        let carriageReturnRange = buffer.range(of: carriageReturnSeparator)

        switch (lineFeedRange, carriageReturnRange) {
        case (.none, .none):
            return nil
        case (.some(let range), .none), (.none, .some(let range)):
            return range
        case (.some(let firstRange), .some(let secondRange)):
            return firstRange.lowerBound < secondRange.lowerBound
                ? firstRange
                : secondRange
        }
    }

    private func fieldValue(from line: String) -> String {
        guard let separatorIndex = line.firstIndex(of: ":") else {
            return ""
        }
        let valueIndex = line.index(after: separatorIndex)
        return line[valueIndex...].trimmingCharacters(in: .whitespaces)
    }
}
