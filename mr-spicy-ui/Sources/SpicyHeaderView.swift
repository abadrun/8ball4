//
//  SpicyHeaderView.swift
//  MR. SPICY
//
//  Overlay header: brand logo, title, status, optional minimize/settings/close.
//  Safe-area aware, RTL-correct, Dynamic Type aware.
//

import UIKit

public protocol SpicyHeaderViewDelegate: AnyObject {
    func headerViewDidTapClose(_ header: SpicyHeaderView)
    func headerViewDidTapMinimize(_ header: SpicyHeaderView)
    func headerViewDidTapSettings(_ header: SpicyHeaderView)
}

public final class SpicyHeaderView: UIView {

    public struct Configuration {
        public var showsMinimize: Bool
        public var showsSettings: Bool
        public var showsClose: Bool

        public init(showsMinimize: Bool = true, showsSettings: Bool = true, showsClose: Bool = true) {
            self.showsMinimize = showsMinimize
            self.showsSettings = showsSettings
            self.showsClose = showsClose
        }

        public static let `default` = Configuration()
    }

    public weak var delegate: SpicyHeaderViewDelegate?

    public var statusText: String? {
        didSet { subtitleLabel.text = statusText }
    }

    private let logoView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textStack = UIStackView()
    private let actionStack = UIStackView()
    private let contentStack = UIStackView()
    private let separator = UIView()

    private let minimizeButton = SpicyHeaderView.makeButton(symbol: "minus")
    private let settingsButton = SpicyHeaderView.makeButton(symbol: "gearshape")
    private let closeButton = SpicyHeaderView.makeButton(symbol: "xmark")

    private let configuration: Configuration

    public init(configuration: Configuration = .default, logo: UIImage? = SpicyBrand.logo) {
        self.configuration = configuration
        super.init(frame: .zero)
        build(logo: logo)
        applyLocalization()
        NotificationCenter.default.addObserver(
            self, selector: #selector(applyLocalization),
            name: SpicyLocalization.languageDidChangeNotification, object: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private static func makeButton(symbol: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbol), for: .normal)
        button.tintColor = SpicyTheme.Color.textSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: SpicyTheme.Metrics.minimumTouchTarget),
            button.heightAnchor.constraint(equalToConstant: SpicyTheme.Metrics.minimumTouchTarget),
        ])
        return button
    }

    private func build(logo: UIImage?) {
        backgroundColor = SpicyTheme.Color.surface

        logoView.image = logo
        logoView.contentMode = .scaleAspectFit   // never distort the brand asset
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.setContentHuggingPriority(.required, for: .horizontal)
        logoView.isAccessibilityElement = true
        logoView.accessibilityTraits = .image

        titleLabel.font = SpicyTheme.Typography.headline()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = SpicyTheme.Color.textPrimary
        titleLabel.numberOfLines = 1
        titleLabel.allowsDefaultTighteningForTruncation = true

        subtitleLabel.font = SpicyTheme.Typography.caption()
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = SpicyTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 1

        textStack.axis = .vertical
        textStack.spacing = SpicyTheme.Spacing.xxs
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        actionStack.axis = .horizontal
        actionStack.spacing = SpicyTheme.Spacing.xxs
        actionStack.alignment = .center
        if configuration.showsSettings { actionStack.addArrangedSubview(settingsButton) }
        if configuration.showsMinimize { actionStack.addArrangedSubview(minimizeButton) }
        if configuration.showsClose { actionStack.addArrangedSubview(closeButton) }

        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = SpicyTheme.Spacing.m
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(logoView)
        contentStack.addArrangedSubview(textStack)
        contentStack.addArrangedSubview(actionStack)

        separator.backgroundColor = SpicyTheme.Color.separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStack)
        addSubview(separator)

        NSLayoutConstraint.activate([
            logoView.heightAnchor.constraint(equalToConstant: SpicyTheme.Metrics.logoHeight),
            logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor),

            contentStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: SpicyTheme.Spacing.l),
            contentStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -SpicyTheme.Spacing.s),
            contentStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: SpicyTheme.Spacing.s),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SpicyTheme.Spacing.s),
            heightAnchor.constraint(greaterThanOrEqualToConstant: SpicyTheme.Metrics.headerHeight),

            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: SpicyTheme.Border.hairline),
        ])

        closeButton.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        minimizeButton.addTarget(self, action: #selector(tapMinimize), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(tapSettings), for: .touchUpInside)
    }

    @objc public func applyLocalization() {
        let l10n = SpicyLocalization.shared
        titleLabel.text = l10n.string(.appTitle)
        subtitleLabel.text = statusText ?? l10n.string(.appSubtitle)

        // True RTL: the whole stack flips, text alignment follows the language.
        semanticContentAttribute = l10n.semanticContentAttribute
        contentStack.semanticContentAttribute = l10n.semanticContentAttribute
        actionStack.semanticContentAttribute = l10n.semanticContentAttribute
        let alignment: NSTextAlignment = l10n.isRTL ? .right : .left
        titleLabel.textAlignment = alignment
        subtitleLabel.textAlignment = alignment

        logoView.accessibilityLabel = l10n.string(.a11yLogo)
        closeButton.accessibilityLabel = l10n.string(.close)
        closeButton.accessibilityHint = l10n.string(.a11yCloseHint)
        minimizeButton.accessibilityLabel = l10n.string(.minimize)
        settingsButton.accessibilityLabel = l10n.string(.settings)
        settingsButton.accessibilityHint = l10n.string(.a11ySettingsHint)

        // Logical focus order: brand, then text, then actions.
        accessibilityElements = [logoView, titleLabel, subtitleLabel] + actionStack.arrangedSubviews
    }

    @objc private func tapClose() { delegate?.headerViewDidTapClose(self) }
    @objc private func tapMinimize() { delegate?.headerViewDidTapMinimize(self) }
    @objc private func tapSettings() { delegate?.headerViewDidTapSettings(self) }
}
