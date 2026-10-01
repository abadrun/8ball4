//
//  SpicySettingsView.swift
//  MR. SPICY
//
//  Structured settings surface. Every control is bound to a real stored
//  preference in SpicySettingsState — no decorative switches that claim to
//  change something the layer does not actually change.
//

import UIKit

public protocol SpicySettingsViewDelegate: AnyObject {
    func settingsView(_ view: SpicySettingsView, didEmit intent: SpicyIntent)
}

public final class SpicySettingsView: UIView {

    public enum Item {
        case segmented(key: SpicyStringKey, options: [String], selectedIndex: Int, onChange: (Int) -> Void)
        case toggle(key: SpicyStringKey, isOn: Bool, onChange: (Bool) -> Void)
        case info(key: SpicyStringKey, value: String)
    }

    public struct Section {
        public let titleKey: SpicyStringKey
        public let items: [Item]
        public init(titleKey: SpicyStringKey, items: [Item]) {
            self.titleKey = titleKey
            self.items = items
        }
    }

    public weak var delegate: SpicySettingsViewDelegate?

    private let stack = UIStackView()
    private var state: SpicySettingsState
    private let hostVersion: String
    private let layerVersion: String

    public init(state: SpicySettingsState,
                layerVersion: String = SpicyVersion.current,
                hostVersion: String = SpicyVersion.hostVersionDescription) {
        self.state = state
        self.layerVersion = layerVersion
        self.hostVersion = hostVersion
        super.init(frame: .zero)
        build()
        reload()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private func build() {
        stack.axis = .vertical
        stack.spacing = SpicyTheme.Spacing.xl
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute
        stack.semanticContentAttribute = semanticContentAttribute
    }

    public func update(state: SpicySettingsState) {
        self.state = state
        reload()
    }

    private func sections() -> [Section] {
        let l10n = SpicyLocalization.shared
        let languages = SpicyLanguage.allCases
        let appearances = SpicySettingsState.Appearance.allCases

        return [
            Section(titleKey: .settingsSectionGeneral, items: [
                .segmented(
                    key: .settingsLanguage,
                    options: languages.map(\.displayName),
                    selectedIndex: languages.firstIndex(of: state.language) ?? 0,
                    onChange: { [weak self] index in
                        guard let self else { return }
                        self.delegate?.settingsView(self, didEmit: .setLanguage(languages[index]))
                    }
                ),
            ]),
            Section(titleKey: .settingsSectionInterface, items: [
                .segmented(
                    key: .settingsAppearance,
                    options: [l10n.string(.settingsAppearanceSystem),
                              l10n.string(.settingsAppearanceLight),
                              l10n.string(.settingsAppearanceDark)],
                    selectedIndex: appearances.firstIndex(of: state.appearance) ?? 0,
                    onChange: { [weak self] index in
                        guard let self else { return }
                        self.delegate?.settingsView(self, didEmit: .setAppearance(appearances[index]))
                    }
                ),
                .toggle(key: .settingsOverlayVisible, isOn: state.overlayVisible, onChange: { [weak self] value in
                    guard let self else { return }
                    self.delegate?.settingsView(self, didEmit: .setOverlayVisible(value))
                }),
            ]),
            Section(titleKey: .settingsSectionAccessibility, items: [
                .toggle(key: .settingsReduceAnimation, isOn: state.reduceAnimation, onChange: { [weak self] value in
                    guard let self else { return }
                    self.delegate?.settingsView(self, didEmit: .setReduceAnimation(value))
                }),
                .toggle(key: .settingsLargeTouchTargets, isOn: state.largeTouchTargets, onChange: { [weak self] value in
                    guard let self else { return }
                    self.delegate?.settingsView(self, didEmit: .setLargeTouchTargets(value))
                }),
            ]),
            Section(titleKey: .settingsSectionAbout, items: [
                .info(key: .settingsVersion, value: layerVersion),
                .info(key: .settingsHostVersion, value: hostVersion),
            ]),
        ]
    }

    private func reload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let l10n = SpicyLocalization.shared
        for section in sections() {
            let header = SpicyModalContent.caption(l10n.string(section.titleKey).uppercased(with: l10n.language.locale))
            header.accessibilityTraits = .header
            let sectionStack = UIStackView(arrangedSubviews: [header])
            sectionStack.axis = .vertical
            sectionStack.spacing = SpicyTheme.Spacing.s
            sectionStack.semanticContentAttribute = l10n.semanticContentAttribute
            section.items.forEach { sectionStack.addArrangedSubview(view(for: $0)) }
            stack.addArrangedSubview(sectionStack)
        }
    }

    private func view(for item: Item) -> UIView {
        let l10n = SpicyLocalization.shared
        switch item {
        case .segmented(let key, let options, let selectedIndex, let onChange):
            let title = SpicyModalContent.body(l10n.string(key))
            let control = UISegmentedControl(items: options)
            control.selectedSegmentIndex = selectedIndex
            control.semanticContentAttribute = l10n.semanticContentAttribute
            control.accessibilityLabel = l10n.string(key)
            control.addAction(UIAction { [weak control] _ in
                guard let control, control.selectedSegmentIndex >= 0 else { return }
                onChange(control.selectedSegmentIndex)
            }, for: .valueChanged)
            control.heightAnchor.constraint(greaterThanOrEqualToConstant: SpicyTheme.Metrics.minimumTouchTarget - 8).isActive = true
            let v = UIStackView(arrangedSubviews: [title, control])
            v.axis = .vertical
            v.spacing = SpicyTheme.Spacing.s
            return v

        case .toggle(let key, let isOn, let onChange):
            let title = SpicyModalContent.body(l10n.string(key))
            let toggle = UISwitch()
            toggle.isOn = isOn
            toggle.onTintColor = SpicyTheme.Color.accent
            toggle.setContentHuggingPriority(.required, for: .horizontal)
            toggle.addAction(UIAction { [weak toggle] _ in
                guard let toggle else { return }
                onChange(toggle.isOn)
            }, for: .valueChanged)
            let row = UIStackView(arrangedSubviews: [title, toggle])
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = SpicyTheme.Spacing.m
            row.semanticContentAttribute = l10n.semanticContentAttribute
            row.isAccessibilityElement = true
            row.accessibilityTraits = .button
            row.accessibilityLabel = l10n.string(key)
            row.accessibilityValue = isOn ? l10n.string(.a11yStateActive) : l10n.string(.a11yStateInactive)
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: SpicyTheme.Metrics.minimumTouchTarget).isActive = true
            return row

        case .info(let key, let value):
            return SpicyModalContent.row(title: l10n.string(key), value: value)
        }
    }
}
