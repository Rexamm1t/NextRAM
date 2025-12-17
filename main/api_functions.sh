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
    [ -f "$MODDIR/api.pid" ] && {
        kill -9 $(cat "$MODDIR/api.pid") 2>/dev/null
        rm -f "$MODDIR/api.pid"
        log "INFO" "Web interface stopped"
    }
}

get_config() {
    cat << EOF
{
  "SWAP_ENABLED": $SWAP_ENABLED,
  "SWAP_SIZE_GB": $SWAP_SIZE_GB,
  "OVERHEAD_GB": $OVERHEAD_GB,
  "ZRAM_ENABLED": $ZRAM_ENABLED,
  "ZRAM_RATIO": $ZRAM_RATIO,
  "ZRAM_ALGORITHM": "$ZRAM_ALGORITHM",
  "MAX_COMP_STREAMS": $MAX_COMP_STREAMS,
  "SWAPPINESS": $SWAPPINESS,
  "CACHE_PRESSURE": $CACHE_PRESSURE,
  "DIRTY_RATIO": $DIRTY_RATIO,
  "DIRTY_BACKGROUND_RATIO": $DIRTY_BACKGROUND_RATIO,
  "EXTRA_TUNING": $EXTRA_TUNING,
  "DYNAMIC_SWAPPINESS": $DYNAMIC_SWAPPINESS,
  "PERFORMANCE_MODE": $PERFORMANCE_MODE,
  "ZRAM_AUTO_TUNE": $ZRAM_AUTO_TUNE,
  "LOG_LEVEL": "$LOG_LEVEL",
  "VM_DIRTY_WRITEBACK_CENTISECS": $VM_DIRTY_WRITEBACK_CENTISECS,
  "VM_DIRTY_EXPIRE_CENTISECS": $VM_DIRTY_EXPIRE_CENTISECS,
  "VM_PAGE_CLUSTER": $VM_PAGE_CLUSTER,
  "VM_LAPTOP_MODE": $VM_LAPTOP_MODE,
  "VM_OOM_KILL_ALLOCATING_TASK": $VM_OOM_KILL_ALLOCATING_TASK,
  "VM_PANIC_ON_OOM": $VM_PANIC_ON_OOM,
  "VM_OVERCOMMIT_MEMORY": $VM_OVERCOMMIT_MEMORY,
  "VM_OVERCOMMIT_RATIO": $VM_OVERCOMMIT_RATIO,
  "VM_WATERMARK_SCALE_FACTOR": $VM_WATERMARK_SCALE_FACTOR,
  "KERNEL_THREADS_MAX": $KERNEL_THREADS_MAX,
  "ZRAM_COMPRESSION_LEVEL": $ZRAM_COMPRESSION_LEVEL,
  "ZRAM_MEMORY_LIMIT": "$ZRAM_MEMORY_LIMIT",
  "SWAP_PRIORITY": $SWAP_PRIORITY,
  "ZRAM_PRIORITY": $ZRAM_PRIORITY,
  "IO_SCHEDULER_TUNE": $IO_SCHEDULER_TUNE,
  "CPU_BOOST": $CPU_BOOST,
  "NETWORK_TUNE": $NETWORK_TUNE
}
EOF
}

set_config() {
    local temp_config="$MODDIR/config.conf.tmp"
    local config_file="$MODDIR/config.conf"
    
    > "$temp_config"
    
    while IFS='=' read -r key value; do
        [ -n "$key" ] && [[ ! "$key" =~ ^[[:space:]]*# ]] && {
            local found=0
            for setting in "$@"; do
                [ "$key" = "${setting%%=*}" ] && { found=1; break; }
            done
            [ "$found" -eq 0 ] && echo "$key=$value" >> "$temp_config"
        }
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
    [ -b "/dev/block/zram0" ] && cat /sys/block/zram0/mm_stat 2>/dev/null || echo "ZRAM not initialized"
    echo ""
    echo "=== Kernel Parameters ==="
    echo "Swappiness: $(cat /proc/sys/vm/swappiness 2>/dev/null || echo N/A)"
    echo "Cache pressure: $(cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null || echo N/A)"
}

apply_configuration() {
    log "INFO" "Applying current configuration"
    swapoff -a 2>/dev/null
    [ -b "/dev/block/zram0" ] && echo 1 > "/dev/block/zram0/reset" 2>/dev/null
    [ "$ZRAM_ENABLED" = "true" ] && setup_zram
    [ "$SWAP_ENABLED" = "true" ] && setup_swap
    adjust_swappiness
    apply_kernel_tuning
    apply_advanced_tuning
    log "INFO" "Configuration applied successfully"
}