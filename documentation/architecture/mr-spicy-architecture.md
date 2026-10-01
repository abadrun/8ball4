# MR. SPICY source architecture

```
mr-spicy-ui/Sources/            host-agnostic, reusable — knows nothing about 8 Ball Pool
    SpicyTheme.swift            design tokens: colour, type, spacing, radius, shadow, metrics, motion
    SpicyBrand.swift            logo.png access, cached decode, aspect-preserving sizing
    SpicyLocalization.swift     SpicyLanguage, SpicyStringKey (61 keys), en/ar catalogue, RTL flags
    SpicyState.swift            SpicyState / SpicyIntent / SpicyReducer — pure, UIKit-free, testable
    SpicyFeatureCircle.swift    reusable circular control, 5 states, a11y, RTL
    SpicyHeaderView.swift       logo + title + status + minimize/settings/close
    SpicyModalView.swift        the single modal container used by every modal state
    SpicySettingsView.swift     structured settings bound to real stored preferences
    SpicyAccountView.swift      account / PRO / license rendering, never authoritative by itself
    SpicyOverlayViewController.swift   container, grid, modal routing, state ownership
    SpicyVersion.swift          independent layer version + validated host identity

integration/host/
    SpicyHostBridge.swift       the ONLY host-aware file
```

## Rules the structure enforces

1. **One direction of knowledge.** `mr-spicy-ui` never imports anything host
   specific; `integration/host` depends on `mr-spicy-ui`, never the reverse.
   Swapping hosts means rewriting one file.
2. **One source of design truth.** No colour, radius, duration or metric is
   literal outside `SpicyTheme`.
3. **One source of state truth.** Views hold no state; they render
   `SpicyState` and emit `SpicyIntent`. `SpicyReducer` is pure, so every
   transition is unit-testable without a simulator.
4. **One modal implementation.** `SpicyModalView` + `SpicyModalContent`
   builders; `SpicyModalKind` selects content, never a parallel modal class.
5. **One localization catalogue.** `SpicyLocalization.fallback` is the source
   of truth; `.strings` files are generated from it by `tools/sync_strings.py`,
   so drift is impossible without failing the parity gate.
6. **Honest state.** `SpicyEntitlementStatus` defaults to `.unconfigured` and
   only `.verified` returns `isAuthoritative == true`.

## State machine

```
closed ──open/expand──▶ expanded ──minimize──▶ minimized
   ▲                        │                     │
   └──────── close ─────────┴──────── expand ─────┘

expanded ──selectFeature(f)──▶ modal(kind(f)) ──dismissModal──▶ expanded
```

`setOverlayVisible(false)` forces `closed`. `close` clears both the modal and
the selection, so no stale modal can survive a dismissal.

## Performance notes

* `SpicyBrand` decodes `logo.png` once into an `NSCache`; views share the image.
* Feature circles are rebuilt only when the vertical size class changes.
* All closures capture `self`/controls weakly (`[weak self]`, `[weak control]`),
  and delegates are `weak` — no retain cycles.
* No timers, no animation loops; animations are one-shot and collapse to 0 s
  under Reduce Motion.
* `NotificationCenter` observers are removed in `deinit`.
