// spl.js
class SettingsParameterLibrary {
    constructor() {
        this.currentLanguage = localStorage.getItem('language') || 'en';
        this.descriptions = this.getParameterDescriptions();
    }

    getParameterDescriptions() {
        return {
            'ZRAM_ENABLED': {
                en: { title: 'Enable ZRAM', description: 'Activates compressed RAM swap space. ZRAM compresses memory pages in RAM, providing additional virtual memory without using storage.' },
                ru: { title: 'Включить ZRAM', description: 'Активирует сжатое пространство подкачки в RAM. ZRAM сжимает страницы памяти в оперативной памяти, предоставляя дополнительную виртуальную память без использования хранилища.' },
                uk: { title: 'Увімкнути ZRAM', description: 'Активує стиснений простір підкачки в RAM. ZRAM стискає сторінки пам\'яті в оперативній пам\'яті, надаючи додаткову віртуальну пам\'ять без використання сховища.' },
                zh: { title: '启用 ZRAM', description: '激活压缩的 RAM 交换空间。ZRAM 压缩 RAM 中的内存页面，在不使用存储的情况下提供额外的虚拟内存。' }
            },
            'SWAP_ENABLED': {
                en: { title: 'Enable Swap File', description: 'Creates a traditional swap file on storage. Only recommended for devices with fast storage (UFS 3.0+ or NVMe).' },
                ru: { title: 'Включить файл подкачки', description: 'Создает традиционный файл подкачки на хранилище. Рекомендуется только для устройств с быстрой памятью (UFS 3.0+ или NVMe).' },
                uk: { title: 'Увімкнути файл підкачки', description: 'Створює традиційний файл підкачки на сховищі. Рекомендується тільки для пристроїв з швидкою пам\'яттю (UFS 3.0+ або NVMe).' },
                zh: { title: '启用交换文件', description: '在存储上创建传统的交换文件。仅推荐用于具有快速存储（UFS 3.0+ 或 NVMe）的设备。' }
            },
            'LOG_LEVEL': {
                en: { title: 'Log Level', description: 'Controls the amount of detail in logs. DEBUG for troubleshooting, INFO for normal use, WARN/ERROR for important messages only.' },
                ru: { title: 'Уровень логов', description: 'Контролирует детализацию логов. DEBUG для диагностики, INFO для обычного использования, WARN/ERROR только для важных сообщений.' },
                uk: { title: 'Рівень логів', description: 'Контролює деталізацію логів. DEBUG для діагностики, INFO для звичайного використання, WARN/ERROR тільки для важливих повідомлень.' },
                zh: { title: '日志级别', description: '控制日志的详细程度。DEBUG 用于故障排除，INFO 用于正常使用，WARN/ERROR 仅用于重要消息。' }
            },
            'EXTRA_TUNING': {
                en: { title: 'Enable Extra Tuning', description: 'Applies additional kernel memory management optimizations. May improve performance but test stability on your device.' },
                ru: { title: 'Включить доп. настройку', description: 'Применяет дополнительные оптимизации управления памятью ядра. Может улучшить производительность, но проверьте стабильность на вашем устройстве.' },
                uk: { title: 'Увімкнути дод. налаштування', description: 'Застосовує додаткові оптимізації управління пам\'яттю ядра. Може покращити продуктивність, але перевірте стабільність на вашому пристрої.' },
                zh: { title: '启用额外调优', description: '应用额外的内核内存管理优化。可能会提高性能，但请测试您设备上的稳定性。' }
            },
            'DYNAMIC_SWAPPINESS': {
                en: { title: 'Dynamic Swappiness', description: 'Automatically adjusts swappiness based on available memory and swap usage. May conflict with manual swappiness settings.' },
                ru: { title: 'Динамическая swappiness', description: 'Автоматически регулирует swappiness на основе доступной памяти и использования подкачки. Может конфликтовать с ручными настройками swappiness.' },
                uk: { title: 'Динамічна swappiness', description: 'Автоматично регулює swappiness на основі доступної пам\'яті та використання підкачки. Може конфліктувати з ручними налаштуваннями swappiness.' },
                zh: { title: '动态交换倾向', description: '根据可用内存和交换使用情况自动调整交换倾向。可能与手动交换倾向设置冲突。' }
            },
            'PERFORMANCE_MODE': {
                en: { title: 'Performance Mode', description: 'Aggressive memory management for maximum performance. Increases battery consumption significantly.' },
                ru: { title: 'Режим производительности', description: 'Агрессивное управление памятью для максимальной производительности. Значительно увеличивает потребление батареи.' },
                uk: { title: 'Режим продуктивності', description: 'Агресивне управління пам\'яттю для максимальної продуктивності. Значно збільшує споживання батареї.' },
                zh: { title: '性能模式', description: '积极的内存管理以获得最大性能。显著增加电池消耗。' }
            },
            'ZRAM_AUTO_TUNE': {
                en: { title: 'ZRAM Auto Tune', description: 'Automatically tests and selects optimal compression algorithms. May conflict with manual ZRAM settings.' },
                ru: { title: 'Автонастройка ZRAM', description: 'Автоматически тестирует и выбирает оптимальные алгоритмы сжатия. Может конфликтовать с ручными настройками ZRAM.' },
                uk: { title: 'Автоналаштування ZRAM', description: 'Автоматично тестує та вибирає оптимальні алгоритми стиснення. Може конфліктувати з ручними налаштуваннями ZRAM.' },
                zh: { title: 'ZRAM 自动调优', description: '自动测试并选择最佳压缩算法。可能与手动 ZRAM 设置冲突。' }
            },
            'IO_SCHEDULER_TUNE': {
                en: { title: 'I/O Scheduler Tune', description: 'Optimizes I/O schedulers for better storage performance. Recommended for most devices.' },
                ru: { title: 'Настройка I/O планировщика', description: 'Оптимизирует I/O планировщики для лучшей производительности хранилища. Рекомендуется для большинства устройств.' },
                uk: { title: 'Налаштування I/O планувальника', description: 'Оптимізує I/O планувальники для кращої продуктивності сховища. Рекомендується для більшості пристроїв.' },
                zh: { title: 'I/O 调度器调优', description: '优化 I/O 调度器以获得更好的存储性能。推荐用于大多数设备。' }
            },
            'CPU_BOOST': {
                en: { title: 'CPU Boost', description: 'Enables CPU frequency boosting for better responsiveness. Increases battery consumption.' },
                ru: { title: 'Ускорение CPU', description: 'Включает повышение частоты CPU для лучшей отзывчивости. Увеличивает потребление батареи.' },
                uk: { title: 'Прискорення CPU', description: 'Увімкнує підвищення частоти CPU для кращої відповіді. Збільшує споживання батареї.' },
                zh: { title: 'CPU 加速', description: '启用 CPU 频率提升以获得更好的响应能力。增加电池消耗。' }
            },
            'NETWORK_TUNE': {
                en: { title: 'Network Tune', description: 'Optimizes network buffer sizes for better throughput. Recommended for gaming and streaming.' },
                ru: { title: 'Настройка сети', description: 'Оптимизирует размеры сетевых буферов для лучшей пропускной способности. Рекомендуется для игр и потоковой передачи.' },
                uk: { title: 'Налаштування мережі', description: 'Оптимізує розміри мережевих буферів для кращої пропускної здатності. Рекомендується для ігор та потокової передачі.' },
                zh: { title: '网络调优', description: '优化网络缓冲区大小以获得更好的吞吐量。推荐用于游戏和流媒体。' }
            },
            'ZRAM_RATIO': {
                en: { title: 'ZRAM Size Ratio', description: 'ZRAM size = RAM size × ratio. Recommended: 1.0-2.0. Higher values provide more swap but may cause lag.' },
                ru: { title: 'Коэффициент размера ZRAM', description: 'Размер ZRAM = размер RAM × коэффициент. Рекомендуется: 1.0-2.0. Более высокие значения дают больше подкачки, но могут вызывать лаги.' },
                uk: { title: 'Коефіцієнт розміру ZRAM', description: 'Розмір ZRAM = розмір RAM × коефіцієнт. Рекомендується: 1.0-2.0. Вищі значення дають більше підкачки, але можуть викликати лаги.' },
                zh: { title: 'ZRAM 大小比率', description: 'ZRAM 大小 = RAM 大小 × 比率。推荐：1.0-2.0。更高的值提供更多交换空间但可能导致卡顿。' }
            },
            'ZRAM_ALGORITHM': {
                en: { title: 'Compression Algorithm', description: 'zstd: Best compression | lz4: Fastest | lzo: Balanced | lzo-rle: Improved lzo | deflate: Good compression but slower' },
                ru: { title: 'Алгоритм сжатия', description: 'zstd: Лучшее сжатие | lz4: Самое быстрое | lzo: Сбалансированное | lzo-rle: Улучшенный lzo | deflate: Хорошее сжатие, но медленнее' },
                uk: { title: 'Алгоритм стиснення', description: 'zstd: Найкраще стиснення | lz4: Найшвидше | lzo: Збалансоване | lzo-rle: Покращений lzo | deflate: Хороше стиснення, але повільніше' },
                zh: { title: '压缩算法', description: 'zstd: 最佳压缩 | lz4: 最快 | lzo: 平衡 | lzo-rle: 改进的 lzo | deflate: 良好压缩但较慢' }
            },
            'MAX_COMP_STREAMS': {
                en: { title: 'Max Compression Streams', description: 'Number of parallel compression streams. Set to match your CPU cores. More streams = better performance but higher CPU usage.' },
                ru: { title: 'Макс. потоков сжатия', description: 'Количество параллельных потоков сжатия. Установите по количеству ядер CPU. Больше потоков = лучше производительность, но выше использование CPU.' },
                uk: { title: 'Макс. потоків стиснення', description: 'Кількість паралельних потоків стиснення. Встановіть за кількістю ядер CPU. Більше потоків = краща продуктивність, але вище використання CPU.' },
                zh: { title: '最大压缩流', description: '并行压缩流的数量。设置与 CPU 核心数匹配。更多流 = 更好性能但更高的 CPU 使用率。' }
            },
            'ZRAM_PRIORITY': {
                en: { title: 'ZRAM Priority', description: 'Swap device priority (0-32767). Lower numbers have higher priority. -1 = highest priority.' },
                ru: { title: 'Приоритет ZRAM', description: 'Приоритет устройства подкачки (0-32767). Меньшие числа имеют более высокий приоритет. -1 = наивысший приоритет.' },
                uk: { title: 'Пріоритет ZRAM', description: 'Пріоритет пристрою підкачки (0-32767). Менші числа мають вищий пріоритет. -1 = найвищий пріоритет.' },
                zh: { title: 'ZRAM 优先级', description: '交换设备优先级 (0-32767)。数字越小优先级越高。-1 = 最高优先级。' }
            },
            'ZRAM_COMPRESSION_LEVEL': {
                en: { title: 'ZRAM Compression Level', description: 'Compression level (1-9). Higher = better compression but slower. zstd: 3-6 recommended, lz4: 1-3 recommended.' },
                ru: { title: 'Уровень сжатия ZRAM', description: 'Уровень сжатия (1-9). Выше = лучше сжатие, но медленнее. zstd: рекомендуется 3-6, lz4: рекомендуется 1-3.' },
                uk: { title: 'Рівень стиснення ZRAM', description: 'Рівень стиснення (1-9). Вище = краще стиснення, але повільніше. zstd: рекомендується 3-6, lz4: рекомендується 1-3.' },
                zh: { title: 'ZRAM 压缩级别', description: '压缩级别 (1-9)。越高 = 压缩越好但越慢。zstd：推荐 3-6，lz4：推荐 1-3。' }
            },
            'ZRAM_MEMORY_LIMIT': {
                en: { title: 'ZRAM Memory Limit', description: 'Maximum memory ZRAM can use (e.g., 4G, 2G). Leave empty for no limit.' },
                ru: { title: 'Лимит памяти ZRAM', description: 'Максимальная память, которую может использовать ZRAM (например, 4G, 2G). Оставьте пустым для отсутствия лимита.' },
                uk: { title: 'Ліміт пам\'яті ZRAM', description: 'Максимальна пам\'ять, яку може використовувати ZRAM (наприклад, 4G, 2G). Залиште порожнім для відсутності ліміту.' },
                zh: { title: 'ZRAM 内存限制', description: 'ZRAM 可以使用的最大内存（例如 4G, 2G）。留空表示无限制。' }
            },
            'SWAP_SIZE_GB': {
                en: { title: 'Swap Size (GB)', description: 'Size of the swap file in gigabytes. Recommended: 1.0-4.0 GB depending on available storage.' },
                ru: { title: 'Размер подкачки (ГБ)', description: 'Размер файла подкачки в гигабайтах. Рекомендуется: 1.0-4.0 ГБ в зависимости от доступного хранилища.' },
                uk: { title: 'Розмір підкачки (ГБ)', description: 'Розмір файлу підкачки в гігабайтах. Рекомендується: 1.0-4.0 ГБ залежно від доступного сховища.' },
                zh: { title: '交换大小 (GB)', description: '交换文件的大小（以 GB 为单位）。推荐：1.0-4.0 GB，取决于可用存储空间。' }
            },
            'OVERHEAD_GB': {
                en: { title: 'Filesystem Overhead (GB)', description: 'Additional space for filesystem metadata. Usually 0.1-0.3 GB. Prevents "no space" errors.' },
                ru: { title: 'Накладные расходы ФС (ГБ)', description: 'Дополнительное пространство для метаданных файловой системы. Обычно 0.1-0.3 ГБ. Предотвращает ошибки "нет места".' },
                uk: { title: 'Накладні витрати ФС (ГБ)', description: 'Додатковий простір для метаданих файлової системи. Зазвичай 0.1-0.3 ГБ. Запобігає помилкам "немає місця".' },
                zh: { title: '文件系统开销 (GB)', description: '用于文件系统元数据的额外空间。通常为 0.1-0.3 GB。防止"空间不足"错误。' }
            },
            'SWAP_PRIORITY': {
                en: { title: 'Swap Priority', description: 'Swap file priority (0-32767). Lower numbers have higher priority. -1 = highest priority.' },
                ru: { title: 'Приоритет подкачки', description: 'Приоритет файла подкачки (0-32767). Меньшие числа имеют более высокий приоритет. -1 = наивысший приоритет.' },
                uk: { title: 'Пріоритет підкачки', description: 'Пріоритет файлу підкачки (0-32767). Менші числа мають вищий пріоритет. -1 = найвищий пріоритет.' },
                zh: { title: '交换优先级', description: '交换文件优先级 (0-32767)。数字越小优先级越高。-1 = 最高优先级。' }
            },
            'SWAPPINESS': {
                en: { title: 'Swappiness', description: 'How aggressively to swap (0-100). 0=minimal swapping, 100=maximum swapping. Recommended: 60-80 for balanced use.' },
                ru: { title: 'Swappiness', description: 'Насколько агрессивно использовать подкачку (0-100). 0=минимальная подкачка, 100=максимальная подкачка. Рекомендуется: 60-80 для сбалансированного использования.' },
                uk: { title: 'Swappiness', description: 'Наскільки агресивно використовувати підкачку (0-100). 0=мінімальна підкачка, 100=максимальна підкачка. Рекомендується: 60-80 для збалансованого використання.' },
                zh: { title: '交换倾向', description: '交换的积极程度 (0-100)。0=最小交换，100=最大交换。推荐：60-80 用于平衡使用。' }
            },
            'CACHE_PRESSURE': {
                en: { title: 'Cache Pressure', description: 'How quickly to reclaim cache memory (1-100). Higher values = more aggressive cache reclaiming.' },
                ru: { title: 'Давление кэша', description: 'Как быстро освобождать кэш-память (1-100). Более высокие значения = более агрессивное освобождение кэша.' },
                uk: { title: 'Тиск кешу', description: 'Як швидко звільняти кеш-пам\'ять (1-100). Вищі значення = більш агресивне звільнення кешу.' },
                zh: { title: '缓存压力', description: '回收缓存内存的速度 (1-100)。值越高 = 越积极地回收缓存。' }
            },
            'DIRTY_RATIO': {
                en: { title: 'Dirty Ratio', description: 'Percentage of total memory when dirty pages must be written to disk (10-40). Higher = better performance but more risk of data loss.' },
                ru: { title: 'Dirty Ratio', description: 'Процент общей памяти, при котором "грязные" страницы должны быть записаны на диск (10-40). Выше = лучше производительность, но больше риск потери данных.' },
                uk: { title: 'Dirty Ratio', description: 'Відсоток загальної пам\'яті, коли "брудні" сторінки мають бути записані на диск (10-40). Вище = краща продуктивність, але більше ризик втрати даних.' },
                zh: { title: '脏页比率', description: '脏页必须写入磁盘时的总内存百分比 (10-40)。越高 = 性能越好但数据丢失风险更大。' }
            },
            'DIRTY_BACKGROUND_RATIO': {
                en: { title: 'Dirty Background Ratio', description: 'Percentage of total memory when background writeback of dirty pages starts (5-20). Should be lower than Dirty Ratio.' },
                ru: { title: 'Dirty Background Ratio', description: 'Процент общей памяти, при котором начинается фоновая запись "грязных" страниц (5-20). Должен быть ниже Dirty Ratio.' },
                uk: { title: 'Dirty Background Ratio', description: 'Відсоток загальної пам\'яті, коли починається фоновий запис "брудних" сторінок (5-20). Повинен бути нижче за Dirty Ratio.' },
                zh: { title: '后台脏页比率', description: '开始后台写入脏页时的总内存百分比 (5-20)。应低于脏页比率。' }
            },
            'VM_DIRTY_WRITEBACK_CENTISECS': {
                en: { title: 'Dirty Writeback Centisecs', description: 'How often dirty data is written to disk (in centiseconds). Lower = more frequent writes, higher performance but more power usage.' },
                ru: { title: 'Dirty Writeback Centisecs', description: 'Как часто "грязные" данные записываются на диск (в сантисекундах). Ниже = более частые записи, выше производительность, но больше потребление энергии.' },
                uk: { title: 'Dirty Writeback Centisecs', description: 'Як часто "брудні" дані записуються на диск (у сантисекундах). Нижче = більш часті записи, вища продуктивність, але більше споживання енергії.' },
                zh: { title: '脏页写回间隔', description: '脏数据写入磁盘的频率（以厘秒为单位）。越低 = 写入越频繁，性能越高但功耗更大。' }
            },
            'VM_DIRTY_EXPIRE_CENTISECS': {
                en: { title: 'Dirty Expire Centisecs', description: 'How long dirty data can remain in memory before being written (in centiseconds). Lower = less data loss risk but more I/O.' },
                ru: { title: 'Dirty Expire Centisecs', description: 'Как долго "грязные" данные могут оставаться в памяти перед записью (в сантисекундах). Ниже = меньше риск потери данных, но больше операций ввода-вывода.' },
                uk: { title: 'Dirty Expire Centisecs', description: 'Як довго "брудні" дані можуть залишатися в пам\'яті перед записом (у сантисекундах). Нижче = менше ризик втрати даних, але більше операцій вводу-виводу.' },
                zh: { title: '脏页过期时间', description: '脏数据在写入前可以在内存中保留的时间（以厘秒为单位）。越低 = 数据丢失风险越小但 I/O 更多。' }
            },
            'VM_PAGE_CLUSTER': {
                en: { title: 'Page Cluster', description: 'Number of pages to read/write in single I/O operation (0-4). 0=disable readahead, 3=default, higher=better sequential performance.' },
                ru: { title: 'Page Cluster', description: 'Количество страниц для чтения/записи в одной операции ввода-вывода (0-4). 0=отключить упреждающее чтение, 3=по умолчанию, выше=лучшая последовательная производительность.' },
                uk: { title: 'Page Cluster', description: 'Кількість сторінок для читання/запису в одній операції вводу-виводу (0-4). 0=вимкнути випереджальне читання, 3=за замовчуванням, вище=краща послідовна продуктивність.' },
                zh: { title: '页面簇', description: '单次 I/O 操作中读取/写入的页面数 (0-4)。0=禁用预读，3=默认，越高=顺序性能越好。' }
            },
            'VM_LAPTOP_MODE': {
                en: { title: 'Laptop Mode', description: 'Power-saving mode that batches disk writes (0-3). 0=disabled, higher=more aggressive power saving.' },
                ru: { title: 'Laptop Mode', description: 'Энергосберегающий режим, который группирует записи на диск (0-3). 0=отключено, выше=более агрессивное энергосбережение.' },
                uk: { title: 'Laptop Mode', description: 'Енергозберігаючий режим, який групує записи на диск (0-3). 0=вимкнено, вище=більш агресивне енергозбереження.' },
                zh: { title: '笔记本模式', description: '批处理磁盘写入的省电模式 (0-3)。0=禁用，越高=越积极的省电。' }
            },
            'VM_OOM_KILL_ALLOCATING_TASK': {
                en: { title: 'OOM Kill Allocating Task', description: 'When out of memory, kill the task that triggered OOM instead of the largest memory user. Can help with responsiveness.' },
                ru: { title: 'OOM Kill Allocating Task', description: 'При нехватке памяти убивать задачу, вызвавшую OOM, вместо крупнейшего потребителя памяти. Может помочь с отзывчивостью.' },
                uk: { title: 'OOM Kill Allocating Task', description: 'При нестачі пам\'яті вбивати задачу, що викликала OOM, замість найбільшого споживача пам\'яті. Може допомогти з відповіддю.' },
                zh: { title: 'OOM 杀死分配任务', description: '内存不足时，杀死触发 OOM 的任务而不是最大的内存用户。有助于提高响应能力。' }
            },
            'VM_PANIC_ON_OOM': {
                en: { title: 'Panic on OOM', description: 'System behavior when out of memory: 0=continue normally, 1=panic after OOM kill, 2=panic immediately.' },
                ru: { title: 'Panic on OOM', description: 'Поведение системы при нехватке памяти: 0=продолжать нормально, 1=panic после OOM kill, 2=panic немедленно.' },
                uk: { title: 'Panic on OOM', description: 'Поведінка системи при нестачі пам\'яті: 0=продовжувати нормально, 1=panic після OOM kill, 2=panic негайно.' },
                zh: { title: 'OOM 时恐慌', description: '内存不足时的系统行为：0=正常继续，1=OOM 杀死后恐慌，2=立即恐慌。' }
            },
            'VM_OVERCOMMIT_MEMORY': {
                en: { title: 'Overcommit Memory', description: 'Memory overcommit policy: 0=heuristic, 1=always overcommit, 2=no overcommit. 1 is recommended for performance.' },
                ru: { title: 'Overcommit Memory', description: 'Политика overcommit памяти: 0=эвристическая, 1=всегда overcommit, 2=нет overcommit. 1 рекомендуется для производительности.' },
                uk: { title: 'Overcommit Memory', description: 'Політика overcommit пам\'яті: 0=евристична, 1=завжди overcommit, 2=немає overcommit. 1 рекомендується для продуктивності.' },
                zh: { title: '内存超配', description: '内存超配策略：0=启发式，1=总是超配，2=不超配。推荐 1 以获得性能。' }
            },
            'VM_OVERCOMMIT_RATIO': {
                en: { title: 'Overcommit Ratio', description: 'Percentage of RAM that can be overcommitted when overcommit is enabled. Higher = more virtual memory but more swap usage.' },
                ru: { title: 'Overcommit Ratio', description: 'Процент RAM, который может быть overcommit при включенном overcommit. Выше = больше виртуальной памяти, но больше использование подкачки.' },
                uk: { title: 'Overcommit Ratio', description: 'Відсоток RAM, який може бути overcommit при увімкненому overcommit. Вище = більше віртуальної пам\'яті, але більше використання підкачки.' },
                zh: { title: '超配比率', description: '启用超配时可以超配的 RAM 百分比。越高 = 虚拟内存越多但交换使用越多。' }
            },
            'VM_WATERMARK_SCALE_FACTOR': {
                en: { title: 'Watermark Scale Factor', description: 'Adjusts memory watermarks (1-1000). Higher = more aggressive memory reclaiming, lower = more caching.' },
                ru: { title: 'Watermark Scale Factor', description: 'Регулирует уровни памяти (1-1000). Выше = более агрессивное освобождение памяти, ниже = больше кэширования.' },
                uk: { title: 'Watermark Scale Factor', description: 'Регулює рівні пам\'яті (1-1000). Вище = більш агресивне звільнення пам\'яті, нижче = більше кешування.' },
                zh: { title: '水位标度因子', description: '调整内存水位线 (1-1000)。越高 = 越积极地回收内存，越低 = 缓存越多。' }
            },
            'KERNEL_THREADS_MAX': {
                en: { title: 'Kernel Threads Max', description: 'Maximum number of kernel threads (0=auto). Increase for heavy multitasking, decrease for memory-constrained devices.' },
                ru: { title: 'Kernel Threads Max', description: 'Максимальное количество потоков ядра (0=авто). Увеличить для тяжелой многозадачности, уменьшить для устройств с ограниченной памятью.' },
                uk: { title: 'Kernel Threads Max', description: 'Максимальна кількість потоків ядра (0=авто). Збільшити для важкої багатозадачності, зменшити для пристроїв з обмеженою пам\'яттю.' },
                zh: { title: '内核线程最大数', description: '内核线程的最大数量 (0=自动)。增加用于重度多任务，减少用于内存受限设备。' }
            },
'GLASS_EFFECT': {
    en: { title: 'Glass Effect', description: 'Applies semi-transparent background with blur effect for modern glass-like interface appearance.' },
    ru: { title: 'Стеклянный эффект', description: 'Применяет полупрозрачный фон с эффектом размытия для современного стеклоподобного интерфейса.' },
    uk: { title: 'Скляний ефект', description: 'Застосовує напівпрозорий фон з ефектом розмиття для сучасного склоподібного інтерфейсу.' },
    zh: { title: '玻璃效果', description: '应用半透明背景和模糊效果，实现现代玻璃般的界面外观。' }
},
'MATERIAL_YOU': {
    en: { title: 'Material You', description: 'Uses dynamic system colors from Android 12+ for personalized interface that matches your wallpaper.' },
    ru: { title: 'Material You', description: 'Использует динамические системные цвета из Android 12+ для персонализированного интерфейса, соответствующего вашим обоям.' },
    uk: { title: 'Material You', description: 'Використовує динамічні системні кольори з Android 12+ для персоналізованого інтерфейсу, що відповідає вашим шпалерам.' },
    zh: { title: 'Material You', description: '使用 Android 12+ 的动态系统颜色，实现与壁纸匹配的个性化界面。' }
}
        };
    }

    getDescription(paramId) {
        const desc = this.descriptions[paramId];
        if (!desc) return null;
        
        return desc[this.currentLanguage] || desc.en;
    }

    setLanguage(language) {
        this.currentLanguage = language;
    }
}

window.spl = new SettingsParameterLibrary();