#!/system/bin/sh
MODDIR=${0%/*}/..

system_info() {
    log "INFO" "===== System Information ====="
    log "INFO" "Kernel: $(uname -r)"
    log "INFO" "Android version: $(getprop ro.build.version.release)"
    log "INFO" "Device: $(getprop ro.product.model)"

    local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    local mem_free=$(awk '/MemFree/ {print $2}' /proc/meminfo)
    local swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
    local swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo)

    log "INFO" "Total RAM: $((mem_total / 1024))MB"
    log "INFO" "Free RAM: $((mem_free / 1024))MB"
    log "INFO" "Total Swap: $((swap_total / 1024))MB"
    log "INFO" "Free Swap: $((swap_free / 1024))MB"
}