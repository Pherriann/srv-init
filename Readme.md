# Init-srv
version : 0.12
scope : RHEL + Ubuntu/Debian

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

02-pod.sh       : install various pod
```

Package-list notes:
- `packages/redhat.lst` preserves the original RedHat package set and adds script prerequisites such as `curl`, `ca-certificates`, and `openssh-clients`.
- `packages/debian.lst` uses Ubuntu/Debian package names, including `openssh-client` and `python3-venv`; it excludes `fastfetch` and `ansible-core` by default because Ansible is installed via `pipx` later in the script.
- `bat` and `fd-find` packages may expose `batcat` and `fdfind` binaries on Debian/Ubuntu.
