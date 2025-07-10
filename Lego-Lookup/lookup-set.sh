#!/usr/bin/env bash
# filepath: setlookup-search.sh

# Simple Bash search tool for Lego sets using setlookup.json

SETLOOKUP_JSON="$HOME/Lego/Lego-Lookup/legolookup.json"

# Check jq is installed
if ! command -v jq &>/dev/null; then
    echo "jq is required for this script. Please install jq."
    exit 1
fi

center() {
    local termwidth padding
    termwidth=$(tput cols)
    padding=$(( (termwidth - ${#1}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$1" $padding ""
}

clear
center "========================================="
center "         LEGO SET LOOKUP TOOL            "
center "========================================="
echo

# Prompt for search criteria
read -rp "Set ID (leave blank to skip): " search_id
read -rp "Set Name (leave blank to skip): " search_name
read -rp "Theme (leave blank to skip): " search_theme
read -rp "Year (leave blank to skip): " search_year
read -rp "Total Pieces (leave blank to skip): " search_pieces

# Build jq filter using correct JSON keys
jq_filter='.[]'
[[ -n "$search_id" ]] && jq_filter+=" | select(.\"Set ID\" | ascii_downcase | test(\"$search_id\"; \"i\"))"
[[ -n "$search_name" ]] && jq_filter+=" | select(.\"Set Name\" | ascii_downcase | test(\"$search_name\"; \"i\"))"
[[ -n "$search_theme" ]] && jq_filter+=" | select(.\"Theme\" | ascii_downcase | test(\"$search_theme\"; \"i\"))"
[[ -n "$search_year" ]] && jq_filter+=" | select(.\"Year\" | tostring | test(\"$search_year\"; \"i\"))"
[[ -n "$search_pieces" ]] && jq_filter+=" | select(.\"Total Pieces\" == $search_pieces)"

# Search and display results
results=$(jq -r "$jq_filter | [.\"Set ID\", .\"Set Name\", .\"Theme\", .\"Year\", .\"Total Pieces\"] | @tsv" "$SETLOOKUP_JSON")

if [[ -z "$results" ]]; then
    echo
    center "No sets found matching your criteria."
    exit 0
fi

# Print table header
printf "\n%-10s | %-35s | %-20s | %-6s | %-12s\n" "Set ID" "Set Name" "Theme" "Year" "Total Pieces"
printf -- "------------------------------------------------------------------------------------------\n"

# Print each result
while IFS=$'\t' read -r id name theme year pieces; do
    printf "%-10s | %-35s | %-20s | %-6s | %-12s\n" \
        "$id" "${name:0:35}" "${theme:0:20}" "$year" "$pieces"
done <<< "$results"

echo
center "Search complete."
echo
read -p "Press Enter to exit..."
