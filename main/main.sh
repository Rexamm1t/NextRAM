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
        
        if [ ! -f /proc/swaps ]; then
            log "WARN" "/proc/swaps not found"
        else
            if [ ! -s /proc/swaps ]; then
                log "INFO" "No swap devices found"
            else
                log "INFO" "Current swap devices:"
                cat /proc/swaps >> "$LOG_FILE" 2>/dev/null
                
                swap_count=0
                disabled_count=0
                
                while IFS= read -r line; do
                    if echo "$line" | grep -q "Filename" || [ -z "$line" ]; then
                        continue
                    fi
                    
                    swap_device=$(echo "$line" | awk '{print $1}')
                    if [ -n "$swap_device" ]; then
                        swap_count=$((swap_count + 1))
                        log "INFO" "Found swap device: $swap_device"
                        
                        if [ -e "$swap_device" ] || [ -f "$swap_device" ] || [ -b "$swap_device" ]; then
                            if swapoff "$swap_device" 2>&1 | while read swap_line; do 
                                log "INFO" "swapoff: $swap_line"
                            done; then
                                disabled_count=$((disabled_count + 1))
                                log "SUCCESS" "Disabled: $swap_device"
                            else
                                log "ERROR" "Failed to disable: $swap_device"
                                if swapoff -f "$swap_device" 2>/dev/null; then
                                    disabled_count=$((disabled_count + 1))
                                    log "SUCCESS" "Force-disabled: $swap_device"
                                else
                                    log "ERROR" "Force disable failed: $swap_device"
                                fi
                            fi
                        else
                            log "WARN" "Device doesn't exist: $swap_device"
                            if swapoff "$swap_device" 2>/dev/null; then
                                disabled_count=$((disabled_count + 1))
                                log "SUCCESS" "Disabled non-existent: $swap_device"
                            fi
                        fi
                    fi
                done < /proc/swaps
                
                log "INFO" "Swap summary: Found $swap_count, disabled $disabled_count"
            fi
        fi

        if command -v free >/dev/null 2>&1; then
            current_swap=$(free | grep -i swap | awk '{print $2}')
            if [ "$current_swap" -eq 0 ] 2>/dev/null; then
                log "INFO" "Verified: All swap disabled"
            else
                log "WARN" "Swap still active: ${current_swap}KB"
            fi
        fi

        if [ -f /proc/swaps ]; then
            remaining_swaps=$(grep -v "Filename" /proc/swaps | grep -v "^$" | wc -l)
            if [ "$remaining_swaps" -eq 0 ]; then
                log "SUCCESS" "Verified: No swap devices remaining"
            else
                log "WARN" "Still $remaining_swaps swap devices active"
                grep -v "Filename" /proc/swaps >> "$LOG_FILE" 2>/dev/null
            fi
        fi

        if [ -b "/dev/block/zram0" ]; then
            log "INFO" "Resetting zram0"
            swapoff "/dev/block/zram0" 2>/dev/null
            if [ -f "/dev/block/zram0/reset" ]; then
                echo 1 > "/dev/block/zram0/reset" 2>/dev/null
            fi
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
        cat /proc/swaps >> "$LOG_FILE" 2>/dev/null
        ;;
esac

exit 0
