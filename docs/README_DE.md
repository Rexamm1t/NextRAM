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

## Beschreibung

NextRAM ist ein leistungsstarkes Magisk-Modul für erweiterte Speicherverwaltung auf Android-Geräten. Das Modul bietet erweiterte zRAM- und Swap-Datei-Funktionen sowie fein abgestimmte Speicherparameter zur Leistungsoptimierung.

## Hauptmerkmale

### Speicherverwaltung
- **ZRAM**: Komprimierte RAM-Konfiguration mit Algorithmusauswahl
- **Swap-Dateien**: Erstellung und Verwaltung von Swap-Dateien
- **Automatische Optimierung**: Intelligente Optimierung von Speicherparametern
- **Dynamische Swappiness**: Adaptive Swap-Verwaltung

### Systemüberwachung
- **Detaillierte Statistiken**: Umfassende Informationen zu Speicher, CPU und Akku
- **EMMC-Gesundheit**: Überwachung der internen Speichergesundheit
- **Protokollierung**: Vollständige Protokollierung der Modulaktivität
- **Systeminformationen**: Erfassung von Geräte- und Systemdaten

### Optimierung
- **Kernel-Einstellungen**: Optimierung von vm.swappiness, cache_pressure, dirty_ratio
- **Leistung**: Verbesserte Systemreaktionsfähigkeit
- **Energieeffizienz**: Balance zwischen Leistung und Akkuverbrauch

## Installation

1. Installieren Sie das Modul über Magisk Manager oder einen anderen Root-Manager
2. Starten Sie Ihr Gerät neu
3. Konfigurieren Sie die Parameter in der NextRAM-App oder der `config.conf`-Datei

## Modulverwaltung

· Verwenden Sie die NextRAM Manager-App zur grafischen Steuerung
· Bearbeiten Sie /data/adb/modules/nextram/config.conf zur manuellen Konfiguration
· Protokolle einsehen unter /data/adb/modules/nextram/logs/

## Kompatibilität

· Android 7.0 und höher
· Unterstützung für Magisk und KernelSU
· ARM, ARM64, x86, x86_64 Architekturen
· Root-Zugang erforderlich

## Sicherheit

Das Modul arbeitet auf Kernel-Ebene mit minimalen Berechtigungen. Alle Änderungen sind reversibel und beeinträchtigen die Systemintegrität nicht.

## Unterstützung

· Telegram-Kanal: @nextram_official
· Entwickler: @rexamm1t, @matrix_5858, @Alloyd031, @wefol1x, @w3b_0s1nt, @GalaxyFier, @Egor164rus, @weutqsz, @DRNv51

## Lizenz

Das Modul wird unter der GPL v3-Lizenz vertrieben. Der Quellcode ist im Projekt-Repository verfügbar.

---

Hinweis: Verwenden Sie das Modul mit Vorsicht. Falsche Konfiguration kann die Systemstabilität beeinträchtigen.
