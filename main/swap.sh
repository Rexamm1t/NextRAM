#!/system/bin/sh
MODDIR=${0%/*}/..

setup_swap() {
    SWAP_IMG="$MODDIR/swapfile.img"
    SWAP_MOUNT_DIR="$MODDIR/swap_mount"
    SWAP_FILE="$SWAP_MOUNT_DIR/swapfile"
    
    [ -z "$SWAP_SIZE_GB" ] && { log "ERROR" "SWAP_SIZE_GB not set"; return 1; }
    [ -z "$OVERHEAD_GB" ] && { log "ERROR" "OVERHEAD_GB not set"; return 1; }
    
    PRECISE_BYTES=$(awk -v s="$SWAP_SIZE_GB" 'BEGIN {printf "%.0f", s * 1073741824}')
    
    if [ -f "$SWAP_IMG" ] && [ -f "$SWAP_FILE" ]; then
        ACTUAL_SIZE=$(stat -c %s "$SWAP_FILE" 2>/dev/null || du -b "$SWAP_FILE" 2>/dev/null | awk '{print $1}')
        ACTUAL_SIZE=${ACTUAL_SIZE:-0}
        
        if [ "$ACTUAL_SIZE" -eq "$PRECISE_BYTES" ]; then
            mkdir -p "$SWAP_MOUNT_DIR" 2>/dev/null
            if mount -o loop,rw,noatime,nodiratime,discard,barrier=0 "$SWAP_IMG" "$SWAP_MOUNT_DIR" 2>/dev/null; then
                mkswap "$SWAP_FILE" >/dev/null 2>&1
                if swapon "$SWAP_FILE" -p ${SWAP_PRIORITY:-10} 2>/dev/null; then
                    log "INFO" "Existing swap activated"
                    return 0
                fi
            fi
        fi
    fi
    
    umount "$SWAP_MOUNT_DIR" 2>/dev/null
    rm -f "$SWAP_IMG" 2>/dev/null
    rm -rf "$SWAP_MOUNT_DIR" 2>/dev/null
    
    TOTAL_IMG_SIZE_GB=$(awk -v s="$SWAP_SIZE_GB" -v o="$OVERHEAD_GB" 'BEGIN {print s + o + 0.1}')
    TOTAL_IMG_SIZE_BYTES=$(awk -v t="$TOTAL_IMG_SIZE_GB" 'BEGIN {printf "%.0f", t * 1073741824}')
    REQUIRED_KB=$(awk -v t="$TOTAL_IMG_SIZE_GB" 'BEGIN {printf "%.0f", t * 1048576 * 1.1}')
    
    local DATA_FREE_KB=0
    if df -k /data >/dev/null 2>&1; then
        DATA_FREE_KB=$(df -k /data 2>/dev/null | awk 'NR==2 {print $4}')
        DATA_FREE_KB=${DATA_FREE_KB:-0}
    else
        log "ERROR" "Cannot check /data free space"
        return 1
    fi
    
    if [ "$DATA_FREE_KB" -lt "$REQUIRED_KB" ]; then
        log "ERROR" "Insufficient space: need ${REQUIRED_KB}KB, have ${DATA_FREE_KB}KB"
        return 1
    fi
    
    log "INFO" "Creating NextRAM swap image: ${TOTAL_IMG_SIZE_GB}GB"
    
    if command -v fallocate >/dev/null 2>&1; then
        if ! fallocate -l "$TOTAL_IMG_SIZE_BYTES" "$SWAP_IMG" 2>/dev/null; then
            log "WARN" "Fallocate failed, using dd"
            rm -f "$SWAP_IMG" 2>/dev/null
        fi
    fi
    
    if [ ! -f "$SWAP_IMG" ] || [ $(stat -c %s "$SWAP_IMG" 2>/dev/null || echo 0) -ne "$TOTAL_IMG_SIZE_BYTES" ]; then
        local count=$((TOTAL_IMG_SIZE_BYTES / 1048576))
        dd if=/dev/zero of="$SWAP_IMG" bs=1M count=$count 2>/dev/null || {
            rm -f "$SWAP_IMG" 2>/dev/null
            log "ERROR" "Failed to create swap image"
            return 1
        }
    fi
    
    if ! mkfs.ext4 -q -F "$SWAP_IMG" >/dev/null 2>&1; then
        rm -f "$SWAP_IMG" 2>/dev/null
        log "ERROR" "Failed to format swap image"
        return 1
    fi
    
    mkdir -p "$SWAP_MOUNT_DIR" 2>/dev/null
    if ! mount -o loop,rw,noatime,nodiratime,discard,barrier=0 "$SWAP_IMG" "$SWAP_MOUNT_DIR" 2>/dev/null; then
        rm -f "$SWAP_IMG" 2>/dev/null
        log "ERROR" "Failed to mount swap image"
        return 1
    fi
    
    log "INFO" "Creating swap file: ${SWAP_SIZE_GB}GB"
    
    if command -v fallocate >/dev/null 2>&1; then
        if ! fallocate -l "$PRECISE_BYTES" "$SWAP_FILE" 2>/dev/null; then
            log "WARN" "Fallocate for swap file failed, using dd"
        fi
    fi
    
    if [ ! -f "$SWAP_FILE" ] || [ $(stat -c %s "$SWAP_FILE" 2>/dev/null || echo 0) -ne "$PRECISE_BYTES" ]; then
        local swap_count=$((PRECISE_BYTES / 1048576))
        dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$swap_count 2>/dev/null || {
            umount "$SWAP_MOUNT_DIR" 2>/dev/null
            rm -f "$SWAP_IMG" 2>/dev/null
            log "ERROR" "Failed to create swap file"
            return 1
        }
    fi
    
    chmod 600 "$SWAP_FILE" 2>/dev/null
    if ! mkswap "$SWAP_FILE" >/dev/null 2>&1; then
        umount "$SWAP_MOUNT_DIR" 2>/dev/null
        rm -f "$SWAP_IMG" 2>/dev/null
        log "ERROR" "Failed to format swap file"
        return 1
    fi
    
    if swapon "$SWAP_FILE" -p ${SWAP_PRIORITY:-10} 2>/dev/null; then
        log "INFO" "Swap setup complete (priority: ${SWAP_PRIORITY:-10})"
        return 0
    else
        umount "$SWAP_MOUNT_DIR" 2>/dev/null
        rm -f "$SWAP_IMG" 2>/dev/null
        log "ERROR" "Failed to activate swap"
        return 1
    fi
}
