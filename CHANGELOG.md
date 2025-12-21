## NextRAM Fusion v9.1.371-(91371)

**[INSTALL]**
- fixed timeout
___
Telegram: https://t.me/nextram_official
Web Site: https://nextram.cocal.ru
___

## NextRAM Fusion v9.1.280-(91280)

**[CODE OPTIMIZATION]**
- Enhanced file permission verification before writing kernel parameters
- Added comprehensive file and directory existence checks
- Optimized error handling routines throughout all scripts
- Streamlined loop structures and conditional statements
- Improved code maintainability while preserving original functionality

**[STABILITY ENHANCEMENTS]**
- Fixed potentially unsafe script constructs
- Added thorough system utility availability validation
- Enhanced device compatibility across different Android implementations
- Improved swap file creation error handling
- Strengthened file access permission verifications

**[ZRAM IMPROVEMENTS]**
- Advanced zram device detection with dual-path checking
- Added safety checks before zram reset operations
- Enhanced compression algorithm selection error handling
- Implemented /sys/block/zram0 directory validation
- Refined compression stream parameter management

**[KERNEL TUNING SYSTEM]**
- Upgraded kernel parameter application with verification layer
- Implemented comprehensive tuning success monitoring
- Enhanced dynamic swappiness algorithm with multi-factor calculations
- Introduced safe parameter setting functions (set_param, set_sysctl)
- Added write capability verification before file operations

**[PERFORMANCE OPTIMIZATION]**
- Reduced script execution overhead through code refinement
- Minimized redundant file system operations
- Optimized I/O operations during swap configuration
- Enhanced script execution efficiency

**[COMPATIBILITY UPDATES]**
- Expanded Android version and Linux kernel compatibility
- Improved operation on low-resource devices
- Added legacy kernel support checks
- Enhanced filesystem type compatibility

**[API ENHANCEMENTS]**
- Improved web interface stability and responsiveness
- Fixed configuration management edge cases
- Enhanced API command parsing and execution
- Added configuration change validation

**[MONITORING SYSTEM]**
- Upgraded memory and zram monitoring architecture
- Added comprehensive device state verification
- Fixed resource leakage in background monitoring
- Enhanced monitoring process management

___
Telegram: https://t.me/nextram_official
Web Site: https://nextram.cocal.ru
___

## NextRAM v9.0.127(90127)
[INSTALL]
- added time-out when selecting the configuration method
___
Telegram: https://t.me/nextram_official
Web Site: https://nextram.cocal.ru
___

## NextRAM v9.0.000(90000) 
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
