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
        .library(name: "ProviderPluginControl", targets: ["ProviderPluginControl"]),
        .library(name: "ProviderPluginManaging", targets: ["ProviderPluginManaging"]),
        .library(name: "ProviderStorage", targets: ["ProviderStorage"]),
        .library(name: "ProviderTheme", targets: ["ProviderTheme"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.0.0"),
        .package(url: "https://github.com/CofficLab/LumiLogging.git", from: "1.0.1"),
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
            name: "ProviderTheme",
            path: "Sources/ProviderTheme",
            resources: [.process("../../Resources/Localizable.xcstrings")]
        ),
        .testTarget(
            name: "ProviderThemeTests",
            dependencies: ["ProviderTheme"],
            path: "Tests/ProviderThemeTests"
        ),
    ]
)
