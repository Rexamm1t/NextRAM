#ifndef NEXTRA_PROFILES_DRIVER_H
#define NEXTRA_PROFILES_DRIVER_H

#include <string>
#include <unordered_map>
#include "nextram_driver_mem.h"

enum class PerformanceProfile {
    BATTERY_SAVER,
    BALANCED,
    PERFORMANCE,
    GAMING,
    MULTITASKING,
    CUSTOM
};

struct ProfileConfig {
    uint32_t swappiness;
    uint32_t cache_pressure;
    uint32_t dirty_ratio;
    uint32_t dirty_background_ratio;
    bool zram_enabled;
    std::string zram_algorithm;
    float zram_ratio;
    uint32_t max_comp_streams;
    bool extra_tuning;
    bool dynamic_swappiness;
    bool performance_mode;
    bool zram_auto_tune;
    uint32_t vm_page_cluster;
    uint32_t vm_swappiness;
};

class ProfileManager {
private:
    PerformanceProfile current_profile_;
    std::unordered_map<PerformanceProfile, ProfileConfig> profile_configs_;
    std::unordered_map<std::string, ProfileConfig> custom_profiles_;
    
    void loadDefaultProfiles();
    bool applyProfileSettings(const ProfileConfig& config);
    bool writeToProcfs(const std::string& path, const std::string& value);
    bool writeToSysfs(const std::string& path, const std::string& value);
    
public:
    ProfileManager();
    
    bool loadProfile(PerformanceProfile profile);
    bool saveCustomProfile(const std::string& name, const ProfileConfig& config);
    bool loadCustomProfile(const std::string& name);
    PerformanceProfile detectOptimalProfile();
    bool applyProfileTweaks();
    
    PerformanceProfile getCurrentProfile() const { return current_profile_; }
    std::string getProfileName(PerformanceProfile profile);
};

#endif