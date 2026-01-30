# NextRAM Configuration Parameters Documentation

## English

| Parameter | Type | Default | Description |
| :-------- | :--- | :------ | :---------- |
| `SWAP_ENABLED` | Boolean | `false` | Enables or disables the creation and activation of a traditional swap file on disk. |
| `SWAP_SIZE_GB` | Float | `1.0` | Size of the swap file to create in Gigabytes. |
| `OVERHEAD_GB` | Float | `0.3` | Additional space reserved on the swap image file for filesystem overhead. |
| `ZRAM_ENABLED` | Boolean | `true` | Enables or disables the initialization and activation of a ZRAM block device. |
| `ZRAM_RATIO` | Float | `1.5` | Multiplier for total RAM to calculate the base size of the ZRAM device. |
| `ZRAM_ALGORITHM` | String | `lz4` | Compression algorithm used by ZRAM (e.g., lz4, zstd, lzo). |
| `MAX_COMP_STREAMS` | Integer | `4` | Limits the maximum number of parallel compression streams for ZRAM. |
| `SWAPPINESS` | Integer | `100` | Kernel parameter controlling the tendency to use swap/ZRAM. Higher values favor swapping. |
| `CACHE_PRESSURE` | Integer | `100` | Kernel parameter influencing the kernel's tendency to reclaim memory from caches. |
| `DIRTY_RATIO` | Integer | `20` | Percentage of total memory at which a process starts writing dirty pages to storage. |
| `DIRTY_BACKGROUND_RATIO` | Integer | `10` | Percentage of total memory at which the kernel background process starts writing dirty pages. |
| `EXTRA_TUNING` | Boolean | `false` | Enables additional, more aggressive kernel parameter tuning if true. |
| `DYNAMIC_SWAPPINESS` | Boolean | `true` | If enabled, automatically adjusts the `SWAPPINESS` value based on system memory usage and swap activity. |
| `PERFORMANCE_MODE` | Boolean | `false` | Enables performance-oriented kernel tuning parameters if true. |
| `ZRAM_AUTO_TUNE` | Boolean | `false` | If true, runs an algorithm test on boot to select the optimal ZRAM compression algorithm. |
| `LOG_LEVEL` | String | `INFO` | Sets the verbosity of logging (DEBUG, INFO, WARN, ERROR). |
| `VM_DIRTY_WRITEBACK_CENTISECS` | Integer | `1500` | Time in centiseconds (1/100th sec) between writeback of dirty pages. |
| `VM_DIRTY_EXPIRE_CENTISECS` | Integer | `3000` | Time in centiseconds before dirty data is old enough to be written. |
| `VM_PAGE_CLUSTER` | Integer | `0` | Number of pages to write to swap in a single operation, optimized based on ZRAM algorithm. |
| `VM_LAPTOP_MODE` | Integer | `0` | Tunes VM for power savings if non-zero (value 0-5, 0 disables). |
| `VM_OOM_KILL_ALLOCATING_TASK` | Integer | `0` | If 1, the OOM killer tries to kill the allocating task first. |
| `VM_PANIC_ON_OOM` | Integer | `0` | If 1, the kernel panics on an out-of-memory condition. |
| `VM_OVERCOMMIT_MEMORY` | Integer | `1` | Controls memory overcommit handling (0: heuristic, 1: always allow, 2: strict). |
| `VM_OVERCOMMIT_RATIO` | Integer | `50` | Percentage of RAM considered available for overcommit when `VM_OVERCOMMIT_MEMORY=2`. |
| `VM_WATERMARK_SCALE_FACTOR` | Integer | `10` | Adjusts the scale factor for low, high, and min watermarks for memory management. |
| `KERNEL_THREADS_MAX` | Integer | `0` | Sets the maximum number of kernel threads. 0 means use default. |
| `ZRAM_COMPRESSION_LEVEL` | Integer | `1` | Compression level for the ZRAM algorithm (if supported). |
| `ZRAM_MEMORY_LIMIT` | String | `4G` | Hard limit on the amount of physical memory ZRAM can use (e.g., 4G). |
| `SWAP_PRIORITY` | Integer | `10` | Priority of the swap file when multiple swap areas are active (higher number = higher priority). |
| `ZRAM_PRIORITY` | Integer | Integer | `100` | Priority of the ZRAM device (usually higher than swap file). |
| `IO_SCHEDULER_TUNE` | Boolean | `false` | If true, tunes I/O scheduler parameters for potentially better performance. |
| `CPU_BOOST` | Boolean | `false` | If true, applies CPU boost related kernel parameters. |
| `NETWORK_TUNE` | Boolean | `false` | If true, tunes network buffer and congestion parameters. |
| `PLAY_ENABLED` | Boolean | `true` | Enables or disables the NextRAM Play gaming mode feature. |
| `PLAY_CPU_BOOST` | Boolean | `true` | Enables CPU boost features when Play mode is active. |
| `PLAY_CPU_GOVERNOR` | String | `performance` | CPU frequency scaling governor to set during Play mode (e.g., performance, interactive). |
| `PLAY_CPU_MIN_FREQ` | Integer | `0` | Minimum CPU frequency (in MHz) to set during Play mode. 0 means no change. |
| `PLAY_CPU_MAX_FREQ` | Integer | `0` | Maximum CPU frequency (in MHz) to set during Play mode. 0 means no change. |
| `PLAY_CPU_MAX_FREQ_PERCENT` | Integer | `100` | Sets maximum CPU frequency as a percentage of its maximum capability. |
| `PLAY_CPU_BOOST_DURATION` | Integer | `2000` | Duration (in milliseconds) for CPU boost when input is detected. |
| `PLAY_CPU_BOOST_LEVEL` | Integer | `50` | Level or intensity of the dynamic CPU boost. |
| `PLAY_GPU_BOOST` | Boolean | `true` | Enables GPU boost features when Play mode is active. |
| `PLAY_GPU_GOVERNOR` | String | `performance` | GPU frequency scaling governor to set during Play mode. |
| `PLAY_GPU_MAX_FREQ_PERCENT` | Integer | `100` | Sets maximum GPU frequency as a percentage of its maximum capability. |
| `PLAY_GPU_TOUCH_BOOST` | Boolean | `true` | Enables GPU boost when touch input is detected. |
| `PLAY_TOUCH_BOOST` | Boolean | `true` | Enables touch responsiveness optimizations. |
| `PLAY_TOUCH_POLLING_RATE` | Integer | `250` | Sets the polling rate for touch input in Hz. |
| `PLAY_VSYNC_MODE` | String | `adaptive` | Sets the VSync mode (on, off, adaptive) for smoother gameplay. |
| `PLAY_DISABLE_HW_OVERLAYS` | Boolean | `false` | Attempts to disable hardware overlays to force GPU rendering. |
| `PLAY_FORCE_GPU_RENDER` | Boolean | `true` | Forces applications to use GPU for rendering. |
| `PLAY_NETWORK_TUNE` | Boolean | `true` | Applies network optimizations for gaming if true. |
| `PLAY_NET_RMEM_DEFAULT` | Integer | `262144` | Default size of receive socket memory buffer. |
| `PLAY_NET_WMEM_DEFAULT` | Integer | `262144` | Default size of send socket memory buffer. |
| `PLAY_NET_RMEM_MAX` | Integer | `67108864` | Maximum size of receive socket memory buffer. |
| `PLAY_NET_WMEM_MAX` | Integer | `67108864` | Maximum size of send socket memory buffer. |
| `PLAY_TCP_CONGESTION` | String | `bbr` | TCP congestion control algorithm to use for gaming (e.g., bbr, cubic). |
| `PLAY_SWAPPINESS` | Integer | `20` | Swappiness value used specifically during Play mode (usually lower). |
| `PLAY_CACHE_PRESSURE` | Integer | `50` | Cache pressure value used specifically during Play mode. |
| `PLAY_DIRTY_RATIO` | Integer | `10` | Dirty ratio used specifically during Play mode. |
| `PLAY_DIRTY_BG_RATIO` | Integer | `5` | Dirty background ratio used specifically during Play mode. |
| `PLAY_ZRAM_OPTIMIZE` | Boolean | `true` | Optimizes ZRAM settings (algorithm, streams) specifically for Play mode. |
| `PLAY_CLEAR_CACHES` | Boolean | `true` | Clears system caches when Play mode starts. |
| `PLAY_THERMAL_CONTROL` | Boolean | `true` | Enables thermal management adjustments during Play mode. |
| `PLAY_THERMAL_PROFILE` | String | `balanced` | Thermal profile to apply (aggressive, conservative, balanced). |
| `PLAY_BG_CONTROL` | Boolean | `true` | Enables control of background processes during Play mode. |
| `PLAY_BG_WHITELIST` | String | `com.discord,com.spotify.music,com.chrome` | Comma-separated list of app packages to keep running in the background. |
| `PLAY_BG_KILL_LIMIT` | Integer | `10` | Limit on the number of background processes killed. |
| `PLAY_AUTO_DETECT` | Boolean | `true` | Enables automatic detection of when a game is running to trigger Play mode. |
| `PLAY_GAME_PROFILE` | String | `auto` | Specifies a default game profile to apply. |
| `PLAY_PERF_MONITOR` | Boolean | `true` | Enables performance monitoring during Play mode. |
| `PLAY_PERF_OVERLAY` | Boolean | `false` | Enables an in-game performance overlay (if supported). |
| `PLAY_AUDIO_LATENCY` | String | `low` | Sets audio latency mode (e.g., low). |
| `PLAY_AUDIO_BUFFER` | Integer | `128` | Sets audio buffer size. |
| `PLAY_CHARGING_BOOST` | Boolean | `true` | Applies performance boosts when the device is charging. |
| `PLAY_BATTERY_SAVER` | Boolean | `false` | Reduces performance when battery is low. |
| `PLAY_POWER_LIMIT` | Integer | `0` | Power limit to apply during Play mode. 0 means no limit. |
| `PLAY_REALTIME_PRIORITY` | Boolean | `true` | Attempts to give game processes higher priority. |
| `PLAY_CPU_AFFINITY` | String | `0-3` | CPU cores to which game processes can be bound (e.g., 0-3, 4-7). |
| `PLAY_MEMORY_LOCK` | Boolean | `false` | Attempts to lock game memory to prevent swapping. |
| `PLAY_IOSCHED_TUNE` | Boolean | `true` | Tunes I/O scheduler specifically during Play mode. |

## Russian

| Параметр | Тип | По умолчанию | Описание |
| :-------- | :--- | :------ | :---------- |
| `SWAP_ENABLED` | Boolean | `false` | Включает или отключает создание и активацию традиционного файла подкачки на диске. |
| `SWAP_SIZE_GB` | Float | `1.0` | Размер файла подкачки в Гигабайтах. |
| `OVERHEAD_GB` | Float | `0.3` | Дополнительное место, зарезервированное в файле образа подкачки для служебных нужд файловой системы. |
| `ZRAM_ENABLED` | Boolean | `true` | Включает или отключает инициализацию и активацию устройства ZRAM. |
| `ZRAM_RATIO` | Float | `1.5` | Множитель для общего объема ОЗУ для расчета базового размера устройства ZRAM. |
| `ZRAM_ALGORITHM` | String | `lz4` | Алгоритм сжатия, используемый ZRAM (например, lz4, zstd, lzo). |
| `MAX_COMP_STREAMS` | Integer | `4` | Ограничивает максимальное количество параллельных потоков сжатия для ZRAM. |
| `SWAPPINESS` | Integer | `100` | Параметр ядра, контролирующий склонность к использованию подкачки/ZRAM. Более высокие значения способствуют подкачке. |
| `CACHE_PRESSURE` | Integer | `100` | Параметр ядра, влияющий на склонность ядра освобождать память из кэшей. |
| `DIRTY_RATIO` | Integer | `20` | Процент от общей памяти, при котором процесс начинает записывать грязные страницы на диск. |
| `DIRTY_BACKGROUND_RATIO` | Integer | `10` | Процент от общей памяти, при котором фоновый процесс ядра начинает записывать грязные страницы. |
| `EXTRA_TUNING` | Boolean | `false` | Включает дополнительные, более агрессивные настройки параметров ядра. |
| `DYNAMIC_SWAPPINESS` | Boolean | `true` | Если включено, автоматически регулирует значение `SWAPPINESS` на основе использования памяти и активности подкачки. |
| `PERFORMANCE_MODE` | Boolean | `false` | Включает параметры настройки ядра, ориентированные на производительность. |
| `ZRAM_AUTO_TUNE` | Boolean | `false` | Если включено, запускает тест алгоритмов при загрузке для выбора оптимального алгоритма сжатия ZRAM. |
| `LOG_LEVEL` | String | `INFO` | Устанавливает уровень подробности логирования (DEBUG, INFO, WARN, ERROR). |
| `VM_DIRTY_WRITEBACK_CENTISECS` | Integer | `1500` | Время в сантисекундах (1/100 сек) между записью грязных страниц. |
| `VM_DIRTY_EXPIRE_CENTISECS` | Integer | `3000` | Время в сантисекундах, прежде чем грязные данные станут достаточно старыми для записи. |
| `VM_PAGE_CLUSTER` | Integer | `0` | Количество страниц для записи в подкачку за одну операцию, оптимизируется в зависимости от алгоритма ZRAM. |
| `VM_LAPTOP_MODE` | Integer | `0` | Настройка виртуальной памяти для экономии энергии (значение 0-5, 0 отключает). |
| `VM_OOM_KILL_ALLOCATING_TASK` | Integer | `0` | Если 1, убийца OOM пытается сначала убить задачу, выделяющую память. |
| `VM_PANIC_ON_OOM` | Integer | `0` | Если 1, ядро вызывает панику при нехватке памяти. |
| `VM_OVERCOMMIT_MEMORY` | Integer | `1` | Управляет обработкой переполнения памяти (0: эвристически, 1: всегда разрешать, 2: строго). |
| `VM_OVERCOMMIT_RATIO` | Integer | `50` | Процент ОЗУ, считаемый доступным для переполнения при `VM_OVERCOMMIT_MEMORY=2`. |
| `VM_WATERMARK_SCALE_FACTOR` | Integer | `10` | Регулирует масштабный коэффициент для низких, высоких и минимальных водяных знаков управления памятью. |
| `KERNEL_THREADS_MAX` | Integer | `0` | Устанавливает максимальное количество потоков ядра. 0 означает использовать значение по умолчанию. |
| `ZRAM_COMPRESSION_LEVEL` | Integer | `1` | Уровень сжатия для алгоритма ZRAM (если поддерживается). |
| `ZRAM_MEMORY_LIMIT` | String | `4G` | Жесткое ограничение на объем физической памяти, которую может использовать ZRAM (например, 4G). |
| `SWAP_PRIORITY` | Integer | `10` | Приоритет файла подкачки при активных нескольких областях подкачки (большее число = выше приоритет). |
| `ZRAM_PRIORITY` | Integer | `100` | Приоритет устройства ZRAM (обычно выше, чем у файла подкачки). |
| `IO_SCHEDULER_TUNE` | Boolean | `false` | Если включено, настраивает параметры планировщика ввода-вывода для потенциально лучшей производительности. |
| `CPU_BOOST` | Boolean | `false` | Если включено, применяет параметры ядра, связанные с ускорением ЦП. |
| `NETWORK_TUNE` | Boolean | `false` | Если включено, настраивает сетевые буферы и параметры перегрузки. |
| `PLAY_ENABLED` | Boolean | `true` | Включает или отключает функцию игрового режима NextRAM Play. |
| `PLAY_CPU_BOOST` | Boolean | `true` | Включает функции ускорения ЦП, когда активен игровой режим. |
| `PLAY_CPU_GOVERNOR` | String | `performance` | Регулятор масштабирования частоты ЦП, устанавливаемый во время игрового режима (например, performance, interactive). |
| `PLAY_CPU_MIN_FREQ` | Integer | `0` | Минимальная частота ЦП (в МГц), устанавливаемая во время игрового режима. 0 означает без изменений. |
| `PLAY_CPU_MAX_FREQ` | Integer | `0` | Максимальная частота ЦП (в МГц), устанавливаемая во время игрового режима. 0 означает без изменений. |
| `PLAY_CPU_MAX_FREQ_PERCENT` | Integer | `100` | Устанавливает максимальную частоту ЦП в процентах от его максимальной возможности. |
| `PLAY_CPU_BOOST_DURATION` | Integer | `2000` | Длительность (в миллисекундах) ускорения ЦП при обнаружении ввода. |
| `PLAY_CPU_BOOST_LEVEL` | Integer | `50` | Уровень или интенсивность динамического ускорения ЦП. |
| `PLAY_GPU_BOOST` | Boolean | `true` | Включает функции ускорения GPU, когда активен игровой режим. |
| `PLAY_GPU_GOVERNOR` | String | `performance` | Регулятор масштабирования частоты GPU, устанавливаемый во время игрового режима. |
| `PLAY_GPU_MAX_FREQ_PERCENT` | Integer | `100` | Устанавливает максимальную частоту GPU в процентах от его максимальной возможности. |
| `PLAY_GPU_TOUCH_BOOST` | Boolean | `true` | Включает ускорение GPU при обнаружении сенсорного ввода. |
| `PLAY_TOUCH_BOOST` | Boolean | `true` | Включает оптимизацию отзывчивости сенсора. |
| `PLAY_TOUCH_POLLING_RATE` | Integer | `250` | Устанавливает частоту опроса сенсорного ввода в Гц. |
| `PLAY_VSYNC_MODE` | String | `adaptive` | Устанавливает режим VSync (on, off, adaptive) для более плавной игры. |
| `PLAY_DISABLE_HW_OVERLAYS` | Boolean | `false` | Пытается отключить аппаратные оверлеи, чтобы заставить рендеринг через GPU. |
| `PLAY_FORCE_GPU_RENDER` | Boolean | `true` | Принуждает приложения использовать GPU для рендеринга. |
| `PLAY_NETWORK_TUNE` | Boolean | `true` | Применяет сетевые оптимизации для игр. |
| `PLAY_NET_RMEM_DEFAULT` | Integer | `262144` | Размер буфера памяти сокета по умолчанию для приема. |
| `PLAY_NET_WMEM_DEFAULT` | Integer | `262144` | Размер буфера памяти сокета по умолчанию для отправки. |
| `PLAY_NET_RMEM_MAX` | Integer | `67108864` | Максимальный размер буфера памяти сокета для приема. |
| `PLAY_NET_WMEM_MAX` | Integer | `67108864` | Максимальный размер буфера памяти сокета для отправки. |
| `PLAY_TCP_CONGESTION` | String | `bbr` | Алгоритм управления перегрузкой TCP для использования в играх (например, bbr, cubic). |
| `PLAY_SWAPPINESS` | Integer | `20` | Значение swappiness, используемое специально во время игрового режима (обычно ниже). |
| `PLAY_CACHE_PRESSURE` | Integer | `50` | Значение давления кэша, используемое специально во время игрового режима. |
| `PLAY_DIRTY_RATIO` | Integer | `10` | Коэффициент грязных данных, используемый специально во время игрового режима. |
| `PLAY_DIRTY_BG_RATIO` | Integer | `5` | Коэффициент фоновых грязных данных, используемый специально во время игрового режима. |
| `PLAY_ZRAM_OPTIMIZE` | Boolean | `true` | Оптимизирует настройки ZRAM (алгоритм, потоки) специально для игрового режима. |
| `PLAY_CLEAR_CACHES` | Boolean | `true` | Очищает системные кэши при запуске игрового режима. |
| `PLAY_THERMAL_CONTROL` | Boolean | `true` | Включает корректировку управления температурой во время игрового режима. |
| `PLAY_THERMAL_PROFILE` | String | `balanced` | Тепловой профиль для применения (агрессивный, консервативный, сбалансированный). |
| `PLAY_BG_CONTROL` | Boolean | `true` | Включает контроль фоновых процессов во время игрового режима. |
| `PLAY_BG_WHITELIST` | String | `com.discord,com.spotify.music,com.chrome` | Список пакетов приложений, разделенных запятыми, которые должны продолжать работать в фоновом режиме. |
| `PLAY_BG_KILL_LIMIT` | Integer | `10` | Ограничение на количество убиваемых фоновых процессов. |
| `PLAY_AUTO_DETECT` | Boolean | `true` | Включает автоматическое определение запуска игры для включения игрового режима. |
| `PLAY_GAME_PROFILE` | String | `auto` | Указывает профиль игры по умолчанию для применения. |
| `PLAY_PERF_MONITOR` | Boolean | `true` | Включает мониторинг производительности во время игрового режима. |
| `PLAY_PERF_OVERLAY` | Boolean | `false` | Включает оверлей производительности в игре (если поддерживается). |
| `PLAY_AUDIO_LATENCY` | String | `low` | Устанавливает режим задержки аудио (например, low). |
| `PLAY_AUDIO_BUFFER` | Integer | `128` | Устанавливает размер аудио буфера. |
| `PLAY_CHARGING_BOOST` | Boolean | `true` | Применяет ускорение производительности при зарядке устройства. |
| `PLAY_BATTERY_SAVER` | Boolean | `false` | Снижает производительность при низком заряде батареи. |
| `PLAY_POWER_LIMIT` | Integer | `0` | Ограничение мощности, применяемое во время игрового режима. 0 означает без ограничений. |
| `PLAY_REALTIME_PRIORITY` | Boolean | `true` | Пытается дать игровым процессам более высокий приоритет. |
| `PLAY_CPU_AFFINITY` | String | `0-3` | ЦП, к которым могут быть привязаны игровые процессы (например, 0-3, 4-7). |
| `PLAY_MEMORY_LOCK` | Boolean | `false` | Пытается заблокировать память игры, чтобы предотвратить подкачку. |
| `PLAY_IOSCHED_TUNE` | Boolean | `true` | Настройка планировщика ввода-вывода специально во время игрового режима. |

## Ukrainian

| Параметр | Тип | За замовчуванням | Опис |
| :-------- | :--- | :------ | :---------- |
| `SWAP_ENABLED` | Boolean | `false` | Вмикає або вимикає створення та активацію традиційного файлу підкачки на диску. |
| `SWAP_SIZE_GB` | Float | `1.0` | Розмір файлу підкачки, який потрібно створити, у Гігабайтах. |
| `OVERHEAD_GB` | Float | `0.3` | Додатковий простір, зарезервований у файлі образу підкачки для службових потреб файлової системи. |
| `ZRAM_ENABLED` | Boolean | `true` | Вмикає або вимикає ініціалізацію та активацію пристрою ZRAM. |
| `ZRAM_RATIO` | Float | `1.5` | Множник для загальної оперативної пам'яті для розрахунку базового розміру пристрою ZRAM. |
| `ZRAM_ALGORITHM` | String | `lz4` | Алгоритм стиснення, що використовується ZRAM (наприклад, lz4, zstd, lzo). |
| `MAX_COMP_STREAMS` | Integer | `4` | Обмежує максимальну кількість паралельних потоків стиснення для ZRAM. |
| `SWAPPINESS` | Integer | `100` | Параметр ядра, який контролює схильність до використання підкачки/ZRAM. Вищі значення сприяють підкачці. |
| `CACHE_PRESSURE` | Integer | `100` | Параметр ядра, що впливає на схильність ядра звільняти пам'ять з кешів. |
| `DIRTY_RATIO` | Integer | `20` | Відсоток від загальної пам'яті, при якому процес починає записувати брудні сторінки на диск. |
| `DIRTY_BACKGROUND_RATIO` | Integer | `10` | Відсоток від загальної пам'яті, при якому фоновий процес ядра починає записувати брудні сторінки. |
| `EXTRA_TUNING` | Boolean | `false` | Вмикає додаткові, більш агресивні налаштування параметрів ядра. |
| `DYNAMIC_SWAPPINESS` | Boolean | `true` | Якщо увімкнено, автоматично регулює значення `SWAPPINESS` на основі використання пам'яті та активності підкачки. |
| `PERFORMANCE_MODE` | Boolean | `false` | Вмикає параметри налаштування ядра, орієнтовані на продуктивність. |
| `ZRAM_AUTO_TUNE` | Boolean | `false` | Якщо встановлено значення true, запускає тест алгоритмів під час завантаження для вибору оптимального алгоритму стиснення ZRAM. |
| `LOG_LEVEL` | String | `INFO` | Встановлює рівень деталізації ведення журналу (DEBUG, INFO, WARN, ERROR). |
| `VM_DIRTY_WRITEBACK_CENTISECS` | Integer | `1500` | Час у сантисекундах (1/100 сек) між записом брудних сторінок. |
| `VM_DIRTY_EXPIRE_CENTISECS` | Integer | `3000` | Час у сантисекундах, перш ніж брудні дані стануть достатньо старими для запису. |
| `VM_PAGE_CLUSTER` | Integer | `0` | Кількість сторінок для запису в підкачку за одну операцію, оптимізується в залежності від алгоритму ZRAM. |
| `VM_LAPTOP_MODE` | Integer | `0` | Налаштування віртуальної пам'яті для економії енергії (значення 0-5, 0 вимикає). |
| `VM_OOM_KILL_ALLOCATING_TASK` | Integer | `0` | Якщо 1, убивця OOM намагається спочатку вбити задачу, яка виділяє пам'ять. |
| `VM_PANIC_ON_OOM` | Integer | `0` | Якщо 1, ядро викликає паніку при нестачі пам'яті. |
| `VM_OVERCOMMIT_MEMORY` | Integer | `1` | Керує обробкою перевищення пам'яті (0: евристично, 1: завжди дозволяти, 2: суворо). |
| `VM_OVERCOMMIT_RATIO` | Integer | `50` | Відсоток ОЗП, що вважається доступним для перевищення при `VM_OVERCOMMIT_MEMORY=2`. |
| `VM_WATERMARK_SCALE_FACTOR` | Integer | `10` | Регулює масштабний коефіцієнт для низьких, високих і мінімальних водяних знаків керування пам'яттю. |
| `KERNEL_THREADS_MAX` | Integer | `0` | Встановлює максимальну кількість потоків ядра. 0 означає використання типового значення. |
| `ZRAM_COMPRESSION_LEVEL` | Integer | `1` | Рівень стиснення для алгоритму ZRAM (якщо підтримується). |
| `ZRAM_MEMORY_LIMIT` | String | `4G` | Жорстке обмеження на обсяг фізичної пам'яті, яку може використовувати ZRAM (наприклад, 4G). |
| `SWAP_PRIORITY` | Integer | `10` | Пріоритет файлу підкачки при активних декількох областях підкачки (більше число = вищий пріоритет). |
| `ZRAM_PRIORITY` | Integer | `100` | Пріоритет пристрою ZRAM (зазвичай вищий, ніж у файлу підкачки). |
| `IO_SCHEDULER_TUNE` | Boolean | `false` | Якщо увімкнено, налаштовує параметри планувальника вводу-виводу для потенційно кращої продуктивності. |
| `CPU_BOOST` | Boolean | `false` | Якщо увімкнено, застосовує параметри ядра, пов'язані з прискоренням ЦП. |
| `NETWORK_TUNE` | Boolean | `false` | Якщо увімкнено, налаштовує мережеві буфери та параметри перевантаження. |
| `PLAY_ENABLED` | Boolean | `true` | Вмикає або вимикає функцію ігрового режиму NextRAM Play. |
| `PLAY_CPU_BOOST` | Boolean | `true` | Вмикає функції прискорення ЦП, коли активний ігровий режим. |
| `PLAY_CPU_GOVERNOR` | String | `performance` | Регулятор масштабування частоти ЦП, який встановлюється під час ігрового режиму (наприклад, performance, interactive). |
| `PLAY_CPU_MIN_FREQ` | Integer | `0` | Мінімальна частота ЦП (у МГц), яка встановлюється під час ігрового режиму. 0 означає без змін. |
| `PLAY_CPU_MAX_FREQ` | Integer | `0` | Максимальна частота ЦП (у МГц), яка встановлюється під час ігрового режиму. 0 означає без змін. |
| `PLAY_CPU_MAX_FREQ_PERCENT` | Integer | `100` | Встановлює максимальну частоту ЦП у відсотках від його максимальної можливості. |
| `PLAY_CPU_BOOST_DURATION` | Integer | `2000` | Тривалість (у мілісекундах) прискорення ЦП при виявленні введення. |
| `PLAY_CPU_BOOST_LEVEL` | Integer | `50` | Рівень або інтенсивність динамічного прискорення ЦП. |
| `PLAY_GPU_BOOST` | Boolean | `true` | Вмикає функції прискорення GPU, коли активний ігровий режим. |
| `PLAY_GPU_GOVERNOR` | String | `performance` | Регулятор масштабування частоти GPU, який встановлюється під час ігрового режиму. |
| `PLAY_GPU_MAX_FREQ_PERCENT` | Integer | `100` | Встановлює максимальну частоту GPU у відсотках від його максимальної можливості. |
| `PLAY_GPU_TOUCH_BOOST` | Boolean | `true` | Вмикає прискорення GPU при виявленні сенсорного введення. |
| `PLAY_TOUCH_BOOST` | Boolean | `true` | Вмикає оптимізацію відгуку сенсора. |
| `PLAY_TOUCH_POLLING_RATE` | Integer | `250` | Встановлює частоту опитування сенсорного введення в Гц. |
| `PLAY_VSYNC_MODE` | String | `adaptive` | Встановлює режим VSync (on, off, adaptive) для більш плавної гри. |
| `PLAY_DISABLE_HW_OVERLAYS` | Boolean | `false` | Намагається вимкнути апаратні оверлеї, щоб змусити рендеринг через GPU. |
| `PLAY_FORCE_GPU_RENDER` | Boolean | `true` | Примушує додатки використовувати GPU для рендерингу. |
| `PLAY_NETWORK_TUNE` | Boolean | `true` | Застосовує мережеві оптимізації для ігор. |
| `PLAY_NET_RMEM_DEFAULT` | Integer | `262144` | Розмір буфера пам'яті сокета за замовчуванням для отримання. |
| `PLAY_NET_WMEM_DEFAULT` | Integer | `262144` | Розмір буфера пам'яті сокета за замовчуванням для відправлення. |
| `PLAY_NET_RMEM_MAX` | Integer | `67108864` | Максимальний розмір буфера пам'яті сокета для отримання. |
| `PLAY_NET_WMEM_MAX` | Integer | `67108864` | Максимальний розмір буфера пам'яті сокета для відправлення. |
| `PLAY_TCP_CONGESTION` | String | `bbr` | Алгоритм керування перевантаженням TCP для використання в іграх (наприклад, bbr, cubic). |
| `PLAY_SWAPPINESS` | Integer | `20` | Значення swappiness, яке використовується спеціально під час ігрового режиму (зазвичай нижче). |
| `PLAY_CACHE_PRESSURE` | Integer | `50` | Значення тиску кеша, яке використовується спеціально під час ігрового режиму. |
| `PLAY_DIRTY_RATIO` | Integer | `10` | Коефіцієнт брудних даних, який використовується спеціально під час ігрового режиму. |
| `PLAY_DIRTY_BG_RATIO` | Integer | `5` | Коефіцієнт фонових брудних даних, який використовується спеціально під час ігрового режиму. |
| `PLAY_ZRAM_OPTIMIZE` | Boolean | `true` | Оптимізує налаштування ZRAM (алгоритм, потоки) спеціально для ігрового режиму. |
| `PLAY_CLEAR_CACHES` | Boolean | `true` | Очищає системні кеші при запуску ігрового режиму. |
| `PLAY_THERMAL_CONTROL` | Boolean | `true` | Вмикає коригування керування температурою під час ігрового режиму. |
| `PLAY_THERMAL_PROFILE` | String | `balanced` | Тепловий профіль для застосування (агресивний, консервативний, збалансований). |
| `PLAY_BG_CONTROL` | Boolean | `true` | Вмикає контроль фонових процесів під час ігрового режиму. |
| `PLAY_BG_WHITELIST` | String | `com.discord,com.spotify.music,com.chrome` | Перелік пакетів додатків, розділених комами, які мають продовжувати працювати у фоновому режимі. |
| `PLAY_BG_KILL_LIMIT` | Integer | `10` | Обмеження на кількість убиваних фонових процесів. |
| `PLAY_AUTO_DETECT` | Boolean | `true` | Вмикає автоматичне визначення запуску гри для активації ігрового режиму. |
| `PLAY_GAME_PROFILE` | String | `auto` | Вказує профіль гри за замовчуванням для застосування. |
| `PLAY_PERF_MONITOR` | Boolean | `true` | Вмикає моніторинг продуктивності під час ігрового режиму. |
| `PLAY_PERF_OVERLAY` | Boolean | `false` | Вмикає накладання продуктивності в грі (якщо підтримується). |
| `PLAY_AUDIO_LATENCY` | String | `low` | Встановлює режим затримки аудіо (наприклад, low). |
| `PLAY_AUDIO_BUFFER` | Integer | `128` | Встановлює розмір аудіо буфера. |
| `PLAY_CHARGING_BOOST` | Boolean | `true` | Застосовує прискорення продуктивності під час зарядки пристрою. |
| `PLAY_BATTERY_SAVER` | Boolean | `false` | Знижує продуктивність при низькому заряді акумулятора. |
| `PLAY_POWER_LIMIT` | Integer | `0` | Обмеження потужності, яке застосовується під час ігрового режиму. 0 означає без обмежень. |
| `PLAY_REALTIME_PRIORITY` | Boolean | `true` | Намагається надати ігровим процесам вищий пріоритет. |
| `PLAY_CPU_AFFINITY` | String | `0-3` | ЦП, до яких можуть бути прив'язані ігрові процеси (наприклад, 0-3, 4-7). |
| `PLAY_MEMORY_LOCK` | Boolean | `false` | Намагається заблокувати пам'ять гри, щоб запобігти підкачці. |
| `PLAY_IOSCHED_TUNE` | Boolean | `true` | Налаштування планувальника вводу-виводу спеціально під час ігрового режиму. |

## Chinese (简体中文)

| 参数 | 类型 | 默认值 | 描述 |
| :-------- | :--- | :------ | :---------- |
| `SWAP_ENABLED` | Boolean | `false` | 启用或禁用在磁盘上创建和激活传统交换文件。 |
| `SWAP_SIZE_GB` | Float | `1.0` | 要创建的交换文件大小（以千兆字节为单位）。 |
| `OVERHEAD_GB` | Float | `0.3` | 为交换镜像文件的文件系统开销预留的额外空间。 |
| `ZRAM_ENABLED` | Boolean | `true` | 启用或禁用 ZRAM 块设备的初始化和激活。 |
| `ZRAM_RATIO` | Float | `1.5` | 总 RAM 的乘数，用于计算 ZRAM 设备的基本大小。 |
| `ZRAM_ALGORITHM` | String | `lz4` | ZRAM 使用的压缩算法（例如 lz4、zstd、lzo）。 |
| `MAX_COMP_STREAMS` | Integer | `4` | 限制 ZRAM 并行压缩流的最大数量。 |
| `SWAPPINESS` | Integer | `100` | 内核参数，控制使用交换/ZRAM 的倾向。值越高越倾向于交换。 |
| `CACHE_PRESSURE` | Integer | `100` | 内核参数，影响内核从缓存中回收内存的倾向。 |
| `DIRTY_RATIO` | Integer | `20` | 进程开始将脏页写入存储的总内存百分比阈值。 |
| `DIRTY_BACKGROUND_RATIO` | Integer | `10` | 内核后台进程开始写入脏页的总内存百分比阈值。 |
| `EXTRA_TUNING` | Boolean | `false` | 如果为 true，则启用更多激进的内核参数调优。 |
| `DYNAMIC_SWAPPINESS` | Boolean | `true` | 如果启用，会根据系统内存使用情况和交换活动自动调整 `SWAPPINESS` 值。 |
| `PERFORMANCE_MODE` | Boolean | `false` | 如果为 true，则启用面向性能的内核调优参数。 |
| `ZRAM_AUTO_TUNE` | Boolean | `false` | 如果为 true，则在启动时运行算法测试以选择最佳的 ZRAM 压缩算法。 |
| `LOG_LEVEL` | String | `INFO` | 设置日志记录的详细程度（DEBUG, INFO, WARN, ERROR）。 |
| `VM_DIRTY_WRITEBACK_CENTISECS` | Integer | `1500` | 脏页回写之间的时间（以百分之一秒为单位）。 |
| `VM_DIRTY_EXPIRE_CENTISECS` | Integer | `3000` | 脏数据被认为足够老可以写入的时间（以百分之一秒为单位）。 |
| `VM_PAGE_CLUSTER` | Integer | `0` | 单次操作中写入交换的页数，根据 ZRAM 算法优化。 |
| `VM_LAPTOP_MODE` | Integer | `0` | 如果非零则调整 VM 以节省电源（值 0-5，0 表示禁用）。 |
| `VM_OOM_KILL_ALLOCATING_TASK` | Integer | `0` | 如果为 1，OOM 杀手会尝试首先杀死分配内存的任务。 |
| `VM_PANIC_ON_OOM` | Integer | `0` | 如果为 1，内存不足时内核会恐慌。 |
| `VM_OVERCOMMIT_MEMORY` | Integer | `1` | 控制内存超额承诺处理（0: 启发式, 1: 总是允许, 2: 严格）。 |
| `VM_OVERCOMMIT_RATIO` | Integer | `50` | 当 `VM_OVERCOMMIT_MEMORY=2` 时，认为可用于超额承诺的 RAM 百分比。 |
| `VM_WATERMARK_SCALE_FACTOR` | Integer | `10` | 调整内存管理低、高、最小水印的缩放因子。 |
| `KERNEL_THREADS_MAX` | Integer | `0` | 设置内核线程的最大数量。0 表示使用默认值。 |
| `ZRAM_COMPRESSION_LEVEL` | Integer | `1` | ZRAM 算法的压缩级别（如果支持）。 |
| `ZRAM_MEMORY_LIMIT` | String | `4G` | ZRAM 可以使用的物理内存量的硬限制（例如 4G）。 |
| `SWAP_PRIORITY` | Integer | `10` | 激活多个交换区域时交换文件的优先级（数字越大优先级越高）。 |
| `ZRAM_PRIORITY` | Integer | `100` | ZRAM 设备的优先级（通常高于交换文件）。 |
| `IO_SCHEDULER_TUNE` | Boolean | `false` | 如果为 true，则调优 I/O 调度器参数以获得潜在的更好性能。 |
| `CPU_BOOST` | Boolean | `false` | 如果为 true，则应用与 CPU 提升相关的内核参数。 |
| `NETWORK_TUNE` | Boolean | `false` | 如果为 true，则调优网络缓冲区和拥塞参数。 |
| `PLAY_ENABLED` | Boolean | `true` | 启用或禁用 NextRAM Play 游戏模式功能。 |
| `PLAY_CPU_BOOST` | Boolean | `true` | 游戏模式激活时启用 CPU 提升功能。 |
| `PLAY_CPU_GOVERNOR` | String | `performance` | 游戏模式期间设置的 CPU 频率调节器（例如 performance, interactive）。 |
| `PLAY_CPU_MIN_FREQ` | Integer | `0` | 游戏模式期间设置的最小 CPU 频率（以 MHz 为单位）。0 表示不更改。 |
| `PLAY_CPU_MAX_FREQ` | Integer | `0` | 游戏模式期间设置的最大 CPU 频率（以 MHz 为单位）。0 表示不更改。 |
| `PLAY_CPU_MAX_FREQ_PERCENT` | Integer | `100` | 将最大 CPU 频率设置为其最大能力的百分比。 |
| `PLAY_CPU_BOOST_DURATION` | Integer | `2000` | 检测到输入时 CPU 提升的持续时间（以毫秒为单位）。 |
| `PLAY_CPU_BOOST_LEVEL` | Integer | `50` | 动态 CPU 提升的级别或强度。 |
| `PLAY_GPU_BOOST` | Boolean | `true` | 游戏模式激活时启用 GPU 提升功能。 |
| `PLAY_GPU_GOVERNOR` | String | `performance` | 游戏模式期间设置的 GPU 频率调节器。 |
| `PLAY_GPU_MAX_FREQ_PERCENT` | Integer | `100` | 将最大 GPU 频率设置为其最大能力的百分比。 |
| `PLAY_GPU_TOUCH_BOOST` | Boolean | `true` | 检测到触摸输入时启用 GPU 提升。 |
| `PLAY_TOUCH_BOOST` | Boolean | `true` | 启用触摸响应优化。 |
| `PLAY_TOUCH_POLLING_RATE` | Integer | `250` | 设置触摸输入的轮询率（以 Hz 为单位）。 |
| `PLAY_VSYNC_MODE` | String | `adaptive` | 设置 VSync 模式（on, off, adaptive）以获得更流畅的游戏体验。 |
| `PLAY_DISABLE_HW_OVERLAYS` | Boolean | `false` | 尝试禁用硬件叠加层以强制 GPU 渲染。 |
| `PLAY_FORCE_GPU_RENDER` | Boolean | `true` | 强制应用程序使用 GPU 进行渲染。 |
| `PLAY_NETWORK_TUNE` | Boolean | `true` | 如果为 true，则应用游戏网络优化。 |
| `PLAY_NET_RMEM_DEFAULT` | Integer | `262144` | 接收套接字内存缓冲区的默认大小。 |
| `PLAY_NET_WMEM_DEFAULT` | Integer | `262144` | 发送套接字内存缓冲区的默认大小。 |
| `PLAY_NET_RMEM_MAX` | Integer | `67108864` | 接收套接字内存缓冲区的最大大小。 |
| `PLAY_NET_WMEM_MAX` | Integer | `67108864` | 发送套接字内存缓冲区的最大大小。 |
| `PLAY_TCP_CONGESTION` | String | `bbr` | 用于游戏的 TCP 拥塞控制算法（例如 bbr, cubic）。 |
| `PLAY_SWAPPINESS` | Integer | `20` | 游戏模式期间专门使用的交换性值（通常较低）。 |
| `PLAY_CACHE_PRESSURE` | Integer | `50` | 游戏模式期间专门使用的缓存压力值。 |
| `PLAY_DIRTY_RATIO` | Integer | `10` | 游戏模式期间专门使用的脏页比率。 |
| `PLAY_DIRTY_BG_RATIO` | Integer | `5` | 游戏模式期间专门使用的脏页背景比率。 |
| `PLAY_ZRAM_OPTIMIZE` | Boolean | `true` | 专门为游戏模式优化 ZRAM 设置（算法、流）。 |
| `PLAY_CLEAR_CACHES` | Boolean | `true` | 游戏模式启动时清除系统缓存。 |
| `PLAY_THERMAL_CONTROL` | Boolean | `true` | 在游戏模式期间启用热管理调整。 |
| `PLAY_THERMAL_PROFILE` | String | `balanced` | 要应用的热配置文件（激进、保守、平衡）。 |
| `PLAY_BG_CONTROL` | Boolean | `true` | 在游戏模式期间启用后台进程控制。 |
| `PLAY_BG_WHITELIST` | String | `com.discord,com.spotify.music,com.chrome` | 逗号分隔的后台保持运行的应用包名列表。 |
| `PLAY_BG_KILL_LIMIT` | Integer | `10` | 被杀死的后台进程数量限制。 |
| `PLAY_AUTO_DETECT` | Boolean | `true` | 启用自动检测游戏何时运行以触发游戏模式。 |
| `PLAY_GAME_PROFILE` | String | `auto` | 指定要应用的默认游戏配置文件。 |
| `PLAY_PERF_MONITOR` | Boolean | `true` | 在游戏模式期间启用性能监控。 |
| `PLAY_PERF_OVERLAY` | Boolean | `false` | 启用游戏内性能覆盖（如果支持）。 |
| `PLAY_AUDIO_LATENCY` | String | `low` | 设置音频延迟模式（例如 low）。 |
| `PLAY_AUDIO_BUFFER` | Integer | `128` | 设置音频缓冲区大小。 |
| `PLAY_CHARGING_BOOST` | Boolean | `true` | 设备充电时应用性能提升。 |
| `PLAY_BATTERY_SAVER` | Boolean | `false` | 电池电量低时降低性能。 |
| `PLAY_POWER_LIMIT` | Integer | `0` | 游戏模式期间应用的功率限制。0 表示无限制。 |
| `PLAY_REALTIME_PRIORITY` | Boolean | `true` | 尝试给予游戏进程更高的优先级。 |
| `PLAY_CPU_AFFINITY` | String | `0-3` | 游戏进程可以绑定到的 CPU 核心（例如 0-3, 4-7）。 |
| `PLAY_MEMORY_LOCK` | Boolean | `false` | 尝试锁定游戏内存以防止交换。 |
| `PLAY_IOSCHED_TUNE` | Boolean | `true` | 在游戏模式期间专门调优 I/O 调度器。 |