#!/system/bin/sh
MODDIR=${0%/*}
exec $MODDIR/main/main.sh "$@"