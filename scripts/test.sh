#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/generate_tests.py
scripts/build.sh tests
mkdir -p docs
# Some SDK versions return 1 even after all Run No Evil tests pass.
# Verify the test summary as well as retaining the full simulator output.
"$CIQ_SDK/bin/monkeydo" build/tests/tests.prg epix2 -t > docs/unit-tests.log 2>&1 || true
cat docs/unit-tests.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('docs/unit-tests.log').read_text()
if not re.search(r'PASSED \(passed=\d+, failed=0, errors=0\)',text):raise SystemExit('SDK tests did not pass')
PY
