#!/system/bin/sh
MODDIR=${0%/*}/..

. "$MODDIR/main/config.sh"
. "$MODDIR/main/log.sh"
. "$MODDIR/main/system_info.sh"
. "$MODDIR/main/prerequisites.sh"
. "$MODDIR/main/zram.sh"
. "$MODDIR/main/swap.sh"
. "$MODDIR/main/kernel_tuning.sh"
. "$MODDIR/main/api_functions.sh"
. "$MODDIR/main/advanced_tuning.sh"
. "$MODDIR/main/monitoring.sh"

init_config || { log "ERROR" "Failed to initialize configuration"; exit 1; }

. "$MODDIR/main/play.sh"

case "${1:-}" in
    "web")
        cleanup_old_logs
        start_monitoring
        start_api_server
        while true; do sleep 60; done
        ;;
    "api")
        case "$2" in
            "get-config") get_config ;;
            "set-config") 
                shift 2
                set_config "$@"
                apply_configuration
                ;;
            "apply") apply_configuration ;;
            "restart") 
                log "INFO" "Restarting service"
                exec "$0" "$@"
                ;;
            "status") get_status ;;
            "stats") get_system_stats ;;
            *) echo "Unknown API command: $2" ;;
        esac
        exit 0
        ;;
    "monitor")
        case "$2" in
            "start") start_monitoring ;;
            "stop") stop_monitoring ;;
            "stats") get_system_stats ;;
            *) echo "Usage: $0 monitor {start|stop|stats}" ;;
        esac
        exit 0
        ;;
    "play")
        init_play_mode
        
        [ "$PLAY_ENABLED" != "true" ] && {
            log "ERROR" "NextRAM Play is disabled. Set PLAY_ENABLED=true in config"
            echo "NextRAM Play is disabled. Set PLAY_ENABLED=true in config"
            exit 1
        }
        case "$2" in
            "start")
                log "INFO" "Starting NextRAM Play gaming mode"
                apply_game_mode
                [ "$PLAY_AUTO_DETECT" = "true" ] && setup_game_detector
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
                    echo "Game detected: $(test -f "$MODDIR/cache/game_active" && echo "Yes" || echo "No")"
                    echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A")"
                    echo "GPU Governor: $(cat /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null || echo "N/A")"
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
        check_prerequisites || { log "ERROR" "Prerequisites check failed"; exit 1; }
        
        log "INFO" "Disabling swap devices..."
        swapoff -a 2>/dev/null
        
        if [ -b "/dev/block/zram0" ] || [ -d "/sys/block/zram0" ]; then
            swapoff "/dev/block/zram0" 2>/dev/null
            [ -f "/sys/block/zram0/reset" ] && echo 1 > "/sys/block/zram0/reset" 2>/dev/null
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
            setup_swap || log "ERROR" "Failed to setup swap"
        fi
        
        if [ "$ZRAM_ENABLED" = "true" ]; then
            setup_zram || log "ERROR" "Failed to setup ZRAM"
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
