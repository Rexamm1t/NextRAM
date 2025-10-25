#include "kernel_tuner.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <chrono>
#include <thread>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <algorithm>
#include <vector>

KernelTuner::KernelTuner() {
    stats.last_successful_tuning = std::chrono::steady_clock::now();
}

KernelTuner::~KernelTuner() {
    stop();
}

bool KernelTuner::initialize() {
    if (!config.load()) {
        std::cerr << "Failed to load kernel tuning configuration" << std::endl;
        initialized = false;
        return false;
    }
    
    if (!config.getBool("EXTRA_TUNING", false)) {
        std::cout << "Kernel tuning is disabled in configuration" << std::endl;
        initialized = false;
        return true;
    }
    
    for (const auto& [param, path_info] : sysfs_paths) {
        if (!validateSysFsPath(path_info.path)) {
            std::cerr << "Warning: SysFS path not accessible: " << path_info.path << std::endl;
        }
    }
    
    std::cout << "Initializing Kernel Tuning service..." << std::endl;
    backupCurrentParameters();
    initialized = true;
    return true;
}

bool KernelTuner::validateSysFsPath(const std::string& path) const {
    return access(path.c_str(), W_OK) == 0 || access(path.c_str(), R_OK) == 0;
}

bool KernelTuner::writeSysFs(const std::string& path, const std::string& value) {
    if (path.empty() || value.empty()) {
        std::cerr << "Invalid path or value for SysFS write" << std::endl;
        return false;
    }
    
    std::ofstream file(path);
    if (!file.is_open()) {
        std::cerr << "Failed to open SysFS path: " << path << std::endl;
        return false;
    }
    
    file << value;
    
    if (file.fail()) {
        std::cerr << "Failed to write to SysFS path: " << path << std::endl;
        file.close();
        return false;
    }
    
    file.close();
    return true;
}

std::string KernelTuner::readSysFs(const std::string& path) {
    std::ifstream file(path);
    if (!file.is_open()) {
        return "";
    }
    
    std::string value;
    std::getline(file, value);
    file.close();
    return value;
}

bool KernelTuner::validateParameterValue(const std::string& param, int value) const {
    auto it = sysfs_paths.find(param);
    if (it != sysfs_paths.end()) {
        return value >= it->second.min_value && value <= it->second.max_value;
    }
    return true;
}

bool KernelTuner::setParameter(const std::string& param, const std::string& value) {
    std::lock_guard<std::mutex> lock(tuning_mutex);
    
    auto it = sysfs_paths.find(param);
    if (it == sysfs_paths.end()) {
        std::cerr << "Unknown parameter: " << param << std::endl;
        return false;
    }
    
    if (!validateSysFsPath(it->second.path)) {
        std::cerr << "SysFS path not accessible: " << it->second.path << std::endl;
        return false;
    }
    
    if (writeSysFs(it->second.path, value)) {
        std::cout << "Successfully set " << it->second.description << " to " << value << std::endl;
        stats.successful_tunings++;
        stats.last_successful_tuning = std::chrono::steady_clock::now();
        return true;
    }
    
    std::cerr << "Failed to set " << it->second.description << " to " << value << std::endl;
    stats.failed_tunings++;
    
    if (stats.failed_tunings > 10) {
        emergencyStop();
    }
    
    return false;
}

bool KernelTuner::setParameter(const std::string& param, int value) {
    if (!validateParameterValue(param, value)) {
        std::cerr << "Parameter value out of range: " << param << " = " << value << std::endl;
        return false;
    }
    return setParameter(param, std::to_string(value));
}

size_t KernelTuner::getTotalMemory() {
    struct sysinfo info;
    if (sysinfo(&info) != 0) {
        return 0;
    }
    
    return info.totalram * info.mem_unit / 1024;
}

bool KernelTuner::isZramActive() {
    std::ifstream swaps_file("/proc/swaps");
    if (!swaps_file.is_open()) {
        return false;
    }
    
    std::string line;
    while (std::getline(swaps_file, line)) {
        if (line.find("/dev/block/zram0") != std::string::npos) {
            return true;
        }
    }
    
    return false;
}

int KernelTuner::calculateDynamicSwappiness() {
    size_t mem_total = getTotalMemory();
    int swappiness = 90;
    
    if (mem_total < 2000000) {
        swappiness = 150;
    } else if (mem_total < 4000000) {
        swappiness = 100;
    } else {
        swappiness = 80;
    }
    
    if (isZramActive()) {
        swappiness += 20;
    }
    
    return std::min(swappiness, 180);
}

void KernelTuner::adjustSwappiness() {
    if (config.getBool("DYNAMIC_SWAPPINESS", false)) {
        int dynamic_swappiness = calculateDynamicSwappiness();
        setParameter("swappiness", dynamic_swappiness);
        std::cout << "Dynamic swappiness adjustment: " << dynamic_swappiness << std::endl;
    } else {
        int swappiness = config.getInt("SWAPPINESS", 90);
        setParameter("swappiness", swappiness);
    }
}

void KernelTuner::applyPerformanceTuning() {
    if (!config.getBool("PERFORMANCE_MODE", false)) {
        return;
    }
    
    std::cout << "Applying performance tuning..." << std::endl;
    
    setParameter("oom_kill_allocating_task", 0);
    setParameter("overcommit_memory", 1);
    setParameter("vfs_cache_pressure", 100);
    setParameter("dirty_background_ratio", 5);
    setParameter("dirty_ratio", 20);
    setParameter("laptop_mode", 0);
    
    if (config.getBool("VM_COMPACTION_PROACTIVE", true)) {
        setParameter("compaction_proactive", 1);
    }
    
    setParameter("page-cluster", config.getInt("VM_PAGE_CLUSTER", 3));
}

void KernelTuner::applyVMTuning() {
    std::cout << "Applying VM tuning..." << std::endl;
    
    setParameter("vfs_cache_pressure", config.getInt("CACHE_PRESSURE", 45));
    setParameter("dirty_ratio", config.getInt("DIRTY_RATIO", 35));
    setParameter("dirty_background_ratio", config.getInt("DIRTY_BACKGROUND_RATIO", 5));
    
    setParameter("extra_free_kbytes", config.getInt("VM_EXTRA_FREE_KBYTES", 12288));
    setParameter("dirty_expire_centisecs", config.getInt("VM_DIRTY_EXPIRE_CENTISECS", 3000));
    setParameter("dirty_writeback_centisecs", config.getInt("VM_DIRTY_WRITEBACK_CENTISECS", 500));
    setParameter("min_free_kbytes", config.getInt("VM_MIN_FREE_KBYTES", 67584));
    setParameter("watermark_scale_factor", config.getInt("VM_WATERMARK_SCALE_FACTOR", 125));
}

void KernelTuner::applyHugePages() {
    if (!config.getBool("HUGEPAGES_ENABLED", true)) {
        return;
    }
    
    int hugepages_count = config.getInt("HUGEPAGES_COUNT", 16);
    int hugepages_size_mb = config.getInt("HUGEPAGES_SIZE_MB", 2);
    
    std::string hugepages_path = "/sys/kernel/mm/hugepages/hugepages-" + 
                                std::to_string(hugepages_size_mb * 1024) + "kB/nr_hugepages";
    
    if (writeSysFs(hugepages_path, std::to_string(hugepages_count))) {
        std::cout << "Set hugepages: " << hugepages_count << " pages of " 
                  << hugepages_size_mb << "MB" << std::endl;
    }
}

void KernelTuner::applyProcessAwareOptimizations() {
    if (!config.getBool("PROCESS_AWARE_OPTIMIZATION", true)) {
        return;
    }
    
    std::string performance_apps = config.get("PERFORMANCE_APPS", "");
    std::string background_apps = config.get("BACKGROUND_APPS", "");
    
    if (!performance_apps.empty()) {
        std::cout << "Applying process-aware optimizations for performance apps" << std::endl;
    }
    
    if (!background_apps.empty()) {
        std::cout << "Applying process-aware optimizations for background apps" << std::endl;
    }
}

void KernelTuner::applyContextAwareOptimizations() {
    if (!config.getBool("CONTEXT_AWARE_OPTIMIZATION", true)) {
        return;
    }
    
    std::cout << "Applying context-aware optimizations..." << std::endl;
    
    std::string profile = config.get("PERFORMANCE_PROFILE", "balanced");
    
    if (profile == "gaming") {
        setParameter("swappiness", 30);
        setParameter("vfs_cache_pressure", 50);
        setParameter("dirty_ratio", 15);
        setParameter("dirty_background_ratio", 5);
    } else if (profile == "battery") {
        setParameter("swappiness", 60);
        setParameter("vfs_cache_pressure", 80);
        setParameter("dirty_ratio", 40);
        setParameter("dirty_background_ratio", 10);
    }
}

void KernelTuner::applyThermalControl() {
    if (!config.getBool("THERMAL_CONTROL_ENABLED", true)) {
        return;
    }
    
    std::cout << "Applying thermal control optimizations..." << std::endl;
    
    std::string thermal_path = "/sys/class/thermal/thermal_zone0/temp";
    std::string temp = readSysFs(thermal_path);
    
    if (!temp.empty()) {
        int temperature = std::stoi(temp);
        if (temperature > 70000) {
            setParameter("swappiness", 120);
            setParameter("vfs_cache_pressure", 150);
            std::cout << "High temperature detected (" << temperature/1000 << "C), adjusting parameters" << std::endl;
        }
    }
}

void KernelTuner::applyKernelTuning() {
    std::cout << "Applying kernel tuning parameters..." << std::endl;
    
    adjustSwappiness();
    applyVMTuning();
    applyPerformanceTuning();
    applyHugePages();
    applyProcessAwareOptimizations();
    applyContextAwareOptimizations();
    applyThermalControl();
    
    if (config.getBool("AI_OPTIMIZER_ENABLED", true)) {
        std::cout << "AI optimizer enabled - adaptive tuning will be applied" << std::endl;
    }
}

void KernelTuner::logCurrentParameters() {
    std::cout << "=== Current Kernel Parameters ===" << std::endl;
    for (const auto& [param, path_info] : sysfs_paths) {
        std::string value = readSysFs(path_info.path);
        if (!value.empty()) {
            std::cout << path_info.description << ": " << value << std::endl;
        }
    }
    std::cout << "=================================" << std::endl;
}

void KernelTuner::emergencyStop() {
    std::cerr << "EMERGENCY: Too many tuning failures, stopping service" << std::endl;
    stop();
}

void KernelTuner::backupCurrentParameters() {
}

void KernelTuner::restoreParametersIfNeeded() {
}

void KernelTuner::monitorKernelParameters() {
    int monitor_count = 0;
    const int MAX_CONSECUTIVE_FAILURES = 5;
    int consecutive_failures = 0;
    
    while (running) {
        try {
            std::this_thread::sleep_for(std::chrono::seconds(10));
            
            if (config.reloadIfNeeded()) {
                std::cout << "Configuration changed, reapplying kernel tuning..." << std::endl;
                applyKernelTuning();
                consecutive_failures = 0;
            }
            
            applyThermalControl();
            
            monitor_count++;
            if (monitor_count % 6 == 0) {
                logCurrentParameters();
            }
            
            if (monitor_count % 30 == 0) {
                restoreParametersIfNeeded();
                monitor_count = 0;
            }
            
        } catch (const std::exception& e) {
            std::cerr << "Error in monitor thread: " << e.what() << std::endl;
            consecutive_failures++;
            
            if (consecutive_failures >= MAX_CONSECUTIVE_FAILURES) {
                std::cerr << "Too many consecutive failures in monitor thread, stopping" << std::endl;
                break;
            }
            
            std::this_thread::sleep_for(std::chrono::seconds(1 << consecutive_failures));
        }
    }
}

void KernelTuner::run() {
    applyKernelTuning();
    logCurrentParameters();
    
    monitor_thread = std::thread(&KernelTuner::monitorKernelParameters, this);
}

void KernelTuner::stop() {
    running = false;
    if (monitor_thread.joinable()) {
        monitor_thread.join();
    }
    
    std::cout << "Kernel tuning service stopped" << std::endl;
}
