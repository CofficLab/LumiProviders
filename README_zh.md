# LumiProviders

📖 [中文版](README_zh.md) | [English](README.md)

Lumi 家族各应用共享的 provider 契约与默认实现。

## Products

- `ProviderCommand`：应用命令注册与分发契约。
- `ProviderContentView`：主内容视图的注册与渲染。
- `ProviderDocsView`：插件贡献的关于页与手册条目。
- `ProviderRailView`：共享 rail 标签页的注册、过滤与渲染。
- `ProviderPluginControl`：构建于 `LumiKernel` 之上的插件启用与控制契约。
- `ProviderPluginManaging`：插件列表、生命周期管理与变更观察。
- `ProviderRootView`：平台中立的根视图区域、覆盖层、尾部面板与变更观察。
- `ProviderStorage`：共享的应用存储与插件启用状态持久化。
- `ProviderStore`：应用内购买与订阅契约（层级、权益、购买界面展示）。
- `ProviderTheme`：共享主题值、内置调色板与主题选择状态。
- `ProviderToast`：非阻塞 toast 展示契约。
- `ProviderToolbar`：共享工具栏项的注册、过滤与渲染。

每个 product 都是独立的 Swift 模块，可分别加入 target。

## ProviderRootView

`ProviderRootView` 定义应用的根视图可以暴露的能力，而不规定单一布局。它支持
工具栏、活动栏、侧边栏、rail、内容头部、内容、页脚、状态栏等可选区域，
以及有序覆盖层与可选的尾部面板。

该契约由 macOS 与 iOS 共享。每个应用自行负责用适合其平台的布局系统组合这些
区域：macOS 上使用面向 AppKit 的布局，iOS 上使用自适应 SwiftUI 布局。应用可以
只实现它需要的区域，或使用 `DefaultRootViewProviding` 获得内置的存储与观察行为。

布局更丰富的应用可以继承默认实现，只覆盖其根布局组合：

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
    .package(url: "https://github.com/lumi-softworks/LumiProviders.git", from: "1.1.0"),
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

## ProviderStore

`ProviderStore` 定义 Lumi 家族应用共享的应用内购买与订阅契约：订阅层级、
权益快照、权益观察、购买界面展示以及产品目录契约。

该模块刻意保持**纯契约**。它只依赖 Foundation —— 不依赖 StoreKit、SwiftUI、
LumiUI 或 `KernelCore` —— 因此可以被任何 target（包括单元测试）采用，而不会
把购买框架拖进依赖图。StoreKit 2 生命周期（交易监听、权益校准、产品获取、
验证）位于独立的 [LumiStoreKit](https://github.com/lumi-softworks/LumiStoreKit) 工具包。

### 类型

- `StoreTier`：有序订阅层级（`none` / `pro` / `ultimate`），带 `isFree`、
  `isProOrHigher`、`isUltimateOrHigher` 以及 `defaultDisplayName`（英文兜底；
  应用可用本地化版本覆盖）。
- `StoreEntitlementSnapshot`：`tier` + `expiresAt` 的值快照。`effectiveTier`
  是权限判定的唯一事实来源：**过期订阅等同于免费层级**，而不是"曾经买过"。
  过期保留 60 秒宽限期，以免时钟偏差导致续订被误判为过期。
- `StoreEntitlementProviding`：回答"当前用户是什么层级？"的能力契约。
  `entitlement` 是事实来源，`tier` 由其派生，因此两者永远不会在过期问题上
  产生分歧。
- `StoreEntitlementEvent` / `StoreEntitlementObserverHandle`：类型化变更通知；
  事件只携带新层级，绝不携带 StoreKit 交易详情。
- `StorePurchasePresenting`："请展示购买面板"这一单一动作。store 插件是唯一
  实现；触发点（达到上限、拖拽导入）请求展示，而不知道它如何被渲染。
- `StoreProductSnapshot` / `StoreProductKind`：不暴露 `StoreKit.Product` 的
  中立产品表示。
- `StoreProductCatalog` / `StaticStoreProductCatalog`：产品 ID → 层级映射契约。
  每个应用提供自己的 ID 表；`tier(for:)` 默认拒绝未知产品，而不是授予权限。

### 用法

应用声明自己的产品表并实现该能力：

```swift
import ProviderStore

struct MyStoreCatalog: StoreProductCatalog {
    let productTiers: [String: StoreTier] = [
        "com.example.pro.monthly": .pro,
        "com.example.pro.yearly": .pro,
    ]
}

@MainActor
final class MyEntitlementProvider: StoreEntitlementProviding {
    var entitlement: StoreEntitlementSnapshot = .none

    func addObserver(
        _ callback: @escaping (StoreEntitlementEvent) -> Void
    ) -> any StoreEntitlementObserverHandle {
        // StoreKit-backed implementation; the contract only requires
        // that changes are published on the main thread.
        ...
    }
}
```

消费方通过内核解析该能力并读出一个结论：

```swift
let tier = kernel.resolveProvider((any StoreEntitlementProviding).self)?.tier ?? .none
if tier.isFree {
    // Show the limit notice; request the purchase panel when tapped.
}
```

### 从机制结果推导权益

StoreKit 工具层报告*哪些订阅产品 ID 处于活跃状态、何时过期* —— 它不知道层级，
层级属于产品语义。`StoreProductCatalog` 提供标准的翻译步骤：

```swift
let snapshot = catalog.entitlement(
    activeProductIDs: holding.activeSubscriptionProductIDs,
    latestExpiration: holding.latestExpiration
)
```

不在目录中的产品解析为无层级并被跳过，这是对付费购买却什么都不授予的防护。

## Requirements

- Swift tools 6.0+
- macOS 14+
- iOS 17

## Tests

```sh
swift test
```
