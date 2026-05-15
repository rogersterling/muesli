import Foundation

enum DictationSpokenFormatNormalizer {
    private static let numberWords: [String: Int] = [
        "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6,
        "seven": 7, "eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12,
    ]

    private static let monthNames: [String: String] = [
        "january": "January",
        "february": "February",
        "march": "March",
        "april": "April",
        "may": "May",
        "june": "June",
        "july": "July",
        "august": "August",
        "september": "September",
        "october": "October",
        "november": "November",
        "december": "December",
    ]

    private static let dayOrdinals: [String: Int] = [
        "first": 1, "one": 1,
        "second": 2, "two": 2,
        "third": 3, "three": 3,
        "fourth": 4, "four": 4,
        "fifth": 5, "five": 5,
        "sixth": 6, "six": 6,
        "seventh": 7, "seven": 7,
        "eighth": 8, "eight": 8,
        "ninth": 9, "nine": 9,
        "tenth": 10, "ten": 10,
        "eleventh": 11, "eleven": 11,
        "twelfth": 12, "twelve": 12,
        "thirteenth": 13, "thirteen": 13,
        "fourteenth": 14, "fourteen": 14,
        "fifteenth": 15, "fifteen": 15,
        "sixteenth": 16, "sixteen": 16,
        "seventeenth": 17, "seventeen": 17,
        "eighteenth": 18, "eighteen": 18,
        "nineteenth": 19, "nineteen": 19,
        "twentieth": 20, "twenty": 20,
        "twenty first": 21, "twenty-first": 21,
        "twenty second": 22, "twenty-second": 22,
        "twenty third": 23, "twenty-third": 23,
        "twenty fourth": 24, "twenty-fourth": 24,
        "twenty fifth": 25, "twenty-fifth": 25,
        "twenty sixth": 26, "twenty-sixth": 26,
        "twenty seventh": 27, "twenty-seventh": 27,
        "twenty eighth": 28, "twenty-eighth": 28,
        "twenty ninth": 29, "twenty-ninth": 29,
        "thirtieth": 30, "thirty": 30,
        "thirty first": 31, "thirty-first": 31,
    ]

    static func apply(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        return normalizeMonthDates(normalizeOClockTimes(text))
    }

    private static func normalizeOClockTimes(_ text: String) -> String {
        let hourPattern = "(?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|1[0-2]|[1-9])"
        let pattern = "\\b(\(hourPattern))\\s+o['’]?clock(?:\\s+([ap])\\.?\\s*m\\.?)?\\b"
        return replaceMatches(in: text, pattern: pattern) { match, source in
            guard let hourRange = Range(match.range(at: 1), in: source),
                  let hour = hourValue(String(source[hourRange])) else {
                return nil
            }

            var suffix = ""
            if match.range(at: 2).location != NSNotFound,
               let meridiemRange = Range(match.range(at: 2), in: source) {
                suffix = " " + (source[meridiemRange].lowercased() == "a" ? "AM" : "PM")
            }
            return "\(hour):00\(suffix)"
        }
    }

    private static func normalizeMonthDates(_ text: String) -> String {
        let monthPattern = monthNames.keys.sorted { $0.count > $1.count }.joined(separator: "|")
        let dayWordPattern = dayOrdinals.keys.sorted { $0.count > $1.count }.map {
            NSRegularExpression.escapedPattern(for: $0)
        }.joined(separator: "|")
        let dayPattern = "(?:\(dayWordPattern)|(?:[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?)"
        let pattern = "\\b(\(monthPattern))\\s+(?:the\\s+)?(\(dayPattern))\\b"
        return replaceMatches(in: text, pattern: pattern) { match, source in
            guard let monthRange = Range(match.range(at: 1), in: source),
                  let dayRange = Range(match.range(at: 2), in: source) else {
                return nil
            }
            let monthKey = String(source[monthRange]).lowercased()
            let dayToken = String(source[dayRange]).lowercased()
            guard let month = monthNames[monthKey],
                  let day = dayValue(dayToken) else {
                return nil
            }
            return "\(month) \(day)"
        }
    }

    private static func hourValue(_ token: String) -> Int? {
        let lower = token.lowercased()
        if let value = numberWords[lower] { return value }
        guard let value = Int(lower), (1...12).contains(value) else { return nil }
        return value
    }

    private static func dayValue(_ token: String) -> Int? {
        if let value = dayOrdinals[token] { return value }
        let stripped = token.replacingOccurrences(
            of: #"(st|nd|rd|th)$"#,
            with: "",
            options: .regularExpression
        )
        guard let value = Int(stripped), (1...31).contains(value) else { return nil }
        return value
    }

    private static func replaceMatches(
        in text: String,
        pattern: String,
        transform: (NSTextCheckingResult, String) -> String?
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return text
        }
        var result = text
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        for match in matches.reversed() {
            guard let range = Range(match.range, in: result),
                  let replacement = transform(match, result) else {
                continue
            }
            result.replaceSubrange(range, with: replacement)
        }
        return result
    }
}
