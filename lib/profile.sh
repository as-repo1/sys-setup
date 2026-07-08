#!/usr/bin/env bash
# =============================================================================
#  lib/profile.sh — installation profiles
#  Sourced by install.sh. Provides:
#    init_profile_defaults   set the "Typical" sensible defaults
#    apply_complete          flip every flag on
#    MODE                    "Typical" | "Complete" | "Custom"
#
#  Flags are grouped by category. Linux-only categories (WM, Gaming, Dotfiles,
#  System, Security) are only meaningful on Linux — macOS is no longer supported.
# =============================================================================

# Window Manager
INSTALL_NIRI=true;  INSTALL_GNOME=false; INSTALL_I3=false

# Browsers
BR_ZEN=true; BR_FLOORP=false; BR_BRAVE=false; BR_FIREFOX=true; BR_EDGE=false
BR_CHROME=true; BR_LIBREWOLF=false; BR_VIVALDI=false; BR_CHROMIUM=false; BR_TOR=false

# Chat & Messaging
CHAT_TELEGRAM=false; CHAT_FERDIUM=false; CHAT_DISCORD=false; CHAT_VESKTOP=false
CHAT_SIGNAL=false;   CHAT_SLACK=false;   CHAT_ELEMENT=false; CHAT_THUNDERBIRD=false

# Multimedia
MEDIA_MPV=true; MEDIA_VLC=false; MEDIA_YTDLP=true; MEDIA_PARABOLIC=false
MEDIA_CELLULOID=false; MEDIA_OBS=false; MEDIA_KDENLIVE=false; MEDIA_AUDACITY=false
MEDIA_HANDBRAKE=false;  MEDIA_SPOTIFY=false; MEDIA_FREETUBE=false; MEDIA_AMBEROL=false

# Development
DEV_NEOVIM=true; DEV_VSCODE=false; DEV_DOCKER=true; DEV_NODE=true; DEV_PYTHON=true
DEV_ANDROID=false; DEV_ZED=false; DEV_HELIX=false; DEV_GO=false; DEV_RUST=false
DEV_GH=false; DEV_LAZYGIT=false; DEV_POSTMAN=false; DEV_DBEAVER=false

# Notes & Office
NOTES_OBSIDIAN=false; NOTES_LOGSEQ=false; NOTES_LIBREOFFICE=false; NOTES_ONLYOFFICE=false
NOTES_ZATHURA=false;  NOTES_OKULAR=false;  NOTES_MARKER=false

# File Managers
FM_NAUTILUS=true; FM_NEMO=false; FM_THUNAR=false; FM_PCMANFM=false

# Utilities
UTIL_BTOP=true; UTIL_HTOP=true; UTIL_NVTOP=true; UTIL_GLANCES=false
UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=true; UTIL_LOCALSEND=false
UTIL_TIMESHIFT=false; UTIL_KEEPASSXC=false; UTIL_BITWARDEN=false
UTIL_SYNCTHING=false; UTIL_FLAMESHOT=false; UTIL_COPYQ=false; UTIL_VENTOY=false
UTIL_BAOBAB=false;   UTIL_GNOME_DISKS=false
UTIL_FILE_ROLLER=true; UTIL_UNRAR=true; UTIL_UNZIP=true

# Gaming
GAME_STEAM=false; GAME_LUTRIS=false; GAME_HEROIC=false
GAME_GAMEMODE=false; GAME_MANGOHUD=false; GAME_PROTONUP=false

# AI & LLMs
AI_ANYLLM=false; AI_LMSTUDIO=false; AI_PINOKIO=false
AI_OLLAMA=false; AI_OPENWEBUI=false; AI_JAN=false

# Dotfiles
DOT_NIRI=true;  DOT_WAYBAR=true; DOT_FISH=true;  DOT_KITTY=true
DOT_GHOSTTY=false; DOT_ALACRITTY=false; DOT_NVIM=true; DOT_BTOP=true
DOT_FUZZEL=true; DOT_DUNST=true; DOT_GTK=true;  DOT_ZATHURA=false
DOT_MPV=false;   DOT_RANGER=false; DOT_NOCTALIA=false; DOT_FASTFETCH=true
DOT_APPIMAGELAUNCHER=false

# System
INSTALL_CHAOTIC=true; SYS_SSH=false; SYS_DOCKER_BOOT=true; SYS_FISH_DEFAULT=true

# Security & Hardening
SEC_FAIL2BAN=false; SEC_SSH_HARDEN=false; SEC_DNSSEC=false; SEC_AUTO_UPDATE=false

# Arch-specific optional extras (gated, not unconditional — bug #4)
ARCH_NOCTALIA=false; ARCH_APPIMAGELAUNCHER=false

# apply_complete — flip every flag on.
apply_complete() {
    INSTALL_NIRI=true; INSTALL_GNOME=true; INSTALL_I3=true

    BR_ZEN=true; BR_FLOORP=true; BR_BRAVE=true; BR_FIREFOX=true; BR_EDGE=true
    BR_CHROME=true; BR_LIBREWOLF=true; BR_VIVALDI=true; BR_CHROMIUM=true; BR_TOR=true

    CHAT_TELEGRAM=true; CHAT_FERDIUM=true; CHAT_DISCORD=true; CHAT_VESKTOP=true
    CHAT_SIGNAL=true;   CHAT_SLACK=true;   CHAT_ELEMENT=true; CHAT_THUNDERBIRD=true

    MEDIA_MPV=true; MEDIA_VLC=true; MEDIA_YTDLP=true; MEDIA_PARABOLIC=true
    MEDIA_CELLULOID=true; MEDIA_OBS=true; MEDIA_KDENLIVE=true; MEDIA_AUDACITY=true
    MEDIA_HANDBRAKE=true;  MEDIA_SPOTIFY=true; MEDIA_FREETUBE=true; MEDIA_AMBEROL=true

    DEV_NEOVIM=true; DEV_VSCODE=true; DEV_DOCKER=true; DEV_NODE=true; DEV_PYTHON=true
    DEV_ANDROID=true; DEV_ZED=true; DEV_HELIX=true; DEV_GO=true; DEV_RUST=true
    DEV_GH=true; DEV_LAZYGIT=true; DEV_POSTMAN=true; DEV_DBEAVER=true

    NOTES_OBSIDIAN=true; NOTES_LOGSEQ=true; NOTES_LIBREOFFICE=true; NOTES_ONLYOFFICE=true
    NOTES_ZATHURA=true;  NOTES_OKULAR=true;  NOTES_MARKER=true

    FM_NAUTILUS=true; FM_NEMO=true; FM_THUNAR=true; FM_PCMANFM=true

    UTIL_BTOP=true; UTIL_HTOP=true; UTIL_NVTOP=true; UTIL_GLANCES=true
    UTIL_MISSION=true; UTIL_HELVUM=true; UTIL_MELD=true; UTIL_LOCALSEND=true
    UTIL_TIMESHIFT=true; UTIL_KEEPASSXC=true; UTIL_BITWARDEN=true
    UTIL_SYNCTHING=true; UTIL_FLAMESHOT=true; UTIL_COPYQ=true; UTIL_VENTOY=true
    UTIL_BAOBAB=true;   UTIL_GNOME_DISKS=true
    UTIL_FILE_ROLLER=true; UTIL_UNRAR=true; UTIL_UNZIP=true

    GAME_STEAM=true; GAME_LUTRIS=true; GAME_HEROIC=true
    GAME_GAMEMODE=true; GAME_MANGOHUD=true; GAME_PROTONUP=true

    AI_ANYLLM=true; AI_LMSTUDIO=true; AI_PINOKIO=true
    AI_OLLAMA=true; AI_OPENWEBUI=true; AI_JAN=true

    DOT_NIRI=true;  DOT_WAYBAR=true; DOT_FUZZEL=true; DOT_DUNST=true
    DOT_GTK=true;   DOT_NOCTALIA=true; DOT_APPIMAGELAUNCHER=true
    DOT_FISH=true;  DOT_KITTY=true; DOT_GHOSTTY=true; DOT_ALACRITTY=true
    DOT_NVIM=true;  DOT_BTOP=true; DOT_ZATHURA=true; DOT_MPV=true
    DOT_RANGER=true; DOT_FASTFETCH=true

    INSTALL_CHAOTIC=true; SYS_SSH=true; SYS_DOCKER_BOOT=true
    SYS_FISH_DEFAULT=true

    SEC_FAIL2BAN=true; SEC_SSH_HARDEN=true; SEC_DNSSEC=true; SEC_AUTO_UPDATE=true

    ARCH_NOCTALIA=true; ARCH_APPIMAGELAUNCHER=true
}
