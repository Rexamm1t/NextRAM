#include "swap_manager.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <chrono>
#include <thread>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mount.h>
#include <sys/syscall.h>

SwapManager::SwapManager() {}

SwapManager::~SwapManager() {
    stop();
}

bool SwapManager::initialize() {
    if (!config.load()) {
        std::cerr << "Failed to load configuration" << std::endl;
        return false;
    }
    
    if (!config.getBool("SWAP_ENABLED", false)) {
        std::cout << "Swap is disabled in configuration" << std::endl;
        return false;
    }
    
    std::cout << "Initializing Swap service..." << std::endl;
    
    if (isSwapActive()) {
        std::cout << "Swap is already active" << std::endl;
        return true;
    }
    
    return true;
}

bool SwapManager::checkExistingSwap() {
    struct stat st_img, st_swapfile;
    
    if (stat(swap_img.c_str(), &st_img) != 0 ||
        stat(swap_file.c_str(), &st_swapfile) != 0) {
        return false;
    }
    
    size_t precise_bytes;
    size_t total_img_bytes;
    if (!calculateSizes(precise_bytes, total_img_bytes)) {
        return false;
    }
    
    if (static_cast<size_t>(st_swapfile.st_size) == precise_bytes) {
        std::cout << "Existing swap file found with correct size" << std::endl;
        return true;
    }
    
    return false;
}

bool SwapManager::calculateSizes(size_t& precise_bytes, size_t& total_img_bytes) {
    double swap_size_gb = config.getDouble("SWAP_SIZE_GB", 1.0);
    double overhead_gb = config.getDouble("OVERHEAD_GB", 0.3);
    
    precise_bytes = static_cast<size_t>(swap_size_gb * 1073741824);
    total_img_bytes = static_cast<size_t>((swap_size_gb + overhead_gb + 0.1) * 1073741824);
    
    return true;
}

bool SwapManager::checkDiskSpace(size_t required_kb) {
    size_t available_kb = getAvailableSpace("/data");
    
    if (available_kb < required_kb) {
        std::cerr << "Insufficient disk space: need " << required_kb 
                  << "KB, have " << available_kb << "KB" << std::endl;
        return false;
    }
    
    return true;
}

size_t SwapManager::getAvailableSpace(const std::string& path) {
    struct statvfs st;
    if (statvfs(path.c_str(), &st) != 0) {
        return 0;
    }
    
    return st.f_bavail * st.f_frsize / 1024;
}

bool SwapManager::createSwapImage(size_t total_img_bytes) {
    std::cout << "Creating swap image: " << (total_img_bytes / 1073741824.0) << "GB" << std::endl;
    
    int fd = open(swap_img.c_str(), O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd == -1) {
        std::cerr << "Failed to create swap image file" << std::endl;
        return false;
    }
    
    bool success = false;
    
    #ifdef __NR_fallocate
    int result = syscall(__NR_fallocate, fd, 0, 0, total_img_bytes);
    if (result == 0) {
        success = true;
    } else {
        std::cout << "Fallocate failed, using fallback method" << std::endl;
    }
    #endif
    
    if (!success) {
        if (ftruncate(fd, total_img_bytes) != 0) {
            std::cerr << "Failed to truncate swap image file" << std::endl;
            close(fd);
            return false;
        }
    }
    
    close(fd);
    return true;
}

bool SwapManager::formatSwapImage() {
    std::string command = "mkfs.ext4 -q -F " + swap_img + " >/dev/null 2>&1";
    if (system(command.c_str()) != 0) {
        std::cerr << "Failed to format swap image" << std::endl;
        return false;
    }
    
    return true;
}

bool SwapManager::mountSwapImage() {
    if (mkdir(swap_mount_dir.c_str(), 0755) != 0 && errno != EEXIST) {
        std::cerr << "Failed to create mount directory" << std::endl;
        return false;
    }
    
    std::string mount_options = "loop,rw,noatime,nodiratime,discard,barrier=0";
    
    if (mount(swap_img.c_str(), swap_mount_dir.c_str(), "ext4", MS_MGC_VAL, mount_options.c_str()) != 0) {
        std::cerr << "Failed to mount swap image" << std::endl;
        return false;
    }
    
    return true;
}

bool SwapManager::createSwapFile(size_t precise_bytes) {
    std::cout << "Creating swap file: " << (precise_bytes / 1073741824.0) << "GB" << std::endl;
    
    int fd = open(swap_file.c_str(), O_CREAT | O_WRONLY | O_TRUNC, 0600);
    if (fd == -1) {
        std::cerr << "Failed to create swap file" << std::endl;
        return false;
    }
    
    bool success = false;
    
    #ifdef __NR_fallocate
    int result = syscall(__NR_fallocate, fd, 0, 0, precise_bytes);
    if (result == 0) {
        success = true;
    }
    #endif
    
    if (!success) {
        if (ftruncate(fd, precise_bytes) != 0) {
            std::cerr << "Failed to truncate swap file" << std::endl;
            close(fd);
            return false;
        }
    }
    
    close(fd);
    return true;
}

bool SwapManager::activateSwap() {
    std::string mkswap_cmd = "mkswap " + swap_file + " >/dev/null 2>&1";
    if (system(mkswap_cmd.c_str()) != 0) {
        std::cerr << "Failed to format swap file" << std::endl;
        return false;
    }
    
    std::string swapon_cmd = "swapon " + swap_file + " -p 10";
    if (system(swapon_cmd.c_str()) != 0) {
        std::cerr << "Failed to activate swap" << std::endl;
        return false;
    }
    
    std::cout << "Swap setup complete" << std::endl;
    return true;
}

void SwapManager::cleanup() {
    system(("swapoff " + swap_file + " 2>/dev/null").c_str());
    system(("umount " + swap_mount_dir + " 2>/dev/null").c_str());
    
    remove(swap_file.c_str());
    remove(swap_img.c_str());
    rmdir(swap_mount_dir.c_str());
}

bool SwapManager::isSwapActive() {
    std::ifstream swaps_file("/proc/swaps");
    if (!swaps_file.is_open()) {
        return false;
    }
    
    std::string line;
    while (std::getline(swaps_file, line)) {
        if (line.find(swap_file) != std::string::npos) {
            return true;
        }
    }
    
    return false;
}

void SwapManager::run() {
    if (checkExistingSwap()) {
        if (mountSwapImage() && activateSwap()) {
            monitor_thread = std::thread(&SwapManager::monitorSwap, this);
            return;
        }
    }
    
    cleanup();
    
    size_t precise_bytes, total_img_bytes;
    if (!calculateSizes(precise_bytes, total_img_bytes)) {
        std::cerr << "Failed to calculate swap sizes" << std::endl;
        return;
    }
    
    size_t required_kb = static_cast<size_t>((total_img_bytes / 1024) * 1.1);
    if (!checkDiskSpace(required_kb)) {
        return;
    }
    
    if (!createSwapImage(total_img_bytes)) {
        return;
    }
    
    if (!formatSwapImage()) {
        cleanup();
        return;
    }
    
    if (!mountSwapImage()) {
        cleanup();
        return;
    }
    
    if (!createSwapFile(precise_bytes)) {
        cleanup();
        return;
    }
    
    if (!activateSwap()) {
        cleanup();
        return;
    }
    
    monitor_thread = std::thread(&SwapManager::monitorSwap, this);
}

void SwapManager::stop() {
    running = false;
    if (monitor_thread.joinable()) {
        monitor_thread.join();
    }
    
    system(("swapoff " + swap_file + " 2>/dev/null").c_str());
    system(("umount " + swap_mount_dir + " 2>/dev/null").c_str());
}

void SwapManager::monitorSwap() {
    while (running) {
        std::this_thread::sleep_for(std::chrono::seconds(30));
        
        if (!isSwapActive()) {
            std::cout << "Swap became inactive, attempting to reactivate..." << std::endl;
            stop();
            std::this_thread::sleep_for(std::chrono::seconds(2));
            
            if (mountSwapImage() && activateSwap()) {
                std::cout << "Swap reactivated successfully" << std::endl;
            } else {
                std::cerr << "Failed to reactivate swap" << std::endl;
                break;
            }
        }
        
        if (config.needsReload()) {
            std::cout << "Configuration changed, reloading swap..." << std::endl;
            config.load();
            
            if (!config.getBool("SWAP_ENABLED", false)) {
                std::cout << "Swap disabled in new configuration, stopping..." << std::endl;
                break;
            }
            
            stop();
            std::this_thread::sleep_for(std::chrono::seconds(2));
            
            if (initialize()) {
                run();
            }
            break;
        }
        
        struct statvfs st;
        if (statvfs("/data", &st) == 0) {
            double free_percent = (static_cast<double>(st.f_bavail) / st.f_blocks) * 100;
            if (free_percent < 5.0) {
                std::cout << "Warning: Low disk space (" << free_percent << "% free)" << std::endl;
            }
        }
    }
}
