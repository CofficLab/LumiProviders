import Foundation

/// 品牌相关的字符串与标识。
///
/// 卸载流程会显示品牌名（"删除 Lumi 数据"）、按品牌判定白名单、并在删除前
/// 广播品牌专属的通知名。这些值在 Lumi 与 Wakey 等同族应用之间不同，
/// 因此集中到本类型，由宿主在装配时注入。
///
/// `UninstallBranding.lumi` 保持 Lumi 的既有取值，默认构造即为 Lumi 行为，
/// 同族应用无需改动现有调用。
public struct UninstallBranding: Sendable, Equatable {
    /// 应用显示名，例如 "Lumi"、"Wakey"。
    public let applicationName: String

    /// 品牌专属的「即将卸载」通知名。
    public let willUninstallNotificationName: String

    /// 确认短语，用户必须在卸载确认框中输入这段文本。
    public let confirmationPhrase: String

    /// 数据目录类目标的显示名，例如 "Lumi 数据"。
    public let applicationDataDisplayName: String

    /// 应用本体类目标的显示名，例如 "Lumi 应用"。
    public let applicationDisplayName: String

    /// 当目标路径不在白名单内时，错误信息中引用的品牌名。
    public let whitelistDescriptionName: String

    /// Release 构建的 bundle id，例如 "com.coffic.lumi"。
    public let bundleIdentifierPrefix: String

    /// 历史遗留的 bundle id，例如 "com.coffic.Lumi"。与
    /// `bundleIdentifierPrefix` 一起构成 Release 构建的白名单。
    public let legacyBundleIdentifier: String

    /// App Group 标识符白名单（Release 构建）。
    public let appGroupIdentifiers: [String]

    /// App Group 标识符白名单（Debug 构建）。
    public let debugAppGroupIdentifiers: [String]

    /// 遗留的 Application Support 目录名，例如 "Lumi"、"LumiMinimal"。
    public let legacyApplicationSupportDirectories: [String]

    /// Release 构建可清理的 Keychain service 白名单。
    public let keychainServices: [String]

    /// Debug 构建可清理的 Keychain service 白名单。
    public let debugKeychainServices: [String]

    public init(
        applicationName: String,
        willUninstallNotificationName: String,
        confirmationPhrase: String,
        applicationDataDisplayName: String,
        applicationDisplayName: String,
        whitelistDescriptionName: String,
        bundleIdentifierPrefix: String,
        legacyBundleIdentifier: String,
        appGroupIdentifiers: [String],
        debugAppGroupIdentifiers: [String],
        legacyApplicationSupportDirectories: [String],
        keychainServices: [String],
        debugKeychainServices: [String]
    ) {
        self.applicationName = applicationName
        self.willUninstallNotificationName = willUninstallNotificationName
        self.confirmationPhrase = confirmationPhrase
        self.applicationDataDisplayName = applicationDataDisplayName
        self.applicationDisplayName = applicationDisplayName
        self.whitelistDescriptionName = whitelistDescriptionName
        self.bundleIdentifierPrefix = bundleIdentifierPrefix
        self.legacyBundleIdentifier = legacyBundleIdentifier
        self.appGroupIdentifiers = appGroupIdentifiers
        self.debugAppGroupIdentifiers = debugAppGroupIdentifiers
        self.legacyApplicationSupportDirectories = legacyApplicationSupportDirectories
        self.keychainServices = keychainServices
        self.debugKeychainServices = debugKeychainServices
    }

    /// Lumi 品牌的默认值。
    public static let lumi = Self(
        applicationName: "Lumi",
        willUninstallNotificationName: "com.coffic.lumi.uninstall.will-uninstall",
        confirmationPhrase: "删除 Lumi 数据",
        applicationDataDisplayName: "Lumi 数据",
        applicationDisplayName: "Lumi 应用",
        whitelistDescriptionName: "Lumi",
        bundleIdentifierPrefix: "com.coffic.lumi",
        legacyBundleIdentifier: "com.coffic.Lumi",
        appGroupIdentifiers: ["group.com.coffic.lumi"],
        debugAppGroupIdentifiers: ["group.com.coffic.lumi.debug"],
        legacyApplicationSupportDirectories: ["Lumi", "LumiMinimal"],
        keychainServices: [
            "com.coffic.lumi.apikey",
            "com.coffic.lumi.database-manager",
            "com.coffic.lumi.appstoreconnect",
            "com.coffic.lumi.mail",
            "com.kit.llm.apikey"
        ],
        debugKeychainServices: [
            "com.coffic.lumi.database-manager.debug",
            "com.coffic.lumi.mail.debug"
        ]
    )

    /// 由品牌名派生的「即将卸载」通知名。
    ///
    /// 便于宿主快速构造：品牌名 "Wakey" 得到
    /// "com.coffic.wakey.uninstall.will-uninstall"。
    public static func notificationName(forBrandIdentifier identifier: String) -> String {
        "com.coffic.\(identifier.lowercased()).uninstall.will-uninstall"
    }

    /// Wakey 品牌的配置。
    ///
    /// 与 Wakey 仓库里迁移前的本地包逐字一致：bundle id 前缀
    /// `com.coffic.wakey`、遗留 bundle id `com.coffic.Wakey`、遗留目录名
    /// `Wakey`，且没有 App Group 与 Keychain 条目。
    public static let wakey = Self(
        applicationName: "Wakey",
        willUninstallNotificationName: "com.coffic.wakey.uninstall.will-uninstall",
        confirmationPhrase: "删除 Wakey 数据",
        applicationDataDisplayName: "Wakey 数据",
        applicationDisplayName: "Wakey 应用",
        whitelistDescriptionName: "Wakey",
        bundleIdentifierPrefix: "com.coffic.wakey",
        legacyBundleIdentifier: "com.coffic.Wakey",
        appGroupIdentifiers: [],
        debugAppGroupIdentifiers: [],
        legacyApplicationSupportDirectories: ["Wakey"],
        keychainServices: [],
        debugKeychainServices: []
    )
}
