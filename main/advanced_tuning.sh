#!/system/bin/sh
MODDIR=${0%/*}/..

apply_advanced_tuning() {
    log "INFO" "Applying advanced system tuning"
    local applied_settings=0

    set_sysctl() {
        local file="$1" 
        local value="$2" 
        local desc="${3:-}"
        [ -z "$desc" ] && desc="$(basename "$file")"
        
        if [ -f "$file" ] && [ -w "$file" ]; then
            if echo "$value" > "$file" 2>/dev/null; then
                applied_settings=$((applied_settings + 1))
                log "DEBUG" "Set $desc to $value"
                return 0
            else
                log "WARN" "Failed to set $desc to $value"
            fi
        else
            log "DEBUG" "Cannot write to $file"
        fi
        return 1
    }

    [ -n "$VM_DIRTY_WRITEBACK_CENTISECS" ] && set_sysctl "/proc/sys/vm/dirty_writeback_centisecs" "$VM_DIRTY_WRITEBACK_CENTISECS"
    [ -n "$VM_DIRTY_EXPIRE_CENTISECS" ] && set_sysctl "/proc/sys/vm/dirty_expire_centisecs" "$VM_DIRTY_EXPIRE_CENTISECS"
    [ -n "$VM_PAGE_CLUSTER" ] && set_sysctl "/proc/sys/vm/page-cluster" "$VM_PAGE_CLUSTER"
    [ -n "$VM_LAPTOP_MODE" ] && set_sysctl "/proc/sys/vm/laptop_mode" "$VM_LAPTOP_MODE"
    [ -n "$VM_OOM_KILL_ALLOCATING_TASK" ] && set_sysctl "/proc/sys/vm/oom_kill_allocating_task" "$VM_OOM_KILL_ALLOCATING_TASK"
    [ -n "$VM_PANIC_ON_OOM" ] && set_sysctl "/proc/sys/vm/panic_on_oom" "$VM_PANIC_ON_OOM"
    [ -n "$VM_OVERCOMMIT_MEMORY" ] && set_sysctl "/proc/sys/vm/overcommit_memory" "$VM_OVERCOMMIT_MEMORY"
    [ -n "$VM_OVERCOMMIT_RATIO" ] && set_sysctl "/proc/sys/vm/overcommit_ratio" "$VM_OVERCOMMIT_RATIO"
    [ -n "$VM_WATERMARK_SCALE_FACTOR" ] && set_sysctl "/proc/sys/vm/watermark_scale_factor" "$VM_WATERMARK_SCALE_FACTOR"

    if [ -f "/proc/sys/kernel/threads-max" ] && [ -w "/proc/sys/kernel/threads-max" ] && [ "$KERNEL_THREADS_MAX" -gt 0 ] 2>/dev/null; then
        if echo "$KERNEL_THREADS_MAX" > "/proc/sys/kernel/threads-max" 2>/dev/null; then
            applied_settings=$((applied_settings + 1))
            log "DEBUG" "Set threads-max to $KERNEL_THREADS_MAX"
        else
            log "WARN" "Failed to set threads-max"
        fi
    fi

    if [ "$IO_SCHEDULER_TUNE" = "true" ]; then
        tune_io_scheduler
        applied_settings=$((applied_settings + 1))
    fi
    
    if [ "$CPU_BOOST" = "true" ]; then
        tune_cpu_boost
        applied_settings=$((applied_settings + 1))
    fi
    
    if [ "$NETWORK_TUNE" = "true" ]; then
        tune_network
        applied_settings=$((applied_settings + 1))
    fi

    log "INFO" "Applied $applied_settings advanced tuning parameters"
}

tune_io_scheduler() {
    log "INFO" "Tuning I/O schedulers"
    local tuned_blocks=0
    
    for block in /sys/block/mmcblk* /sys/block/sd*; do
        [ -d "$block" ] || continue
        
        if [ -f "$block/queue/scheduler" ] && [ -w "$block/queue/scheduler" ]; then
            local available_schedulers=$(cat "$block/queue/scheduler" 2>/dev/null)
            if echo "$available_schedulers" | grep -q "noop"; then
                if echo "noop" > "$block/queue/scheduler" 2>/dev/null; then
                    tuned_blocks=$((tuned_blocks + 1))
                fi
            elif echo "$available_schedulers" | grep -q "mq-deadline"; then
                if echo "mq-deadline" > "$block/queue/scheduler" 2>/dev/null; then
                    tuned_blocks=$((tuned_blocks + 1))
                fi
            fi
        fi
        
        if [ -f "$block/queue/read_ahead_kb" ] && [ -w "$block/queue/read_ahead_kb" ]; then
            echo "256" > "$block/queue/read_ahead_kb" 2>/dev/null
        fi
        
        if [ -f "$block/queue/nr_requests" ] && [ -w "$block/queue/nr_requests" ]; then
            echo "128" > "$block/queue/nr_requests" 2>/dev/null
        fi
        
        if [ -f "$block/queue/iostats" ] && [ -w "$block/queue/iostats" ]; then
            echo "0" > "$block/queue/iostats" 2>/dev/null
        fi
    done
    
    log "DEBUG" "Tuned $tuned_blocks block devices"
}

tune_cpu_boost() {
    log "INFO" "Applying CPU boost settings"
    
    if [ -d "/sys/module/cpu_boost" ]; then
        if [ -f "/sys/module/cpu_boost/parameters/input_boost_ms" ] && [ -w "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
            echo "100" > "/sys/module/cpu_boost/parameters/input_boost_ms" 2>/dev/null
        fi
        
        if [ -f "/sys/module/cpu_boost/parameters/input_boost_enabled" ] && [ -w "/sys/module/cpu_boost/parameters/input_boost_enabled" ]; then
            echo "1" > "/sys/module/cpu_boost/parameters/input_boost_enabled" 2>/dev/null
        fi
    fi
    
    if [ -f "/proc/sys/kernel/sched_min_task_util_for_colocation" ] && [ -w "/proc/sys/kernel/sched_min_task_util_for_colocation" ]; then
        echo "0" > "/proc/sys/kernel/sched_min_task_util_for_colocation" 2>/dev/null
    fi
    
    if [ -f "/proc/sys/kernel/sched_migration_fixup" ] && [ -w "/proc/sys/kernel/sched_migration_fixup" ]; then
        echo "1" > "/proc/sys/kernel/sched_migration_fixup" 2>/dev/null
    fi
}

tune_network() {
    log "INFO" "Tuning network parameters"
    
    if [ -f "/proc/sys/net/core/rmem_default" ] && [ -w "/proc/sys/net/core/rmem_default" ]; then
        echo "262144" > "/proc/sys/net/core/rmem_default" 2>/dev/null
    fi
    
    if [ -f "/proc/sys/net/core/wmem_default" ] && [ -w "/proc/sys/net/core/wmem_default" ]; then
        echo "262144" > "/proc/sys/net/core/wmem_default" 2>/dev/null
    fi
    
    if [ -f "/proc/sys/net/core/rmem_max" ] && [ -w "/proc/sys/net/core/rmem_max" ]; then
        echo "67108864" > "/proc/sys/net/core/rmem_max" 2>/dev/null
    fi
    
    if [ -f "/proc/sys/net/core/wmem_max" ] && [ -w "/proc/sys/net/core/wmem_max" ]; then
        echo "67108864" > "/proc/sys/net/core/wmem_max" 2>/dev/null
    fi
    
    if [ -f "/proc/sys/net/ipv4/tcp_congestion_control" ] && [ -w "/proc/sys/net/ipv4/tcp_congestion_control" ]; then
        echo "cubic" > "/proc/sys/net/ipv4/tcp_congestion_control" 2>/dev/null
    fi
}

export_tuning_functions() {
    export -f apply_advanced_tuning 
    export -f tune_io_scheduler 
    export -f tune_cpu_boost 
    export -f tune_network
}

export_tuning_functions