#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
device=${1:-epix2};suffix=
if [[ "$device" != epix2 ]]; then suffix="-$device"; fi
scripts/build.sh tests "$device"
mkdir -p docs
"$CIQ_SDK/bin/monkeydo" "artifacts/power-tests$suffix.prg" "$device" -t > "docs/unit-tests$suffix.log" 2>&1 || true
python3 - "docs/unit-tests$suffix.log" <<'PY'
import re,sys
from pathlib import Path
text=Path(sys.argv[1]).read_text()
summary=re.search(r'PASSED \(passed=\d+, failed=0, errors=0\)',text)
if not summary:
 print(text);raise SystemExit('Simulator tests did not pass')
print(summary.group(0))
PY
