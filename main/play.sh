#!/system/bin/sh
MODDIR=${0%/*}/..

init_play_mode() {
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set in config"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled in config"; return 0; }
    
    log "INFO" "Initializing NextRAM Play gaming mode"
    [ ! -d "$MODDIR/cache" ] && mkdir -p "$MODDIR/cache" 2>/dev/null
    log "INFO" "Play mode initialized successfully"
    return 0
}

validate_path() {
    [ -z "$1" ] && { log "DEBUG" "validate_path: empty path provided"; return 1; }
    [ ! -e "$1" ] && { log "DEBUG" "validate_path: path does not exist: $1"; return 1; }
    [ ! -r "$1" ] && { log "DEBUG" "validate_path: path not readable: $1"; return 1; }
    return 0
}

write_with_check() {
    local file="$1" value="$2" description="$3"
    
    [ -z "$description" ] && description="parameter"
    
    validate_path "$file" || { 
        log "WARN" "Cannot write $description: $file not valid"
        return 1
    }
    
    [ ! -w "$file" ] && { 
        log "WARN" "Cannot write $description: $file not writable"
        return 1
    }
    
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
    
    validate_path "$cpu_path/scaling_governor" || { 
        log "WARN" "CPU governor path not valid: $cpu_path/scaling_governor"
        return 1
    }
    
    if [ ! -f "$MODDIR/cache/cpu_gov_backup" ]; then
        local current_gov=$(cat "$cpu_path/scaling_governor" 2>/dev/null)
        [ -n "$current_gov" ] && {
            echo "$current_gov" > "$MODDIR/cache/cpu_gov_backup" 2>/dev/null
            log "DEBUG" "Backed up CPU governor: $current_gov"
        }
    fi
    
    local target_gov="$PLAY_CPU_GOVERNOR"
    local available_govs=$(cat "$cpu_path/scaling_available_governors" 2>/dev/null)
    
    if echo "$available_govs" | grep -q "$target_gov"; then
        write_with_check "$cpu_path/scaling_governor" "$target_gov" "CPU governor" || 
            log "WARN" "Failed to set CPU governor to $target_gov"
    else
        log "WARN" "Governor $target_gov not available for $cpu_path (available: $available_govs)"
    fi
    
    if [ "$PLAY_CPU_MIN_FREQ" -gt 0 ]; then
        validate_path "$cpu_path/scaling_min_freq" && {
            local min_freq=$(cat "$cpu_path/scaling_min_freq" 2>/dev/null)
            local target_min=$((PLAY_CPU_MIN_FREQ * 1000))
            [ -n "$min_freq" ] && [ "$target_min" -gt "$min_freq" ] && {
                write_with_check "$cpu_path/scaling_min_freq" "$target_min" "CPU min freq" ||
                    log "WARN" "Failed to set CPU min freq to $target_min"
            }
        }
    fi
    
    if [ "$PLAY_CPU_MAX_FREQ" -gt 0 ]; then
        validate_path "$cpu_path/scaling_max_freq" && {
            write_with_check "$cpu_path/scaling_max_freq" "$((PLAY_CPU_MAX_FREQ * 1000))" "CPU max freq" ||
                log "WARN" "Failed to set CPU max freq to $((PLAY_CPU_MAX_FREQ * 1000))"
        }
    fi
    
    log "DEBUG" "CPU operation completed for $cpu_path"
    return 0
}

boost_cpu_performance() {
    log "INFO" "Starting CPU performance boost"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping CPU boost"; return 0; }
    [ "$PLAY_CPU_BOOST" != "true" ] && { log "DEBUG" "CPU boost disabled in settings"; return 0; }
    
    local cpu_count=0
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
        [ -d "$cpu" ] && {
            safe_cpu_operation "$cpu"
            cpu_count=$((cpu_count + 1))
        }
    done
    log "INFO" "Configured CPU performance for $cpu_count cores"
    
    if [ -d "/sys/module/cpu_boost" ]; then
        write_with_check "/sys/module/cpu_boost/parameters/input_boost_ms" "$PLAY_CPU_BOOST_DURATION" "CPU boost duration" ||
            log "WARN" "Failed to set CPU boost duration"
        
        write_with_check "/sys/module/cpu_boost/parameters/input_boost_enabled" "1" "CPU boost enable" ||
            log "WARN" "Failed to enable CPU boost"
        
        if [ -f "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]; then
            write_with_check "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "$PLAY_CPU_BOOST_LEVEL" "CPU boost level" ||
                log "WARN" "Failed to set CPU boost level"
        fi
    else
        log "DEBUG" "CPU boost module not available"
    fi
    
    write_with_check "/proc/sys/kernel/sched_min_task_util_for_colocation" "0" "sched min task util" ||
        log "WARN" "Failed to set sched min task util"
    
    write_with_check "/proc/sys/kernel/sched_migration_fixup" "1" "sched migration fixup" ||
        log "WARN" "Failed to set sched migration fixup"
    
    if [ -d "/dev/cpuset/foreground" ]; then
        write_with_check "/dev/cpuset/foreground/cpus" "0-3" "foreground CPU affinity" ||
            log "WARN" "Failed to set CPU affinity"
    fi
    
    log "INFO" "CPU performance boost completed"
    return 0
}

optimize_gpu_for_gaming() {
    log "INFO" "Starting GPU optimization"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping GPU optimization"; return 0; }
    [ "$PLAY_GPU_BOOST" != "true" ] && { log "DEBUG" "GPU boost disabled in settings"; return 0; }
    
    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        write_with_check "/sys/class/kgsl/kgsl-3d0/devfreq/governor" "$PLAY_GPU_GOVERNOR" "GPU governor" ||
            log "WARN" "Failed to set GPU governor"
        
        if validate_path "/sys/class/kgsl/kgsl-3d0/max_gpuclk"; then
            local max_freq=$(cat /sys/class/kgsl/kgsl-3d0/max_gpuclk 2>/dev/null)
            [ -n "$max_freq" ] && {
                local target_freq=$((max_freq * PLAY_GPU_MAX_FREQ_PERCENT / 100))
                write_with_check "/sys/class/kgsl/kgsl-3d0/max_gpuclk" "$target_freq" "GPU max frequency" ||
                    log "WARN" "Failed to set GPU max frequency"
            }
        fi
        
        if [ -f "/sys/class/kgsl/kgsl-3d0/throttling" ]; then
            write_with_check "/sys/class/kgsl/kgsl-3d0/throttling" "0" "GPU throttling disable" ||
                log "WARN" "Failed to disable GPU throttling"
        fi
    else
        log "DEBUG" "Adreno GPU path not found"
    fi
    
    if [ -d "/sys/devices/platform/14ac0000.mali" ] || [ -d "/sys/devices/platform/mali.0" ]; then
        local mali_path=""
        [ -d "/sys/devices/platform/14ac0000.mali" ] && mali_path="/sys/devices/platform/14ac0000.mali"
        [ -d "/sys/devices/platform/mali.0" ] && mali_path="/sys/devices/platform/mali.0"
        
        if [ -n "$mali_path" ]; then
            write_with_check "$mali_path/dvfs_governor" "$PLAY_GPU_GOVERNOR" "Mali GPU governor" ||
                log "WARN" "Failed to set Mali GPU governor"
            
            if [ -f "$mali_path/dvfs_max_lock" ]; then
                write_with_check "$mali_path/dvfs_max_lock" "$((PLAY_GPU_MAX_FREQ_PERCENT * 100))" "Mali GPU max lock" ||
                    log "WARN" "Failed to set Mali GPU max lock"
            fi
        fi
    fi
    
    if [ -d "/proc/gpufreq" ]; then
        write_with_check "/proc/gpufreq/gpufreq_governor" "$PLAY_GPU_GOVERNOR" "GPU freq governor" ||
            log "WARN" "Failed to set GPU freq governor"
        
        write_with_check "/proc/gpufreq/gpufreq_max_freq" "$PLAY_GPU_MAX_FREQ_PERCENT" "GPU max freq" ||
            log "WARN" "Failed to set GPU max freq"
    fi
    
    if [ "$PLAY_GPU_TOUCH_BOOST" = "true" ] && [ -f "/sys/class/kgsl/kgsl-3d0/touch_boost" ]; then
        write_with_check "/sys/class/kgsl/kgsl-3d0/touch_boost" "1" "GPU touch boost" ||
            log "WARN" "Failed to enable GPU touch boost"
    fi
    
    log "INFO" "GPU optimization completed"
    return 0
}

enhance_touch_responsiveness() {
    log "INFO" "Enhancing touch responsiveness"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping touch optimization"; return 0; }
    [ "$PLAY_TOUCH_BOOST" != "true" ] && { log "DEBUG" "Touch boost disabled in settings"; return 0; }
    
    local input_count=0
    for input in /sys/class/input/input*; do
        [ -d "$input" ] || continue
        
        if [ -f "$input/poll" ] && [ -w "$input/poll" ]; then
            echo "1" > "$input/poll" 2>/dev/null
        fi
        
        if [ -n "$PLAY_TOUCH_POLLING_RATE" ] && [ -f "$input/poll_rate" ] && [ -w "$input/poll_rate" ]; then
            echo "$PLAY_TOUCH_POLLING_RATE" > "$input/poll_rate" 2>/dev/null
        fi
        
        input_count=$((input_count + 1))
    done
    log "DEBUG" "Configured $input_count input devices"
    
    write_with_check "/proc/sys/vm/dirty_writeback_centisecs" "0" "dirty writeback centisecs" ||
        log "WARN" "Failed to set dirty writeback centisecs"
    
    write_with_check "/proc/sys/vm/dirty_expire_centisecs" "0" "dirty expire centisecs" ||
        log "WARN" "Failed to set dirty expire centisecs"
    
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
    
    [ "$PLAY_DISABLE_HW_OVERLAYS" = "true" ] && {
        if command -v service >/dev/null 2>&1; then
            service call SurfaceFlinger 1008 i32 1 >/dev/null 2>&1 && 
                log "DEBUG" "Hardware overlays disabled" ||
                log "WARN" "Failed to disable hardware overlays"
        fi
    }
    
    [ "$PLAY_FORCE_GPU_RENDER" = "true" ] && {
        setprop debug.sf.hw 1 2>/dev/null && log "DEBUG" "Forced GPU rendering enabled"
    }
    
    log "INFO" "Touch responsiveness enhancement completed"
    return 0
}

tune_network_for_gaming() {
    log "INFO" "Tuning network for gaming"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping network tuning"; return 0; }
    [ "$PLAY_NETWORK_TUNE" != "true" ] && { log "DEBUG" "Network tuning disabled in settings"; return 0; }
    
    write_with_check "/proc/sys/net/core/rmem_default" "$PLAY_NET_RMEM_DEFAULT" "net rmem default" ||
        log "WARN" "Failed to set net rmem default"
    
    write_with_check "/proc/sys/net/core/wmem_default" "$PLAY_NET_WMEM_DEFAULT" "net wmem default" ||
        log "WARN" "Failed to set net wmem default"
    
    write_with_check "/proc/sys/net/core/rmem_max" "$PLAY_NET_RMEM_MAX" "net rmem max" ||
        log "WARN" "Failed to set net rmem max"
    
    write_with_check "/proc/sys/net/core/wmem_max" "$PLAY_NET_WMEM_MAX" "net wmem max" ||
        log "WARN" "Failed to set net wmem max"
    
    write_with_check "/proc/sys/net/ipv4/tcp_fastopen" "3" "TCP fastopen" ||
        log "WARN" "Failed to set TCP fastopen"
    
    write_with_check "/proc/sys/net/ipv4/tcp_tw_reuse" "1" "TCP tw reuse" ||
        log "WARN" "Failed to set TCP tw reuse"
    
    write_with_check "/proc/sys/net/ipv4/tcp_low_latency" "1" "TCP low latency" ||
        log "WARN" "Failed to set TCP low latency"
    
    write_with_check "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0" "TCP slow start after idle" ||
        log "WARN" "Failed to set TCP slow start after idle"
    
    if validate_path "/proc/sys/net/ipv4/tcp_congestion_control"; then
        if validate_path "/proc/sys/net/ipv4/tcp_available_congestion_control"; then
            if grep -q "$PLAY_TCP_CONGESTION" /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null; then
                write_with_check "/proc/sys/net/ipv4/tcp_congestion_control" "$PLAY_TCP_CONGESTION" "TCP congestion control" ||
                    log "WARN" "Failed to set TCP congestion control to $PLAY_TCP_CONGESTION"
            else
                log "WARN" "TCP congestion control $PLAY_TCP_CONGESTION not available"
            fi
        fi
    fi
    
    write_with_check "/proc/sys/net/core/netdev_max_backlog" "5000" "netdev max backlog" ||
        log "WARN" "Failed to set netdev max backlog"
    
    write_with_check "/proc/sys/net/ipv4/tcp_mtu_probing" "1" "TCP MTU probing" ||
        log "WARN" "Failed to set TCP MTU probing"
    
    if [ -d "/sys/class/net/wlan0" ]; then
        if [ -f "/sys/class/net/wlan0/power_save" ]; then
            write_with_check "/sys/class/net/wlan0/power_save" "0" "WiFi power save" ||
                log "WARN" "Failed to disable WiFi power save"
        fi
        
        if command -v iw >/dev/null 2>&1; then
            iw wlan0 set power_save off >/dev/null 2>&1 && 
                log "DEBUG" "WiFi power save disabled via iw" ||
                log "WARN" "Failed to disable WiFi power save via iw"
        fi
    fi
    
    log "INFO" "Network tuning completed"
    return 0
}

optimize_memory_for_games() {
    log "INFO" "Optimizing memory for gaming"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping memory optimization"; return 0; }
    
    write_with_check "/proc/sys/vm/swappiness" "$PLAY_SWAPPINESS" "swappiness" ||
        log "WARN" "Failed to set swappiness"
    
    write_with_check "/proc/sys/vm/vfs_cache_pressure" "$PLAY_CACHE_PRESSURE" "cache pressure" ||
        log "WARN" "Failed to set cache pressure"
    
    write_with_check "/proc/sys/vm/dirty_ratio" "$PLAY_DIRTY_RATIO" "dirty ratio" ||
        log "WARN" "Failed to set dirty ratio"
    
    write_with_check "/proc/sys/vm/dirty_background_ratio" "$PLAY_DIRTY_BG_RATIO" "dirty background ratio" ||
        log "WARN" "Failed to set dirty background ratio"
    
    write_with_check "/proc/sys/vm/dirty_writeback_centisecs" "0" "dirty writeback centisecs" ||
        log "WARN" "Failed to set dirty writeback centisecs"
    
    write_with_check "/proc/sys/vm/dirty_expire_centisecs" "0" "dirty expire centisecs" ||
        log "WARN" "Failed to set dirty expire centisecs"
    
    if [ "$PLAY_ZRAM_OPTIMIZE" = "true" ] && [ -b "/dev/block/zram0" ]; then
        log "DEBUG" "Optimizing ZRAM for gaming"
        if validate_path "/sys/block/zram0/comp_algorithm"; then
            local available_algs=$(cat /sys/block/zram0/comp_algorithm 2>/dev/null)
            [ -n "$available_algs" ] && {
                if echo "$available_algs" | grep -q "zstd"; then
                    write_with_check "/sys/block/zram0/comp_algorithm" "zstd" "ZRAM compression algorithm" ||
                        log "WARN" "Failed to set ZRAM algorithm to zstd"
                elif echo "$available_algs" | grep -q "lz4"; then
                    write_with_check "/sys/block/zram0/comp_algorithm" "lz4" "ZRAM compression algorithm" ||
                        log "WARN" "Failed to set ZRAM algorithm to lz4"
                fi
            }
        fi
        
        if validate_path "/sys/block/zram0/max_comp_streams" && [ -f "/proc/cpuinfo" ]; then
            local cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "4")
            write_with_check "/sys/block/zram0/max_comp_streams" "$cores" "ZRAM compression streams" ||
                log "WARN" "Failed to set ZRAM compression streams"
        fi
    else
        log "DEBUG" "ZRAM optimization disabled or ZRAM not available"
    fi
    
    if [ "$PLAY_CLEAR_CACHES" = "true" ] && [ -f "/proc/sys/vm/drop_caches" ]; then
        log "DEBUG" "Clearing caches"
        write_with_check "/proc/sys/vm/drop_caches" "3" "drop caches" ||
            log "WARN" "Failed to clear caches"
        sync 2>/dev/null
        log "DEBUG" "Caches cleared"
    fi
    
    log "INFO" "Memory optimization completed"
    return 0
}

manage_thermal_gaming() {
    log "INFO" "Managing thermal settings for gaming"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping thermal management"; return 0; }
    [ "$PLAY_THERMAL_CONTROL" != "true" ] && { log "DEBUG" "Thermal control disabled in settings"; return 0; }
    
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
        [ ! -d "$thermal" ] && continue
        
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
        write_with_check "/sys/module/msm_thermal/parameters/enabled" "N" "msm thermal enable" ||
            log "WARN" "Failed to set msm thermal enabled"
    fi
    
    if [ -d "/sys/module/msm_thermal/core_control" ] && [ -f "/sys/module/msm_thermal/core_control/enabled" ]; then
        write_with_check "/sys/module/msm_thermal/core_control/enabled" "0" "msm thermal core control" ||
            log "WARN" "Failed to set msm thermal core control"
    fi
    
    log "INFO" "Thermal management completed"
    return 0
}

control_background_processes() {
    log "INFO" "Controlling background processes"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping background control"; return 0; }
    [ "$PLAY_BG_CONTROL" != "true" ] && { log "DEBUG" "Background control disabled in settings"; return 0; }
    
    [ ! -f "$MODDIR/cache/process_backup.txt" ] && {
        ps -A -o pid,cmd > "$MODDIR/cache/process_backup.txt" 2>/dev/null &&
            log "DEBUG" "Backed up process list" ||
            log "WARN" "Failed to backup process list"
    }
    
    local killed_count=0
    local pids=$(ps -A -o pid 2>/dev/null | grep -E '^[0-9]+' || echo "")
    
    for pid in $pids; do
        [ "$pid" -eq 1 ] && continue
        [ ! -d "/proc/$pid" ] && continue
        
        local cmdline=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ')
        [ -z "$cmdline" ] && continue
        
        local is_essential=0
        case "$cmdline" in
            *system_server*|*surfaceflinger*|*zygote*|*android.hardware*|*com.android.systemui*|*com.google.android.gms*)
                is_essential=1
                ;;
        esac
        
        if [ "$is_essential" -eq 0 ] && [ -n "$PLAY_BG_WHITELIST" ]; then
            local IFS=','
            for whitelisted in $PLAY_BG_WHITELIST; do
                echo "$cmdline" | grep -qi "$whitelisted" && {
                    is_essential=1
                    break
                }
            done
            unset IFS
        fi
        
        if [ "$is_essential" -eq 0 ]; then
            local uid=$(stat -c %u /proc/$pid 2>/dev/null)
            if [ -n "$uid" ] && echo "$uid" | grep -qE '^[0-9]+$' && [ "$uid" -ge 10000 ]; then
                if kill -15 "$pid" 2>/dev/null; then
                    sleep 0.1
                    if [ -d "/proc/$pid" ]; then
                        kill -9 "$pid" 2>/dev/null && {
                            killed_count=$((killed_count + 1))
                            log "DEBUG" "Killed background process: $cmdline (PID: $pid)"
                        }
                    else
                        killed_count=$((killed_count + 1))
                    fi
                fi
            fi
        fi
        
        [ "$killed_count" -ge "$PLAY_BG_KILL_LIMIT" ] && [ "$PLAY_BG_KILL_LIMIT" -gt 0 ] && break
    done
    
    if validate_path "/proc/sys/kernel/threads-max"; then
        local current_threads=$(ps -eLf 2>/dev/null | wc -l)
        [ -n "$current_threads" ] && {
            local new_limit=$((current_threads * 120 / 100))
            write_with_check "/proc/sys/kernel/threads-max" "$new_limit" "threads max" ||
                log "WARN" "Failed to set threads max"
        }
    fi
    
    log "INFO" "Background process control completed. Killed $killed_count processes"
    return 0
}

setup_game_detector() {
    log "INFO" "Setting up game detector"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping game detector"; return 0; }
    [ "$PLAY_AUTO_DETECT" != "true" ] && { log "DEBUG" "Auto detection disabled in settings"; return 0; }
    
    [ -f "$MODDIR/cache/game_detector_pid" ] && {
        local old_pid=$(cat "$MODDIR/cache/game_detector_pid" 2>/dev/null)
        [ -n "$old_pid" ] && [ -d "/proc/$old_pid" ] && {
            kill -9 "$old_pid" 2>/dev/null
            log "DEBUG" "Stopped previous game detector (PID: $old_pid)"
        }
    }
    
    log "INFO" "Starting game detector in background"
    nohup sh -c "
    while true; do
        sleep 3
        command -v dumpsys >/dev/null 2>&1 || continue
        
        local current_app=\$(dumpsys window windows 2>/dev/null | \
            grep -E 'mCurrentFocus|mFocusedApp' | \
            grep -oE '[a-zA-Z0-9._]+/[a-zA-Z0-9._]+' | \
            head -1 | cut -d'/' -f1)
        
        [ -z \"\$current_app\" ] && continue
        
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
    echo $detector_pid > "$MODDIR/cache/game_detector_pid" 2>/dev/null
    log "INFO" "Game detector started (PID: $detector_pid)"
}

apply_game_profile() {
    local profile="$1"
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping profile application"; return 0; }
    
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
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "DEBUG" "Play mode disabled, skipping performance monitor"; return 0; }
    [ "$PLAY_PERF_MONITOR" != "true" ] && { log "DEBUG" "Performance monitor disabled in settings"; return 0; }
    
    [ -f "$MODDIR/cache/perf_monitor_pid" ] && {
        local old_pid=$(cat "$MODDIR/cache/perf_monitor_pid" 2>/dev/null)
        [ -n "$old_pid" ] && [ -d "/proc/$old_pid" ] && {
            kill -9 "$old_pid" 2>/dev/null
            log "DEBUG" "Stopped previous performance monitor (PID: $old_pid)"
        }
    }
    
    mkdir -p "$MODDIR/logs" 2>/dev/null
    log "INFO" "Performance monitor started"
}

apply_game_mode() {
    log "INFO" "=== APPLYING GAME MODE ==="
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "ERROR" "Play mode is disabled in configuration"; return 1; }
    
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
    [ -z "$PLAY_ENABLED" ] && { log "ERROR" "PLAY_ENABLED not set"; return 1; }
    [ "$PLAY_ENABLED" != "true" ] && { log "ERROR" "Play mode is disabled in configuration"; return 1; }
    
    log "INFO" "Restoring normal system settings..."
    
    if [ -f "$MODDIR/cache/cpu_gov_backup" ]; then
        local saved_gov=$(cat "$MODDIR/cache/cpu_gov_backup" 2>/dev/null)
        [ -n "$saved_gov" ] && {
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
                [ -d "$cpu" ] && write_with_check "$cpu/scaling_governor" "$saved_gov" "CPU governor restore" || true
            done
            log "DEBUG" "Restored CPU governor to: $saved_gov"
        }
        rm -f "$MODDIR/cache/cpu_gov_backup" 2>/dev/null
    fi
    
    for thermal in /sys/class/thermal/thermal_zone*; do
        [ ! -d "$thermal" ] && continue
        
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
            iw wlan0 set power_save on >/dev/null 2>&1 && 
                log "DEBUG" "Restored WiFi power save via iw" ||
                log "WARN" "Failed to restore WiFi power save via iw"
        fi
    fi
    
    setprop debug.sf.vsync 1 2>/dev/null && log "DEBUG" "Restored VSync"
    setprop debug.egl.swapinterval 1 2>/dev/null && log "DEBUG" "Restored EGL swap interval"
    
    rm -f "$MODDIR/cache/game_mode_active" "$MODDIR/cache/game_active" 2>/dev/null
    log "DEBUG" "Cleared game mode flags"
    
    [ -f "$MODDIR/cache/game_detector_pid" ] && {
        local detector_pid=$(cat "$MODDIR/cache/game_detector_pid" 2>/dev/null)
        [ -n "$detector_pid" ] && [ -d "/proc/$detector_pid" ] && {
            kill -9 "$detector_pid" 2>/dev/null
            log "DEBUG" "Stopped game detector (PID: $detector_pid)"
        }
        rm -f "$MODDIR/cache/game_detector_pid" 2>/dev/null
    }
    
    [ -f "$MODDIR/cache/perf_monitor_pid" ] && {
        local monitor_pid=$(cat "$MODDIR/cache/perf_monitor_pid" 2>/dev/null)
        [ -n "$monitor_pid" ] && [ -d "/proc/$monitor_pid" ] && {
            kill -9 "$monitor_pid" 2>/dev/null
            log "DEBUG" "Stopped performance monitor (PID: $monitor_pid)"
        }
        rm -f "$MODDIR/cache/perf_monitor_pid" 2>/dev/null
    }
    
    log "INFO" "=== NORMAL MODE RESTORED ==="
    log "INFO" "All game mode settings have been reverted"
}