![logo](githubcfg/nextram-gh-logo.png)
![NextRAM Banner](https://img.shields.io/badge/NextRAM-Smart%20Memory%20Optimization-blue?style=for-the-badge)
![Android](https://img.shields.io/badge/Android-6.0%2B-3DDC84?style=for-the-badge&logo=android)
![Linux](https://img.shields.io/badge/Linux-3.1%2B-3DDC84?style=for-the-badge&logo=linux)
<a href="https://t.me/nextram_official"><img src="https://img.shields.io/badge/Telegram-blue?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram Badge" /></a>

<center><p><a href="https://github.com/Rexamm1t/NextRAM/releases"><img src="https://img.shields.io/github/downloads/Rexamm1t/NextRAM/total" alt="Downloads" /></a></p></center>

<center>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/public-main/README_RU.md">
      Russian
    </a>
  </font>
  <font size="2">
    |
  </font>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/public-main/README.md">
      English
    </a>
  </font>
</center>


# NextRAM - Advanced Memory Management Module

## Description

NextRAM is a powerful Magisk module for advanced memory management on Android devices. The module provides enhanced zram and swap file capabilities along with fine-tuned memory parameters for performance optimization.

## Key Features

### Memory Management
- **ZRAM**: Compressed RAM configuration with algorithm selection
- **Swap Files**: Creation and management of swap files
- **Auto-tuning**: Intelligent memory parameter optimization
- **Dynamic Swappiness**: Adaptive swap management

### System Monitoring
- **Detailed Statistics**: Comprehensive memory, CPU, and battery information
- **EMMC Health**: Internal storage health monitoring
- **Logging**: Complete module operation logging
- **System Information**: Device and system data collection

### Optimization
- **Kernel Settings**: Optimization of vm.swappiness, cache_pressure, dirty_ratio
- **Performance**: Improved system responsiveness
- **Power Efficiency**: Balance between performance and battery consumption

## Installation

1. Install the module via Magisk Manager/Other Root Manager
2. Reboot your device
3. Configure parameters in NextRAM App or `config.conf` file

## Module Management

- Use NextRAM Manager app for graphical control
- Edit /data/adb/modules/nextram/config.conf for manual configuration
- View logs in /data/adb/modules/nextram/logs/

## Compatibility

- Android 7.0 and higher
- Magisk and KernelSU support
- ARM, ARM64, x86, x86_64 architectures
- Root access required

## Security

The module operates at kernel level with minimal permissions. All changes are reversible and don't affect system integrity.

## Support

- Telegram channel: @nextram_official
- Developers: @rexamm1t, @matrix_5858, @Alloyd031, @wefol1x, @w3b_0s1nt

## License

Module is distributed under GPL v3 license. Source code is available in project repository.

---

Note: Use the module with caution. Incorrect configuration may affect system stability.

