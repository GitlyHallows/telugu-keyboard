import Foundation

public struct SeedLexiconCandidateProvider: CandidateProvider {
    private struct SeedEntry {
        let roman: String
        let text: String
        let score: Double
    }

    private let entries: [String: [(text: String, score: Double)]]

    public init() {
        self.entries = Dictionary(grouping: Self.seedEntries, by: { $0.roman })
            .mapValues { rows in rows.map { ($0.text, $0.score) } }
    }

    public func candidates(for roman: String, limit: Int) -> [Candidate] {
        let key = RomanNormalizer.normalize(roman)
        return entries[key, default: []]
            .sorted { lhs, rhs in lhs.score == rhs.score ? lhs.text < rhs.text : lhs.score > rhs.score }
            .prefix(limit)
            .map { Candidate(text: $0.text, roman: key, score: $0.score, source: "seed-lexicon") }
    }

    private static let seedEntries: [SeedEntry] = rawSeedEntries.map { row in
        SeedEntry(roman: RomanNormalizer.normalize(row.0), text: row.1, score: row.2)
    }

    private static let rawSeedEntries: [(String, String, Double)] = [
        ("padaku", "పడకు", 160.0),
        ("padhaku", "పడకు", 150.0),
        ("padakuu", "పడకూ", 126.0),
        ("padanu", "పడను", 115.0),
        ("pada", "పద", 110.0),

        ("thondara", "తొందర", 160.0),
        ("tondara", "తొందర", 145.0),
        ("thondaraa", "తొందరా", 132.0),
        ("thondare", "తొందరే", 125.0),
        ("thondaraga", "తొందరగా", 122.0),

        ("telugu", "తెలుగు", 160.0),
        ("thelugu", "తెలుగు", 154.0),
        ("telgu", "తెలుగు", 130.0),
        ("telugulo", "తెలుగులో", 126.0),

        ("amma", "అమ్మ", 150.0),
        ("nanna", "నాన్న", 145.0),
        ("akka", "అక్క", 140.0),
        ("anna", "అన్న", 140.0),

        ("nenu", "నేను", 140.0),
        ("neenu", "నేను", 126.0),
        ("meeru", "మీరు", 140.0),
        ("miru", "మీరు", 126.0),
        ("nuvvu", "నువ్వు", 135.0),
        ("manam", "మనం", 132.0),
        ("mana", "మన", 124.0),
        ("maa", "మా", 120.0),
        ("mee", "మీ", 120.0),

        ("idi", "ఇది", 132.0),
        ("adi", "అది", 130.0),
        ("em", "ఏం", 150.0),
        ("em", "ఏమి", 128.0),
        ("em", "ఎం", 118.0),
        ("yem", "ఏం", 145.0),
        ("emi", "ఏమి", 142.0),
        ("evaru", "ఎవరు", 132.0),
        ("enduku", "ఎందుకు", 135.0),
        ("ela", "ఎలా", 130.0),
        ("ekkada", "ఎక్కడ", 132.0),
        ("ippudu", "ఇప్పుడు", 132.0),
        ("inka", "ఇంకా", 126.0),

        ("ledu", "లేదు", 138.0),
        ("avunu", "అవును", 136.0),
        ("kaadu", "కాదు", 136.0),
        ("kadu", "కాదు", 125.0),
        ("randi", "రండి", 128.0),
        ("vellandi", "వెళ్లండి", 126.0),
        ("veldam", "వెళ్దాం", 120.0),

        ("bagundi", "బాగుంది", 142.0),
        ("bagunnara", "బాగున్నారా", 145.0),
        ("baagunnara", "బాగున్నారా", 136.0),
        ("chala", "చాలా", 130.0),
        ("chaala", "చాలా", 130.0),
        ("chestunnav", "చేస్తున్నావ్", 160.0),
        ("chestunnav", "చేస్తున్నావు", 150.0),
        ("chestunnavu", "చేస్తున్నావు", 160.0),
        ("chestunav", "చేస్తున్నావ్", 134.0),
        ("chesthunav", "చేస్తున్నావ్", 130.0),
        ("chesthunnav", "చేస్తున్నావ్", 148.0),
        ("chesthunnavu", "చేస్తున్నావు", 148.0),
        ("chestunna", "చేస్తున్నా", 138.0),
        ("chesthunna", "చేస్తున్నా", 132.0),
        ("santosham", "సంతోషం", 130.0),
        ("namaste", "నమస్తే", 128.0),
        ("dhanyavadalu", "ధన్యవాదాలు", 128.0)
    ]
}
