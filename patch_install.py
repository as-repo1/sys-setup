import sys

with open('install.sh', 'r') as f:
    content = f.read()

# Add File Managers defaults
content = content.replace(
    'NOTES_ZATHURA=false; NOTES_OKULAR=false; NOTES_MARKER=false\n\n# Utilities\n',
    'NOTES_ZATHURA=false; NOTES_OKULAR=false; NOTES_MARKER=false\n\n# File Managers\nFM_NAUTILUS=true; FM_NEMO=false; FM_THUNAR=false; FM_PCMANFM=false\n\n# Utilities\n'
)

# Add File Managers to Complete Override
content = content.replace(
    'NOTES_ZATHURA=true; NOTES_OKULAR=true; NOTES_MARKER=true\n\n    UTIL_BTOP=true; UTIL_MISSION=true;',
    'NOTES_ZATHURA=true; NOTES_OKULAR=true; NOTES_MARKER=true\n\n    FM_NAUTILUS=true; FM_NEMO=true; FM_THUNAR=true; FM_PCMANFM=true\n\n    UTIL_BTOP=true; UTIL_MISSION=true;'
)

# Update Utilities variables in defaults
content = content.replace(
    'UTIL_BTOP=true; UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=true\nUTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_KEEPASSXC=false; UTIL_BITWARDEN=false\nUTIL_SYNCTHING=false; UTIL_FLAMESHOT=false; UTIL_COPYQ=false; UTIL_VENTOY=false\nUTIL_BAOBAB=false; UTIL_GNOME_DISKS=false',
    'UTIL_BTOP=true; UTIL_HTOP=true; UTIL_NVTOP=true; UTIL_GLANCES=false; UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=true\nUTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_KEEPASSXC=false; UTIL_BITWARDEN=false\nUTIL_SYNCTHING=false; UTIL_FLAMESHOT=false; UTIL_COPYQ=false; UTIL_VENTOY=false\nUTIL_BAOBAB=false; UTIL_GNOME_DISKS=false; UTIL_FILE_ROLLER=true; UTIL_UNRAR=true; UTIL_UNZIP=true'
)

# Update Utilities variables in Complete Override
content = content.replace(
    'UTIL_BTOP=true; UTIL_MISSION=true; UTIL_HELVUM=true; UTIL_MELD=true\n    UTIL_LOCALSEND=true; UTIL_TIMESHIFT=true; UTIL_KEEPASSXC=true; UTIL_BITWARDEN=true\n    UTIL_SYNCTHING=true; UTIL_FLAMESHOT=true; UTIL_COPYQ=true; UTIL_VENTOY=true\n    UTIL_BAOBAB=true; UTIL_GNOME_DISKS=true',
    'UTIL_BTOP=true; UTIL_HTOP=true; UTIL_NVTOP=true; UTIL_GLANCES=true; UTIL_MISSION=true; UTIL_HELVUM=true; UTIL_MELD=true\n    UTIL_LOCALSEND=true; UTIL_TIMESHIFT=true; UTIL_KEEPASSXC=true; UTIL_BITWARDEN=true\n    UTIL_SYNCTHING=true; UTIL_FLAMESHOT=true; UTIL_COPYQ=true; UTIL_VENTOY=true\n    UTIL_BAOBAB=true; UTIL_GNOME_DISKS=true; UTIL_FILE_ROLLER=true; UTIL_UNRAR=true; UTIL_UNZIP=true'
)

# Add File Managers to categories
content = content.replace(
    '    CATEGORIES+=("📝 Notes & Office")\n    CATEGORIES+=("🔧 Utilities")',
    '    CATEGORIES+=("📝 Notes & Office")\n    CATEGORIES+=("📁 File Managers")\n    CATEGORIES+=("🔧 Utilities")'
)

# Add File Managers Custom logic after Notes & Office Custom logic
notes_logic = '''        [[ "$NOTES_OPTS" == *"Okular"*       ]] && NOTES_OKULAR=true
        [[ "$NOTES_OPTS" == *"Marker"*       ]] && NOTES_MARKER=true
    fi'''

fm_logic = '''

    # ── File Managers ────────────────────────────────────────────────────────
    if [[ "$CAT_OPTS" == *"File Managers"* ]]; then
        FM_NAUTILUS=false; FM_NEMO=false; FM_THUNAR=false; FM_PCMANFM=false
        FM_OPTS=$(gum_choose_multi "  File Managers" \\
            "Nautilus           — GNOME default" \\
            "Nemo               — Cinnamon default" \\
            "Thunar             — XFCE default" \\
            "PCManFM            — LXDE default")
        [[ "$FM_OPTS" == *"Nautilus"* ]] && FM_NAUTILUS=true
        [[ "$FM_OPTS" == *"Nemo"*     ]] && FM_NEMO=true
        [[ "$FM_OPTS" == *"Thunar"*   ]] && FM_THUNAR=true
        [[ "$FM_OPTS" == *"PCManFM"*  ]] && FM_PCMANFM=true
    fi'''

content = content.replace(notes_logic, notes_logic + fm_logic)

# Update Utilities Custom logic
util_defaults = '''        UTIL_BTOP=false; UTIL_MISSION=false; UTIL_HELVUM=false; UTIL_MELD=false
        UTIL_LOCALSEND=false; UTIL_TIMESHIFT=false; UTIL_KEEPASSXC=false; UTIL_BITWARDEN=false
        UTIL_SYNCTHING=false; UTIL_FLAMESHOT=false; UTIL_COPYQ=false; UTIL_VENTOY=false
        UTIL_BAOBAB=false; UTIL_GNOME_DISKS=false'''
util_defaults_new = util_defaults.replace('UTIL_BTOP=false;', 'UTIL_BTOP=false; UTIL_HTOP=false; UTIL_NVTOP=false; UTIL_GLANCES=false; UTIL_FILE_ROLLER=false; UTIL_UNRAR=false; UTIL_UNZIP=false;')
content = content.replace(util_defaults, util_defaults_new)

util_opts = '''        UTIL_OPTS=$(gum_choose_multi "  Utilities" \\
            "btop               — Resource monitor (TUI)" \\
            "Mission Center     — Resource monitor (GUI)" \\'''
util_opts_new = '''        UTIL_OPTS=$(gum_choose_multi "  Utilities" \\
            "btop               — Resource monitor (TUI)" \\
            "htop               — Classic resource monitor" \\
            "nvtop              — GPU monitor" \\
            "glances            — Advanced system monitor" \\
            "file-roller        — Archive manager (GUI)" \\
            "unrar              — RAR extractor (CLI)" \\
            "unzip              — ZIP extractor (CLI)" \\
            "Mission Center     — Resource monitor (GUI)" \\'''
content = content.replace(util_opts, util_opts_new)

util_logic = '''        [[ "$UTIL_OPTS" == *"btop"*        ]] && UTIL_BTOP=true'''
util_logic_new = '''        [[ "$UTIL_OPTS" == *"btop"*        ]] && UTIL_BTOP=true
        [[ "$UTIL_OPTS" == *"htop"*        ]] && UTIL_HTOP=true
        [[ "$UTIL_OPTS" == *"nvtop"*       ]] && UTIL_NVTOP=true
        [[ "$UTIL_OPTS" == *"glances"*     ]] && UTIL_GLANCES=true
        [[ "$UTIL_OPTS" == *"file-roller"* ]] && UTIL_FILE_ROLLER=true
        [[ "$UTIL_OPTS" == *"unrar"*       ]] && UTIL_UNRAR=true
        [[ "$UTIL_OPTS" == *"unzip"*       ]] && UTIL_UNZIP=true'''
content = content.replace(util_logic, util_logic_new)

# Add to Summary
notes_summary = '''make_row $NOTES_ZATHURA "Zathura"; make_row $NOTES_OKULAR "Okular"
make_row $NOTES_MARKER "Marker"'''
fm_summary = '''

echo -e "\\n${BOLD}  File Managers${RESET}"
make_row $FM_NAUTILUS "Nautilus"; make_row $FM_NEMO "Nemo"
make_row $FM_THUNAR "Thunar"; make_row $FM_PCMANFM "PCManFM"'''
content = content.replace(notes_summary, notes_summary + fm_summary)

# Utilities summary
util_summary = '''make_row $UTIL_BTOP "btop"; make_row $UTIL_MISSION "Mission Center"'''
util_summary_new = '''make_row $UTIL_BTOP "btop"; make_row $UTIL_HTOP "htop"; make_row $UTIL_NVTOP "nvtop"; make_row $UTIL_GLANCES "glances"
make_row $UTIL_FILE_ROLLER "file-roller"; make_row $UTIL_UNRAR "unrar"; make_row $UTIL_UNZIP "unzip"
make_row $UTIL_MISSION "Mission Center"'''
content = content.replace(util_summary, util_summary_new)

# Add to Installation logic
notes_install = '''$NOTES_OKULAR      && { smart_install "okular" "Okular";             success "Okular installed"; }
$NOTES_MARKER      && { smart_install "marker" "Marker";             success "Marker installed"; }'''
fm_install = '''

# File Managers
$FM_NAUTILUS && { smart_install "nautilus" "Nautilus"; success "Nautilus installed"; }
$FM_NEMO     && { smart_install "nemo" "Nemo";         success "Nemo installed"; }
$FM_THUNAR   && { smart_install "thunar" "Thunar";     success "Thunar installed"; }
$FM_PCMANFM  && { smart_install "pcmanfm" "PCManFM";   success "PCManFM installed"; }'''
content = content.replace(notes_install, notes_install + fm_install)

# Utilities install
util_install = '''$UTIL_BTOP        && { smart_install "btop" "btop";                   success "btop installed"; }'''
util_install_new = '''$UTIL_BTOP        && { smart_install "btop" "btop";                   success "btop installed"; }
$UTIL_HTOP        && { smart_install "htop" "htop";                   success "htop installed"; }
$UTIL_NVTOP       && { smart_install "nvtop" "nvtop";                 success "nvtop installed"; }
$UTIL_GLANCES     && { smart_install "glances" "glances";             success "glances installed"; }
$UTIL_FILE_ROLLER && { smart_install "file-roller" "file-roller";     success "file-roller installed"; }
$UTIL_UNRAR       && { smart_install "unrar" "unrar";                 success "unrar installed"; }
$UTIL_UNZIP       && { smart_install "unzip" "unzip";                 success "unzip installed"; }'''
content = content.replace(util_install, util_install_new)

with open('install.sh', 'w') as f:
    f.write(content)

