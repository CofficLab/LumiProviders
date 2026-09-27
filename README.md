# LumiProviders

Shared provider contracts and default implementations used by Coffic Lab apps.

## Products

- `ProviderCommand`: application command registration and dispatch contracts.
- `ProviderPluginControl`: plugin enablement and control contracts built on `LumiKernel`.
- `ProviderPluginManaging`: plugin listing, lifecycle management, and change observation.
- `ProviderStorage`: shared app storage and plugin enabled-state persistence.
- `ProviderTheme`: shared theme values, built-in palettes, and theme selection state.

Each product is an independent Swift module and can be added to a target separately.

```swift
dependencies: [
    .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.1.0"),
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "ProviderCommand", package: "LumiProviders"),
            .product(name: "ProviderPluginManaging", package: "LumiProviders"),
            .product(name: "ProviderStorage", package: "LumiProviders"),
            .product(name: "ProviderTheme", package: "LumiProviders"),
        ]
    ),
]
```

## Requirements

- Swift tools 6.0+
- macOS 14+
- iOS 17

## Tests

```sh
swift test
```
