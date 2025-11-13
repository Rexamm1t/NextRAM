#!/system/bin/sh
MODDIR=${0%/*}/..

MEMORY_CACHE=""
ZRAM_SIZE_CACHE=""

adjust_swappiness() {
    if [ "$DYNAMIC_SWAPPINESS" = "true" ]; then
        local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
        local zram_size=0
        local swap_usage=0

        if [ -b "/dev/block/zram0" ]; then
            zram_size=$(awk '/^\/dev\/block\/zram0/ {print $3}' /proc/swaps 2>/dev/null || echo 0)
        fi
        
        local swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
        local swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo)
        if [ "$swap_total" -gt 0 ]; then
            swap_usage=$(( (swap_total - swap_free) * 100 / swap_total ))
        fi

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

        if [ "$zram_size" -gt 0 ]; then
            SWAPPINESS=$((SWAPPINESS + 30))
        fi

        if [ "$swap_usage" -gt 80 ]; then
            SWAPPINESS=$((SWAPPINESS + 20))
        elif [ "$swap_usage" -lt 20 ]; then
            SWAPPINESS=$((SWAPPINESS - 15))
        fi

        SWAPPINESS=$((SWAPPINESS > 200 ? 200 : SWAPPINESS))
        SWAPPINESS=$((SWAPPINESS < 20 ? 20 : SWAPPINESS))
        
        log "INFO" "Dynamic swappiness: $SWAPPINESS (Memory: ${mem_total}KB, ZRAM: ${zram_size}KB, Swap usage: ${swap_usage}%)"
    fi
}

apply_kernel_tuning() {
    local applied_settings=0
    
    if [ -w "/proc/sys/vm/swappiness" ]; then
        echo $SWAPPINESS > /proc/sys/vm/swappiness
        log "DEBUG" "Set swappiness to $SWAPPINESS"
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/vfs_cache_pressure" ]; then
        echo $CACHE_PRESSURE > /proc/sys/vm/vfs_cache_pressure
        log "DEBUG" "Set vfs_cache_pressure to $CACHE_PRESSURE"
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/dirty_ratio" ]; then
        echo $DIRTY_RATIO > /proc/sys/vm/dirty_ratio
        log "DEBUG" "Set dirty_ratio to $DIRTY_RATIO"
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/dirty_background_ratio" ]; then
        echo $DIRTY_BACKGROUND_RATIO > /proc/sys/vm/dirty_background_ratio
        log "DEBUG" "Set dirty_background_ratio to $DIRTY_BACKGROUND_RATIO"
        applied_settings=$((applied_settings + 1))
    fi

    if [ "$EXTRA_TUNING" = "true" ]; then
        if [ -w "/proc/sys/vm/min_free_kbytes" ]; then
            local min_free_kbytes=$(awk '/MemTotal/ {printf "%d", $2 * 0.5}' /proc/meminfo)
            echo $min_free_kbytes > /proc/sys/vm/min_free_kbytes
            log "DEBUG" "Set min_free_kbytes to $min_free_kbytes"
        fi

        if [ -w "/proc/sys/vm/watermark_scale_factor" ]; then
            echo 50 > /proc/sys/vm/watermark_scale_factor
            log "DEBUG" "Set watermark_scale_factor to 50"
        fi

        if [ -w "/proc/sys/vm/oom_kill_allocating_task" ]; then
            echo 0 > /proc/sys/vm/oom_kill_allocating_task
            log "DEBUG" "Disabled OOM kill allocating task"
        fi

        if [ -w "/proc/sys/vm/panic_on_oom" ]; then
            echo 0 > /proc/sys/vm/panic_on_oom
            log "DEBUG" "Disabled panic on OOM"
        fi

        if [ -w "/proc/sys/vm/overcommit_memory" ]; then
            echo 1 > /proc/sys/vm/overcommit_memory
            log "DEBUG" "Set overcommit_memory to 1"
        fi

        if [ -w "/proc/sys/vm/overcommit_ratio" ]; then
            echo 50 > /proc/sys/vm/overcommit_ratio
            log "DEBUG" "Set overcommit_ratio to 50"
        fi

        if [ -w "/proc/sys/vm/compact_memory" ]; then
            echo 1 > /proc/sys/vm/compact_memory
            log "DEBUG" "Triggered memory compaction"
        fi

        applied_settings=$((applied_settings + 8))
    fi

    if [ "$PERFORMANCE_MODE" = "true" ]; then
        if [ -w "/proc/sys/vm/laptop_mode" ]; then
            echo 0 > /proc/sys/vm/laptop_mode
            log "DEBUG" "Disabled laptop_mode"
        fi

        if [ -w "/proc/sys/vm/dirty_writeback_centisecs" ]; then
            echo 500 > /proc/sys/vm/dirty_writeback_centisecs
            log "DEBUG" "Set dirty_writeback_centisecs to 500"
        fi

        if [ -w "/proc/sys/vm/dirty_expire_centisecs" ]; then
            echo 200 > /proc/sys/vm/dirty_expire_centisecs
            log "DEBUG" "Set dirty_expire_centisecs to 200"
        fi

        if [ -w "/proc/sys/vm/vfs_cache_pressure" ]; then
            echo 150 > /proc/sys/vm/vfs_cache_pressure
            log "DEBUG" "Performance mode: set vfs_cache_pressure to 150"
        fi

        applied_settings=$((applied_settings + 4))
    else
        if [ -w "/proc/sys/vm/dirty_writeback_centisecs" ]; then
            echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
            log "DEBUG" "Balance mode: set dirty_writeback_centisecs to 1500"
        fi

        if [ -w "/proc/sys/vm/dirty_expire_centisecs" ]; then
            echo 3000 > /proc/sys/vm/dirty_expire_centisecs
            log "DEBUG" "Balance mode: set dirty_expire_centisecs to 3000"
        fi
    fi

    if [ -w "/proc/sys/kernel/threads-max" ]; then
        local threads_max=$(awk '/MemTotal/ {printf "%d", $2 * 2}' /proc/meminfo)
        echo $threads_max > /proc/sys/kernel/threads-max
        log "DEBUG" "Set threads-max to $threads_max"
        applied_settings=$((applied_settings + 1))
    fi

    log "INFO" "Applied $applied_settings kernel tuning parameters"
}

verify_tuning() {
    local verification_passed=0
    local total_checks=0

    if [ -r "/proc/sys/vm/swappiness" ]; then
        local current_swappiness=$(cat /proc/sys/vm/swappiness)
        if [ "$current_swappiness" -eq "$SWAPPINESS" ]; then
            verification_passed=$((verification_passed + 1))
        fi
        total_checks=$((total_checks + 1))
    fi

    if [ -r "/proc/sys/vm/vfs_cache_pressure" ]; then
        local current_pressure=$(cat /proc/sys/vm/vfs_cache_pressure)
        if [ "$current_pressure" -eq "$CACHE_PRESSURE" ]; then
            verification_passed=$((verification_passed + 1))
        fi
        total_checks=$((total_checks + 1))
    fi

    if [ $total_checks -gt 0 ]; then
        local success_rate=$((verification_passed * 100 / total_checks))
        log "INFO" "Tuning verification: $success_rate% ($verification_passed/$total_checks) settings applied successfully"
        
        if [ $success_rate -lt 50 ]; then
            log "WARN" "Low tuning success rate, some parameters may not be supported by this kernel"
        fi
    fi
}

export -f adjust_swappiness apply_kernel_tuning verify_tuning
