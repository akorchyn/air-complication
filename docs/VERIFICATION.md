# Verification record — 2026-10-10

## Executed

- Compiled the production Device App for `epix2` using Garmin Connect IQ SDK **9.2.0**, Java 17, strict type-check level 1. See `build.log` and the delivered `artifacts/air-alert.prg`.
- Before implementing REST integration, installed a standalone public TEST publisher and a separate subscribing watch face in the actual Garmin simulator. The consumer displayed TEST. The final source tree retains both targets for reproduction.

  The final clean spike was also re-run: [spike-consumer.log](spike-consumer.log) and [spike-test.png](spike-test.png) show `CONSUMER RECEIVED: TEST` and the consumer display.
- Executed **41 actual Monkey C Run No Evil tests**: `PASSED (passed=41, failed=0, errors=0)`. See [unit-tests.log](unit-tests.log). These compile and invoke production Monkey C logic, not a Python reimplementation.
- Pressed simulated Epix START through the production Refresh delegate with a mocked transport. It published YELLOW; subsequently loaded consumer read YELLOW.
- Injected a Garmin simulator temporal background event for the publisher while the consumer watch face was active. The real service/request/cache/parser path published RED; subscribed consumer received RED and repainted. See [probe-1-consumer.log](probe-1-consumer.log), [manual-yellow.png](manual-yellow.png), and [background-red.png](background-red.png).
- Tested 10 and 25 distinct realistic alert dictionaries with long threat messages in the service. Ten propagated RED. Twenty-five exhausted memory; the consumer received N/A, which had been published before allocation. See the logs below.

The temporal integration fixture makes the request immediately due when a simulator event is injected. This tests the service and delivery path without waiting five minutes; production does not have that override. There are no networking calls to the live API in tests.

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
| 1 | 21,752 B | 39,504 B | Consumer RED |
| 10 | 39,152 B | 22,104 B | Consumer RED |
| 25 | Allocation failed | — | Out Of Memory; consumer N/A |

Logs: [one](probe-1-consumer.log), [ten](probe-10-consumer.log), [twenty-five](probe-25-consumer.log). The payload includes distinct strings/dictionaries and long threat text. It is not a live nationwide snapshot or a measurement of phone-side deserialization buffers. No blanket claim that direct nationwide JSON fits is justified.

## Verification environment and remaining checks

The official Garmin Linux simulator was run under X11 with Epix Gen 2 definitions. This workspace lacked the old WebKit/libs required by the downloaded simulator and authenticated Garmin simulator fonts. Legacy runtime libraries were supplied locally. A collision between the simulator's exported static FreeType symbols and the host FreeType was corrected by hiding those exported symbols in the local simulator executable. This is an environment workaround only: no patched simulator is distributed, and application APIs/VM logic were not replaced.

The compatibility/integration/consumer views use bundled DejaVu-derived ASCII raster fonts. The production app uses Garmin native fonts. Its native-font rendering and on-watch text picker were compiled but not visually verified in this workspace. The status deadline timer is foreground-only and performs no request.

Still unverified: physical Epix installation, Tronic's actual field updates/truncation, Pro unlock gating, long-press app launch, authenticated live requests, Garmin Connect disconnection/reconnection timing, and real OS-delayed five-minute delivery. Tronic's proprietary executable was unavailable; the included consumer is independent test code and is not a Tronic replacement.

Unsupported guarantees: wrist-raise refresh of this separate Device App; consumer text/background colors; strict automatic expiry while Garmin suppresses all publisher execution. The Complications API has no TTL. A previously published value can remain visible when no service executes, and this publisher cannot force Tronic's repaint policy. See README before installation.
