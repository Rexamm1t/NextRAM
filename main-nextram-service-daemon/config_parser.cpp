#include "config_parser.h"
#include <fstream>
#include <sstream>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <pwd.h>
#include <grp.h>
#include <iostream>
#include <iomanip>
#include <cstring>

ConfigManager::ConfigManager(const std::string& path) : config_path(path) {
    setDefaults();
}

bool ConfigManager::load() {
    std::cout << "Loading configuration from: " << config_path << std::endl;
    
    if (!ensureConfigDirectory()) {
        std::cerr << "Failed to ensure config directory exists" << std::endl;
        return false;
    }
    
    std::ifstream file(config_path);
    if (!file.is_open()) {
        std::cout << "Config file not found, creating default configuration..." << std::endl;
        if (!createDefaultConfig()) {
            std::cerr << "Failed to create default config file" << std::endl;
            return false;
        }
        
        file.open(config_path);
        if (!file.is_open()) {
            std::cerr << "Still cannot open config file after creation" << std::endl;
            return false;
        }
    }
    
    config.clear();
    std::string line;
    int line_number = 0;
    
    while (std::getline(file, line)) {
        line_number++;
        parseLine(line);
    }
    
    file.close();
    
    struct stat st;
    if (stat(config_path.c_str(), &st) == 0) {
        last_mod_time = std::chrono::system_clock::from_time_t(st.st_mtime);
    }
    
    std::cout << "Successfully loaded " << config.size() << " configuration parameters" << std::endl;
    needs_reload = false;
    return true;
}

bool ConfigManager::save() {
    std::cout << "Saving configuration to: " << config_path << std::endl;
    
    if (!ensureConfigDirectory()) {
        std::cerr << "Cannot save: config directory not available" << std::endl;
        return false;
    }
    
   
    std::string temp_path = config_path + ".tmp";
    std::ofstream file(temp_path);
    
    if (!file.is_open()) {
        std::cerr << "Failed to create temporary config file: " << temp_path << std::endl;
        std::cerr << "Error: " << strerror(errno) << std::endl;
        return false;
    }
    
    file << "# NextRAM Daemon Configuration" << std::endl;
    file << "# Generated automatically - modify with care" << std::endl;
    file << "# " << std::endl;
    

    std::vector<std::string> categories = {
        "LOG_LEVEL"
    };
    
    std::vector<std::string> swap_settings = {
        "SWAP_ENABLED", "SWAP_SIZE_GB", "OVERHEAD_GB"
    };
    
    std::vector<std::string> zram_settings = {
        "ZRAM_ENABLED", "ZRAM_RATIO", "ZRAM_ALGORITHM", "MAX_COMP_STREAMS"
    };
    
    std::vector<std::string> vm_settings = {
        "SWAPPINESS", "CACHE_PRESSURE", "DIRTY_RATIO", "DIRTY_BACKGROUND_RATIO",
        "DYNAMIC_SWAPPINESS"
    };
    
    std::vector<std::string> advanced_settings = {
        "EXTRA_TUNING", "PERFORMANCE_MODE", "ZRAM_AUTO_TUNE"
    };
    
    std::vector<std::string> vm_extra_settings = {
        "VM_COMPACTION_PROACTIVE", "VM_PAGE_CLUSTER", "VM_EXTRA_FREE_KBYTES",
        "VM_DIRTY_EXPIRE_CENTISECS", "VM_DIRTY_WRITEBACK_CENTISECS",
        "VM_MIN_FREE_KBYTES", "VM_WATERMARK_SCALE_FACTOR"
    };
    
    std::vector<std::string> ai_settings = {
        "AI_OPTIMIZER_ENABLED", "PERFORMANCE_PROFILE", "THERMAL_CONTROL_ENABLED",
        "PROCESS_AWARE_OPTIMIZATION", "CONTEXT_AWARE_OPTIMIZATION"
    };
    
    std::vector<std::string> hugepages_settings = {
        "HUGEPAGES_ENABLED", "HUGEPAGES_COUNT", "HUGEPAGES_SIZE_MB", "HUGEPAGES_AUTO_MANAGE"
    };
    
    
    auto writeGroup = [&](const std::vector<std::string>& keys, const std::string& comment) {
        file << std::endl << "# " << comment << std::endl;
        for (const auto& key : keys) {
            auto it = config.find(key);
            if (it != config.end()) {
                file << key << "=" << it->second << std::endl;
            }
        }
    };
    
    writeGroup(categories, "Basic Settings");
    writeGroup(swap_settings, "Swap Configuration");
    writeGroup(zram_settings, "ZRAM Configuration");
    writeGroup(vm_settings, "Virtual Memory Settings");
    writeGroup(advanced_settings, "Advanced Features");
    writeGroup(vm_extra_settings, "Extra VM Settings");
    writeGroup(ai_settings, "AI Optimizer Settings");
    writeGroup(hugepages_settings, "HugePages Configuration");
    
    file.close();
    
    if (rename(temp_path.c_str(), config_path.c_str()) != 0) {
        std::cerr << "Failed to replace config file: " << strerror(errno) << std::endl;
        unlink(temp_path.c_str());
        return false;
    }
    
    chmod(config_path.c_str(), 0644);
    
    std::cout << "Configuration saved successfully with " << config.size() << " parameters" << std::endl;
    return true;
}

bool ConfigManager::createDefaultConfig() {
    std::cout << "Creating default configuration..." << std::endl;
    
    if (!ensureConfigDirectory()) {
        std::cerr << "Cannot create config: directory not available" << std::endl;
        return false;
    }
    
    setDefaults();
    bool result = save();
    
    if (result) {
        std::cout << "Default configuration created successfully at: " << config_path << std::endl;
        
        validateConfigPermissions();
    } else {
        std::cerr << "FAILED to create configuration at: " << config_path << std::endl;
    }
    
    return result;
}

bool ConfigManager::ensureConfigDirectory() {
    std::string dir = config_path.substr(0, config_path.find_last_of('/'));
    
    if (dir.empty()) {
        std::cerr << "Invalid config path: " << config_path << std::endl;
        return false;
    }
    
    if (!createDirectoryRecursive(dir)) {
        std::cerr << "Failed to create config directory: " << dir << std::endl;
        return false;
    }
    
    return true;
}

bool ConfigManager::validateConfigPermissions() {
    struct stat st;
    
    if (stat(config_path.c_str(), &st) != 0) {
        std::cerr << "Cannot stat config file: " << strerror(errno) << std::endl;
        return false;
    }
    
    std::cout << "Config file permissions: " << std::oct << (st.st_mode & 0777) << std::dec << std::endl;
    std::cout << "Config file owner: " << st.st_uid << ":" << st.st_gid << std::endl;
    
    if (access(config_path.c_str(), R_OK) != 0) {
        std::cerr << "Config file is not readable" << std::endl;
        return false;
    }
    
    return true;
}

bool ConfigManager::createDirectoryRecursive(const std::string& path) {
    if (path.empty() || path == "/") return true;
    
    struct stat st;
    if (stat(path.c_str(), &st) == 0) {
        if (S_ISDIR(st.st_mode)) {
            if (access(path.c_str(), W_OK) == 0) {
                return true;
            } else {
                std::cerr << "No write permission for directory: " << path << std::endl;
                return false;
            }
        } else {
            std::cerr << "Path exists but is not a directory: " << path << std::endl;
            return false;
        }
    }
    
    std::string parent = path.substr(0, path.find_last_of('/'));
    if (!parent.empty() && !createDirectoryRecursive(parent)) {
        return false;
    }
    
    if (mkdir(path.c_str(), 0755) != 0) {
        if (errno != EEXIST) {
            std::cerr << "Failed to create directory " << path << ": " << strerror(errno) << std::endl;
            return false;
        }
    }
    
    std::cout << "Created directory: " << path << std::endl;
    return true;
}

bool ConfigManager::checkFilePermissions(const std::string& path) {
    if (access(path.c_str(), F_OK) != 0) {
        return false;
    }
    
    if (access(path.c_str(), R_OK) != 0) {
        std::cerr << "No read permission for: " << path << std::endl;
        return false;
    }
    
    return true;
}

std::string ConfigManager::get(const std::string& key, const std::string& default_value) {
    auto it = config.find(key);
    return it != config.end() ? it->second : default_value;
}

void ConfigManager::set(const std::string& key, const std::string& value) {
    config[key] = value;
}

bool ConfigManager::getBool(const std::string& key, bool default_value) {
    std::string value = get(key);
    if (value == "true" || value == "1" || value == "yes") return true;
    if (value == "false" || value == "0" || value == "no") return false;
    return default_value;
}

int ConfigManager::getInt(const std::string& key, int default_value) {
    try {
        return std::stoi(get(key));
    } catch (...) {
        return default_value;
    }
}

double ConfigManager::getDouble(const std::string& key, double default_value) {
    try {
        return std::stod(get(key));
    } catch (...) {
        return default_value;
    }
}

bool ConfigManager::needsReload() {
    return needs_reload || fileModified();
}

void ConfigManager::forceReload() {
    needs_reload = true;
}

void ConfigManager::setDefaults() {
    config = {
        {"LOG_LEVEL", "INFO"},
        {"SWAP_ENABLED", "false"},
        {"SWAP_SIZE_GB", "1"},
        {"OVERHEAD_GB", "0.3"},
        {"ZRAM_ENABLED", "true"},
        {"ZRAM_RATIO", "2.10"},
        {"ZRAM_ALGORITHM", "zstd"},
        {"MAX_COMP_STREAMS", "6"},
        {"SWAPPINESS", "90"},
        {"CACHE_PRESSURE", "45"},
        {"DIRTY_RATIO", "35"},
        {"DIRTY_BACKGROUND_RATIO", "5"},
        {"DYNAMIC_SWAPPINESS", "false"},
        {"EXTRA_TUNING", "false"},
        {"PERFORMANCE_MODE", "false"},
        {"ZRAM_AUTO_TUNE", "false"},
        {"VM_COMPACTION_PROACTIVE", "true"},
        {"VM_PAGE_CLUSTER", "3"},
        {"VM_EXTRA_FREE_KBYTES", "12288"},
        {"VM_DIRTY_EXPIRE_CENTISECS", "3000"},
        {"VM_DIRTY_WRITEBACK_CENTISECS", "500"},
        {"VM_MIN_FREE_KBYTES", "67584"},
        {"VM_WATERMARK_SCALE_FACTOR", "125"},
        {"AI_OPTIMIZER_ENABLED", "true"},
        {"PERFORMANCE_PROFILE", "balanced"},
        {"THERMAL_CONTROL_ENABLED", "true"},
        {"PROCESS_AWARE_OPTIMIZATION", "true"},
        {"CONTEXT_AWARE_OPTIMIZATION", "true"},
        {"HUGEPAGES_ENABLED", "true"},
        {"HUGEPAGES_COUNT", "16"},
        {"HUGEPAGES_SIZE_MB", "2"},
        {"HUGEPAGES_AUTO_MANAGE", "true"}
    };
}

bool ConfigManager::fileModified() {
    struct stat st;
    if (stat(config_path.c_str(), &st) != 0) {
        return false;
    }
    
    auto current_mtime = std::chrono::system_clock::from_time_t(st.st_mtime);
    return current_mtime > last_mod_time;
}

void ConfigManager::parseLine(const std::string& line) {
    std::string trimmed = line;
    
    trimmed.erase(0, trimmed.find_first_not_of(" \t"));
    trimmed.erase(trimmed.find_last_not_of(" \t") + 1);
    
    if (trimmed.empty() || trimmed[0] == '#') return;
    
    size_t pos = trimmed.find('=');
    if (pos != std::string::npos) {
        std::string key = trimmed.substr(0, pos);
        std::string value = trimmed.substr(pos + 1);
        
        key.erase(0, key.find_first_not_of(" \t"));
        key.erase(key.find_last_not_of(" \t") + 1);
        
        value.erase(0, value.find_first_not_of(" \t\""));
        value.erase(value.find_last_not_of(" \t\"") + 1);
        
        if (!key.empty()) {
            config[key] = value;
        }
    }
}

std::vector<std::string> ConfigManager::getConfigStats() {
    std::vector<std::string> stats;
    
    stats.push_back("Configuration Statistics:");
    stats.push_back("Path: " + config_path);
    stats.push_back("Parameters: " + std::to_string(config.size()));
    
    struct stat st;
    if (stat(config_path.c_str(), &st) == 0) {
        char time_buf[80];
        std::strftime(time_buf, sizeof(time_buf), "%Y-%m-%d %H:%M:%S", std::localtime(&st.st_mtime));
        stats.push_back("Last modified: " + std::string(time_buf));
        stats.push_back("Permissions: " + std::to_string(st.st_mode & 0777));
    }
    
    return stats;
}
