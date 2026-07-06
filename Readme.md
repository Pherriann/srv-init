# Init-srv
version : 0.12
scope : Ubuntu/Debian + RHEL-compatible/Fedora

Set of scripts to get a new server setup with essential components installed and configuration applied

Full install:

add necessary repos if needed. Example for RHEL/EPEL:
```
 sudo subscription-manager repos --enable codeready-builder-for-rhel-10-$(arch)-rpms
 sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y
```

For minimal Ubuntu/Debian images, enable the standard repository components required by packages such as `podman`, `btop`, `gdu`, `bat`, and `fd-find` before running the installer. On Ubuntu this may include `universe`.

run script
```
./main-init.sh
```

Main-init details:
```
01-packages.sh  : install necessary packages from the OS-specific list:
                  - packages/redhat.lst for RHEL/Rocky/CentOS/Fedora-like systems
                  - packages/debian.lst for Ubuntu/Debian-like systems
                  install OhMyBash, Shai, Tailscale
                  Generate ssh key for Git and give info to configure access to your repo

02-pod.sh       : optional Podman app menu. Lets you install predefined compose apps:
                  - bentopdf, exposed at http://localhost:3250/
                  - n8n, exposed at http://localhost:5678/
                  Opens the selected app ports in firewalld or ufw when active, then verifies with ss that each app listens on the LAN-facing port.
                  Use PODMAN_APPS=bentopdf,n8n or ./02-pod.sh --install bentopdf,n8n for non-interactive installs.
```

## Supported distribution matrix

| Distribution | Versions covered by tests | Package list | Status | Notes |
| --- | --- | --- | --- | --- |
| Ubuntu LTS | 22.04, 24.04 | `packages/debian.lst` | Supported | Enable standard repositories; minimal installs may need `universe` for packages such as `podman`, `btop`, `gdu`, `bat`, and `fd-find`. |
| Debian stable | 12 bookworm | `packages/debian.lst` | Supported | `bat` and `fd-find` may expose `batcat` and `fdfind` binaries. |
| Rocky Linux | 9 | `packages/redhat.lst` | Supported | EPEL is enabled automatically before installing packages. |
| AlmaLinux | 9 | `packages/redhat.lst` | Supported | EPEL is enabled automatically before installing packages. |
| Fedora Server | 42 | `packages/redhat.lst` | Supported | Good modern RPM target; faster-moving than enterprise RHEL-compatible distributions. |
| CentOS Stream | 9 | `packages/redhat.lst` | Supported | Close to RHEL, but rolling ahead of RHEL; treat as useful for dev/validation. |
| RHEL official | 9/10 compatible family | `packages/redhat.lst` | Experimental | May require subscription-manager repositories such as CodeReady Builder before EPEL/packages are available. |

Current automated fixtures validate OS-family routing for Ubuntu 22.04/24.04, Debian 12, Rocky 9, AlmaLinux 9, Fedora 42, and CentOS Stream 9.

Package-list notes:
- `packages/redhat.lst` preserves the original RedHat package set and adds script prerequisites such as `curl`, `ca-certificates`, `iproute`, and `openssh-clients`.
- `packages/debian.lst` uses Ubuntu/Debian package names, including `openssh-client`, `python3-venv`, and `iproute2`; it excludes `fastfetch` and `ansible-core` by default because Ansible is installed via `pipx` later in the script.
- `bat` and `fd-find` packages may expose `batcat` and `fdfind` binaries on Debian/Ubuntu.
