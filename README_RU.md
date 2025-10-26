![elogo](https://github.com/Rexamm1t/NextRAM/blob/official-public-nextram/githubcfg/nextram-gh-logo.png)
![NextRAM Banner](https://img.shields.io/badge/NextRAM-Smart%20Memory%20Optimization-blue?style=for-the-badge)
![Android](https://img.shields.io/badge/Android-6.0%2B-3DDC84?style=for-the-badge&logo=android)
![Linux](https://img.shields.io/badge/Linux-3.1%2B-3DDC84?style=for-the-badge&logo=linux)
<a href="https://t.me/nextram_official"><img src="https://img.shields.io/badge/Telegram-blue?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram Badge" /></a>

<center><p><a href="https://github.com/Rexamm1t/NextRAM/releases/latest"><img src="https://img.shields.io/github/v/release/Rexamm1t/NextRAM" alt="Latest Release" /></a><a href="https://github.com/Rexamm1t/NextRAM/releases"><img src="https://img.shields.io/github/downloads/Rexamm1t/NextRAM/total" alt="Downloads" /></a></p></center>

<center>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/official-public-nextram/README_RU.md">
      Русский
    </a>
  </font>
  <font size="2">
    |
  </font>
  <font size="2">
    <a href="https://github.com/Rexamm1t/NextRAM/blob/official-public-nextram/README_EN.md">
      Английский
    </a>
  </font>
</center>

# NextRAM - набор драйверов и ПО для управления zRAM, NextRAM Swapfile и ядра Linux. 
 
NextRAM — это сложное и мощное многофункциональное решение для управления памятью на Android. Оно интеллектуально координирует сжатие ZRAM, управление подкачкой и настройку параметров ядра в реальном времени, значительно повышая производительность устройства и возможности многозадачности.

## Обзор архитектуры

NextRAM включает пять специализированных демонов, работающих совместно:

- **Основной демон**: оркестровка сервисов, мониторинг работоспособности и управление конфигурацией
- **Сервис zRAM**: динамический выбор алгоритма сжатия (lz4, zstd, lzo, deflate) и адаптивное изменение размера.
- **Сервис NextRAM Swapfile**: циклическая подкачка на базе устройства в ext4 с управлением накладных расходов и автоматическим восстановлением.
- **Сервис настройки ядра**: оптимизация более 15 параметров ядра в режиме реального времени (подкачка, нагрузка на кэш, коэффициенты грязных записей и т. д.)
- **Глобальный контроллер**: унифицированный интерфейс командной строки для управления системой, мониторинга и управления профилями.

## Основные функции

- **Оптимизация на основе ИИ**: адаптивная настройка памяти на основе использования и температурных условий
- **Профили многопроизводительности**: предустановленные параметры для игр, энергосбережения, сбалансированного режима и производительности Примеры использования
- **Осведомленность о процессах и контексте**: оптимизация для каждого приложения и настройка на основе сценариев
- **Мониторинг в реальном времени**: метрики в реальном времени через sysfs/procfs с подробными отчётами
- **Архитектура самовосстановления**: автоматическое восстановление служб и откат параметров при сбоях

## Техническая реализация

- **Язык**: C++, C - со стандартной библиотекой и API POSIX
- **Параллелизм**: многопоточные демоны с атомарными операциями и защитой мьютексов
- **Совместимость**: Android 6.0+ (минимальные системные требования могут не совпадать с индивидуальными особенностями прошивок) - (ядро Linux 3.1+)

## Производительность, преимущества

Задокументированные улучшения для нескольких категорий устройств:
- Сокращение времени запуска приложений на 30–50%
- Увеличение объёма доступной памяти под нагрузкой на 60–80%
- Повышение производительности многозадачности на 25% в тестах производительности

## Лицензия

Лицензия MIT — подробности см. в [лицензии](LICENSE).
