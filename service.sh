#!/system/bin/sh

SWAP_ENABLED=false
SWAP_SIZE_GB=1.0
OVERHEAD_GB=0.3
ZRAM_ENABLED=true
ZRAM_RATIO=0.70
ZRAM_ALGORITHM=zstd
MAX_COMP_STREAMS=8
SWAPPINESS=90
CACHE_PRESSURE=20
DIRTY_RATIO=20
DIRTY_BACKGROUND_RATIO=5
EXTRA_TUNING=true
DYNAMIC_SWAPPINESS=true
PERFORMANCE_MODE=false
ZRAM_AUTO_TUNE=false
LOG_LEVEL="INFO"

MODDIR=${0%/*}
TOYBOX="${MODDIR}/bin/toybox"
LOG_DIR="$MODDIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/nextram_$(date +%Y%m%d_%H%M%S).log"
MAX_LOG_FILES=5

ZRAM_DEV="/dev/block/zram0"
SYS_ZRAM="/sys/block/zram0"
PROC_MEMINFO="/proc/meminfo"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    case "$LOG_LEVEL" in
        "DEBUG") echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "INFO") [[ "$level" == "DEBUG" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "WARN") [[ "$level" == "DEBUG" || "$level" == "INFO" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "ERROR") [[ "$level" == "ERROR" ]] && echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
    esac
    echo "[NextRAM] $level: $message"
}

cleanup_old_logs() {
    ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +$(($MAX_LOG_FILES + 1)) | xargs rm -f 2>/dev/null
}

system_info() {
    log "INFO" "===== System Information ====="
    log "INFO" "Kernel: $(uname -r)"
    log "INFO" "Android version: $(getprop ro.build.version.release)"
    log "INFO" "Device: $(getprop ro.product.model)"
    
    local mem_total=$(awk '/MemTotal/ {print $2}' $PROC_MEMINFO)
    local mem_free=$(awk '/MemFree/ {print $2}' $PROC_MEMINFO)
    local swap_total=$(awk '/SwapTotal/ {print $2}' $PROC_MEMINFO)
    local swap_free=$(awk '/SwapFree/ {print $2}' $PROC_MEMINFO)
    
    log "INFO" "Total RAM: $((mem_total / 1024))MB"
    log "INFO" "Free RAM: $((mem_free / 1024))MB"
    log "INFO" "Total Swap: $((swap_total / 1024))MB"
    log "INFO" "Free Swap: $((swap_free / 1024))MB"
}

check_prerequisites() {
    [ "$(id -u)" -ne 0 ] && { 
        log "ERROR" "Must run as root"
        exit 1
    }
    
    local missing_tools=""
    for tool in swapon swapoff mkswap mount umount awk grep; do
        if ! command -v $tool >/dev/null 2>&1; then
            missing_tools="$missing_tools $tool"
        fi
    done
    
    if [ -n "$missing_tools" ]; then
        log "WARN" "Missing tools: $missing_tools"
    fi
    
    if [ ! -b "$ZRAM_DEV" ]; then
        log "WARN" "ZRAM device not found"
        ZRAM_ENABLED=false
    fi
}

adjust_swappiness() {
    if [ "$DYNAMIC_SWAPPINESS" = "true" ]; then
        local mem_total=$(awk '/MemTotal/ {print $2}' $PROC_MEMINFO)
        
        if [ "$mem_total" -lt 2000000 ]; then
            SWAPPINESS=100
        elif [ "$mem_total" -lt 4000000 ]; then
            SWAPPINESS=90
        else
            SWAPPINESS=80
        fi
        
        log "INFO" "Dynamic swappiness adjustment: $SWAPPINESS"
    fi
}

apply_kernel_tuning() {
    if [ "$EXTRA_TUNING" = "true" ]; then
        echo $SWAPPINESS > /proc/sys/vm/swappiness
        echo $CACHE_PRESSURE > /proc/sys/vm/vfs_cache_pressure
        echo $DIRTY_RATIO > /proc/sys/vm/dirty_ratio
        echo $DIRTY_BACKGROUND_RATIO > /proc/sys/vm/dirty_background_ratio
        
        if [ "$PERFORMANCE_MODE" = "true" ]; then
            echo 0 > /proc/sys/vm/oom_kill_allocating_task
            echo 1 > /proc/sys/vm/overcommit_memory
        fi
        
        log "INFO" "Applied kernel tuning parameters"
    fi
}

test_zram_algorithms() {
    [ ! -b "$ZRAM_DEV" ] && return 1
    
    log "INFO" "Testing ZRAM compression algorithms"
    local available_algs=$(cat "$SYS_ZRAM/comp_algorithm" | sed 's/\[//g;s/\]//g' | tr ' ' '\n')
    local test_algorithms="lz4 zstd lzo lzo-rle"
    local best_alg="lz4"
    local best_score=0
    
    for alg in $test_algorithms; do
        if echo "$available_algs" | grep -qw "$alg"; then
            echo "$alg" > "$SYS_ZRAM/comp_algorithm"
            echo "1M" > "$SYS_ZRAM/disksize"
            
            if mkswap "$ZRAM_DEV" >/dev/null 2>&1 && swapon "$ZRAM_DEV" >/dev/null 2>&1; then
                local start_time=$(date +%s%N)
                dd if=/dev/zero of=/dev/block/zram0 bs=1M count=10 >/dev/null 2>&1
                local end_time=$(date +%s%N)
                local duration=$((($end_time - $start_time)/1000000))
                
                swapoff "$ZRAM_DEV" >/dev/null 2>&1
                echo 1 > "$SYS_ZRAM/reset"
                
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
    if [ -f "$SYS_ZRAM/mm_stat" ]; then
        local stats=$(cat "$SYS_ZRAM/mm_stat")
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
    [ ! -b "$ZRAM_DEV" ] && {
        log "WARN" "ZRAM device not found, skipping ZRAM setup"
        return 1
    }

    if [ "$ZRAM_AUTO_TUNE" = "true" ]; then
        test_zram_algorithms
    fi

    log "INFO" "Configuring ZRAM with extended compression algorithms"

    local compression_algorithms="zstd lz4 lzo lzo-rle deflate lz4hc 842 z3fold"
    local available_algs=$(cat "$SYS_ZRAM/comp_algorithm" | sed 's/\[//g;s/\]//g' | tr ' ' '\n')
    local chosen_alg=""
    
    if echo "$available_algs" | grep -qw "$ZRAM_ALGORITHM"; then
        chosen_alg="$ZRAM_ALGORITHM"
        log "INFO" "Using configured algorithm: $chosen_alg"
    else
        for alg in $compression_algorithms; do
            if echo "$available_algs" | grep -qw "$alg"; then
                chosen_alg="$alg"
                log "INFO" "Selected compression algorithm: $chosen_alg (from priority list)"
                break
            fi
        done
    fi

    if [ -z "$chosen_alg" ]; then
        chosen_alg=$(echo "$available_algs" | head -n1 | awk '{print $1}')
        log "WARN" "No preferred algorithm found, using first available: $chosen_alg"
    fi

    echo "$chosen_alg" > "$SYS_ZRAM/comp_algorithm"
    
    case "$chosen_alg" in
        "zstd")
            echo 3 > /proc/sys/vm/page-cluster
            ;;
        "lz4"|"lz4hc")
            echo 2 > /proc/sys/vm/page-cluster
            ;;
        *)
            echo 0 > /proc/sys/vm/page-cluster
            ;;
    esac

    local cpu_cores=$(grep -c ^processor /proc/cpuinfo)
    if [ "$cpu_cores" -gt 0 ]; then
        if echo "$chosen_alg" | grep -qE "^(zstd|lz4|lz4hc)$"; then
            echo $cpu_cores > "$SYS_ZRAM/max_comp_streams"
            log "INFO" "Set compression streams to $cpu_cores for multi-threaded algorithm $chosen_alg"
        else
            echo 1 > "$SYS_ZRAM/max_comp_streams"
            log "INFO" "Set compression streams to 1 for single-threaded algorithm $chosen_alg"
        fi
    fi

    local total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    local zram_size_kb=$(awk -v ram="$total_ram" -v ratio="$ZRAM_RATIO" 'BEGIN {printf "%.0f", ram * ratio}')
    
    if echo "$chosen_alg" | grep -qE "^(zstd|deflate)$"; then
        zram_size_kb=$(awk -v size="$zram_size_kb" 'BEGIN {printf "%.0f", size * 1.2}')
        log "INFO" "Increased ZRAM size by 20% for better compression with $chosen_alg"
    fi

    local max_zram_kb=4194304
    if [ "$zram_size_kb" -gt "$max_zram_kb" ]; then
        zram_size_kb=$max_zram_kb
        log "INFO" "ZRAM size limited to 4GB"
    fi

    echo "${zram_size_kb}K" > "$SYS_ZRAM/disksize"
    log "INFO" "ZRAM size set to: ${zram_size_kb}KB"

    if [ -f "$SYS_ZRAM/memory_limit" ]; then
        echo 0 > "$SYS_ZRAM/memory_limit"
    fi

    if mkswap "$ZRAM_DEV" >/dev/null 2>&1; then
        if su -c "swapon '$ZRAM_DEV' -p 100"; then
            log "INFO" "ZRAM activated with priority 100 using $chosen_alg algorithm"
            
            if [ -f "$SYS_ZRAM/mm_stat" ]; then
                log "DEBUG" "Initial ZRAM stats: $(cat $SYS_ZRAM/mm_stat)"
            fi
            
            monitor_zram_efficiency
            return 0
        else
            log "ERROR" "Failed to activate ZRAM swap"
        fi
    else
        log "ERROR" "Failed to initialize ZRAM device"
    fi

    return 1
}

setup_swap() {
    SWAP_IMG="$MODDIR/swapfile.img"
    SWAP_MOUNT_DIR="$MODDIR/swap_mount"
    SWAP_FILE="$SWAP_MOUNT_DIR/swapfile"
    
    PRECISE_BYTES=$(awk -v s="$SWAP_SIZE_GB" 'BEGIN {printf "%.0f", s * 1073741824}')
    
    if [ -f "$SWAP_IMG" ] && [ -f "$SWAP_FILE" ]; then
        ACTUAL_SIZE=$(stat -c %s "$SWAP_FILE" 2>/dev/null)
        if [ "$ACTUAL_SIZE" -eq "$PRECISE_BYTES" ]; then
            mkdir -p "$SWAP_MOUNT_DIR"
            su -c "mount -o loop,rw,noatime,nodiratime,discard '$SWAP_IMG' '$SWAP_MOUNT_DIR'" && {
                mkswap "$SWAP_FILE" >/dev/null 2>&1
                su -c "swapon '$SWAP_FILE' -p 10" && {
                    log "INFO" "Existing swap activated"
                    return 0
                }
            }
        fi
    fi

    su -c "umount '$SWAP_MOUNT_DIR'" 2>/dev/null
    rm -f "$SWAP_IMG"
    rm -rf "$SWAP_MOUNT_DIR"

    TOTAL_IMG_SIZE_GB=$(awk -v s="$SWAP_SIZE_GB" -v o="$OVERHEAD_GB" 'BEGIN {print s + o}')
    TOTAL_IMG_SIZE_BYTES=$(awk -v t="$TOTAL_IMG_SIZE_GB" 'BEGIN {printf "%.0f", t * 1073741824}')

    REQUIRED_KB=$(awk -v t="$TOTAL_IMG_SIZE_GB" 'BEGIN {printf "%.0f", t * 1048576}')
    DATA_FREE_KB=$(df -k /data | awk 'NR==2 {print $4}')
    if [ "$DATA_FREE_KB" -lt "$REQUIRED_KB" ]; then
        log "ERROR" "Insufficient space: need ${REQUIRED_KB}KB, have ${DATA_FREE_KB}KB"
        return 1
    fi

    log "INFO" "Creating swap image: ${TOTAL_IMG_SIZE_GB}GB"
    if ! $TOYBOX fallocate -l "$TOTAL_IMG_SIZE_BYTES" "$SWAP_IMG" 2>/dev/null; then
        rm -f "$SWAP_IMG"
        log "WARN" "Fallocate failed, using dd"
        dd if=/dev/zero of="$SWAP_IMG" bs=1024 count=$(($TOTAL_IMG_SIZE_BYTES / 1024)) 2>/dev/null || {
            rm -f "$SWAP_IMG"
            return 1
        }
    fi

    if ! mkfs.ext4 -F "$SWAP_IMG" >/dev/null 2>&1; then
        rm -f "$SWAP_IMG"
        return 1
    fi

    mkdir -p "$SWAP_MOUNT_DIR"
    if ! su -c "mount -o loop,rw,noatime,nodiratime,discard '$SWAP_IMG' '$SWAP_MOUNT_DIR'"; then
        rm -f "$SWAP_IMG"
        return 1
    fi

    log "INFO" "Creating swap file: ${SWAP_SIZE_GB}GB"
    if ! $TOYBOX fallocate -l "$PRECISE_BYTES" "$SWAP_FILE" 2>/dev/null; then
        dd if=/dev/zero of="$SWAP_FILE" bs=1024 count=$(($PRECISE_BYTES / 1024)) 2>/dev/null || {
            su -c "umount '$SWAP_MOUNT_DIR'"
            rm -f "$SWAP_IMG"
            return 1
        }
    fi

    chmod 600 "$SWAP_FILE"
    if ! mkswap "$SWAP_FILE" >/dev/null 2>&1; then
        su -c "umount '$SWAP_MOUNT_DIR'"
        rm -f "$SWAP_IMG"
        return 1
    fi

    if ! su -c "swapon '$SWAP_FILE' -p 10"; then
        su -c "umount '$SWAP_MOUNT_DIR'"
        rm -f "$SWAP_IMG"
        return 1
    fi

    log "INFO" "Swap setup complete"
    return 0
}

start_api_server() {
    log "INFO" "Starting web interface on port 8080"
    busybox httpd -p 8080 -h "$MODDIR/webroot" -f &
    API_PID=$!
    echo $API_PID > "$MODDIR/api.pid"
    log "INFO" "Web interface available at: http://localhost:8080"
}

stop_api_server() {
    if [ -f "$MODDIR/api.pid" ]; then
        kill $(cat "$MODDIR/api.pid") 2>/dev/null
        rm -f "$MODDIR/api.pid"
        log "INFO" "Web interface stopped"
    fi
}

get_config() {
    echo "{"
    echo "  \"SWAP_ENABLED\": $SWAP_ENABLED,"
    echo "  \"SWAP_SIZE_GB\": $SWAP_SIZE_GB,"
    echo "  \"OVERHEAD_GB\": $OVERHEAD_GB,"
    echo "  \"ZRAM_ENABLED\": $ZRAM_ENABLED,"
    echo "  \"ZRAM_RATIO\": $ZRAM_RATIO,"
    echo "  \"ZRAM_ALGORITHM\": \"$ZRAM_ALGORITHM\","
    echo "  \"MAX_COMP_STREAMS\": $MAX_COMP_STREAMS,"
    echo "  \"SWAPPINESS\": $SWAPPINESS,"
    echo "  \"CACHE_PRESSURE\": $CACHE_PRESSURE,"
    echo "  \"DIRTY_RATIO\": $DIRTY_RATIO,"
    echo "  \"DIRTY_BACKGROUND_RATIO\": $DIRTY_BACKGROUND_RATIO,"
    echo "  \"EXTRA_TUNING\": $EXTRA_TUNING,"
    echo "  \"DYNAMIC_SWAPPINESS\": $DYNAMIC_SWAPPINESS,"
    echo "  \"PERFORMANCE_MODE\": $PERFORMANCE_MODE,"
    echo "  \"ZRAM_AUTO_TUNE\": $ZRAM_AUTO_TUNE,"
    echo "  \"LOG_LEVEL\": \"$LOG_LEVEL\""
    echo "}"
}

set_config() {
    for setting in "$@"; do
        key="${setting%%=*}"
        value="${setting#*=}"
        sed -i "s/^${key}=.*/${key}=${value}/" "$0"
    done
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
    if [ -b "/dev/block/zram0" ]; then
        cat /sys/block/zram0/mm_stat 2>/dev/null || echo "ZRAM not initialized"
    else
        echo "ZRAM device not available"
    fi
}

apply_configuration() {
    log "INFO" "Applying current configuration"
    
    swapoff -a 2>/dev/null
    
    if [ -b "/dev/block/zram0" ]; then
        echo 1 > "/dev/block/zram0/reset" 2>/dev/null
    fi
    
    if [ "$ZRAM_ENABLED" = "true" ]; then
        setup_zram
    fi
    
    if [ "$SWAP_ENABLED" = "true" ]; then
        setup_swap
    fi
    
    adjust_swappiness
    apply_kernel_tuning
    
    log "INFO" "Configuration applied successfully"
}

case "${1:-}" in
    "web")
        cleanup_old_logs
        start_api_server
        while true; do sleep 60; done
        ;;
    "api")
        case "$2" in
            "get-config") get_config ;;
            "set-config") shift 2; set_config "$@" ;;
            "apply") apply_configuration ;;
            "restart") exec "$0" ;;
            "status") get_status ;;
            *) echo "Unknown API command: $2" ;;
        esac
        exit 0
        ;;
    "apply")
        apply_configuration
        exit 0
        ;;
    "restart")
        log "INFO" "Restarting service"
        exec "$0"
        ;;
    *)
        cleanup_old_logs
        system_info
        check_prerequisites
        
        log "INFO" "Disabling all swap devices"
        swapoff -a 2>&1 | while read line; do log "INFO" "swapoff: $line"; done

        if [ -b "/dev/block/zram0" ]; then
            log "INFO" "Resetting zram0"
            swapoff "/dev/block/zram0" 2>/dev/null
            echo 1 > "/dev/block/zram0/reset" 2>/dev/null
        fi

        adjust_swappiness
        apply_kernel_tuning

        if [ "$SWAP_ENABLED" = "true" ]; then
            setup_swap
        fi

        if [ "$ZRAM_ENABLED" = "true" ]; then
            setup_zram
        fi

        log "INFO" "NextRAM setup complete"
        log "INFO" "Current swap status:"
        cat /proc/swaps >> "$LOG_FILE" 2>/dev/null
        ;;
esac

exit 0