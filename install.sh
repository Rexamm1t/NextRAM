#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false


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

  ui_print "Extracting files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'webroot/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" '*.sh' -x "install.sh" -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'bin/*' -d $MODPATH >&2

  if [ ! -f "$MODPATH/system/bin/nextram" ]; then
    ui_print "ERROR: nextram binary not found"
    exit 1
  fi
}

set_permissions() {
  set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
  set_perm $MODPATH/system/bin/nextram 0 0 0755
  set_perm $MODPATH/bin 0 0 0755
  set_perm $MODPATH/bin/toybox 0 0 0755
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/action.sh 0 0 0755
  set_perm $MODPATH/uninstall.sh 0 0 0755
  set_perm $MODPATH/webroot 0 0 0755
  set_perm $MODPATH/webroot/index.html 0 0 0755
  ui_print "Installation completed successfully"
}
