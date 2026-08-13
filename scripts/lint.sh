#!/usr/bin/env bash
set -euo pipefail

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly project_root="$(cd "$script_dir/.." && pwd)"

cd "$project_root"
"$script_dir/doctor.sh" format
"$script_dir/check-inline-directives.sh" "$project_root"
swiftformat --lint --config "$project_root/.swiftformat" "$project_root"
