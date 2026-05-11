import Foundation

public struct RuleBasedCandidateProvider: CandidateProvider {
    private struct VowelOption {
        let token: String
        let independent: String
        let sign: String
        let score: Double
    }

    private struct ConsonantOption {
        let token: String
        let letter: String
        let score: Double
    }

    private struct State {
        let text: String
        let score: Double
    }

    private static let virama = "్"
    private static let anusvara = "ం"

    private static let vowels: [VowelOption] = [
        VowelOption(token: "ai", independent: "ఐ", sign: "ై", score: 1.00),
        VowelOption(token: "au", independent: "ఔ", sign: "ౌ", score: 1.00),
        VowelOption(token: "ou", independent: "ఔ", sign: "ౌ", score: 0.92),
        VowelOption(token: "aa", independent: "ఆ", sign: "ా", score: 1.00),
        VowelOption(token: "ii", independent: "ఈ", sign: "ీ", score: 0.96),
        VowelOption(token: "ee", independent: "ఈ", sign: "ీ", score: 0.96),
        VowelOption(token: "uu", independent: "ఊ", sign: "ూ", score: 0.96),
        VowelOption(token: "oo", independent: "ఊ", sign: "ూ", score: 0.82),
        VowelOption(token: "a", independent: "అ", sign: "", score: 1.00),
        VowelOption(token: "i", independent: "ఇ", sign: "ి", score: 1.00),
        VowelOption(token: "u", independent: "ఉ", sign: "ు", score: 1.00),
        VowelOption(token: "e", independent: "ఎ", sign: "ె", score: 0.96),
        VowelOption(token: "o", independent: "ఒ", sign: "ొ", score: 0.96)
    ]

    private static let consonants: [ConsonantOption] = [
        ConsonantOption(token: "ksh", letter: "క్ష", score: 1.00),
        ConsonantOption(token: "kk", letter: "క్క", score: 1.10),
        ConsonantOption(token: "gg", letter: "గ్గ", score: 1.08),
        ConsonantOption(token: "jj", letter: "జ్జ", score: 1.04),
        ConsonantOption(token: "tt", letter: "త్త", score: 0.96),
        ConsonantOption(token: "tt", letter: "ట్ట", score: 0.86),
        ConsonantOption(token: "dd", letter: "ద్ద", score: 0.96),
        ConsonantOption(token: "dd", letter: "డ్డ", score: 0.86),
        ConsonantOption(token: "nn", letter: "న్న", score: 1.12),
        ConsonantOption(token: "nn", letter: "ణ్ణ", score: 0.76),
        ConsonantOption(token: "pp", letter: "ప్ప", score: 1.08),
        ConsonantOption(token: "bb", letter: "బ్బ", score: 1.06),
        ConsonantOption(token: "mm", letter: "మ్మ", score: 1.12),
        ConsonantOption(token: "yy", letter: "య్య", score: 1.02),
        ConsonantOption(token: "rr", letter: "ర్ర", score: 0.82),
        ConsonantOption(token: "ll", letter: "ల్ల", score: 1.04),
        ConsonantOption(token: "ll", letter: "ళ్ల", score: 0.98),
        ConsonantOption(token: "vv", letter: "వ్వ", score: 1.02),
        ConsonantOption(token: "ss", letter: "స్స", score: 0.94),
        ConsonantOption(token: "chh", letter: "ఛ", score: 0.75),
        ConsonantOption(token: "kh", letter: "ఖ", score: 0.82),
        ConsonantOption(token: "gh", letter: "ఘ", score: 0.82),
        ConsonantOption(token: "ch", letter: "చ", score: 1.00),
        ConsonantOption(token: "jh", letter: "ఝ", score: 0.84),
        ConsonantOption(token: "ny", letter: "ఞ", score: 0.78),
        ConsonantOption(token: "ng", letter: "ఙ", score: 0.68),
        ConsonantOption(token: "th", letter: "త", score: 1.00),
        ConsonantOption(token: "th", letter: "థ", score: 0.74),
        ConsonantOption(token: "th", letter: "ఠ", score: 0.56),
        ConsonantOption(token: "dh", letter: "ధ", score: 0.88),
        ConsonantOption(token: "dh", letter: "ఢ", score: 0.66),
        ConsonantOption(token: "dh", letter: "ద", score: 0.45),
        ConsonantOption(token: "ph", letter: "ఫ", score: 0.82),
        ConsonantOption(token: "bh", letter: "భ", score: 0.98),
        ConsonantOption(token: "sh", letter: "శ", score: 1.00),
        ConsonantOption(token: "sh", letter: "ష", score: 0.84),
        ConsonantOption(token: "sh", letter: "స", score: 0.42),
        ConsonantOption(token: "ss", letter: "ష", score: 0.74),
        ConsonantOption(token: "rr", letter: "ఱ", score: 0.62),
        ConsonantOption(token: "ll", letter: "ళ", score: 0.84),
        ConsonantOption(token: "zh", letter: "ళ", score: 0.58),

        ConsonantOption(token: "k", letter: "క", score: 1.00),
        ConsonantOption(token: "g", letter: "గ", score: 1.00),
        ConsonantOption(token: "c", letter: "క", score: 0.36),
        ConsonantOption(token: "j", letter: "జ", score: 1.00),
        ConsonantOption(token: "t", letter: "త", score: 0.90),
        ConsonantOption(token: "t", letter: "ట", score: 0.78),
        ConsonantOption(token: "d", letter: "ద", score: 0.88),
        ConsonantOption(token: "d", letter: "డ", score: 0.82),
        ConsonantOption(token: "n", letter: "న", score: 1.00),
        ConsonantOption(token: "n", letter: "ణ", score: 0.58),
        ConsonantOption(token: "p", letter: "ప", score: 1.00),
        ConsonantOption(token: "f", letter: "ఫ", score: 0.64),
        ConsonantOption(token: "b", letter: "బ", score: 1.00),
        ConsonantOption(token: "m", letter: "మ", score: 1.00),
        ConsonantOption(token: "y", letter: "య", score: 1.00),
        ConsonantOption(token: "r", letter: "ర", score: 1.00),
        ConsonantOption(token: "l", letter: "ల", score: 1.00),
        ConsonantOption(token: "l", letter: "ళ", score: 0.52),
        ConsonantOption(token: "v", letter: "వ", score: 1.00),
        ConsonantOption(token: "w", letter: "వ", score: 0.88),
        ConsonantOption(token: "s", letter: "స", score: 1.00),
        ConsonantOption(token: "s", letter: "శ", score: 0.58),
        ConsonantOption(token: "h", letter: "హ", score: 1.00)
    ].sorted { lhs, rhs in
        lhs.token.count == rhs.token.count ? lhs.score > rhs.score : lhs.token.count > rhs.token.count
    }

    public init() {}

    public func candidates(for roman: String, limit: Int) -> [Candidate] {
        let input = RomanNormalizer.normalize(roman)
        guard !input.isEmpty else { return [] }

        let chars = Array(input)
        var beams = Array(repeating: [State](), count: chars.count + 1)
        beams[0] = [State(text: "", score: 0)]

        for index in 0..<chars.count {
            guard !beams[index].isEmpty else { continue }
            let states = prune(beams[index], maxCount: 64)
            for state in states {
                expandConsonants(input: chars, index: index, state: state, beams: &beams)
                expandVowels(input: chars, index: index, state: state, beams: &beams)
                if !startsConsonant(input: chars, index: index) && !startsVowel(input: chars, index: index) {
                    beams[index + 1].append(State(text: state.text + String(chars[index]), score: state.score - 4))
                }
            }
            beams[index].removeAll(keepingCapacity: false)
        }

        return prune(beams[chars.count], maxCount: limit * 4)
            .reduce(into: [String: Candidate]()) { result, state in
                let candidate = Candidate(text: state.text, roman: input, score: state.score, source: "rule")
                if let existing = result[candidate.text], existing.score >= candidate.score {
                    return
                }
                result[candidate.text] = candidate
            }
            .values
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.text < rhs.text
                }
                return lhs.score > rhs.score
            }
            .prefix(limit)
            .map { $0 }
    }

    private func expandConsonants(input: [Character], index: Int, state: State, beams: inout [[State]]) {
        let matchingConsonants = Self.consonants.filter { matches($0.token, in: input, at: index) }
        guard let longestMatch = matchingConsonants.map(\.token.count).max() else { return }

        for consonant in matchingConsonants where consonant.token.count == longestMatch {
            let afterConsonant = index + consonant.token.count

            if let nextVowels = vowelMatches(input: input, index: afterConsonant), !nextVowels.isEmpty {
                for vowel in nextVowels {
                    let output = consonant.letter + vowel.option.sign
                    beams[vowel.nextIndex].append(State(text: state.text + output, score: state.score + consonant.score + vowel.option.score))
                }
                continue
            }

            if startsConsonant(input: input, index: afterConsonant) {
                if consonant.token == "n" {
                    beams[afterConsonant].append(State(text: state.text + Self.anusvara, score: state.score + consonant.score + 0.16))
                } else if consonant.token == "m", !matches("m", in: input, at: afterConsonant) {
                    beams[afterConsonant].append(State(text: state.text + Self.anusvara, score: state.score + consonant.score + 0.06))
                }
                beams[afterConsonant].append(State(text: state.text + consonant.letter + Self.virama, score: state.score + consonant.score - 0.04))
            } else {
                beams[afterConsonant].append(State(text: state.text + consonant.letter, score: state.score + consonant.score - 0.02))
            }
        }
    }

    private func expandVowels(input: [Character], index: Int, state: State, beams: inout [[State]]) {
        guard let matches = vowelMatches(input: input, index: index) else { return }
        for vowel in matches {
            beams[vowel.nextIndex].append(State(text: state.text + vowel.option.independent, score: state.score + vowel.option.score - 0.05))
        }
    }

    private func vowelMatches(input: [Character], index: Int) -> [(option: VowelOption, nextIndex: Int)]? {
        guard index < input.count else { return nil }
        let found = Self.vowels
            .filter { self.matches($0.token, in: input, at: index) }
            .map { (option: $0, nextIndex: index + $0.token.count) }
        guard let longest = found.map(\.option.token.count).max() else { return nil }
        return found.filter { $0.option.token.count == longest }
    }

    private func startsConsonant(input: [Character], index: Int) -> Bool {
        guard index < input.count else { return false }
        return Self.consonants.contains { matches($0.token, in: input, at: index) }
    }

    private func startsVowel(input: [Character], index: Int) -> Bool {
        guard index < input.count else { return false }
        return Self.vowels.contains { matches($0.token, in: input, at: index) }
    }

    private func matches(_ token: String, in input: [Character], at index: Int) -> Bool {
        let tokenChars = Array(token)
        guard index + tokenChars.count <= input.count else { return false }
        for offset in 0..<tokenChars.count where input[index + offset] != tokenChars[offset] {
            return false
        }
        return true
    }

    private func prune(_ states: [State], maxCount: Int) -> [State] {
        var bestByText: [String: State] = [:]
        for state in states {
            if let existing = bestByText[state.text], existing.score >= state.score {
                continue
            }
            bestByText[state.text] = state
        }
        return bestByText.values
            .sorted { lhs, rhs in lhs.score == rhs.score ? lhs.text < rhs.text : lhs.score > rhs.score }
            .prefix(maxCount)
            .map { $0 }
    }
}
