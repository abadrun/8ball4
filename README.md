# MR. SPICY

**MR. SPICY is not the host game.** It is a source-controlled customization,
branding, UI and integration layer intended to run *with* an authorized build
of the host application **8 Ball Pool**.

| Role | Artifact |
|------|----------|
| Original host application (baseline, never modified) | `8-ball-pool-i3rby-IPAOMTK.COM.ipa` |
| Customization / UI / branding / integration layer | **MR. SPICY** (`mr-spicy-ui/`, `integration/`) |
| Optional final integrated release artifact | `output/Mr Spicy.ipa` — **NOT PRODUCED** (see below) |

The original IPA keeps its original filename, forever. It is never renamed to
`Mr Spicy.ipa`, never overwritten and never modified in place.

---

## Current status (honest summary)

| Gate | Status |
|------|--------|
| Original IPA preserved, original filename intact | **DONE** |
| Original SHA-256 recorded | **DONE** — `59607b4177f8ffdf36649d9bb3b0c5900d39f5b6b3eaa0c6e351ba353a58c2f8` |
| Repository inventoried | **DONE** |
| IPA inspected (archive, Info.plist, frameworks, Mach-O, plug-ins) | **DONE** (read-only) |
| Architecture documented & components classified | **DONE** |
| MR. SPICY source layer implemented | **DONE** |
| Logo integrated (no distortion, cached decode) | **DONE** |
| English + Arabic localization, 61/61 key parity | **DONE** (automated check) |
| RTL implemented | **DONE** in code — **NOT VISUALLY VERIFIED** (no simulator) |
| Accessibility implemented | **DONE** in code — **NOT VERIFIED WITH VOICEOVER** |
| Swift compilation | **NOT ATTEMPTED** — no macOS/Xcode/Swift toolchain in this environment |
| Unit tests executed | **NOT ATTEMPTED** — same reason |
| Host integration into the supplied IPA | **BLOCKED BY SOURCE LIMITATION** — host source is unavailable; only a compiled, Appdome-protected, signed binary exists |
| Build of `Mr Spicy.ipa` | **NOT DONE** |
| Signing | **SIGNING NOT AVAILABLE** |
| Installation test | **INSTALLATION TEST NOT PERFORMED** |
| Compatibility claim | **REQUIRES REVIEW** — nothing has been runtime-validated |

`output/` is intentionally empty. No artifact is placed there unless it was
actually built and signed through an authorized path.

---

## Repository layout

```
8-ball-pool-i3rby-IPAOMTK.COM.ipa   original host baseline (in place, untouched)
logo.png                            supplied brand asset (in place, untouched)

original/                           preservation records for the baseline
    original.sha256
    original-manifest.json
    PRESERVATION.md
assets/                             brand assets for the MR. SPICY layer
mr-spicy-ui/                        reusable, host-agnostic MR. SPICY layer
    Sources/  Resources/  Localization/  Tests/
integration/                        host-specific glue, kept separate on purpose
    host/  configuration/  integration-notes/
versions/                           host + layer version records
    host/  mr-spicy/  compatibility/
documentation/                      architecture, UI, localization, build, release…
validation/                         manifests, checksums, reports, regression
tools/                              read-only inspection + localization tooling
output/                             authorized release artifacts only (empty)
Package.swift                       SwiftPM manifest (iOS 13+, requires Xcode)
```

## Tooling

```bash
python3 tools/inspect_ipa.py 8-ball-pool-i3rby-IPAOMTK.COM.ipa   # read-only inspection + manifests
python3 tools/sync_strings.py --check                            # localization parity gate
python3 tools/verify_integrity.py                                # re-verify preserved checksums
```

## Scope boundary

MR. SPICY is a UI/customization system. This repository deliberately contains
no gameplay automation, aim assistance, anti-cheat evasion, DRM/licence/payment
bypass, server manipulation or binary patching, and the account/PRO/licence UI
only *renders* entitlement state supplied by an authorized provider — with no
provider configured it reports "unavailable" rather than claiming access.

See `documentation/` for the full architecture, integration, build, validation,
compatibility and future-update documents.
