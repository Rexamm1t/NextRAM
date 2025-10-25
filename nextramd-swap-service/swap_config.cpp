#include "swap_config.h"
#include <fstream>
#include <sstream>
#include <sys/stat.h>
#include <ctime>

bool SwapConfig::load() {
    std::ifstream file(config_path);
    if (!file.is_open()) {
        return false;
    }
    
    config.clear();
    std::string line;
    
    while (std::getline(file, line)) {
        parseLine(line);
    }
    
    file.close();
    return true;
}

std::string SwapConfig::get(const std::string& key, const std::string& default_value) {
    auto it = config.find(key);
    return it != config.end() ? it->second : default_value;
}

bool SwapConfig::getBool(const std::string& key, bool default_value) {
    std::string value = get(key);
    if (value == "true") return true;
    if (value == "false") return false;
    return default_value;
}

bool SwapConfig::needsReload() {
    static time_t last_mod_time = 0;
    struct stat st;
    
    if (stat(config_path.c_str(), &st) != 0) {
        return false;
    }
    
    if (st.st_mtime != last_mod_time) {
        last_mod_time = st.st_mtime;
        return true;
    }
    
    return false;
}

int SwapConfig::getInt(const std::string& key, int default_value) {
    try {
        return std::stoi(get(key));
    } catch (...) {
        return default_value;
    }
}

double SwapConfig::getDouble(const std::string& key, double default_value) {
    try {
        return std::stod(get(key));
    } catch (...) {
        return default_value;
    }
}

void SwapConfig::parseLine(const std::string& line) {
    if (line.empty() || line[0] == '#') return;
    
    size_t pos = line.find('=');
    if (pos != std::string::npos) {
        std::string key = line.substr(0, pos);
        std::string value = line.substr(pos + 1);
        key.erase(0, key.find_first_not_of(" \t"));
        key.erase(key.find_last_not_of(" \t") + 1);
        value.erase(0, value.find_first_not_of(" \t\""));
        value.erase(value.find_last_not_of(" \t\"") + 1);
        
        if (!key.empty()) {
            config[key] = value;
        }
    }
}
