# Regression checklist

Status of this run: **NOT ATTEMPTED** — nothing was built or executed, and the
host bundle was never modified, so no regression surface was created.

Run every item before any release.

## Host functionality preserved
- [ ] Game launches to the main menu
- [ ] Matchmaking, gameplay, shop, inbox, clubs behave as on the unmodified host
- [ ] Push notifications, widget, iMessage extension still function
- [ ] No new crashes in the first 30 minutes of play
- [ ] Host frame rate unchanged while the overlay is closed

## MR. SPICY behaviour
- [ ] Overlay opens, minimizes, expands, closes
- [ ] All nine feature circles open their modal and dismiss cleanly
- [ ] No modal survives a close
- [ ] Hiding the overlay in settings closes it
- [ ] Language switch re-localizes live, including accessibility strings
- [ ] Appearance override applies to the overlay only
- [ ] Touches outside the overlay card still reach the game

## Integrity
- [ ] `tools/verify_integrity.py` → PASS
- [ ] `tools/sync_strings.py --check` → PASS
- [ ] No unrelated host resource changed (before/after file list + hashes)
- [ ] Info.plist diff empty, or every key change justified in an audit row
