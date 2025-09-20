#!/system/bin/sh
MODDIR=${0%/*}/..

setup_swap() {
    SWAP_IMG="$MODDIR/swapfile.img"
    SWAP_MOUNT_DIR="$MODDIR/swap_mount"
    SWAP_FILE="$SWAP_MOUNT_DIR/swapfile"
    TOYBOX="$MODDIR/bin/toybox"

    PRECISE_BYTES=$(awk -v s="$SWAP_SIZE_GB" 'BEGIN {printf "%.0f", s * 1073741824}')

    if [ -f "$SWAP_IMG" ] && [ -f "$SWAP_FILE" ]; then
        ACTUAL_SIZE=$(stat -c %s "$SWAP_FILE" 2>/dev/null)
        if [ "$ACTUAL_SIZE" -eq "$PRECISE_BYTES" ]; then
            mkdir -p "$SWAP_MOUNT_DIR"
            mount -o loop,rw,noatime,nodiratime,discard "$SWAP_IMG" "$SWAP_MOUNT_DIR" && {
                mkswap "$SWAP_FILE" >/dev/null 2>&1
                swapon "$SWAP_FILE" -p 10 && {
                    log "INFO" "Existing swap activated"
                    return 0
                }
            }
        fi
    fi

    umount "$SWAP_MOUNT_DIR" 2>/dev/null
    rm -f "$SWAP_IMG"
    rm -rf "$SWAP_MOUNT_DIR"

    TOTAL_IMG_SIZE_GB=$(awk -v s="$SWAP_SIZE_GB" -v o="$OVERHEAD_GB" 'BEGIN {print s + o}')
    TOTAL_IMG_SIZE_BYTES=$(awk -v t="$TOTAL_IMG_SIZE_GB" 'BEGIN {printf "%.0f", t * 1073741824}')

    REQUIRED_KB=$(awk -v t="$TOTAL_IMG_SIZE_GB" 'BEGIN {printf "%.0f", t * 1048576}')
    DATA_FREE_KB=$(df -k /data | awk 'NR==2 {print $4}')
    if [ "$DATA_FREE_KB" -lt "$REQUIRED_KB" ]; then
        log "ERROR" "Insufficient space: need ${REQUIRED_KB}KB, have ${DATA_FREE_KB}KB"
        return 1
    fi

    log "INFO" "Creating swap image: ${TOTAL_IMG_SIZE_GB}GB"
    if ! $TOYBOX fallocate -l "$TOTAL_IMG_SIZE_BYTES" "$SWAP_IMG" 2>/dev/null; then
        rm -f "$SWAP_IMG"
        log "WARN" "Fallocate failed, using dd"
        dd if=/dev/zero of="$SWAP_IMG" bs=1024 count=$(($TOTAL_IMG_SIZE_BYTES / 1024)) 2>/dev/null || {
            rm -f "$SWAP_IMG"
            return 1
        }
    fi

    if ! mkfs.ext4 -F "$SWAP_IMG" >/dev/null 2>&1; then
        rm -f "$SWAP_IMG"
        return 1
    fi

    mkdir -p "$SWAP_MOUNT_DIR"
    if ! mount -o loop,rw,noatime,nodiratime,discard "$SWAP_IMG" "$SWAP_MOUNT_DIR"; then
        rm -f "$SWAP_IMG"
        return 1
    fi

    log "INFO" "Creating swap file: ${SWAP_SIZE_GB}GB"
    if ! $TOYBOX fallocate -l "$PRECISE_BYTES" "$SWAP_FILE" 2>/dev/null; then
        dd if=/dev/zero of="$SWAP_FILE" bs=1024 count=$(($PRECISE_BYTES / 1024)) 2>/dev/null || {
            umount "$SWAP_MOUNT_DIR"
            rm -f "$SWAP_IMG"
            return 1
        }
    fi

    chmod 600 "$SWAP_FILE"
    if ! mkswap "$SWAP_FILE" >/dev/null 2>&1; then
        umount "$SWAP_MOUNT_DIR"
        rm -f "$SWAP_IMG"
        return 1
    fi

    if ! su -c swapon "$SWAP_FILE" -p 10; then
        umount "$SWAP_MOUNT_DIR"
        rm -f "$SWAP_IMG"
        return 1
    fi

    log "INFO" "Swap setup complete"
    return 0
}
