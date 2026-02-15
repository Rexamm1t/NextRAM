#!/system/bin/sh
MODDIR=${0%/*}/..
ZRAM_CTL="$MODDIR/bin/nextram-zram-ctl"
export MODDIR
export LOG_FILE

setup_zram() {
    log "INFO" "Setting up ZRAM via nextram-zram-ctl"
    "$ZRAM_CTL" setup
    return $?
}

monitor_zram_usage() {
    if [ ! -f "$MODDIR/cache/zram_monitor.pid" ]; then
        "$ZRAM_CTL" monitor 30 "$MODDIR/logs" &
        echo $! > "$MODDIR/cache/zram_monitor.pid"
        log "INFO" "ZRAM monitoring started via compiled tool"
    fi
}

zram_cleanup() {
    if [ -f "$MODDIR/cache/zram_monitor.pid" ]; then
        kill -9 $(cat "$MODDIR/cache/zram_monitor.pid") 2>/dev/null
        rm -f "$MODDIR/cache/zram_monitor.pid"
    fi
    "$ZRAM_CTL" cleanup
}

zram_init() {
    "$ZRAM_CTL" init
    return $?
}

zram_device_reset() {
    "$ZRAM_CTL" reset
    return $?
}

zram_set_algorithm() {
    "$ZRAM_CTL" set-algorithm "$1"
    return $?
}

zram_set_streams() {
    "$ZRAM_CTL" set-streams "$1"
    return $?
}

zram_set_disksize() {
    "$ZRAM_CTL" set-size "$1"
    return $?
}

zram_activate_swap() {
    "$ZRAM_CTL" activate "${1:-100}"
    return $?
}

zram_deactivate() {
    "$ZRAM_CTL" deactivate
    return $?
}

zram_get_stats() {
    "$ZRAM_CTL" stats
    return $?
}

zram_test_algorithms() {
    "$ZRAM_CTL" test "${1:-}"
    return $?
}

zram_calculate_optimal_size() {
    "$ZRAM_CTL" calc-size
    return $?
}

zram_get_optimal_streams() {
    "$ZRAM_CTL" optimal-streams "$1"
    return $?
}