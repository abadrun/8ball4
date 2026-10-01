# Integration notes

## Confirmed integration surface

| Question | Answer from inspection |
|----------|------------------------|
| Is the host UI UIKit? | No. cocos2d-x style engine (`.ccbi`, `.plist` atlases, OpenGLES + Metal). The MR. SPICY overlay therefore composites above the engine's `UIView`, and cannot restyle in-engine screens. |
| Where can a UIKit overlay attach? | The host's `UIWindow` / root view controller, from host-owned startup code. |
| Does the host already carry Arabic? | Yes, `ar.lproj` exists in the bundle; MR. SPICY ships its own catalogue and does not depend on the host's. |
| Minimum iOS | 13.0 — matches the MR. SPICY deployment target. |
| Device family | iPhone + iPad; the layout is ratio-based and size-class aware for both. |
| Is in-bundle modification viable? | No. `libloader.framework` (Appdome) protects the bundle; modifying it defeats a protection mechanism and is out of scope. |

## Open items for an authorized integrator

* Decide the invocation point (app launch vs. an explicit host entry point).
* Supply a real `SpicyEntitlementProviding` if account/PRO/licence state should
  ever be shown as verified; without one the UI honestly reports "unavailable".
* Decide whether the overlay should pause host audio/input while expanded —
  this requires host APIs and is intentionally not assumed here.
* Add `logo.png` to an asset catalogue with `@2x`/`@3x` variants.
