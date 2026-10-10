#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CIQ_SDK:?Set CIQ_SDK to your Connect IQ SDK directory}"
: "${CIQ_KEY:?Set CIQ_KEY to your private developer key .der}"
mode=${1:-app}
args=()
case "$mode" in
 app) jungle=monkey.jungle; name=air-alert.prg ;;
 tests) jungle=tests.jungle; name=tests.prg; args+=(-t) ;;
 spike) jungle=spike/monkey.jungle; name=spike.prg ;;
 consumer) jungle=tests/consumer/monkey.jungle; name=consumer.prg ;;
 integration) jungle=tests/integration/monkey.jungle; name=integration.prg ;;
 package) jungle=monkey.jungle; name=air-alert.iq; args+=(-e -r) ;;
 *) echo 'Usage: scripts/build.sh [app|tests|spike|consumer|integration|package]' >&2; exit 2 ;;
esac
mkdir -p "build/$mode"
if [[ "$mode" != package ]]; then args+=(-d epix2); fi
"$CIQ_SDK/bin/monkeyc" -f "$jungle" -o "build/$mode/$name" -y "$CIQ_KEY" -l 1 -w "${args[@]}"
mkdir -p artifacts
cp "build/$mode/$name" "artifacts/$name"
if [[ "$mode" == app || "$mode" == package ]]; then
 python3 - <<'PY'
from pathlib import Path
import hashlib
root=Path('artifacts')
files=[root/name for name in ['air-alert.prg','air-alert.iq'] if (root/name).is_file()]
(root/'SHA256SUMS').write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+p.name+'\n' for p in files))
PY
fi
echo "Published artifacts/$name"
