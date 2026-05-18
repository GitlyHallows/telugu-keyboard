import Foundation
import TeluguKeyboardCore

var failures: [String] = []

@MainActor
func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        failures.append(message)
    }
}

let transliterator = TeluguTransliterator(learningStore: nil)

@MainActor
func topCandidate(for roman: String) -> String? {
    transliterator.candidates(for: roman, limit: 1, includePassthrough: false).first?.text
}

@MainActor
func texts(for roman: String, limit: Int) -> [String] {
    transliterator.candidates(for: roman, limit: limit, includePassthrough: false).map(\.text)
}

expect(topCandidate(for: "padaku") == "పడకు", "padaku should rank పడకు first")
expect(topCandidate(for: "thondara") == "తొందర", "thondara should rank తొందర first")
expect(topCandidate(for: "telugu") == "తెలుగు", "telugu should rank తెలుగు first")
expect(topCandidate(for: "thelugu") == "తెలుగు", "thelugu should rank తెలుగు first")

expect(topCandidate(for: "amma") == "అమ్మ", "amma should rank అమ్మ first")
expect(topCandidate(for: "bagunnara") == "బాగున్నారా", "bagunnara should rank బాగున్నారా first")
expect(topCandidate(for: "enduku") == "ఎందుకు", "enduku should rank ఎందుకు first")
expect(topCandidate(for: "avunu") == "అవును", "avunu should rank అవును first")
expect(topCandidate(for: "em") == "ఏం", "em should rank ఏం first")
expect(topCandidate(for: "emo") == "ఏమో", "emo should rank ఏమో first")
expect(topCandidate(for: "nake") == "నాకే", "nake should rank నాకే first")
expect(topCandidate(for: "naake") == "నాకే", "naake should rank నాకే first")
expect(topCandidate(for: "neeke") == "నీకే", "neeke should rank నీకే first")
expect(topCandidate(for: "meeke") == "మీకే", "meeke should rank మీకే first")
expect(topCandidate(for: "maake") == "మాకే", "maake should rank మాకే first")
expect(topCandidate(for: "ilaa") == "ఇలా", "ilaa should rank ఇలా first")
expect(topCandidate(for: "ilaage") == "ఇలాగే", "ilaage should rank ఇలాగే first")
expect(topCandidate(for: "ilage") == "ఇలాగే", "ilage should rank ఇలాగే first")
expect(topCandidate(for: "ala") == "అలా", "ala should rank అలా first")
expect(topCandidate(for: "alaa") == "అలా", "alaa should rank అలా first")
expect(topCandidate(for: "alane") == "అలానే", "alane should rank అలానే first")
expect(topCandidate(for: "alaane") == "అలానే", "alaane should rank అలానే first")
expect(topCandidate(for: "eppudoo") == "ఎప్పుడూ", "eppudoo should rank ఎప్పుడూ first")
expect(topCandidate(for: "appudoo") == "అప్పుడూ", "appudoo should rank అప్పుడూ first")
expect(topCandidate(for: "yellappudu") == "యెల్లప్పుడూ", "yellappudu should rank యెల్లప్పుడూ first")
expect(topCandidate(for: "yellappudoo") == "యెల్లప్పుడూ", "yellappudoo should rank యెల్లప్పుడూ first")
expect(topCandidate(for: "ayyinda") == "అయ్యిందా", "ayyinda should rank అయ్యిందా first")
expect(topCandidate(for: "ayinda") == "అయిందా", "ayinda should rank అయిందా first")
expect(topCandidate(for: "chestunnav") == "చేస్తున్నావ్", "chestunnav should rank చేస్తున్నావ్ first")
expect(topCandidate(for: "unnav") == "ఉన్నావ్", "unnav should rank ఉన్నావ్ first")
expect(topCandidate(for: "unnavu") == "ఉన్నావు", "unnavu should rank ఉన్నావు first")
expect(topCandidate(for: "unnaru") == "ఉన్నారు", "unnaru should rank ఉన్నారు first")
expect(topCandidate(for: "unnava") == "ఉన్నావా", "unnava should rank ఉన్నావా first")
expect(topCandidate(for: "bagunnava") == "బాగున్నావా", "bagunnava should rank బాగున్నావా first")
expect(topCandidate(for: "parledu") == "పర్లేదు", "parledu should rank పర్లేదు first")
expect(topCandidate(for: "parledhu") == "పర్లేదు", "parledhu should rank పర్లేదు first")
expect(topCandidate(for: "thindi") == "తిండి", "thindi should rank తిండి first")
expect(topCandidate(for: "kooda") == "కూడా", "kooda should rank కూడా first")
expect(topCandidate(for: "koodaa") == "కూడా", "koodaa should rank కూడా first")
expect(topCandidate(for: "kada") == "కద", "kada should rank కద first")
expect(topCandidate(for: "potunattlu") == "పొతున్నట్లు", "potunattlu should rank పొతున్నట్లు first")
expect(topCandidate(for: "pothunatlu") == "పొతున్నట్లు", "pothunatlu should rank పొతున్నట్లు first")
expect(topCandidate(for: "entasepu") == "ఎంతసేపు", "entasepu should rank ఎంతసేపు first")
expect(topCandidate(for: "enthasepu") == "ఎంతసేపు", "enthasepu should rank ఎంతసేపు first")
expect(topCandidate(for: "inthena") == "ఇంతేనా", "inthena should rank ఇంతేనా first")
expect(topCandidate(for: "inthenaa") == "ఇంతేనా", "inthenaa should rank ఇంతేనా first")
expect(topCandidate(for: "vachadu") == "వచ్చాడు", "vachadu should rank వచ్చాడు first")
expect(topCandidate(for: "vachaadu") == "వచ్చాడు", "vachaadu should rank వచ్చాడు first")
expect(topCandidate(for: "vacchadu") == "వచ్చాడు", "vacchadu should rank వచ్చాడు first")
expect(topCandidate(for: "vacchaadu") == "వచ్చాడు", "vacchaadu should rank వచ్చాడు first")
expect(topCandidate(for: "vasthundo") == "వస్తుందో", "vasthundo should rank వస్తుందో first")
expect(topCandidate(for: "vastundo") == "వస్తుందో", "vastundo should rank వస్తుందో first")
expect(topCandidate(for: "pothundo") == "పోతుందో", "pothundo should rank పోతుందో first")
expect(topCandidate(for: "potundo") == "పోతుందో", "potundo should rank పోతుందో first")
expect(topCandidate(for: "ko") == "కో", "ko should rank కో first")
expect(topCandidate(for: "pada") == "పద", "pada should rank పద first")
expect(topCandidate(for: "padaa") == "పదా", "padaa should rank పదా first")
expect(topCandidate(for: "paduko") == "పడుకో", "paduko should rank పడుకో first")
expect(topCandidate(for: "pettuko") == "పెట్టుకో", "pettuko should rank పెట్టుకో first")
expect(topCandidate(for: "puchukunte") == "పుచ్చుకుంటే", "puchukunte should rank పుచ్చుకుంటే first")
expect(topCandidate(for: "chesko") == "చేస్కో", "chesko should rank చేస్కో first")
expect(topCandidate(for: "choosko") == "చూస్కో", "choosko should rank చూస్కో first")
expect(topCandidate(for: "veltunnavo") == "వెళ్తున్నావో", "veltunnavo should rank వెళ్తున్నావో first")
expect(topCandidate(for: "velthunnavo") == "వెళ్తున్నావో", "velthunnavo should rank వెళ్తున్నావో first")
expect(topCandidate(for: "lekunna") == "లేకున్నా", "lekunna should rank లేకున్నా first")
expect(topCandidate(for: "lekunnaa") == "లేకున్నా", "lekunnaa should rank లేకున్నా first")
expect(topCandidate(for: "lekapoina") == "లేకపోయినా", "lekapoina should rank లేకపోయినా first")
expect(topCandidate(for: "lekapoinaa") == "లేకపోయినా", "lekapoinaa should rank లేకపోయినా first")
expect(topCandidate(for: "lekapoyina") == "లేకపోయినా", "lekapoyina should rank లేకపోయినా first")
expect(topCandidate(for: "poina") == "పోయిన", "poina should rank పోయిన first")
expect(topCandidate(for: "poinaa") == "పోయినా", "poinaa should rank పోయినా first")
expect(topCandidate(for: "sari") == "సారి", "sari should rank సారి first")
expect(topCandidate(for: "elagaina") == "ఎలాగైనా", "elagaina should rank ఎలాగైనా first")
expect(topCandidate(for: "elaagaina") == "ఎలాగైనా", "elaagaina should rank ఎలాగైనా first")
expect(topCandidate(for: "sare") == "సరే", "sare should rank సరే first")
expect(topCandidate(for: "sarey") == "సరే", "sarey should rank సరే first")
expect(topCandidate(for: "ivvana") == "ఇవ్వనా", "ivvana should rank ఇవ్వనా first")
expect(topCandidate(for: "ivvanaa") == "ఇవ్వనా", "ivvanaa should rank ఇవ్వనా first")
expect(topCandidate(for: "isthunna") == "ఇస్తున్నా", "isthunna should rank ఇస్తున్నా first")
expect(topCandidate(for: "istunna") == "ఇస్తున్నా", "istunna should rank ఇస్తున్నా first")
expect(topCandidate(for: "ichi") == "ఇచ్చి", "ichi should rank ఇచ్చి first")
expect(topCandidate(for: "icchi") == "ఇచ్చి", "icchi should rank ఇచ్చి first")
expect(topCandidate(for: "ichanu") == "ఇచ్చాను", "ichanu should rank ఇచ్చాను first")
expect(topCandidate(for: "ichaanu") == "ఇచ్చాను", "ichaanu should rank ఇచ్చాను first")
expect(topCandidate(for: "icchanu") == "ఇచ్చాను", "icchanu should rank ఇచ్చాను first")
expect(topCandidate(for: "icchaanu") == "ఇచ్చాను", "icchaanu should rank ఇచ్చాను first")
expect(topCandidate(for: "ichindi") == "ఇచ్చింది", "ichindi should rank ఇచ్చింది first")
expect(topCandidate(for: "icchindi") == "ఇచ్చింది", "icchindi should rank ఇచ్చింది first")
expect(topCandidate(for: "puchindi") == "పుచ్చింది", "puchindi should rank పుచ్చింది first")
expect(topCandidate(for: "pucchindi") == "పుచ్చింది", "pucchindi should rank పుచ్చింది first")
expect(topCandidate(for: "pichi") == "పిచ్చి", "pichi should rank పిచ్చి first")
expect(topCandidate(for: "picchi") == "పిచ్చి", "picchi should rank పిచ్చి first")
expect(topCandidate(for: "pachi") == "పచ్చి", "pachi should rank పచ్చి first")
expect(topCandidate(for: "pacchi") == "పచ్చి", "pacchi should rank పచ్చి first")
expect(topCandidate(for: "ichana") == "ఇచ్చిన", "ichana should rank ఇచ్చిన first")
expect(topCandidate(for: "vadiki") == "వాడికి", "vadiki should rank వాడికి first")
let poinaCandidates = texts(for: "poina", limit: 3)
expect(poinaCandidates.prefix(2).elementsEqual(["పోయిన", "పోయినా"]), "poina should offer పోయిన then పోయినా")
let kadaCandidates = texts(for: "kada", limit: 3)
expect(kadaCandidates.prefix(2).elementsEqual(["కద", "కదా"]), "kada should offer కద then కదా")
let ichiCandidates = texts(for: "ichi", limit: 3)
expect(ichiCandidates.prefix(2).elementsEqual(["ఇచ్చి", "ఇచి"]), "ichi should offer ఇచ్చి then ఇచి")
let pichiCandidates = texts(for: "pichi", limit: 3)
expect(pichiCandidates.prefix(2).elementsEqual(["పిచ్చి", "పిచి"]), "pichi should offer పిచ్చి then పిచి")
let padaaCandidates = texts(for: "padaa", limit: 3)
expect(padaaCandidates.prefix(2).elementsEqual(["పదా", "పద"]), "padaa should offer పదా then పద")
let ichanaCandidates = texts(for: "ichana", limit: 4)
expect(ichanaCandidates.prefix(3).elementsEqual(["ఇచ్చిన", "ఇచ్చినా", "ఇచ్చానా"]), "ichana should offer ఇచ్చిన, ఇచ్చినా, then ఇచ్చానా")

let contextual = TeluguTransliterator(learningStore: nil)
let elaContext = TransliterationContext(previousRomanWords: ["ela"], previousTeluguWords: ["ఎలా"])
expect(
    contextual.candidates(for: "unnav", context: elaContext, limit: 1, includePassthrough: false).first?.text == "ఉన్నావ్",
    "context ela + unnav should rank ఎలా ఉన్నావ్ naturally"
)
let emContext = TransliterationContext(previousRomanWords: ["em"], previousTeluguWords: ["ఏం"])
expect(
    contextual.candidates(for: "chestunnav", context: emContext, limit: 1, includePassthrough: false).first?.text == "చేస్తున్నావ్",
    "context em + chestunnav should rank ఏం చేస్తున్నావ్ naturally"
)

let taCandidates = texts(for: "ta", limit: 10)
expect(taCandidates.contains("త"), "ta should include త")
expect(taCandidates.contains("ట"), "ta should include ట")

let daCandidates = texts(for: "da", limit: 10)
expect(daCandidates.contains("ద"), "da should include ద")
expect(daCandidates.contains("డ"), "da should include డ")

let thaCandidates = texts(for: "tha", limit: 10)
expect(thaCandidates.contains("త"), "tha should include త")
expect(thaCandidates.contains("థ"), "tha should include థ")
expect(thaCandidates.contains("ఠ"), "tha should include ఠ")

let rulesOnly = TeluguTransliterator(providers: [RuleBasedCandidateProvider()], learningStore: nil)
expect(rulesOnly.candidates(for: "amma", limit: 1, includePassthrough: false).first?.text == "అమ్మ", "rule engine should compose amma")
expect(rulesOnly.candidates(for: "thondara", limit: 1, includePassthrough: false).first?.text == "తొందర", "rule engine should compose thondara")
expect(rulesOnly.candidates(for: "ilaa", limit: 1, includePassthrough: false).first?.text == "ఇలా", "rule engine should prefer ఇలా over ఇలఅ")

let suffixOnly = TeluguTransliterator(providers: [CommonChatSuffixCandidateProvider()], learningStore: nil)
expect(suffixOnly.candidates(for: "vasthundo", limit: 1, includePassthrough: false).first?.text == "వస్తుందో", "suffix provider should compose vasthundo")
expect(suffixOnly.candidates(for: "pothundo", limit: 1, includePassthrough: false).first?.text == "పోతుందో", "suffix provider should compose pothundo")
expect(suffixOnly.candidates(for: "ko", limit: 1, includePassthrough: false).first?.text == "కో", "suffix provider should compose bare ko")
expect(suffixOnly.candidates(for: "pettuko", limit: 1, includePassthrough: false).first?.text == "పెట్టుకో", "suffix provider should compose pettuko")
expect(suffixOnly.candidates(for: "chesko", limit: 1, includePassthrough: false).first?.text == "చేస్కో", "suffix provider should compose chesko")
expect(suffixOnly.candidates(for: "choosko", limit: 1, includePassthrough: false).first?.text == "చూస్కో", "suffix provider should compose choosko")
expect(suffixOnly.candidates(for: "veltunnavo", limit: 1, includePassthrough: false).first?.text == "వెళ్తున్నావో", "suffix provider should compose veltunnavo")
expect(suffixOnly.candidates(for: "velthunnavo", limit: 1, includePassthrough: false).first?.text == "వెళ్తున్నావో", "suffix provider should compose velthunnavo")
expect(suffixOnly.candidates(for: "lekunna", limit: 1, includePassthrough: false).first?.text == "లేకున్నా", "suffix provider should compose lekunna")
expect(suffixOnly.candidates(for: "lekunnaa", limit: 1, includePassthrough: false).first?.text == "లేకున్నా", "suffix provider should compose lekunnaa")
expect(suffixOnly.candidates(for: "vastunna", limit: 1, includePassthrough: false).first?.text == "వస్తున్నా", "suffix provider should compose final nna as న్నా")
expect(suffixOnly.candidates(for: "lekapoina", limit: 1, includePassthrough: false).first?.text == "లేకపోయినా", "suffix provider should compose lekapoina")
expect(suffixOnly.candidates(for: "lekapoinaa", limit: 1, includePassthrough: false).first?.text == "లేకపోయినా", "suffix provider should compose lekapoinaa")
expect(suffixOnly.candidates(for: "poina", limit: 1, includePassthrough: false).first?.text == "పోయిన", "suffix provider should prefer bare poina as పోయిన")
expect(suffixOnly.candidates(for: "poina", limit: 2, includePassthrough: false).map(\.text).contains("పోయినా"), "suffix provider should still offer పోయినా for poina")
expect(suffixOnly.candidates(for: "poinaa", limit: 1, includePassthrough: false).first?.text == "పోయినా", "suffix provider should compose bare poinaa")
expect(suffixOnly.candidates(for: "elagaina", limit: 1, includePassthrough: false).first?.text == "ఎలాగైనా", "suffix provider should compose elagaina")
expect(suffixOnly.candidates(for: "elaagaina", limit: 1, includePassthrough: false).first?.text == "ఎలాగైనా", "suffix provider should compose elaagaina")
expect(suffixOnly.candidates(for: "isthunna", limit: 1, includePassthrough: false).first?.text == "ఇస్తున్నా", "suffix provider should compose isthunna")
expect(suffixOnly.candidates(for: "istunna", limit: 1, includePassthrough: false).first?.text == "ఇస్తున్నా", "suffix provider should compose istunna")

let patternOnly = TeluguTransliterator(providers: [ConversationalPatternCandidateProvider()], learningStore: nil)
expect(patternOnly.candidates(for: "nake", limit: 1, includePassthrough: false).first?.text == "నాకే", "pattern provider should compose nake")
expect(patternOnly.candidates(for: "naake", limit: 1, includePassthrough: false).first?.text == "నాకే", "pattern provider should compose naake")
expect(patternOnly.candidates(for: "neeke", limit: 1, includePassthrough: false).first?.text == "నీకే", "pattern provider should compose neeke")
expect(patternOnly.candidates(for: "meeke", limit: 1, includePassthrough: false).first?.text == "మీకే", "pattern provider should compose meeke")
expect(patternOnly.candidates(for: "maake", limit: 1, includePassthrough: false).first?.text == "మాకే", "pattern provider should compose maake")
expect(patternOnly.candidates(for: "make", limit: 1, includePassthrough: false).isEmpty, "pattern provider should not transliterate English make as మాకే")
expect(patternOnly.candidates(for: "ichindi", limit: 1, includePassthrough: false).first?.text == "ఇచ్చింది", "pattern provider should compose ichindi")
expect(patternOnly.candidates(for: "icchindi", limit: 1, includePassthrough: false).first?.text == "ఇచ్చింది", "pattern provider should compose icchindi")
expect(patternOnly.candidates(for: "ichanu", limit: 1, includePassthrough: false).first?.text == "ఇచ్చాను", "pattern provider should compose ichanu")
expect(patternOnly.candidates(for: "ichaanu", limit: 1, includePassthrough: false).first?.text == "ఇచ్చాను", "pattern provider should compose ichaanu")
expect(patternOnly.candidates(for: "icchanu", limit: 1, includePassthrough: false).first?.text == "ఇచ్చాను", "pattern provider should compose icchanu")
expect(patternOnly.candidates(for: "icchaanu", limit: 1, includePassthrough: false).first?.text == "ఇచ్చాను", "pattern provider should compose icchaanu")
expect(patternOnly.candidates(for: "puchindi", limit: 1, includePassthrough: false).first?.text == "పుచ్చింది", "pattern provider should compose puchindi")
expect(patternOnly.candidates(for: "pucchindi", limit: 1, includePassthrough: false).first?.text == "పుచ్చింది", "pattern provider should compose pucchindi")
expect(patternOnly.candidates(for: "eppudoo", limit: 1, includePassthrough: false).first?.text == "ఎప్పుడూ", "pattern provider should compose eppudoo")
expect(patternOnly.candidates(for: "appudoo", limit: 1, includePassthrough: false).first?.text == "అప్పుడూ", "pattern provider should compose appudoo")
expect(patternOnly.candidates(for: "ippudu", limit: 1, includePassthrough: false).first?.text == "ఇప్పుడు", "pattern provider should compose ippudu")

let store = UserLearningStore(url: nil)
store.learnExplicitSelection(roman: "ta", candidateText: "ట")
let learned = TeluguTransliterator(learningStore: store)
expect(learned.candidates(for: "ta", limit: 1, includePassthrough: false).first?.text == "ట", "learned candidate should override default ranking")

let weakStore = UserLearningStore(url: nil)
weakStore.learnDefaultAccept(roman: "unnav", candidateText: "ఉంనవ")
let weakLearned = TeluguTransliterator(learningStore: weakStore)
expect(
    weakLearned.candidates(for: "unnav", limit: 1, includePassthrough: false).first?.text == "ఉన్నావ్",
    "default accepts should not immediately outrank common chat defaults"
)

let weakRuleStore = UserLearningStore(url: nil)
weakRuleStore.learnDefaultAccept(roman: "ta", candidateText: "డ")
let weakRuleLearned = TeluguTransliterator(learningStore: weakRuleStore)
expect(
    weakRuleLearned.candidates(for: "ta", limit: 1, includePassthrough: false).first?.text == "త",
    "default accepts should not act like strong candidate selections"
)

let strongStore = UserLearningStore(url: nil)
strongStore.learnExplicitSelection(roman: "unnav", candidateText: "ఉంనవ")
strongStore.learnExplicitSelection(roman: "unnav", candidateText: "ఉంనవ")
let strongLearned = TeluguTransliterator(learningStore: strongStore)
expect(
    strongLearned.candidates(for: "unnav", limit: 1, includePassthrough: false).first?.text == "ఉంనవ",
    "repeated explicit selections should outrank common chat defaults"
)

let provisionalStore = UserLearningStore(url: nil)
provisionalStore.learnExplicitSelection(roman: "parledu", candidateText: "పర్లెదు")
let provisionalLearned = TeluguTransliterator(learningStore: provisionalStore)
expect(
    provisionalLearned.candidates(for: "parledu", limit: 1, includePassthrough: false).first?.text == "పర్లేదు",
    "one accidental explicit selection should not outrank a high-confidence common chat correction"
)

let privateSettings = KeyboardSettings(localLearningEnabled: true, privateModeEnabled: true)
expect(privateSettings.usesLocalLearning == false, "private mode should disable learned ranking")
expect(
    (privateSettings.usesLocalLearning ? learned : transliterator).candidates(for: "ta", limit: 1, includePassthrough: false).first?.text == "త",
    "private mode should ignore learned candidates"
)

let disabledLearningSettings = KeyboardSettings(localLearningEnabled: false, privateModeEnabled: false)
expect(disabledLearningSettings.usesLocalLearning == false, "disabled local learning should disable learned ranking")
let blockedStore = UserLearningStore(url: nil)
if disabledLearningSettings.usesLocalLearning {
    blockedStore.learnExplicitSelection(roman: "ta", candidateText: "ట")
}
let blockedLearned = TeluguTransliterator(learningStore: blockedStore)
expect(
    blockedLearned.candidates(for: "ta", limit: 1, includePassthrough: false).first?.text == "త",
    "disabled local learning should block new learning writes"
)

let settingsURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("telugu-keyboard-settings-\(UUID().uuidString).json")
let settingsStore = KeyboardSettingsStore(url: settingsURL)
expect(settingsStore.load() == KeyboardSettings(), "missing settings file should load defaults")
settingsStore.save(KeyboardSettings(localLearningEnabled: false, privateModeEnabled: false))
expect(settingsStore.load().localLearningEnabled == false, "settings should persist local learning")
let updatedSettings = settingsStore.update { settings in
    settings.privateModeEnabled = true
}
expect(updatedSettings.privateModeEnabled == true, "settings update should return updated value")
expect(settingsStore.load().privateModeEnabled == true, "settings update should persist")
try? FileManager.default.removeItem(at: settingsURL)

let removableLearningURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("telugu-keyboard-learning-\(UUID().uuidString).json")
let removableStore = UserLearningStore(url: removableLearningURL)
removableStore.learnExplicitSelection(roman: "ta", candidateText: "ట")
expect(FileManager.default.fileExists(atPath: removableLearningURL.path), "learning file should exist after learning")
expect(
    TeluguTransliterator(learningStore: removableStore).candidates(for: "ta", limit: 1, includePassthrough: false).first?.text == "ట",
    "learned entry should rank before clear"
)
removableStore.removeAll()
expect(FileManager.default.fileExists(atPath: removableLearningURL.path) == false, "removeAll should delete learning file")
expect(
    TeluguTransliterator(learningStore: removableStore).candidates(for: "ta", limit: 1, includePassthrough: false).first?.text == "త",
    "removeAll should clear in-memory learned entries"
)

let legacyURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("telugu-keyboard-legacy-learning-\(UUID().uuidString).json")
let legacyData = try JSONEncoder().encode(["ta": ["ట": 2]])
try legacyData.write(to: legacyURL)
let legacyStore = UserLearningStore(url: legacyURL)
let legacyLearned = TeluguTransliterator(learningStore: legacyStore)
expect(
    legacyLearned.candidates(for: "ta", limit: 1, includePassthrough: false).first?.text == "ట",
    "legacy learning JSON should load as explicit selections"
)
try? FileManager.default.removeItem(at: legacyURL)

if failures.isEmpty {
    print("Smoke tests passed")
} else {
    print("Smoke tests failed:")
    for failure in failures {
        print("- \(failure)")
    }
    exit(1)
}
