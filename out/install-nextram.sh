#!/system/bin/sh

echo "NextRAM Installation Script"
echo "==========================="

BIN_DIR="/system/bin"
BACKUP_DIR="/data/adb/nextram/backup"

mkdir -p "$BACKUP_DIR"

for binary in main-nextram-service-daemon nextramd-zram-service nextramd-swap-service nextramd-kernel-tn-service nextramd-ctl-global; do
    if [ -f "$BIN_DIR/$binary" ]; then
        echo "Backing up existing $binary..."
        cp "$BIN_DIR/$binary" "$BACKUP_DIR/$binary.backup.$(date +%s)"
    fi
done

echo "Installation complete!"
echo "Please restart your device to start using NextRAM services."
