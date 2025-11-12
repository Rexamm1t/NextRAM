#!/system/bin/sh

MODDIR=${0%/*}
SWAP_MOUNT_DIR="$MODDIR/swap_mount"
SWAP_IMG="$MODDIR/swapfile.img"

swapoff "$SWAP_MOUNT_DIR/swapfile" 2>/dev/null
umount "$SWAP_MOUNT_DIR" 2>/dev/null
rm -f "$SWAP_IMG"
rm -rf "$SWAP_MOUNT_DIR"

if [ -b "/dev/block/zram0" ]; then
    swapoff "/dev/block/zram0" 2>/dev/null
    echo 1 > "/dev/block/zram0/reset" 2>/dev/null
fi

echo "NextRAM completely uninstalled"
exit 0