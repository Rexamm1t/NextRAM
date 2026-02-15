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

## Описание

NextRAM — это мощный модуль Magisk для расширенного управления памятью Android-устройств. Модуль предоставляет улучшенные возможности работы с zram, swap-файлами и тонкую настройку параметров памяти для оптимизации производительности.

## Основные возможности

### Управление памятью
- **ZRAM**: Настройка сжатой оперативной памяти с выбором алгоритмов
- **Swap-файлы**: Создание и управление файлами подкачки
- **Автоматическая настройка**: Интеллектуальная оптимизация параметров памяти
- **Динамический swappiness**: Адаптивное управление подкачкой

### Мониторинг системы
- **Детальная статистика**: Подробная информация о памяти, CPU, батарее
- **Здоровье EMMC**: Мониторинг состояния внутренней памяти
- **Логирование**: Полное ведение логов работы модуля
- **Системная информация**: Сбор данных об устройстве и системе

### Оптимизация
- **Настройки ядра**: Оптимизация vm.swappiness, cache_pressure, dirty_ratio
- **Производительность**: Улучшение отзывчивости системы
- **Энергоэффективность**: Баланс между производительностью и расходом батареи

## Установка

1. Установите модуль через Magisk Manager или в другом рут менеджере
2. Перезагрузите устройство
3. Настройте параметры в приложении NextRAM или файле `config.conf`

## Управление модулем

· Используйте приложение NextRAM Manager для графического управления
· Редактируйте /data/adb/modules/nextram/config.conf для ручной настройки
· Просматривайте логи в /data/adb/modules/nextram/logs/

## Совместимость

· Android 7.0 и выше
· Поддержка Magisk и KernelSU
· ARM, ARM64, x86, x86_64 архитектуры
· Требуется root-доступ

## Безопасность

Модуль работает на уровне ядра и требует минимальных разрешений. Все изменения обратимы и не влияют на целостность системы.

## Поддержка

· Telegram канал: @nextram_official
· Разработчики: @rexamm1t, @matrix_5858, @Alloyd031, @wefol1x, @w3b_0s1nt, @GalaxyFier, @Egor164rus, @weutqsz, @DRNv51, @weluvsz

## Лицензия

Модуль распространяется по лицензии GPL v3. Исходный код доступен в репозитории проекта.

---

Примечание: Используйте модуль с осторожностью. Неправильная настройка может повлиять на стабильность системы.
