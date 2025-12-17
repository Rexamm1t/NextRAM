#!/system/bin/sh
MODDIR=${0%/*}/..

adjust_swappiness() {
    [ "$DYNAMIC_SWAPPINESS" != "true" ] && return 0
    
    local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    local zram_size=0
    local swap_usage=0

    if [ -b "/dev/block/zram0" ] || [ -d "/sys/block/zram0" ]; then
        zram_size=$(awk '/^\/dev\/block\/zram0/ {print $3}' /proc/swaps 2>/dev/null || echo 0)
    fi
    
    local swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
    local swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo)
    [ "$swap_total" -gt 0 ] && swap_usage=$(( (swap_total - swap_free) * 100 / swap_total ))

    if [ "$mem_total" -lt 2000000 ]; then
        SWAPPINESS=160
    elif [ "$mem_total" -lt 4000000 ]; then
        SWAPPINESS=120
    elif [ "$mem_total" -lt 6000000 ]; then
        SWAPPINESS=100
    elif [ "$mem_total" -lt 8000000 ]; then
        SWAPPINESS=80
    else
        SWAPPINESS=60
    fi

    [ "$zram_size" -gt 0 ] && SWAPPINESS=$((SWAPPINESS + 30))
    [ "$swap_usage" -gt 80 ] && SWAPPINESS=$((SWAPPINESS + 20))
    [ "$swap_usage" -lt 20 ] && SWAPPINESS=$((SWAPPINESS - 15))

    SWAPPINESS=$((SWAPPINESS > 200 ? 200 : SWAPPINESS))
    SWAPPINESS=$((SWAPPINESS < 20 ? 20 : SWAPPINESS))
    
    log "INFO" "Dynamic swappiness: $SWAPPINESS (Memory: ${mem_total}KB, ZRAM: ${zram_size}KB, Swap usage: ${swap_usage}%)"
}

apply_kernel_tuning() {
    local applied_settings=0
    
    set_param() {
        local file="$1"
        local value="$2"
        [ -w "$file" ] && {
            echo "$value" > "$file" 2>/dev/null && {
                log "DEBUG" "Set $(basename "$file") to $value"
                applied_settings=$((applied_settings + 1))
                return 0
            }
        }
        return 1
    }
    
    set_param "/proc/sys/vm/swappiness" "$SWAPPINESS"
    set_param "/proc/sys/vm/vfs_cache_pressure" "$CACHE_PRESSURE"
    set_param "/proc/sys/vm/dirty_ratio" "$DIRTY_RATIO"
    set_param "/proc/sys/vm/dirty_background_ratio" "$DIRTY_BACKGROUND_RATIO"
    
    if [ "$EXTRA_TUNING" = "true" ]; then
        [ -w "/proc/sys/vm/min_free_kbytes" ] && {
            local mem_total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
            local min_free_kbytes=$((mem_total_kb / 100))
            local max_min_free=524288
            [ "$min_free_kbytes" -gt "$max_min_free" ] && min_free_kbytes=$max_min_free
            echo $min_free_kbytes > /proc/sys/vm/min_free_kbytes && {
                log "DEBUG" "Set min_free_kbytes to $min_free_kbytes"
                applied_settings=$((applied_settings + 1))
            }
        }
        
        set_param "/proc/sys/vm/watermark_scale_factor" "50"
        set_param "/proc/sys/vm/oom_kill_allocating_task" "0"
        set_param "/proc/sys/vm/panic_on_oom" "0"
        set_param "/proc/sys/vm/overcommit_memory" "1"
        set_param "/proc/sys/vm/overcommit_ratio" "50"
        [ -w "/proc/sys/vm/compact_memory" ] && echo 1 > /proc/sys/vm/compact_memory
    fi
    
    if [ "$PERFORMANCE_MODE" = "true" ]; then
        set_param "/proc/sys/vm/laptop_mode" "0"
        set_param "/proc/sys/vm/dirty_writeback_centisecs" "500"
        set_param "/proc/sys/vm/dirty_expire_centisecs" "200"
        set_param "/proc/sys/vm/vfs_cache_pressure" "150"
    else
        set_param "/proc/sys/vm/dirty_writeback_centisecs" "1500"
        set_param "/proc/sys/vm/dirty_expire_centisecs" "3000"
    fi
    
    [ -w "/proc/sys/kernel/threads-max" ] && {
        local threads_max=$(awk '/MemTotal/ {printf "%d", $2 * 2}' /proc/meminfo)
        echo "$threads_max" > /proc/sys/kernel/threads-max && {
            log "DEBUG" "Set threads-max to $threads_max"
            applied_settings=$((applied_settings + 1))
        }
    }
    
    log "INFO" "Applied $applied_settings kernel tuning parameters"
}

verify_tuning() {
    local verification_passed=0
    local total_checks=0

    verify_param() {
        local file="$1"
        local expected="$2"
        [ -r "$file" ] && {
            local current=$(cat "$file" 2>/dev/null)
            [ "$current" = "$expected" ] && verification_passed=$((verification_passed + 1))
            total_checks=$((total_checks + 1))
        }
    }
    
    verify_param "/proc/sys/vm/swappiness" "$SWAPPINESS"
    verify_param "/proc/sys/vm/vfs_cache_pressure" "$CACHE_PRESSURE"
    
    [ $total_checks -gt 0 ] && {
        local success_rate=$((verification_passed * 100 / total_checks))
        log "INFO" "Tuning verification: $success_rate% ($verification_passed/$total_checks)"
        [ $success_rate -lt 50 ] && log "WARN" "Low tuning success rate"
    }
}

export -f adjust_swappiness apply_kernel_tuning verify_tuning
