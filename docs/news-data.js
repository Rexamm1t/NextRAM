const newsData = [
    {
        id: 6,
        date: "2025-12-10",
        category: "release",
        tags: ["release", "update", "optimization"],
        author: "@rexamm1t",
        en: {
            title: "NextRAM Fusion v9.1.280 (91280)",
            preview: "Code optimization, stability enhancements, ZRAM improvements, kernel tuning system upgrades, performance optimization, compatibility updates, API enhancements, and monitoring system upgrades.",
            content: `
                <h3>NextRAM Fusion v9.1.280 (91280) Release Notes</h3>
                <p><strong>[CODE OPTIMIZATION]</strong></p>
                <ul>
                    <li>Enhanced file permission verification before writing kernel parameters</li>
                    <li>Added comprehensive file and directory existence checks</li>
                    <li>Optimized error handling routines throughout all scripts</li>
                    <li>Streamlined loop structures and conditional statements</li>
                    <li>Improved code maintainability while preserving original functionality</li>
                </ul>
                <p><strong>[STABILITY ENHANCEMENTS]</strong></p>
                <ul>
                    <li>Fixed potentially unsafe script constructs</li>
                    <li>Added thorough system utility availability validation</li>
                    <li>Enhanced device compatibility across different Android implementations</li>
                    <li>Improved swap file creation error handling</li>
                    <li>Strengthened file access permission verifications</li>
                </ul>
                <p><strong>[ZRAM IMPROVEMENTS]</strong></p>
                <ul>
                    <li>Advanced zram device detection with dual-path checking</li>
                    <li>Added safety checks before zram reset operations</li>
                    <li>Enhanced compression algorithm selection error handling</li>
                    <li>Implemented /sys/block/zram0 directory validation</li>
                    <li>Refined compression stream parameter management</li>
                </ul>
                <p><strong>[KERNEL TUNING SYSTEM]</strong></p>
                <ul>
                    <li>Upgraded kernel parameter application with verification layer</li>
                    <li>Implemented comprehensive tuning success monitoring</li>
                    <li>Enhanced dynamic swappiness algorithm with multi-factor calculations</li>
                    <li>Introduced safe parameter setting functions (set_param, set_sysctl)</li>
                    <li>Added write capability verification before file operations</li>
                </ul>
                <p><strong>[PERFORMANCE OPTIMIZATION]</strong></p>
                <ul>
                    <li>Reduced script execution overhead through code refinement</li>
                    <li>Minimized redundant file system operations</li>
                    <li>Optimized I/O operations during swap configuration</li>
                    <li>Enhanced script execution efficiency</li>
                </ul>
                <p><strong>[COMPATIBILITY UPDATES]</strong></p>
                <ul>
                    <li>Expanded Android version and Linux kernel compatibility</li>
                    <li>Improved operation on low-resource devices</li>
                    <li>Added legacy kernel support checks</li>
                    <li>Enhanced filesystem type compatibility</li>
                </ul>
                <p><strong>[API ENHANCEMENTS]</strong></p>
                <ul>
                    <li>Improved web interface stability and responsiveness</li>
                    <li>Fixed configuration management edge cases</li>
                    <li>Enhanced API command parsing and execution</li>
                    <li>Added configuration change validation</li>
                </ul>
                <p><strong>[MONITORING SYSTEM]</strong></p>
                <ul>
                    <li>Upgraded memory and zram monitoring architecture</li>
                    <li>Added comprehensive device state verification</li>
                    <li>Fixed resource leakage in background monitoring</li>
                    <li>Enhanced monitoring process management</li>
                </ul>
                <p><strong>Links:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        ru: {
            title: "NextRAM Fusion v9.1.280 (91280)",
            preview: "Оптимизация кода, улучшение стабильности, улучшения ZRAM, обновления системы настройки ядра, оптимизация производительности, обновления совместимости, улучшения API и обновления системы мониторинга.",
            content: `
                <h3>NextRAM Fusion v9.1.280 (91280) Примечания к выпуску</h3>
                <p><strong>[ОПТИМИЗАЦИЯ КОДА]</strong></p>
                <ul>
                    <li>Улучшена проверка разрешений файлов перед записью параметров ядра</li>
                    <li>Добавлена комплексная проверка существования файлов и каталогов</li>
                    <li>Оптимизированы процедуры обработки ошибок во всех скриптах</li>
                    <li>Упрощены структуры циклов и условные операторы</li>
                    <li>Улучшена сопровождаемость кода при сохранении исходной функциональности</li>
                </ul>
                <p><strong>[УЛУЧШЕНИЯ СТАБИЛЬНОСТИ]</strong></p>
                <ul>
                    <li>Исправлены потенциально небезопасные конструкции скриптов</li>
                    <li>Добавлена тщательная проверка доступности системных утилит</li>
                    <li>Улучшена совместимость устройств в разных реализациях Android</li>
                    <li>Улучшена обработка ошибок создания файла подкачки</li>
                    <li>Усилена проверка разрешений доступа к файлам</li>
                </ul>
                <p><strong>[УЛУЧШЕНИЯ ZRAM]</strong></p>
                <ul>
                    <li>Продвинутое обнаружение устройств zram с двойной проверкой путей</li>
                    <li>Добавлены проверки безопасности перед операциями сброса zram</li>
                    <li>Улучшена обработка ошибок выбора алгоритма сжатия</li>
                    <li>Реализована проверка каталога /sys/block/zram0</li>
                    <li>Усовершенствовано управление параметрами потоков сжатия</li>
                </ul>
                <p><strong>[СИСТЕМА НАСТРОЙКИ ЯДРА]</strong></p>
                <ul>
                    <li>Обновлено применение параметров ядра с уровнем проверки</li>
                    <li>Реализован комплексный мониторинг успешности настройки</li>
                    <li>Улучшен алгоритм динамической подкачки с многофакторными расчетами</li>
                    <li>Введены безопасные функции установки параметров (set_param, set_sysctl)</li>
                    <li>Добавлена проверка возможности записи перед операциями с файлами</li>
                </ul>
                <p><strong>[ОПТИМИЗАЦИЯ ПРОИЗВОДИТЕЛЬНОСТИ]</strong></p>
                <ul>
                    <li>Снижены накладные расходы на выполнение скриптов за счет оптимизации кода</li>
                    <li>Минимизированы избыточные операции файловой системы</li>
                    <li>Оптимизированы операции ввода-вывода при настройке подкачки</li>
                    <li>Улучшена эффективность выполнения скриптов</li>
                </ul>
                <p><strong>[ОБНОВЛЕНИЯ СОВМЕСТИМОСТИ]</strong></p>
                <ul>
                    <li>Расширена совместимость версий Android и ядер Linux</li>
                    <li>Улучшена работа на устройствах с низкими ресурсами</li>
                    <li>Добавлены проверки поддержки старых ядер</li>
                    <li>Улучшена совместимость типов файловых систем</li>
                </ul>
                <p><strong>[УЛУЧШЕНИЯ API]</strong></p>
                <ul>
                    <li>Улучшена стабильность и отзывчивость веб-интерфейса</li>
                    <li>Исправлены крайние случаи управления конфигурацией</li>
                    <li>Улучшен анализ и выполнение команд API</li>
                    <li>Добавлена проверка изменений конфигурации</li>
                </ul>
                <p><strong>[СИСТЕМА МОНИТОРИНГА]</strong></p>
                <ul>
                    <li>Оновлена архитектура мониторинга памяти и zram</li>
                    <li>Добавлена комплексная проверка состояния устройства</li>
                    <li>Исправлена утечка ресурс ов в фоновом мониторинге</li>
                    <li>Улучшено управление процессами мониторинга</li>
                </ul>
                <p><strong>Ссылки:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        uk: {
            title: "NextRAM Fusion v9.1.280 (91280)",
            preview: "Оптимізація коду, покращення стабільності, покращення ZRAM, оновлення системи налаштування ядра, оптимізація продуктивності, оновлення сумісності, покращення API та оновлення системи моніторингу.",
            content: `
                <h3>NextRAM Fusion v9.1.280 (91280) Примітки до випуску</h3>
                <p><strong>[ОПТИМІЗАЦІЯ КОДУ]</strong></p>
                <ul>
                    <li>Покращена перевірка дозволів файлів перед записом параметрів ядра</li>
                    <li>Додано комплексну перевірку існування файлів та каталогів</li>
                    <li>Оптимізовано процедури обробки помилок у всіх скриптах</li>
                    <li>Спрощено структури циклів та умовні оператори</li>
                    <li>Покращено супроводжуваність коду при збереженні вихідної функціональності</li>
                </ul>
                <p><strong>[ПОКРАЩЕННЯ СТАБІЛЬНОСТІ]</strong></p>
                <ul>
                    <li>Виправлено потенційно небезпечні конструкції скриптів</li>
                    <li>Додано ретельну перевірку доступності системних утиліт</li>
                    <li>Покращено сумісність пристроїв у різних реалізаціях Android</li>
                    <li>Покращено обробку помилок створення файлу підкачки</li>
                    <li>Посилено перевірку дозволів доступу до файлів</li>
                </ul>
                <p><strong>[ПОКРАЩЕННЯ ZRAM]</strong></p>
                <ul>
                    <li>Розширене виявлення пристроїв zram з подвійною перевіркою шляхів</li>
                    <li>Додано перевірки безпеки перед операціями скидання zram</li>
                    <li>Покращено обробку помилок вибору алгоритму стиснення</li>
                    <li>Реалізовано перевірку каталогу /sys/block/zram0</li>
                    <li>Удосконалено управління параметрами потоків стиснення</li>
                </ul>
                <p><strong>[СИСТЕМА НАЛАШТУВАННЯ ЯДРА]</strong></p>
                <ul>
                    <li>Оновлено застосування параметрів ядра з рівнем перевірки</li>
                    <li>Реалізовано комплексний моніторинг успішності налаштування</li>
                    <li>Покращено алгоритм динамічної підкачки з багатофакторними розрахунками</li>
                    <li>Введено безпечні функції встановлення параметрів (set_param, set_sysctl)</li>
                    <li>Додано перевірку можливості запису перед операціями з файлами</li>
                </ul>
                <p><strong>[ОПТИМІЗАЦІЯ ПРОДУКТИВНОСТІ]</strong></p>
                <ul>
                    <li>Знижено накладні витрати на виконання скриптів за рахунок оптимізації коду</li>
                    <li>Мінімізовано надлишкові операції файлової системи</li>
                    <li>Оптимізовано операції вводу-виводу під час налаштування підкачки</li>
                    <li>Покращено ефективність виконання скриптів</li>
                </ul>
                <p><strong>[ОНОВЛЕННЯ СУМІСНОСТІ]</strong></p>
                <ul>
                    <li>Розширено сумісність версій Android та ядер Linux</li>
                    <li>Покращено роботу на пристроях з низькими ресурсами</li>
                    <li>Додано перевірки підтримки старих ядер</li>
                    <li>Покращено сумісність типів файлових систем</li>
                </ul>
                <p><strong>[ПОКРАЩЕННЯ API]</strong></p>
                <ul>
                    <li>Покращено стабільність та відповідальність веб-інтерфейсу</li>
                    <li>Виправлено крайні випадки управління конфігурацією</li>
                    <li>Покращено аналіз та виконання команд API</li>
                    <li>Додано перевірку змін конфігурації</li>
                </ul>
                <p><strong>[СИСТЕМА МОНІТОРИНГУ]</strong></p>
                <ul>
                    <li>Оновлено архітектуру моніторингу пам'яті та zram</li>
                    <li>Додано комплексну перевірку стану пристрою</li>
                    <li>Виправлено витік ресурсів у фоновому моніторингу</li>
                    <li>Покращено управління процесами моніторингу</li>
                </ul>
                <p><strong>Посилання:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        zh: {
            title: "NextRAM Fusion v9.1.280 (91280)",
            preview: "代码优化、稳定性增强、ZRAM 改进、内核调优系统升级、性能优化、兼容性更新、API 增强和监控系统升级。",
            content: `
                <h3>NextRAM Fusion v9.1.280 (91280) 发布说明</h3>
                <p><strong>[代码优化]</strong></p>
                <ul>
                    <li>在写入内核参数之前增强文件权限验证</li>
                    <li>添加全面的文件和目录存在检查</li>
                    <li>优化所有脚本中的错误处理例程</li>
                    <li>简化循环结构和条件语句</li>
                    <li>在保留原始功能的同时提高代码可维护性</li>
                </ul>
                <p><strong>[稳定性增强]</strong></p>
                <ul>
                    <li>修复了潜在不安全的脚本结构</li>
                    <li>添加了全面的系统实用程序可用性验证</li>
                    <li>增强了不同 Android 实现的设备兼容性</li>
                    <li>改进了交换文件创建错误处理</li>
                    <li>加强了文件访问权限验证</li>
                </ul>
                <p><strong>[ZRAM 改进]</strong></p>
                <ul>
                    <li>通过双路径检查进行高级 zram 设备检测</li>
                    <li>在 zram 重置操作之前添加安全检查</li>
                    <li>增强了压缩算法选择错误处理</li>
                    <li>实现了 /sys/block/zram0 目录验证</li>
                    <li>改进了压缩流参数管理</li>
                </ul>
                <p><strong>[内核调优系统]</strong></p>
                <ul>
                    <li>通过验证层升级内核参数应用</li>
                    <li>实现了全面的调优成功监控</li>
                    <li>通过多因素计算增强动态交换性算法</li>
                    <li>引入了安全参数设置函数（set_param、set_sysctl）</li>
                    <li>在文件操作之前添加了写入能力验证</li>
                </ul>
                <p><strong>[性能优化]</strong></p>
                <ul>
                    <li>通过代码优化减少了脚本执行开销</li>
                    <li>最小化了冗余文件系统操作</li>
                    <li>优化了交换配置期间的 I/O 操作</li>
                    <li>提高了脚本执行效率</li>
                </ul>
                <p><strong>[兼容性更新]</strong></p>
                <ul>
                    <li>扩展了 Android 版本和 Linux 内核兼容性</li>
                    <li>改进了低资源设备上的操作</li>
                    <li>添加了旧内核支持检查</li>
                    <li>增强了文件系统类型兼容性</li>
                </ul>
                <p><strong>[API 增强]</strong></p>
                <ul>
                    <li>改进了 Web 界面的稳定性和响应能力</li>
                    <li>修复了配置管理的边缘情况</li>
                    <li>增强了 API 命令解析和执行</li>
                    <li>添加了配置更改验证</li>
                </ul>
                <p><strong>[监控系统]</strong></p>
                <ul>
                    <li>升级了内存和 zram 监控架构</li>
                    <li>添加了全面的设备状态验证</li>
                    <li>修复了后台监控中的资源泄漏</li>
                    <li>改进了监控过程管理</li>
                </ul>
                <p><strong>链接:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        }
    },
    {
        id: 5,
        date: "2025-12-1",
        category: "release",
        tags: ["release", "update"],
        author: "@rexamm1t",
        en: {
            title: "NextRAM v9.0.127 (90127)",
            preview: "Added time-out when selecting the configuration method. Fixed various bugs and improved stability.",
            content: `
                <h3>NextRAM v9.0.127 (90127) Release Notes</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Added time-out when selecting the configuration method</li>
                </ul>
                <p><strong>Links:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        ru: {
            title: "NextRAM v9.0.127 (90127)",
            preview: "Добавлен тайм-аут при выборе метода конфигурации. Исправлены различные ошибки и улучшена стабильность.",
            content: `
                <h3>NextRAM v9.0.127 (90127) Примечания к выпуску</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Добавлен тайм-аут при выборе метода конфигурации</li>
                </ul>
                <p><strong>Ссылки:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        uk: {
            title: "NextRAM v9.0.127 (90127)",
            preview: "Додано тайм-аут при виборі методу конфігурації. Виправлені різні помилки та покращено стабільність.",
            content: `
                <h3>NextRAM v9.0.127 (90127) Примітки до випуску</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Додано тайм-аут при виборі методу конфігурації</li>
                </ul>
                <p><strong>Посилання:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        zh: {
            title: "NextRAM v9.0.127 (90127)",
            preview: "添加了选择配置方法时的超时设置。修复了各种错误并提高了稳定性。",
            content: `
                <h3>NextRAM v9.0.127 (90127) 发布说明</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>添加了选择配置方法时的超时设置</li>
                </ul>
                <p><strong>链接:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        }
    },
    {
        id: 4,
        date: "2025-12-1",
        category: "release",
        tags: ["release", "major", "beta"],
        author: "@rexamm1t",
        en: {
            title: "NextRAM v9.0.000 (90000) [NRAICF] (beta)",
            preview: "Major release with first C++ tool for NextRAM, complete APK redesign with Material 3, and kernel improvements.",
            content: `
                <h3>NextRAM v9.0.000 (90000) Release Notes</h3>
                <p><strong>[NRAICF] (beta)</strong></p>
                <ul>
                    <li>Added the first C++ tool for NextRAM. It generates a configuration for the device</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>Major corrections in the code</li>
                    <li>Added new settings to the configuration file regarding the kernel</li>
                    <li>zRAM fixes...</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>Completely updated the interface - Material 3</li>
                    <li>Switches have been added for new parameters</li>
                    <li>Improved existing themes</li>
                    <li>Added new translations: Chinese and Ukrainian</li>
                    <li>Added help for each parameter with translation</li>
                    <li>Fixed switching color scheme</li>
                </ul>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Update information</li>
                    <li>Added new logic (NRAICF)</li>
                </ul>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>Fixed the display of nlive and logs</li>
                </ul>
                <p><strong>Links:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        ru: {
            title: "NextRAM v9.0.000 (90000) [NRAICF] (beta)",
            preview: "Крупный релиз с первым C++ инструментом для NextRAM, полным редизайном APK в Material 3 и улучшениями ядра.",
            content: `
                <h3>NextRAM v9.0.000 (90000) Примечания к выпуску</h3>
                <p><strong>[NRAICF] (beta)</strong></p>
                <ul>
                    <li>Добавлен первый инструмент на C++ для NextRAM. Он генерирует конфигурацию для устройства</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>Крупные исправления в коде</li>
                    <li>Добавлены новые настройки в файл конфигурации относительно ядра</li>
                    <li>Исправления zRAM...</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>Полностью обновлен интерфейс - Material 3</li>
                    <li>Добавлены переключатели для новых параметров</li>
                    <li>Улучшены существующие темы</li>
                    <li>Добавлены новые переводы: китайский и украинский</li>
                    <li>Добавлена помощь для каждого параметра с переводом</li>
                    <li>Исправлено переключение цветовой схемы</li>
                </ul>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Обновлена информация</li>
                    <li>Добавлена новая логика (NRAICF)</li>
                </ul>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>Исправлено отображение nlive и логов</li>
                </ul>
                <p><strong>Ссылки:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        uk: {
            title: "NextRAM v9.0.000 (90000) [NRAICF] (beta)",
            preview: "Крупний реліз з першим інструментом C++ для NextRAM, повним редизайном APK у Material 3 та покращеннями ядра.",
            content: `
                <h3>NextRAM v9.0.000 (90000) Примітки до випуску</h3>
                <p><strong>[NRAICF] (beta)</strong></p>
                <ul>
                    <li>Додано перший інструмент на C++ для NextRAM. Він генерує конфігурацію для пристрою</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>Крупні виправлення в коді</li>
                    <li>Додано нові налаштування у файл конфігурації щодо ядра</li>
                    <li>Виправлення zRAM...</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>Повністю оновлено інтерфейс - Material 3</li>
                    <li>Додано перемикачі для нових параметрів</li>
                    <li>Покращено існуючі теми</li>
                    <li>Додано нові переклади: китайська та українська</li>
                    <li>Додано допомогу для кожного параметра з перекладом</li>
                    <li>Виправлено перемикання кольорової схеми</li>
                </ul>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Оновлено інформацію</li>
                    <li>Додано нову логіку (NRAICF)</li>
                </ul>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>Виправлено відображення nlive та логів</li>
                </ul>
                <p><strong>Посилання:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        },
        zh: {
            title: "NextRAM v9.0.000 (90000) [NRAICF] (beta)",
            preview: "主要版本包含首个 NextRAM 的 C++ 工具，APK 完全重新设计为 Material 3，以及内核改进。",
            content: `
                <h3>NextRAM v9.0.000 (90000) 发布说明</h3>
                <p><strong>[NRAICF] (beta)</strong></p>
                <ul>
                    <li>添加了首个 NextRAM 的 C++ 工具。它为设备生成配置</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>代码中的主要修正</li>
                    <li>在配置文件中添加了关于内核的新设置</li>
                    <li>zRAM 修复...</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>完全更新了界面 - Material 3</li>
                    <li>为新参数添加了开关</li>
                    <li>改进了现有主题</li>
                    <li>添加了新翻译：中文和乌克兰语</li>
                    <li>为每个参数添加了带有翻译的帮助</li>
                    <li>修复了颜色方案切换</li>
                </ul>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>更新信息</li>
                    <li>添加了新逻辑 (NRAICF)</li>
                </ul>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>修复了 nlive 和日志的显示</li>
                </ul>
                <p><strong>链接:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
                <p>Web Site: https://nextram.cocal.ru</p>
            `
        }
    },
    {
        id: 3,
        date: "2025-11-17",
        category: "update",
        tags: ["update", "zram"],
        author: "@rexamm1t",
        en: {
            title: "NextRAM v8.5.638 (85638)",
            preview: "Reworked logic of the 'Action' button, updated NextRAM App to 8.4.201-fix, and zRAM fixes.",
            content: `
                <h3>NextRAM v8.5.638 (85638) Release Notes</h3>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>Reworked the logic of the "Action" button in root managers</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>Update NextRAM App - 8.4.201-fix (84201)</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>Fix settings - maximum compression streams</li>
                    <li>Other improvements to the code</li>
                </ul>
                <p><strong>Links:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        ru: {
            title: "NextRAM v8.5.638 (85638)",
            preview: "Переработана логика кнопки 'Action', обновлено приложение NextRAM до 8.4.201-fix и исправления zRAM.",
            content: `
                <h3>NextRAM v8.5.638 (85638) Примечания к выпуску</h3>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>Переработана логика кнопки "Action" в рут-менеджерах</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>Обновление NextRAM App - 8.4.201-fix (84201)</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>Исправление настроек - максимальные потоки сжатия</li>
                    <li>Другие улучшения кода</li>
                </ul>
                <p><strong>Ссылки:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        uk: {
            title: "NextRAM v8.5.638 (85638)",
            preview: "Перероблено логіку кнопки 'Action', оновлено додаток NextRAM до 8.4.201-fix та виправлення zRAM.",
            content: `
                <h3>NextRAM v8.5.638 (85638) Примітки до випуску</h3>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>Перероблено логіку кнопки "Action" у рут-менеджерах</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>Оновлення NextRAM App - 8.4.201-fix (84201)</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>Виправлення налаштувань - максимальні потоки стиснення</li>
                    <li>Інші покращення коду</li>
                </ul>
                <p><strong>Посилання:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        zh: {
            title: "NextRAM v8.5.638 (85638)",
            preview: "重新设计了 'Action' 按钮的逻辑，将 NextRAM App 更新至 8.4.201-fix，以及 zRAM 修复。",
            content: `
                <h3>NextRAM v8.5.638 (85638) 发布说明</h3>
                <p><strong>[ACTION]</strong></p>
                <ul>
                    <li>重新设计了 root 管理器中的 "Action" 按钮逻辑</li>
                </ul>
                <p><strong>[APK]</strong></p>
                <ul>
                    <li>更新 NextRAM App - 8.4.201-fix (84201)</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>修复设置 - 最大压缩流</li>
                    <li>代码的其他改进</li>
                </ul>
                <p><strong>链接:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        }
    },
    {
        id: 2,
        date: "2025-11-15",
        category: "update",
        tags: ["update", "fix", "kernel"],
        author: "@rexamm1t",
        en: {
            title: "NextRAM v8.4.201-fix (84201)",
            preview: "Fix for tuning scripts and slowed charge, zRAM custom size fix, and various bugfixes.",
            content: `
                <h3>NextRAM v8.4.201-fix (84201) Release Notes</h3>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>Fix tuning scripts</li>
                    <li>Fix slowed charge</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>Fix zRAM custom size (4G?)</li>
                    <li>Bugfixes</li>
                </ul>
                <p><strong>Links:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        ru: {
            title: "NextRAM v8.4.201-fix (84201)",
            preview: "Исправление скриптов настройки и замедленной зарядки, исправление пользовательского размера zRAM и различные исправления ошибок.",
            content: `
                <h3>NextRAM v8.4.201-fix (84201) Примечания к выпуску</h3>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>Исправление скриптов настройки</li>
                    <li>Исправление замедленной зарядки</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>Исправление пользовательского размера zRAM (4G?)</li>
                    <li>Исправления ошибок</li>
                </ul>
                <p><strong>Ссылки:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        uk: {
            title: "NextRAM v8.4.201-fix (84201)",
            preview: "Виправлення скриптів налаштування та уповільненої зарядки, виправлення користувацького розміру zRAM та різні виправлення помилок.",
            content: `
                <h3>NextRAM v8.4.201-fix (84201) Примітки до випуску</h3>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>Виправлення скриптів налаштування</li>
                    <li>Виправлення уповільненої зарядки</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>Виправлення користувацького розміру zRAM (4G?)</li>
                    <li>Виправлення помилок</li>
                </ul>
                <p><strong>Посилання:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        zh: {
            title: "NextRAM v8.4.201-fix (84201)",
            preview: "修复调优脚本和充电缓慢问题，zRAM 自定义大小修复，以及各种错误修复。",
            content: `
                <h3>NextRAM v8.4.201-fix (84201) 发布说明</h3>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>修复调优脚本</li>
                    <li>修复充电缓慢问题</li>
                </ul>
                <p><strong>[zRAM]</strong></p>
                <ul>
                    <li>修复 zRAM 自定义大小 (4G?)</li>
                    <li>错误修复</li>
                </ul>
                <p><strong>链接:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        }
    },
    {
        id: 1,
        date: "2025-11-13",
        category: "development",
        tags: ["development", "pre-release", "kernel"],
        author: "@rexamm1t",
        en: {
            title: "NextRAM v8.3.201-pre (83201p)",
            preview: "Pre-release with support for older configurations, swapoff fixes, and smart dynamic swappiness tuning.",
            content: `
                <h3>NextRAM v8.3.201-pre (83201p) Release Notes</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Adding support for older configurations (almost NextRAM 2+)</li>
                    <li>Adding new options to the config when they are missing</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>Fix swapoff options</li>
                </ul>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>Smart dynamic swappiness tuning based on memory size, ZRAM usage, and current swap utilization</li>
                    <li>Extended memory parameters - min_free_kbytes, watermark_scale_factor, OOM settings</li>
                    <li>Dual operation modes - performance (aggressive) and power-saving (balanced)</li>
                    <li>Settings verification with success rate checking</li>
                    <li>Safe handling - file availability checks before writing</li>
                    <li>Detailed logging of each modified parameter</li>
                </ul>
                <p><strong>Links:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        ru: {
            title: "NextRAM v8.3.201-pre (83201p)",
            preview: "Пре-релиз с поддержкой старых конфигураций, исправлениями swapoff и умной динамической настройкой swappiness.",
            content: `
                <h3>NextRAM v8.3.201-pre (83201p) Примечания к выпуску</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Добавление поддержки старых конфигураций (почти NextRAM 2+)</li>
                    <li>Добавление новых опций в конфиг при их отсутствии</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>Исправление опций swapoff</li>
                </ul>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>Умная динамическая настройка swappiness на основе размера памяти, использования ZRAM и текущего использования подкачки</li>
                    <li>Расширенные параметры памяти - min_free_kbytes, watermark_scale_factor, настройки OOM</li>
                    <li>Двойные режимы работы - производительный (агрессивный) и энергосберегающий (сбалансированный)</li>
                    <li>Проверка настроек с проверкой успешности</li>
                    <li>Безопасная обработка - проверка доступности файлов перед записью</li>
                    <li>Подробное логирование каждого измененного параметра</li>
                </ul>
                <p><strong>Ссылки:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        uk: {
            title: "NextRAM v8.3.201-pre (83201p)",
            preview: "Пре-реліз з підтримкою старих конфігурацій, виправленнями swapoff та розумною динамічною налаштуванням swappiness.",
            content: `
                <h3>NextRAM v8.3.201-pre (83201p) Примітки до випуску</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>Додавання підтримки старих конфігурацій (майже NextRAM 2+)</li>
                    <li>Додавання нових опцій у конфіг при їх відсутності</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>Виправлення опцій swapoff</li>
                </ul>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>Розумна динамічна налаштування swappiness на основі розміру пам'яті, використання ZRAM та поточного використання підкачки</li>
                    <li>Розширені параметри пам'яті - min_free_kbytes, watermark_scale_factor, налаштування OOM</li>
                    <li>Подвійні режими роботи - продуктивний (агресивний) та енергозберігаючий (збалансований)</li>
                    <li>Перевірка налаштувань з перевіркою успішності</li>
                    <li>Безпечна обробка - перевірка доступності файлів перед записом</li>
                    <li>Детальне логування кожного зміненого параметра</li>
                </ul>
                <p><strong>Посилання:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        },
        zh: {
            title: "NextRAM v8.3.201-pre (83201p)",
            preview: "预发布版本，支持旧配置，swapoff 修复和智能动态 swappiness 调优。",
            content: `
                <h3>NextRAM v8.3.201-pre (83201p) 发布说明</h3>
                <p><strong>[INSTALL]</strong></p>
                <ul>
                    <li>添加对旧配置的支持（几乎 NextRAM 2+）</li>
                    <li>在配置缺少时添加新选项</li>
                </ul>
                <p><strong>[MAIN]</strong></p>
                <ul>
                    <li>修复 swapoff 选项</li>
                </ul>
                <p><strong>[KERNEL]</strong></p>
                <ul>
                    <li>基于内存大小、ZRAM 使用情况和当前交换利用率的智能动态 swappiness 调优</li>
                    <li>扩展内存参数 - min_free_kbytes、watermark_scale_factor、OOM 设置</li>
                    <li>双重操作模式 - 性能（激进）和节能（平衡）</li>
                    <li>设置验证与成功率检查</li>
                    <li>安全处理 - 写入前检查文件可用性</li>
                    <li>每个修改参数的详细日志记录</li>
                </ul>
                <p><strong>链接:</strong></p>
                <p>Telegram: https://t.me/nextram_official</p>
            `
        }
    }
];