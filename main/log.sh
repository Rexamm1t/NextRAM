#!/system/bin/sh
MODDIR=${0%/*}/..

LOG_DIR="$MODDIR/logs"
mkdir -p "$LOG_DIR" 2>/dev/null
mkdir -p "$MODDIR/cache" 2>/dev/null
MAX_LOG_FILES=3
MAX_LOG_SIZE=1048576

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "0000-00-00 00:00:00")
    
    if [ -z "${LOG_FILE}" ] || [ ! -f "${LOG_FILE}" ]; then
        LOG_FILE="$LOG_DIR/nextram_$(date +%Y%m%d).log"
        mkdir -p "$LOG_DIR" 2>/dev/null
        touch "$LOG_FILE" 2>/dev/null
        chmod 644 "$LOG_FILE" 2>/dev/null
    fi
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null &
    
    if [ "$level" = "ERROR" ] && command -v logcat >/dev/null 2>&1; then
        logcat -t 100 -s "NextRAM:E $message" 2>/dev/null &
    fi
}

cleanup_old_logs() {
    find "$LOG_DIR" -name "*.log*" -type f -mtime +7 -delete 2>/dev/null
    ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +$(($MAX_LOG_FILES + 1)) | xargs rm -f 2>/dev/null
}
