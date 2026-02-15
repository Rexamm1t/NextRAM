#!/system/bin/sh
MODDIR=${0%/*}/..

start_api_server() {
    log "INFO" "Starting web interface on port 8080"
    if [ -x "$MODDIR/bin/nextram-api-server" ]; then
        "$MODDIR/bin/nextram-api-server" --port 8080 --webroot "$MODDIR/webroot" &
        API_PID=$!
        echo "$API_PID" > "$MODDIR/api.pid" 2>/dev/null
        log "INFO" "Web interface available at: http://localhost:8080 (via compiled server)"
    elif command -v busybox >/dev/null 2>&1 && [ -d "$MODDIR/webroot" ]; then
        busybox httpd -p 8080 -h "$MODDIR/webroot" -f &
        API_PID=$!
        echo "$API_PID" > "$MODDIR/api.pid" 2>/dev/null
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
  "SWAP_ENABLED": ${SWAP_ENABLED:-false},
  "SWAP_SIZE_GB": ${SWAP_SIZE_GB:-1.0},
  "OVERHEAD_GB": ${OVERHEAD_GB:-0.3},
  "ZRAM_ENABLED": ${ZRAM_ENABLED:-true},
  "ZRAM_RATIO": ${ZRAM_RATIO:-1.5},
  "ZRAM_ALGORITHM": "${ZRAM_ALGORITHM:-lz4}",
  "MAX_COMP_STREAMS": ${MAX_COMP_STREAMS:-4},
  "SWAPPINESS": ${SWAPPINESS:-100},
  "CACHE_PRESSURE": ${CACHE_PRESSURE:-100},
  "DIRTY_RATIO": ${DIRTY_RATIO:-20},
  "DIRTY_BACKGROUND_RATIO": ${DIRTY_BACKGROUND_RATIO:-10},
  "EXTRA_TUNING": ${EXTRA_TUNING:-false},
  "DYNAMIC_SWAPPINESS": ${DYNAMIC_SWAPPINESS:-true},
  "PERFORMANCE_MODE": ${PERFORMANCE_MODE:-false},
  "ZRAM_AUTO_TUNE": ${ZRAM_AUTO_TUNE:-false},
  "LOG_LEVEL": "${LOG_LEVEL:-INFO}",
  "VM_DIRTY_WRITEBACK_CENTISECS": ${VM_DIRTY_WRITEBACK_CENTISECS:-1500},
  "VM_DIRTY_EXPIRE_CENTISECS": ${VM_DIRTY_EXPIRE_CENTISECS:-3000},
  "VM_PAGE_CLUSTER": ${VM_PAGE_CLUSTER:-0},
  "VM_LAPTOP_MODE": ${VM_LAPTOP_MODE:-0},
  "VM_OOM_KILL_ALLOCATING_TASK": ${VM_OOM_KILL_ALLOCATING_TASK:-0},
  "VM_PANIC_ON_OOM": ${VM_PANIC_ON_OOM:-0},
  "VM_OVERCOMMIT_MEMORY": ${VM_OVERCOMMIT_MEMORY:-1},
  "VM_OVERCOMMIT_RATIO": ${VM_OVERCOMMIT_RATIO:-50},
  "VM_WATERMARK_SCALE_FACTOR": ${VM_WATERMARK_SCALE_FACTOR:-10},
  "KERNEL_THREADS_MAX": ${KERNEL_THREADS_MAX:-0},
  "ZRAM_COMPRESSION_LEVEL": ${ZRAM_COMPRESSION_LEVEL:-1},
  "ZRAM_MEMORY_LIMIT": "${ZRAM_MEMORY_LIMIT:-4G}",
  "SWAP_PRIORITY": ${SWAP_PRIORITY:-10},
  "ZRAM_PRIORITY": ${ZRAM_PRIORITY:-100},
  "IO_SCHEDULER_TUNE": ${IO_SCHEDULER_TUNE:-false},
  "CPU_BOOST": ${CPU_BOOST:-false},
  "NETWORK_TUNE": ${NETWORK_TUNE:-false},
  "PLAY_ENABLED": ${PLAY_ENABLED:-true},
  "PLAY_CPU_BOOST": ${PLAY_CPU_BOOST:-true},
  "PLAY_CPU_GOVERNOR": "${PLAY_CPU_GOVERNOR:-performance}",
  "PLAY_CPU_MIN_FREQ": ${PLAY_CPU_MIN_FREQ:-0},
  "PLAY_CPU_MAX_FREQ": ${PLAY_CPU_MAX_FREQ:-0},
  "PLAY_CPU_MAX_FREQ_PERCENT": ${PLAY_CPU_MAX_FREQ_PERCENT:-100},
  "PLAY_CPU_BOOST_DURATION": ${PLAY_CPU_BOOST_DURATION:-2000},
  "PLAY_CPU_BOOST_LEVEL": ${PLAY_CPU_BOOST_LEVEL:-50},
  "PLAY_GPU_BOOST": ${PLAY_GPU_BOOST:-true},
  "PLAY_GPU_GOVERNOR": "${PLAY_GPU_GOVERNOR:-performance}",
  "PLAY_GPU_MAX_FREQ_PERCENT": ${PLAY_GPU_MAX_FREQ_PERCENT:-100},
  "PLAY_GPU_TOUCH_BOOST": ${PLAY_GPU_TOUCH_BOOST:-true},
  "PLAY_TOUCH_BOOST": ${PLAY_TOUCH_BOOST:-true},
  "PLAY_TOUCH_POLLING_RATE": ${PLAY_TOUCH_POLLING_RATE:-250},
  "PLAY_VSYNC_MODE": "${PLAY_VSYNC_MODE:-adaptive}",
  "PLAY_DISABLE_HW_OVERLAYS": ${PLAY_DISABLE_HW_OVERLAYS:-false},
  "PLAY_FORCE_GPU_RENDER": ${PLAY_FORCE_GPU_RENDER:-true},
  "PLAY_NETWORK_TUNE": ${PLAY_NETWORK_TUNE:-true},
  "PLAY_NET_RMEM_DEFAULT": ${PLAY_NET_RMEM_DEFAULT:-262144},
  "PLAY_NET_WMEM_DEFAULT": ${PLAY_NET_WMEM_DEFAULT:-262144},
  "PLAY_NET_RMEM_MAX": ${PLAY_NET_RMEM_MAX:-67108864},
  "PLAY_NET_WMEM_MAX": ${PLAY_NET_WMEM_MAX:-67108864},
  "PLAY_TCP_CONGESTION": "${PLAY_TCP_CONGESTION:-bbr}",
  "PLAY_SWAPPINESS": ${PLAY_SWAPPINESS:-20},
  "PLAY_CACHE_PRESSURE": ${PLAY_CACHE_PRESSURE:-50},
  "PLAY_DIRTY_RATIO": ${PLAY_DIRTY_RATIO:-10},
  "PLAY_DIRTY_BG_RATIO": ${PLAY_DIRTY_BG_RATIO:-5},
  "PLAY_ZRAM_OPTIMIZE": ${PLAY_ZRAM_OPTIMIZE:-true},
  "PLAY_CLEAR_CACHES": ${PLAY_CLEAR_CACHES:-true},
  "PLAY_THERMAL_CONTROL": ${PLAY_THERMAL_CONTROL:-true},
  "PLAY_THERMAL_PROFILE": "${PLAY_THERMAL_PROFILE:-balanced}",
  "PLAY_BG_CONTROL": ${PLAY_BG_CONTROL:-true},
  "PLAY_BG_WHITELIST": "${PLAY_BG_WHITELIST:-com.discord,com.spotify.music,com.chrome}",
  "PLAY_BG_KILL_LIMIT": ${PLAY_BG_KILL_LIMIT:-10},
  "PLAY_AUTO_DETECT": ${PLAY_AUTO_DETECT:-true},
  "PLAY_GAME_PROFILE": "${PLAY_GAME_PROFILE:-auto}",
  "PLAY_PERF_MONITOR": ${PLAY_PERF_MONITOR:-true},
  "PLAY_PERF_OVERLAY": ${PLAY_PERF_OVERLAY:-false},
  "PLAY_AUDIO_LATENCY": "${PLAY_AUDIO_LATENCY:-low}",
  "PLAY_AUDIO_BUFFER": ${PLAY_AUDIO_BUFFER:-128},
  "PLAY_CHARGING_BOOST": ${PLAY_CHARGING_BOOST:-true},
  "PLAY_BATTERY_SAVER": ${PLAY_BATTERY_SAVER:-false},
  "PLAY_POWER_LIMIT": ${PLAY_POWER_LIMIT:-0},
  "PLAY_REALTIME_PRIORITY": ${PLAY_REALTIME_PRIORITY:-true},
  "PLAY_CPU_AFFINITY": "${PLAY_CPU_AFFINITY:-0-3}",
  "PLAY_MEMORY_LOCK": ${PLAY_MEMORY_LOCK:-false},
  "PLAY_IOSCHED_TUNE": ${PLAY_IOSCHED_TUNE:-true}
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
    while IFS='=' read -r key value; do
        [ -z "$key" ] && continue
        case "$key" in
            \#*)
                echo "$key=$value" >> "$temp_config" 2>/dev/null
                continue
                ;;
        esac
        local found=0
        for setting in "$@"; do
            local setting_key="${setting%%=*}"
            [ "$key" = "$setting_key" ] && { found=1; break; }
        done
        [ "$found" -eq 0 ] && echo "$key=$value" >> "$temp_config" 2>/dev/null
    done < "$config_file"
    for setting in "$@"; do
        local key="${setting%%=*}"
        local value="${setting#*=}"
        [ -n "$key" ] && [ -n "$value" ] && echo "$key=$value" >> "$temp_config" 2>/dev/null
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
        if [ -x "$MODDIR/bin/nextram-zram-ctl" ]; then
            "$MODDIR/bin/nextram-zram-ctl" stats
        else
            cat /sys/block/zram0/mm_stat 2>/dev/null || echo "Cannot read ZRAM stats"
        fi
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