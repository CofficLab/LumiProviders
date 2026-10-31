import Foundation

/// 商品表：商品 ID → 订阅档位的映射契约。
///
/// 各项目商品 ID 不同（`com.yueyi.cisum.*`、`com.coffic.wakey.*` …），但
/// 「哪些商品授予什么档位」的**语义**是共性的。把映射规则本身做成契约，
/// 各项目只需提供一份 ID 表即可复用整条商店链路。
///
/// ## 为什么映射必须唯一真值
///
/// 商品 ID 集合历史上容易散落在多处（代码映射、`.storekit` 配置、
/// 商品清单文件），各自漂移。漂移的后果不是「配置不好看」，而是
/// **付费链路静默断裂**：
///
/// - 商品在商店配置里但不在映射里 → 查档位得到 `.none` → 权益判定直接
///   跳过 → **用户付了钱，权益没到账**；
/// - 商品在映射里但线上没有 → 商品拉取失败 → 购买面板加载不出来。
///
/// 因此这里要求实现方提供**单一**映射，并允许消费方据此校验一致性。
public protocol StoreProductCatalog: Sendable {
    /// 商品 ID → 档位。
    var productTiers: [String: StoreTier] { get }
}

public extension StoreProductCatalog {
    /// 全部商品 ID。
    var allProductIds: [String] {
        productTiers.keys.sorted()
    }

    /// 授予付费权益的商品 ID。
    ///
    /// 购买面板据此决定展示哪些商品。
    var subscriptionProductIds: [String] {
        productTiers
            .filter { $0.value > .none }
            .map(\.key)
            .sorted()
    }

    /// 查询商品对应的档位。
    ///
    /// 未登记的商品返回 `.none`（默认拒绝，而非默认放行）。
    func tier(for productId: String) -> StoreTier {
        productTiers[productId] ?? .none
    }
}

/// 内存态商品表：由各项目在启动时用自己的一份 ID 集合构造。
///
/// 适合商品表是静态常量的项目；若商品表需要热更新（例如从服务端下发），
/// 实现方应自行提供 `StoreProductCatalog` 的其他实现。
public struct StaticStoreProductCatalog: StoreProductCatalog {
    public let productTiers: [String: StoreTier]

    public init(_ productTiers: [String: StoreTier]) {
        self.productTiers = productTiers
    }
}
