#!/system/bin/sh
MODDIR=${0%/*}/..

LOG_DIR="$MODDIR/logs"
mkdir -p "$LOG_DIR"
MAX_LOG_FILES=5

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local LOG_FILE="$LOG_DIR/nextram_$(date +%Y%m%d).log"

    case "$LOG_LEVEL" in
        "DEBUG") echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "INFO") [[ "$level" == "DEBUG" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "WARN") [[ "$level" == "DEBUG" || "$level" == "INFO" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
        "ERROR") [[ "$level" == "ERROR" ]] && echo "[$timestamp] [$level] $message" >> "$LOG_FILE" ;;
    esac
    echo "[NextRAM] $level: $message"
}

cleanup_old_logs() {
    ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +$(($MAX_LOG_FILES + 1)) | xargs rm -f 2>/dev/null
}