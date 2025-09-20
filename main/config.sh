#!/system/bin/sh
MODDIR=${0%/*}/..

init_config() {
    cat $MODDIR/config.conf >/dev/null 2>&1 || touch $MODDIR/config.conf

    LIST_VAR='
    SWAP_ENABLED:false
    SWAP_SIZE_GB:1.0
    OVERHEAD_GB:0.3
    ZRAM_ENABLED:true
    ZRAM_RATIO:2.56
    ZRAM_ALGORITHM:lz4
    MAX_COMP_STREAMS:6
    SWAPPINESS:90
    CACHE_PRESSURE:34
    DIRTY_RATIO:24
    DIRTY_BACKGROUND_RATIO:7
    EXTRA_TUNING:false
    DYNAMIC_SWAPPINESS:false
    PERFORMANCE_MODE:false
    ZRAM_AUTO_TUNE:false
    LOG_LEVEL:"INFO"
    '

    for var in $LIST_VAR; do
        variable="${var%%:*}"
        value="${var#*:}"
        
        if [ -z "$(eval echo \$$variable)" ]; then
            echo "$variable=$value" >> $MODDIR/config.conf
            eval "$variable=\"$value\""
        fi
    done

    . $MODDIR/config.conf
}