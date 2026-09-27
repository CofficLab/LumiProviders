# LumiProviders

Shared provider contracts and default implementations used by Coffic Lab apps.

## Products

- `ProviderCommand`: application command registration and dispatch contracts.
- `ProviderPluginControl`: plugin enablement and control contracts built on `LumiKernel`.
- `ProviderTheme`: shared theme values, built-in palettes, and theme selection state.

Each product is an independent Swift module and can be added to a target separately.

```swift
dependencies: [
    .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "ProviderCommand", package: "LumiProviders"),
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
