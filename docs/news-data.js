/*
{
    id: ,
    date: "",
    tags: [],
    author: "",
    title: "",
    preview: "",
    content:
},
*/
const newsData = [
{
    id: 11,
    date: "2026-11-14",
    category: "development",
    author: "@rexamm1t",
    title: "NextRAM code is transferred to Rust",
    preview: "We continue to work on the module and would like to inform you about it.",
    content: `
         <h3>NextRAM in Rust?!</h3>
         <p>We've overcome the crisis and are back to working with the module, although it's rather difficult to call this project a module any longer...</p>
         <p>Also, we're not promising any new functionality yet (while we're rewriting the database). We need to create an excellent foundation for future work.</p>
    `
},
{
    id: 10,
    date: "2026-02-13",
    category: "release",
    author: "@GalaxyFier",
    title: "NextRAM Play Fix 9.3.981",
    preview: "Code optimization, Play Mode improvements, memory management enhancements, and various fixes.",
    content: `
        <h3>NextRAM Play Fix 9.3.981</h3>
        <p><strong>[CODE OPTIMIZATION]</strong></p>
        <ul>
            <li>Added pre-write verification for all file operations</li>
            <li>Replaced all backticks (\`) with $() for POSIX shell compatibility</li>
            <li>Added fallback mechanisms for unavailable functions</li>
            <li>Enhanced logging for better troubleshooting</li>
            <li>Added path availability checks before usage</li>
            <li>Expanded support for various GPU/CPU paths across different chipsets</li>
            <li>Replaced all &>/dev/null with 2>/dev/null for compatibility</li>
            <li>Added file and directory permission checks</li>
            <li>Optimized loops and conditional operators</li>
            <li>Fixed potential compatibility issues with Magisk Alpha</li>
            <li>Improved error handling for swap mounting operations</li>
            <li>Added safe ZRAM reset operations</li>
            <li>Enhanced root permission checking for different Android versions</li>
            <li>Fixed potential deadlocks in configuration handling</li>
            <li>Added timeouts for critical operations</li>
            <li>Improved compatibility with different firmwares and kernels</li>
        </ul>
        <p><strong>[PLAY MODE IMPROVEMENTS]</strong></p>
        <ul>
            <li>Added alternative GPU control paths (Adreno, Mali, Generic)</li>
            <li>Enhanced CPU/GPU path availability checking system</li>
            <li>Added safe CPU frequency modification operations</li>
            <li>Improved error handling in game detector</li>
            <li>Optimized thermal zone management</li>
        </ul>
        <p><strong>[MEMORY MANAGEMENT]</strong></p>
        <ul>
            <li>Enhanced ZRAM operation safety</li>
            <li>Added additional checks before ZRAM reset</li>
            <li>Optimized ZRAM size calculation</li>
            <li>Improved compression stream handling</li>
        </ul>
        <p><strong>Links:</strong></p>
        <p>Telegram: https://t.me/nextram_official</p>
        <p>Web Site: https://nextram.cocal.ru</p>
    `
},
{
    id: 9,
    date: "2026-02-01",
    category: "release",
    author: "@GalaxyFier",
    title: "NextRAM Play v9.3.978-(93978)",
    preview: "Play Mode with gaming optimizations, CPU/GPU tuning, network and memory enhancements, installation fixes.",
    content: `
        <h3>NextRAM Play v9.3.978-(93978)</h3>
        <p><strong>[PLAY MODE]</strong></p>
        <ul>
            <li>Added NextRAM Play gaming mode for enhanced in-game performance</li>
            <li>Added CPU optimization: governor control, min/max frequency management, boost mode</li>
            <li>Added GPU optimization: governor tuning, frequency control, throttling disable</li>
            <li>Enhanced touch responsiveness: increased polling rate, VSync configuration</li>
            <li>Added network tuning for gaming: TCP optimization, buffer management, WiFi power save disable</li>
            <li>Added memory optimization: swappiness tuning, cache pressure control, ZRAM management</li>
            <li>Added thermal management: profile selection (aggressive, balanced, conservative)</li>
            <li>Added background process control for resource optimization</li>
            <li>Added game detector for automatic gaming mode activation</li>
            <li>Added gaming profiles: FPS Competitive, Open World, Casual, Battery Saver, Custom</li>
            <li>Added performance monitor</li>
        </ul>
        <p><strong>[INSTALL]</strong></p>
        <ul>
            <li>Fixed Play Mode installation on some devices</li>
            <li>Improved compatibility with various kernel manufacturers</li>
            <li>Fixed timeouts during configuration application</li>
        </ul>
        <p><strong>[CTL]</strong></p>
        <ul>
            <li>update NextRAM CTL Service</li>
        </ul>
        <p><strong>Links:</strong></p>
        <p>Telegram: https://t.me/nextram_official</p>
        <p>Web Site: https://nextram.cocal.ru</p>
    `
},
{
    id: 8,
    date: "2026-01-06",
    category: "release",
    author: "@GalaxyFier",
    title: "NextRAM Whole Fix 9.2.822",
    preview: "Bug fixes for the app.",
    content: `
        <h3>NextRAM Whole Fix 9.2.822</h3>
        <p><strong>[APP]</strong></p>
        <ul>
            <li>bug fixes</li>
        </ul>
        <p><strong>Links:</strong></p>
        <p>Telegram: https://t.me/nextram_official</p>
        <p>Web Site: https://nextram.cocal.ru</p>
    `
},
{
    id: 7,
    date: "2025-12-30",
    category: "release",
    author: "@GalaxyFier",
    title: "NextRAM Whole v9.2.371-(92371)",
    preview: "New theme, liquid glass, configuration import/export, NextRAM Store, and various fixes.",
    content: `
        <h3>NextRAM Whole v9.2.371-(92371)</h3>
        <p><strong>[APP]</strong></p>
        <ul>
            <li>added the material you theme</li>
            <li>added liquid glass</li>
            <li>added a map with information about the module</li>
            <li>added a function to turn on/off the module</li>
            <li>added import/export of configurations</li>
            <li>changed the themes</li>
            <li>fixed the recording of configurations from the history</li>
            <li>added NextRAM Store</li>
            <li>fixed small bugs</li>
        </ul>
        <p><strong>[INSTALL]</strong></p>
        <ul>
            <li>fixed an issue with installing the app</li>
            <li>fixed time-out</li>
        </ul>
        <p><strong>Links:</strong></p>
        <p>Telegram: https://t.me/nextram_official</p>
        <p>Web Site: https://nextram.cocal.ru</p>
    `
},
{
    id: 6,
    date: "2025-12-10",
    category: "release",
    author: "@rexamm1t",
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
{
    id: 5,
    date: "2025-12-1",
    category: "release",
    author: "@rexamm1t",
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
{
    id: 4,
    date: "2025-12-1",
    category: "release",
    author: "@rexamm1t",
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
{
    id: 3,
    date: "2025-11-17",
    category: "update",
    author: "@rexamm1t",
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
{
    id: 2,
    date: "2025-11-15",
    category: "update",
    author: "@rexamm1t",
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
{
    id: 1,
    date: "2025-11-13",
    category: "development",
    author: "@rexamm1t",
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
}
];