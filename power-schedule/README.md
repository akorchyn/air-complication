# Power Schedule UA

A separate Garmin Device App for Ukrainian planned electricity outages, with public watch-face complications and a glance in the watch's swipe/widget list. **Air Alert UA keeps its existing name, app IDs and behavior.** Both apps can be installed together.

The YASNO API contract and Kyiv-time interpretation follow [ha-yasno-outages](https://github.com/denysdovhan/ha-yasno-outages), pinned to commit `88f33db22cdddf4336937f4e15817792672c3d0f`. This is a Monkey C implementation, with a small HTTPS adapter for Garmin's memory limits; Home Assistant is not required.

**These are schedules, not measurements of your home's electricity.** Emergency shutdowns, repairs and last-minute changes can override them. Confirm important plans with your electricity provider.

## Setup

1. Obtain the HTTPS base URL of a running [schedule adapter](adapter/README.md). You can deploy the included Cloudflare Worker once and share it between your watches. No YASNO token or home address is needed.
2. Install the PRG for your exact model, or the app through a Garmin listing when one is available. The supported models are Epix Gen 2, Epix Pro Gen 2 51 mm, and Venu 4 in 41/45 mm sizes.
3. In **Connect IQ → My Device → My Apps → Power Schedule UA → Settings**, enter the adapter base URL, such as `https://your-adapter.workers.dev`. Enter its optional access key if the owner enabled one.
4. Choose **region/provider** and enter your **outage group**. The initial values are **Kyiv city / DTEK / 19.1**; check these against your own provider before using the result. Group IDs are strings, such as `19.1` or `2.2`.
5. Open the app and check that the last-check time advances. START/tap refreshes; UP/DOWN or vertical swipes browse all available today/tomorrow schedule pages. Times on schedule pages are **Kyiv time**, even when travelling.
6. Add the app through your watch's **Add/Edit Glances** menu for the swipe-list preview. Menu wording varies by firmware. Selecting its glance opens the full app.
7. In a watch face supporting **third-party Connect IQ complications**, select any of the fields below. The face controls fonts, colors, truncation, interaction and repainting.

Settings are on the phone, including provider, group, adapter URL/key, check interval and stale threshold. USB sideloads may not expose mobile settings reliably; use Garmin-installed apps for normal configuration.

The adapter is required; there is no embedded public server or guessed default endpoint. Until configured, the app shows **SETUP**. The adapter's key, if enabled, is its own access key, not a DTEK/YASNO account password.

## Fields and status

| Complication | Example | Meaning |
|---|---|---|
| Power Schedule UA | `OFF 20:00` | Outage scheduled now, with confirmed scheduled restoration at 20:00 |
| Power Schedule UA | `ON 21:00` | No outage scheduled now; next confirmed scheduled outage starts at 21:00 |
| Next outage UA | `21:00`, `T 08:00`, `NOW` | Next confirmed outage, or one already scheduled at this moment |
| Next restoration UA | `20:00`, `T 10:00` | Confirmed non-outage slot following the current/next outage |

`T` means tomorrow relative to the current Kyiv schedule day. `--` means no corresponding confirmed transition in the loaded horizon; it does not promise an outage-free future. Touching outage slots are merged, including across midnight. Restoration is shown only when a confirmed non-outage slot follows; a gap or an unknown tomorrow cannot establish a restoration time.

| Value | Meaning |
|---|---|
| ON / OFF | **Scheduled** state only; not measured supply |
| WAIT | Provider is waiting for a confirmed schedule |
| EMERG | Emergency shutdowns; normal timetable cannot establish current supply |
| N/A | Missing, malformed, unsupported or failed data, or no slot covering now |
| STALE | Last validated upstream check is too old |
| SETUP | Adapter URL/group needs configuration |

The app displays both the **provider's schedule update time** and time since our last successful check. They are different timestamps. Unconfirmed slots are not treated as confirmed outages or as proof of power. Weekly probable schedules and address lookup are deliberately outside this first release; today/tomorrow planned schedules drive the status.

## Coverage

YASNO's live region directory, checked 29 October 2026, exposes these pairs:

| Region / provider | YASNO IDs |
|---|---|
| Kyiv city / DTEK Kyiv Electric Networks | region 25, DSO 902 |
| Dnipro / DnEM | region 3, DSO 301 |
| Dnipro / CEK | region 3, DSO 303 |

These are YASNO IDs, not the air-alert location IDs. Kyiv Oblast and other DTEK territories are not silently mapped to Kyiv city. A missing group produces unavailable status. The phone settings accept a group string instead of assuming only groups 1–6; Kyiv currently has groups through 60.1. `/v1/groups?region=25&dso=902` on the adapter lists current groups.

## Refresh and memory limits

The default API check interval is **15 minutes**, matching the reference integration. Choices: 5, 10, 15, 30 and 60 minutes. Opening the full app attempts one refresh; browsing a glance reads the cache without requesting data. Manual refresh shares a persisted one-minute request gate and failure backoff. Settings changes discard the old scope's status and reject old replies.

Background temporal events publish scheduled transitions from cached UTC intervals as well as fetching when due. Garmin enforces a **five-minute minimum** and may delay or suppress execution, so transitions are not exact-time notifications. There is no wrist-raise callback from another watch face. A foreground-only display timer updates the visible app without making extra requests.

Stale defaults to **30 minutes** from the adapter's successful upstream check, not merely when the watch downloaded a cached body. Errors retain history but show N/A/STALE. A pending request preserves a previously validated value without extending its freshness. Retries use 5–60 minute exponential backoff; 429 starts at 15 minutes, 401/403 at 60 minutes.

Garmin provides no complication expiry/TTL. If the service cannot run, an old published value may remain visible. The glance can also be cached by Garmin. Check the full app's timestamps when the information matters.

The current Kyiv API response contains 60 groups and was about **43 KB** on the wire; JSON decoding can exceed these watches' **64 KiB background budget**. The adapter fetches/caches upstream data, projects only the chosen group, normalizes Kyiv DST to UTC intervals and caps its output at **8 KiB**. The live group 19.1 sample projected to **557 bytes**. These are observations, not maximum source sizes; fixture tests enforce the adapter's output/slot bounds. No nationwide/full-provider JSON is sent to the watch.

## Local builds and simulator

Install Garmin's [Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/), SDK 9.2.0, device definitions, simulator fonts and Java 17+. Create a local developer key outside the repository. From this directory:

```sh
export CIQ_SDK=/path/to/sdk
export CIQ_KEY=/path/to/developer-key.der
scripts/build.sh app epix2pro51mm beta
scripts/build.sh app venu445mm beta
scripts/build.sh package epix2 beta
```

Beta is the default and has a separate identity/name. Other models: `epix2`, `venu441mm`. Production is the third argument `production`. PRGs and IQs are under ignored `artifacts/`. Rename your model's PRG to `power-schedule-beta.prg` (or `power-schedule.prg` for production), copy it to `GARMIN/APPS/` over USB, and safely disconnect. IQ packages are for Garmin distribution tooling, not USB installation.

The dedicated **Build Power Schedule UA** Actions workflow produces beta artifacts by default and offers production through manual dispatch once the workflow is on the default branch. It does not upload to Garmin or deploy the adapter. Air Alert UA's workflow is unchanged.

With the official simulator running:

```sh
node --test adapter/test/worker.test.mjs
node scripts/generate-fixtures.mjs
scripts/test.sh epix2pro51mm
scripts/build.sh consumer epix2pro51mm
scripts/build.sh integration epix2pro51mm
# Optional Linux UI automation (requires python-xlib):
python3 scripts/verify-simulator.py
```

Fixtures are synthetic, not live outage events. See [verification](docs/VERIFICATION.md) and [adapter setup](adapter/README.md). The simulator publisher/consumer binaries are test-only and must not be sideloaded for real use.
