#!/usr/bin/env bash

# Detect the supported OS family from an os-release file.
# Outputs one of:
#   UBUNTU  for Debian/Ubuntu-like systems
#   RHEL    for RHEL/Fedora-like systems
#   UNKNOWN and returns non-zero for unsupported systems
#
# Usage: detect_os_type [os-release-file]
detect_os_type() {
  local os_release_file="${1:-${OS_RELEASE_FILE:-/etc/os-release}}"
  local ID=""
  local ID_LIKE=""

  if [[ ! -f "$os_release_file" ]]; then
    echo "UNKNOWN"
    return 1
  fi

  # shellcheck source=/dev/null
  source "$os_release_file"

  local id_lc="${ID,,}"
  local id_like_lc=" ${ID_LIKE,,} "

  case "$id_lc" in
    ubuntu|debian)
      echo "UBUNTU"
      return 0
      ;;
    rhel|rocky|almalinux|centos|fedora)
      echo "RHEL"
      return 0
      ;;
  esac

  if [[ "$id_like_lc" == *" debian "* ]]; then
    echo "UBUNTU"
    return 0
  fi

  if [[ "$id_like_lc" == *" rhel "* || "$id_like_lc" == *" fedora "* || "$id_like_lc" == *" centos "* ]]; then
    echo "RHEL"
    return 0
  fi

  echo "UNKNOWN"
  return 1
}
