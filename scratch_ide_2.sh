#!/bin/bash

export TOP_LINES=8
export IDE_UI_ACTIVE=false

setup_ide_ui() {
    tput smcup
    clear
    local LINES=$(tput lines)
    local COLS=$(tput cols)
    
    # Draw horizontal divider
    echo -ne "\033[$((TOP_LINES+1));1H"
    echo -ne "\033[38;5;8m"
    for ((i=1; i<=COLS; i++)); do echo -n "─"; done
    echo -ne "\033[0m"
    
    # Draw static header
    echo -ne "\033[1;1H\033[K\n"
    echo -e "  \033[1;36m◆  System Setup  ◆\033[0m"
    
    echo -ne "\033[$((TOP_LINES+2));${LINES}r"
    IDE_UI_ACTIVE=true
}

teardown_ide_ui() {
    if $IDE_UI_ACTIVE; then
        echo -ne "\033[r"
        tput rmcup
        IDE_UI_ACTIVE=false
    fi
}

run_with_logs() {
    local title="$1"
    shift
    
    local LINES=$(tput lines)
    local COLS=$(tput cols)
    
    echo -ne "\033[s" # save cursor
    echo -ne "\033[4;1H\033[K"
    echo -e "  \033[1;34m▶\033[0m \033[1m$title\033[0m"
    echo -ne "\033[u" # restore cursor
    
    "$@" 2>&1 | while IFS= read -r line; do
        echo -ne "\033[${LINES};1H\033[K"
        echo -e "\033[2m│\033[0m ${line:0:$((COLS-3))}"
    done
}

trap teardown_ide_ui EXIT INT TERM

setup_ide_ui

run_with_logs "Task 1: Doing something" bash -c 'for i in {1..5}; do echo "Log output $i"; sleep 0.1; done'
run_with_logs "Task 2: Doing another thing" bash -c 'for i in {1..10}; do echo "Another log $i"; sleep 0.1; done'

teardown_ide_ui
