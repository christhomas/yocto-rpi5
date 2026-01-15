#!/bin/bash
# =============================================================================
# Layer Setup Script (runs inside Docker container)
# =============================================================================
# This script clones all required Yocto layers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LAYERS_DIR="$PROJECT_DIR/layers"

# Yocto release branch (scarthgap is the current LTS as of 2024)
YOCTO_BRANCH="scarthgap"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

clone_layer() {
    local name="$1"
    local url="$2"
    local branch="${3:-$YOCTO_BRANCH}"
    
    if [ -d "$LAYERS_DIR/$name" ]; then
        log_warn "Layer $name already exists, skipping..."
    else
        log_info "Cloning $name (branch: $branch)..."
        git clone -b "$branch" --depth 1 "$url" "$LAYERS_DIR/$name"
    fi
}

main() {
    mkdir -p "$LAYERS_DIR"
    
    log_info "Setting up Yocto layers for Raspberry Pi 5 with RAUC..."
    log_info "Using Yocto release: $YOCTO_BRANCH"
    echo ""
    
    # Core Yocto layers
    clone_layer "poky" "git://git.yoctoproject.org/poky"
    
    # OpenEmbedded layers (provides additional recipes)
    clone_layer "meta-openembedded" "git://git.openembedded.org/meta-openembedded"
    
    # Raspberry Pi BSP layer
    clone_layer "meta-raspberrypi" "https://github.com/agherzan/meta-raspberrypi.git"
    
    # RAUC update framework layer
    clone_layer "meta-rauc" "https://github.com/rauc/meta-rauc.git"
    
    echo ""
    log_info "All layers cloned successfully!"
    log_info ""
    log_info "Next step: Run the build"
    log_info "  ./scripts/build.sh build"
}

main "$@"
