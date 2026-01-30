#!/system/bin/sh
MODDIR=${0%/*}/..

add_missing_config_params() {
    local config_file="$MODDIR/config.conf"
    local temp_file="$config_file.tmp"
    
    [ ! -f "$config_file" ] && { log "ERROR" "Config file not found"; return 1; }
    
    declare -A current_config
    while IFS='=' read -r key value; do
        [ -z "$key" ] && continue
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -n "$key" ] && current_config["$key"]="$value"
    done < "$config_file"
    
    declare -A default_config=(
        ["SWAP_ENABLED"]="false"
        ["SWAP_SIZE_GB"]="1.0"
        ["OVERHEAD_GB"]="0.3"
        ["ZRAM_ENABLED"]="true"
        ["ZRAM_RATIO"]="1.5"
        ["ZRAM_ALGORITHM"]="lz4"
        ["MAX_COMP_STREAMS"]="4"
        ["SWAPPINESS"]="100"
        ["CACHE_PRESSURE"]="100"
        ["DIRTY_RATIO"]="20"
        ["DIRTY_BACKGROUND_RATIO"]="10"
        ["EXTRA_TUNING"]="false"
        ["DYNAMIC_SWAPPINESS"]="true"
        ["PERFORMANCE_MODE"]="false"
        ["ZRAM_AUTO_TUNE"]="false"
        ["LOG_LEVEL"]="INFO"
        ["VM_DIRTY_WRITEBACK_CENTISECS"]="1500"
        ["VM_DIRTY_EXPIRE_CENTISECS"]="3000"
        ["VM_PAGE_CLUSTER"]="0"
        ["VM_LAPTOP_MODE"]="0"
        ["VM_OOM_KILL_ALLOCATING_TASK"]="0"
        ["VM_PANIC_ON_OOM"]="0"
        ["VM_OVERCOMMIT_MEMORY"]="1"
        ["VM_OVERCOMMIT_RATIO"]="50"
        ["VM_WATERMARK_SCALE_FACTOR"]="10"
        ["KERNEL_THREADS_MAX"]="0"
        ["ZRAM_COMPRESSION_LEVEL"]="1"
        ["ZRAM_MEMORY_LIMIT"]="4G"
        ["SWAP_PRIORITY"]="10"
        ["ZRAM_PRIORITY"]="100"
        ["IO_SCHEDULER_TUNE"]="false"
        ["CPU_BOOST"]="false"
        ["NETWORK_TUNE"]="false"
        ["PLAY_ENABLED"]="true"
        ["PLAY_CPU_BOOST"]="true"
        ["PLAY_CPU_GOVERNOR"]="performance"
        ["PLAY_CPU_MIN_FREQ"]="0"
        ["PLAY_CPU_MAX_FREQ"]="0"
        ["PLAY_CPU_MAX_FREQ_PERCENT"]="100"
        ["PLAY_CPU_BOOST_DURATION"]="2000"
        ["PLAY_CPU_BOOST_LEVEL"]="50"
        ["PLAY_GPU_BOOST"]="true"
        ["PLAY_GPU_GOVERNOR"]="performance"
        ["PLAY_GPU_MAX_FREQ_PERCENT"]="100"
        ["PLAY_GPU_TOUCH_BOOST"]="true"
        ["PLAY_TOUCH_BOOST"]="true"
        ["PLAY_TOUCH_POLLING_RATE"]="250"
        ["PLAY_VSYNC_MODE"]="adaptive"
        ["PLAY_DISABLE_HW_OVERLAYS"]="false"
        ["PLAY_FORCE_GPU_RENDER"]="true"
        ["PLAY_NETWORK_TUNE"]="true"
        ["PLAY_NET_RMEM_DEFAULT"]="262144"
        ["PLAY_NET_WMEM_DEFAULT"]="262144"
        ["PLAY_NET_RMEM_MAX"]="67108864"
        ["PLAY_NET_WMEM_MAX"]="67108864"
        ["PLAY_TCP_CONGESTION"]="bbr"
        ["PLAY_SWAPPINESS"]="20"
        ["PLAY_CACHE_PRESSURE"]="50"
        ["PLAY_DIRTY_RATIO"]="10"
        ["PLAY_DIRTY_BG_RATIO"]="5"
        ["PLAY_ZRAM_OPTIMIZE"]="true"
        ["PLAY_CLEAR_CACHES"]="true"
        ["PLAY_THERMAL_CONTROL"]="true"
        ["PLAY_THERMAL_PROFILE"]="balanced"
        ["PLAY_BG_CONTROL"]="true"
        ["PLAY_BG_WHITELIST"]="com.discord,com.spotify.music,com.chrome"
        ["PLAY_BG_KILL_LIMIT"]="10"
        ["PLAY_AUTO_DETECT"]="true"
        ["PLAY_GAME_PROFILE"]="auto"
        ["PLAY_PERF_MONITOR"]="true"
        ["PLAY_PERF_OVERLAY"]="false"
        ["PLAY_AUDIO_LATENCY"]="low"
        ["PLAY_AUDIO_BUFFER"]="128"
        ["PLAY_CHARGING_BOOST"]="true"
        ["PLAY_BATTERY_SAVER"]="false"
        ["PLAY_POWER_LIMIT"]="0"
        ["PLAY_REALTIME_PRIORITY"]="true"
        ["PLAY_CPU_AFFINITY"]="0-3"
        ["PLAY_MEMORY_LOCK"]="false"
        ["PLAY_IOSCHED_TUNE"]="true"
    )
    
    > "$temp_file" 2>/dev/null || { log "ERROR" "Cannot create temp file"; return 1; }
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*# ]]; then
            echo "$line" >> "$temp_file"
        elif [[ "$line" =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            if [ -n "${default_config[$key]}" ]; then
                echo "$key=$value" >> "$temp_file"
                unset default_config["$key"]
            else
                echo "$line" >> "$temp_file"
                log "DEBUG" "Unknown config parameter: $key"
            fi
        elif [ -n "$line" ]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$config_file"
    
    local missing_count=0
    for key in "${!default_config[@]}"; do
        if [ -n "${default_config[$key]}" ]; then
            echo "$key=${default_config[$key]}" >> "$temp_file"
            log "INFO" "Added missing config: $key=${default_config[$key]}"
            missing_count=$((missing_count + 1))
        fi
    done
    
    if mv "$temp_file" "$config_file" 2>/dev/null; then
        if [ "$missing_count" -gt 0 ]; then
            log "INFO" "Added $missing_count missing configuration parameters"
        fi
    else
        log "ERROR" "Failed to update config file"
        rm -f "$temp_file" 2>/dev/null
        return 1
    fi
    
    return 0
}

validate_config_file() {
    local config_file="$MODDIR/config.conf"
    local temp_file="$config_file.tmp"
    
    [ ! -f "$config_file" ] && { log "ERROR" "Config file not found"; return 1; }
    
    grep -v '^[[:space:]]*$' "$config_file" | \
    grep -v '^[[:space:]]*#' | \
    grep -v '^[[:space:]]*$' > "$temp_file" 2>/dev/null
    
    local invalid_lines=0
    while IFS= read -r line; do
        if [[ ! "$line" =~ ^[A-Z_][A-Z0-9_]*= ]]; then
            invalid_lines=$((invalid_lines + 1))
            log "WARN" "Invalid config line: $line"
        fi
    done < "$temp_file"
    
    rm -f "$temp_file" 2>/dev/null
    
    if [ "$invalid_lines" -gt 0 ]; then
        log "WARN" "Found $invalid_lines invalid lines in config"
        return 1
    fi
    
    return 0
}

init_config() {
    local config_file="$MODDIR/config.conf"
    
    if [ ! -f "$config_file" ]; then
        mkdir -p "$(dirname "$config_file")" 2>/dev/null
        log "INFO" "Creating new configuration file"
        
        cat > "$config_file" << 'EOF'
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
        [ $? -ne 0 ] && { log "ERROR" "Failed to create config file"; return 1; }
    else
        if ! validate_config_file; then
            log "ERROR" "Configuration file is corrupted"
            return 1
        fi
        
        add_missing_config_params || { log "ERROR" "Failed to add missing params"; return 1; }
    fi

    . "$config_file" 2>/dev/null || { log "ERROR" "Failed to load config"; return 1; }
    
    for var in $(set | grep -E '^[A-Z_]+=' | cut -d= -f1); do
        case "$var" in
            SWAP_ENABLED|SWAP_SIZE_GB|OVERHEAD_GB|ZRAM_ENABLED|ZRAM_RATIO|ZRAM_ALGORITHM|MAX_COMP_STREAMS|SWAPPINESS|CACHE_PRESSURE|DIRTY_RATIO|DIRTY_BACKGROUND_RATIO|EXTRA_TUNING|DYNAMIC_SWAPPINESS|PERFORMANCE_MODE|ZRAM_AUTO_TUNE|LOG_LEVEL|VM_DIRTY_WRITEBACK_CENTISECS|VM_DIRTY_EXPIRE_CENTISECS|VM_PAGE_CLUSTER|VM_LAPTOP_MODE|VM_OOM_KILL_ALLOCATING_TASK|VM_PANIC_ON_OOM|VM_OVERCOMMIT_MEMORY|VM_OVERCOMMIT_RATIO|VM_WATERMARK_SCALE_FACTOR|KERNEL_THREADS_MAX|ZRAM_COMPRESSION_LEVEL|ZRAM_MEMORY_LIMIT|SWAP_PRIORITY|ZRAM_PRIORITY|IO_SCHEDULER_TUNE|CPU_BOOST|NETWORK_TUNE|PLAY_ENABLED|PLAY_CPU_BOOST|PLAY_CPU_GOVERNOR|PLAY_CPU_MIN_FREQ|PLAY_CPU_MAX_FREQ|PLAY_CPU_MAX_FREQ_PERCENT|PLAY_CPU_BOOST_DURATION|PLAY_CPU_BOOST_LEVEL|PLAY_GPU_BOOST|PLAY_GPU_GOVERNOR|PLAY_GPU_MAX_FREQ_PERCENT|PLAY_GPU_TOUCH_BOOST|PLAY_TOUCH_BOOST|PLAY_TOUCH_POLLING_RATE|PLAY_VSYNC_MODE|PLAY_DISABLE_HW_OVERLAYS|PLAY_FORCE_GPU_RENDER|PLAY_NETWORK_TUNE|PLAY_NET_RMEM_DEFAULT|PLAY_NET_WMEM_DEFAULT|PLAY_NET_RMEM_MAX|PLAY_NET_WMEM_MAX|PLAY_TCP_CONGESTION|PLAY_SWAPPINESS|PLAY_CACHE_PRESSURE|PLAY_DIRTY_RATIO|PLAY_DIRTY_BG_RATIO|PLAY_ZRAM_OPTIMIZE|PLAY_CLEAR_CACHES|PLAY_THERMAL_CONTROL|PLAY_THERMAL_PROFILE|PLAY_BG_CONTROL|PLAY_BG_WHITELIST|PLAY_BG_KILL_LIMIT|PLAY_AUTO_DETECT|PLAY_GAME_PROFILE|PLAY_PERF_MONITOR|PLAY_PERF_OVERLAY|PLAY_AUDIO_LATENCY|PLAY_AUDIO_BUFFER|PLAY_CHARGING_BOOST|PLAY_BATTERY_SAVER|PLAY_POWER_LIMIT|PLAY_REALTIME_PRIORITY|PLAY_CPU_AFFINITY|PLAY_MEMORY_LOCK|PLAY_IOSCHED_TUNE)
                eval "export $var" 2>/dev/null
                ;;
        esac
    done
    
    log "DEBUG" "Configuration loaded successfully"
    return 0
}
