#!/usr/bin/env python3
"""MR. SPICY — read-only inspector for the original host IPA.

Opens the IPA strictly read-only, never writes to it, and emits:
  - validation/checksums/<name>.sha256
  - original/original-manifest.json
  - validation/manifests/ipa-inventory.json

Usage:
    python3 tools/inspect_ipa.py <path-to-ipa> [--out-root .]
"""
from __future__ import annotations

import argparse
import collections
import hashlib
import json
import os
import plistlib
import struct
import sys
import zipfile

MH_MAGIC_64 = 0xFEEDFACF
LC_LOAD_DYLIB = 0x0C
LC_LOAD_WEAK_DYLIB = 0x80000018
LC_REEXPORT_DYLIB = 0x1F
LC_RPATH = 0x8000001C
LC_CODE_SIGNATURE = 0x1D

CPU_NAMES = {(16777228, 0): "arm64", (16777228, 2): "arm64e", (16777223, 3): "x86_64"}


def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_macho(blob: bytes) -> dict:
    """Parse a thin little-endian 64-bit Mach-O header. Read-only, no patching."""
    info: dict = {"parsed": False}
    if len(blob) < 32:
        return info
    magic_be = struct.unpack(">I", blob[:4])[0]
    if magic_be in (0xCAFEBABE, 0xBEBAFECA):
        info["fat"] = True
        info["slices"] = struct.unpack(">I", blob[4:8])[0]
        return info
    magic_le = struct.unpack("<I", blob[:4])[0]
    if magic_le != MH_MAGIC_64:
        return info
    cpu, sub = struct.unpack("<ii", blob[4:12])
    ncmds = struct.unpack("<I", blob[16:20])[0]
    libs, rpaths, signed = [], [], False
    off = 32
    for _ in range(ncmds):
        if off + 8 > len(blob):
            break
        cmd, size = struct.unpack("<II", blob[off:off + 8])
        if size == 0:
            break
        if cmd in (LC_LOAD_DYLIB, LC_LOAD_WEAK_DYLIB, LC_REEXPORT_DYLIB):
            o = struct.unpack("<I", blob[off + 8:off + 12])[0]
            libs.append(blob[off + o:off + size].split(b"\0")[0].decode("utf-8", "replace"))
        elif cmd == LC_RPATH:
            o = struct.unpack("<I", blob[off + 8:off + 12])[0]
            rpaths.append(blob[off + o:off + size].split(b"\0")[0].decode("utf-8", "replace"))
        elif cmd == LC_CODE_SIGNATURE:
            signed = True
        off += size
    info.update(
        parsed=True,
        fat=False,
        architecture=CPU_NAMES.get((cpu, sub & 0x00FFFFFF), f"cputype={cpu},subtype={sub}"),
        load_commands=ncmds,
        linked_libraries=libs,
        rpaths=rpaths,
        has_code_signature_load_command=signed,
    )
    return info


def inspect(ipa_path: str) -> dict:
    zf = zipfile.ZipFile(ipa_path)
    names = zf.namelist()
    apps = sorted({n.split("/")[1] for n in names if n.startswith("Payload/") and n.count("/") >= 2 and n.split("/")[1].endswith(".app")})
    if not apps:
        raise SystemExit("No .app bundle found under Payload/")
    app = apps[0]
    base = f"Payload/{app}"

    info_plist = plistlib.loads(zf.read(f"{base}/Info.plist"))
    executable = info_plist.get("CFBundleExecutable")

    frameworks = sorted({n.split("/")[3] for n in names if n.startswith(f"{base}/Frameworks/") and n.count("/") > 3})
    plugins = sorted({n.split("/")[3] for n in names if n.startswith(f"{base}/PlugIns/") and n.count("/") > 3})
    dylibs = sorted(n for n in names if n.endswith(".dylib"))
    lprojs = sorted({p for n in names for p in n.split("/") if p.endswith(".lproj")})

    exts = collections.Counter(
        n.rsplit(".", 1)[-1].lower() for n in names if "." in n.split("/")[-1] and not n.endswith("/")
    )

    macho = parse_macho(zf.read(f"{base}/{executable}")) if executable else {}

    framework_details = []
    for fw in frameworks:
        fw_base = f"{base}/Frameworks/{fw}"
        fw_name = fw[:-len(".framework")] if fw.endswith(".framework") else fw
        entry = {"name": fw, "bundle_identifier": None, "version": None,
                 "executable_sha256": None, "code_signature_present": f"{fw_base}/_CodeSignature/CodeResources" in names}
        try:
            pl = plistlib.loads(zf.read(f"{fw_base}/Info.plist"))
            entry["bundle_identifier"] = pl.get("CFBundleIdentifier")
            entry["version"] = pl.get("CFBundleShortVersionString")
            fw_name = pl.get("CFBundleExecutable", fw_name)
        except KeyError:
            pass
        try:
            entry["executable_sha256"] = hashlib.sha256(zf.read(f"{fw_base}/{fw_name}")).hexdigest()
        except KeyError:
            pass
        framework_details.append(entry)

    return {
        "artifact": os.path.basename(ipa_path),
        "sha256": sha256_file(ipa_path),
        "file_size_bytes": os.path.getsize(ipa_path),
        "zip_entries": len(names),
        "uncompressed_size_bytes": sum(zf.getinfo(n).file_size for n in names),
        "payload": {
            "app_bundle": app,
            "bundle_identifier": info_plist.get("CFBundleIdentifier"),
            "display_name": info_plist.get("CFBundleDisplayName"),
            "bundle_name": info_plist.get("CFBundleName"),
            "executable": executable,
            "short_version": info_plist.get("CFBundleShortVersionString"),
            "build": info_plist.get("CFBundleVersion"),
            "minimum_os_version": info_plist.get("MinimumOSVersion"),
            "device_family": info_plist.get("UIDeviceFamily"),
            "supported_platforms": info_plist.get("CFBundleSupportedPlatforms"),
            "dt_platform_version": info_plist.get("DTPlatformVersion"),
            "dt_xcode_build": info_plist.get("DTXcodeBuild"),
        },
        "code_signature_present": f"{base}/_CodeSignature/CodeResources" in names,
        "embedded_mobileprovision_present": any("mobileprovision" in n for n in names),
        "frameworks": framework_details,
        "plugins": plugins,
        "dylibs": dylibs,
        "localizations_in_bundle": lprojs,
        "resource_extension_counts": dict(exts.most_common(25)),
        "main_executable_macho": macho,
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("ipa")
    ap.add_argument("--out-root", default=".")
    args = ap.parse_args()

    data = inspect(args.ipa)
    root = args.out_root
    for d in ("original", "validation/checksums", "validation/manifests"):
        os.makedirs(os.path.join(root, d), exist_ok=True)

    name = data["artifact"]
    with open(os.path.join(root, "validation/checksums", name + ".sha256"), "w") as fh:
        fh.write(f"{data['sha256']}  {name}\n")
    with open(os.path.join(root, "original/original.sha256"), "w") as fh:
        fh.write(f"{data['sha256']}  {name}\n")
    with open(os.path.join(root, "original/original-manifest.json"), "w") as fh:
        json.dump(data, fh, indent=2, sort_keys=True)
        fh.write("\n")
    with open(os.path.join(root, "validation/manifests/ipa-inventory.json"), "w") as fh:
        json.dump(data, fh, indent=2, sort_keys=True)
        fh.write("\n")

    print(json.dumps({k: data[k] for k in ("artifact", "sha256", "file_size_bytes", "zip_entries")}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
