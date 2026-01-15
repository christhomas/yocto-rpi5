#!/bin/bash
# =============================================================================
# Yocto Build Script (runs inside Docker container)
# =============================================================================

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

ensure_project_build_conf() {
    local build_dir="$1"
    local local_conf="$build_dir/conf/local.conf"
    local require_line='require ../../conf/project-build.conf'

    if [ ! -f "$local_conf" ]; then
        log_error "Missing local.conf at: $local_conf"
        exit 1
    fi

    if ! grep -Fq "$require_line" "$local_conf"; then
        log_info "Enabling project build config in local.conf"
        printf "\n%s\n" "$require_line" >> "$local_conf"
    fi
}

check_layers() {
    local missing=0
    
    for layer in poky meta-openembedded meta-raspberrypi meta-rauc meta-lts-mixins; do
        if [ ! -d "$PROJECT_DIR/layers/$layer" ]; then
            log_error "Missing layer: $layer"
            missing=1
        fi
    done
    
    if [ $missing -eq 1 ]; then
        log_error "Please run './scripts/setup-layers.sh' first"
        exit 1
    fi
}

ensure_lts_mixins_layer() {
    local lts_mixins_path="$PROJECT_DIR/layers/meta-lts-mixins"
    
    if [ ! -d "$lts_mixins_path" ]; then
        log_warn "meta-lts-mixins layer not found. Please run './project setup-layers' first."
        return
    fi
    
    # Check if layer is already added
    if bitbake-layers show-layers 2>/dev/null | grep -q "meta-lts-mixins"; then
        return
    fi
    
    log_info "Adding meta-lts-mixins layer for U-Boot RPi5 support..."
    bitbake-layers add-layer "$lts_mixins_path"
}

ensure_rauc_keys() {
    local keys_dir="$PROJECT_DIR/layers/meta-rpi5-rauc/files"
    if [ -f "$keys_dir/ca.cert.pem" ]; then
        return
    fi

    log_warn "RAUC keys not found (missing ca.cert.pem). Generating development keys..."
    "$PROJECT_DIR/scripts/generate-rauc-keys.sh"

    if [ ! -f "$keys_dir/ca.cert.pem" ]; then
        log_error "Failed to generate RAUC keys: $keys_dir/ca.cert.pem still missing"
        log_error "Try running: ./project keys"
        exit 1
    fi
}

clear_parse_cache() {
    log_warn "Clearing BitBake parse cache..."
    rm -f "$PROJECT_DIR/build/cache/bb_codeparser.dat"
    rm -f "$PROJECT_DIR/build/cache/bb_persist_data.sqlite3"
}

build_image() {
    local target="${1:-rpi5-rauc-image}"
    
    log_info "Initializing Yocto build environment..."
    
    cd "$PROJECT_DIR"

    ensure_rauc_keys
    
    source layers/poky/oe-init-build-env build

    ensure_project_build_conf "$PROJECT_DIR/build"
    ensure_lts_mixins_layer
    
    log_info "Starting build for target: $target"
    log_info "This will take a while (1-4 hours depending on your system)..."

    local bb_log
    bb_log="$(mktemp /tmp/bitbake.XXXXXX.log)"

    bitbake "$target" 2>&1 | tee "$bb_log"
    local bb_status=${PIPESTATUS[0]}

    if [ $bb_status -ne 0 ]; then
        if grep -q "Parsing halted due to errors\|Unable to get checksum" "$bb_log"; then
            log_warn "Parse error detected. Clearing cache and retrying..."
            clear_parse_cache

            bitbake "$target"
            bb_status=$?
        fi
    fi

    rm -f "$bb_log" || true

    if [ $bb_status -ne 0 ]; then
        return $bb_status
    fi

    log_info "Build complete!"
    log_info "Image location: $PROJECT_DIR/build/tmp/deploy/images/raspberrypi5/"
}

enter_shell() {
    check_layers
    cd "$PROJECT_DIR"
    source layers/poky/oe-init-build-env build

    ensure_project_build_conf "$PROJECT_DIR/build"
    exec /bin/bash
}

main() {
    local command="${1:-build}"
    
    case "$command" in
        build)
            check_layers
            build_image "${2:-rpi5-rauc-image}"
            ;;
        shell)
            enter_shell
            ;;
        clean)
            log_warn "Cleaning build directory and cache..."
            rm -rf "$PROJECT_DIR/build/tmp"
            rm -rf "$PROJECT_DIR/build/cache"
            log_info "Clean complete. Downloads and sstate-cache preserved."
            ;;
        *)
            echo "Usage: $0 {build|shell|clean} [target]"
            echo ""
            echo "Commands:"
            echo "  build [target]  - Build the specified target (default: rpi5-rauc-image)"
            echo "  shell           - Enter the Yocto build environment shell"
            echo "  clean           - Remove build artifacts and cache"
            exit 1
            ;;
    esac
}

main "$@"
