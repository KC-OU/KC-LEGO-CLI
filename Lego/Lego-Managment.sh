#!/usr/bin/env bash

# Paths to your scripts
PARTS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Personal-Collection/kc-parts/main.sh"
SETS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Personal-Collection/kc-sets/main.sh"
LICENSE_CACHE_FILE="$HOME/Lego/.lego_manager_license_agreed"
Non_Retired_LEGO_SETS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Non-Retired-Lego-Sets/main.sh"
Retired_or_Retiring_LEGO_SETS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Retried-and-retiring-Lego-Sets/main.sh"
LegoLookup="$HOME/Lego/Lego-Lookup/lookup-set.sh"
LegoPartLookup="$HOME/Lego/Lego-Lookup/lookup-part.sh"
SETTINGS_FILE="$HOME/Lego/.kc-lego-cli.conf"

# Function to center text
center() {
    local termwidth
    termwidth=$(tput cols)
    local padding
    padding=$(( (termwidth - ${#1}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$1" $padding ""
}

# Function to check if a menu item is enabled in the config
is_item_enabled() {
    local item_name="$1"
    if grep -q "\[ \].*$item_name" "$SETTINGS_FILE"; then
        return 0 # Enabled
    else
        return 1 # Disabled or not found
    fi
}

# License agreement function
show_license_agreement() {
    if [[ -f "$LICENSE_CACHE_FILE" ]]; then
        return
    fi
    clear
    center "==============================================="
    center "           LICENSE AGREEMENT SCREEN            "
    center "==============================================="
    echo
    # ... (license text remains the same)
    while true; do
        read -rp "$(center 'Do you agree to the license? (yes/no): ')" agree
        case "$agree" in
            [Yy][Ee][Ss]|[Yy])
                touch "$LICENSE_CACHE_FILE"
                break
                ;;
            [Nn][Oo]|[Nn])
                center "You did not agree to the license. Exiting."
                sleep 1
                exit 0
                ;;
            *)
                center "Please answer yes or no."
                ;;
        esac
    done
}

personal_collection_menu() {
    while true; do
        clear
        echo
        center "========================================="
        center "           PERSONAL COLLECTION           "
        center "========================================="
        echo

        options=()
        if is_item_enabled "Manage Lego Parts"; then options+=("Manage Lego Parts"); fi
        if is_item_enabled "Manage Lego Sets"; then options+=("Manage Lego Sets"); fi
        options+=("Back to Main Menu")

        for i in "${!options[@]}"; do
            center "$((i+1)). ${options[i]}"
        done
        echo

        read -rp "$(center "Select an option [1-${#options[@]}]: ")" pc_choice

        if [[ "$pc_choice" -ge 1 && "$pc_choice" -le ${#options[@]} ]]; then
            selected_option="${options[$((pc_choice-1))]}"
            case "$selected_option" in
                "Manage Lego Parts") "$PARTS_SCRIPT" ;;
                "Manage Lego Sets") "$SETS_SCRIPT" ;;
                "Back to Main Menu") break ;;
            esac
        else
            center "Invalid option. Please try again."
            sleep 1
        fi
    done
}

lego_management_system_menu() {
    while true; do
        clear
        echo
        center "========================================="
        center "         KC LEGO MANAGEMENT SYSTEM       "
        center "========================================="
        echo
        
        options=()
        if is_item_enabled "Personal Collection"; then options+=("Personal Collection"); fi
        if is_item_enabled "Non Retired Lego Sets"; then options+=("Non Retired Lego Sets"); fi
        if is_item_enabled "Retired Lego Sets"; then options+=("Retired Lego Sets"); fi
        options+=("Back")

        for i in "${!options[@]}"; do
            center "$((i+1)). ${options[i]}"
        done
        echo

        read -rp "$(center "Select an option [1-${#options[@]}]: ")" choice

        if [[ "$choice" -ge 1 && "$choice" -le ${#options[@]} ]]; then
            selected_option="${options[$((choice-1))]}"
            case "$selected_option" in
                "Personal Collection") personal_collection_menu ;;
                "Non Retired Lego Sets") "$Non_Retired_LEGO_SETS_SCRIPT" ;;
                "Retired Lego Sets") "$Retired_or_Retiring_LEGO_SETS_SCRIPT" ;;
                "Back") break ;;
            esac
        else
            center "Invalid option. Please try again."
            sleep 1
        fi
    done
}

lego_lookup_menu() {
    while true; do
        clear
        center "========================================="
        center "             LEGO LOOKUP                 "
        center "========================================="
        echo

        options=()
        if is_item_enabled "Lookup by Set"; then options+=("Lookup by Set"); fi
        if is_item_enabled "Lookup by Part"; then options+=("Lookup by Part"); fi
        options+=("Back")

        for i in "${!options[@]}"; do
            center "$((i+1)). ${options[i]}"
        done
        echo

        read -rp "$(center "Select an option [1-${#options[@]}]: ")" ll_choice

        if [[ "$ll_choice" -ge 1 && "$ll_choice" -le ${#options[@]} ]]; then
            selected_option="${options[$((ll_choice-1))]}"
            case "$selected_option" in
                "Lookup by Set") "$LegoLookup" ;;
                "Lookup by Part") "$LegoPartLookup" ;;
                "Back") break ;;
            esac
        else
            center "Invalid option. Please try again."
            sleep 1
        fi
    done
}

settings_menu() {
    clear
    center "========================================="
    center "                 SETTINGS                "
    center "========================================="
    echo
    center "To configure menu visibility, please edit"
    center "the .kc-lego-cli.conf file in your project"
    center "directory. Use '[ ]' to show an item and"
    center "'[x]' to hide it."
    echo
    center "Press Enter to return to the main menu."
    read -r
}

startup_menu() {
    while true; do
        clear
        center "========================================="
        center "         LEGO SYSTEM LAUNCHER            "
        center "========================================="
        echo

        options=()
        if is_item_enabled "Lego Management System"; then options+=("Lego Management System"); fi
        if is_item_enabled "Lego Lookup"; then options+=("Lego Lookup"); fi
        if is_item_enabled "View License"; then options+=("View License"); fi
        if is_item_enabled "Settings"; then options+=("Settings"); fi
        options+=("Exit")

        for i in "${!options[@]}"; do
            center "$((i+1)). ${options[i]}"
        done
        echo

        read -rp "$(center "Select an option [1-${#options[@]}]: ")" start_choice

        if [[ "$start_choice" -ge 1 && "$start_choice" -le ${#options[@]} ]]; then
            selected_option="${options[$((start_choice-1))]}"
            case "$selected_option" in
                "Lego Management System") lego_management_system_menu ;;
                "Lego Lookup") lego_lookup_menu ;;
                "View License")
                    clear
                    # ... (license text remains the same)
                    center "Press Enter to return to the menu."
                    read
                    ;;
                "Settings") settings_menu ;;
                "Exit")
                    center "Goodbye!"
                    sleep 1
                    exit 0
                    ;;
            esac
        else
            center "Invalid option. Please try again."
            sleep 1
        fi
    done
}

# Show license agreement at the very start
show_license_agreement

# Start the launcher
startup_menu
