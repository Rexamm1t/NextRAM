#!/system/bin/sh
MODDIR=${0%/*}
exec $MODDIR/main/main.sh "$@"
$MODDIR/system/bin/nextram_driver -d

while true; do
    sleep 60
    if ! pgrep -f "nextram_driver" > /dev/null; then
        $MODDIR/system/bin/nextram_driver -d
    fi
done &