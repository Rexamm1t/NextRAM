#ifndef CTL_CONFIG_H
#define CTL_CONFIG_H

#include <string>
#include <unordered_map>

class CtlConfig {
private:
    std::string config_path = "/data/adb/nextram/cfg-main.prop";
    std::unordered_map<std::string, std::string> config;
    
public:
    bool load();
    bool save();
    std::string get(const std::string& key, const std::string& default_value = "");
    void set(const std::string& key, const std::string& value);
    bool getBool(const std::string& key, bool default_value = false);
    int getInt(const std::string& key, int default_value = 0);
    double getDouble(const std::string& key, double default_value = 0.0);
    
private:
    void parseLine(const std::string& line);
};

#endif
