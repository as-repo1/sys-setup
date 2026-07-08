#!/usr/bin/env bash
# =============================================================================
#  lib/log.sh — logging + command runner
#  Sourced by install.sh. Provides:
#    log / success / warn / error   pretty, log-file-aware printers
#    run                             run a command, capture real exit code
#    die                             error + exit
#
#  Bugfixes vs original:
#    • DRY_RUN no longer appends to the log (bug #15)
#    • run() returns the REAL exit code of the command (bug #2)
# =============================================================================

# These are set by install.sh before sourcing:
#   LOG_FILE   — path to the install log
#   DRY_RUN    — "true" | "false"

_log_write() {
    # Append a timestamped raw line to the log only (no color, no terminal).
    if [[ "${DRY_RUN:-false}" != "true" ]]; then
        printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
    fi
}

log() {
    echo -e "${CYAN}  [$(date '+%H:%M:%S')]${RESET} $*"
    _log_write "INFO  $*"
}

success() {
    echo -e "${GREEN}  ✓${RESET} $*"
    _log_write "OK    $*"
}

warn() {
    echo -e "${YELLOW}  ⚠${RESET} $*"
    _log_write "WARN  $*"
}

error() {
    echo -e "${RED}  ✗${RESET} $*" >&2
    _log_write "ERROR $*"
}

die() {
    error "$*"
    _log_write "FATAL $*"
    exit 1
}

# run — execute a command, teeing output to the log.
# Returns the command's REAL exit code (not the tee/redirect code).
# In dry-run it prints the command and returns 0 without executing (bug #15).
run() {
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[dry-run]${RESET} $*"
        return 0
    fi
    "$@" >> "$LOG_FILE" 2>&1
    return $?
}
