# Air Alert UA

Ukrainian air-alert status on your Garmin watch, available as a **custom Connect IQ complication**. Monitor a city or region and display its status in any watch face that supports third-party complications. The app also has a simple status screen with the selected location, last successful check, manual Refresh and a hint directing you to phone settings.

Choose English or Ukrainian text, uppercase or lowercase, or Unicode status circles. Data comes from **UA Siren** (free, no token required) or **Ukraine Alarm**.

**Informational only. Continue using official air-alert notifications.** Updates depend on the phone connection, provider availability and Garmin background execution. This app does not provide emergency sounds or guaranteed real-time notifications.

## Supported watches

| Watch | Production PRG filename | Display |
|---|---|---|
| Epix (Gen 2) | `air-alert.prg` | 416×416 |
| Epix Pro (Gen 2), 51 mm | `air-alert-epix2pro51mm.prg` | 454×454 |
| Venu 4, 41 mm | `air-alert-venu441mm.prg` | 390×390 |
| Venu 4, 45 mm | `air-alert-venu445mm.prg` | 454×454 |

Get current builds from [GitHub Actions](https://github.com/akorchyn/air-complication/actions/workflows/build.yml). Choose a successful run at version **1.7.0 or newer** and download its application artifact; automatic builds use beta filenames. The [older production release](https://github.com/akorchyn/air-complication/releases/latest) predates the token-free default and Epix Pro support. The pinned device profiles require Epix firmware **23.16 or newer**, or Venu 4 firmware **17.33 or newer**. Update your watch first.

The original Epix Gen 2 and Epix Pro 51 mm are separate SDK targets. Connect IQ Store installation requires the exact model to be included in the uploaded IQ package; a PRG working when sideloaded does not establish store compatibility. Epix Pro 42 mm and 47 mm are not included.

Your watch face must support **external/custom Connect IQ complications**. Support for Garmin's built-in fields alone is not sufficient. Field selection, paid features and interaction with the complication depend on the watch face.

## Install and get started

1. Download the **PRG for your exact watch model**.
2. Connect the watch by USB. Using an MTP-capable file manager, copy the file to `GARMIN/APPS/air-alert.prg`, renaming it if necessary. Safely disconnect. The `.iq` package is not a USB installation file.
3. Open **Air Alert UA** from the watch's activity/app list. On a fresh installation, it attempts a check for **Kyiv city using UA Siren**, with no API token or settings changes required.
4. On your phone, open **Connect IQ → My Device → My Apps → Air Alert UA → Settings** (choose **Air Alert UA Beta** for beta). Choose your location and display preferences, then save. **UA Siren is the default and requires no token**. Provider selection and a token are needed only if you prefer Ukraine Alarm.
5. Use Refresh and check that a successful update time appears.
6. In your watch face's settings, assign a custom/external complication to a field and select **Air Alert UA**. Return to the face and check the displayed value.

Keep Garmin Connect connected to the watch and allowed to run on your phone. **All configuration lives in Connect IQ mobile settings**: provider, optional Ukraine Alarm key, location, display language/case/mode, refresh interval and stale threshold. The watch shows status, last update and Refresh; its settings hint directs you to the phone. Save phone changes and let them sync to the watch. Mobile settings availability for USB-sideloaded apps varies by Garmin tooling; a sideloaded installation may not expose the configuration page. These phone-only controls apply to version 1.6.0 and newer; older releases also have on-watch settings.

| Watch | Manual Refresh |
|---|---|
| Epix (Gen 2), or Epix Pro 51 mm | START, or tap with touch enabled |
| Venu 4, either size | Tap, or press the top-right button |

The Venu bottom-right button goes back. The status screen includes these control hints.

Development downloads from [GitHub Actions](https://github.com/akorchyn/air-complication/actions/workflows/build.yml) may contain **Air Alert UA Beta**. Its files have `air-alert-beta` names; rename your model's file to `air-alert-beta.prg` for USB installation and select **Air Alert UA Beta** in the complication picker. Beta and production have separate settings and caches and can coexist. Do not sideload the simulator fixtures: they are test applications.

## Choose a provider and location

| Provider | Required configuration |
|---|---|
| UA Siren (default) | None; free public [Ukraine Alarm wrapper](https://siren.pp.ua/) |
| Ukraine Alarm | Request a key at [api.ukrainealarm.com](https://api.ukrainealarm.com/) and enter **Ukraine Alarm API key** |

For Ukraine Alarm, enter the key itself, without `Bearer`. Switching provider retains this key but invalidates the old status; there is no automatic provider fallback. The key is stored in application properties and is never logged. Treat mobile settings and their synchronization as sensitive; Garmin controls whether its editor displays or masks key values.

**Upgrading to 1.7.0:** direct alerts.in.ua integration was removed because its nationwide detailed response can exceed Garmin's background memory. Existing alerts.in.ua selections automatically switch to UA Siren, and their cached status is discarded until a new valid check succeeds. Existing Ukraine Alarm selections/keys and UA Siren selections remain intact. The official location catalog is still used for verified UID mappings.

Location choices include all oblasts, Crimea, Kyiv, Sevastopol and major cities. The default is **Kyiv city, UID 31**; **Kyiv Oblast, UID 14**, is a different selection. For another supported city/community, choose **Custom location UID**, enter its official UID, and optionally a short label. Open the app after changing a custom UID so it can resolve the location. Changing location invalidates the previous location's cached status.

Mappings come from the [official location spreadsheet](https://docs.google.com/spreadsheets/d/1XnTOzcPHd1LZUrarR1Fk43FUyl8Ae6a6M7pcwDRjNdA/edit), linked by alerts.in.ua. The bundled catalog covers 1,471 cities/communities; some entries describe a territorial community containing a city.

| City | UID | Applicable whole-parent alerts |
|---|---:|---|
| Kyiv | 31 | Separate city |
| Kharkiv | 1293 | Declared separately |
| Lviv | 845 | Oblast 27; raion 90 |
| Odesa | 964 | Oblast 18; raion 104 |
| Dnipro | 332 | Oblast 9; raion 44 |
| Zaporizhzhia | 564 | Declared separately |

For a city, the app checks its own alerts and applicable whole-parent oblast/raion alerts. A sibling city's alert does not apply. Kyiv, Kharkiv, Zaporizhzhia and Sevastopol are treated as independently declared locations according to the official list.

For an oblast, the app also considers district/community alerts inside its verified scope, excluding independently declared cities. A warning therefore means an alert **somewhere in the selected region**, rather than every locality being affected. Missing ancestry or unsupported locations cannot produce CLEAR. Ukraine Alarm and UA Siren do not support every location in the official spreadsheet, including Sevastopol; unsupported selections display unavailable. [Mapping provenance](research/PROVENANCE.md) and [provider details](docs/API-ALTERNATIVES.md).

## Display options

| Meaning | English | Ukrainian | Status circles |
|---|---|---|---|
| Valid check found no applicable active air-raid alert | CLEAR | Немає | 🟢 |
| Yellow-level alert | YELLOW | Жовта | 🟡 |
| Red-level alert | RED | Червона | 🔴 |
| Unavailable, failed or unknown | N/A | н.д. | `?` |
| Last successful check is too old | STALE | Застар. | `!` |

Choose **Display mode**, **Text language** and **Text case** in Connect IQ mobile settings. Case choices are Default, UPPERCASE and lowercase. For a less prominent field, try Ukrainian + lowercase: `немає`, `жовта`, `червона`, `н.д.` and `застар.`. Presentation changes update the cached complication without fetching again.

**Your watch face controls font size, colors, placement, truncation and repainting.** Ukrainian needs Cyrillic glyphs; Unicode circles need the corresponding glyphs. Circles may be monochrome, blank or missing-glyph boxes. The publisher cannot force colored emoji or change the face's text/background colors. Use Text if circles are unreadable. The app's own status screen uses readable status words.

Only air-raid alerts are represented. Red takes priority over yellow. Missing/unknown severity, malformed relevant data or unsuccessful requests never establish CLEAR. Unrelated artillery, chemical, nuclear and urban-fighting alerts are outside this display's scope.

## Refresh and stale data

Background refresh intervals are **5, 10, 15, 30 or 60 minutes**, default **5 minutes**. Garmin enforces a minimum five-minute interval, and services may be delayed, suspended or terminated.

Opening Air Alert UA automatically attempts one refresh. Returning to the same status view during a launch does not repeat it. Manual Refresh requests another check, subject to the same safeguards: no overlapping request, at least one minute between refresh cycles, valid provider/location configuration, and failure backoff. Rapid reopening reuses the cache. Some faces can launch the associated app from the complication; that depends on the face.

While fetching, the app keeps the previous validated status and original successful-check time, alongside **Refreshing...**. A valid response updates both. Fetching does not extend freshness. Failed responses retain history in storage but display unavailable or stale; a retry cannot make an old failed value current without validation.

The default stale threshold is **10 minutes** after the last successful check. The next app/service execution publishes STALE when that threshold is reached. Opening the app makes its update time and error visible.

**Wrist-raise refresh is unsupported.** `WatchFace.onExitSleep()` belongs to the active watch face; it is not delivered to this separate Device App. The app uses Garmin's supported temporal background events, not a watch-face polling timer.

**Expiry on a watch face is not guaranteed.** Garmin's complication API has no expiry/TTL field. If the app and its service cannot run, an earlier published value—including CLEAR—can remain visible. Termination during fetching can also leave the previous value published until another execution evaluates its lease/staleness. The publisher cannot force the consuming face to repaint.

## Troubleshooting

Use **v1.5.1 or newer**: older versions can crash during a network callback, especially on a connection-error path.

- **No status on first launch:** the default UA Siren provider needs no token. Check your phone connection and the app's error, then Refresh when retry backoff permits. If you selected Ukraine Alarm, configure its key. Check your location is supported.
- **Status does not update:** open the app and note its error and **Updated** time. Keep the phone powered on, connected, and Garmin Connect permitted to run. If Updated advances but the face remains unchanged, check its selected complication and repaint behavior.
- **Phone/network unavailable or response error:** retries initially wait five minutes, increasing to 10, 20, 40 and 60 minutes after repeated failures. Opening/manual Refresh respects that backoff.
- **401 / 403:** check provider access, or the key if using Ukraine Alarm. These errors back off for 60 minutes; changing the token allows recovery, subject to the shared one-minute gate.
- **429: Rate limited:** wait at least 15 minutes; repeated failures increase the delay up to 60. UA Siren documents [50 requests/minute/IP](https://github.com/PaulAnnekov/uasiren#limitations). Other apps/devices sharing the same IP can count toward that limit.
- **Region updates work in the foreground but fail in the background:** whole-oblast monitoring needs the nationwide response. All supported watches allow only **64 KiB background memory**; decoded JSON can exceed it before the app can filter it. City requests from Ukraine Alarm/UA Siren generally use smaller regional responses, but their maximum size is not guaranteed either. [Measured limits](docs/VERIFICATION.md#background-memory).
- **App crash or IQ error:** connect by USB and look in `GARMIN/APPS/LOGS/` for `CIQ_LOG.YML` / `CIQ_LOG.YAML` and rotated `.BAK` files. These are Garmin crash reports. The app retains its latest error but has no request-history log; files under `docs/` are developer verification results.

For a bug report, include the app version, watch model/firmware, provider, selected location, error message and last successful update time. Report issues at [GitHub Issues](https://github.com/akorchyn/air-complication/issues). Do not include API tokens.

## Build locally

1. Install [Garmin's Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/), sign in, and install the SDK, your device definitions and simulator fonts. The project was built with **SDK 9.2.0 and Java 17**. The Monkey C VS Code extension is optional.
2. Create a personal developer key outside the repository, for example using VS Code's **Monkey C: Generate Developer Key** command.
3. Clone the project, set the SDK/key paths, and build your model:

   ```sh
   git clone https://github.com/akorchyn/air-complication.git
   cd air-complication
   export CIQ_SDK=/absolute/path/to/sdk
   export CIQ_KEY=/absolute/path/to/developer-key.der
   scripts/build.sh app                 # Epix Gen 2
   scripts/build.sh app epix2pro51mm    # Epix Pro (Gen 2), 51 mm
   scripts/build.sh app venu441mm       # Venu 4, 41 mm
   scripts/build.sh app venu445mm       # Venu 4, 45 mm
   ```

The production PRGs are written to the ignored `artifacts/` directory with the filenames in the download table. Intermediate files stay in `build/`. Install your model's PRG as described above. On Windows, run these scripts in a Bash-capable shell, or build with Garmin's Monkey C VS Code extension.

For a local beta build, add `beta` as the third argument, for example `scripts/build.sh app epix2 beta`. It uses a separate app identity and the **Air Alert UA Beta** label. Use `air-alert-beta.prg` when sideloading this variant. No live API tokens are required or embedded by the build.

## Simulator and tests

Start the official Garmin simulator through SDK Manager / VS Code or `"$CIQ_SDK/bin/connectiq"`. With the SDK/key environment variables above, run:

```sh
scripts/test.sh epix2
scripts/test.sh epix2pro51mm
scripts/test.sh venu441mm
scripts/test.sh venu445mm
```

All **98 Monkey C simulator tests pass on each of the four supported models**, covering token-free startup, upgrade migration, parsing, regional inheritance, provider/location changes, invalid data, network errors, retries, staleness, opening/manual refresh and callback compatibility. Fixtures do not depend on live alert events. GitHub CI compiles these tests; it does not execute the graphical simulator.

A separate publisher/consumer fixture verifies actual complication delivery in the simulator. See [verification results and remaining limits](docs/VERIFICATION.md). This does not establish immediate refresh or native font/emoji rendering in every third-party watch face. Authenticated live upstream requests and physical Venu verification remain incomplete.

Official references: [Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html), [Background services](https://developer.garmin.com/connect-iq/articles/core-topics/Backgrounding.html), [Communications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html), and [Ukraine Alarm API](https://api.ukrainealarm.com/). [Test-font license](docs/FONT-LICENSE.txt). [Changelog](CHANGELOG.md).
