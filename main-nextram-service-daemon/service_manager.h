#ifndef SERVICE_MANAGER_H
#define SERVICE_MANAGER_H

#include "config_parser.h"
#include <vector>
#include <memory>
#include <unordered_map>
#include <thread>
#include <atomic>

struct ServiceInfo {
    std::string name;
    std::string binary_path;
    std::string config_key;
    pid_t pid = 0;
    bool enabled = false;
    bool should_run = false;
    int restart_count = 0;
    bool running = false;
    bool is_ctl_service = false;

    ServiceInfo() = default;
    
    ServiceInfo(std::string n, std::string b, std::string c, bool e, bool s, bool ctl)
        : name(std::move(n)), binary_path(std::move(b)), config_key(std::move(c)), 
          enabled(e), should_run(s), is_ctl_service(ctl) {}
};

class ServiceManager {
private:
    ConfigManager& config;
    std::unordered_map<std::string, ServiceInfo> services;
    std::atomic<bool> monitoring{false};
    std::thread monitor_thread;
    
public:
    ServiceManager(ConfigManager& cfg);
    ~ServiceManager();
    
    bool initialize();
    void startAll();
    void stopAll();
    void restartAll();
    void reloadAll();
    bool checkAllRunning();
    void printStatus();
    void stopMonitoring();
    void executeCtlCommand(const std::vector<std::string>& args);
    
private:
    void initializeServices();
    void updateServiceStates();
    bool startService(const std::string& name);
    bool stopService(const std::string& name);
    void monitorServices();
    bool isServiceEnabled(const std::string& name);
    bool checkBinaryExists(const std::string& path);
};

#endif
