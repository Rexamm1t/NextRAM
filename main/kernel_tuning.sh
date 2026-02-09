#!/system/bin/sh
MODDIR=${0%/*}/..

adjust_swappiness() {
    [ "$DYNAMIC_SWAPPINESS" != "true" ] && return 0
    
    local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)
    [ -z "$mem_total" ] && { log "WARN" "Cannot get total memory"; return 1; }
    
    local zram_size=0
    local swap_usage=0
    
    if [ -b "/dev/block/zram0" ] || [ -d "/sys/block/zram0" ]; then
        zram_size=$(awk '/^\/dev\/block\/zram0/ {print $3}' /proc/swaps 2>/dev/null)
        [ -z "$zram_size" ] && zram_size=0
    fi
    
    local swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo 2>/dev/null)
    local swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo 2>/dev/null)
    swap_total=${swap_total:-0}
    swap_free=${swap_free:-0}
    
    if [ "$swap_total" -gt 0 ]; then
        swap_usage=$(( (swap_total - swap_free) * 100 / swap_total ))
    fi
    
    local base_swappiness=100
    
    if [ "$mem_total" -lt 1000000 ]; then
        base_swappiness=170
    elif [ "$mem_total" -lt 2000000 ]; then
        base_swappiness=155
    elif [ "$mem_total" -lt 3000000 ]; then
        base_swappiness=145
    elif [ "$mem_total" -lt 4000000 ]; then
        base_swappiness=125
    elif [ "$mem_total" -lt 5000000 ]; then
        base_swappiness=105
    elif [ "$mem_total" -lt 6000000 ]; then
        base_swappiness=100
    elif [ "$mem_total" -lt 8000000 ]; then
        base_swappiness=80
    elif [ "$mem_total" -lt 12000000 ]; then
        base_swappiness=70
    elif [ "$mem_total" -lt 16000000 ]; then
        base_swappiness=55
    else
        base_swappiness=50
    fi
    
    SWAPPINESS=$base_swappiness
    
    [ "$zram_size" -gt 0 ] && SWAPPINESS=$((SWAPPINESS + 30))
    [ "$swap_usage" -gt 80 ] && SWAPPINESS=$((SWAPPINESS + 20))
    [ "$swap_usage" -lt 20 ] && SWAPPINESS=$((SWAPPINESS - 15))
    
    if [ "$SWAPPINESS" -gt 200 ]; then
        SWAPPINESS=200
    fi
    
    if [ "$SWAPPINESS" -lt 20 ]; then
        SWAPPINESS=20
    fi
    
    log "INFO" "Dynamic swappiness: $SWAPPINESS (Memory: ${mem_total}KB, ZRAM: ${zram_size}KB, Swap usage: ${swap_usage}%)"
}

apply_kernel_tuning() {
    local applied_settings=0
    
    set_param() {
        local file="$1" 
        local value="$2" 
        local desc="${3:-}"
        [ -z "$desc" ] && desc="$(basename "$file")"
        
        if [ -f "$file" ] && [ -w "$file" ]; then
            if echo "$value" > "$file" 2>/dev/null; then
                log "DEBUG" "Set $desc to $value"
                applied_settings=$((applied_settings + 1))
                return 0
            else
                log "WARN" "Failed to set $desc to $value"
            fi
        else
            log "DEBUG" "Cannot write to $file"
        fi
        return 1
    }
    
    set_param "/proc/sys/vm/swappiness" "$SWAPPINESS"
    set_param "/proc/sys/vm/vfs_cache_pressure" "$CACHE_PRESSURE"
    set_param "/proc/sys/vm/dirty_ratio" "$DIRTY_RATIO"
    set_param "/proc/sys/vm/dirty_background_ratio" "$DIRTY_BACKGROUND_RATIO"
    
    if [ "$EXTRA_TUNING" = "true" ]; then
        if [ -f "/proc/sys/vm/min_free_kbytes" ] && [ -w "/proc/sys/vm/min_free_kbytes" ]; then
            local mem_total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)
            if [ -n "$mem_total_kb" ]; then
                local min_free_kbytes=$((mem_total_kb / 100))
                local max_min_free=524288
                if [ "$min_free_kbytes" -gt "$max_min_free" ]; then
                    min_free_kbytes=$max_min_free
                fi
                if echo "$min_free_kbytes" > "/proc/sys/vm/min_free_kbytes" 2>/dev/null; then
                    log "DEBUG" "Set min_free_kbytes to $min_free_kbytes"
                    applied_settings=$((applied_settings + 1))
                fi
            fi
        fi
        
        set_param "/proc/sys/vm/watermark_scale_factor" "50"
        set_param "/proc/sys/vm/oom_kill_allocating_task" "0"
        set_param "/proc/sys/vm/panic_on_oom" "0"
        set_param "/proc/sys/vm/overcommit_memory" "1"
        set_param "/proc/sys/vm/overcommit_ratio" "50"
        
        if [ -f "/proc/sys/vm/compact_memory" ] && [ -w "/proc/sys/vm/compact_memory" ]; then
            echo 1 > "/proc/sys/vm/compact_memory" 2>/dev/null
        fi
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
    
    if [ -f "/proc/sys/kernel/threads-max" ] && [ -w "/proc/sys/kernel/threads-max" ]; then
        local mem_total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)
        if [ -n "$mem_total_kb" ]; then
            local threads_max=$((mem_total_kb * 2))
            if echo "$threads_max" > "/proc/sys/kernel/threads-max" 2>/dev/null; then
                log "DEBUG" "Set threads-max to $threads_max"
                applied_settings=$((applied_settings + 1))
            fi
        fi
    fi
    
    log "INFO" "Applied $applied_settings kernel tuning parameters"
}

verify_tuning() {
    local verification_passed=0
    local total_checks=0

    verify_param() {
        local file="$1" 
        local expected="$2"
        if [ -r "$file" ]; then
            local current=$(cat "$file" 2>/dev/null)
            [ "$current" = "$expected" ] && verification_passed=$((verification_passed + 1))
            total_checks=$((total_checks + 1))
        fi
    }
    
    verify_param "/proc/sys/vm/swappiness" "$SWAPPINESS"
    verify_param "/proc/sys/vm/vfs_cache_pressure" "$CACHE_PRESSURE"
    
    if [ "$total_checks" -gt 0 ]; then
        local success_rate=$((verification_passed * 100 / total_checks))
        log "INFO" "Tuning verification: $success_rate% ($verification_passed/$total_checks)"
        if [ "$success_rate" -lt 50 ]; then
            log "WARN" "Low tuning success rate"
        fi
    fi
}

export_functions() {
    export -f adjust_swappiness 
    export -f apply_kernel_tuning 
    export -f verify_tuning
}

export_functions
