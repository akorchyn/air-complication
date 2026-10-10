# Verification record — 2026-10-10

## Executed

- Compiled the production Device App for `epix2` using Garmin Connect IQ SDK **9.2.0**, Java 17, strict type-check level 1. See `build.log` and the delivered `artifacts/air-alert.prg`.
- Before implementing REST integration, installed a standalone public TEST publisher and a separate subscribing watch face in the actual Garmin simulator. The consumer displayed TEST. The final source tree retains both targets for reproduction.

  The final clean spike was also re-run: [spike-consumer.log](spike-consumer.log) and [spike-test.png](spike-test.png) show `CONSUMER RECEIVED: TEST` and the consumer display.
- Executed **77 actual Monkey C Run No Evil tests** for version 1.1.0: `PASSED (passed=77, failed=0, errors=0)`. See [unit-tests.log](unit-tests.log). These compile and invoke production Monkey C logic, not a Python reimplementation. New cases cover both response formats, separate tokens, provider switching, whole-oblast partial alerts, Crimea's alias, unsupported provider locations and all-parent request aggregation.
- Made a **real HTTPS UA Siren request** through the official simulator's `Communications.makeWebRequest` transport, using the production request/cache/parser path and a temporary diagnostic subclass. A decoded root JSON array arrived with HTTP 200 and the cache recorded a successful check. See [network-uasiren.log](network-uasiren.log). This checks the SDK callback boundary, whose published static type omits root arrays despite runtime support. The log contains no alert body, API token or headers; live events are not test fixtures. Authenticated providers still need personal-token/hardware checks.
- Pressed simulated Epix START through the production Refresh delegate with a mocked transport. It published YELLOW; subsequently loaded consumer read YELLOW.
- Injected a Garmin simulator temporal background event for the publisher while the consumer watch face was active. The real service/request/cache/parser path published RED; subscribed consumer received RED and repainted. See [probe-1-consumer.log](probe-1-consumer.log), [manual-yellow.png](manual-yellow.png), and [background-red.png](background-red.png).
- Tested 10 and 25 distinct realistic alert dictionaries with long threat messages in the service. Ten propagated RED. Twenty-five exhausted memory; the consumer received N/A, which had been published before allocation. See the logs below.

The temporal integration fixture makes the request immediately due when a simulator event is injected. This tests the service and delivery path without waiting five minutes; production does not have that override. Automated tests and consumer/memory probes use mocked data exclusively; the separate live smoke check is listed above.

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

## Verification environment and remaining checks

The official Garmin Linux simulator was run under X11 with Epix Gen 2 definitions. This workspace lacked the old WebKit/libs required by the downloaded simulator and authenticated Garmin simulator fonts. Legacy runtime libraries were supplied locally. A collision between the simulator's exported static FreeType symbols and the host FreeType was corrected by hiding those exported symbols in the local simulator executable. This is an environment workaround only: no patched simulator is distributed, and application APIs/VM logic were not replaced.

The compatibility/integration/consumer views use bundled DejaVu-derived ASCII raster fonts. The production app uses Garmin native fonts. Its native-font rendering and on-watch text picker were compiled but not visually verified in this workspace. The status deadline timer is foreground-only and performs no request.

Still unverified: physical Epix installation, Tronic's actual field updates/truncation, Pro unlock gating, long-press app launch, authenticated live requests, Garmin Connect disconnection/reconnection timing, and real OS-delayed five-minute delivery. Tronic's proprietary executable was unavailable; the included consumer is independent test code and is not a Tronic replacement.

Unsupported guarantees: wrist-raise refresh of this separate Device App; consumer text/background colors; strict automatic expiry while Garmin suppresses all publisher execution. The Complications API has no TTL. A previously published value can remain visible when no service executes, and this publisher cannot force Tronic's repaint policy. See README before installation.
