import Foundation

public struct CommonChatSuffixCandidateProvider: CandidateProvider {
    private struct Ending {
        let suffix: String
        let teluguSuffix: String
        let score: Double
    }

    private static let endings: [Ending] = [
        Ending(suffix: "unnaa", teluguSuffix: "ున్నా", score: 188),
        Ending(suffix: "unna", teluguSuffix: "ున్నా", score: 186),
        Ending(suffix: "unnavo", teluguSuffix: "ున్నావో", score: 188),
        Ending(suffix: "unnava", teluguSuffix: "ున్నావా", score: 188),
        Ending(suffix: "unnavu", teluguSuffix: "ున్నావు", score: 186),
        Ending(suffix: "unnaru", teluguSuffix: "ున్నారు", score: 186),
        Ending(suffix: "unnav", teluguSuffix: "ున్నావ్", score: 184),
        Ending(suffix: "nnaa", teluguSuffix: "న్నా", score: 180),
        Ending(suffix: "nna", teluguSuffix: "న్నా", score: 178),
        Ending(suffix: "nnavo", teluguSuffix: "న్నావో", score: 180),
        Ending(suffix: "nnava", teluguSuffix: "న్నావా", score: 180),
        Ending(suffix: "nnavu", teluguSuffix: "న్నావు", score: 178),
        Ending(suffix: "nnaru", teluguSuffix: "న్నారు", score: 178),
        Ending(suffix: "nnav", teluguSuffix: "న్నావ్", score: 176),
        Ending(suffix: "navo", teluguSuffix: "నావో", score: 176),
        Ending(suffix: "nava", teluguSuffix: "న్నావా", score: 176),
        Ending(suffix: "navu", teluguSuffix: "నావు", score: 172),
        Ending(suffix: "naru", teluguSuffix: "న్నారు", score: 172),
        Ending(suffix: "nav", teluguSuffix: "నావ్", score: 170),
        Ending(suffix: "poinaa", teluguSuffix: "పోయినా", score: 190),
        Ending(suffix: "poina", teluguSuffix: "పోయినా", score: 190),
        Ending(suffix: "poyinaa", teluguSuffix: "పోయినా", score: 190),
        Ending(suffix: "gainaa", teluguSuffix: "గైనా", score: 190),
        Ending(suffix: "gaina", teluguSuffix: "గైనా", score: 190),
        Ending(suffix: "do", teluguSuffix: "దో", score: 190),
        Ending(suffix: "ko", teluguSuffix: "కో", score: 190)
    ]

    private static let stems: [String: String] = [
        "": "",
        "bag": "బాగ",
        "baag": "బాగ",
        "chest": "చేస్త",
        "chesth": "చేస్త",
        "ist": "ఇస్త",
        "isth": "ఇస్త",
        "ela": "ఎలా",
        "elaa": "ఎలా",
        "choost": "చూస్త",
        "chust": "చూస్త",
        "vast": "వస్త",
        "lek": "లేక",
        "leka": "లేక",
        "ai": "అయి",
        "ayi": "అయి",
        "vasthun": "వస్తుం",
        "vastun": "వస్తుం",
        "pothun": "పోతుం",
        "potun": "పోతుం",
        "padu": "పడు",
        "pettu": "పెట్టు",
        "ches": "చేస్",
        "choos": "చూస్",
        "chus": "చుస్",
        "velth": "వెళ్త",
        "velt": "వెళ్త",
        "matladut": "మాట్లాడుత",
        "matladuth": "మాట్లాడుత",
        "tint": "తింట",
        "tagut": "తాగుత",
        "taguth": "తాగుత",
        "padukunt": "పడుకుంట",
        "chadavut": "చదువుత",
        "chadivut": "చదువుత",
        "ti": "తి",
        "vi": "వి",
        "choosi": "చూసి",
        "chusi": "చూసి",
        "cheppi": "చెప్పి"
    ]

    public init() {}

    public func candidates(for roman: String, limit: Int) -> [Candidate] {
        let key = RomanNormalizer.normalize(roman)
        guard key.isEmpty == false else { return [] }

        var results: [String: Candidate] = [:]
        for ending in Self.endings where key.hasSuffix(ending.suffix) {
            let stemKey = String(key.dropLast(ending.suffix.count))
            guard let stem = Self.stems[stemKey] else { continue }
            let text = stemKey.isEmpty && ending.teluguSuffix.hasPrefix("ు")
                ? "ఉ" + String(ending.teluguSuffix.dropFirst())
                : stem + ending.teluguSuffix
            let score = ending.score + (stemKey.isEmpty ? 4 : 0)
            results[text] = Candidate(text: text, roman: key, score: score, source: "chat-suffix")
        }
        if key == "poina" || key == "poyina" {
            results["పోయిన"] = Candidate(text: "పోయిన", roman: key, score: 196, source: "chat-suffix")
        }

        return results.values
            .sorted { lhs, rhs in lhs.score == rhs.score ? lhs.text < rhs.text : lhs.score > rhs.score }
            .prefix(limit)
            .map { $0 }
    }
}
