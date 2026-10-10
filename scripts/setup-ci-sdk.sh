#!/usr/bin/env bash
# Linux CLI build setup. No simulator, fonts, API token or Garmin login needed.
set -euo pipefail
ciq_install_root=${1:?Usage: scripts/setup-ci-sdk.sh /absolute/install/directory}
mkdir -p "$ciq_install_root/downloads" "$ciq_install_root/sdk" "$HOME/.Garmin/ConnectIQ/Devices"

sdk_archive="$ciq_install_root/downloads/sdk.zip"
devices_archive="$ciq_install_root/downloads/devices.tar.gz"
sdk_url=https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-9.2.0-2026-06-09-92a1605b2.zip
devices_url=https://raw.githubusercontent.com/blackshadev/garmin-connectiq-tools/cd073d7fc4083edf75eb3e1068d7ee4087c19423/devices.tar.gz

download_verified() {
 local url=$1 destination=$2 expected=$3
 if [[ ! -f "$destination" ]]; then
  curl --fail --location --retry 3 --max-time 180 "$url" --output "$destination"
 fi
 printf '%s  %s\n' "$expected" "$destination" | sha256sum --check --status
}

download_verified "$sdk_url" "$sdk_archive" 4907d8455b651c5a00a865e364cc4f1921c055b9279c7c8634c7a7a6773b5593
download_verified "$devices_url" "$devices_archive" 329ebb68bf55a07d86cda993a1381b20f7fc786eba059737abbf1d72778d2feb
unzip -q -o "$sdk_archive" -d "$ciq_install_root/sdk"
# Extract only supported device definitions; the service catalog remains external.
tar -xzf "$devices_archive" -C "$HOME/.Garmin/ConnectIQ/Devices" ./epix2 ./venu441mm ./venu445mm
chmod +x "$ciq_install_root/sdk/bin/monkeyc"
echo "SDK 9.2.0 and pinned Epix Gen 2 / Venu 4 definitions installed in $ciq_install_root/sdk"
