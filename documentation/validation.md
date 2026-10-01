# Validation report

Date of run: 2026-10-01. Environment: Linux sandbox, Python 3, **no Apple
toolchain** (no `swift`, `swiftc`, `xcodebuild`, `codesign`, `sips`).

## Executed and passing

| Check | Tool | Result |
|-------|------|--------|
| Repository inventory | manual + `tools/inspect_ipa.py` | **DONE** |
| Original IPA preserved, unrenamed, unmodified | `tools/verify_integrity.py` | **PASS** |
| Original SHA-256 recorded | `original/original.sha256` | **DONE** |
| `logo.png` checksum recorded and copy verified identical | `tools/verify_integrity.py` | **PASS** |
| IPA archive structure, Info.plist, frameworks, plug-ins, localizations | `tools/inspect_ipa.py` | **DONE** (read-only) |
| Main executable Mach-O header, arch, rpaths, 69 linked libraries | `tools/inspect_ipa.py` | **DONE** (parsed, never patched) |
| Component classification with evidence and confidence | `documentation/architecture/host-architecture.md` | **DONE** |
| Localization parity en/ar, 61/61 keys | `tools/sync_strings.py --check` | **PASS** |
| `.strings` generated from the single source of truth | `tools/sync_strings.py` | **DONE** |

## Implemented in code, not runtime-verified

| Area | Status |
|------|--------|
| Header / overlay / feature circles / modals / settings / account | **NOT VERIFIED** — never rendered |
| Responsive layout (portrait, landscape, safe areas, Dynamic Island, iPad) | **NOT VERIFIED** |
| RTL rendering | **NOT VERIFIED** (logic implemented; no screenshots) |
| VoiceOver, Dynamic Type, contrast, touch targets, Reduce Motion | **NOT VERIFIED** |
| Animation behaviour | **NOT VERIFIED** |
| Performance / leaks (Instruments) | **NOT MEASURED** (reviewed statically only) |
| Unit tests in `mr-spicy-ui/Tests` | **NOT ATTEMPTED** — no XCTest runtime |

## Not applicable / blocked

| Area | Status |
|------|--------|
| Host integration into the supplied IPA | **BLOCKED BY SOURCE LIMITATION** |
| Build | **NOT DONE** |
| Signing | **SIGNING NOT AVAILABLE** |
| IPA packaging | **NOT DONE** |
| Installation | **INSTALLATION TEST NOT PERFORMED** |
| Regression against host functionality | **NOT ATTEMPTED** — the host was never modified, so there is nothing to regress, and nothing was run |
| Logo `@2x`/`@3x` variants | **NOT AVAILABLE** — no image tooling (see `mr-spicy-ui/Resources/README.md`) |

## Required before any release claim

1. `swift build` / Xcode compile of `MrSpicyUI` and `MrSpicyHostBridge`.
2. `xcodebuild test` — all tests in `mr-spicy-ui/Tests` green.
3. Screenshot pass: iPhone SE / 15 / 15 Pro Max / iPad, portrait + landscape,
   light + dark, English + Arabic, default + XXL Dynamic Type.
4. VoiceOver walkthrough in both languages.
5. Instruments: Leaks + Allocations on overlay open/close cycles.
6. Signed archive, then and only then fill in the release manifest.
