# Official location data

Retrieved 2026-10-10 from the full location list linked in https://devs.alerts.in.ua/:

https://docs.google.com/spreadsheets/d/1XnTOzcPHd1LZUrarR1Fk43FUyl8Ae6a6M7pcwDRjNdA/edit

CSV export used:

https://docs.google.com/spreadsheets/d/1XnTOzcPHd1LZUrarR1Fk43FUyl8Ae6a6M7pcwDRjNdA/export?format=csv

`locations.csv` retains the original hierarchy and notes. The generator uses its official UIDs and region classifications, cross-checked against `regions-ukrainealarm.json`, to produce `source/LocationCatalog.mc`, `source/LocationPresets.mc`, mobile location strings and settings. There are 32 presets and 1,471 custom community/special-city UIDs.

CSV SHA-256: `a5bf1d312ee7258b16caaaf6c06e3df56fca68b0c14a060ec7c5ee7ce40b9620`.

UIDs 564 and 1293 carry the official note that city alerts are declared separately from oblast/raion alerts. UIDs 30 and 31 are special-status cities. Those four entries deliberately have no inherited parent alerts in the application. Other communities inherit whole-region alerts from their containing oblast and raion. This does not imply that a sibling city's alert covers the entire region.

## Provider directory and aliases

The Ukraine Alarm directory snapshot was retrieved without authentication from `https://siren.pp.ua/api/v3/regions` on 2026-10-10. This is UA Siren's public wrapper around the [official Ukraine Alarm API](https://api.ukrainealarm.com/swagger/v3/swagger.json). Only directory metadata is retained; no active live alerts are fixtures. The snapshot independently confirms the shared community IDs and explicit State → District → Community hierarchy.

The official CSV inserts the standalone Crimea row (UID 29) between Volyn (8) and Volyn's districts. A naive row-order hierarchy assigns those districts to Crimea. The generator handles that isolated row and uses the provider's explicit ancestry for shared IDs. The Volyn regression test checks community UID 255 → oblast 8.

The providers use ID 9999 for Crimea, whereas the official alerts.in.ua CSV uses 29. The adapter translates that alias while settings and cached scope retain canonical UID 29. Sevastopol UID 30 and some CSV communities are absent from the Ukraine Alarm directory; those selections remain unavailable with Ukraine Alarm/UA Siren instead of being guessed or treated as clear. The directory's test region 0 is not a selectable location.

Oblast scope contains the region and its districts/communities, excluding Kyiv, Sevastopol, Kharkiv and Zaporizhzhia's independent scopes. It reports any applicable alert in that scope, not uniform conditions throughout the oblast. A compact known-UID bitmap lets background parsing distinguish known outside locations from unknown IDs without loading the full directory.

Garmin SDK 9.2.0 and the API reference were obtained from the official Garmin SDK/documentation sources. Epix device definitions used for local verification came from the public cache at https://github.com/blackshadev/garmin-connectiq-tools , commit `cd073d7fc4083edf75eb3e1068d7ee4087c19423`, because direct device/font downloads required an authenticated Garmin session. Users should install current official definitions and fonts with SDK Manager.

No downloaded SDK, private key, authenticated API response, or third-party watch face executable is part of this project.
