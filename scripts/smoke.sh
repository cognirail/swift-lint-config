#!/usr/bin/env bash
set -euo pipefail

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly project_root="$(cd "$script_dir/.." && pwd)"
readonly fixture_dir="$(mktemp -d)"
trap 'rm -rf "$fixture_dir"' EXIT

cd "$project_root"

"$script_dir/doctor.sh" strict
"$script_dir/lint-strict.sh"

mkdir -p "$fixture_dir/InlineDirective" "$fixture_dir/ForceUnwrap" "$fixture_dir/Naming" "$fixture_dir/NestedTernary"
printf '%s\n' '// swiftlint:disable force_unwrapping' 'let value: String? = nil' > "$fixture_dir/InlineDirective/Invalid.swift"
printf '%s\n' 'func unsafeValue(_ value: String?) -> String {' '    value!' '}' > "$fixture_dir/ForceUnwrap/Invalid.swift"
printf '%s\n' 'struct bad_type_name {' '    let BAD_VALUE: String' '}' > "$fixture_dir/Naming/Invalid.swift"
printf '%s\n' 'func phaseLabel(_ phase: String, _ isReady: Bool) -> String {' '    phase == "ready" ? (isReady ? "ready" : "waiting") : "editing"' '}' > "$fixture_dir/NestedTernary/Invalid.swift'

if "$script_dir/check-inline-directives.sh" "$fixture_dir/InlineDirective"; then
  echo "error: inline-directive guard accepted an invalid fixture" >&2
  exit 1
fi

if swiftlint lint --strict --no-cache --config "$project_root/.swiftlint.yml" "$fixture_dir/ForceUnwrap"; then
  echo "error: SwiftLint accepted a force unwrap" >&2
  exit 1
fi

if swiftlint lint --strict --no-cache --config "$project_root/.swiftlint.yml" "$fixture_dir/Naming"; then
  echo "error: SwiftLint accepted invalid Swift naming" >&2
  exit 1
fi

if swiftlint lint --strict --no-cache --config "$project_root/.swiftlint.yml" "$fixture_dir/NestedTernary"; then
  echo "error: SwiftLint accepted a nested ternary" >&2
  exit 1
fi

echo "smoke checks passed"
