//
//  SpicyModalView.swift
//  MR. SPICY
//
//  One reusable modal container for every MR. SPICY modal state.
//  Shared typography, spacing, radius, buttons, dismissal, animation,
//  accessibility and RTL behaviour. No component implements its own modal.
//

import UIKit

public protocol SpicyModalViewDelegate: AnyObject {
    func modalViewDidRequestDismiss(_ modal: SpicyModalView)
    func modalView(_ modal: SpicyModalView, didTapPrimaryActionWithIdentifier identifier: String)
}

public final class SpicyModalView: UIView {

    public struct Action {
        public enum Style { case primary, secondary, destructive }
        public let identifier: String
        public let title: String
        public let style: Style
        public let isEnabled: Bool

        public init(identifier: String, title: String, style: Style = .primary, isEnabled: Bool = true) {
            self.identifier = identifier
            self.title = title
            self.style = style
            self.isEnabled = isEnabled
        }
    }

    public weak var delegate: SpicyModalViewDelegate?
    public private(set) var kind: SpicyModalKind

    private let scrim = UIView()
    private let card = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let contentStack = UIStackView()
    private let actionStack = UIStackView()
    private let scrollView = UIScrollView()
    private var cardWidthConstraint: NSLayoutConstraint!

    public init(kind: SpicyModalKind, title: String, contentViews: [UIView], actions: [Action] = []) {
        self.kind = kind
        super.init(frame: .zero)
        build()
        titleLabel.text = title
        contentViews.forEach { contentStack.addArrangedSubview($0) }
        actions.forEach { actionStack.addArrangedSubview(makeButton(for: $0)) }
        actionStack.isHidden = actions.isEmpty
        applyDirection()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private func build() {
        scrim.backgroundColor = SpicyTheme.Color.scrim
        scrim.translatesAutoresizingMaskIntoConstraints = false
        scrim.alpha = 0
        scrim.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(requestDismiss)))
        scrim.accessibilityLabel = SpicyText(.close)

        card.backgroundColor = SpicyTheme.Color.surface
        card.layer.cornerRadius = SpicyTheme.Radius.modal
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false
        SpicyTheme.Shadow.modal.apply(to: card.layer)

        titleLabel.font = SpicyTheme.Typography.title()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = SpicyTheme.Color.textPrimary
        titleLabel.numberOfLines = 2
        titleLabel.accessibilityTraits = .header

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = SpicyTheme.Color.textSecondary
        closeButton.accessibilityLabel = SpicyText(.close)
        closeButton.addTarget(self, action: #selector(requestDismiss), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = SpicyTheme.Spacing.m

        contentStack.axis = .vertical
        contentStack.spacing = SpicyTheme.Spacing.m

        actionStack.axis = .horizontal
        actionStack.distribution = .fillEqually
        actionStack.spacing = SpicyTheme.Spacing.s

        let rootStack = UIStackView(arrangedSubviews: [headerStack, contentStack, actionStack])
        rootStack.axis = .vertical
        rootStack.spacing = SpicyTheme.Spacing.l
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.addSubview(rootStack)

        card.addSubview(scrollView)
        addSubview(scrim)
        addSubview(card)

        cardWidthConstraint = card.widthAnchor.constraint(
            lessThanOrEqualToConstant: SpicyTheme.Metrics.modalMaxWidth
        )

        NSLayoutConstraint.activate([
            scrim.topAnchor.constraint(equalTo: topAnchor),
            scrim.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrim.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrim.trailingAnchor.constraint(equalTo: trailingAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            cardWidthConstraint,
            card.widthAnchor.constraint(
                lessThanOrEqualTo: safeAreaLayoutGuide.widthAnchor,
                multiplier: SpicyTheme.Metrics.overlayScreenWidthRatio
            ),
            card.heightAnchor.constraint(
                lessThanOrEqualTo: safeAreaLayoutGuide.heightAnchor,
                multiplier: SpicyTheme.Metrics.modalScreenHeightRatio
            ),

            scrollView.topAnchor.constraint(equalTo: card.topAnchor, constant: SpicyTheme.Spacing.l),
            scrollView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -SpicyTheme.Spacing.l),
            scrollView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: SpicyTheme.Spacing.l),
            scrollView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -SpicyTheme.Spacing.l),

            rootStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            rootStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            rootStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            rootStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            closeButton.widthAnchor.constraint(equalToConstant: SpicyTheme.Metrics.minimumTouchTarget),
            closeButton.heightAnchor.constraint(equalToConstant: SpicyTheme.Metrics.minimumTouchTarget),
        ])

        // A modal traps VoiceOver focus inside the card.
        accessibilityViewIsModal = true
    }

    private func makeButton(for action: Action) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = action.title
        config.cornerStyle = .fixed
        config.background.cornerRadius = SpicyTheme.Radius.control
        config.contentInsets = NSDirectionalEdgeInsets(
            top: SpicyTheme.Spacing.m, leading: SpicyTheme.Spacing.l,
            bottom: SpicyTheme.Spacing.m, trailing: SpicyTheme.Spacing.l
        )
        switch action.style {
        case .primary:
            config.baseBackgroundColor = SpicyTheme.Color.accent
            config.baseForegroundColor = SpicyTheme.Color.textOnAccent
        case .secondary:
            config.baseBackgroundColor = SpicyTheme.Color.surfaceElevated
            config.baseForegroundColor = SpicyTheme.Color.textPrimary
        case .destructive:
            config.baseBackgroundColor = SpicyTheme.Color.danger
            config.baseForegroundColor = SpicyTheme.Color.textOnAccent
        }

        let button = UIButton(configuration: config)
        button.isEnabled = action.isEnabled
        button.titleLabel?.font = SpicyTheme.Typography.button()
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.accessibilityLabel = action.title
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: SpicyTheme.Metrics.controlHeight).isActive = true
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.modalView(self, didTapPrimaryActionWithIdentifier: action.identifier)
        }, for: .touchUpInside)
        return button
    }

    private func applyDirection() {
        let attribute = SpicyLocalization.shared.semanticContentAttribute
        semanticContentAttribute = attribute
        card.semanticContentAttribute = attribute
        contentStack.semanticContentAttribute = attribute
        // Confirm/cancel ordering mirrors with the writing direction.
        actionStack.semanticContentAttribute = attribute
        titleLabel.textAlignment = SpicyLocalization.shared.isRTL ? .right : .left
    }

    // MARK: - Presentation

    public func present(in container: UIView, animated: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor),
            bottomAnchor.constraint(equalTo: container.bottomAnchor),
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        container.layoutIfNeeded()

        card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        card.alpha = 0
        let duration = SpicyTheme.Motion.duration(animated ? SpicyTheme.Motion.standard : 0)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: SpicyTheme.Motion.springDamping,
                       initialSpringVelocity: SpicyTheme.Motion.springVelocity,
                       options: [.allowUserInteraction]) {
            self.scrim.alpha = 1
            self.card.alpha = 1
            self.card.transform = .identity
        } completion: { _ in
            UIAccessibility.post(notification: .screenChanged, argument: self.titleLabel)
        }
    }

    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let duration = SpicyTheme.Motion.duration(animated ? SpicyTheme.Motion.fast : 0)
        UIView.animate(withDuration: duration) {
            self.scrim.alpha = 0
            self.card.alpha = 0
            self.card.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        } completion: { _ in
            self.removeFromSuperview()
            completion?()
        }
    }

    @objc private func requestDismiss() { delegate?.modalViewDidRequestDismiss(self) }

    public override func accessibilityPerformEscape() -> Bool {
        requestDismiss()
        return true
    }
}

// MARK: - Shared content builders (no duplicated modal implementations)

public enum SpicyModalContent {

    public static func label(_ text: String, style: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = style
        label.textColor = color
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = SpicyLocalization.shared.isRTL ? .right : .left
        return label
    }

    public static func body(_ text: String) -> UILabel {
        label(text, style: SpicyTheme.Typography.body(), color: SpicyTheme.Color.textPrimary)
    }

    public static func caption(_ text: String) -> UILabel {
        label(text, style: SpicyTheme.Typography.caption(), color: SpicyTheme.Color.textSecondary)
    }

    public static func row(title: String, value: String) -> UIView {
        let titleLabel = label(title, style: SpicyTheme.Typography.callout(), color: SpicyTheme.Color.textSecondary)
        let valueLabel = label(value, style: SpicyTheme.Typography.callout(), color: SpicyTheme.Color.textPrimary)
        valueLabel.textAlignment = SpicyLocalization.shared.isRTL ? .left : .right
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = SpicyTheme.Spacing.m
        stack.semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute
        stack.isAccessibilityElement = true
        stack.accessibilityLabel = title
        stack.accessibilityValue = value
        return stack
    }
}
