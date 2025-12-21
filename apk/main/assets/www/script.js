function setupTabs() {
    const tabs = document.querySelectorAll('.tab');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const targetTab = tab.getAttribute('data-tab');
            
            tabs.forEach(t => t.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));
            
            tab.classList.add('active');
            document.getElementById(`${targetTab}-tab`).classList.add('active');
            
            if (targetTab === 'home') {
                checkModuleStatus();
            }
        });
    });
}

function switchTab(tabName) {
    const tabs = document.querySelectorAll('.tab');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabs.forEach(t => t.classList.remove('active'));
    tabContents.forEach(content => content.classList.remove('active'));
    
    document.querySelector(`.tab[data-tab="${tabName}"]`).classList.add('active');
    document.getElementById(`${tabName}-tab`).classList.add('active');
    
    if (tabName === 'faq' && window.faqManager) {
        window.faqManager.renderFAQ();
    }
    
    if (tabName === 'home') {
        checkModuleStatus();
    }
}

const translations = {
    en: {
        "Module Status": "Module Status",
        "Checking module...": "Checking module...",
        "Install Module": "Install Module",
        "Update Module": "Update Module",
        "Uninstall Module": "Uninstall Module",
        "Enable": "Enable",
        "Disable": "Disable",
        "Not installed": "Not installed",
        "Installed": "Installed",
        "Enabled": "Enabled",
        "Disabled": "Disabled",
        "Version": "Version",
        "Version Code": "Version Code",
        "Frontend developer, community representative": "Frontend developer, community representative",
        "Tester": "Tester",
        "Select ZIP file": "Select ZIP file",
        "Module installed successfully": "Module installed successfully",
        "Module updated successfully": "Module updated successfully",
        "Module uninstalled successfully": "Module uninstalled successfully",
        "Module enabled": "Module enabled",
        "Module disabled": "Module disabled",
        "Installation failed": "Installation failed",
        "Uninstallation failed": "Uninstallation failed",
        "Root required for module operations": "Root required for module operations",
        "Checking module status...": "Checking module status...",
        "NextRAM": "NextRAM",
        "Welcome to NextRAM": "Welcome to NextRAM",
        "Advanced memory optimization for Android devices": "Advanced memory optimization for Android devices",
        "Root Access": "Root Access",
        "ZRAM Status": "ZRAM Status",
        "Swap Status": "Swap Status",
        "Quick Setup": "Quick Setup",
        "Learn More": "Learn More",
        "Smart Recommendations": "Smart Recommendations",
        "Analyzing your system": "Analyzing your system",
        "Development Team": "Development Team",
        "The main developer and founder of NextRAM": "The main developer and founder of NextRAM",
        "Developer and best friend of Rexamm1t": "Developer and best friend of Rexamm1t",
        "Developer, tester ": "Developer, tester",
        "Configurator, tests, support": "Configurator, tests, support",
        "Configurator, community representative, the tester": "Configurator, community representative, the tester",
        "Stay Updated": "Stay Updated",
        "Join our Telegram channel": "Join our Telegram channel",
        "Battery Saver": "Battery Saver",
        "Recommended": "Recommended",
        "Optimizes for battery life with minimal performance impact": "Optimizes for battery life with minimal performance impact",
        "ZRAM Ratio": "ZRAM Ratio",
        "Swappiness": "Swappiness",
        "Performance Mode": "Performance Mode",
        "Off": "Off",
        "Apply Profile": "Apply Profile",
        "Balanced": "Balanced",
        "Best for most": "Best for most",
        "Perfect balance between performance and battery life": "Perfect balance between performance and battery life",
        "Performance": "Performance",
        "For heavy apps": "For heavy apps",
        "Maximizes multitasking and app keeping": "Maximizes multitasking and app keeping",
        "On": "On",
        "Gaming": "Gaming",
        "For gaming": "For gaming",
        "Maximum performance for gaming and emulators": "Maximum performance for gaming and emulators",
        "Ready": "Ready",
        "Checking root access": "Checking root access",
        "Root access required!": "Root access required!",
        "Please grant root permissions to use all features.": "Please grant root permissions to use all features.",
        "Retry": "Retry",
        "Home": "Home",
        "Profiles": "Profiles",
        "Config": "Config",
        "ZRAM": "ZRAM",
        "Swap": "Swap",
        "Advanced": "Advanced",
        "FAQ": "FAQ",
        "Settings": "Settings",
        "Basic Settings": "Basic Settings",
        "Enable ZRAM": "Enable ZRAM",
        "Enable Swap File": "Enable Swap File",
        "Log Level": "Log Level",
        "DEBUG": "DEBUG",
        "INFO": "INFO",
        "WARN": "WARN",
        "ERROR": "ERROR",
        "Performance Settings": "Performance Settings",
        "Enable Extra Tuning": "Enable Extra Tuning",
        "Dynamic Swappiness": "Dynamic Swappiness",
        "Performance Mode": "Performance Mode",
        "ZRAM Auto Tune": "ZRAM Auto Tune",
        "I/O Scheduler Tune": "I/O Scheduler Tune",
        "CPU Boost": "CPU Boost",
        "Network Tune": "Network Tune",
        "ZRAM Configuration": "ZRAM Configuration",
        "ZRAM Size Ratio": "ZRAM Size Ratio",
        "Compression Algorithm": "Compression Algorithm",
        "zstd (Best compression)": "zstd (Best compression)",
        "lz4 (Fastest)": "lz4 (Fastest)",
        "lzo (Balanced)": "lzo (Balanced)",
        "lzo-rle (Improved lzo)": "lzo-rle (Improved lzo)",
        "deflate (Good compression)": "deflate (Good compression)",
        "Max Compression Streams": "Max Compression Streams",
        "ZRAM Priority": "ZRAM Priority",
        "ZRAM Compression Level": "ZRAM Compression Level",
        "ZRAM Memory Limit": "ZRAM Memory Limit",
        "Swap File Configuration": "Swap File Configuration",
        "Swap Size (GB)": "Swap Size (GB)",
        "Filesystem Overhead (GB)": "Filesystem Overhead (GB)",
        "Swap Priority": "Swap Priority",
        "Swap Performance": "Swap Performance",
        "Kernel Tuning Parameters": "Kernel Tuning Parameters",
        "Cache Pressure": "Cache Pressure",
        "Dirty Ratio": "Dirty Ratio",
        "Dirty Background Ratio": "Dirty Background Ratio",
        "Advanced VM Settings": "Advanced VM Settings",
        "Dirty Writeback Centisecs": "Dirty Writeback Centisecs",
        "Dirty Expire Centisecs": "Dirty Expire Centisecs",
        "Page Cluster": "Page Cluster",
        "Laptop Mode": "Laptop Mode",
        "OOM Kill Allocating Task": "OOM Kill Allocating Task",
        "Panic on OOM": "Panic on OOM",
        "Overcommit Memory": "Overcommit Memory",
        "Overcommit Ratio": "Overcommit Ratio",
        "Watermark Scale Factor": "Watermark Scale Factor",
        "Kernel Threads Max": "Kernel Threads Max",
        "Frequently Asked Questions": "Frequently Asked Questions",
        "Quick Start Guide": "Quick Start Guide",
        "Appearance": "Appearance",
        "Accent Color": "Accent Color",
        "Orange": "Orange",
        "Blue": "Blue",
        "Green": "Green",
        "Purple": "Purple",
        "Red": "Red",
        "Teal": "Teal",
        "Theme": "Theme",
        "Light": "Light",
        "Dark": "Dark",
        "OLED": "OLED",
        "Auto": "Auto",
        "Enable Animations": "Enable Animations",
        "Language": "Language",
        "English": "English",
        "Russian": "Russian",
        "Ukrainian": "Ukrainian",
        "Chinese": "Chinese",
        "Configuration History": "Configuration History",
        "No configuration history yet": "No configuration history yet",
        "Save Current Configuration": "Save Current Configuration",
        "Save Changes": "Save Changes",
        "Configuration saved. Please reboot your device.": "Configuration saved. Please reboot your device.",
        "High ZRAM Ratio": "High ZRAM Ratio",
        "ZRAM ratio is set very high which may cause system lag": "ZRAM ratio is set very high which may cause system lag",
        "Consider reducing to 1.5-2.0 range": "Consider reducing to 1.5-2.0 range",
        "Low ZRAM Ratio": "Low ZRAM Ratio",
        "ZRAM ratio is quite low, you may experience app reloads": "ZRAM ratio is quite low, you may experience app reloads",
        "Consider increasing to 0.8-1.0 for better multitasking": "Consider increasing to 0.8-1.0 for better multitasking",
        "High Swappiness": "High Swappiness",
        "Swappiness is set high without Performance Mode": "Swappiness is set high without Performance Mode",
        "Either enable Performance Mode or reduce swappiness to 60-80": "Either enable Performance Mode or reduce swappiness to 60-80",
        "Swap on Slow Storage": "Swap on Slow Storage",
        "Using swap file on slow storage will degrade performance": "Using swap file on slow storage will degrade performance",
        "Disable swap file or upgrade to faster storage": "Disable swap file or upgrade to faster storage",
        "Auto-tuning Conflict": "Auto-tuning Conflict",
        "ZRAM Auto Tune may conflict with manual tuning settings": "ZRAM Auto Tune may conflict with manual tuning settings",
        "Disable either Auto Tune or manual tuning features": "Disable either Auto Tune or manual tuning features",
        "High Compression Streams": "High Compression Streams",
        "Using many compression streams may increase CPU usage": "Using many compression streams may increase CPU usage",
        "Set streams to match your CPU cores (usually 4-8)": "Set streams to match your CPU cores (usually 4-8)",
        "Your configuration looks good!": "Your configuration looks good!",
        "Applied": "Applied",
        "profile": "profile",
        "Enter a description for this configuration:": "Enter a description for this configuration:",
        "Manual save": "Manual save",
        "Configuration saved to history": "Configuration saved to history",
        "Configuration restored from history": "Configuration restored from history",
        "Root access granted": "Root access granted",
        "Root access required": "Root access required",
        "Android interface not available": "Android interface not available",
        "Root check error: ": "Root check error: ",
        "Loading configuration": "Loading configuration",
        "Configuration loaded successfully": "Configuration loaded successfully",
        "Failed to write service.sh": "Failed to write service.sh",
        "0 (Disabled)": "0 (Disabled)",
        "1 (Enabled)": "1 (Enabled)",
        "2 (Enabled with timeout)": "2 (Enabled with timeout)",
        "0 (Heuristic)": "0 (Heuristic)",
        "1 (Always)": "1 (Always)",
        "2 (Disabled)": "2 (Disabled)"
    },
    ru: {
        "Module Status": "Статус модуля",
        "Checking module...": "Проверка модуля...",
        "Install Module": "Установить модуль",
        "Update Module": "Обновить модуль",
        "Uninstall Module": "Удалить модуль",
        "Enable": "Включить",
        "Disable": "Выключить",
        "Not installed": "Не установлен",
        "Installed": "Установлен",
        "Enabled": "Включен",
        "Disabled": "Выключен",
        "Version": "Версия",
        "Version Code": "Код версии",
        "Frontend developer, community representative": "Фронтенд разработчик, представитель комьюнити",
        "Tester": "Тестер",
        "Select ZIP file": "Выберите ZIP файл",
        "Module installed successfully": "Модуль успешно установлен",
        "Module updated successfully": "Модуль успешно обновлен",
        "Module uninstalled successfully": "Модуль успешно удален",
        "Module enabled": "Модуль включен",
        "Module disabled": "Модуль выключен",
        "Installation failed": "Ошибка установки",
        "Uninstallation failed": "Ошибка удаления",
        "Root required for module operations": "Требуется root для операций с модулем",
        "Checking module status...": "Проверка статуса модуля...",
        "NextRAM": "NextRAM",
        "Welcome to NextRAM": "Добро пожаловать в NextRAM",
        "Advanced memory optimization for Android devices": "Продвинутая оптимизация памяти для Android устройств",
        "Root Access": "Root доступ",
        "ZRAM Status": "Статус ZRAM",
        "Swap Status": "Статус Swap",
        "Quick Setup": "Быстрая настройка",
        "Learn More": "Узнать больше",
        "Smart Recommendations": "Умные рекомендации",
        "Analyzing your system": "Анализ вашей системы",
        "Development Team": "Команда разработчиков",
        "The main developer and founder of NextRAM": "Главный разработчик и основатель NextRAM",
        "Developer and best friend of Rexamm1t": "Разработчик и лучший друг Rexamm1t'a",
        "Developer, tester ": "Разработчик, тестер",
        "Configurator, tests, support": "Конфигуратор, тесты, поддержка",
        "Configurator, community representative, the tester": "Конфигуратор, представитель комьюнити. Тестер",
        "Stay Updated": "Будьте в курсе",
        "Join our Telegram channel": "Присоединяйтесь к нашему Telegram каналу",
        "Battery Saver": "Экономия батареи",
        "Recommended": "Рекомендуется",
        "Optimizes for battery life with minimal performance impact": "Оптимизировано для экономии батареи с минимальным влиянием на производительность",
        "ZRAM Ratio": "Коэффициент ZRAM",
        "Swappiness": "Swappiness",
        "Performance Mode": "Режим производительности",
        "Off": "Выкл",
        "Apply Profile": "Применить профиль",
        "Balanced": "Сбалансированный",
        "Best for most": "Лучший для большинства",
        "Perfect balance between performance and battery life": "Идеальный баланс между производительностью и временем работы от батареи",
        "Performance": "Производительность",
        "For heavy apps": "Для тяжелых приложений",
        "Maximizes multitasking and app keeping": "Максимизирует многозадачность и удержание приложений",
        "On": "Вкл",
        "Gaming": "Игры",
        "For gaming": "Для игр",
        "Maximum performance for gaming and emulators": "Максимальная производительность для игр и эмуляторов",
        "Ready": "Готов",
        "Checking root access": "Проверка root доступа",
        "Root access required!": "Требуется root доступ!",
        "Please grant root permissions to use all features.": "Предоставьте root права для использования всех функций.",
        "Retry": "Повторить",
        "Home": "Главная",
        "Profiles": "Профили",
        "Config": "Конфиг",
        "ZRAM": "ZRAM",
        "Swap": "Swap",
        "Advanced": "Дополнительно",
        "FAQ": "FAQ",
        "Settings": "Настройки",
        "Basic Settings": "Основные настройки",
        "Enable ZRAM": "Включить ZRAM",
        "Enable Swap File": "Включить файл подкачки",
        "Log Level": "Уровень логов",
        "DEBUG": "DEBUG",
        "INFO": "INFO",
        "WARN": "WARN",
        "ERROR": "ERROR",
        "Performance Settings": "Настройки производительности",
        "Enable Extra Tuning": "Включить доп. настройку",
        "Dynamic Swappiness": "Динамическая swappiness",
        "Performance Mode": "Режим производительности",
        "ZRAM Auto Tune": "Автонастройка ZRAM",
        "I/O Scheduler Tune": "Настройка I/O планировщика",
        "CPU Boost": "Ускорение CPU",
        "Network Tune": "Настройка сети",
        "ZRAM Configuration": "Конфигурация ZRAM",
        "ZRAM Size Ratio": "Коэффициент размера ZRAM",
        "Compression Algorithm": "Алгоритм сжатия",
        "zstd (Best compression)": "zstd (Лучшее сжатие)",
        "lz4 (Fastest)": "lz4 (Самое быстрое)",
        "lzo (Balanced)": "lzo (Сбалансированное)",
        "lzo-rle (Improved lzo)": "lzo-rle (Улучшенный lzo)",
        "deflate (Good compression)": "deflate (Хорошее сжатие)",
        "Max Compression Streams": "Макс. потоков сжатия",
        "ZRAM Priority": "Приоритет ZRAM",
        "ZRAM Compression Level": "Уровень сжатия ZRAM",
        "ZRAM Memory Limit": "Лимит памяти ZRAM",
        "Swap File Configuration": "Конфигурация файла подкачки",
        "Swap Size (GB)": "Размер подкачки (ГБ)",
        "Filesystem Overhead (GB)": "Накладные расходы ФС (ГБ)",
        "Swap Priority": "Приоритет подкачки",
        "Swap Performance": "Производительность подкачки",
        "Kernel Tuning Parameters": "Параметры настройки ядра",
        "Cache Pressure": "Давление кэша",
        "Dirty Ratio": "Dirty Ratio",
        "Dirty Background Ratio": "Dirty Background Ratio",
        "Advanced VM Settings": "Расширенные настройки VM",
        "Dirty Writeback Centisecs": "Dirty Writeback Centisecs",
        "Dirty Expire Centisecs": "Dirty Expire Centisecs",
        "Page Cluster": "Page Cluster",
        "Laptop Mode": "Laptop Mode",
        "OOM Kill Allocating Task": "OOM Kill Allocating Task",
        "Panic on OOM": "Panic on OOM",
        "Overcommit Memory": "Overcommit Memory",
        "Overcommit Ratio": "Overcommit Ratio",
        "Watermark Scale Factor": "Watermark Scale Factor",
        "Kernel Threads Max": "Kernel Threads Max",
        "Frequently Asked Questions": "Часто задаваемые вопросы",
        "Quick Start Guide": "Краткое руководство",
        "Appearance": "Внешний вид",
        "Accent Color": "Акцентный цвет",
        "Orange": "Оранжевый",
        "Blue": "Синий",
        "Green": "Зеленый",
        "Purple": "Фиолетовый",
        "Red": "Красный",
        "Teal": "Бирюзовый",
        "Theme": "Тема",
        "Light": "Светлая",
        "Dark": "Темная",
        "OLED": "OLED",
        "Auto": "Авто",
        "Enable Animations": "Включить анимации",
        "Language": "Язык",
        "English": "Английский",
        "Russian": "Русский",
        "Ukrainian": "Украинский",
        "Chinese": "Китайский",
        "Configuration History": "История конфигураций",
        "No configuration history yet": "Истории конфигураций пока нет",
        "Save Current Configuration": "Сохранить текущую конфигурацию",
        "Save Changes": "Сохранить изменения",
        "Configuration saved. Please reboot your device.": "Конфигурация сохранена. Перезагрузите устройство.",
        "High ZRAM Ratio": "Высокий коэффициент ZRAM",
        "ZRAM ratio is set very high which may cause system lag": "Коэффициент ZRAM установлен слишком высоким, что может вызвать лаги",
        "Consider reducing to 1.5-2.0 range": "Рекомендуется уменьшить до 1.5-2.0",
        "Low ZRAM Ratio": "Низкий коэффициент ZRAM",
        "ZRAM ratio is quite low, you may experience app reloads": "Коэффициент ZRAM слишком низкий, возможны перезагрузки приложений",
        "Consider increasing to 0.8-1.0 for better multitasking": "Рекомендуется увеличить до 0.8-1.0 для лучшей многозадачности",
        "High Swappiness": "Высокий swappiness",
        "Swappiness is set high without Performance Mode": "Swappiness установлен высоким без режима производительности",
        "Either enable Performance Mode or reduce swappiness to 60-80": "Включите режим производительности или уменьшите swappiness до 60-80",
        "Swap on Slow Storage": "Swap на медленном хранилище",
        "Using swap file on slow storage will degrade performance": "Использование swap на медленном хранилище ухудшит производительность",
        "Disable swap file or upgrade to faster storage": "Отключите swap или используйте быстрое хранилище",
        "Auto-tuning Conflict": "Конфликт автонастройки",
        "ZRAM Auto Tune may conflict with manual tuning settings": "Автонастройка ZRAM может конфликтовать с ручными настройками",
        "Disable either Auto Tune or manual tuning features": "Отключите автонастройку или ручные настройки",
        "High Compression Streams": "Много потоков сжатия",
        "Using many compression streams may increase CPU usage": "Большое количество потоков сжатия увеличит нагрузку на CPU",
        "Set streams to match your CPU cores (usually 4-8)": "Установите количество потоков по числу ядер CPU (обычно 4-8)",
        "Your configuration looks good!": "Ваша конфигурация выглядит хорошо!",
        "Applied": "Применен",
        "profile": "профиль",
        "Enter a description for this configuration:": "Введите описание конфигурации:",
        "Manual save": "Ручное сохранение",
        "Configuration saved to history": "Конфигурация сохранена в историю",
        "Configuration restored from history": "Конфигурация восстановлена из истории",
        "Root access granted": "Root доступ предоставлен",
        "Root access required": "Требуется root доступ",
        "Android interface not available": "Android интерфейс недоступен",
        "Root check error: ": "Ошибка проверки root: ",
        "Loading configuration": "Загрузка конфигурации",
        "Configuration loaded successfully": "Конфигурация загружена успешно",
        "Failed to write service.sh": "Ошибка записи service.sh",
        "0 (Disabled)": "0 (Выключено)",
        "1 (Enabled)": "1 (Включено)",
        "2 (Enabled with timeout)": "2 (Включено с таймаутом)",
        "0 (Heuristic)": "0 (Эвристика)",
        "1 (Always)": "1 (Всегда)",
        "2 (Disabled)": "2 (Выключено)"
    },
    uk: {
        "Module Status": "Статус модуля",
        "Checking module...": "Перевірка модуля...",
        "Install Module": "Встановити модуль",
        "Update Module": "Оновити модуль",
        "Uninstall Module": "Видалити модуль",
        "Enable": "Увімкнути",
        "Disable": "Вимкнути",
        "Not installed": "Не встановлено",
        "Installed": "Встановлено",
        "Enabled": "Увімкнено",
        "Disabled": "Вимкнено",
        "Version": "Версія",
        "Version Code": "Код версії",
        "Frontend developer, community representative": "Фронтенд розробник, представник спільноти",
        "Tester": "Тестувальник",
        "Select ZIP file": "Виберіть ZIP файл",
        "Module installed successfully": "Модуль успішно встановлено",
        "Module updated successfully": "Модуль успішно оновлено",
        "Module uninstalled successfully": "Модуль успішно видалено",
        "Module enabled": "Модуль увімкнено",
        "Module disabled": "Модуль вимкнено",
        "Installation failed": "Помилка встановлення",
        "Uninstallation failed": "Помилка видалення",
        "Root required for module operations": "Потрібен root для операцій з модулем",
        "Checking module status...": "Перевірка статусу модуля...",
        "NextRAM": "NextRAM",
        "Welcome to NextRAM": "Ласкаво просимо до NextRAM",
        "Advanced memory optimization for Android devices": "Розширена оптимізація пам'яті для пристроїв Android",
        "Root Access": "Root доступ",
        "ZRAM Status": "Статус ZRAM",
        "Swap Status": "Статус Swap",
        "Quick Setup": "Швидке налаштування",
        "Learn More": "Дізнатися більше",
        "Smart Recommendations": "Розумні рекомендації",
        "Analyzing your system": "Аналіз вашої системи",
        "Development Team": "Команда розробників",
        "The main developer and founder of NextRAM": "Головний розробник та засновник NextRAM",
        "Developer and best friend of Rexamm1t": "Розробник та найкращий друг Rexamm1t",
        "Developer, tester": "Розробник, тестувальник",
        "Configurator, tests, support": "Конфігуратор, тести, підтримка",
        "Configurator, community representative, the tester": "Конфігуратор, представник спільноти. Тестувальник",
        "Stay Updated": "Будьте в курсі",
        "Join our Telegram channel": "Приєднуйтесь до нашого Telegram каналу",
        "Battery Saver": "Економія батареї",
        "Recommended": "Рекомендується",
        "Optimizes for battery life with minimal performance impact": "Оптимізовано для економії батареї з мінімальним впливом на продуктивність",
        "ZRAM Ratio": "Коефіцієнт ZRAM",
        "Swappiness": "Swappiness",
        "Performance Mode": "Режим продуктивності",
        "Off": "Вимк",
        "Apply Profile": "Застосувати профіль",
        "Balanced": "Збалансований",
        "Best for most": "Найкращий для більшості",
        "Perfect balance between performance and battery life": "Ідеальний баланс між продуктивністю та часом роботи від батареї",
        "Performance": "Продуктивність",
        "For heavy apps": "Для важких додатків",
        "Maximizes multitasking and app keeping": "Максимізує багатозадачність та утримання додатків",
        "On": "Увімк",
        "Gaming": "Ігри",
        "For gaming": "Для ігор",
        "Maximum performance for gaming and emulators": "Максимальна продуктивність для ігор та емуляторів",
        "Ready": "Готово",
        "Checking root access": "Перевірка root доступу",
        "Root access required!": "Потрібен root доступ!",
        "Please grant root permissions to use all features.": "Надайте root права для використання всіх функцій.",
        "Retry": "Повторити",
        "Home": "Головна",
        "Profiles": "Профілі",
        "Config": "Конфіг",
        "ZRAM": "ZRAM",
        "Swap": "Swap",
        "Advanced": "Додатково",
        "FAQ": "FAQ",
        "Settings": "Налаштування",
        "Basic Settings": "Основні налаштування",
        "Enable ZRAM": "Увімкнути ZRAM",
        "Enable Swap File": "Увімкнути файл підкачки",
        "Log Level": "Рівень логів",
        "DEBUG": "DEBUG",
        "INFO": "INFO",
        "WARN": "WARN",
        "ERROR": "ERROR",
        "Performance Settings": "Налаштування продуктивності",
        "Enable Extra Tuning": "Увімкнути дод. налаштування",
        "Dynamic Swappiness": "Динамічна swappiness",
        "Performance Mode": "Режим продуктивності",
        "ZRAM Auto Tune": "Автоналаштування ZRAM",
        "I/O Scheduler Tune": "Налаштування I/O планувальника",
        "CPU Boost": "Прискорення CPU",
        "Network Tune": "Налаштування мережі",
        "ZRAM Configuration": "Конфігурація ZRAM",
        "ZRAM Size Ratio": "Коефіцієнт розміру ZRAM",
        "Compression Algorithm": "Алгоритм стиснення",
        "zstd (Best compression)": "zstd (Найкраще стиснення)",
        "lz4 (Fastest)": "lz4 (Найшвидше)",
        "lzo (Balanced)": "lzo (Збалансоване)",
        "lzo-rle (Improved lzo)": "lzo-rle (Покращений lzo)",
        "deflate (Good compression)": "deflate (Хороше стиснення)",
        "Max Compression Streams": "Макс. потоків стиснення",
        "ZRAM Priority": "Пріоритет ZRAM",
        "ZRAM Compression Level": "Рівень стиснення ZRAM",
        "ZRAM Memory Limit": "Ліміт пам'яті ZRAM",
        "Swap File Configuration": "Конфігурація файлу підкачки",
        "Swap Size (GB)": "Розмір підкачки (ГБ)",
        "Filesystem Overhead (GB)": "Накладні витрати ФС (ГБ)",
        "Swap Priority": "Пріоритет підкачки",
        "Swap Performance": "Продуктивність підкачки",
        "Kernel Tuning Parameters": "Параметри налаштування ядра",
        "Cache Pressure": "Тиск кешу",
        "Dirty Ratio": "Dirty Ratio",
        "Dirty Background Ratio": "Dirty Background Ratio",
        "Advanced VM Settings": "Розширені налаштування VM",
        "Dirty Writeback Centisecs": "Dirty Writeback Centisecs",
        "Dirty Expire Centisecs": "Dirty Expire Centisecs",
        "Page Cluster": "Page Cluster",
        "Laptop Mode": "Laptop Mode",
        "OOM Kill Allocating Task": "OOM Kill Allocating Task",
        "Panic on OOM": "Panic on OOM",
        "Overcommit Memory": "Overcommit Memory",
        "Overcommit Ratio": "Overcommit Ratio",
        "Watermark Scale Factor": "Watermark Scale Factor",
        "Kernel Threads Max": "Kernel Threads Max",
        "Frequently Asked Questions": "Часті запитання",
        "Quick Start Guide": "Короткий посібник",
        "Appearance": "Зовнішній вигляд",
        "Accent Color": "Акцентний колір",
        "Orange": "Помаранчевий",
        "Blue": "Синій",
        "Green": "Зелений",
        "Purple": "Фіолетовий",
        "Red": "Червоний",
        "Teal": "Бірюзовий",
        "Theme": "Тема",
        "Light": "Світла",
        "Dark": "Темна",
        "OLED": "OLED",
        "Auto": "Авто",
        "Enable Animations": "Увімкнути анімації",
        "Language": "Мова",
        "English": "Англійська",
        "Russian": "Російська",
        "Ukrainian": "Українська",
        "Chinese": "Китайська",
        "Configuration History": "Історія конфігурацій",
        "No configuration history yet": "Історії конфігурацій поки немає",
        "Save Current Configuration": "Зберегти поточну конфігурацію",
        "Save Changes": "Зберегти зміни",
        "Configuration saved. Please reboot your device.": "Конфігурацію збережено. Перезавантажте пристрій.",
        "High ZRAM Ratio": "Високий коефіцієнт ZRAM",
        "ZRAM ratio is set very high which may cause system lag": "Коефіцієнт ZRAM встановлено занадто високим, що може спричинити лаги",
        "Consider reducing to 1.5-2.0 range": "Рекомендується зменшити до 1.5-2.0",
        "Low ZRAM Ratio": "Низький коефіцієнт ZRAM",
        "ZRAM ratio is quite low, you may experience app reloads": "Коефіцієнт ZRAM занадто низький, можливі перезавантаження додатків",
        "Consider increasing to 0.8-1.0 for better multitasking": "Рекомендується збільшити до 0.8-1.0 для кращої багатозадачності",
        "High Swappiness": "Високий swappiness",
        "Swappiness is set high without Performance Mode": "Swappiness встановлено високим без режиму продуктивності",
        "Either enable Performance Mode or reduce swappiness to 60-80": "Увімкніть режим продуктивності або зменшіть swappiness до 60-80",
        "Swap on Slow Storage": "Swap на повільному сховищі",
        "Using swap file on slow storage will degrade performance": "Використання swap на повільному сховищі погіршить продуктивність",
        "Disable swap file or upgrade to faster storage": "Вимкніть swap або використовуйте швидше сховище",
        "Auto-tuning Conflict": "Конфлікт автоналаштування",
        "ZRAM Auto Tune may conflict with manual tuning settings": "Автоналаштування ZRAM може конфліктувати з ручними налаштуваннями",
        "Disable either Auto Tune or manual tuning features": "Вимкніть автоналаштування або ручні налаштування",
        "High Compression Streams": "Багато потоків стиснення",
        "Using many compression streams may increase CPU usage": "Велика кількість потоків стиснення збільшить навантаження на CPU",
        "Set streams to match your CPU cores (зазвичай 4-8)": "Встановіть кількість потоків за кількістю ядер CPU (зазвичай 4-8)",
        "Your configuration looks good!": "Ваша конфігурація виглядає добре!",
        "Applied": "Застосовано",
        "profile": "профіль",
        "Enter a description for this configuration:": "Введіть опис конфігурації:",
        "Manual save": "Ручне збереження",
        "Configuration saved to history": "Конфігурацію збережено в історію",
        "Configuration restored from history": "Конфігурацію відновлено з історії",
        "Root access granted": "Root доступ надано",
        "Root access required": "Потрібен root доступ",
        "Android interface not available": "Android інтерфейс недоступний",
        "Root check error: ": "Помилка перевірки root: ",
        "Loading configuration": "Завантаження конфігурації",
        "Configuration loaded successfully": "Конфігурацію завантажено успішно",
        "Failed to write service.sh": "Помилка запису service.sh",
        "0 (Disabled)": "0 (Вимкнено)",
        "1 (Enabled)": "1 (Увімкнено)",
        "2 (Enabled with timeout)": "2 (Увімкнено з таймаутом)",
        "0 (Heuristic)": "0 (Евристика)",
        "1 (Always)": "1 (Завжди)",
        "2 (Disabled)": "2 (Вимкнено)"
    },
    zh: {
        "Module Status": "模块状态",
        "Checking module...": "检查模块...",
        "Install Module": "安装模块",
        "Update Module": "更新模块",
        "Uninstall Module": "卸载模块",
        "Enable": "启用",
        "Disable": "禁用",
        "Not installed": "未安装",
        "Installed": "已安装",
        "Enabled": "已启用",
        "Disabled": "已禁用",
        "Version": "版本",
        "Version Code": "版本代码",
        "Frontend developer, community representative": "前端开发者，社区代表",
        "Tester": "测试员",
        "Select ZIP file": "选择 ZIP 文件",
        "Module installed successfully": "模块安装成功",
        "Module updated successfully": "模块更新成功",
        "Module uninstalled successfully": "模块卸载成功",
        "Module enabled": "模块已启用",
        "Module disabled": "模块已禁用",
        "Installation failed": "安装失败",
        "Uninstallation failed": "卸载失败",
        "Root required for module operations": "模块操作需要 Root 权限",
        "Checking module status...": "检查模块状态...",
        "NextRAM": "NextRAM",
        "Welcome to NextRAM": "欢迎使用 NextRAM",
        "Advanced memory optimization for Android devices": "Android 设备的高级内存优化",
        "Root Access": "Root 权限",
        "ZRAM Status": "ZRAM 状态",
        "Swap Status": "Swap 状态",
        "Quick Setup": "快速设置",
        "Learn More": "了解更多",
        "Smart Recommendations": "智能推荐",
        "Analyzing your system": "分析您的系统",
        "Development Team": "开发团队",
        "The main developer and founder of NextRAM": "NextRAM 的主要开发者和创始人",
        "Developer and best friend of Rexamm1t": "Rexamm1t 的开发者和最好的朋友",
        "Developer, tester": "开发者，测试员",
        "Configurator, tests, support": "配置器，测试，支持",
        "Configurator, community representative, the tester": "配置器，社区代表，测试员",
        "Stay Updated": "保持更新",
        "Join our Telegram channel": "加入我们的 Telegram 频道",
        "Battery Saver": "省电模式",
        "Recommended": "推荐",
        "Optimizes for battery life with minimal performance impact": "优化电池寿命，对性能影响最小",
        "ZRAM Ratio": "ZRAM 比率",
        "Swappiness": "交换倾向",
        "Performance Mode": "性能模式",
        "Off": "关",
        "Apply Profile": "应用配置",
        "Balanced": "平衡模式",
        "Best for most": "适合大多数",
        "Perfect balance between performance and battery life": "性能和电池寿命之间的完美平衡",
        "Performance": "性能模式",
        "For heavy apps": "适用于重型应用",
        "Maximizes multitasking and app keeping": "最大化多任务和应用保持",
        "On": "开",
        "Gaming": "游戏模式",
        "For gaming": "适用于游戏",
        "Maximum performance for gaming and emulators": "游戏和模拟器的最大性能",
        "Ready": "就绪",
        "Checking root access": "检查 root 权限",
        "Root access required!": "需要 root 权限！",
        "Please grant root permissions to use all features.": "请授予 root 权限以使用所有功能。",
        "Retry": "重试",
        "Home": "首页",
        "Profiles": "配置方案",
        "Config": "配置",
        "ZRAM": "ZRAM",
        "Swap": "Swap",
        "Advanced": "高级",
        "FAQ": "常见问题",
        "Settings": "设置",
        "Basic Settings": "基本设置",
        "Enable ZRAM": "启用 ZRAM",
        "Enable Swap File": "启用交换文件",
        "Log Level": "日志级别",
        "DEBUG": "调试",
        "INFO": "信息",
        "WARN": "警告",
        "ERROR": "错误",
        "Performance Settings": "性能设置",
        "Enable Extra Tuning": "启用额外调优",
        "Dynamic Swappiness": "动态交换倾向",
        "Performance Mode": "性能模式",
        "ZRAM Auto Tune": "ZRAM 自动调优",
        "I/O Scheduler Tune": "I/O 调度器调优",
        "CPU Boost": "CPU 加速",
        "Network Tune": "网络调优",
        "ZRAM Configuration": "ZRAM 配置",
        "ZRAM Size Ratio": "ZRAM 大小比率",
        "Compression Algorithm": "压缩算法",
        "zstd (Best compression)": "zstd (最佳压缩)",
        "lz4 (Fastest)": "lz4 (最快)",
        "lzo (Balanced)": "lzo (平衡)",
        "lzo-rle (Improved lzo)": "lzo-rle (改进的 lzo)",
        "deflate (Good compression)": "deflate (良好压缩)",
        "Max Compression Streams": "最大压缩流",
        "ZRAM Priority": "ZRAM 优先级",
        "ZRAM Compression Level": "ZRAM 压缩级别",
        "ZRAM Memory Limit": "ZRAM 内存限制",
        "Swap File Configuration": "交换文件配置",
        "Swap Size (GB)": "交换大小 (GB)",
        "Filesystem Overhead (GB)": "文件系统开销 (GB)",
        "Swap Priority": "交换优先级",
        "Swap Performance": "交换性能",
        "Kernel Tuning Parameters": "内核调优参数",
        "Cache Pressure": "缓存压力",
        "Dirty Ratio": "脏页比率",
        "Dirty Background Ratio": "后台脏页比率",
        "Advanced VM Settings": "高级 VM 设置",
        "Dirty Writeback Centisecs": "脏页写回间隔",
        "Dirty Expire Centisecs": "脏页过期时间",
        "Page Cluster": "页面簇",
        "Laptop Mode": "笔记本模式",
        "OOM Kill Allocating Task": "OOM 杀死分配任务",
        "Panic on OOM": "OOM 时恐慌",
        "Overcommit Memory": "内存超配",
        "Overcommit Ratio": "超配比率",
        "Watermark Scale Factor": "水位标度因子",
        "Kernel Threads Max": "内核线程最大数",
        "Frequently Asked Questions": "常见问题",
        "Quick Start Guide": "快速入门指南",
        "Appearance": "外观",
        "Accent Color": "主题色",
        "Orange": "橙色",
        "Blue": "蓝色",
        "Green": "绿色",
        "Purple": "紫色",
        "Red": "红色",
        "Teal": "青色",
        "Theme": "主题",
        "Light": "浅色",
        "Dark": "深色",
        "OLED": "OLED",
        "Auto": "自动",
        "Enable Animations": "启用动画",
        "Language": "语言",
        "English": "英语",
        "Russian": "俄语",
        "Ukrainian": "乌克兰语",
        "Chinese": "中文",
        "Configuration History": "配置历史",
        "No configuration history yet": "暂无配置历史",
        "Save Current Configuration": "保存当前配置",
        "Save Changes": "保存更改",
        "Configuration saved. Please reboot your device.": "配置已保存。请重启设备。",
        "High ZRAM Ratio": "高 ZRAM 比率",
        "ZRAM ratio is set very high which may cause system lag": "ZRAM 比率设置过高，可能导致系统卡顿",
        "Consider reducing to 1.5-2.0 range": "建议降低到 1.5-2.0 范围",
        "Low ZRAM Ratio": "低 ZRAM 比率",
        "ZRAM ratio is quite low, you may experience app reloads": "ZRAM 比率过低，可能会遇到应用重载",
        "Consider increasing to 0.8-1.0 for better multitasking": "建议增加到 0.8-1.0 以获得更好的多任务处理",
        "High Swappiness": "高交换倾向",
        "Swappiness is set high without Performance Mode": "交换倾向设置过高但未启用性能模式",
        "Either enable Performance Mode or reduce swappiness to 60-80": "启用性能模式或将交换倾向降低到 60-80",
        "Swap on Slow Storage": "在慢速存储上使用交换",
        "Using swap file on slow storage will degrade performance": "在慢速存储上使用交换文件会降低性能",
        "Disable swap file or upgrade to faster storage": "禁用交换文件或升级到更快的存储",
        "Auto-tuning Conflict": "自动调优冲突",
        "ZRAM Auto Tune may conflict with manual tuning settings": "ZRAM 自动调优可能与手动调优设置冲突",
        "Disable either Auto Tune or manual tuning features": "禁用自动调优或手动调优功能",
        "High Compression Streams": "高压缩流",
        "Using many compression streams may increase CPU usage": "使用过多压缩流可能会增加 CPU 使用率",
        "Set streams to match your CPU cores (通常 4-8)": "设置流数以匹配 CPU 核心数 (通常 4-8)",
        "Your configuration looks good!": "您的配置看起来很好！",
        "Applied": "已应用",
        "profile": "配置方案",
        "Enter a description for this configuration:": "输入此配置的描述：",
        "Manual save": "手动保存",
        "Configuration saved to history": "配置已保存到历史记录",
        "Configuration restored from history": "配置已从历史记录恢复",
        "Root access granted": "Root 权限已授予",
        "Root access required": "需要 Root 权限",
        "Android interface not available": "Android 接口不可用",
        "Root check error: ": "Root 检查错误：",
        "Loading configuration": "加载配置",
        "Configuration loaded successfully": "配置加载成功",
        "Failed to write service.sh": "写入 service.sh 失败",
        "0 (Disabled)": "0 (禁用)",
        "1 (Enabled)": "1 (启用)",
        "2 (Enabled with timeout)": "2 (启用带超时)",
        "0 (Heuristic)": "0 (启发式)",
        "1 (Always)": "1 (总是)",
        "2 (Disabled)": "2 (禁用)"
    }
};

const performanceProfiles = {
    battery: {
        ZRAM_ENABLED: true,
        SWAP_ENABLED: false,
        ZRAM_RATIO: 0.8,
        ZRAM_ALGORITHM: "lz4",
        MAX_COMP_STREAMS: 4,
        SWAPPINESS: 40,
        PERFORMANCE_MODE: false,
        EXTRA_TUNING: false,
        DYNAMIC_SWAPPINESS: false,
        ZRAM_AUTO_TUNE: false,
        IO_SCHEDULER_TUNE: false,
        CPU_BOOST: false,
        NETWORK_TUNE: false,
        ZRAM_PRIORITY: 0,
        ZRAM_COMPRESSION_LEVEL: 3,
        ZRAM_MEMORY_LIMIT: "",
        SWAP_PRIORITY: 0,
        VM_DIRTY_WRITEBACK_CENTISECS: 500,
        VM_DIRTY_EXPIRE_CENTISECS: 3000,
        VM_PAGE_CLUSTER: 3,
        VM_LAPTOP_MODE: 0,
        VM_OOM_KILL_ALLOCATING_TASK: false,
        VM_PANIC_ON_OOM: 0,
        VM_OVERCOMMIT_MEMORY: 0,
        VM_OVERCOMMIT_RATIO: 50,
        VM_WATERMARK_SCALE_FACTOR: 10,
        KERNEL_THREADS_MAX: 0
    },
    balanced: {
        ZRAM_ENABLED: true,
        SWAP_ENABLED: false,
        ZRAM_RATIO: 1.2,
        ZRAM_ALGORITHM: "zstd",
        MAX_COMP_STREAMS: 6,
        SWAPPINESS: 60,
        PERFORMANCE_MODE: false,
        EXTRA_TUNING: true,
        DYNAMIC_SWAPPINESS: true,
        ZRAM_AUTO_TUNE: false,
        IO_SCHEDULER_TUNE: true,
        CPU_BOOST: false,
        NETWORK_TUNE: true,
        ZRAM_PRIORITY: 0,
        ZRAM_COMPRESSION_LEVEL: 6,
        ZRAM_MEMORY_LIMIT: "",
        SWAP_PRIORITY: 0,
        VM_DIRTY_WRITEBACK_CENTISECS: 500,
        VM_DIRTY_EXPIRE_CENTISECS: 3000,
        VM_PAGE_CLUSTER: 3,
        VM_LAPTOP_MODE: 0,
        VM_OOM_KILL_ALLOCATING_TASK: false,
        VM_PANIC_ON_OOM: 0,
        VM_OVERCOMMIT_MEMORY: 0,
        VM_OVERCOMMIT_RATIO: 50,
        VM_WATERMARK_SCALE_FACTOR: 10,
        KERNEL_THREADS_MAX: 0
    },
    performance: {
        ZRAM_ENABLED: true,
        SWAP_ENABLED: false,
        ZRAM_RATIO: 2.10,
        ZRAM_ALGORITHM: "zstd",
        MAX_COMP_STREAMS: 6,
        SWAPPINESS: 100,
        CACHE_PRESSURE: 45,
        PERFORMANCE_MODE: true,
        EXTRA_TUNING: false,
        DYNAMIC_SWAPPINESS: false,
        ZRAM_AUTO_TUNE: false,
        IO_SCHEDULER_TUNE: true,
        CPU_BOOST: true,
        NETWORK_TUNE: true,
        ZRAM_PRIORITY: -1,
        ZRAM_COMPRESSION_LEVEL: 9,
        ZRAM_MEMORY_LIMIT: "",
        SWAP_PRIORITY: -1,
        VM_DIRTY_WRITEBACK_CENTISECS: 100,
        VM_DIRTY_EXPIRE_CENTISECS: 1000,
        VM_PAGE_CLUSTER: 0,
        VM_LAPTOP_MODE: 0,
        VM_OOM_KILL_ALLOCATING_TASK: true,
        VM_PANIC_ON_OOM: 0,
        VM_OVERCOMMIT_MEMORY: 1,
        VM_OVERCOMMIT_RATIO: 80,
        VM_WATERMARK_SCALE_FACTOR: 100,
        KERNEL_THREADS_MAX: 16384
    },
    gaming: {
        ZRAM_ENABLED: true,
        SWAP_ENABLED: false,
        ZRAM_RATIO: 2.35,
        ZRAM_ALGORITHM: "lz4",
        MAX_COMP_STREAMS: 8,
        SWAPPINESS: 100,
        CACHE_PRESSURE: 60,
        PERFORMANCE_MODE: true,
        EXTRA_TUNING: false,
        DYNAMIC_SWAPPINESS: false,
        ZRAM_AUTO_TUNE: false,
        IO_SCHEDULER_TUNE: true,
        CPU_BOOST: true,
        NETWORK_TUNE: true,
        ZRAM_PRIORITY: -1,
        ZRAM_COMPRESSION_LEVEL: 3,
        ZRAM_MEMORY_LIMIT: "",
        SWAP_PRIORITY: -1,
        VM_DIRTY_WRITEBACK_CENTISECS: 50,
        VM_DIRTY_EXPIRE_CENTISECS: 500,
        VM_PAGE_CLUSTER: 0,
        VM_LAPTOP_MODE: 0,
        VM_OOM_KILL_ALLOCATING_TASK: true,
        VM_PANIC_ON_OOM: 0,
        VM_OVERCOMMIT_MEMORY: 1,
        VM_OVERCOMMIT_RATIO: 90,
        VM_WATERMARK_SCALE_FACTOR: 150,
        KERNEL_THREADS_MAX: 32767
    }
};

class RecommendationEngine {
    constructor(language) {
        this.language = language;
    }

    getRecommendations(config) {
        const recommendations = [];
        
        if (config.ZRAM_RATIO > 3.0) {
            recommendations.push({
                type: 'warning',
                icon: '⚠️',
                title: this.translate('High ZRAM Ratio'),
                message: this.translate('ZRAM ratio is set very high which may cause system lag'),
                action: this.translate('Consider reducing to 1.5-2.0 range')
            });
        }

        if (config.ZRAM_RATIO < 0.5) {
            recommendations.push({
                type: 'info',
                icon: '💡',
                title: this.translate('Low ZRAM Ratio'),
                message: this.translate('ZRAM ratio is quite low, you may experience app reloads'),
                action: this.translate('Consider increasing to 0.8-1.0 for better multitasking')
            });
        }

        if (config.SWAPPINESS > 100 && !config.PERFORMANCE_MODE) {
            recommendations.push({
                type: 'warning',
                icon: '⚡',
                title: this.translate('High Swappiness'),
                message: this.translate('Swappiness is set high without Performance Mode'),
                action: this.translate('Either enable Performance Mode or reduce swappiness to 60-80')
            });
        }

        if (config.SWAP_ENABLED) {
            recommendations.push({
                type: 'error',
                icon: '🚫',
                title: this.translate('Swap on Slow Storage'),
                message: this.translate('Using swap file on slow storage will degrade performance'),
                action: this.translate('Disable swap file or upgrade to faster storage')
            });
        }

        if (config.ZRAM_AUTO_TUNE && (config.EXTRA_TUNING || config.DYNAMIC_SWAPPINESS)) {
            recommendations.push({
                type: 'error',
                icon: '⚡',
                title: this.translate('Auto-tuning Conflict'),
                message: this.translate('ZRAM Auto Tune may conflict with manual tuning settings'),
                action: this.translate('Disable either Auto Tune or manual tuning features')
            });
        }

        if (config.MAX_COMP_STREAMS > 8) {
            recommendations.push({
                type: 'info',
                icon: '💡',
                title: this.translate('High Compression Streams'),
                message: this.translate('Using many compression streams may increase CPU usage'),
                action: this.translate('Set streams to match your CPU cores (usually 4-8)')
            });
        }

        return recommendations;
    }

    translate(key) {
        return translations[this.language]?.[key] || key;
    }
}

class ConfigurationHistory {
    constructor() {
        this.history = JSON.parse(localStorage.getItem('nextram_history')) || [];
    }

    saveSnapshot(config, comment = 'Manual save') {
        const snapshot = {
            id: Date.now(),
            timestamp: new Date().toLocaleString(),
            config: {...config},
            comment: comment
        };

        this.history.unshift(snapshot);
        this.history = this.history.slice(0, 5);
        localStorage.setItem('nextram_history', JSON.stringify(this.history));
        this.renderHistory();
    }

    restoreSnapshot(snapshotId) {
        const snapshot = this.history.find(s => s.id === snapshotId);
        return snapshot ? snapshot.config : null;
    }

    renderHistory() {
        const container = document.getElementById('config-history');
        if (!container) return;

        if (this.history.length === 0) {
            container.innerHTML = '<div class="history-empty">No configuration history yet</div>';
            return;
        }

        let html = '';
        this.history.forEach(snapshot => {
            html += `
                <div class="history-item" onclick="nextram.restoreConfig(${snapshot.id})">
                    <div class="history-timestamp">${snapshot.timestamp}</div>
                    <div class="history-comment">${snapshot.comment}</div>
                    <div class="history-config">
                        <span>ZRAM: ${snapshot.config.ZRAM_RATIO || 'N/A'}</span>
                        <span>Swap: ${snapshot.config.SWAPPINESS || 'N/A'}</span>
                    </div>
                </div>
            `;
        });

        container.innerHTML = html;
    }
}

class NextRAMController {
    constructor() {
        this.config = {};
        this.originalContent = "";
        this.hasRoot = false;
        this.isFormChanged = false;
        this.currentTheme = localStorage.getItem('theme') || 'auto';
        this.currentLanguage = localStorage.getItem('language') || 'en';
        this.currentAccent = localStorage.getItem('accent') || 'orange';
        this.animationsEnabled = localStorage.getItem('animationsEnabled') !== 'false';
        this.moduleStatus = null;
        this.moduleStatusChecked = false;
        this.installInProgress = false;
        this.installLog = "";
        
        this.recommendationEngine = new RecommendationEngine(this.currentLanguage);
        this.configHistory = new ConfigurationHistory();
        
        this.init();
    }

    async init() {
        setupTabs();
        this.setupTheme();
        this.setupAccentColor();
        this.setupAnimations();
        this.setupLanguage();
        this.setupFormListeners();
        this.setupParameterInfo();
        this.setupModuleFileInput();
        this.configHistory.renderHistory();
        this.updateStatus('Checking root...', false);
        await this.checkRootAccess();
        this.updateHomeStatus();
        this.generateRecommendations();
        this.checkModuleStatus();
    }

    setupModuleFileInput() {
        const fileInput = document.getElementById('module-file-input');
        if (fileInput) {
            fileInput.addEventListener('change', (e) => {
                const file = e.target.files[0];
                if (file) {
                    this.handleModuleFile(file);
                }
            });
        }
    }

    async handleModuleFile(file) {
        if (this.installInProgress) {
            this.showNotification(this.translate('Installation already in progress'), 'error');
            return;
        }

        if (!this.hasRoot) {
            this.showNotification(this.translate('Root required for module operations'), 'error');
            return;
        }

        try {
            this.installInProgress = true;
            this.showNotification(this.translate('Starting installation...'), 'info');
            
            const reader = new FileReader();
            
            reader.onload = async (e) => {
                try {
                    const tempUrl = URL.createObjectURL(file);
                    
                    if (typeof AndroidRoot !== 'undefined') {
                        AndroidRoot.clearInstallLog();
                        const success = AndroidRoot.installModule(tempUrl);
                        
                        if (success) {
                            const isUpdate = this.moduleStatus && this.moduleStatus.installed === 'true';
                            this.showNotification(
                                this.translate(isUpdate ? 'Module updated successfully' : 'Module installed successfully'), 
                                'success'
                            );
                            
                            if (typeof AndroidRoot !== 'undefined') {
                                const log = AndroidRoot.getInstallLog();
                                console.log('Install log:', log);
                            }
                        } else {
                            this.showNotification(this.translate('Installation failed'), 'error');
                            if (typeof AndroidRoot !== 'undefined') {
                                const log = AndroidRoot.getInstallLog();
                                console.error('Install failed, log:', log);
                            }
                        }
                        
                        URL.revokeObjectURL(tempUrl);
                        this.checkModuleStatus();
                    }
                } catch (error) {
                    console.error('Install error:', error);
                    this.showNotification(this.translate('Installation failed: ') + error.message, 'error');
                } finally {
                    this.installInProgress = false;
                }
            };
            
            reader.onerror = () => {
                this.showNotification(this.translate('Failed to read file'), 'error');
                this.installInProgress = false;
            };
            
            reader.readAsDataURL(file);
        } catch (error) {
            console.error('File handling error:', error);
            this.showNotification(this.translate('Installation failed'), 'error');
            this.installInProgress = false;
        }
    }

    async checkModuleStatus() {
        if (typeof AndroidRoot === 'undefined') {
            this.updateModuleStatusUI(null);
            return;
        }

        try {
            const detailsStr = AndroidRoot.getModuleDetails();
            let details = {};
            
            try {
                details = JSON.parse(detailsStr);
            } catch (e) {
                console.error('Failed to parse module details:', e);
            }
            
            this.moduleStatus = details;
            this.moduleStatusChecked = true;
            this.updateModuleStatusUI(details);
        } catch (error) {
            console.error('Error checking module status:', error);
            this.updateModuleStatusUI(null);
        }
    }

    updateModuleStatusUI(details) {
        const container = document.getElementById('module-status-container');
        const actionsContainer = document.getElementById('module-actions');
        const installBtn = document.getElementById('install-btn');
        const uninstallBtn = document.getElementById('uninstall-btn');
        const enableDisableBtn = document.getElementById('enable-disable-btn');
        
        if (!container) return;
        
        if (!this.hasRoot) {
            container.innerHTML = `
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Module Status')}</span>
                    <span class="module-status-value">${this.translate('Root required')}</span>
                </div>
            `;
            actionsContainer.style.display = 'none';
            return;
        }
        
        if (!this.moduleStatusChecked) {
            container.innerHTML = `
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Module Status')}</span>
                    <span class="module-status-value">${this.translate('Checking module...')}</span>
                </div>
            `;
            actionsContainer.style.display = 'none';
            return;
        }
        
        if (!details || details.installed === 'false') {
            container.innerHTML = `
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Status')}</span>
                    <span class="module-status-value not-installed">${this.translate('Not installed')}</span>
                </div>
            `;
            actionsContainer.style.display = 'flex';
            installBtn.textContent = this.translate('Install Module');
            uninstallBtn.style.display = 'none';
            enableDisableBtn.style.display = 'none';
            return;
        }
        
        const isEnabled = details.enabled === 'true';
        const version = details.version || 'Unknown';
        const versionCode = details.versionCode || '0';
        
        let statusHtml = `
            <div class="module-status-item">
                <span class="module-status-label">${this.translate('Status')}</span>
                <span class="module-status-value ${isEnabled ? 'enabled' : 'disabled'}">
                    ${isEnabled ? this.translate('Enabled') : this.translate('Disabled')}
                </span>
            </div>
            <div class="module-status-item">
                <span class="module-status-label">${this.translate('Version')}</span>
                <span class="module-status-value">${version} (${versionCode})</span>
            </div>
        `;
        
        container.innerHTML = statusHtml;
        actionsContainer.style.display = 'flex';
        
        installBtn.textContent = this.translate('Update Module');
        uninstallBtn.style.display = 'inline-block';
        enableDisableBtn.style.display = 'inline-block';
        enableDisableBtn.textContent = isEnabled ? this.translate('Disable') : this.translate('Enable');
        enableDisableBtn.className = isEnabled ? 'btn btn-small btn-secondary' : 'btn btn-small btn-primary';
    }

    setupParameterInfo() {
        const infoButtons = document.querySelectorAll('.info-btn');
        const modal = document.getElementById('paramInfoModal');
        const closeBtn = document.querySelector('.modal-close');
        const modalTitle = document.getElementById('modalParamTitle');
        const modalDescription = document.getElementById('modalParamDescription');

        infoButtons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const paramId = e.target.getAttribute('data-param');
                const description = spl.getDescription(paramId);
                
                if (description) {
                    modalTitle.textContent = description.title;
                    modalDescription.textContent = description.description;
                    modal.style.display = 'block';
                }
            });
        });

        closeBtn.addEventListener('click', () => {
            modal.style.display = 'none';
        });

        window.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.style.display = 'none';
            }
        });
    }

    setupTheme() {
        if (this.currentTheme === 'auto') {
            this.applyAutoTheme();
        } else {
            document.documentElement.setAttribute('data-theme', this.currentTheme);
        }
        
        document.getElementById('THEME').value = this.currentTheme;
        
        if (this.currentTheme === 'auto' && window.matchMedia) {
            window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
                if (this.currentTheme === 'auto') this.applyAutoTheme();
            });
        }
    }

    setupAccentColor() {
        document.documentElement.setAttribute('data-accent', this.currentAccent);
        document.getElementById('ACCENT_COLOR').value = this.currentAccent;
    }

    setupAnimations() {
        document.getElementById('ANIMATIONS_ENABLED').checked = this.animationsEnabled;
        if (!this.animationsEnabled) {
            document.body.classList.add('animations-disabled');
        }
    }

    applyAutoTheme() {
        const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
    }

    setupLanguage() {
        document.getElementById('LANGUAGE').value = this.currentLanguage;
        this.updateLanguage();
    }

    updateLanguage() {
        const elements = document.querySelectorAll('[data-translate]');
        elements.forEach(element => {
            const key = element.getAttribute('data-translate');
            if (translations[this.currentLanguage]?.[key]) {
                element.textContent = translations[this.currentLanguage][key];
            }
        });
        
        this.recommendationEngine.language = this.currentLanguage;
        
        if (window.spl) {
            window.spl.setLanguage(this.currentLanguage);
        }
        
        this.generateRecommendations();
        
        if (window.faqManager) {
            window.faqManager.renderFAQ();
        }
        
        this.checkModuleStatus();
    }

    setupFormListeners() {
        const inputs = document.querySelectorAll('input, select');
        inputs.forEach(input => {
            if (!['THEME', 'LANGUAGE', 'ACCENT_COLOR', 'ANIMATIONS_ENABLED'].includes(input.id)) {
                input.addEventListener('change', () => this.onFormChange());
            }
        });

        document.getElementById('THEME').addEventListener('change', (e) => {
            this.currentTheme = e.target.value;
            localStorage.setItem('theme', this.currentTheme);
            this.setupTheme();
        });

        document.getElementById('LANGUAGE').addEventListener('change', (e) => {
            this.currentLanguage = e.target.value;
            localStorage.setItem('language', this.currentLanguage);
            this.updateLanguage();
        });

        document.getElementById('ACCENT_COLOR').addEventListener('change', (e) => {
            this.currentAccent = e.target.value;
            localStorage.setItem('accent', this.currentAccent);
            this.setupAccentColor();
        });

        document.getElementById('ANIMATIONS_ENABLED').addEventListener('change', (e) => {
            this.animationsEnabled = e.target.checked;
            localStorage.setItem('animationsEnabled', this.animationsEnabled);
            if (this.animationsEnabled) {
                document.body.classList.remove('animations-disabled');
            } else {
                document.body.classList.add('animations-disabled');
            }
        });
    }

    updateHomeStatus() {
        const rootStatus = document.getElementById('home-root-status');
        const zramStatus = document.getElementById('home-zram-status');
        const swapStatus = document.getElementById('home-swap-status');
        
        if (rootStatus) rootStatus.textContent = this.hasRoot ? 'Granted' : 'Required';
        if (zramStatus) zramStatus.textContent = document.getElementById('ZRAM_ENABLED')?.checked ? 'Enabled' : 'Disabled';
        if (swapStatus) swapStatus.textContent = document.getElementById('SWAP_ENABLED')?.checked ? 'Enabled' : 'Disabled';
    }

    generateRecommendations() {
        const currentConfig = this.gatherFormData();
        const recommendations = this.recommendationEngine.getRecommendations(currentConfig);
        const container = document.getElementById('recommendations-list');
        
        if (!container) return;

        if (recommendations.length === 0) {
            container.innerHTML = `<div class="recommendation info">${this.translate('Your configuration looks good!')}</div>`;
            return;
        }

        container.innerHTML = recommendations.map(rec => `
            <div class="recommendation ${rec.type}">
                <div class="recommendation-header">
                    <span>${rec.icon}</span>
                    <span>${rec.title}</span>
                </div>
                <div class="recommendation-message">${rec.message}</div>
                <div class="recommendation-action">${rec.action}</div>
            </div>
        `).join('');
    }

    applyProfile(profileName) {
        const profile = performanceProfiles[profileName];
        if (!profile) return;

        Object.keys(profile).forEach(key => {
            const element = document.getElementById(key);
            if (element) {
                element.type === 'checkbox' ? element.checked = profile[key] : element.value = profile[key];
            }
        });

        this.onFormChange();
        this.showNotification(`${this.translate('Applied')} ${this.translate(profileName)} ${this.translate('profile')}`, 'success');
    }

    saveCurrentConfig() {
        const config = this.gatherFormData();
        const comment = prompt(this.translate('Enter a description for this configuration:'), this.translate('Manual save'));
        if (comment) {
            this.configHistory.saveSnapshot(config, comment);
            this.showNotification(this.translate('Configuration saved to history'), 'success');
        }
    }

    restoreConfig(snapshotId) {
        const config = this.configHistory.restoreSnapshot(snapshotId);
        if (config) {
            this.populateForm(config);
            this.showNotification(this.translate('Configuration restored from history'), 'success');
        }
    }

    onFormChange() {
        this.isFormChanged = true;
        this.showSaveButton();
        this.generateRecommendations();
    }

    showSaveButton() {
        document.getElementById('saveButtonContainer').style.display = 'block';
    }

    hideSaveButton() {
        document.getElementById('saveButtonContainer').style.display = 'none';
    }

    async checkRootAccess() {
        try {
            this.updateStatus('Checking root access...', false);
            if (typeof AndroidRoot !== 'undefined') {
                this.hasRoot = AndroidRoot.hasRootAccess();
                this.updateRootStatus();
                
                if (this.hasRoot) {
                    this.showNotification(this.translate('Root access granted'), 'success');
                    await this.loadConfig();
                } else {
                    this.showNotification(this.translate('Root access required'), 'error');
                }
            } else {
                this.hasRoot = false;
                this.updateRootStatus();
                this.showNotification(this.translate('Android interface not available'), 'error');
            }
        } catch (error) {
            this.hasRoot = false;
            this.updateRootStatus();
            this.showNotification(this.translate('Root check error: ') + error.message, 'error');
        }
    }

    updateRootStatus() {
        const statusElement = document.getElementById('rootStatus');
        const warningElement = document.getElementById('rootWarning');
        if (statusElement) {
            statusElement.textContent = this.hasRoot ? 'Root: Granted' : 'Root: Access Required';
        }
        if (warningElement) {
            warningElement.style.display = this.hasRoot ? 'none' : 'flex';
        }
    }

    async loadConfig() {
        try {
            this.updateStatus(this.translate('Loading configuration'), false);
            if (typeof AndroidRoot !== 'undefined') {
                const content = AndroidRoot.readServiceSh();
                if (content.startsWith('ERROR:')) throw new Error(content);
                
                this.originalContent = content;
                this.parseConfigFromContent(content);
                this.updateStatus(this.translate('Ready'), true);
                this.showNotification(this.translate('Configuration loaded successfully'), 'success');
            } else {
                throw new Error(this.translate('Android interface not available'));
            }
        } catch (error) {
            this.updateStatus(this.translate('Error'), false);
            this.showNotification(error.message, 'error');
        }
    }

    parseConfigFromContent(content) {
        const config = {};
        content.split('\n').forEach(line => {
            const match = line.match(/^([A-Z_]+)=([^#]+)/);
            if (match) {
                const key = match[1].trim();
                let value = match[2].trim().replace(/["']/g, '');
                if (value === 'true') value = true;
                else if (value === 'false') value = false;
                else if (!isNaN(value)) value = parseFloat(value);
                config[key] = value;
            }
        });
        this.config = config;
        this.populateForm(this.config);
    }

    populateForm(config) {
        Object.keys(config).forEach(key => {
            const element = document.getElementById(key);
            if (element) {
                element.type === 'checkbox' ? element.checked = config[key] : element.value = config[key];
            }
        });
        this.generateRecommendations();
    }

    gatherFormData() {
        const config = {};
        document.querySelectorAll('input, select').forEach(element => {
            config[element.name] = element.type === 'checkbox' ? element.checked : element.value;
        });
        return config;
    }

    patchServiceSh(content, config) {
        let newContent = content;
        Object.entries(config).forEach(([key, value]) => {
            const regex = new RegExp(`^${key}=.*`, 'm');
            const newLine = `${key}=${value}`;
            newContent = regex.test(newContent) ? newContent.replace(regex, newLine) : newLine + '\n' + newContent;
        });
        return newContent;
    }

    async saveChanges() {
        try {
            if (this.isFormChanged) {
                const newConfig = this.gatherFormData();
                const patchedContent = this.patchServiceSh(this.originalContent, newConfig);
                if (typeof AndroidRoot !== 'undefined' && AndroidRoot.writeServiceSh(patchedContent)) {
                    this.originalContent = patchedContent;
                    this.config = newConfig;
                    this.isFormChanged = false;
                    this.hideSaveButton();
                    this.showNotification(this.translate("Configuration saved. Please reboot your device."), 'success');
                } else {
                    throw new Error(this.translate('Failed to write service.sh'));
                }
            }
        } catch (error) {
            this.showNotification(error.message, 'error');
        }
    }

    updateStatus(message, isOnline) {
        const statusText = document.getElementById('statusText');
        const indicator = document.getElementById('statusIndicator');
        if (statusText) statusText.textContent = message;
        if (indicator) indicator.style.background = isOnline ? '#059669' : '#dc2626';
    }

    showNotification(message, type) {
        if (typeof AndroidRoot !== 'undefined') AndroidRoot.showToast(message);
        
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.style.background = type === 'success' ? '#059669' : '#dc2626';
        notification.textContent = message;
        document.body.appendChild(notification);
        setTimeout(() => notification.remove(), 3000);
    }

    translate(key) {
        return translations[this.currentLanguage]?.[key] || key;
    }
}

const nextram = new NextRAMController();

document.getElementById('saveButton').addEventListener('click', () => {
    nextram.saveChanges();
    nextram.updateHomeStatus();
});

function checkRootAccess() {
    nextram.checkRootAccess();
    nextram.updateHomeStatus();
}

function installModule() {
    if (nextram.installInProgress) {
        nextram.showNotification(nextram.translate('Installation already in progress'), 'error');
        return;
    }
    
    const fileInput = document.getElementById('module-file-input');
    if (fileInput) {
        fileInput.value = '';
        fileInput.click();
    }
}

async function uninstallModule() {
    if (typeof AndroidRoot !== 'undefined') {
        const confirmed = confirm(nextram.translate('Are you sure you want to uninstall the module?'));
        if (confirmed) {
            const success = AndroidRoot.uninstallModule();
            if (success) {
                nextram.showNotification(nextram.translate('Module uninstalled successfully'), 'success');
                nextram.moduleStatus = { installed: 'false', enabled: 'false' };
                nextram.moduleStatusChecked = true;
                nextram.updateModuleStatusUI(nextram.moduleStatus);
                setTimeout(() => {
                    nextram.checkModuleStatus();
                }, 1000);
            } else {
                nextram.showNotification(nextram.translate('Uninstallation failed'), 'error');
            }
        }
    }
}

async function enableDisableModule() {
    if (typeof AndroidRoot !== 'undefined' && nextram.moduleStatus && nextram.moduleStatus.installed === 'true') {
        const isEnabled = nextram.moduleStatus.enabled === 'true';
        
        let success = false;
        if (isEnabled) {
            success = AndroidRoot.disableModule();
        } else {
            success = AndroidRoot.enableModule();
        }
        
        if (success) {
            nextram.showNotification(
                isEnabled ? nextram.translate('Module disabled') : nextram.translate('Module enabled'), 
                'success'
            );
            setTimeout(() => {
                nextram.checkModuleStatus();
            }, 1000);
        } else {
            nextram.showNotification(nextram.translate('Operation failed'), 'error');
        }
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const fileInput = document.getElementById('module-file-input');
    if (fileInput) {
        fileInput.addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (file) {
                if (!file.name.endsWith('.zip')) {
                    nextram.showNotification(nextram.translate('Please select a ZIP file'), 'error');
                    return;
                }
                nextram.handleModuleFile(file);
            }
        });
    }
});