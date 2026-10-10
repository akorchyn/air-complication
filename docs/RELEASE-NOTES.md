**Opening Air Alert UA now automatically attempts one refresh.** A pending request keeps the previous validated status visible instead of temporarily publishing N/A.

- The initial view starts the same request path as manual Refresh. Returning from Settings does not fetch again. Opening from a complication works when the consuming watch face supports launching the associated app.
- Rapid reopening within one minute reuses the cache. Existing requests, missing tokens, unsupported locations and failure backoff still prevent unnecessary requests; 429 limits are respected.
- While fetching, the prior state and successful-check timestamp stay persisted. The app shows `Refreshing...`; a valid response updates the status and timestamp. Failed/malformed responses display unavailable while retaining history. Fetching never extends the stale deadline or restores a previously failed status as current.
- Interrupted requests become unavailable when their lease expires and the status is next evaluated. Retrying requires a valid response before an old CLEAR value can become current again.
- Reopening preserves an already registered matching network/stale deadline instead of postponing it another five minutes. Background intervals remain 5–60 minutes; wrist-raise refresh is still unsupported.

English/Ukrainian text, letter-case choices, Status dots and all three API providers remain available on Epix (Gen 2) and both Venu 4 sizes.

Choose **only the PRG for your exact model**:

| Watch | Release asset |
|---|---|
| Epix (Gen 2) | air-alert.prg |
| Venu 4, 41 mm | air-alert-venu441mm.prg |
| Venu 4, 45 mm | air-alert-venu445mm.prg |

Rename the selected file to `air-alert.prg` and copy it to `GARMIN/APPS/air-alert.prg`, then safely disconnect. The multi-device IQ package is for Garmin distribution tooling, not USB sideloading. CI compiles and publishes every model's assets from the version tag.

Verified with **102 passing simulator tests per device**, including launch lifecycle, shared request gating, pending-cache persistence, failure handling, interruption/retry safety and background deadlines. On all three models, a fixture using the production view's opening callback fetched YELLOW without a Refresh button/tap, and a separate subscribing watch face received YELLOW followed by background RED. All three production PRGs and the multi-device IQ package compile successfully with SDK 9.2.0. CI compiles and publishes the release assets; simulator execution is recorded separately in the repository.

Informational only: continue using official air-alert notifications. Background delivery and complication expiry are not guaranteed. Keeping a cached value during fetching also means OS termination can leave it published until another execution evaluates its lease/stale deadline. Nationwide responses can exceed background memory. Cyrillic/emoji glyphs and colors depend on your watch face. Physical Venu installation and authenticated upstream requests remain unverified.

CI uses an ephemeral signing key unless `CIQ_SIGNING_KEY_BASE64` is configured. No live API token is embedded.
