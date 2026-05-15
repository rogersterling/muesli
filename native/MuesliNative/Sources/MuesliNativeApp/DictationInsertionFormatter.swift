import Foundation

enum DictationInsertionFormatter {
    private static let leadingPunctuation = CharacterSet(charactersIn: ".,;:!?)]}”’")
    private static let openingPunctuation = CharacterSet(charactersIn: "([{“‘")
    private static let sentenceEnders = CharacterSet(charactersIn: ".!?")
    private static let continuationLowercaseWords: Set<String> = [
        "a", "actually", "also", "an", "and", "as", "at", "basically", "because", "before",
        "but", "by", "can", "could", "for", "from", "he", "here", "how", "however", "if",
        "in", "it", "on", "or", "she", "should", "so", "that", "the", "then", "there",
        "these", "they", "this", "those", "to", "unless", "until", "we", "what", "when",
        "where", "which", "while", "who", "why", "will", "with", "without", "would", "you",
    ]

    static func prepareForInsertion(
        _ text: String,
        context: DictationContext?,
        recentInsertionContext: String? = nil,
        hasTextBeforeCursorWhenContextUnavailable: Bool = false
    ) -> String {
        var output = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !output.isEmpty else { return output }
        let context = readableContext(context, recentInsertionContext: recentInsertionContext)
        guard let context else {
            if hasTextBeforeCursorWhenContextUnavailable,
               needsLeadingSpaceWithoutReadableContext(insertion: output) {
                return " " + output
            }
            return output
        }

        let isReplacingSelection = !context.selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if shouldLowercaseFirstWord(context.documentContext) {
            output = lowercaseLeadingContinuationWord(output)
        }
        if !isReplacingSelection, needsLeadingSpace(before: context.documentContext, insertion: output) {
            output = " " + output
        } else if context.documentContext.isEmpty,
                  !isReplacingSelection,
                  hasTextBeforeCursorWhenContextUnavailable,
                  needsLeadingSpaceWithoutReadableContext(insertion: output) {
            output = " " + output
        }
        return output
    }

    private static func readableContext(
        _ context: DictationContext?,
        recentInsertionContext: String?
    ) -> DictationContext? {
        let recentContext = recentInsertionContext?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !recentContext.isEmpty else { return context }
        guard let context else {
            return DictationContext(
                appName: "Unknown",
                bundleID: "",
                documentContext: recentContext,
                selectedText: "",
                url: nil
            )
        }
        guard context.documentContext.isEmpty,
              context.selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return context
        }
        return DictationContext(
            appName: context.appName,
            bundleID: context.bundleID,
            documentContext: recentContext,
            selectedText: "",
            url: context.url
        )
    }

    private static func shouldLowercaseFirstWord(_ documentContext: String) -> Bool {
        if documentContext.last?.isNewline == true { return false }
        guard let lastNonWhitespace = documentContext.last(where: { !$0.isWhitespace }) else { return false }
        guard String(lastNonWhitespace).rangeOfCharacter(from: sentenceEnders) == nil else { return false }
        return true
    }

    private static func lowercaseLeadingContinuationWord(_ text: String) -> String {
        guard let range = leadingWordRange(in: text) else { return text }
        let word = String(text[range])
        let lowercasedWord = word.lowercased()
        guard continuationLowercaseWords.contains(lowercasedWord) else { return text }
        var result = text
        result.replaceSubrange(range, with: lowercasedWord)
        return result
    }

    private static func leadingWordRange(in text: String) -> Range<String.Index>? {
        guard let first = text.firstIndex(where: { $0.isLetter }) else { return nil }
        var end = first
        while end < text.endIndex {
            let char = text[end]
            guard char.isLetter || char == "'" || char == "’" else { break }
            end = text.index(after: end)
        }
        return first..<end
    }

    private static func needsLeadingSpace(before documentContext: String, insertion: String) -> Bool {
        guard let previous = documentContext.last else { return false }
        guard !previous.isWhitespace else { return false }
        guard String(previous).rangeOfCharacter(from: openingPunctuation) == nil else { return false }
        guard let first = insertion.first else { return false }
        guard String(first).rangeOfCharacter(from: leadingPunctuation) == nil else { return false }
        return true
    }

    private static func needsLeadingSpaceWithoutReadableContext(insertion: String) -> Bool {
        guard let first = insertion.first else { return false }
        guard !first.isWhitespace else { return false }
        guard String(first).rangeOfCharacter(from: leadingPunctuation) == nil else { return false }
        return true
    }
}
