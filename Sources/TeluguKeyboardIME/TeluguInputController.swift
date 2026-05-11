@preconcurrency import AppKit
import Carbon.HIToolbox
@preconcurrency import InputMethodKit
import os
import TeluguKeyboardCore

@objc(TeluguInputController)
final class TeluguInputController: IMKInputController {
    private static let log = Logger(subsystem: "org.telugukeyboard.inputmethod.TeluguKeyboard", category: "Controller")
    private let learningStore: UserLearningStore
    private let settingsStore: KeyboardSettingsStore
    private let personalizedTransliterator: TeluguTransliterator
    private let baseTransliterator: TeluguTransliterator
    private var settings: KeyboardSettings
    private var romanBuffer = ""
    private var currentCandidates: [Candidate] = []
    private var selectedCandidateIndex = 0
    private var passthroughMode = false
    private var committedRomanWords: [String] = []
    private var committedTeluguWords: [String] = []
    private let notFoundRange = NSRange(location: NSNotFound, length: NSNotFound)
    private let maxContextWords = 4

    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        let learningStore = UserLearningStore.defaultStore()
        let settingsStore = KeyboardSettingsStore.defaultStore()
        self.learningStore = learningStore
        self.settingsStore = settingsStore
        self.personalizedTransliterator = TeluguTransliterator(learningStore: learningStore)
        self.baseTransliterator = TeluguTransliterator(learningStore: nil)
        self.settings = settingsStore.load()
        super.init(server: server, delegate: delegate, client: inputClient)
        Self.log.notice("init controller clientType=\(String(describing: type(of: inputClient)), privacy: .public)")
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard event.type == .keyDown else { return false }
        Self.log.notice("handle keyCode=\(event.keyCode, privacy: .public) chars=\(event.charactersIgnoringModifiers ?? "nil", privacy: .public) modifiers=\(event.modifierFlags.rawValue, privacy: .public)")

        if isToggleEvent(event) {
            passthroughMode.toggle()
            Self.log.notice("toggle passthrough=\(self.passthroughMode, privacy: .public)")
            clearComposition(sender)
            return true
        }

        if passthroughMode {
            return false
        }

        if event.modifierFlags.intersection([.command, .option, .control]).isEmpty == false {
            return false
        }

        switch Int(event.keyCode) {
        case kVK_Delete:
            return handleBackspace(sender)
        case kVK_Escape:
            clearComposition(sender)
            return !romanBuffer.isEmpty
        case kVK_Return:
            return commitBestCandidate(sender, suffix: "\n")
        case kVK_DownArrow, kVK_RightArrow:
            return moveCandidate(delta: 1, sender: sender)
        case kVK_UpArrow, kVK_LeftArrow:
            return moveCandidate(delta: -1, sender: sender)
        default:
            break
        }

        guard let characters = event.charactersIgnoringModifiers, characters.count == 1 else {
            return false
        }

        return processText(characters, sender: sender)
    }

    override func inputText(_ string: String!, client sender: Any!) -> Bool {
        guard let string, !string.isEmpty else { return false }
        Self.log.notice("inputText string=\(string, privacy: .public)")
        var handledAny = false
        for character in string {
            handledAny = processText(String(character), sender: sender) || handledAny
        }
        return handledAny
    }

    override func didCommand(by aSelector: Selector!, client sender: Any!) -> Bool {
        Self.log.notice("didCommand selector=\(NSStringFromSelector(aSelector), privacy: .public)")
        switch aSelector {
        case #selector(NSResponder.deleteBackward(_:)):
            return handleBackspace(sender)
        case #selector(NSResponder.cancelOperation(_:)):
            let hadComposition = !romanBuffer.isEmpty
            clearComposition(sender)
            return hadComposition
        case #selector(NSResponder.insertNewline(_:)):
            return commitBestCandidate(sender, suffix: "\n")
        default:
            return false
        }
    }

    private func processText(_ characters: String, sender: Any!) -> Bool {
        Self.log.notice("processText chars=\(characters, privacy: .public) bufferBefore=\(self.romanBuffer, privacy: .public)")
        if let scalar = characters.unicodeScalars.first, CharacterSet.letters.contains(scalar) {
            romanBuffer.append(String(scalar).lowercased())
            if refreshComposition(sender) {
                Self.log.notice("processed letter bufferAfter=\(self.romanBuffer, privacy: .public)")
                return true
            }
            romanBuffer.removeLast()
            Self.log.error("refreshComposition failed; not swallowing letter")
            return false
        }

        if let scalar = characters.unicodeScalars.first, CharacterSet.whitespacesAndNewlines.contains(scalar) || CharacterSet.punctuationCharacters.contains(scalar) {
            if romanBuffer.isEmpty {
                return false
            }
            return commitBestCandidate(sender, suffix: characters)
        }

        return false
    }

    override func candidates(_ sender: Any!) -> [Any]! {
        currentCandidates.map(\.text)
    }

    override func menu() -> NSMenu! {
        reloadSettings()
        let menu = NSMenu(title: "Telugu Keyboard")

        let localLearningItem = NSMenuItem(
            title: "Use Local Learning",
            action: #selector(toggleLocalLearning(_:)),
            keyEquivalent: ""
        )
        localLearningItem.target = self
        localLearningItem.state = settings.localLearningEnabled ? .on : .off
        menu.addItem(localLearningItem)

        let privateModeItem = NSMenuItem(
            title: "Private Mode",
            action: #selector(togglePrivateMode(_:)),
            keyEquivalent: ""
        )
        privateModeItem.target = self
        privateModeItem.state = settings.privateModeEnabled ? .on : .off
        menu.addItem(privateModeItem)

        menu.addItem(NSMenuItem.separator())

        let clearLearningItem = NSMenuItem(
            title: "Clear Learned Words",
            action: #selector(clearLearnedWords(_:)),
            keyEquivalent: ""
        )
        clearLearningItem.target = self
        menu.addItem(clearLearningItem)

        return menu
    }

    override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
        guard let index = currentCandidates.firstIndex(where: { $0.text == candidateString.string }) else {
            return
        }
        selectedCandidateIndex = index
    }

    override func candidateSelected(_ candidateString: NSAttributedString!) {
        guard !candidateString.string.isEmpty else { return }
        let roman = romanBuffer
        let text = candidateString.string
        reloadSettings()
        let shouldLearn = settings.usesLocalLearning
        guard commit(text, sender: client()) else { return }
        if shouldLearn {
            personalizedTransliterator.learnExplicitSelection(roman: roman, candidateText: text)
        }
        recordCommittedWord(roman: roman, telugu: text)
    }

    override func deactivateServer(_ sender: Any!) {
        _ = commitBestCandidate(sender, suffix: "")
    }

    private func isToggleEvent(_ event: NSEvent) -> Bool {
        let hasControl = event.modifierFlags.contains(.control)
        return hasControl && event.charactersIgnoringModifiers?.lowercased() == "g"
    }

    private func handleBackspace(_ sender: Any!) -> Bool {
        guard !romanBuffer.isEmpty else { return false }
        romanBuffer.removeLast()
        if romanBuffer.isEmpty {
            clearComposition(sender)
        } else {
            return refreshComposition(sender)
        }
        return true
    }

    private func moveCandidate(delta: Int, sender: Any!) -> Bool {
        guard !currentCandidates.isEmpty else { return false }
        selectedCandidateIndex = (selectedCandidateIndex + delta + currentCandidates.count) % currentCandidates.count
        guard setMarkedText(currentCandidates[selectedCandidateIndex].text, sender: sender) else {
            return false
        }
        showCandidatesWindow()
        return true
    }

    private func refreshComposition(_ sender: Any!) -> Bool {
        currentCandidates = activeTransliterator().candidates(for: romanBuffer, context: transliterationContext, limit: 8)
        selectedCandidateIndex = 0
        let markedText = currentCandidates.first?.text ?? romanBuffer
        Self.log.notice("refreshComposition buffer=\(self.romanBuffer, privacy: .public) marked=\(markedText, privacy: .public) candidateCount=\(self.currentCandidates.count, privacy: .public)")
        guard setMarkedText(markedText, sender: sender) else {
            currentCandidates.removeAll(keepingCapacity: true)
            return false
        }

        if currentCandidates.count > 1 {
            showCandidatesWindow()
        } else {
            hideCandidatesWindow()
        }
        return true
    }

    private func commitBestCandidate(_ sender: Any!, suffix: String) -> Bool {
        guard !romanBuffer.isEmpty else { return false }
        let committedRoman = romanBuffer
        let transliterator = activeTransliterator()
        let shouldLearn = settings.usesLocalLearning
        let candidateText = currentCandidates.indices.contains(selectedCandidateIndex)
            ? currentCandidates[selectedCandidateIndex].text
            : transliterator.candidates(for: romanBuffer, context: transliterationContext, limit: 1).first?.text ?? romanBuffer
        Self.log.notice("commitBestCandidate buffer=\(self.romanBuffer, privacy: .public) candidate=\(candidateText, privacy: .public) suffix=\(suffix, privacy: .public)")
        guard commit(candidateText + suffix, sender: sender) else {
            return false
        }
        if shouldLearn {
            personalizedTransliterator.learnDefaultAccept(roman: committedRoman, candidateText: candidateText)
        }
        recordCommittedWord(roman: committedRoman, telugu: candidateText)
        return true
    }

    @discardableResult
    private func commit(_ text: String, sender: Any!) -> Bool {
        guard let inputClient = inputClient(from: sender) else {
            Self.log.error("commit failed: no IMKTextInput client")
            return false
        }
        Self.log.notice("insertText text=\(text, privacy: .public)")
        inputClient.insertText(text, replacementRange: notFoundRange)
        romanBuffer.removeAll(keepingCapacity: true)
        currentCandidates.removeAll(keepingCapacity: true)
        selectedCandidateIndex = 0
        hideCandidatesWindow()
        return true
    }

    private func clearComposition(_ sender: Any!) {
        if let inputClient = inputClient(from: sender) {
            inputClient.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: notFoundRange)
        }
        romanBuffer.removeAll(keepingCapacity: true)
        currentCandidates.removeAll(keepingCapacity: true)
        selectedCandidateIndex = 0
        hideCandidatesWindow()
    }

    private func setMarkedText(_ text: String, sender: Any!) -> Bool {
        guard let inputClient = inputClient(from: sender) else {
            Self.log.error("setMarkedText failed: no IMKTextInput client")
            return false
        }
        let attributes = mark(forStyle: kTSMHiliteConvertedText, at: inputClient.selectedRange()) as? [NSAttributedString.Key: Any] ?? [:]
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes(attributes, range: NSRange(location: 0, length: attributedText.length))
        Self.log.notice("setMarkedText text=\(text, privacy: .public) selectedRange=\(NSStringFromRange(inputClient.selectedRange()), privacy: .public)")
        inputClient.setMarkedText(attributedText, selectionRange: NSRange(location: attributedText.length, length: 0), replacementRange: notFoundRange)
        return true
    }

    private var candidatesWindow: IMKCandidates? {
        AppDelegate.shared?.candidatesWindow
    }

    private var transliterationContext: TransliterationContext {
        TransliterationContext(previousRomanWords: committedRomanWords, previousTeluguWords: committedTeluguWords)
    }

    private func activeTransliterator() -> TeluguTransliterator {
        reloadSettings()
        return settings.usesLocalLearning ? personalizedTransliterator : baseTransliterator
    }

    private func reloadSettings() {
        settings = settingsStore.load()
    }

    @objc private func toggleLocalLearning(_ sender: Any?) {
        settings = settingsStore.update { settings in
            settings.localLearningEnabled.toggle()
        }
        refreshCompositionAfterSettingsChange()
    }

    @objc private func togglePrivateMode(_ sender: Any?) {
        settings = settingsStore.update { settings in
            settings.privateModeEnabled.toggle()
        }
        refreshCompositionAfterSettingsChange()
    }

    @objc private func clearLearnedWords(_ sender: Any?) {
        learningStore.removeAll()
        refreshCompositionAfterSettingsChange()
    }

    private func refreshCompositionAfterSettingsChange() {
        guard !romanBuffer.isEmpty else { return }
        _ = refreshComposition(client())
    }

    private func recordCommittedWord(roman: String, telugu: String) {
        let normalizedRoman = RomanNormalizer.normalize(roman)
        guard normalizedRoman.isEmpty == false, telugu.isEmpty == false else { return }
        committedRomanWords.append(normalizedRoman)
        committedTeluguWords.append(telugu)
        if committedRomanWords.count > maxContextWords {
            committedRomanWords.removeFirst(committedRomanWords.count - maxContextWords)
        }
        if committedTeluguWords.count > maxContextWords {
            committedTeluguWords.removeFirst(committedTeluguWords.count - maxContextWords)
        }
    }

    private func inputClient(from sender: Any!) -> IMKTextInput? {
        if let inputClient = sender as? IMKTextInput {
            return inputClient
        }
        return client()
    }

    private func showCandidatesWindow() {
        guard let window = candidatesWindow else { return }
        MainActor.assumeIsolated {
            window.update()
            window.show()
        }
    }

    private func hideCandidatesWindow() {
        guard let window = candidatesWindow else { return }
        MainActor.assumeIsolated {
            window.hide()
        }
    }
}
