# MR. SPICY UI design document

## Tokens (`SpicyTheme`)

| Group | Values |
|-------|--------|
| Colour | accent `#E2452B` / `#FF5A3C` (dark), surface, surfaceElevated, surfaceSunken, scrim 45%, separator, textPrimary/Secondary/OnAccent, success, warning, danger, disabled — all dynamic (light/dark) |
| Typography | title / headline / body / callout / caption / button, all `UIFontMetrics`-scaled with a 34 pt ceiling |
| Spacing | 2 · 4 · 8 · 12 · 16 · 24 · 32 |
| Radius | control 10, card 16, modal 20, pill |
| Border | hairline (1/scale), regular 1, emphasis 2 |
| Shadow | card (y4 r10 12%), modal (y10 r24 22%) |
| Metrics | touch target 44, control 48, header 56, icon 22, circle 64 (52 compact), logo 28, overlay max 420, modal max 460 |
| Motion | fast .18, standard .28, slow .42, spring damping .86 — all routed through `Motion.duration()` which returns 0 under Reduce Motion |

Avoided by construction: ad-hoc gradients, one-off spacing, mixed radii,
duplicated shadow definitions, oversized controls.

## Components

**Header** — logo (aspect-fit, never stretched) · title · status subtitle ·
optional settings/minimize/close. Pinned to `safeAreaLayoutGuide`, hairline
separator, explicit `accessibilityElements` order.

**Overlay container** — rounded card, centred in the safe area, width
`min(92% of safe width, 420)`, height ≤ 80% of safe height, card shadow,
`clipsToBounds` off so the shadow renders.

**Feature circle** — icon + title + optional subtitle. States: normal,
selected (accent fill), disabled, unavailable, loading (spinner replaces icon).
Press feedback: 0.94 scale + 72% alpha. Minimum 44×44 regardless of diameter.

**Modal** — scrim (tap to dismiss, escape gesture supported) + card with
header row, scrollable content stack and an equal-width action row.
`accessibilityViewIsModal = true`; focus is posted to the title on present.

**Settings** — sections General / Interface / Accessibility / About built from
a declarative `[Section]`; every control writes to a real `SpicySettingsState`
field. No placeholder switches.

**Account** — signed-out/signed-in headline plus PRO and licence rows. When
neither is authoritatively verified an explicit amber notice states that no
entitlement service is configured.

## Responsive behaviour

* Ratio-based width with an absolute cap; nothing is positioned absolutely.
* Compact vertical size class (landscape iPhone) → smaller circles and up to
  five per row; the grid rebuilds on size-class change only.
* Safe areas, notch and Dynamic Island are handled by `safeAreaLayoutGuide`.
* Arabic text expansion absorbed by multi-line labels, vertical stacks and the
  Dynamic Type ceiling.

## Accessibility

VoiceOver labels, hints and values on every control; `.selected` / `.notEnabled`
traits reflect state; `.header` traits on titles and section headers;
Dynamic Type everywhere (`adjustsFontForContentSizeCategory`); ≥44 pt targets;
logical focus order; `accessibilityPerformEscape` on modals; Reduce Motion
honoured globally; colour pairs chosen for ≥4.5:1 body contrast in both
appearances.

**Verification status:** implemented in code, **not verified on a device or
simulator** — no Apple toolchain is available in this environment.
