import Foundation

public final class TeluguTransliterator {
    private let providers: [CandidateProvider]
    private let learningStore: UserLearningStore?

    public init(providers: [CandidateProvider]? = nil, learningStore: UserLearningStore? = UserLearningStore.defaultStore()) {
        self.learningStore = learningStore
        if let providers {
            self.providers = providers
        } else {
            var defaultProviders: [CandidateProvider] = []
            if let learningStore {
                defaultProviders.append(learningStore)
            }
            defaultProviders.append(CommonChatLexiconCandidateProvider())
            defaultProviders.append(SeedLexiconCandidateProvider())
            defaultProviders.append(ConversationalPatternCandidateProvider())
            defaultProviders.append(CommonChatSuffixCandidateProvider())
            defaultProviders.append(RuleBasedCandidateProvider())
            self.providers = defaultProviders
        }
    }

    public func candidates(for roman: String, limit: Int = 8, includePassthrough: Bool = true) -> [Candidate] {
        candidates(for: roman, context: TransliterationContext(), limit: limit, includePassthrough: includePassthrough)
    }

    public func candidates(
        for roman: String,
        context: TransliterationContext,
        limit: Int = 8,
        includePassthrough: Bool = true
    ) -> [Candidate] {
        let key = RomanNormalizer.normalize(roman)
        guard !key.isEmpty else { return [] }

        var merged: [String: Candidate] = [:]
        for provider in providers {
            for candidate in provider.candidates(for: key, limit: limit * 2) where !candidate.text.isEmpty {
                if let existing = merged[candidate.text] {
                    let nextScore = max(existing.score, candidate.score) + 0.05
                    let source = existing.source == candidate.source ? existing.source : "\(existing.source)+\(candidate.source)"
                    merged[candidate.text] = Candidate(text: candidate.text, roman: key, score: nextScore, source: source)
                } else {
                    merged[candidate.text] = candidate
                }
            }
        }

        if includePassthrough {
            merged[key] = Candidate(text: key, roman: key, score: -100, source: "passthrough")
        }

        return merged.values
            .map { applyContextBoost(to: $0, context: context) }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    if lhs.text.count == rhs.text.count {
                        return lhs.text < rhs.text
                    }
                    return lhs.text.count < rhs.text.count
                }
                return lhs.score > rhs.score
            }
            .prefix(limit)
            .map { $0 }
    }

    private func applyContextBoost(to candidate: Candidate, context: TransliterationContext) -> Candidate {
        let boost = contextBoost(for: candidate, context: context)
        guard boost != 0 else { return candidate }
        return Candidate(
            text: candidate.text,
            roman: candidate.roman,
            score: candidate.score + boost,
            source: candidate.source + "+context"
        )
    }

    private func contextBoost(for candidate: Candidate, context: TransliterationContext) -> Double {
        guard let previousRoman = context.lastRomanWord else { return 0 }
        let previousTelugu = context.lastTeluguWord ?? ""
        let current = candidate.roman
        let text = candidate.text

        if previousRoman == "ela" || previousTelugu == "ఎలా" {
            switch (current, text) {
            case ("unnav", "ఉన్నావ్"), ("unnavu", "ఉన్నావు"), ("unnava", "ఉన్నావా"), ("unnaru", "ఉన్నారు"):
                return 35
            default:
                break
            }
        }

        if previousRoman == "em" || previousRoman == "emi" || previousTelugu == "ఏం" || previousTelugu == "ఏమి" {
            if current.hasPrefix("chest") && text.hasPrefix("చేస్త") {
                return 28
            }
            if current.hasPrefix("choost") && text.hasPrefix("చూస్త") {
                return 24
            }
        }

        if previousRoman == "bagunnava" || previousTelugu == "బాగున్నావా" {
            if current == "nenu" && text == "నేను" {
                return 18
            }
        }

        return 0
    }

    public func learn(roman: String, candidateText: String) {
        learnExplicitSelection(roman: roman, candidateText: candidateText)
    }

    public func learnExplicitSelection(roman: String, candidateText: String) {
        learningStore?.learnExplicitSelection(roman: roman, candidateText: candidateText)
    }

    public func learnDefaultAccept(roman: String, candidateText: String) {
        learningStore?.learnDefaultAccept(roman: roman, candidateText: candidateText)
    }
}
