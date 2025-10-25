#ifndef SWAP_MANAGER_H
#define SWAP_MANAGER_H

#include "swap_config.h"
#include <string>
#include <thread>
#include <atomic>

class SwapManager {
private:
    SwapConfig config;
    std::atomic<bool> running{true};
    std::thread monitor_thread;
    
    std::string swap_img = "/data/adb/nextram/swapfile.img";
    std::string swap_mount_dir = "/data/adb/nextram/swap_mount";
    std::string swap_file = "/data/adb/nextram/swap_mount/swapfile";
    
public:
    SwapManager();
    ~SwapManager();
    
    bool initialize();
    void run();
    void stop();
    
private:
    bool checkExistingSwap();
    bool calculateSizes(size_t& precise_bytes, size_t& total_img_bytes);
    bool checkDiskSpace(size_t required_kb);
    bool createSwapImage(size_t total_img_bytes);
    bool formatSwapImage();
    bool mountSwapImage();
    bool createSwapFile(size_t precise_bytes);
    bool activateSwap();
    void cleanup();
    bool isSwapActive();
    void monitorSwap();
    size_t getAvailableSpace(const std::string& path);
};

#endif
