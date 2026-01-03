![logo](githubcfg/nextram-gh-logo.png)

<div align="center">
<img src="https://img.shields.io/badge/Android-6.0+-3DDC84?style=flat-square&logo=android" />
<img src="https://img.shields.io/badge/Linux-3.1+-FCC624?style=flat-square&logo=linux" />
<img src="https://img.shields.io/badge/Magisk-00B0F0?style=flat-square&logo=android" />
<img src="https://img.shields.io/badge/License-GPLv3-blue?style=flat-square" />
</div>

<div align="center">
<a href="https://t.me/nextram_official">
<img src="https://img.shields.io/badge/Telegram-blue?style=for-the-badge&logo=telegram&logoColor=white" />
</a>
<a href="https://github.com/Rexamm1t/NextRAM/releases">
<img src="https://img.shields.io/github/downloads/Rexamm1t/NextRAM/total?style=for-the-badge" />
</a>
</div>

<div align="center">
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/public-main/docs/README_RU.md">Русский</a>
  </font>
  <font size="2"> | </font>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/public-main/README_EN.md">English</a>
  </font>
  <font size="2"> | </font>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/public-main/docs/README_UK.md">Українська</a>
  </font>
  <font size="2"> | </font>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/public-main/docs/README_ZH.md">中文</a>
  </font>
  <font size="2"> | </font>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/public-main/docs/README_DE.md">Deutsch</a>
  </font>
</div>

# NextRAM - Advanced Memory Management Module

## 简介

NextRAM 是一个功能强大的 Magisk 模块，用于在 Android 设备上进行高级内存管理。该模块提供了增强的 zram 和交换文件功能，以及经过微调的内存参数以优化性能。

## 主要功能

### 内存管理
- **ZRAM**: 压缩 RAM 配置，支持算法选择
- **交换文件**: 创建和管理交换文件
- **自动调优**: 智能内存参数优化
- **动态交换性**: 自适应交换管理

### 系统监控
- **详细统计**: 全面的内存、CPU 和电池信息
- **EMMC 健康**: 内部存储健康监控
- **日志记录**: 完整的模块操作日志
- **系统信息**: 收集设备和系统数据

### 优化
- **内核设置**: 优化 vm.swappiness、cache_pressure、dirty_ratio
- **性能**: 提高系统响应速度
- **能效**: 平衡性能和电池消耗

## 安装

1. 通过 Magisk Manager 或其他 Root 管理器安装模块
2. 重启设备
3. 在 NextRAM 应用或 `config.conf` 文件中配置参数

## 模块管理

- 使用 NextRAM Manager 应用程序进行图形控制
- 编辑 /data/adb/modules/nextram/config.conf 进行手动配置
- 查看 /data/adb/modules/nextram/logs/ 中的日志

## 兼容性

- Android 7.0 及以上
- 支持 Magisk 和 KernelSU
- ARM、ARM64、x86、x86_64 架构
- 需要 Root 权限

## 安全性

该模块在内核级别运行，所需权限最小。所有更改都是可逆的，不影响系统完整性。

## 支持

- Telegram 频道: @nextram_official
- 开发者: @rexamm1t, @matrix_5858, @Alloyd031, @wefol1x, @w3b_0s1nt, @GalaxyFier, @Egor164rus

## 许可证

本模块根据 GPL v3 许可证分发。源代码可在项目仓库中获取。

---

注意：请谨慎使用本模块。配置不当可能影响系统稳定性。