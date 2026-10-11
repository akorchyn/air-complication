**Adds Connect IQ Store compatibility for Epix Pro (Gen 2), 51 mm.** The original Epix Gen 2 and the Pro 51 mm are separate Garmin SDK targets. An older PRG could work when sideloaded while the store still rejected installation because the Pro model was missing from the exported package.

- Added the `epix2pro51mm` target to production, beta and simulator fixtures.
- CI exports the Pro 51 mm binary inside both IQ variants and supplies a separate model-specific PRG with checksums.
- The four supported targets are original Epix Gen 2, Epix Pro 51 mm, and Venu 4 in 41 mm and 45 mm sizes. Other Epix Pro sizes are not included.

For USB installation on Epix Pro 51 mm, choose `air-alert-beta-epix2pro51mm.prg` for beta or `air-alert-epix2pro51mm.prg` for production. Rename it to `air-alert-beta.prg` or `air-alert.prg` respectively, then copy it to `GARMIN/APPS/` and safely disconnect. The `.iq` package is not a USB installation file.

All configuration remains in Connect IQ mobile settings. English/Ukrainian text, letter-case choices, Status circles and all three API providers remain available. Beta and production keep separate settings and caches.

Designed for occasional status checks. Continue using official air-alert notifications for timely warnings. Background delivery, freshness on a consuming watch face, Cyrillic/emoji rendering and colors depend on Garmin execution and the watch face. Physical installation of the new store package still needs confirmation.
