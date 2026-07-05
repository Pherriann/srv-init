#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fixtures="$repo_root/tests/fixtures"
unknown_os_output=$(mktemp)
trap 'rm -f "$unknown_os_output"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  local actual="$1"
  local expected="$2"
  local label="$3"
  [[ "$actual" == "$expected" ]] || fail "$label: expected '$expected', got '$actual'"
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  grep -qx -- "$needle" <<< "$haystack" || fail "$label: missing '$needle'"
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  if grep -qx -- "$needle" <<< "$haystack"; then
    fail "$label: unexpected '$needle'"
  fi
}

source "$repo_root/lib/os.sh"

assert_eq "$(detect_os_type "$fixtures/os-release.ubuntu")" "UBUNTU" "ubuntu fixture detection"
assert_eq "$(detect_os_type "$fixtures/os-release.debian")" "UBUNTU" "debian fixture detection"
assert_eq "$(detect_os_type "$fixtures/os-release.rhel")" "RHEL" "rhel-like fixture detection"
if detect_os_type "$fixtures/os-release.unknown" >"$unknown_os_output" 2>/dev/null; then
  fail "unknown fixture should not be supported"
fi
assert_eq "$(cat "$unknown_os_output")" "UNKNOWN" "unknown fixture output"

ubuntu_packages=$("$repo_root/01-packages.sh" --print-packages UBUNTU)
rhel_packages=$("$repo_root/01-packages.sh" --print-packages RHEL)

assert_contains "$ubuntu_packages" "openssh-client" "ubuntu packages"
assert_contains "$ubuntu_packages" "python3-venv" "ubuntu packages"
assert_contains "$ubuntu_packages" "curl" "ubuntu packages"
assert_contains "$ubuntu_packages" "ca-certificates" "ubuntu packages"
assert_not_contains "$ubuntu_packages" "openssh-clients" "ubuntu packages"
assert_not_contains "$ubuntu_packages" "fastfetch" "ubuntu packages"
assert_not_contains "$ubuntu_packages" "ansible-core" "ubuntu packages"

assert_contains "$rhel_packages" "openssh-clients" "rhel packages"
assert_contains "$rhel_packages" "ansible-core" "rhel packages"
assert_contains "$rhel_packages" "fastfetch" "rhel packages"
assert_not_contains "$rhel_packages" "python3-venv" "rhel packages"

[[ "$ubuntu_packages" != "$rhel_packages" ]] || fail "Ubuntu and RHEL package lists must be distinct"

ubuntu_dry_run=$(OS_RELEASE_FILE="$fixtures/os-release.ubuntu" "$repo_root/01-packages.sh" --dry-run)
grep -q "apt-get update" <<< "$ubuntu_dry_run" || fail "ubuntu dry-run should update apt"
grep -q "apt-get install -y" <<< "$ubuntu_dry_run" || fail "ubuntu dry-run should install with apt"
! grep -q "dnf install" <<< "$ubuntu_dry_run" || fail "ubuntu dry-run must not call dnf"
! grep -q '^+ sudo' <<< "$ubuntu_dry_run" || fail "dry-run should not execute sudo"

rhel_dry_run=$(OS_RELEASE_FILE="$fixtures/os-release.rhel" "$repo_root/01-packages.sh" --dry-run)
grep -q "dnf install -y" <<< "$rhel_dry_run" || fail "rhel dry-run should install with dnf"
! grep -q "apt-get" <<< "$rhel_dry_run" || fail "rhel dry-run must not call apt-get"

echo "ok - OS detection, package lists, and dry-run behavior"
