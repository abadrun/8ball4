//
//  SpicyOverlayViewController.swift
//  MR. SPICY
//
//  Primary MR. SPICY container. Owns the state, renders header + feature grid
//  + modals, and emits nothing into the host beyond its own view hierarchy.
//  Contains no host business logic, so it is reusable across authorized hosts.
//

import UIKit

public protocol SpicyOverlayDelegate: AnyObject {
    func overlayDidClose(_ overlay: SpicyOverlayViewController)
    func overlay(_ overlay: SpicyOverlayViewController, didChange state: SpicyState)
}

public final class SpicyOverlayViewController: UIViewController {

    public weak var delegate: SpicyOverlayDelegate?
    public private(set) var state = SpicyState()

    private let header = SpicyHeaderView()
    private let container = UIView()
    private let gridStack = UIStackView()
    private var circles: [SpicyFeature: SpicyFeatureCircle] = [:]
    private var presentedModal: SpicyModalView?
    private var entitlementProvider: SpicyEntitlementProviding?

    private let features: [SpicyFeature]
    private let columns = 3

    public init(features: [SpicyFeature] = SpicyFeature.allCases,
                entitlementProvider: SpicyEntitlementProviding? = nil) {
        self.features = features
        self.entitlementProvider = entitlementProvider
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildHierarchy()
        state.account = entitlementProvider?.currentAccountState() ?? .unconfigured
        state.presentation = .expanded
        render()

        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange),
            name: SpicyLocalization.languageDidChangeNotification, object: nil
        )
    }

    private func buildHierarchy() {
        container.backgroundColor = SpicyTheme.Color.surface
        container.layer.cornerRadius = SpicyTheme.Radius.card
        container.layer.cornerCurve = .continuous
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true
        SpicyTheme.Shadow.card.apply(to: container.layer)
        container.layer.masksToBounds = false

        header.delegate = self
        header.translatesAutoresizingMaskIntoConstraints = false

        gridStack.axis = .vertical
        gridStack.spacing = SpicyTheme.Spacing.l
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute

        container.addSubview(header)
        container.addSubview(gridStack)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            container.widthAnchor.constraint(lessThanOrEqualToConstant: SpicyTheme.Metrics.overlayMaxWidth),
            container.widthAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.widthAnchor,
                multiplier: SpicyTheme.Metrics.overlayScreenWidthRatio
            ).withPriority(.defaultHigh),
            container.heightAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor,
                multiplier: SpicyTheme.Metrics.modalScreenHeightRatio
            ),

            header.topAnchor.constraint(equalTo: container.topAnchor),
            header.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            gridStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: SpicyTheme.Spacing.l),
            gridStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: SpicyTheme.Spacing.l),
            gridStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -SpicyTheme.Spacing.l),
            gridStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -SpicyTheme.Spacing.xl),
        ])

        buildGrid()
    }

    private func buildGrid() {
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        circles.removeAll()

        // Compact layout on short/landscape screens.
        let compact = traitCollection.verticalSizeClass == .compact
        let perRow = compact ? min(features.count, 5) : columns

        for chunk in stride(from: 0, to: features.count, by: perRow) {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.alignment = .top
            row.spacing = SpicyTheme.Spacing.m
            row.semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute
            for feature in features[chunk..<min(chunk + perRow, features.count)] {
                let circle = SpicyFeatureCircle(feature: feature, compact: compact)
                circle.delegate = self
                circles[feature] = circle
                row.addArrangedSubview(circle)
            }
            // Keep the last row aligned with full rows.
            let missing = perRow - row.arrangedSubviews.count
            for _ in 0..<max(0, missing) { row.addArrangedSubview(UIView()) }
            gridStack.addArrangedSubview(row)
        }
    }

    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        if previous?.verticalSizeClass != traitCollection.verticalSizeClass {
            buildGrid()
            render()
        }
    }

    // MARK: - State

    public func send(_ intent: SpicyIntent) {
        let next = SpicyReducer.reduce(state, intent)
        guard next != state else { return }
        let previousModal = state.presentedModal
        state = next

        if case .setLanguage(let language) = intent {
            SpicyLocalization.shared.setLanguage(language)
        }
        if case .setAppearance(let appearance) = intent {
            applyAppearance(appearance)
        }

        render(modalChanged: previousModal != state.presentedModal)
        delegate?.overlay(self, didChange: state)
        if state.presentation == .closed { delegate?.overlayDidClose(self) }
    }

    private func applyAppearance(_ appearance: SpicySettingsState.Appearance) {
        switch appearance {
        case .system: overrideUserInterfaceStyle = .unspecified
        case .light: overrideUserInterfaceStyle = .light
        case .dark: overrideUserInterfaceStyle = .dark
        }
    }

    private func render(modalChanged: Bool = true) {
        header.statusText = state.errorMessage ?? SpicyText(.statusReady)

        for (feature, circle) in circles {
            if feature == .pro || feature == .license, !state.account.pro.isAuthoritative {
                // Accurate representation: nothing verified means nothing claimed.
                circle.controlState = state.selectedFeature == feature ? .selected : .normal
                circle.subtitle = SpicyText(.statusUnavailable)
            } else {
                circle.controlState = state.selectedFeature == feature ? .selected : .normal
                circle.subtitle = nil
            }
        }

        guard modalChanged else { return }
        presentedModal?.dismiss(animated: true)
        presentedModal = nil
        guard let kind = state.presentedModal else { return }
        let modal = makeModal(for: kind)
        modal.delegate = self
        modal.present(in: view)
        presentedModal = modal
    }

    private func makeModal(for kind: SpicyModalKind) -> SpicyModalView {
        let l10n = SpicyLocalization.shared
        switch kind {
        case .settings:
            let settings = SpicySettingsView(state: state.settings)
            settings.delegate = self
            return SpicyModalView(kind: kind, title: l10n.string(.settingsTitle), contentViews: [settings],
                                  actions: [.init(identifier: "done", title: l10n.string(.done))])
        case .language:
            let settings = SpicySettingsView(state: state.settings)
            settings.delegate = self
            return SpicyModalView(kind: kind, title: l10n.string(.settingsLanguage), contentViews: [settings],
                                  actions: [.init(identifier: "done", title: l10n.string(.done))])
        case .account, .license:
            let account = SpicyAccountView(state: state.account)
            return SpicyModalView(kind: kind, title: l10n.string(.accountTitle), contentViews: [account],
                                  actions: [.init(identifier: "done", title: l10n.string(.done), style: .secondary)])
        case .about, .information:
            let views = [
                SpicyModalContent.body(l10n.string(.aboutBody)),
                SpicyModalContent.caption(l10n.string(.aboutHostNotice)),
                SpicyModalContent.row(title: l10n.string(.settingsVersion), value: SpicyVersion.current),
                SpicyModalContent.row(title: l10n.string(.settingsHostVersion), value: SpicyVersion.hostVersionDescription),
            ]
            return SpicyModalView(kind: kind, title: l10n.string(.aboutTitle), contentViews: views,
                                  actions: [.init(identifier: "done", title: l10n.string(.done), style: .secondary)])
        case .confirmation(let message):
            return SpicyModalView(kind: kind, title: l10n.string(.confirm),
                                  contentViews: [SpicyModalContent.body(message)],
                                  actions: [
                                    .init(identifier: "cancel", title: l10n.string(.cancel), style: .secondary),
                                    .init(identifier: "confirm", title: l10n.string(.confirm)),
                                  ])
        }
    }

    @objc private func languageDidChange() {
        view.semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute
        gridStack.semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute
        header.applyLocalization()
        circles.values.forEach { $0.applyLocalization() }
        render()
        UIAccessibility.post(notification: .screenChanged, argument: header)
    }
}

// MARK: - Delegates

extension SpicyOverlayViewController: SpicyHeaderViewDelegate {
    public func headerViewDidTapClose(_ header: SpicyHeaderView) { send(.close) }
    public func headerViewDidTapMinimize(_ header: SpicyHeaderView) { send(.minimize) }
    public func headerViewDidTapSettings(_ header: SpicyHeaderView) { send(.selectFeature(.settings)) }
}

extension SpicyOverlayViewController: SpicyFeatureCircleDelegate {
    public func featureCircleDidActivate(_ circle: SpicyFeatureCircle) {
        send(.selectFeature(circle.feature))
    }
}

extension SpicyOverlayViewController: SpicyModalViewDelegate {
    public func modalViewDidRequestDismiss(_ modal: SpicyModalView) { send(.dismissModal) }

    public func modalView(_ modal: SpicyModalView, didTapPrimaryActionWithIdentifier identifier: String) {
        switch identifier {
        case "done", "cancel", "confirm": send(.dismissModal)
        default: break
        }
    }
}

extension SpicyOverlayViewController: SpicySettingsViewDelegate {
    public func settingsView(_ view: SpicySettingsView, didEmit intent: SpicyIntent) {
        send(intent)
        view.update(state: state.settings)
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
