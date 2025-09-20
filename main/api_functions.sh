#!/system/bin/sh
MODDIR=${0%/*}/..

start_api_server() {
    log "INFO" "Starting web interface on port 8080"
    busybox httpd -p 8080 -h "$MODDIR/webroot" -f &
    API_PID=$!
    echo $API_PID > "$MODDIR/api.pid"
    log "INFO" "Web interface available at: http://localhost:8080"
}

stop_api_server() {
    if [ -f "$MODDIR/api.pid" ]; then
        kill $(cat "$MODDIR/api.pid") 2>/dev/null
        rm -f "$MODDIR/api.pid"
        log "INFO" "Web interface stopped"
    fi
}

get_config() {
    echo "{"
    echo "  \"SWAP_ENABLED\": $SWAP_ENABLED,"
    echo "  \"SWAP_SIZE_GB\": $SWAP_SIZE_GB,"
    echo "  \"OVERHEAD_GB\": $OVERHEAD_GB,"
    echo "  \"ZRAM_ENABLED\": $ZRAM_ENABLED,"
    echo "  \"ZRAM_RATIO\": $ZRAM_RATIO,"
    echo "  \"ZRAM_ALGORITHM\": \"$ZRAM_ALGORITHM\","
    echo "  \"MAX_COMP_STREAMS\": $MAX_COMP_STREAMS,"
    echo "  \"SWAPPINESS\": $SWAPPINESS,"
    echo "  \"CACHE_PRESSURE\": $CACHE_PRESSURE,"
    echo "  \"DIRTY_RATIO\": $DIRTY_RATIO,"
    echo "  \"DIRTY_BACKGROUND_RATIO\": $DIRTY_BACKGROUND_RATIO,"
    echo "  \"EXTRA_TUNING\": $EXTRA_TUNING,"
    echo "  \"DYNAMIC_SWAPPINESS\": $DYNAMIC_SWAPPINESS,"
    echo "  \"PERFORMANCE_MODE\": $PERFORMANCE_MODE,"
    echo "  \"ZRAM_AUTO_TUNE\": $ZRAM_AUTO_TUNE,"
    echo "  \"LOG_LEVEL\": \"$LOG_LEVEL\""
    echo "}"
}

set_config() {
    for setting in "$@"; do
        key="${setting%%=*}"
        value="${setting#*=}"
        sed -i "s/^${key}=.*/${key}=${value}/" "$MODDIR/config.conf"
    done
    log "INFO" "Configuration updated from web interface"
}

get_status() {
    echo "=== Memory Status ==="
    free -m
    echo ""
    echo "=== Swap Status ==="
    cat /proc/swaps
    echo ""
    echo "=== ZRAM Status ==="
    if [ -b "/dev/block/zram0" ]; then
        cat /sys/block/zram0/mm_stat 2>/dev/null || echo "ZRAM not initialized"
    else
        echo "ZRAM device not available"
    fi
}

apply_configuration() {
    log "INFO" "Applying current configuration"

    swapoff -a 2>/dev/null

    if [ -b "/dev/block/zram0" ]; then
        echo 1 > "/dev/block/zram0/reset" 2>/dev/null
    fi

    if [ "$ZRAM_ENABLED" = "true" ]; then
        setup_zram
    fi

    if [ "$SWAP_ENABLED" = "true" ]; then
        setup_swap
    fi

    adjust_swappiness
    apply_kernel_tuning

    log "INFO" "Configuration applied successfully"
}