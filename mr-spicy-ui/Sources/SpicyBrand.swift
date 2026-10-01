//
//  SpicyBrand.swift
//  MR. SPICY
//
//  Single access point for the MR. SPICY brand asset (logo.png).
//  The image is decoded once and cached; callers never re-decode per view.
//

import UIKit

public enum SpicyBrand {

    public static let assetName = "logo"

    /// Source asset: assets/logo.png — 1254x1254, PNG, 8-bit RGB, no alpha channel.
    public static let sourcePixelSize = CGSize(width: 1254, height: 1254)

    private static let cache = NSCache<NSString, UIImage>()

    /// Cached brand logo. Returns nil when the asset is absent from the bundle
    /// rather than substituting a placeholder that would misrepresent branding.
    public static var logo: UIImage? {
        if let cached = cache.object(forKey: assetName as NSString) { return cached }
        let bundle = Bundle(for: SpicyBundleToken.self)
        guard let image = UIImage(named: assetName, in: bundle, compatibleWith: nil)
            ?? UIImage(named: assetName) else { return nil }
        cache.setObject(image, forKey: assetName as NSString)
        return image
    }

    /// Aspect-preserving target size for a given height. Never distorts the logo.
    public static func size(forHeight height: CGFloat) -> CGSize {
        let ratio = sourcePixelSize.width / sourcePixelSize.height
        return CGSize(width: (height * ratio).rounded(), height: height)
    }
}

final class SpicyBundleToken {}
