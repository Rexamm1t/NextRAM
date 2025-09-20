#!/system/bin/sh
MODDIR=${0%/*}/..

. $MODDIR/main/config.sh
. $MODDIR/main/log.sh
. $MODDIR/main/system_info.sh
. $MODDIR/main/prerequisites.sh
. $MODDIR/main/zram.sh
. $MODDIR/main/swap.sh
. $MODDIR/main/kernel_tuning.sh
. $MODDIR/main/api_functions.sh

init_config

case "${1:-}" in
    "web")
        cleanup_old_logs
        start_api_server
        while true; do sleep 60; done
        ;;
    "api")
        case "$2" in
            "get-config") get_config ;;
            "set-config") shift 2; set_config "$@" ;;
            "apply") apply_configuration ;;
            "restart") exec "$0" ;;
            "status") get_status ;;
            *) echo "Unknown API command: $2" ;;
        esac
        exit 0
        ;;
    "apply")
        apply_configuration
        exit 0
        ;;
    "restart")
        log "INFO" "Restarting service"
        exec "$0"
        ;;
    *)
        cleanup_old_logs
        system_info
        check_prerequisites

        log "INFO" "Disabling all swap devices"
        swapoff -a 2>&1 | while read line; do log "INFO" "swapoff: $line"; done

        if [ -b "/dev/block/zram0" ]; then
            log "INFO" "Resetting zram0"
            swapoff "/dev/block/zram0" 2>/dev/null
            echo 1 > "/dev/block/zram0/reset" 2>/dev/null
        fi

        adjust_swappiness
        apply_kernel_tuning

        if [ "$SWAP_ENABLED" = "true" ]; then
            setup_swap
        fi

        if [ "$ZRAM_ENABLED" = "true" ]; then
            setup_zram
        fi

        log "INFO" "NextRAM setup complete"
        log "INFO" "Current swap status:"
        cat /proc/swaps >> "$LOG_DIR/nextram_$(date +%Y%m%d).log" 2>/dev/null
        ;;
esac

exit 0