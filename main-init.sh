#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=lib/os.sh
source "$script_dir/lib/os.sh"

os_type=$(detect_os_type "${OS_RELEASE_FILE:-/etc/os-release}") || {
  echo "Error: unsupported OS in ${OS_RELEASE_FILE:-/etc/os-release}" >&2
  exit 1
}

start_t=$(date +%H:%M:%S)
echo "Starting server init at $start_t"
echo "OS type: $os_type"

OS_TYPE="$os_type" "$script_dir/01-packages.sh"

date_output=$(date +%H:%M:%S)
echo "End of server init at $date_output ..."
