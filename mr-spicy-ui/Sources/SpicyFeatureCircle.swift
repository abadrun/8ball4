//
//  SpicyFeatureCircle.swift
//  MR. SPICY
//
//  Reusable circular feature control: icon + title (+ optional subtitle),
//  with normal / selected / disabled / loading / unavailable states,
//  full VoiceOver support and RTL-correct layout.
//

import UIKit

public protocol SpicyFeatureCircleDelegate: AnyObject {
    func featureCircleDidActivate(_ circle: SpicyFeatureCircle)
}

public final class SpicyFeatureCircle: UIControl {

    public let feature: SpicyFeature
    public weak var delegate: SpicyFeatureCircleDelegate?

    public var controlState: SpicyControlState = .normal {
        didSet { guard controlState != oldValue else { return }; applyState(animated: true) }
    }

    public var subtitle: String? {
        didSet { subtitleLabel.text = subtitle; subtitleLabel.isHidden = (subtitle?.isEmpty ?? true) }
    }

    private let circleView = UIView()
    private let iconView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()
    private var diameterConstraint: NSLayoutConstraint!

    public init(feature: SpicyFeature, compact: Bool = false) {
        self.feature = feature
        super.init(frame: .zero)
        build(compact: compact)
        applyLocalization()
        applyState(animated: false)
        NotificationCenter.default.addObserver(
            self, selector: #selector(applyLocalization),
            name: SpicyLocalization.languageDidChangeNotification, object: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    // MARK: - Build

    private func build(compact: Bool) {
        let diameter = compact ? SpicyTheme.Metrics.featureCircleCompactDiameter
                               : SpicyTheme.Metrics.featureCircleDiameter

        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = diameter / 2
        circleView.layer.cornerCurve = .continuous
        circleView.layer.borderWidth = SpicyTheme.Border.regular
        circleView.isUserInteractionEnabled = false
        SpicyTheme.Shadow.card.apply(to: circleView.layer)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: SpicyTheme.Metrics.iconSize, weight: .semibold
        )
        iconView.image = UIImage(systemName: feature.systemImageName)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true

        titleLabel.font = SpicyTheme.Typography.caption()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.textColor = SpicyTheme.Color.textSecondary

        subtitleLabel.font = SpicyTheme.Typography.caption()
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textColor = SpicyTheme.Color.textSecondary
        subtitleLabel.isHidden = true

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = SpicyTheme.Spacing.xs
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false

        circleView.addSubview(iconView)
        circleView.addSubview(spinner)
        stack.addArrangedSubview(circleView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        addSubview(stack)

        diameterConstraint = circleView.widthAnchor.constraint(equalToConstant: diameter)
        NSLayoutConstraint.activate([
            diameterConstraint,
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor),
            iconView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            widthAnchor.constraint(greaterThanOrEqualToConstant: SpicyTheme.Metrics.minimumTouchTarget),
            heightAnchor.constraint(greaterThanOrEqualToConstant: SpicyTheme.Metrics.minimumTouchTarget),
        ])

        addTarget(self, action: #selector(handleTouchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(handleTouchUpOutside), for: [.touchDragExit, .touchCancel])
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    // MARK: - Localization / direction

    @objc public func applyLocalization() {
        let l10n = SpicyLocalization.shared
        titleLabel.text = l10n.string(feature.titleKey)
        semanticContentAttribute = l10n.semanticContentAttribute
        stack.semanticContentAttribute = l10n.semanticContentAttribute
        let alignment: NSTextAlignment = .center
        titleLabel.textAlignment = alignment
        subtitleLabel.textAlignment = alignment
        updateAccessibility()
    }

    // MARK: - State

    private func applyState(animated: Bool) {
        let apply = { [self] in
            switch controlState {
            case .normal:
                circleView.backgroundColor = SpicyTheme.Color.surfaceElevated
                circleView.layer.borderColor = SpicyTheme.Color.separator.cgColor
                iconView.tintColor = SpicyTheme.Color.accent
                iconView.isHidden = false
                alpha = 1
                isUserInteractionEnabled = true
                spinner.stopAnimating()
            case .selected:
                circleView.backgroundColor = SpicyTheme.Color.accent
                circleView.layer.borderColor = SpicyTheme.Color.accent.cgColor
                iconView.tintColor = SpicyTheme.Color.textOnAccent
                iconView.isHidden = false
                alpha = 1
                isUserInteractionEnabled = true
                spinner.stopAnimating()
            case .disabled, .unavailable:
                circleView.backgroundColor = SpicyTheme.Color.surfaceSunken
                circleView.layer.borderColor = SpicyTheme.Color.separator.cgColor
                iconView.tintColor = SpicyTheme.Color.disabled
                iconView.isHidden = false
                alpha = SpicyTheme.Opacity.disabled
                isUserInteractionEnabled = false
                spinner.stopAnimating()
            case .loading:
                circleView.backgroundColor = SpicyTheme.Color.surfaceElevated
                circleView.layer.borderColor = SpicyTheme.Color.separator.cgColor
                iconView.isHidden = true
                alpha = 1
                isUserInteractionEnabled = false
                spinner.startAnimating()
            }
            titleLabel.textColor = controlState == .selected
                ? SpicyTheme.Color.textPrimary : SpicyTheme.Color.textSecondary
        }

        if animated {
            UIView.animate(withDuration: SpicyTheme.Motion.duration(SpicyTheme.Motion.fast), animations: apply)
        } else {
            apply()
        }
        updateAccessibility()
    }

    private func updateAccessibility() {
        let l10n = SpicyLocalization.shared
        accessibilityLabel = l10n.string(feature.titleKey)
        accessibilityHint = l10n.string(.a11yFeatureHint)
        switch controlState {
        case .normal: accessibilityValue = l10n.string(.a11yStateInactive)
        case .selected: accessibilityValue = l10n.string(.a11yStateActive)
        case .disabled, .unavailable: accessibilityValue = l10n.string(.a11yStateDisabled)
        case .loading: accessibilityValue = l10n.string(.a11yStateLoading)
        }
        var traits: UIAccessibilityTraits = .button
        if controlState == .selected { traits.insert(.selected) }
        if controlState == .disabled || controlState == .unavailable { traits.insert(.notEnabled) }
        accessibilityTraits = traits
    }

    // MARK: - Interaction

    @objc private func handleTouchDown() {
        UIView.animate(withDuration: SpicyTheme.Motion.duration(SpicyTheme.Motion.fast)) {
            self.circleView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            self.circleView.alpha = SpicyTheme.Opacity.pressed
        }
    }

    @objc private func handleTouchUpOutside() { resetPress() }

    @objc private func handleTap() {
        resetPress()
        delegate?.featureCircleDidActivate(self)
        sendActions(for: .primaryActionTriggered)
    }

    private func resetPress() {
        UIView.animate(withDuration: SpicyTheme.Motion.duration(SpicyTheme.Motion.fast)) {
            self.circleView.transform = .identity
            self.circleView.alpha = 1
        }
    }

    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        if previous?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyState(animated: false)
        }
    }
}
