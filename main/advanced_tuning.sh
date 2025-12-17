#!/system/bin/sh
MODDIR=${0%/*}/..

apply_advanced_tuning() {
    log "INFO" "Applying advanced system tuning"
    local applied_settings=0

    set_sysctl() {
        local file="$1"
        local value="$2"
        if [ -w "$file" ]; then
            echo "$value" > "$file" 2>/dev/null && {
                applied_settings=$((applied_settings + 1))
                return 0
            }
        fi
        return 1
    }

    set_sysctl "/proc/sys/vm/dirty_writeback_centisecs" "$VM_DIRTY_WRITEBACK_CENTISECS"
    set_sysctl "/proc/sys/vm/dirty_expire_centisecs" "$VM_DIRTY_EXPIRE_CENTISECS"
    set_sysctl "/proc/sys/vm/page-cluster" "$VM_PAGE_CLUSTER"
    set_sysctl "/proc/sys/vm/laptop_mode" "$VM_LAPTOP_MODE"
    set_sysctl "/proc/sys/vm/oom_kill_allocating_task" "$VM_OOM_KILL_ALLOCATING_TASK"
    set_sysctl "/proc/sys/vm/panic_on_oom" "$VM_PANIC_ON_OOM"
    set_sysctl "/proc/sys/vm/overcommit_memory" "$VM_OVERCOMMIT_MEMORY"
    set_sysctl "/proc/sys/vm/overcommit_ratio" "$VM_OVERCOMMIT_RATIO"
    set_sysctl "/proc/sys/vm/watermark_scale_factor" "$VM_WATERMARK_SCALE_FACTOR"

    if [ -w "/proc/sys/kernel/threads-max" ] && [ "$KERNEL_THREADS_MAX" -gt 0 ]; then
        echo "$KERNEL_THREADS_MAX" > /proc/sys/kernel/threads-max && applied_settings=$((applied_settings + 1))
    fi

    [ "$IO_SCHEDULER_TUNE" = "true" ] && { tune_io_scheduler; applied_settings=$((applied_settings + 1)); }
    [ "$CPU_BOOST" = "true" ] && { tune_cpu_boost; applied_settings=$((applied_settings + 1)); }
    [ "$NETWORK_TUNE" = "true" ] && { tune_network; applied_settings=$((applied_settings + 1)); }

    log "INFO" "Applied $applied_settings advanced tuning parameters"
}

tune_io_scheduler() {
    log "INFO" "Tuning I/O schedulers"
    for block in /sys/block/mmcblk* /sys/block/sda; do
        [ -d "$block" ] || continue
        if [ -w "$block/queue/scheduler" ]; then
            if grep -q "noop" "$block/queue/scheduler"; then
                echo "noop" > "$block/queue/scheduler"
            elif grep -q "mq-deadline" "$block/queue/scheduler"; then
                echo "mq-deadline" > "$block/queue/scheduler"
            fi
        fi
        [ -w "$block/queue/read_ahead_kb" ] && echo "256" > "$block/queue/read_ahead_kb"
        [ -w "$block/queue/nr_requests" ] && echo "128" > "$block/queue/nr_requests"
        [ -w "$block/queue/iostats" ] && echo "0" > "$block/queue/iostats"
    done
}

tune_cpu_boost() {
    log "INFO" "Applying CPU boost settings"
    if [ -d "/sys/module/cpu_boost" ]; then
        [ -w "/sys/module/cpu_boost/parameters/input_boost_ms" ] && echo "100" > /sys/module/cpu_boost/parameters/input_boost_ms
        [ -w "/sys/module/cpu_boost/parameters/input_boost_enabled" ] && echo "1" > /sys/module/cpu_boost/parameters/input_boost_enabled
    fi
    [ -w "/proc/sys/kernel/sched_min_task_util_for_colocation" ] && echo "0" > /proc/sys/kernel/sched_min_task_util_for_colocation
    [ -w "/proc/sys/kernel/sched_migration_fixup" ] && echo "1" > /proc/sys/kernel/sched_migration_fixup
}

tune_network() {
    log "INFO" "Tuning network parameters"
    [ -w "/proc/sys/net/core/rmem_default" ] && echo "262144" > /proc/sys/net/core/rmem_default
    [ -w "/proc/sys/net/core/wmem_default" ] && echo "262144" > /proc/sys/net/core/wmem_default
    [ -w "/proc/sys/net/core/rmem_max" ] && echo "67108864" > /proc/sys/net/core/rmem_max
    [ -w "/proc/sys/net/core/wmem_max" ] && echo "67108864" > /proc/sys/net/core/wmem_max
    [ -w "/proc/sys/net/ipv4/tcp_congestion_control" ] && echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
}

export -f apply_advanced_tuning tune_io_scheduler tune_cpu_boost tune_network