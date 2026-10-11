**Configure Air Alert UA from Connect IQ on your phone.** Provider, API tokens, location, display options, refresh interval and stale threshold are now managed together in mobile app settings. The watch keeps status, last successful check and manual Refresh, with a settings hint pointing to Connect IQ mobile.

- Phone-delivered provider/location changes invalidate old status and in-flight replies. Updating a token permits recovery from authentication backoff. Presentation-only changes preserve the cached check and retry schedule.
- English/Ukrainian text, letter-case choices, Status circles and all three API providers remain available on Epix (Gen 2) and both Venu 4 sizes.
- Development builds use the separate **Air Alert UA Beta** identity. Beta and production can coexist with independent settings and caches. Select the matching app name in your watch face's complication picker.

For USB installation, choose your model's PRG and rename it to `air-alert-beta.prg` for beta, or `air-alert.prg` for production, then copy it to `GARMIN/APPS/` and safely disconnect. The `.iq` package is not a USB installation file. Mobile configuration availability for USB-sideloaded apps depends on Garmin tooling.

Informational only: continue using official air-alert notifications. Background delivery and complication expiry are not guaranteed. Nationwide responses can exceed background memory. Cyrillic/emoji glyphs and colors depend on your watch face. Physical Venu installation and authenticated upstream requests remain unverified.
