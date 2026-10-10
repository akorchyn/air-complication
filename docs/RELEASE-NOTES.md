Fixes on-watch settings showing old values after returning from a selection dialog.

- Selecting an API provider immediately updates its name and whether a token is required, without reopening settings.
- Location, custom UID/label, refresh interval and stale threshold also refresh when their picker closes.
- Settings delivered from the phone update the currently visible settings menu.
- The existing menu is updated in place, retaining its position.

Download **air-alert.prg** and copy it to `GARMIN/APPS/air-alert.prg` on the watch, then safely disconnect. The IQ package is for Garmin distribution tooling, not USB sideloading. CI builds and publishes these release assets automatically from the version tag.

The three providers and all region presets remain available. This is an informational display: keep using official air-alert notifications. Garmin service delivery and complication expiry are not guaranteed; whole-oblast responses can exceed background memory. Physical Tronic integration and authenticated upstream requests remain unverified.

CI uses an ephemeral signing key unless `CIQ_SIGNING_KEY_BASE64` is configured. No live API token is embedded.
