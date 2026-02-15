#!/system/bin/sh
MODDIR=${0%/*}/..
MONITOR_BIN="$MODDIR/bin/nextram-monitor"

start_monitoring() {
    log "INFO" "Starting system monitoring"
    if [ -f "$MODDIR/monitor.pid" ]; then
        local old_pid=$(cat "$MODDIR/monitor.pid" 2>/dev/null)
        if [ -n "$old_pid" ] && [ -d "/proc/$old_pid" ]; then
            kill -9 "$old_pid" 2>/dev/null
        fi
        rm -f "$MODDIR/monitor.pid" 2>/dev/null
    fi
    mkdir -p "$MODDIR/logs" 2>/dev/null
    if [ -x "$MONITOR_BIN" ]; then
        "$MONITOR_BIN" --interval 30 --output-dir "$MODDIR/logs" &
        MONITOR_PID=$!
    else
        nohup sh -c "
        while true; do
            if [ -b '/dev/block/zram0' ]; then
                local stats=\$(cat /sys/block/zram0/mm_stat 2>/dev/null)
                if [ -n \"\$stats\" ]; then
                    local compr_size=\$(echo \"\$stats\" | awk '{print \$2}')
                    local orig_size=\$(echo \"\$stats\" | awk '{print \$3}')
                    local ratio=0
                    if [ \"\$compr_size\" -gt 0 ]; then
                        ratio=\$(awk -v c=\"\$compr_size\" -v o=\"\$orig_size\" 'BEGIN {printf \"%.2f\", o/c}')
                    fi
                    echo \"\$(date '+%Y-%m-%d %H:%M:%S'),ZRAM,\$compr_size,\$orig_size,\$ratio\" >> \"$MODDIR/logs/zram_monitor.csv\" 2>/dev/null
                fi
            fi
            local swap_total=\$(awk '/SwapTotal/ {print \$2}' /proc/meminfo 2>/dev/null)
            local swap_free=\$(awk '/SwapFree/ {print \$2}' /proc/meminfo 2>/dev/null)
            swap_total=\${swap_total:-0}
            swap_free=\${swap_free:-0}
            local swap_used=\$((swap_total - swap_free))
            echo \"\$(date '+%Y-%m-%d %H:%M:%S'),SWAP,\$swap_used,\$swap_total\" >> \"$MODDIR/logs/swap_monitor.csv\" 2>/dev/null
            local mem_available=\$(awk '/MemAvailable/ {print \$2}' /proc/meminfo 2>/dev/null)
            local mem_total=\$(awk '/MemTotal/ {print \$2}' /proc/meminfo 2>/dev/null)
            mem_available=\${mem_available:-0}
            mem_total=\${mem_total:-0}
            echo \"\$(date '+%Y-%m-%d %H:%M:%S'),MEMORY,\$mem_available,\$mem_total\" >> \"$MODDIR/logs/memory_monitor.csv\" 2>/dev/null
            sleep 30
        done
        " > /dev/null 2>&1 &
        MONITOR_PID=$!
    fi
    echo "$MONITOR_PID" > "$MODDIR/monitor.pid" 2>/dev/null
    log "INFO" "System monitoring started (PID: $MONITOR_PID)"
}

stop_monitoring() {
    if [ -f "$MODDIR/monitor.pid" ]; then
        local pid=$(cat "$MODDIR/monitor.pid" 2>/dev/null)
        if [ -n "$pid" ] && [ -d "/proc/$pid" ]; then
            kill -9 "$pid" 2>/dev/null
        fi
        rm -f "$MODDIR/monitor.pid" 2>/dev/null
        log "INFO" "System monitoring stopped"
    fi
}

get_system_stats() {
    echo "=== System Statistics ==="
    echo "Uptime: $(awk '{print $1}' /proc/uptime 2>/dev/null || echo "N/A") seconds"
    echo "Load Average: $(cat /proc/loadavg 2>/dev/null || echo "N/A")"
    echo ""
    echo "=== Memory Stats ==="
    free -m 2>/dev/null || echo "Cannot get memory stats"
    echo ""
    echo "=== ZRAM Stats ==="
    if [ -b "/dev/block/zram0" ] || [ -d "/sys/block/zram0" ]; then
        if [ -x "$MODDIR/bin/nextram-zram-ctl" ]; then
            "$MODDIR/bin/nextram-zram-ctl" stats
        else
            cat /sys/block/zram0/mm_stat 2>/dev/null | awk '
            {
                if (NF >= 3) {
                    print "Original:", $3 " KB"
                    print "Compressed:", $2 " KB"
                    if ($2 > 0) {
                        print "Ratio:", ($3/$2)
                    } else {
                        print "Ratio: N/A"
                    }
                } else {
                    print "Insufficient ZRAM stats"
                }
            }' || echo "Cannot read ZRAM stats"
        fi
    else
        echo "ZRAM not available"
    fi
    echo ""
    echo "=== Disk I/O ==="
    grep -v "0 0 0" /proc/diskstats 2>/dev/null | head -10 || echo "Cannot get disk stats"
}