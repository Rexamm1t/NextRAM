#!/system/bin/sh
MODDIR=${0%/*}/..

. "$MODDIR/config.sh"
. "$MODDIR/log.sh"
. "$MODDIR/system_info.sh"
. "$MODDIR/prerequisites.sh"
. "$MODDIR/zram.sh"
. "$MODDIR/swap.sh"
. "$MODDIR/kernel_tuning.sh"
. "$MODDIR/api_functions.sh"

init_config

case "${1:-}" in
    "web")
        cleanup_old_logs
        start_api_server
        while true; do
            sleep 300
            cleanup_old_logs
        done
        ;;
    "api")
        case "$2" in
            "get-config") get_config ;;
            "set-config") shift 2; set_config "$@" ;;
            "apply") apply_configuration ;;
            "restart") stop_api_server; exec "$0" "$@" ;;
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
        swapoff -a

        if [ -b "/dev/block/zram0" ]; then
            swapoff "/dev/block/zram0" 2>/dev/null
            echo 1 > "/dev/block/zram0/reset" 2>/dev/null
        fi

        adjust_swappiness
        apply_kernel_tuning

        if [ "$ZRAM_ENABLED" = "true" ]; then
            setup_zram
        fi

        if [ "$SWAP_ENABLED" = "true" ]; then
            setup_swap
        fi

        log "INFO" "NextRAM setup complete"
        free -m | while read line; do log "INFO" "$line"; done
        ;;
esac

exit 0