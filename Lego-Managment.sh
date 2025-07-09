#!/usr/bin/env bash

# Paths to your Python scripts
PARTS_SCRIPT="$HOME/Lego/kc-parts/main.sh"
SETS_SCRIPT="$HOME/Lego/kc-sets/main.sh"

# Function to center text
center() {
    local termwidth
    termwidth=$(tput cols)
    local padding
    padding=$(( (termwidth - ${#1}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$1" $padding ""
}

# Main menu loop
while true; do
    clear
    echo
    center "========================================="
    center "         KC LEGO MANAGEMENT SYSTEM       "
    center "========================================="
    echo
    center "1. Manage Lego Parts"
    center "2. Manage Lego Sets"
    center "3. Exit"
    echo

    read -rp "$(center 'Select an option [1-3]: ')" choice

    case "$choice" in
        1)
            # Run the parts management Python script
            "$PARTS_SCRIPT"
            ;;
        2)
            # Run the sets management Python script
            "$SETS_SCRIPT"
            ;;
        3)
            center "Goodbye!"
            sleep 1
            exit 0
            ;;
        *)
            center "Invalid option. Please try again."
            sleep 1
            ;;
    esac
done