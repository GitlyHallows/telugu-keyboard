# Install Telugu Keyboard on macOS

## Signed Installer

The public release should feel like installing a regular Mac app:

1. Download `TeluguKeyboard.pkg` from the GitHub Releases page.
2. Double-click the package and finish the installer.
3. If macOS asks to allow **Telugu Keyboard**, choose **Allow**.
4. Press the `fn` or globe key and select **Telugu Keyboard**.
5. Type Roman Telugu and press space to accept the best Telugu candidate.

## Homebrew Beta

Until signed releases are available, a Homebrew cask can provide a one-command unsigned beta install for users who are comfortable with Terminal.

See [HOMEBREW_INSTALL.md](HOMEBREW_INSTALL.md).

## If The Keyboard Does Not Appear

Open **System Settings** -> **Keyboard** -> **Text Input** -> **Input Sources** and check whether **Telugu Keyboard** is listed.

If it is listed, select it from the input menu in the menu bar or press the `fn`/globe key.

If it is not listed, reinstall the package and restart the app where you want to type.

## Developer Install

Until signed releases are available, local developer builds can be installed with:

```sh
script/install_input_method.sh
```

Developer installs require Xcode command line tools and are not meant for regular users.
