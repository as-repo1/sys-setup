#!/usr/bin/env bash
# =============================================================================
#  lib/deps.sh — dependency bootstrapping
#  Sourced by install.sh. Provides:
#    bootstrap_gum      install gum (via distro repo) before any UI renders
#    ensure_core_deps   install curl/git/sudo/etc. that the rest relies on
#
#  Design (per plan §3): gum is installed FIRST, before any TUI is shown.
#  The raw-ANSI helpers in lib/theme.sh + lib/log.sh keep preflight messages
#  legible even before gum exists.
# =============================================================================

# bootstrap_gum — make `gum` available. Idempotent.
bootstrap_gum() {
    check_cmd gum && return 0

    echo -e "${YELLOW}  Installing gum (TUI dependency)…${RESET}"
    case "$OS" in
        arch)
            sudo pacman -Sy --noconfirm gum >> "$LOG_FILE" 2>&1 \
                || yay -S --noconfirm gum >> "$LOG_FILE" 2>&1 \
                || { warn "gum unavailable — install manually: https://github.com/charmbracelet/gum"; return 1; }
            ;;
        ubuntu)
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key \
                | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg >> "$LOG_FILE" 2>&1
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
                | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
            sudo apt-get update >> "$LOG_FILE" 2>&1 \
                && sudo apt-get install -y gum >> "$LOG_FILE" 2>&1 \
                || { warn "gum unavailable — install manually"; return 1; }
            ;;
        fedora)
            sudo tee /etc/yum.repos.d/charm.repo > /dev/null <<'EOF'
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
EOF
            sudo dnf install -y gum >> "$LOG_FILE" 2>&1 \
                || { warn "gum unavailable — install manually"; return 1; }
            ;;
    esac
}

# ensure_core_deps — install the handful of tools the installer itself needs.
# Run after bootstrap_gum so we can show spinners.
ensure_core_deps() {
    local -a needed=()
    check_cmd curl   || needed+=(curl)
    check_cmd git    || needed+=(git)
    check_cmd jq     || needed+=(jq)
    check_cmd stow   || needed+=(stow)

    if [[ ${#needed[@]} -gt 0 ]]; then
        gum_spin "Installing core helpers: ${needed[*]}…" \
            pkg_install "${needed[@]}"
    fi
}
