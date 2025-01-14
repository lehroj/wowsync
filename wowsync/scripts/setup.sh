#!/bin/bash

# Strict error handling
set -euo pipefail

# Include utility functions
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/tools/utils.sh"

info "Setup"
