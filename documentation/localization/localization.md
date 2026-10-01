# Localization and RTL

## Model

`SpicyStringKey` declares **61 keys** covering titles, actions, feature labels,
settings, account/PRO/licence, about, errors, empty and loading states, and
**accessibility labels/hints/values** — not just visible labels.

`SpicyLocalization.fallback` holds the English and Arabic catalogues and is the
single source of truth. `tools/sync_strings.py` parses it, enforces 100 %
parity, and generates:

```
mr-spicy-ui/Localization/en.lproj/MrSpicy.strings
mr-spicy-ui/Localization/ar.lproj/MrSpicy.strings
```

Last run: `en: 61/61`, `ar: 61/61` — **LOCALIZATION PARITY: PASS**.
`SpicyLocalizationTests` additionally asserts that no Arabic value is a copy of
its English counterpart.

Language selection persists in `UserDefaults` (`mrspicy.language`), defaults to
the device preference, and broadcasts
`SpicyLocalization.languageDidChangeNotification`; the header, feature circles
and overlay re-localize live and post a VoiceOver `.screenChanged`.

## True RTL

Not label mirroring. Direction is applied via
`UISemanticContentAttribute.forceRightToLeft` on the overlay, header stack,
action stack, grid rows, settings rows, modal card and content stacks, so:

* horizontal stacks reverse (logo → right, action buttons → left);
* modal confirm/cancel ordering mirrors;
* `textAlignment` follows the language (`.right` for Arabic, trailing values
  flip to `.left`);
* feature icons are direction-neutral SF Symbols, so none need mirroring;
* accessibility element order follows the visual order.

Layout uses leading/trailing anchors throughout, so Auto Layout mirrors the
rest automatically.

**Verification status:** LTR and RTL are implemented and unit-testable at the
state level, but **have not been rendered or visually inspected** — no
simulator is available here. Run the LTR/RTL screenshot pass described in
`documentation/validation.md` before any release.
