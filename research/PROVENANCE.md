# Official location data

Retrieved 2026-10-10 from the full location list linked in https://devs.alerts.in.ua/:

https://docs.google.com/spreadsheets/d/1XnTOzcPHd1LZUrarR1Fk43FUyl8Ae6a6M7pcwDRjNdA/edit

CSV export used:

https://docs.google.com/spreadsheets/d/1XnTOzcPHd1LZUrarR1Fk43FUyl8Ae6a6M7pcwDRjNdA/export?format=csv

`locations.csv` retains the original hierarchy and notes. `source/LocationCatalog.mc` is generated from that CSV. `location-mapping.json` is an inspectable expanded hierarchy captured during research; the CSV is the generator's source of truth.

CSV SHA-256: `a5bf1d312ee7258b16caaaf6c06e3df56fca68b0c14a060ec7c5ee7ce40b9620`.

UIDs 564 and 1293 carry the official note that city alerts are declared separately from oblast/raion alerts. UIDs 30 and 31 are special-status cities. Those four entries deliberately have no inherited parent alerts in the application. Other communities inherit whole-region alerts from their containing oblast and raion. This does not imply that a sibling city's alert covers the entire region.

Garmin SDK 9.2.0 and the API reference were obtained from the official Garmin SDK/documentation sources. Epix device definitions used for local verification came from the public cache at https://github.com/blackshadev/garmin-connectiq-tools , commit `cd073d7fc4083edf75eb3e1068d7ee4087c19423`, because direct device/font downloads required an authenticated Garmin session. Users should install current official definitions and fonts with SDK Manager.

No downloaded SDK, private key, authenticated API response, or Tronic executable is part of this project.
