#include "nextram_driver_thermal.h"
#include <fstream>
#include <sstream>
#include <vector>
#include <dirent.h>
#include <thread>
#include <chrono>

ThermalManager::ThermalManager() {
    DIR* dir = opendir("/sys/class/thermal");
    if (dir) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            if (strstr(entry->d_name, "thermal_zone")) {
                std::string zone_path = "/sys/class/thermal/" + std::string(entry->d_name);
                thermal_zones_.push_back(zone_path);
            }
        }
        closedir(dir);
    }
}

ThermalManager::~ThermalManager() {
    stopMonitoring();
}

void ThermalManager::startMonitoring() {
    monitoring_ = true;
    monitor_thread_ = std::thread(&ThermalManager::continuousMonitoring, this);
}

void ThermalManager::stopMonitoring() {
    monitoring_ = false;
    if (monitor_thread_.joinable()) {
        monitor_thread_.join();
    }
}

int ThermalManager::readTemperature() {
    int max_temp = 0;
    for (const auto& zone : thermal_zones_) {
        std::ifstream temp_file(zone + "/temp");
        if (temp_file.good()) {
            int temp;
            temp_file >> temp;
            temp /= 1000;
            if (temp > max_temp) {
                max_temp = temp;
            }
        }
    }
    return max_temp;
}

void ThermalManager::continuousMonitoring() {
    while (monitoring_) {
        current_temperature_ = readTemperature();
        
        if (shouldThrottle()) {
            applyThermalThrottling();
        }
        
        std::this_thread::sleep_for(std::chrono::seconds(10));
    }
}

bool ThermalManager::shouldThrottle() {
    return current_temperature_ > temperature_threshold_;
}

void ThermalManager::applyThermalThrottling() {
    std::ofstream swappiness_file("/proc/sys/vm/swappiness");
    if (swappiness_file.is_open()) {
        swappiness_file << "30";
    }
    
    std::ofstream cache_pressure_file("/proc/sys/vm/vfs_cache_pressure");
    if (cache_pressure_file.is_open()) {
        cache_pressure_file << "100";
    }
}

void ThermalManager::applyThermalProfile() {
    if (current_temperature_ > 70) {
        temperature_threshold_ = 70;
    } else if (current_temperature_ > 50) {
        temperature_threshold_ = 50;
    } else {
        temperature_threshold_ = 45;
    }
}

void ThermalManager::adjustForTemperature() {
    if (current_temperature_ > 60) {
        temperature_threshold_ = 65;
    }
}

void ThermalManager::setTemperatureThreshold(int threshold) {
    temperature_threshold_ = threshold;
}