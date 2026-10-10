Adds **Venu 4 support for both 41 mm and 45 mm models**, alongside Epix (Gen 2).

The main screen now shows how to open settings and refresh:

- **Epix:** START: Refresh; Hold MENU: Settings (middle-left button).
- **Venu 4:** Tap: Refresh; Hold screen: Settings. The top-right button also refreshes; bottom-right goes back.

Touch hold also opens settings on Epix when touch is enabled. The main layout uses actual screen dimensions and font heights; long lines are shortened to fit the round display. Each Venu size has matching launcher/complication icons.

Choose **only the PRG for your exact model**:

| Watch | Release asset |
|---|---|
| Epix (Gen 2) | air-alert.prg |
| Venu 4, 41 mm | air-alert-venu441mm.prg |
| Venu 4, 45 mm | air-alert-venu445mm.prg |

Rename the selected file to `air-alert.prg` and copy it to `GARMIN/APPS/air-alert.prg`, then safely disconnect. The multi-device IQ package is for Garmin distribution tooling, not USB sideloading. CI compiles and publishes every model's assets from the version tag.

All three API providers, location presets and Text/Status dots modes remain available. Use the public complication with a watch face supporting third-party Connect IQ complications.

Verified with **83 passing simulator tests per device**, manual YELLOW → background RED delivery to a separate consuming watch face on both Venu sizes, and main-view/touch-hold settings checks on both Venu sizes. All three production PRGs and the multi-device IQ package compile successfully with SDK 9.2.0.

Informational only: continue using official air-alert notifications. Background delivery and complication expiry are not guaranteed; nationwide responses can exceed background memory on all supported devices. Emoji glyphs and colors depend on your watch face. Physical Venu installation and authenticated upstream requests remain unverified.

CI uses an ephemeral signing key unless `CIQ_SIGNING_KEY_BASE64` is configured. No live API token is embedded.
