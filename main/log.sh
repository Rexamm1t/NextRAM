#!/system/bin/sh
MODDIR=${0%/*}/..

LOG_DIR="$MODDIR/logs"
mkdir -p "$LOG_DIR"
mkdir -p "$MODDIR/cache"
MAX_LOG_FILES=3
MAX_LOG_SIZE=1048576

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    : ${LOG_FILE:="$LOG_DIR/nextram_$(date +%Y%m%d_%H%M%S).log"}

    if [ -f "$LOG_FILE" ] && [ $(stat -c %s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
    fi

    case "$LOG_LEVEL" in
        "DEBUG") echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "INFO") [[ "$level" == "DEBUG" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "WARN") [[ "$level" == "DEBUG" || "$level" == "INFO" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "ERROR") [[ "$level" == "ERROR" ]] && echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
    esac
    
    [ "$level" = "ERROR" ] && echo "[NextRAM] $level: $message"
}

cleanup_old_logs() {
    find "$LOG_DIR" -name "*.log*" -type f -mtime +7 -delete
    ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +$(($MAX_LOG_FILES + 1)) | xargs rm -f 2>/dev/null
}
