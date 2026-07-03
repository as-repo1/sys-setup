#!/usr/bin/env bash
# =============================================================================
#  sync-dots.sh — Pull live dotfiles from ~/.config into the repo
#  Run this whenever you update a config and want to save it to the repo.
#
#  Usage:
#    cd ~/coding/sys-setup && bash sync-dots.sh
#    bash sync-dots.sh --dry-run    (preview changes only)
#    bash sync-dots.sh --no-commit  (sync files but skip git commit)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$SCRIPT_DIR/dots"
DRY_RUN=false
NO_COMMIT=false

for arg in "$@"; do
    [[ "$arg" == "--dry-run"   ]] && DRY_RUN=true
    [[ "$arg" == "--no-commit" ]] && NO_COMMIT=true
done

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
    $DRY_RUN && { echo -e "  \033[33m[dry-run]\033[0m $*"; return 0; }
    gum spin --spinner dot --title=" $title" --title.foreground="51" -- "$@"
}

success() { echo -e "\033[32m  ✓\033[0m $*"; }
warn()    { echo -e "\033[33m  ⚠\033[0m $*"; }
skipped() { echo -e "\033[90m  ↷\033[0m $* \033[90m(unchanged)\033[0m"; }
added()   { echo -e "\033[34m  +\033[0m $*"; }

# ─── Sync one dotfile package ─────────────────────────────────────────────────
# Usage: sync_pkg <stow-package-name> <source-path-relative-to-HOME>
# e.g.:  sync_pkg "niri" ".config/niri"
sync_pkg() {
    local pkg="$1"
    local src="$HOME/$2"
    local dest="$DOTS_DIR/$pkg/$2"

    # Source must exist
    if [[ ! -e "$src" ]]; then
        warn "$pkg: source not found ($src) — skipping"
        return
    fi

    if $DRY_RUN; then
        echo -e "  \033[33m[dry-run]\033[0m rsync $src → $dest"
        return
    fi

    mkdir -p "$(dirname "$dest")"
    rsync -a --delete "$src" "$(dirname "$dest")/" 2>/dev/null
    success "$pkg synced"
}

# ─── Banner ──────────────────────────────────────────────────────────────────
clear
bootstrap_gum

echo ""
gum style \
    --foreground="51" --border-foreground="201" \
    --border=double --align=center \
    --width=52 --margin="1 2" --padding="1 2" \
    "  Dotfiles Sync  ·  sys-setup  " \
    "" \
    "Pulls live configs → repo"

$DRY_RUN   && gum style --foreground="214" --bold --align=center --width=52 --margin="0 2" "⚡ DRY RUN — no files will be written"
$NO_COMMIT && gum style --foreground="214" --bold --align=center --width=52 --margin="0 2" "  NO COMMIT — files will sync but not be committed"
echo ""

# ─── Select which dotfiles to sync ───────────────────────────────────────────
gum_header "Select configs to pull from your system"
gum style --foreground="240" --margin="0 3" "SPACE to toggle  ·  ENTER to confirm  ·  / to filter"
echo ""

SELECTED=$(gum choose --no-limit \
    --header="  Which configs should be updated in the repo?" \
    --header.foreground="51" \
    --cursor.foreground="201" \
    --selected.foreground="51" \
    --selected-prefix="[✓] " \
    --unselected-prefix="[ ] " \
    --cursor-prefix="[·] " \
    "niri          · ~/.config/niri" \
    "waybar        · ~/.config/waybar" \
    "fish          · ~/.config/fish" \
    "kitty         · ~/.config/kitty" \
    "ghostty       · ~/.config/ghostty" \
    "alacritty     · ~/.config/alacritty" \
    "nvim          · ~/.config/nvim" \
    "btop          · ~/.config/btop" \
    "fuzzel        · ~/.config/fuzzel" \
    "dunst         · ~/.config/dunst" \
    "gtk           · ~/.config/gtk-3.0 + gtk-4.0" \
    "zathura       · ~/.config/zathura" \
    "mpv           · ~/.config/mpv" \
    "ranger        · ~/.config/ranger" \
    "noctalia      · ~/.config/noctalia" \
    "fastfetch     · ~/.config/fastfetch" \
    "appimagelauncher · ~/.config/appimagelauncher.cfg")

[[ -z "$SELECTED" ]] && { warn "Nothing selected — exiting."; exit 0; }

# ─── Sync ────────────────────────────────────────────────────────────────────
gum_header "Syncing Selected Configs"

[[ "$SELECTED" == *"niri"*            ]] && sync_pkg "niri"            ".config/niri"
[[ "$SELECTED" == *"waybar"*          ]] && sync_pkg "waybar"          ".config/waybar"
[[ "$SELECTED" == *"fish"*            ]] && sync_pkg "fish"            ".config/fish"
[[ "$SELECTED" == *"kitty"*           ]] && sync_pkg "kitty"           ".config/kitty"
[[ "$SELECTED" == *"ghostty"*         ]] && sync_pkg "ghostty"         ".config/ghostty"
[[ "$SELECTED" == *"alacritty"*       ]] && sync_pkg "alacritty"       ".config/alacritty"
[[ "$SELECTED" == *"nvim"*            ]] && sync_pkg "nvim"            ".config/nvim"
[[ "$SELECTED" == *"btop"*            ]] && sync_pkg "btop"            ".config/btop"
[[ "$SELECTED" == *"fuzzel"*          ]] && sync_pkg "fuzzel"          ".config/fuzzel"
[[ "$SELECTED" == *"dunst"*           ]] && sync_pkg "dunst"           ".config/dunst"
[[ "$SELECTED" == *"gtk"*             ]] && {
    sync_pkg "gtk" ".config/gtk-3.0"
    sync_pkg "gtk" ".config/gtk-4.0"
}
[[ "$SELECTED" == *"zathura"*         ]] && sync_pkg "zathura"         ".config/zathura"
[[ "$SELECTED" == *"mpv"*             ]] && sync_pkg "mpv"             ".config/mpv"
[[ "$SELECTED" == *"ranger"*          ]] && sync_pkg "ranger"          ".config/ranger"
[[ "$SELECTED" == *"noctalia"*        ]] && sync_pkg "noctalia"        ".config/noctalia"
[[ "$SELECTED" == *"fastfetch"*       ]] && sync_pkg "fastfetch"       ".config/fastfetch"
[[ "$SELECTED" == *"appimagelauncher"* ]] && sync_pkg "appimagelauncher" ".config/appimagelauncher.cfg"

# ─── Git diff summary ─────────────────────────────────────────────────────────
gum_header "Git Status"

cd "$SCRIPT_DIR"
git status --short | head -30

CHANGED=$(git status --porcelain | wc -l)
if [[ "$CHANGED" -eq 0 ]]; then
    gum style --foreground="46" --align=center --width=52 --margin="0 2" \
        "✓ Everything up to date — nothing to commit"
    exit 0
fi

gum style --foreground="51" --margin="0 3" \
    "  $CHANGED file(s) changed"

# ─── Commit ───────────────────────────────────────────────────────────────────
if ! $NO_COMMIT && ! $DRY_RUN; then
    gum_header "Commit Changes"

    # Build default message from selected packages
    PKGS=$(echo "$SELECTED" | awk -F'·' '{print $1}' | tr '\n' ' ' | sed 's/  */ /g' | xargs)
    DEFAULT_MSG="dots: sync $PKGS"

    COMMIT_MSG=$(gum input \
        --placeholder "Commit message..." \
        --value "$DEFAULT_MSG" \
        --width=60 \
        --prompt="  ❯ " \
        --prompt.foreground="51" \
        --cursor.foreground="201")

    [[ -z "$COMMIT_MSG" ]] && COMMIT_MSG="$DEFAULT_MSG"

    gum_spin "Staging changes..." git add -A
    gum_spin "Committing..."      git commit -m "$COMMIT_MSG"

    success "Committed: \"$COMMIT_MSG\""

    # Offer to push
    if git remote get-url origin &>/dev/null; then
        echo ""
        gum confirm \
            --affirmative="Push" --negative="Skip" \
            --prompt.foreground="51" \
            --selected.background="201" --selected.foreground="0" \
            "Push to remote?" && {
            gum_spin "Pushing to origin..." git push
            success "Pushed to $(git remote get-url origin)"
        } || warn "Skipped push — run 'git push' manually"
    else
        warn "No remote configured. Add one with: git remote add origin <url>"
    fi
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
gum style \
    --foreground="46" --border-foreground="46" \
    --border=rounded --align=center \
    --width=52 --margin="1 2" --padding="1 2" \
    "✓  Dotfiles synced successfully!"
echo ""
