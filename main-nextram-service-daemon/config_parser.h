#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include <string>
#include <unordered_map>
#include <chrono>
#include <vector>

class ConfigManager {
private:
    std::string config_path;
    std::unordered_map<std::string, std::string> config;
    std::chrono::system_clock::time_point last_mod_time;
    bool needs_reload = false;

public:
    ConfigManager(const std::string& path);
    bool load();
    bool save();
    bool createDefaultConfig();
    bool ensureConfigDirectory();
    bool validateConfigPermissions();
    std::string get(const std::string& key, const std::string& default_value = "");
    void set(const std::string& key, const std::string& value);
    bool getBool(const std::string& key, bool default_value = false);
    int getInt(const std::string& key, int default_value = 0);
    double getDouble(const std::string& key, double default_value = 0.0);
    bool needsReload();
    void forceReload();
    std::vector<std::string> getConfigStats();

private:
    void setDefaults();
    bool fileModified();
    void parseLine(const std::string& line);
    bool createDirectoryRecursive(const std::string& path);
    bool checkFilePermissions(const std::string& path);
};

#endif
