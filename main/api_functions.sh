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
        kill -9 $(cat "$MODDIR/api.pid") 2>/dev/null
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
    echo "  \"LOG_LEVEL\": \"$LOG_LEVEL\","
    echo "  \"VM_DIRTY_WRITEBACK_CENTISECS\": $VM_DIRTY_WRITEBACK_CENTISECS,"
    echo "  \"VM_DIRTY_EXPIRE_CENTISECS\": $VM_DIRTY_EXPIRE_CENTISECS,"
    echo "  \"VM_PAGE_CLUSTER\": $VM_PAGE_CLUSTER,"
    echo "  \"VM_LAPTOP_MODE\": $VM_LAPTOP_MODE,"
    echo "  \"VM_OOM_KILL_ALLOCATING_TASK\": $VM_OOM_KILL_ALLOCATING_TASK,"
    echo "  \"VM_PANIC_ON_OOM\": $VM_PANIC_ON_OOM,"
    echo "  \"VM_OVERCOMMIT_MEMORY\": $VM_OVERCOMMIT_MEMORY,"
    echo "  \"VM_OVERCOMMIT_RATIO\": $VM_OVERCOMMIT_RATIO,"
    echo "  \"VM_WATERMARK_SCALE_FACTOR\": $VM_WATERMARK_SCALE_FACTOR,"
    echo "  \"KERNEL_THREADS_MAX\": $KERNEL_THREADS_MAX,"
    echo "  \"ZRAM_COMPRESSION_LEVEL\": $ZRAM_COMPRESSION_LEVEL,"
    echo "  \"ZRAM_MEMORY_LIMIT\": \"$ZRAM_MEMORY_LIMIT\","
    echo "  \"SWAP_PRIORITY\": $SWAP_PRIORITY,"
    echo "  \"ZRAM_PRIORITY\": $ZRAM_PRIORITY,"
    echo "  \"IO_SCHEDULER_TUNE\": $IO_SCHEDULER_TUNE,"
    echo "  \"CPU_BOOST\": $CPU_BOOST,"
    echo "  \"NETWORK_TUNE\": $NETWORK_TUNE"
    echo "}"
}

set_config() {
    local temp_config="$MODDIR/config.conf.tmp"
    local config_file="$MODDIR/config.conf"
    
    > "$temp_config"
    
    while IFS='=' read -r key value; do
        if [ -n "$key" ] && [[ ! "$key" =~ ^[[:space:]]*# ]]; then
            local found=0
            for setting in "$@"; do
                setting_key="${setting%%=*}"
                if [ "$key" = "$setting_key" ]; then
                    found=1
                    break
                fi
            done
            if [ "$found" -eq 0 ]; then
                echo "$key=$value" >> "$temp_config"
            fi
        fi
    done < "$config_file"
    
    for setting in "$@"; do
        key="${setting%%=*}"
        value="${setting#*=}"
        echo "$key=$value" >> "$temp_config"
    done
    
    cat "$temp_config" > "$config_file"
    rm -f "$temp_config"
    
    . "$config_file"
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
    echo ""
    echo "=== Kernel Parameters ==="
    echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
    echo "Cache pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
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
    apply_advanced_tuning
    log "INFO" "Configuration applied successfully"
}