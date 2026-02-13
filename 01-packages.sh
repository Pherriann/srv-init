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
echo "   OhMyBash"
curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh

# SHai install
echo "   Shai"
curl -fsSL https://raw.githubusercontent.com/ovh/shai/main/install.sh | sh

# Tailscale install
curl -fsSL https://tailscale.com/install.sh | sh
echo "   Log in to start using Tailscale by running: sudo tailscale up" 

#################################################
# Must be last
#################################################

# ssh key generation (if no key are present) to use for Git
echo "   Key management for Git"
user=$(whoami)

if [ ! -d "home/$user/.ssh" ]; then
  mkdir /home/$user/.ssh
fi
echo "Generating ssh key for github"
ssh-keygen -t ed25519 -C "pherriann@gmail.com"
ssh-add /home/$user/.ssh/id_ed25519
echo "Key generated"
cat /home/$user/.ssh/id_ed25519.pub
echo "Add it to you github account"
echo "Run 'ssh -T git@github.com -y' to test the connection"
echo "Change URL of depot from https to git"
echo "  git remote -v"
echo "  git remote set-url origin git@github.com:utilisateur/depot.git"
