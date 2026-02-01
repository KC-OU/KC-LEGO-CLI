#!/usr/bin/env bash

# Bash search tool for Lego sets, using Rebrickable API with local fallback

# --- Configuration ---
SETLOOKUP_JSON="$HOME/Lego/Lego-Lookup/legolookup.json"
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
        # We can still proceed to local search, so we don't exit
        return 1
    fi
    return 0
}


# --- Lookup Functions ---

# New function to perform lookup via Rebrickable API
api_set_lookup() {
    local set_num
    read -rp "Enter the LEGO Set Number (e.g., 75192-1): " set_num

    if [[ -z "$set_num" ]]; then
        center "Set number cannot be empty."
        sleep 1
        return 1
    fi

    center "Querying Rebrickable API..."
    
    # Call the API wrapper and capture the output
    local api_response
    api_response=$("$API_WRAPPER" "sets" "$set_num")

    # Check if the response is empty or contains an error message from the API
    if [[ -z "$api_response" ]] || ! jq -e '.set_num' >/dev/null 2>&1 <<< "$api_response"; then
        center "Failed to retrieve data from Rebrickable API."
        center "The set may not exist, or there could be a network/API key issue."
        sleep 2
        return 1
    fi

    # Parse and display the result using jq
    center "--- API Result ---"
    {
        echo "Set Number:   $(jq -r '.set_num' <<< "$api_response")"
        echo "Name:         $(jq -r '.name' <<< "$api_response")"
        echo "Year:         $(jq -r '.year' <<< "$api_response")"
        echo "Theme ID:     $(jq -r '.theme_id' <<< "$api_response")"
        echo "Pieces:       $(jq -r '.num_parts' <<< "$api_response")"
    } | awk '{printf "%-15s %s\n", $1, $2}'
    
    echo
    center "--------------------"
    return 0
}

# The original lookup function, repurposed as a local-only search
local_set_lookup() {
    clear
    center "========================================="
    center "       LOCAL LEGO SET SEARCH TOOL        "
    center "========================================="
    echo
    center "Searching local legolookup.json file."
    echo
    
    read -rp "Set ID(s) (comma-separated, leave blank to skip): " search_ids
    read -rp "Set Name (leave blank to skip): " search_name
    read -rp "Theme(s) (comma-separated, leave blank to skip): " search_themes
    
    local jq_filter='.[]'

    # Build the jq filter based on user input
    if [[ -n "$search_ids" ]]; then
        IFS=',' read -ra ids <<< "$search_ids"
        local id_filter=""
        for id in "${ids[@]}"; do
            local id_trimmed=$(echo "$id" | xargs)
            id_filter+="(.\"Set ID\" | ascii_downcase | test(\"$id_trimmed\"; \"i\")) or "
        done
        id_filter="${id_filter% or }"
        jq_filter+=" | select($id_filter)"
    fi
    
    [[ -n "$search_name" ]] && jq_filter+=" | select(.\"Set Name\" | ascii_downcase | test(\"$search_name\"; \"i\"))"

    if [[ -n "$search_themes" ]]; then
        IFS=',' read -ra themes <<< "$search_themes"
        local theme_filter=""
        for theme in "${themes[@]}"; do
            local theme_trimmed=$(echo "$theme" | xargs)
            theme_filter+="(.\"Theme\" | ascii_downcase | test(\"$theme_trimmed\"; \"i\")) or "
        done
        theme_filter="${theme_filter% or }"
        jq_filter+=" | select($theme_filter)"
    fi

    local results
    results=$(jq -c "$jq_filter" "$SETLOOKUP_JSON")

    if [[ -z "$results" ]]; then
        echo
        center "No sets found in local file matching your criteria."
        return
    fi
    
    # Function to print a formatted table from local results
    print_local_table() {
        printf "\n%-10s | %-35s | %-25s | %-6s | %-12s\n" "Set ID" "Set Name" "Theme" "Year" "Total Pieces"
        printf -- "------------------------------------------------------------------------------------------\n"
        while IFS= read -r row; do
            local id name theme year pieces
            id=$(jq -r '."Set ID"' <<< "$row")
            name=$(jq -r '."Set Name"' <<< "$row")
            theme=$(jq -r '."Theme"' <<< "$row")
            year=$(jq -r '."Year"' <<< "$row")
            pieces=$(jq -r '."Total Pieces"' <<< "$row")
            printf "%-10s | %-35s | %-25s | %-6s | %-12s\n" \
                "$id" "${name:0:35}" "${theme:0:25}" "$year" "$pieces"
        done <<< "$1"
    }

    print_local_table "$results"
}

# --- Main Menu ---

main_menu() {
    while true; do
        clear
        center "========================================="
        center "         LEGO SET LOOKUP TOOL            "
        center "========================================="
        echo
        center "1. Search by Set Number (Rebrickable API)"
        center "2. Advanced Search (Local File)"
        center "3. Exit"
        echo
        
        read -rp "$(center 'Select an option [1-3]: ')" choice

        case "$choice" in
            1)
                # Try API lookup
                if ! api_set_lookup; then
                    # If API fails, offer to try local search
                    read -rp "$(center 'API lookup failed. Try local search instead? (y/n): ')" fallback_choice
                    if [[ "$fallback_choice" =~ ^[Yy]$ ]]; then
                        local_set_lookup
                        echo
                        read -rp "$(center 'Press Enter to return to menu...')"
                    fi
                else
                    echo
                    read -rp "$(center 'Press Enter to return to menu...')"
                fi
                ;;
            2)
                # Go directly to local search
                local_set_lookup
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
