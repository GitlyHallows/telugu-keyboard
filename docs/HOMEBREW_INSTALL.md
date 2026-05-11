# Homebrew Install

This is the unsigned beta install path for users who are comfortable pasting one command into Terminal.

It is easier than building from source, but it is not the same as a signed and notarized installer. Until the project has Apple Developer ID signing, this cask removes quarantine from the installed `TeluguKeyboard.app` so macOS can load the input method. Users should install it only if they trust this open-source project.

## User Install

After the first GitHub release is published and the Homebrew cask is filled in, users can install with:

```sh
brew tap GitlyHallows/telugu-keyboard https://github.com/GitlyHallows/telugu-keyboard && brew install --cask GitlyHallows/telugu-keyboard/telugu-keyboard
```

Then:

1. Allow **Telugu Keyboard** if macOS asks.
2. Press `fn` or globe and select **Telugu Keyboard**.
3. Type Roman Telugu and press space.

Remove the cask quarantine workaround once releases are signed and notarized.

## If Homebrew Is Not Installed

Install Homebrew first from [brew.sh](https://brew.sh), then run the install command above.

Homebrew may ask to install Apple's Command Line Tools. That is normal for a Homebrew-based install.

## Maintainer Release Steps

1. Build the unsigned cask zip:

   ```sh
   script/package_homebrew_cask_release.sh
   ```

2. Upload `dist/homebrew/TeluguKeyboard-<version>.zip` to a GitHub release named `v<version>`.
3. Copy the SHA256 printed by the script into `Casks/telugu-keyboard.rb`.
4. Confirm the release URL in `Casks/telugu-keyboard.rb` points to the uploaded GitHub release asset.
5. Test the cask from a clean account:

   ```sh
   brew tap telugu-keyboard/local /path/to/telugu-keyboard
   brew install --cask telugu-keyboard/local/telugu-keyboard
   ```

6. Confirm **Telugu Keyboard** appears as one input source and can type:

   - `padaku ` -> `పడకు `
   - `ela unnav ` -> `ఎలా ఉన్నావ్ `
   - `em chestunnav ` -> `ఏం చేస్తున్నావ్ `
