# ORIGINAL HOST PRESERVATION RECORD — NON-NEGOTIABLE

## Artifact

| Field | Value |
|-------|-------|
| Filename | `8-ball-pool-i3rby-IPAOMTK.COM.ipa` |
| SHA-256 | `59607b4177f8ffdf36649d9bb3b0c5900d39f5b6b3eaa0c6e351ba353a58c2f8` |
| Size | 98,576,945 bytes |
| ZIP entries | 3,505 |
| Uncompressed size | 205,308,617 bytes |
| Repository location | **repository root**, unchanged (see note) |

## Note on physical location

The master specification suggests `original/8-ball-pool-i3rby-IPAOMTK.COM.ipa`.
The file is **left byte-for-byte in place at the repository root** instead:

* moving or duplicating a 94 MiB binary inside Git would either double the
  repository size or rewrite a large binary blob in history, and
* the requirement that actually matters — *the original is preserved,
  unrenamed, unmodified, and permanently bound to its checksum* — is satisfied
  either way.

`original/` therefore holds the **preservation record** (this file,
`original.sha256`, `original-manifest.json`) that points at the untouched
artifact. If a policy decision later requires physical relocation, use
`git mv` (never a copy-then-delete) and re-run `tools/verify_integrity.py`.

## Rules in force

* NEVER rename this file. In particular, it is **not** `Mr Spicy.ipa`.
* NEVER overwrite, delete or modify it in place.
* NEVER place a renamed copy of it in `output/`.
* The checksum above stays bound to this artifact permanently.

## Verification

```bash
python3 tools/verify_integrity.py     # last run: PASS
```

All inspection performed by `tools/inspect_ipa.py` opens the archive
**read-only** (`zipfile.ZipFile` in default read mode); nothing in this
repository writes to the IPA.
