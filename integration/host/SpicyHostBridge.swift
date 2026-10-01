//
//  SpicyHostBridge.swift
//  MR. SPICY — host integration layer (host-specific, deliberately thin).
//
//  Everything host-specific lives here. mr-spicy-ui/Sources has no knowledge
//  of 8 Ball Pool, which is what makes the layer reusable on future
//  AUTHORIZED host versions.
//
//  This bridge requires an authorized build of the host that links MrSpicyUI
//  as a normal framework and calls `install(in:)` from the host's own code.
//  It performs NO runtime injection, NO method swizzling of host internals,
//  NO binary patching and NO modification of the shipped IPA.
//

import UIKit

public struct SpicyHostDescriptor: Equatable {
    public let bundleIdentifier: String
    public let shortVersion: String
    public let build: String

    public init(bundleIdentifier: String, shortVersion: String, build: String) {
        self.bundleIdentifier = bundleIdentifier
        self.shortVersion = shortVersion
        self.build = build
    }

    public static func current(bundle: Bundle = .main) -> SpicyHostDescriptor {
        SpicyHostDescriptor(
            bundleIdentifier: bundle.bundleIdentifier ?? "",
            shortVersion: bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            build: bundle.infoDictionary?["CFBundleVersion"] as? String ?? ""
        )
    }
}

public enum SpicyHostCompatibility: Equatable {
    case validated
    case requiresReview(reason: String)
    case unsupported(reason: String)
}

public enum SpicyHostBridge {

    /// Compatibility is established per host build and never assumed.
    public static func compatibility(for host: SpicyHostDescriptor) -> SpicyHostCompatibility {
        guard host.bundleIdentifier == SpicyVersion.validatedHostBundleIdentifier else {
            return .unsupported(reason: "Unknown host bundle identifier: \(host.bundleIdentifier)")
        }
        if SpicyVersion.isValidated(hostShortVersion: host.shortVersion, build: host.build) {
            return .validated
        }
        return .requiresReview(reason: "Host \(host.shortVersion) (\(host.build)) has not been inspected or regression-tested.")
    }

    /// Installs the overlay into a host-provided window.
    /// Returns nil when compatibility has not been established for this build.
    @discardableResult
    public static func install(in window: UIWindow,
                               host: SpicyHostDescriptor = .current(),
                               entitlementProvider: SpicyEntitlementProviding? = nil,
                               allowUnvalidatedHost: Bool = false) -> SpicyOverlayViewController? {
        switch compatibility(for: host) {
        case .unsupported:
            return nil
        case .requiresReview where !allowUnvalidatedHost:
            return nil
        default:
            break
        }

        let overlay = SpicyOverlayViewController(entitlementProvider: entitlementProvider)
        guard let root = window.rootViewController else { return nil }
        root.addChild(overlay)
        overlay.view.frame = root.view.bounds
        overlay.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Above host content, but never swallowing touches outside the card.
        root.view.addSubview(overlay.view)
        overlay.didMove(toParent: root)
        return overlay
    }

    public static func remove(_ overlay: SpicyOverlayViewController) {
        overlay.willMove(toParent: nil)
        overlay.view.removeFromSuperview()
        overlay.removeFromParent()
    }
}
