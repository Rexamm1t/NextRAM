#ifndef NEXTRA_THERMAL_DRIVER_H
#define NEXTRA_THERMAL_DRIVER_H

#include <atomic>
#include <vector>
#include <string>
#include <thread>

class ThermalManager {
private:
    std::atomic<int> current_temperature_{0};
    std::atomic<int> temperature_threshold_{45};
    std::atomic<bool> monitoring_{false};
    std::thread monitor_thread_;
    
    std::vector<std::string> thermal_zones_;
    
    int readTemperature();
    void continuousMonitoring();
    
public:
    void applyThermalThrottling();
    
public:
    ThermalManager();
    ~ThermalManager();
    
    void startMonitoring();
    void stopMonitoring();
    void setTemperatureThreshold(int threshold);
    
    bool shouldThrottle();
    void applyThermalProfile();
    void adjustForTemperature();
    
    int getCurrentTemperature() const { return current_temperature_; }
};

#endif