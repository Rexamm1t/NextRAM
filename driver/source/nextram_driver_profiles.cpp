#include "nextram_driver_profiles.h"
#include <fstream>
#include <algorithm>
#include <cmath>

ProfileManager::ProfileManager() {
    loadDefaultProfiles();
    current_profile_ = PerformanceProfile::BALANCED;
}

void ProfileManager::loadDefaultProfiles() {
    ProfileConfig battery;
    battery.swappiness = 30;
    battery.cache_pressure = 80;
    battery.dirty_ratio = 10;
    battery.dirty_background_ratio = 5;
    battery.zram_enabled = true;
    battery.zram_algorithm = "lzo";
    battery.zram_ratio = 1.5f;
    battery.max_comp_streams = 2;
    battery.extra_tuning = false;
    battery.dynamic_swappiness = true;
    battery.performance_mode = false;
    battery.zram_auto_tune = false;
    battery.vm_page_cluster = 0;
    battery.vm_swappiness = 30;
    profile_configs_[PerformanceProfile::BATTERY_SAVER] = battery;

    ProfileConfig balanced;
    balanced.swappiness = 60;
    balanced.cache_pressure = 50;
    balanced.dirty_ratio = 20;
    balanced.dirty_background_ratio = 10;
    balanced.zram_enabled = true;
    balanced.zram_algorithm = "lz4";
    balanced.zram_ratio = 2.0f;
    balanced.max_comp_streams = 4;
    balanced.extra_tuning = true;
    balanced.dynamic_swappiness = true;
    balanced.performance_mode = false;
    balanced.zram_auto_tune = true;
    balanced.vm_page_cluster = 2;
    balanced.vm_swappiness = 60;
    profile_configs_[PerformanceProfile::BALANCED] = balanced;

    ProfileConfig performance;
    performance.swappiness = 100;
    performance.cache_pressure = 30;
    performance.dirty_ratio = 30;
    performance.dirty_background_ratio = 15;
    performance.zram_enabled = true;
    performance.zram_algorithm = "zstd";
    performance.zram_ratio = 3.0f;
    performance.max_comp_streams = 8;
    performance.extra_tuning = true;
    performance.dynamic_swappiness = false;
    performance.performance_mode = true;
    performance.zram_auto_tune = true;
    performance.vm_page_cluster = 3;
    performance.vm_swappiness = 100;
    profile_configs_[PerformanceProfile::PERFORMANCE] = performance;

    ProfileConfig gaming;
    gaming.swappiness = 80;
    gaming.cache_pressure = 40;
    gaming.dirty_ratio = 25;
    gaming.dirty_background_ratio = 10;
    gaming.zram_enabled = true;
    gaming.zram_algorithm = "lz4";
    gaming.zram_ratio = 2.5f;
    gaming.max_comp_streams = 6;
    gaming.extra_tuning = true;
    gaming.dynamic_swappiness = false;
    gaming.performance_mode = true;
    gaming.zram_auto_tune = true;
    gaming.vm_page_cluster = 3;
    gaming.vm_swappiness = 80;
    profile_configs_[PerformanceProfile::GAMING] = gaming;

    ProfileConfig multitasking;
    multitasking.swappiness = 70;
    multitasking.cache_pressure = 60;
    multitasking.dirty_ratio = 15;
    multitasking.dirty_background_ratio = 5;
    multitasking.zram_enabled = true;
    multitasking.zram_algorithm = "lz4";
    multitasking.zram_ratio = 2.2f;
    multitasking.max_comp_streams = 6;
    multitasking.extra_tuning = true;
    multitasking.dynamic_swappiness = true;
    multitasking.performance_mode = false;
    multitasking.zram_auto_tune = true;
    multitasking.vm_page_cluster = 2;
    multitasking.vm_swappiness = 70;
    profile_configs_[PerformanceProfile::MULTITASKING] = multitasking;
}

bool ProfileManager::loadProfile(PerformanceProfile profile) {
    auto it = profile_configs_.find(profile);
    if (it == profile_configs_.end()) {
        return false;
    }

    current_profile_ = profile;
    return applyProfileSettings(it->second);
}

bool ProfileManager::saveCustomProfile(const std::string& name, const ProfileConfig& config) {
    custom_profiles_[name] = config;
    return true;
}

bool ProfileManager::loadCustomProfile(const std::string& name) {
    auto it = custom_profiles_.find(name);
    if (it == custom_profiles_.end()) {
        return false;
    }

    current_profile_ = PerformanceProfile::CUSTOM;
    return applyProfileSettings(it->second);
}

PerformanceProfile ProfileManager::detectOptimalProfile() {
    std::ifstream meminfo("/proc/meminfo");
    uint64_t total_memory = 0;
    uint64_t available_memory = 0;
    std::string line;
    
    while (std::getline(meminfo, line)) {
        if (line.find("MemTotal:") != std::string::npos) {
            sscanf(line.c_str(), "MemTotal: %lu kB", &total_memory);
        } else if (line.find("MemAvailable:") != std::string::npos) {
            sscanf(line.c_str(), "MemAvailable: %lu kB", &available_memory);
        }
    }
    
    float memory_usage = 1.0f - (float)available_memory / total_memory;
    
    if (memory_usage > 0.8f) {
        return PerformanceProfile::PERFORMANCE;
    } else if (memory_usage < 0.3f) {
        return PerformanceProfile::BATTERY_SAVER;
    } else {
        return PerformanceProfile::BALANCED;
    }
}

bool ProfileManager::applyProfileSettings(const ProfileConfig& config) {
    bool success = true;
    
    success &= writeToProcfs("/proc/sys/vm/swappiness", std::to_string(config.swappiness));
    success &= writeToProcfs("/proc/sys/vm/vfs_cache_pressure", std::to_string(config.cache_pressure));
    success &= writeToProcfs("/proc/sys/vm/dirty_ratio", std::to_string(config.dirty_ratio));
    success &= writeToProcfs("/proc/sys/vm/dirty_background_ratio", std::to_string(config.dirty_background_ratio));
    success &= writeToProcfs("/proc/sys/vm/page-cluster", std::to_string(config.vm_page_cluster));
    
    if (config.zram_enabled) {
        success &= writeToSysfs("/sys/block/zram0/comp_algorithm", config.zram_algorithm);
    }
    
    return success;
}

bool ProfileManager::applyProfileTweaks() {
    auto it = profile_configs_.find(current_profile_);
    if (it != profile_configs_.end()) {
        return applyProfileSettings(it->second);
    }
    return false;
}

std::string ProfileManager::getProfileName(PerformanceProfile profile) {
    switch (profile) {
        case PerformanceProfile::BATTERY_SAVER: return "battery";
        case PerformanceProfile::BALANCED: return "balanced";
        case PerformanceProfile::PERFORMANCE: return "performance";
        case PerformanceProfile::GAMING: return "gaming";
        case PerformanceProfile::MULTITASKING: return "multitasking";
        case PerformanceProfile::CUSTOM: return "custom";
        default: return "unknown";
    }
}

bool ProfileManager::writeToProcfs(const std::string& path, const std::string& value) {
    std::ofstream file(path);
    if (!file.is_open()) return false;
    file << value;
    return file.good();
}

bool ProfileManager::writeToSysfs(const std::string& path, const std::string& value) {
    std::ofstream file(path);
    if (!file.is_open()) return false;
    file << value;
    return file.good();
}