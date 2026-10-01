# Release document

## This release

**No binary release exists.** MR. SPICY 1.0.0 is a **source release** only.

| Item | Value |
|------|-------|
| MR. SPICY version | 1.0.0 |
| Release artifact | none — `output/Mr Spicy.ipa` **NOT PRODUCED** |
| Release SHA-256 | n/a |
| Build | NOT DONE |
| Signing | SIGNING NOT AVAILABLE |
| Installation | INSTALLATION TEST NOT PERFORMED |
| Compatibility | REQUIRES REVIEW |

## Release procedure (when an authorized path exists)

1. Pass every gate in `documentation/validation.md`.
2. Archive and export a signed IPA from Xcode.
3. `mv <export>.ipa "output/Mr Spicy.ipa"` — never copy the original there.
4. `sha256sum "output/Mr Spicy.ipa" > "output/Mr Spicy.sha256"`.
5. Fill `validation/manifests/release-manifest.json` with real values only.
6. Add a row with evidence to `versions/compatibility/matrix.md`.
7. Write the build, validation, installation, changed-files and regression
   reports under `validation/reports/`.
8. Re-run `tools/verify_integrity.py` and confirm the original is untouched.
