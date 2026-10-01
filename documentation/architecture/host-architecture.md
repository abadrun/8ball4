# Host architecture — 8 Ball Pool 56.30.0 (5328)

Derived **only** from read-only inspection of
`8-ball-pool-i3rby-IPAOMTK.COM.ipa`. No value here is assumed.

## Package

```
Payload/
  pool.app/
    pool                       main executable, arm64 Mach-O, 81,963,248 bytes
    Info.plist
    PkgInfo
    _CodeSignature/CodeResources
    Frameworks/                25 embedded frameworks + libswift_Concurrency.dylib
    PlugIns/                   4 app extensions
    *.lproj/                   36 bundle localizations (ar.lproj present)
    ~1,326 png, 819 plist, 688 ccbi, 142 mp3, 83 strings, 45 atlas, 23 skel …
```

The expected path `Payload/pool.app/` was an *investigation target* and is
**confirmed**. The expected
`Payload/pool.app/Frameworks/libloader.framework/libloader` is also
**confirmed present** (see classification below).

## Main executable

| Field | Value |
|-------|-------|
| Mach-O | 64-bit, thin, little-endian (`0xFEEDFACF`) |
| Architecture | arm64 |
| Load commands | 125 |
| rpaths | `/usr/lib/swift`, `@executable_path/Frameworks` |
| Code-signature load command | present |
| Linked libraries | 69 (system + Swift runtime + 6 `@rpath` ad SDKs + `libloader`) |

Rendering stack: OpenGLES **and** Metal/MetalKit, GLKit, `.ccbi` resources —
a cocos2d-x / CocosBuilder derived engine with a native Swift/Obj-C shell.
The game UI is therefore **engine-drawn, not UIKit**: a UIKit overlay such as
MR. SPICY composites above it rather than inside it.

## Embedded frameworks

| Framework | Bundle identifier | Version |
|-----------|-------------------|---------|
| `AdSurgeSDK.framework` | `com.AdSurge.ADN` | 1.0 |
| `AppLovinSDK.framework` | `com.applovin.sdk` | 13.6.3 |
| `BigoADS.framework` | `org.cocoapods.BigoADS` | 5.2.1 |
| `DTBiOSSDK.framework` | `com.a9.pdp.DTBiOSSDK` | 1.0 |
| `FBAudienceNetwork.framework` | `com.facebook.FBAudienceNetwork` | 1.0 |
| `FBLPromises.framework` | `org.cocoapods.FBLPromises` | 2.4.0 |
| `FirebaseAnalytics.framework` | `org.cocoapods.FirebaseAnalytics` | 11.15.0 |
| `FirebaseCore.framework` | `org.cocoapods.FirebaseCore` | 11.15.0 |
| `FirebaseCoreExtension.framework` | `org.cocoapods.FirebaseCoreExtension` | 11.15.0 |
| `FirebaseCoreInternal.framework` | `org.cocoapods.FirebaseCoreInternal` | 11.15.0 |
| `FirebaseCrashlytics.framework` | `org.cocoapods.FirebaseCrashlytics` | 11.15.0 |
| `FirebaseInstallations.framework` | `org.cocoapods.FirebaseInstallations` | 11.15.0 |
| `FirebaseRemoteConfigInterop.framework` | `org.cocoapods.FirebaseRemoteConfigInterop` | 11.15.0 |
| `FirebaseSessions.framework` | `org.cocoapods.FirebaseSessions` | 11.15.0 |
| `GoogleAdsOnDeviceConversion.framework` | `com.google.ads.GoogleAdsOnDeviceConversion` | 2.1.0 |
| `GoogleAppMeasurement.framework` | `org.cocoapods.GoogleAppMeasurement` | 11.15.0 |
| `GoogleAppMeasurementIdentitySupport.framework` | `org.cocoapods.GoogleAppMeasurementIdentitySupport` | 11.15.0 |
| `GoogleDataTransport.framework` | `org.cocoapods.GoogleDataTransport` | 10.1.0 |
| `GoogleUtilities.framework` | `org.cocoapods.GoogleUtilities` | 8.1.0 |
| `InMobiSDK.framework` | `com.inmobi.InMobiSDK` | 11.3.0 |
| `MolocoSDK.framework` | `com.moloco.ads.sdk.core` | 4.7.0 |
| `OMSDK_Appodeal.framework` | `com.iabtechlab.omsdk` | 1.6.0 |
| `Promises.framework` | `org.cocoapods.Promises` | 2.4.0 |
| `libloader.framework` | `com.appdome.libloader` | 1.0.0 |
| `nanopb.framework` | `org.cocoapods.nanopb` | 3.30910.0 |

## App extensions

`NotificationContent.appex`, `NotificationService.appex`,
`PoolWidgetExtension.appex`, `PooliMessage.appex`.

## Component classification

| Component | Class | Confidence | Evidence |
|-----------|-------|-----------|----------|
| `pool` executable, `.ccbi`/`.plist`/`.png`/`.mp3` resources, `*.lproj` | ORIGINAL_APPLICATION | HIGH | Bundle id `com.miniclip.8ballpoolmult`, Miniclip naming, engine resource formats |
| 4 `.appex` plug-ins | ORIGINAL_APPLICATION | HIGH | Signed as part of the bundle, host-specific names |
| AppLovin, InMobi, BigoADS, FBAudienceNetwork, DTBiOSSDK, MolocoSDK, AdSurgeSDK, OMSDK_Appodeal | THIRD_PARTY | HIGH | Public SDK bundle identifiers and versions |
| Firebase\*, GoogleAppMeasurement\*, GoogleUtilities, GoogleDataTransport, nanopb, Promises/FBLPromises | THIRD_PARTY | HIGH | Public SDK bundle identifiers |
| `libswift_Concurrency.dylib` | SHARED | HIGH | Apple Swift back-deployment runtime |
| `libloader.framework` | THIRD_PARTY (protection/repackaging layer) | MEDIUM-HIGH | `CFBundleIdentifier = com.appdome.libloader`, 11.5 MB, links JavaScriptCore/WebKit/StoreKit/Security; Appdome is a no-code app-protection/repackaging platform. It is **not** Miniclip code and **not** MR. SPICY code. |
| `MR. SPICY` | CUSTOM_OVERLAY | HIGH | Authored in this repository, `mr-spicy-ui/` |

### Consequence of the `libloader` finding

The supplied IPA is a **repackaged redistribution**, not a pristine App Store
build: an Appdome protection/repackaging framework has been injected into the
bundle and linked into the main executable. Two things follow:

1. The bundle is **tamper-protected**. Any further modification of the payload
   invalidates both the existing signature and the protection layer's
   integrity checks. Repackaging it is explicitly out of scope here.
2. Its provenance (a third-party download site) means it should **not** be
   treated as an authorized distribution. The authorized integration path for
   MR. SPICY is a host build produced by the host's own owners/developers that
   links `MrSpicyUI` as a normal framework — see
   `documentation/build/integration.md`.
