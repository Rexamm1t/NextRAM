#!/system/bin/sh
MODDIR=${0%/*}/..

adjust_swappiness() {
    if [ "$DYNAMIC_SWAPPINESS" = "true" ]; then
        local mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)

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