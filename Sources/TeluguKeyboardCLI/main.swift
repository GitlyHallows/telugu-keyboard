import Foundation
import TeluguKeyboardCore

let words = Array(CommandLine.arguments.dropFirst())
guard !words.isEmpty else {
    print("usage: telugu-keyboard-cli <roman-word> [roman-word...]")
    exit(2)
}

let transliterator = TeluguTransliterator(learningStore: nil)

for word in words {
    print("\(word):")
    for (index, candidate) in transliterator.candidates(for: word, limit: 10, includePassthrough: false).enumerated() {
        let rank = index + 1
        print("  \(rank). \(candidate.text)\t\(String(format: "%.2f", candidate.score))\t\(candidate.source)")
    }
}
