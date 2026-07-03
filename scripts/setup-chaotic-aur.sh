#!/usr/bin/env bash
# setup-chaotic-aur.sh — Add Chaotic-AUR repo for pre-built AUR binaries

set -euo pipefail

echo "→ Setting up Chaotic-AUR..."

if grep -q "chaotic-aur" /etc/pacman.conf; then
    echo "  Chaotic-AUR already configured, skipping."
    exit 0
fi

# Import key and install keyring/mirrorlist
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Append repo to pacman.conf
sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

sudo pacman -Sy
echo "  ✓ Chaotic-AUR configured."
