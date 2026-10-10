#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/generate_tests.py
device=${1:-epix2}
scripts/build.sh tests "$device"
name=tests.prg
log=docs/unit-tests.log
if [[ "$device" != epix2 ]]; then name="tests-$device.prg"; log="docs/unit-tests-$device.log"; fi
mkdir -p docs
# Some SDK versions return 1 even after all Run No Evil tests pass.
# Verify the test summary as well as retaining the full simulator output.
"$CIQ_SDK/bin/monkeydo" "artifacts/$name" "$device" -t > "$log" 2>&1 || true
cat "$log"
python3 - "$log" <<'PY'
from pathlib import Path
import re,sys
text=Path(sys.argv[1]).read_text()
if not re.search(r'PASSED \(passed=\d+, failed=0, errors=0\)',text):raise SystemExit('SDK tests did not pass')
PY
