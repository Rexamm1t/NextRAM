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

init_config

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
        check_prerequisites
        
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
        
        [ "$SWAP_ENABLED" = "true" ] && setup_swap
        [ "$ZRAM_ENABLED" = "true" ] && {
            setup_zram
            monitor_zram_usage
        }
        
        start_monitoring
        log "INFO" "NextRAM setup complete"
        
        log "INFO" "Current swap status:"
        cat /proc/swaps >> "$LOG_FILE" 2>/dev/null
        ;;
esac

exit 0
