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

# OhMyBash install
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

#################################################
# Must be last
#################################################

# ssh key generation (if no key are present) to use for Git
user=$(whoami)
nb=$(ls -l /home/$user/.ssh/*.pub)

if nb -eq 0; then
  echo "No ssh public key found. Generating one"
  ssh-keygen -t ed25519 -C "pherriann@gmail.com"
  ssh-add /home/$user/.ssh/id_ed25519
  echo "Key generated"
  cat home/$user/.ssh/id_ed25519
  echo "Add it to you github account"
  echo "And run 'ssh -T git@github.com -y' to test the connection"
