#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CIQ_SDK:?Set CIQ_SDK to your Connect IQ SDK directory}"
: "${CIQ_KEY:?Set CIQ_KEY to your private developer key .der}"
mode=${1:-app}
device=${2:-epix2}
variant=${3:-production}
case "$variant" in
 beta|production) ;;
 *) echo 'Variant must be beta or production' >&2; exit 2 ;;
esac
case "$device" in
 epix2|epix2pro51mm|venu441mm|venu445mm) ;;
 *) echo 'Device must be epix2, epix2pro51mm, venu441mm, or venu445mm' >&2; exit 2 ;;
esac
args=()
case "$mode" in
 app) jungle=monkey.jungle; name=air-alert.prg ;;
 tests) jungle=tests.jungle; name=tests.prg; args+=(-t) ;;
 spike) jungle=spike/monkey.jungle; name=spike.prg ;;
 consumer) jungle=tests/consumer/monkey.jungle; name=consumer.prg ;;
 integration) jungle=tests/integration/monkey.jungle; name=integration.prg ;;
 package) jungle=monkey.jungle; name=air-alert.iq; args+=(-e -r) ;;
 *) echo 'Usage: scripts/build.sh [app|tests|spike|consumer|integration|package] [epix2|epix2pro51mm|venu441mm|venu445mm] [production|beta]' >&2; exit 2 ;;
esac
if [[ "$variant" == beta ]]; then
 if [[ "$mode" != app && "$mode" != package ]]; then
  echo 'Beta variant is available only for app and package builds' >&2; exit 2
 fi
 python3 scripts/beta_manifest.py
 jungle=beta.jungle
 name="${name/air-alert/air-alert-beta}"
fi
if [[ "$mode" != package ]]; then
 args+=(-d "$device")
 if [[ "$device" != epix2 ]]; then name="${name%.prg}-$device.prg"; fi
fi
build_dir="build/$mode/$device"
if [[ "$variant" == beta ]]; then build_dir="build/beta/$mode/$device"; fi
mkdir -p "$build_dir"
"$CIQ_SDK/bin/monkeyc" -f "$jungle" -o "$build_dir/$name" -y "$CIQ_KEY" -l 1 -w "${args[@]}"
mkdir -p artifacts
cp "$build_dir/$name" "artifacts/$name"
if [[ "$mode" == app || "$mode" == package ]]; then
 BUILD_VARIANT="$variant" python3 - <<'PY'
from pathlib import Path
import hashlib,os
root=Path('artifacts')
beta=os.environ['BUILD_VARIANT']=='beta'
base='air-alert-beta' if beta else 'air-alert'
files=[root/(base+suffix) for suffix in ['.prg','-epix2pro51mm.prg','-venu441mm.prg','-venu445mm.prg','.iq'] if (root/(base+suffix)).is_file()]
(root/('SHA256SUMS-beta' if beta else 'SHA256SUMS')).write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+p.name+'\n' for p in files))
PY
fi
echo "Published artifacts/$name"
