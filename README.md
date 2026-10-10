# Air Alert UA — Epix Gen 2 complication publisher

A standalone Connect IQ **Device App** with a public complication, ID `0`. Install it alongside Tronic; it does not change Tronic. The release uses the official detailed alerts.in.ua API and publishes `CLEAR`, `YELLOW`, `RED`, `N/A`, or `STALE`, with a short city label. The included consumer watch face exists only for simulator tests.

**Informational only. Continue using official Ukrainian air-alert notifications.** There are no emergency sounds or guaranteed delivery. `CLEAR` means a successful response contained no applicable **air-raid** alerts; unrelated chemical, nuclear, artillery and urban-fighting alerts are outside this display's scope.

The project compiles for Epix Gen 2 and publisher-to-consumer updates were exercised in Garmin's simulator. Physical Tronic integration and authenticated live API requests remain unverified. Two material limits remain: the nationwide response can exceed background memory, and Garmin provides no complication expiry mechanism. Read the limitations below before relying on this display.

## Build tools

1. Install Garmin's [Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/), sign in, and install the current SDK, **Epix (Gen 2)** device definitions and simulator fonts. Install the Java runtime required by that SDK. The delivered build was compiled with SDK 9.2.0 and Java 17. The Monkey C VS Code extension is optional.
2. Create your own developer key outside this project:

   ```sh
   openssl genrsa -out developer-key.pem 4096
   openssl pkcs8 -topk8 -inform PEM -outform DER -in developer-key.pem -out developer-key.der -nocrypt
   ```

3. Set paths and compile from the project directory:

   ```sh
   export CIQ_SDK=/absolute/path/to/your/sdk
   export CIQ_KEY=/absolute/path/to/developer-key.der
   scripts/build.sh app
   ```

   Output: `build/app/air-alert.prg`. A prebuilt Epix binary is supplied as `bin/air-alert.prg`, signed with a development key. Use your own key for subsequent releases. Never commit private keys or API tokens. The source declares CIQ 4.2 minimum; the current Epix device profile used for this build requires firmware **23.16 or newer** (CIQ 5.2). Update the watch first.

To export an IQ package for your own beta/store workflow, run `scripts/build.sh package`. Nothing is uploaded or published by these scripts. On Windows, use equivalent `monkeyc` commands from `scripts/build.sh`, or run the shell scripts in a suitable shell.

## Installation and settings

For personal sideloading, connect the watch over USB and copy **only the production PRG** to `GARMIN/APPS/air-alert.prg` using an MTP-capable file manager. Safely disconnect. Open **Air Alert UA** from the watch's activity/app list once to initialize its complication and background registration. Do not install the spike/integration binaries on your everyday watch: they share the publisher's application ID and overwrite it.

Obtain a personal API token through the instructions at [devs.alerts.in.ua](https://devs.alerts.in.ua/). Enter it in Air Alert UA's Connect IQ application settings in Garmin Connect / Connect IQ mobile. The resources include native mobile settings for token, city, custom UID/label, refresh interval and stale threshold. Mobile settings availability for a sideloaded app varies by Garmin tooling; the app also provides an on-watch **hold MENU → settings → API token** text picker. The token is never printed in logs or shown back in the configuration menu. It is stored in Garmin application properties, which are not a secret vault.

Choose a city in the dropdown. Default: **Kyiv city, UID 31**, which is distinct from **Kyiv Oblast, UID 14**. For another supported city/community, choose **Custom UID**, enter its official UID and optionally a label of at most five characters. Open the app after changing a custom UID so its foreground-only catalog resolves the parents. Unknown UIDs remain `N/A`; the app does not guess. Changing location invalidates the old cached state immediately when settings are delivered to the watch. Settings delivery itself can be delayed by the phone/watch connection.

All IDs come from the [official location spreadsheet](https://docs.google.com/spreadsheets/d/1XnTOzcPHd1LZUrarR1Fk43FUyl8Ae6a6M7pcwDRjNdA/edit), linked by alerts.in.ua documentation. The bundled CSV snapshot covers 1,471 communities and special-status cities. Some official entries represent an entire territorial community containing a city.

| City | UID | Inherited whole-region alert UIDs | Label |
|---|---:|---|---|
| Kyiv | 31 | None: special-status city | KYIV |
| Kharkiv | 1293 | None: declared separately | KHARK |
| Lviv | 845 | Oblast 27; raion 90 | LVIV |
| Odesa | 964 | Oblast 18; raion 104 | ODESA |
| Dnipro | 332 | Oblast 9; raion 44 | DNIPR |
| Zaporizhzhia | 564 | None: declared separately | ZAPOR |

Matching accepts the exact selected UID, or a whole parent oblast/raion alert with the corresponding `location_type`. A different city is never matched merely because its `location_oblast_uid` is the same. The official list explicitly says Kharkiv and Zaporizhzhia alerts are declared separately from oblast/raion alerts; those cities are exact-only, as are Kyiv and Sevastopol. This exception is intentional and tested. To refresh official mappings, replace `research/locations.csv` with the spreadsheet's CSV export, inspect hierarchy/exception changes, then run `python3 scripts/generate_locations.py` and the tests.

## Add to Tronic

Use [Tronic by frinkr](https://apps.garmin.com/en-UA/apps/a67586af-b888-4c60-9845-1aa064cc3d6d), version 3.0.0 or newer.

1. In Tronic's mobile settings, assign **Custom Complication** to an available data field (near the end of the source list).
2. On the watch, open **Watch Faces → Tronic → Customize → Custom Complication**, choose **Air Alert UA**, and apply the changes.
3. Check that the field shows the published text. Refresh Air Alert UA manually and return to Tronic to check the update on your actual watch.

These steps follow [the author's complication instructions](https://ko-fi.com/Post/Complications-S6S21PPWWW). The author describes a long press on the field launching its associated app; this has not been tested on physical Tronic. Opening Air Alert UA from the app list always provides the explicit Refresh action. Tronic advertises some Pro-only features, but the available instructions do not establish whether this particular field requires a Pro unlock. Confirm that in your installed version; no Pro requirement is assumed here.

The publisher supplies text and a short label. **Tronic controls colors, font, placement, truncation and repainting.** Dynamic text/background coloring is not implemented or claimed. `YELLOW` is the longest value (six characters); actual truncation in each Tronic layout needs hardware checking.

## Refresh and stale data

**Refresh on wrist raise is unsupported for this separate app.** `WatchFace.onExitSleep()` belongs to the active watch face, Tronic. Neither public complication subscription nor publication gives another Device App that callback. There is no invented wake hook or fast polling timer.

The app uses supported, one-shot `Background.registerForTemporalEvent(Time.Moment)` events, registering the next event before starting networking. Intervals are **5, 10, 15, 30 or 60 minutes**, default 5. No event is scheduled sooner than five minutes from registration. Services can run late or be suspended/terminated; Garmin's background service execution window is limited to 30 seconds.

Opening the app displays the cache and arms background work. Press **START** for **Refresh**. Manual refresh starts a request immediately unless a request is already active, another request started within the last minute, or failure backoff is active. It does not bypass a 429 rate limit. Cached values are reused between checks. Changing settings resets failure backoff for recovery after replacing a token; the shared one-minute request gate still applies.

The default stale threshold is **10 minutes** after the last successful check. The next execution publishes `STALE` at or beyond that boundary. Longer refresh intervals also schedule a supported stale-transition event; that event does not fetch early if the network interval has not elapsed. Failures show `N/A` while the prior successful check is fresh, and `STALE` once it is old. First launch without a token shows `N/A` and performs no network request.

While the Device App's status screen remains open, a single foreground-only timer repaints at the stale deadline. It performs no networking and is stopped when the screen is hidden. It cannot wake the separate app while Tronic is active.

**A strict ten-minute expiry in Tronic cannot be guaranteed.** `Complications.Data` has no TTL or expiry field. If Garmin prevents every subsequent execution, a consuming face can retain the last published value, including an earlier `CLEAR`. The app invalidates the published value to `N/A` before each request, which covers termination during fetching, but cannot invalidate a value when it never receives CPU time. There is also no guarantee that Tronic will immediately repaint after a publisher update. This is a platform limitation and an unmet hard-expiry guarantee, not a safety assurance.

## API, validation and caching

Production sends HTTPS GET requests to `https://api.alerts.in.ua/v1/alerts/active.json` with `Authorization: Bearer <configured token>`. It never uses the compact IoT endpoint. Networking runs in supported foreground or background service contexts. No Android companion or server is included.

Only a validated HTTP 200 response with an `alerts` array can produce `CLEAR`. Applicable `air_raid` alerts require recognized `red`/`yellow` severity; threats can raise severity to red. Red wins over yellow and over uncertain additional rows. Missing/unknown levels, malformed relevant rows, unsupported relevant types, invalid JSON and contradictory ended alerts yield `N/A` unless a known applicable red warning exists. Unknown location classification is treated conservatively. Recognized unrelated alert types are excluded.

Application storage retains selected resolved ancestry, state, successful-check epoch, request lease/gate, retry time, failure count and error message. Application properties retain selection and settings. Responses for an old city are discarded if settings changed in flight. The request gate spans location changes. A restarted or terminated request has an expiring lease; no token or authorization header is logged.

| Outcome | Behavior |
|---|---|
| 200, valid | Update cache and public complication; schedule configured interval |
| 304 | `N/A`; no unvalidated cache reuse |
| 401 / 403 | `N/A`; retry after 60 minutes; show token/access error |
| 429 | `N/A`; retry after at least 15 minutes, increasing to 60 |
| 5xx / invalid JSON / network failure | `N/A`; backoff 5, 10, 20, 40, then 60 minutes |
| No phone / timeout | Same failure policy; never substitute `CLEAR` |
| Oversized response | Memory error where reported; `N/A` is already published before allocation |

The provider documents soft limits around 8–10 requests/minute/IP and a hard limit of 12, plus abnormal daily usage restrictions. This app's one-request/minute floor and normal five-minute interval stay below those per-app rates; other applications sharing your IP/token also count.

The API supports `If-Modified-Since` and `Last-Modified`, but the documented `Communications.makeWebRequest` callback does not expose response headers. This implementation therefore does not issue conditional requests or invent modification metadata. The reserved `modified` cache field remains null. An unsolicited 304 is handled as unavailable rather than refreshing an unverified timestamp. Per-alert `updated_at` is not substituted for the endpoint's `Last-Modified` header.

## Background memory and an optional proxy

Epix Gen 2's device definition allows **64 KiB background memory**, versus 768 KiB for a foreground Device App. `makeWebRequest` allocates the decoded nationwide JSON before this app can filter it. The large official location catalog is deliberately excluded from background code; only selected ancestry is retained there.

Actual simulator probes using the real request callback, parser and publisher measured approximately **21 KiB used for one realistic alert** and **38 KiB for ten**. A 25-record fixture with long message strings caused **Out Of Memory** in the background service; the running consumer received **N/A**. See [verification evidence](docs/VERIFICATION.md). These synthetic records investigate decoded object memory; they do not prove a particular live API body will fit or reproduce the phone's JSON transport buffers.

**Direct background integration cannot be guaranteed during widespread alerts.** Nationwide responses are unbounded and can exceed the measured limit. Manual foreground Refresh has more memory, but is not a substitute for reliable unattended updates. Truncated responses must never be treated as complete. This project deliberately keeps direct personal-token integration and fails closed; it does not claim the nationwide payload always fits.

For dependable large-response operation or public distribution, a minimal HTTPS caching proxy is the justified next architecture: obtain the complete detailed response on a server, validate it, cache upstream requests, and return a small complete `alerts` wrapper containing exact-location and applicable whole-parent alerts, preserving severity and threats. Empty output is allowed only after a successful complete upstream validation; upstream failures must return an error. Retain the separate-city exceptions and the same fixture tests. Use per-user client authorization and keep the upstream token on the server. The proxy is **evaluated, not implemented** here; adding it requires an explicit HTTPS endpoint configuration and authentication change to `AlertRequest.send()`. The current release contacts the official endpoint directly. Do not publish a shared API token inside a downloadable PRG.

## Simulator and tests

Start the official Garmin simulator with `"$CIQ_SDK/bin/connectiq"` (or SDK Manager / VS Code). Installed device profiles and fonts are required. The following targets are intentionally separate; build sequentially and do not install multiple publisher variants on hardware.

Compatibility spike, with no API integration:

```sh
scripts/build.sh spike
scripts/build.sh consumer
"$CIQ_SDK/bin/monkeydo" build/spike/spike.prg epix2
# Then load the consumer in the same running simulator:
"$CIQ_SDK/bin/monkeydo" build/consumer/consumer.prg epix2
```

The consumer discovers the public complication by its long label, subscribes to it, draws `TEST`, and prints `CONSUMER RECEIVED: TEST`. Successful publisher API execution alone is not the assertion. This spike was performed before REST implementation.

Run the actual Monkey C **Run No Evil** tests with mocked fixtures:

```sh
scripts/test.sh
```

The script generates Monkey C literals from JSON fixtures, compiles the production logic with tests, and checks the simulator's test summary. Tests cover all requested state, matching, switching, HTTP, connection, stale and recovery cases, plus request overlap, corrupted cache and late-response rejection. Raw malformed JSON is also provided; the callback test injects Garmin's invalid-body error rather than implementing another JSON parser.

To verify manual and background publication:

```sh
scripts/build.sh integration
scripts/build.sh consumer
"$CIQ_SDK/bin/monkeydo" build/integration/integration.prg epix2
# Press START: production Refresh path publishes YELLOW.
"$CIQ_SDK/bin/monkeydo" build/consumer/consumer.prg epix2
# Simulator: Simulation > Background Events > Temporal Event > Air Alert UA > OK
# Consumer must receive and draw RED.
```

The integration subclass replaces only the transport and test scheduling gate, uses a fixture-only token, and exercises the production cache, parser, request lifecycle and publication. Its simulator event override permits immediate manual injection; production still enforces five-minute scheduling. Optional Linux X11 automation: install `python-xlib` and ImageMagick, position the standard simulator window at the top left, then run `python3 scripts/verify_simulator.py 1` (or `10`, `25`) with `DISPLAY` set. It is tailored to the standard Epix simulator layout; use the manual steps on other desktops.

The production UI uses native system fonts and simple system settings widgets. Test views use bundled ASCII raster fonts to remain readable in environments missing authenticated simulator font downloads. The release UI's native-font rendering was not visually verified here; fixture UI and consuming-face values were. See the verification record for the local Linux simulator runtime workaround and the remaining hardware checks.

## Project map and references

`source/`: publisher lifecycle, service, request/cache logic, matching, city resolver and watch UI. `resources/`: public complication, icons, native mobile settings/properties. `spike/`: TEST publisher. `tests/consumer/`: subscribing test face. `tests/integration/`: mocked transport/background probe. `tests/unit/`, `tests/fixtures/`: automated logic/request tests. `scripts/`: reproducible builds and fixture/catalog generation.

Official references: [Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html), [Background services](https://developer.garmin.com/connect-iq/articles/core-topics/Backgrounding.html), [WatchFace lifecycle](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html), [Communications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html), [publisher/consumer example discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/353286/sample-of-ciq-complication-publisher-and-consumer-of-those-complications), [alerts.in.ua API](https://devs.alerts.in.ua/), [Tronic instructions](https://ko-fi.com/Post/Complications-S6S21PPWWW).

Test font attribution and license: [docs/FONT-LICENSE.txt](docs/FONT-LICENSE.txt). No Garmin SDK, simulator executable, Tronic binary, private developer key or live API token is included.
