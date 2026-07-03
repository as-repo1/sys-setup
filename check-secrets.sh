#!/usr/bin/env bash
# =============================================================================
#  check-secrets.sh — Scan dotfiles for exposed secrets (API keys, passwords)
#  Run this before committing to ensure you don't leak sensitive data.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$SCRIPT_DIR/dots"

# ─── Helpers ─────────────────────────────────────────────────────────────────
check_cmd() { command -v "$1" &>/dev/null; }

bootstrap_gum() {
    if ! check_cmd gum; then
        echo "Installing dependency: gum..."
        sudo pacman -Sy --noconfirm gum || yay -S --noconfirm gum || return 1
    fi
}

gum_header() {
    echo ""
    gum style \
        --foreground="51" --border-foreground="201" \
        --border=rounded --align=center \
        --width=52 --margin="0 2" --padding="0 2" \
        "$1"
    echo ""
}

gum_spin() {
    local title="$1"; shift
    gum spin --spinner dot --title=" $title" --title.foreground="51" -- "$@"
}

success() { echo -e "\033[32m  ✓\033[0m $*"; }
warn()    { echo -e "\033[33m  ⚠\033[0m $*"; }
error()   { echo -e "\033[31m  ✗\033[0m $*"; }

# ─── Banner ──────────────────────────────────────────────────────────────────
clear
bootstrap_gum

echo ""
gum style \
    --foreground="51" --border-foreground="201" \
    --border=double --align=center \
    --width=52 --margin="1 2" --padding="1 2" \
    "  Secrets Checker  ·  sys-setup  " \
    "" \
    "Scans dots/ for passwords and API keys"
echo ""

# ─── Dependencies ────────────────────────────────────────────────────────────
if ! check_cmd gitleaks; then
    warn "gitleaks is not installed. It is recommended for secret scanning."
    if gum confirm "Install gitleaks now?"; then
        gum_spin "Installing gitleaks..." sudo pacman -S --noconfirm gitleaks || yay -S --noconfirm gitleaks
    else
        warn "Proceeding with basic grep scan only. This is NOT comprehensive!"
        BASIC_SCAN=true
    fi
fi

# ─── Scan ────────────────────────────────────────────────────────────────────
gum_header "Scanning for Secrets..."

cd "$SCRIPT_DIR"

if check_cmd gitleaks; then
    # gitleaks requires a git repo, which sys-setup is. 
    # We want to scan the dots directory specifically.
    # --no-git scans the directory files rather than git history, useful for uncommitted files.
    echo "Running gitleaks on dots/ directory..."
    if gitleaks detect --no-git --source="$DOTS_DIR" --verbose; then
        success "No secrets detected by gitleaks in dots/!"
    else
        error "Gitleaks found potential secrets. Please review them before committing!"
        exit 1
    fi
else
    # Basic fallback scan
    echo "Running basic regex grep on dots/ directory..."
    # Looking for common patterns: token=..., password=..., api_key=...
    # Exclude binary files
    if grep -rniE "(api[_-]?key|password|secret|token|auth)\s*[:=]\s*['\"]?[a-zA-Z0-9_\-]{8,}['\"]?" "$DOTS_DIR" | grep -v 'gitleaks'; then
        error "Found potential secrets (basic scan). Please review the lines above!"
        exit 1
    else
        success "No obvious secrets detected by basic scan."
    fi
fi

echo ""
gum style \
    --foreground="46" --border-foreground="46" \
    --border=rounded --align=center \
    --width=52 --margin="1 2" --padding="1 2" \
    "✓  Configurations look safe to commit!"
echo ""

# Ask to add to pre-commit hook
HOOK_FILE="$SCRIPT_DIR/.git/hooks/pre-commit"
if [[ ! -f "$HOOK_FILE" ]]; then
    if gum confirm "Would you like to run this check automatically before every commit (git hook)?"; then
        mkdir -p "$(dirname "$HOOK_FILE")"
        cat << 'EOF' > "$HOOK_FILE"
#!/usr/bin/env bash
echo "Running secrets check before commit..."
bash check-secrets.sh
if [ $? -ne 0 ]; then
    echo "Commit aborted due to potential secrets. Use git commit --no-verify to bypass."
    exit 1
fi
EOF
        chmod +x "$HOOK_FILE"
        success "Pre-commit hook installed!"
    fi
fi
