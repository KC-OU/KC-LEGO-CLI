#!/usr/bin/env bash
TODO: NEED TO FIX THE SCRIPTS DUE TO ERROS
# Paths to your scripts
PARTS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Personal-Collection/kc-parts/main.sh"
SETS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Personal-Collection/kc-sets/main.sh"
LICENSE_CACHE_FILE="$HOME/Lego/.lego_manager_license_agreed"

# KC NO Retired Sets
Non_Retired_LEGO_SETS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Non-Retired-Lego-Sets/main.sh"
Retired_or_Retiring_LEGO_SETS_SCRIPT="$HOME/Lego/Lego-Magement-Screen/Retried-and-retiring-Lego-Sets/main.sh"
# KC Retired Sets



LegoLookup="$HOME/Lego/Lego-Lookup/lookup-set.sh"


# Function to center text
center() {
    local termwidth
    termwidth=$(tput cols)
    local padding
    padding=$(( (termwidth - ${#1}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$1" $padding ""
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
    center "This project is licensed under the MIT License."
    center "You must agree to the license to use this script."
    center "-----------------------------------------------"
    center ""
    center "Copyright <YEAR> <COPYRIGHT HOLDER>"
    center ""
    center "Permission is hereby granted, free of charge, to any" 
    center "person obtaining a copy of this software and associated" 
    center "documentation files (the \"Software\"), to deal in the"
    center "Software without restriction, including without limitation" 
    center "the rights to use, copy, modify, merge, publish, distribute," 
    center "sublicense, and/or sell copies of the Software, and to permit" 
    center "persons to whom the Software is furnished to do so, subject"
    center "to the following conditions:"
    center "                                                           "
    center "The above copyright notice and this permission notice shall"
    center "be included in all copies or substantial portions of the Software."
    center "                                                                  "
    center "THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND," 
    center "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES"
    center "OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT." 
    center "IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM," 
    center "DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR" 
    center "OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE"
    center "OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    center ""
    center "Full license: https://opensource.org/license/mit"
    echo
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

# Main menu loop as a function (LMS)
lego_management_system_menu() {
    while true; do
        clear
        echo
        center "========================================="
        center "         KC LEGO MANAGEMENT SYSTEM       "
        center "         -------------------------       "
        center "   This bash shell, helps you with your  "
        center "      Personal Lego Collection and       "
        center "      non-personal Lego collection       "
        center "========================================="
        echo
        center "1. Personal Collection"
        center "2. Non Retired Lego Sets"
        center "3. Retired Lego Sets"
        center "4. Back"
        center "5. Exit"
        echo

        read -rp "$(center 'Select an option [1-5]:')" choice

        case "$choice" in
            1)
                personal_collection_menu
                ;;
            2)
                "$Non_Retired_LEGO_SETS_SCRIPT"
                ;;
            3)
                "$Retired_or_Retiring_LEGO_SETS_SCRIPT"
                ;;
            4)
                break  # Back to startup menu
                ;;
            5)
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
}

# Lego Lookup menu (LL) with Back button
lego_lookup_menu() {
    while true; do
        clear
        center "========================================="
        center "             LEGO LOOKUP                 "
        center "========================================="
        echo
        center "1. Lookup by Set"
        center "2. Lookup by Part"
        center "3. Lookup by Minifigure"
        center "4. Back"
        center "5. Exit"
        echo

        read -rp "$(center 'Select an option [1-5]: ')" ll_choice

        case "$ll_choice" in
            1)
                
                "$LegoLookup"
                ;;
            2)
                center "Part lookup coming soon!"
                sleep 1
                ;;
            3)
                center "Minifigure lookup coming soon!"
                sleep 1
                ;;
            4)
                break  # Back to startup menu
                ;;
            5)
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
}

# LMS/LL start menu
startup_menu() {
    while true; do
        clear
        center "========================================="
        center "         LEGO SYSTEM LAUNCHER            "
        center "========================================="
        echo
        center "1. Lego Management System"
        center "2. Lego Lookup"
        center "3. View License"
        center "4. Exit"
        echo

        read -rp "$(center 'Select an option [1-4]: ')" start_choice

        case "$start_choice" in
            1)
                lego_management_system_menu
                ;;
            2)
                lego_lookup_menu
                ;;
            3)
                clear
                center "==============================================="
                center "This project is licensed under the MIT License."
                center "You can view the license at:"
                center "https://opensource.org/license/mit"
                center "==============================================="
                center ""
                center "Full Decription"
                center "---------------"
                center "               "
                center "Copyright <YEAR> <COPYRIGHT HOLDER>"
                center ""
                center "Permission is hereby granted, free of charge, to any" 
                center "person obtaining a copy of this software and associated" 
                center "documentation files (the \"Software\"), to deal in the"
                center "Software without restriction, including without limitation" 
                center "the rights to use, copy, modify, merge, publish, distribute," 
                center "sublicense, and/or sell copies of the Software, and to permit" 
                center "persons to whom the Software is furnished to do so, subject"
                center "to the following conditions:"
                center "                                                           "
                center "The above copyright notice and this permission notice shall"
                center "be included in all copies or substantial portions of the Software."
                center "                                                                  "
                center "THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND," 
                center "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES"
                center "OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT." 
                center "IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM," 
                center "DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR" 
                center "OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE"
                center "OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
                center ""
                center "==========================================================================="
                echo
                center "Press Enter to return to the menu."
                read
                ;;
            4)
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
}

# Show license agreement at the very start
show_license_agreement

# Start the launcher
startup_menu