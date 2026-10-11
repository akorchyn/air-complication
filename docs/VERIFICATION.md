# Verification record — updated 2026-10-11

## Epix Pro (Gen 2), 51 mm — 1.6.1

The Connect IQ Store rejected the user's Epix Pro 51 mm because the previous package declared only original Epix Gen 2 and Venu 4 targets. Added the distinct official `epix2pro51mm` target, which has a 454×454 display and 64 KiB background memory, to production, beta and all simulator fixtures. Epix Pro 42 mm and 47 mm remain outside the supported targets.

- Compiled all four supported models for both production and beta with stock SDK 9.2.0, and exported both multi-device IQ packages at version 1.6.1.
- Extracted each IQ package and confirmed its manifest includes `006-B4314-00`, `006-B4542-00` and `006-B4556-00`, the part numbers in Garmin's Pro 51 mm SDK profile. Confirmed their binaries, all 11 settings and public complication 0 are present. The SDK profile also covers D2 Mach 1 Pro and tactix 7 AMOLED aliases. Each package now has eight device-part entries. Both app IDs are unchanged; binary checksums pass.
- Executed **108 Run No Evil tests** on `epix2pro51mm`: `PASSED (passed=108, failed=0, errors=0)`. See [unit-tests-epix2pro51mm.log](unit-tests-epix2pro51mm.log).
- On the Pro 51 mm simulator, invoked the production manual Refresh delegate through a mocked transport and received YELLOW in the separate subscribing watch face. Injecting a temporal background event delivered RED to that consumer. See [publisher log](probe-1-epix2pro51mm-publisher.log), [consumer log](probe-1-epix2pro51mm-consumer.log), [fixture build](probe-1-epix2pro51mm-build.log), [manual screenshot](probe-1-epix2pro51mm-manual.png) and [background screenshot](probe-1-epix2pro51mm-background.png). These screenshots show the diagnostic fixture/consumer, not third-party watch-face rendering.
- Ran the SDK/device setup script with its pinned archives, confirming it extracts the Pro 51 mm profile. Updated the CI cache key, build loops, upload assets and tag-release assets to include the new target. Workflow syntax passes actionlint.

Physical installation through the Connect IQ Store remains to be confirmed after the owner uploads the new IQ package to the existing beta listing. A sideloaded PRG running on the watch does not add that watch to the store's package compatibility list.

## Mobile configuration and beta builds — 1.6.0

All **108 Monkey C Run No Evil tests passed on each of Epix Gen 2, Venu 4 41 mm and Venu 4 45 mm**. The three settings regressions now exercise the production phone-settings callback: switching provider preserves separate credentials and rejects an old in-flight reply; custom location/interval changes resolve and invalidate the previous check; replacing a token clears authentication backoff without revalidating old CLEAR history. Existing presentation tests verify language/case/mode edits preserve cached success, in-flight generations and failure backoff. See the three `unit-tests*.log` files.

Compiled both production and beta PRGs for all three models and both multi-device IQ packages with stock SDK 9.2.0 and Java 17. Inspected the exported packages: distinct app IDs and complication labels, shared version 1.6.0, public complication 0, all 11 mobile settings, 33 location choices including Custom, and identical developer public keys. Checked both sets of binary SHA-256 checksums. The same private signing key therefore works for both identities.

Validated workflow syntax with actionlint and executed its signing-key setup branches: production rejects a missing permanent key; beta permits a temporary key with a warning; a supplied permanent key is preserved. The local build default remains production, while automatic CI defaults to beta and manual workflow dispatch offers either variant.

The watch settings editor was removed. Configuration now lives in Connect IQ mobile settings; the watch retains status, last update and Refresh with a phone-settings hint. Tests exercise delivery through `onSettingsChanged`; they do not verify a physical phone's settings editor or guarantee its availability for USB-sideloaded applications. Beta Garmin installation/account access and physical Venu behavior remain unverified. Historical watch-menu checks below describe older versions.

## Executed

- Compiled the production Device App for `epix2` using Garmin Connect IQ SDK **9.2.0**, Java 17, strict type-check level 1. See `build.log` and the delivered `artifacts/air-alert.prg`.
- Before implementing REST integration, installed a standalone public TEST publisher and a separate subscribing watch face in the actual Garmin simulator. The consumer displayed TEST. The final source tree retains both targets for reproduction.

  The final clean spike was also re-run: [spike-consumer.log](spike-consumer.log) and [spike-test.png](spike-test.png) show `CONSUMER RECEIVED: TEST` and the consumer display.
- Executed **83 actual Monkey C Run No Evil tests** for version 1.2.0: `PASSED (passed=83, failed=0, errors=0)` (79 passed in 1.1.1; 77 in 1.1.0). See [unit-tests.log](unit-tests.log). These compile and invoke production Monkey C logic, not a Python reimplementation. New cases cover both response formats, separate tokens, provider switching, whole-oblast partial alerts, Crimea's alias, unsupported provider locations and all-parent request aggregation.
- Made a **real HTTPS UA Siren request** through the official simulator's `Communications.makeWebRequest` transport, using the production request/cache/parser path and a temporary diagnostic subclass. A decoded root JSON array arrived with HTTP 200 and the cache recorded a successful check. See [network-uasiren.log](network-uasiren.log). This checks the SDK callback boundary, whose published static type omits root arrays despite runtime support. The log contains no alert body, API token or headers; live events are not test fixtures. Authenticated providers still need personal-token/hardware checks.
- Pressed simulated Epix START through the production Refresh delegate with a mocked transport. It published YELLOW; subsequently loaded consumer read YELLOW.
- Injected a Garmin simulator temporal background event for the publisher while the consumer watch face was active. The real service/request/cache/parser path published RED; subscribed consumer received RED and repainted. See [probe-1-consumer.log](probe-1-consumer.log), [manual-yellow.png](manual-yellow.png), and [background-red.png](background-red.png).
- Tested 10 and 25 distinct realistic alert dictionaries with long threat messages in the service. Ten propagated RED. Twenty-five exhausted memory; the consumer received N/A, which had been published before allocation. See the logs below.

The temporal integration fixture makes the request immediately due when a simulator event is injected. This tests the service and delivery path without waiting five minutes; production does not have that override. Automated tests and consumer/memory probes use mocked data exclusively; the separate live smoke check is listed above.

## Display modes — 1.2.0

Four new simulator tests validate Text/dot mappings, invalid-mode fallback, failed/stale checks never producing green, immediate formatting-only changes preserving cached success/request generation/next-check time, and preserving 429 failure backoff. The settings lifecycle regression also checks the mode label updates on return. All 83 tests passed.

The mode publishes literal Unicode strings for green/yellow/red and ASCII ?/! for unknown/stale. Background callbacks use the selected mode; the foreground status view intentionally retains words. Emoji glyph/color support in third-party watch faces is unverified. The ASCII-only test consumer logs the exact received Unicode string and draws an explanatory caption; it does not demonstrate native colored emoji.

The actual simulator consumer received 🟡 after a mocked manual refresh, 🔴 after a temporal background event, and 🟢 after a subsequent background event returning a validated empty response. See [dots-1-consumer.log](dots-1-consumer.log), [publisher log](dots-1-publisher.log), and [build log](dots-1-build.log). Reproduce with `scripts/verify_simulator.py 1 dots` after compiling the consumer. The current one-alert dot-mode background probe used 34,904 B after synthetic payload allocation; large-response constraints still apply.

## Settings reactivity patch — 1.1.1

The settings menu reloads values in `onShow()` when a picker closes. It updates the existing MenuItems in place; the same menu instance and position are retained. The application settings callback also updates a currently visible settings menu for phone-delivered changes. This change does not fetch network data when a setting is edited.

Two new actual simulator Run No Evil regressions invoke the same menu instance’s return-to-screen lifecycle after changing properties. `settings_return_updates_provider_and_token_requirement` verifies alerts.in.ua → UA Siren → Ukraine Alarm and the dependent token label; `settings_return_updates_location_and_intervals` verifies location, custom UID/label and both intervals. Both passed, and the complete suite reports 79 passes. Production Epix compilation also passed. Native menu rendering remains unverified because this workspace lacks authenticated Garmin simulator fonts; the diagnostic native view reported Invalid Font Specified. These are programmatic lifecycle/label checks, not a claim of visual hardware verification.

The consumer propagation, live transport and background memory evidence below was recorded for 1.1.0.

## Requested case coverage

| Case | Evidence |
|---|---|
| First launch, no token | `first_launch_without_token`, `missing_token_avoids_network` |
| Valid empty/no relevant alerts | `no_alerts`, `unrelated_type` |
| Yellow / red / both | `yellow_city`, `red_city`, `red_priority` |
| Threat-level escalation | `red_threat_over_yellow` |
| Whole oblast / raion coverage | `oblast_inheritance`, `raion_inheritance` |
| Other city excluded | `sibling_city` |
| Separate Kyiv, Kharkiv, Zaporizhzhia | `kyiv_oblast_separate`, `kharkiv_separate`, `zaporizhzhia_separate` |
| Switch city | `switching_city_invalidates_cache`, `old_response_cannot_contaminate_new_city` |
| Switch provider / separate tokens | `provider_switch_invalidates_cache`, `old_provider_response_is_discarded`, `official_provider_uses_separate_key` |
| Tokenless public provider | `public_provider_needs_no_token`; separate live transport smoke check |
| City checks all parents | `city_requires_all_parent_checks_before_clear`, `parent_failure_never_clears_city`, `parent_red_stops_remaining_requests` |
| Whole-oblast partial alert | `alerts_oblast_child`, `ua_oblast_partial`; separate cities/outside regions excluded |
| Provider alias and unsupported region | `ua_crimea_alias`, `unsupported_provider_location_avoids_network` |
| Volyn ancestry regression | `volyn_hierarchy_is_not_crimea`, `alerts_volyn_child` |
| Invalid body / unsupported values | Fixture tests; `malformed_json_callback_is_unknown` |
| HTTP 304/401/403/429/5xx, memory and connection errors | `http_failures_never_clear`, `rate_limit_backoff` |
| No phone / timeout | Negative error injection; never CLEAR |
| Stale and clock rollback | `stale_boundary_and_clock_rollback` |
| Recovery | `recovery_after_reconnection` |
| Background publication reaches consumer | `probe-1-consumer.log`: YELLOW → background RED |
| Manual publication reaches consumer | `probe-1-publisher.log` + consumer initial YELLOW |
| Overlap / shared gate / persistence | `overlapping_requests_and_manual_floor`, `shared_gate_survives_city_switch`, `manual_request_updates_persisted_status` |

HTTP/network outcomes are injected into the real callback/cache path. Tests do not prove Garmin Connect phone transport behavior or actual upstream authentication. `malformed.json.txt` supplies a raw invalid JSON fixture; the request test injects the documented invalid-body outcome, since Monkey C does not itself decode the transport JSON here.

## Background memory

Epix definition: background 65,536 bytes; foreground Device App 786,432 bytes. The simulator reports 61,256 bytes as used+free in this service context, with its overhead already reserved.

| Synthetic alert count | Used after allocation | Free after allocation | Result |
|---:|---:|---:|---|
| 1 | 33,864 B | 27,392 B | Consumer RED |
| 10 | 51,264 B | 9,992 B | Consumer RED |
| 25 | Allocation failed | — | Out Of Memory; consumer N/A |

These are current 1.1.0 measurements, including all three provider adapters and the preset metadata. Logs: [one](probe-1-consumer.log), [ten](probe-10-consumer.log), [twenty-five](probe-25-consumer.log). The payload uses the alerts.in.ua shape with distinct strings/dictionaries and long threat text. It is not a live nationwide snapshot or a measurement of phone-side deserialization buffers. Parent requests are sequential, but the maximum Ukraine Alarm/UA Siren response and whole-oblast scope overhead remain unbounded by these tests. No blanket claim that direct nationwide JSON fits is justified.

## Venu 4 support and main view controls — 1.3.0

The production manifest now supports `epix2`, `venu441mm` (390×390) and `venu445mm` (454×454). Strict level-1 production compilation succeeded for all three using stock SDK 9.2.0; the multi-device IQ export succeeded. Logs: [Epix](epix2-build-1.3.0.log), [Venu 41 mm](venu441mm-build-1.3.0.log), [Venu 45 mm](venu445mm-build-1.3.0.log), [package](package-build-1.3.0.log). Model-specific Venu launcher/complication icons avoid scaling warnings in production. All three PRGs and the IQ package passed local SHA-256 verification. The CLI SDK setup was also exercised with the newly added Venu profiles.

Executed the same **83 Monkey C tests on all three devices**, with zero failures/errors: [Epix](unit-tests.log), [Venu 41 mm](unit-tests-venu441mm.log), [Venu 45 mm](unit-tests-venu445mm.log). These are actual simulator runs, separate from CI's compilation-only checks.

The production touch delegate was used by the fixture publisher on both Venu sizes: tapping the main view returned a mocked YELLOW response; a subsequent temporal event ran the real background service and published RED. A separate watch face subscribed, received both values and repainted:

- **41 mm:** [consumer log](probe-1-venu441mm-consumer.log), [manual YELLOW](probe-1-venu441mm-manual.png), [background RED](probe-1-venu441mm-background.png).
- **45 mm:** [consumer log](probe-1-venu445mm-consumer.log), [manual YELLOW](probe-1-venu445mm-manual.png), [background RED](probe-1-venu445mm-background.png).

Both one-alert probes used 35,000 B after synthetic allocation, with 26,256 B free in the service; earlier large-response limitations still apply. The consumer now checks for a string long label before comparing it, because some built-in Venu complications have no label.

The production main view and touch-hold Settings gesture were also exercised on both Venu sizes. Holding the screen opened the real native Menu2 settings screen. The main view lays out actual native font heights and shortens long lines inside the circular display; its device resources show “Tap: Refresh” and “Hold screen: Settings”. Epix resources retain START/MENU hints, and its existing button delegate remains available. Screenshots: [41 mm main](venu441mm-main-1.3.0.png), [41 mm Settings](venu441mm-settings-1.3.0.png), [45 mm main](venu445mm-main-1.3.0.png), [45 mm Settings](venu445mm-settings-1.3.0.png). The UI uses cached fixture states; these screenshots are not live alert information. Physical installation and watch-face interactions remain unverified.

For this local Venu UI check, `Roboto-Regular.ttf` from the upstream [Google Fonts Roboto repository](https://github.com/googlefonts/roboto/blob/main/src/hinted/Roboto-Regular.ttf) was installed into the simulator's local Fonts directory. SHA-256: `56a45233d29f11b4dfb86d248e921939d115778f87325e7ae8cc108383d6664d`. This font is environment-only and is not bundled into the app. It permits the SDK's TTF-based Venu native UI to render; it does not establish exact physical-firmware font metrics. Epix's bitmap native fonts are still unavailable in this environment.

Earlier temporary-manifest compilation logs are retained as the preliminary compatibility check: [41 mm](venu4-41mm-build.log), [45 mm](venu4-45mm-build.log).

## Ukrainian text and letter case — 1.4.0

Added independently selectable status language and case. English uppercase remains the default. Ukrainian Default publishes `Немає`, `Жовта`, `Червона`, `н.д.`, `Застар.`; UPPERCASE and lowercase have explicit Cyrillic variants. The production main view uses the same text formatter. Status dots retain their existing values. The settings callback republishes cached values while preserving request generation, leases, backoff and the background schedule for presentation-only edits.

Executed **89 Monkey C Run No Evil tests on each supported device**, all passing with zero failures/errors: [Epix](unit-tests.log), [Venu 41 mm](unit-tests-venu441mm.log), [Venu 45 mm](unit-tests-venu445mm.log). These replace the earlier 83-test logs linked above; historical results remain in git. Six added tests cover every Ukrainian state/case, English lowercase and invalid-setting fallback, unknown/stale safety, cached-success and 429 backoff preservation, formatting edits during an in-flight request, and reactive language/case labels on the same settings menu instance.

Stock SDK 9.2.0 strict production builds and multi-device export succeeded: [Epix](epix2-build-1.4.0.log), [Venu 41 mm](venu441mm-build-1.4.0.log), [Venu 45 mm](venu445mm-build-1.4.0.log), [package](package-build-1.4.0.log). All four local release binaries passed their SHA-256 checks.

The separate subscribing watch face received Ukrainian values after the production manual Refresh delegate and subsequent temporal events with mocked red and empty responses:

- Epix Default: [Жовта → Червона → Немає](ua-1-consumer.log).
- Epix lowercase: [жовта → червона → немає](ua-lower-1-consumer.log).
- Epix UPPERCASE: [ЖОВТА → ЧЕРВОНА → НЕМАЄ](ua-upper-1-consumer.log).
- Venu 41 mm lowercase: [consumer log](ua-lower-1-venu441mm-consumer.log), [ASCII caption after manual refresh](ua-lower-1-venu441mm-manual.png).
- Venu 45 mm lowercase: [consumer log](ua-lower-1-venu445mm-consumer.log), [ASCII caption after manual refresh](ua-lower-1-venu445mm-manual.png).

These logs record exact Unicode strings read by the consumer through `getComplication()` and its change callback, beyond the publisher's `updateComplication()` return. The fixture's ASCII font displays translated captions (`YELLOW UA`, `RED UA`, `CLEAR UA`), so the checks establish delivery rather than Cyrillic rendering in a third-party face. Font size, case transformations and glyph coverage remain controlled by that face.

Reproduce after building the consumer for the model: `scripts/verify_simulator.py 1 ua epix2`, `1 ua-upper epix2`, or `1 ua-lower epix2` / `venu441mm` / `venu445mm`. The script restores its temporary fixture properties when finished and selects the background-event menu relative to the desktop-scaled popup. No live alert events or tokens are used. The one-alert Ukrainian probe consumed 35,984 B after allocation in Epix's background service (25,272 B free), and 36,080 B on each Venu (25,176 B free); this does not establish that a nationwide response fits.

## Refresh on opening and retained status while fetching — 1.5.0 (2026-10-11)

The production `getInitialView()` creates a Refresh delegate and passes its `onSelect()` callback to the initial view. The first `onShow()` consumes that callback before invoking it, so returning from Settings does not fetch again. Opening follows the existing manual path and preserves shared gates, active-request leases, missing-token/location checks and failure backoff. The background scheduler retains a matching already registered future network/stale deadline instead of postponing it on a skipped foreground request.

Request startup now retains the previous validated state and success timestamp. `Refreshing...` is foreground UI metadata; only a validated response updates state/success. A failed response keeps historical state/time but displays UNKNOWN or STALE. Unknown/failed/stale caches are not made current merely by fetching. An expired nonzero request lease evaluates as UNKNOWN while the old success is otherwise fresh, and retrying an interrupted request marks the old result unavailable until a valid response arrives. The foreground deadline timer also considers lease expiry and performs no network request.

Executed **102 actual Monkey C tests on every model**, with no failures/errors: [Epix](unit-tests.log), [Venu 41 mm](unit-tests-venu441mm.log), [Venu 45 mm](unit-tests-venu445mm.log). The 13 new cases cover opening a fresh cache, one callback per launch, Settings return, manual/reopen gating, missing tokens, 429 backoff, overlap with a background request, retained network/stale deadlines, changed deadlines, all three cached valid states and timestamps while pending, HTTP/network failures, stale transition during fetching, expired leases, and retrying an interrupted CLEAR without prematurely restoring it. The launch tests call the production initial-view factory and replace only the request transport. These logs replace the earlier 89-test logs linked above; historical results remain in git.

Stock SDK 9.2.0 strict production compilation and multi-device export succeeded: [Epix](epix2-build-1.5.0.log), [Venu 41 mm](venu441mm-build-1.5.0.log), [Venu 45 mm](venu445mm-build-1.5.0.log), [package](package-build-1.5.0.log). All four binaries passed local SHA-256 verification.

Using the inherited production view lifecycle with an ASCII drawing override and mocked transport, the fixture fetched YELLOW immediately on opening. The automation did **not** press START or tap Refresh. A separate subscribing face then received YELLOW and, after a temporal event, RED:

- Epix: [publisher](open-probe-1-publisher.log), [consumer](open-probe-1-consumer.log), [background RED](open-probe-1-background.png).
- Venu 41 mm: [publisher](open-probe-1-venu441mm-publisher.log), [consumer](open-probe-1-venu441mm-consumer.log), [opening YELLOW](open-probe-1-venu441mm-manual.png), [background RED](open-probe-1-venu441mm-background.png).
- Venu 45 mm: [publisher](open-probe-1-venu445mm-publisher.log), [consumer](open-probe-1-venu445mm-consumer.log), [opening YELLOW](open-probe-1-venu445mm-manual.png), [background RED](open-probe-1-venu445mm-background.png).

The consumer callback logs show actual delivery through `getComplication()`, beyond successful publisher calls. Reproduce with `scripts/verify_simulator.py 1 text MODEL open` after building that model's consumer. The default `manual` fixture mode disables its automatic callback so existing manual-Refresh probes still test the button/tap. Probe properties are restored after each run. A fixture screenshot's `-manual.png` suffix denotes the pre-background snapshot even in `open` mode; no Refresh input was sent.

The one-alert background probe used 36,200 B after allocation on Epix (25,056 B free) and 36,296 B on each Venu (24,960 B free). Earlier full-response memory limits still apply. Pre-1.5.0 logs describing N/A published before allocation are historical: 1.5.0 intentionally keeps validated history visible during requests. If Garmin terminates the process, consumers can retain that value until another execution evaluates lease/staleness; there is still no complication TTL. This does not guarantee physical delivery or native third-party rendering.

## Network callback compatibility fix — 1.5.1

A supplied physical-watch log identified three `Not Enough Arguments Error` crashes at `AlertRequest.webResponse`, during manual Refresh and two temporal events. The app expected a third context argument; the device invoked the callback with fewer arguments. These records do not establish an upstream HTTP status or rate-limit failure. The private device log is not committed.

Production networking now omits `:context` and binds a two-argument callback to a small handler that captures the request sequence and query index. Late/duplicate replies are still rejected. The integration fixture traverses that same callback adapter. Consumer verification now waits up to ten seconds for actual notification delivery: an initial Venu 41 mm run failed the previous one-second assumption; the bounded wait passed without another production change.

- **108 tests passed on each model**, with zero failures/errors: [Epix](unit-tests.log), [Venu 41 mm](unit-tests-venu441mm.log), [Venu 45 mm](unit-tests-venu445mm.log). Six added cases cover two-argument root-array success, network error, HTTP 429 with retained history/backoff, duplicate parent replies, replies from a previous cycle, and location changes.
- Stock SDK 9.2.0 production builds passed: [Epix](epix2-build-1.5.1.log), [Venu 41 mm](venu441mm-build-1.5.1.log), [Venu 45 mm](venu445mm-build-1.5.1.log), [multi-device package](package-build-1.5.1.log). SHA-256 checks passed for all four local binaries.
- A temporary test app using production `AlertRequest.send` fetched UA Siren's public Kyiv endpoint through Garmin's simulator transport. The bound callback received HTTP 200 and an array, and cache validation succeeded. [Metadata-only log](network-uasiren-1.5.1.log). No response body, token or authorization headers were logged; live alert state was not used as a test assertion.
- On all three models, the fixture fetched YELLOW on opening without pressing Refresh; a separate subscribing watch face then received background RED: [Epix](open-probe-1-consumer.log), [Venu 41 mm](open-probe-1-venu441mm-consumer.log), [Venu 45 mm](open-probe-1-venu445mm-consumer.log). These logs exercise mocked values through the new callback.
- The one-alert background probe used 36,352 B on Epix (24,904 B free), and 36,448 B on each Venu (24,808 B free). The large-response memory constraint remains.

Physical-watch confirmation of the corrected binary and Garmin Connect disconnection/reconnection behavior is still needed. Simulator success does not establish compatibility with every consuming watch face or firmware error path.

## Verification environment and remaining checks

The official Garmin Linux simulator was run under X11 with Epix Gen 2 and both Venu 4 definitions. This workspace lacked the old WebKit/libs required by the downloaded simulator and authenticated Garmin simulator fonts. Legacy runtime libraries were supplied locally. A collision between the simulator's exported static FreeType symbols and the host FreeType was corrected by hiding those exported symbols in the local simulator executable. This is an environment workaround only: no patched simulator is distributed, and application APIs/VM logic were not replaced.

The compatibility/integration/consumer views use bundled DejaVu-derived ASCII raster fonts. The production app uses Garmin native fonts. Epix native-font rendering and the on-watch text picker remain visually unverified; Venu rendering and settings entry are described above. The status deadline timer is foreground-only and performs no request.

Still unverified: physical Epix/Venu installation, third-party watch faces' actual field updates/truncation and app-launch interactions, authenticated live requests, Garmin Connect disconnection/reconnection timing, and real OS-delayed five-minute delivery. No third-party watch face binary was tested; the included consumer is independent test code for public API delivery.

Unsupported guarantees: wrist-raise refresh of this separate Device App; consumer text/background colors; strict automatic expiry while Garmin suppresses all publisher execution. The Complications API has no TTL. A previously published value can remain visible when no service executes, and this publisher cannot force a consuming watch face's repaint policy. See README before installation.
