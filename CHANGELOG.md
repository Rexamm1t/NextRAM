## NextRAM v8.3.201-pre(83201p)
[INSTALL]

- adding support for older configurations (almost NextRAM 2+) 
- adding new options to the config when they are missing

[MAIN]
 
- fix swapoff options

[KERNEL]

- Smart dynamic swappiness tuning based on memory size, ZRAM usage, and current swap utilization
- Extended memory parameters - min_free_kbytes, watermark_scale_factor, OOM settings
- Dual operation modes - performance (aggressive) and power-saving (balanced)
- Settings verification with success rate checking
- Safe handling - file availability checks before writing
- Detailed logging of each modified parameter
___
Telegram: https://t.me/nextram_official
