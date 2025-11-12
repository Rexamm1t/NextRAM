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


print_modname() {
  ui_print "   \  |               |     _ \      \      \  |"
  ui_print "    \ |   _ \ \ \  /  __|  |   |    _ \    |\/ |"
  ui_print "  |\  |   __/  \  <   |    __ <    ___ \   |   |"
  ui_print " _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _|"
  ui_print " "
  ui_print "          by @rexamm1t • @matrix_5858"
  ui_print "      @Alloyd031 • @wefol1x • @w3b_0s1nt"
  ui_print "         tg channel: @nextram_official"
}

on_install() {
  ui_print " "
  ui_print "Starting installation"

  
  ui_print "NextRAM Version - $(awk -F= '/^version=/{print $2}' "$CONFIG_FILE") ($(awk -F= '/^versionCode=/{print $2}' "$CONFIG_FILE"))"
  ui_print "Architecture: $(uname -m)"
  ui_print "Android: $(getprop ro.build.version.release)"
  ui_print "Linux: $(uname -r)"
  ui_print "API: $(getprop ro.build.version.sdk)"
  ui_print "Model: $(getprop ro.product.model)"

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
    ZRAM_RATIO:2.56
    ZRAM_ALGORITHM:lz4
    MAX_COMP_STREAMS:6
    SWAPPINESS:90
    CACHE_PRESSURE:34
    DIRTY_RATIO:24
    DIRTY_BACKGROUND_RATIO:8
    EXTRA_TUNING:false
    DYNAMIC_SWAPPINESS:false
    PERFORMANCE_MODE:false
    ZRAM_AUTO_TUNE:false
    LOG_LEVEL:"INFO"
    '

    if [ -f "/data/adb/modules/NextRAM/common/post-fs-data.sh" ] || ( [ -f "/data/adb/modules/NextRAM/post-fs-data.sh" ] ) && [ ! -f "$conf" ]; then
               ui_print "NextRAM 3.0+ (post-fs-data.sh) config detected, migrating to config.conf..."
    elif [ -f "/data/adb/modules/NextRAM/service.sh" ] && [ ! -f "$conf" ]; then
                ui_print "NextRAM 6.0+ (service.sh) config detected, migrating to config.conf..."
    fi

    for var in $LIST_VAR; do
        variable="${var%%:*}"
        value="${var#*:}"


        if [ -f "/data/adb/modules/NextRAM/common/post-fs-data.sh" ] || ( [ -f "/data/adb/modules/NextRAM/post-fs-data.sh" ] ) && [ ! -f "$conf" ]; then
               grep -m 1 "${var%%:*}" "/data/adb/modules/NextRAM/post-fs.data.sh" >> $MODPATH/config.conf
               grep -m 1 "${var%%:*}" "/data/adb/modules/NextRAM/common/post-fs.data.sh" >> $MODPATH/config.conf
        elif [ -f "/data/adb/modules/NextRAM/service.sh" ] && [ ! -f "$conf" ]; then
                grep -m 1 "${var%%:*}" "/data/adb/modules/NextRAM/service.sh" >> $MODPATH/config.conf
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

  ui_print "Extracting files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" '*.sh' -x "install.sh" -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'apk/*' -d $MODPATH >&2


  if [ ! -f "$MODPATH/system/bin/nextram" ]; then
    ui_print "ERROR: nextram binary not found"
    exit 1
  fi

  if [ ! -f "$MODPATH/apk/nextram.apk" ]; then
    ui_print "ERROR: nextram.apk not found, skip..."
  else
   
   mkdir $APKDIR
   cp -r $MODPATH/apk/nextram.apk $APKDIR
   unzip -o "$ZIPFILE" 'apk/bin/aapt/*' -d $APKDIR >&2
   chmod 775 $APKDIR/apk/bin/aapt/aapt-$(uname -m)

   if [ -z "$(pm list packages | grep "com.nextram.manager")" ] || ( [ "$(pm dump com.nextram.manager | grep 'versionCode' | grep -o -E '[0-9]+' | head -n 1)" -lt "$($APKDIR/apk/bin/aapt/aapt-$(uname -m) dump badging $APKDIR/nextram.apk | grep "versionCode=" | cut -d"'" -f4)" ]  && [ "$(echo $(pm dump com.nrf.manager | grep 'versionName' | cut -d"=" -f2) > $($APKDIR/apk/bin/aapt/aapt-$(uname -m) dump badging $APKDIR/nextram.apk | grep "versionName=" | cut -d"'" -f6) | bc) -eq 1" ] ); then  
     ui_print "Installing nextram.apk..."
     pm install $APKDIR/nextram.apk >&2 || su -c pm install $APKDIR/nextram.apk >&2
   else
     ui_print "nextram.apk already updated, skip..."
   fi
   rm -rf $APKDIR
  fi
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0755
  ui_print "Installation completed successfully"
}
