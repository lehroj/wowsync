#!/bin/bash

# Function to display messages with colors
# Usage: echo_color "color_code" "message"
echo_color() {
    local color_code="$1"
    local message="$2"

    echo -e "${color_code}${message}\033[0m"
}

# Define color codes
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"

# Shortcut functions for colored messages
info() { echo_color "$BLUE" "$1"; }
success() { echo_color "$GREEN" "$1"; }
error() { echo_color "$RED" "$1"; }
warn() { echo_color "$YELLOW" "$1"; }

# Validate configuration before running backup/restore
check_config() {
    info "Check configuration..."

    local config_file="$(dirname "$0")/../config.toml"

    # Check config.toml exists
    if [ ! -f "$config_file" ]; then
        error "Configuration file $config_file is missing. Please run 'wowsync setup' first."
        exit 1
    fi

    # Extract configuration values from the config.toml file
    local wow_path
    local wow_classic
    local wow_classic_era
    local wow_retail
    local repository_url
    local repository_branch

    wow_path=$(grep "^WOW_PATH" "$config_file" | cut -d'=' -f2 | tr -d ' "')
    wow_classic=$(grep "^WOW_CLASSIC" "$config_file" | cut -d'=' -f2 | tr -d ' ')
    wow_classic_era=$(grep "^WOW_CLASSIC_ERA" "$config_file" | cut -d'=' -f2 | tr -d ' ')
    wow_retail=$(grep "^WOW_RETAIL" "$config_file" | cut -d'=' -f2 | tr -d ' ')
    repository_url=$(grep "^REPOSITORY_URL" "$config_file" | cut -d'=' -f2 | tr -d ' "')
    repository_branch=$(grep "^REPOSITORY_BRANCH" "$config_file" | cut -d'=' -f2 | tr -d ' "')

    # Verify the WoW installation path exists
    if [ ! -d "$wow_path" ]; then
        error "Invalid WoW installation path: $wow_path. Please update the configuration file."
        exit 1
    fi

    # Ensure at least one of the WoW versions is enabled
    if [[ "$wow_classic" != "true" && "$wow_classic_era" != "true" && "$wow_retail" != "true" ]]; then
        error "At least one WoW version (Classic, Classic Era, Retail) must be enabled in the configuration."
        exit 1
    fi

    # Check if the repository URL is a valid Git repository
    if ! git ls-remote "$repository_url" &>/dev/null; then
        error "Invalid or unreachable Git repository URL: $repository_url. Please check the configuration."
        exit 1
    fi

    # Verify the specified branch exists in the repository
    if ! git ls-remote --heads "$repository_url" "$repository_branch" &>/dev/null; then
        error "Branch '$repository_branch' does not exist in the repository $repository_url."
        exit 1
    fi
}
