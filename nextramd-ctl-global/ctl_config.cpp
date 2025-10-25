#include "ctl_config.h"
#include <fstream>
#include <sstream>

bool CtlConfig::load() {
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

bool CtlConfig::save() {
    std::ofstream file(config_path);
    if (!file.is_open()) {
        return false;
    }
    
    for (const auto& [key, value] : config) {
        file << key << "=" << value << std::endl;
    }
    
    file.close();
    return true;
}

std::string CtlConfig::get(const std::string& key, const std::string& default_value) {
    auto it = config.find(key);
    return it != config.end() ? it->second : default_value;
}

void CtlConfig::set(const std::string& key, const std::string& value) {
    config[key] = value;
}

bool CtlConfig::getBool(const std::string& key, bool default_value) {
    std::string value = get(key);
    if (value == "true") return true;
    if (value == "false") return false;
    return default_value;
}

int CtlConfig::getInt(const std::string& key, int default_value) {
    try {
        return std::stoi(get(key));
    } catch (...) {
        return default_value;
    }
}

double CtlConfig::getDouble(const std::string& key, double default_value) {
    try {
        return std::stod(get(key));
    } catch (...) {
        return default_value;
    }
}

void CtlConfig::parseLine(const std::string& line) {
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
