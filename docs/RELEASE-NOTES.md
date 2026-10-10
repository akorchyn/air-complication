Adds **Ukrainian status text** and configurable letter case for Epix (Gen 2) and both Venu 4 sizes.

In on-watch settings select **Text language → Українська** and **Text case → Default / UPPERCASE / lowercase**. Mobile settings provide **Status text language** and **Status text case**.

| State | Default | UPPERCASE | lowercase |
|---|---|---|---|
| No applicable air-raid alert | Немає | НЕМАЄ | немає |
| Yellow | Жовта | ЖОВТА | жовта |
| Red | Червона | ЧЕРВОНА | червона |
| Unknown / failed | н.д. | Н.Д. | н.д. |
| Stale | Застар. | ЗАСТАР. | застар. |

Try **Українська + lowercase** for a less prominent appearance. The watch face determines font size, glyph support and any additional capitalization. Language and case also apply to status words on the app's screen. English uppercase remains the default, and Status dots remain available.

Presentation changes immediately republish the cached status without a new API request. They preserve failure backoff, in-flight requests and the background schedule. Settings selections update when returning from a picker.

Choose **only the PRG for your exact model**:

| Watch | Release asset |
|---|---|
| Epix (Gen 2) | air-alert.prg |
| Venu 4, 41 mm | air-alert-venu441mm.prg |
| Venu 4, 45 mm | air-alert-venu445mm.prg |

Rename the selected file to `air-alert.prg` and copy it to `GARMIN/APPS/air-alert.prg`, then safely disconnect. The multi-device IQ package is for Garmin distribution tooling, not USB sideloading. CI compiles and publishes every model's assets from the version tag.

Verified with **89 passing simulator tests per device**, covering Ukrainian/English formatting, unknown/stale safety, cache/backoff preservation and reactive settings. Ukrainian strings were delivered through the public complication API to a separate consumer using mocked manual and background updates. All three production PRGs and the multi-device IQ package compile successfully with SDK 9.2.0. CI compiles and publishes the release assets; simulator execution is recorded separately in the repository.

Informational only: continue using official air-alert notifications. Background delivery and complication expiry are not guaranteed; nationwide responses can exceed background memory on all supported devices. Cyrillic/emoji glyphs and colors depend on your watch face. Physical Venu installation and authenticated upstream requests remain unverified.

CI uses an ephemeral signing key unless `CIQ_SIGNING_KEY_BASE64` is configured. No live API token is embedded.
