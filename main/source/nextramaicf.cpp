/*#########################################
### NextRAM CPP is a tool for creating ####
### configurations for your device     ####
#########################################*/
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <map>
#include <vector>
#include <algorithm>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <dirent.h>
#include <cstring>
#include <cmath>
#include <cctype>

struct SystemSpecs {
    long total_ram_kb = 0;
    long available_ram_kb = 0;
    long swap_total_kb = 0;
    long swap_free_kb = 0;
    int cpu_cores = 0;
    int cpu_big_cores = 0;
    int cpu_little_cores = 0;
    std::vector<long> cpu_frequencies;
    long cpu_max_freq = 0;
    long cpu_min_freq = 0;
    std::string storage_type;
    std::string device_model;
    std::string kernel_version;
    bool is_low_memory_device = false;
    bool is_medium_memory_device = false;
    bool is_high_memory_device = false;
    bool is_very_high_memory_device = false;
    bool is_emmc_storage = false;
    bool is_ufs_storage = false;
    bool is_nvme_storage = false;
    bool has_zram = false;
    bool has_swap = false;
    bool is_gaming_device = false;
    double memory_pressure = 0.0;
    double cpu_performance_score = 0.0;
    bool has_gpu = false;
    std::string gpu_governor;
    long gpu_max_freq = 0;
    bool has_wifi = false;
    std::vector<std::string> tcp_congestion_available;
};

class AdvancedSystemAnalyzer {
private:
    SystemSpecs specs;

    std::string readFile(const std::string& path) {
        std::ifstream file(path);
        if (!file) return "";
        std::stringstream buffer;
        buffer << file.rdbuf();
        std::string content = buffer.str();
        content.erase(std::remove(content.begin(), content.end(), '\n'), content.end());
        return content;
    }

    std::string execCommand(const std::string& cmd) {
        char buffer[256];
        std::string result = "";
        FILE* pipe = popen(cmd.c_str(), "r");
        if (!pipe) return "";
        while (fgets(buffer, sizeof buffer, pipe) != NULL) {
            result += buffer;
        }
        pclose(pipe);
        return result;
    }

    std::string trim(const std::string& str) {
        size_t start = str.find_first_not_of(" \t\n\r");
        size_t end = str.find_last_not_of(" \t\n\r");
        if (start == std::string::npos) return "";
        return str.substr(start, end - start + 1);
    }

    bool fileExists(const std::string& path) {
        return access(path.c_str(), F_OK) == 0;
    }

    void loadMemInfo() {
        std::ifstream file("/proc/meminfo");
        if (!file) return;

        std::string line;
        while (std::getline(file, line)) {
            std::istringstream iss(line);
            std::string key;
            long value;
            std::string unit;
            iss >> key >> value >> unit;
            if (!key.empty() && key.back() == ':') key.pop_back();

            if (key == "MemTotal") specs.total_ram_kb = value;
            else if (key == "MemAvailable") specs.available_ram_kb = value;
            else if (key == "SwapTotal") specs.swap_total_kb = value;
            else if (key == "SwapFree") specs.swap_free_kb = value;
        }

        long total_ram_gb = specs.total_ram_kb / (1024 * 1024);
        specs.is_low_memory_device = (total_ram_gb <= 2);
        specs.is_medium_memory_device = (total_ram_gb > 2 && total_ram_gb <= 6);
        specs.is_high_memory_device = (total_ram_gb > 6 && total_ram_gb <= 12);
        specs.is_very_high_memory_device = (total_ram_gb > 12);

        specs.memory_pressure = specs.total_ram_kb > 0 ?
            (double)(specs.total_ram_kb - specs.available_ram_kb) / specs.total_ram_kb : 0.0;
    }

    void detectCPUInfo() {
        specs.cpu_cores = sysconf(_SC_NPROCESSORS_ONLN);
        if (specs.cpu_cores <= 0) specs.cpu_cores = 4;

        specs.cpu_max_freq = 0;
        specs.cpu_min_freq = LONG_MAX;

        for (int i = 0; i < specs.cpu_cores; i++) {
            std::string freq_path = "/sys/devices/system/cpu/cpu" + std::to_string(i) + "/cpufreq/cpuinfo_max_freq";
            if (fileExists(freq_path)) {
                std::string freq_str = readFile(freq_path);
                if (!freq_str.empty()) {
                    long freq = std::stol(freq_str);
                    specs.cpu_frequencies.push_back(freq);
                    if (freq > specs.cpu_max_freq) specs.cpu_max_freq = freq;
                    if (freq < specs.cpu_min_freq) specs.cpu_min_freq = freq;
                }
            }
        }

        if (!specs.cpu_frequencies.empty()) {
            std::sort(specs.cpu_frequencies.begin(), specs.cpu_frequencies.end());
            long threshold = specs.cpu_frequencies.front() * 1.5;
            for (long freq : specs.cpu_frequencies) {
                if (freq >= threshold) specs.cpu_big_cores++;
                else specs.cpu_little_cores++;
            }
            if (specs.cpu_big_cores == 0) specs.cpu_big_cores = specs.cpu_cores / 2;
            if (specs.cpu_little_cores == 0) specs.cpu_little_cores = specs.cpu_cores - specs.cpu_big_cores;

            long total_freq = 0;
            for (long freq : specs.cpu_frequencies) total_freq += freq;
            specs.cpu_performance_score = (double)total_freq / (specs.cpu_cores * 1000000.0);
        } else {
            specs.cpu_big_cores = std::max(1, specs.cpu_cores / 2);
            specs.cpu_little_cores = specs.cpu_cores - specs.cpu_big_cores;
            specs.cpu_performance_score = 1.0;
            specs.cpu_max_freq = 2000000;
            specs.cpu_min_freq = 300000;
        }
    }

    void detectStorageInfo() {
        if (access("/sys/class/ufs", F_OK) == 0) {
            specs.storage_type = "UFS";
            specs.is_ufs_storage = true;
        } else if (access("/sys/class/nvme", F_OK) == 0) {
            specs.storage_type = "NVMe";
            specs.is_nvme_storage = true;
        } else {
            specs.storage_type = "eMMC";
            specs.is_emmc_storage = true;
        }
    }

    void detectGPU() {
        if (access("/sys/class/kgsl/kgsl-3d0", F_OK) == 0) {
            specs.has_gpu = true;
            if (access("/sys/class/kgsl/kgsl-3d0/devfreq/governor", F_OK) == 0) {
                specs.gpu_governor = readFile("/sys/class/kgsl/kgsl-3d0/devfreq/governor");
            }
            if (access("/sys/class/kgsl/kgsl-3d0/max_gpuclk", F_OK) == 0) {
                std::string val = readFile("/sys/class/kgsl/kgsl-3d0/max_gpuclk");
                if (!val.empty()) specs.gpu_max_freq = std::stol(val);
            }
        } else if (access("/sys/devices/platform/14ac0000.mali", F_OK) == 0) {
            specs.has_gpu = true;
        } else if (access("/sys/kernel/gpu", F_OK) == 0) {
            specs.has_gpu = true;
        }
    }

    void detectNetwork() {
        specs.has_wifi = (access("/sys/class/net/wlan0", F_OK) == 0);
        if (access("/proc/sys/net/ipv4/tcp_available_congestion_control", F_OK) == 0) {
            std::string algs = readFile("/proc/sys/net/ipv4/tcp_available_congestion_control");
            std::istringstream iss(algs);
            std::string alg;
            while (iss >> alg) {
                specs.tcp_congestion_available.push_back(alg);
            }
        }
    }

    void detectDeviceInfo() {
        specs.device_model = execCommand("getprop ro.product.model 2>/dev/null");
        if (specs.device_model.empty()) {
            specs.device_model = execCommand("getprop ro.product.device 2>/dev/null");
        }
        specs.device_model = trim(specs.device_model);

        struct utsname uname_data;
        if (uname(&uname_data) == 0) {
            specs.kernel_version = uname_data.release;
        }

        std::string product_brand = execCommand("getprop ro.product.brand 2>/dev/null");
        product_brand = trim(product_brand);
        std::string lower_brand = product_brand;
        std::transform(lower_brand.begin(), lower_brand.end(), lower_brand.begin(), ::tolower);

        std::vector<std::string> gaming_brands = {"asus", "rog", "redmagic", "blackshark", "poco", "redmi", "gaming", "lenovo", "legion"};
        for (const auto& brand : gaming_brands) {
            if (lower_brand.find(brand) != std::string::npos) {
                specs.is_gaming_device = true;
                break;
            }
        }
    }

    void detectMemoryFeatures() {
        for (int i = 0; i < 8; i++) {
            std::string zram_path = "/dev/block/zram" + std::to_string(i);
            if (fileExists(zram_path)) {
                specs.has_zram = true;
                break;
            }
        }

        std::string swaps_content = readFile("/proc/swaps");
        if (swaps_content.find("zram") != std::string::npos) {
            specs.has_zram = true;
        }

        specs.has_swap = (specs.swap_total_kb > 0);
    }

public:
    AdvancedSystemAnalyzer() {
        loadMemInfo();
        detectCPUInfo();
        detectStorageInfo();
        detectGPU();
        detectNetwork();
        detectDeviceInfo();
        detectMemoryFeatures();
    }

    const SystemSpecs& getSpecs() const { return specs; }
};

class SmartConfigGenerator {
private:
    const SystemSpecs& specs;

    std::string pickTCPCongestion() {
        std::vector<std::string> preferred = {"bbr", "bbr2", "cubic", "reno"};
        for (const auto& p : preferred) {
            if (std::find(specs.tcp_congestion_available.begin(), specs.tcp_congestion_available.end(), p) != specs.tcp_congestion_available.end()) {
                return p;
            }
        }
        return "cubic";
    }

public:
    SmartConfigGenerator(const AdvancedSystemAnalyzer& analyzer) : specs(analyzer.getSpecs()) {}

    std::map<std::string, std::string> generateFullConfig() {
        std::map<std::string, std::string> cfg;

        cfg["SWAP_ENABLED"] = "false";
        cfg["SWAP_SIZE_GB"] = "1.0";
        cfg["OVERHEAD_GB"] = "0.3";
        cfg["ZRAM_ENABLED"] = "true";

        if (specs.is_very_high_memory_device) {
            cfg["ZRAM_RATIO"] = "0.3";
        } else if (specs.total_ram_kb > 9 * 1024 * 1024) {
            cfg["ZRAM_RATIO"] = "0.5";
        } else if (specs.is_high_memory_device) {
            cfg["ZRAM_RATIO"] = "1.0";
        } else if (specs.is_medium_memory_device) {
            cfg["ZRAM_RATIO"] = "1.5";
        } else {
            cfg["ZRAM_RATIO"] = "2.0";
        }

        if (specs.cpu_big_cores >= 4) {
            cfg["ZRAM_ALGORITHM"] = "zstd";
        } else if (specs.cpu_big_cores >= 2) {
            cfg["ZRAM_ALGORITHM"] = "lz4";
        } else {
            cfg["ZRAM_ALGORITHM"] = "lzo-rle";
        }

        int streams = specs.cpu_big_cores > 0 ? specs.cpu_big_cores : specs.cpu_cores;
        streams = std::min(streams, 8);
        cfg["MAX_COMP_STREAMS"] = std::to_string(streams);

        int swappiness = 100;
        if (specs.is_low_memory_device) swappiness = 120;
        else if (specs.is_medium_memory_device) swappiness = 100;
        else if (specs.is_high_memory_device) swappiness = 80;
        else swappiness = 60;
        cfg["SWAPPINESS"] = std::to_string(swappiness);

        int cache_pressure = 100;
        if (specs.is_low_memory_device) cache_pressure = 70;
        else if (specs.is_medium_memory_device) cache_pressure = 80;
        else cache_pressure = 90;
        cfg["CACHE_PRESSURE"] = std::to_string(cache_pressure);

        if (specs.is_emmc_storage) {
            cfg["DIRTY_RATIO"] = "15";
            cfg["DIRTY_BACKGROUND_RATIO"] = "5";
        } else if (specs.is_ufs_storage) {
            cfg["DIRTY_RATIO"] = "20";
            cfg["DIRTY_BACKGROUND_RATIO"] = "10";
        } else {
            cfg["DIRTY_RATIO"] = "25";
            cfg["DIRTY_BACKGROUND_RATIO"] = "12";
        }

        cfg["EXTRA_TUNING"] = (specs.is_high_memory_device && specs.cpu_big_cores >= 2) ? "true" : "false";
        cfg["DYNAMIC_SWAPPINESS"] = "true";
        cfg["PERFORMANCE_MODE"] = specs.is_gaming_device ? "true" : "false";
        cfg["ZRAM_AUTO_TUNE"] = "false";
        cfg["LOG_LEVEL"] = "INFO";

        if (specs.is_emmc_storage) {
            cfg["VM_DIRTY_WRITEBACK_CENTISECS"] = "3000";
            cfg["VM_DIRTY_EXPIRE_CENTISECS"] = "5000";
        } else if (specs.is_ufs_storage) {
            cfg["VM_DIRTY_WRITEBACK_CENTISECS"] = "2000";
            cfg["VM_DIRTY_EXPIRE_CENTISECS"] = "4000";
        } else {
            cfg["VM_DIRTY_WRITEBACK_CENTISECS"] = "1500";
            cfg["VM_DIRTY_EXPIRE_CENTISECS"] = "3000";
        }

        cfg["VM_PAGE_CLUSTER"] = specs.is_low_memory_device ? "0" : "3";
        cfg["VM_LAPTOP_MODE"] = "0";
        cfg["VM_OOM_KILL_ALLOCATING_TASK"] = "0";
        cfg["VM_PANIC_ON_OOM"] = "0";
        cfg["VM_OVERCOMMIT_MEMORY"] = "1";

        if (specs.is_low_memory_device) {
            cfg["VM_OVERCOMMIT_RATIO"] = "70";
        } else if (specs.is_high_memory_device) {
            cfg["VM_OVERCOMMIT_RATIO"] = "90";
        } else {
            cfg["VM_OVERCOMMIT_RATIO"] = "80";
        }

        if (specs.is_low_memory_device) {
            cfg["VM_WATERMARK_SCALE_FACTOR"] = "150";
        } else if (specs.is_high_memory_device) {
            cfg["VM_WATERMARK_SCALE_FACTOR"] = "50";
        } else {
            cfg["VM_WATERMARK_SCALE_FACTOR"] = "100";
        }

        cfg["KERNEL_THREADS_MAX"] = "0";

        if (specs.cpu_big_cores >= 4) {
            cfg["ZRAM_COMPRESSION_LEVEL"] = "3";
        } else if (specs.cpu_big_cores >= 2) {
            cfg["ZRAM_COMPRESSION_LEVEL"] = "2";
        } else {
            cfg["ZRAM_COMPRESSION_LEVEL"] = "1";
        }

        long total_ram_gb = specs.total_ram_kb / (1024 * 1024);
        long zram_limit;
        if (specs.is_very_high_memory_device) {
            zram_limit = std::min(total_ram_gb / 4, 4L);
        } else if (specs.is_high_memory_device) {
            zram_limit = std::min(total_ram_gb / 3, 6L);
        } else if (specs.is_medium_memory_device) {
            zram_limit = std::min(total_ram_gb / 2, 4L);
        } else {
            zram_limit = std::min(total_ram_gb / 2, 2L);
        }
        cfg["ZRAM_MEMORY_LIMIT"] = std::to_string(zram_limit) + "G";

        cfg["SWAP_PRIORITY"] = "10";
        cfg["ZRAM_PRIORITY"] = "100";
        cfg["IO_SCHEDULER_TUNE"] = specs.is_emmc_storage ? "true" : "false";
        cfg["CPU_BOOST"] = specs.cpu_big_cores >= 2 ? "true" : "false";
        cfg["NETWORK_TUNE"] = "false";

        cfg["PLAY_ENABLED"] = specs.is_gaming_device ? "true" : "false";
        cfg["PLAY_CPU_BOOST"] = specs.cpu_big_cores >= 2 ? "true" : "false";
        cfg["PLAY_CPU_GOVERNOR"] = specs.cpu_big_cores >= 2 ? "performance" : "schedutil";
        cfg["PLAY_CPU_MIN_FREQ"] = std::to_string(specs.cpu_min_freq / 1000);
        cfg["PLAY_CPU_MAX_FREQ"] = std::to_string(specs.cpu_max_freq / 1000);
        cfg["PLAY_CPU_MAX_FREQ_PERCENT"] = "100";
        cfg["PLAY_CPU_BOOST_DURATION"] = "2000";
        cfg["PLAY_CPU_BOOST_LEVEL"] = "50";

        cfg["PLAY_GPU_BOOST"] = specs.has_gpu ? "true" : "false";
        if (specs.has_gpu) {
            if (!specs.gpu_governor.empty() && specs.gpu_governor.find("performance") != std::string::npos) {
                cfg["PLAY_GPU_GOVERNOR"] = "performance";
            } else {
                cfg["PLAY_GPU_GOVERNOR"] = "performance";
            }
        } else {
            cfg["PLAY_GPU_GOVERNOR"] = "performance";
        }
        cfg["PLAY_GPU_MAX_FREQ_PERCENT"] = "100";
        cfg["PLAY_GPU_TOUCH_BOOST"] = "true";

        cfg["PLAY_TOUCH_BOOST"] = "true";
        cfg["PLAY_TOUCH_POLLING_RATE"] = specs.is_gaming_device ? "250" : "180";
        cfg["PLAY_VSYNC_MODE"] = "adaptive";
        cfg["PLAY_DISABLE_HW_OVERLAYS"] = "false";
        cfg["PLAY_FORCE_GPU_RENDER"] = "true";

        cfg["PLAY_NETWORK_TUNE"] = "true";
        cfg["PLAY_NET_RMEM_DEFAULT"] = "262144";
        cfg["PLAY_NET_WMEM_DEFAULT"] = "262144";
        cfg["PLAY_NET_RMEM_MAX"] = "67108864";
        cfg["PLAY_NET_WMEM_MAX"] = "67108864";
        cfg["PLAY_TCP_CONGESTION"] = pickTCPCongestion();

        cfg["PLAY_SWAPPINESS"] = specs.is_low_memory_device ? "30" : "20";
        cfg["PLAY_CACHE_PRESSURE"] = specs.is_low_memory_device ? "60" : "50";
        cfg["PLAY_DIRTY_RATIO"] = specs.is_emmc_storage ? "5" : "10";
        cfg["PLAY_DIRTY_BG_RATIO"] = specs.is_emmc_storage ? "2" : "5";
        cfg["PLAY_ZRAM_OPTIMIZE"] = specs.has_zram ? "true" : "false";
        cfg["PLAY_CLEAR_CACHES"] = "true";

        cfg["PLAY_THERMAL_CONTROL"] = "true";
        cfg["PLAY_THERMAL_PROFILE"] = specs.is_gaming_device ? "aggressive" : "balanced";

        cfg["PLAY_BG_CONTROL"] = "true";
        cfg["PLAY_BG_WHITELIST"] = "com.discord,com.spotify.music,com.chrome,com.whatsapp,com.instagram.android";
        cfg["PLAY_BG_KILL_LIMIT"] = "10";

        cfg["PLAY_AUTO_DETECT"] = "true";
        cfg["PLAY_GAME_PROFILE"] = "auto";

        cfg["PLAY_PERF_MONITOR"] = "true";
        cfg["PLAY_PERF_OVERLAY"] = "false";

        cfg["PLAY_AUDIO_LATENCY"] = "low";
        cfg["PLAY_AUDIO_BUFFER"] = "128";

        cfg["PLAY_CHARGING_BOOST"] = "true";
        cfg["PLAY_BATTERY_SAVER"] = "false";
        cfg["PLAY_POWER_LIMIT"] = "0";

        cfg["PLAY_REALTIME_PRIORITY"] = "true";
        cfg["PLAY_CPU_AFFINITY"] = "0-" + std::to_string(specs.cpu_cores - 1);
        cfg["PLAY_MEMORY_LOCK"] = "false";

        cfg["PLAY_IOSCHED_TUNE"] = specs.is_emmc_storage ? "true" : "false";

        return cfg;
    }
};

bool ensureModuleDirectory() {
    std::string module_dir = "/data/adb/modules/NextRAM";
    if (access(module_dir.c_str(), F_OK) != 0) {
        return mkdir(module_dir.c_str(), 0755) == 0;
    }
    return true;
}

bool writeConfig(const std::map<std::string, std::string>& config, const std::string& path) {
    std::ofstream file(path);
    if (!file) return false;

    for (const auto& [key, value] : config) {
        file << key << "=" << value << std::endl;
    }
    return true;
}

void validateConfiguration(const std::map<std::string, std::string>& config) {
    auto it = config.find("ZRAM_RATIO");
    if (it != config.end()) {
        double ratio = std::stod(it->second);
        if (ratio > 3.6) {
            std::cerr << "[Validator] Warning: ZRAM ratio too high: " << ratio << std::endl;
        }
    }

    it = config.find("SWAPPINESS");
    if (it != config.end()) {
        int swappiness = std::stoi(it->second);
        if (swappiness > 190) {
            std::cerr << "[Validator] CRITICAL: Swappiness exceeds 150: " << swappiness << std::endl;
        }
    }

    it = config.find("CACHE_PRESSURE");
    if (it != config.end()) {
        int cache_pressure = std::stoi(it->second);
        if (cache_pressure > 100) {
            std::cerr << "[Validator] CRITICAL: Cache pressure exceeds 100: " << cache_pressure << std::endl;
        }
    }
}

int main() {
    std::cout << "[NextRAM AICF] Starting smart configuration analysis..." << std::endl;

    if (geteuid() != 0) {
        std::cout << "[NextRAM] Error: Root access required" << std::endl;
        return 1;
    }

    try {
        AdvancedSystemAnalyzer analyzer;
        SmartConfigGenerator generator(analyzer);
        auto config = generator.generateFullConfig();

        validateConfiguration(config);

        std::string config_path = "/data/adb/modules/NextRAM/config.conf";

        if (ensureModuleDirectory() && writeConfig(config, config_path)) {
            std::cout << "[NextRAM AICF] Configuration generated successfully!" << std::endl;
            std::cout << "=== Key parameters ===" << std::endl;
            std::cout << "ZRAM Ratio: " << config.at("ZRAM_RATIO") << std::endl;
            std::cout << "ZRAM Algorithm: " << config.at("ZRAM_ALGORITHM") << std::endl;
            std::cout << "Swappiness: " << config.at("SWAPPINESS") << std::endl;
            std::cout << "Cache Pressure: " << config.at("CACHE_PRESSURE") << std::endl;
            std::cout << "Play Enabled: " << config.at("PLAY_ENABLED") << std::endl;
            std::cout << "CPU Governor (Play): " << config.at("PLAY_CPU_GOVERNOR") << std::endl;
            std::cout << "TCP Congestion: " << config.at("PLAY_TCP_CONGESTION") << std::endl;
            return 0;
        } else {
            std::string fallback_path = "./NextRAM_config.conf";
            if (writeConfig(config, fallback_path)) {
                std::cout << "[NextRAM] Configuration saved to current directory" << std::endl;
                return 0;
            }
            std::cout << "[NextRAM] Error: Failed to write configuration" << std::endl;
            return 1;
        }
    } catch (const std::exception& e) {
        std::cout << "[NextRAM] Error: " << e.what() << std::endl;
        return 1;
    }
}
