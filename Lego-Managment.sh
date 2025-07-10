#!/usr/bin/env bash

# Paths to your scripts
PARTS_SCRIPT="$HOME/Lego/Personal-Collection/kc-parts/main.sh"
SETS_SCRIPT="$HOME/Lego/Personal-Collection/kc-sets/main.sh"

# Function to center text
center() {
    local termwidth
    termwidth=$(tput cols)
    local padding
    padding=$(( (termwidth - ${#1}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$1" $padding ""
}

# Personal Collection submenu
personal_collection_menu() {
    while true; do
        clear
        echo
        center "========================================="
        center "           PERSONAL COLLECTION           "
        center "========================================="
        echo
        center "1. Manage Lego Parts"
        center "2. Manage Lego Sets"
        center "3. Back to Main Menu"
        echo

        read -rp "$(center 'Select an option [1-3]: ')" pc_choice

        case "$pc_choice" in
            1)
                "$PARTS_SCRIPT"
                ;;
            2)
                "$SETS_SCRIPT"
                ;;
            3)
                break
                ;;
            *)
                center "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Main menu loop
while true; do
    clear
    echo
    center "========================================="
    center "         KC LEGO MANAGEMENT SYSTEM       "
    center "========================================="
    echo
    center "1. Personal Collection"
    center "2. Exit"
    echo

    read -rp "$(center 'Select an option [1-2]: ')" choice

    case "$choice" in
        1)
            personal_collection_menu
            ;;
        2)
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