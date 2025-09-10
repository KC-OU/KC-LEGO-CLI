#!/usr/bin/env bash
# filepath: setlookup-search.sh

# Simple Bash search tool for Lego sets using setlookup.json

# ...existing code...

lego_set_lookup() {
    SETLOOKUP_JSON="$HOME/Lego/Lego-Lookup/legolookup.json"

    if ! command -v jq &>/dev/null; then
        echo "jq is required for this script. Please install jq."
        return 1
    fi

    center() {
        local termwidth padding
        termwidth=$(tput cols)
        padding=$(( (termwidth - ${#1}) / 2 ))
        printf "%*s%s%*s\n" $padding "" "$1" $padding ""
    }

    while true; do
        clear
        center "========================================="
        center "         LEGO SET LOOKUP TOOL            "
        center "========================================="
        echo

        read -rp "Set ID(s) (comma-separated, leave blank to skip): " search_ids
        read -rp "Set Name (leave blank to skip): " search_name
        read -rp "Theme(s) (comma-separated, leave blank to skip): " search_themes
        read -rp "Year(s) (comma-separated, leave blank to skip): " search_years
        read -rp "Total Pieces (comma-separated, leave blank to skip): " search_pieces
        read -rp "When is it retiring (leave blank to skip): " search_retiring
        read -rp "Cost of set in £ (leave blank to skip): " search_cost

        jq_filter='.[]'

        # Multiple or single IDs
        if [[ -n "$search_ids" ]]; then
            IFS=',' read -ra ids <<< "$search_ids"
            id_filter=""
            for id in "${ids[@]}"; do
                id_trimmed=$(echo "$id" | xargs)
                id_filter+="(.\"Set ID\" | ascii_downcase | test(\"$id_trimmed\"; \"i\")) or "
            done
            id_filter="${id_filter% or }"
            jq_filter+=" | select($id_filter)"
        fi

        # Set Name (single)
        [[ -n "$search_name" ]] && jq_filter+=" | select(.\"Set Name\" | ascii_downcase | test(\"$search_name\"; \"i\"))"

        # Multiple or single Themes
        if [[ -n "$search_themes" ]]; then
            IFS=',' read -ra themes <<< "$search_themes"
            theme_filter=""
            for theme in "${themes[@]}"; do
                theme_trimmed=$(echo "$theme" | xargs)
                theme_filter+="(.\"Theme\" | ascii_downcase | test(\"$theme_trimmed\"; \"i\")) or "
            done
            theme_filter="${theme_filter% or }"
            jq_filter+=" | select($theme_filter)"
        fi

        # Multiple or single Years
        if [[ -n "$search_years" ]]; then
            IFS=',' read -ra years <<< "$search_years"
            year_filter=""
            for year in "${years[@]}"; do
                year_trimmed=$(echo "$year" | xargs)
                year_filter+="(.\"Year\" == \"$year_trimmed\") or "
            done
            year_filter="${year_filter% or }"
            jq_filter+=" | select($year_filter)"
        fi

        # Multiple or single Pieces
        if [[ -n "$search_pieces" ]]; then
            IFS=',' read -ra pieces <<< "$search_pieces"
            pieces_filter=""
            for piece in "${pieces[@]}"; do
                piece_trimmed=$(echo "$piece" | xargs)
                pieces_filter+="(.\"Total Pieces\" == \"$piece_trimmed\") or "
            done
            pieces_filter="${pieces_filter% or }"
            jq_filter+=" | select($pieces_filter)"
        fi

        [[ -n "$search_retiring" ]] && jq_filter+=" | select(.\"When is it retiring\" | ascii_downcase | test(\"$search_retiring\"; \"i\"))"
        [[ -n "$search_cost" ]] && jq_filter+=" | select(.\"Cost (£)\" == \"$search_cost\")"

        results=$(jq -c "$jq_filter" "$SETLOOKUP_JSON")

        if [[ -z "$results" ]]; then
            echo
            center "No sets found matching your criteria."
            read -rp "Would you like to search again? (y/n): " try_again
            [[ "$try_again" =~ ^[Yy]$ ]] && continue || break
        fi

        print_table() {
            printf "\n%-10s | %-35s | %-25s | %-6s | %-12s | %-20s | %-10s\n" "Set ID" "Set Name" "Theme" "Year" "Total Pieces" "Retiring" "Cost (£)"
            printf -- "-------------------------------------------------------------------------------------------------------------------------------\n"
            while IFS= read -r row; do
                id=$(jq -r '."Set ID"' <<< "$row")
                name=$(jq -r '."Set Name"' <<< "$row")
                theme=$(jq -r '."Theme"' <<< "$row")
                year=$(jq -r '."Year"' <<< "$row")
                pieces=$(jq -r '."Total Pieces"' <<< "$row")
                retiring=$(jq -r '."When is it retiring"' <<< "$row")
                cost=$(jq -r '."Cost (£)"' <<< "$row")
                printf "%-10s | %-35s | %-25s | %-6s | %-12s | %-20s | %-10s\n" \
                    "$id" "${name:0:35}" "${theme:0:25}" "$year" "$pieces" "$retiring" "$cost"
            done <<< "$1"
        }

        print_table "$results"

        # Post-search narrowing section
        while true; do
            echo
            read -rp "Would you like to narrow the results further by Year or Total Pieces? (y/n): " narrow
            [[ "$narrow" =~ ^[Yy]$ ]] || break

            read -rp "Filter by Year (leave blank to skip): " filter_year
            read -rp "Filter by Total Pieces (leave blank to skip): " filter_pieces

            filtered_results="$results"
            [[ -n "$filter_year" ]] && filtered_results=$(jq -c --arg y "$filter_year" 'select(."Year" == $y)' <<< "$filtered_results")
            [[ -n "$filter_pieces" ]] && filtered_results=$(jq -c --arg p "$filter_pieces" 'select(."Total Pieces" == $p)' <<< "$filtered_results")

            if [[ -z "$filtered_results" ]]; then
                echo
                center "No sets found after narrowing."
                break
            fi

            print_table "$filtered_results"
            results="$filtered_results"
        done

        echo
        center "Search complete."
        echo
        read -rp "Would you like to search again? (y/n): " again
        [[ "$again" =~ ^[Yy]$ ]] || break
    done
}

lego_set_lookup

# ...existing code...
