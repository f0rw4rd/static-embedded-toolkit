#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

build_gdb() {
    local arch=$1
    local mode=${2:-release}
    
    log_tool "gdb" "Downloading pre-built static GDB for $arch..."
    
    local variant="${GDB_VARIANT:-both}"
    local has_gdb=false
    
    case "$variant" in
        slim)
            if [ -d "/build/output/$arch/gdb-slim" ] && [ -f "/build/output/$arch/gdb-slim/gdb" ]; then
                has_gdb=true
            fi
            ;;
        full)
            if [ -d "/build/output/$arch/gdb-full" ] && [ -f "/build/output/$arch/gdb-full/gdb" ]; then
                has_gdb=true
            fi
            ;;
        both)
            if [ -d "/build/output/$arch/gdb-slim" ] && [ -f "/build/output/$arch/gdb-slim/gdb" ] && \
               [ -d "/build/output/$arch/gdb-full" ] && [ -f "/build/output/$arch/gdb-full/gdb" ]; then
                has_gdb=true
            fi
            ;;
    esac
    
    if [ "$has_gdb" = "true" ]; then
        log_tool "gdb" "Already built for $arch (variant: $variant)"
        return 0
    fi
    
    "$SCRIPT_DIR/download-gdb-static.sh" download "$arch" "$variant" || {
        log_tool "gdb" "Failed to download GDB for $arch"
        return 1
    }
    
    log_tool "gdb" "Successfully installed GDB for $arch"
    return 0
}

main() {
    local arch="${1:-}"
    local mode="${2:-release}"
    
    if [ -z "$arch" ]; then
        echo "Usage: $0 <architecture> [mode]"
        echo "Example: $0 x86_64"
        echo ""
        echo "This script downloads pre-built static GDB binaries from the gdb-static project"
        exit 1
    fi
    
    build_gdb "$arch" "$mode" || exit 1
}

main "$@"