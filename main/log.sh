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
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    timestamp=${timestamp:-"1970-01-01 00:00:00"}
    
    : ${LOG_FILE:="$LOG_DIR/nextram_$(date +%Y%m%d_%H%M%S 2>/dev/null).log"}
    LOG_FILE=${LOG_FILE:-"$LOG_DIR/nextram.log"}

    if [ -f "$LOG_FILE" ] && [ $(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0) -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "$LOG_FILE.old" 2>/dev/null
    fi

    case "$LOG_LEVEL" in
        "DEBUG") 
            echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
            ;;
        "INFO") 
            [[ "$level" == "DEBUG" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
            ;;
        "WARN") 
            [[ "$level" == "DEBUG" || "$level" == "INFO" ]] || echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
            ;;
        "ERROR") 
            [[ "$level" == "ERROR" ]] && echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
            ;;
        *) 
            echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
            ;;
    esac
    
    if [ "$level" = "ERROR" ]; then
        echo "[NextRAM] $level: $message"
    fi
}

cleanup_old_logs() {
    find "$LOG_DIR" -name "*.log*" -type f -mtime +7 -delete 2>/dev/null
    ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +$(($MAX_LOG_FILES + 1)) | xargs rm -f 2>/dev/null
}
