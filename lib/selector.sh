#!/usr/bin/env bash
# =============================================================================
#  lib/selector.sh — Custom-profile category selectors
#  Sourced by install.sh. Provides:
#    run_custom_profile   interactive category → sub-selection flow
#
#  Bugfix vs original (bug #14): every gum choose item now carries a STABLE
#  leading token of the form "ZZ·" — matching is done on that token, so names
#  that share substrings (e.g. "Go" vs "Google Chrome") never collide.
# =============================================================================

# has() — does the selection blob contain a given token? Tokens are of the
# form "NN·Word"; we match the marker + first word to stay unambiguous.
has() { [[ "$1" == *"$2"* ]]; }

run_custom_profile() {
    # Build category list
    local -a categories=(
        "🖥️  Desktop / Window Manager"
        "🌐 Browsers"
        "💬 Chat & Messaging"
        "🎵 Multimedia"
        "🛠️  Development Tools"
        "📝 Notes & Office"
        "📁 File Managers"
        "🔧 Utilities"
        "🎮 Gaming"
        "🤖 AI & Local LLMs"
        "📦 Dotfiles"
        "⚙️  System Options"
        "🔒 Security & Hardening"
    )

    local cat_opts
    cat_opts=$(gum_choose_multi "  Select categories to customize" "${categories[@]}")

    # ── Window Manager ───────────────────────────────────────────────────────
    if has "$cat_opts" "Window Manager"; then
        INSTALL_NIRI=false; INSTALL_GNOME=false; INSTALL_I3=false
        local wm_opts
        wm_opts=$(gum_choose_multi "  Desktop / Window Manager" \
            "01·Niri   (Wayland tiling — recommended)" \
            "02·GNOME  (full desktop)" \
            "03·i3     (X11 tiling + bspwm)")
        has "$wm_opts" "01·Niri"   && INSTALL_NIRI=true
        has "$wm_opts" "02·GNOME"  && INSTALL_GNOME=true
        has "$wm_opts" "03·i3"     && INSTALL_I3=true
    fi

    # ── Browsers ─────────────────────────────────────────────────────────────
    if has "$cat_opts" "Browsers"; then
        BR_ZEN=false; BR_FLOORP=false; BR_BRAVE=false; BR_FIREFOX=false; BR_EDGE=false
        BR_CHROME=false; BR_LIBREWOLF=false; BR_VIVALDI=false; BR_CHROMIUM=false; BR_TOR=false
        local br_opts
        br_opts=$(gum_choose_multi "  Browsers  (pick any)" \
            "01·Zen Browser     — Firefox-based, privacy" \
            "02·Firefox         — Mozilla's browser" \
            "03·Google Chrome   — Google's browser" \
            "04·Brave           — Chromium + ad-block" \
            "05·Floorp          — Firefox-based, customizable" \
            "06·Microsoft Edge  — Chromium-based" \
            "07·Librewolf       — Hardened Firefox fork" \
            "08·Vivaldi         — Feature-rich Chromium" \
            "09·Chromium        — Open-source Chrome" \
            "10·Tor Browser     — Anonymous browsing")
        has "$br_opts" "01·" && BR_ZEN=true
        has "$br_opts" "02·" && BR_FIREFOX=true
        has "$br_opts" "03·" && BR_CHROME=true
        has "$br_opts" "04·" && BR_BRAVE=true
        has "$br_opts" "05·" && BR_FLOORP=true
        has "$br_opts" "06·" && BR_EDGE=true
        has "$br_opts" "07·" && BR_LIBREWOLF=true
        has "$br_opts" "08·" && BR_VIVALDI=true
        has "$br_opts" "09·" && BR_CHROMIUM=true
        has "$br_opts" "10·" && BR_TOR=true
    fi

    # ── Chat & Messaging ─────────────────────────────────────────────────────
    if has "$cat_opts" "Chat"; then
        CHAT_TELEGRAM=false; CHAT_FERDIUM=false; CHAT_DISCORD=false; CHAT_VESKTOP=false
        CHAT_SIGNAL=false; CHAT_SLACK=false; CHAT_ELEMENT=false; CHAT_THUNDERBIRD=false
        local chat_opts
        chat_opts=$(gum_choose_multi "  Chat & Messaging" \
            "01·Discord         — Gaming/communities" \
            "02·Vesktop         — Better Discord client" \
            "03·Telegram        — Telegram messenger" \
            "04·Signal          — Encrypted messenger" \
            "05·Slack           — Team communication" \
            "06·Element         — Matrix client (decentralized)" \
            "07·Ferdium         — All-in-one messenger hub" \
            "08·Thunderbird     — Email client")
        has "$chat_opts" "01·" && CHAT_DISCORD=true
        has "$chat_opts" "02·" && CHAT_VESKTOP=true
        has "$chat_opts" "03·" && CHAT_TELEGRAM=true
        has "$chat_opts" "04·" && CHAT_SIGNAL=true
        has "$chat_opts" "05·" && CHAT_SLACK=true
        has "$chat_opts" "06·" && CHAT_ELEMENT=true
        has "$chat_opts" "07·" && CHAT_FERDIUM=true
        has "$chat_opts" "08·" && CHAT_THUNDERBIRD=true
    fi

    # ── Multimedia ───────────────────────────────────────────────────────────
    if has "$cat_opts" "Multimedia"; then
        MEDIA_MPV=false; MEDIA_VLC=false; MEDIA_YTDLP=false; MEDIA_PARABOLIC=false
        MEDIA_CELLULOID=false; MEDIA_OBS=false; MEDIA_KDENLIVE=false; MEDIA_AUDACITY=false
        MEDIA_HANDBRAKE=false; MEDIA_SPOTIFY=false; MEDIA_FREETUBE=false; MEDIA_AMBEROL=false
        local media_opts
        media_opts=$(gum_choose_multi "  Multimedia" \
            "01·mpv         — Lightweight video player" \
            "02·VLC         — Universal media player" \
            "03·yt-dlp      — Video downloader (CLI)" \
            "04·Spotify     — Music streaming" \
            "05·OBS Studio  — Screen recording/streaming" \
            "06·Kdenlive    — Video editor" \
            "07·Audacity    — Audio editor" \
            "08·Handbrake   — Video transcoder" \
            "09·Celluloid   — GTK frontend for mpv" \
            "10·Parabolic   — GUI video downloader" \
            "11·Freetube    — Private YouTube client" \
            "12·Amberol     — Simple music player")
        has "$media_opts" "01·" && MEDIA_MPV=true
        has "$media_opts" "02·" && MEDIA_VLC=true
        has "$media_opts" "03·" && MEDIA_YTDLP=true
        has "$media_opts" "04·" && MEDIA_SPOTIFY=true
        has "$media_opts" "05·" && MEDIA_OBS=true
        has "$media_opts" "06·" && MEDIA_KDENLIVE=true
        has "$media_opts" "07·" && MEDIA_AUDACITY=true
        has "$media_opts" "08·" && MEDIA_HANDBRAKE=true
        has "$media_opts" "09·" && MEDIA_CELLULOID=true
        has "$media_opts" "10·" && MEDIA_PARABOLIC=true
        has "$media_opts" "11·" && MEDIA_FREETUBE=true
        has "$media_opts" "12·" && MEDIA_AMBEROL=true
    fi

    # ── Development Tools ────────────────────────────────────────────────────
    if has "$cat_opts" "Development"; then
        DEV_NEOVIM=false; DEV_VSCODE=false; DEV_DOCKER=false; DEV_NODE=false; DEV_PYTHON=false
        DEV_ANDROID=false; DEV_ZED=false; DEV_HELIX=false; DEV_GO=false; DEV_RUST=false
        DEV_GH=false; DEV_LAZYGIT=false; DEV_POSTMAN=false; DEV_DBEAVER=false
        local dev_opts
        dev_opts=$(gum_choose_multi "  Development Tools" \
            "01·Neovim             — Terminal editor" \
            "02·VSCode             — GUI editor" \
            "03·Zed                — Fast collaborative editor" \
            "04·Helix              — Modal terminal editor" \
            "05·Docker             — Containers" \
            "06·Node.js            — JavaScript runtime" \
            "07·Python             — Python runtime" \
            "08·Go                 — Go language" \
            "09·Rust               — Rust toolchain (rustup)" \
            "10·GitHub CLI (gh)    — GitHub from terminal" \
            "11·lazygit            — Terminal git UI" \
            "12·Postman            — API testing" \
            "13·DBeaver            — Database client" \
            "14·Android SDK        — Mobile dev + scrcpy")
        has "$dev_opts" "01·" && DEV_NEOVIM=true
        has "$dev_opts" "02·" && DEV_VSCODE=true
        has "$dev_opts" "03·" && DEV_ZED=true
        has "$dev_opts" "04·" && DEV_HELIX=true
        has "$dev_opts" "05·" && DEV_DOCKER=true
        has "$dev_opts" "06·" && DEV_NODE=true
        has "$dev_opts" "07·" && DEV_PYTHON=true
        has "$dev_opts" "08·" && DEV_GO=true
        has "$dev_opts" "09·" && DEV_RUST=true
        has "$dev_opts" "10·" && DEV_GH=true
        has "$dev_opts" "11·" && DEV_LAZYGIT=true
        has "$dev_opts" "12·" && DEV_POSTMAN=true
        has "$dev_opts" "13·" && DEV_DBEAVER=true
        has "$dev_opts" "14·" && DEV_ANDROID=true
    fi

    # ── Notes & Office ───────────────────────────────────────────────────────
    if has "$cat_opts" "Notes"; then
        NOTES_OBSIDIAN=false; NOTES_LOGSEQ=false; NOTES_LIBREOFFICE=false; NOTES_ONLYOFFICE=false
        NOTES_ZATHURA=false;  NOTES_OKULAR=false;  NOTES_MARKER=false
        local notes_opts
        notes_opts=$(gum_choose_multi "  Notes & Office" \
            "01·Obsidian     — Markdown knowledge base" \
            "02·Logseq       — Outline-based notes" \
            "03·LibreOffice  — Full office suite" \
            "04·ONLYOFFICE   — MS Office compatible" \
            "05·Zathura      — Minimal PDF viewer" \
            "06·Okular       — Feature-rich PDF viewer" \
            "07·Marker       — Markdown editor")
        has "$notes_opts" "01·" && NOTES_OBSIDIAN=true
        has "$notes_opts" "02·" && NOTES_LOGSEQ=true
        has "$notes_opts" "03·" && NOTES_LIBREOFFICE=true
        has "$notes_opts" "04·" && NOTES_ONLYOFFICE=true
        has "$notes_opts" "05·" && NOTES_ZATHURA=true
        has "$notes_opts" "06·" && NOTES_OKULAR=true
        has "$notes_opts" "07·" && NOTES_MARKER=true
    fi

    # ── File Managers ────────────────────────────────────────────────────────
    if has "$cat_opts" "File Managers"; then
        FM_NAUTILUS=false; FM_NEMO=false; FM_THUNAR=false; FM_PCMANFM=false
        local fm_opts
        fm_opts=$(gum_choose_multi "  File Managers" \
            "01·Nautilus — GNOME default" \
            "02·Nemo     — Cinnamon default" \
            "03·Thunar   — XFCE default" \
            "04·PCManFM  — LXDE default")
        has "$fm_opts" "01·" && FM_NAUTILUS=true
        has "$fm_opts" "02·" && FM_NEMO=true
        has "$fm_opts" "03·" && FM_THUNAR=true
        has "$fm_opts" "04·" && FM_PCMANFM=true
    fi

    # ── Utilities ────────────────────────────────────────────────────────────
    if has "$cat_opts" "Utilities"; then
        UTIL_BTOP=false; UTIL_HTOP=false; UTIL_NVTOP=false; UTIL_GLANCES=false
        UTIL_FILE_ROLLER=false; UTIL_UNRAR=false; UTIL_UNZIP=false
        UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=false
        UTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_KEEPASSXC=false; UTIL_BITWARDEN=false
        UTIL_SYNCTHING=false; UTIL_FLAMESHOT=false; UTIL_COPYQ=false; UTIL_VENTOY=false
        UTIL_BAOBAB=false;   UTIL_GNOME_DISKS=false
        local util_opts
        util_opts=$(gum_choose_multi "  Utilities" \
            "01·btop            — Resource monitor (TUI)" \
            "02·htop            — Classic resource monitor" \
            "03·nvtop           — GPU monitor" \
            "04·glances         — Advanced system monitor" \
            "05·file-roller     — Archive manager (GUI)" \
            "06·unrar           — RAR extractor (CLI)" \
            "07·unzip           — ZIP extractor (CLI)" \
            "08·Mission Center  — Resource monitor (GUI)" \
            "09·Meld            — Diff & merge tool" \
            "10·LocalSend       — Cross-device file sharing" \
            "11·KeePassXC       — Password manager (local)" \
            "12·Bitwarden       — Password manager (cloud)" \
            "13·Syncthing       — File synchronization" \
            "14·Flameshot       — Screenshot tool" \
            "15·CopyQ           — Clipboard manager" \
            "16·Helvum          — Audio patchbay (PipeWire)" \
            "17·Timeshift       — System backup/restore" \
            "18·Ventoy          — Bootable USB creator" \
            "19·Baobab          — Disk usage analyzer" \
            "20·GNOME Disks     — Disk management")
        has "$util_opts" "01·" && UTIL_BTOP=true
        has "$util_opts" "02·" && UTIL_HTOP=true
        has "$util_opts" "03·" && UTIL_NVTOP=true
        has "$util_opts" "04·" && UTIL_GLANCES=true
        has "$util_opts" "05·" && UTIL_FILE_ROLLER=true
        has "$util_opts" "06·" && UTIL_UNRAR=true
        has "$util_opts" "07·" && UTIL_UNZIP=true
        has "$util_opts" "08·" && UTIL_MISSION=true
        has "$util_opts" "09·" && UTIL_MELD=true
        has "$util_opts" "10·" && UTIL_LOCALSEND=true
        has "$util_opts" "11·" && UTIL_KEEPASSXC=true
        has "$util_opts" "12·" && UTIL_BITWARDEN=true
        has "$util_opts" "13·" && UTIL_SYNCTHING=true
        has "$util_opts" "14·" && UTIL_FLAMESHOT=true
        has "$util_opts" "15·" && UTIL_COPYQ=true
        has "$util_opts" "16·" && UTIL_HELVUM=true
        has "$util_opts" "17·" && UTIL_TIMESHIFT=true
        has "$util_opts" "18·" && UTIL_VENTOY=true
        has "$util_opts" "19·" && UTIL_BAOBAB=true
        has "$util_opts" "20·" && UTIL_GNOME_DISKS=true
    fi

    # ── Gaming ───────────────────────────────────────────────────────────────
    if has "$cat_opts" "Gaming"; then
        GAME_STEAM=false; GAME_LUTRIS=false; GAME_HEROIC=false
        GAME_GAMEMODE=false; GAME_MANGOHUD=false; GAME_PROTONUP=false
        local game_opts
        game_opts=$(gum_choose_multi "  Gaming" \
            "01·Steam       — Valve's game store" \
            "02·Lutris      — Game manager (Wine/Proton)" \
            "03·Heroic      — Epic/GOG/Amazon launcher" \
            "04·Gamemode    — CPU/GPU game optimizer" \
            "05·MangoHud    — FPS overlay" \
            "06·ProtonUp    — Proton version manager")
        has "$game_opts" "01·" && GAME_STEAM=true
        has "$game_opts" "02·" && GAME_LUTRIS=true
        has "$game_opts" "03·" && GAME_HEROIC=true
        has "$game_opts" "04·" && GAME_GAMEMODE=true
        has "$game_opts" "05·" && GAME_MANGOHUD=true
        has "$game_opts" "06·" && GAME_PROTONUP=true
    fi

    # ── AI & Local LLMs ──────────────────────────────────────────────────────
    if has "$cat_opts" "AI"; then
        AI_ANYLLM=false; AI_LMSTUDIO=false; AI_PINOKIO=false
        AI_OLLAMA=false; AI_OPENWEBUI=false; AI_JAN=false
        local ai_opts
        ai_opts=$(gum_choose_multi "  AI & Local LLMs" \
            "01·Ollama       — Local LLM server" \
            "02·Open WebUI   — Chat UI for Ollama" \
            "03·Jan          — Offline AI assistant" \
            "04·AnythingLLM  — AI workspace (AppImage)" \
            "05·LM Studio    — Local LLM runner (AppImage)" \
            "06·Pinokio      — AI app browser (AppImage)")
        has "$ai_opts" "01·" && AI_OLLAMA=true
        has "$ai_opts" "02·" && AI_OPENWEBUI=true
        has "$ai_opts" "03·" && AI_JAN=true
        has "$ai_opts" "04·" && AI_ANYLLM=true
        has "$ai_opts" "05·" && AI_LMSTUDIO=true
        has "$ai_opts" "06·" && AI_PINOKIO=true
    fi

    # ── Dotfiles ─────────────────────────────────────────────────────────────
    if has "$cat_opts" "Dotfiles"; then
        DOT_NIRI=false; DOT_WAYBAR=false; DOT_FISH=false; DOT_KITTY=false
        DOT_GHOSTTY=false; DOT_ALACRITTY=false; DOT_NVIM=false; DOT_BTOP=false
        DOT_FUZZEL=false; DOT_DUNST=false; DOT_GTK=false; DOT_ZATHURA=false
        DOT_MPV=false; DOT_RANGER=false; DOT_NOCTALIA=false; DOT_FASTFETCH=false
        DOT_APPIMAGELAUNCHER=false
        local dot_opts
        dot_opts=$(gum_choose_multi "  Dotfiles  (configs to stow into ~)" \
            "01·niri              — WM config + keybinds" \
            "02·waybar            — Status bar" \
            "03·fish              — Shell config + aliases" \
            "04·kitty             — Terminal emulator" \
            "05·ghostty           — Terminal emulator" \
            "06·alacritty         — Terminal emulator" \
            "07·neovim            — Editor config" \
            "08·btop              — Monitor theme" \
            "09·fuzzel            — App launcher" \
            "10·dunst             — Notifications" \
            "11·gtk               — GTK3/4 themes" \
            "12·zathura           — PDF viewer" \
            "13·mpv               — Media player" \
            "14·ranger            — File manager" \
            "15·noctalia          — Noctalia shell" \
            "16·fastfetch         — System info" \
            "17·appimagelauncher  — AppImage config")
        has "$dot_opts" "01·" && DOT_NIRI=true
        has "$dot_opts" "02·" && DOT_WAYBAR=true
        has "$dot_opts" "03·" && DOT_FISH=true
        has "$dot_opts" "04·" && DOT_KITTY=true
        has "$dot_opts" "05·" && DOT_GHOSTTY=true
        has "$dot_opts" "06·" && DOT_ALACRITTY=true
        has "$dot_opts" "07·" && DOT_NVIM=true
        has "$dot_opts" "08·" && DOT_BTOP=true
        has "$dot_opts" "09·" && DOT_FUZZEL=true
        has "$dot_opts" "10·" && DOT_DUNST=true
        has "$dot_opts" "11·" && DOT_GTK=true
        has "$dot_opts" "12·" && DOT_ZATHURA=true
        has "$dot_opts" "13·" && DOT_MPV=true
        has "$dot_opts" "14·" && DOT_RANGER=true
        has "$dot_opts" "15·" && DOT_NOCTALIA=true
        has "$dot_opts" "16·" && DOT_FASTFETCH=true
        has "$dot_opts" "17·" && DOT_APPIMAGELAUNCHER=true
    fi

    # ── System Options ───────────────────────────────────────────────────────
    if has "$cat_opts" "System Options"; then
        INSTALL_CHAOTIC=false; SYS_SSH=false; SYS_DOCKER_BOOT=false; SYS_FISH_DEFAULT=false
        local sys_opts
        sys_opts=$(gum_choose_multi "  System Options" \
            "01·Chaotic-AUR / RPM Fusion  — pre-built community packages" \
            "02·Enable SSH server" \
            "03·Enable Docker on boot" \
            "04·Set fish as default shell")
        has "$sys_opts" "01·" && INSTALL_CHAOTIC=true
        has "$sys_opts" "02·" && SYS_SSH=true
        has "$sys_opts" "03·" && SYS_DOCKER_BOOT=true
        has "$sys_opts" "04·" && SYS_FISH_DEFAULT=true
    fi

    # ── Security & Hardening ─────────────────────────────────────────────────
    if has "$cat_opts" "Security"; then
        SEC_FAIL2BAN=false; SEC_SSH_HARDEN=false; SEC_DNSSEC=false; SEC_AUTO_UPDATE=false
        local sec_opts
        sec_opts=$(gum_choose_multi "  Security & Hardening" \
            "01·fail2ban        — Ban brute-force IPs" \
            "02·Harden SSH      — Disable root login, key-only" \
            "03·Enable DNSSEC   — DNS security via systemd-resolved" \
            "04·Auto updates    — paccache/unattended/dnf-automatic")
        has "$sec_opts" "01·" && SEC_FAIL2BAN=true
        has "$sec_opts" "02·" && SEC_SSH_HARDEN=true
        has "$sec_opts" "03·" && SEC_DNSSEC=true
        has "$sec_opts" "04·" && SEC_AUTO_UPDATE=true
    fi
}
