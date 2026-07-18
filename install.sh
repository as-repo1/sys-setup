#!/usr/bin/env bash
# =============================================================================
#  install.sh — Universal Workstation Bootstrap
#  One-command setup for Arch/EndeavourOS, Ubuntu/Debian, Fedora, and macOS
#  Powered by gum TUI with Nord theme
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

# ═══════════════════════════════════════════════════════════════════════════════
#  OS DETECTION
# ═══════════════════════════════════════════════════════════════════════════════

OS=""
IS_LINUX=false
IS_MAC=false

detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            IS_MAC=true
            ;;
        Linux)
            IS_LINUX=true
            if check_cmd pacman; then
                OS="arch"
            elif check_cmd apt-get; then
                OS="ubuntu"
            elif check_cmd dnf; then
                OS="fedora"
            else
                error "Unsupported Linux distribution. Supported: Arch, Ubuntu/Debian, Fedora."
                exit 1
            fi
            ;;
        *)
            error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

detect_os

# ─── Package manager wrappers ────────────────────────────────────────────────
pkg_install() {
    if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${RESET} pkg_install: $*"; return 0; fi
    case "$OS" in
        arch)   sudo pacman -S --noconfirm --needed "$@" >> "$LOG_FILE" 2>&1 || warn "Some packages failed: $*" ;;
        ubuntu) sudo apt-get install -y "$@" >> "$LOG_FILE" 2>&1 || warn "Some packages failed: $*" ;;
        fedora) sudo dnf install -y "$@" >> "$LOG_FILE" 2>&1 || warn "Some packages failed: $*" ;;
        macos)  brew install "$@" >> "$LOG_FILE" 2>&1 || warn "Some packages failed: $*" ;;
    esac
}

aur_install() {
    if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${RESET} aur_install: $*"; return 0; fi
    case "$OS" in
        arch)   yay -S --noconfirm --needed "$@" >> "$LOG_FILE" 2>&1 || warn "AUR install failed: $*" ;;
        *)      warn "AUR not available on $OS — skipping $*" ;;
    esac
}

cask_install() {
    if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${RESET} cask_install: $*"; return 0; fi
    if [[ "$OS" == "macos" ]]; then
        brew install --cask "$@" >> "$LOG_FILE" 2>&1 || warn "Cask install failed: $*"
    else
        warn "cask_install only available on macOS — skipping $*"
    fi
}

flat_install() {
    if $DRY_RUN; then echo -e "  ${YELLOW}[dry-run]${RESET} flat_install: $*"; return 0; fi
    if $IS_LINUX && check_cmd flatpak; then
        flatpak install -y flathub "$@" >> "$LOG_FILE" 2>&1 || warn "Flatpak install failed: $*"
    fi
}

# Source package mapping
source "$SCRIPT_DIR/packages/pkg-map.sh"

# ─── Phase 0: Preflight ───────────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}  [ DIAGNOSTIC DISPATCH ] PHASE 0  ·  Preflight Checks${RESET}"

[[ "$EUID" -eq 0 ]] && { error "Do not run as root."; exit 1; }

# Internet check
curl -s --max-time 5 https://archlinux.org > /dev/null 2>&1 || \
curl -s --max-time 5 https://google.com > /dev/null 2>&1 || \
{ error "No internet connection."; exit 1; }

# Platform-specific checks
case "$OS" in
    arch)
        check_cmd pacman || { error "pacman not found."; exit 1; }
        sudo -v || { error "sudo not configured."; exit 1; }
        ;;
    ubuntu)
        check_cmd apt-get || { error "apt-get not found."; exit 1; }
        sudo -v || { error "sudo not configured."; exit 1; }
        ;;
    fedora)
        check_cmd dnf || { error "dnf not found."; exit 1; }
        sudo -v || { error "sudo not configured."; exit 1; }
        ;;
    macos)
        if ! check_cmd brew; then
            echo -e "${YELLOW}  Installing Homebrew...${RESET}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        ;;
esac

success "User: $USER  ·  OS: $OS  ·  Internet: OK"

# Bootstrap gum
if ! check_cmd gum; then
    echo -e "${YELLOW}  Installing dependencies (gum)...${RESET}"
    case "$OS" in
        arch)   sudo pacman -Sy --noconfirm gum || yay -S --noconfirm gum 2>/dev/null ;;
        ubuntu) sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                sudo apt-get update && sudo apt-get install -y gum ;;
        fedora) echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
                sudo dnf install -y gum ;;
        macos)  brew install gum ;;
    esac || warn "gum unavailable — install manually: https://github.com/charmbracelet/gum"
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
    gum spin --show-output --spinner dot \
        --title=" $title" \
        --title.foreground="$NORD8" \
        --spinner.foreground="$NORD12" \
        -- bash -c '"$@" 2>&1 | tee -a "$LOG_FILE"' _ "$@"
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
    "$(echo -e '  SYSTEM OPERATIONAL // UPLINK-9000\n\n  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗\n  ██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔════╝\n  ██║     ███████║███████║██║   ██║███████╗\n  ██║     ██╔══██║██╔══██║██║   ██║╚════██║\n  ╚██████╗██║  ██║██║  ██║╚██████╔╝███████║\n   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝\n\n  ----------------------------------------\n  NSF SOL - O'\''NEIL // FORCE IN READINESS')"

gum style --foreground="$NORD12" --bold --align=center --width=52 --margin="0 2" \
    "Workstation Bootstrap  ·  sys-setup"
gum style --foreground="$NORD3" --align=center --width=52 --margin="0 2" \
    "OS: $OS  ·  LOG → $LOG_FILE"
$DRY_RUN && gum style --foreground="$NORD13" --bold --align=center --width=52 --margin="0 2" \
    "⚡ WARNING // DRY RUN MODE ACTIVE // NO CHANGES WILL BE WRITTEN"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
#  PHASE 1: Interactive Selection
# ═══════════════════════════════════════════════════════════════════════════════
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
    "Typical Installation   (Recommended defaults — fast setup)" \
    "Complete Installation  (Everything — all packages and configs)" \
    "Custom Installation    (Pick exactly what you want)")

# ─── Initialize Sensible "Typical" Defaults ──────────────────────────────────

# Window Manager (Linux only)
INSTALL_NIRI=true; INSTALL_GNOME=false; INSTALL_I3=false

# Browsers
BR_ZEN=true; BR_FLOORP=false; BR_BRAVE=false; BR_FIREFOX=true; BR_EDGE=false
BR_CHROME=true; BR_LIBREWOLF=false; BR_VIVALDI=false; BR_CHROMIUM=false; BR_TOR=false

# Chat & Messaging
CHAT_TELEGRAM=false; CHAT_FERDIUM=false; CHAT_DISCORD=false; CHAT_VESKTOP=false
CHAT_SIGNAL=false; CHAT_SLACK=false; CHAT_ELEMENT=false; CHAT_THUNDERBIRD=false

# Multimedia
MEDIA_MPV=true; MEDIA_VLC=false; MEDIA_YTDLP=true; MEDIA_PARABOLIC=false
MEDIA_CELLULOID=false; MEDIA_OBS=false; MEDIA_KDENLIVE=false; MEDIA_AUDACITY=false
MEDIA_HANDBRAKE=false; MEDIA_SPOTIFY=false; MEDIA_FREETUBE=false; MEDIA_AMBEROL=false

# Development
DEV_NEOVIM=true; DEV_VSCODE=false; DEV_DOCKER=true; DEV_NODE=true; DEV_PYTHON=true
DEV_ANDROID=false; DEV_ZED=false; DEV_HELIX=false; DEV_GO=false; DEV_RUST=false
DEV_GH=false; DEV_LAZYGIT=false; DEV_POSTMAN=false; DEV_DBEAVER=false

# Notes & Office
NOTES_OBSIDIAN=false; NOTES_LOGSEQ=false; NOTES_LIBREOFFICE=false; NOTES_ONLYOFFICE=false
NOTES_ZATHURA=false; NOTES_OKULAR=false; NOTES_MARKER=false

# File Managers
FM_NAUTILUS=true; FM_NEMO=false; FM_THUNAR=false; FM_PCMANFM=false

# Utilities
UTIL_BTOP=true; UTIL_HTOP=true; UTIL_NVTOP=true; UTIL_GLANCES=false; UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=true
UTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_KEEPASSXC=false; UTIL_BITWARDEN=false
UTIL_SYNCTHING=false; UTIL_FLAMESHOT=false; UTIL_COPYQ=false; UTIL_VENTOY=false
UTIL_BAOBAB=false; UTIL_GNOME_DISKS=false; UTIL_FILE_ROLLER=true; UTIL_UNRAR=true; UTIL_UNZIP=true

# Gaming (Linux only)
GAME_STEAM=false; GAME_LUTRIS=false; GAME_HEROIC=false
GAME_GAMEMODE=false; GAME_MANGOHUD=false; GAME_PROTONUP=false

# AI & LLMs
AI_ANYLLM=false; AI_LMSTUDIO=false; AI_PINOKIO=false
AI_OLLAMA=false; AI_OPENWEBUI=false; AI_JAN=false

# Dotfiles
DOT_NIRI=true; DOT_WAYBAR=true; DOT_FISH=true; DOT_KITTY=true
DOT_GHOSTTY=false; DOT_ALACRITTY=false; DOT_NVIM=true; DOT_BTOP=true
DOT_FUZZEL=true; DOT_DUNST=true; DOT_GTK=true; DOT_ZATHURA=false
DOT_MPV=false; DOT_RANGER=false; DOT_NOCTALIA=false; DOT_FASTFETCH=true
DOT_APPIMAGELAUNCHER=false

# System
INSTALL_CHAOTIC=true; SYS_SSH=false; SYS_DOCKER_BOOT=true; SYS_FISH_DEFAULT=true

# Security & Hardening (Linux only)
SEC_FAIL2BAN=false; SEC_SSH_HARDEN=false; SEC_DNSSEC=false; SEC_AUTO_UPDATE=false

# ─── macOS: override Linux-only defaults ─────────────────────────────────────
if $IS_MAC; then
    INSTALL_NIRI=false; INSTALL_GNOME=false; INSTALL_I3=false
    INSTALL_CHAOTIC=false; SYS_DOCKER_BOOT=false
    DOT_NIRI=false; DOT_WAYBAR=false; DOT_FUZZEL=false; DOT_DUNST=false
    DOT_GTK=false; DOT_APPIMAGELAUNCHER=false; DOT_NOCTALIA=false
fi

# ─── Complete Profile Override ────────────────────────────────────────────────
if [[ "$MODE" == *"Complete"* ]]; then
    $IS_LINUX && { INSTALL_NIRI=true; INSTALL_GNOME=true; INSTALL_I3=true; }
    BR_ZEN=true; BR_FLOORP=true; BR_BRAVE=true; BR_FIREFOX=true; BR_EDGE=true
    BR_CHROME=true; BR_LIBREWOLF=true; BR_VIVALDI=true; BR_CHROMIUM=true; BR_TOR=true

    CHAT_TELEGRAM=true; CHAT_FERDIUM=true; CHAT_DISCORD=true; CHAT_VESKTOP=true
    CHAT_SIGNAL=true; CHAT_SLACK=true; CHAT_ELEMENT=true; CHAT_THUNDERBIRD=true

    MEDIA_MPV=true; MEDIA_VLC=true; MEDIA_YTDLP=true; MEDIA_PARABOLIC=true
    MEDIA_CELLULOID=true; MEDIA_OBS=true; MEDIA_KDENLIVE=true; MEDIA_AUDACITY=true
    MEDIA_HANDBRAKE=true; MEDIA_SPOTIFY=true; MEDIA_FREETUBE=true; MEDIA_AMBEROL=true

    DEV_NEOVIM=true; DEV_VSCODE=true; DEV_DOCKER=true; DEV_NODE=true; DEV_PYTHON=true
    DEV_ANDROID=true; DEV_ZED=true; DEV_HELIX=true; DEV_GO=true; DEV_RUST=true
    DEV_GH=true; DEV_LAZYGIT=true; DEV_POSTMAN=true; DEV_DBEAVER=true

    NOTES_OBSIDIAN=true; NOTES_LOGSEQ=true; NOTES_LIBREOFFICE=true; NOTES_ONLYOFFICE=true
    NOTES_ZATHURA=true; NOTES_OKULAR=true; NOTES_MARKER=true

    FM_NAUTILUS=true; FM_NEMO=true; FM_THUNAR=true; FM_PCMANFM=true

    UTIL_BTOP=true; UTIL_HTOP=true; UTIL_NVTOP=true; UTIL_GLANCES=true; UTIL_MISSION=true; UTIL_HELVUM=true; UTIL_MELD=true
    UTIL_LOCALSEND=true; UTIL_TIMESHIFT=true; UTIL_KEEPASSXC=true; UTIL_BITWARDEN=true
    UTIL_SYNCTHING=true; UTIL_FLAMESHOT=true; UTIL_COPYQ=true; UTIL_VENTOY=true
    UTIL_BAOBAB=true; UTIL_GNOME_DISKS=true; UTIL_FILE_ROLLER=true; UTIL_UNRAR=true; UTIL_UNZIP=true

    $IS_LINUX && {
        GAME_STEAM=true; GAME_LUTRIS=true; GAME_HEROIC=true
        GAME_GAMEMODE=true; GAME_MANGOHUD=true; GAME_PROTONUP=true
    }

    AI_ANYLLM=true; AI_LMSTUDIO=true; AI_PINOKIO=true
    AI_OLLAMA=true; AI_OPENWEBUI=true; AI_JAN=true

    $IS_LINUX && {
        DOT_NIRI=true; DOT_WAYBAR=true; DOT_FUZZEL=true; DOT_DUNST=true
        DOT_GTK=true; DOT_NOCTALIA=true; DOT_APPIMAGELAUNCHER=true
    }
    DOT_FISH=true; DOT_KITTY=true; DOT_GHOSTTY=true; DOT_ALACRITTY=true
    DOT_NVIM=true; DOT_BTOP=true; DOT_ZATHURA=true; DOT_MPV=true
    DOT_RANGER=true; DOT_FASTFETCH=true

    $IS_LINUX && { INSTALL_CHAOTIC=true; SYS_SSH=true; SYS_DOCKER_BOOT=true; }
    SYS_FISH_DEFAULT=true

    $IS_LINUX && {
        SEC_FAIL2BAN=true; SEC_SSH_HARDEN=true; SEC_DNSSEC=true; SEC_AUTO_UPDATE=true
    }

# ─── Custom Profile Prompts ──────────────────────────────────────────────────
elif [[ "$MODE" == *"Custom"* ]]; then

    # Build category list based on platform
    CATEGORIES=()
    $IS_LINUX && CATEGORIES+=("🖥️  Desktop / Window Manager")
    CATEGORIES+=("🌐 Browsers")
    CATEGORIES+=("💬 Chat & Messaging")
    CATEGORIES+=("🎵 Multimedia")
    CATEGORIES+=("🛠️  Development Tools")
    CATEGORIES+=("📝 Notes & Office")
    CATEGORIES+=("📁 File Managers")
    CATEGORIES+=("🔧 Utilities")
    $IS_LINUX && CATEGORIES+=("🎮 Gaming")
    CATEGORIES+=("🤖 AI & Local LLMs")
    $IS_LINUX && CATEGORIES+=("📦 Dotfiles")
    $IS_LINUX && CATEGORIES+=("⚙️  System Options")
    $IS_LINUX && CATEGORIES+=("🔒 Security & Hardening")

    CAT_OPTS=$(gum_choose_multi "  Select categories to customize" "${CATEGORIES[@]}")

    # ── Window Manager (Linux only) ──────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Window Manager"* ]] && $IS_LINUX; then
        INSTALL_NIRI=false; INSTALL_GNOME=false; INSTALL_I3=false
        WM_OPTS=$(gum_choose_multi "  Desktop / Window Manager" \
            "Niri  (Wayland tiling — recommended)" \
            "GNOME  (full desktop)" \
            "i3 + bspwm  (X11 tiling)")
        [[ "$WM_OPTS" == *"Niri"*  ]] && INSTALL_NIRI=true
        [[ "$WM_OPTS" == *"GNOME"* ]] && INSTALL_GNOME=true
        [[ "$WM_OPTS" == *"i3"*    ]] && INSTALL_I3=true
    fi

    # ── Browsers ─────────────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Browsers"* ]]; then
        BR_ZEN=false; BR_FLOORP=false; BR_BRAVE=false; BR_FIREFOX=false; BR_EDGE=false
        BR_CHROME=false; BR_LIBREWOLF=false; BR_VIVALDI=false; BR_CHROMIUM=false; BR_TOR=false
        BR_OPTS=$(gum_choose_multi "  Browsers  (pick any)" \
            "Zen Browser        — Firefox-based, privacy" \
            "Firefox            — Mozilla's browser" \
            "Google Chrome      — Google's browser" \
            "Brave              — Chromium + ad-block" \
            "Floorp             — Firefox-based, customizable" \
            "Microsoft Edge     — Chromium-based" \
            "Librewolf          — Hardened Firefox fork" \
            "Vivaldi            — Feature-rich Chromium" \
            "Chromium           — Open-source Chrome" \
            "Tor Browser        — Anonymous browsing")
        [[ "$BR_OPTS" == *"Zen"*       ]] && BR_ZEN=true
        [[ "$BR_OPTS" == *"Firefox"*   ]] && BR_FIREFOX=true
        [[ "$BR_OPTS" == *"Chrome"*    ]] && BR_CHROME=true
        [[ "$BR_OPTS" == *"Brave"*     ]] && BR_BRAVE=true
        [[ "$BR_OPTS" == *"Floorp"*    ]] && BR_FLOORP=true
        [[ "$BR_OPTS" == *"Edge"*      ]] && BR_EDGE=true
        [[ "$BR_OPTS" == *"Librewolf"* ]] && BR_LIBREWOLF=true
        [[ "$BR_OPTS" == *"Vivaldi"*   ]] && BR_VIVALDI=true
        [[ "$BR_OPTS" == *"Chromium"*  ]] && BR_CHROMIUM=true
        [[ "$BR_OPTS" == *"Tor"*       ]] && BR_TOR=true
    fi

    # ── Chat & Messaging ────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Chat"* ]]; then
        CHAT_TELEGRAM=false; CHAT_FERDIUM=false; CHAT_DISCORD=false; CHAT_VESKTOP=false
        CHAT_SIGNAL=false; CHAT_SLACK=false; CHAT_ELEMENT=false; CHAT_THUNDERBIRD=false
        CHAT_OPTS=$(gum_choose_multi "  Chat & Messaging" \
            "Discord            — Gaming/communities" \
            "Vesktop            — Better Discord client" \
            "Telegram Desktop   — Telegram messenger" \
            "Signal             — Encrypted messenger" \
            "Slack              — Team communication" \
            "Element            — Matrix client (decentralized)" \
            "Ferdium            — All-in-one messenger hub" \
            "Thunderbird        — Email client")
        [[ "$CHAT_OPTS" == *"Discord"*     ]] && CHAT_DISCORD=true
        [[ "$CHAT_OPTS" == *"Vesktop"*     ]] && CHAT_VESKTOP=true
        [[ "$CHAT_OPTS" == *"Telegram"*    ]] && CHAT_TELEGRAM=true
        [[ "$CHAT_OPTS" == *"Signal"*      ]] && CHAT_SIGNAL=true
        [[ "$CHAT_OPTS" == *"Slack"*       ]] && CHAT_SLACK=true
        [[ "$CHAT_OPTS" == *"Element"*     ]] && CHAT_ELEMENT=true
        [[ "$CHAT_OPTS" == *"Ferdium"*     ]] && CHAT_FERDIUM=true
        [[ "$CHAT_OPTS" == *"Thunderbird"* ]] && CHAT_THUNDERBIRD=true
    fi

    # ── Multimedia ───────────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Multimedia"* ]]; then
        MEDIA_MPV=false; MEDIA_VLC=false; MEDIA_YTDLP=false; MEDIA_PARABOLIC=false
        MEDIA_CELLULOID=false; MEDIA_OBS=false; MEDIA_KDENLIVE=false; MEDIA_AUDACITY=false
        MEDIA_HANDBRAKE=false; MEDIA_SPOTIFY=false; MEDIA_FREETUBE=false; MEDIA_AMBEROL=false
        MEDIA_OPTS=$(gum_choose_multi "  Multimedia" \
            "mpv                — Lightweight video player" \
            "VLC                — Universal media player" \
            "yt-dlp             — Video downloader (CLI)" \
            "Spotify            — Music streaming" \
            "OBS Studio         — Screen recording/streaming" \
            "Kdenlive           — Video editor" \
            "Audacity           — Audio editor" \
            "Handbrake          — Video transcoder" \
            "Celluloid          — GTK+ frontend for mpv" \
            "Parabolic          — GUI video downloader" \
            "Freetube           — Private YouTube client" \
            "Amberol            — Simple music player")
        [[ "$MEDIA_OPTS" == *"mpv"*       ]] && MEDIA_MPV=true
        [[ "$MEDIA_OPTS" == *"VLC"*       ]] && MEDIA_VLC=true
        [[ "$MEDIA_OPTS" == *"yt-dlp"*    ]] && MEDIA_YTDLP=true
        [[ "$MEDIA_OPTS" == *"Spotify"*   ]] && MEDIA_SPOTIFY=true
        [[ "$MEDIA_OPTS" == *"OBS"*       ]] && MEDIA_OBS=true
        [[ "$MEDIA_OPTS" == *"Kdenlive"*  ]] && MEDIA_KDENLIVE=true
        [[ "$MEDIA_OPTS" == *"Audacity"*  ]] && MEDIA_AUDACITY=true
        [[ "$MEDIA_OPTS" == *"Handbrake"* ]] && MEDIA_HANDBRAKE=true
        [[ "$MEDIA_OPTS" == *"Celluloid"* ]] && MEDIA_CELLULOID=true
        [[ "$MEDIA_OPTS" == *"Parabolic"* ]] && MEDIA_PARABOLIC=true
        [[ "$MEDIA_OPTS" == *"Freetube"*  ]] && MEDIA_FREETUBE=true
        [[ "$MEDIA_OPTS" == *"Amberol"*   ]] && MEDIA_AMBEROL=true
    fi

    # ── Development Tools ────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Development"* ]]; then
        DEV_NEOVIM=false; DEV_VSCODE=false; DEV_DOCKER=false; DEV_NODE=false; DEV_PYTHON=false
        DEV_ANDROID=false; DEV_ZED=false; DEV_HELIX=false; DEV_GO=false; DEV_RUST=false
        DEV_GH=false; DEV_LAZYGIT=false; DEV_POSTMAN=false; DEV_DBEAVER=false
        DEV_OPTS=$(gum_choose_multi "  Development Tools" \
            "Neovim             — Terminal editor" \
            "VSCode             — GUI editor" \
            "Zed                — Fast collaborative editor" \
            "Helix              — Modal terminal editor" \
            "Docker + Compose   — Containers" \
            "Node.js + npm      — JavaScript runtime" \
            "Python + pip       — Python runtime" \
            "Go                 — Go programming language" \
            "Rust (rustup)      — Rust toolchain" \
            "GitHub CLI (gh)    — GitHub from terminal" \
            "lazygit            — Terminal git UI" \
            "Postman            — API testing" \
            "DBeaver            — Database client" \
            "Android SDK + scrcpy — Mobile dev")
        [[ "$DEV_OPTS" == *"Neovim"*   ]] && DEV_NEOVIM=true
        [[ "$DEV_OPTS" == *"VSCode"*   ]] && DEV_VSCODE=true
        [[ "$DEV_OPTS" == *"Zed"*      ]] && DEV_ZED=true
        [[ "$DEV_OPTS" == *"Helix"*    ]] && DEV_HELIX=true
        [[ "$DEV_OPTS" == *"Docker"*   ]] && DEV_DOCKER=true
        [[ "$DEV_OPTS" == *"Node"*     ]] && DEV_NODE=true
        [[ "$DEV_OPTS" == *"Python"*   ]] && DEV_PYTHON=true
        [[ "$DEV_OPTS" == *"Go "* || "$DEV_OPTS" == *"Go"$'\n'* ]] && DEV_GO=true
        [[ "$DEV_OPTS" == *"Rust"*     ]] && DEV_RUST=true
        [[ "$DEV_OPTS" == *"GitHub"*   ]] && DEV_GH=true
        [[ "$DEV_OPTS" == *"lazygit"*  ]] && DEV_LAZYGIT=true
        [[ "$DEV_OPTS" == *"Postman"*  ]] && DEV_POSTMAN=true
        [[ "$DEV_OPTS" == *"DBeaver"*  ]] && DEV_DBEAVER=true
        [[ "$DEV_OPTS" == *"Android"*  ]] && DEV_ANDROID=true
    fi

    # ── Notes & Office ───────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Notes"* ]]; then
        NOTES_OBSIDIAN=false; NOTES_LOGSEQ=false; NOTES_LIBREOFFICE=false; NOTES_ONLYOFFICE=false
        NOTES_ZATHURA=false; NOTES_OKULAR=false; NOTES_MARKER=false
        NOTES_OPTS=$(gum_choose_multi "  Notes & Office" \
            "Obsidian           — Markdown knowledge base" \
            "Logseq             — Outline-based notes" \
            "LibreOffice        — Full office suite" \
            "ONLYOFFICE         — MS Office compatible" \
            "Zathura            — Minimal PDF viewer" \
            "Okular             — Feature-rich PDF viewer" \
            "Marker             — Markdown editor")
        [[ "$NOTES_OPTS" == *"Obsidian"*     ]] && NOTES_OBSIDIAN=true
        [[ "$NOTES_OPTS" == *"Logseq"*       ]] && NOTES_LOGSEQ=true
        [[ "$NOTES_OPTS" == *"LibreOffice"*  ]] && NOTES_LIBREOFFICE=true
        [[ "$NOTES_OPTS" == *"ONLYOFFICE"*   ]] && NOTES_ONLYOFFICE=true
        [[ "$NOTES_OPTS" == *"Zathura"*      ]] && NOTES_ZATHURA=true
        [[ "$NOTES_OPTS" == *"Okular"*       ]] && NOTES_OKULAR=true
        [[ "$NOTES_OPTS" == *"Marker"*       ]] && NOTES_MARKER=true
    fi

    # ── File Managers ────────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"File Managers"* ]]; then
        FM_NAUTILUS=false; FM_NEMO=false; FM_THUNAR=false; FM_PCMANFM=false
        FM_OPTS=$(gum_choose_multi "  File Managers" \
            "Nautilus           — GNOME default" \
            "Nemo               — Cinnamon default" \
            "Thunar             — XFCE default" \
            "PCManFM            — LXDE default")
        [[ "$FM_OPTS" == *"Nautilus"* ]] && FM_NAUTILUS=true
        [[ "$FM_OPTS" == *"Nemo"*     ]] && FM_NEMO=true
        [[ "$FM_OPTS" == *"Thunar"*   ]] && FM_THUNAR=true
        [[ "$FM_OPTS" == *"PCManFM"*  ]] && FM_PCMANFM=true
    fi

    # ── Utilities ────────────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Utilities"* ]]; then
        UTIL_BTOP=false; UTIL_HTOP=false; UTIL_NVTOP=false; UTIL_GLANCES=false; UTIL_FILE_ROLLER=false; UTIL_UNRAR=false; UTIL_UNZIP=false; UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=false
        UTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_KEEPASSXC=false; UTIL_BITWARDEN=false
        UTIL_SYNCTHING=false; UTIL_FLAMESHOT=false; UTIL_COPYQ=false; UTIL_VENTOY=false
        UTIL_BAOBAB=false; UTIL_GNOME_DISKS=false
        UTIL_OPTS=$(gum_choose_multi "  Utilities" \
            "btop               — Resource monitor (TUI)" \
            "htop               — Classic resource monitor" \
            "nvtop              — GPU monitor" \
            "glances            — Advanced system monitor" \
            "file-roller        — Archive manager (GUI)" \
            "unrar              — RAR extractor (CLI)" \
            "unzip              — ZIP extractor (CLI)" \
            "Mission Center     — Resource monitor (GUI)" \
            "Meld               — Diff & merge tool" \
            "LocalSend          — Cross-device file sharing" \
            "KeePassXC          — Password manager (local)" \
            "Bitwarden          — Password manager (cloud)" \
            "Syncthing          — File synchronization" \
            "Flameshot          — Screenshot tool" \
            "CopyQ              — Clipboard manager" \
            "Helvum             — Audio patchbay (PipeWire)" \
            "Timeshift          — System backup/restore" \
            "Ventoy             — Bootable USB creator" \
            "Baobab             — Disk usage analyzer" \
            "GNOME Disks        — Disk management")
        [[ "$UTIL_OPTS" == *"btop"*        ]] && UTIL_BTOP=true
        [[ "$UTIL_OPTS" == *"htop"*        ]] && UTIL_HTOP=true
        [[ "$UTIL_OPTS" == *"nvtop"*       ]] && UTIL_NVTOP=true
        [[ "$UTIL_OPTS" == *"glances"*     ]] && UTIL_GLANCES=true
        [[ "$UTIL_OPTS" == *"file-roller"* ]] && UTIL_FILE_ROLLER=true
        [[ "$UTIL_OPTS" == *"unrar"*       ]] && UTIL_UNRAR=true
        [[ "$UTIL_OPTS" == *"unzip"*       ]] && UTIL_UNZIP=true
        [[ "$UTIL_OPTS" == *"Mission"*     ]] && UTIL_MISSION=true
        [[ "$UTIL_OPTS" == *"Meld"*        ]] && UTIL_MELD=true
        [[ "$UTIL_OPTS" == *"LocalSend"*   ]] && UTIL_LOCALSEND=true
        [[ "$UTIL_OPTS" == *"KeePassXC"*   ]] && UTIL_KEEPASSXC=true
        [[ "$UTIL_OPTS" == *"Bitwarden"*   ]] && UTIL_BITWARDEN=true
        [[ "$UTIL_OPTS" == *"Syncthing"*   ]] && UTIL_SYNCTHING=true
        [[ "$UTIL_OPTS" == *"Flameshot"*   ]] && UTIL_FLAMESHOT=true
        [[ "$UTIL_OPTS" == *"CopyQ"*       ]] && UTIL_COPYQ=true
        [[ "$UTIL_OPTS" == *"Helvum"*      ]] && UTIL_HELVUM=true
        [[ "$UTIL_OPTS" == *"Timeshift"*   ]] && UTIL_TIMESHIFT=true
        [[ "$UTIL_OPTS" == *"Ventoy"*      ]] && UTIL_VENTOY=true
        [[ "$UTIL_OPTS" == *"Baobab"*      ]] && UTIL_BAOBAB=true
        [[ "$UTIL_OPTS" == *"GNOME Disks"* ]] && UTIL_GNOME_DISKS=true
    fi

    # ── Gaming (Linux only) ──────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Gaming"* ]] && $IS_LINUX; then
        GAME_STEAM=false; GAME_LUTRIS=false; GAME_HEROIC=false
        GAME_GAMEMODE=false; GAME_MANGOHUD=false; GAME_PROTONUP=false
        GAME_OPTS=$(gum_choose_multi "  Gaming" \
            "Steam              — Valve's game store" \
            "Lutris             — Game manager (Wine/Proton)" \
            "Heroic Launcher    — Epic/GOG/Amazon games" \
            "Gamemode           — CPU/GPU game optimizer" \
            "MangoHud           — FPS overlay" \
            "ProtonUp-Qt        — Proton version manager")
        [[ "$GAME_OPTS" == *"Steam"*     ]] && GAME_STEAM=true
        [[ "$GAME_OPTS" == *"Lutris"*    ]] && GAME_LUTRIS=true
        [[ "$GAME_OPTS" == *"Heroic"*    ]] && GAME_HEROIC=true
        [[ "$GAME_OPTS" == *"Gamemode"*  ]] && GAME_GAMEMODE=true
        [[ "$GAME_OPTS" == *"MangoHud"*  ]] && GAME_MANGOHUD=true
        [[ "$GAME_OPTS" == *"ProtonUp"*  ]] && GAME_PROTONUP=true
    fi

    # ── AI & Local LLMs ──────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"AI"* ]]; then
        AI_ANYLLM=false; AI_LMSTUDIO=false; AI_PINOKIO=false
        AI_OLLAMA=false; AI_OPENWEBUI=false; AI_JAN=false
        AI_OPTS=$(gum_choose_multi "  AI & Local LLMs" \
            "Ollama             — Local LLM server" \
            "Open WebUI         — Chat UI for Ollama" \
            "Jan                — Offline AI assistant" \
            "AnythingLLM        — Local AI workspace (AppImage)" \
            "LM Studio          — Local LLM runner (AppImage)" \
            "Pinokio            — AI app browser (AppImage)")
        [[ "$AI_OPTS" == *"Ollama"*       ]] && AI_OLLAMA=true
        [[ "$AI_OPTS" == *"Open WebUI"*   ]] && AI_OPENWEBUI=true
        [[ "$AI_OPTS" == *"Jan"*          ]] && AI_JAN=true
        [[ "$AI_OPTS" == *"AnythingLLM"*  ]] && AI_ANYLLM=true
        [[ "$AI_OPTS" == *"LM Studio"*    ]] && AI_LMSTUDIO=true
        [[ "$AI_OPTS" == *"Pinokio"*      ]] && AI_PINOKIO=true
    fi

    # ── Dotfiles (Linux only — macOS gets cross-platform subset auto) ────────
    if [[ "$CAT_OPTS" == *"Dotfiles"* ]] && $IS_LINUX; then
        DOT_NIRI=false; DOT_WAYBAR=false; DOT_FISH=false; DOT_KITTY=false
        DOT_GHOSTTY=false; DOT_ALACRITTY=false; DOT_NVIM=false; DOT_BTOP=false
        DOT_FUZZEL=false; DOT_DUNST=false; DOT_GTK=false; DOT_ZATHURA=false
        DOT_MPV=false; DOT_RANGER=false; DOT_NOCTALIA=false; DOT_FASTFETCH=false
        DOT_APPIMAGELAUNCHER=false
        DOT_OPTS=$(gum_choose_multi "  Dotfiles  (configs to stow into ~)" \
            "niri               — WM config + keybinds" \
            "waybar             — Status bar" \
            "fish               — Shell config + aliases" \
            "kitty              — Terminal emulator" \
            "ghostty            — Terminal emulator" \
            "alacritty          — Terminal emulator" \
            "neovim             — Editor config" \
            "btop               — Monitor theme" \
            "fuzzel             — App launcher" \
            "dunst              — Notifications" \
            "gtk                — GTK3/4 themes" \
            "zathura            — PDF viewer" \
            "mpv                — Media player" \
            "ranger             — File manager" \
            "noctalia           — Noctalia shell" \
            "fastfetch          — System info" \
            "appimagelauncher   — AppImage config")
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

    # ── System Options (Linux only) ──────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"System Options"* ]] && $IS_LINUX; then
        INSTALL_CHAOTIC=false; SYS_SSH=false; SYS_DOCKER_BOOT=false; SYS_FISH_DEFAULT=false
        SYS_OPTS=$(gum_choose_multi "  System Options" \
            "Chaotic-AUR / RPM Fusion  (pre-built community packages)" \
            "Enable SSH server" \
            "Enable Docker on boot" \
            "Set fish as default shell")
        [[ "$SYS_OPTS" == *"Chaotic"* ]] && INSTALL_CHAOTIC=true
        [[ "$SYS_OPTS" == *"SSH"*     ]] && SYS_SSH=true
        [[ "$SYS_OPTS" == *"Docker"*  ]] && SYS_DOCKER_BOOT=true
        [[ "$SYS_OPTS" == *"fish"*    ]] && SYS_FISH_DEFAULT=true
    fi

    # ── Security & Hardening (Linux only) ────────────────────────────────────
    if [[ "$CAT_OPTS" == *"Security"* ]] && $IS_LINUX; then
        SEC_FAIL2BAN=false; SEC_SSH_HARDEN=false; SEC_DNSSEC=false; SEC_AUTO_UPDATE=false
        SEC_OPTS=$(gum_choose_multi "  Security & Hardening" \
            "fail2ban           — Ban brute-force IPs" \
            "Harden SSH         — Disable root login, key-only auth" \
            "Enable DNSSEC      — DNS security via systemd-resolved" \
            "Auto security updates  (paccache/unattended-upgrades/dnf-automatic)")
        [[ "$SEC_OPTS" == *"fail2ban"*   ]] && SEC_FAIL2BAN=true
        [[ "$SEC_OPTS" == *"Harden"*     ]] && SEC_SSH_HARDEN=true
        [[ "$SEC_OPTS" == *"DNSSEC"*     ]] && SEC_DNSSEC=true
        [[ "$SEC_OPTS" == *"Auto"*       ]] && SEC_AUTO_UPDATE=true
    fi
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
gum_header "Review Your Selection"

# Build summary table
make_row() { $1 && echo -e "  ${GREEN}✓${RESET} $2" || true; }

if $IS_LINUX; then
    echo -e "${BOLD}  Window Manager${RESET}"
    make_row $INSTALL_NIRI "Niri/Wayland"; make_row $INSTALL_GNOME "GNOME"; make_row $INSTALL_I3 "i3/bspwm"
fi

echo -e "\n${BOLD}  Browsers${RESET}"
make_row $BR_ZEN "Zen"; make_row $BR_FIREFOX "Firefox"; make_row $BR_CHROME "Chrome"
make_row $BR_BRAVE "Brave"; make_row $BR_FLOORP "Floorp"; make_row $BR_EDGE "Edge"
make_row $BR_LIBREWOLF "Librewolf"; make_row $BR_VIVALDI "Vivaldi"
make_row $BR_CHROMIUM "Chromium"; make_row $BR_TOR "Tor Browser"

echo -e "\n${BOLD}  Chat & Messaging${RESET}"
make_row $CHAT_DISCORD "Discord"; make_row $CHAT_VESKTOP "Vesktop"
make_row $CHAT_TELEGRAM "Telegram"; make_row $CHAT_SIGNAL "Signal"
make_row $CHAT_SLACK "Slack"; make_row $CHAT_ELEMENT "Element"
make_row $CHAT_FERDIUM "Ferdium"; make_row $CHAT_THUNDERBIRD "Thunderbird"

echo -e "\n${BOLD}  Multimedia${RESET}"
make_row $MEDIA_MPV "mpv"; make_row $MEDIA_VLC "VLC"; make_row $MEDIA_YTDLP "yt-dlp"
make_row $MEDIA_SPOTIFY "Spotify"; make_row $MEDIA_OBS "OBS Studio"
make_row $MEDIA_KDENLIVE "Kdenlive"; make_row $MEDIA_AUDACITY "Audacity"
make_row $MEDIA_HANDBRAKE "Handbrake"; make_row $MEDIA_CELLULOID "Celluloid"
make_row $MEDIA_PARABOLIC "Parabolic"; make_row $MEDIA_FREETUBE "Freetube"
make_row $MEDIA_AMBEROL "Amberol"

echo -e "\n${BOLD}  Development${RESET}"
make_row $DEV_NEOVIM "Neovim"; make_row $DEV_VSCODE "VSCode"; make_row $DEV_ZED "Zed"
make_row $DEV_HELIX "Helix"; make_row $DEV_DOCKER "Docker"; make_row $DEV_NODE "Node.js"
make_row $DEV_PYTHON "Python"; make_row $DEV_GO "Go"; make_row $DEV_RUST "Rust"
make_row $DEV_GH "GitHub CLI"; make_row $DEV_LAZYGIT "lazygit"
make_row $DEV_POSTMAN "Postman"; make_row $DEV_DBEAVER "DBeaver"
make_row $DEV_ANDROID "Android SDK"

echo -e "\n${BOLD}  Notes & Office${RESET}"
make_row $NOTES_OBSIDIAN "Obsidian"; make_row $NOTES_LOGSEQ "Logseq"
make_row $NOTES_LIBREOFFICE "LibreOffice"; make_row $NOTES_ONLYOFFICE "ONLYOFFICE"
make_row $NOTES_ZATHURA "Zathura"; make_row $NOTES_OKULAR "Okular"
make_row $NOTES_MARKER "Marker"

echo -e "\n${BOLD}  File Managers${RESET}"
make_row $FM_NAUTILUS "Nautilus"; make_row $FM_NEMO "Nemo"
make_row $FM_THUNAR "Thunar"; make_row $FM_PCMANFM "PCManFM"

echo -e "\n${BOLD}  Utilities${RESET}"
make_row $UTIL_BTOP "btop"; make_row $UTIL_HTOP "htop"; make_row $UTIL_NVTOP "nvtop"; make_row $UTIL_GLANCES "glances"
make_row $UTIL_FILE_ROLLER "file-roller"; make_row $UTIL_UNRAR "unrar"; make_row $UTIL_UNZIP "unzip"
make_row $UTIL_MISSION "Mission Center"
make_row $UTIL_MELD "Meld"; make_row $UTIL_LOCALSEND "LocalSend"
make_row $UTIL_KEEPASSXC "KeePassXC"; make_row $UTIL_BITWARDEN "Bitwarden"
make_row $UTIL_SYNCTHING "Syncthing"; make_row $UTIL_FLAMESHOT "Flameshot"
make_row $UTIL_COPYQ "CopyQ"; make_row $UTIL_HELVUM "Helvum"
make_row $UTIL_TIMESHIFT "Timeshift"; make_row $UTIL_VENTOY "Ventoy"
make_row $UTIL_BAOBAB "Baobab"; make_row $UTIL_GNOME_DISKS "GNOME Disks"

if $IS_LINUX; then
    echo -e "\n${BOLD}  Gaming${RESET}"
    make_row $GAME_STEAM "Steam"; make_row $GAME_LUTRIS "Lutris"
    make_row $GAME_HEROIC "Heroic"; make_row $GAME_GAMEMODE "Gamemode"
    make_row $GAME_MANGOHUD "MangoHud"; make_row $GAME_PROTONUP "ProtonUp-Qt"
fi

echo -e "\n${BOLD}  AI & LLMs${RESET}"
make_row $AI_OLLAMA "Ollama"; make_row $AI_OPENWEBUI "Open WebUI"
make_row $AI_JAN "Jan"; make_row $AI_ANYLLM "AnythingLLM"
make_row $AI_LMSTUDIO "LM Studio"; make_row $AI_PINOKIO "Pinokio"

if $IS_LINUX; then
    echo -e "\n${BOLD}  Dotfiles${RESET}"
    for d in niri waybar fish kitty ghostty alacritty nvim btop fuzzel dunst gtk zathura mpv ranger noctalia fastfetch appimagelauncher; do
        varname="DOT_${d^^}"
        varname="${varname//-/_}"
        ${!varname} && echo -e "  ${GREEN}✓${RESET} $d" || true
    done

    echo -e "\n${BOLD}  Security${RESET}"
    make_row $SEC_FAIL2BAN "fail2ban"; make_row $SEC_SSH_HARDEN "SSH hardening"
    make_row $SEC_DNSSEC "DNSSEC"; make_row $SEC_AUTO_UPDATE "Auto updates"
fi

echo ""
gum_confirm "Everything look good? Start the installation?" || { warn "Aborted."; exit 0; }

# ═══════════════════════════════════════════════════════════════════════════════
#  INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Phase 2: System Setup (Linux only) ──────────────────────────────────────
if $IS_LINUX; then
    gum_header "2  ·  System Setup"
    case "$OS" in
        arch)
            gum_spin "Ranking mirrors with reflector..." \
                sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
            success "Mirrors updated"
            gum_spin "Syncing package databases..." sudo pacman -Sy
            ;;
        ubuntu)
            gum_spin "Updating package lists..." sudo apt-get update
            ;;
        fedora)
            gum_spin "Updating package metadata..." sudo dnf check-update || true
            ;;
    esac
    success "Package DB synced"
fi

# ─── Phase 3: Community Repos ─────────────────────────────────────────────────
if $INSTALL_CHAOTIC && $IS_LINUX; then
    gum_header "3  ·  Community Repositories"
    case "$OS" in
        arch)
            gum_spin "Setting up Chaotic-AUR..." bash "$SCRIPT_DIR/scripts/setup-chaotic-aur.sh"
            success "Chaotic-AUR ready"
            ;;
        fedora)
            gum_spin "Enabling RPM Fusion (free + nonfree)..." bash -c "
                sudo dnf install -y \
                    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-\$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-\$(rpm -E %fedora).noarch.rpm
            "
            success "RPM Fusion enabled"
            ;;
        ubuntu)
            gum_spin "Installing restricted extras..." \
                sudo apt-get install -y ubuntu-restricted-extras
            success "Restricted extras installed"
            ;;
    esac
fi

# ─── Phase 4: AUR Helper / Flatpak Setup ─────────────────────────────────────
if $IS_LINUX; then
    gum_header "4  ·  Package Sources"

    # Flatpak (all Linux distros)
    if ! check_cmd flatpak; then
        case "$OS" in
            arch)   gum_spin "Installing flatpak..." sudo pacman -S --noconfirm flatpak ;;
            ubuntu) gum_spin "Installing flatpak..." sudo apt-get install -y flatpak ;;
            fedora) success "Flatpak pre-installed on Fedora" ;;
        esac
    fi
    if check_cmd flatpak; then
        gum_spin "Adding Flathub remote..." \
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        success "Flathub ready"
    fi

    # AUR helper (Arch only)
    if [[ "$OS" == "arch" ]]; then
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
    fi
fi

# ─── Phase 5: Packages ────────────────────────────────────────────────────────
gum_header "5  ·  Installing Packages"

# Core packages (Arch only — Ubuntu/Fedora have their own base)
if [[ "$OS" == "arch" ]]; then
    mapfile -t CORE_PKGS < <(grep -v '^\s*#' "$SCRIPT_DIR/packages/pkglist-core.txt" | grep -v '^\s*$')
    gum_spin "Installing ${#CORE_PKGS[@]} core packages..." \
        sudo pacman -S --noconfirm --needed "${CORE_PKGS[@]}"
    success "Core packages installed"
elif [[ "$OS" == "ubuntu" ]]; then
    gum_spin "Installing core utilities..." \
        sudo apt-get install -y git curl wget rsync build-essential software-properties-common \
        apt-transport-https ca-certificates gnupg lsb-release flatpak stow
    success "Core packages installed"
elif [[ "$OS" == "fedora" ]]; then
    gum_spin "Installing core utilities..." \
        sudo dnf install -y git curl wget rsync @development-tools flatpak stow \
        dnf-plugins-core
    success "Core packages installed"
elif [[ "$OS" == "macos" ]]; then
    gum_spin "Installing core utilities..." \
        brew install git curl wget rsync stow coreutils
    success "Core packages installed"
fi

# WM (Linux only)
if $IS_LINUX; then
    $INSTALL_NIRI && {
        if [[ "$OS" == "arch" ]]; then
            gum_spin "Installing Niri/Wayland stack..." \
                sudo pacman -S --noconfirm --needed niri waybar fuzzel swaybg swaylock \
                wl-clipboard cliphist grim slurp mako xdg-desktop-portal \
                xdg-desktop-portal-gnome xdg-desktop-portal-gtk polkit-gnome \
                xwayland xorg-xwayland xorg-xrandr
        else
            smart_install "niri" "Niri" 2>/dev/null || warn "Niri not available on $OS — Wayland WM may need manual setup"
        fi
        success "Niri stack installed"
    }
    $INSTALL_GNOME && { smart_install "gnome-shell" "GNOME" || true; success "GNOME installed"; }
    $INSTALL_I3    && { smart_install "i3-wm" "i3"          || true; success "i3 installed"; }
fi

# Browsers
$BR_ZEN       && { smart_install "zen-browser" "Zen Browser";     success "Zen installed"; }
$BR_FIREFOX   && { smart_install "firefox" "Firefox";             success "Firefox installed"; }
$BR_CHROME    && { smart_install "google-chrome" "Google Chrome"; success "Chrome installed"; }
$BR_BRAVE     && { smart_install "brave" "Brave";                 success "Brave installed"; }
$BR_FLOORP    && { smart_install "floorp" "Floorp";               success "Floorp installed"; }
$BR_EDGE      && { smart_install "microsoft-edge" "Edge";         success "Edge installed"; }
$BR_LIBREWOLF && { smart_install "librewolf" "Librewolf";         success "Librewolf installed"; }
$BR_VIVALDI   && { smart_install "vivaldi" "Vivaldi";             success "Vivaldi installed"; }
$BR_CHROMIUM  && { smart_install "chromium" "Chromium";           success "Chromium installed"; }
$BR_TOR       && { smart_install "tor-browser" "Tor Browser";     success "Tor Browser installed"; }

# Chat
$CHAT_DISCORD     && { smart_install "discord" "Discord";           success "Discord installed"; }
$CHAT_VESKTOP     && { smart_install "vesktop" "Vesktop";           success "Vesktop installed"; }
$CHAT_TELEGRAM    && { smart_install "telegram" "Telegram";         success "Telegram installed"; }
$CHAT_SIGNAL      && { smart_install "signal" "Signal";             success "Signal installed"; }
$CHAT_SLACK       && { smart_install "slack" "Slack";               success "Slack installed"; }
$CHAT_ELEMENT     && { smart_install "element" "Element";           success "Element installed"; }
$CHAT_FERDIUM     && { smart_install "ferdium" "Ferdium";           success "Ferdium installed"; }
$CHAT_THUNDERBIRD && { smart_install "thunderbird" "Thunderbird";   success "Thunderbird installed"; }

# Multimedia
$MEDIA_MPV       && { smart_install "mpv" "mpv";             success "mpv installed"; }
$MEDIA_VLC       && { smart_install "vlc" "VLC";             success "VLC installed"; }
$MEDIA_YTDLP     && { smart_install "yt-dlp" "yt-dlp";      success "yt-dlp installed"; }
$MEDIA_SPOTIFY   && { smart_install "spotify" "Spotify";     success "Spotify installed"; }
$MEDIA_OBS       && { smart_install "obs-studio" "OBS";      success "OBS installed"; }
$MEDIA_KDENLIVE  && { smart_install "kdenlive" "Kdenlive";   success "Kdenlive installed"; }
$MEDIA_AUDACITY  && { smart_install "audacity" "Audacity";   success "Audacity installed"; }
$MEDIA_HANDBRAKE && { smart_install "handbrake" "Handbrake"; success "Handbrake installed"; }
$MEDIA_CELLULOID && { smart_install "celluloid" "Celluloid"; success "Celluloid installed"; }
$MEDIA_PARABOLIC && { smart_install "parabolic" "Parabolic"; success "Parabolic installed"; }
$MEDIA_FREETUBE  && { smart_install "freetube" "Freetube";   success "Freetube installed"; }
$MEDIA_AMBEROL   && { smart_install "amberol" "Amberol";     success "Amberol installed"; }

# Codecs (Linux only)
if $IS_LINUX && ($MEDIA_MPV || $MEDIA_VLC); then
    case "$OS" in
        arch)   gum_spin "Installing multimedia codecs..." sudo pacman -S --noconfirm --needed \
                    gst-libav gst-plugin-va gst-plugins-bad gst-plugins-ugly libdvdcss ;;
        ubuntu) gum_spin "Installing multimedia codecs..." sudo apt-get install -y \
                    gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
                    gstreamer1.0-vaapi libdvd-pkg ;;
        fedora) gum_spin "Installing multimedia codecs..." sudo dnf install -y \
                    gstreamer1-libav gstreamer1-plugins-bad-free gstreamer1-plugins-ugly ;;
    esac
    success "Codecs installed"
fi

# Development
$DEV_NEOVIM  && { smart_install "neovim" "Neovim";           success "Neovim installed"; }
$DEV_VSCODE  && { smart_install "vscode" "VSCode";           success "VSCode installed"; }
$DEV_ZED     && { smart_install "zed" "Zed";                 success "Zed installed"; }
$DEV_HELIX   && { smart_install "helix" "Helix";             success "Helix installed"; }
$DEV_DOCKER  && { smart_install "docker" "Docker";           success "Docker installed"; }
$DEV_NODE    && { smart_install "nodejs" "Node.js";          success "Node.js installed"; }
$DEV_PYTHON  && { smart_install "python" "Python";           success "Python installed"; }
$DEV_GO      && { smart_install "go" "Go";                   success "Go installed"; }
$DEV_RUST    && { smart_install "rustup" "Rust";             success "Rust installed"; }
$DEV_GH      && { smart_install "gh" "GitHub CLI";           success "GitHub CLI installed"; }
$DEV_LAZYGIT && { smart_install "lazygit" "lazygit";         success "lazygit installed"; }
$DEV_POSTMAN && { smart_install "postman" "Postman";         success "Postman installed"; }
$DEV_DBEAVER && { smart_install "dbeaver" "DBeaver";         success "DBeaver installed"; }
$DEV_ANDROID && {
    case "$OS" in
        arch)   gum_spin "Installing Android SDK..." sudo pacman -S --noconfirm --needed android-tools scrcpy
                aur_install android-sdk-cmdline-tools-latest ;;
        *)      smart_install "android-tools" "Android tools" ;;
    esac
    success "Android SDK installed"
}

# Notes & Office
$NOTES_OBSIDIAN    && { smart_install "obsidian" "Obsidian";         success "Obsidian installed"; }
$NOTES_LOGSEQ      && { smart_install "logseq" "Logseq";            success "Logseq installed"; }
$NOTES_LIBREOFFICE && { smart_install "libreoffice" "LibreOffice";   success "LibreOffice installed"; }
$NOTES_ONLYOFFICE  && { smart_install "onlyoffice" "ONLYOFFICE";     success "ONLYOFFICE installed"; }
$NOTES_ZATHURA     && { smart_install "zathura" "Zathura";           success "Zathura installed"; }
$NOTES_OKULAR      && { smart_install "okular" "Okular";             success "Okular installed"; }
$NOTES_MARKER      && { smart_install "marker" "Marker";             success "Marker installed"; }

# File Managers
$FM_NAUTILUS && { smart_install "nautilus" "Nautilus"; success "Nautilus installed"; }
$FM_NEMO     && { smart_install "nemo" "Nemo";         success "Nemo installed"; }
$FM_THUNAR   && { smart_install "thunar" "Thunar";     success "Thunar installed"; }
$FM_PCMANFM  && { smart_install "pcmanfm" "PCManFM";   success "PCManFM installed"; }

# Utilities
$UTIL_BTOP        && { smart_install "btop" "btop";                   success "btop installed"; }
$UTIL_HTOP        && { smart_install "htop" "htop";                   success "htop installed"; }
$UTIL_NVTOP       && { smart_install "nvtop" "nvtop";                 success "nvtop installed"; }
$UTIL_GLANCES     && { smart_install "glances" "glances";             success "glances installed"; }
$UTIL_FILE_ROLLER && { smart_install "file-roller" "file-roller";     success "file-roller installed"; }
$UTIL_UNRAR       && { smart_install "unrar" "unrar";                 success "unrar installed"; }
$UTIL_UNZIP       && { smart_install "unzip" "unzip";                 success "unzip installed"; }
$UTIL_MISSION     && { smart_install "mission-center" "Mission Center"; success "Mission Center installed"; }
$UTIL_MELD        && { smart_install "meld" "Meld";                   success "Meld installed"; }
$UTIL_LOCALSEND   && { smart_install "localsend" "LocalSend";         success "LocalSend installed"; }
$UTIL_KEEPASSXC   && { smart_install "keepassxc" "KeePassXC";         success "KeePassXC installed"; }
$UTIL_BITWARDEN   && { smart_install "bitwarden" "Bitwarden";         success "Bitwarden installed"; }
$UTIL_SYNCTHING   && { smart_install "syncthing" "Syncthing";         success "Syncthing installed"; }
$UTIL_FLAMESHOT   && { smart_install "flameshot" "Flameshot";         success "Flameshot installed"; }
$UTIL_COPYQ       && { smart_install "copyq" "CopyQ";                 success "CopyQ installed"; }
$UTIL_HELVUM      && { smart_install "helvum" "Helvum";               success "Helvum installed"; }
$UTIL_TIMESHIFT   && { smart_install "timeshift" "Timeshift";         success "Timeshift installed"; }
$UTIL_VENTOY      && { smart_install "ventoy" "Ventoy";               success "Ventoy installed"; }
$UTIL_BAOBAB      && { smart_install "baobab" "Baobab";               success "Baobab installed"; }
$UTIL_GNOME_DISKS && { smart_install "gnome-disk-utility" "GNOME Disks"; success "GNOME Disks installed"; }

# Gaming (Linux only)
if $IS_LINUX; then
    $GAME_STEAM    && { smart_install "steam" "Steam";       success "Steam installed"; }
    $GAME_LUTRIS   && { smart_install "lutris" "Lutris";     success "Lutris installed"; }
    $GAME_HEROIC   && { smart_install "heroic" "Heroic";     success "Heroic installed"; }
    $GAME_GAMEMODE && { smart_install "gamemode" "Gamemode"; success "Gamemode installed"; }
    $GAME_MANGOHUD && { smart_install "mangohud" "MangoHud"; success "MangoHud installed"; }
    $GAME_PROTONUP && { smart_install "protonup-qt" "ProtonUp-Qt"; success "ProtonUp-Qt installed"; }
fi

# AI & LLMs
$AI_OLLAMA    && { smart_install "ollama" "Ollama";   success "Ollama installed"; }
$AI_OPENWEBUI && {
    if $DEV_DOCKER || check_cmd docker; then
        gum_spin "Pulling Open WebUI container..." \
            docker pull ghcr.io/open-webui/open-webui:main
        success "Open WebUI ready (run: docker run -d -p 3000:8080 ghcr.io/open-webui/open-webui:main)"
    else
        warn "Open WebUI requires Docker — enable Docker first"
    fi
}
$AI_JAN && { smart_install "jan" "Jan"; success "Jan installed"; }

# Arch-specific extras (noctalia, antigravity, appimagelauncher)
if [[ "$OS" == "arch" ]]; then
    gum_spin "Installing noctalia-shell + appimagelauncher..." \
        yay -S --noconfirm --needed noctalia-shell antigravity appimagelauncher 2>/dev/null || true
    success "noctalia-shell + extras installed"
fi

# ─── Phase 6: Services (Linux only) ──────────────────────────────────────────
if $IS_LINUX; then
    gum_header "6  ·  Enabling Services"

    while IFS= read -r svc; do
        [[ -z "$svc" || "$svc" == \#* ]] && continue
        run sudo systemctl enable "$svc" && success "Enabled: $svc" || warn "Skipped: $svc"
    done < "$SCRIPT_DIR/system/services.txt"

    $SYS_SSH         && { run sudo systemctl enable sshd;                success "SSH enabled"; }
    $SYS_DOCKER_BOOT && { run sudo systemctl enable docker containerd;   success "Docker enabled on boot"; }
    $INSTALL_GNOME   && { run sudo systemctl enable gdm;                 success "GDM enabled"; }
    $AI_OLLAMA       && { run sudo systemctl enable ollama;              success "Ollama service enabled"; }
fi

# ─── Phase 7: Dotfiles ────────────────────────────────────────────────────────
gum_header "7  ·  Stowing Dotfiles"

check_cmd stow || {
    case "$OS" in
        arch)   gum_spin "Installing stow..." sudo pacman -S --noconfirm stow ;;
        ubuntu) gum_spin "Installing stow..." sudo apt-get install -y stow ;;
        fedora) gum_spin "Installing stow..." sudo dnf install -y stow ;;
        macos)  gum_spin "Installing stow..." brew install stow ;;
    esac
}

DOTS_DIR="$SCRIPT_DIR/dots"
stow_pkg() {
    local enabled="$1" pkg="$2"
    if $enabled; then
        if [[ -d "$DOTS_DIR/$pkg" ]]; then
            if run stow --dir="$DOTS_DIR" --target="$HOME" "$pkg"; then
                success "Stowed: $pkg"
            else
                warn "Conflict on $pkg — run: stow --adopt -d $DOTS_DIR -t \$HOME $pkg"
            fi
        else
            warn "Dotfile directory not found: $pkg"
        fi
    fi
}

# Linux-only dotfiles
if $IS_LINUX; then
    stow_pkg $DOT_NIRI            niri
    stow_pkg $DOT_WAYBAR          waybar
    stow_pkg $DOT_FUZZEL          fuzzel
    stow_pkg $DOT_DUNST           dunst
    stow_pkg $DOT_GTK             gtk
    stow_pkg $DOT_NOCTALIA        noctalia
    stow_pkg $DOT_APPIMAGELAUNCHER appimagelauncher
fi

# Cross-platform dotfiles
stow_pkg $DOT_FISH            fish
stow_pkg $DOT_KITTY           kitty
stow_pkg $DOT_GHOSTTY         ghostty
stow_pkg $DOT_ALACRITTY       alacritty
stow_pkg $DOT_NVIM            nvim
stow_pkg $DOT_BTOP            btop
stow_pkg $DOT_ZATHURA         zathura
stow_pkg $DOT_MPV             mpv
stow_pkg $DOT_RANGER          ranger
stow_pkg $DOT_FASTFETCH       fastfetch

# ─── Phase 8: AppImages (Linux only) ─────────────────────────────────────────
if $IS_LINUX; then
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
fi

# ─── Phase 9: Security & Hardening (Linux only) ──────────────────────────────
if $IS_LINUX; then
    SECURITY_APPLIED=false

    if $SEC_FAIL2BAN || $SEC_SSH_HARDEN || $SEC_DNSSEC || $SEC_AUTO_UPDATE; then
        gum_header "9  ·  Security & Hardening"
        SECURITY_APPLIED=true
    fi

    if $SEC_FAIL2BAN; then
        smart_install "fail2ban" "fail2ban"
        run sudo systemctl enable fail2ban
        success "fail2ban enabled"
    fi

    if $SEC_SSH_HARDEN; then
        SSHD_CONF="/etc/ssh/sshd_config"
        if [[ -f "$SSHD_CONF" ]]; then
            run sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONF"
            run sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONF"
            run sudo systemctl restart sshd 2>/dev/null || true
            success "SSH hardened: root login disabled, key-only auth"
        else
            warn "sshd_config not found — skipping SSH hardening"
        fi
    fi

    if $SEC_DNSSEC; then
        run sudo mkdir -p /etc/systemd/resolved.conf.d
        echo -e "[Resolve]\nDNSSEC=yes\nDNSOverTLS=yes" | \
            run sudo tee /etc/systemd/resolved.conf.d/dnssec.conf > /dev/null
        run sudo systemctl restart systemd-resolved 2>/dev/null || true
        success "DNSSEC + DNS-over-TLS enabled"
    fi

    if $SEC_AUTO_UPDATE; then
        case "$OS" in
            arch)
                run sudo systemctl enable paccache.timer
                success "paccache timer enabled (auto-cleanup old packages)"
                ;;
            ubuntu)
                gum_spin "Installing unattended-upgrades..." \
                    sudo apt-get install -y unattended-upgrades
                run sudo dpkg-reconfigure -plow unattended-upgrades
                success "Unattended security upgrades enabled"
                ;;
            fedora)
                gum_spin "Installing dnf-automatic..." \
                    sudo dnf install -y dnf-automatic
                run sudo systemctl enable dnf-automatic-install.timer
                success "DNF automatic updates enabled"
                ;;
        esac
    fi
fi

# ─── Phase 10: Post-Install ──────────────────────────────────────────────────
gum_header "10  ·  Post-Install"

bash "$SCRIPT_DIR/scripts/setup-git.sh"

if $DEV_DOCKER && $IS_LINUX; then
    bash "$SCRIPT_DIR/scripts/setup-docker.sh"
fi
if $DEV_ANDROID && [[ "$OS" == "arch" ]]; then
    bash "$SCRIPT_DIR/scripts/setup-android-sdk.sh"
fi

if $SYS_FISH_DEFAULT && check_cmd fish && [[ "$SHELL" != "$(which fish)" ]]; then
    run chsh -s "$(which fish)" && success "Default shell → fish (re-login to apply)"
fi

$IS_LINUX && run xdg-user-dirs-update

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
gum style \
    --foreground="46" --border-foreground="46" \
    --border=double --align=center \
    --width=52 --margin="1 2" --padding="1 3" \
    "✓  Setup Complete!" \
    "" \
    "OS: $OS  ·  Your workstation is ready." \
    "Log saved to: ~/sys-setup-install.log"
echo ""

if $IS_LINUX; then
    gum_confirm "Reboot now to apply all changes?" && sudo reboot || true
else
    success "macOS setup complete. Some apps may require a logout to take effect."
fi
