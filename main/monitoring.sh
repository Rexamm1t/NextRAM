#!/system/bin/sh
MODDIR=${0%/*}/..

start_monitoring() {
    log "INFO" "Starting system monitoring"
    nohup sh -c "
    while true; do
        if [ -b '/dev/block/zram0' ]; then
            local stats=\$(cat /sys/block/zram0/mm_stat 2>/dev/null)
            if [ -n \"\$stats\" ]; then
                local compr_size=\$(echo \"\$stats\" | awk '{print \$2}')
                local orig_size=\$(echo \"\$stats\" | awk '{print \$3}')
                local ratio=\$(awk -v c=\"\$compr_size\" -v o=\"\$orig_size\" 'BEGIN {if(c>0) printf \"%.2f\", o/c; else print \"0\"}')
                echo \"\$(date '+%Y-%m-%d %H:%M:%S'),ZRAM,\$compr_size,\$orig_size,\$ratio\" >> \"$MODDIR/logs/zram_monitor.csv\"
            fi
        fi
        local swap_total=\$(awk '/SwapTotal/ {print \$2}' /proc/meminfo)
        local swap_free=\$(awk '/SwapFree/ {print \$2}' /proc/meminfo)
        local swap_used=\$((swap_total - swap_free))
        echo \"\$(date '+%Y-%m-%d %H:%M:%S'),SWAP,\$swap_used,\$swap_total\" >> \"$MODDIR/logs/swap_monitor.csv\"
        local mem_available=\$(awk '/MemAvailable/ {print \$2}' /proc/meminfo)
        local mem_total=\$(awk '/MemTotal/ {print \$2}' /proc/meminfo)
        echo \"\$(date '+%Y-%m-%d %H:%M:%S'),MEMORY,\$mem_available,\$mem_total\" >> \"$MODDIR/logs/memory_monitor.csv\"
        sleep 30
    done
    " > /dev/null 2>&1 &
    MONITOR_PID=$!
    echo $MONITOR_PID > "$MODDIR/monitor.pid"
    log "INFO" "System monitoring started (PID: $MONITOR_PID)"
}

stop_monitoring() {
    if [ -f "$MODDIR/monitor.pid" ]; then
        kill -9 $(cat "$MODDIR/monitor.pid") 2>/dev/null
        rm -f "$MODDIR/monitor.pid"
        log "INFO" "System monitoring stopped"
    fi
}

get_system_stats() {
    echo "=== System Statistics ==="
    echo "Uptime: $(cat /proc/uptime | awk '{print $1}') seconds"
    echo "Load Average: $(cat /proc/loadavg)"
    echo ""
    echo "=== Memory Stats ==="
    free -m
    echo ""
    echo "=== ZRAM Stats ==="
    if [ -b "/dev/block/zram0" ]; then
        cat /sys/block/zram0/mm_stat 2>/dev/null | awk '
        {
            print "Original:", $3 " KB"
            print "Compressed:", $2 " KB" 
            print "Ratio:", ($3/$2)
        }' || echo "ZRAM not available"
    fi
    echo ""
    echo "=== Disk I/O ==="
    grep -v "0 0 0" /proc/diskstats | head -10
}

export -f start_monitoring stop_monitoring get_system_stats