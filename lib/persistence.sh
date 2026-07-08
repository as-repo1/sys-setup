#!/usr/bin/env bash
# =============================================================================
#  lib/persistence.sh — selection persistence
#  Sourced by install.sh. Provides:
#    SELECTION_FILE     ~/.config/sys-setup/last-selection.conf
#    save_selection     write all profile flags to the file
#    load_selection     source the file if it exists
#    offer_restore      gum confirm to restore last selection (returns rc)
#
#  Format is a simple shell file of `KEY=value` lines, sourced safely.
# =============================================================================

SELECTION_FILE="$HOME/.config/sys-setup/last-selection.conf"

# All profile flag names — kept in sync with lib/profile.sh.
# Used by save_selection and is_enabled helper.
PROFILE_FLAGS=(
    INSTALL_NIRI INSTALL_GNOME INSTALL_I3
    BR_ZEN BR_FLOORP BR_BRAVE BR_FIREFOX BR_EDGE BR_CHROME BR_LIBREWOLF BR_VIVALDI BR_CHROMIUM BR_TOR
    CHAT_TELEGRAM CHAT_FERDIUM CHAT_DISCORD CHAT_VESKTOP CHAT_SIGNAL CHAT_SLACK CHAT_ELEMENT CHAT_THUNDERBIRD
    MEDIA_MPV MEDIA_VLC MEDIA_YTDLP MEDIA_PARABOLIC MEDIA_CELLULOID MEDIA_OBS MEDIA_KDENLIVE MEDIA_AUDACITY MEDIA_HANDBRAKE MEDIA_SPOTIFY MEDIA_FREETUBE MEDIA_AMBEROL
    DEV_NEOVIM DEV_VSCODE DEV_DOCKER DEV_NODE DEV_PYTHON DEV_ANDROID DEV_ZED DEV_HELIX DEV_GO DEV_RUST DEV_GH DEV_LAZYGIT DEV_POSTMAN DEV_DBEAVER
    NOTES_OBSIDIAN NOTES_LOGSEQ NOTES_LIBREOFFICE NOTES_ONLYOFFICE NOTES_ZATHURA NOTES_OKULAR NOTES_MARKER
    FM_NAUTILUS FM_NEMO FM_THUNAR FM_PCMANFM
    UTIL_BTOP UTIL_HTOP UTIL_NVTOP UTIL_GLANCES UTIL_MISSION UTIL_HELVUM UTIL_MELD UTIL_LOCALSEND UTIL_TIMESHIFT UTIL_KEEPASSXC UTIL_BITWARDEN UTIL_SYNCTHING UTIL_FLAMESHOT UTIL_COPYQ UTIL_VENTOY UTIL_BAOBAB UTIL_GNOME_DISKS UTIL_FILE_ROLLER UTIL_UNRAR UTIL_UNZIP
    GAME_STEAM GAME_LUTRIS GAME_HEROIC GAME_GAMEMODE GAME_MANGOHUD GAME_PROTONUP
    AI_ANYLLM AI_LMSTUDIO AI_PINOKIO AI_OLLAMA AI_OPENWEBUI AI_JAN
    DOT_NIRI DOT_WAYBAR DOT_FISH DOT_KITTY DOT_GHOSTTY DOT_ALACRITTY DOT_NVIM DOT_BTOP DOT_FUZZEL DOT_DUNST DOT_GTK DOT_ZATHURA DOT_MPV DOT_RANGER DOT_NOCTALIA DOT_FASTFETCH DOT_APPIMAGELAUNCHER
    INSTALL_CHAOTIC SYS_SSH SYS_DOCKER_BOOT SYS_FISH_DEFAULT
    SEC_FAIL2BAN SEC_SSH_HARDEN SEC_DNSSEC SEC_AUTO_UPDATE
    ARCH_NOCTALIA ARCH_APPIMAGELAUNCHER
)

save_selection() {
    mkdir -p "$(dirname "$SELECTION_FILE")"
    {
        echo "# sys-setup selection — saved $(date '+%Y-%m-%d %H:%M:%S')"
        echo "SAVED_MODE=\"$MODE\""
        for f in "${PROFILE_FLAGS[@]}"; do
            printf '%s=%s\n' "$f" "${!f}"
        done
    } > "$SELECTION_FILE"
    log "Selection saved to $SELECTION_FILE"
}

load_selection() {
    [[ -f "$SELECTION_FILE" ]] || return 1
    # shellcheck disable=SC1090
    source "$SELECTION_FILE"
    return 0
}

# offer_restore — ask the user. Returns 0 if they want to restore.
offer_restore() {
    [[ -f "$SELECTION_FILE" ]] || return 1
    local saved_mode="${SAVED_MODE:-previous}"
    gum_confirm "Restore your last selection ($saved_mode profile)?"
}
