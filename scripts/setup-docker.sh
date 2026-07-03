#!/usr/bin/env bash
# setup-docker.sh — Configure Docker for rootless use & custom storage

set -euo pipefail

USER="${USER:-$(whoami)}"

# Gum UI setup
check_cmd() { command -v "$1" &>/dev/null; }
gum_spin() {
    local title="$1"; shift
    if check_cmd gum; then
        gum spin --spinner dot --title=" $title" --title.foreground="212" -- "$@"
    else
        echo "  → $title"
        "$@"
    fi
}
success() { echo -e "\033[32m  ✓\033[0m $*"; }

echo ""
if check_cmd gum; then
    gum style --foreground="212" --border=rounded --margin="0 1" --padding="0 2" "🐳 Configuring Docker"
else
    echo "→ Configuring Docker..."
fi

# 1. Setup custom docker storage in home directory
DOCKER_DATA_ROOT="/home/$USER/.local/share/docker"
DOCKER_CONF_DIR="/etc/docker"
DOCKER_CONF_FILE="$DOCKER_CONF_DIR/daemon.json"

gum_spin "Creating Docker home storage directory..." mkdir -p "$DOCKER_DATA_ROOT"

gum_spin "Setting up Docker daemon.json..." sudo bash -c "
mkdir -p \"$DOCKER_CONF_DIR\"
cat > \"$DOCKER_CONF_FILE\" <<EOF
{
  \"data-root\": \"$DOCKER_DATA_ROOT\"
}
EOF
"
success "Docker storage set to: $DOCKER_DATA_ROOT"

# 2. Enable and start services
gum_spin "Enabling Docker services..." sudo systemctl enable --now docker containerd
success "Docker & Containerd services running."

# 3. Add user to group
if ! groups "$USER" | grep -q docker; then
    gum_spin "Adding user to docker group..." sudo usermod -aG docker "$USER"
    success "Added $USER to docker group (re-login required)"
else
    success "$USER already in docker group"
fi

echo ""
