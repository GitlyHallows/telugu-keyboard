import Foundation

public struct LearningEntry: Codable, Equatable, Sendable {
    public var explicitSelectionCount: Int
    public var defaultAcceptCount: Int

    public init(explicitSelectionCount: Int = 0, defaultAcceptCount: Int = 0) {
        self.explicitSelectionCount = explicitSelectionCount
        self.defaultAcceptCount = defaultAcceptCount
    }
}

public final class UserLearningStore: CandidateProvider {
    private let url: URL?
    private var entries: [String: [String: LearningEntry]]

    public static func defaultStore() -> UserLearningStore {
        let base = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/TeluguKeyboard", isDirectory: true)
        return UserLearningStore(url: base.appendingPathComponent("learning.json"))
    }

    public init(url: URL?) {
        self.url = url
        self.entries = [:]
        load()
    }

    public func candidates(for roman: String, limit: Int) -> [Candidate] {
        let key = RomanNormalizer.normalize(roman)
        let learnedEntries = entries[key, default: [:]]
        var candidates: [Candidate] = []
        for (text, entry) in learnedEntries {
            guard let score = score(for: entry) else { continue }
            let source = entry.explicitSelectionCount > 0 ? "learning-explicit" : "learning-default"
            candidates.append(Candidate(text: text, roman: key, score: score, source: source))
        }
        candidates.sort { lhs, rhs in
            lhs.score == rhs.score ? lhs.text < rhs.text : lhs.score > rhs.score
        }
        return Array(candidates.prefix(limit))
    }

    public func learn(roman: String, candidateText: String) {
        learnExplicitSelection(roman: roman, candidateText: candidateText)
    }

    public func learnExplicitSelection(roman: String, candidateText: String) {
        let key = RomanNormalizer.normalize(roman)
        guard !key.isEmpty, !candidateText.isEmpty else { return }
        var entry = entries[key, default: [:]][candidateText, default: LearningEntry()]
        entry.explicitSelectionCount += 1
        entries[key, default: [:]][candidateText] = entry
        save()
    }

    public func learnDefaultAccept(roman: String, candidateText: String) {
        let key = RomanNormalizer.normalize(roman)
        guard !key.isEmpty, !candidateText.isEmpty, key != candidateText else { return }
        var entry = entries[key, default: [:]][candidateText, default: LearningEntry()]
        entry.defaultAcceptCount += 1
        entries[key, default: [:]][candidateText] = entry
        save()
    }

    public func removeAll() {
        entries.removeAll(keepingCapacity: false)
        guard let url else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private func score(for entry: LearningEntry) -> Double? {
        if entry.explicitSelectionCount > 0 {
            let explicitCount = min(entry.explicitSelectionCount, 20)
            let base = entry.explicitSelectionCount == 1 ? 235.0 : 335.0
            return base + Double(explicitCount * 8) + min(Double(entry.defaultAcceptCount), 20) * 0.1
        }
        if entry.defaultAcceptCount > 0 {
            return 1 + min(Double(entry.defaultAcceptCount), 40) * 0.02
        }
        return nil
    }

    private func load() {
        guard let url, let data = try? Data(contentsOf: url) else { return }
        if let storedEntries = try? JSONDecoder().decode([String: [String: LearningEntry]].self, from: data) {
            entries = storedEntries
            return
        }

        if let legacyCounts = try? JSONDecoder().decode([String: [String: Int]].self, from: data) {
            entries = legacyCounts.mapValues { textCounts in
                textCounts.mapValues { count in
                    LearningEntry(explicitSelectionCount: count, defaultAcceptCount: 0)
                }
            }
        }
    }

    private func save() {
        guard let url else { return }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(entries)
            try data.write(to: url, options: [.atomic])
        } catch {
            // Learning is a ranking aid only; typing must keep working if persistence fails.
        }
    }
}
