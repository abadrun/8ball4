# Integration and build

## The honest situation

MR. SPICY cannot be integrated into the supplied artifact.

| Requirement | Reality |
|-------------|---------|
| Host source code | **NOT AVAILABLE** — only a compiled, signed IPA was supplied |
| Host build system | **NOT AVAILABLE** |
| Apple toolchain (Xcode/swiftc/codesign) | **NOT AVAILABLE** in this environment (Linux, no Swift) |
| Signing identity / provisioning profile | **NOT AVAILABLE** |
| Bundle integrity | The payload is wrapped by `libloader.framework` (`com.appdome.libloader`), a third-party app-protection/repackaging layer. Modifying the payload breaks both the code signature and that layer's integrity checks. |

Status: **BLOCKED BY SOURCE LIMITATION**.

Producing `output/Mr Spicy.ipa` from the supplied file would require unpacking
a protected, signed third-party binary, injecting code into it and re-signing
it. That is binary patching / protection-defeat, which this project explicitly
excludes. It has **not** been done, and no placeholder artifact has been
created in `output/`.

## The authorized path (how this layer is meant to ship)

1. Obtain an **authorized** host project — i.e. a build of 8 Ball Pool from
   its owners/developers, with source and an Xcode project.
2. Add this repository as a Swift package dependency, or drag
   `mr-spicy-ui/` and `integration/host/` into the host project.
3. Add `mr-spicy-ui/Resources/logo.png` and `mr-spicy-ui/Localization/*.lproj`
   to the app target's Copy Bundle Resources phase.
4. From the host's own startup code:

   ```swift
   import MrSpicyUI
   import MrSpicyHostBridge

   // In the host's scene/app delegate, with the host's own permission:
   SpicyHostBridge.install(in: window, entitlementProvider: myAuthorizedProvider)
   ```

   `install(in:)` refuses to attach when `SpicyHostBridge.compatibility(for:)`
   does not return `.validated` for the running build, unless the caller
   explicitly opts in with `allowUnvalidatedHost: true`.
5. Build, test, sign and archive **through Xcode with a valid identity**.
6. Export the IPA, name the export `Mr Spicy.ipa`, place it in `output/`,
   generate `output/Mr Spicy.sha256`, and fill in
   `validation/manifests/release-manifest.json` with real values.

Note that the engine renders the game with cocos2d-x/OpenGL/Metal, so the
MR. SPICY UIKit overlay composites **above** the game view; it does not and
cannot restyle in-engine screens.

## What the bridge deliberately does not do

No runtime injection, no swizzling of host internals, no `DYLD_INSERT_LIBRARIES`,
no Mach-O load-command editing, no re-signing of someone else's binary, no
Info.plist rewriting of the shipped bundle. The host calls MR. SPICY; MR. SPICY
never forces its way into the host.

## Build status

```
BUILD:              NOT DONE (no toolchain, no authorized host project)
COMPILATION:        NOT ATTEMPTED
UNIT TESTS:         NOT ATTEMPTED
SIGNING:            SIGNING NOT AVAILABLE
PACKAGING:          NOT DONE
INSTALLATION TEST:  INSTALLATION TEST NOT PERFORMED
output/Mr Spicy.ipa: NOT PRODUCED
```
