import Foundation

public struct TransliterationContext: Sendable, Equatable {
    public var previousRomanWords: [String]
    public var previousTeluguWords: [String]

    public init(previousRomanWords: [String] = [], previousTeluguWords: [String] = []) {
        self.previousRomanWords = previousRomanWords.map(RomanNormalizer.normalize)
        self.previousTeluguWords = previousTeluguWords
    }

    var lastRomanWord: String? {
        previousRomanWords.last
    }

    var lastTeluguWord: String? {
        previousTeluguWords.last
    }
}
