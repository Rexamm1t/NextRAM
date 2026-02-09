#!/system/bin/sh
MODDIR=${0%/*}/..

init_play_mode() {
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set in config"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled in config"
        return 0
    fi
    
    log "INFO" "Initializing NextRAM Play gaming mode"
    if [ ! -d "$MODDIR/cache" ]; then
        mkdir -p "$MODDIR/cache" 2>/dev/null
    fi
    log "INFO" "Play mode initialized successfully"
    return 0
}

validate_path() {
    local path="$1"
    if [ -z "$path" ]; then
        log "DEBUG" "validate_path: empty path provided"
        return 1
    fi
    
    if [ ! -e "$path" ]; then
        log "DEBUG" "validate_path: path does not exist: $path"
        return 1
    fi
    
    if [ ! -r "$path" ]; then
        log "DEBUG" "validate_path: path not readable: $path"
        return 1
    fi
    
    return 0
}

write_with_check() {
    local file="$1" 
    local value="$2" 
    local description="$3"
    
    if [ -z "$description" ]; then
        description="parameter"
    fi
    
    if ! validate_path "$file"; then
        log "WARN" "Cannot write $description: $file not valid"
        return 1
    fi
    
    if [ ! -w "$file" ]; then
        log "WARN" "Cannot write $description: $file not writable"
        return 1
    fi
    
    if echo "$value" > "$file" 2>/dev/null; then
        log "DEBUG" "Set $description to $value in $(basename "$file")"
        return 0
    else
        log "WARN" "Failed to set $description to $value in $(basename "$file")"
        return 1
    fi
}

safe_cpu_operation() {
    local cpu_path="$1"
    log "DEBUG" "Performing safe CPU operation on $cpu_path"
    
    if ! validate_path "$cpu_path/scaling_governor"; then
        log "WARN" "CPU governor path not valid: $cpu_path/scaling_governor"
        return 1
    fi
    
    if [ ! -f "$MODDIR/cache/cpu_gov_backup" ]; then
        local current_gov=$(cat "$cpu_path/scaling_governor" 2>/dev/null)
        if [ -n "$current_gov" ]; then
            echo "$current_gov" > "$MODDIR/cache/cpu_gov_backup" 2>/dev/null
            log "DEBUG" "Backed up CPU governor: $current_gov"
        fi
    fi
    
    local target_gov="$PLAY_CPU_GOVERNOR"
    local available_govs=$(cat "$cpu_path/scaling_available_governors" 2>/dev/null)
    
    if echo "$available_govs" | grep -q "$target_gov"; then
        write_with_check "$cpu_path/scaling_governor" "$target_gov" "CPU governor" || log "WARN" "Failed to set CPU governor to $target_gov"
    else
        log "WARN" "Governor $target_gov not available for $cpu_path (available: $available_govs)"
    fi
    
    if [ "$PLAY_CPU_MIN_FREQ" -gt 0 ]; then
        if validate_path "$cpu_path/scaling_min_freq"; then
            local min_freq=$(cat "$cpu_path/scaling_min_freq" 2>/dev/null)
            local target_min=$((PLAY_CPU_MIN_FREQ * 1000))
            if [ -n "$min_freq" ] && [ "$target_min" -gt "$min_freq" ]; then
                write_with_check "$cpu_path/scaling_min_freq" "$target_min" "CPU min freq" || log "WARN" "Failed to set CPU min freq to $target_min"
            fi
        fi
    fi
    
    if [ "$PLAY_CPU_MAX_FREQ" -gt 0 ]; then
        if validate_path "$cpu_path/scaling_max_freq"; then
            write_with_check "$cpu_path/scaling_max_freq" "$((PLAY_CPU_MAX_FREQ * 1000))" "CPU max freq" || log "WARN" "Failed to set CPU max freq to $((PLAY_CPU_MAX_FREQ * 1000))"
        fi
    fi
    
    log "DEBUG" "CPU operation completed for $cpu_path"
    return 0
}

boost_cpu_performance() {
    log "INFO" "Starting CPU performance boost"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping CPU boost"
        return 0
    fi
    
    if [ "$PLAY_CPU_BOOST" != "true" ]; then
        log "DEBUG" "CPU boost disabled in settings"
        return 0
    fi
    
    local cpu_count=0
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
        if [ -d "$cpu" ]; then
            safe_cpu_operation "$cpu"
            cpu_count=$((cpu_count + 1))
        fi
    done
    log "INFO" "Configured CPU performance for $cpu_count cores"
    
    if [ -d "/sys/module/cpu_boost" ]; then
        write_with_check "/sys/module/cpu_boost/parameters/input_boost_ms" "$PLAY_CPU_BOOST_DURATION" "CPU boost duration" || log "WARN" "Failed to set CPU boost duration"
        
        write_with_check "/sys/module/cpu_boost/parameters/input_boost_enabled" "1" "CPU boost enable" || log "WARN" "Failed to enable CPU boost"
        
        if [ -f "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]; then
            write_with_check "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "$PLAY_CPU_BOOST_LEVEL" "CPU boost level" || log "WARN" "Failed to set CPU boost level"
        fi
    else
        log "DEBUG" "CPU boost module not available"
    fi
    
    write_with_check "/proc/sys/kernel/sched_min_task_util_for_colocation" "0" "sched min task util" || log "WARN" "Failed to set sched min task util"
    
    write_with_check "/proc/sys/kernel/sched_migration_fixup" "1" "sched migration fixup" || log "WARN" "Failed to set sched migration fixup"
    
    if [ -d "/dev/cpuset/foreground" ]; then
        write_with_check "/dev/cpuset/foreground/cpus" "0-3" "foreground CPU affinity" || log "WARN" "Failed to set CPU affinity"
    fi
    
    log "INFO" "CPU performance boost completed"
    return 0
}

optimize_gpu_for_gaming() {
    log "INFO" "Starting GPU optimization"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping GPU optimization"
        return 0
    fi
    
    if [ "$PLAY_GPU_BOOST" != "true" ]; then
        log "DEBUG" "GPU boost disabled in settings"
        return 0
    fi
    
    local gpu_paths=""
    
    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        gpu_paths="$gpu_paths /sys/class/kgsl/kgsl-3d0"
    fi
    
    if [ -d "/sys/devices/platform/14ac0000.mali" ]; then
        gpu_paths="$gpu_paths /sys/devices/platform/14ac0000.mali"
    fi
    
    if [ -d "/sys/devices/platform/mali.0" ]; then
        gpu_paths="$gpu_paths /sys/devices/platform/mali.0"
    fi
    
    if [ -d "/sys/class/misc/mali0" ]; then
        gpu_paths="$gpu_paths /sys/class/misc/mali0"
    fi
    
    if [ -d "/sys/kernel/gpu" ]; then
        gpu_paths="$gpu_paths /sys/kernel/gpu"
    fi
    
    if [ -z "$gpu_paths" ]; then
        log "DEBUG" "No GPU control paths found"
        return 0
    fi
    
    for gpu_path in $gpu_paths; do
        log "DEBUG" "Checking GPU path: $gpu_path"
        
        if [ -f "$gpu_path/devfreq/governor" ] && [ -w "$gpu_path/devfreq/governor" ]; then
            write_with_check "$gpu_path/devfreq/governor" "$PLAY_GPU_GOVERNOR" "GPU governor" || log "WARN" "Failed to set GPU governor at $gpu_path"
        fi
        
        if [ -f "$gpu_path/max_gpuclk" ] && [ -w "$gpu_path/max_gpuclk" ]; then
            local max_freq=$(cat "$gpu_path/max_gpuclk" 2>/dev/null)
            if [ -n "$max_freq" ]; then
                local target_freq=$((max_freq * PLAY_GPU_MAX_FREQ_PERCENT / 100))
                write_with_check "$gpu_path/max_gpuclk" "$target_freq" "GPU max frequency" || log "WARN" "Failed to set GPU max frequency at $gpu_path"
            fi
        fi
        
        if [ -f "$gpu_path/throttling" ] && [ -w "$gpu_path/throttling" ]; then
            write_with_check "$gpu_path/throttling" "0" "GPU throttling disable" || log "WARN" "Failed to disable GPU throttling at $gpu_path"
        fi
        
        if [ -f "$gpu_path/dvfs_governor" ] && [ -w "$gpu_path/dvfs_governor" ]; then
            write_with_check "$gpu_path/dvfs_governor" "$PLAY_GPU_GOVERNOR" "Mali GPU governor" || log "WARN" "Failed to set Mali GPU governor at $gpu_path"
        fi
        
        if [ -f "$gpu_path/dvfs_max_lock" ] && [ -w "$gpu_path/dvfs_max_lock" ]; then
            write_with_check "$gpu_path/dvfs_max_lock" "$((PLAY_GPU_MAX_FREQ_PERCENT * 100))" "Mali GPU max lock" || log "WARN" "Failed to set Mali GPU max lock at $gpu_path"
        fi
    done
    
    if [ -d "/proc/gpufreq" ]; then
        if [ -f "/proc/gpufreq/gpufreq_governor" ]; then
            write_with_check "/proc/gpufreq/gpufreq_governor" "$PLAY_GPU_GOVERNOR" "GPU freq governor" || log "WARN" "Failed to set GPU freq governor"
        fi
        
        if [ -f "/proc/gpufreq/gpufreq_max_freq" ]; then
            write_with_check "/proc/gpufreq/gpufreq_max_freq" "$PLAY_GPU_MAX_FREQ_PERCENT" "GPU max freq" || log "WARN" "Failed to set GPU max freq"
        fi
    fi
    
    if [ "$PLAY_GPU_TOUCH_BOOST" = "true" ] && [ -f "/sys/class/kgsl/kgsl-3d0/touch_boost" ]; then
        write_with_check "/sys/class/kgsl/kgsl-3d0/touch_boost" "1" "GPU touch boost" || log "WARN" "Failed to enable GPU touch boost"
    fi
    
    log "INFO" "GPU optimization completed"
    return 0
}

enhance_touch_responsiveness() {
    log "INFO" "Enhancing touch responsiveness"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping touch optimization"
        return 0
    fi
    
    if [ "$PLAY_TOUCH_BOOST" != "true" ]; then
        log "DEBUG" "Touch boost disabled in settings"
        return 0
    fi
    
    local input_count=0
    for input in /sys/class/input/input*; do
        if [ ! -d "$input" ]; then
            continue
        fi
        
        if [ -f "$input/poll" ] && [ -w "$input/poll" ]; then
            echo "1" > "$input/poll" 2>/dev/null
        fi
        
        if [ -n "$PLAY_TOUCH_POLLING_RATE" ] && [ -f "$input/poll_rate" ] && [ -w "$input/poll_rate" ]; then
            echo "$PLAY_TOUCH_POLLING_RATE" > "$input/poll_rate" 2>/dev/null
        fi
        
        input_count=$((input_count + 1))
    done
    log "DEBUG" "Configured $input_count input devices"
    
    write_with_check "/proc/sys/vm/dirty_writeback_centisecs" "0" "dirty writeback centisecs" || log "WARN" "Failed to set dirty writeback centisecs"
    
    write_with_check "/proc/sys/vm/dirty_expire_centisecs" "0" "dirty expire centisecs" || log "WARN" "Failed to set dirty expire centisecs"
    
    case "$PLAY_VSYNC_MODE" in
        "off")
            setprop debug.sf.vsync 0 2>/dev/null && log "DEBUG" "VSync disabled"
            setprop debug.egl.swapinterval 0 2>/dev/null
            ;;
        "adaptive")
            setprop debug.sf.vsync 2 2>/dev/null && log "DEBUG" "VSync set to adaptive"
            setprop debug.egl.swapinterval -1 2>/dev/null
            ;;
        "on")
            setprop debug.sf.vsync 1 2>/dev/null && log "DEBUG" "VSync enabled"
            setprop debug.egl.swapinterval 1 2>/dev/null
            ;;
    esac
    
    if [ "$PLAY_DISABLE_HW_OVERLAYS" = "true" ]; then
        if command -v service >/dev/null 2>&1; then
            service call SurfaceFlinger 1008 i32 1 >/dev/null 2>&1 && log "DEBUG" "Hardware overlays disabled" || log "WARN" "Failed to disable hardware overlays"
        fi
    fi
    
    if [ "$PLAY_FORCE_GPU_RENDER" = "true" ]; then
        setprop debug.sf.hw 1 2>/dev/null && log "DEBUG" "Forced GPU rendering enabled"
    fi
    
    log "INFO" "Touch responsiveness enhancement completed"
    return 0
}

tune_network_for_gaming() {
    log "INFO" "Tuning network for gaming"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping network tuning"
        return 0
    fi
    
    if [ "$PLAY_NETWORK_TUNE" != "true" ]; then
        log "DEBUG" "Network tuning disabled in settings"
        return 0
    fi
    
    write_with_check "/proc/sys/net/core/rmem_default" "$PLAY_NET_RMEM_DEFAULT" "net rmem default" || log "WARN" "Failed to set net rmem default"
    
    write_with_check "/proc/sys/net/core/wmem_default" "$PLAY_NET_WMEM_DEFAULT" "net wmem default" || log "WARN" "Failed to set net wmem default"
    
    write_with_check "/proc/sys/net/core/rmem_max" "$PLAY_NET_RMEM_MAX" "net rmem max" || log "WARN" "Failed to set net rmem max"
    
    write_with_check "/proc/sys/net/core/wmem_max" "$PLAY_NET_WMEM_MAX" "net wmem max" || log "WARN" "Failed to set net wmem max"
    
    write_with_check "/proc/sys/net/ipv4/tcp_fastopen" "3" "TCP fastopen" || log "WARN" "Failed to set TCP fastopen"
    
    write_with_check "/proc/sys/net/ipv4/tcp_tw_reuse" "1" "TCP tw reuse" || log "WARN" "Failed to set TCP tw reuse"
    
    write_with_check "/proc/sys/net/ipv4/tcp_low_latency" "1" "TCP low latency" || log "WARN" "Failed to set TCP low latency"
    
    write_with_check "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0" "TCP slow start after idle" || log "WARN" "Failed to set TCP slow start after idle"
    
    if validate_path "/proc/sys/net/ipv4/tcp_congestion_control"; then
        if validate_path "/proc/sys/net/ipv4/tcp_available_congestion_control"; then
            if grep -q "$PLAY_TCP_CONGESTION" "/proc/sys/net/ipv4/tcp_available_congestion_control" 2>/dev/null; then
                write_with_check "/proc/sys/net/ipv4/tcp_congestion_control" "$PLAY_TCP_CONGESTION" "TCP congestion control" || log "WARN" "Failed to set TCP congestion control to $PLAY_TCP_CONGESTION"
            else
                log "WARN" "TCP congestion control $PLAY_TCP_CONGESTION not available"
            fi
        fi
    fi
    
    write_with_check "/proc/sys/net/core/netdev_max_backlog" "5000" "netdev max backlog" || log "WARN" "Failed to set netdev max backlog"
    
    write_with_check "/proc/sys/net/ipv4/tcp_mtu_probing" "1" "TCP MTU probing" || log "WARN" "Failed to set TCP MTU probing"
    
    if [ -d "/sys/class/net/wlan0" ]; then
        if [ -f "/sys/class/net/wlan0/power_save" ]; then
            write_with_check "/sys/class/net/wlan0/power_save" "0" "WiFi power save" || log "WARN" "Failed to disable WiFi power save"
        fi
        
        if command -v iw >/dev/null 2>&1; then
            iw wlan0 set power_save off >/dev/null 2>&1 && log "DEBUG" "WiFi power save disabled via iw" || log "WARN" "Failed to disable WiFi power save via iw"
        fi
    fi
    
    log "INFO" "Network tuning completed"
    return 0
}

optimize_memory_for_games() {
    log "INFO" "Optimizing memory for gaming"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping memory optimization"
        return 0
    fi
    
    write_with_check "/proc/sys/vm/swappiness" "$PLAY_SWAPPINESS" "swappiness" || log "WARN" "Failed to set swappiness"
    
    write_with_check "/proc/sys/vm/vfs_cache_pressure" "$PLAY_CACHE_PRESSURE" "cache pressure" || log "WARN" "Failed to set cache pressure"
    
    write_with_check "/proc/sys/vm/dirty_ratio" "$PLAY_DIRTY_RATIO" "dirty ratio" || log "WARN" "Failed to set dirty ratio"
    
    write_with_check "/proc/sys/vm/dirty_background_ratio" "$PLAY_DIRTY_BG_RATIO" "dirty background ratio" || log "WARN" "Failed to set dirty background ratio"
    
    write_with_check "/proc/sys/vm/dirty_writeback_centisecs" "0" "dirty writeback centisecs" || log "WARN" "Failed to set dirty writeback centisecs"
    
    write_with_check "/proc/sys/vm/dirty_expire_centisecs" "0" "dirty expire centisecs" || log "WARN" "Failed to set dirty expire centisecs"
    
    if [ "$PLAY_ZRAM_OPTIMIZE" = "true" ] && [ -b "/dev/block/zram0" ]; then
        log "DEBUG" "Optimizing ZRAM for gaming"
        if validate_path "/sys/block/zram0/comp_algorithm"; then
            local available_algs=$(cat "/sys/block/zram0/comp_algorithm" 2>/dev/null)
            if [ -n "$available_algs" ]; then
                if echo "$available_algs" | grep -q "zstd"; then
                    write_with_check "/sys/block/zram0/comp_algorithm" "zstd" "ZRAM compression algorithm" || log "WARN" "Failed to set ZRAM algorithm to zstd"
                elif echo "$available_algs" | grep -q "lz4"; then
                    write_with_check "/sys/block/zram0/comp_algorithm" "lz4" "ZRAM compression algorithm" || log "WARN" "Failed to set ZRAM algorithm to lz4"
                fi
            fi
        fi
        
        if validate_path "/sys/block/zram0/max_comp_streams" ] && [ -f "/proc/cpuinfo" ]; then
            local cores=$(grep -c "^processor" "/proc/cpuinfo" 2>/dev/null || echo "4")
            write_with_check "/sys/block/zram0/max_comp_streams" "$cores" "ZRAM compression streams" || log "WARN" "Failed to set ZRAM compression streams"
        fi
    else
        log "DEBUG" "ZRAM optimization disabled or ZRAM not available"
    fi
    
    if [ "$PLAY_CLEAR_CACHES" = "true" ] && [ -f "/proc/sys/vm/drop_caches" ]; then
        log "DEBUG" "Clearing caches"
        write_with_check "/proc/sys/vm/drop_caches" "3" "drop caches" || log "WARN" "Failed to clear caches"
        sync 2>/dev/null
        log "DEBUG" "Caches cleared"
    fi
    
    log "INFO" "Memory optimization completed"
    return 0
}

manage_thermal_gaming() {
    log "INFO" "Managing thermal settings for gaming"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping thermal management"
        return 0
    fi
    
    if [ "$PLAY_THERMAL_CONTROL" != "true" ]; then
        log "DEBUG" "Thermal control disabled in settings"
        return 0
    fi
    
    local temp_value="85000"
    case "$PLAY_THERMAL_PROFILE" in
        "aggressive") 
            temp_value="95000"
            log "DEBUG" "Using aggressive thermal profile"
            ;;
        "conservative") 
            temp_value="80000"
            log "DEBUG" "Using conservative thermal profile"
            ;;
        "balanced") 
            temp_value="85000"
            log "DEBUG" "Using balanced thermal profile"
            ;;
    esac
    
    local thermal_zones=0
    for thermal in /sys/class/thermal/thermal_zone*; do
        if [ ! -d "$thermal" ]; then
            continue
        fi
        
        if [ -f "$thermal/trip_point_0_temp" ] && [ -w "$thermal/trip_point_0_temp" ]; then
            echo "$temp_value" > "$thermal/trip_point_0_temp" 2>/dev/null
        fi
        
        if [ -f "$thermal/trip_point_1_temp" ] && [ -w "$thermal/trip_point_1_temp" ]; then
            echo "$((temp_value + 10000))" > "$thermal/trip_point_1_temp" 2>/dev/null
        fi
        
        thermal_zones=$((thermal_zones + 1))
    done
    log "DEBUG" "Configured $thermal_zones thermal zones"
    
    if [ -f "/sys/module/msm_thermal/parameters/enabled" ]; then
        write_with_check "/sys/module/msm_thermal/parameters/enabled" "N" "msm thermal enable" || log "WARN" "Failed to set msm thermal enabled"
    fi
    
    if [ -d "/sys/module/msm_thermal/core_control" ] && [ -f "/sys/module/msm_thermal/core_control/enabled" ]; then
        write_with_check "/sys/module/msm_thermal/core_control/enabled" "0" "msm thermal core control" || log "WARN" "Failed to set msm thermal core control"
    fi
    
    log "INFO" "Thermal management completed"
    return 0
}

control_background_processes() {
    log "INFO" "Controlling background processes"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping background control"
        return 0
    fi
    
    if [ "$PLAY_BG_CONTROL" != "true" ]; then
        log "DEBUG" "Background control disabled in settings"
        return 0
    fi
    
    if [ ! -f "$MODDIR/cache/process_backup.txt" ]; then
        ps -A -o pid,cmd > "$MODDIR/cache/process_backup.txt" 2>/dev/null && log "DEBUG" "Backed up process list" || log "WARN" "Failed to backup process list"
    fi
    
    local killed_count=0
    local pids=$(ps -A -o pid 2>/dev/null | grep -E '^[0-9]+' || echo "")
    
    for pid in $pids; do
        if [ "$pid" -eq 1 ]; then
            continue
        fi
        
        if [ ! -d "/proc/$pid" ]; then
            continue
        fi
        
        local cmdline=$(cat "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ')
        if [ -z "$cmdline" ]; then
            continue
        fi
        
        local is_essential=0
        case "$cmdline" in
            *system_server*|*surfaceflinger*|*zygote*|*android.hardware*|*com.android.systemui*|*com.google.android.gms*)
                is_essential=1
                ;;
        esac
        
        if [ "$is_essential" -eq 0 ] && [ -n "$PLAY_BG_WHITELIST" ]; then
            local IFS=','
            for whitelisted in $PLAY_BG_WHITELIST; do
                if echo "$cmdline" | grep -qi "$whitelisted"; then
                    is_essential=1
                    break
                fi
            done
            unset IFS
        fi
        
        if [ "$is_essential" -eq 0 ]; then
            local uid=$(stat -c %u "/proc/$pid" 2>/dev/null)
            if [ -n "$uid" ] && echo "$uid" | grep -qE '^[0-9]+$' && [ "$uid" -ge 10000 ]; then
                if kill -15 "$pid" 2>/dev/null; then
                    sleep 0.1
                    if [ -d "/proc/$pid" ]; then
                        if kill -9 "$pid" 2>/dev/null; then
                            killed_count=$((killed_count + 1))
                            log "DEBUG" "Killed background process: $cmdline (PID: $pid)"
                        fi
                    else
                        killed_count=$((killed_count + 1))
                    fi
                fi
            fi
        fi
        
        if [ "$killed_count" -ge "$PLAY_BG_KILL_LIMIT" ] && [ "$PLAY_BG_KILL_LIMIT" -gt 0 ]; then
            break
        fi
    done
    
    if validate_path "/proc/sys/kernel/threads-max"; then
        local current_threads=$(ps -eLf 2>/dev/null | wc -l)
        if [ -n "$current_threads" ]; then
            local new_limit=$((current_threads * 120 / 100))
            write_with_check "/proc/sys/kernel/threads-max" "$new_limit" "threads max" || log "WARN" "Failed to set threads max"
        fi
    fi
    
    log "INFO" "Background process control completed. Killed $killed_count processes"
    return 0
}

setup_game_detector() {
    log "INFO" "Setting up game detector"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping game detector"
        return 0
    fi
    
    if [ "$PLAY_AUTO_DETECT" != "true" ]; then
        log "DEBUG" "Auto detection disabled in settings"
        return 0
    fi
    
    if [ -f "$MODDIR/cache/game_detector_pid" ]; then
        local old_pid=$(cat "$MODDIR/cache/game_detector_pid" 2>/dev/null)
        if [ -n "$old_pid" ] && [ -d "/proc/$old_pid" ]; then
            kill -9 "$old_pid" 2>/dev/null
            log "DEBUG" "Stopped previous game detector (PID: $old_pid)"
        fi
    fi
    
    log "INFO" "Starting game detector in background"
    nohup sh -c "
    while true; do
        sleep 3
        if ! command -v dumpsys >/dev/null 2>&1; then
            continue
        fi
        
        local current_app=\$(dumpsys window windows 2>/dev/null | \
            grep -E 'mCurrentFocus|mFocusedApp' | \
            grep -oE '[a-zA-Z0-9._]+/[a-zA-Z0-9._]+' | \
            head -1 | cut -d'/' -f1)
        
        if [ -z \"\$current_app\" ]; then
            continue
        fi
        
        local is_game=0
        case \"\$current_app\" in
            *game*|*play*|*pubg*|*cod*|*genshin*|*fortnite*|*minecraft*|*roblox*|*among*|*apex*|*valorant*|*overwatch*|*dota*|*lol*|*mobilelegends*|*freefire*)
                is_game=1
                ;;
        esac
        
        if [ \"\$is_game\" -eq 1 ]; then
            if [ ! -f \"$MODDIR/cache/game_active\" ]; then
                touch \"$MODDIR/cache/game_active\"
                log \"INFO\" \"Game detected: \$current_app - activating game mode\"
                apply_game_mode
                
                if [ -f \"/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor\" ]; then
                    echo \"performance\" > \"/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor\" 2>/dev/null
                fi
                
                if [ -f \"/sys/module/cpu_boost/parameters/input_boost_ms\" ]; then
                    echo \"$PLAY_CPU_BOOST_DURATION\" > \"/sys/module/cpu_boost/parameters/input_boost_ms\" 2>/dev/null
                fi
            fi
        else
            if [ -f \"$MODDIR/cache/game_active\" ]; then
                rm -f \"$MODDIR/cache/game_active\"
                log \"INFO\" \"Game closed - restoring normal mode\"
                restore_normal_mode
            fi
        fi
    done
    " >/dev/null 2>&1 &
    
    local detector_pid=$!
    echo "$detector_pid" > "$MODDIR/cache/game_detector_pid" 2>/dev/null
    log "INFO" "Game detector started (PID: $detector_pid)"
}

apply_game_profile() {
    local profile="$1"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping profile application"
        return 0
    fi
    
    log "INFO" "Applying game profile: $profile"
    case "$profile" in
        "fps_competitive")
            PLAY_CPU_GOVERNOR="performance"
            PLAY_GPU_GOVERNOR="performance"
            PLAY_TOUCH_POLLING_RATE=250
            PLAY_VSYNC_MODE="off"
            PLAY_TCP_CONGESTION="bbr"
            PLAY_SWAPPINESS=20
            PLAY_THERMAL_PROFILE="aggressive"
            log "DEBUG" "Applied FPS Competitive profile"
            ;;
        "open_world")
            PLAY_CPU_GOVERNOR="interactive"
            PLAY_GPU_GOVERNOR="msm-adreno-tz"
            PLAY_TOUCH_POLLING_RATE=180
            PLAY_VSYNC_MODE="adaptive"
            PLAY_ZRAM_OPTIMIZE=true
            PLAY_CACHE_PRESSURE=50
            log "DEBUG" "Applied Open World profile"
            ;;
        "casual")
            PLAY_CPU_GOVERNOR="schedutil"
            PLAY_GPU_GOVERNOR="simple_ondemand"
            PLAY_TOUCH_POLLING_RATE=120
            PLAY_VSYNC_MODE="on"
            PLAY_BG_CONTROL=true
            log "DEBUG" "Applied Casual profile"
            ;;
        "battery_saver")
            PLAY_CPU_GOVERNOR="powersave"
            PLAY_GPU_GOVERNOR="powersave"
            PLAY_TOUCH_BOOST=false
            PLAY_NETWORK_TUNE=false
            PLAY_THERMAL_PROFILE="conservative"
            log "DEBUG" "Applied Battery Saver profile"
            ;;
        "custom")
            if [ -f "$MODDIR/profiles/custom.profile" ]; then
                . "$MODDIR/profiles/custom.profile" 2>/dev/null
                log "DEBUG" "Applied Custom profile"
            else
                log "WARN" "Custom profile file not found: $MODDIR/profiles/custom.profile"
            fi
            ;;
        *)
            log "WARN" "Unknown profile: $profile"
            return 1
            ;;
    esac
    
    apply_game_mode
    log "INFO" "Game profile $profile applied successfully"
}

start_performance_monitor() {
    log "INFO" "Starting performance monitor"
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "DEBUG" "Play mode disabled, skipping performance monitor"
        return 0
    fi
    
    if [ "$PLAY_PERF_MONITOR" != "true" ]; then
        log "DEBUG" "Performance monitor disabled in settings"
        return 0
    fi
    
    if [ -f "$MODDIR/cache/perf_monitor_pid" ]; then
        local old_pid=$(cat "$MODDIR/cache/perf_monitor_pid" 2>/dev/null)
        if [ -n "$old_pid" ] && [ -d "/proc/$old_pid" ]; then
            kill -9 "$old_pid" 2>/dev/null
            log "DEBUG" "Stopped previous performance monitor (PID: $old_pid)"
        fi
    fi
    
    mkdir -p "$MODDIR/logs" 2>/dev/null
    log "INFO" "Performance monitor started"
}

apply_game_mode() {
    log "INFO" "=== APPLYING GAME MODE ==="
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "ERROR" "Play mode is disabled in configuration"
        return 1
    fi
    
    mkdir -p "$MODDIR/cache" 2>/dev/null
    
    log "INFO" "Starting game mode optimizations..."
    
    boost_cpu_performance || log "WARN" "CPU boost failed"
    optimize_gpu_for_gaming || log "WARN" "GPU optimization failed"
    enhance_touch_responsiveness || log "WARN" "Touch enhancement failed"
    tune_network_for_gaming || log "WARN" "Network tuning failed"
    optimize_memory_for_games || log "WARN" "Memory optimization failed"
    manage_thermal_gaming || log "WARN" "Thermal management failed"
    control_background_processes || log "WARN" "Background control failed"
    
    if [ "$PLAY_PERF_MONITOR" = "true" ]; then
        start_performance_monitor || log "WARN" "Performance monitor failed"
    fi
    
    touch "$MODDIR/cache/game_mode_active" 2>/dev/null
    log "INFO" "=== GAME MODE ACTIVATED ==="
    log "INFO" "Game mode optimizations applied successfully"
}

restore_normal_mode() {
    log "INFO" "=== RESTORING NORMAL MODE ==="
    
    if [ -z "$PLAY_ENABLED" ]; then
        log "ERROR" "PLAY_ENABLED not set"
        return 1
    fi
    
    if [ "$PLAY_ENABLED" != "true" ]; then
        log "ERROR" "Play mode is disabled in configuration"
        return 1
    fi
    
    log "INFO" "Restoring normal system settings..."
    
    if [ -f "$MODDIR/cache/cpu_gov_backup" ]; then
        local saved_gov=$(cat "$MODDIR/cache/cpu_gov_backup" 2>/dev/null)
        if [ -n "$saved_gov" ]; then
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
                if [ -d "$cpu" ]; then
                    write_with_check "$cpu/scaling_governor" "$saved_gov" "CPU governor restore" || true
                fi
            done
            log "DEBUG" "Restored CPU governor to: $saved_gov"
        fi
        rm -f "$MODDIR/cache/cpu_gov_backup" 2>/dev/null
    fi
    
    for thermal in /sys/class/thermal/thermal_zone*; do
        if [ ! -d "$thermal" ]; then
            continue
        fi
        
        if [ -f "$thermal/trip_point_0_temp" ] && [ -w "$thermal/trip_point_0_temp" ]; then
            echo "85000" > "$thermal/trip_point_0_temp" 2>/dev/null
        fi
        
        if [ -f "$thermal/trip_point_1_temp" ] && [ -w "$thermal/trip_point_1_temp" ]; then
            echo "95000" > "$thermal/trip_point_1_temp" 2>/dev/null
        fi
    done
    log "DEBUG" "Restored thermal settings"
    
    if [ -d "/sys/class/net/wlan0" ] && [ -f "/sys/class/net/wlan0/power_save" ]; then
        write_with_check "/sys/class/net/wlan0/power_save" "1" "WiFi power save restore" || true
        if command -v iw >/dev/null 2>&1; then
            iw wlan0 set power_save on >/dev/null 2>&1 && log "DEBUG" "Restored WiFi power save via iw" || log "WARN" "Failed to restore WiFi power save via iw"
        fi
    fi
    
    setprop debug.sf.vsync 1 2>/dev/null && log "DEBUG" "Restored VSync"
    setprop debug.egl.swapinterval 1 2>/dev/null && log "DEBUG" "Restored EGL swap interval"
    
    rm -f "$MODDIR/cache/game_mode_active" "$MODDIR/cache/game_active" 2>/dev/null
    log "DEBUG" "Cleared game mode flags"
    
    if [ -f "$MODDIR/cache/game_detector_pid" ]; then
        local detector_pid=$(cat "$MODDIR/cache/game_detector_pid" 2>/dev/null)
        if [ -n "$detector_pid" ] && [ -d "/proc/$detector_pid" ]; then
            kill -9 "$detector_pid" 2>/dev/null
            log "DEBUG" "Stopped game detector (PID: $detector_pid)"
        fi
        rm -f "$MODDIR/cache/game_detector_pid" 2>/dev/null
    fi
    
    if [ -f "$MODDIR/cache/perf_monitor_pid" ]; then
        local monitor_pid=$(cat "$MODDIR/cache/perf_monitor_pid" 2>/dev/null)
        if [ -n "$monitor_pid" ] && [ -d "/proc/$monitor_pid" ]; then
            kill -9 "$monitor_pid" 2>/dev/null
            log "DEBUG" "Stopped performance monitor (PID: $monitor_pid)"
        fi
        rm -f "$MODDIR/cache/perf_monitor_pid" 2>/dev/null
    fi
    
    log "INFO" "=== NORMAL MODE RESTORED ==="
    log "INFO" "All game mode settings have been reverted"
}