// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LumiProviders",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "ProviderCommand", targets: ["ProviderCommand"]),
        .library(name: "ProviderContentView", targets: ["ProviderContentView"]),
        .library(name: "ProviderDocsView", targets: ["ProviderDocsView"]),
        .library(name: "ProviderRailView", targets: ["ProviderRailView"]),
        .library(name: "ProviderPluginControl", targets: ["ProviderPluginControl"]),
        .library(name: "ProviderPluginManaging", targets: ["ProviderPluginManaging"]),
        .library(name: "ProviderRootView", targets: ["ProviderRootView"]),
        .library(name: "ProviderStorage", targets: ["ProviderStorage"]),
        .library(name: "ProviderTheme", targets: ["ProviderTheme"]),
        .library(name: "ProviderToast", targets: ["ProviderToast"]),
        .library(name: "ProviderToolbar", targets: ["ProviderToolbar"]),
        .library(name: "PluginToolbar", targets: ["PluginToolbar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.0.0"),
        .package(url: "https://github.com/CofficLab/LumiLogging.git", from: "1.0.1"),
        .package(url: "https://github.com/CofficLab/LumiLocalization.git", from: "1.0.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "ProviderCommand",
            path: "Sources/ProviderCommand"
        ),
        .testTarget(
            name: "ProviderCommandTests",
            dependencies: ["ProviderCommand"],
            path: "Tests/ProviderCommandTests"
        ),
        .target(
            name: "ProviderPluginControl",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
            ],
            path: "Sources/ProviderPluginControl"
        ),
        .testTarget(
            name: "ProviderPluginControlTests",
            dependencies: [
                "ProviderPluginControl",
                .product(name: "KernelCore", package: "LumiKernel"),
            ],
            path: "Tests/ProviderPluginControlTests"
        ),
        .target(
            name: "ProviderPluginManaging",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderPluginControl",
            ],
            path: "Sources/ProviderPluginManaging"
        ),
        .testTarget(
            name: "ProviderPluginManagingTests",
            dependencies: [
                "ProviderPluginManaging",
                "ProviderPluginControl",
                .product(name: "KernelCore", package: "LumiKernel"),
            ],
            path: "Tests/ProviderPluginManagingTests"
        ),
        .target(
            name: "ProviderRootView",
            dependencies: ["ProviderRailView"],
            path: "Sources/ProviderRootView"
        ),
        .testTarget(
            name: "ProviderRootViewTests",
            dependencies: ["ProviderRootView"],
            path: "Tests/ProviderRootViewTests"
        ),
        .target(
            name: "ProviderContentView",
            dependencies: [
                .product(name: "LumiLocalizationKit", package: "LumiLocalization"),
                .product(name: "LumiUI", package: "LumiUI"),
            ],
            path: "Sources/ProviderContentView",
            resources: [.process("../../Resources/Localizable.xcstrings")]
        ),
        .testTarget(
            name: "ProviderContentViewTests",
            dependencies: ["ProviderContentView"],
            path: "Tests/ProviderContentViewTests"
        ),
        .target(
            name: "ProviderDocsView",
            path: "Sources/ProviderDocsView"
        ),
        .testTarget(
            name: "ProviderDocsViewTests",
            dependencies: ["ProviderDocsView"],
            path: "Tests/ProviderDocsViewTests"
        ),
        .target(
            name: "ProviderRailView",
            dependencies: [
                .product(name: "LumiUI", package: "LumiUI"),
            ],
            path: "Sources/ProviderRailView"
        ),
        .testTarget(
            name: "ProviderRailViewTests",
            dependencies: ["ProviderRailView"],
            path: "Tests/ProviderRailViewTests"
        ),
        .target(
            name: "ProviderStorage",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiLoggingKit", package: "LumiLogging"),
            ],
            path: "Sources/ProviderStorage"
        ),
        .testTarget(
            name: "ProviderStorageTests",
            dependencies: [
                "ProviderStorage",
                .product(name: "KernelCore", package: "LumiKernel"),
            ],
            path: "Tests/ProviderStorageTests"
        ),
        .target(
            name: "ProviderToast",
            path: "Sources/ProviderToast"
        ),
        .testTarget(
            name: "ProviderToastTests",
            dependencies: ["ProviderToast"],
            path: "Tests/ProviderToastTests"
        ),
        .target(
            name: "ProviderTheme",
            path: "Sources/ProviderTheme",
            resources: [.process("../../Resources/Localizable.xcstrings")]
        ),
        .testTarget(
            name: "ProviderThemeTests",
            dependencies: ["ProviderTheme"],
            path: "Tests/ProviderThemeTests"
        ),
        .target(
            name: "ProviderToolbar",
            dependencies: [
                .product(name: "LumiUI", package: "LumiUI"),
            ],
            path: "Sources/ProviderToolbar"
        ),
        .testTarget(
            name: "ProviderToolbarTests",
            dependencies: ["ProviderToolbar"],
            path: "Tests/ProviderToolbarTests"
        ),
        .target(
            name: "PluginToolbar",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiLoggingKit", package: "LumiLogging"),
                "ProviderPluginManaging",
                "ProviderToolbar",
            ],
            path: "Sources/PluginToolbar"
        ),
    ]
)
