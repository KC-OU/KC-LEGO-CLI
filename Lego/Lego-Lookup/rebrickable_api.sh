#!/usr/bin/env bash

# Wrapper script for the Rebrickable API
# Usage:
# ./rebrickable_api.sh sets <set_num>
# ./rebrickable_api.sh parts <part_num>

BASE_URL="https://rebrickable.com/api/v3/lego"
API_KEY=""
ENV_FILE="$HOME/Lego/.env"

# --- Helper Functions ---

# Function to print error messages to stderr
print_error() {
    echo "Error: $1" >&2
}

# Function to load API key from .env file
load_api_key() {
    if [[ ! -f "$ENV_FILE" ]]; then
        print_error "Configuration file not found at $ENV_FILE"
        return 1
    fi
    # Source the .env file to get the key
    source "$ENV_FILE"
    API_KEY="$REBRICKABLE_API_KEY"
    if [[ -z "$API_KEY" ]]; then
        print_error "REBRICKABLE_API_KEY not set in $ENV_FILE"
        return 1
    fi
    return 0
}

# --- Main Script Logic ---

# Check for correct number of arguments
if [[ "$#" -ne 2 ]]; then
    print_error "Invalid number of arguments."
    echo "Usage: $0 <endpoint> <id>" >&2
    echo "Examples:" >&2
    echo "  $0 sets 75192-1" >&2
    echo "  $0 parts 3001" >&2
    exit 1
fi

ENDPOINT="$1"
ID="$2"
URL=""

# Validate endpoint and construct URL
case "$ENDPOINT" in
    sets)
        URL="$BASE_URL/sets/$ID/"
        ;;
    parts)
        URL="$BASE_URL/parts/$ID/"
        ;;
    *)
        print_error "Invalid endpoint '$ENDPOINT'. Must be 'sets' or 'parts'."
        exit 1
        ;;
esac

# Load the API key
if ! load_api_key; then
    exit 1
fi

# Make the API call using curl
# -s: silent mode
# -H: add header for authorization
# The output will be the JSON response from the API
curl -s -H "Authorization: key $API_KEY" "$URL"
exit 0
