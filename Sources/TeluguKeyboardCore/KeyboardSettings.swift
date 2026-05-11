import Foundation

public struct KeyboardSettings: Codable, Equatable, Sendable {
    public var localLearningEnabled: Bool
    public var privateModeEnabled: Bool

    public init(localLearningEnabled: Bool = true, privateModeEnabled: Bool = false) {
        self.localLearningEnabled = localLearningEnabled
        self.privateModeEnabled = privateModeEnabled
    }

    public var usesLocalLearning: Bool {
        localLearningEnabled && !privateModeEnabled
    }
}

public final class KeyboardSettingsStore {
    private let url: URL?

    public static func defaultStore() -> KeyboardSettingsStore {
        let base = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/TeluguKeyboard", isDirectory: true)
        return KeyboardSettingsStore(url: base.appendingPathComponent("settings.json"))
    }

    public init(url: URL?) {
        self.url = url
    }

    public func load() -> KeyboardSettings {
        guard let url, let data = try? Data(contentsOf: url) else {
            return KeyboardSettings()
        }
        return (try? JSONDecoder().decode(KeyboardSettings.self, from: data)) ?? KeyboardSettings()
    }

    public func save(_ settings: KeyboardSettings) {
        guard let url else { return }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(settings)
            try data.write(to: url, options: [.atomic])
        } catch {
            // Settings should never prevent the input method from working.
        }
    }

    @discardableResult
    public func update(_ transform: (inout KeyboardSettings) -> Void) -> KeyboardSettings {
        var settings = load()
        transform(&settings)
        save(settings)
        return settings
    }
}
