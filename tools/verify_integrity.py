#!/usr/bin/env python3
"""Re-verify every recorded checksum in validation/checksums/."""
from __future__ import annotations
import hashlib, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHECKS = os.path.join(ROOT, "validation", "checksums")


def sha256(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    failures = 0
    for name in sorted(os.listdir(CHECKS)):
        if not name.endswith(".sha256"):
            continue
        expected, artifact = open(os.path.join(CHECKS, name)).read().split(None, 1)
        artifact = artifact.strip()
        path = os.path.join(ROOT, artifact)
        if not os.path.exists(path):
            print(f"MISSING  {artifact}")
            failures += 1
            continue
        actual = sha256(path)
        ok = actual == expected
        print(f"{'OK      ' if ok else 'MISMATCH'} {artifact}  {actual}")
        failures += 0 if ok else 1
    print("INTEGRITY: " + ("PASS" if failures == 0 else f"FAIL ({failures})"))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
