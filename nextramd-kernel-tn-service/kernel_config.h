#ifndef KERNEL_CONFIG_H
#define KERNEL_CONFIG_H

#include <string>
#include <unordered_map>
#include <mutex>
#include <atomic>

class KernelConfig {
private:
    std::string config_path = "/data/adb/nextram/cfg-main.prop";
    std::unordered_map<std::string, std::string> config;
    mutable std::mutex config_mutex;
    std::atomic<bool> config_loaded{false};
    
public:
    bool load();
    bool reloadIfNeeded();
    std::string get(const std::string& key, const std::string& default_value = "");
    bool getBool(const std::string& key, bool default_value = false);
    int getInt(const std::string& key, int default_value = 0);
    double getDouble(const std::string& key, double default_value = 0.0);
    bool isLoaded() const { return config_loaded.load(); }
    
private:
    void parseLine(const std::string& line);
    bool validateConfig() const;
    std::string getLastConfigModification() const;
};

#endif
