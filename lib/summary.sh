#!/usr/bin/env bash
# =============================================================================
#  lib/summary.sh — selection summary renderer
#  Sourced by install.sh. Provides:
#    show_summary     render the grouped selection summary + confirm
#
#  Redesign (plan §3.4): grouped counts with a collapsible full detail list
#  instead of a flat 40-line checklist.
# =============================================================================

# _row — print a checkmark row if a flag is true. Used by the detail view.
_row() { [[ "$1" == "true" ]] && echo -e "  ${GREEN}✓${RESET} $2" || true; }

# _count_enabled — echo "n" of enabled flags among args.
_count_enabled() {
    local n=0
    for v in "$@"; do [[ "$v" == "true" ]] && ((n++)); done
    echo "$n"
}

show_summary() {
    phase_header "—" "Review Your Selection"

    # ── Compact grouped counts ───────────────────────────────────────────────
    local wm_n br_n chat_n media_n dev_n notes_n fm_n util_n game_n ai_n dot_n sec_n
    wm_n=$(_count_enabled "$INSTALL_NIRI" "$INSTALL_GNOME" "$INSTALL_I3")
    br_n=$(_count_enabled "$BR_ZEN" "$BR_FLOORP" "$BR_BRAVE" "$BR_FIREFOX" "$BR_EDGE" "$BR_CHROME" "$BR_LIBREWOLF" "$BR_VIVALDI" "$BR_CHROMIUM" "$BR_TOR")
    chat_n=$(_count_enabled "$CHAT_TELEGRAM" "$CHAT_FERDIUM" "$CHAT_DISCORD" "$CHAT_VESKTOP" "$CHAT_SIGNAL" "$CHAT_SLACK" "$CHAT_ELEMENT" "$CHAT_THUNDERBIRD")
    media_n=$(_count_enabled "$MEDIA_MPV" "$MEDIA_VLC" "$MEDIA_YTDLP" "$MEDIA_PARABOLIC" "$MEDIA_CELLULOID" "$MEDIA_OBS" "$MEDIA_KDENLIVE" "$MEDIA_AUDACITY" "$MEDIA_HANDBRAKE" "$MEDIA_SPOTIFY" "$MEDIA_FREETUBE" "$MEDIA_AMBEROL")
    dev_n=$(_count_enabled "$DEV_NEOVIM" "$DEV_VSCODE" "$DEV_DOCKER" "$DEV_NODE" "$DEV_PYTHON" "$DEV_ANDROID" "$DEV_ZED" "$DEV_HELIX" "$DEV_GO" "$DEV_RUST" "$DEV_GH" "$DEV_LAZYGIT" "$DEV_POSTMAN" "$DEV_DBEAVER")
    notes_n=$(_count_enabled "$NOTES_OBSIDIAN" "$NOTES_LOGSEQ" "$NOTES_LIBREOFFICE" "$NOTES_ONLYOFFICE" "$NOTES_ZATHURA" "$NOTES_OKULAR" "$NOTES_MARKER")
    fm_n=$(_count_enabled "$FM_NAUTILUS" "$FM_NEMO" "$FM_THUNAR" "$FM_PCMANFM")
    util_n=$(_count_enabled "$UTIL_BTOP" "$UTIL_HTOP" "$UTIL_NVTOP" "$UTIL_GLANCES" "$UTIL_MISSION" "$UTIL_HELVUM" "$UTIL_MELD" "$UTIL_LOCALSEND" "$UTIL_TIMESHIFT" "$UTIL_KEEPASSXC" "$UTIL_BITWARDEN" "$UTIL_SYNCTHING" "$UTIL_FLAMESHOT" "$UTIL_COPYQ" "$UTIL_VENTOY" "$UTIL_BAOBAB" "$UTIL_GNOME_DISKS" "$UTIL_FILE_ROLLER" "$UTIL_UNRAR" "$UTIL_UNZIP")
    game_n=$(_count_enabled "$GAME_STEAM" "$GAME_LUTRIS" "$GAME_HEROIC" "$GAME_GAMEMODE" "$GAME_MANGOHUD" "$GAME_PROTONUP")
    ai_n=$(_count_enabled "$AI_ANYLLM" "$AI_LMSTUDIO" "$AI_PINOKIO" "$AI_OLLAMA" "$AI_OPENWEBUI" "$AI_JAN")
    dot_n=$(_count_enabled "$DOT_NIRI" "$DOT_WAYBAR" "$DOT_FISH" "$DOT_KITTY" "$DOT_GHOSTTY" "$DOT_ALACRITTY" "$DOT_NVIM" "$DOT_BTOP" "$DOT_FUZZEL" "$DOT_DUNST" "$DOT_GTK" "$DOT_ZATHURA" "$DOT_MPV" "$DOT_RANGER" "$DOT_NOCTALIA" "$DOT_FASTFETCH" "$DOT_APPIMAGELAUNCHER")
    sec_n=$(_count_enabled "$SEC_FAIL2BAN" "$SEC_SSH_HARDEN" "$SEC_DNSSEC" "$SEC_AUTO_UPDATE")

    gum format <<EOF
**Profile:** `${MODE}`

| Category            | Selected |
|---------------------|:--------:|
| 🖥️  Window Manager  | ${wm_n} |
| 🌐 Browsers         | ${br_n} |
| 💬 Chat             | ${chat_n} |
| 🎵 Multimedia       | ${media_n} |
| 🛠️  Development     | ${dev_n} |
| 📝 Notes & Office   | ${notes_n} |
| 📁 File Managers    | ${fm_n} |
| 🔧 Utilities        | ${util_n} |
| 🎮 Gaming           | ${game_n} |
| 🤖 AI & LLMs        | ${ai_n} |
| 📦 Dotfiles         | ${dot_n} |
| 🔒 Security         | ${sec_n} |
EOF

    # ── Optional full detail ────────────────────────────────────────────────
    if gum_confirm "Show the full item-by-item list?"; then
        echo -e "\n${BOLD}  Window Manager${RESET}"
        _row "$INSTALL_NIRI" "Niri/Wayland"; _row "$INSTALL_GNOME" "GNOME"; _row "$INSTALL_I3" "i3/bspwm"

        echo -e "\n${BOLD}  Browsers${RESET}"
        _row "$BR_ZEN" "Zen"; _row "$BR_FIREFOX" "Firefox"; _row "$BR_CHROME" "Chrome"
        _row "$BR_BRAVE" "Brave"; _row "$BR_FLOORP" "Floorp"; _row "$BR_EDGE" "Edge"
        _row "$BR_LIBREWOLF" "Librewolf"; _row "$BR_VIVALDI" "Vivaldi"
        _row "$BR_CHROMIUM" "Chromium"; _row "$BR_TOR" "Tor Browser"

        echo -e "\n${BOLD}  Chat & Messaging${RESET}"
        _row "$CHAT_DISCORD" "Discord"; _row "$CHAT_VESKTOP" "Vesktop"
        _row "$CHAT_TELEGRAM" "Telegram"; _row "$CHAT_SIGNAL" "Signal"
        _row "$CHAT_SLACK" "Slack"; _row "$CHAT_ELEMENT" "Element"
        _row "$CHAT_FERDIUM" "Ferdium"; _row "$CHAT_THUNDERBIRD" "Thunderbird"

        echo -e "\n${BOLD}  Multimedia${RESET}"
        _row "$MEDIA_MPV" "mpv"; _row "$MEDIA_VLC" "VLC"; _row "$MEDIA_YTDLP" "yt-dlp"
        _row "$MEDIA_SPOTIFY" "Spotify"; _row "$MEDIA_OBS" "OBS Studio"
        _row "$MEDIA_KDENLIVE" "Kdenlive"; _row "$MEDIA_AUDACITY" "Audacity"
        _row "$MEDIA_HANDBRAKE" "Handbrake"; _row "$MEDIA_CELLULOID" "Celluloid"
        _row "$MEDIA_PARABOLIC" "Parabolic"; _row "$MEDIA_FREETUBE" "Freetube"
        _row "$MEDIA_AMBEROL" "Amberol"

        echo -e "\n${BOLD}  Development${RESET}"
        _row "$DEV_NEOVIM" "Neovim"; _row "$DEV_VSCODE" "VSCode"; _row "$DEV_ZED" "Zed"
        _row "$DEV_HELIX" "Helix"; _row "$DEV_DOCKER" "Docker"; _row "$DEV_NODE" "Node.js"
        _row "$DEV_PYTHON" "Python"; _row "$DEV_GO" "Go"; _row "$DEV_RUST" "Rust"
        _row "$DEV_GH" "GitHub CLI"; _row "$DEV_LAZYGIT" "lazygit"
        _row "$DEV_POSTMAN" "Postman"; _row "$DEV_DBEAVER" "DBeaver"
        _row "$DEV_ANDROID" "Android SDK"

        echo -e "\n${BOLD}  Notes & Office${RESET}"
        _row "$NOTES_OBSIDIAN" "Obsidian"; _row "$NOTES_LOGSEQ" "Logseq"
        _row "$NOTES_LIBREOFFICE" "LibreOffice"; _row "$NOTES_ONLYOFFICE" "ONLYOFFICE"
        _row "$NOTES_ZATHURA" "Zathura"; _row "$NOTES_OKULAR" "Okular"
        _row "$NOTES_MARKER" "Marker"

        echo -e "\n${BOLD}  File Managers${RESET}"
        _row "$FM_NAUTILUS" "Nautilus"; _row "$FM_NEMO" "Nemo"
        _row "$FM_THUNAR" "Thunar"; _row "$FM_PCMANFM" "PCManFM"

        echo -e "\n${BOLD}  Utilities${RESET}"
        _row "$UTIL_BTOP" "btop"; _row "$UTIL_HTOP" "htop"; _row "$UTIL_NVTOP" "nvtop"; _row "$UTIL_GLANCES" "glances"
        _row "$UTIL_FILE_ROLLER" "file-roller"; _row "$UTIL_UNRAR" "unrar"; _row "$UTIL_UNZIP" "unzip"
        _row "$UTIL_MISSION" "Mission Center"; _row "$UTIL_MELD" "Meld"; _row "$UTIL_LOCALSEND" "LocalSend"
        _row "$UTIL_KEEPASSXC" "KeePassXC"; _row "$UTIL_BITWARDEN" "Bitwarden"
        _row "$UTIL_SYNCTHING" "Syncthing"; _row "$UTIL_FLAMESHOT" "Flameshot"
        _row "$UTIL_COPYQ" "CopyQ"; _row "$UTIL_HELVUM" "Helvum"
        _row "$UTIL_TIMESHIFT" "Timeshift"; _row "$UTIL_VENTOY" "Ventoy"
        _row "$UTIL_BAOBAB" "Baobab"; _row "$UTIL_GNOME_DISKS" "GNOME Disks"

        echo -e "\n${BOLD}  Gaming${RESET}"
        _row "$GAME_STEAM" "Steam"; _row "$GAME_LUTRIS" "Lutris"
        _row "$GAME_HEROIC" "Heroic"; _row "$GAME_GAMEMODE" "Gamemode"
        _row "$GAME_MANGOHUD" "MangoHud"; _row "$GAME_PROTONUP" "ProtonUp-Qt"

        echo -e "\n${BOLD}  AI & LLMs${RESET}"
        _row "$AI_OLLAMA" "Ollama"; _row "$AI_OPENWEBUI" "Open WebUI"
        _row "$AI_JAN" "Jan"; _row "$AI_ANYLLM" "AnythingLLM"
        _row "$AI_LMSTUDIO" "LM Studio"; _row "$AI_PINOKIO" "Pinokio"

        echo -e "\n${BOLD}  Dotfiles${RESET}"
        _row "$DOT_NIRI" "niri"; _row "$DOT_WAYBAR" "waybar"; _row "$DOT_FISH" "fish"
        _row "$DOT_KITTY" "kitty"; _row "$DOT_GHOSTTY" "ghostty"; _row "$DOT_ALACRITTY" "alacritty"
        _row "$DOT_NVIM" "neovim"; _row "$DOT_BTOP" "btop"; _row "$DOT_FUZZEL" "fuzzel"
        _row "$DOT_DUNST" "dunst"; _row "$DOT_GTK" "gtk"; _row "$DOT_ZATHURA" "zathura"
        _row "$DOT_MPV" "mpv"; _row "$DOT_RANGER" "ranger"; _row "$DOT_NOCTALIA" "noctalia"
        _row "$DOT_FASTFETCH" "fastfetch"; _row "$DOT_APPIMAGELAUNCHER" "appimagelauncher"

        echo -e "\n${BOLD}  System${RESET}"
        _row "$INSTALL_CHAOTIC" "Chaotic-AUR/RPM Fusion"; _row "$SYS_SSH" "SSH server"
        _row "$SYS_DOCKER_BOOT" "Docker on boot"; _row "$SYS_FISH_DEFAULT" "fish default shell"

        echo -e "\n${BOLD}  Security${RESET}"
        _row "$SEC_FAIL2BAN" "fail2ban"; _row "$SEC_SSH_HARDEN" "SSH hardening"
        _row "$SEC_DNSSEC" "DNSSEC"; _row "$SEC_AUTO_UPDATE" "Auto updates"
        echo ""
    fi

    echo ""
    gum_confirm "Everything look good? Start the installation?" || { warn "Aborted by user."; exit 0; }
}
