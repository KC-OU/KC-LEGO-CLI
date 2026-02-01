#!/usr/bin/env bash

# Bash search tool for Lego parts, using Rebrickable API with local fallback

# --- Configuration ---
PARTLOOKUP_JSON="$HOME/Lego/Lego-Lookup/legolookup-part.json"
API_WRAPPER="$HOME/Lego/Lego-Lookup/rebrickable_api.sh"

# --- Helper Functions ---

# Function to center text
center() {
    local termwidth padding
    termwidth=$(tput cols)
    padding=$(( (termwidth - ${#1}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$1" $padding ""
}

# Function to check for required commands
check_dependencies() {
    if ! command -v jq &>/dev/null; then
        center "Error: jq is required. Please install it to continue."
        exit 1
    fi
    if [[ ! -x "$API_WRAPPER" ]]; then
        center "Error: API wrapper not found or not executable at $API_WRAPPER"
        return 1
    fi
    return 0
}


# --- Lookup Functions ---

# New function to perform lookup via Rebrickable API
api_part_lookup() {
    local part_num
    read -rp "Enter the LEGO Part Number (e.g., 3001): " part_num

    if [[ -z "$part_num" ]]; then
        center "Part number cannot be empty."
        sleep 1
        return 1
    fi

    center "Querying Rebrickable API..."
    
    local api_response
    api_response=$("$API_WRAPPER" "parts" "$part_num")

    if [[ -z "$api_response" ]] || ! jq -e '.part_num' >/dev/null 2>&1 <<< "$api_response"; then
        center "Failed to retrieve data from Rebrickable API."
        center "The part may not exist, or there could be a network/API key issue."
        sleep 2
        return 1
    fi

    center "--- API Result ---"
    {
        echo "Part Number:  $(jq -r '.part_num' <<< "$api_response")"
        echo "Name:         $(jq -r '.name' <<< "$api_response")"
        echo "Category ID:  $(jq -r '.part_cat_id' <<< "$api_response")"
    } | awk '{printf "%-15s %s\n", $1, $2}'

    echo
    center "--------------------"
    return 0
}

# The original lookup function, repurposed as a local-only search
local_part_lookup() {
    clear
    center "========================================="
    center "       LOCAL LEGO PART SEARCH TOOL       "
    center "========================================="
    echo
    center "Searching local legolookup-part.json file."
    echo
    
    read -rp "Part Number (leave blank to skip): " search_number
    read -rp "Part Name (leave blank to skip): " search_name
    read -rp "Part Category (leave blank to skip): " search_category

    local jq_filter='.[]'
    [[ -n "$search_number" ]] && jq_filter+=" | select(.part_number | ascii_downcase | test(\"$search_number\"; \"i\"))"
    [[ -n "$search_name" ]] && jq_filter+=" | select(.part_name | ascii_downcase | test(\"$search_name\"; \"i\"))"
    [[ -n "$search_category" ]] && jq_filter+=" | select(.part_category | ascii_downcase | test(\"$search_category\"; \"i\"))"

    local results
    results=$(jq -c "$jq_filter" "$PARTLOOKUP_JSON")

    if [[ -z "$results" ]]; then
        echo
        center "No parts found in local file matching your criteria."
        return
    fi
    
    printf "\n%-15s | %-40s | %-30s\n" "Part Number" "Part Name" "Part Category"
    printf -- "--------------------------------------------------------------------------------------\n"
    
    while IFS= read -r row; do
        local number name category
        number=$(jq -r '.part_number' <<< "$row")
        name=$(jq -r '.part_name' <<< "$row")
        category=$(jq -r '.part_category' <<< "$row")
        printf "%-15s | %-40s | %-30s\n" \
            "$number" "${name:0:40}" "${category:0:30}"
    done <<< "$results"
}

# --- Main Menu ---

main_menu() {
    while true; do
        clear
        center "========================================="
        center "         LEGO PART LOOKUP TOOL           "
        center "========================================="
        echo
        center "1. Search by Part Number (Rebrickable API)"
        center "2. Advanced Search (Local File)"
        center "3. Exit"
        echo
        
        read -rp "$(center 'Select an option [1-3]: ')" choice

        case "$choice" in
            1)
                if ! api_part_lookup; then
                    read -rp "$(center 'API lookup failed. Try local search instead? (y/n): ')" fallback_choice
                    if [[ "$fallback_choice" =~ ^[Yy]$ ]]; then
                        local_part_lookup
                        echo
                        read -rp "$(center 'Press Enter to return to menu...')"
                    fi
                else
                    echo
                    read -rp "$(center 'Press Enter to return to menu...')"
                fi
                ;;
            2)
                local_part_lookup
                echo
                read -rp "$(center 'Press Enter to return to menu...')"
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

# --- Script Start ---
check_dependencies
main_menu