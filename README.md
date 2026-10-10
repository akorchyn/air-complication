# Air Alert UA — Garmin air-alert complication

A standalone Connect IQ **Device App** that publishes Ukrainian air-alert status as a public complication, ID `0`. Use it with any watch face that supports **third-party Connect IQ complications** on a supported device. Select **alerts.in.ua**, **Ukraine Alarm**, or **UA Siren** and monitor a city or oblast. Choose **Text** in English or Ukrainian with configurable letter case, or **Status dots** (🟢, 🟡, 🔴, `?`, `!`), with a short location label. The included consumer watch face exists only for simulator tests.

Download the PRG for your watch from the **[latest GitHub Release](https://github.com/akorchyn/air-complication/releases/latest)**:

| Watch | Installable download | Display |
|---|---|---|
| Epix (Gen 2) | [air-alert.prg](https://github.com/akorchyn/air-complication/releases/latest/download/air-alert.prg) | 416×416 |
| Venu 4, 41 mm | [air-alert-venu441mm.prg](https://github.com/akorchyn/air-complication/releases/latest/download/air-alert-venu441mm.prg) | 390×390 |
| Venu 4, 45 mm | [air-alert-venu445mm.prg](https://github.com/akorchyn/air-complication/releases/latest/download/air-alert-venu445mm.prg) | 454×454 |

Copy **only the matching PRG**, renamed to `air-alert.prg`, to `GARMIN/APPS/air-alert.prg` on the connected watch. Safely disconnect and open Air Alert UA once. Source control contains no generated binaries; release assets and GitHub Actions downloads contain the builds.

**Informational only. Continue using official Ukrainian air-alert notifications.** There are no emergency sounds or guaranteed delivery. `CLEAR` means a successful response contained no applicable **air-raid** alerts; unrelated chemical, nuclear, artillery and urban-fighting alerts are outside this display's scope.

The project targets Epix Gen 2 and both Venu 4 sizes. Publisher-to-consumer updates were exercised in Garmin's simulator. A real UA Siren request also succeeded in the simulator. Physical integration with third-party watch faces and authenticated live API requests remain unverified. Two material limits remain: nationwide responses can exceed background memory, and Garmin provides no complication expiry mechanism. Read the limitations below before relying on this display.

## Compatibility

The complication uses Garmin's public `Toybox.Complications` API and has no dependency on a particular watch face. The face must let you select an external/custom Connect IQ complication and display its string value. Support for built-in Garmin data fields alone does not establish support for third-party publishers. Picker names, available fields and any paid feature requirements depend on the watch face.

**Supported products:** `epix2`, `venu441mm`, and `venu445mm`. Device support and watch-face support are separate requirements; use the PRG compiled for your exact model. The exported IQ package contains all supported products.

The main view adapts to screen dimensions and native font heights, and shortens long lines to fit the round display. It shows how to use the app:

| Watch | Refresh | Settings |
|---|---|---|
| Epix (Gen 2) | Press START, or tap the screen with touch enabled | Hold MENU (middle-left button), or hold the screen with touch enabled |
| Venu 4, either size | Tap the screen, or press the top-right button | Hold the screen |

On Venu, the bottom-right button goes back. These touch controls apply to the main view; the settings screens use Garmin's native menus and pickers. Venu has no Epix-style MENU button. All three devices have a 64 KiB background-memory limit, so Venu support does not remove the response-size constraint. See [verification evidence](docs/VERIFICATION.md#venu-4-support-and-main-view-controls--130) for simulator results and remaining physical-watch checks.

## Build tools

1. Install Garmin's [Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/), sign in, and install the current SDK, **Epix (Gen 2)** and/or **Venu 4 (41 mm / 45 mm)** device definitions and simulator fonts. Install the Java runtime required by that SDK. The delivered build was compiled with SDK 9.2.0 and Java 17. The Monkey C VS Code extension is optional.
2. Create your own developer key outside this project:

   ```sh
   openssl genrsa -out developer-key.pem 4096
   openssl pkcs8 -topk8 -inform PEM -outform DER -in developer-key.pem -out developer-key.der -nocrypt
   ```

3. Set paths and compile from the project directory:

   ```sh
   export CIQ_SDK=/absolute/path/to/your/sdk
   export CIQ_KEY=/absolute/path/to/developer-key.der
   scripts/build.sh app                # Epix Gen 2
   scripts/build.sh app venu441mm     # Venu 4, 41 mm
   scripts/build.sh app venu445mm     # Venu 4, 45 mm
   ```

   Outputs: `artifacts/air-alert.prg`, `artifacts/air-alert-venu441mm.prg`, and `artifacts/air-alert-venu445mm.prg`, respectively. Compiler intermediates remain in `build/`; local outputs are copied to the ignored `artifacts/` directory. Downloadable prebuilt binaries are GitHub Release assets. Never commit private keys or API tokens. The source declares CIQ 4.2 minimum; the pinned device profiles require Epix firmware **23.16 or newer** (CIQ 5.2) and Venu 4 firmware **17.33 or newer** (CIQ 6.0.2). Update the watch first.

To export an IQ package for your own beta/store workflow, run `scripts/build.sh package`. Nothing is uploaded or published by these scripts. On Windows, use equivalent `monkeyc` commands from `scripts/build.sh`, or run the shell scripts in a suitable shell.

## GitHub Actions builds

[Build Connect IQ](https://github.com/akorchyn/air-complication/actions/workflows/build.yml) runs on pushes to `main`, pull requests, version tags and manual **Run workflow** requests. It builds a PRG for each supported model and a multi-device IQ package, and compiles the separate spike, consumer, integration and unit-test targets for all three models. Tag pushes such as `v1.4.0` automatically create a **GitHub Release** containing the three model-specific PRGs, `air-alert.iq`, and `SHA256SUMS`. The tag must match the application version in `manifest.xml`. These are the downloadable binaries shown in GitHub's **Releases** sidebar; publishing a GitHub Package is unnecessary for a Garmin PRG.

For an untagged development build, open a successful run and download **Air-Alert-UA-Epix-Gen-2-and-Venu-4** under **Artifacts**. Extract the ZIP, choose your model's PRG, and copy it to your watch as `GARMIN/APPS/air-alert.prg`. The separate simulator-fixture download must not be installed on your everyday watch.

Local builds produce the PRGs listed above and `artifacts/air-alert.iq`, with `artifacts/SHA256SUMS`. Epix fixture outputs are `artifacts/spike.prg`, `consumer.prg`, `integration.prg`, and `tests.prg`; Venu fixture names include `-venu441mm` or `-venu445mm` before `.prg`. Both output directories are ignored by Git. CI stores downloadable artifacts and publishes tag builds as GitHub Releases; it does not publish to the Garmin store.

The workflow uses Java 17, official Garmin SDK 9.2.0 and the existing public device-definition cache, pinned to an immutable commit and SHA-256 checksums. `scripts/setup-ci-sdk.sh /absolute/install/directory` reproduces the Linux CLI setup. Device/font downloads through Garmin SDK Manager require authentication; the public definition snapshot allows unattended compilation without a Garmin login. No simulator executable modifications are used for CI builds.

No secrets are required for a build. By default CI creates a temporary development signing key, then deletes it; the signing identity changes between runs. For a consistent identity, set repository Actions secret **CIQ_SIGNING_KEY_BASE64** to the base64 representation of your own DER developer key. Never put the key in Git. Fork pull requests use a temporary key because repository secrets are withheld. No provider token is used or embedded by CI.

CI **compiles** the Run No Evil tests; it does not execute the graphical Garmin simulator or claim fresh simulator test results. Run `scripts/test.sh` locally with a working simulator to execute them. The repository contains the executed **89-test** verification logs for Epix and both Venu sizes.

## Installation and settings

For personal sideloading, connect the watch over USB and copy **only the production PRG for your exact model**, renamed to `air-alert.prg`, to `GARMIN/APPS/air-alert.prg` using an MTP-capable file manager. Safely disconnect. Open **Air Alert UA** from the watch's activity/app list once to initialize its complication and background registration. Do not install the spike/integration binaries on your everyday watch: they share the publisher's application ID and overwrite it.

Choose **API provider** in Air Alert UA's Connect IQ application settings in Garmin Connect / Connect IQ mobile:

| Provider | Configuration | Connection |
|---|---|---|
| alerts.in.ua (default) | Obtain a personal token through [devs.alerts.in.ua](https://devs.alerts.in.ua/); enter **alerts.in.ua API token** | Official detailed active-alerts endpoint; Bearer authentication |
| Ukraine Alarm | Request a separate key through [api.ukrainealarm.com](https://api.ukrainealarm.com/); enter **Ukraine Alarm API token** | Official API; raw key in Authorization header |
| UA Siren | No token required | Public [Ukraine Alarm wrapper](https://siren.pp.ua/); adds a third-party intermediary |

The two tokens are separate properties; switching provider retains each token and invalidates the cached status. There is no automatic fallback to a different provider. Enter only the token/key, without adding `Bearer`.

Mobile settings availability for a sideloaded app varies by Garmin tooling; the app also provides **API provider / Provider token / Location** in its on-watch settings. On Epix, hold **MENU** (middle-left button); on Venu 4, **hold the screen**. The main screen shows the matching Refresh and Settings hints. Touch hold also works on Epix when touch is enabled. The token picker edits the currently selected provider's token. Tokens are never printed in logs or shown back in the menu. They are stored in application properties, which are not a secret vault. Settings also include custom UID/label, refresh interval and stale threshold. The on-watch menu updates immediately when returning from a picker, including provider-specific token requirements; there is no need to close and reopen settings.

The location dropdown has **32 presets**: all **24 oblasts**, **Crimea**, **Kyiv city**, **Kharkiv city**, **Zaporizhzhia city**, **Sevastopol**, **Lviv**, **Odesa**, and **Dnipro**, plus **Custom UID**. Default: **Kyiv city, UID 31**, which is distinct from **Kyiv Oblast, UID 14**.

For another supported city/community, choose **Custom UID**, enter its official alerts.in.ua UID and optionally a label of at most five characters. Open the app after selecting an oblast or changing a custom UID so its foreground-only catalog resolves the selected scope. Unknown UIDs remain `N/A`; the app does not guess. Changing location or provider invalidates old cached status when settings are delivered to the watch. Settings delivery can be delayed by the phone/watch connection.

Ukraine Alarm and UA Siren do not list Sevastopol or every community from the alerts.in.ua spreadsheet; unsupported selections show `N/A` without making a request. Crimea retains canonical UID **29** in settings and is translated to these providers' ID **9999** internally. Selecting a region does not establish that reliable reporting exists throughout occupied territory.

All IDs come from the [official location spreadsheet](https://docs.google.com/spreadsheets/d/1XnTOzcPHd1LZUrarR1Fk43FUyl8Ae6a6M7pcwDRjNdA/edit), linked by alerts.in.ua documentation. The bundled CSV snapshot covers 1,471 communities and special-status cities. Some official entries represent an entire territorial community containing a city.

| City | UID | Inherited whole-region alert UIDs | Label |
|---|---:|---|---|
| Kyiv | 31 | None: special-status city | KYIV |
| Kharkiv | 1293 | None: declared separately | KHARK |
| Lviv | 845 | Oblast 27; raion 90 | LVIV |
| Odesa | 964 | Oblast 18; raion 104 | ODESA |
| Dnipro | 332 | Oblast 9; raion 44 | DNIPR |
| Zaporizhzhia | 564 | None: declared separately | ZAPOR |

For a **city**, matching accepts its exact UID or a whole parent oblast/raion alert of the corresponding type. A sibling city's alert does not cover it. The official list explicitly says Kharkiv and Zaporizhzhia alerts are declared separately; these are exact-only, as are Kyiv and Sevastopol.

For an **oblast**, matching accepts its own alert and district/community alerts inside its verified scope, excluding those four independently declared cities. Thus `RED` or `YELLOW` means an applicable alert **somewhere in the selected alert region**, including a partial alert; it does not mean every locality is affected. Known outside locations are excluded. An unknown UID without enough ancestry information prevents `CLEAR`.

All these rules have mocked regression tests. The generator cross-checks the official CSV's hierarchy against the Ukraine Alarm directory snapshot; the CSV inserts Crimea between Volyn and its districts, so row order alone must not assign Volyn's communities to Crimea. See [data provenance](research/PROVENANCE.md). To update mappings, refresh both directory snapshots, inspect differences, run `python3 scripts/generate_locations.py`, and run the tests.

## Add to a watch face

1. Install and open **Air Alert UA** once. Configure its provider, token if required, and location; use **Refresh** to obtain a status.
2. In your watch face's settings, assign an **external/custom complication** to an available field. Depending on the face, this is configured in its mobile settings, its on-watch customization menu, or both. Follow the face author's instructions.
3. In the complication picker, select **Air Alert UA** and save/apply the changes. If the face does not offer third-party publishers, it cannot consume this complication.
4. Refresh Air Alert UA manually, then return to the watch face and check that the field displays the updated status and location label.

Some faces can launch a complication's associated app when its field is selected or long-pressed. This interaction depends on the face and is unverified here. You can open Air Alert UA from the watch's app list to use Refresh and settings.

The publisher supplies text and a short label. **Your watch face controls colors, font size, placement, truncation and repainting.** Dynamic text/background coloring is not implemented or claimed. `YELLOW` and `Червона` are the longest normal English/Ukrainian values; check readability in your chosen field.

## Complication display mode

Choose **Complication display mode** in mobile settings or open the on-watch **Settings → Display mode** menu:

| Status | English text (default) | Ukrainian text | Status dots |
|---|---|---|---|
| No applicable active air-raid alert after a validated check | CLEAR | Немає | 🟢 |
| Yellow-level air-raid alert | YELLOW | Жовта | 🟡 |
| Red-level air-raid alert | RED | Червона | 🔴 |
| Unavailable / failed / unknown | N/A | н.д. | `?` |
| Last successful check is stale | STALE | Застар. | `!` |

For Ukrainian, select **Status text language → Українська** in mobile settings or **Settings → Text language → Українська** on the watch. **Status text case / Text case** offers:

| Choice | English example | Ukrainian example |
|---|---|---|
| Default | YELLOW | Жовта |
| UPPERCASE | YELLOW | ЖОВТА |
| lowercase | yellow | жовта |

For a less prominent appearance, try **Українська + lowercase**: `немає`, `жовта`, `червона`, `н.д.` and `застар.`. This changes the characters supplied to the face; the face determines their size and may enforce its own capitalization. Its font must contain Cyrillic glyphs to display Ukrainian. Cyrillic delivery is tested in the simulator; rendering in your chosen third-party face remains device/font dependent. Language and case apply to status words on the app's own screen too; Status dots keep the same symbols.

These are literal Unicode characters (U+1F7E2, U+1F7E1, U+1F534), not published images or instructions to recolor text. Dot mode is optional: **your watch face's font must support those characters**. They may appear monochrome, as missing-glyph boxes or blank. Colored emoji rendering by third-party watch faces is **unverified** and cannot be guaranteed by the publisher; switch back to Text if the symbols are unreadable. The included ASCII-font consumer proves the Unicode values arrive, but draws captions rather than claiming to render color emoji.

The app's own status screen keeps readable status words. Changing only display mode, text language or letter case republishes the same cached state immediately, without an API request. It preserves failure backoff, in-flight requests and the existing background event. After a restart, the app applies the saved presentation settings to its cache. Selecting a different provider/location continues to invalidate old status.

## Refresh and stale data

**Refresh on wrist raise is unsupported for this separate app.** `WatchFace.onExitSleep()` belongs to the active watch face. Neither public complication subscription nor publication gives another Device App that callback. There is no invented wake hook or fast polling timer.

The app uses supported, one-shot `Background.registerForTemporalEvent(Time.Moment)` events, registering the next event before starting networking. Intervals are **5, 10, 15, 30 or 60 minutes**, default 5. No event is scheduled sooner than five minutes from registration. Services can run late or be suspended/terminated; Garmin's background service execution window is limited to 30 seconds.

Opening the app displays the cache and arms background work. Use **Refresh**: press START on Epix, or tap the screen / press the top-right button on Venu 4. Manual refresh starts a check immediately unless a check is already active, another check started within the last minute, or failure backoff is active. A city check can make up to three sequential requests when verifying parents. It does not bypass a 429 rate limit. Cached values are reused between checks. Data/refresh-setting changes reset failure backoff for recovery after replacing a token; the shared one-minute gate still applies. Presentation-only changes retain that backoff.

The default stale threshold is **10 minutes** after the last successful check. The next execution publishes `STALE` at or beyond that boundary. Longer refresh intervals also schedule a supported stale-transition event; that event does not fetch early if the network interval has not elapsed. Failures show `N/A` while the prior successful check is fresh, and `STALE` once it is old. First launch with the default provider and no token shows `N/A` without requesting data. UA Siren needs no token but still requires a successful Refresh before showing a status.

While the Device App's status screen remains open, a single foreground-only timer repaints at the stale deadline. It performs no networking and is stopped when the screen is hidden. It cannot wake the separate app while a watch face is active.

**A strict ten-minute expiry in a consuming watch face cannot be guaranteed.** `Complications.Data` has no TTL or expiry field. If Garmin prevents every subsequent execution, a consuming face can retain the last published value, including an earlier `CLEAR` or green dot. The app invalidates the published value to `N/A` (or `?` in dot mode) before each request, which covers termination during fetching, but cannot invalidate a value when it never receives CPU time. There is also no guarantee that a watch face will immediately repaint after a publisher update. This is a platform limitation and an unmet hard-expiry guarantee, not a safety assurance.

## API, validation and caching

All providers use HTTPS in supported foreground or background service contexts. No Android companion or server is included.

- **alerts.in.ua:** `GET https://api.alerts.in.ua/v1/alerts/active.json`, `Authorization: Bearer <token>`. The detailed API preserves severity; the compact IoT endpoint is not used.
- **Ukraine Alarm:** `GET https://api.ukrainealarm.com/api/v3/alerts/{regionId}`, `Authorization: <key>`.
- **UA Siren:** `GET https://siren.pp.ua/api/v3/alerts/{regionId}`, without authentication. Same documented alert model as Ukraine Alarm.

For the latter two, a city check verifies the selected location and applicable parent oblast/raion sequentially. An empty regional response array is invalid; a validated regional record with an empty `activeAlerts` array is valid. `CLEAR` is published only after **every** required response validates. A known applicable RED can end the check early. A failed parent check cannot turn an empty city response into `CLEAR`.

**Oblast monitoring uses the nationwide endpoint** for all three providers. In live UA Siren checks, an oblast's regional endpoint could report no whole-oblast alert while district/community alerts inside it were active. A single oblast request therefore cannot establish that the entire selected scope has no alerts. Nationwide data is filtered using the stored verified scope; its memory risk is described below.

Only validated HTTP 200 data can produce `CLEAR`. alerts.in.ua requires an `alerts` array and recognized `red`/`yellow` severity for applicable `air_raid` alerts; threats can raise severity to red. Ukraine Alarm/UA Siren require an array of valid regional records; applicable `AIR` alerts need a nonempty `activeAlertLevels` array containing recognized `Red`/`Yellow` levels. Red wins over yellow and uncertain additional rows. Missing/unknown levels, malformed relevant rows, unsupported relevant types, invalid JSON and contradictory ended alerts yield `N/A` unless an applicable red warning exists. Unknown location classification is conservative; recognized unrelated alert types are excluded.

Application storage retains selected scope/ancestry, provider identity, state, successful-check epoch, request sequence/lease/gate, retry time, failure count and error message. Application properties retain selection and settings. Responses from an old location/provider or data-setting generation are discarded; a presentation-only edit keeps the in-flight request and formats its result with the current mode, language and case. The shared gate spans data-setting changes; requests have expiring leases. No token or authorization header is logged. The foreground settings comparison is held only in memory, not copied into storage.

| Outcome | Behavior |
|---|---|
| 200, valid | Update cache and public complication; schedule configured interval |
| 304 | `N/A`; no unvalidated cache reuse |
| 401 / 403 | `N/A`; retry after 60 minutes; show token/access error |
| 429 | `N/A`; retry after at least 15 minutes, increasing to 60 |
| 5xx / invalid JSON / network failure | `N/A`; backoff 5, 10, 20, 40, then 60 minutes |
| No phone / timeout | Same failure policy; never substitute `CLEAR` |
| Oversized response | Memory error where reported; `N/A` is already published before allocation |

alerts.in.ua documents soft limits around 8–10 requests/minute/IP and a hard limit of 12, plus abnormal daily usage restrictions. UA Siren documents 200 requests/five minutes/IP. The app permits at most one refresh cycle/minute, normally one/five minutes; Ukraine Alarm/UA Siren city cycles make at most three sequential requests. Background cycles share the foreground gate. Other apps on your IP/key also count, and provider quotas can change. A 429 from any provider enforces backoff.

The API supports `If-Modified-Since` and `Last-Modified`, but the documented `Communications.makeWebRequest` callback does not expose response headers. This implementation therefore does not issue conditional requests or invent modification metadata. The reserved `modified` cache field remains null. An unsolicited 304 is handled as unavailable rather than refreshing an unverified timestamp. Per-alert `updated_at` is not substituted for the endpoint's `Last-Modified` header.

## Background memory and an optional proxy

The supported Epix Gen 2 and Venu 4 device definitions allow **64 KiB background memory**, versus 768 KiB for a foreground Device App. `makeWebRequest` allocates decoded JSON before this app can filter it. The large location catalog is excluded from background code; only selected ancestry/scope is retained there. Ukraine Alarm/UA Siren **city** requests usually avoid the nationwide response, but their maximum regional payload still has no proven memory bound.

Actual simulator probes using the production callback, parser and publisher measured decoded-object memory and exercised an oversized fixture that caused **Out Of Memory**; the running consumer received **N/A**, published before allocation. See the current measurements and logs in [verification evidence](docs/VERIFICATION.md). Synthetic records do not prove a particular live body will fit or reproduce the phone's JSON transport buffers.

**Nationwide background integration cannot be guaranteed during widespread alerts.** This affects alerts.in.ua and whole-oblast checks with every provider. Manual foreground Refresh has more memory, but does not guarantee unattended updates. Truncated responses must never be treated as complete. The app fails closed and does not claim these bodies always fit.

For dependable large-response operation or public distribution, a minimal HTTPS caching proxy is an optional next architecture: obtain and validate a complete upstream response on a server, cache upstream requests, and return a small complete result for the selected scope, preserving severity and ancestry. Empty output is allowed only after complete successful validation; upstream failures must return an error. Retain separate-city exceptions and fixture tests. Use per-user authorization and keep upstream tokens on the server. This proxy is **evaluated, not implemented**; adding it requires explicit endpoint configuration and a provider adapter. Direct personal-token configuration remains supported. Do not embed a shared API token in a publicly downloadable PRG.

See [the alternative API comparison](docs/API-ALTERNATIVES.md) for provider documentation, regional-response observations and other researched services that are not integrated.

## Simulator and tests

Start the official Garmin simulator with `"$CIQ_SDK/bin/connectiq"` (or SDK Manager / VS Code). Installed device profiles and fonts are required. The following targets are intentionally separate; build sequentially and do not install multiple publisher variants on hardware.

Compatibility spike, with no API integration:

```sh
scripts/build.sh spike
scripts/build.sh consumer
"$CIQ_SDK/bin/monkeydo" artifacts/spike.prg epix2
# Then load the consumer in the same running simulator:
"$CIQ_SDK/bin/monkeydo" artifacts/consumer.prg epix2
```

The consumer discovers the public complication by its long label, subscribes to it, draws `TEST`, and prints `CONSUMER RECEIVED: TEST`. Successful publisher API execution alone is not the assertion. This spike was performed before REST implementation.

Run the actual Monkey C **Run No Evil** tests with mocked fixtures:

```sh
scripts/test.sh               # Epix Gen 2
scripts/test.sh venu441mm     # Venu 4, 41 mm
scripts/test.sh venu445mm     # Venu 4, 45 mm
```

The script generates Monkey C literals from JSON fixtures, compiles the production logic with tests, and checks the simulator's test summary. Tests cover all requested state, matching, switching, HTTP, connection, stale and recovery cases, plus request overlap, corrupted cache and late-response rejection. Raw malformed JSON is also provided; the callback test injects Garmin's invalid-body error rather than implementing another JSON parser.

To verify manual and background publication:

```sh
scripts/build.sh integration
scripts/build.sh consumer
"$CIQ_SDK/bin/monkeydo" artifacts/integration.prg epix2
# Press START: production Refresh path publishes YELLOW.
"$CIQ_SDK/bin/monkeydo" artifacts/consumer.prg epix2
# Simulator: Simulation > Background Events > Temporal Event > Air Alert UA > OK
# Consumer must receive and draw RED.
```

The integration subclass replaces only the transport and test scheduling gate, uses a fixture-only token, and exercises the production cache, parser, request lifecycle and publication. Its simulator event override permits immediate manual injection; production still enforces five-minute scheduling. Optional Linux X11 automation: install `python-xlib` and ImageMagick, position the standard simulator window at the top left, then run `python3 scripts/verify_simulator.py 1` (or `10`, `25`) with `DISPLAY` set. The optional third argument selects `epix2` (default), `venu441mm`, or `venu445mm`; for example, compile `scripts/build.sh consumer venu441mm` and run `python3 scripts/verify_simulator.py 1 text venu441mm`. It uses standard simulator window geometry with the window positioned at the top left; use manual steps on other desktops.

To check Unicode delivery with the same publisher/consumer paths, compile the consumer and run `python3 scripts/verify_simulator.py 1 dots`. Its log must contain the exact values `CONSUMER RECEIVED: 🟡`, `CONSUMER RECEIVED: 🔴`, and `CONSUMER RECEIVED: 🟢`. This validates publication and delivery; it does not verify another watch face's glyphs or colors.

The production UI uses native system fonts and simple system settings widgets. Venu's main screen and touch-hold settings menu were exercised with a local Roboto font installed in the simulator; physical-watch rendering remains unverified. Test views use bundled ASCII raster fonts. See the verification record for the local simulator runtime/font setup and remaining hardware checks.

## Project map and references

`source/`: publisher lifecycle, service, request/cache logic, matching, city resolver and watch UI. `resources/`: public complication, icons, native mobile settings/properties. `resources-venu441mm/`, `resources-venu445mm/`: device-sized icons and Venu control hints. `spike/`: TEST publisher. `tests/consumer/`: subscribing test face. `tests/integration/`: mocked transport/background probe. `tests/unit/`, `tests/fixtures/`: automated logic/request tests. `scripts/`: reproducible builds and fixture/catalog generation.

Official references: [Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html), [Background services](https://developer.garmin.com/connect-iq/articles/core-topics/Backgrounding.html), [WatchFace lifecycle](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html), [Communications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html), [publisher/consumer example discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/353286/sample-of-ciq-complication-publisher-and-consumer-of-those-complications), [alerts.in.ua API](https://devs.alerts.in.ua/).

Test font attribution and license: [docs/FONT-LICENSE.txt](docs/FONT-LICENSE.txt). No Garmin SDK, simulator executable, third-party watch face binary, private developer key or live API token is included.
