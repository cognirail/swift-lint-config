#!/usr/bin/env bash
set -euo pipefail

version_at_least() {
  local actual="$1"
  local minimum="$2"
  test "$(printf '%s\n%s\n' "$minimum" "$actual" | sort -V | head -n 1)" = "$minimum"
}

require_tool() {
  local command_name="$1"
  local minimum_version="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "error: $command_name is missing; run 'brew bundle'." >&2
    return 1
  fi

  local actual_version
  actual_version="$($command_name --version | grep -Eo '[0-9]+(\.[0-9]+){2}' | head -n 1)"
  if ! version_at_least "$actual_version" "$minimum_version"; then
    echo "error: $command_name $actual_version is older than required $minimum_version." >&2
    return 1
  fi

  printf '%-12s %s\n' "$command_name" "$actual_version"
}

require_tool swiftformat 0.62.1

mode="${1:-format}"
if test "$mode" != "format" && test "$mode" != "strict"; then
  echo "usage: $0 [format|strict]" >&2
  exit 2
fi

if test "$mode" = "format"; then
  printf '%-12s %s\n' "mode" "format (CLT-compatible)"
  exit 0
fi

require_tool swiftlint 0.65.0

developer_dir="$(xcode-select -p 2>/dev/null || true)"
if test -z "$developer_dir" || test "$developer_dir" = "/Library/Developer/CommandLineTools"; then
  echo "error: SwiftLint requires a complete Xcode toolchain; select Xcode with xcode-select." >&2
  exit 1
fi

if ! find "$developer_dir" -path '*sourcekitdInProc.framework' -print -quit | grep -q .; then
  echo "error: sourcekitdInProc.framework was not found under the selected Xcode toolchain." >&2
  exit 1
fi

printf '%-12s %s\n' "xcode" "$developer_dir"
