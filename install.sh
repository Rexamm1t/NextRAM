#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false
APKDIR="/data/local/tmp/apk"
CONFIG_FILE="$MODPATH/module.prop"
unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH >&2

ui_print() {
    echo "$1"
}

ui_print_n() {
    echo -n "$1"
}

run_aicf_analysis() {
    if [ ! -x "$MODPATH/main/tools/nextramaicf" ]; then
        ui_print "ERROR: AICF driver not found"
        return 1
    fi
    
    $MODPATH/main/tools/nextramaicf --generate
    
    if [ $? -eq 0 ] && [ -f "/data/adb/modules/NextRAM/config.conf" ]; then
        cp "/data/adb/modules/NextRAM/config.conf" "$MODPATH/config.conf"
        return 0
    else
        return 1
    fi
}

open_browser() {
    ui_print "Opening browser..."
    am start -a android.intent.action.VIEW -d "https://nextram.cocal.ru" >/dev/null 2>&1 &
    am start -n com.android.chrome/com.google.android.apps.chrome.Main -d "https://nextram.cocal.ru" >/dev/null 2>&1 &
    am start -a android.intent.action.VIEW -d "https://nextram.cocal.ru" --user 0 >/dev/null 2>&1 &
}

ui_print " "
ui_print "   \  |               |     _ \      \      \  |"
ui_print "    \ |   _ \ \ \  /  __|  |   |    _ \    |\/ |"
ui_print_n "  |\  |   __/  \  <   |    __ <    __ "
ui_print "$(awk -F= '/^version=/{print $2}' "$CONFIG_FILE")"
ui_print " _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _|"
ui_print " "
ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
ui_print "•  by @rexamm1t • @matrix_5858 • @galaxyfier   •"
ui_print "•            @Alloyd031 • @wefol1x             •"
ui_print "•           @Egor164rus • @w3b_0s1nt           •"
ui_print "•                 with love <3                 •"
ui_print "•        tg channel: @nextram_official         •"
ui_print "•  official web site: https://nextram.cocal.ru/•"
ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"

on_install() {
  ui_print "> Version  > $(awk -F= '/^version=/{print $2}' "$CONFIG_FILE") ($(awk -F= '/^versionCode=/{print $2}' "$CONFIG_FILE"))"
  ui_print "> Status   > $(awk -F= '/^status=/{print $2}' "$CONFIG_FILE")"
  ui_print "> ModName  > $(awk -F= '/^modname=/{print $2}' "$CONFIG_FILE")"
  ui_print "> Type     > $(awk -F= '/^type=/{print $2}' "$CONFIG_FILE")"
  ui_print "+•[ 1 / 5 ]•••••••••••••••••••••[INFORMATION]••+"
  ui_print " • arch    • $(uname -m)"
  ui_print " • android • $(getprop ro.build.version.release)"
  ui_print " • linux   • $(uname -r)"
  ui_print " • API     • $(getprop ro.build.version.sdk)"
  ui_print " • model   • $(getprop ro.product.model)"
  ui_print "+•[ 2 / 5 ]•••••••••••••••••••••••[NR CONFIG]••+"

  conf="/data/adb/modules/$(awk -F= '/^id=/{print $2}' "$CONFIG_FILE")/config.conf"
 
  if [ -f "$conf" ]; then
   ui_print "• config.conf detected, backuping...           •"
   ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
   cp -r $conf $MODPATH
  else
   if [ -f "/data/adb/modules/NextRAM/module.prop" ]; then
    LIST_VAR='
    SWAP_ENABLED:false
    SWAP_SIZE_GB:1.0
    OVERHEAD_GB:0.3
    ZRAM_ENABLED:true
    ZRAM_RATIO:1.5
    ZRAM_ALGORITHM:lz4
    MAX_COMP_STREAMS:4
    SWAPPINESS:100
    CACHE_PRESSURE:100
    DIRTY_RATIO:20
    DIRTY_BACKGROUND_RATIO:10
    EXTRA_TUNING:false
    DYNAMIC_SWAPPINESS:true
    PERFORMANCE_MODE:false
    ZRAM_AUTO_TUNE:false
    LOG_LEVEL:INFO
    VM_DIRTY_WRITEBACK_CENTISECS:1500
    VM_DIRTY_EXPIRE_CENTISECS:3000
    VM_PAGE_CLUSTER:0
    VM_LAPTOP_MODE:0
    VM_OOM_KILL_ALLOCATING_TASK:0
    VM_PANIC_ON_OOM:0
    VM_OVERCOMMIT_MEMORY:1
    VM_OVERCOMMIT_RATIO:50
    VM_WATERMARK_SCALE_FACTOR:10
    KERNEL_THREADS_MAX:0
    ZRAM_COMPRESSION_LEVEL:1
    ZRAM_MEMORY_LIMIT:4G
    SWAP_PRIORITY:10
    ZRAM_PRIORITY:100
    IO_SCHEDULER_TUNE:false
    CPU_BOOST:false
    NETWORK_TUNE:false
    PLAY_ENABLED:true
    PLAY_CPU_BOOST:true
    PLAY_CPU_GOVERNOR:performance
    PLAY_CPU_MIN_FREQ:0
    PLAY_CPU_MAX_FREQ:0
    PLAY_CPU_MAX_FREQ_PERCENT:100
    PLAY_CPU_BOOST_DURATION:2000
    PLAY_CPU_BOOST_LEVEL:50
    PLAY_GPU_BOOST:true
    PLAY_GPU_GOVERNOR:performance
    PLAY_GPU_MAX_FREQ_PERCENT:100
    PLAY_GPU_TOUCH_BOOST:true
    PLAY_TOUCH_BOOST:true
    PLAY_TOUCH_POLLING_RATE:250
    PLAY_VSYNC_MODE:adaptive
    PLAY_DISABLE_HW_OVERLAYS:false
    PLAY_FORCE_GPU_RENDER:true
    PLAY_NETWORK_TUNE:true
    PLAY_NET_RMEM_DEFAULT:262144
    PLAY_NET_WMEM_DEFAULT:262144
    PLAY_NET_RMEM_MAX:67108864
    PLAY_NET_WMEM_MAX:67108864
    PLAY_TCP_CONGESTION:bbr
    PLAY_SWAPPINESS:20
    PLAY_CACHE_PRESSURE:50
    PLAY_DIRTY_RATIO:10
    PLAY_DIRTY_BG_RATIO:5
    PLAY_ZRAM_OPTIMIZE:true
    PLAY_CLEAR_CACHES:true
    PLAY_THERMAL_CONTROL:true
    PLAY_THERMAL_PROFILE:balanced
    PLAY_BG_CONTROL:true
    PLAY_BG_WHITELIST:com.discord,com.spotify.music,com.chrome
    PLAY_BG_KILL_LIMIT:10
    PLAY_AUTO_DETECT:true
    PLAY_GAME_PROFILE:auto
    PLAY_PERF_MONITOR:true
    PLAY_PERF_OVERLAY:false
    PLAY_AUDIO_LATENCY:low
    PLAY_AUDIO_BUFFER:128
    PLAY_CHARGING_BOOST:true
    PLAY_BATTERY_SAVER:false
    PLAY_POWER_LIMIT:0
    PLAY_REALTIME_PRIORITY:true
    PLAY_CPU_AFFINITY:0-3
    PLAY_MEMORY_LOCK:false
    PLAY_IOSCHED_TUNE:true
    '

    if [ -f "/data/adb/modules/NextRAM/common/post-fs-data.sh" ] || [ -f "/data/adb/modules/NextRAM/post-fs-data.sh" ] && [ ! -f "$conf" ]; then
               ui_print "• NextRAM 3.0+ config detected, census...      •"
               ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
    elif [ -f "/data/adb/modules/NextRAM/service.sh" ] && [ ! -f "$conf" ]; then
                ui_print "• NextRAM 6.0+ config detected, census...      •"
                ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
    fi

    for var in $LIST_VAR; do
        variable="${var%%:*}"
        value="${var#*:}"

        if [ -f "/data/adb/modules/NextRAM/common/post-fs-data.sh" ] || [ -f "/data/adb/modules/NextRAM/post-fs-data.sh" ] && [ ! -f "$conf" ]; then
               grep -m 1 "$variable" "/data/adb/modules/NextRAM/post-fs-data.sh" >> $MODPATH/config.conf 2>/dev/null
               grep -m 1 "$variable" "/data/adb/modules/NextRAM/common/post-fs-data.sh" >> $MODPATH/config.conf 2>/dev/null
        elif [ -f "/data/adb/modules/NextRAM/service.sh" ] && [ ! -f "$conf" ]; then
                grep -m 1 "$variable" "/data/adb/modules/NextRAM/service.sh" >> $MODPATH/config.conf 2>/dev/null
        fi

        if [ -f "$MODPATH/config.conf" ]; then
         . $MODPATH/config.conf
         if [ -z "$(eval echo \$$variable)" ]; then
            echo "$variable=$value" >> $MODPATH/config.conf
            eval "$variable=\"$value\""
         fi
        fi
    done
   fi
  fi
  ui_print "+•[ 3 / 5 ]•••••••••••••••••••••••••[Extract]••+"
  ui_print "•              extracting files...             •"
  ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
  unzip -o "$ZIPFILE" 'main/*' -d $MODPATH >&2
  ui_print "•   [1/4] • main* has been copied              •"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  ui_print "•   [2/4] • system* has been copied            •"
  unzip -o "$ZIPFILE" '*.sh' -x "install.sh" -d $MODPATH >&2
  ui_print "•   [3/4] •  the scripts were copied           •"
  unzip -o "$ZIPFILE" 'apk/*' -d $MODPATH >&2
  ui_print "•   [4/4] • apk* has been copied               •"
  ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
  ui_print "•                   * - dir                    •"
  ui_print "•           file copying is complete           •"
  ui_print "+•[ 4 / 5 ]•••••••••••••••••••••••••••••[APK]••+"
  
  find $MODPATH -type f -name "*.sh" -exec chmod 755 {} \;
  find $MODPATH/main/tools -type f -exec chmod 755 {} \;
  chmod 755 $MODPATH/system/bin/nextram 2>/dev/null

  if [ ! -f "$MODPATH/system/bin/nextram" ]; then
    ui_print "ERROR: nextram binary not found"
    exit 1
  fi

  if [ ! -f "$MODPATH/main/tools/nextramaicf" ]; then
    ui_print "WARNING: nextramaicf not found - AICF features will be unavailable"
  fi

  if [ ! -f "$MODPATH/apk/nextram.apk" ]; then
    ui_print "ERROR: nextram.apk not found, skip..."
  else
   mkdir -p $APKDIR
   cp -r $MODPATH/apk/nextram.apk $APKDIR
   unzip -o "$ZIPFILE" 'apk/bin/aapt/*' -d $APKDIR >&2
   chmod 775 $APKDIR/apk/bin/aapt/aapt-$(uname -m)

   if [ -z "$(pm list packages | grep "com.nextram.manager")" ]; then  
     ui_print "•          installing nextram.apk...           •"
     ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
     pm install $APKDIR/nextram.apk >&2 || su -c pm install $APKDIR/nextram.apk >&2
   else
     ui_print "•     nextram.apk already exists, updating...  •"
     ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
     
     pm install -r $APKDIR/nextram.apk >&2 || su -c pm install -r $APKDIR/nextram.apk >&2
     
     if [ $? -ne 0 ]; then
         ui_print "•   update failed, uninstalling old version... •"
         ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
         pm uninstall com.nextram.manager >&2 || su -c pm uninstall com.nextram.manager >&2
         ui_print "•           installing new version...          •"
         ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
         pm install $APKDIR/nextram.apk >&2 || su -c pm install $APKDIR/nextram.apk >&2
     fi
   fi
   rm -rf $APKDIR
  fi
  ui_print "+•[ 5 / 5 ]••••••••••••••••••••••••••••[AICF]••+"
  ui_print "• generate a configuration file for your device?"
  ui_print "• Vol (+) - Yes (beta, not beautiful)          •"
  ui_print "• Vol (-) - No (standard cfg, existing)        •"
  ui_print "• waiting for 15 seconds...                    •"
  ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"

  timeout_seconds=15
  line="$(timeout $timeout_seconds getevent -ql 2>/dev/null | grep -m1 -E "KEY_VOLUME(UP|DOWN)")"
    
  case "$line" in
        *KEY_VOLUMEUP*)   run_aicf_analysis ;;
        *KEY_VOLUMEDOWN*) ui_print "•     Completion with the standard config      •" ;;
        *) ui_print "•   timeout - using default configuration...   •" ;;
    esac
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0755
  set_perm $MODPATH/main/tools/* 0 0 0755 0755
  set_perm $MODPATH/system/bin/nextram 0 0 0755 0755
  ui_print "+•[  ;)   ]••••••••••••••••••••••••••••••••••••+"
  ui_print "•    installation completed successfully <3    •"
  ui_print "+••••••••••••••••••••••••••••••••••••••••••••••+"
  open_browser
}
