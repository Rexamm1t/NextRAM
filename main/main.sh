#!/system/bin/sh
MODDIR=${0%/*}/..

safe_source() {
    local module="$1"
    local module_path="$MODDIR/main/$module"
    
    if [ ! -f "$module_path" ]; then
        echo "[NextRAM] ERROR: Module $module not found" >&2
        return 1
    fi
    
    if ! sh -n "$module_path" 2>/dev/null; then
        echo "[NextRAM] WARN: Syntax error in $module" >&2
    fi
    
    . "$module_path" 2>&1 || {
        echo "[NextRAM] ERROR: Failed to load $module" >&2
        return 1
    }
    
    return 0
}

MODULES=(
    "log.sh"
    "config.sh"
    "system_info.sh"
    "prerequisites.sh"
    "zram.sh"
    "swap.sh"
    "kernel_tuning.sh"
    "api_functions.sh"
    "advanced_tuning.sh"
    "monitoring.sh"
)

for module in "${MODULES[@]}"; do
    if ! safe_source "$module"; then
        echo "[NextRAM] CRITICAL: Cannot continue without $module"
        exit 1
    fi
done

CONFIG_LOADED=false
for i in 1 2 3; do
    if init_config; then
        CONFIG_LOADED=true
        break
    fi
    log "WARN" "Config load attempt $i failed, retrying..."
    sleep 1
done

if [ "$CONFIG_LOADED" != "true" ]; then
    log "ERROR" "Failed to load configuration after 3 attempts"
    export SWAP_ENABLED=false
    export ZRAM_ENABLED=false
    export LOG_LEVEL=ERROR
    log "INFO" "Running in emergency mode"
fi

. "$MODDIR/main/play.sh"

case "${1:-}" in
    "web")
        cleanup_old_logs
        start_monitoring
        start_api_server
        while true; do
            sleep 60
        done
        ;;
    "api")
        case "$2" in
            "get-config")
                get_config
                ;;
            "set-config")
                shift 2
                set_config "$@"
                apply_configuration
                ;;
            "apply")
                apply_configuration
                ;;
            "restart")
                log "INFO" "Restarting service"
                exec "$0" "$@"
                ;;
            "status")
                get_status
                ;;
            "stats")
                get_system_stats
                ;;
            *)
                echo "Unknown API command: $2"
                ;;
        esac
        exit 0
        ;;
    "monitor")
        case "$2" in
            "start")
                start_monitoring
                ;;
            "stop")
                stop_monitoring
                ;;
            "stats")
                get_system_stats
                ;;
            *)
                echo "Usage: $0 monitor {start|stop|stats}"
                ;;
        esac
        exit 0
        ;;
    "play")
        if ! init_play_mode; then
            log "ERROR" "Failed to initialize play mode"
            exit 1
        fi
        
        if [ "$PLAY_ENABLED" != "true" ]; then
            log "ERROR" "NextRAM Play is disabled. Set PLAY_ENABLED=true in config"
            echo "NextRAM Play is disabled. Set PLAY_ENABLED=true in config"
            exit 1
        fi
        
        case "$2" in
            "start")
                log "INFO" "Starting NextRAM Play gaming mode"
                apply_game_mode
                if [ "$PLAY_AUTO_DETECT" = "true" ]; then
                    setup_game_detector
                fi
                echo "NextRAM Play activated"
                log "INFO" "NextRAM Play activated via command"
                ;;
            "stop")
                log "INFO" "Stopping NextRAM Play"
                restore_normal_mode
                echo "NextRAM Play deactivated"
                log "INFO" "NextRAM Play deactivated via command"
                ;;
            "profile")
                case "$3" in
                    "fps_competitive"|"open_world"|"casual"|"battery_saver"|"custom")
                        apply_game_profile "$3"
                        echo "Applied profile: $3"
                        log "INFO" "Applied game profile: $3 via command"
                        ;;
                    *)
                        echo "Available profiles: fps_competitive, open_world, casual, battery_saver, custom"
                        log "WARN" "Unknown profile requested: $3"
                        ;;
                esac
                ;;
            "status")
                if [ -f "$MODDIR/cache/game_mode_active" ]; then
                    echo "NextRAM Play: ACTIVE"
                    if [ -f "$MODDIR/cache/game_active" ]; then
                        echo "Game detected: Yes"
                    else
                        echo "Game detected: No"
                    fi
                    local cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A")
                    echo "CPU Governor: $cpu_gov"
                    local gpu_gov=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null || echo "N/A")
                    echo "GPU Governor: $cpu_gov"
                    echo "Touch Polling: ${PLAY_TOUCH_POLLING_RATE}Hz"
                    echo "VSync: $PLAY_VSYNC_MODE"
                    log "DEBUG" "Play status check: ACTIVE"
                else
                    echo "NextRAM Play: INACTIVE"
                    log "DEBUG" "Play status check: INACTIVE"
                fi
                ;;
            "monitor")
                start_performance_monitor
                echo "Performance monitor started"
                log "INFO" "Performance monitor started via command"
                ;;
            "detector")
                setup_game_detector
                echo "Game detector started"
                log "INFO" "Game detector started via command"
                ;;
            *)
                echo "NextRAM Play Commands:"
                echo "  start      - Activate gaming optimizations"
                echo "  stop       - Deactivate and restore normal mode"
                echo "  profile <name> - Apply specific game profile"
                echo "  status     - Show current gaming status"
                echo "  monitor    - Start performance monitoring"
                echo "  detector   - Start game detector"
                log "INFO" "Displayed Play command help"
                ;;
        esac
        exit 0
        ;;
    "apply")
        apply_configuration
        exit 0
        ;;
    "restart")
        log "INFO" "Restarting service"
        exec "$0" "$@"
        ;;
    *)
        cleanup_old_logs
        system_info
        if ! check_prerequisites; then
            log "ERROR" "Prerequisites check failed"
            exit 1
        fi
        
        log "INFO" "Disabling swap devices..."
        swapoff -a 2>/dev/null
        
        if [ -b "/dev/block/zram0" ] || [ -d "/sys/block/zram0" ]; then
            swapoff "/dev/block/zram0" 2>/dev/null
            if [ -f "/sys/block/zram0/reset" ]; then
                echo 1 > "/sys/block/zram0/reset" 2>/dev/null
            fi
            sleep 1
        fi
        
        local remaining_swaps=$(grep -v "Filename" /proc/swaps 2>/dev/null | grep -vc "^$" || echo 0)
        if [ "$remaining_swaps" -eq 0 ]; then
            log "INFO" "All swap devices disabled"
        else
            log "INFO" "Some swap devices remain active: $remaining_swaps"
            grep -v "Filename" /proc/swaps >> "$LOG_FILE" 2>/dev/null
        fi
        
        adjust_swappiness
        apply_kernel_tuning
        apply_advanced_tuning
        
        if [ "$SWAP_ENABLED" = "true" ]; then
            if ! setup_swap; then
                log "ERROR" "Failed to setup swap"
            fi
        fi
        
        if [ "$ZRAM_ENABLED" = "true" ]; then
            if ! setup_zram; then
                log "ERROR" "Failed to setup ZRAM"
            fi
            monitor_zram_usage
        fi
        
        start_monitoring
        log "INFO" "NextRAM setup complete"
        
        log "INFO" "Current swap status:"
        cat /proc/swaps >> "$LOG_FILE" 2>/dev/null
        
        init_play_mode
        ;;
esac

exit 0
