#!/bin/bash
tput smcup
clear
LINES=$(tput lines)
TOP_LINES=8
echo -ne "\033[$((TOP_LINES+2));${LINES}r"
echo -ne "\033[${LINES};1H" # move to bottom

success() {
    echo -e "  \033[1;32m✓\033[0m $1"
}

# pretend run_with_logs just finished
echo "Log from command 1"
echo "Log from command 2"
success "Task finished!"
echo "Log from next command 1"
success "Task 2 finished!"

echo -ne "\033[r"
tput rmcup
