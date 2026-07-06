#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DRY_RUN=0
REQUESTED_APPS="${PODMAN_APPS:-}"

APP_ORDER=(bentopdf n8n)

declare -A APP_LABELS=(
  [bentopdf]="BentoPDF - PDF tools web UI"
  [n8n]="n8n - workflow automation"
)

declare -A APP_COMPOSE_FILES=(
  [bentopdf]="$script_dir/bentopdf.yaml"
  [n8n]="$script_dir/n8n.yaml"
)

declare -A APP_URLS=(
  [bentopdf]="http://localhost:3250/"
  [n8n]="http://localhost:5678/"
)

usage() {
  cat <<'USAGE'
Usage: ./02-pod.sh [--dry-run] [--list] [--install APP[,APP...]]

Installs optional Podman applications from a predefined list.

Options:
  --dry-run                 Print podman commands without executing them.
  --list                    List available applications and URLs.
  --install APP[,APP...]    Install selected apps. Use "all" or "none" as shortcuts.

Environment:
  PODMAN_APPS=APP[,APP...]  Non-interactive app selection. Same values as --install.
USAGE
}

list_apps() {
  local app
  for app in "${APP_ORDER[@]}"; do
    printf '%-10s %s (%s)\n' "$app" "${APP_LABELS[$app]}" "${APP_URLS[$app]}"
  done
}

normalize_selection() {
  local raw="$1"
  raw="${raw// /}"
  raw="${raw,,}"
  echo "$raw"
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

app_exists() {
  local candidate="$1"
  local app
  for app in "${APP_ORDER[@]}"; do
    [[ "$candidate" == "$app" ]] && return 0
  done
  return 1
}

select_apps_interactively() {
  echo "Optional Podman applications:"
  local i app
  for i in "${!APP_ORDER[@]}"; do
    app="${APP_ORDER[$i]}"
    printf '  %d) %-10s %s (%s)\n' "$((i + 1))" "$app" "${APP_LABELS[$app]}" "${APP_URLS[$app]}"
  done
  echo "  a) all"
  echo "  n) none"
  echo
  read -rp "Choose apps to install [comma-separated numbers/names, default: none]: " selection
  selection="${selection:-none}"
  echo "$selection"
}

resolve_apps() {
  local selection
  selection=$(normalize_selection "$1")

  if [[ -z "$selection" || "$selection" == "none" || "$selection" == "n" ]]; then
    return 0
  fi

  if [[ "$selection" == "all" || "$selection" == "a" ]]; then
    printf '%s\n' "${APP_ORDER[@]}"
    return 0
  fi

  local item app index
  IFS=',' read -ra items <<< "$selection"
  for item in "${items[@]}"; do
    [[ -z "$item" ]] && continue
    if [[ "$item" =~ ^[0-9]+$ ]]; then
      index=$((item - 1))
      if (( index < 0 || index >= ${#APP_ORDER[@]} )); then
        echo "Unknown podman app: $item" >&2
        return 1
      fi
      app="${APP_ORDER[$index]}"
    else
      app="$item"
      if ! app_exists "$app"; then
        echo "Unknown podman app: $app" >&2
        return 1
      fi
    fi
    printf '%s\n' "$app"
  done | awk '!seen[$0]++'
}

install_app() {
  local app="$1"
  local compose_file="${APP_COMPOSE_FILES[$app]}"

  if [[ ! -f "$compose_file" ]]; then
    echo "Missing compose file for $app: $compose_file" >&2
    return 1
  fi

  echo "Installing $app with Podman Compose..."
  run_cmd podman compose --file "$compose_file" up -d
  echo "$app available at ${APP_URLS[$app]}"
}

main() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --list)
        list_apps
        return 0
        ;;
      --install)
        REQUESTED_APPS="${2:-}"
        if [[ -z "$REQUESTED_APPS" ]]; then
          usage >&2
          return 1
        fi
        shift 2
        ;;
      -h|--help)
        usage
        return 0
        ;;
      *)
        echo "Error: unknown argument: $1" >&2
        usage >&2
        return 1
        ;;
    esac
  done

  if [[ -z "$REQUESTED_APPS" ]]; then
    if [[ -t 0 ]]; then
      REQUESTED_APPS=$(select_apps_interactively)
    else
      REQUESTED_APPS="none"
    fi
  fi

  local resolved_apps
  resolved_apps=$(resolve_apps "$REQUESTED_APPS") || return $?

  mapfile -t selected_apps <<< "$resolved_apps"
  if [[ -z "$resolved_apps" || "${#selected_apps[@]}" -eq 0 ]]; then
    echo "No podman apps selected."
    return 0
  fi

  local app
  for app in "${selected_apps[@]}"; do
    install_app "$app"
  done
}

main "$@"
