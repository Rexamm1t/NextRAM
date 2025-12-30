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
                nextram.checkModuleStatus();
            } else if (targetTab === 'store') {
                nextram.loadStoreConfigs();
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
        nextram.checkModuleStatus();
    } else if (tabName === 'store') {
        nextram.loadStoreConfigs();
    }
}

const translations = {
    en: {
        "Store": "Store",
        "NextRAM Configuration Store": "NextRAM Configuration Store",
        "About the Store": "About the Store",
        "Configurations are loaded from the official GitHub repository. All configurations are community-created and tested.": "Configurations are loaded from the official GitHub repository. All configurations are community-created and tested.",
        "Source:": "Source:",
        "Loading configurations from GitHub...": "Loading configurations from GitHub...",
        "No configurations found in store.": "No configurations found in store.",
        "Visit repository": "Visit repository",
        "Error loading configurations": "Error loading configurations",
        "Retry": "Retry",
        "configurations loaded from GitHub": "configurations loaded from GitHub",
        "New": "New",
        "Loading from GitHub...": "Loading from GitHub...",
        "Device": "Device",
        "Created": "Created",
        "Configuration preview:": "Configuration preview:",
        "Apply Configuration": "Apply Configuration",
        "Loaded from GitHub repository": "Loaded from GitHub repository",
        "Configuration applied to form.": "Configuration applied to form.",
        "settings updated. Click Save to apply.": "settings updated. Click Save to apply.",
        "Configuration file not found": "Configuration file not found",
        "No valid configuration found in file": "No valid configuration found in file",
        "Module Status": "Module Status",
        "Checking module...": "Checking module...",
        "Enable": "Enable",
        "Disable": "Disable",
        "Not installed": "Not installed",
        "Installed": "Installed",
        "Active": "Active",
        "Enabled": "Enabled",
        "Disabled": "Disabled",
        "Version": "Version",
        "Version Code": "Version Code",
        "Frontend developer, community representative": "Frontend developer, community representative",
        "Tester": "Tester",
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
        "2 (Disabled)": "2 (Disabled)",
        "Author": "Author",
        "Module not found": "Module not found",
        "Install via Magisk Manager": "Install via Magisk Manager",
        "Delete configuration": "Delete configuration",
        "Are you sure you want to delete this configuration?": "Are you sure you want to delete this configuration?",
        "Configuration deleted": "Configuration deleted",
        "Failed to delete configuration": "Failed to delete configuration",
        "Apply & Save": "Apply & Save",
        "Configuration applied and saved successfully": "Configuration applied and saved successfully",
        "Configuration not found": "Configuration not found",
        "Root access required to apply configuration": "Root access required to apply configuration",
        "Operation failed": "Operation failed",
        "Configuration Import/Export": "Configuration Import/Export",
        "Export Configuration": "Export Configuration",
        "Import Configuration": "Import Configuration",
        "Config file path:": "Config file path:",
        "Interface Appearance": "Interface Appearance",
        "Glass Effect": "Glass Effect",
        "Material You": "Material You",
        "Semi-transparent interface": "Semi-transparent interface",
        "Dynamic system colors": "Dynamic system colors",
        "Note:": "Note:",
        "Material You requires Android 12+ and compatible system theme": "Material You requires Android 12+ and compatible system theme",
        "Configuration exported successfully": "Configuration exported successfully",
        "Configuration imported successfully": "Configuration imported successfully",
        "Failed to export configuration": "Failed to export configuration",
        "Failed to import configuration": "Failed to import configuration",
        "Export failed": "Export failed",
        "Import failed": "Import failed",
        "Authors": "Authors",
        "Description": "Description",
        "Disabled": "Disabled",
        "ID": "ID",
        "Root required": "Root required",
        "Status": "Status",
        "Tested On": "Tested On",
        "Created With": "Created With",
        "Export not supported": "Export not supported",
        "Failed to read current config": "Failed to read current config",
        "Save to History": "Save to History",
        "Note: Material You requires Android 12+ and compatible system theme": "Note: Material You requires Android 12+ and compatible system theme"
    },
    ru: {
        "Store": "Магазин",
        "NextRAM Configuration Store": "Магазин конфигураций NextRAM",
        "About the Store": "О магазине",
        "Configurations are loaded from the official GitHub repository. All configurations are community-created and tested.": "Конфигурации загружаются из официального репозитория GitHub. Все конфигурации созданы и протестированы сообществом.",
        "Source:": "Источник:",
        "Loading configurations from GitHub...": "Загрузка конфигураций из GitHub...",
        "No configurations found in store.": "Конфигурации не найдены в магазине.",
        "Visit repository": "Посетить репозиторий",
        "Error loading configurations": "Ошибка загрузки конфигураций",
        "Retry": "Повторить",
        "configurations loaded from GitHub": "конфигураций загружено из GitHub",
        "New": "Новое",
        "Loading from GitHub...": "Загрузка из GitHub...",
        "Device": "Устройство",
        "Created": "Создано",
        "Configuration preview:": "Предпросмотр конфигурации:",
        "Apply Configuration": "Применить конфигурацию",
        "Loaded from GitHub repository": "Загружено из репозитория GitHub",
        "Configuration applied to form.": "Конфигурация применена к форме.",
        "settings updated. Click Save to apply.": "настроек обновлено. Нажмите Сохранить для применения.",
        "Configuration file not found": "Файл конфигурации не найден",
        "No valid configuration found in file": "В файле не найдено корректной конфигурации",
        "Module Status": "Статус модуля",
        "Checking module...": "Проверка модуля...",
        "Enable": "Включить",
        "Disable": "Выключить",
        "Not installed": "Не установлен",
        "Installed": "Установлен",
        "Active": "Активен",
        "Enabled": "Включен",
        "Disabled": "Выключен",
        "Version": "Версия",
        "Version Code": "Код версии",
        "Frontend developer, community representative": "Фронтенд разработчик, представитель комьюнити",
        "Tester": "Тестер",
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
        "Perfect balance between performance and battery life": "Идельный баланс между производительностью и временем работы от батареи",
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
        "Set streams to match your CPU cores (обычно 4-8)": "Установите количество потоков по числу ядер CPU (обычно 4-8)",
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
        "2 (Disabled)": "2 (Выключено)",
        "Author": "Автор",
        "Module not found": "Модуль не найден",
        "Install via Magisk Manager": "Установить через Magisk Manager",
        "Delete configuration": "Удалить конфигурацию",
        "Are you sure you want to delete this configuration?": "Вы уверены, что хотите удалить эту конфигурацию?",
        "Configuration deleted": "Конфигурация удалена",
        "Failed to delete configuration": "Ошибка удаления конфигурации",
        "Apply & Save": "Применить и сохранить",
        "Configuration applied and saved successfully": "Конфигурация применена и сохранена успешно",
        "Configuration not found": "Конфигурация не найдена",
        "Root access required to apply configuration": "Требуется root доступ для применения конфигурации",
        "Operation failed": "Операция не выполнена",
        "Configuration Import/Export": "Импорт/Экспорт конфигурации",
        "Export Configuration": "Экспорт конфигурации",
        "Import Configuration": "Импорт конфигурации",
        "Config file path:": "Путь к файлу конфигурации:",
        "Interface Appearance": "Внешний вид интерфейса",
        "Glass Effect": "Стеклянный эффект",
        "Material You": "Material You",
        "Semi-transparent interface": "Полупрозрачный интерфейс",
        "Dynamic system colors": "Динамические системные цвета",
        "Note:": "Примечание:",
        "Material You requires Android 12+ and compatible system theme": "Material You требует Android 12+ и совместимую системную тему",
        "Configuration exported successfully": "Конфигурация успешно экспортирована",
        "Configuration imported successfully": "Конфигурация успешно импортирована",
        "Failed to export configuration": "Не удалось экспортировать конфигурацию",
        "Failed to import configuration": "Не удалось импортировать конфигурацию",
        "Export failed": "Ошибка экспорта",
        "Import failed": "Ошибка импорта",
        "Authors": "Авторы",
        "Description": "Описание",
        "Active": "Активен",
        "Disabled": "Отключен",
        "ID": "ID",
        "Root required": "Требуется root",
        "Status": "Статус",
        "Tested On": "Тестировано на",
        "Created With": "Создано с",
        "Export not supported": "Экспорт не поддерживается",
        "Failed to read current config": "Не удалось прочитать текущую конфигурацию",
        "Save to History": "Сохранить в историю",
        "Note: Material You requires Android 12+ and compatible system theme": "Примечание: Material You требует Android 12+ и совместимую системную тему"
    },
    uk: {
        "Store": "Магазин",
        "NextRAM Configuration Store": "Магазин конфігурацій NextRAM",
        "About the Store": "Про магазин",
        "Configurations are loaded from the official GitHub repository. All configurations are community-created and tested.": "Конфігурації завантажуються з офіційного репозиторію GitHub. Усі конфігурації створені та протестовані спільнотою.",
        "Source:": "Джерело:",
        "Loading configurations from GitHub...": "Завантаження конфігурацій з GitHub...",
        "No configurations found in store.": "Конфігурації не знайдено в магазині.",
        "Visit repository": "Відвідати репозиторій",
        "Error loading configurations": "Помилка завантаження конфігурацій",
        "Retry": "Повторити",
        "configurations loaded from GitHub": "конфігурацій завантажено з GitHub",
        "New": "Нове",
        "Loading from GitHub...": "Завантаження з GitHub...",
        "Device": "Пристрій",
        "Created": "Створено",
        "Configuration preview:": "Попередній перегляд конфігурації:",
        "Apply Configuration": "Застосувати конфігурацію",
        "Loaded from GitHub repository": "Завантажено з репозиторію GitHub",
        "Configuration applied to form.": "Конфігурацію застосовано до форми.",
        "settings updated. Click Save to apply.": "налаштувань оновлено. Натисніть Зберегти для застосування.",
        "Configuration file not found": "Файл конфігурації не знайдено",
        "No valid configuration found in file": "У файлі не знайдено коректної конфігурації",
        "Module Status": "Статус модуля",
        "Checking module...": "Перевірка модуля...",
        "Enable": "Увімкнути",
        "Disable": "Вимкнути",
        "Not installed": "Не встановлено",
        "Installed": "Встановлено",
        "Active": "Активний",
        "Enabled": "Увімкнено",
        "Disabled": "Вимкнено",
        "Version": "Версія",
        "Version Code": "Код версії",
        "Frontend developer, community representative": "Фронтенд розробник, представник спільноти",
        "Tester": "Тестувальник",
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
        "2 (Disabled)": "2 (Вимкнено)",
        "Author": "Автор",
        "Module not found": "Модуль не знайдено",
        "Install via Magisk Manager": "Встановити через Magisk Manager",
        "Delete configuration": "Видалити конфігурацію",
        "Are you sure you want to delete this configuration?": "Ви впевнені, що хочете видалити цю конфігурацію?",
        "Configuration deleted": "Конфігурацію видалено",
        "Failed to delete configuration": "Помилка видалення конфігурації",
        "Apply & Save": "Застосувати та зберегти",
        "Configuration applied and saved successfully": "Конфігурацію застосовано та збережено успішно",
        "Configuration not found": "Конфігурацію не знайдено",
        "Root access required to apply configuration": "Потрібен root доступ для застосування конфігурації",
        "Operation failed": "Операція не виконана",
        "Configuration Import/Export": "Імпорт/Експорт конфігурації",
        "Export Configuration": "Експорт конфігурації",
        "Import Configuration": "Імпорт конфігурації",
        "Config file path:": "Шлях до файлу конфігурації:",
        "Interface Appearance": "Зовнішній вигляд інтерфейсу",
        "Glass Effect": "Скляний ефект",
        "Material You": "Material You",
        "Semi-transparent interface": "Напівпрозорий інтерфейс",
        "Dynamic system colors": "Динамічні системні кольори",
        "Note:": "Примітка:",
        "Material You requires Android 12+ and compatible system theme": "Material You потребує Android 12+ та сумісної системної теми",
        "Configuration exported successfully": "Конфігурацію успішно експортовано",
        "Configuration imported successfully": "Конфігурацію успішно імпортовано",
        "Failed to export configuration": "Не вдалося експортувати конфігурацію",
        "Failed to import configuration": "Не вдалося імпортувати конфігурацію",
        "Export failed": "Помилка експорту",
        "Import failed": "Помилка імпорту",
        "Authors": "Автори",
        "Description": "Опис",
        "Active": "Активний",
        "Disabled": "Вимкнено",
        "ID": "ID",
        "Root required": "Потрібен root",
        "Status": "Статус",
        "Tested On": "Тестовано на",
        "Created With": "Створено з",
        "Export not supported": "Експорт не підтримується",
        "Failed to read current config": "Не вдалося прочитати поточну конфігурацію",
        "Save to History": "Зберегти в історію",
        "Note: Material You requires Android 12+ and compatible system theme": "Примітка: Material You потребує Android 12+ та сумісної системної теми"
    },
    zh: {
        "Store": "商店",
        "NextRAM Configuration Store": "NextRAM 配置商店",
        "About the Store": "关于商店",
        "Configurations are loaded from the official GitHub repository. All configurations are community-created and tested.": "配置从官方 GitHub 仓库加载。所有配置均由社区创建和测试。",
        "Source:": "来源:",
        "Loading configurations from GitHub...": "从 GitHub 加载配置...",
        "No configurations found in store.": "商店中未找到配置。",
        "Visit repository": "访问仓库",
        "Error loading configurations": "加载配置时出错",
        "Retry": "重试",
        "configurations loaded from GitHub": "个配置从 GitHub 加载",
        "New": "新",
        "Loading from GitHub...": "从 GitHub 加载...",
        "Device": "设备",
        "Created": "创建于",
        "Configuration preview:": "配置预览:",
        "Apply Configuration": "应用配置",
        "Loaded from GitHub repository": "从 GitHub 仓库加载",
        "Configuration applied to form.": "配置已应用到表单。",
        "settings updated. Click Save to apply.": "个设置已更新。点击保存以应用。",
        "Configuration file not found": "配置文件未找到",
        "No valid configuration found in file": "文件中未找到有效配置",
        "Module Status": "模块状态",
        "Checking module...": "检查模块...",
        "Enable": "启用",
        "Disable": "禁用",
        "Not installed": "未安装",
        "Installed": "已安装",
        "Active": "活跃",
        "Enabled": "已启用",
        "Disabled": "已禁用",
        "Version": "版本",
        "Version Code": "版本代码",
        "Frontend developer, community representative": "前端开发者，社区代表",
        "Tester": "测试员",
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
        "2 (Disabled)": "2 (禁用)",
        "Author": "作者",
        "Module not found": "模块未找到",
        "Install via Magisk Manager": "通过 Magisk Manager 安装",
        "Delete configuration": "删除配置",
        "Are you sure you want to delete this configuration?": "您确定要删除此配置吗？",
        "Configuration deleted": "配置已删除",
        "Failed to delete configuration": "删除配置失败",
        "Apply & Save": "应用并保存",
        "Configuration applied and saved successfully": "配置已应用并成功保存",
        "Configuration not found": "配置未找到",
        "Root access required to apply configuration": "应用配置需要 Root 权限",
        "Operation failed": "操作失败",
        "Configuration Import/Export": "配置导入/导出",
        "Export Configuration": "导出配置",
        "Import Configuration": "导入配置",
        "Config file path:": "配置文件路径:",
        "Interface Appearance": "界面外观",
        "Glass Effect": "玻璃效果",
        "Material You": "Material You",
        "Semi-transparent interface": "半透明界面",
        "Dynamic system colors": "动态系统颜色",
        "Note:": "注意:",
        "Material You requires Android 12+ and compatible system theme": "Material You 需要 Android 12+ 和兼容的系统主题",
        "Configuration exported successfully": "配置导出成功",
        "Configuration imported successfully": "配置导入成功",
        "Failed to export configuration": "导出配置失败",
        "Failed to import configuration": "导入配置失败",
        "Export failed": "导出失败",
        "Import failed": "导入失败",
        "Authors": "作者",
        "Description": "描述",
        "Active": "活跃",
        "Disabled": "已禁用",
        "ID": "ID",
        "Root required": "需要 Root",
        "Status": "状态",
        "Tested On": "测试于",
        "Created With": "创建使用",
        "Export not supported": "导出不支持",
        "Failed to read current config": "读取当前配置失败",
        "Save to History": "保存到历史记录",
        "Note: Material You requires Android 12+ and compatible system theme": "注意：Material You 需要 Android 12+ 和兼容的系统主题"
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
        this.history = this.history.slice(0, 10);
        localStorage.setItem('nextram_history', JSON.stringify(this.history));
        this.renderHistory();
    }

    restoreSnapshot(snapshotId) {
        const snapshot = this.history.find(s => s.id === snapshotId);
        return snapshot ? snapshot.config : null;
    }

    deleteSnapshot(snapshotId) {
        const index = this.history.findIndex(s => s.id === snapshotId);
        if (index !== -1) {
            this.history.splice(index, 1);
            localStorage.setItem('nextram_history', JSON.stringify(this.history));
            this.renderHistory();
            return true;
        }
        return false;
    }

    renderHistory() {
        const container = document.getElementById('config-history');
        if (!container) return;

        if (this.history.length === 0) {
            container.innerHTML = '<div class="history-empty" data-translate="No configuration history yet">No configuration history yet</div>';
            return;
        }

        let html = '';
        this.history.forEach(snapshot => {
            html += `
                <div class="history-item">
                    <div class="history-header">
                        <div class="history-timestamp">${snapshot.timestamp}</div>
                        <button class="history-delete-btn" onclick="nextram.deleteConfig(${snapshot.id})" title="${nextram.translate('Delete configuration')}">×</button>
                    </div>
                    <div class="history-comment">${snapshot.comment}</div>
                    <div class="history-config">
                        <span>ZRAM: ${snapshot.config.ZRAM_RATIO || 'N/A'}</span>
                        <span>Swappiness: ${snapshot.config.SWAPPINESS || 'N/A'}</span>
                        <span>${snapshot.config.ZRAM_ENABLED ? 'ZRAM: On' : 'ZRAM: Off'}</span>
                    </div>
                    <button class="btn btn-small btn-primary" onclick="nextram.applySavedConfig(${snapshot.id})" style="margin-top: 8px; width: 100%;">
                        ${nextram.translate('Apply & Save')}
                    </button>
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
        this.setupAppearanceSettings();
        this.configHistory.renderHistory();
        this.updateStatus('Checking root...', false);
        await this.reliableRootCheck();
        this.updateHomeStatus();
        this.generateRecommendations();
        this.checkModuleStatus();
    }

    applyMaterialYouSystemColors() {
        if (!document.getElementById('MATERIAL_YOU').checked) {
            document.body.classList.remove('material-you');
            document.documentElement.style.removeProperty('--md-primary');
            document.documentElement.style.removeProperty('--md-primary-container');
            return;
        }
        
        const userAgent = navigator.userAgent || navigator.vendor || window.opera;
        const androidMatch = userAgent.match(/Android\s+([0-9.]+)/);
        
        if (androidMatch && parseFloat(androidMatch[1]) >= 12) {
            document.body.classList.add('material-you');
            
            document.documentElement.style.setProperty('--md-primary', 'var(--material-you-primary, #6750A4)');
            document.documentElement.style.setProperty('--md-primary-container', 'var(--material-you-primary-container, #EADDFF)');
            document.documentElement.style.setProperty('--md-on-primary', 'var(--material-you-on-primary, #FFFFFF)');
            document.documentElement.style.setProperty('--md-secondary', 'var(--material-you-secondary, #625B71)');
            document.documentElement.style.setProperty('--md-secondary-container', 'var(--material-you-secondary-container, #E8DEF8)');
            
            setTimeout(() => {
                if (!getComputedStyle(document.documentElement).getPropertyValue('--md-primary')) {
                    this.applyMaterialYouColors();
                }
            }, 100);
        } else {
            this.applyMaterialYouColors();
        }
    }

    async reliableRootCheck() {
        if (typeof AndroidRoot === 'undefined') {
            this.hasRoot = false;
            this.updateRootStatus();
            this.showNotification(this.translate('Android interface not available'), 'error');
            return;
        }

        for (let i = 0; i < 3; i++) {
            try {
                this.hasRoot = AndroidRoot.hasRootAccess();
                if (this.hasRoot) {
                    const testResult = AndroidRoot.testRoot();
                    if (testResult && !testResult.startsWith('ERROR:')) {
                        this.updateRootStatus();
                        this.showNotification(this.translate('Root access granted'), 'success');
                        await this.loadConfig();
                        return;
                    }
                }
                
                if (i < 2) {
                    await new Promise(resolve => setTimeout(resolve, 500));
                }
            } catch (error) {
                console.error(`Root check ${i + 1} failed:`, error);
            }
        }
        
        this.hasRoot = false;
        this.updateRootStatus();
        this.showNotification(this.translate('Root access required'), 'warning');
    }

    setupTabs() {
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
                    this.checkModuleStatus();
                } else if (targetTab === 'store') {
                    this.loadStoreConfigs();
                }
            });
        });
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
            if (!['THEME', 'LANGUAGE', 'ACCENT_COLOR', 'ANIMATIONS_ENABLED', 'GLASS_EFFECT', 'MATERIAL_YOU'].includes(input.id)) {
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

    setupAppearanceSettings() {
        if (typeof AndroidRoot !== 'undefined') {
            try {
                const settings = AndroidRoot.getAppearanceSettings();
                if (settings) {
                    const data = JSON.parse(settings);
                    if (data.glass_effect !== undefined) {
                        document.getElementById('GLASS_EFFECT').checked = data.glass_effect;
                    }
                    if (data.material_you !== undefined) {
                        document.getElementById('MATERIAL_YOU').checked = data.material_you;
                    }
                    if (data.accent_color) {
                        document.getElementById('ACCENT_COLOR').value = data.accent_color;
                        this.currentAccent = data.accent_color;
                        document.documentElement.setAttribute('data-accent', data.accent_color);
                    }
                    this.applyAppearanceSettings(data.glass_effect || false, data.material_you || false);
                } else {
                    this.loadLocalAppearanceSettings();
                }
            } catch (e) {
                console.error("Error parsing appearance settings:", e);
                this.loadLocalAppearanceSettings();
            }
        } else {
            this.loadLocalAppearanceSettings();
        }
        
        document.getElementById('GLASS_EFFECT').addEventListener('change', (e) => {
            this.saveAppearanceSettings();
        });
        
        document.getElementById('MATERIAL_YOU').addEventListener('change', (e) => {
            this.saveAppearanceSettings();
        });
    }

    loadLocalAppearanceSettings() {
        const glassEffect = localStorage.getItem('glass_effect') === 'true';
        const materialYou = localStorage.getItem('material_you') === 'true';
        
        document.getElementById('GLASS_EFFECT').checked = glassEffect;
        document.getElementById('MATERIAL_YOU').checked = materialYou;
        
        this.applyAppearanceSettings(glassEffect, materialYou);
    }

    saveAppearanceSettings() {
        const glassEffect = document.getElementById('GLASS_EFFECT').checked;
        const materialYou = document.getElementById('MATERIAL_YOU').checked;
        const accentColor = document.getElementById('ACCENT_COLOR').value;
        
        if (typeof AndroidRoot !== 'undefined') {
            AndroidRoot.setAppearanceSettings(
                glassEffect.toString(),
                materialYou.toString()
            );
        }
        
        localStorage.setItem('glass_effect', glassEffect);
        localStorage.setItem('material_you', materialYou);
        localStorage.setItem('accent', accentColor);
        
        this.applyAppearanceSettings(glassEffect, materialYou);
        
        if (materialYou) {
            this.applyMaterialYouSystemColors();
        }
    }

    applyAppearanceSettings(glassEffect, materialYou) {
        if (glassEffect) {
            document.body.classList.add('glass-effect');
            document.querySelectorAll('.card').forEach(card => {
                card.classList.add('glass-card');
            });
        } else {
            document.body.classList.remove('glass-effect');
            document.querySelectorAll('.card').forEach(card => {
                card.classList.remove('glass-card');
            });
        }
        
        if (materialYou) {
            this.applyMaterialYouSystemColors();
        } else {
            document.body.classList.remove('material-you');
            document.documentElement.style.setProperty('--md-primary', '');
            document.documentElement.style.setProperty('--md-primary-container', '');
            document.documentElement.style.setProperty('--md-on-primary', '');
            document.documentElement.style.setProperty('--md-secondary', '');
            document.documentElement.style.setProperty('--md-secondary-container', '');
        }
    }

    applyMaterialYouColors() {
        if (!document.getElementById('MATERIAL_YOU').checked) {
            document.body.classList.remove('material-you');
            document.documentElement.style.removeProperty('--md-primary');
            document.documentElement.style.removeProperty('--md-primary-container');
            return;
        }
        
        const storedAccent = localStorage.getItem('material_you_accent');
        if (storedAccent) {
            const [h, s, l] = storedAccent.split(',').map(Number);
            document.documentElement.style.setProperty('--md-primary', `hsl(${h}, ${s}%, ${l}%)`);
            document.documentElement.style.setProperty('--md-primary-container', `hsl(${h}, ${s}%, 90%)`);
        } else {
            const hue = Math.floor(Math.random() * 360);
            localStorage.setItem('material_you_accent', `${hue},70,50`);
            document.documentElement.style.setProperty('--md-primary', `hsl(${hue}, 70%, 50%)`);
            document.documentElement.style.setProperty('--md-primary-container', `hsl(${hue}, 70%, 90%)`);
        }
        document.documentElement.style.setProperty('--md-on-primary', '#FFFFFF');
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

    async applySavedConfig(snapshotId) {
        const config = this.configHistory.restoreSnapshot(snapshotId);
        if (!config) {
            this.showNotification(this.translate('Configuration not found'), 'error');
            return;
        }

        try {
            if (this.hasRoot) {
                const patchedContent = this.patchServiceSh(this.originalContent, config);
                if (typeof AndroidRoot !== 'undefined' && AndroidRoot.writeServiceSh(patchedContent)) {
                    this.originalContent = patchedContent;
                    this.config = {...config};
                    
                    this.populateForm(config);
                    
                    if (typeof AndroidRoot !== 'undefined') {
                        AndroidRoot.applyConfiguration();
                        
                        await new Promise(resolve => setTimeout(resolve, 1000));
                        
                        this.hasRoot = AndroidRoot.hasRootAccess();
                        
                        try {
                            AndroidRoot.refreshRootStatus();
                        } catch (e) {
                            console.log("refreshRootStatus not available, using fallback");
                        }
                        
                        this.updateRootStatus();
                        this.updateHomeStatus();
                        
                        const rootTest = AndroidRoot.testRoot();
                        if (rootTest && !rootTest.startsWith('ERROR:')) {
                            this.hasRoot = true;
                        } else {
                            this.hasRoot = false;
                            this.showNotification(this.translate('Root check failed, retrying...'), 'warning');
                            
                            setTimeout(() => {
                                this.checkRootAccess();
                            }, 2000);
                        }
                    }
                    
                    this.showNotification(this.translate('Configuration applied and saved successfully'), 'success');
                } else {
                    throw new Error(this.translate('Failed to write service.sh'));
                }
            } else {
                this.showNotification(this.translate('Root access required to apply configuration'), 'error');
            }
        } catch (error) {
            this.showNotification(error.message, 'error');
        }
    }

    deleteConfig(snapshotId) {
        if (confirm(this.translate('Are you sure you want to delete this configuration?'))) {
            if (this.configHistory.deleteSnapshot(snapshotId)) {
                this.showNotification(this.translate('Configuration deleted'), 'success');
            } else {
                this.showNotification(this.translate('Failed to delete configuration'), 'error');
            }
        }
    }

    getTimestamp() {
        return new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
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
                
                const testResult = AndroidRoot.testRoot();
                if (testResult && !testResult.startsWith('ERROR:')) {
                    this.hasRoot = true;
                }
                
                this.updateRootStatus();
                
                if (this.hasRoot) {
                    this.showNotification(this.translate('Root access granted'), 'success');
                    await this.loadConfig();
                } else {
                    setTimeout(async () => {
                        this.hasRoot = AndroidRoot.hasRootAccess();
                        this.updateRootStatus();
                        
                        if (!this.hasRoot) {
                            this.showNotification(this.translate('Root access required'), 'error');
                        }
                    }, 1000);
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
                if (content.startsWith('ERROR:')) {
                    const forcedContent = AndroidRoot.forceReadServiceSh();
                    if (forcedContent && !forcedContent.startsWith('ERROR:')) {
                        this.originalContent = forcedContent;
                        this.parseConfigFromContent(forcedContent);
                        this.updateStatus(this.translate('Ready'), true);
                        this.showNotification(this.translate('Configuration loaded successfully'), 'success');
                        return;
                    }
                    throw new Error('File not found or cannot be read');
                }
                
                this.originalContent = content;
                this.parseConfigFromContent(content);
                this.updateStatus(this.translate('Ready'), true);
                this.showNotification(this.translate('Configuration loaded successfully'), 'success');
            } else {
                throw new Error(this.translate('Android interface not available'));
            }
        } catch (error) {
            if (this.hasRoot) {
                try {
                    this.updateStatus('Creating default configuration...', false);
                    const defaultConfig = performanceProfiles.balanced;
                    const patchedContent = this.patchServiceSh('', defaultConfig);
                    if (typeof AndroidRoot !== 'undefined' && AndroidRoot.writeServiceSh(patchedContent)) {
                        this.originalContent = patchedContent;
                        this.parseConfigFromContent(patchedContent);
                        this.updateStatus(this.translate('Ready'), true);
                        this.showNotification('Default configuration created and loaded', 'success');
                    } else {
                        throw new Error('Failed to write default configuration');
                    }
                } catch (writeError) {
                    this.updateStatus(this.translate('Error'), false);
                    this.showNotification(writeError.message, 'error');
                }
            } else {
                this.updateStatus(this.translate('Error'), false);
                this.showNotification(error.message, 'error');
            }
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

    async loadModuleFullInfo() {
        try {
            if (typeof AndroidRoot !== 'undefined') {
                const infoStr = AndroidRoot.getModuleFullInfo();
                if (infoStr.startsWith("ERROR:")) {
                    console.error("Failed to load module info:", infoStr);
                    return null;
                }
                
                const info = JSON.parse(infoStr);
                return info;
            }
        } catch (error) {
            console.error("Error loading module info:", error);
        }
        return null;
    }

    async exportConfig() {
        try {
            if (typeof AndroidRoot !== 'undefined') {
                const result = AndroidRoot.exportConfiguration();
                if (result.startsWith("ERROR:")) {
                    this.showNotification(this.translate('Failed to export configuration'), 'error');
                    return;
                }
                
                if (result.includes('/storage/emulated/0/Download/')) {
                    this.showNotification(`${this.translate('Configuration exported successfully')}: ${result}`, 'success');
                } else if (result.startsWith('/')) {
                    this.showNotification(`${this.translate('Configuration exported successfully')}: ${result}`, 'success');
                } else {
                    this.showNotification(result, 'info');
                }
            } else {
                this.showNotification(this.translate('Android interface not available'), 'error');
            }
        } catch (error) {
            console.error("Export error:", error);
            this.showNotification(this.translate('Export failed') + ': ' + error.message, 'error');
        }
    }

    async importConfig() {
        try {
            if (typeof AndroidRoot === 'undefined') {
                this.showNotification(this.translate('Android interface not available'), 'error');
                return;
            }

            const input = document.createElement('input');
            input.type = 'file';
            input.accept = '.conf,.txt';
            
            input.onchange = async (e) => {
                const file = e.target.files[0];
                if (!file) return;
                
                const reader = new FileReader();
                reader.onload = async (event) => {
                    const importedContent = event.target.result;
                    
                    if (typeof AndroidRoot !== 'undefined') {
                        const success = AndroidRoot.importConfiguration(importedContent);
                        if (success) {
                            this.showNotification(this.translate('Configuration imported successfully'), 'success');
                            await this.reliableRootCheck();
                        } else {
                            this.showNotification(this.translate('Failed to import configuration'), 'error');
                        }
                    }
                };
                reader.readAsText(file);
            };
            
            input.click();
        } catch (error) {
            console.error("Import error:", error);
            this.showNotification(this.translate('Import failed') + ': ' + error.message, 'error');
        }
    }

    mergeConfigs(currentContent, importedContent) {
        const currentLines = currentContent.split('\n');
        const importedLines = importedContent.split('\n');
        
        const currentConfig = {};
        const importedConfig = {};
        
        currentLines.forEach(line => {
            const match = line.match(/^([A-Z_]+)=([^#]+)/);
            if (match) {
                currentConfig[match[1]] = match[2].trim();
            }
        });
        
        importedLines.forEach(line => {
            const match = line.match(/^([A-Z_]+)=([^#]+)/);
            if (match) {
                importedConfig[match[1]] = match[2].trim();
            }
        });
        
        const mergedConfig = { ...currentConfig, ...importedConfig };
        
        return Object.entries(mergedConfig)
            .map(([key, value]) => `${key}=${value}`)
            .join('\n');
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

    async updateModuleStatusUI(details) {
        const container = document.getElementById('module-status-container');
        const actionsContainer = document.getElementById('module-actions');
        const enableDisableBtn = document.getElementById('enable-disable-btn');
        
        if (!container) return;
        
        const fullInfo = await this.loadModuleFullInfo();
        
        if (!this.hasRoot) {
            container.innerHTML = `
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Module Status')}</span>
                    <span class="module-status-value">${this.translate('Root required')}</span>
                </div>
            `;
            if (actionsContainer) actionsContainer.style.display = 'none';
            return;
        }
        
        if (!this.moduleStatusChecked) {
            container.innerHTML = `
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Module Status')}</span>
                    <span class="module-status-value">${this.translate('Checking module...')}</span>
                </div>
            `;
            if (actionsContainer) actionsContainer.style.display = 'none';
            return;
        }
        
        if (!details || details.installed === 'false') {
            container.innerHTML = `
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Status')}</span>
                    <span class="module-status-value not-installed">${this.translate('Not installed')}</span>
                </div>
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Module not found')}</span>
                    <span class="module-status-value">${this.translate('Install via Magisk Manager')}</span>
                </div>
            `;
            if (actionsContainer) actionsContainer.style.display = 'none';
            return;
        }
        
        const isEnabled = details.enabled === 'true';
        const version = details.version || 'Unknown';
        const versionCode = details.versionCode || '0';
        
        const moduleId = fullInfo?.id || details.id || 'NextRAM';
        const authors = fullInfo?.authors || details.author || 'Unknown';
        
        let statusText;
        let statusClass;
        
        if (isEnabled) {
            statusText = this.translate('Active');
            statusClass = 'enabled';
        } else {
            statusText = this.translate('Disabled');
            statusClass = 'disabled';
        }
        
        let statusHtml = `
            <div class="module-status-item">
                <span class="module-status-label">ID</span>
                <span class="module-status-value id-value">${moduleId}</span>
            </div>
            <div class="module-status-item">
                <span class="module-status-label">${this.translate('Version')}</span>
                <span class="module-status-value">${version} (${versionCode})</span>
            </div>
            <div class="module-status-item">
                <span class="module-status-label">${this.translate('Status')}</span>
                <span class="module-status-value ${statusClass}">
                    ${statusText}
                </span>
            </div>
            <div class="module-status-item authors-item">
                <span class="module-status-label">${this.translate('Authors')}</span>
                <span class="module-status-value authors-value">${authors}</span>
            </div>
        `;
        
        if (fullInfo?.description) {
            statusHtml += `
                <div class="module-status-item">
                    <span class="module-status-label">${this.translate('Description')}</span>
                    <span class="module-status-value" style="font-size: 12px; opacity: 0.8;">
                        ${fullInfo.description}
                    </span>
                </div>
            `;
        }
        
        container.innerHTML = statusHtml;
        
        if (actionsContainer) {
            actionsContainer.style.display = 'flex';
            if (enableDisableBtn) {
                enableDisableBtn.style.display = 'inline-block';
                enableDisableBtn.textContent = isEnabled ? this.translate('Disable') : this.translate('Enable');
                enableDisableBtn.className = isEnabled ? 'btn btn-small btn-secondary' : 'btn btn-small btn-primary';
            }
        }
    }

    async loadStoreConfigs() {
        try {
            const storeContent = document.getElementById('store-content');
            const storeLoading = document.getElementById('store-loading');
            const storeEmpty = document.getElementById('store-empty');
            const storeError = document.getElementById('store-error');
            const storeConnectionInfo = document.getElementById('store-connection-info');
            const storeCount = document.getElementById('store-count');
            
            storeLoading.style.display = 'block';
            storeContent.style.display = 'none';
            storeEmpty.style.display = 'none';
            storeError.style.display = 'none';
            storeConnectionInfo.style.display = 'none';
            
            if (typeof AndroidRoot !== 'undefined') {
                const response = AndroidRoot.getStoreConfigs();
                const data = JSON.parse(response);
                
                if (data.error) {
                    throw new Error(data.error);
                }
                
                if (!data.configs || data.configs.length === 0) {
                    storeLoading.style.display = 'none';
                    storeEmpty.style.display = 'block';
                    return;
                }
                
                storeContent.innerHTML = '';
                
                if (storeCount) {
                    storeCount.textContent = data.count || data.configs.length;
                    storeConnectionInfo.style.display = 'block';
                }
                
                data.configs.forEach(config => {
                    const configHtml = this.createStoreConfigHTML(config);
                    storeContent.innerHTML += configHtml;
                });
                
                storeLoading.style.display = 'none';
                storeContent.style.display = 'block';
                
                this.setupStoreEventListeners();
                
            } else {
                throw new Error('Android interface not available');
            }
        } catch (error) {
            const storeLoading = document.getElementById('store-loading');
            const storeError = document.getElementById('store-error');
            const errorMessage = document.getElementById('store-error-message');
            
            storeLoading.style.display = 'none';
            errorMessage.textContent = error.message;
            storeError.style.display = 'block';
        }
    }

    createStoreConfigHTML(config) {
        const name = config.name || config.fileName?.replace('.json', '') || 'Unnamed Configuration';
        const fileName = config.fileName || '';
        
        return `
            <div class="store-config-item" data-filename="${fileName}">
                <div class="store-config-header">
                    <div style="display: flex; align-items: center;">
                        <h4>${name}</h4>
                        <span class="config-badge" data-translate="New">New</span>
                    </div>
                    <span class="store-config-arrow">▼</span>
                </div>
                <div class="store-config-content">
                    <div class="store-config-loading">
                        <span class="loading-spinner"></span>
                        <span data-translate="Loading from GitHub...">Loading from GitHub...</span>
                    </div>
                </div>
            </div>
        `;
    }

    setupStoreEventListeners() {
        const configItems = document.querySelectorAll('.store-config-item');
        
        configItems.forEach(item => {
            const header = item.querySelector('.store-config-header');
            const arrow = item.querySelector('.store-config-arrow');
            const content = item.querySelector('.store-config-content');
            const fileName = item.getAttribute('data-filename');
            
            header.addEventListener('click', async () => {
                const isExpanded = content.style.display === 'block';
                
                if (isExpanded) {
                    content.style.display = 'none';
                    arrow.classList.remove('expanded');
                } else {
                    arrow.classList.add('expanded');
                    
                    if (content.children.length === 1 && 
                        content.children[0].classList.contains('store-config-loading')) {
                        await this.loadStoreConfigContent(fileName, content);
                    }
                    
                    content.style.display = 'block';
                }
            });
        });
    }

    async loadStoreConfigContent(fileName, contentContainer) {
        try {
            if (typeof AndroidRoot !== 'undefined') {
                const response = AndroidRoot.getStoreConfigContent(fileName);
                
                let data;
                try {
                    data = JSON.parse(response);
                } catch (jsonError) {
                    throw new Error('Invalid JSON file');
                }
                
                if (data.error) {
                    if (data.error === 'file_not_found' || data.error === 'invalid_file_format') {
                        throw new Error(this.translate('Configuration file not found'));
                    } else if (data.error === 'invalid_json') {
                        throw new Error('Invalid JSON format in file');
                    } else {
                        throw new Error(data.message || data.error);
                    }
                }
                
                const config = data.config || {};
                const metadata = {
                    name: data.name || fileName.replace('.json', ''),
                    description: data.description || 'No description available',
                    author: data.author || 'Unknown',
                    version: data.version || '1.0',
                    testedOn: data.testedOn || 'Not specified',
                    device: data.device || 'Not specified',
                    createdWith: data.createdWith || 'Unknown',
                    createdDate: data.createdDate || 'Unknown'
                };
                
                const rawContent = data.rawContent || JSON.stringify(data, null, 2);
                
                if (Object.keys(config).length === 0) {
                    throw new Error(this.translate('No valid configuration found in file'));
                }
                
                const configHtml = this.createStoreConfigDetailHTML(metadata, config, rawContent);
                contentContainer.innerHTML = configHtml;
                
                const applyBtn = contentContainer.querySelector('.apply-store-config');
                if (applyBtn) {
                    applyBtn.addEventListener('click', () => {
                        this.applyStoreConfig(config);
                    });
                }
                
                const saveBtn = contentContainer.querySelector('.btn-secondary');
                if (saveBtn && saveBtn.textContent.includes('Save to History')) {
                    saveBtn.addEventListener('click', () => {
                        const configName = metadata.name;
                        this.saveStoreConfigToHistory(configName, config);
                    });
                }
            }
        } catch (error) {
            console.error('Error loading store config:', error);
            contentContainer.innerHTML = `
                <div class="recommendation error">
                    <div class="recommendation-header">
                        <span>⚠️</span>
                        <span data-translate="Error">Error</span>
                    </div>
                    <div class="recommendation-message">${error.message}</div>
                    <button class="btn btn-small" onclick="nextram.loadStoreConfigContent('${fileName}', this.parentElement.parentElement)" style="margin-top: 8px;" data-translate="Retry">Retry</button>
                </div>
            `;
        }
    }

    createStoreConfigDetailHTML(metadata, config, rawContent) {
        const { name, description, author, version, testedOn, device, createdWith, createdDate } = metadata;
        
        let configPreview;
        try {
            configPreview = JSON.stringify(config, null, 2);
        } catch (e) {
            configPreview = 'Cannot display configuration preview';
        }
        
        return `
            <div class="store-config-meta">
                <div class="meta-item">
                    <span class="meta-label" data-translate="Author">Author</span>
                    <span class="meta-value">${author}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label" data-translate="Version">Version</span>
                    <span class="meta-value">${version}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label" data-translate="Tested On">Tested On</span>
                    <span class="meta-value">${testedOn}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label" data-translate="Device">Device</span>
                    <span class="meta-value">${device}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label" data-translate="Created">Created</span>
                    <span class="meta-value">${createdDate}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label" data-translate="Created With">Created With</span>
                    <span class="meta-value">${createdWith}</span>
                </div>
            </div>
            
            <div class="meta-item" style="grid-column: 1 / -1;">
                <span class="meta-label" data-translate="Description">Description</span>
                <span class="meta-value" style="font-weight: normal; margin-top: 4px;">${description}</span>
            </div>
            
            <div class="store-config-preview">
                <div style="margin-bottom: 8px; font-size: 11px; color: var(--md-on-surface-variant);" data-translate="Configuration preview:">Configuration preview:</div>
                <code>${configPreview}</code>
            </div>
            
            <div class="store-config-actions">
                <button class="btn btn-primary apply-store-config" data-translate="Apply Configuration">Apply Configuration</button>
                <button class="btn btn-secondary" data-translate="Save to History">Save to History</button>
            </div>
            
            <div class="store-source-info">
                <span data-translate="Loaded from GitHub repository">Loaded from GitHub repository</span>
            </div>
        `;
    }

    applyStoreConfig(config) {
        let appliedCount = 0;
        Object.keys(config).forEach(key => {
            const element = document.getElementById(key);
            if (element) {
                if (element.type === 'checkbox') {
                    element.checked = Boolean(config[key]);
                } else {
                    element.value = config[key];
                }
                appliedCount++;
            }
        });
        
        this.onFormChange();
        this.showNotification(
            `${this.translate('Configuration applied to form.')} ${appliedCount} ${this.translate('settings updated. Click Save to apply.')}`,
            'success'
        );
        switchTab('config');
    }

    saveStoreConfigToHistory(name, config) {
        const currentConfig = this.gatherFormData();
        const mergedConfig = { ...currentConfig, ...config };
        this.configHistory.saveSnapshot(mergedConfig, `Store config: ${name}`);
        this.showNotification(this.translate('Configuration saved to history'), 'success');
    }
}

const nextram = new NextRAMController();

document.getElementById('saveButton').addEventListener('click', () => {
    nextram.saveChanges();
    nextram.updateHomeStatus();
});

function checkRootAccess() {
    nextram.reliableRootCheck();
    nextram.updateHomeStatus();
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