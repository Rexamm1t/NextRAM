#!/system/bin/sh

MODDIR=${0%/*}
ZRAM_DEV="/dev/block/zram0"
ZRAM_SYS="/sys/block/zram0"
CONFIG_FILE="/data/adb/modules/NextRAM/module.prop"
SWAP_FILE="/data/adb/modules/NextRAM/swapfile_mount/swapfile"

get_module_info() {
  MODULE_DESCRIPTION=$(awk -F= '/^description=/{print $2}' "$CONFIG_FILE")
}

get_system_info() {
  DEVICE_MODEL=$(getprop ro.product.model)
  DEVICE_BRAND=$(getprop ro.product.brand)
  ANDROID_VERSION=$(getprop ro.build.version.release)
  BUILD_ID=$(getprop ro.build.id)
  KERNEL_VERSION=$(uname -r)
  SECURITY_PATCH=$(getprop ro.build.version.security_patch)
  FALLOCATE_AVAILABLE="unavailable"
  if command -v fallocate >/dev/null 2>&1; then
    FALLOCATE_AVAILABLE="available"
  fi
}

get_memory_stats() {
  read -r TOTAL_RAM AVAILABLE_RAM <<EOF
$(awk '
/MemTotal/ {total=$2}
/MemAvailable/ {avail=$2}
END {printf "%d %d", total/1024, avail/1024}
' /proc/meminfo)
EOF

  RAM_USAGE=$((100 - (AVAILABLE_RAM * 100 / TOTAL_RAM)))
  SWAPPINESS=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "N/A")
  CACHE_PRESSURE=$(cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null || echo "N/A")
  LOW_MEM_KILLER=$(cat /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null || echo "N/A")

  if [ -b "$ZRAM_DEV" ] && [ -f "$ZRAM_SYS/mm_stat" ]; then
    ZRAM_ALGO=$(tr -d '[:space:]' < "$ZRAM_SYS/comp_algorithm" | awk -F'[][]' '{print $2}')
    ZRAM_SIZE=$(awk '{printf "%.1f", $1/1048576}' "$ZRAM_SYS/disksize")
    COMP_STREAMS=$(cat "$ZRAM_SYS/max_comp_streams" 2>/dev/null || echo "N/A")

    read -r ZRAM_ORIG ZRAM_COMP ZRAM_USED <<EOF
$(awk '{printf "%.1f %.1f %.1f", $1/1048576, $2/1048576, $3/1048576}' "$ZRAM_SYS/mm_stat")
EOF

    if [ "$ZRAM_COMP" != "0.0" ] && [ "$(echo "$ZRAM_COMP > 0" | awk '$1 > 0 {print 1}')" = "1" ]; then
      COMP_RATIO=$(awk "BEGIN {printf \"%.2f\", $ZRAM_ORIG/$ZRAM_COMP}")
    else
      COMP_RATIO="0.00"
    fi
    ZRAM_ENABLED=true
  else
    ZRAM_ENABLED=false
  fi

  SWAP_TOTAL=0
  SWAP_USED=0
  SWAP_ZRAM_SIZE=0
  SWAP_ZRAM_USED=0
  SWAP_FILE_SIZE=0
  SWAP_FILE_USED=0
  SWAP_OTHER_SIZE=0
  SWAP_OTHER_USED=0

  while read -r filename type size used _; do
    swap_size=$((size/1024))
    swap_used=$((used/1024))
    SWAP_TOTAL=$((SWAP_TOTAL + swap_size))
    SWAP_USED=$((SWAP_USED + swap_used))

    case "$filename" in
      "$ZRAM_DEV")
        SWAP_ZRAM_SIZE=$swap_size
        SWAP_ZRAM_USED=$swap_used
        ;;
      "$SWAP_FILE")
        SWAP_FILE_SIZE=$swap_size
        SWAP_FILE_USED=$swap_used
        ;;
      *)
        SWAP_OTHER_SIZE=$((SWAP_OTHER_SIZE + swap_size))
        SWAP_OTHER_USED=$((SWAP_OTHER_USED + swap_used))
        ;;
    esac
  done < /proc/swaps

  SWAP_PERCENT=$([ "$SWAP_TOTAL" -gt 0 ] && echo $((SWAP_USED * 100 / SWAP_TOTAL)) || echo 0)
  SWAP_FILE_ACTUAL_SIZE=$([ -f "$SWAP_FILE" ] && stat -c %s "$SWAP_FILE" 2>/dev/null | awk '{printf "%.1f", $1/1048576}' || echo "0.0")
}

get_cpu_stats() {
  CPU_CORES=$(grep -c ^processor /proc/cpuinfo)
  CPU_MODEL=$(awk -F': ' '/Hardware/{print $2}' /proc/cpuinfo | head -n1)
  if [ -z "$CPU_MODEL" ]; then
    CPU_MODEL=$(getprop ro.board.platform)
  fi
  CPU_ARCH=$(uname -m)
}

get_storage_info() {
  INTERNAL_STORAGE=$(df -h /data | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')
  SYSTEM_STORAGE=$(df -h /system | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')

  EMMC_HEALTH=""
  LIFE_TIME_A=""
  LIFE_TIME_B=""
  EMMC_MODEL=""
  EMMC_SERIAL=""
  EMMC_LIFE_PERCENT="N/A"

  for block in mmcblk0 mmcblk1; do
    if [ -d "/sys/block/$block" ]; then
      if [ -f "/sys/block/$block/device/name" ]; then
        EMMC_MODEL=$(cat "/sys/block/$block/device/name")
      fi

      if [ -f "/sys/block/$block/device/serial" ]; then
        EMMC_SERIAL=$(cat "/sys/block/$block/device/serial")
      fi

      if [ -f "/sys/block/$block/device/pre_eol_info" ]; then
        EMMC_HEALTH=$(cat "/sys/block/$block/device/pre_eol_info")
        case $EMMC_HEALTH in
          "0x01") 
            EMMC_HEALTH="Normal (0x01)"
            EMMC_LIFE_PERCENT="100%"
            ;;
          "0x02") 
            EMMC_HEALTH="Warning (0x02)"
            EMMC_LIFE_PERCENT="80%"
            ;;
          "0x03") 
            EMMC_HEALTH="Urgent (0x03)"
            EMMC_LIFE_PERCENT="60%"
            ;;
          *) 
            EMMC_HEALTH="Unknown ($EMMC_HEALTH)"
            EMMC_LIFE_PERCENT="N/A"
            ;;
        esac
      fi

      if [ -f "/sys/block/$block/device/life_time" ]; then
        read -r LIFE_TIME_A LIFE_TIME_B <<EOF
$(cat "/sys/block/$block/device/life_time")
EOF

        if [ "$LIFE_TIME_A" != "0x00" ] && [ "$LIFE_TIME_B" != "0x00" ]; then
          LIFE_A_DEC=$(( $(printf "%d" "$LIFE_TIME_A") ))
          LIFE_B_DEC=$(( $(printf "%d" "$LIFE_TIME_B") ))

          if [ $LIFE_A_DEC -gt 0 ] && [ $LIFE_B_DEC -gt 0 ]; then
            LIFE_PERCENT=$(( 100 - (LIFE_A_DEC > LIFE_B_DEC ? LIFE_A_DEC : LIFE_B_DEC) * 10 ))
            EMMC_LIFE_PERCENT="$LIFE_PERCENT%"
          fi
        fi
      fi

      break
    fi
  done
}

generate_output() {
  echo "NextRAM Live"
  echo "=[HOME]===========================NextRAM="
  echo " Device:    $DEVICE_BRAND $DEVICE_MODEL"
  echo " Android:   $ANDROID_VERSION ($SECURITY_PATCH)"
  echo " Kernel:    $KERNEL_VERSION"
  echo " Build:     $BUILD_ID"
  echo "=[MEMORY]=========================NextRAM="
  echo " Total RAM:         ${TOTAL_RAM}MB"
  echo " Available:         ${AVAILABLE_RAM}MB"
  echo " RAM Usage:         ${RAM_USAGE}%"
  echo " Swappiness:        $SWAPPINESS"
  echo " Cache Pressure:    $CACHE_PRESSURE"
  [ "$LOW_MEM_KILLER" != "N/A" ] && echo " Low Memory Killer: $LOW_MEM_KILLER"
  if $ZRAM_ENABLED; then
    echo "=[zRAM]===========================NextRAM="
    echo " Algorithm:          $ZRAM_ALGO"
    echo " Size:               ${ZRAM_SIZE}MB"
    echo " Used:               ${ZRAM_USED}MB"
    echo " Compression Ratio:  ${COMP_RATIO}x"
    echo " Original Data:      ${ZRAM_ORIG}MB"
    echo " Compressed Data:    ${ZRAM_COMP}MB"
    echo " Compression Streams: $COMP_STREAMS"
  fi
  echo "=[SWAP]===========================NextRAM="
  echo " Total Swap:        ${SWAP_TOTAL}MB"
  echo " Used Swap:         ${SWAP_USED}MB"
  echo " Swap Usage:        ${SWAP_PERCENT}%"

  echo " "
  if [ "$SWAP_ZRAM_SIZE" -gt 0 ]; then
    zram_usage=$([ "$SWAP_ZRAM_SIZE" -gt 0 ] && echo $((SWAP_ZRAM_USED * 100 / SWAP_ZRAM_SIZE)) || echo 0)
    echo " ZRAM:              ${SWAP_ZRAM_USED}MB / ${SWAP_ZRAM_SIZE}MB (${zram_usage}%)"
  fi

  if [ "$SWAP_FILE_SIZE" -gt 0 ]; then
    file_usage=$([ "$SWAP_FILE_SIZE" -gt 0 ] && echo $((SWAP_FILE_USED * 100 / SWAP_FILE_SIZE)) || echo 0)
    echo " Swapfile:          ${SWAP_FILE_USED}MB / ${SWAP_FILE_SIZE}MB (${file_usage}%)"
    echo " File Size:         ${SWAP_FILE_ACTUAL_SIZE}MB"
    echo " Creation Method:   $FALLOCATE_AVAILABLE"
  fi

  if [ "$SWAP_OTHER_SIZE" -gt 0 ]; then
    other_usage=$([ "$SWAP_OTHER_SIZE" -gt 0 ] && echo $((SWAP_OTHER_USED * 100 / SWAP_OTHER_SIZE)) || echo 0)
    echo " NextRAM Swapfile:  ${SWAP_OTHER_USED}MB / ${SWAP_OTHER_SIZE}MB (${other_usage}%)"
  fi

  echo "=[CPU]============================NextRAM="
  echo " Model:             $CPU_MODEL"
  echo " Architecture:      $CPU_ARCH"
  echo " Cores:             $CPU_CORES"
  echo "=[STORAGE]========================NextRAM="
  echo " Internal Storage:   $INTERNAL_STORAGE"
  echo " System Storage:     $SYSTEM_STORAGE"

  if [ -n "$EMMC_MODEL" ]; then
    echo "=[eMMC]===========================NextRAM="
    echo " Model:              $EMMC_MODEL"
    [ -n "$EMMC_SERIAL" ] && echo " Serial:             $EMMC_SERIAL"
    [ -n "$EMMC_HEALTH" ] && echo " Health Status:      $EMMC_HEALTH"
    echo " Life Percentage:    $EMMC_LIFE_PERCENT"
    echo ""
  fi
  echo "=========================================="
  echo "Generated: $(date)"
  echo "=========================================="
}

main() {
  get_module_info
  get_system_info
  get_memory_stats
  get_cpu_stats
  get_storage_info
  generate_output
}

main

exit 0