![elogo](https://github.com/Rexamm1t/NextRAM/blob/official-public-nextram/githubcfg/nextram-gh-logo.png)
![NextRAM Banner](https://img.shields.io/badge/NextRAM-Smart%20Memory%20Optimization-blue?style=for-the-badge)
![Magisk](https://img.shields.io/badge/Magisk-20.4%2B-00B39B?style=for-the-badge&logo=android)
![Android](https://img.shields.io/badge/Android-8.0%2B-3DDC84?style=for-the-badge&logo=android)
<a href="https://t.me/nextram_official"><img src="https://img.shields.io/badge/Telegram-blue?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram Badge" /></a>

<center><p><a href="https://github.com/Rexamm1t/NextRAM/releases/latest"><img src="https://img.shields.io/github/v/release/Rexamm1t/NextRAM" alt="Latest Release" /></a><a href="https://github.com/Rexamm1t/NextRAM/releases"><img src="https://img.shields.io/github/downloads/Rexamm1t/NextRAM/total" alt="Downloads" /></a></p></center>

# NextRAM - a set of drivers and software for managing zRAM, NextRAM Swapfile, and the Linux kernel.

NextRAM is a sophisticated and powerful multi-functional memory management solution for Android. It intelligently coordinates ZRAM compression, swap management, and kernel parameter tuning in real time, significantly improving device performance and multitasking capabilities.

##Architecture Overview

NextRAM includes five specialized daemons that work together:

- **Main Daemon**: Service orchestration, health monitoring, and configuration management
- **zRAM Service**: Dynamic compression algorithm selection (lz4, zstd, lzo, deflate) and adaptive resizing.
- **NextRAM Swapfile Service**: Device-based circular swapping on ext4 with overhead management and automatic reclamation.
- **Kernel Tuning Service**: Optimize over 15 kernel parameters in real time (swapping, cache load, dirty write ratios, etc.)
- **Global Controller**: A unified command-line interface for system management, monitoring, and profile management.

##Key Features

- **AI-powered optimization**: Adaptive memory tuning based on usage and thermal conditions
- **Multiperformance profiles**: Preset parameters for gaming, power saving, balanced, and performance. Use Cases
- **Process and context awareness**: Per-app optimization and scenario-based tuning
- **Real-time monitoring**: Real-time metrics via sysfs/procfs with detailed reporting
- **Self-healing architecture**: Automatic service recovery and parameter rollback upon failure

##Technical Implementation

- **Language**: C++, C - with standard library and POSIX API
- **Parallelism**: Multithreaded daemons with atomic operations and mutex protection
- **Compatibility**: Android 6.0+ (minimum system requirements may differ from individual requirements) Firmware features) - (Linux kernel 3.1+)

##Performance, Benefits

Documented improvements for several device categories:
- Reduced application startup time by 30–50%
- Increased available memory under load by 60–80%
- Improved multitasking performance by 25% in benchmarks

##License

MIT License - see [LICENSE](LICENSE) for details.
---

**Experience the next level of Android memory optimization with NextRAM - where performance meets intelligence!**
