#ifndef ZRAM_MANAGER_H
#define ZRAM_MANAGER_H

#include "zram_config.h"
#include <string>
#include <vector>
#include <thread>
#include <atomic>

class ZramManager {
private:
    ZramConfig config;
    std::atomic<bool> running{true};
    std::thread monitor_thread;

    const std::string ZRAM_DEVICE = "/dev/block/zram0";
    const std::string ZRAM_SYSFS = "/sys/block/zram0/";

public:
    ZramManager();
    ~ZramManager();
    
    bool initialize();
    void run();
    void stop();
    
private:
    bool loadKernelModule();
    bool createZramDevice();
    bool testCompressionAlgorithms(std::string& best_algorithm, double& best_ratio);
    bool setupZramAlgorithm(const std::string& algorithm);
    bool setupZramStreams(int streams);
    bool setupZramSize();
    bool activateZram();
    void monitorZram();
    size_t calculateOptimalSize();
    int getOptimalStreams(const std::string& algorithm);
    void optimizeAlgorithmParams(const std::string& algorithm);
    double getCurrentCompressionRatio();
    void logZramStats();
};

#endif
