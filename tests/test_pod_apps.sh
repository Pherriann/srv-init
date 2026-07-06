#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  grep -Fq -- "$needle" <<< "$haystack" || fail "$label: missing '$needle'"
}

list_output=$("$repo_root/02-pod.sh" --list)
assert_contains "$list_output" "bentopdf" "app list"
assert_contains "$list_output" "n8n" "app list"
assert_contains "$list_output" "http://localhost:3250/" "bentopdf URL"
assert_contains "$list_output" "http://localhost:5678/" "n8n URL"

selected_output=$("$repo_root/02-pod.sh" --dry-run --install bentopdf,n8n)
assert_contains "$selected_output" "podman compose --file $repo_root/bentopdf.yaml up -d" "bentopdf dry-run"
assert_contains "$selected_output" "podman compose --file $repo_root/n8n.yaml up -d" "n8n dry-run"

single_output=$(PODMAN_APPS=n8n "$repo_root/02-pod.sh" --dry-run)
assert_contains "$single_output" "podman compose --file $repo_root/n8n.yaml up -d" "env selected n8n dry-run"
if grep -Fq "bentopdf.yaml" <<< "$single_output"; then
  fail "env selected n8n should not install bentopdf"
fi

none_output=$("$repo_root/02-pod.sh" --dry-run --install none)
assert_contains "$none_output" "No podman apps selected." "none selection"

if "$repo_root/02-pod.sh" --dry-run --install unknown >/tmp/srv-init-unknown-pod.out 2>&1; then
  fail "unknown app should fail"
fi
assert_contains "$(cat /tmp/srv-init-unknown-pod.out)" "Unknown podman app: unknown" "unknown app error"

compose_output=$(cat "$repo_root/n8n.yaml")
assert_contains "$compose_output" "image: docker.n8n.io/n8nio/n8n:latest" "n8n compose image"
assert_contains "$compose_output" '"5678:5678"' "n8n compose port"
assert_contains "$compose_output" "n8n_data:" "n8n persistent volume"

echo "ok - podman app menu, selection, and compose definitions"
