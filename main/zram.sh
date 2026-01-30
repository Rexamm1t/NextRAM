#!/system/bin/sh
MODDIR=${0%/*}/..

ZRAM_ALGORITHM_CACHE=""
ZRAM_STREAMS_CACHE=""
ZRAM_OPTIMAL_RATIO=2.5

zram_init() {
    [ -b "/dev/block/zram0" ] && return 0
    
    [ -d "/sys/block/zram0" ] || {
        insmod /system/lib/modules/zram.ko 2>/dev/null
        insmod /vendor/lib/modules/zram.ko 2>/dev/null
        sleep 2
    }
    
    [ -d "/sys/class/zram-control" ] && [ ! -b "/dev/block/zram0" ] && {
        cat /sys/class/zram-control/hot_add 2>/dev/null >/dev/null
        sleep 1
    }
    
    [ -b "/dev/block/zram0" ] && return 0
    return 1
}

test_zram_algorithms() {
    [ ! -b "/dev/block/zram0" ] && return 1
    
    log "INFO" "Testing ZRAM compression algorithms"
    local available_algs=$(cat /sys/block/zram0/comp_algorithm 2>/dev/null | sed 's/\[//g;s/\]//g' | tr ' ' '\n' | grep -v none)
    local test_algorithms="lz4 zstd lzo lzo-rle deflate lz4hc 842"
    local best_alg="lz4"
    local best_ml_score=0
    local best_ratio=0
    local test_data_dir="$MODDIR/cache/test_data"
    
    mkdir -p "$test_data_dir" 2>/dev/null
    
    dd if=/dev/urandom of="$test_data_dir/random.bin" bs=1M count=5 2>/dev/null
    dd if=/dev/zero of="$test_data_dir/zeros.bin" bs=1M count=5 2>/dev/null
    logcat -d > "$test_data_dir/logs.txt" 2>/dev/null
    
    if [ -f "/system/framework/framework-res.apk" ]; then
        cp /system/framework/framework-res.apk "$test_data_dir/app.apk" 2>/dev/null
    fi
    
    for alg in $test_algorithms; do
        echo "$available_algs" | grep -qw "$alg" || continue
        local total_score=0
        local test_count=0
        local avg_ratio=0
        
        for test_file in "$test_data_dir"/*; do
            [ -f "$test_file" ] || continue
            
            echo 1 > /sys/block/zram0/reset 2>/dev/null
            echo "$alg" > /sys/block/zram0/comp_algorithm 2>/dev/null
            echo "50M" > /sys/block/zram0/disksize 2>/dev/null
            
            mkswap "/dev/block/zram0" >/dev/null 2>&1 && swapon "/dev/block/zram0" >/dev/null 2>&1 && {
                local file_size=$(stat -c %s "$test_file" 2>/dev/null)
                file_size=${file_size:-0}
                local start_time=$(date +%s%N)
                dd if="$test_file" of=/dev/block/zram0 bs=1M 2>/dev/null
                local end_time=$(date +%s%N)
                local duration=$((($end_time - $start_time)/1000000))
                duration=${duration:-1}
                local compr_size=$(awk '{print $2}' /sys/block/zram0/mm_stat 2>/dev/null)
                compr_size=${compr_size:-1}
                local ratio=0
                if [ "$compr_size" -gt 0 ]; then
                    ratio=$(awk -v o="$file_size" -v c="$compr_size" 'BEGIN {printf "%.2f", o/c}')
                fi
                local speed_score=$((10000/(duration+1)))
                local ratio_score=$(awk -v r="$ratio" 'BEGIN {printf "%.0f", r * 1000}')
                local test_score=$((speed_score * 3 + ratio_score * 4))
                
                total_score=$((total_score + test_score))
                avg_ratio=$(awk -v ar="$avg_ratio" -v r="$ratio" -v tc="$test_count" 'BEGIN {printf "%.2f", (ar * tc + r) / (tc + 1)}')
                test_count=$((test_count + 1))
                swapoff "/dev/block/zram0" >/dev/null 2>&1
            }
            echo 1 > /sys/block/zram0/reset 2>/dev/null
        done
        
        [ "$test_count" -gt 0 ] && {
            local ml_score=$((total_score / test_count))
            [ "$ml_score" -gt "$best_ml_score" ] && {
                best_ml_score=$ml_score
                best_alg=$alg
                best_ratio=$avg_ratio
            }
        }
    done
    
    rm -rf "$test_data_dir" 2>/dev/null
    log "INFO" "Optimal algorithm: $best_alg (Ratio: ${best_ratio}:1)"
    ZRAM_ALGORITHM="$best_alg"
    ZRAM_ALGORITHM_CACHE="$best_alg"
    echo "$best_alg:$best_ratio" > "$MODDIR/cache/algorithm_analytics.txt" 2>/dev/null
    return 0
}

optimize_algorithm_params() {
    local alg="$1"
    [ ! -f "/proc/sys/vm/page-cluster" ] && return
    
    case "$alg" in
        "zstd") echo 3 > /proc/sys/vm/page-cluster 2>/dev/null ;;
        "lz4"|"lz4hc") echo 2 > /proc/sys/vm/page-cluster 2>/dev/null ;;
        "deflate") echo 1 > /proc/sys/vm/page-cluster 2>/dev/null ;;
        *) echo 0 > /proc/sys/vm/page-cluster 2>/dev/null ;;
    esac
}

get_optimal_streams() {
    local algorithm="$1"
    local cpu_cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null)
    cpu_cores=${cpu_cores:-4}
    
    [ -d "/sys/devices/system/cpu/cpu0/cpufreq" ] && {
        local big_cores=$(cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq 2>/dev/null | awk '$1 > 1500000' | wc -l)
        [ "$big_cores" -gt 0 ] && cpu_cores=$big_cores
    }
    
    local calculated_streams=$cpu_cores
    case "$algorithm" in
        "zstd") calculated_streams=$cpu_cores ;;
        "lz4"|"lz4hc") calculated_streams=$((cpu_cores > 4 ? cpu_cores - 1 : cpu_cores)) ;;
        *) calculated_streams=1 ;;
    esac
    
    [ -n "$MAX_COMP_STREAMS" ] && [ "$MAX_COMP_STREAMS" -gt 0 ] && [ "$calculated_streams" -gt "$MAX_COMP_STREAMS" ] && {
        log "INFO" "Limiting streams from $calculated_streams to $MAX_COMP_STREAMS"
        calculated_streams="$MAX_COMP_STREAMS"
    }
    
    case "$algorithm" in
        "lzo"|"lzo-rle") calculated_streams=$((calculated_streams > 2 ? 2 : calculated_streams)) ;;
    esac
    
    echo $calculated_streams
}

calculate_optimal_zram_size() {
    local total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo 2>/dev/null)
    local available_ram=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)
    
    total_ram=${total_ram:-0}
    available_ram=${available_ram:-0}
    
    local swap_usage=0
    local swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo 2>/dev/null)
    local swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo 2>/dev/null)
    swap_total=${swap_total:-0}
    swap_free=${swap_free:-0}
    
    if [ "$swap_total" -gt 0 ]; then
        swap_usage=$(( (swap_total - swap_free) * 100 / swap_total ))
    fi
    
    local base_size=$(awk -v ram="$total_ram" -v ratio="${ZRAM_RATIO:-1.5}" 'BEGIN {printf "%.0f", ram * ratio}')
    
    [ "$available_ram" -lt $((total_ram / 4)) ] && base_size=$((base_size * 120 / 100))
    [ "$swap_usage" -gt 70 ] && base_size=$((base_size * 130 / 100))
    
    local max_zram_kb=$((total_ram * 4))
    local min_zram_kb=524288
    [ "$base_size" -gt "$max_zram_kb" ] && base_size=$max_zram_kb
    [ "$base_size" -lt "$min_zram_kb" ] && base_size=$min_zram_kb
    
    log "DEBUG" "ZRAM calculation: RAM=${total_ram}KB, Ratio=${ZRAM_RATIO:-1.5}, Base=${base_size}KB"
    echo $base_size
}

monitor_zram_efficiency() {
    [ ! -b "/dev/block/zram0" ] && return 1
    local stats=$(cat /sys/block/zram0/mm_stat 2>/dev/null)
    [ -z "$stats" ] && return 1
    
    local compr_data_size=$(echo "$stats" | awk '{print $2}')
    local orig_data_size=$(echo "$stats" | awk '{print $3}')
    
    compr_data_size=${compr_data_size:-0}
    orig_data_size=${orig_data_size:-0}
    
    if [ "$orig_data_size" -gt 0 ]; then
        local ratio=0
        if [ "$compr_data_size" -gt 0 ]; then
            ratio=$(awk -v compr="$compr_data_size" -v orig="$orig_data_size" 'BEGIN {printf "%.2f", orig/compr}')
        fi
        echo "$(date +%s),$ratio,$compr_data_size,$orig_data_size" >> "$MODDIR/cache/zram_history.txt" 2>/dev/null
        
        [ ! -f "$MODDIR/cache/ratio_checked.flag" ] && {
            [ "$(echo "$ratio < $ZRAM_OPTIMAL_RATIO" | bc -l 2>/dev/null)" = "1" ] && log "WARN" "Suboptimal compression ratio: ${ratio}:1"
            touch "$MODDIR/cache/ratio_checked.flag" 2>/dev/null
        }
        
        [ "$(echo "$ratio < 1.5" | bc -l 2>/dev/null)" = "1" ] && touch "$MODDIR/cache/optimize_algorithm" 2>/dev/null
    fi
}

verify_stream_limits() {
    local requested_streams="$1"
    local actual_streams=$(cat /sys/block/zram0/max_comp_streams 2>/dev/null || echo "$requested_streams")
    
    [ "$actual_streams" != "$requested_streams" ] && {
        log "WARN" "Stream mismatch: requested $requested_streams, got $actual_streams"
        echo "$requested_streams" > /sys/block/zram0/max_comp_streams 2>/dev/null
        sleep 1
        
        local verified_streams=$(cat /sys/block/zram0/max_comp_streams 2>/dev/null)
        [ "$verified_streams" = "$requested_streams" ] && log "INFO" "Enforced stream limit: $requested_streams" || log "WARN" "Using: $verified_streams"
    }
}

monitor_zram_usage() {
    [ ! -b "/dev/block/zram0" ] && return 1
    
    local current_streams=$(cat /sys/block/zram0/max_comp_streams 2>/dev/null || echo "N/A")
    local compr_data_size=$(awk '{print $2}' /sys/block/zram0/mm_stat 2>/dev/null || echo "0")
    local orig_data_size=$(awk '{print $3}' /sys/block/zram0/mm_stat 2>/dev/null || echo "0")
    
    log "DEBUG" "ZRAM streams: $current_streams, compressed: ${compr_data_size}KB, original: ${orig_data_size}KB"
    
    [ "$current_streams" != "N/A" ] && [ -n "$MAX_COMP_STREAMS" ] && [ "$MAX_COMP_STREAMS" -gt 0 ] && [ "$current_streams" -gt "$MAX_COMP_STREAMS" ] && log "WARN" "ZRAM using $current_streams streams (limit: $MAX_COMP_STREAMS)"
}

setup_zram() {
    zram_init || {
        log "INFO" "ZRAM device not available"
        ZRAM_ENABLED=false
        return 0
    }
    
    [ "$ZRAM_AUTO_TUNE" = "true" ] || [ -f "$MODDIR/cache/retest_algorithms" ] || [ -f "$MODDIR/cache/optimize_algorithm" ] && {
        local system_uptime=$(awk '{print $1}' /proc/uptime 2>/dev/null | cut -d. -f1)
        local load_avg=$(awk '{print $1}' /proc/loadavg 2>/dev/null)
        
        system_uptime=${system_uptime:-0}
        load_avg=${load_avg:-0}
        
        if [ "$system_uptime" -gt 120 ] && [ "$(echo "$load_avg < 3.0" | bc -l 2>/dev/null)" = "1" ]; then
            test_zram_algorithms
        else
            log "INFO" "Delaying algorithm test (uptime: ${system_uptime}s, load: ${load_avg})"
            ZRAM_ALGORITHM_CACHE="lz4"
        fi
        rm -f "$MODDIR/cache/retest_algorithms" "$MODDIR/cache/optimize_algorithm" 2>/dev/null
    }
    
    local algorithm="${ZRAM_ALGORITHM_CACHE:-$ZRAM_ALGORITHM}"
    log "INFO" "Configuring ZRAM with algorithm: $algorithm"
    
    local available_algs=$(cat /sys/block/zram0/comp_algorithm 2>/dev/null | sed 's/\[//g;s/\]//g')
    echo "$available_algs" | grep -qw "$algorithm" || {
        algorithm=$(echo "$available_algs" | awk '{print $1}')
        ZRAM_ALGORITHM="$algorithm"
        log "WARN" "Algorithm not available, using: $algorithm"
    }
    
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    sleep 1
    echo "$algorithm" > /sys/block/zram0/comp_algorithm 2>/dev/null
    optimize_algorithm_params "$algorithm"
    
    local streams=$(get_optimal_streams "$algorithm")
    echo "$streams" > /sys/block/zram0/max_comp_streams 2>/dev/null
    verify_stream_limits "$streams"
    ZRAM_STREAMS_CACHE="$streams"
    
    local zram_size_kb=$(calculate_optimal_zram_size)
    echo "${zram_size_kb}K" > /sys/block/zram0/disksize 2>/dev/null
    sleep 1
    
    local verify_size=$(cat /sys/block/zram0/disksize 2>/dev/null)
    log "DEBUG" "ZRAM size: requested ${zram_size_kb}K, got ${verify_size}"
    
    [ "$verify_size" != "$zram_size_kb" ] && {
        log "WARN" "ZRAM size mismatch, retrying..."
        echo 1 > /sys/block/zram0/reset 2>/dev/null
        sleep 1
        echo "${zram_size_kb}K" > /sys/block/zram0/disksize 2>/dev/null
    }
    
    [ -f "/sys/block/zram0/memory_limit" ] && [ -n "$ZRAM_MEMORY_LIMIT" ] && echo "$ZRAM_MEMORY_LIMIT" > /sys/block/zram0/memory_limit 2>/dev/null
    
    mkswap "/dev/block/zram0" >/dev/null 2>&1 && swapon "/dev/block/zram0" -p "${ZRAM_PRIORITY:-100}" 2>/dev/null && {
        log "INFO" "ZRAM activated: ${zram_size_kb}KB with $algorithm, priority: ${ZRAM_PRIORITY:-100}"
        rm -f "$MODDIR/cache/ratio_checked.flag" 2>/dev/null
        monitor_zram_efficiency
        return 0
    }
    
    log "INFO" "ZRAM setup completed"
    return 0
}

zram_cleanup() {
    log "INFO" "Performing ZRAM cleanup"
    swapoff "/dev/block/zram0" 2>/dev/null
    [ -f "/sys/block/zram0/reset" ] && echo 1 > "/sys/block/zram0/reset" 2>/dev/null
    rm -f "$MODDIR/cache/retest_algorithms" "$MODDIR/cache/optimize_algorithm" "$MODDIR/cache/ratio_checked.flag" 2>/dev/null
}

export -f zram_init test_zram_algorithms setup_zram zram_cleanup verify_stream_limits monitor_zram_usage