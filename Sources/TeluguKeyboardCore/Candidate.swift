import Foundation

public struct Candidate: Codable, Equatable, Hashable {
    public let text: String
    public let roman: String
    public let score: Double
    public let source: String

    public init(text: String, roman: String, score: Double, source: String) {
        self.text = text
        self.roman = roman
        self.score = score
        self.source = source
    }
}

public protocol CandidateProvider {
    func candidates(for roman: String, limit: Int) -> [Candidate]
}
