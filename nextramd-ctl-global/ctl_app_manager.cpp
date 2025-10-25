#include "ctl_app_manager.h"
#include <iostream>
#include <sstream>

CtlAppManager::CtlAppManager(CtlConfig& cfg) : config(cfg) {}

void CtlAppManager::showPerformanceApps() {
    std::string apps = config.get("PERFORMANCE_APPS");
    std::cout << "Performance Apps:" << std::endl;
    
    std::vector<std::string> app_list = splitApps(apps);
    if (app_list.empty()) {
        std::cout << "  None configured" << std::endl;
    } else {
        for (const auto& app : app_list) {
            std::cout << "  " << app << std::endl;
        }
    }
}

void CtlAppManager::showBackgroundApps() {
    std::string apps = config.get("BACKGROUND_APPS");
    std::cout << "Background Apps:" << std::endl;
    
    std::vector<std::string> app_list = splitApps(apps);
    if (app_list.empty()) {
        std::cout << "  None configured" << std::endl;
    } else {
        for (const auto& app : app_list) {
            std::cout << "  " << app << std::endl;
        }
    }
}

void CtlAppManager::addPerformanceApp(const std::string& app) {
    std::string current = config.get("PERFORMANCE_APPS");
    std::vector<std::string> app_list = splitApps(current);
    
    if (appExists(app_list, app)) {
        std::cout << "App '" << app << "' is already in performance list." << std::endl;
        return;
    }
    
    app_list.push_back(app);
    config.set("PERFORMANCE_APPS", joinApps(app_list));
    config.save();
    
    std::cout << "Added '" << app << "' to performance apps." << std::endl;
}

void CtlAppManager::removePerformanceApp(const std::string& app) {
    std::string current = config.get("PERFORMANCE_APPS");
    std::vector<std::string> app_list = splitApps(current);
    
    if (app_list.empty()) {
        std::cout << "No performance apps configured." << std::endl;
        return;
    }
    
    std::vector<std::string> new_list;
    for (const auto& a : app_list) {
        if (a != app) {
            new_list.push_back(a);
        }
    }
    
    config.set("PERFORMANCE_APPS", joinApps(new_list));
    config.save();
    
    std::cout << "Removed '" << app << "' from performance apps." << std::endl;
}

void CtlAppManager::addBackgroundApp(const std::string& app) {
    std::string current = config.get("BACKGROUND_APPS");
    std::vector<std::string> app_list = splitApps(current);
    
    if (appExists(app_list, app)) {
        std::cout << "App '" << app << "' is already in background list." << std::endl;
        return;
    }
    
    app_list.push_back(app);
    config.set("BACKGROUND_APPS", joinApps(app_list));
    config.save();
    
    std::cout << "Added '" << app << "' to background apps." << std::endl;
}

void CtlAppManager::removeBackgroundApp(const std::string& app) {
    std::string current = config.get("BACKGROUND_APPS");
    std::vector<std::string> app_list = splitApps(current);
    
    if (app_list.empty()) {
        std::cout << "No background apps configured." << std::endl;
        return;
    }
    
    std::vector<std::string> new_list;
    for (const auto& a : app_list) {
        if (a != app) {
            new_list.push_back(a);
        }
    }
    
    config.set("BACKGROUND_APPS", joinApps(new_list));
    config.save();
    
    std::cout << "Removed '" << app << "' from background apps." << std::endl;
}

std::vector<std::string> CtlAppManager::splitApps(const std::string& apps_str) {
    std::vector<std::string> apps;
    if (apps_str.empty()) {
        return apps;
    }
    
    std::stringstream ss(apps_str);
    std::string app;
    while (std::getline(ss, app, ',')) {
        if (!app.empty()) {
            apps.push_back(app);
        }
    }
    
    return apps;
}

std::string CtlAppManager::joinApps(const std::vector<std::string>& apps) {
    std::stringstream ss;
    for (size_t i = 0; i < apps.size(); i++) {
        if (i > 0) {
            ss << ",";
        }
        ss << apps[i];
    }
    return ss.str();
}

bool CtlAppManager::appExists(const std::vector<std::string>& apps, const std::string& app) {
    for (const auto& a : apps) {
        if (a == app) {
            return true;
        }
    }
    return false;
}
