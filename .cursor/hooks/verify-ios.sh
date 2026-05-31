#!/usr/bin/env bash
# After Swift edits under Sudoku/ or SudokuTests/, run xcodebuild and report failures to the agent.
set -euo pipefail

input=$(cat)
root="$(cd "$(dirname "$0")/../.." && pwd)"

path=$(printf '%s' "$input" | python3 -c '
import json, sys
data = json.load(sys.stdin)
for key in ("file_path", "path", "filePath", "edited_file"):
    v = data.get(key)
    if isinstance(v, str) and v:
        print(v)
        break
else:
    tool_input = data.get("tool_input") or data.get("input") or {}
    if isinstance(tool_input, dict):
        for key in ("file_path", "path", "filePath"):
            v = tool_input.get(key)
            if isinstance(v, str) and v:
                print(v)
                break
')

if [[ -z "${path:-}" ]] || [[ "$path" != *.swift ]]; then
  printf '%s\n' '{}'
  exit 0
fi

if [[ "$path" != *Sudoku/* && "$path" != *SudokuTests/* ]]; then
  printf '%s\n' '{}'
  exit 0
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  printf '%s\n' '{"additional_context":"verify-ios: xcodebuild not found; skip iOS build check."}'
  exit 0
fi

cd "$root"
log=$(mktemp)
trap 'rm -f "$log"' EXIT

set +e
xcodebuild -scheme Sudoku -destination 'generic/platform=iOS Simulator' build >"$log" 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  printf '%s\n' '{"additional_context":"verify-ios: xcodebuild build succeeded for scheme Sudoku."}'
  exit 0
fi

tail -n 40 "$log" | python3 -c '
import json, sys
log = sys.stdin.read().strip()
msg = "verify-ios: xcodebuild build FAILED. Fix compiler errors before continuing.\n\n" + log
print(json.dumps({"additional_context": msg}))
'

exit 0
