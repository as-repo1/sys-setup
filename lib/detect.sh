#!/usr/bin/env bash
# =============================================================================
#  lib/detect.sh — OS / package-manager detection + install wrappers
#  Sourced by install.sh. Provides:
#    OS                      ("arch" | "ubuntu" | "fedora")
#    IS_LINUX                (always true here; macOS dropped)
#    DISTRO_PRETTY           human-readable distro name (for the banner)
#    detect_os               sets the above
#    check_cmd               portable command existence
#    pkg_install / aur_install / flat_install   distro install wrappers
#
#  macOS support has been dropped (see plan §2). Only Arch/Ubuntu/Fedora remain.
# =============================================================================

OS=""
IS_LINUX=true
DISTRO_PRETTY="Linux"

check_cmd() { command -v "$1" &>/dev/null; }

detect_os() {
    case "$(uname -s)" in
        Linux)
            IS_LINUX=true
            if check_cmd pacman; then
                OS="arch"
            elif check_cmd apt-get; then
                OS="ubuntu"
            elif check_cmd dnf; then
                OS="fedora"
            else
                die "Unsupported Linux distribution. Supported: Arch, Ubuntu/Debian, Fedora."
            fi
            # Pretty name for the banner (best-effort)
            if [[ -f /etc/os-release ]]; then
                DISTRO_PRETTY="$(. /etc/os-release; echo "${PRETTY_NAME:-Linux}")"
            else
                DISTRO_PRETTY="$OS"
            fi
            ;;
        Darwin)
            die "macOS is no longer supported by sys-setup. Use Arch, Ubuntu, or Fedora."
            ;;
        *)
            die "Unsupported OS: $(uname -s)"
            ;;
    esac
}

# ─── Package manager wrappers ────────────────────────────────────────────────
pkg_install() {
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[dry-run]${RESET} pkg_install: $*"
        return 0
    fi
    case "$OS" in
        arch)   sudo pacman -S --noconfirm --needed "$@" >> "$LOG_FILE" 2>&1 || { warn "Some packages failed: $*"; return 1; } ;;
        ubuntu) sudo apt-get install -y "$@" >> "$LOG_FILE" 2>&1 || { warn "Some packages failed: $*"; return 1; } ;;
        fedora) sudo dnf install -y "$@" >> "$LOG_FILE" 2>&1 || { warn "Some packages failed: $*"; return 1; } ;;
    esac
}

aur_install() {
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[dry-run]${RESET} aur_install: $*"
        return 0
    fi
    case "$OS" in
        arch)   yay -S --noconfirm --needed "$@" >> "$LOG_FILE" 2>&1 || { warn "AUR install failed: $*"; return 1; } ;;
        *)      warn "AUR not available on $OS — skipping $*"; return 1 ;;
    esac
}

# flat_install — flatpak fallback. Warns explicitly if flatpak is missing
# (bug #13: original silently did nothing).
flat_install() {
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[dry-run]${RESET} flat_install: $*"
        return 0
    fi
    if check_cmd flatpak; then
        flatpak install -y flathub "$@" >> "$LOG_FILE" 2>&1 || { warn "Flatpak install failed: $*"; return 1; }
    else
        warn "flatpak not installed — cannot install $*"
        return 1
    fi
}
