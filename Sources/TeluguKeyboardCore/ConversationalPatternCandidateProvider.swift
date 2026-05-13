import Foundation

public struct ConversationalPatternCandidateProvider: CandidateProvider {
    private static let dativeEmphaticStems: [String: String] = [
        "na": "నా",
        "naa": "నా",
        "nee": "నీ",
        "mee": "మీ",
        "maa": "మా"
    ]

    private static let chindiGeminationStems: [String: String] = [
        "i": "ఇ",
        "pu": "పు"
    ]

    private static let chaanuGeminationStems: [String: String] = [
        "i": "ఇ"
    ]

    private static let ppuduStems: [String: String] = [
        "a": "అ",
        "e": "ఎ",
        "i": "ఇ",
        "ye": "యె"
    ]

    public init() {}

    public func candidates(for roman: String, limit: Int) -> [Candidate] {
        let key = RomanNormalizer.normalize(roman)
        guard key.isEmpty == false else { return [] }

        var results: [Candidate] = []
        if key == "kada" {
            results.append(
                Candidate(
                    text: "కదా",
                    roman: key,
                    score: 292,
                    source: "pattern:ambiguous-particle"
                )
            )
        }
        if key.hasSuffix("ke") {
            let stemKey = String(key.dropLast(2))
            if let stem = Self.dativeEmphaticStems[stemKey] {
                results.append(
                    Candidate(
                        text: stem + "కే",
                        roman: key,
                        score: 212,
                        source: "pattern:dative-emphatic"
                    )
                )
            }
        }
        for suffix in ["cchindi", "chindi"] where key.hasSuffix(suffix) {
            let stemKey = String(key.dropLast(suffix.count))
            guard let stem = Self.chindiGeminationStems[stemKey] else { continue }
            results.append(
                Candidate(
                    text: stem + "చ్చింది",
                    roman: key,
                    score: 296,
                    source: "pattern:chindi-gemination"
                )
            )
        }
        for suffix in ["cchaanu", "cchanu", "chaanu", "chanu"] where key.hasSuffix(suffix) {
            let stemKey = String(key.dropLast(suffix.count))
            guard let stem = Self.chaanuGeminationStems[stemKey] else { continue }
            results.append(
                Candidate(
                    text: stem + "చ్చాను",
                    roman: key,
                    score: 296,
                    source: "pattern:chaanu-gemination"
                )
            )
        }
        for suffix in ["ppudoo", "ppudu"] where key.hasSuffix(suffix) {
            let stemKey = String(key.dropLast(suffix.count))
            guard let stem = Self.ppuduStems[stemKey] else { continue }
            let textSuffix = suffix == "ppudoo" ? "ప్పుడూ" : "ప్పుడు"
            results.append(
                Candidate(
                    text: stem + textSuffix,
                    roman: key,
                    score: 224,
                    source: "pattern:ppudu"
                )
            )
        }

        return results
            .sorted { lhs, rhs in lhs.score == rhs.score ? lhs.text < rhs.text : lhs.score > rhs.score }
            .prefix(limit)
            .map { $0 }
    }
}
