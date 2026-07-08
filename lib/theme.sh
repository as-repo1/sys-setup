#!/usr/bin/env bash
# =============================================================================
#  lib/theme.sh — Nord theme colors + terminal constants
#  Sourced by install.sh. Provides:
#    • NORD0–NORD15  hex colors (for gum --*.*foreground flags)
#    • raw ANSI fallbacks (RED/GREEN/...) used before gum is bootstrapped
#    • UI widths / glyphs
# =============================================================================

# ─── Nord hex (passed to gum style flags) ────────────────────────────────────
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

# ─── Raw ANSI fallbacks (truecolor, matching Nord) ───────────────────────────
# Used by log helpers before gum is available, or when gum output is unwanted.
RED='\033[38;2;191;97;106m'      # Nord11
GREEN='\033[38;2;163;190;140m'   # Nord14
YELLOW='\033[38;2;235;203;139m'  # Nord13
ORANGE='\033[38;2;208;135;112m'  # Nord12
BLUE='\033[38;2;129;161;193m'    # Nord9
CYAN='\033[38;2;136;192;208m'    # Nord8
MAGENTA='\033[38;2;180;142;173m' # Nord15
GREY='\033[38;2;76;86;106m'      # Nord3
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── Layout constants ────────────────────────────────────────────────────────
UI_WIDTH=60
TOTAL_PHASES=10
