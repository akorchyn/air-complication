# Verification — 29 October 2026

The project is an independent Device App. Air Alert UA's application IDs, source, settings and existing workflow are unchanged. The only root README edit links to this separate project.

## Automated checks

- **34 adapter tests passed** with Node's test runner. They cover all four provider status categories, unknown states/types, strict slot validation, gaps, scope isolation, UTC conversion from Kyiv wall-clock time, winter/summer and both DST transitions, minute 1440, response bounds, optional access-key authentication, error handling and cache timestamp preservation. Tests are synthetic and never depend on current outages.
- **23 Garmin Run No Evil tests passed on each** of Epix Gen 2, Epix Pro Gen 2 51 mm, Venu 4 41 mm and Venu 4 45 mm. Logs are the four `unit-tests*.log` files here. Tests cover scheduled ON/OFF, exact boundaries, midnight continuity, unknown horizons, WAIT/EMERG, gaps, explicit NoOutages, malformed/wrong-scope responses, clock rollback, staleness, interruption, callbacks with two arguments, HTTP/transport errors, backoff, overlap, provider/group changes, refresh-on-open and read-only glance rendering.
- Production and beta PRGs compiled for all four models with Connect IQ SDK 9.2.0. Both IQ packages were extracted and inspected: version 1.0.0, distinct permanent app IDs, eight device-part entries, three public complication definitions and six mobile settings. Default group is 19.1, profile Kyiv/DTEK, URL empty. Both manifest signatures and all binary SHA-256 checksums verified.
- Worker bundling passed `wrangler deploy --dry-run`; **no Worker was deployed**. New Actions workflow passes actionlint. Generated watch fixtures are deterministic projections of the same synthetic upstream fixture used by the adapter.

## Actual publisher-to-consumer delivery

On the Epix Pro 51 mm simulator, the separate fixture publisher used production `PowerRequest`, its two-argument callback adapter, `PowerCache`, `PowerLogic`, `PowerService` scheduling and public complication publication. Only network transport and drawing were replaced. Opening fetched a synthetic scheduled OFF result; the independently subscribing watch face received `OFF 10:00`. An injected temporal event used the maximum 128-slot projected shape and delivered `ON` to that consumer.

See [consumer log](integration-consumer.log), [publisher log](integration-publisher.log) and [consumer screenshot](integration-consumer.png). Background instrumentation reported **36,176 B used / 25,080 B free** after response allocation and **47,608 B used / 13,648 B free** after publication and scheduling. The simulator reserves overhead from the nominal 65,536 B service budget. These are observations at instrumented points, not a guarantee of peak heap use or of physical phone JSON-transfer buffers. The fixture intentionally retains 128 rows to exercise the bound, even when a real adapter would merge equal adjacent rows.

The fixed test script expects a fresh simulator session with the fixture first in the Background Events app list. If other apps are present, select **Power Schedule Fixture** manually; selecting a different test app is not a failed publisher refresh.

## Live contract check

The reference repository was read at `88f33db22cdddf4336937f4e15817792672c3d0f`. Its public regions endpoint returned Kyiv/902 and Dnipro/301,303. The current Kyiv planned-outages response had **60 groups / 43,062 wire bytes**; the implemented normalizer parsed group **19.1** and projected two days into **557 bytes**. Only response sizes and catalog metadata are recorded here. Live outage bodies are not committed and were not used as assertions or safety conclusions.

## UI and environment limits

See [native glance](venu445mm-glance.png) and [setup screen](venu445mm-setup.png). Native Venu 4 45 mm glance and setup-screen rendering were inspected in the official simulator with a local Roboto font. Selecting the glance opened the full app; round-screen text fitting and device-specific hints were checked. Default fonts only were visually checked; physical firmware and accessibility scaling need confirmation. The RNE tests also invoke the real glance renderer with a recording canvas, verifying that changed cached errors become N/A without network activity.

The clean Linux workspace needed locally extracted legacy GTK/WebKit libraries to run Garmin's simulator. A FreeType symbol collision with the host graphics stack was isolated in the local simulator executable. This changes only local GUI library visibility; the SDK compiler, VM and application APIs were not replaced. No modified simulator, SDK, font or private signing key is distributed. Epix native fonts remain visually unverified; the independent consumer fixture uses the repository's licensed ASCII test font.

Still to verify: a deployed HTTPS adapter through physical Garmin Connect transport, actual watch installation, firmware-delayed background delivery, the physical swipe-list entry and repainting/truncation in third-party watch faces. There is no hosted adapter URL or automatic Garmin store submission. Configure a deployed adapter to use real schedules; without it the app correctly remains SETUP.

The app never measures electricity and does not deliver emergency shutdown notifications. Garmin execution delays and the lack of complication TTL can leave a cached value visible. See README for the resulting limits.
