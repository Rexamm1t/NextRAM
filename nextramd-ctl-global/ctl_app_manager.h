#ifndef CTL_APP_MANAGER_H
#define CTL_APP_MANAGER_H

#include "ctl_config.h"
#include <string>
#include <vector>

class CtlAppManager {
private:
    CtlConfig& config;
    
public:
    CtlAppManager(CtlConfig& cfg);
    
    void showPerformanceApps();
    void showBackgroundApps();
    void addPerformanceApp(const std::string& app);
    void removePerformanceApp(const std::string& app);
    void addBackgroundApp(const std::string& app);
    void removeBackgroundApp(const std::string& app);
    
private:
    std::vector<std::string> splitApps(const std::string& apps_str);
    std::string joinApps(const std::vector<std::string>& apps);
    bool appExists(const std::vector<std::string>& apps, const std::string& app);
};

#endif
