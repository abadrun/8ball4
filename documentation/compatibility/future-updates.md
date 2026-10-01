# Future host update procedure

A new host IPA is never trusted and an old modification is never blindly
re-applied.

1. **Preserve** the new IPA under its own original filename. Never overwrite
   an earlier one.
2. `python3 tools/inspect_ipa.py <new.ipa>` → SHA-256, manifest, inventory.
3. Record version/build in `versions/host/<version>-<build>.md`.
4. **Diff against the previous host record**: bundle id, version, minimum iOS,
   architecture, load commands, rpaths, linked libraries, framework list and
   versions, plug-ins, localizations, resource-type counts.
5. Flag every change: new/removed frameworks, changed protection layer,
   changed rendering stack, changed UI system, changed integration points.
6. Assess MR. SPICY compatibility against `SpicyHostBridge.compatibility(for:)`
   and update `SpicyVersion.validatedHost*` **only after** the steps below pass.
7. Reuse the `mr-spicy-ui` layer unchanged wherever it still applies; change
   only `integration/host/` where the host actually changed.
8. Build through Xcode; run unit tests; run the LTR/RTL, Dynamic Type and
   VoiceOver passes; run the regression checklist.
9. Update `versions/compatibility/matrix.md` with evidence — never mark
   "Compatible" without a tested result.
10. Create a release record and a new manifest.

Explicitly forbidden: an automated binary patcher that applies past
modifications to future versions.

## Diffing two host records

```bash
python3 tools/inspect_ipa.py old.ipa --out-root /tmp/old
python3 tools/inspect_ipa.py new.ipa --out-root /tmp/new
diff <(jq -S . /tmp/old/original/original-manifest.json) \
     <(jq -S . /tmp/new/original/original-manifest.json)
```
