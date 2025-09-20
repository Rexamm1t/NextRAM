#!/system/bin/sh
MODDIR=${0%/*}/..

ZRAM_ALGORITHM_CACHE=""
ZRAM_STREAMS_CACHE=""
ZRAM_OPTIMAL_RATIO=2.5

zram_init() {
    [ ! -d "/sys/block/zram0" ] && {
        insmod /system/lib/modules/zram.ko 2>/dev/null
        insmod /vendor/lib/modules/zram.ko 2>/dev/null
        sleep 1
    }
    
    if [ -d "/sys/class/zram-control" ] && [ ! -b "/dev/block/zram0" ]; then
        local zram_id=$(cat /sys/class/zram-control/hot_add)
        [ -z "$zram_id" ] && return 1
    fi
    
    return 0
}

test_zram_algorithms() {
    [ ! -b "/dev/block/zram0" ] && return 1

    log "INFO" "Testing ZRAM compression algorithms"

    local available_algs=$(cat /sys/block/zram0/comp_algorithm | sed 's/\[//g;s/\]//g' | tr ' ' '\n' | grep -v none)
    local test_algorithms="lz4 zstd lzo lzo-rle deflate lz4hc 842"
    local best_alg="lz4"
    local best_ml_score=0
    local best_ratio=0

    local test_data_dir="$MODDIR/cache/test_data"
    mkdir -p "$test_data_dir"
    
    dd if=/dev/urandom of="$test_data_dir/random.bin" bs=1M count=5 2>/dev/null
    dd if=/dev/zero of="$test_data_dir/zeros.bin" bs=1M count=5 2>/dev/null
    logcat -d > "$test_data_dir/logs.txt" 2>/dev/null
    cp /system/framework/framework-res.apk "$test_data_dir/app.apk" 2>/dev/null || true

    for alg in $test_algorithms; do
        if echo "$available_algs" | grep -qw "$alg"; then
            
            local total_score=0
            local test_count=0
            local avg_ratio=0

            for test_file in "$test_data_dir"/*; do
                [ ! -f "$test_file" ] && continue
                
                echo 1 > /sys/block/zram0/reset 2>/dev/null
                echo "$alg" > /sys/block/zram0/comp_algorithm
                echo "50M" > /sys/block/zram0/disksize

                if mkswap "/dev/block/zram0" >/dev/null 2>&1 && swapon "/dev/block/zram0" >/dev/null 2>&1; then
                    local file_size=$(stat -c %s "$test_file")
                    local start_time=$(date +%s%N)
                    
                    dd if="$test_file" of=/dev/block/zram0 bs=1M 2>/dev/null
                    
                    local end_time=$(date +%s%N)
                    local duration=$((($end_time - $start_time)/1000000))
                    
                    local compr_size=$(awk '{print $2}' /sys/block/zram0/mm_stat 2>/dev/null)
                    local ratio=$(awk -v o="$file_size" -v c="$compr_size" 'BEGIN {printf "%.2f", o/c}')
                    
                    local speed_score=$((10000/(duration+1)))
                    local ratio_score=$(awk -v r="$ratio" 'BEGIN {printf "%.0f", r * 1000}')
                    
                    local test_score=$((speed_score * 3 + ratio_score * 4))
                    total_score=$((total_score + test_score))
                    
                    avg_ratio=$(awk -v ar="$avg_ratio" -v r="$ratio" -v tc="$test_count" 'BEGIN {printf "%.2f", (ar * tc + r) / (tc + 1)}')
                    
                    test_count=$((test_count + 1))
                    
                    swapoff "/dev/block/zram0" >/dev/null 2>&1
                fi
                echo 1 > /sys/block/zram0/reset 2>/dev/null
            done

            if [ "$test_count" -gt 0 ]; then
                local ml_score=$((total_score / test_count))
                
                if [ "$ml_score" -gt "$best_ml_score" ]; then
                    best_ml_score=$ml_score
                    best_alg=$alg
                    best_ratio=$avg_ratio
                fi
            fi
        fi
    done

    rm -rf "$test_data_dir"
    
    log "INFO" "Optimal algorithm: $best_alg (Ratio: ${best_ratio}:1)"
    ZRAM_ALGORITHM="$best_alg"
    ZRAM_ALGORITHM_CACHE="$best_alg"
    
    echo "$best_alg:$best_ratio" > "$MODDIR/cache/algorithm_analytics.txt"
    
    return 0
}

optimize_algorithm_params() {
    local alg="$1"
    
    case "$alg" in
        "zstd")
            echo 3 > /proc/sys/vm/page-cluster
            [ -f "/sys/block/zram0/zstd_comp_level" ] && echo 1 > /sys/block/zram0/zstd_comp_level
            ;;
        "lz4"|"lz4hc")
            echo 2 > /proc/sys/vm/page-cluster
            [ -f "/sys/block/zram0/lz4hc_comp_level" ] && echo 9 > /sys/block/zram0/lz4hc_comp_level
            ;;
        "deflate")
            echo 1 > /proc/sys/vm/page-cluster
            [ -f "/sys/block/zram0/deflate_comp_level" ] && echo 6 > /sys/block/zram0/deflate_comp_level
            ;;
        *)
            echo 0 > /proc/sys/vm/page-cluster
            ;;
    esac
    
    local cpu_max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo 1000000)
    if [ "$cpu_max_freq" -gt 2000000 ]; then
        case "$alg" in
            "zstd") [ -f "/sys/block/zram0/zstd_comp_level" ] && echo 3 > /sys/block/zram0/zstd_comp_level ;;
            "lz4hc") [ -f "/sys/block/zram0/lz4hc_comp_level" ] && echo 12 > /sys/block/zram0/lz4hc_comp_level ;;
        esac
    fi
}

get_optimal_streams() {
    local alg="$1"
    local cpu_cores=$(grep -c ^processor /proc/cpuinfo)
    
    if [ -d "/sys/devices/system/cpu/cpu0/cpufreq" ]; then
        local big_cores=$(cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | awk '$1 > 1500000' | wc -l)
        [ "$big_cores" -gt 0 ] && cpu_cores=$big_cores
    fi
    
    case "$alg" in
        "zstd")
            echo $cpu_cores
            ;;
        "lz4"|"lz4hc")
            echo $((cpu_cores > 4 ? cpu_cores - 1 : cpu_cores))
            ;;
        *)
            echo 1
            ;;
    esac
}

calculate_optimal_zram_size() {
    local total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    local available_ram=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
    local swap_usage=$(awk '/SwapTotal/ {total=$2} /SwapFree/ {free=$2} END {printf "%.1f", (total-free)/total*100}' /proc/meminfo 2>/dev/null || echo 0)
    
    local base_size=$(awk -v ram="$total_ram" -v ratio="$ZRAM_RATIO" 'BEGIN {printf "%.0f", ram * ratio}')
    
    if [ "$available_ram" -lt $((total_ram / 4)) ]; then
        base_size=$((base_size * 120 / 100))
    fi
    
    if [ $(echo "$swap_usage > 70" | bc -l) -eq 1 ]; then
        base_size=$((base_size * 130 / 100))
    fi
    
    local max_zram_kb=4194304
    local min_zram_kb=524288
    
    [ "$base_size" -gt "$max_zram_kb" ] && base_size=$max_zram_kb
    [ "$base_size" -lt "$min_zram_kb" ] && base_size=$min_zram_kb
    
    echo $base_size
}

monitor_zram_efficiency() {
    [ ! -b "/dev/block/zram0" ] && return 1
    
    local stats=$(cat /sys/block/zram0/mm_stat 2>/dev/null)
    [ -z "$stats" ] && return 1
    
    local compr_data_size=$(echo "$stats" | awk '{print $2}')
    local orig_data_size=$(echo "$stats" | awk '{print $3}')

    if [ "$orig_data_size" -gt 0 ]; then
        local ratio=$(awk -v compr="$compr_data_size" -v orig="$orig_data_size" 'BEGIN {printf "%.2f", orig/compr}')
        
        echo "$(date +%s),$ratio,$compr_data_size,$orig_data_size" >> "$MODDIR/cache/zram_history.txt"
        
        if [ ! -f "$MODDIR/cache/ratio_checked.flag" ]; then
            if [ $(echo "$ratio < $ZRAM_OPTIMAL_RATIO" | bc -l) -eq 1 ]; then
                log "WARN" "Suboptimal compression ratio detected: ${ratio}:1"
            fi
            touch "$MODDIR/cache/ratio_checked.flag"
        fi
        
        if [ $(echo "$ratio < 1.5" | bc -l) -eq 1 ]; then
            touch "$MODDIR/cache/optimize_algorithm"
        fi
    fi
}

setup_zram() {
    zram_init || {
        ZRAM_ENABLED=false
        return 1
    }

    if [ "$ZRAM_AUTO_TUNE" = "true" ] || [ -f "$MODDIR/cache/retest_algorithms" ]; then
        test_zram_algorithms
        rm -f "$MODDIR/cache/retest_algorithms" 2>/dev/null
    fi

    local algorithm="${ZRAM_ALGORITHM_CACHE:-$ZRAM_ALGORITHM}"
    log "INFO" "Configuring ZRAM with algorithm: $algorithm"
    
    local available_algs=$(cat /sys/block/zram0/comp_algorithm | sed 's/\[//g;s/\]//g')
    if ! echo "$available_algs" | grep -qw "$algorithm"; then
        algorithm=$(echo "$available_algs" | awk '{print $1}')
        ZRAM_ALGORITHM="$algorithm"
        log "WARN" "Algorithm not available, using: $algorithm"
    fi

    echo 1 > /sys/block/zram0/reset 2>/dev/null
    echo "$algorithm" > /sys/block/zram0/comp_algorithm
    
    optimize_algorithm_params "$algorithm"
    
    local streams=$(get_optimal_streams "$algorithm")
    echo "$streams" > /sys/block/zram0/max_comp_streams

    local zram_size_kb=$(calculate_optimal_zram_size)
    echo "${zram_size_kb}K" > /sys/block/zram0/disksize
    log "INFO" "Set ZRAM size: $(($zram_size_kb / 1024))MB"

    if [ -f "/sys/block/zram0/memory_limit" ]; then
        echo "4G" > /sys/block/zram0/memory_limit
    fi

    if mkswap "/dev/block/zram0" >/dev/null 2>&1; then
        if swapon "/dev/block/zram0" -p 100; then
            log "INFO" "ZRAM activated successfully"
            
            rm -f "$MODDIR/cache/ratio_checked.flag"
            monitor_zram_efficiency
            
            return 0
        fi
    fi

    log "ERROR" "Failed to initialize ZRAM"
    return 1
}

zram_cleanup() {
    log "INFO" "Performing ZRAM cleanup"
    swapoff "/dev/block/zram0" 2>/dev/null
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    
    rm -f "$MODDIR/cache/retest_algorithms" "$MODDIR/cache/optimize_algorithm" "$MODDIR/cache/ratio_checked.flag"
}