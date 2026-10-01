//
//  SpicyVersion.swift
//  MR. SPICY
//
//  MR. SPICY is versioned independently from the host application.
//

import Foundation

public enum SpicyVersion {
    public static let current = "1.0.0"

    /// Host identity validated during inspection of
    /// original/8-ball-pool-i3rby-IPAOMTK.COM.ipa (see original-manifest.json).
    public static let validatedHostShortVersion = "56.30.0"
    public static let validatedHostBuild = "5328"
    public static let validatedHostBundleIdentifier = "com.miniclip.8ballpoolmult"

    public static var hostVersionDescription: String {
        "\(validatedHostShortVersion) (\(validatedHostBuild))"
    }

    /// Compatibility is never assumed: it must be re-established per host build.
    public static func isValidated(hostShortVersion: String, build: String) -> Bool {
        hostShortVersion == validatedHostShortVersion && build == validatedHostBuild
    }
}
