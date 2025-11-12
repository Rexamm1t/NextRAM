#!/system/bin/sh
MODDIR=${0%/*}/..

adjust_swappiness() {
    if [ "$DYNAMIC_SWAPPINESS" = "true" ]; then
        local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
        local zram_size=0

        if [ -b "/dev/block/zram0" ]; then
            zram_size=$(awk '/^\/dev\/block\/zram0/ {print $3}' /proc/swaps)
        fi

        if [ "$mem_total" -lt 2000000 ]; then
            SWAPPINESS=150
        elif [ "$mem_total" -lt 4000000 ]; then
            SWAPPINESS=100
        else
            SWAPPINESS=80
        fi

        if [ "$zram_size" -gt 0 ]; then
            SWAPPINESS=$((SWAPPINESS + 20))
        fi

        SWAPPINESS=$((SWAPPINESS > 180 ? 180 : SWAPPINESS))
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
            echo 100 > /proc/sys/vm/vfs_cache_pressure
            echo 5 > /proc/sys/vm/dirty_background_ratio
            echo 20 > /proc/sys/vm/dirty_ratio
            echo 0 > /proc/sys/vm/laptop_mode
        fi

        log "INFO" "Applied kernel tuning parameters"
    fi
}