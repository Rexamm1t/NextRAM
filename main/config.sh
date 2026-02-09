#!/system/bin/sh
MODDIR=${0%/*}/..

add_missing_config_params() {
    local config_file="$MODDIR/config.conf"
    local lock_file="${config_file}.lock"
    local temp_file="${config_file}.tmp.$$"
    
    [ ! -f "$config_file" ] && { log "ERROR" "Config file not found"; return 1; }
    
    exec 9>"$lock_file"
    if ! flock -n 9; then
        log "WARN" "Config file is locked, skipping update"
        exec 9>&-
        return 0
    fi
    
    trap 'rm -f "$temp_file" "$lock_file" 2>/dev/null; exec 9>&-' EXIT
    
    local existing_params=""
    while IFS='=' read -r key value; do
        [ -z "$key" ] && continue
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        case "$key" in
            \#*|'') continue ;;
            *) existing_params="$existing_params $key" ;;
        esac
    done < "$config_file"
    
    local default_config="SWAP_ENABLED=false
SWAP_SIZE_GB=1.0
OVERHEAD_GB=0.3
ZRAM_ENABLED=true
ZRAM_RATIO=1.5
ZRAM_ALGORITHM=lz4
MAX_COMP_STREAMS=4
SWAPPINESS=100
CACHE_PRESSURE=100
DIRTY_RATIO=20
DIRTY_BACKGROUND_RATIO=10
EXTRA_TUNING=false
DYNAMIC_SWAPPINESS=true
PERFORMANCE_MODE=false
ZRAM_AUTO_TUNE=false
LOG_LEVEL=INFO
VM_DIRTY_WRITEBACK_CENTISECS=1500
VM_DIRTY_EXPIRE_CENTISECS=3000
VM_PAGE_CLUSTER=0
VM_LAPTOP_MODE=0
VM_OOM_KILL_ALLOCATING_TASK=0
VM_PANIC_ON_OOM=0
VM_OVERCOMMIT_MEMORY=1
VM_OVERCOMMIT_RATIO=50
VM_WATERMARK_SCALE_FACTOR=10
KERNEL_THREADS_MAX=0
ZRAM_COMPRESSION_LEVEL=1
ZRAM_MEMORY_LIMIT=4G
SWAP_PRIORITY=10
ZRAM_PRIORITY=100
IO_SCHEDULER_TUNE=false
CPU_BOOST=false
NETWORK_TUNE=false
PLAY_ENABLED=true
PLAY_CPU_BOOST=true
PLAY_CPU_GOVERNOR=performance
PLAY_CPU_MIN_FREQ=0
PLAY_CPU_MAX_FREQ=0
PLAY_CPU_MAX_FREQ_PERCENT=100
PLAY_CPU_BOOST_DURATION=2000
PLAY_CPU_BOOST_LEVEL=50
PLAY_GPU_BOOST=true
PLAY_GPU_GOVERNOR=performance
PLAY_GPU_MAX_FREQ_PERCENT=100
PLAY_GPU_TOUCH_BOOST=true
PLAY_TOUCH_BOOST=true
PLAY_TOUCH_POLLING_RATE=250
PLAY_VSYNC_MODE=adaptive
PLAY_DISABLE_HW_OVERLAYS=false
PLAY_FORCE_GPU_RENDER=true
PLAY_NETWORK_TUNE=true
PLAY_NET_RMEM_DEFAULT=262144
PLAY_NET_WMEM_DEFAULT=262144
PLAY_NET_RMEM_MAX=67108864
PLAY_NET_WMEM_MAX=67108864
PLAY_TCP_CONGESTION=bbr
PLAY_SWAPPINESS=20
PLAY_CACHE_PRESSURE=50
PLAY_DIRTY_RATIO=10
PLAY_DIRTY_BG_RATIO=5
PLAY_ZRAM_OPTIMIZE=true
PLAY_CLEAR_CACHES=true
PLAY_THERMAL_CONTROL=true
PLAY_THERMAL_PROFILE=balanced
PLAY_BG_CONTROL=true
PLAY_BG_WHITELIST=com.discord,com.spotify.music,com.chrome
PLAY_BG_KILL_LIMIT=10
PLAY_AUTO_DETECT=true
PLAY_GAME_PROFILE=auto
PLAY_PERF_MONITOR=true
PLAY_PERF_OVERLAY=false
PLAY_AUDIO_LATENCY=low
PLAY_AUDIO_BUFFER=128
PLAY_CHARGING_BOOST=true
PLAY_BATTERY_SAVER=false
PLAY_POWER_LIMIT=0
PLAY_REALTIME_PRIORITY=true
PLAY_CPU_AFFINITY=0-3
PLAY_MEMORY_LOCK=false
PLAY_IOSCHED_TUNE=true"
    
    > "$temp_file"
    while IFS= read -r line; do
        if echo "$line" | grep -qE '^[[:space:]]*#'; then
            echo "$line" >> "$temp_file"
        fi
    done < "$config_file"
    
    while IFS='=' read -r key value; do
        [ -z "$key" ] && continue
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if echo "$existing_params" | grep -q " $key "; then
            while IFS='=' read -r existing_key existing_value; do
                existing_key=$(echo "$existing_key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                [ "$existing_key" = "$key" ] && echo "$key=$existing_value" >> "$temp_file"
            done < "$config_file"
        else
            echo "$key=$value" >> "$temp_file"
            log "INFO" "Added missing param: $key=$value"
        fi
    done << EOF
$default_config
EOF
    
    if cp "$temp_file" "$config_file" 2>/dev/null; then
        chmod 644 "$config_file" 2>/dev/null
        sync
        log "INFO" "Config file updated successfully"
        return 0
    else
        log "ERROR" "Failed to update config file"
        return 1
    fi
}

validate_config_file() {
    local config_file="$MODDIR/config.conf"
    local temp_file="$config_file.tmp"
    
    [ ! -f "$config_file" ] && { log "ERROR" "Config file not found"; return 1; }
    
    grep -v '^[[:space:]]*$' "$config_file" | grep -v '^[[:space:]]*#' > "$temp_file" 2>/dev/null
    
    local invalid_lines=0
    while IFS= read -r line; do
        if ! echo "$line" | grep -q '^[A-Z_][A-Z0-9_]*='; then
            invalid_lines=$((invalid_lines + 1))
            log "WARN" "Invalid config line: $line"
        fi
    done < "$temp_file"
    
    rm -f "$temp_file" 2>/dev/null
    
    [ "$invalid_lines" -gt 0 ] && return 1
    return 0
}

init_config() {
    local config_file="$MODDIR/config.conf"
    local retry_count=3
    local retry_delay=1
    
    for ((i=0; i<retry_count; i++)); do
        if [ -f "$config_file" ]; then
            if [ -r "$config_file" ] && [ -w "$config_file" ]; then
                break
            else
                log "WARN" "Config file permissions issue, attempt $((i+1))"
                chmod 644 "$config_file" 2>/dev/null
            fi
        fi
        sleep $retry_delay
    done
    
    if [ ! -f "$config_file" ]; then
        log "INFO" "Creating new configuration file"
        mkdir -p "$(dirname "$config_file")" 2>/dev/null
        
        local temp_config="${config_file}.new"
        cat > "$temp_config" << 'EOF'
SWAP_ENABLED=false
SWAP_SIZE_GB=1.0
OVERHEAD_GB=0.3
ZRAM_ENABLED=true
ZRAM_RATIO=1.5
ZRAM_ALGORITHM=lz4
MAX_COMP_STREAMS=4
SWAPPINESS=100
CACHE_PRESSURE=100
DIRTY_RATIO=20
DIRTY_BACKGROUND_RATIO=10
EXTRA_TUNING=false
DYNAMIC_SWAPPINESS=true
PERFORMANCE_MODE=false
ZRAM_AUTO_TUNE=false
LOG_LEVEL=INFO
VM_DIRTY_WRITEBACK_CENTISECS=1500
VM_DIRTY_EXPIRE_CENTISECS=3000
VM_PAGE_CLUSTER=0
VM_LAPTOP_MODE=0
VM_OOM_KILL_ALLOCATING_TASK=0
VM_PANIC_ON_OOM=0
VM_OVERCOMMIT_MEMORY=1
VM_OVERCOMMIT_RATIO=50
VM_WATERMARK_SCALE_FACTOR=10
KERNEL_THREADS_MAX=0
ZRAM_COMPRESSION_LEVEL=1
ZRAM_MEMORY_LIMIT=4G
SWAP_PRIORITY=10
ZRAM_PRIORITY=100
IO_SCHEDULER_TUNE=false
CPU_BOOST=false
NETWORK_TUNE=false
PLAY_ENABLED=true
PLAY_CPU_BOOST=true
PLAY_CPU_GOVERNOR=performance
PLAY_CPU_MIN_FREQ=0
PLAY_CPU_MAX_FREQ=0
PLAY_CPU_MAX_FREQ_PERCENT=100
PLAY_CPU_BOOST_DURATION=2000
PLAY_CPU_BOOST_LEVEL=50
PLAY_GPU_BOOST=true
PLAY_GPU_GOVERNOR=performance
PLAY_GPU_MAX_FREQ_PERCENT=100
PLAY_GPU_TOUCH_BOOST=true
PLAY_TOUCH_BOOST=true
PLAY_TOUCH_POLLING_RATE=250
PLAY_VSYNC_MODE=adaptive
PLAY_DISABLE_HW_OVERLAYS=false
PLAY_FORCE_GPU_RENDER=true
PLAY_NETWORK_TUNE=true
PLAY_NET_RMEM_DEFAULT=262144
PLAY_NET_WMEM_DEFAULT=262144
PLAY_NET_RMEM_MAX=67108864
PLAY_NET_WMEM_MAX=67108864
PLAY_TCP_CONGESTION=bbr
PLAY_SWAPPINESS=20
PLAY_CACHE_PRESSURE=50
PLAY_DIRTY_RATIO=10
PLAY_DIRTY_BG_RATIO=5
PLAY_ZRAM_OPTIMIZE=true
PLAY_CLEAR_CACHES=true
PLAY_THERMAL_CONTROL=true
PLAY_THERMAL_PROFILE=balanced
PLAY_BG_CONTROL=true
PLAY_BG_WHITELIST=com.discord,com.spotify.music,com.chrome
PLAY_BG_KILL_LIMIT=10
PLAY_AUTO_DETECT=true
PLAY_GAME_PROFILE=auto
PLAY_PERF_MONITOR=true
PLAY_PERF_OVERLAY=false
PLAY_AUDIO_LATENCY=low
PLAY_AUDIO_BUFFER=128
PLAY_CHARGING_BOOST=true
PLAY_BATTERY_SAVER=false
PLAY_POWER_LIMIT=0
PLAY_REALTIME_PRIORITY=true
PLAY_CPU_AFFINITY=0-3
PLAY_MEMORY_LOCK=false
PLAY_IOSCHED_TUNE=true
EOF
        
        if mv "$temp_config" "$config_file" 2>/dev/null; then
            log "INFO" "Config file created"
        else
            log "ERROR" "Failed to create config file"
            return 1
        fi
    fi
    
    if ! validate_config_file; then
        log "WARN" "Config file validation failed, attempting repair"
        local backup_file="${config_file}.backup.$(date +%s)"
        cp "$config_file" "$backup_file" 2>/dev/null
        
        local essential_params=(
            "SWAP_ENABLED=false"
            "ZRAM_ENABLED=true"
            "LOG_LEVEL=INFO"
            "SWAPPINESS=100"
            "CACHE_PRESSURE=100"
        )
        
        for param in "${essential_params[@]}"; do
            if ! grep -q "^${param%=*}=" "$config_file" 2>/dev/null; then
                echo "$param" >> "$config_file"
            fi
        done
    fi
    
    add_missing_config_params || {
        log "WARN" "Failed to add missing params, using fallback"
    }
    
    if ! . "$config_file" 2>/dev/null; then
        log "ERROR" "Failed to load config file - syntax error?"
        
        local temp_loader="/tmp/nextram_config_loader.$$"
        grep -E '^[A-Z_][A-Z0-9_]*=' "$config_file" > "$temp_loader" 2>/dev/null
        . "$temp_loader" 2>/dev/null
        rm -f "$temp_loader" 2>/dev/null
    fi
    
    export SWAP_ENABLED ZRAM_ENABLED LOG_LEVEL SWAPPINESS CACHE_PRESSURE
    export VM_DIRTY_WRITEBACK_CENTISECS VM_DIRTY_EXPIRE_CENTISECS VM_PAGE_CLUSTER
    export VM_LAPTOP_MODE VM_OOM_KILL_ALLOCATING_TASK VM_PANIC_ON_OOM
    export VM_OVERCOMMIT_MEMORY VM_OVERCOMMIT_RATIO VM_WATERMARK_SCALE_FACTOR
    export KERNEL_THREADS_MAX ZRAM_COMPRESSION_LEVEL ZRAM_MEMORY_LIMIT
    export SWAP_PRIORITY ZRAM_PRIORITY IO_SCHEDULER_TUNE CPU_BOOST NETWORK_TUNE
    export PLAY_ENABLED PLAY_CPU_BOOST PLAY_CPU_GOVERNOR PLAY_CPU_MIN_FREQ
    export PLAY_CPU_MAX_FREQ PLAY_CPU_MAX_FREQ_PERCENT PLAY_CPU_BOOST_DURATION
    export PLAY_CPU_BOOST_LEVEL PLAY_GPU_BOOST PLAY_GPU_GOVERNOR
    export PLAY_GPU_MAX_FREQ_PERCENT PLAY_GPU_TOUCH_BOOST PLAY_TOUCH_BOOST
    export PLAY_TOUCH_POLLING_RATE PLAY_VSYNC_MODE PLAY_DISABLE_HW_OVERLAYS
    export PLAY_FORCE_GPU_RENDER PLAY_NETWORK_TUNE PLAY_NET_RMEM_DEFAULT
    export PLAY_NET_WMEM_DEFAULT PLAY_NET_RMEM_MAX PLAY_NET_WMEM_MAX
    export PLAY_TCP_CONGESTION PLAY_SWAPPINESS PLAY_CACHE_PRESSURE
    export PLAY_DIRTY_RATIO PLAY_DIRTY_BG_RATIO PLAY_ZRAM_OPTIMIZE
    export PLAY_CLEAR_CACHES PLAY_THERMAL_CONTROL PLAY_THERMAL_PROFILE
    export PLAY_BG_CONTROL PLAY_BG_WHITELIST PLAY_BG_KILL_LIMIT
    export PLAY_AUTO_DETECT PLAY_GAME_PROFILE PLAY_PERF_MONITOR
    export PLAY_PERF_OVERLAY PLAY_AUDIO_LATENCY PLAY_AUDIO_BUFFER
    export PLAY_CHARGING_BOOST PLAY_BATTERY_SAVER PLAY_POWER_LIMIT
    export PLAY_REALTIME_PRIORITY PLAY_CPU_AFFINITY PLAY_MEMORY_LOCK
    export PLAY_IOSCHED_TUNE
    
    log "DEBUG" "Configuration initialized successfully"
    return 0
}
