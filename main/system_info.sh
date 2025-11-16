#!/system/bin/sh
MODDIR=${0%/*}/..
CONFIG_FILE="/data/adb/modules/NextRAM/module.prop"

system_info() {
    log "INFO" "starting NextRAM $(awk -F= '/^version=/{print $2}' "$CONFIG_FILE") ($(awk -F= '/^versionCode=/{print $2}' "$CONFIG_FILE"))"
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
