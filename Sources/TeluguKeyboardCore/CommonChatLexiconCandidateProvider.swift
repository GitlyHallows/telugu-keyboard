import Foundation

public struct CommonChatLexiconCandidateProvider: CandidateProvider {
    private struct Row {
        let roman: String
        let text: String
        let score: Double
    }

    private let entries: [String: [(text: String, score: Double)]]

    public init() {
        self.entries = Dictionary(grouping: Self.loadRows(), by: \.roman)
            .mapValues { rows in rows.map { ($0.text, $0.score) } }
    }

    public func candidates(for roman: String, limit: Int) -> [Candidate] {
        let key = RomanNormalizer.normalize(roman)
        return entries[key, default: []]
            .sorted { lhs, rhs in lhs.score == rhs.score ? lhs.text < rhs.text : lhs.score > rhs.score }
            .prefix(limit)
            .map { Candidate(text: $0.text, roman: key, score: $0.score, source: "common-chat") }
    }

    private static func loadRows() -> [Row] {
        guard let url = Bundle.module.url(forResource: "common_chat", withExtension: "tsv"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return fallbackRows
        }
        let rows = parseTSV(contents)
        return rows.isEmpty ? fallbackRows : rows
    }

    private static func parseTSV(_ contents: String) -> [Row] {
        contents
            .split(whereSeparator: \.isNewline)
            .compactMap { line -> Row? in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard trimmed.isEmpty == false, trimmed.hasPrefix("#") == false else {
                    return nil
                }
                let columns = trimmed.split(separator: "\t", omittingEmptySubsequences: false)
                guard columns.count >= 2 else { return nil }
                let roman = RomanNormalizer.normalize(String(columns[0]))
                let text = String(columns[1])
                let score = columns.count >= 3 ? Double(columns[2]) ?? 220.0 : 220.0
                guard roman.isEmpty == false, text.isEmpty == false else { return nil }
                return Row(roman: roman, text: text, score: score)
            }
    }

    private static let fallbackRows: [Row] = [
        Row(roman: "unnav", text: "ఉన్నావ్", score: 260),
        Row(roman: "unnavu", text: "ఉన్నావు", score: 260),
        Row(roman: "unnaru", text: "ఉన్నారు", score: 260),
        Row(roman: "unnava", text: "ఉన్నావా", score: 260),
        Row(roman: "bagunnava", text: "బాగున్నావా", score: 260),
        Row(roman: "ela", text: "ఎలా", score: 260),
        Row(roman: "em", text: "ఏం", score: 260),
        Row(roman: "chestunnav", text: "చేస్తున్నావ్", score: 260),
        Row(roman: "padaku", text: "పడకు", score: 260),
        Row(roman: "thondara", text: "తొందర", score: 260)
    ]
}
