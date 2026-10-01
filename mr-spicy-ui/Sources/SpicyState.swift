//
//  SpicyState.swift
//  MR. SPICY
//
//  Single explicit state model for the whole customization layer.
//  Views never own state; they render it and emit intents.
//

import Foundation

public enum SpicyOverlayPresentation: Equatable {
    case closed
    case minimized
    case expanded
}

public enum SpicyFeature: String, CaseIterable, Equatable {
    case account, pro, license, settings, language, appearance, information, help, about

    public var titleKey: SpicyStringKey {
        switch self {
        case .account: return .featureAccount
        case .pro: return .featurePro
        case .license: return .featureLicense
        case .settings: return .featureSettings
        case .language: return .featureLanguage
        case .appearance: return .featureAppearance
        case .information: return .featureInformation
        case .help: return .featureHelp
        case .about: return .featureAbout
        }
    }

    /// SF Symbol name — direction-neutral symbols only, so RTL needs no mirroring.
    public var systemImageName: String {
        switch self {
        case .account: return "person.crop.circle"
        case .pro: return "star.circle"
        case .license: return "checkmark.seal"
        case .settings: return "gearshape"
        case .language: return "globe"
        case .appearance: return "paintpalette"
        case .information: return "info.circle"
        case .help: return "questionmark.circle"
        case .about: return "doc.text"
        }
    }
}

public enum SpicyControlState: Equatable {
    case normal
    case selected
    case disabled
    case loading
    case unavailable
}

public enum SpicyModalKind: Equatable {
    case information
    case settings
    case account
    case language
    case license
    case about
    case confirmation(message: String)
}

public enum SpicyEntitlementStatus: Equatable {
    /// No entitlement/backend service is configured. The honest default.
    case unconfigured
    case unverified
    case verified(identifier: String, expiry: Date?)
    case failed(reason: String)

    public var isAuthoritative: Bool {
        if case .verified = self { return true }
        return false
    }
}

public struct SpicyAccountState: Equatable {
    public var isSignedIn: Bool
    public var displayName: String?
    public var pro: SpicyEntitlementStatus
    public var license: SpicyEntitlementStatus

    /// Default state: nothing verified, nothing claimed.
    public static let unconfigured = SpicyAccountState(
        isSignedIn: false, displayName: nil, pro: .unconfigured, license: .unconfigured
    )

    public init(isSignedIn: Bool, displayName: String?, pro: SpicyEntitlementStatus, license: SpicyEntitlementStatus) {
        self.isSignedIn = isSignedIn
        self.displayName = displayName
        self.pro = pro
        self.license = license
    }
}

public struct SpicySettingsState: Equatable {
    public enum Appearance: String, CaseIterable { case system, light, dark }

    public var language: SpicyLanguage
    public var appearance: Appearance
    public var overlayVisible: Bool
    public var reduceAnimation: Bool
    public var largeTouchTargets: Bool

    public static let `default` = SpicySettingsState(
        language: SpicyLocalization.shared.language,
        appearance: .system,
        overlayVisible: true,
        reduceAnimation: false,
        largeTouchTargets: false
    )

    public init(language: SpicyLanguage, appearance: Appearance, overlayVisible: Bool,
                reduceAnimation: Bool, largeTouchTargets: Bool) {
        self.language = language
        self.appearance = appearance
        self.overlayVisible = overlayVisible
        self.reduceAnimation = reduceAnimation
        self.largeTouchTargets = largeTouchTargets
    }
}

public struct SpicyState: Equatable {
    public var presentation: SpicyOverlayPresentation = .closed
    public var selectedFeature: SpicyFeature?
    public var presentedModal: SpicyModalKind?
    public var account: SpicyAccountState = .unconfigured
    public var settings: SpicySettingsState = .default
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init() {}
}

public enum SpicyIntent: Equatable {
    case open
    case close
    case minimize
    case expand
    case selectFeature(SpicyFeature)
    case dismissModal
    case setLanguage(SpicyLanguage)
    case setAppearance(SpicySettingsState.Appearance)
    case setOverlayVisible(Bool)
    case setReduceAnimation(Bool)
    case setLargeTouchTargets(Bool)
    case clearError
}

/// Pure reducer: deterministic, testable, no UIKit dependency.
public enum SpicyReducer {

    public static func reduce(_ state: SpicyState, _ intent: SpicyIntent) -> SpicyState {
        var next = state
        switch intent {
        case .open, .expand:
            next.presentation = .expanded
        case .close:
            next.presentation = .closed
            next.presentedModal = nil
            next.selectedFeature = nil
        case .minimize:
            next.presentation = .minimized
            next.presentedModal = nil
        case .selectFeature(let feature):
            next.selectedFeature = feature
            next.presentedModal = modal(for: feature)
        case .dismissModal:
            next.presentedModal = nil
            next.selectedFeature = nil
        case .setLanguage(let language):
            next.settings.language = language
        case .setAppearance(let appearance):
            next.settings.appearance = appearance
        case .setOverlayVisible(let visible):
            next.settings.overlayVisible = visible
            if !visible { next.presentation = .closed }
        case .setReduceAnimation(let value):
            next.settings.reduceAnimation = value
        case .setLargeTouchTargets(let value):
            next.settings.largeTouchTargets = value
        case .clearError:
            next.errorMessage = nil
        }
        return next
    }

    static func modal(for feature: SpicyFeature) -> SpicyModalKind {
        switch feature {
        case .account, .pro: return .account
        case .license: return .license
        case .settings, .appearance: return .settings
        case .language: return .language
        case .information, .help: return .information
        case .about: return .about
        }
    }
}
