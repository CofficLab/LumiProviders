import Foundation

public extension Notification.Name {
    /// Posted immediately before Lumi-owned data is removed.
    /// Components with asynchronous file writers should flush and stop here.
    static let lumiWillUninstall = Notification.Name("com.coffic.lumi.uninstall.will-uninstall")

    /// 品牌专属的「即将卸载」通知名。
    ///
    /// 同族应用（如 Wakey）用自己的通知名，避免两个应用的监听器互相响应。
    static func willUninstall(branding: UninstallBranding) -> Notification.Name {
        Notification.Name(branding.willUninstallNotificationName)
    }
}

/// The categories of data owned by Lumi that can be removed by the uninstall flow.
public enum UninstallTargetKind: String, Codable, Sendable, Equatable {
    case applicationData
    case legacyData
    case caches
    case appGroup
    case preferences
    case keychain
    case application

    /// 目标类型的显示名。
    ///
    /// 品牌相关的两个分支（应用数据与应用本体）需要注入品牌文案；未传
    /// `branding` 时回退到 Lumi 的取值。
    public func displayName(branding: UninstallBranding = .lumi) -> String {
        switch self {
        case .applicationData: return branding.applicationDataDisplayName
        case .legacyData: return "旧版本数据"
        case .caches: return "缓存"
        case .appGroup: return "Finder 扩展数据"
        case .preferences: return "偏好设置"
        case .keychain: return "Keychain 凭据"
        case .application: return branding.applicationDisplayName
        }
    }

    /// Lumi 品牌的显示名，保留给未注入品牌的既有调用点。
    public var displayName: String { displayName(branding: .lumi) }
}

/// A single deletion candidate discovered by a preflight scan.
public struct UninstallTarget: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let kind: UninstallTargetKind
    public let location: String
    public let sizeInBytes: Int64
    public let isSensitive: Bool

    public init(
        id: String,
        kind: UninstallTargetKind,
        location: String,
        sizeInBytes: Int64 = 0,
        isSensitive: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.location = location
        self.sizeInBytes = sizeInBytes
        self.isSensitive = isSensitive
    }
}

/// Result of a read-only uninstall preflight scan.
public struct UninstallScan: Codable, Sendable, Equatable {
    public let targets: [UninstallTarget]

    public init(targets: [UninstallTarget] = []) {
        self.targets = targets
    }

    public var totalSizeInBytes: Int64 {
        targets.reduce(0) { $0 + $1.sizeInBytes }
    }

    public var hasData: Bool {
        !targets.isEmpty
    }

    public var keychainTargetCount: Int {
        targets.filter { $0.kind == .keychain }.count
    }
}

/// Options explicitly chosen by the user in the final confirmation step.
public struct UninstallOptions: Sendable, Equatable {
    /// Lumi 品牌的确认短语，保留给未注入品牌的既有调用点。
    public static let confirmationPhrase = UninstallBranding.lumi.confirmationPhrase

    public let confirmation: String
    public let removeKeychainCredentials: Bool
    public let removeApplication: Bool

    public init(
        confirmation: String,
        removeKeychainCredentials: Bool,
        removeApplication: Bool
    ) {
        self.confirmation = confirmation
        self.removeKeychainCredentials = removeKeychainCredentials
        self.removeApplication = removeApplication
    }
}

public struct UninstallFailure: Codable, Sendable, Equatable {
    public let targetID: String
    public let location: String
    public let message: String

    public init(targetID: String, location: String, message: String) {
        self.targetID = targetID
        self.location = location
        self.message = message
    }
}

public struct UninstallResult: Codable, Sendable, Equatable {
    public let removedTargetIDs: [String]
    public let failures: [UninstallFailure]
    public let applicationMovedToTrash: Bool

    public init(
        removedTargetIDs: [String],
        failures: [UninstallFailure],
        applicationMovedToTrash: Bool
    ) {
        self.removedTargetIDs = removedTargetIDs
        self.failures = failures
        self.applicationMovedToTrash = applicationMovedToTrash
    }

    public var succeeded: Bool {
        failures.isEmpty
    }
}

public enum UninstallError: LocalizedError, Sendable, Equatable {
    case invalidConfirmation
    case unsafeTarget(String)

    public var errorDescription: String? {
        errorDescription(branding: .lumi)
    }

    /// 错误描述。
    ///
    /// 「不属于白名单」的错误信息里带有品牌名，需要随宿主注入；未传
    /// `branding` 时回退到 Lumi 的取值。
    public func errorDescription(branding: UninstallBranding = .lumi) -> String? {
        switch self {
        case .invalidConfirmation:
            return "确认文本不正确，未执行卸载。"
        case let .unsafeTarget(path):
            return "拒绝删除不属于 \(branding.whitelistDescriptionName) 白名单的路径：\(path)"
        }
    }
}

/// Filesystem and application context used by the default provider.
///
/// Keeping these locations injectable makes the destructive part testable without
/// touching the real user's Library directory.
public struct UninstallLocations: Sendable, Equatable {
    public let applicationSupportDirectory: URL
    public let groupContainersDirectory: URL
    public let cachesDirectory: URL
    public let savedApplicationStateDirectory: URL
    public let preferencesDirectory: URL
    public let webKitDirectory: URL
    public let containersDirectory: URL
    public let cookiesDirectory: URL
    public let applicationBundleURL: URL?

    public init(
        applicationSupportDirectory: URL,
        groupContainersDirectory: URL,
        cachesDirectory: URL,
        savedApplicationStateDirectory: URL,
        preferencesDirectory: URL,
        webKitDirectory: URL,
        containersDirectory: URL,
        cookiesDirectory: URL,
        applicationBundleURL: URL?
    ) {
        self.applicationSupportDirectory = applicationSupportDirectory.standardizedFileURL
        self.groupContainersDirectory = groupContainersDirectory.standardizedFileURL
        self.cachesDirectory = cachesDirectory.standardizedFileURL
        self.savedApplicationStateDirectory = savedApplicationStateDirectory.standardizedFileURL
        self.preferencesDirectory = preferencesDirectory.standardizedFileURL
        self.webKitDirectory = webKitDirectory.standardizedFileURL
        self.containersDirectory = containersDirectory.standardizedFileURL
        self.cookiesDirectory = cookiesDirectory.standardizedFileURL
        self.applicationBundleURL = applicationBundleURL?.standardizedFileURL
    }

    public static func live(
        applicationBundleURL: URL? = Bundle.main.bundleURL
    ) -> Self {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let library = home.appendingPathComponent("Library", isDirectory: true)
        return Self(
            applicationSupportDirectory: library.appendingPathComponent("Application Support", isDirectory: true),
            groupContainersDirectory: library.appendingPathComponent("Group Containers", isDirectory: true),
            cachesDirectory: library.appendingPathComponent("Caches", isDirectory: true),
            savedApplicationStateDirectory: library.appendingPathComponent("Saved Application State", isDirectory: true),
            preferencesDirectory: library.appendingPathComponent("Preferences", isDirectory: true),
            webKitDirectory: library.appendingPathComponent("WebKit", isDirectory: true),
            containersDirectory: library.appendingPathComponent("Containers", isDirectory: true),
            cookiesDirectory: library.appendingPathComponent("Cookies", isDirectory: true),
            applicationBundleURL: applicationBundleURL
        )
    }
}

/// The storage namespace that belongs to the currently running Lumi build.
///
/// Debug and Release intentionally do not share filesystem targets. Some old
/// API-key services are shared by both builds and therefore are only removable
/// from the production scope, where deleting them cannot affect a debug-only
/// installation.
public struct UninstallScope: Sendable, Equatable {
    public let bundleIdentifiers: [String]
    public let appGroupIdentifiers: [String]
    public let preferenceDomains: [String]
    public let cacheBundleIdentifiers: [String]
    public let legacyApplicationSupportDirectories: [String]
    public let keychainServices: [String]

    public init(
        bundleIdentifiers: [String],
        appGroupIdentifiers: [String],
        preferenceDomains: [String],
        cacheBundleIdentifiers: [String],
        legacyApplicationSupportDirectories: [String],
        keychainServices: [String]
    ) {
        self.bundleIdentifiers = bundleIdentifiers
        self.appGroupIdentifiers = appGroupIdentifiers
        self.preferenceDomains = preferenceDomains
        self.cacheBundleIdentifiers = cacheBundleIdentifiers
        self.legacyApplicationSupportDirectories = legacyApplicationSupportDirectories
        self.keychainServices = keychainServices
    }

    public static let production = Self(
        bundleIdentifiers: ["com.coffic.lumi", "com.coffic.Lumi"],
        appGroupIdentifiers: ["group.com.coffic.lumi"],
        preferenceDomains: ["com.coffic.lumi", "com.coffic.Lumi"],
        cacheBundleIdentifiers: ["com.coffic.lumi", "com.coffic.Lumi"],
        legacyApplicationSupportDirectories: ["Lumi", "LumiMinimal"],
        keychainServices: [
            "com.coffic.lumi.apikey",
            "com.coffic.lumi.database-manager",
            "com.coffic.lumi.appstoreconnect",
            "com.coffic.lumi.mail",
            "com.kit.llm.apikey"
        ]
    )

    public static let debug = Self(
        bundleIdentifiers: ["com.coffic.lumi.debug"],
        appGroupIdentifiers: ["group.com.coffic.lumi.debug"],
        preferenceDomains: ["com.coffic.lumi.debug"],
        cacheBundleIdentifiers: ["com.coffic.lumi.debug"],
        legacyApplicationSupportDirectories: [],
        keychainServices: [
            "com.coffic.lumi.database-manager.debug",
            "com.coffic.lumi.mail.debug"
        ]
    )

    public static func live(bundleIdentifier: String? = Bundle.main.bundleIdentifier) -> Self {
        bundleIdentifier == "com.coffic.lumi.debug" ? .debug : .production
    }

    /// 按品牌与构建类型生成白名单。
    ///
    /// 同族应用（如 Wakey）的 bundle id、App Group、偏好域与遗留目录名都与
    /// Lumi 不同，因此白名单必须由宿主提供，不能沿用 Lumi 的取值。
    ///
    /// Debug 与 Release 不共享文件系统目标：Debug 只清理自己的 `.debug`
    /// bundle id，不碰 Release 的遗留 bundle id 与遗留目录。
    ///
    /// - Parameters:
    ///   - branding: 品牌配置，提供 bundle id 前缀与遗留目录名。
    ///   - isDebug: 是否为 Debug 构建。
    public static func branded(
        branding: UninstallBranding,
        isDebug: Bool
    ) -> Self {
        if isDebug {
            let bundleIdentifier = "\(branding.bundleIdentifierPrefix).debug"
            return Self(
                bundleIdentifiers: [bundleIdentifier],
                appGroupIdentifiers: branding.debugAppGroupIdentifiers,
                preferenceDomains: [bundleIdentifier],
                cacheBundleIdentifiers: [bundleIdentifier],
                legacyApplicationSupportDirectories: [],
                keychainServices: branding.debugKeychainServices
            )
        }

        return Self(
            bundleIdentifiers: [branding.bundleIdentifierPrefix, branding.legacyBundleIdentifier],
            appGroupIdentifiers: branding.appGroupIdentifiers,
            preferenceDomains: [branding.bundleIdentifierPrefix, branding.legacyBundleIdentifier],
            cacheBundleIdentifiers: [branding.bundleIdentifierPrefix, branding.legacyBundleIdentifier],
            legacyApplicationSupportDirectories: branding.legacyApplicationSupportDirectories,
            keychainServices: branding.keychainServices
        )
    }
}

public protocol UninstallPersistentDomainRemoving: Sendable {
    func removePersistentDomain(named name: String) throws
}

public protocol UninstallKeychainManaging: Sendable {
    func containsItems(forService service: String) -> Bool
    func removeItems(forService service: String) throws
}

/// A provider used by Settings > General to scan and remove Lumi-owned data.
public protocol UninstallProviding: AnyObject, Sendable {
    func scan() async -> UninstallScan
    func uninstall(options: UninstallOptions) async throws -> UninstallResult
}
