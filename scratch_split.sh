#!/bin/bash
clear

# Set scrolling region to bottom 10 lines (say lines 15 to 25)
# Assuming a standard terminal, let's just get lines
LINES=$(tput lines)
TOP_PANE=$((LINES - 12))
BOTTOM_PANE=$((LINES - 11))

# Set scrolling region for the bottom pane
echo -e "\033[${BOTTOM_PANE};${LINES}r"

# Move to top pane, print something
echo -e "\033[1;1H\033[KTop pane!"

# Move to bottom pane, print logs
for i in {1..20}; do
    echo -e "\033[${LINES};1H\033[KLog line $i"
    sleep 0.2
done

# Reset scrolling region
echo -e "\033[r"
clear
