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

## Опис

NextRAM — це потужний модуль Magisk для розширеного управління пам'яттю Android-пристроїв. Модуль надає покращені можливості роботи з zram, swap-файлами та тонке налаштування параметрів пам'яті для оптимізації продуктивності.

## Основні можливості

### Управління пам'яттю
- **ZRAM**: Налаштування стисненої оперативної пам'яті з вибором алгоритмів
- **Swap-файли**: Створення та управління файлами підкачки
- **Автоматичне налаштування**: Інтелектуальна оптимізація параметрів пам'яті
- **Динамічний swappiness**: Адаптивне управління підкачкою

### Моніторинг системи
- **Детальна статистика**: Детальна інформація про пам'ять, CPU, акумулятор
- **Здоров'я EMMC**: Моніторинг стану внутрішньої пам'яті
- **Логування**: Повне ведення логів роботи модуля
- **Системна інформація**: Збір даних про пристрій та систему

### Оптимізація
- **Налаштування ядра**: Оптимізація vm.swappiness, cache_pressure, dirty_ratio
- **Продуктивність**: Покращення відгуку системи
- **Енергоефективність**: Баланс між продуктивністю та витратою акумулятора

## Встановлення

1. Встановіть модуль через Magisk Manager або інший рут-менеджер
2. Перезавантажте пристрій
3. Налаштуйте параметри в додатку NextRAM або файлі `config.conf`

## Управління модулем

· Використовуйте додаток NextRAM Manager для графічного управління
· Редагуйте /data/adb/modules/nextram/config.conf для ручного налаштування
· Переглядайте логи в /data/adb/modules/nextram/logs/

## Сумісність

· Android 7.0 та вище
· Підтримка Magisk та KernelSU
· ARM, ARM64, x86, x86_64 архітектури
· Потрібен root-доступ

## Безпека

Модуль працює на рівні ядра і потребує мінімальних дозволів. Усі зміни обернені та не впливають на цілісність системи.

## Підтримка

· Telegram канал: @nextram_official

## Ліцензія

Модуль поширюється під ліцензією GPL v3. Вихідний код доступний у репозиторії проекту.

---

Примітка: Використовуйте модуль обережно. Неправильне налаштування може вплинути на стабільність системи.
