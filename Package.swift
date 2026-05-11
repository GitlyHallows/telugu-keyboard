// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TeluguKeyboard",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TeluguKeyboardCore",
            targets: ["TeluguKeyboardCore"]
        ),
        .executable(
            name: "telugu-keyboard-cli",
            targets: ["TeluguKeyboardCLI"]
        ),
        .executable(
            name: "TeluguKeyboardIME",
            targets: ["TeluguKeyboardIME"]
        ),
        .executable(
            name: "telugu-keyboard-installer",
            targets: ["TeluguKeyboardInstaller"]
        ),
        .executable(
            name: "telugu-keyboard-smoke-tests",
            targets: ["TeluguKeyboardSmokeTests"]
        ),
        .executable(
            name: "telugu-keyboard-quality-tests",
            targets: ["TeluguKeyboardQualityTests"]
        )
    ],
    targets: [
        .target(
            name: "TeluguKeyboardCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "TeluguKeyboardCLI",
            dependencies: ["TeluguKeyboardCore"]
        ),
        .executableTarget(
            name: "TeluguKeyboardIME",
            dependencies: ["TeluguKeyboardCore"]
        ),
        .executableTarget(
            name: "TeluguKeyboardInstaller"
        ),
        .executableTarget(
            name: "TeluguKeyboardSmokeTests",
            dependencies: ["TeluguKeyboardCore"]
        ),
        .executableTarget(
            name: "TeluguKeyboardQualityTests",
            dependencies: ["TeluguKeyboardCore"]
        )
    ]
)
