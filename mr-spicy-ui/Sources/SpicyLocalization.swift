//
//  SpicyLocalization.swift
//  MR. SPICY
//
//  English + Arabic localization for the MR. SPICY layer, including
//  accessibility strings, error strings and empty/unavailable states.
//  Strings live in Localization/{en,ar}.lproj/MrSpicy.strings; the table in
//  this file is the authoritative key list and the in-code fallback so the
//  layer degrades gracefully when the resource bundle is unavailable.
//

import UIKit

public enum SpicyLanguage: String, CaseIterable {
    case english = "en"
    case arabic = "ar"

    public var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }

    public var layoutDirection: UIUserInterfaceLayoutDirection {
        self == .arabic ? .rightToLeft : .leftToRight
    }

    public var isRTL: Bool { layoutDirection == .rightToLeft }

    public var locale: Locale { Locale(identifier: rawValue) }
}

public enum SpicyStringKey: String, CaseIterable {
    // Header / shell
    case appTitle = "spicy.app.title"
    case appSubtitle = "spicy.app.subtitle"
    case statusReady = "spicy.status.ready"
    case statusUnavailable = "spicy.status.unavailable"
    case close = "spicy.action.close"
    case minimize = "spicy.action.minimize"
    case expand = "spicy.action.expand"
    case settings = "spicy.action.settings"
    case done = "spicy.action.done"
    case cancel = "spicy.action.cancel"
    case confirm = "spicy.action.confirm"
    case retry = "spicy.action.retry"

    // Features
    case featureAccount = "spicy.feature.account"
    case featurePro = "spicy.feature.pro"
    case featureLicense = "spicy.feature.license"
    case featureSettings = "spicy.feature.settings"
    case featureLanguage = "spicy.feature.language"
    case featureAppearance = "spicy.feature.appearance"
    case featureInformation = "spicy.feature.information"
    case featureHelp = "spicy.feature.help"
    case featureAbout = "spicy.feature.about"

    // Settings
    case settingsTitle = "spicy.settings.title"
    case settingsSectionGeneral = "spicy.settings.section.general"
    case settingsSectionInterface = "spicy.settings.section.interface"
    case settingsSectionAccessibility = "spicy.settings.section.accessibility"
    case settingsSectionAbout = "spicy.settings.section.about"
    case settingsLanguage = "spicy.settings.language"
    case settingsAppearance = "spicy.settings.appearance"
    case settingsAppearanceSystem = "spicy.settings.appearance.system"
    case settingsAppearanceLight = "spicy.settings.appearance.light"
    case settingsAppearanceDark = "spicy.settings.appearance.dark"
    case settingsOverlayVisible = "spicy.settings.overlay.visible"
    case settingsReduceAnimation = "spicy.settings.reduce.animation"
    case settingsLargeTouchTargets = "spicy.settings.large.touch.targets"
    case settingsVersion = "spicy.settings.version"
    case settingsHostVersion = "spicy.settings.host.version"

    // Account / PRO / license
    case accountTitle = "spicy.account.title"
    case accountSignedOut = "spicy.account.signed.out"
    case accountSignedOutDetail = "spicy.account.signed.out.detail"
    case accountSignIn = "spicy.account.sign.in"
    case accountSignOut = "spicy.account.sign.out"
    case accountProTitle = "spicy.account.pro.title"
    case accountProUnknown = "spicy.account.pro.unknown"
    case accountLicenseTitle = "spicy.account.license.title"
    case accountLicenseUnverified = "spicy.account.license.unverified"
    case accountBackendUnconfigured = "spicy.account.backend.unconfigured"

    // About / info
    case aboutTitle = "spicy.about.title"
    case aboutBody = "spicy.about.body"
    case aboutHostNotice = "spicy.about.host.notice"

    // Errors / empty
    case errorGeneric = "spicy.error.generic"
    case errorNetwork = "spicy.error.network"
    case emptyState = "spicy.empty.state"
    case loading = "spicy.loading"

    // Accessibility
    case a11yLogo = "spicy.a11y.logo"
    case a11yCloseHint = "spicy.a11y.close.hint"
    case a11ySettingsHint = "spicy.a11y.settings.hint"
    case a11yFeatureHint = "spicy.a11y.feature.hint"
    case a11yStateActive = "spicy.a11y.state.active"
    case a11yStateInactive = "spicy.a11y.state.inactive"
    case a11yStateDisabled = "spicy.a11y.state.disabled"
    case a11yStateLoading = "spicy.a11y.state.loading"
}

public final class SpicyLocalization {

    public static let shared = SpicyLocalization()

    public static let languageDidChangeNotification = Notification.Name("SpicyLocalizationLanguageDidChange")

    private static let storageKey = "mrspicy.language"

    public private(set) var language: SpicyLanguage

    private let defaults: UserDefaults
    private let bundle: Bundle

    public init(defaults: UserDefaults = .standard, bundle: Bundle = Bundle(for: SpicyLocalization.self)) {
        self.defaults = defaults
        self.bundle = bundle
        if let stored = defaults.string(forKey: Self.storageKey), let lang = SpicyLanguage(rawValue: stored) {
            self.language = lang
        } else {
            let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
            self.language = preferred.hasPrefix("ar") ? .arabic : .english
        }
    }

    public func setLanguage(_ language: SpicyLanguage) {
        guard language != self.language else { return }
        self.language = language
        defaults.set(language.rawValue, forKey: Self.storageKey)
        NotificationCenter.default.post(name: Self.languageDidChangeNotification, object: self)
    }

    public func string(_ key: SpicyStringKey) -> String {
        if let path = bundle.path(forResource: language.rawValue, ofType: "lproj"),
           let localized = Bundle(path: path)?.localizedString(forKey: key.rawValue, value: nil, table: "MrSpicy"),
           localized != key.rawValue {
            return localized
        }
        return Self.fallback[language]?[key] ?? Self.fallback[.english]?[key] ?? key.rawValue
    }

    public func string(_ key: SpicyStringKey, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: language.locale, arguments: arguments)
    }

    public var isRTL: Bool { language.isRTL }

    public var semanticContentAttribute: UISemanticContentAttribute {
        language.isRTL ? .forceRightToLeft : .forceLeftToRight
    }
}

// MARK: - In-code fallback catalogue (authoritative key coverage)

extension SpicyLocalization {

    static let fallback: [SpicyLanguage: [SpicyStringKey: String]] = [
        .english: [
            .appTitle: "MR. SPICY",
            .appSubtitle: "Customization layer",
            .statusReady: "Ready",
            .statusUnavailable: "Unavailable",
            .close: "Close",
            .minimize: "Minimize",
            .expand: "Expand",
            .settings: "Settings",
            .done: "Done",
            .cancel: "Cancel",
            .confirm: "Confirm",
            .retry: "Retry",
            .featureAccount: "Account",
            .featurePro: "PRO",
            .featureLicense: "License",
            .featureSettings: "Settings",
            .featureLanguage: "Language",
            .featureAppearance: "Appearance",
            .featureInformation: "Information",
            .featureHelp: "Help",
            .featureAbout: "About",
            .settingsTitle: "Settings",
            .settingsSectionGeneral: "General",
            .settingsSectionInterface: "Interface",
            .settingsSectionAccessibility: "Accessibility",
            .settingsSectionAbout: "About",
            .settingsLanguage: "Language",
            .settingsAppearance: "Appearance",
            .settingsAppearanceSystem: "System",
            .settingsAppearanceLight: "Light",
            .settingsAppearanceDark: "Dark",
            .settingsOverlayVisible: "Show overlay",
            .settingsReduceAnimation: "Reduce animation",
            .settingsLargeTouchTargets: "Larger touch targets",
            .settingsVersion: "MR. SPICY version",
            .settingsHostVersion: "Host version",
            .accountTitle: "Account",
            .accountSignedOut: "Signed out",
            .accountSignedOutDetail: "No account is connected to this device.",
            .accountSignIn: "Sign in",
            .accountSignOut: "Sign out",
            .accountProTitle: "PRO status",
            .accountProUnknown: "Not verified",
            .accountLicenseTitle: "License",
            .accountLicenseUnverified: "Not verified",
            .accountBackendUnconfigured: "No entitlement service is configured, so account, PRO and license status cannot be verified.",
            .aboutTitle: "About MR. SPICY",
            .aboutBody: "MR. SPICY is a customization and interface layer. It is not the host game and does not alter gameplay.",
            .aboutHostNotice: "Host application: 8 Ball Pool",
            .errorGeneric: "Something went wrong.",
            .errorNetwork: "No network connection.",
            .emptyState: "Nothing to show here yet.",
            .loading: "Loading…",
            .a11yLogo: "MR. SPICY logo",
            .a11yCloseHint: "Closes the MR. SPICY overlay.",
            .a11ySettingsHint: "Opens MR. SPICY settings.",
            .a11yFeatureHint: "Opens this section.",
            .a11yStateActive: "Active",
            .a11yStateInactive: "Inactive",
            .a11yStateDisabled: "Disabled",
            .a11yStateLoading: "Loading",
        ],
        .arabic: [
            .appTitle: "مستر سبايسي",
            .appSubtitle: "طبقة التخصيص",
            .statusReady: "جاهز",
            .statusUnavailable: "غير متاح",
            .close: "إغلاق",
            .minimize: "تصغير",
            .expand: "توسيع",
            .settings: "الإعدادات",
            .done: "تم",
            .cancel: "إلغاء",
            .confirm: "تأكيد",
            .retry: "إعادة المحاولة",
            .featureAccount: "الحساب",
            .featurePro: "النسخة الاحترافية",
            .featureLicense: "الترخيص",
            .featureSettings: "الإعدادات",
            .featureLanguage: "اللغة",
            .featureAppearance: "المظهر",
            .featureInformation: "معلومات",
            .featureHelp: "المساعدة",
            .featureAbout: "حول",
            .settingsTitle: "الإعدادات",
            .settingsSectionGeneral: "عام",
            .settingsSectionInterface: "الواجهة",
            .settingsSectionAccessibility: "إمكانية الوصول",
            .settingsSectionAbout: "حول",
            .settingsLanguage: "اللغة",
            .settingsAppearance: "المظهر",
            .settingsAppearanceSystem: "النظام",
            .settingsAppearanceLight: "فاتح",
            .settingsAppearanceDark: "داكن",
            .settingsOverlayVisible: "إظهار الطبقة",
            .settingsReduceAnimation: "تقليل الحركة",
            .settingsLargeTouchTargets: "مساحات لمس أكبر",
            .settingsVersion: "إصدار مستر سبايسي",
            .settingsHostVersion: "إصدار التطبيق المضيف",
            .accountTitle: "الحساب",
            .accountSignedOut: "غير مسجل الدخول",
            .accountSignedOutDetail: "لا يوجد حساب متصل بهذا الجهاز.",
            .accountSignIn: "تسجيل الدخول",
            .accountSignOut: "تسجيل الخروج",
            .accountProTitle: "حالة النسخة الاحترافية",
            .accountProUnknown: "غير مُتحقق منها",
            .accountLicenseTitle: "الترخيص",
            .accountLicenseUnverified: "غير مُتحقق منه",
            .accountBackendUnconfigured: "لا توجد خدمة تحقق مُهيأة، لذلك لا يمكن التحقق من الحساب أو النسخة الاحترافية أو الترخيص.",
            .aboutTitle: "حول مستر سبايسي",
            .aboutBody: "مستر سبايسي طبقة تخصيص وواجهة. إنه ليس اللعبة المضيفة ولا يغيّر طريقة اللعب.",
            .aboutHostNotice: "التطبيق المضيف: 8 Ball Pool",
            .errorGeneric: "حدث خطأ ما.",
            .errorNetwork: "لا يوجد اتصال بالشبكة.",
            .emptyState: "لا يوجد شيء لعرضه بعد.",
            .loading: "جارٍ التحميل…",
            .a11yLogo: "شعار مستر سبايسي",
            .a11yCloseHint: "يغلق طبقة مستر سبايسي.",
            .a11ySettingsHint: "يفتح إعدادات مستر سبايسي.",
            .a11yFeatureHint: "يفتح هذا القسم.",
            .a11yStateActive: "مفعّل",
            .a11yStateInactive: "غير مفعّل",
            .a11yStateDisabled: "معطّل",
            .a11yStateLoading: "جارٍ التحميل",
        ],
    ]
}

public func SpicyText(_ key: SpicyStringKey) -> String {
    SpicyLocalization.shared.string(key)
}
