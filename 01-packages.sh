#!/bin/bash

wdir=$(dirname $0)

if [[ -f $wdir/packages.lst ]]; then
  for i in $( cat $wdir/packages.lst); do
    sudo dnf install $i -y
  done  
else
  echo "File $wdir/packages.lst missing"
  return 1
fi

# pipx config
pipx ensurepath
sudo pipx ensurepath

# ansible install
pipx install --include-deps ansible

# ansible autocompletion in Bash
sudo pip3 install argcomplete
sudo activate-global-python-argcomplete
