#!/bin/bash
tput smcup
clear

LINES=$(tput lines)
COLS=$(tput cols)
TOP_LINES=8

# Draw a border between top and bottom
echo -ne "\033[$((TOP_LINES+1));1H"
for ((i=1; i<=COLS; i++)); do echo -n "─"; done
echo ""

# Set scrolling region for logs
echo -ne "\033[$((TOP_LINES+2));${LINES}r"

update_status() {
    echo -ne "\033[s" # save cursor
    echo -ne "\033[1;1H"
    echo -e "\033[K\033[1;36m◆  System Setup  ◆\033[0m"
    echo -e "\033[K"
    echo -e "\033[K  \033[1;34m▶\033[0m $1"
    echo -e "\033[K"
    echo -ne "\033[u" # restore cursor
}

run_with_logs() {
    update_status "$1"
    shift
    # Run command, pipe to loop
    "$@" 2>&1 | while IFS= read -r line; do
        # Move cursor to bottom, print line
        echo -ne "\033[${LINES};1H\033[K"
        echo -e "${line:0:$COLS}"
    done
}

run_with_logs "Installing something..." bash -c 'for i in {1..5}; do echo "Log output $i from task 1"; sleep 0.1; done'
run_with_logs "Configuring network..." bash -c 'for i in {1..5}; do echo "Network output $i"; sleep 0.1; done'

# Reset
echo -ne "\033[r"
tput rmcup
