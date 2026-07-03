#!/usr/bin/env bash
# =============================================================================
#  update-dots.sh — Fetch live dotfiles from the repo and apply to ~/.config
#  Run this whenever you want to update your system from the repository.
#
#  Usage:
#    cd ~/coding/sys-setup && bash update-dots.sh
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
        --foreground="46" --border-foreground="46" \
        --border=rounded --align=center \
        --width=52 --margin="0 2" --padding="0 2" \
        "$1"
    echo ""
}

gum_spin() {
    local title="$1"; shift
    gum spin --spinner dot --title=" $title" --title.foreground="46" -- "$@"
}

success() { echo -e "\033[32m  ✓\033[0m $*"; }
warn()    { echo -e "\033[33m  ⚠\033[0m $*"; }
error()   { echo -e "\033[31m  ✗\033[0m $*"; }

# ─── Banner ──────────────────────────────────────────────────────────────────
clear
bootstrap_gum

echo ""
gum style \
    --foreground="46" --border-foreground="99" \
    --border=double --align=center \
    --width=52 --margin="1 2" --padding="1 2" \
    "  Dotfiles Apply  ·  sys-setup  " \
    "" \
    "Fetches from repo → Applies to system"
echo ""

# ─── Git Pull ────────────────────────────────────────────────────────────────
gum_header "Fetching Latest Updates"

cd "$SCRIPT_DIR"

if ! git remote -v &>/dev/null; then
    warn "No git remote configured. Cannot fetch updates from GitHub."
else
    # Check if there are local uncommitted changes that might conflict
    if [[ -n $(git status --porcelain) ]]; then
        warn "You have uncommitted local changes!"
        if ! gum confirm --default=false "Stash local changes and pull updates?"; then
            warn "Aborting pull. Will only apply local files."
        else
            gum_spin "Stashing changes..." git stash
            gum_spin "Pulling updates..." git pull
            gum_spin "Popping stash..." git stash pop || warn "Merge conflicts found in stashed changes!"
            success "Updated from GitHub."
        fi
    else
        gum_spin "Pulling updates from GitHub..." git pull
        success "Updated from GitHub."
    fi
fi

# ─── Select configs to apply ─────────────────────────────────────────────────
gum_header "Select configs to apply"
gum style --foreground="240" --margin="0 3" "SPACE to toggle  ·  ENTER to confirm  ·  / to filter"
echo ""

# Find all available packages in the dots/ directory
AVAILABLE_PKGS=()
for pkg in "$DOTS_DIR"/*/; do
    [[ -d "$pkg" ]] || continue
    pkg_name="$(basename "$pkg")"
    AVAILABLE_PKGS+=("$pkg_name")
done

if [[ ${#AVAILABLE_PKGS[@]} -eq 0 ]]; then
    error "No packages found in $DOTS_DIR."
    exit 1
fi

SELECTED=$(gum choose --no-limit \
    --header="  Which configs should be applied (via Stow)?" \
    --header.foreground="46" \
    --cursor.foreground="46" \
    --selected.foreground="46" \
    --selected-prefix="[✓] " \
    --unselected-prefix="[ ] " \
    --cursor-prefix="[·] " \
    "${AVAILABLE_PKGS[@]}")

[[ -z "$SELECTED" ]] && { warn "Nothing selected — exiting."; exit 0; }

# ─── Stow ────────────────────────────────────────────────────────────────────
gum_header "Applying Selected Configs"

check_cmd stow || {
    warn "stow is not installed."
    gum_spin "Installing stow..." sudo pacman -S --noconfirm stow || yay -S --noconfirm stow
}

stow_pkg() {
    local pkg="$1"
    
    # Use stow to apply. --adopt will overwrite repo version with local version if there's a conflict
    # but we just want to safely apply. A dry-run first can be helpful but stow is usually safe.
    if stow --dir="$DOTS_DIR" --target="$HOME" --restow "$pkg" 2>/dev/null; then
        success "Applied: $pkg"
    else
        warn "Conflict applying $pkg. Running with --adopt..."
        if stow --adopt --dir="$DOTS_DIR" --target="$HOME" --restow "$pkg" 2>/dev/null; then
            success "Applied (adopted): $pkg"
            warn "Note: local changes were written to the repo to resolve the conflict."
        else
            error "Failed to apply $pkg"
        fi
    fi
}

for pkg in $SELECTED; do
    stow_pkg "$pkg"
done

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
gum style \
    --foreground="46" --border-foreground="46" \
    --border=rounded --align=center \
    --width=52 --margin="1 2" --padding="1 2" \
    "✓  Dotfiles applied successfully!"
echo ""
