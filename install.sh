#!/usr/bin/env bash

# Ensure the script is being run with Bash
# If not, exit with an error
if [ -z "${BASH_VERSION:-}" ]; then
    echo -e "\033[31mError: Bash is required to interpret this script.\033[0m"
    exit 1
fi

# Check if the script is running on macOS
# If not, exit with an error
if [[ "$(uname)" != "Darwin" ]]; then
    error "Unsupported OS: $OS. This script only supports macOS."
    exit 1
fi

# Enable strict error handling
set -euo pipefail

# Function to display colored messages
echo_color() {
    local color_code="$1"
    local message="$2"
    echo -e "${color_code}${message}\033[0m"
}

# Color codes for output messages
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"

# Helper functions for messaging
info() { echo_color "$BLUE" "$1"; }
success() { echo_color "$GREEN" "$1"; }
error() { echo_color "$RED" "$1"; }
warn() { echo_color "$YELLOW" "$1"; }

# Verify required tools and permissions
info "Checking system environment..."

# Ensure Git is installed
if ! command -v git &> /dev/null; then
    error "Git is required. Please install Git and try again."
    exit 1
fi

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    error "Please run this script as root using sudo."
    exit 1
fi

# Define variables for installation
REPOSITORY_URL="https://github.com/lehroj/wowsync.git"
TEMP_DIR=$(mktemp -d)  # Create a temporary directory for the installation
INSTALL_DIR="/opt/wowsync"  # Target installation directory
SYMLINK_PATH="/usr/local/bin/wowsync"  # Symlink to the WoWSync executable

# Clean up temporary directory on exit
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Begin installation
info "Starting WoWSync installation..."

# Clone the repository into the temporary directory
info "Cloning WoWSync repository from $REPOSITORY_URL..."
if ! git clone "$REPOSITORY_URL" "$TEMP_DIR"; then
    error "Failed to clone the repository. Please check your internet connection or the repository URL."
    exit 1
fi
success "Repository cloned."

# Handle existing installation directory
if [ -d "$INSTALL_DIR" ]; then
    warn "$INSTALL_DIR already exists. We'll overwrite it."
    rm -rf "$INSTALL_DIR"
fi

# Move the cloned repository to the installation directory
mv "$TEMP_DIR/wowsync" "$INSTALL_DIR"
success "Moved WoWSync to $INSTALL_DIR."

# Move config.toml if it exists
if [ -f "$TEMP_DIR/config.toml" ]; then
    mv "$TEMP_DIR/config.toml" "$INSTALL_DIR/config.toml"
    success "Moved config.toml to $INSTALL_DIR/config.toml."
else
    warn "config.toml not found in the repository root. Skipping."
fi

# Create or update the symlink
if [ -L "$SYMLINK_PATH" ]; then
    warn "Symlink $SYMLINK_PATH already exists. It will be updated."
    rm -rf "$SYMLINK_PATH"
fi

ln -s "$INSTALL_DIR/wowsync" "$SYMLINK_PATH"
success "Created symlink at $SYMLINK_PATH."

# Set executable permissions on scripts
for file in "$INSTALL_DIR/wowsync" "$INSTALL_DIR/config.toml" "$INSTALL_DIR/tools/"*.sh "$INSTALL_DIR/scripts/"*.sh; do
    [ -e "$file" ] && chmod +x "$file"
done

success "Set executable permissions for scripts in $INSTALL_DIR."

# Completion message
success "WoWSync installation completed."
info "Please run \`wowsync setup\` to edit WoWSync configuration."
