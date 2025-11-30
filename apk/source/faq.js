// faq.js
class FAQManager {
    constructor() {
        this.currentLanguage = localStorage.getItem('language') || 'en';
        this.init();
    }

    init() {
        this.renderFAQ();
        this.setupLanguageListener();
    }

    setupLanguageListener() {
        const languageSelect = document.getElementById('LANGUAGE');
        if (languageSelect) {
            languageSelect.addEventListener('change', (e) => {
                this.currentLanguage = e.target.value;
                this.renderFAQ();
            });
        }
    }

    renderFAQ() {
        this.renderFAQContent();
        this.renderGuideContent();
    }

    renderFAQContent() {
        const faqContent = document.getElementById('faq-content');
        if (!faqContent) return;

        const faqData = this.getFAQData();
        let html = '';

        faqData.forEach(item => {
            html += `
                <div class="faq-item">
                    <div class="faq-question">${item.question}</div>
                    <div class="faq-answer">${item.answer}</div>
                </div>
            `;
        });

        faqContent.innerHTML = html;
    }

    renderGuideContent() {
        const guideContent = document.getElementById('guide-content');
        if (!guideContent) return;

        const guideData = this.getGuideData();
        let html = '';

        guideData.forEach(item => {
            html += `
                <div class="guide-section">
                    <div class="guide-title">${item.title}</div>
                    <div class="guide-content">${item.content}</div>
                </div>
            `;
        });

        guideContent.innerHTML = html;
    }

    getFAQData() {
        const faqs = {
            en: [
                {
                    question: "What is ZRAM?",
                    answer: "ZRAM is compressed RAM that acts as swap space, improving multitasking and preventing app reloads by compressing memory pages in RAM."
                },
                {
                    question: "Which compression algorithm should I use?",
                    answer: "• zstd: Best compression ratio (recommended)\n• lz4: Fastest compression\n• lzo: Balanced performance\n• lzo-rle: Slightly better than lzo\n• deflate: Good compression but slower"
                },
                {
                    question: "What ZRAM ratio should I set?",
                    answer: "• 4GB RAM: 1.5-2.0 ratio (6-8GB ZRAM)\n• 6GB RAM: 1.0-1.5 ratio (6-9GB ZRAM)\n• 8GB+ RAM: 0.5-1.0 ratio (4-8GB ZRAM)\nStart with lower values and increase if needed."
                },
                {
                    question: "Should I enable swap with ZRAM?",
                    answer: "Only if you have fast storage (UFS 3.0+ or NVMe). For eMMC storage, use ZRAM only to avoid storage wear and slow performance."
                },
                {
                    question: "What swappiness value is optimal?",
                    answer: "• 80-100: Aggressive swapping for multitasking\n• 60-80: Balanced usage (recommended)\n• 40-60: Conservative for battery saving\n• 0-40: Minimal swapping"
                },
                {
                    question: "Should I enable auto-tuning features?",
                    answer: "⚠️ If you have manually configured ZRAM and swap, DO NOT enable auto-tuning features like ZRAM Auto Tune or Dynamic Swappiness. They can conflict with manual settings and cause performance issues."
                },
                {
                    question: "What about Performance Mode?",
                    answer: "Performance Mode increases CPU frequency and memory bandwidth. Use only for gaming or heavy apps. Disable for normal usage to save battery."
                },
                {
                    question: "How many compression streams?",
                    answer: "Set to match your CPU cores (4 streams for 4-core, 8 for 8-core). More streams = better parallel compression but higher CPU usage."
                }
            ],
            ru: [
                {
                    question: "Что такое ZRAM?",
                    answer: "ZRAM - это сжатая оперативная память, работающая как подкачка, улучшая многозадачность и предотвращая перезагрузку приложений за счёт сжатия страниц памяти в RAM."
                },
                {
                    question: "Какой алгоритм сжатия выбрать?",
                    answer: "• zstd: Лучшее сжатие (рекомендуется)\n• lz4: Самое быстрое сжатие\n• lzo: Сбалансированная производительность\n• lzo-rle: Немного лучше lzo\n• deflate: Хорошее сжатие, но медленнее"
                },
                {
                    question: "Какой коэффициент ZRAM установить?",
                    answer: "• 4GB RAM: коэффициент 1.5-2.0 (6-8GB ZRAM)\n• 6GB RAM: коэффициент 1.0-1.5 (6-9GB ZRAM)\n• 8GB+ RAM: коэффициент 0.5-1.0 (4-8GB ZRAM)\nНачните с меньших значений и увеличивайте при необходимости."
                },
                {
                    question: "Включать ли swap вместе с ZRAM?",
                    answer: "Только если у вас быстрая память (UFS 3.0+ или NVMe). Для eMMC используйте только ZRAM, чтобы избежать износа памяти и медленной работы."
                },
                {
                    question: "Какое значение swappiness оптимально?",
                    answer: "• 80-100: Агрессивная подкачка для многозадачности\n• 60-80: Сбалансированное использование (рекомендуется)\n• 40-60: Консервативно для экономии батареи\n• 0-40: Минимальная подкачка"
                },
                {
                    question: "Включать ли автонастройки?",
                    answer: "⚠️ Если вы вручную настроили ZRAM и swap, НЕ включайте автонастройки как ZRAM Auto Tune или Dynamic Swappiness. Они могут конфликтовать с ручными настройками и вызывать проблемы с производительностью."
                },
                {
                    question: "Что насчёт Режима производительности?",
                    answer: "Режим производительности увеличивает частоту CPU и пропускную способность памяти. Используйте только для игр или тяжёлых приложений. Отключайте для обычного использования для экономии батареи."
                },
                {
                    question: "Сколько потоков сжатия использовать?",
                    answer: "Установите по количеству ядер CPU (4 потока для 4-ядерного, 8 для 8-ядерного). Больше потоков = лучше параллельное сжатие, но выше использование CPU."
                }
            ],
            uk: [
                {
                    question: "Що таке ZRAM?",
                    answer: "ZRAM - це стиснена оперативна пам'ять, яка використовується як простір підкачки, покращуючи багатозадачність і запобігаючи перезавантаженню додатків шляхом стиснення сторінок пам'яті в RAM."
                },
                {
                    question: "Який алгоритм стиснення вибрати?",
                    answer: "• zstd: Найкраще стиснення (рекомендується)\n• lz4: Найшвидше стиснення\n• lzo: Збалансована продуктивність\n• lzo-rle: Трохи краще за lzo\n• deflate: Хороше стиснення, але повільніше"
                },
                {
                    question: "Який коефіцієнт ZRAM встановити?",
                    answer: "• 4GB RAM: коефіцієнт 1.5-2.0 (6-8GB ZRAM)\n• 6GB RAM: коефіцієнт 1.0-1.5 (6-9GB ZRAM)\n• 8GB+ RAM: коефіцієнт 0.5-1.0 (4-8GB ZRAM)\nПочніть з менших значень і збільшуйте за потреби."
                },
                {
                    question: "Чи вмикати swap разом з ZRAM?",
                    answer: "Тільки якщо у вас швидка пам'ять (UFS 3.0+ або NVMe). Для eMMC використовуйте тільки ZRAM, щоб уникнути зносу пам'яті та повільної роботи."
                },
                {
                    question: "Яке значення swappiness оптимально?",
                    answer: "• 80-100: Агресивна підкачка для багатозадачності\n• 60-80: Збалансоване використання (рекомендується)\n• 40-60: Консервативно для економії батареї\n• 0-40: Мінімальна підкачка"
                },
                {
                    question: "Чи вмикати автоналаштування?",
                    answer: "⚠️ Якщо ви вручну налаштували ZRAM і swap, НЕ вмикайте автоналаштування як ZRAM Auto Tune або Dynamic Swappiness. Вони можуть конфліктувати з ручними налаштуваннями і викликати проблеми з продуктивністю."
                },
                {
                    question: "Що щодо Режиму продуктивності?",
                    answer: "Режим продуктивності збільшує частоту CPU та пропускну здатність пам'яті. Використовуйте тільки для ігор або важких додатків. Вимкніть для звичайного використання для економії батареї."
                },
                {
                    question: "Скільки потоків стиснення використовувати?",
                    answer: "Встановіть за кількістю ядер CPU (4 потоки для 4-ядерного, 8 для 8-ядерного). Більше потоків = краще паралельне стиснення, але вище використання CPU."
                }
            ],
            zh: [
                {
                    question: "什么是 ZRAM？",
                    answer: "ZRAM 是压缩的内存，用作交换空间，通过压缩 RAM 中的内存页面来改善多任务处理并防止应用程序重新加载。"
                },
                {
                    question: "应该使用哪种压缩算法？",
                    answer: "• zstd: 最佳压缩比（推荐）\n• lz4: 最快压缩\n• lzo: 平衡性能\n• lzo-rle: 比 lzo 稍好\n• deflate: 良好压缩但较慢"
                },
                {
                    question: "应该设置多大的 ZRAM 比率？",
                    answer: "• 4GB RAM: 1.5-2.0 比率 (6-8GB ZRAM)\n• 6GB RAM: 1.0-1.5 比率 (6-9GB ZRAM)\n• 8GB+ RAM: 0.5-1.0 比率 (4-8GB ZRAM)\n从较低值开始，根据需要增加。"
                },
                {
                    question: "应该启用 ZRAM 和交换文件吗？",
                    answer: "仅在您有快速存储 (UFS 3.0+ 或 NVMe) 时启用。对于 eMMC 存储，仅使用 ZRAM 以避免存储磨损和性能下降。"
                },
                {
                    question: "什么交换倾向值是最优的？",
                    answer: "• 80-100: 积极交换以支持多任务\n• 60-80: 平衡使用（推荐）\n• 40-60: 保守以节省电池\n• 0-40: 最小交换"
                },
                {
                    question: "应该启用自动调优功能吗？",
                    answer: "⚠️ 如果您已手动配置 ZRAM 和交换，请勿启用自动调优功能，如 ZRAM 自动调优或动态交换倾向。它们可能与手动设置冲突并导致性能问题。"
                },
                {
                    question: "性能模式怎么样？",
                    answer: "性能模式会增加 CPU 频率和内存带宽。仅在游戏或重型应用时使用。正常使用时禁用以节省电池。"
                },
                {
                    question: "应该使用多少压缩流？",
                    answer: "设置与 CPU 核心数匹配（4 核用 4 个流，8 核用 8 个流）。更多流 = 更好的并行压缩但更高的 CPU 使用率。"
                }
            ]
        };

        return faqs[this.currentLanguage] || faqs.en;
    }

    getGuideData() {
        const guides = {
            en: [
                {
                    title: "⚠️ Important Warnings",
                    content: "• DO NOT enable auto-tuning if using manual configuration\n• Performance Mode increases battery consumption significantly\n• Too high ZRAM ratio can cause system lag\n• Swap on slow storage will degrade performance"
                },
                {
                    title: "Basic Setup for Beginners",
                    content: "1. Enable ZRAM only\n2. Set ZRAM ratio to 1.0\n3. Choose zstd compression\n4. Set compression streams to 4\n5. Set swappiness to 70\n6. Save and reboot"
                },
                {
                    title: "Optimal Configuration",
                    content: "ZRAM Enabled: Yes\nZRAM Ratio: 1.0-1.5\nAlgorithm: zstd\nStreams: 4-8\nSwap: Disabled (unless fast storage)\nSwappiness: 60-80\nExtra Tuning: Disabled\nAuto Features: Disabled"
                },
                {
                    title: "Performance Tips",
                    content: "• Use zstd for best memory efficiency\n• Keep ZRAM ratio reasonable for your RAM size\n• Disable swap if not using fast storage\n• Monitor system performance after changes\n• Reboot after configuration changes"
                },
                {
                    title: "Troubleshooting Common Issues",
                    content: "Device lag: Lower ZRAM ratio\nApps reloading: Increase ZRAM ratio\nHigh battery drain: Disable Performance Mode\nSystem instability: Disable Extra Tuning\nSlow performance: Check storage speed"
                }
            ],
            ru: [
                {
                    title: "⚠️ Важные предупреждения",
                    content: "• НЕ включайте автонастройки при ручной конфигурации\n• Режим производительности значительно увеличивает расход батареи\n• Слишком высокий коэффициент ZRAM может вызвать лаги\n• Swap на медленной памяти ухудшит производительность"
                },
                {
                    title: "Базовая настройка для начинающих",
                    content: "1. Включите только ZRAM\n2. Установите коэффициент ZRAM 1.0\n3. Выберите сжатие zstd\n4. Установите 4 потока сжатия\n5. Установите swappiness 70\n6. Сохраните и перезагрузите"
                },
                {
                    title: "Оптимальная конфигурация",
                    content: "ZRAM: Включён\nКоэффициент ZRAM: 1.0-1.5\nАлгоритм: zstd\nПотоки: 4-8\nSwap: Выключен (если нет быстрой памяти)\nSwappiness: 60-80\nДоп. настройка: Выключена\nАвтонастройки: Выключены"
                },
                {
                    title: "Советы по производительности",
                    content: "• Используйте zstd для лучшей эффективности памяти\n• Сохраняйте разумный коэффициент ZRAM для вашего размера RAM\n• Отключайте swap если нет быстрой памяти\n• Мониторьте производительность после изменений\n• Перезагружайте после изменений конфигурации"
                },
                {
                    title: "Решение частых проблем",
                    content: "Лаги устройства: Уменьшите коэффициент ZRAM\nПерезагрузка приложений: Увеличьте коэффициент ZRAM\nВысокий расход батареи: Отключите Режим производительности\nНестабильность системы: Отключите Доп. настройку\nМедленная работа: Проверьте скорость памяти"
                }
            ],
            uk: [
                {
                    title: "⚠️ Важливі попередження",
                    content: "• НЕ вмикайте автоналаштування, якщо використовуєте ручну конфігурацію\n• Режим продуктивності значно збільшує споживання батареї\n• Занадто високий коефіцієнт ZRAM може спричинити лаги системи\n• Підкачка на повільному сховищі погіршить продуктивність"
                },
                {
                    title: "Базова настройка для початківців",
                    content: "1. Увімкніть тільки ZRAM\n2. Встановіть коефіцієнт ZRAM 1.0\n3. Виберіть стиснення zstd\n4. Встановіть 4 потоки стиснення\n5. Встановіть swappiness 70\n6. Збережіть та перезавантажте"
                },
                {
                    title: "Оптимальна конфігурація",
                    content: "ZRAM: Увімкнено\nКоефіцієнт ZRAM: 1.0-1.5\nАлгоритм: zstd\nПотоки: 4-8\nSwap: Вимкнено (якщо немає швидкої пам'яті)\nSwappiness: 60-80\nДод. налаштування: Вимкнено\nАвто функції: Вимкнено"
                },
                {
                    title: "Поради щодо продуктивності",
                    content: "• Використовуйте zstd для найкращої ефективності пам'яті\n• Зберігайте розумний коефіцієнт ZRAM для вашого розміру RAM\n• Вимкніть swap якщо немає швидкої пам'яті\n• Моніторьте продуктивність після змін\n• Перезавантажуйте після змін конфігурації"
                },
                {
                    title: "Вирішення поширених проблем",
                    content: "Лаги пристрою: Зменшіть коефіцієнт ZRAM\nПерезавантаження додатків: Збільшіть коефіцієнт ZRAM\nВисокий розряд батареї: Вимкніть Режим продуктивності\nНестабільність системи: Вимкніть Дод. налаштування\nПовільна робота: Перевірте швидкість пам'яті"
                }
            ],
            zh: [
                {
                    title: "⚠️ 重要警告",
                    content: "• 如果使用手动配置，请勿启用自动调优\n• 性能模式会显著增加电池消耗\n• ZRAM 比率过高可能导致系统卡顿\n• 在慢速存储上使用交换文件会降低性能"
                },
                {
                    title: "初学者基本设置",
                    content: "1. 仅启用 ZRAM\n2. 设置 ZRAM 比率为 1.0\n3. 选择 zstd 压缩\n4. 设置 4 个压缩流\n5. 设置交换倾向为 70\n6. 保存并重启"
                },
                {
                    title: "最优配置",
                    content: "ZRAM 启用: 是\nZRAM 比率: 1.0-1.5\n算法: zstd\n流数: 4-8\n交换: 禁用（除非有快速存储）\n交换倾向: 60-80\n额外调优: 禁用\n自动功能: 禁用"
                },
                {
                    title: "性能提示",
                    content: "• 使用 zstd 获得最佳内存效率\n• 根据 RAM 大小保持合理的 ZRAM 比率\n• 如果没有快速存储，请禁用交换\n• 更改后监控系统性能\n• 配置更改后重启"
                },
                {
                    title: "常见问题排查",
                    content: "设备卡顿: 降低 ZRAM 比率\n应用重载: 增加 ZRAM 比率\n高电池消耗: 禁用性能模式\n系统不稳定: 禁用额外调优\n性能缓慢: 检查存储速度"
                }
            ]
        };

        return guides[this.currentLanguage] || guides.en;
    }
}

document.addEventListener('DOMContentLoaded', function() {
    window.faqManager = new FAQManager();
});