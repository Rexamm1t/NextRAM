#!/system/bin/sh

MODDIR=${0%/*}
LOG_DIR="/data/adb/modules/NextRAM/logs"

safe_mkdir() {
    [ -d "$1" ] || mkdir -p "$1" || {
        echo "ERROR: Cannot create directory $1"
        exit 1
    }
}

get_log_entries() {
    LOG_FILE=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -n1)
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo "No log files found"
    fi
}

main() {
    safe_mkdir "$LOG_DIR"
    get_log_entries
}

main
exit 0