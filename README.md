# LumiProviders

Shared provider contracts and default implementations used by Coffic Lab apps.

## Products

- `ProviderCommand`: application command registration and dispatch contracts.
- `ProviderContentView`: main content view registration and rendering.
- `ProviderDocsView`: plugin-contributed about and manual entries.
- `ProviderRailView`: shared rail tab registration, filtering, and rendering.
- `ProviderPluginControl`: plugin enablement and control contracts built on `LumiKernel`.
- `ProviderPluginManaging`: plugin listing, lifecycle management, and change observation.
- `ProviderRootView`: platform-neutral root view regions, overlays, trailing panes, and change observation.
- `ProviderStorage`: shared app storage and plugin enabled-state persistence.
- `ProviderTheme`: shared theme values, built-in palettes, and theme selection state.
- `ProviderToast`: non-blocking toast presentation contracts.
- `ProviderToolbar`: shared toolbar item registration, filtering, and rendering.

Each product is an independent Swift module and can be added to a target separately.

## ProviderRootView

`ProviderRootView` defines the capabilities an app may expose from its root view without prescribing a single layout. It supports optional regions such as toolbar, activity bar, sidebar, rail, content header, content, footer, and status bar, plus ordered overlays and an optional trailing pane.

The contract is shared by macOS and iOS. Each app remains responsible for composing these regions with the layout system that fits its platform: AppKit-oriented layouts on macOS and adaptive SwiftUI layouts on iOS. Apps can implement only the regions they need, or use `DefaultRootViewProviding` for the built-in storage and observation behavior.

An app with a richer layout can subclass the default implementation and override only its root composition:

```swift
@MainActor
final class PluginRootView: DefaultRootViewProviding {
    override func makeRootView() -> AnyView {
        AnyView(MyPlatformRootLayout(
            toolbar: toolbarView,
            content: contentView,
            trailingPane: trailingPane
        ))
    }
}
```

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
