#!/system/bin/sh
MODDIR=${0%/*}/..

check_prerequisites() {
    [ "$(id -u)" -ne 0 ] && { 
        log "ERROR" "Must run as root"
        exit 1
    }

    local missing_tools=""
    for tool in swapon swapoff mkswap mount umount awk grep; do
        if ! command -v $tool >/dev/null 2>&1; then
            missing_tools="$missing_tools $tool"
        fi
    done

    if [ -n "$missing_tools" ]; then
        log "WARN" "Missing tools: $missing_tools"
    fi

    if [ ! -b "/dev/block/zram0" ]; then
        log "WARN" "ZRAM device not found"
        ZRAM_ENABLED=false
    fi
}