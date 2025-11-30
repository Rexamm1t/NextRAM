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

struct SystemSpecs {
    long total_ram_kb = 0;
    long available_ram_kb = 0;
    long swap_total_kb = 0;
    long swap_free_kb = 0;
    int cpu_cores = 0;
    int cpu_big_cores = 0;
    int cpu_little_cores = 0;
    std::vector<long> cpu_frequencies;
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
        
        for (int i = 0; i < specs.cpu_cores; i++) {
            std::string freq_path = "/sys/devices/system/cpu/cpu" + std::to_string(i) + "/cpufreq/cpuinfo_max_freq";
            if (fileExists(freq_path)) {
                std::string freq_str = readFile(freq_path);
                if (!freq_str.empty()) {
                    specs.cpu_frequencies.push_back(std::stol(freq_str));
                }
            }
        }
        
        if (!specs.cpu_frequencies.empty()) {
            std::sort(specs.cpu_frequencies.begin(), specs.cpu_frequencies.end());
            
            long min_freq = specs.cpu_frequencies.front();
            long max_freq = specs.cpu_frequencies.back();
            long threshold = (min_freq + max_freq) / 3;
            
            for (long freq : specs.cpu_frequencies) {
                if (freq > threshold * 1.5) specs.cpu_big_cores++;
                else specs.cpu_little_cores++;
            }
            
            long total_freq = 0;
            for (long freq : specs.cpu_frequencies) total_freq += freq;
            specs.cpu_performance_score = (double)total_freq / (specs.cpu_cores * 1000000.0);
        } else {
            specs.cpu_big_cores = std::max(1, specs.cpu_cores / 2);
            specs.cpu_little_cores = specs.cpu_cores - specs.cpu_big_cores;
            specs.cpu_performance_score = 1.0;
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
        
        std::vector<std::string> gaming_brands = {"asus", "rog", "redmagic", "blackshark", "poco", "redmi", "gaming"};
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
        detectDeviceInfo();
        detectMemoryFeatures();
    }

    const SystemSpecs& getSpecs() const { return specs; }
};

class SmartConfigGenerator {
private:
    AdvancedSystemAnalyzer analyzer;

public:
    SmartConfigGenerator(const AdvancedSystemAnalyzer& sysAnalyzer) : analyzer(sysAnalyzer) {}

    std::map<std::string, std::string> generateSmartConfig() {
        std::map<std::string, std::string> config;
        const SystemSpecs& specs = analyzer.getSpecs();

        config["SWAP_ENABLED"] = "false";
        config["SWAP_SIZE_GB"] = "1.0";
        config["OVERHEAD_GB"] = "0.3";
        config["ZRAM_ENABLED"] = "true";
        
        if (specs.is_very_high_memory_device) {
            config["ZRAM_RATIO"] = "0.3";
        } else if (specs.total_ram_kb > 9 * 1024 * 1024) {
            config["ZRAM_RATIO"] = "0.5";
        } else if (specs.is_high_memory_device) {
            config["ZRAM_RATIO"] = "1.0";
        } else if (specs.is_medium_memory_device) {
            config["ZRAM_RATIO"] = "1.5";
        } else {
            config["ZRAM_RATIO"] = "2.0";
        }
        
        if (specs.cpu_big_cores >= 4) {
            config["ZRAM_ALGORITHM"] = "lz4";
        } else if (specs.cpu_big_cores >= 2) {
            config["ZRAM_ALGORITHM"] = "lzo-rle";
        } else {
            config["ZRAM_ALGORITHM"] = "lzo";
        }
        
        int streams = specs.cpu_cores;
        if (specs.cpu_big_cores > 0) {
            streams = specs.cpu_big_cores * 2;
        }
        config["MAX_COMP_STREAMS"] = std::to_string(std::min(streams, 8));
        
        int swappiness;
        if (specs.is_low_memory_device) {
            swappiness = 100;
        } else if (specs.is_high_memory_device) {
            swappiness = (specs.memory_pressure < 0.3) ? 60 : 80;
        } else {
            swappiness = 80;
        }
        config["SWAPPINESS"] = std::to_string(std::min(swappiness, 150));
        
        int cache_pressure;
        if (specs.is_low_memory_device) {
            cache_pressure = 60;
        } else if (specs.total_ram_kb >= 6 * 1024 * 1024) {
            cache_pressure = 80;
        } else {
            cache_pressure = 70;
        }
        config["CACHE_PRESSURE"] = std::to_string(std::min(cache_pressure, 100));
        
        if (specs.is_emmc_storage) {
            config["DIRTY_RATIO"] = "15";
            config["DIRTY_BACKGROUND_RATIO"] = "5";
        } else if (specs.is_ufs_storage) {
            config["DIRTY_RATIO"] = "20";
            config["DIRTY_BACKGROUND_RATIO"] = "10";
        } else {
            config["DIRTY_RATIO"] = "25";
            config["DIRTY_BACKGROUND_RATIO"] = "12";
        }
        
        config["EXTRA_TUNING"] = (specs.is_high_memory_device && specs.cpu_big_cores >= 2) ? "true" : "false";
        config["DYNAMIC_SWAPPINESS"] = "true";
        config["PERFORMANCE_MODE"] = specs.is_gaming_device ? "true" : "false";
        config["ZRAM_AUTO_TUNE"] = "false";
        config["LOG_LEVEL"] = "INFO";
        
        if (specs.is_emmc_storage) {
            config["VM_DIRTY_WRITEBACK_CENTISECS"] = "3000";
            config["VM_DIRTY_EXPIRE_CENTISECS"] = "5000";
        } else if (specs.is_ufs_storage) {
            config["VM_DIRTY_WRITEBACK_CENTISECS"] = "2000";
            config["VM_DIRTY_EXPIRE_CENTISECS"] = "4000";
        } else {
            config["VM_DIRTY_WRITEBACK_CENTISECS"] = "1500";
            config["VM_DIRTY_EXPIRE_CENTISECS"] = "3000";
        }
        
        config["VM_PAGE_CLUSTER"] = specs.is_low_memory_device ? "0" : "3";
        config["VM_LAPTOP_MODE"] = "0";
        config["VM_OOM_KILL_ALLOCATING_TASK"] = "0";
        config["VM_PANIC_ON_OOM"] = "0";
        config["VM_OVERCOMMIT_MEMORY"] = "1";
        
        if (specs.is_low_memory_device) {
            config["VM_OVERCOMMIT_RATIO"] = "70";
        } else if (specs.is_high_memory_device) {
            config["VM_OVERCOMMIT_RATIO"] = "90";
        } else {
            config["VM_OVERCOMMIT_RATIO"] = "80";
        }
        
        if (specs.is_low_memory_device) {
            config["VM_WATERMARK_SCALE_FACTOR"] = "150";
        } else if (specs.is_high_memory_device) {
            config["VM_WATERMARK_SCALE_FACTOR"] = "50";
        } else {
            config["VM_WATERMARK_SCALE_FACTOR"] = "100";
        }
        
        config["KERNEL_THREADS_MAX"] = "0";
        
        if (specs.cpu_big_cores >= 4) {
            config["ZRAM_COMPRESSION_LEVEL"] = "3";
        } else if (specs.cpu_big_cores >= 2) {
            config["ZRAM_COMPRESSION_LEVEL"] = "2";
        } else {
            config["ZRAM_COMPRESSION_LEVEL"] = "1";
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
        config["ZRAM_MEMORY_LIMIT"] = std::to_string(zram_limit) + "G";
        
        config["SWAP_PRIORITY"] = "10";
        config["ZRAM_PRIORITY"] = "100";
        config["IO_SCHEDULER_TUNE"] = "false";
        config["CPU_BOOST"] = "false";
        config["NETWORK_TUNE"] = "false";

        return config;
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
        if (ratio > 2.5) {
            std::cerr << "[Validator] Warning: ZRAM ratio too high: " << ratio << std::endl;
        }
    }
    
    it = config.find("SWAPPINESS");
    if (it != config.end()) {
        int swappiness = std::stoi(it->second);
        if (swappiness > 150) {
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
    std::cout << "[NextRAM] Starting smart configuration analysis..." << std::endl;
    
    if (geteuid() != 0) {
        std::cout << "[NextRAM] Error: Root access required" << std::endl;
        return 1;
    }
    
    try {
        AdvancedSystemAnalyzer analyzer;
        SmartConfigGenerator generator(analyzer);
        auto config = generator.generateSmartConfig();
        
        validateConfiguration(config);
        
        std::string config_path = "/data/adb/modules/NextRAM/config.conf";
        
        if (ensureModuleDirectory() && writeConfig(config, config_path)) {
            std::cout << "[NextRAM] Configuration successfully generated!" << std::endl;
            std::cout << "[NextRAM] ZRAM Ratio: " << config.at("ZRAM_RATIO") << std::endl;
            std::cout << "[NextRAM] Algorithm: " << config.at("ZRAM_ALGORITHM") << std::endl;
            std::cout << "[NextRAM] Swappiness: " << config.at("SWAPPINESS") << std::endl;
            std::cout << "[NextRAM] Cache Pressure: " << config.at("CACHE_PRESSURE") << std::endl;
            std::cout << "[NextRAM] Streams: " << config.at("MAX_COMP_STREAMS") << std::endl;
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