**Fixes a network callback crash that prevented manual and background updates.** Physical-watch logs showed `Not Enough Arguments Error` in `AlertRequest.webResponse`: Garmin invoked the callback with two arguments while the app expected the optional third context argument.

- All providers now use the standard two-argument `makeWebRequest` callback. Each callback holds its own request sequence and query index, preserving rejection of outdated and duplicate replies without relying on optional context delivery.
- Network failures reach normal error/backoff handling instead of crashing the app or service.
- Opening the app still attempts one refresh. Cached status stays visible during fetching; successful validation, staleness and retry rules are unchanged.
- Corrected UA Siren's documented rate limit to **50 requests/minute/IP** and added troubleshooting instructions. This callback crash is not evidence of HTTP 429.

English/Ukrainian text, letter-case choices, Status dots and all three API providers remain available on Epix (Gen 2) and both Venu 4 sizes.

Choose **only the PRG for your exact model**:

| Watch | Release asset |
|---|---|
| Epix (Gen 2) | air-alert.prg |
| Venu 4, 41 mm | air-alert-venu441mm.prg |
| Venu 4, 45 mm | air-alert-venu445mm.prg |

Rename the selected file to `air-alert.prg` and copy it to `GARMIN/APPS/air-alert.prg`, then safely disconnect. The multi-device IQ package is for Garmin distribution tooling, not USB sideloading. CI compiles and publishes every model's assets from the version tag.

Verified with **108 passing simulator tests per device**, including six callback regression cases: two-argument Siren responses and transport failures, HTTP 429/history retention, duplicate parent replies, old refresh-cycle replies, and replies after a location change. All three production PRGs and the multi-device IQ package compile with SDK 9.2.0. Publisher-to-consumer fixture checks and the live public-provider transport check are recorded in the verification document. CI builds and publishes the release binaries from the version tag; physical-watch confirmation of this fix is still needed.

Informational only: continue using official air-alert notifications. Background delivery and complication expiry are not guaranteed. Keeping a cached value during fetching also means OS termination can leave it published until another execution evaluates its lease/stale deadline. Nationwide responses can exceed background memory. Cyrillic/emoji glyphs and colors depend on your watch face. Physical Venu installation and authenticated upstream requests remain unverified.

CI uses an ephemeral signing key unless `CIQ_SIGNING_KEY_BASE64` is configured. No live API token is embedded.
