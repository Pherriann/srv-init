#!/bin/bash

wdir=$(dirname "$0")
os_type="UNKNOWN"

# Load OS type from parent script
source $wdir/../main-init.sh || { echo "Error: Failed to load os_type from main-init.sh" >&2; exit 1; }

# Check if packages.lst exists
if [[ ! -f "$wdir/packages.lst" ]]; then
echo "Error: $wdir/packages.lst missing" >&2
return 1
fi

# Install packages based on OS type
case "$os_type" in
    "UBUNTU")
        # Ubuntu/Debian package manager (apt)
        for pkg in $(cat "$wdir/packages.lst"); do
            if ! sudo apt-get update && sudo apt-get install -y "$pkg"; then
echo "Error: Failed to install $pkg on Ubuntu" >&2
return 1
fi
done
    ;;
    
    "RHEL")
        # RHEL/CentOS package manager (dnf)
        for pkg in $(cat "$wdir/packages.lst"); do
            if ! sudo dnf install -y "$pkg"; then
echo "Error: Failed to install $pkg on RHEL" >&2
return 1
fi
done
    ;;
    
    *)
        echo "Warning: Unsupported OS type: $os_type. Using dnf as fallback." >&2
        for pkg in $(cat "$wdir/packages.lst"); do
            if ! sudo dnf install -y "$pkg"; then
echo "Error: Failed to install $pkg (fallback failed)" >&2
return 1
fi
done
    ;;
esac

# Pipx/Python setup with error checks
if ! pipx ensurepath; then
echo "Error: pipx ensurepath failed" >&2
exit 1
fi
sudo pipx ensurepath || { echo "Warning: sudo pipx ensurepath ignored." >&2; }

# Ansible install
pipx install --include-deps ansible || { echo "Error: Failed to install ansible via pipx." >&2; exit 1; }

# SSH Key Setup (with user input)
echo "   Key management for Git"
user=$(whoami)
mkdir -p "/home/$user/.ssh"
if ! ssh-keygen -t ed25519 -C "$(read -rp 'Enter GitHub email: ') "; then
echo "Error: SSH key generation failed." >&2
exit 1
fi
ssh-add "/home/$user/.ssh/id_ed25519" || { echo "Warning: Failed to add SSH key." >&2; }
cat "/home/$user/.ssh/id_ed25519.pub"
echo "Add it to your GitHub account."
echo "Run 'ssh -T git@github.com -y' to test the connection."

# OhMyBash install
echo "   OhMyBash"
curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | bash || { echo "Warning: Failed to install OhMyBash." >&2; }

# SHai install
echo "   Shai"
curl -fsSL https://raw.githubusercontent.com/ovh/shai/main/install.sh | sh || { echo "Warning: Failed to install SHai." >&2; }

# Tailscale install
echo "   Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh
echo "   Log in to start using Tailscale by running: sudo tailscale up"
