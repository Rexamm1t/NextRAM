#include "zram_config.h"
#include <fstream>
#include <sstream>
#include <sys/stat.h>

bool ZramConfig::load() {
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
    last_mod_time = getFileModTime();
    return true;
}

std::string ZramConfig::get(const std::string& key, const std::string& default_value) {
    auto it = config.find(key);
    return it != config.end() ? it->second : default_value;
}

bool ZramConfig::getBool(const std::string& key, bool default_value) {
    std::string value = get(key);
    if (value == "true") return true;
    if (value == "false") return false;
    return default_value;
}

int ZramConfig::getInt(const std::string& key, int default_value) {
    try {
        return std::stoi(get(key));
    } catch (...) {
        return default_value;
    }
}

double ZramConfig::getDouble(const std::string& key, double default_value) {
    try {
        return std::stod(get(key));
    } catch (...) {
        return default_value;
    }
}

void ZramConfig::parseLine(const std::string& line) {
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

std::time_t ZramConfig::getFileModTime() {
    struct stat stat_buf;
    if (stat(config_path.c_str(), &stat_buf) == 0) {
        return stat_buf.st_mtime;
    }
    return 0;
}

bool ZramConfig::needsReload() {
    std::time_t current_mod_time = getFileModTime();
    if (current_mod_time != last_mod_time) {
        return true;
    }
    return false;
}
