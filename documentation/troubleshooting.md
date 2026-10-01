# Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `SpicyHostBridge.install` returns `nil` | Host build is not the validated one, or the bundle id differs | Run the update procedure in `documentation/compatibility/future-updates.md`; only then update `SpicyVersion.validatedHost*`. For local experiments pass `allowUnvalidatedHost: true`. |
| Logo does not appear | `logo.png` is not in the app target's resources, or the bundle lookup fails | Add `mr-spicy-ui/Resources/logo.png` to Copy Bundle Resources. `SpicyBrand.logo` returns `nil` rather than a placeholder, by design. |
| Strings show raw keys like `spicy.app.title` | `.strings` not bundled | Add `mr-spicy-ui/Localization/*.lproj`; the in-code fallback should normally prevent this. |
| Arabic text appears but layout stays LTR | A custom container did not inherit the semantic attribute | Set `semanticContentAttribute = SpicyLocalization.shared.semanticContentAttribute` on it, and use leading/trailing anchors only. |
| Animations feel instant | Reduce Motion is enabled | Expected — `SpicyTheme.Motion.duration()` returns 0. |
| Overlay blocks the game | Touches outside the card reach the host only if the overlay's root view is transparent and non-blocking | Keep `view.backgroundColor = .clear`; do not add a full-screen scrim outside modals. |
| `tools/verify_integrity.py` reports MISMATCH | A preserved artifact was modified | Restore it from Git immediately; the original IPA must never change. |
| `tools/sync_strings.py` reports FAIL | A key was added without both translations | Add the missing language entry in `SpicyLocalization.swift`, then re-run. |
