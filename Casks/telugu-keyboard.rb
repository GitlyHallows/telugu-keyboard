cask "telugu-keyboard" do
  version "0.1.0"
  sha256 "32a9c9880f59575df7fb0d5040faa1f95d2e0084dac48bac878dfb8121144353"

  url "https://github.com/GitlyHallows/telugu-keyboard/releases/download/v#{version}/TeluguKeyboard-#{version}.zip"
  name "Telugu Keyboard"
  desc "Offline Telugu transliteration input method for macOS"
  homepage "https://github.com/GitlyHallows/telugu-keyboard"

  depends_on macos: ">= :sonoma"

  input_method "TeluguKeyboard.app"

  postflight do
    input_method_path = "#{Dir.home}/Library/Input Methods/TeluguKeyboard.app"
    helper = "#{input_method_path}/Contents/Resources/telugu-keyboard-installer"

    # Unsigned beta releases are not notarized. Remove quarantine only from the
    # installed input method so macOS can load it after the user intentionally
    # installs this cask.
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", input_method_path],
                   sudo: false,
                   must_succeed: false

    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", input_method_path],
                   sudo: false
    system_command "/usr/bin/open",
                   args: [input_method_path],
                   sudo: false

    if File.exist?(helper)
      system_command helper,
                     args: ["register", input_method_path],
                     sudo: false
      system_command helper,
                     args: ["enable-and-select"],
                     sudo: false
    end
  end

  uninstall quit: "org.telugukeyboard.inputmethod.TeluguKeyboard"

  zap trash: [
    "~/Library/Application Support/TeluguKeyboard",
    "~/Library/Preferences/org.telugukeyboard.inputmethod.TeluguKeyboard.plist",
  ]
end
