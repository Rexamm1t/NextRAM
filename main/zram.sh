#!/system/bin/sh
MODDIR=${0%/*}/..

test_zram_algorithms() {
    [ ! -b "/dev/block/zram0" ] && return 1

    log "INFO" "Testing ZRAM compression algorithms"
    local available_algs=$(cat /sys/block/zram0/comp_algorithm | sed 's/\[//g;s/\]//g' | tr ' ' '\n')
    local test_algorithms="lz4 zstd lzo lzo-rle"
    local best_alg="lz4"
    local best_score=0

    for alg in $test_algorithms; do
        if echo "$available_algs" | grep -qw "$alg"; then
            echo "$alg" > /sys/block/zram0/comp_algorithm
            echo "1M" > /sys/block/zram0/disksize

            if mkswap "/dev/block/zram0" >/dev/null 2>&1 && swapon "/dev/block/zram0" >/dev/null 2>&1; then
                local start_time=$(date +%s%N)
                dd if=/dev/zero of=/dev/block/zram0 bs=1M count=10 >/dev/null 2>&1
                local end_time=$(date +%s%N)
                local duration=$((($end_time - $start_time)/1000000))

                swapoff "/dev/block/zram0" >/dev/null 2>&1
                echo 1 > /sys/block/zram0/reset

                local score=$((10000/($duration+1)))
                log "DEBUG" "Algorithm $alg score: $score (time: ${duration}ms)"

                if [ "$score" -gt "$best_score" ]; then
                    best_score=$score
                    best_alg=$alg
                fi
            fi
        fi
    done

    log "INFO" "Best performing algorithm: $best_alg (score: $best_score)"
    ZRAM_ALGORITHM=$best_alg
}

monitor_zram_efficiency() {
    if [ -f "/sys/block/zram0/mm_stat" ]; then
        local stats=$(cat /sys/block/zram0/mm_stat)
        local compr_data_size=$(echo "$stats" | awk '{print $2}')
        local orig_data_size=$(echo "$stats" | awk '{print $3}')

        if [ "$orig_data_size" -gt 0 ]; then
            local ratio=$(awk -v compr="$compr_data_size" -v orig="$orig_data_size" 'BEGIN {printf "%.2f", orig/compr}')
            log "INFO" "ZRAM compression ratio: $ratio:1"

            if [ $(echo "$ratio < 1.5" | bc -l) -eq 1 ]; then
                log "WARN" "Low compression ratio, consider changing algorithm"
            fi
        fi
    fi
}

setup_zram() {
    [ ! -b "/dev/block/zram0" ] && {
        log "WARN" "ZRAM device not found, skipping ZRAM setup"
        return 1
    }

    if [ "$ZRAM_AUTO_TUNE" = "true" ]; then
        test_zram_algorithms
    fi

    log "INFO" "Configuring ZRAM with algorithm: $ZRAM_ALGORITHM"

    local available_algs=$(cat /sys/block/zram0/comp_algorithm | sed 's/\[//g;s/\]//g')
    if ! echo "$available_algs" | grep -qw "$ZRAM_ALGORITHM"; then
        ZRAM_ALGORITHM=$(echo "$available_algs" | awk '{print $1}')
        log "WARN" "Requested algorithm not available, using: $ZRAM_ALGORITHM"
    fi

    echo "$ZRAM_ALGORITHM" > /sys/block/zram0/comp_algorithm

    case "$ZRAM_ALGORITHM" in
        "zstd") echo 3 > /proc/sys/vm/page-cluster ;;
        "lz4"|"lz4hc") echo 2 > /proc/sys/vm/page-cluster ;;
        *) echo 0 > /proc/sys/vm/page-cluster ;;
    esac

    local cpu_cores=$(grep -c ^processor /proc/cpuinfo)
    if echo "$ZRAM_ALGORITHM" | grep -qE "^(zstd|lz4|lz4hc)$"; then
        echo $cpu_cores > /sys/block/zram0/max_comp_streams
    else
        echo 1 > /sys/block/zram0/max_comp_streams
    fi

    local total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    local zram_size_kb=$(awk -v ram="$total_ram" -v ratio="$ZRAM_RATIO" 'BEGIN {printf "%.0f", ram * ratio}')
    local max_zram_kb=4194304

    if [ "$zram_size_kb" -gt "$max_zram_kb" ]; then
        zram_size_kb=$max_zram_kb
    fi

    echo "${zram_size_kb}K" > /sys/block/zram0/disksize

    if [ -f "/sys/block/zram0/memory_limit" ]; then
        echo "4G" > /sys/block/zram0/memory_limit
    fi

    if mkswap "/dev/block/zram0" >/dev/null 2>&1 && swapon "/dev/block/zram0" -p 100; then
        log "INFO" "ZRAM activated successfully"
        monitor_zram_efficiency
        return 0
    else
        log "ERROR" "Failed to activate ZRAM"
        return 1
    fi
}