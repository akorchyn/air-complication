# Alternative air-alert APIs

Researched **10 October 2026** for this Garmin publisher. Version **1.1.0 integrates alerts.in.ua, Ukraine Alarm and UA Siren** as selectable providers. Public documentation and unauthenticated endpoints were checked, and a real UA Siren request succeeded through Garmin's simulator transport. No Ukraine Alarm or alerts.in.ua key was available, so authenticated live responses remain unverified. Other services below are research findings only.

## Comparison

| Provider | Access | Yellow/red information | City coverage and Garmin suitability |
|---|---|---|---|
| [Ukraine Alarm / Stfalcon](https://api.ukrainealarm.com/) | Request a separate API key through the provider's form | Current official schema includes `activeAlertLevels[].alertLevel`, enum `Red` / `Yellow` | `/api/v3/alerts/{regionId}` avoids fetching the nationwide body. `/api/v3/regions` supplies the hierarchy. Strongest direct alternative. |
| [UA Siren](https://siren.pp.ua/) | Public wrapper; no key required for tested endpoints | Wraps Ukraine Alarm; Home Assistant documents separate red/yellow sensors | Same regional API and hierarchy; tested Kyiv response was **152 bytes**. Best candidate when avoiding another key application. Adds an independent intermediary. |
| [Vadym Klymenko / єМапа](https://vadimklimenko.com/map/) | Tested public JSON required no key | Current version 10 JSON includes `alert_level`; observed values included `red`, `yellow` and null | Nationwide `statuses.json` was **22,815 bytes** on the wire, with name-keyed oblast/district structures. Decoded memory, fine city/community coverage and a regional-only contract remain unverified. |
| [Tryvoha.online](https://tryvoha.online/api) | Public, no key | Documents `level`, but defines yellow as drone threat and red as missile threat or regular raid | Small `/api/v1/alerts/{slug}` responses; directory covers oblasts, districts and Kyiv. Classification is not verified equivalent to official severity. No general city/community coverage documented. |
| [Ubilling](https://wiki.ubilling.net.ua/doku.php?id=aerialalertsapi) | Public, no key | Normalized endpoint exposes `alertnow` boolean, not severity | Small response (**4,125 bytes** in sample), primarily oblast-level. Cannot satisfy current severity/city requirements. Raw-source mode does not establish a compact city-level severity contract. |

Wire sizes are individual observations, not payload bounds or decoded Monkey C memory measurements. No live status from these samples is used as a test fixture or safety conclusion.

## Recommended choices

**Direct provider: Ukraine Alarm.** Its current [official OpenAPI schema](https://api.ukrainealarm.com/swagger/v3/swagger.json) describes:

```text
GET https://api.ukrainealarm.com/api/v3/alerts/{regionId}
GET https://api.ukrainealarm.com/api/v3/regions

AlertRegionModel.activeAlerts[]:
  type = AIR | ARTILLERY | URBAN_FIGHTS | CHEMICAL | NUCLEAR | ...
  activeAlertLevels[].alertLevel = Red | Yellow
  activeAlertLevels[].reason
  activeAlertLevels[].createdAt
```

Authentication is an API key in the `Authorization` header according to the schema. The adapter sends the raw Ukraine Alarm key, with a separate property from the alerts.in.ua Bearer token. Missing severity remains UNKNOWN; an active AIR alert alone does not establish a red level. Authenticated request limits and maximum regional payload sizes still need provider confirmation.

**Public wrapper: UA Siren.** The site's [wrapper library](https://github.com/PaulAnnekov/uasiren) states a limit of **200 requests per five minutes per IP**. [Home Assistant's documentation](https://www.home-assistant.io/integrations/ukraine_alarm/) explicitly identifies this wrapper and documents simultaneous red and yellow levels. These requests succeeded without credentials:

```text
GET https://siren.pp.ua/api/v3/regions
GET https://siren.pp.ua/api/v3/alerts/31
```

The wrapper's directory independently confirmed all six mappings:

| City | Region ID | Provider hierarchy |
|---|---:|---|
| Kyiv city | 31 | Separate top-level region |
| Kharkiv | 1293 | Separate top-level region |
| Zaporizhzhia | 564 | Separate top-level region |
| Lviv | 845 | Oblast 27 → district 90 → community 845 |
| Odesa | 964 | Oblast 18 → district 104 → community 964 |
| Dnipro | 332 | Oblast 9 → district 44 → community 332 |

A single-city response is promising for Epix's 64 KiB background budget, but the 152-byte no-alert example does not prove the maximum fits. The implemented adapter verifies the selected city and each applicable whole-parent region sequentially before publishing CLEAR. Separate cities need only their exact region. An empty response array is invalid; a valid regional record with empty `activeAlerts` can be combined only after every required check succeeds. Mocked tests cover mixed levels, missing/unknown values, sibling exclusion, failed parent requests and Crimea's provider alias (canonical UID 29 → provider ID 9999). Sevastopol (30) is absent from this directory and is unavailable with these two adapters.

Live regional checks found oblast responses that contained no whole-oblast alert while the nationwide response contained active district alerts inside that oblast. Therefore **whole-oblast monitoring requests `/api/v3/alerts`**, filters the verified descendant scope and excludes separately declared cities. A small empty oblast response cannot prove that the entire region is clear. This nationwide request retains the background-memory risk of the original provider.

The Garmin five-minute temporal-event limit and complication expiry limitations remain regardless of provider. Home Assistant's faster polling cannot be copied into a Garmin service.

## Other findings

- [Vadym's public response](https://vadimklimenko.com/map/statuses.json) now contains severity fields. Older binary-only descriptions do not describe the sampled version 10. Some state records use a `type:` key; a provider-specific parser and validation would be needed.
- Tryvoha documents **120 requests/minute/IP**, a **30–60-second cache**, attribution requirements and no availability guarantee. Its threat semantics and regional precision differ from this project's requirements.
- Ubilling documents a **three-second cache** and **two requests/second/host**. Its default source can vary; normalized boolean output loses severity.
- alerts.in.ua's compact IoT routes discard the required severity. A small proxy preserving detailed real levels remains an option when staying with the original provider.
- The old alerts.com.ua root/API pages returned 404 in this check; no current supported production endpoint was established. This does not establish that every legacy deployment is unavailable.

The shipped providers retain separate settings, tokens and provider-specific parsing, with fail-closed cached status and shared rate limiting. Vadym Klymenko, Tryvoha and Ubilling are not integrated because their location/level contracts do not yet meet the same verified behavior.
