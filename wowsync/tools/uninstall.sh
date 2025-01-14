#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Load utility functions from the utils.sh script
source "$(dirname "$0")/../tools/utils.sh"

# Display a warning to the user about the uninstallation
warn "This will completely remove WoWSync and its configuration."
warn "Do you want to proceed? [y/N]"

# Read user input (response) for confirmation
read -r response


# Check if the response is either "y" or "Y"
# If true, abort the uninstallation process
if [[ "$response" == "y" || "$response" == "Y" ]]; then
    info "Uninstallation aborted."
    exit 0
fi

# Define paths used during the uninstallation process
INSTALL_DIR="/opt/wowsync"
SYMLINK_PATH="/usr/local/bin/wowsync"

# Remove the installation directory if it exists
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    success "Removed $INSTALL_DIR."
fi

# Remove the symlink if it exists
if [ -L "$SYMLINK_PATH" ]; then
    rm "$SYMLINK_PATH"
    success "Removed symlink $SYMLINK_PATH."
fi

# Display a final confirmation message to the user
info "WoWSync has been uninstalled."
info "Thank you for using WoWSync."
