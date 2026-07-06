#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=lib/os.sh
source "$script_dir/lib/os.sh"

DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: ./01-packages.sh [--dry-run] [--print-packages UBUNTU|RHEL]

Installs the OS-specific package list for the detected OS family.
Use OS_TYPE=UBUNTU|RHEL to bypass detection, or OS_RELEASE_FILE=/path/to/os-release for tests.
USAGE
}

package_list_for_os() {
  case "$1" in
    UBUNTU) echo "$script_dir/packages/debian.lst" ;;
    RHEL) echo "$script_dir/packages/redhat.lst" ;;
    *)
      echo "Error: unsupported OS type: $1" >&2
      return 1
      ;;
  esac
}

print_packages_for_os() {
  local os_type="$1"
  local package_file

  package_file=$(package_list_for_os "$os_type") || return 1
  if [[ ! -f "$package_file" ]]; then
    echo "Error: package list missing: $package_file" >&2
    return 1
  fi

  grep -Ev '^\s*(#|$)' "$package_file"
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

run_privileged() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd "$@"
    return 0
  fi

  sudo "$@"
}

install_system_packages() {
  local os_type="$1"
  local packages=()

  mapfile -t packages < <(print_packages_for_os "$os_type")
  if [[ "${#packages[@]}" -eq 0 ]]; then
    echo "Error: no packages configured for $os_type" >&2
    return 1
  fi

  case "$os_type" in
    UBUNTU)
      run_privileged apt-get update
      run_privileged apt-get install -y "${packages[@]}"
      ;;
    RHEL)
      run_privileged dnf install -y epel-release
      run_privileged dnf makecache
      run_privileged dnf install -y "${packages[@]}"
      ;;
    *)
      echo "Error: unsupported OS type: $os_type" >&2
      return 1
      ;;
  esac
}

install_post_packages() {
  run_cmd pipx ensurepath
  run_privileged pipx ensurepath || echo "Warning: sudo pipx ensurepath ignored." >&2
  run_cmd pipx install --include-deps ansible

  echo "   Key management for Git"
  local current_user github_email ssh_dir
  current_user=$(whoami)
  ssh_dir="/home/$current_user/.ssh"
  run_cmd mkdir -p "$ssh_dir"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd ssh-keygen -t ed25519 -C "user@example.com"
    run_cmd ssh-add "$ssh_dir/id_ed25519"
  else
    read -rp 'Enter GitHub email: ' github_email
    ssh-keygen -t ed25519 -C "$github_email"
    ssh-add "$ssh_dir/id_ed25519" || echo "Warning: Failed to add SSH key." >&2
    cat "$ssh_dir/id_ed25519.pub"
  fi

  echo "Add it to your GitHub account."
  echo "Run 'ssh -T git@github.com -y' to test the connection."

  echo "   OhMyBash"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh
  else
    curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | bash || echo "Warning: Failed to install OhMyBash." >&2
  fi

  echo "   Shai"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd curl -fsSL https://raw.githubusercontent.com/ovh/shai/main/install.sh
  else
    curl -fsSL https://raw.githubusercontent.com/ovh/shai/main/install.sh | sh || echo "Warning: Failed to install SHai." >&2
  fi

  echo "   Tailscale"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd curl -fsSL https://tailscale.com/install.sh
  else
    curl -fsSL https://tailscale.com/install.sh | sh
  fi
  echo "   Log in to start using Tailscale by running: sudo tailscale up"
}

main() {
  local print_packages_os=""
  local os_type="${OS_TYPE:-}"

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --print-packages)
        print_packages_os="${2:-}"
        if [[ -z "$print_packages_os" ]]; then
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

  if [[ -n "$print_packages_os" ]]; then
    print_packages_for_os "$print_packages_os"
    return $?
  fi

  if [[ -z "$os_type" ]]; then
    os_type=$(detect_os_type "${OS_RELEASE_FILE:-/etc/os-release}") || {
      echo "Error: unsupported OS in ${OS_RELEASE_FILE:-/etc/os-release}" >&2
      return 1
    }
  fi

  install_system_packages "$os_type"
  install_post_packages
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
