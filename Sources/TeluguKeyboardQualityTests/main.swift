import Foundation
import TeluguKeyboardCore

struct FixtureRow {
    let roman: String
    let telugu: String
}

struct CorrectionLedgerRow {
    let id: String
    let roman: String
    let expected: String
    let category: String
    let generalization: String
    let status: String
}

var failures: [String] = []

@MainActor
func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        failures.append(message)
    }
}

func projectRoot() -> URL {
    var url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    for _ in 0..<4 {
        if FileManager.default.fileExists(atPath: url.appendingPathComponent("Package.swift").path) {
            return url
        }
        url.deleteLastPathComponent()
    }
    return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
}

@MainActor
func loadFixtureRows() -> [FixtureRow] {
    let fixtureURL = projectRoot()
        .appendingPathComponent("Sources/TeluguKeyboardCore/Resources/common_chat.tsv")
    guard let contents = try? String(contentsOf: fixtureURL, encoding: .utf8) else {
        failures.append("Unable to read common_chat.tsv at \(fixtureURL.path)")
        return []
    }

    return contents
        .split(whereSeparator: \.isNewline)
        .compactMap { line -> FixtureRow? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.isEmpty == false, trimmed.hasPrefix("#") == false else { return nil }
            let columns = trimmed.split(separator: "\t", omittingEmptySubsequences: false)
            guard columns.count >= 2 else { return nil }
            return FixtureRow(roman: String(columns[0]), telugu: String(columns[1]))
        }
}

func topCandidates(for roman: String, limit: Int = 3) -> [String] {
    TeluguTransliterator(learningStore: nil)
        .candidates(for: roman, limit: limit, includePassthrough: false)
        .map(\.text)
}

func transliteratePhrase(_ phrase: String) -> String {
    let transliterator = TeluguTransliterator(learningStore: nil)
    var previousRoman: [String] = []
    var previousTelugu: [String] = []
    var output: [String] = []

    for word in phrase.split(separator: " ") {
        let roman = String(word)
        let context = TransliterationContext(previousRomanWords: previousRoman, previousTeluguWords: previousTelugu)
        let telugu = transliterator.candidates(for: roman, context: context, limit: 1, includePassthrough: false).first?.text ?? roman
        output.append(telugu)
        previousRoman.append(roman)
        previousTelugu.append(telugu)
    }

    return output.joined(separator: " ")
}

@MainActor
func loadCorrectionLedgerRows() -> [CorrectionLedgerRow] {
    let ledgerURL = projectRoot().appendingPathComponent("data/correction_ledger.tsv")
    guard let contents = try? String(contentsOf: ledgerURL, encoding: .utf8) else {
        failures.append("Unable to read correction ledger at \(ledgerURL.path)")
        return []
    }

    return contents
        .split(whereSeparator: \.isNewline)
        .compactMap { line -> CorrectionLedgerRow? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.isEmpty == false, trimmed.hasPrefix("#") == false else { return nil }
            let columns = trimmed.split(separator: "\t", omittingEmptySubsequences: false)
            guard columns.count >= 7 else {
                failures.append("Correction ledger row must have 7 columns: \(trimmed)")
                return nil
            }
            return CorrectionLedgerRow(
                id: String(columns[0]),
                roman: String(columns[1]),
                expected: String(columns[2]),
                category: String(columns[3]),
                generalization: String(columns[4]),
                status: String(columns[5])
            )
        }
}

@MainActor
func assertCorrectionLedgerBehavior() {
    let rows = loadCorrectionLedgerRows()
    expect(rows.count >= 25, "correction ledger should track the user-confirmed fixes")

    let allowedCategories: Set<String> = [
        "exact-common-word",
        "generalized-suffix-pattern",
        "candidate-ranking-feature",
        "local-user-learning-case"
    ]
    let requiredCategories = allowedCategories
    let allowedStatuses: Set<String> = [
        "exact-only",
        "pattern-implemented",
        "ranking-implemented",
        "local-runtime"
    ]
    let categories = Set(rows.map(\.category))
    expect(requiredCategories.isSubset(of: categories), "correction ledger should use every correction category")

    for row in rows {
        expect(allowedCategories.contains(row.category), "correction \(row.id) has unknown category \(row.category)")
        expect(row.generalization.isEmpty == false && row.generalization != "none" || row.category == "exact-common-word", "correction \(row.id) should record generalization decision")
        expect(allowedStatuses.contains(row.status), "correction \(row.id) has unknown status \(row.status)")

        guard row.expected != "-" else { continue }
        if row.roman.contains(" ") {
            expect(
                transliteratePhrase(row.roman) == row.expected,
                "correction \(row.id) phrase \(row.roman) should rank \(row.expected)"
            )
        } else {
            expect(
                topCandidates(for: row.roman, limit: 1).first == row.expected,
                "correction \(row.id) \(row.roman) should rank \(row.expected) first"
            )
        }
    }
}

@MainActor
func assertReviewImportScriptBehavior() {
    let root = projectRoot()
    let tempDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("telugu-keyboard-review-import-\(UUID().uuidString)", isDirectory: true)
    do {
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        let commonURL = tempDirectory.appendingPathComponent("common_chat.tsv")
        let reviewURL = tempDirectory.appendingPathComponent("review.tsv")
        try """
        # roman\ttelugu\tscore
        sampleold\tపాత\t111
        samplereplace\tపాతది\t111
        duplicate\tమొదటి\t111
        duplicate\tరెండవది\t111
        keep\tఉంచు\t111

        """.write(to: commonURL, atomically: true, encoding: .utf8)
        try """
        roman\tlocal_top\tcandidate_top\tcandidates\tstatus
        sampleold\tపాత\tకొత్త\tకొత్త|కొత\taccepted
        samplereplace\tపాతది\tసరైనది\tసరైనది|సరి అయినది\treplace
        samplenew\t\tకొత్తది\tకొత్తది|కొతది\taccepted
        skiprejected\t\tవద్దు\tవద్దు\trejected
        ela unnav\tఎలా ఉన్నావ్\tఎలా ఉన్నావ్\tఎలా ఉన్నావ్\taccepted

        """.write(to: reviewURL, atomically: true, encoding: .utf8)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [root.appendingPathComponent("script/import_accepted_review_rows.sh").path, reviewURL.path]
        var environment = ProcessInfo.processInfo.environment
        environment["COMMON_CHAT_TSV"] = commonURL.path
        environment["IMPORT_SCORE"] = "333"
        process.environment = environment
        try process.run()
        process.waitUntilExit()
        expect(process.terminationStatus == 0, "review import script should exit successfully")

        let imported = try String(contentsOf: commonURL, encoding: .utf8)
        expect(imported.contains("sampleold\tపాత\t111"), "accepted existing rows should not overwrite without replace")
        expect(imported.contains("samplereplace\tసరైనది\t333"), "replace rows should overwrite existing mappings")
        expect(imported.contains("samplenew\tకొత్తది\t333"), "accepted new rows should append")
        expect(imported.contains("skiprejected") == false, "rejected rows should not import")
        expect(imported.contains("ela unnav") == false, "phrase rows should not import into word-level common_chat.tsv")
        expect(imported.components(separatedBy: "duplicate\t").count == 2, "import should deduplicate existing normalized roman rows")
    } catch {
        failures.append("review import script fixture failed: \(error)")
    }
    try? FileManager.default.removeItem(at: tempDirectory)
}

let rows = loadFixtureRows()
expect(rows.count >= 300, "common_chat.tsv should contain at least 300 curated rows")

let requiredExamples: [String: String] = [
    "unnav": "ఉన్నావ్",
    "unnavu": "ఉన్నావు",
    "unnaru": "ఉన్నారు",
    "unnava": "ఉన్నావా",
    "bagunnava": "బాగున్నావా",
    "ela": "ఎలా",
    "em": "ఏం",
    "emo": "ఏమో",
    "telidu": "తెలీదు",
    "teleedu": "తెలీదు",
    "kada": "కద",
    "kooda": "కూడా",
    "koodaa": "కూడా",
    "nake": "నాకే",
    "naake": "నాకే",
    "neeke": "నీకే",
    "meeke": "మీకే",
    "maake": "మాకే",
    "ilaa": "ఇలా",
    "ilaage": "ఇలాగే",
    "ilage": "ఇలాగే",
    "ala": "అలా",
    "alaa": "అలా",
    "alane": "అలానే",
    "alaane": "అలానే",
    "eppudoo": "ఎప్పుడూ",
    "appudoo": "అప్పుడూ",
    "yellappudu": "యెల్లప్పుడూ",
    "yellappudoo": "యెల్లప్పుడూ",
    "ayyinda": "అయ్యిందా",
    "ayinda": "అయిందా",
    "chestunnav": "చేస్తున్నావ్",
    "padaku": "పడకు",
    "vachadu": "వచ్చాడు",
    "vachaadu": "వచ్చాడు",
    "vacchadu": "వచ్చాడు",
    "vacchaadu": "వచ్చాడు",
    "vasthundo": "వస్తుందో",
    "vastundo": "వస్తుందో",
    "pothundo": "పోతుందో",
    "potundo": "పోతుందో",
    "ko": "కో",
    "pada": "పద",
    "padaa": "పదా",
    "paduko": "పడుకో",
    "pettuko": "పెట్టుకో",
    "puchukunte": "పుచ్చుకుంటే",
    "chesko": "చేస్కో",
    "choosko": "చూస్కో",
    "veltunnavo": "వెళ్తున్నావో",
    "velthunnavo": "వెళ్తున్నావో",
    "lekunna": "లేకున్నా",
    "lekunnaa": "లేకున్నా",
    "lekapoina": "లేకపోయినా",
    "lekapoinaa": "లేకపోయినా",
    "lekapoyina": "లేకపోయినా",
    "poina": "పోయిన",
    "poinaa": "పోయినా",
    "sari": "సారి",
    "elagaina": "ఎలాగైనా",
    "elaagaina": "ఎలాగైనా",
    "sare": "సరే",
    "sarey": "సరే",
    "ivvana": "ఇవ్వనా",
    "ivvanaa": "ఇవ్వనా",
    "isthunna": "ఇస్తున్నా",
    "istunna": "ఇస్తున్నా",
    "ichi": "ఇచ్చి",
    "icchi": "ఇచ్చి",
    "ichanu": "ఇచ్చాను",
    "ichaanu": "ఇచ్చాను",
    "icchanu": "ఇచ్చాను",
    "icchaanu": "ఇచ్చాను",
    "ichindi": "ఇచ్చింది",
    "icchindi": "ఇచ్చింది",
    "puchindi": "పుచ్చింది",
    "pucchindi": "పుచ్చింది",
    "pichi": "పిచ్చి",
    "picchi": "పిచ్చి",
    "pachi": "పచ్చి",
    "pacchi": "పచ్చి",
    "ichana": "ఇచ్చిన",
    "vadiki": "వాడికి",
    "thondara": "తొందర"
]

for (roman, expected) in requiredExamples {
    expect(topCandidates(for: roman, limit: 1).first == expected, "\(roman) should rank \(expected) first")
}

var top1Hits = 0
var top3Hits = 0
for row in rows {
    let candidates = topCandidates(for: row.roman, limit: 3)
    if candidates.first == row.telugu {
        top1Hits += 1
    }
    if candidates.contains(row.telugu) {
        top3Hits += 1
    }
}

let top1Accuracy = rows.isEmpty ? 0 : Double(top1Hits) / Double(rows.count)
let top3Accuracy = rows.isEmpty ? 0 : Double(top3Hits) / Double(rows.count)
expect(top1Accuracy >= 0.90, String(format: "common chat top-1 accuracy %.2f should be >= 0.90", top1Accuracy))
expect(top3Accuracy >= 0.97, String(format: "common chat top-3 accuracy %.2f should be >= 0.97", top3Accuracy))

expect(transliteratePhrase("ela unnav") == "ఎలా ఉన్నావ్", "phrase ela unnav should rank naturally")
expect(transliteratePhrase("em chestunnav") == "ఏం చేస్తున్నావ్", "phrase em chestunnav should rank naturally")
expect(transliteratePhrase("bagundi kani ilaa") == "బాగుంది కానీ ఇలా", "phrase bagundi kani ilaa should rank naturally")
expect(transliteratePhrase("ala cheyyaku") == "అలా చెయ్యకు", "phrase ala cheyyaku should rank naturally")
expect(transliteratePhrase("yellappudoo alane") == "యెల్లప్పుడూ అలానే", "phrase yellappudoo alane should rank naturally")
expect(transliteratePhrase("ilaage undi") == "ఇలాగే ఉంది", "phrase ilaage undi should rank naturally")
expect(transliteratePhrase("ardham ayyinda") == "అర్థం అయ్యిందా", "phrase ardham ayyinda should rank naturally")
expect(transliteratePhrase("nenu vastunna") == "నేను వస్తున్నా", "phrase nenu vastunna should rank naturally")
expect(transliteratePhrase("vaadu vachadu") == "వాడు వచ్చాడు", "phrase vaadu vachadu should rank naturally")
expect(transliteratePhrase("inka entasepu") == "ఇంకా ఎంతసేపు", "phrase inka entasepu should rank naturally")
expect(transliteratePhrase("idi pothundo choodu") == "ఇది పోతుందో చూడు", "phrase idi pothundo choodu should rank naturally")
expect(transliteratePhrase("padaa kooda") == "పదా కూడా", "phrase padaa kooda should rank naturally")
expect(transliteratePhrase("paduko pettuko chesko choosko") == "పడుకో పెట్టుకో చేస్కో చూస్కో", "phrase ko endings should rank naturally")
expect(transliteratePhrase("nenu lekunna parledu") == "నేను లేకున్నా పర్లేదు", "phrase nenu lekunna parledu should rank naturally")
expect(transliteratePhrase("nenu lekapoina parledu") == "నేను లేకపోయినా పర్లేదు", "phrase nenu lekapoina parledu should rank naturally")
expect(transliteratePhrase("poina sari") == "పోయిన సారి", "phrase poina sari should rank naturally")
expect(transliteratePhrase("elagaina sare") == "ఎలాగైనా సరే", "phrase elagaina sare should rank naturally")
expect(transliteratePhrase("ichana vadiki") == "ఇచ్చిన వాడికి", "phrase ichana vadiki should rank naturally")
expect(transliteratePhrase("ivvana isthunna") == "ఇవ్వనా ఇస్తున్నా", "phrase ivvana isthunna should rank naturally")
expect(transliteratePhrase("vadiki ichi ichanu") == "వాడికి ఇచ్చి ఇచ్చాను", "phrase vadiki ichi ichanu should rank naturally")
expect(transliteratePhrase("adi ichindi puchindi") == "అది ఇచ్చింది పుచ్చింది", "phrase adi ichindi puchindi should rank naturally")
expect(transliteratePhrase("ichi pichi") == "ఇచ్చి పిచ్చి", "phrase ichi pichi should rank naturally")
expect(transliteratePhrase("pachi puchukunte") == "పచ్చి పుచ్చుకుంటే", "phrase pachi puchukunte should rank naturally")
expect(transliteratePhrase("naake kavali") == "నాకే కావాలి", "phrase naake kavali should rank naturally")

let forbiddenRuntimeTokens = ["URLSession", "https://"]
for sourceDirectory in ["Sources/TeluguKeyboardCore", "Sources/TeluguKeyboardIME"] {
    let sourceURL = projectRoot().appendingPathComponent(sourceDirectory)
    if let enumerator = FileManager.default.enumerator(at: sourceURL, includingPropertiesForKeys: nil) {
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            let contents = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
            for token in forbiddenRuntimeTokens {
                expect(contents.contains(token) == false, "Runtime source should not contain network token \(token) in \(fileURL.lastPathComponent)")
            }
        }
    }
}

assertReviewImportScriptBehavior()
assertCorrectionLedgerBehavior()

if failures.isEmpty {
    print(String(format: "Quality tests passed: %d rows, top-1 %.2f, top-3 %.2f", rows.count, top1Accuracy, top3Accuracy))
} else {
    print("Quality tests failed:")
    for failure in failures {
        print("- \(failure)")
    }
    exit(1)
}
