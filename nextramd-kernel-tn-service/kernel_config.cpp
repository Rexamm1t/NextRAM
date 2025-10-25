#include "kernel_config.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <sys/stat.h>
#include <chrono>
#include <algorithm>
#include <filesystem>
#include <cctype>
#include <vector>

bool KernelConfig::load() {
    std::lock_guard<std::mutex> lock(config_mutex);
    
    struct stat file_stat;
    if (stat(config_path.c_str(), &file_stat) != 0) {
        std::cerr << "Config file not found: " << config_path << std::endl;
        config_loaded = false;
        return false;
    }

    std::ifstream file(config_path);
    if (!file.is_open()) {
        std::cerr << "Failed to open config file: " << config_path << std::endl;
        config_loaded = false;
        return false;
    }
    
    auto old_config = std::move(config);
    config.clear();
    
    std::string line;
    int line_number = 0;
    
    try {
        while (std::getline(file, line)) {
            line_number++;
            parseLine(line);
        }
        
        file.close();
        
        if (!validateConfig()) {
            std::cerr << "Config validation failed, restoring previous config" << std::endl;
            config = std::move(old_config);
            config_loaded = false;
            return false;
        }
        
        config_loaded = true;
        std::cout << "Config loaded successfully, " << config.size() << " parameters" << std::endl;
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "Error loading config at line " << line_number << ": " << e.what() << std::endl;
        config = std::move(old_config);
        config_loaded = false;
        return false;
    }
}

bool KernelConfig::reloadIfNeeded() {
    static auto last_check = std::chrono::steady_clock::now();
    static std::string last_modification;
    
    auto now = std::chrono::steady_clock::now();
    if (std::chrono::duration_cast<std::chrono::seconds>(now - last_check).count() < 5) {
        return false;
    }
    
    last_check = now;
    std::string current_mod = getLastConfigModification();
    
    if (current_mod != last_modification) {
        last_modification = current_mod;
        return load();
    }
    
    return false;
}

std::string KernelConfig::get(const std::string& key, const std::string& default_value) {
    std::lock_guard<std::mutex> lock(config_mutex);
    
    if (!config_loaded) {
        std::cerr << "Warning: Accessing config before loading, key: " << key << std::endl;
        return default_value;
    }
    
    auto it = config.find(key);
    return it != config.end() ? it->second : default_value;
}

bool KernelConfig::getBool(const std::string& key, bool default_value) {
    std::string value = get(key);
    std::string lower_value;
    std::transform(value.begin(), value.end(), std::back_inserter(lower_value), ::tolower);
    
    if (lower_value == "true" || lower_value == "1" || lower_value == "yes") return true;
    if (lower_value == "false" || lower_value == "0" || lower_value == "no") return false;
    
    std::cerr << "Warning: Invalid boolean value for key " << key << ": " << value << std::endl;
    return default_value;
}

int KernelConfig::getInt(const std::string& key, int default_value) {
    std::string value = get(key);
    if (value.empty()) return default_value;
    
    try {
        size_t pos;
        int result = std::stoi(value, &pos);
        
        if (pos != value.length()) {
            throw std::invalid_argument("invalid characters");
        }
        
        return result;
    } catch (const std::exception& e) {
        std::cerr << "Warning: Invalid integer value for key " << key << ": " << value << " - " << e.what() << std::endl;
        return default_value;
    }
}

double KernelConfig::getDouble(const std::string& key, double default_value) {
    std::string value = get(key);
    if (value.empty()) return default_value;
    
    try {
        size_t pos;
        double result = std::stod(value, &pos);
        
        if (pos != value.length()) {
            throw std::invalid_argument("invalid characters");
        }
        
        return result;
    } catch (const std::exception& e) {
        std::cerr << "Warning: Invalid double value for key " << key << ": " << value << " - " << e.what() << std::endl;
        return default_value;
    }
}

void KernelConfig::parseLine(const std::string& line) {
    std::string trimmed_line = line;
    trimmed_line.erase(0, trimmed_line.find_first_not_of(" \t"));
    trimmed_line.erase(trimmed_line.find_last_not_of(" \t") + 1);
    
    if (trimmed_line.empty() || trimmed_line[0] == '#' || trimmed_line[0] == ';') {
        return;
    }
    
    size_t pos = trimmed_line.find('=');
    if (pos != std::string::npos && pos > 0 && pos < trimmed_line.length() - 1) {
        std::string key = trimmed_line.substr(0, pos);
        std::string value = trimmed_line.substr(pos + 1);
        
        key.erase(0, key.find_first_not_of(" \t"));
        key.erase(key.find_last_not_of(" \t") + 1);
        
        value.erase(0, value.find_first_not_of(" \t\"'"));
        value.erase(value.find_last_not_of(" \t\"'") + 1);
        
        if (!key.empty() && key.find_first_of(" \t") == std::string::npos) {
            config[key] = value;
        }
    }
}

bool KernelConfig::validateConfig() const {
    const std::vector<std::string> required_params = {"EXTRA_TUNING"};
    
    for (const auto& param : required_params) {
        if (config.find(param) == config.end()) {
            std::cerr << "Missing required parameter: " << param << std::endl;
            return false;
        }
    }
   
    auto validate_range = [this](const std::string& key, int min_val, int max_val) {
        if (config.find(key) != config.end()) {
            try {
                int value = std::stoi(config.at(key));
                if (value < min_val || value > max_val) {
                    std::cerr << "Parameter " << key << " out of range: " << value 
                              << " (expected " << min_val << "-" << max_val << ")" << std::endl;
                    return false;
                }
            } catch (...) {
                std::cerr << "Invalid numeric value for parameter: " << key << std::endl;
                return false;
            }
        }
        return true;
    };
    
    return validate_range("SWAPPINESS", 0, 200) &&
           validate_range("VM_PAGE_CLUSTER", 0, 10) &&
           validate_range("CACHE_PRESSURE", 1, 500);
}

std::string KernelConfig::getLastConfigModification() const {
    struct stat file_stat;
    if (stat(config_path.c_str(), &file_stat) == 0) {
        return std::to_string(file_stat.st_mtime) + "_" + std::to_string(file_stat.st_size);
    }
    return "";
}
