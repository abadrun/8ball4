# MR. SPICY — Resources

| File | Source | Notes |
|------|--------|-------|
| `logo.png` | byte-identical copy of the supplied `logo.png` | 1254×1254, PNG, 8-bit truecolour (no alpha), sha256 `2056971c95da6f04ddf546c8409100604302c3deb5e47a7b29418ed220d44dc9` |

Scaled `@2x` / `@3x` variants were **NOT GENERATED** — no image-processing
toolchain (Pillow / sips / ImageMagick) is available in this environment.
The single 1254×1254 asset is well above every required rendering size
(28 pt logo = 84 px at @3x), and `SpicyBrand.size(forHeight:)` keeps the
aspect ratio 1:1, so the logo is never distorted. Generate asset-catalogue
variants on a machine with Xcode before release.
