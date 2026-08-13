#!/usr/bin/env bash
set -euo pipefail

readonly project_root="${1:-.}"

found_directive=0
while IFS= read -r -d '' swift_file; do
  if grep -nE '(swiftlint|swiftformat):[[:space:]]*(disable|enable|options)' "$swift_file"; then
    found_directive=1
  fi
done < <(
  find "$project_root" \
    \( -type d \( \
      -name .build -o \
      -name .swiftpm -o \
      -name DerivedData -o \
      -name Packages -o \
      -name Pods -o \
      -name Carthage -o \
      -name Generated \
    \) -prune \) -o \
    \( -type f -name '*.swift' -print0 \)
)

if test "$found_directive" -eq 1; then
  echo "error: inline SwiftLint/SwiftFormat directives are forbidden; change the project-level config instead." >&2
  exit 1
fi
