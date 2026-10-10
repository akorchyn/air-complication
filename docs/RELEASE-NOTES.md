Standalone Epix Gen 2 Device App publishing a public air-alert complication for compatible watch faces, including Tronic.

Download **air-alert.prg** below and copy it to the watch's `GARMIN/APPS` directory. The IQ package is intended for Garmin distribution tooling; it is not the USB sideload file.

- Select **alerts.in.ua**, **Ukraine Alarm**, or **UA Siren** in application settings. The first two use separate personal tokens; UA Siren requires no token.
- Choose from all 24 oblasts, Crimea, Kyiv, Kharkiv, Zaporizhzhia, Sevastopol, Lviv, Odesa and Dnipro, or enter a supported custom community UID.
- Oblast status includes applicable district/community alerts and excludes independently declared cities. It means an alert somewhere in the selected alert region, not a claim that every locality shares that alert.
- Refresh every 5–60 minutes using supported background events, or press START in the app for manual Refresh. Failures and unsupported locations display N/A; expired checks display STALE when execution occurs.
- Binaries are published as release assets, not stored in the source tree. Tag builds compile production and simulator targets and verify asset checksums before publishing.

Informational only: continue using official air-alert notifications. Garmin cannot guarantee service delivery or complication expiry while the app is suspended, and watch-face colors are controlled by the consumer. Whole-oblast monitoring uses nationwide responses, which can exceed background memory during widespread alerts. UA Siren adds a third-party intermediary. Authenticated Ukraine Alarm/alerts.in.ua requests and physical Tronic integration were not verified here; mocked response tests and simulator consumer propagation are documented in the repository.

CI uses a temporary signing key unless the repository's `CIQ_SIGNING_KEY_BASE64` secret is configured. Configure a stable developer key for consistent release signing. No live API token is included.
