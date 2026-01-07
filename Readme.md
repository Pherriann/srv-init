# Init-srv
version : 0.1

Set of scripts to get a new server setup with essential components installed and configuration applied

Full install:

add necessary repos if needed (example below is for EPEL/rhel10)
```
 sudo subscription-manager repos --enable codeready-builder-for-rhel-10-$(arch)-rpms
 sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y
```
run script
```./main-init.sh
```

Main-init details:
```
01-packages.sh  : install necessary packages (from RH default repository) like ansible, ...
02-
```
