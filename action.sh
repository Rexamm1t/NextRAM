#!/system/bin/sh
LOG_DIR="$MODDIR/logs"
MODULE_VERSION=$(awk -F= '/^version=/{print $2}' "/data/adb/modules/NextRAM/module.prop")
echo "    \  |               |     _ \      \      \  | "
echo "     \ |   _ \ \ \  /  __|  |   |    _ \    |\/ | "
echo "   |\  |   __/  \  <   |    __ <    ___ \   |   | "
echo "  _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _| "
echo "press volume (+) (open nlive) or volume (-) (log)"
echo "Welcome to action mode!"
echo "NextRAM $MODULE_VERSION"

open_live_monitor() {
	echo ""
	echo "→ open live monitor..."
	su -c "bash /data/adb/modules/NextRAM/action/sysinfo.sh"
	echo " "
	echo "✓ Operation completed!"
}


open_log() {
	echo ""
	echo "→ open logs file..."
   	su -c "bash /data/adb/modules/NextRAM/action/livelog.sh"
	echo " "
	echo "✓ Operation completed!"
}

echo ""
echo "Waiting for input..."
while true; do
	event=$(getevent -qlc 1 2>/dev/null)
	if echo "$event" | grep -q "KEY_VOLUMEUP"; then
		open_live_monitor
		break
	elif echo "$event" | grep -q "KEY_VOLUMEDOWN"; then
		open_log
		break
	fi
done
