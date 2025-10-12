#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false
APKDIR="/data/local/tmp/apk"
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
  ui_print "          by @rexamm1t, @matrix_5858"
  ui_print "         tg channel: @rexamm1t_channel"
}

on_install() {
  ui_print "Starting installation"

  ui_print "Architecture: $(uname -m)"
  ui_print "Android: $(getprop ro.build.version.release)"
  ui_print "API: $(getprop ro.build.version.sdk)"
  ui_print "Model: $(getprop ro.product.model)"

  unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH >&2
  conf="/data/adb/modules/$(awk -F= '/^id=/{print $2}' "$CONFIG_FILE")/config.conf"

  if [ -f "$conf" ]; then
   ui_print "config.conf detected, backuping..."
   cp -r $conf $MODPATH
  fi

  ui_print "Extracting files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" '*.sh' -x "install.sh" -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'bin/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'apk/*' -d $MODPATH >&2

  ARCH=$(uname -m)
  case "$ARCH" in
    armv7*)
      DRIVER_SRC="driver/prebuilt/armv7/nextram_driver"
      ui_print "Using ARMv7 driver"
      ;;
    aarch64|armv8*)
      DRIVER_SRC="driver/prebuilt/armv8l/nextram_driver"
      ui_print "Using ARMv8 driver"
      ;;
    *)
      ui_print "WARNING: Unknown architecture $ARCH, trying ARMv8 driver"
      DRIVER_SRC="driver/prebuilt/armv8l/nextram_driver"
      ;;
  esac

  
  ui_print "Extracting driver: $DRIVER_SRC"
  unzip -o "$ZIPFILE" "$DRIVER_SRC" -d $MODPATH >&2
  
  if [ -f "$MODPATH/$DRIVER_SRC" ]; then
    mkdir -p $MODPATH/system/bin
    cp "$MODPATH/$DRIVER_SRC" "$MODPATH/system/bin/nextram_driver"
  else
    ui_print "ERROR: Driver not found at $DRIVER_SRC"
    exit 1
  fi

  if [ ! -f "$MODPATH/system/bin/nextram" ]; then
    ui_print "ERROR: nextram binary not found"
    exit 1
  fi

  if [ ! -f "$MODPATH/system/bin/nextram_driver" ]; then
    ui_print "ERROR: nextram_driver not found"
    exit 1
  fi

  if [ ! -f "$MODPATH/apk/nextram.apk" ]; then
    ui_print "ERROR: nextram.apk not found, skip..."
  else
   
   mkdir $APKDIR
   cp -r $MODPATH/apk/nextram.apk $APKDIR
   unzip -o "$ZIPFILE" 'bin/aapt/*' -d $APKDIR >&2
   chmod 775 $APKDIR/bin/aapt/aapt-$(uname -m)

   if [ -z "$(pm list packages | grep "com.nextram.manager")" ] || ( [ "$(pm dump com.nextram.manager | grep 'versionCode' | grep -o -E '[0-9]+' | head -n 1)" -lt "$($APKDIR/bin/aapt/aapt-$(uname -m) dump badging $APKDIR/nextram.apk | grep "versionCode=" | cut -d"'" -f4)" ]  && [ "$(echo $(pm dump com.nextram.manager | grep 'versionName' | cut -d"=" -f2) > $($APKDIR/bin/aapt/aapt-$(uname -m) dump badging $APKDIR/nextram.apk | grep "versionName=" | cut -d"'" -f6) | bc) -eq 1" ] ); then  
     ui_print "Installing nextram.apk..."
     pm install $APKDIR/nextram.apk >&2 || su -c pm install $APKDIR/nextram.apk >&2
   else
     ui_print "nextram.apk already updated, skip..."
   fi
   rm -rf $APKDIR
  fi
}

set_permissions() {
  set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
  set_perm $MODPATH/system/bin/nextram 0 0 0755
  set_perm $MODPATH/system/bin/nextram_driver 0 0 0755
  set_perm $MODPATH/apk 0 0 0755
  set_perm $MODPATH/main 0 0 0755
  set_perm $MODPATH/main/api_functions.sh 0 0 0755
  set_perm $MODPATH/main/config.sh 0 0 0755
  set_perm $MODPATH/main/kernel_tuning.sh 0 0 0755
  set_perm $MODPATH/main/log.sh 0 0 0755
  set_perm $MODPATH/main/main.sh 0 0 0755
  set_perm $MODPATH/main/api_functions.sh 0 0 0755
  set_perm $MODPATH/main/prerequisites.sh 0 0 0755
  set_perm $MODPATH/main/zram.sh 0 0 0755
  set_perm $MODPATH/main/system_info.sh 0 0 0755
  set_perm $MODPATH/main/swap.sh 0 0 0755
  set_perm $MODPATH/apk/nextram.apk 0 0 0755
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/action.sh 0 0 0755
  set_perm $MODPATH/uninstall.sh 0 0 0755
  ui_print "Installation completed successfully"
}
