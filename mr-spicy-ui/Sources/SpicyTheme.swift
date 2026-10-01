//
//  SpicyTheme.swift
//  MR. SPICY — customization layer for the 8 Ball Pool host application.
//
//  Centralized design system. No visual constant used by more than one
//  component may be hard-coded anywhere else in the MR. SPICY layer.
//

import UIKit

public enum SpicyTheme {

    // MARK: - Color

    public enum Color {
        public static let accent = dynamic(light: 0xE2452B, dark: 0xFF5A3C)
        public static let accentMuted = dynamic(light: 0xF0785F, dark: 0xC9442C)
        public static let surface = dynamic(light: 0xFFFFFF, dark: 0x141518)
        public static let surfaceElevated = dynamic(light: 0xF6F6F8, dark: 0x1D1F24)
        public static let surfaceSunken = dynamic(light: 0xECEDF1, dark: 0x0E0F12)
        public static let scrim = UIColor.black.withAlphaComponent(0.45)
        public static let separator = dynamic(light: 0xD9DAE0, dark: 0x2C2F36, alpha: 1.0)
        public static let textPrimary = dynamic(light: 0x101114, dark: 0xF4F5F7)
        public static let textSecondary = dynamic(light: 0x5B5F6B, dark: 0xA3A8B4)
        public static let textOnAccent = UIColor.white
        public static let success = dynamic(light: 0x1E8E52, dark: 0x3FBF7B)
        public static let warning = dynamic(light: 0xB7791F, dark: 0xE2A33A)
        public static let danger = dynamic(light: 0xC0392B, dark: 0xF06A5A)
        public static let disabled = dynamic(light: 0xB6B9C2, dark: 0x4A4E57)

        static func dynamic(light: UInt32, dark: UInt32, alpha: CGFloat = 1.0) -> UIColor {
            UIColor { traits in
                UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light, alpha: alpha)
            }
        }
    }

    // MARK: - Typography (Dynamic Type aware)

    public enum Typography {
        public static func title() -> UIFont { scaled(.title3, weight: .bold) }
        public static func headline() -> UIFont { scaled(.headline, weight: .semibold) }
        public static func body() -> UIFont { scaled(.body, weight: .regular) }
        public static func callout() -> UIFont { scaled(.callout, weight: .medium) }
        public static func caption() -> UIFont { scaled(.caption1, weight: .regular) }
        public static func button() -> UIFont { scaled(.subheadline, weight: .semibold) }

        /// Upper bound so Arabic text expansion plus large accessibility sizes
        /// cannot break compact overlay layouts.
        public static let maximumPointSize: CGFloat = 34

        static func scaled(_ style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
            let base = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
            return UIFontMetrics(forTextStyle: style).scaledFont(for: base, maximumPointSize: maximumPointSize)
        }
    }

    // MARK: - Spacing

    public enum Spacing {
        public static let xxs: CGFloat = 2
        public static let xs: CGFloat = 4
        public static let s: CGFloat = 8
        public static let m: CGFloat = 12
        public static let l: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }

    // MARK: - Radius / Border / Shadow

    public enum Radius {
        public static let control: CGFloat = 10
        public static let card: CGFloat = 16
        public static let modal: CGFloat = 20
        public static let pill: CGFloat = 999
    }

    public enum Border {
        public static let hairline: CGFloat = 1.0 / UIScreen.main.scale
        public static let regular: CGFloat = 1
        public static let emphasis: CGFloat = 2
    }

    public struct Shadow {
        public let color: UIColor
        public let opacity: Float
        public let radius: CGFloat
        public let offset: CGSize

        public static let card = Shadow(color: .black, opacity: 0.12, radius: 10, offset: CGSize(width: 0, height: 4))
        public static let modal = Shadow(color: .black, opacity: 0.22, radius: 24, offset: CGSize(width: 0, height: 10))

        public func apply(to layer: CALayer) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = opacity
            layer.shadowRadius = radius
            layer.shadowOffset = offset
        }
    }

    // MARK: - Metrics

    public enum Metrics {
        /// Apple HIG minimum touch target.
        public static let minimumTouchTarget: CGFloat = 44
        public static let controlHeight: CGFloat = 48
        public static let headerHeight: CGFloat = 56
        public static let iconSize: CGFloat = 22
        public static let featureCircleDiameter: CGFloat = 64
        public static let featureCircleCompactDiameter: CGFloat = 52
        public static let logoHeight: CGFloat = 28
        public static let overlayMaxWidth: CGFloat = 420
        public static let modalMaxWidth: CGFloat = 460
        public static let overlayScreenWidthRatio: CGFloat = 0.92
        public static let modalScreenHeightRatio: CGFloat = 0.8
    }

    // MARK: - Motion

    public enum Motion {
        public static let fast: TimeInterval = 0.18
        public static let standard: TimeInterval = 0.28
        public static let slow: TimeInterval = 0.42
        public static let springDamping: CGFloat = 0.86
        public static let springVelocity: CGFloat = 0.4

        /// Honours Reduce Motion: returns 0 so animations resolve instantly.
        public static func duration(_ value: TimeInterval) -> TimeInterval {
            UIAccessibility.isReduceMotionEnabled ? 0 : value
        }
    }

    public enum Opacity {
        public static let disabled: CGFloat = 0.4
        public static let pressed: CGFloat = 0.72
        public static let scrim: CGFloat = 0.45
    }
}

extension UIColor {
    convenience init(rgb: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
