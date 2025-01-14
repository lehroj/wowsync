#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Load utility functions from the utils.sh script
source "$(dirname "$0")/../tools/utils.sh"

# Display help message
echo
info "Usage: wowsync <command>"
echo
info "Available commands:"
info "  setup      Configure WoWSync for your system."
info "  backup     Backup WoW settings and addons to the Git repository."
info "  restore    Restore WoW settings and addons from the Git repository."
info "  update     Update WoWSync to the latest version."
info "  help       Display this help message."
echo
info "For detailed information, visit the GitHub repository:"
info "https://github.com/lehroj/wowsync"
echo
