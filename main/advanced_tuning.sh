#!/system/bin/sh
MODDIR=${0%/*}/..

apply_advanced_tuning() {
    log "INFO" "Applying advanced system tuning"
    local applied_settings=0

    if [ -w "/proc/sys/vm/dirty_writeback_centisecs" ]; then
        echo $VM_DIRTY_WRITEBACK_CENTISECS > /proc/sys/vm/dirty_writeback_centisecs
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/dirty_expire_centisecs" ]; then
        echo $VM_DIRTY_EXPIRE_CENTISECS > /proc/sys/vm/dirty_expire_centisecs
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/page-cluster" ]; then
        echo $VM_PAGE_CLUSTER > /proc/sys/vm/page-cluster
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/laptop_mode" ]; then
        echo $VM_LAPTOP_MODE > /proc/sys/vm/laptop_mode
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/oom_kill_allocating_task" ]; then
        echo $VM_OOM_KILL_ALLOCATING_TASK > /proc/sys/vm/oom_kill_allocating_task
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/panic_on_oom" ]; then
        echo $VM_PANIC_ON_OOM > /proc/sys/vm/panic_on_oom
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/overcommit_memory" ]; then
        echo $VM_OVERCOMMIT_MEMORY > /proc/sys/vm/overcommit_memory
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/overcommit_ratio" ]; then
        echo $VM_OVERCOMMIT_RATIO > /proc/sys/vm/overcommit_ratio
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/vm/watermark_scale_factor" ]; then
        echo $VM_WATERMARK_SCALE_FACTOR > /proc/sys/vm/watermark_scale_factor
        applied_settings=$((applied_settings + 1))
    fi

    if [ -w "/proc/sys/kernel/threads-max" ] && [ "$KERNEL_THREADS_MAX" -gt 0 ]; then
        echo $KERNEL_THREADS_MAX > /proc/sys/kernel/threads-max
        applied_settings=$((applied_settings + 1))
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
    for block in /sys/block/mmcblk* /sys/block/sda; do
        if [ -d "$block" ]; then
            local block_name=$(basename $block)
            if [ -w "$block/queue/scheduler" ]; then
                if grep -q "noop" "$block/queue/scheduler"; then
                    echo "noop" > "$block/queue/scheduler"
                elif grep -q "mq-deadline" "$block/queue/scheduler"; then
                    echo "mq-deadline" > "$block/queue/scheduler"
                fi
            fi
            if [ -w "$block/queue/read_ahead_kb" ]; then
                echo "256" > "$block/queue/read_ahead_kb"
            fi
            if [ -w "$block/queue/nr_requests" ]; then
                echo "128" > "$block/queue/nr_requests"
            fi
            if [ -w "$block/queue/iostats" ]; then
                echo "0" > "$block/queue/iostats"
            fi
        fi
    done
}

tune_cpu_boost() {
    log "INFO" "Applying CPU boost settings"
    if [ -d "/sys/module/cpu_boost" ]; then
        if [ -w "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
            echo "100" > /sys/module/cpu_boost/parameters/input_boost_ms
        fi
        if [ -w "/sys/module/cpu_boost/parameters/input_boost_enabled" ]; then
            echo "1" > /sys/module/cpu_boost/parameters/input_boost_enabled
        fi
    fi
    if [ -w "/proc/sys/kernel/sched_min_task_util_for_colocation" ]; then
        echo "0" > /proc/sys/kernel/sched_min_task_util_for_colocation
    fi
    if [ -w "/proc/sys/kernel/sched_migration_fixup" ]; then
        echo "1" > /proc/sys/kernel/sched_migration_fixup
    fi
}

tune_network() {
    log "INFO" "Tuning network parameters"
    if [ -w "/proc/sys/net/core/rmem_default" ]; then
        echo "262144" > /proc/sys/net/core/rmem_default
    fi
    if [ -w "/proc/sys/net/core/wmem_default" ]; then
        echo "262144" > /proc/sys/net/core/wmem_default
    fi
    if [ -w "/proc/sys/net/core/rmem_max" ]; then
        echo "67108864" > /proc/sys/net/core/rmem_max
    fi
    if [ -w "/proc/sys/net/core/wmem_max" ]; then
        echo "67108864" > /proc/sys/net/core/wmem_max
    fi
    if [ -w "/proc/sys/net/ipv4/tcp_congestion_control" ]; then
        echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
    fi
}

export -f apply_advanced_tuning tune_io_scheduler tune_cpu_boost tune_network