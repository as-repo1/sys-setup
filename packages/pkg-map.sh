#!/usr/bin/env bash
# =============================================================================
#  pkg-map.sh — Canonical package name → distro-specific package mapping
#  Sourced by install.sh — provides pkg_name() lookup function
# =============================================================================

# Usage:  pkg_name "canonical-name"
# Returns the distro-specific package name(s) for the detected OS.
# Returns empty string if package is unavailable on the current platform.

declare -A PKG_ARCH PKG_UBUNTU PKG_FEDORA PKG_MACOS PKG_MACOS_CASK

# ─── Core System (Linux only) ────────────────────────────────────────────────
PKG_ARCH[base-devel]="base-devel"
PKG_UBUNTU[base-devel]="build-essential"
PKG_FEDORA[base-devel]="@development-tools"

PKG_ARCH[git]="git"
PKG_UBUNTU[git]="git"
PKG_FEDORA[git]="git"
PKG_MACOS[git]="git"

PKG_ARCH[curl]="curl"
PKG_UBUNTU[curl]="curl"
PKG_FEDORA[curl]="curl"
PKG_MACOS[curl]="curl"

PKG_ARCH[wget]="wget"
PKG_UBUNTU[wget]="wget"
PKG_FEDORA[wget]="wget"
PKG_MACOS[wget]="wget"

PKG_ARCH[stow]="stow"
PKG_UBUNTU[stow]="stow"
PKG_FEDORA[stow]="stow"
PKG_MACOS[stow]="stow"

PKG_ARCH[rsync]="rsync"
PKG_UBUNTU[rsync]="rsync"
PKG_FEDORA[rsync]="rsync"
PKG_MACOS[rsync]="rsync"

# ─── Shell & Terminal ─────────────────────────────────────────────────────────
PKG_ARCH[fish]="fish"
PKG_UBUNTU[fish]="fish"
PKG_FEDORA[fish]="fish"
PKG_MACOS[fish]="fish"

PKG_ARCH[starship]="starship"
PKG_UBUNTU[starship]=""           # install via curl
PKG_FEDORA[starship]=""           # install via curl
PKG_MACOS[starship]="starship"

PKG_ARCH[kitty]="kitty"
PKG_UBUNTU[kitty]="kitty"
PKG_FEDORA[kitty]="kitty"
PKG_MACOS_CASK[kitty]="kitty"

PKG_ARCH[ghostty]="ghostty"
PKG_UBUNTU[ghostty]=""            # not in repos
PKG_FEDORA[ghostty]=""            # not in repos
PKG_MACOS_CASK[ghostty]="ghostty"

PKG_ARCH[alacritty]="alacritty"
PKG_UBUNTU[alacritty]="alacritty"
PKG_FEDORA[alacritty]="alacritty"
PKG_MACOS_CASK[alacritty]="alacritty"

# ─── CLI Tools ────────────────────────────────────────────────────────────────
PKG_ARCH[neovim]="neovim"
PKG_UBUNTU[neovim]="neovim"
PKG_FEDORA[neovim]="neovim"
PKG_MACOS[neovim]="neovim"

PKG_ARCH[bat]="bat"
PKG_UBUNTU[bat]="bat"
PKG_FEDORA[bat]="bat"
PKG_MACOS[bat]="bat"

PKG_ARCH[lsd]="lsd"
PKG_UBUNTU[lsd]="lsd"
PKG_FEDORA[lsd]="lsd"
PKG_MACOS[lsd]="lsd"

PKG_ARCH[yazi]="yazi"
PKG_UBUNTU[yazi]=""               # not in repos — use cargo
PKG_FEDORA[yazi]=""               # not in repos — use cargo
PKG_MACOS[yazi]="yazi"

PKG_ARCH[btop]="btop"
PKG_UBUNTU[btop]="btop"
PKG_FEDORA[btop]="btop"
PKG_MACOS[btop]="btop"

PKG_ARCH[htop]="htop"
PKG_UBUNTU[htop]="htop"
PKG_FEDORA[htop]="htop"
PKG_MACOS[htop]="htop"

PKG_ARCH[fastfetch]="fastfetch"
PKG_UBUNTU[fastfetch]="fastfetch"
PKG_FEDORA[fastfetch]="fastfetch"
PKG_MACOS[fastfetch]="fastfetch"

PKG_ARCH[tree]="tree"
PKG_UBUNTU[tree]="tree"
PKG_FEDORA[tree]="tree"
PKG_MACOS[tree]="tree"

PKG_ARCH[tldr]="tldr"
PKG_UBUNTU[tldr]="tldr"
PKG_FEDORA[tldr]="tldr"
PKG_MACOS[tldr]="tldr"

PKG_ARCH[ranger]="ranger"
PKG_UBUNTU[ranger]="ranger"
PKG_FEDORA[ranger]="ranger"
PKG_MACOS[ranger]="ranger"

PKG_ARCH[gh]="github-cli"
PKG_UBUNTU[gh]="gh"
PKG_FEDORA[gh]="gh"
PKG_MACOS[gh]="gh"

PKG_ARCH[lazygit]="lazygit"
PKG_UBUNTU[lazygit]=""            # PPA or binary
PKG_FEDORA[lazygit]=""            # COPR
PKG_MACOS[lazygit]="lazygit"

# ─── Browsers ────────────────────────────────────────────────────────────────
PKG_ARCH[firefox]="firefox"
PKG_UBUNTU[firefox]="firefox"
PKG_FEDORA[firefox]="firefox"
PKG_MACOS_CASK[firefox]="firefox"

PKG_ARCH[chromium]="chromium"
PKG_UBUNTU[chromium]="chromium-browser"
PKG_FEDORA[chromium]="chromium"
PKG_MACOS_CASK[chromium]="chromium"

PKG_ARCH[zen-browser]="zen-browser-bin"        # AUR
PKG_UBUNTU[zen-browser]=""                      # flatpak
PKG_FEDORA[zen-browser]=""                      # flatpak
PKG_MACOS_CASK[zen-browser]="zen-browser"

PKG_ARCH[floorp]="floorp-bin"                   # AUR
PKG_UBUNTU[floorp]=""                           # flatpak
PKG_FEDORA[floorp]=""                           # flatpak
PKG_MACOS_CASK[floorp]="floorp"

PKG_ARCH[brave]="brave-bin"                     # AUR
PKG_UBUNTU[brave]=""                            # apt repo
PKG_FEDORA[brave]=""                            # dnf repo
PKG_MACOS_CASK[brave]="brave-browser"

PKG_ARCH[google-chrome]="google-chrome"         # AUR
PKG_UBUNTU[google-chrome]=""                    # apt repo
PKG_FEDORA[google-chrome]=""                    # dnf repo
PKG_MACOS_CASK[google-chrome]="google-chrome"

PKG_ARCH[microsoft-edge]="microsoft-edge-stable-bin"  # AUR
PKG_UBUNTU[microsoft-edge]=""                   # apt repo
PKG_FEDORA[microsoft-edge]=""                   # dnf repo
PKG_MACOS_CASK[microsoft-edge]="microsoft-edge"

PKG_ARCH[librewolf]="librewolf-bin"             # AUR
PKG_UBUNTU[librewolf]=""                        # flatpak
PKG_FEDORA[librewolf]=""                        # flatpak
PKG_MACOS_CASK[librewolf]="librewolf"

PKG_ARCH[vivaldi]="vivaldi"                     # AUR
PKG_UBUNTU[vivaldi]=""                          # apt repo
PKG_FEDORA[vivaldi]=""                          # dnf repo
PKG_MACOS_CASK[vivaldi]="vivaldi"

PKG_ARCH[tor-browser]="tor-browser"             # AUR
PKG_UBUNTU[tor-browser]="torbrowser-launcher"
PKG_FEDORA[tor-browser]=""                      # flatpak
PKG_MACOS_CASK[tor-browser]="tor-browser"

# ─── Chat & Messaging ────────────────────────────────────────────────────────
PKG_ARCH[telegram]="telegram-desktop"
PKG_UBUNTU[telegram]="telegram-desktop"
PKG_FEDORA[telegram]=""                         # flatpak
PKG_MACOS_CASK[telegram]="telegram"

PKG_ARCH[ferdium]="ferdium-bin"                 # AUR
PKG_UBUNTU[ferdium]=""                          # flatpak
PKG_FEDORA[ferdium]=""                          # flatpak
PKG_MACOS_CASK[ferdium]="ferdium"

PKG_ARCH[discord]="discord"
PKG_UBUNTU[discord]=""                          # flatpak
PKG_FEDORA[discord]=""                          # flatpak
PKG_MACOS_CASK[discord]="discord"

PKG_ARCH[vesktop]="vesktop-bin"                 # AUR
PKG_UBUNTU[vesktop]=""                          # flatpak
PKG_FEDORA[vesktop]=""                          # flatpak
PKG_MACOS_CASK[vesktop]="vesktop"

PKG_ARCH[signal]="signal-desktop"               # AUR
PKG_UBUNTU[signal]=""                           # apt repo
PKG_FEDORA[signal]=""                           # flatpak
PKG_MACOS_CASK[signal]="signal"

PKG_ARCH[slack]="slack-desktop"                 # AUR
PKG_UBUNTU[slack]=""                            # snap/flatpak
PKG_FEDORA[slack]=""                            # flatpak
PKG_MACOS_CASK[slack]="slack"

PKG_ARCH[element]="element-desktop"             # AUR
PKG_UBUNTU[element]=""                          # flatpak
PKG_FEDORA[element]=""                          # flatpak
PKG_MACOS_CASK[element]="element"

PKG_ARCH[thunderbird]="thunderbird"
PKG_UBUNTU[thunderbird]="thunderbird"
PKG_FEDORA[thunderbird]="thunderbird"
PKG_MACOS_CASK[thunderbird]="thunderbird"

# ─── Multimedia ──────────────────────────────────────────────────────────────
PKG_ARCH[mpv]="mpv"
PKG_UBUNTU[mpv]="mpv"
PKG_FEDORA[mpv]="mpv"
PKG_MACOS[mpv]="mpv"

PKG_ARCH[vlc]="vlc"
PKG_UBUNTU[vlc]="vlc"
PKG_FEDORA[vlc]="vlc"
PKG_MACOS_CASK[vlc]="vlc"

PKG_ARCH[yt-dlp]="yt-dlp"
PKG_UBUNTU[yt-dlp]="yt-dlp"
PKG_FEDORA[yt-dlp]="yt-dlp"
PKG_MACOS[yt-dlp]="yt-dlp"

PKG_ARCH[parabolic]="parabolic"                 # AUR
PKG_UBUNTU[parabolic]=""                        # flatpak
PKG_FEDORA[parabolic]=""                        # flatpak

PKG_ARCH[celluloid]="celluloid"
PKG_UBUNTU[celluloid]="celluloid"
PKG_FEDORA[celluloid]="celluloid"

PKG_ARCH[obs-studio]="obs-studio"
PKG_UBUNTU[obs-studio]="obs-studio"
PKG_FEDORA[obs-studio]="obs-studio"
PKG_MACOS_CASK[obs-studio]="obs"

PKG_ARCH[kdenlive]="kdenlive"
PKG_UBUNTU[kdenlive]="kdenlive"
PKG_FEDORA[kdenlive]="kdenlive"
PKG_MACOS_CASK[kdenlive]="kdenlive"

PKG_ARCH[audacity]="audacity"
PKG_UBUNTU[audacity]="audacity"
PKG_FEDORA[audacity]="audacity"
PKG_MACOS_CASK[audacity]="audacity"

PKG_ARCH[handbrake]="handbrake"
PKG_UBUNTU[handbrake]="handbrake"
PKG_FEDORA[handbrake]="handbrake"
PKG_MACOS_CASK[handbrake]="handbrake"

PKG_ARCH[spotify]="spotify"                     # AUR
PKG_UBUNTU[spotify]=""                          # flatpak/snap
PKG_FEDORA[spotify]=""                          # flatpak
PKG_MACOS_CASK[spotify]="spotify"

PKG_ARCH[freetube]="freetube-bin"               # AUR
PKG_UBUNTU[freetube]=""                         # flatpak
PKG_FEDORA[freetube]=""                         # flatpak
PKG_MACOS_CASK[freetube]="freetube"

PKG_ARCH[amberol]="amberol"                     # AUR
PKG_UBUNTU[amberol]=""                          # flatpak
PKG_FEDORA[amberol]=""                          # flatpak

# ─── Development ─────────────────────────────────────────────────────────────
PKG_ARCH[vscode]="visual-studio-code-bin"       # AUR
PKG_UBUNTU[vscode]=""                           # apt repo
PKG_FEDORA[vscode]=""                           # rpm repo
PKG_MACOS_CASK[vscode]="visual-studio-code"

PKG_ARCH[docker]="docker docker-compose"
PKG_UBUNTU[docker]="docker.io docker-compose-v2"
PKG_FEDORA[docker]="docker docker-compose"
PKG_MACOS_CASK[docker]="docker"

PKG_ARCH[nodejs]="nodejs npm"
PKG_UBUNTU[nodejs]="nodejs npm"
PKG_FEDORA[nodejs]="nodejs npm"
PKG_MACOS[nodejs]="node"

PKG_ARCH[python]="python python-pip"
PKG_UBUNTU[python]="python3 python3-pip python3-venv"
PKG_FEDORA[python]="python3 python3-pip"
PKG_MACOS[python]="python"

PKG_ARCH[go]="go"
PKG_UBUNTU[go]="golang"
PKG_FEDORA[go]="golang"
PKG_MACOS[go]="go"

PKG_ARCH[rustup]="rustup"
PKG_UBUNTU[rustup]="rustup"
PKG_FEDORA[rustup]="rustup"
PKG_MACOS[rustup]="rustup-init"

PKG_ARCH[android-tools]="android-tools scrcpy"
PKG_UBUNTU[android-tools]="adb scrcpy"
PKG_FEDORA[android-tools]="android-tools scrcpy"

PKG_ARCH[zed]="zed"                             # AUR
PKG_UBUNTU[zed]=""                              # binary/flatpak
PKG_FEDORA[zed]=""                              # binary/flatpak
PKG_MACOS_CASK[zed]="zed"

PKG_ARCH[helix]="helix"
PKG_UBUNTU[helix]="helix-editor"
PKG_FEDORA[helix]="helix"
PKG_MACOS[helix]="helix"

PKG_ARCH[postman]="postman-bin"                 # AUR
PKG_UBUNTU[postman]=""                          # flatpak
PKG_FEDORA[postman]=""                          # flatpak
PKG_MACOS_CASK[postman]="postman"

PKG_ARCH[dbeaver]="dbeaver"                     # AUR
PKG_UBUNTU[dbeaver]=""                          # flatpak
PKG_FEDORA[dbeaver]=""                          # flatpak
PKG_MACOS_CASK[dbeaver]="dbeaver-community"

# ─── Notes & Office ──────────────────────────────────────────────────────────
PKG_ARCH[obsidian]="obsidian"                   # AUR
PKG_UBUNTU[obsidian]=""                         # flatpak
PKG_FEDORA[obsidian]=""                         # flatpak
PKG_MACOS_CASK[obsidian]="obsidian"

PKG_ARCH[logseq]="logseq-desktop-bin"           # AUR
PKG_UBUNTU[logseq]=""                           # flatpak
PKG_FEDORA[logseq]=""                           # flatpak
PKG_MACOS_CASK[logseq]="logseq"

PKG_ARCH[libreoffice]="libreoffice-fresh"
PKG_UBUNTU[libreoffice]="libreoffice"
PKG_FEDORA[libreoffice]="libreoffice"
PKG_MACOS_CASK[libreoffice]="libreoffice"

PKG_ARCH[onlyoffice]="onlyoffice-bin"           # AUR
PKG_UBUNTU[onlyoffice]=""                       # flatpak
PKG_FEDORA[onlyoffice]=""                       # flatpak
PKG_MACOS_CASK[onlyoffice]="onlyoffice"

PKG_ARCH[zathura]="zathura zathura-pdf-mupdf"
PKG_UBUNTU[zathura]="zathura"
PKG_FEDORA[zathura]="zathura zathura-pdf-mupdf"

PKG_ARCH[okular]="okular"
PKG_UBUNTU[okular]="okular"
PKG_FEDORA[okular]="okular"

PKG_ARCH[marker]="marker"                       # AUR
PKG_UBUNTU[marker]=""                           # flatpak
PKG_FEDORA[marker]=""                           # flatpak

# ─── Utilities ───────────────────────────────────────────────────────────────
PKG_ARCH[meld]="meld"
PKG_UBUNTU[meld]="meld"
PKG_FEDORA[meld]="meld"
PKG_MACOS_CASK[meld]="meld"

PKG_ARCH[localsend]="localsend-bin"             # AUR
PKG_UBUNTU[localsend]=""                        # flatpak
PKG_FEDORA[localsend]=""                        # flatpak
PKG_MACOS_CASK[localsend]="localsend"

PKG_ARCH[timeshift]="timeshift"
PKG_UBUNTU[timeshift]="timeshift"
PKG_FEDORA[timeshift]="timeshift"

PKG_ARCH[mission-center]="mission-center"       # AUR
PKG_UBUNTU[mission-center]=""                   # flatpak
PKG_FEDORA[mission-center]=""                   # flatpak

PKG_ARCH[helvum]="helvum-git"                   # AUR
PKG_UBUNTU[helvum]=""                           # flatpak
PKG_FEDORA[helvum]=""                           # flatpak

PKG_ARCH[keepassxc]="keepassxc"
PKG_UBUNTU[keepassxc]="keepassxc"
PKG_FEDORA[keepassxc]="keepassxc"
PKG_MACOS_CASK[keepassxc]="keepassxc"

PKG_ARCH[bitwarden]="bitwarden"                 # AUR
PKG_UBUNTU[bitwarden]=""                        # flatpak
PKG_FEDORA[bitwarden]=""                        # flatpak
PKG_MACOS_CASK[bitwarden]="bitwarden"

PKG_ARCH[syncthing]="syncthing"
PKG_UBUNTU[syncthing]="syncthing"
PKG_FEDORA[syncthing]="syncthing"
PKG_MACOS[syncthing]="syncthing"

PKG_ARCH[flameshot]="flameshot"
PKG_UBUNTU[flameshot]="flameshot"
PKG_FEDORA[flameshot]="flameshot"

PKG_ARCH[copyq]="copyq"                        # AUR
PKG_UBUNTU[copyq]="copyq"
PKG_FEDORA[copyq]="copyq"

PKG_ARCH[ventoy]="ventoy-bin"                   # AUR
PKG_UBUNTU[ventoy]=""                           # binary
PKG_FEDORA[ventoy]=""                           # binary

PKG_ARCH[baobab]="baobab"
PKG_UBUNTU[baobab]="baobab"
PKG_FEDORA[baobab]="baobab"

PKG_ARCH[gnome-disk-utility]="gnome-disk-utility"
PKG_UBUNTU[gnome-disk-utility]="gnome-disk-utility"
PKG_FEDORA[gnome-disk-utility]="gnome-disk-utility"

# ─── Gaming (Linux only) ─────────────────────────────────────────────────────
PKG_ARCH[steam]="steam"
PKG_UBUNTU[steam]="steam-installer"
PKG_FEDORA[steam]="steam"                       # RPM Fusion

PKG_ARCH[lutris]="lutris"
PKG_UBUNTU[lutris]="lutris"
PKG_FEDORA[lutris]="lutris"

PKG_ARCH[heroic]="heroic-games-launcher-bin"    # AUR
PKG_UBUNTU[heroic]=""                           # flatpak
PKG_FEDORA[heroic]=""                           # flatpak

PKG_ARCH[gamemode]="gamemode lib32-gamemode"
PKG_UBUNTU[gamemode]="gamemode"
PKG_FEDORA[gamemode]="gamemode"

PKG_ARCH[mangohud]="mangohud lib32-mangohud"    # AUR
PKG_UBUNTU[mangohud]="mangohud"
PKG_FEDORA[mangohud]="mangohud"

PKG_ARCH[protonup-qt]="protonup-qt"             # AUR
PKG_UBUNTU[protonup-qt]=""                      # flatpak
PKG_FEDORA[protonup-qt]=""                      # flatpak

# ─── AI & LLMs ───────────────────────────────────────────────────────────────
PKG_ARCH[ollama]="ollama"
PKG_UBUNTU[ollama]=""                           # curl install
PKG_FEDORA[ollama]=""                           # curl install
PKG_MACOS[ollama]="ollama"

PKG_ARCH[jan]="jan-bin"                         # AUR
PKG_UBUNTU[jan]=""                              # .deb from releases
PKG_FEDORA[jan]=""                              # .rpm from releases
PKG_MACOS_CASK[jan]="jan"

# ─── Security (Linux only) ───────────────────────────────────────────────────
PKG_ARCH[fail2ban]="fail2ban"
PKG_UBUNTU[fail2ban]="fail2ban"
PKG_FEDORA[fail2ban]="fail2ban"

# ─── Flatpak app IDs (universal fallback) ────────────────────────────────────
declare -A FLATPAK_ID
FLATPAK_ID[zen-browser]="io.github.nickvision.application"
FLATPAK_ID[discord]="com.discordapp.Discord"
FLATPAK_ID[vesktop]="dev.vencord.Vesktop"
FLATPAK_ID[signal]="org.signal.Signal"
FLATPAK_ID[slack]="com.slack.Slack"
FLATPAK_ID[element]="im.riot.Riot"
FLATPAK_ID[spotify]="com.spotify.Client"
FLATPAK_ID[obsidian]="md.obsidian.Obsidian"
FLATPAK_ID[logseq]="com.logseq.Logseq"
FLATPAK_ID[ferdium]="org.ferdium.Ferdium"
FLATPAK_ID[parabolic]="org.nickvision.tubeconverter"
FLATPAK_ID[freetube]="io.freetubeapp.FreeTube"
FLATPAK_ID[amberol]="io.bassi.Amberol"
FLATPAK_ID[mission-center]="io.missioncenter.MissionCenter"
FLATPAK_ID[helvum]="org.pipewire.Helvum"
FLATPAK_ID[heroic]="com.heroicgameslauncher.hgl"
FLATPAK_ID[protonup-qt]="net.davidotek.pupgui2"
FLATPAK_ID[postman]="com.getpostman.Postman"
FLATPAK_ID[dbeaver]="io.dbeaver.DBeaverCommunity"
FLATPAK_ID[bitwarden]="com.bitwarden.desktop"
FLATPAK_ID[onlyoffice]="org.onlyoffice.desktopeditors"
FLATPAK_ID[localsend]="org.localsend.localsend_app"
FLATPAK_ID[marker]="com.github.fabiocolacio.marker"
FLATPAK_ID[telegram]="org.telegram.desktop"
FLATPAK_ID[floorp]="one.nicotine.nicotine"
FLATPAK_ID[librewolf]="io.gitlab.librewolf-community"
FLATPAK_ID[vscode]="com.visualstudio.code"
FLATPAK_ID[zed]="dev.zed.Zed"

# ─── Lookup function ─────────────────────────────────────────────────────────
# Returns the package name for the current OS, or empty if not available
# Usage: pkg_name "canonical-name"
# Requires: OS variable to be set ("arch"|"ubuntu"|"fedora"|"macos")
pkg_name() {
    local canonical="$1"
    case "$OS" in
        arch)   echo "${PKG_ARCH[$canonical]:-}" ;;
        ubuntu) echo "${PKG_UBUNTU[$canonical]:-}" ;;
        fedora) echo "${PKG_FEDORA[$canonical]:-}" ;;
        macos)  echo "${PKG_MACOS[$canonical]:-}" ;;
    esac
}

# Returns macOS cask name, or empty
cask_name() {
    echo "${PKG_MACOS_CASK[$1]:-}"
}

# Returns flatpak app ID, or empty
flatpak_id() {
    echo "${FLATPAK_ID[$1]:-}"
}

# Smart install: tries native package first, falls back to flatpak
# Usage: smart_install "canonical-name" "display-name"
smart_install() {
    local canonical="$1" display="${2:-$1}"
    local native cask flat

    # macOS: try cask first, then formula
    if [[ "$OS" == "macos" ]]; then
        cask=$(cask_name "$canonical")
        if [[ -n "$cask" ]]; then
            gum_spin "Installing $display..." brew install --cask "$cask"
            return $?
        fi
        native=$(pkg_name "$canonical")
        if [[ -n "$native" ]]; then
            gum_spin "Installing $display..." brew install $native
            return $?
        fi
        warn "$display is not available on macOS"
        return 1
    fi

    # Linux: try native package manager first
    native=$(pkg_name "$canonical")
    if [[ -n "$native" ]]; then
        case "$OS" in
            arch)   gum_spin "Installing $display..." sudo pacman -S --noconfirm --needed $native || \
                    gum_spin "Installing $display (AUR)..." yay -S --noconfirm --needed $native ;;
            ubuntu) gum_spin "Installing $display..." sudo apt-get install -y $native ;;
            fedora) gum_spin "Installing $display..." sudo dnf install -y $native ;;
        esac
        return $?
    fi

    # Fallback to flatpak
    flat=$(flatpak_id "$canonical")
    if [[ -n "$flat" ]]; then
        gum_spin "Installing $display (flatpak)..." flatpak install -y flathub "$flat"
        return $?
    fi

    warn "$display is not available on $OS"
    return 1
}

# ─── File Managers ───────────────────────────────────────────────────────────
PKG_ARCH[nautilus]="nautilus"
PKG_UBUNTU[nautilus]="nautilus"
PKG_FEDORA[nautilus]="nautilus"

PKG_ARCH[nemo]="nemo"
PKG_UBUNTU[nemo]="nemo"
PKG_FEDORA[nemo]="nemo"

PKG_ARCH[thunar]="thunar"
PKG_UBUNTU[thunar]="thunar"
PKG_FEDORA[thunar]="thunar"

PKG_ARCH[pcmanfm]="pcmanfm"
PKG_UBUNTU[pcmanfm]="pcmanfm"
PKG_FEDORA[pcmanfm]="pcmanfm"

# ─── Extra Utilities ─────────────────────────────────────────────────────────
PKG_ARCH[nvtop]="nvtop"
PKG_UBUNTU[nvtop]="nvtop"
PKG_FEDORA[nvtop]="nvtop"

PKG_ARCH[glances]="glances"
PKG_UBUNTU[glances]="glances"
PKG_FEDORA[glances]="glances"

PKG_ARCH[file-roller]="file-roller"
PKG_UBUNTU[file-roller]="file-roller"
PKG_FEDORA[file-roller]="file-roller"

PKG_ARCH[unrar]="unrar"
PKG_UBUNTU[unrar]="unrar"
PKG_FEDORA[unrar]="unrar"

PKG_ARCH[unzip]="unzip"
PKG_UBUNTU[unzip]="unzip"
PKG_FEDORA[unzip]="unzip"

