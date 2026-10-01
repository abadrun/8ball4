//
//  SpicyAccountView.swift
//  MR. SPICY
//
//  Account / PRO / license presentation.
//
//  AUTHORIZATION BOUNDARY: this view only *renders* entitlement state supplied
//  by an authorized provider. It never grants, infers, caches-as-true, or
//  fabricates entitlements. With no provider configured the honest
//  `.unconfigured` state is shown.
//

import UIKit

public protocol SpicyEntitlementProviding: AnyObject {
    /// Implemented only by an authorized backend integration.
    func currentAccountState() -> SpicyAccountState
}

public protocol SpicyAccountViewDelegate: AnyObject {
    func accountViewDidRequestSignIn(_ view: SpicyAccountView)
    func accountViewDidRequestSignOut(_ view: SpicyAccountView)
}

public final class SpicyAccountView: UIView {

    public weak var delegate: SpicyAccountViewDelegate?

    private let stack = UIStackView()
    private var state: SpicyAccountState

    public init(state: SpicyAccountState = .unconfigured) {
        self.state = state
        super.init(frame: .zero)
        stack.axis = .vertical
        stack.spacing = SpicyTheme.Spacing.m
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        reload()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    public func update(state: SpicyAccountState) {
        self.state = state
        reload()
    }

    private func describe(_ status: SpicyEntitlementStatus) -> String {
        let l10n = SpicyLocalization.shared
        switch status {
        case .unconfigured, .unverified:
            return l10n.string(.statusUnavailable)
        case .verified(let identifier, let expiry):
            guard let expiry else { return identifier }
            let formatter = DateFormatter()
            formatter.locale = l10n.language.locale
            formatter.dateStyle = .medium
            return "\(identifier) — \(formatter.string(from: expiry))"
        case .failed:
            return l10n.string(.errorGeneric)
        }
    }

    private func reload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let l10n = SpicyLocalization.shared

        let headline = SpicyModalContent.body(
            state.isSignedIn ? (state.displayName ?? l10n.string(.accountTitle))
                             : l10n.string(.accountSignedOut)
        )
        headline.font = SpicyTheme.Typography.headline()
        stack.addArrangedSubview(headline)

        if !state.isSignedIn {
            stack.addArrangedSubview(SpicyModalContent.caption(l10n.string(.accountSignedOutDetail)))
        }

        stack.addArrangedSubview(SpicyModalContent.row(
            title: l10n.string(.accountProTitle), value: describe(state.pro)
        ))
        stack.addArrangedSubview(SpicyModalContent.row(
            title: l10n.string(.accountLicenseTitle), value: describe(state.license)
        ))

        // Honest disclosure whenever nothing is authoritatively verified.
        if !state.pro.isAuthoritative || !state.license.isAuthoritative {
            let notice = SpicyModalContent.caption(l10n.string(.accountBackendUnconfigured))
            notice.textColor = SpicyTheme.Color.warning
            stack.addArrangedSubview(notice)
        }
    }
}
