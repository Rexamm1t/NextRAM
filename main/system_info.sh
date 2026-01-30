#!/system/bin/sh
MODDIR=${0%/*}/..
CONFIG_FILE="/data/adb/modules/NextRAM/module.prop"

system_info() {
    local version="unknown"
    local version_code="unknown"
    
    if [ -f "$CONFIG_FILE" ]; then
        version=$(awk -F= '/^version=/{print $2}' "$CONFIG_FILE" 2>/dev/null)
        version_code=$(awk -F= '/^versionCode=/{print $2}' "$CONFIG_FILE" 2>/dev/null)
    fi
    
    log "INFO" "starting NextRAM $version ($version_code)"
    log "INFO" "kernel: $(uname -r 2>/dev/null || echo unknown)"
    log "INFO" "android version: $(getprop ro.build.version.release 2>/dev/null || echo unknown)"
    log "INFO" "device: $(getprop ro.product.model 2>/dev/null || echo unknown)"

    local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)
    local mem_free=$(awk '/MemFree/ {print $2}' /proc/meminfo 2>/dev/null)
    local swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo 2>/dev/null)
    local swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo 2>/dev/null)

    mem_total=${mem_total:-0}
    mem_free=${mem_free:-0}
    swap_total=${swap_total:-0}
    swap_free=${swap_free:-0}

    log "INFO" "Total RAM: $((mem_total / 1024))MB | Free: $((mem_free / 1024))MB"
    log "INFO" "Total Swap: $((swap_total / 1024))MB | Free: $((swap_free / 1024))MB"
}
