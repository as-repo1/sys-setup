#!/usr/bin/env bash
# =============================================================================
#  install.sh — Chaos Workstation Bootstrap
#  Single-command Arch/EndeavourOS setup — powered by gum TUI
#
#  Usage:
#    bash <(curl -sL https://raw.githubusercontent.com/as-repo1/sys-setup/main/install.sh)
#  Or locally:
#    git clone https://github.com/as-repo1/sys-setup.git ~/coding/sys-setup
#    cd ~/coding/sys-setup && bash install.sh [--dry-run]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/sys-setup-install.log"
DRY_RUN=false

USER="${USER:-$(whoami)}"

for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done


# Nord Theme Colors (Hex codes for gum TUI)
NORD0="#2E3440"   # Polar Night (Deep Dark Blue-Gray)
NORD1="#3B4252"   # Polar Night (Dark Gray)
NORD2="#434C5E"   # Polar Night (Medium Gray)
NORD3="#4C566A"   # Polar Night (Light Gray / Comments)
NORD4="#D8DEE9"   # Snow Storm (Off-White)
NORD5="#E5E9F0"   # Snow Storm (White)
NORD6="#ECEFF4"   # Snow Storm (Bright White)
NORD7="#8FBCBB"   # Frost (Teal-Green)
NORD8="#88C0D0"   # Frost (Ice Cyan)
NORD9="#81A1C1"   # Frost (Sky Blue)
NORD10="#5E81AC"  # Frost (Deep Blue)
NORD11="#BF616A"  # Aurora (Nordic Red)
NORD12="#D08770"  # Aurora (Nordic Orange)
NORD13="#EBCB8B"  # Aurora (Nordic Yellow)
NORD14="#A3BE8C"  # Aurora (Nordic Green)
NORD15="#B48EAD"  # Aurora (Nordic Purple)

# ─── Raw colors (fallback before gum is available matching Nord truecolor) ───
RED='\033[38;2;191;97;106m'      # Nord11 (Red)
GREEN='\033[38;2;163;190;140m'    # Nord14 (Green)
YELLOW='\033[38;2;235;203;139m'   # Nord13 (Yellow)
ORANGE='\033[38;2;208;135;112m'   # Nord12 (Orange)
BLUE='\033[38;2;129;161;193m'     # Nord9 (Blue)
CYAN='\033[38;2;136;192;208m'     # Nord8 (Cyan)
MAGENTA='\033[38;2;180;142;173m'  # Nord15 (Purple)
BOLD='\033[1m'
RESET='\033[0m'

# ─── Helpers ─────────────────────────────────────────────────────────────────
log()     { echo -e "${CYAN}  [$(date '+%H:%M:%S')]${RESET} $*" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}  ✓${RESET} $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}  ⚠${RESET} $*" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}  ✗${RESET} $*" | tee -a "$LOG_FILE"; }

run() {
    if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${RESET} $*"; return 0; fi
    "$@" >> "$LOG_FILE" 2>&1
}

check_cmd() { command -v "$1" &>/dev/null; }

pkg_install() { run sudo pacman -S --noconfirm --needed "$@" || warn "Some packages failed: $*"; }
aur_install()  { run yay  -S --noconfirm --needed "$@" || warn "Some AUR packages failed: $*"; }

# ─── Phase 0: Preflight ───────────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}  [ DIAGNOSTIC DISPATCH ] PHASE 0  ·  Preflight Checks${RESET}"

[[ "$EUID" -eq 0 ]] && { error "Do not run as root."; exit 1; }
check_cmd pacman || { error "pacman not found — Arch/EndeavourOS only."; exit 1; }
curl -s --max-time 5 https://archlinux.org > /dev/null || { error "No internet."; exit 1; }
sudo -v || { error "sudo not configured."; exit 1; }
success "User: $USER  ·  Internet: OK  ·  sudo: OK  ·  Arch: confirmed"

# Bootstrap gum
if ! check_cmd gum; then
    echo -e "${YELLOW}  Installing dependencies (gum)...${RESET}"
    sudo pacman -Sy --noconfirm gum || \
    yay  -S --noconfirm gum || \
    { warn "gum unavailable — falling back to plain prompts"; }
fi

# ─── GUM wrappers ─────────────────────────────────────────────────────────────
# Multi-select checkbox list
gum_choose_multi() {
    local header="$1"; shift
    gum choose --no-limit \
        --header="$header" \
        --header.foreground="$NORD8" \
        --cursor.foreground="$NORD12" \
        --selected.foreground="$NORD14" \
        --item.foreground="$NORD4" \
        --selected-prefix="[✓] " \
        --unselected-prefix="[ ] " \
        --cursor-prefix="[▶] " \
        "$@"
}

# Single confirm
gum_confirm() {
    gum confirm \
        --affirmative="Yes" \
        --negative="No" \
        --prompt.foreground="$NORD8" \
        --selected.background="$NORD12" \
        --selected.foreground="$NORD0" \
        "$1"
}

# Spinner while running a command
gum_spin() {
    local title="$1"; shift
    if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${RESET} $*"; return 0; fi
    gum spin --spinner dot \
        --title=" $title" \
        --title.foreground="$NORD8" \
        --spinner.foreground="$NORD12" \
        -- "$@" >> "$LOG_FILE" 2>&1
}

# Styled section header
gum_header() {
    echo ""
    gum style \
        --foreground="$NORD8" --border-foreground="$NORD7" \
        --border=double --align=center \
        --width=52 --margin="0 2" --padding="0 1" --bold \
        "◆ $1 ◆"
    echo ""
}

# ─── Banner ──────────────────────────────────────────────────────────────────
clear
echo ""
gum style \
    --foreground="$NORD8" --border-foreground="$NORD7" \
    --border=double --align=center \
    --width=52 --margin="1 2" --padding="1 3" \
    "$(echo -e '  SYSTEM OPERATIONAL // UPLINK-9000\n\n  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗\n  ██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔════╝\n  ██║     ███████║███████║██║   ██║███████╗\n  ██║     ██╔══██║██╔══██║██║   ██║╚════██║\n  ╚██████╗██║  ██║██║  ██║╚██████╔╝███████║\n   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝\n\n  ----------------------------------------\n  NSF SOL - O\x27NEIL // FORCE IN READINESS')"

gum style --foreground="$NORD12" --bold --align=center --width=52 --margin="0 2" \
    "Workstation Bootstrap  ·  sys-setup"
gum style --foreground="$NORD3" --align=center --width=52 --margin="0 2" \
    "LOG UPLINK → $LOG_FILE"
$DRY_RUN && gum style --foreground="$NORD13" --bold --align=center --width=52 --margin="0 2" \
    "⚡ WARNING // DRY RUN MODE ACTIVE // NO CHANGES WILL BE WRITTEN"
echo ""

# ─── Phase 1: Interactive Selection ───────────────────────────────────────────
gum_header "1  ·  Configure Your Install"

gum style --foreground="$NORD3" --margin="0 3" \
    "Use SPACE to toggle, ENTER to confirm, / to filter"
echo ""

MODE=$(gum choose \
    --header="  Select Installation Profile" \
    --header.foreground="$NORD8" \
    --cursor.foreground="$NORD12" \
    --item.foreground="$NORD4" \
    --selected.foreground="$NORD14" \
    --cursor-prefix="[▶] " \
    "Typical Installation   (Niri WM + Dev tools + Browsers + Dotfiles)" \
    "Complete Installation  (All packages, appimages, dotfiles & system options)" \
    "Custom Installation    (Select exactly which categories to customize)")

# 1. Initialize Sensible "Typical" Defaults
INSTALL_NIRI=true; INSTALL_GNOME=false; INSTALL_I3=false
BR_ZEN=true; BR_FLOORP=false; BR_BRAVE=false; BR_FIREFOX=true; BR_EDGE=false; BR_CHROME=true
CHAT_TELEGRAM=false; CHAT_FERDIUM=false
DEV_NEOVIM=true; DEV_VSCODE=false; DEV_DOCKER=true; DEV_NODE=true; DEV_PYTHON=true; DEV_ANDROID=false
MEDIA_MPV=true; MEDIA_VLC=false; MEDIA_YTDLP=true; MEDIA_PARABOLIC=false
UTIL_OBSIDIAN=false; UTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_BTOP=true; UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=true
AI_ANYLLM=false; AI_LMSTUDIO=false; AI_PINOKIO=false; AI_IDESCRIPTOR=false; AI_POOL=false
DOT_NIRI=true; DOT_WAYBAR=true; DOT_FISH=true; DOT_KITTY=true; DOT_GHOSTTY=false; DOT_ALACRITTY=false; DOT_NVIM=true; DOT_BTOP=true; DOT_FUZZEL=true; DOT_DUNST=true; DOT_GTK=true; DOT_ZATHURA=false; DOT_MPV=false; DOT_RANGER=false; DOT_NOCTALIA=false; DOT_FASTFETCH=true; DOT_APPIMAGELAUNCHER=false
INSTALL_CHAOTIC=true; SYS_SSH=false; SYS_DOCKER_BOOT=true; SYS_FISH_DEFAULT=true

# 2. Complete Profile Override
if [[ "$MODE" == *"Complete"* ]]; then
    INSTALL_NIRI=true; INSTALL_GNOME=true; INSTALL_I3=true
    BR_ZEN=true; BR_FLOORP=true; BR_BRAVE=true; BR_FIREFOX=true; BR_EDGE=true; BR_CHROME=true
    CHAT_TELEGRAM=true; CHAT_FERDIUM=true
    DEV_NEOVIM=true; DEV_VSCODE=true; DEV_DOCKER=true; DEV_NODE=true; DEV_PYTHON=true; DEV_ANDROID=true
    MEDIA_MPV=true; MEDIA_VLC=true; MEDIA_YTDLP=true; MEDIA_PARABOLIC=true
    UTIL_OBSIDIAN=true; UTIL_LOCALSEND=true; UTIL_TIMESHIFT=true; UTIL_BTOP=true; UTIL_MISSION=true; UTIL_HELVUM=true; UTIL_MELD=true
    AI_ANYLLM=true; AI_LMSTUDIO=true; AI_PINOKIO=true; AI_IDESCRIPTOR=true; AI_POOL=true
    DOT_NIRI=true; DOT_WAYBAR=true; DOT_FISH=true; DOT_KITTY=true; DOT_GHOSTTY=true; DOT_ALACRITTY=true; DOT_NVIM=true; DOT_BTOP=true; DOT_FUZZEL=true; DOT_DUNST=true; DOT_GTK=true; DOT_ZATHURA=true; DOT_MPV=true; DOT_RANGER=true; DOT_NOCTALIA=true; DOT_FASTFETCH=true; DOT_APPIMAGELAUNCHER=true
    INSTALL_CHAOTIC=true; SYS_SSH=true; SYS_DOCKER_BOOT=true; SYS_FISH_DEFAULT=true

# 3. Custom Profile Prompts
elif [[ "$MODE" == *"Custom"* ]]; then
    CAT_OPTS=$(gum_choose_multi "  Select categories to customize" \
        "Desktop / Window Manager" \
        "Browsers" \
        "Chat & Messaging" \
        "Development Tools" \
        "Media Apps" \
        "Utilities" \
        "AppImages" \
        "Dotfiles" \
        "System Options")

    if [[ "$CAT_OPTS" == *"Window Manager"* ]]; then
        INSTALL_NIRI=false; INSTALL_GNOME=false; INSTALL_I3=false
        WM_OPTS=$(gum_choose_multi "  Desktop / Window Manager" \
            "Niri  (Wayland — recommended)" \
            "GNOME" \
            "i3 + bspwm  (X11)")
        [[ "$WM_OPTS" == *"Niri"*  ]] && INSTALL_NIRI=true
        [[ "$WM_OPTS" == *"GNOME"* ]] && INSTALL_GNOME=true
        [[ "$WM_OPTS" == *"i3"*    ]] && INSTALL_I3=true
    fi

    if [[ "$CAT_OPTS" == *"Browsers"* ]]; then
        BR_ZEN=false; BR_FLOORP=false; BR_BRAVE=false; BR_FIREFOX=false; BR_EDGE=false; BR_CHROME=false
        BR_OPTS=$(gum_choose_multi "  Browsers  (pick any)" \
            "Zen Browser  (AUR)" \
            "Floorp  (AUR)" \
            "Brave  (AUR)" \
            "Firefox" \
            "Microsoft Edge  (AUR)" \
            "Google Chrome  (AUR)")
        [[ "$BR_OPTS" == *"Zen"*     ]] && BR_ZEN=true
        [[ "$BR_OPTS" == *"Floorp"*  ]] && BR_FLOORP=true
        [[ "$BR_OPTS" == *"Brave"*   ]] && BR_BRAVE=true
        [[ "$BR_OPTS" == *"Firefox"* ]] && BR_FIREFOX=true
        [[ "$BR_OPTS" == *"Edge"*    ]] && BR_EDGE=true
        [[ "$BR_OPTS" == *"Chrome"*  ]] && BR_CHROME=true
    fi

    if [[ "$CAT_OPTS" == *"Chat"* ]]; then
        CHAT_TELEGRAM=false; CHAT_FERDIUM=false
        CHAT_OPTS=$(gum_choose_multi "  Chat & Messaging" \
            "Telegram Desktop" \
            "Ferdium  (AUR — all-in-one messenger)")
        [[ "$CHAT_OPTS" == *"Telegram"* ]] && CHAT_TELEGRAM=true
        [[ "$CHAT_OPTS" == *"Ferdium"*  ]] && CHAT_FERDIUM=true
    fi

    if [[ "$CAT_OPTS" == *"Development Tools"* ]]; then
        DEV_NEOVIM=false; DEV_VSCODE=false; DEV_DOCKER=false; DEV_NODE=false; DEV_PYTHON=false; DEV_ANDROID=false
        DEV_OPTS=$(gum_choose_multi "  Development Tools" \
            "Neovim" \
            "VSCode  (AUR)" \
            "Docker + Docker Compose" \
            "Node.js + npm" \
            "Python + pip" \
            "Android SDK + scrcpy")
        [[ "$DEV_OPTS" == *"Neovim"*  ]] && DEV_NEOVIM=true
        [[ "$DEV_OPTS" == *"VSCode"*  ]] && DEV_VSCODE=true
        [[ "$DEV_OPTS" == *"Docker"*  ]] && DEV_DOCKER=true
        [[ "$DEV_OPTS" == *"Node"*    ]] && DEV_NODE=true
        [[ "$DEV_OPTS" == *"Python"*  ]] && DEV_PYTHON=true
        [[ "$DEV_OPTS" == *"Android"* ]] && DEV_ANDROID=true
    fi

    if [[ "$CAT_OPTS" == *"Media"* ]]; then
        MEDIA_MPV=false; MEDIA_VLC=false; MEDIA_YTDLP=false; MEDIA_PARABOLIC=false
        MEDIA_OPTS=$(gum_choose_multi "  Media Apps" \
            "mpv" \
            "VLC" \
            "yt-dlp  (CLI downloader)" \
            "Parabolic  (AUR — GUI yt-dlp)")
        [[ "$MEDIA_OPTS" == *"mpv"*       ]] && MEDIA_MPV=true
        [[ "$MEDIA_OPTS" == *"VLC"*       ]] && MEDIA_VLC=true
        [[ "$MEDIA_OPTS" == *"yt-dlp"*    ]] && MEDIA_YTDLP=true
        [[ "$MEDIA_OPTS" == *"Parabolic"* ]] && MEDIA_PARABOLIC=true
    fi

    if [[ "$CAT_OPTS" == *"Utilities"* ]]; then
        UTIL_OBSIDIAN=false; UTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_BTOP=false; UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=false
        UTIL_OPTS=$(gum_choose_multi "  Utilities" \
            "Obsidian  (AUR — notes)" \
            "LocalSend  (AUR — file sharing)" \
            "Timeshift  (backups)" \
            "btop  (resource monitor)" \
            "Mission Center  (AUR — GUI monitor)" \
            "Helvum  (AUR — audio patchbay)" \
            "Meld  (diff/merge tool)")
        [[ "$UTIL_OPTS" == *"Obsidian"* ]] && UTIL_OBSIDIAN=true
        [[ "$UTIL_OPTS" == *"LocalSend"* ]] && UTIL_LOCALSEND=true
        [[ "$UTIL_OPTS" == *"Timeshift"* ]] && UTIL_TIMESHIFT=true
        [[ "$UTIL_OPTS" == *"btop"*     ]] && UTIL_BTOP=true
        [[ "$UTIL_OPTS" == *"Mission"*  ]] && UTIL_MISSION=true
        [[ "$UTIL_OPTS" == *"Helvum"*   ]] && UTIL_HELVUM=true
        [[ "$UTIL_OPTS" == *"Meld"*     ]] && UTIL_MELD=true
    fi

    if [[ "$CAT_OPTS" == *"AppImages"* ]]; then
        AI_ANYLLM=false; AI_LMSTUDIO=false; AI_PINOKIO=false; AI_IDESCRIPTOR=false; AI_POOL=false
        AI_OPTS=$(gum_choose_multi "  AppImages  (downloaded to ~/Appimages)" \
            "AnythingLLM Desktop  (local AI)" \
            "LM Studio  (local LLM runner)" \
            "Pinokio  (AI app browser)" \
            "iDescriptor" \
            "AppImagePool  (AppImage manager)")
        [[ "$AI_OPTS" == *"AnythingLLM"*  ]] && AI_ANYLLM=true
        [[ "$AI_OPTS" == *"LM Studio"*    ]] && AI_LMSTUDIO=true
        [[ "$AI_OPTS" == *"Pinokio"*      ]] && AI_PINOKIO=true
        [[ "$AI_OPTS" == *"iDescriptor"*  ]] && AI_IDESCRIPTOR=true
        [[ "$AI_OPTS" == *"AppImagePool"* ]] && AI_POOL=true
    fi

    if [[ "$CAT_OPTS" == *"Dotfiles"* ]]; then
        DOT_NIRI=false; DOT_WAYBAR=false; DOT_FISH=false; DOT_KITTY=false; DOT_GHOSTTY=false; DOT_ALACRITTY=false; DOT_NVIM=false; DOT_BTOP=false; DOT_FUZZEL=false; DOT_DUNST=false; DOT_GTK=false; DOT_ZATHURA=false; DOT_MPV=false; DOT_RANGER=false; DOT_NOCTALIA=false; DOT_FASTFETCH=false; DOT_APPIMAGELAUNCHER=false
        DOT_OPTS=$(gum_choose_multi "  Dotfiles  (configs to stow into ~)" \
            "niri  (WM config + keybinds)" \
            "waybar  (status bar)" \
            "fish  (shell config + aliases)" \
            "kitty  (terminal)" \
            "ghostty  (terminal)" \
            "alacritty  (terminal)" \
            "neovim" \
            "btop  (monitor theme)" \
            "fuzzel  (app launcher)" \
            "dunst  (notifications)" \
            "gtk  (themes GTK3/4)" \
            "zathura  (PDF viewer)" \
            "mpv  (media player)" \
            "ranger  (file manager)" \
            "noctalia  (noctalia-shell)" \
            "fastfetch" \
            "appimagelauncher  (config)")
        [[ "$DOT_OPTS" == *"niri"*            ]] && DOT_NIRI=true
        [[ "$DOT_OPTS" == *"waybar"*          ]] && DOT_WAYBAR=true
        [[ "$DOT_OPTS" == *"fish"*            ]] && DOT_FISH=true
        [[ "$DOT_OPTS" == *"kitty"*           ]] && DOT_KITTY=true
        [[ "$DOT_OPTS" == *"ghostty"*         ]] && DOT_GHOSTTY=true
        [[ "$DOT_OPTS" == *"alacritty"*       ]] && DOT_ALACRITTY=true
        [[ "$DOT_OPTS" == *"neovim"*          ]] && DOT_NVIM=true
        [[ "$DOT_OPTS" == *"btop"*            ]] && DOT_BTOP=true
        [[ "$DOT_OPTS" == *"fuzzel"*          ]] && DOT_FUZZEL=true
        [[ "$DOT_OPTS" == *"dunst"*           ]] && DOT_DUNST=true
        [[ "$DOT_OPTS" == *"gtk"*             ]] && DOT_GTK=true
        [[ "$DOT_OPTS" == *"zathura"*         ]] && DOT_ZATHURA=true
        [[ "$DOT_OPTS" == *"mpv"*             ]] && DOT_MPV=true
        [[ "$DOT_OPTS" == *"ranger"*          ]] && DOT_RANGER=true
        [[ "$DOT_OPTS" == *"noctalia"*        ]] && DOT_NOCTALIA=true
        [[ "$DOT_OPTS" == *"fastfetch"*       ]] && DOT_FASTFETCH=true
        [[ "$DOT_OPTS" == *"appimagelauncher"* ]] && DOT_APPIMAGELAUNCHER=true
    fi

    if [[ "$CAT_OPTS" == *"System Options"* ]]; then
        INSTALL_CHAOTIC=false; SYS_SSH=false; SYS_DOCKER_BOOT=false; SYS_FISH_DEFAULT=false
        SYS_OPTS=$(gum_choose_multi "  System Options" \
            "Chaotic-AUR  (pre-built AUR — faster installs)" \
            "Enable SSH server" \
            "Enable Docker on boot" \
            "Set fish as default shell")
        [[ "$SYS_OPTS" == *"Chaotic"* ]] && INSTALL_CHAOTIC=true
        [[ "$SYS_OPTS" == *"SSH"*     ]] && SYS_SSH=true
        [[ "$SYS_OPTS" == *"Docker"*  ]] && SYS_DOCKER_BOOT=true
        [[ "$SYS_OPTS" == *"fish"*    ]] && SYS_FISH_DEFAULT=true
    fi
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
gum_header "Review Your Selection"

# Build summary table
make_row() { $1 && echo "  ${GREEN}✓${RESET} $2" || true; }

echo -e "${BOLD}  Window Manager${RESET}"
make_row $INSTALL_NIRI "Niri/Wayland"; make_row $INSTALL_GNOME "GNOME"; make_row $INSTALL_I3 "i3/bspwm"

echo -e "\n${BOLD}  Browsers${RESET}"
make_row $BR_ZEN "Zen"; make_row $BR_FLOORP "Floorp"; make_row $BR_BRAVE "Brave"
make_row $BR_FIREFOX "Firefox"; make_row $BR_EDGE "Edge"; make_row $BR_CHROME "Chrome"

echo -e "\n${BOLD}  Chat${RESET}"
make_row $CHAT_TELEGRAM "Telegram"; make_row $CHAT_FERDIUM "Ferdium"

echo -e "\n${BOLD}  Dev${RESET}"
make_row $DEV_NEOVIM "Neovim"; make_row $DEV_VSCODE "VSCode"; make_row $DEV_DOCKER "Docker"
make_row $DEV_NODE "Node.js"; make_row $DEV_PYTHON "Python"; make_row $DEV_ANDROID "Android SDK"

echo -e "\n${BOLD}  Media${RESET}"
make_row $MEDIA_MPV "mpv"; make_row $MEDIA_VLC "VLC"
make_row $MEDIA_YTDLP "yt-dlp"; make_row $MEDIA_PARABOLIC "Parabolic"

echo -e "\n${BOLD}  Utilities${RESET}"
make_row $UTIL_OBSIDIAN "Obsidian"; make_row $UTIL_LOCALSEND "LocalSend"
make_row $UTIL_TIMESHIFT "Timeshift"; make_row $UTIL_BTOP "btop"
make_row $UTIL_MISSION "Mission Center"; make_row $UTIL_HELVUM "Helvum"
make_row $UTIL_MELD "Meld"

echo -e "\n${BOLD}  AppImages${RESET}"
make_row $AI_ANYLLM "AnythingLLM"; make_row $AI_LMSTUDIO "LM Studio"
make_row $AI_PINOKIO "Pinokio"; make_row $AI_IDESCRIPTOR "iDescriptor"
make_row $AI_POOL "AppImagePool"

echo -e "\n${BOLD}  Dotfiles${RESET}"
for d in niri waybar fish kitty ghostty alacritty nvim btop fuzzel dunst gtk zathura mpv ranger noctalia fastfetch appimagelauncher; do
    varname="DOT_${d^^}"
    varname="${varname//-/_}"
    ${!varname} && echo -e "  ${GREEN}✓${RESET} $d" || true
done

echo ""
gum_confirm "Everything look good? Start the installation?" || { warn "Aborted."; exit 0; }

# ═══════════════════════════════════════════════════════════════════════════════
#  INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Phase 2: System Setup ────────────────────────────────────────────────────
gum_header "2  ·  System Setup"

gum_spin "Ranking mirrors with reflector..." \
    sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
success "Mirrors updated"

gum_spin "Syncing package databases..." sudo pacman -Sy
success "Package DB synced"

# ─── Phase 3: Chaotic-AUR ─────────────────────────────────────────────────────
if $INSTALL_CHAOTIC; then
    gum_header "3  ·  Chaotic-AUR"
    gum_spin "Setting up Chaotic-AUR..." bash "$SCRIPT_DIR/scripts/setup-chaotic-aur.sh"
    success "Chaotic-AUR ready"
fi

# ─── Phase 4: yay ────────────────────────────────────────────────────────────
gum_header "4  ·  AUR Helper (yay)"

if check_cmd yay; then
    success "yay already installed"
else
    gum_spin "Installing yay..." bash -c "
        sudo pacman -S --noconfirm git base-devel
        TMP=\$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git \$TMP/yay
        cd \$TMP/yay && makepkg -si --noconfirm
        rm -rf \$TMP"
    success "yay installed"
fi

# ─── Phase 5: Packages ────────────────────────────────────────────────────────
gum_header "5  ·  Installing Packages"

# Core
mapfile -t CORE_PKGS < <(grep -v '^\s*#' "$SCRIPT_DIR/packages/pkglist-core.txt" | grep -v '^\s*$')
gum_spin "Installing ${#CORE_PKGS[@]} core packages..." \
    sudo pacman -S --noconfirm --needed "${CORE_PKGS[@]}"
success "Core packages installed"

# WM
$INSTALL_NIRI  && { gum_spin "Installing Niri/Wayland stack..." \
    sudo pacman -S --noconfirm --needed niri waybar fuzzel swaybg swaylock wl-clipboard cliphist grim slurp mako xdg-desktop-portal xdg-desktop-portal-gnome polkit-gnome; success "Niri stack installed"; }
$INSTALL_GNOME && { gum_spin "Installing GNOME..." \
    sudo pacman -S --noconfirm --needed gdm gnome-shell gnome-control-center gnome-tweaks gnome-terminal gnome-console gnome-text-editor gnome-disk-utility gnome-system-monitor gnome-calculator gnome-clocks gnome-weather gnome-usage gnome-keyring nautilus loupe sushi evince adwaita-icon-theme; success "GNOME installed"; }
$INSTALL_I3    && { gum_spin "Installing i3/bspwm..." \
    sudo pacman -S --noconfirm --needed i3-wm bspwm sxhkd; success "i3/bspwm installed"; }

# Browsers
$BR_ZEN     && { gum_spin "Installing Zen Browser..."  yay -S --noconfirm --needed zen-browser-bin;             success "Zen installed"; }
$BR_FLOORP  && { gum_spin "Installing Floorp..."        yay -S --noconfirm --needed floorp-bin;                  success "Floorp installed"; }
$BR_BRAVE   && { gum_spin "Installing Brave..."         yay -S --noconfirm --needed brave-bin;                   success "Brave installed"; }
$BR_FIREFOX && { gum_spin "Installing Firefox..."       sudo pacman -S --noconfirm --needed firefox;             success "Firefox installed"; }
$BR_EDGE    && { gum_spin "Installing Edge..."          yay -S --noconfirm --needed microsoft-edge-stable-bin;   success "Edge installed"; }
$BR_CHROME  && { gum_spin "Installing Chrome..."        yay -S --noconfirm --needed google-chrome;               success "Chrome installed"; }

# Chat
$CHAT_TELEGRAM && { gum_spin "Installing Telegram..." sudo pacman -S --noconfirm --needed telegram-desktop; success "Telegram installed"; }
$CHAT_FERDIUM  && { gum_spin "Installing Ferdium..."  yay -S --noconfirm --needed ferdium-bin;              success "Ferdium installed"; }

# Dev
$DEV_NEOVIM  && { gum_spin "Installing Neovim..."    sudo pacman -S --noconfirm --needed neovim;                       success "Neovim installed"; }
$DEV_VSCODE  && { gum_spin "Installing VSCode..."    yay -S --noconfirm --needed visual-studio-code-bin;               success "VSCode installed"; }
$DEV_DOCKER  && { gum_spin "Installing Docker..."    sudo pacman -S --noconfirm --needed docker docker-compose;        success "Docker installed"; }
$DEV_NODE    && { gum_spin "Installing Node.js..."   sudo pacman -S --noconfirm --needed nodejs npm;                   success "Node.js installed"; }
$DEV_PYTHON  && { gum_spin "Installing Python..."    sudo pacman -S --noconfirm --needed python python-pip;            success "Python installed"; }
$DEV_ANDROID && { gum_spin "Installing Android SDK..." sudo pacman -S --noconfirm --needed android-tools scrcpy; \
                  yay -S --noconfirm --needed android-sdk-cmdline-tools-latest; success "Android SDK installed"; }

# Media
$MEDIA_MPV       && { gum_spin "Installing mpv..."       sudo pacman -S --noconfirm --needed mpv gst-libav gst-plugin-va gst-plugins-bad gst-plugins-ugly libdvdcss; success "mpv installed"; }
$MEDIA_VLC       && { gum_spin "Installing VLC..."        sudo pacman -S --noconfirm --needed vlc;          success "VLC installed"; }
$MEDIA_YTDLP     && { gum_spin "Installing yt-dlp..."     sudo pacman -S --noconfirm --needed yt-dlp;       success "yt-dlp installed"; }
$MEDIA_PARABOLIC && { gum_spin "Installing Parabolic..."  yay -S --noconfirm --needed parabolic;            success "Parabolic installed"; }

# Utilities
$UTIL_OBSIDIAN  && { gum_spin "Installing Obsidian..."       yay -S --noconfirm --needed obsidian;       success "Obsidian installed"; }
$UTIL_LOCALSEND && { gum_spin "Installing LocalSend..."      yay -S --noconfirm --needed localsend-bin;  success "LocalSend installed"; }
$UTIL_TIMESHIFT && { gum_spin "Installing Timeshift..."      sudo pacman -S --noconfirm --needed timeshift; success "Timeshift installed"; }
$UTIL_BTOP      && { gum_spin "Installing btop..."           sudo pacman -S --noconfirm --needed btop;   success "btop installed"; }
$UTIL_MISSION   && { gum_spin "Installing Mission Center..." yay -S --noconfirm --needed mission-center; success "Mission Center installed"; }
$UTIL_HELVUM    && { gum_spin "Installing Helvum..."         yay -S --noconfirm --needed helvum-git;     success "Helvum installed"; }
$UTIL_MELD      && { gum_spin "Installing Meld..."           sudo pacman -S --noconfirm --needed meld;   success "Meld installed"; }

# Always install noctalia + antigravity + appimagelauncher
gum_spin "Installing noctalia-shell + appimagelauncher..." \
    yay -S --noconfirm --needed noctalia-shell antigravity appimagelauncher
success "noctalia-shell + antigravity installed"

# Flatpak
gum_spin "Adding Flathub remote..." \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
while IFS= read -r app; do
    [[ -z "$app" || "$app" == \#* ]] && continue
    gum_spin "Installing flatpak: $app..." flatpak install -y flathub "$app" || warn "$app failed"
done < "$SCRIPT_DIR/packages/pkglist-flatpak.txt"
success "Flatpak apps installed"

# ─── Phase 6: Services ────────────────────────────────────────────────────────
gum_header "6  ·  Enabling Services"

while IFS= read -r svc; do
    [[ -z "$svc" ]] && continue
    run sudo systemctl enable "$svc" && success "Enabled: $svc" || warn "Skipped: $svc"
done < "$SCRIPT_DIR/system/services.txt"

$SYS_SSH         && { run sudo systemctl enable sshd;      success "SSH enabled"; }
$SYS_DOCKER_BOOT && { run sudo systemctl enable docker containerd; success "Docker enabled on boot"; }

# ─── Phase 7: Dotfiles ────────────────────────────────────────────────────────
gum_header "7  ·  Stowing Dotfiles"

check_cmd stow || { gum_spin "Installing stow..." sudo pacman -S --noconfirm stow; }

DOTS_DIR="$SCRIPT_DIR/dots"
stow_pkg() {
    local enabled="$1" pkg="$2"
    if $enabled; then
        if run stow --dir="$DOTS_DIR" --target="$HOME" "$pkg"; then
            success "Stowed: $pkg"
        else
            warn "Conflict on $pkg — run: stow --adopt -d $DOTS_DIR -t \$HOME $pkg"
        fi
    fi
}

stow_pkg $DOT_NIRI            niri
stow_pkg $DOT_WAYBAR          waybar
stow_pkg $DOT_FISH            fish
stow_pkg $DOT_KITTY           kitty
stow_pkg $DOT_GHOSTTY         ghostty
stow_pkg $DOT_ALACRITTY       alacritty
stow_pkg $DOT_NVIM            nvim
stow_pkg $DOT_BTOP            btop
stow_pkg $DOT_FUZZEL          fuzzel
stow_pkg $DOT_DUNST           dunst
stow_pkg $DOT_GTK             gtk
stow_pkg $DOT_ZATHURA         zathura
stow_pkg $DOT_MPV             mpv
stow_pkg $DOT_RANGER          ranger
stow_pkg $DOT_NOCTALIA        noctalia
stow_pkg $DOT_FASTFETCH       fastfetch
stow_pkg $DOT_APPIMAGELAUNCHER appimagelauncher

# ─── Phase 8: AppImages ───────────────────────────────────────────────────────
gum_header "8  ·  AppImages"

APPIMG_DIR="$HOME/Appimages"
mkdir -p "$APPIMG_DIR"

dl_appimage() {
    local enabled="$1" name="$2" url="$3"
    $enabled || return 0
    local out="$APPIMG_DIR/${name}.AppImage"
    [[ -f "$out" ]] && { warn "$name already exists"; return 0; }
    gum_spin "Downloading $name..." curl -L --silent -o "$out" "$url" && {
        chmod +x "$out"
        check_cmd ail-cli && run ail-cli integrate "$out"
        success "AppImage ready: $name"
    } || { error "Failed: $name"; rm -f "$out"; }
}

dl_appimage $AI_ANYLLM     "AnythingLLMDesktop" \
    "https://github.com/Mintplex-Labs/anything-llm/releases/latest/download/AnythingLLMDesktop.AppImage"
dl_appimage $AI_LMSTUDIO   "LM-Studio" \
    "https://releases.lmstudio.ai/linux/x64/latest/LM-Studio-linux-x64.AppImage"
dl_appimage $AI_PINOKIO    "Pinokio" \
    "https://github.com/pinokiocomputer/pinokio/releases/latest/download/Pinokio-Linux.AppImage"
dl_appimage $AI_IDESCRIPTOR "iDescriptor" \
    "https://github.com/iDescriptor/iDescriptor/releases/latest/download/iDescriptor-Linux_x86_64.AppImage"
dl_appimage $AI_POOL       "AppImagePool" \
    "https://github.com/prateekmedia/appimagepool/releases/latest/download/appimagepool-x86_64.AppImage"

# ─── Phase 9: Post-Install ────────────────────────────────────────────────────
gum_header "9  ·  Post-Install"

bash "$SCRIPT_DIR/scripts/setup-git.sh"

$DEV_DOCKER  && bash "$SCRIPT_DIR/scripts/setup-docker.sh"
$DEV_ANDROID && bash "$SCRIPT_DIR/scripts/setup-android-sdk.sh"

if $SYS_FISH_DEFAULT && check_cmd fish && [[ "$SHELL" != "$(which fish)" ]]; then
    run chsh -s "$(which fish)" && success "Default shell → fish (re-login to apply)"
fi

run xdg-user-dirs-update

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
gum style \
    --foreground="46" --border-foreground="46" \
    --border=double --align=center \
    --width=52 --margin="1 2" --padding="1 3" \
    "✓  Setup Complete!" \
    "" \
    "Your workstation is ready." \
    "Log saved to: ~/sys-setup-install.log"
echo ""

gum_confirm "Reboot now to apply all changes?" && sudo reboot || true
