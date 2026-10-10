Adds **Display mode** with two choices: **Text** (default) and **Status dots**.

| State | Text | Status dots |
|---|---|---|
| No applicable active air-raid alert after a validated check | CLEAR | 🟢 |
| Yellow alert | YELLOW | 🟡 |
| Red alert | RED | 🔴 |
| Unavailable or unknown | N/A | ? |
| Stale | STALE | ! |

Choose the mode in mobile settings or hold MENU → Display mode on the watch. Switching modes immediately republishes cached status without a network request or resetting failure backoff. The app's own screen keeps readable status words.

**Glyph/color support depends on your watch face's font.** The publisher sends Unicode text, not colored images. These circles may render monochrome, as boxes, or blank; switch to Text if unreadable. Physical watch-face emoji/color rendering is unverified. Never interpret ? or ! as clear.

Download **air-alert.prg** and replace `GARMIN/APPS/air-alert.prg` on the watch, then safely disconnect. The IQ package is for Garmin distribution tooling, not USB sideloading. CI builds and publishes these assets from the version tag.

All three providers and the region presets remain available. Informational only: continue using official air-alert notifications. Garmin background delivery and complication expiry are not guaranteed; whole-oblast responses can exceed background memory. Authenticated upstream requests remain unverified.

CI uses an ephemeral signing key unless `CIQ_SIGNING_KEY_BASE64` is configured. No live API token is embedded.
