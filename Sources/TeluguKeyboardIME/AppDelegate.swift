@preconcurrency import AppKit
@preconcurrency import InputMethodKit
import os

final class AppDelegate: NSObject, NSApplicationDelegate {
    private static let log = Logger(subsystem: "org.telugukeyboard.inputmethod.TeluguKeyboard", category: "App")
    nonisolated(unsafe) static private(set) var shared: AppDelegate!

    private(set) var server: IMKServer!
    private(set) var candidatesWindow: IMKCandidates!

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self
        NSApp.setActivationPolicy(.accessory)
        Self.log.notice("TeluguKeyboard applicationDidFinishLaunching")
        NSLog("TeluguKeyboard applicationDidFinishLaunching")

        guard let connectionName = Bundle.main.object(forInfoDictionaryKey: "InputMethodConnectionName") as? String else {
            fatalError("Missing InputMethodConnectionName in Info.plist")
        }
        Self.log.notice("Starting IMKServer with connectionName=\(connectionName, privacy: .public)")
        NSLog("Starting IMKServer with connectionName=%@", connectionName)
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("Missing bundle identifier")
        }
        guard let server = IMKServer(name: connectionName, bundleIdentifier: bundleIdentifier) else {
            fatalError("Unable to start IMKServer")
        }

        self.server = server
        self.candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleColumnScrollingCandidatePanel)
        self.candidatesWindow.setAttributes([
            IMKCandidatesSendServerKeyEventFirst: NSNumber(value: true)
        ])
        Self.log.notice("IMKServer ready")
        NSLog("IMKServer ready")
    }

    func applicationWillTerminate(_ notification: Notification) {
        Self.log.notice("TeluguKeyboard applicationWillTerminate")
        server?.commitComposition(self)
    }
}
