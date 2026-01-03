#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false
APKDIR="/data/local/tmp/apk"
unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH >&2
CONFIG_FILE="$MODPATH/module.prop"

ui_print() {
    echo "- $1"
}

run_aicf_analysis() {
    if [ ! -x "$MODPATH/main/tools/nextramaicf" ]; then
        aicf_print "ERROR: AICF driver not found"
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

print_modname() {
  ui_print " "
  ui_print "   \  |               |     _ \      \      \  |"
  ui_print "    \ |   _ \ \ \  /  __|  |   |    _ \    |\/ |"
  ui_print "  |\  |   __/  \  <   |    __ <    ___ \   |   |"
  ui_print " _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _|"
  ui_print " "
  ui_print "   by @rexamm1t • @matrix_5858 • @galaxyfier"
  ui_print "             @Alloyd031 • @wefol1x "
  ui_print "            @Egor164rus • @w3b_0s1nt"
  ui_print "                  with love <3"
  ui_print "         tg channel: @nextram_official"
  ui_print "   official web site: https://nextram.cocal.ru/ "
}

on_install() {
  ui_print "____________________________________________"
  ui_print "starting installation"
  ui_print "____________________________________________"
  ui_print "NextRAM Version - $(awk -F= '/^version=/{print $2}' "$CONFIG_FILE") ($(awk -F= '/^versionCode=/{print $2}' "$CONFIG_FILE"))"
  ui_print "NextRAM Status  - $(awk -F= '/^status=/{print $2}' "$CONFIG_FILE")"
  ui_print "NextRAM ModName  - $(awk -F= '/^modname=/{print $2}' "$CONFIG_FILE")"
  ui_print "____________________________________________"
  ui_print "arch   : $(uname -m)"
  ui_print "android: $(getprop ro.build.version.release)"
  ui_print "linux  : $(uname -r)"
  ui_print "API    : $(getprop ro.build.version.sdk)"
  ui_print "model  : $(getprop ro.product.model)"
  ui_print "____________________________________________"

  conf="/data/adb/modules/$(awk -F= '/^id=/{print $2}' "$CONFIG_FILE")/config.conf"
 
  if [ -f "$conf" ]; then
   ui_print "config.conf detected, backuping..."
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
    '

    if [ -f "/data/adb/modules/NextRAM/common/post-fs-data.sh" ] || [ -f "/data/adb/modules/NextRAM/post-fs-data.sh" ] && [ ! -f "$conf" ]; then
               ui_print "NextRAM 3.0+ config detected, migrating to config.conf..."
    elif [ -f "/data/adb/modules/NextRAM/service.sh" ] && [ ! -f "$conf" ]; then
                ui_print "NextRAM 6.0+ config detected, migrating to config.conf..."
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

  ui_print "extracting files..."
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" '*.sh' -x "install.sh build_tools.sh" -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'apk/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'tools/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'status_gt' -d $MODPATH >&2
  
  chmod 0755 $MODPATH/tools/* 2>/dev/null

  if [ ! -f "$MODPATH/system/bin/nextram" ]; then
    ui_print "ERROR: nextram binary not found"
    exit 1
  fi

  if [ ! -f "$MODPATH/apk/nextram.apk" ]; then
    ui_print "ERROR: nextram.apk not found, skip..."
  else
   mkdir -p $APKDIR
   cp -r $MODPATH/apk/nextram.apk $APKDIR
   unzip -o "$ZIPFILE" 'apk/bin/aapt/*' -d $APKDIR >&2
   chmod 775 $APKDIR/apk/bin/aapt/aapt-$(uname -m)

   if [ -z "$(pm list packages | grep "com.nextram.manager")" ]; then  
     ui_print "installing nextram.apk..."
     pm install $APKDIR/nextram.apk >&2 || su -c pm install $APKDIR/nextram.apk >&2
   else
     ui_print "nextram.apk already exists, updating..."
     
     pm install -r $APKDIR/nextram.apk >&2 || su -c pm install -r $APKDIR/nextram.apk >&2
     
     if [ $? -ne 0 ]; then
         ui_print "update failed, uninstalling old version..."
         pm uninstall com.nextram.manager >&2 || su -c pm uninstall com.nextram.manager >&2
         ui_print "installing new version..."
         pm install $APKDIR/nextram.apk >&2 || su -c pm install $APKDIR/nextram.apk >&2
     fi
   fi
   rm -rf $APKDIR
  fi

  ui_print "Generate a configuration file for your device?"
  ui_print "Vol (+) - Yes (beta, not beautiful) "
  ui_print "Vol (-) - No (standard cfg, existing)"
  ui_print "waiting for 15 seconds..."

  timeout_seconds=15
  line="$(timeout $timeout_seconds getevent -ql 2>/dev/null | grep -m1 -E "KEY_VOLUME(UP|DOWN)")"
    
  case "$line" in
        *KEY_VOLUMEUP*)   run_aicf_analysis ;;
        *KEY_VOLUMEDOWN*) ui_print "Completion with the standard config" ;;
        *) ui_print " "
           ui_print "timeout - using default configuration..." ;;
    esac
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0755
  set_perm $MODPATH/tools/* 0 0 0755 0755
  set_perm $MODPATH/system/bin/nextram 0 0 0755 0755
  set_perm $MODPATH/status_gt 0 0 0755 0755
  ui_print "installation completed successfully <3"
  open_browser
}
