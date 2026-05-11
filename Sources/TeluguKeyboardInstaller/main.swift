import Carbon.HIToolbox
import Foundation

private let bundleIdentifier = "org.telugukeyboard.inputmethod.TeluguKeyboard"

private struct InputSource {
    let reference: TISInputSource
    let sourceID: String
    let bundleID: String
    let localizedName: String
    let kind: String
    let isEnabled: Bool
    let isSelected: Bool
    let isEnableCapable: Bool
}

private enum ExitCode: Int32 {
    case ok = 0
    case usage = 2
    case runtimeFailure = 3
}

private func objectProperty(_ source: TISInputSource, _ key: CFString) -> AnyObject? {
    guard let pointer = TISGetInputSourceProperty(source, key) else {
        return nil
    }
    return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
}

private func stringProperty(_ source: TISInputSource, _ key: CFString) -> String {
    objectProperty(source, key) as? String ?? ""
}

private func boolProperty(_ source: TISInputSource, _ key: CFString) -> Bool {
    guard let value = objectProperty(source, key) else {
        return false
    }
    if CFGetTypeID(value) == CFBooleanGetTypeID() {
        return CFBooleanGetValue((value as! CFBoolean))
    }
    return (value as? NSNumber)?.boolValue ?? false
}

private func allInputSources(includeAllInstalled: Bool = true) -> [InputSource] {
    guard let sources = TISCreateInputSourceList(nil, includeAllInstalled)?.takeRetainedValue() as? [TISInputSource] else {
        return []
    }
    return sources.map { source in
        InputSource(
            reference: source,
            sourceID: stringProperty(source, kTISPropertyInputSourceID),
            bundleID: stringProperty(source, kTISPropertyBundleID),
            localizedName: stringProperty(source, kTISPropertyLocalizedName),
            kind: stringProperty(source, kTISPropertyInputSourceType),
            isEnabled: boolProperty(source, kTISPropertyInputSourceIsEnabled),
            isSelected: boolProperty(source, kTISPropertyInputSourceIsSelected),
            isEnableCapable: boolProperty(source, kTISPropertyInputSourceIsEnableCapable)
        )
    }
}

private func teluguKeyboardSources() -> [InputSource] {
    allInputSources().filter { source in
        source.bundleID == bundleIdentifier || source.sourceID == bundleIdentifier
    }
}

private func registerInputMethod(at path: String) -> Bool {
    let url = URL(fileURLWithPath: path)
    let status = TISRegisterInputSource(url as CFURL)
    if status == noErr {
        print("Registered: \(path)")
        return true
    }
    printError("TISRegisterInputSource failed with OSStatus \(status): \(path)")
    return false
}

private func enable(_ source: InputSource) -> Bool {
    let status = TISEnableInputSource(source.reference)
    if status == noErr {
        print("Enabled: \(source.localizedName) [\(source.sourceID)]")
        return true
    }
    printError("TISEnableInputSource failed with OSStatus \(status): \(source.sourceID)")
    return false
}

private func select(_ source: InputSource) -> Bool {
    let status = TISSelectInputSource(source.reference)
    if status == noErr {
        print("Selected: \(source.localizedName) [\(source.sourceID)]")
        return true
    }
    printError("TISSelectInputSource failed with OSStatus \(status): \(source.sourceID)")
    return false
}

private func printStatus() {
    let sources = teluguKeyboardSources()
    if sources.isEmpty {
        print("Telugu Keyboard source: not registered")
        return
    }

    for source in sources {
        print("Telugu Keyboard source:")
        print("  name: \(source.localizedName)")
        print("  sourceID: \(source.sourceID)")
        print("  bundleID: \(source.bundleID)")
        print("  kind: \(source.kind)")
        print("  enableCapable: \(source.isEnableCapable)")
        print("  enabled: \(source.isEnabled)")
        print("  selected: \(source.isSelected)")
    }
}

private func firstUsableSource() -> InputSource? {
    teluguKeyboardSources().first { $0.isEnabled } ?? teluguKeyboardSources().first
}

private func usage() {
    print(
        """
        Usage:
          telugu-keyboard-installer status
          telugu-keyboard-installer register <path-to-TeluguKeyboard.app>
          telugu-keyboard-installer enable
          telugu-keyboard-installer select
          telugu-keyboard-installer enable-and-select
        """
    )
}

private func printError(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

let arguments = CommandLine.arguments.dropFirst()
guard let command = arguments.first else {
    usage()
    exit(ExitCode.usage.rawValue)
}

switch command {
case "status":
    printStatus()
    exit(ExitCode.ok.rawValue)

case "register":
    guard let path = arguments.dropFirst().first else {
        usage()
        exit(ExitCode.usage.rawValue)
    }
    exit(registerInputMethod(at: path) ? ExitCode.ok.rawValue : ExitCode.runtimeFailure.rawValue)

case "enable":
    guard let source = firstUsableSource() else {
        printError("Telugu Keyboard source is not registered")
        exit(ExitCode.runtimeFailure.rawValue)
    }
    exit(enable(source) ? ExitCode.ok.rawValue : ExitCode.runtimeFailure.rawValue)

case "select":
    guard let source = firstUsableSource() else {
        printError("Telugu Keyboard source is not registered")
        exit(ExitCode.runtimeFailure.rawValue)
    }
    exit(select(source) ? ExitCode.ok.rawValue : ExitCode.runtimeFailure.rawValue)

case "enable-and-select":
    guard let source = firstUsableSource() else {
        printError("Telugu Keyboard source is not registered")
        exit(ExitCode.runtimeFailure.rawValue)
    }
    let enabled = source.isEnabled || enable(source)
    let refreshedSource = firstUsableSource() ?? source
    let selected = select(refreshedSource)
    exit(enabled && selected ? ExitCode.ok.rawValue : ExitCode.runtimeFailure.rawValue)

default:
    usage()
    exit(ExitCode.usage.rawValue)
}
