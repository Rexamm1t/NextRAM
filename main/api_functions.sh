#!/system/bin/sh
MODDIR=${0%/*}/..

start_api_server() {
    log "INFO" "Starting web interface on port 8080"
    if command -v busybox >/dev/null 2>&1 && [ -d "$MODDIR/webroot" ]; then
        busybox httpd -p 8080 -h "$MODDIR/webroot" -f &
        API_PID=$!
        echo $API_PID > "$MODDIR/api.pid" 2>/dev/null
        log "INFO" "Web interface available at: http://localhost:8080"
    else
        log "ERROR" "Cannot start web interface: busybox not found or webroot missing"
    fi
}

stop_api_server() {
    if [ -f "$MODDIR/api.pid" ]; then
        local pid=$(cat "$MODDIR/api.pid" 2>/dev/null)
        if [ -n "$pid" ] && [ -d "/proc/$pid" ]; then
            kill -9 "$pid" 2>/dev/null
        fi
        rm -f "$MODDIR/api.pid" 2>/dev/null
        log "INFO" "Web interface stopped"
    fi
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
  "NETWORK_TUNE": $NETWORK_TUNE,
  "PLAY_ENABLED": $PLAY_ENABLED,
  "PLAY_CPU_BOOST": $PLAY_CPU_BOOST,
  "PLAY_CPU_GOVERNOR": "$PLAY_CPU_GOVERNOR",
  "PLAY_CPU_MIN_FREQ": $PLAY_CPU_MIN_FREQ,
  "PLAY_CPU_MAX_FREQ": $PLAY_CPU_MAX_FREQ,
  "PLAY_CPU_MAX_FREQ_PERCENT": $PLAY_CPU_MAX_FREQ_PERCENT,
  "PLAY_CPU_BOOST_DURATION": $PLAY_CPU_BOOST_DURATION,
  "PLAY_CPU_BOOST_LEVEL": $PLAY_CPU_BOOST_LEVEL,
  "PLAY_GPU_BOOST": $PLAY_GPU_BOOST,
  "PLAY_GPU_GOVERNOR": "$PLAY_GPU_GOVERNOR",
  "PLAY_GPU_MAX_FREQ_PERCENT": $PLAY_GPU_MAX_FREQ_PERCENT,
  "PLAY_GPU_TOUCH_BOOST": $PLAY_GPU_TOUCH_BOOST,
  "PLAY_TOUCH_BOOST": $PLAY_TOUCH_BOOST,
  "PLAY_TOUCH_POLLING_RATE": $PLAY_TOUCH_POLLING_RATE,
  "PLAY_VSYNC_MODE": "$PLAY_VSYNC_MODE",
  "PLAY_DISABLE_HW_OVERLAYS": $PLAY_DISABLE_HW_OVERLAYS,
  "PLAY_FORCE_GPU_RENDER": $PLAY_FORCE_GPU_RENDER,
  "PLAY_NETWORK_TUNE": $PLAY_NETWORK_TUNE,
  "PLAY_NET_RMEM_DEFAULT": $PLAY_NET_RMEM_DEFAULT,
  "PLAY_NET_WMEM_DEFAULT": $PLAY_NET_WMEM_DEFAULT,
  "PLAY_NET_RMEM_MAX": $PLAY_NET_RMEM_MAX,
  "PLAY_NET_WMEM_MAX": $PLAY_NET_WMEM_MAX,
  "PLAY_TCP_CONGESTION": "$PLAY_TCP_CONGESTION",
  "PLAY_SWAPPINESS": $PLAY_SWAPPINESS,
  "PLAY_CACHE_PRESSURE": $PLAY_CACHE_PRESSURE,
  "PLAY_DIRTY_RATIO": $PLAY_DIRTY_RATIO,
  "PLAY_DIRTY_BG_RATIO": $PLAY_DIRTY_BG_RATIO,
  "PLAY_ZRAM_OPTIMIZE": $PLAY_ZRAM_OPTIMIZE,
  "PLAY_CLEAR_CACHES": $PLAY_CLEAR_CACHES,
  "PLAY_THERMAL_CONTROL": $PLAY_THERMAL_CONTROL,
  "PLAY_THERMAL_PROFILE": "$PLAY_THERMAL_PROFILE",
  "PLAY_BG_CONTROL": $PLAY_BG_CONTROL,
  "PLAY_BG_WHITELIST": "$PLAY_BG_WHITELIST",
  "PLAY_BG_KILL_LIMIT": $PLAY_BG_KILL_LIMIT,
  "PLAY_AUTO_DETECT": $PLAY_AUTO_DETECT,
  "PLAY_GAME_PROFILE": "$PLAY_GAME_PROFILE",
  "PLAY_PERF_MONITOR": $PLAY_PERF_MONITOR,
  "PLAY_PERF_OVERLAY": $PLAY_PERF_OVERLAY,
  "PLAY_AUDIO_LATENCY": "$PLAY_AUDIO_LATENCY",
  "PLAY_AUDIO_BUFFER": $PLAY_AUDIO_BUFFER,
  "PLAY_CHARGING_BOOST": $PLAY_CHARGING_BOOST,
  "PLAY_BATTERY_SAVER": $PLAY_BATTERY_SAVER,
  "PLAY_POWER_LIMIT": $PLAY_POWER_LIMIT,
  "PLAY_REALTIME_PRIORITY": $PLAY_REALTIME_PRIORITY,
  "PLAY_CPU_AFFINITY": "$PLAY_CPU_AFFINITY",
  "PLAY_MEMORY_LOCK": $PLAY_MEMORY_LOCK,
  "PLAY_IOSCHED_TUNE": $PLAY_IOSCHED_TUNE
}
EOF
}

set_config() {
    local temp_config="$MODDIR/config.conf.tmp"
    local config_file="$MODDIR/config.conf"
    local lock_file="$MODDIR/config.lock"
    
    [ ! -f "$config_file" ] && { log "ERROR" "Config file not found"; return 1; }
    
    exec 9>"$lock_file" || { log "ERROR" "Cannot lock config file"; return 1; }
    flock -x 9 || { log "ERROR" "Cannot acquire lock"; return 1; }
    
    > "$temp_config" 2>/dev/null || { log "ERROR" "Cannot create temp file"; flock -u 9; return 1; }
    
    local existing_keys=""
    while IFS='=' read -r key value; do
        [ -z "$key" ] && continue
        [[ "$key" =~ ^[[:space:]]*# ]] && { echo "$key=$value" >> "$temp_config"; continue; }
        existing_keys="$existing_keys $key"
        local found=0
        for setting in "$@"; do
            local setting_key="${setting%%=*}"
            [ "$key" = "$setting_key" ] && { found=1; break; }
        done
        [ "$found" -eq 0 ] && echo "$key=$value" >> "$temp_config"
    done < "$config_file"
    
    for setting in "$@"; do
        local key="${setting%%=*}"
        local value="${setting#*=}"
        [ -n "$key" ] && [ -n "$value" ] && echo "$key=$value" >> "$temp_config"
    done
    
    if mv "$temp_config" "$config_file" 2>/dev/null; then
        . "$config_file" 2>/dev/null
        log "INFO" "Configuration updated from web interface"
    else
        log "ERROR" "Failed to update config file"
    fi
    
    flock -u 9
    rm -f "$lock_file" 2>/dev/null
}

get_status() {
    echo "=== Memory Status ==="
    free -m 2>/dev/null || echo "Cannot get memory info"
    echo ""
    echo "=== Swap Status ==="
    cat /proc/swaps 2>/dev/null || echo "Cannot get swap info"
    echo ""
    echo "=== ZRAM Status ==="
    if [ -b "/dev/block/zram0" ] || [ -d "/sys/block/zram0" ]; then
        cat /sys/block/zram0/mm_stat 2>/dev/null || echo "Cannot read ZRAM stats"
    else
        echo "ZRAM not initialized"
    fi
    echo ""
    echo "=== Kernel Parameters ==="
    echo "Swappiness: $(cat /proc/sys/vm/swappiness 2>/dev/null || echo N/A)"
    echo "Cache pressure: $(cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null || echo N/A)"
}

apply_configuration() {
    log "INFO" "Applying current configuration"
    
    swapoff -a 2>/dev/null
    sleep 1
    
    if [ -b "/dev/block/zram0" ]; then
        echo 1 > "/dev/block/zram0/reset" 2>/dev/null
    elif [ -d "/sys/block/zram0" ] && [ -f "/sys/block/zram0/reset" ]; then
        echo 1 > "/sys/block/zram0/reset" 2>/dev/null
    fi
    
    sleep 1
    
    [ "$ZRAM_ENABLED" = "true" ] && setup_zram
    [ "$SWAP_ENABLED" = "true" ] && setup_swap
    
    adjust_swappiness
    apply_kernel_tuning
    apply_advanced_tuning
    
    log "INFO" "Configuration applied successfully"
}