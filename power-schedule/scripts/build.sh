#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CIQ_SDK:?Set CIQ_SDK}" "${CIQ_KEY:?Set CIQ_KEY}"
mode=${1:-app}; device=${2:-epix2}; variant=${3:-beta}
case "$device" in epix2|epix2pro51mm|venu441mm|venu445mm) ;; *) exit 2 ;; esac
case "$variant" in beta|production) ;; *) exit 2 ;; esac
args=(); jungle=monkey.jungle; name=power-schedule
case "$mode" in
 app) args+=(-d "$device") ;;
 package) args+=(-e -r) ;;
 tests) jungle=tests.jungle; name=power-tests; args+=(-d "$device" -t) ;;
 consumer|integration) jungle="tests/$mode/monkey.jungle"; name="power-$mode"; args+=(-d "$device") ;;
 *) echo 'Usage: build.sh [app|package|tests|consumer|integration] MODEL [beta|production]' >&2; exit 2 ;;
esac
mkdir -p build artifacts
if [[ "$variant" == beta && ( "$mode" == app || "$mode" == package ) ]]; then
 python3 - <<'PY'
import xml.etree.ElementTree as E
E.register_namespace('iq','http://www.garmin.com/xml/connectiq')
t=E.parse('manifest.xml')
t.getroot().find('{http://www.garmin.com/xml/connectiq}application').set('id','e24634ca677142f19bd0bb4bb684b675')
t.write('build/beta-manifest.xml',encoding='unicode',xml_declaration=True)
PY
 jungle=beta.jungle; name+=-beta
fi
if [[ "$mode" != package && "$device" != epix2 ]]; then name+="-$device"; fi
if [[ "$mode" == package ]]; then name+=.iq; else name+=.prg; fi
mkdir -p "build/$mode/$device/$variant"
"$CIQ_SDK/bin/monkeyc" -f "$jungle" -o "build/$mode/$device/$variant/$name" -y "$CIQ_KEY" -l 1 -w "${args[@]}"
cp "build/$mode/$device/$variant/$name" "artifacts/$name"
echo "Built artifacts/$name"
