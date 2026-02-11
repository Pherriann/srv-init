# Init-srv
version : 0.11
scope : RHEL

Set of scripts to get a new server setup with essential components installed and configuration applied

Full install:

add necessary repos if needed (example below is for EPEL)
```
 sudo subscription-manager repos --enable codeready-builder-for-rhel-10-$(arch)-rpms
 sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y
```

run script
```
./main-init.sh
```

Main-init details:
```
01-packages.sh  : install necessary packages, see packages.lst for complete list of rpm installed...
                  install OhMyBash, Shai, Tailscale
                  Generate ssh key for Git and give info to configure access to your repo

02-pod.sh       : install various pod
```
