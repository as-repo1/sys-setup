#!/usr/bin/env bash
# =============================================================================
#  lib/ui.sh — gum TUI primitives
#  Sourced by install.sh. Requires `gum` to be installed (bootstrap_gum first).
#  Provides:
#    gum_choose_multi   multi-select checkbox list
#    gum_choose_single  single-select list
#    gum_confirm        yes/no prompt
#    gum_input          text input (with prefill, skippable)
#    gum_spin           spinner that CAPTURES the real exit code (bug #3)
#    banner             startup banner
#    phase_header       "◆ Phase N of TOTAL · Title ◆"
#    section            small subsection label
#    dry_run_notice     the dry-run warning strip
#
#  Bugfixes vs original:
#    • gum_spin now returns the wrapped command's real exit code (bug #3)
#      so success()/warn() after it are trustworthy.
# =============================================================================

# ─── Selection primitives ────────────────────────────────────────────────────
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

gum_choose_single() {
    local header="$1"; shift
    gum choose \
        --header="$header" \
        --header.foreground="$NORD8" \
        --cursor.foreground="$NORD12" \
        --item.foreground="$NORD4" \
        --selected.foreground="$NORD14" \
        --cursor-prefix="[▶] " \
        "$@"
}

gum_confirm() {
    gum confirm \
        --affirmative="Yes" \
        --negative="No" \
        --prompt.foreground="$NORD8" \
        --selected.background="$NORD12" \
        --selected.foreground="$NORD0" \
        "$1"
}

# gum_input — text prompt. Args: prompt [prefill]
gum_input() {
    local prompt="$1" prefill="${2:-}"
    if [[ -n "$prefill" ]]; then
        gum input --prompt="$prompt" --value="$prefill" \
            --cursor.foreground="$NORD8" --prompt.foreground="$NORD9"
    else
        gum input --prompt="$prompt" --placeholder="…" \
            --cursor.foreground="$NORD8" --prompt.foreground="$NORD9"
    fi
}

# ─── gum_spin — the critical exit-code fix ───────────────────────────────────
# gum's own spin masks the inner command's exit status. We run the command
# ourselves to a temp log, then feed gum a dummy spinner, and return the real
# status. This makes downstream success()/warn() accurate (bug #3).
gum_spin() {
    local title="$1"; shift

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[dry-run]${RESET} $title  →  $*"
        return 0
    fi

    local real_rc=0 tmp
    tmp="$(mktemp)"

    # Run the real command in the background, capturing its exit code.
    ( "$@" ) > "$tmp" 2>&1 &
    local pid=$!

    # Show a spinner until the background job finishes.
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' i=0
    tput civis 2>/dev/null || true
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${ORANGE}${spin:i++%10:1}${RESET} ${CYAN}%s${RESET}" "$title"
        sleep 0.08
    done
    wait "$pid"; real_rc=$?
    printf "\r\033[K"  # clear the spinner line

    tput cnorm 2>/dev/null || true

    # Fold captured output into the main log.
    cat "$tmp" >> "$LOG_FILE"
    rm -f "$tmp"
    return "$real_rc"
}

# ─── Visual headers ──────────────────────────────────────────────────────────
banner() {
    clear
    echo ""
    gum style \
        --foreground="$NORD8" --border-foreground="$NORD7" \
        --border=double --align=center \
        --width="$UI_WIDTH" --margin="1 2" --padding="1 3" \
        "$(cat <<'ASCII'
  SYSTEM OPERATIONAL // UPLINK-9000

  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗
  ██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔════╝
  ██║     ███████║███████║██║   ██║███████╗
  ██║     ██╔══██║██╔══██║██║   ██║╚════██║
  ╚██████╗██║  ██║██║  ██║╚██████╔╝███████║
   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝

  NSF SOL — O'NEIL // FORCE IN READINESS
ASCII
)"
    gum style --foreground="$NORD12" --bold --align=center \
        --width="$UI_WIDTH" --margin="0 2" \
        "Workstation Bootstrap  ·  sys-setup"
    gum style --foreground="$NORD3" --align=center \
        --width="$UI_WIDTH" --margin="0 2" \
        "OS: $DISTRO_PRETTY  ·  LOG → $LOG_FILE"
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        dry_run_notice
    fi
    echo ""
}

# phase_header — "◆ Phase N of TOTAL · Title ◆"
phase_header() {
    local n="$1" title="$2"
    echo ""
    gum style \
        --foreground="$NORD8" --border-foreground="$NORD7" \
        --border=double --align=center \
        --width="$UI_WIDTH" --margin="0 2" --padding="0 1" --bold \
        "Phase $n of $TOTAL_PHASES  ·  $title"
    echo ""
}

section() {
    echo ""
    gum style --foreground="$NORD9" --bold --margin="0 3" "▌ $1"
}

dry_run_notice() {
    gum style --foreground="$NORD13" --bold --align=center \
        --width="$UI_WIDTH" --margin="0 2" \
        "⚡ DRY RUN MODE — NO CHANGES WILL BE WRITTEN"
}
