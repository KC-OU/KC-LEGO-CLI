#!/usr/bin/env bash

PARTLOOKUP_JSON="$HOME/Lego/Lego-Lookup/legolookup-part.json"

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
center "         LEGO PART LOOKUP TOOL           "
center "========================================="
echo

# Prompt for search criteria
read -rp "Part Number (leave blank to skip): " search_number
read -rp "Part Name (leave blank to skip): " search_name
read -rp "Part Category (leave blank to skip): " search_category

# Build jq filter using correct JSON keys
jq_filter='.[]'
[[ -n "$search_number" ]] && jq_filter+=" | select(.part_number | ascii_downcase | test(\"$search_number\"; \"i\"))"
[[ -n "$search_name" ]] && jq_filter+=" | select(.part_name | ascii_downcase | test(\"$search_name\"; \"i\"))"
[[ -n "$search_category" ]] && jq_filter+=" | select(.part_category | ascii_downcase | test(\"$search_category\"; \"i\"))"

# Search and display results
results=$(jq -r "$jq_filter | [.part_number, .part_name, .part_category] | @tsv" "$PARTLOOKUP_JSON")

if [[ -z "$results" ]]; then
    echo
    center "No parts found matching your criteria."
    exit 0
fi

# Print table header
printf "\n%-15s | %-40s | %-30s\n" "Part Number" "Part Name" "Part Category"
printf -- "-------------------------------------------------------------------------------\n"

# Print each result
while IFS=$'\t' read -r number name category; do
    printf "%-15s | %-40s | %-30s\n" \
        "$number" "${name:0:40}" "${category:0:30}"
done <<< "$results"

 echo
        center "Search complete."
        echo
        read -rp "Would you like to search again? (y/n): " again
        [[ "$again" =~ ^[Yy]$ ]] || break
    done