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
        .library(name: "ProviderTheme", targets: ["ProviderTheme"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/CofficLab/LumiKernel.git",
            revision: "4a30c5f4d6e3b24be61e87a036b14720ef0f1654"
        ),
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
            name: "ProviderTheme",
            path: "Sources/ProviderTheme"
        ),
        .testTarget(
            name: "ProviderThemeTests",
            dependencies: ["ProviderTheme"],
            path: "Tests/ProviderThemeTests"
        ),
    ]
)
