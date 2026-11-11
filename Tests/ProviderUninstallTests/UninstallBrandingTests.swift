import Foundation
import Testing
@testable import ProviderUninstall

/// 品牌注入的等价性守卫。
///
/// `UninstallBranding.lumi` 与 `UninstallScope.production` / `.debug` 必须
/// 产出完全相同的白名单，否则 Lumi 主项目的卸载流程会改变行为——这是
/// 数据删除逻辑，白名单错了后果严重。
@Suite("卸载品牌注入")
struct UninstallBrandingTests {
    @Test("Lumi 品牌的 production 白名单与既有静态值一致")
    func lumiProductionMatchesLegacyScope() {
        let branded = UninstallScope.branded(branding: .lumi, isDebug: false)

        #expect(branded == UninstallScope.production)
    }

    @Test("Lumi 品牌的 debug 白名单与既有静态值一致")
    func lumiDebugMatchesLegacyScope() {
        let branded = UninstallScope.branded(branding: .lumi, isDebug: true)

        #expect(branded == UninstallScope.debug)
    }

    @Test("Wakey 品牌的白名单与迁移前的本地包逐字一致")
    func wakeyScopeMatchesFormerLocalPackage() {
        // 这组期望值抄自 Wakey 仓库里迁移前的本地 ProviderAppUninstall 包。
        // 迁移后必须逐字相同，否则用户的卸载流程会删错或漏删数据。
        let production = UninstallScope.branded(branding: .wakey, isDebug: false)

        #expect(production.bundleIdentifiers == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(production.appGroupIdentifiers == [])
        #expect(production.preferenceDomains == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(production.cacheBundleIdentifiers == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(production.legacyApplicationSupportDirectories == ["Wakey"])
        #expect(production.keychainServices == [])

        let debug = UninstallScope.branded(branding: .wakey, isDebug: true)

        #expect(debug.bundleIdentifiers == ["com.coffic.wakey.debug"])
        #expect(debug.appGroupIdentifiers == [])
        #expect(debug.preferenceDomains == ["com.coffic.wakey.debug"])
        #expect(debug.cacheBundleIdentifiers == ["com.coffic.wakey.debug"])
        #expect(debug.legacyApplicationSupportDirectories == [])
        #expect(debug.keychainServices == [])
    }

    @Test("Wakey 品牌的文案与迁移前的本地包逐字一致")
    func wakeyBrandingMatchesFormerLocalPackage() {
        #expect(UninstallBranding.wakey.confirmationPhrase == "删除 Wakey 数据")
        #expect(UninstallBranding.wakey.applicationDataDisplayName == "Wakey 数据")
        #expect(UninstallBranding.wakey.applicationDisplayName == "Wakey 应用")
        #expect(UninstallBranding.wakey.whitelistDescriptionName == "Wakey")
        #expect(
            UninstallBranding.wakey.willUninstallNotificationName
                == "com.coffic.wakey.uninstall.will-uninstall"
        )
    }

    @Test("目标类型的显示名按品牌渲染")
    func targetKindDisplayNameFollowsBranding() {
        #expect(UninstallTargetKind.applicationData.displayName(branding: .wakey) == "Wakey 数据")
        #expect(UninstallTargetKind.application.displayName(branding: .wakey) == "Wakey 应用")
        // 非品牌相关的分支不随品牌变化。
        #expect(UninstallTargetKind.caches.displayName(branding: .wakey) == "缓存")
        #expect(UninstallTargetKind.keychain.displayName(branding: .wakey) == "Keychain 凭据")

        // 默认参数下仍是 Lumi 文案。
        #expect(UninstallTargetKind.applicationData.displayName == "Lumi 数据")
        #expect(UninstallTargetKind.application.displayName == "Lumi 应用")
    }

    @Test("白名单错误信息按品牌渲染")
    func unsafeTargetMessageFollowsBranding() {
        let error = UninstallError.unsafeTarget("/tmp/example")

        #expect(error.errorDescription(branding: .wakey) == "拒绝删除不属于 Wakey 白名单的路径：/tmp/example")
        #expect(error.errorDescription == "拒绝删除不属于 Lumi 白名单的路径：/tmp/example")
    }

    @Test("通知名按品牌区分")
    func notificationNameFollowsBranding() {
        #expect(
            Notification.Name.willUninstall(branding: .lumi)
                == Notification.Name("com.coffic.lumi.uninstall.will-uninstall")
        )
        #expect(
            Notification.Name.willUninstall(branding: .lumi)
                == Notification.Name.lumiWillUninstall
        )
        #expect(
            Notification.Name.willUninstall(branding: .wakey)
                == Notification.Name("com.coffic.wakey.uninstall.will-uninstall")
        )
    }

    @Test("确认短语按品牌区分")
    func confirmationPhraseFollowsBranding() {
        #expect(UninstallBranding.lumi.confirmationPhrase == "删除 Lumi 数据")
        #expect(UninstallOptions.confirmationPhrase == "删除 Lumi 数据")
    }
}
