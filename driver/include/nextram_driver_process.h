#ifndef NEXTRA_PROCESS_DRIVER_H
#define NEXTRA_PROCESS_DRIVER_H

#include <vector>
#include <string>
#include <unordered_set>

class ProcessAwareOptimizer {
private:
    std::unordered_set<std::string> performance_apps_;
    std::unordered_set<std::string> background_apps_;
    std::string current_foreground_app_;
    
    void loadAppLists();
    std::string getForegroundApp();
    
public:
    ProcessAwareOptimizer();
    
    void addPerformanceApp(const std::string& package);
    void addBackgroundApp(const std::string& package);
    void removePerformanceApp(const std::string& package);
    void removeBackgroundApp(const std::string& package);
    
    bool isPerformanceApp(const std::string& process);
    bool isBackgroundApp(const std::string& process);
    void applyProcessSpecificTweaks(const std::string& process);
    void updateForegroundApp();
    
    const std::unordered_set<std::string>& getPerformanceApps() const { return performance_apps_; }
    const std::unordered_set<std::string>& getBackgroundApps() const { return background_apps_; }
};

#endif