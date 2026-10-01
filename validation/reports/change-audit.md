# Change audit (before / after)

## Supplied artifacts

| Path | Before | After | Change | Reason |
|------|--------|-------|--------|--------|
| `8-ball-pool-i3rby-IPAOMTK.COM.ipa` | sha256 `59607b41…a58c2f8`, 98,576,945 B | sha256 `59607b41…a58c2f8`, 98,576,945 B | **NONE** | Original host baseline — preserved, never renamed, never modified |
| `logo.png` | sha256 `2056971c…d44dc9`, 1,172,471 B | identical | **NONE** | Brand source asset left untouched |
| `.gitattributes` | LF normalization | unchanged | **NONE** | — |

Verified by `tools/verify_integrity.py` → PASS.

## Added (all new, nothing overwritten)

| Path | Purpose |
|------|---------|
| `README.md` | Project identity, honest status table, layout |
| `Package.swift` | SwiftPM manifest for the layer (iOS 13+) |
| `original/` | Preservation record: checksum, manifest, rules |
| `assets/logo.png` | Byte-identical working copy of the brand asset |
| `mr-spicy-ui/Sources/*.swift` (11 files) | The MR. SPICY UI layer |
| `mr-spicy-ui/Localization/{en,ar}.lproj/MrSpicy.strings` | Generated catalogues |
| `mr-spicy-ui/Resources/logo.png` + README | Bundled brand asset + variant status |
| `mr-spicy-ui/Tests/SpicyReducerTests.swift` | State, localization and version tests |
| `integration/host/SpicyHostBridge.swift` | The only host-aware file |
| `versions/`, `documentation/`, `validation/`, `tools/` | Records, docs, gates, tooling |
| `output/.gitkeep` | Intentionally empty — no release artifact was produced |

No file in the repository was deleted, renamed or overwritten.

## Rollback

Every addition is new-file-only, so rollback is `git revert` of this change set;
the supplied artifacts are unaffected by construction.
