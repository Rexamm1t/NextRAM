## NextRAM v9.0.000(00000) 
[NRAICF] (beta)
- added the first C++ tool for NextRAM. It generates a configuration for the device

[MAIN]
- major corrections in the code
- added new settings to the configuration file regarding the kernel
- zRAM fixes...

[APK]
- completely updated the interface - Material 3
- switches have been added for new parameters
- improved existing themes
- added new translations: Chinese and Ukrainian
- added help for each parameter with translation
- fixed switching color scheme

[INSTALL]
- update information
- added new logic (NRAICF)

[ACTION]
- fixed the display of nlive and logs
___
Telegram: https://t.me/nextram_official
Web Site: https://nextram.cocal.ru
___

## NextRAM v8.5.638(85638)
[ACTION]
- reworked the logic of the "Action" button in root managers

[APK]
- update NextRAM App - 8.4.201-fix (84201)

[zRAM]
- fix settings - maximum compression streams
- other improvements to the code
___
Telegram: https://t.me/nextram_official
___

## NextRAM v8.4.201-fix(84201)
[KERNEL]
- fix tuning scripts
- fix slowed charge

[zRAM]
- fix zRAM custom size (4G?)
- bugfixes
___
Telegram: https://t.me/nextram_official
___
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
