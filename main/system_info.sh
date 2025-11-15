#!/system/bin/sh
MODDIR=${0%/*}/..

system_info() {
    log "INFO" "starting NextRAM 8.4.201..."
    log "INFO" "kernel: $(uname -r)"
    log "INFO" "android version: $(getprop ro.build.version.release)"
    log "INFO" "device: $(getprop ro.product.model)"

    local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    local mem_free=$(awk '/MemFree/ {print $2}' /proc/meminfo)
    local swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
    local swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo)

    log "INFO" "Total RAM: $((mem_total / 1024))MB | Free: $((mem_free / 1024))MB"
    log "INFO" "Total Swap: $((swap_total / 1024))MB | Free $((swap_free / 1024))MB"
}
