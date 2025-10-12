#include "nextram_driver_process.h"
#include <fstream>
#include <sstream>

ProcessAwareOptimizer::ProcessAwareOptimizer() {
    loadAppLists();
}

void ProcessAwareOptimizer::loadAppLists() {
    performance_apps_.insert("com.tencent.ig");
    performance_apps_.insert("com.mojang.minecraftpe");
    performance_apps_.insert("com.gameloft.android.ANMP.GloftA8HM");
    
    background_apps_.insert("com.whatsapp");
    background_apps_.insert("com.facebook.katana");
    background_apps_.insert("com.instagram.android");
}

void ProcessAwareOptimizer::addPerformanceApp(const std::string& package) {
    performance_apps_.insert(package);
}

void ProcessAwareOptimizer::addBackgroundApp(const std::string& package) {
    background_apps_.insert(package);
}

void ProcessAwareOptimizer::removePerformanceApp(const std::string& package) {
    performance_apps_.erase(package);
}

void ProcessAwareOptimizer::removeBackgroundApp(const std::string& package) {
    background_apps_.erase(package);
}

bool ProcessAwareOptimizer::isPerformanceApp(const std::string& process) {
    return performance_apps_.find(process) != performance_apps_.end();
}

bool ProcessAwareOptimizer::isBackgroundApp(const std::string& process) {
    return background_apps_.find(process) != background_apps_.end();
}

void ProcessAwareOptimizer::applyProcessSpecificTweaks(const std::string& process) {
    if (isPerformanceApp(process)) {
        std::ofstream swappiness_file("/proc/sys/vm/swappiness");
        if (swappiness_file.is_open()) {
            swappiness_file << "100";
        }
        
        std::ofstream cache_pressure_file("/proc/sys/vm/vfs_cache_pressure");
        if (cache_pressure_file.is_open()) {
            cache_pressure_file << "30";
        }
    } else if (isBackgroundApp(process)) {
        std::ofstream swappiness_file("/proc/sys/vm/swappiness");
        if (swappiness_file.is_open()) {
            swappiness_file << "30";
        }
        
        std::ofstream cache_pressure_file("/proc/sys/vm/vfs_cache_pressure");
        if (cache_pressure_file.is_open()) {
            cache_pressure_file << "100";
        }
    }
}

void ProcessAwareOptimizer::updateForegroundApp() {
    current_foreground_app_ = getForegroundApp();
    if (!current_foreground_app_.empty()) {
        applyProcessSpecificTweaks(current_foreground_app_);
    }
}

std::string ProcessAwareOptimizer::getForegroundApp() {
    std::ifstream cmdline("/proc/self/cmdline");
    if (cmdline.good()) {
        std::string app_name;
        std::getline(cmdline, app_name);
        return app_name;
    }
    
    return "";
}