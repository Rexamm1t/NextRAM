#include "zram_manager.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <chrono>
#include <thread>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <cmath>

ZramManager::ZramManager() {}

ZramManager::~ZramManager() {
    stop();
}

bool ZramManager::initialize() {
    if (!config.load()) {
        std::cerr << "Failed to load configuration" << std::endl;
        return false;
    }
    
    if (!config.getBool("ZRAM_ENABLED", true)) {
        std::cout << "ZRAM is disabled in configuration" << std::endl;
        return false;
    }
    
    std::cout << "Initializing ZRAM service..." << std::endl;
    
    if (!loadKernelModule()) {
        std::cerr << "Failed to load ZRAM kernel module" << std::endl;
        return false;
    }
    
    if (!createZramDevice()) {
        std::cerr << "Failed to create ZRAM device" << std::endl;
        return false;
    }
    
    return true;
}

bool ZramManager::loadKernelModule() {
    if (system("lsmod | grep -q zram") == 0) {
        return true;
    }
    
    if (system("insmod /system/lib/modules/zram.ko 2>/dev/null") == 0 ||
        system("insmod /vendor/lib/modules/zram.ko 2>/dev/null") == 0) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
        return true;
    }
    
    return false;
}

bool ZramManager::createZramDevice() {
    struct stat st;
    if (stat(ZRAM_DEVICE.c_str(), &st) == 0) {
        return true;
    }
    
    if (system("echo 1 > /sys/class/zram-control/hot_add 2>/dev/null") != 0) {
        return false;
    }
    
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
    return stat(ZRAM_DEVICE.c_str(), &st) == 0;
}

bool ZramManager::testCompressionAlgorithms(std::string& best_algorithm, double& best_ratio) {
    std::ifstream alg_file(ZRAM_SYSFS + "comp_algorithm");
    if (!alg_file.is_open()) {
        return false;
    }
    
    std::string available_algs;
    std::getline(alg_file, available_algs);
    alg_file.close();
    
    std::vector<std::string> test_algorithms = {"lz4", "zstd", "lzo", "lzo-rle", "deflate"};
    best_algorithm = "lz4";
    best_ratio = 2.0;
    
    for (const auto& alg : test_algorithms) {
        if (available_algs.find(alg) != std::string::npos) {
            std::cout << "Testing algorithm: " << alg << std::endl;
            
            std::ofstream reset_file(ZRAM_SYSFS + "reset");
            reset_file << "1";
            reset_file.close();
            
            std::ofstream alg_set_file(ZRAM_SYSFS + "comp_algorithm");
            alg_set_file << alg;
            alg_set_file.close();
            
            std::ofstream size_file(ZRAM_SYSFS + "disksize");
            size_file << "50M";
            size_file.close();
            
            system("mkswap /dev/block/zram0 >/dev/null 2>&1");
            system("swapon /dev/block/zram0 >/dev/null 2>&1");
            
            std::ifstream mm_stat_file(ZRAM_SYSFS + "mm_stat");
            if (mm_stat_file.is_open()) {
                std::string line;
                std::getline(mm_stat_file, line);
                std::istringstream iss(line);
                long compr_size, orig_size;
                iss >> compr_size >> compr_size >> orig_size;
                
                if (orig_size > 0) {
                    double ratio = static_cast<double>(orig_size) / compr_size;
                    if (ratio > best_ratio) {
                        best_ratio = ratio;
                        best_algorithm = alg;
                    }
                }
                mm_stat_file.close();
            }
            
            system("swapoff /dev/block/zram0 >/dev/null 2>&1");
        }
    }
    
    std::cout << "Selected algorithm: " << best_algorithm << " (ratio: " << best_ratio << ")" << std::endl;
    return true;
}

bool ZramManager::setupZramAlgorithm(const std::string& algorithm) {
    std::ofstream alg_file(ZRAM_SYSFS + "comp_algorithm");
    if (!alg_file.is_open()) {
        return false;
    }
    
    alg_file << algorithm;
    alg_file.close();
    
    optimizeAlgorithmParams(algorithm);
    return true;
}

void ZramManager::optimizeAlgorithmParams(const std::string& algorithm) {
    if (algorithm == "zstd") {
        system("echo 3 > /proc/sys/vm/page-cluster");
        std::ofstream zstd_level(ZRAM_SYSFS + "zstd_comp_level");
        if (zstd_level.is_open()) {
            zstd_level << "1";
            zstd_level.close();
        }
    } else if (algorithm == "lz4" || algorithm == "lz4hc") {
        system("echo 2 > /proc/sys/vm/page-cluster");
        std::ofstream lz4_level(ZRAM_SYSFS + "lz4hc_comp_level");
        if (lz4_level.is_open()) {
            lz4_level << "9";
            lz4_level.close();
        }
    } else if (algorithm == "deflate") {
        system("echo 1 > /proc/sys/vm/page-cluster");
        std::ofstream deflate_level(ZRAM_SYSFS + "deflate_comp_level");
        if (deflate_level.is_open()) {
            deflate_level << "6";
            deflate_level.close();
        }
    } else {
        system("echo 0 > /proc/sys/vm/page-cluster");
    }
}

bool ZramManager::setupZramStreams(int streams) {
    std::ofstream streams_file(ZRAM_SYSFS + "max_comp_streams");
    if (!streams_file.is_open()) {
        return false;
    }
    
    streams_file << streams;
    streams_file.close();
    return true;
}

int ZramManager::getOptimalStreams(const std::string& algorithm) {
    int cpu_cores = get_nprocs();
    
    if (algorithm == "zstd") {
        return cpu_cores;
    } else if (algorithm == "lz4" || algorithm == "lz4hc") {
        return cpu_cores > 4 ? cpu_cores - 1 : cpu_cores;
    } else {
        return 1;
    }
}

size_t ZramManager::calculateOptimalSize() {
    struct sysinfo info;
    if (sysinfo(&info) != 0) {
        return 0;
    }
    
    size_t total_ram = info.totalram * info.mem_unit / 1024;
    double ratio = config.getDouble("ZRAM_RATIO", 2.0);
    size_t base_size = static_cast<size_t>(total_ram * ratio);
    
    size_t available_ram = info.freeram * info.mem_unit / 1024;
    if (available_ram < total_ram / 4) {
        base_size = base_size * 120 / 100;
    }
    
    size_t max_zram_kb = 4 * 1024 * 1024;
    size_t min_zram_kb = 512 * 1024;
    
    if (base_size > max_zram_kb) base_size = max_zram_kb;
    if (base_size < min_zram_kb) base_size = min_zram_kb;
    
    return base_size;
}

bool ZramManager::setupZramSize() {
    size_t zram_size_kb = calculateOptimalSize();
    
    std::ofstream size_file(ZRAM_SYSFS + "disksize");
    if (!size_file.is_open()) {
        return false;
    }
    
    size_file << zram_size_kb << "K";
    size_file.close();
    
    std::cout << "Set ZRAM size: " << (zram_size_kb / 1024) << "MB" << std::endl;
    return true;
}

bool ZramManager::activateZram() {
    if (system("mkswap /dev/block/zram0 >/dev/null 2>&1") != 0) {
        return false;
    }
    
    if (system("swapon /dev/block/zram0 -p 100 >/dev/null 2>&1") != 0) {
        return false;
    }
    
    std::cout << "ZRAM activated successfully" << std::endl;
    return true;
}

void ZramManager::run() {
    std::string algorithm = config.get("ZRAM_ALGORITHM", "lz4");
    
    if (config.getBool("ZRAM_AUTO_TUNE", false)) {
        double best_ratio;
        if (testCompressionAlgorithms(algorithm, best_ratio)) {
            std::cout << "Auto-tuned algorithm: " << algorithm << std::endl;
        }
    }
    
    std::ofstream reset_file(ZRAM_SYSFS + "reset");
    reset_file << "1";
    reset_file.close();
    
    if (!setupZramAlgorithm(algorithm)) {
        std::cerr << "Failed to setup ZRAM algorithm" << std::endl;
        return;
    }
    
    int streams = config.getInt("MAX_COMP_STREAMS", 0);
    if (streams <= 0) {
        streams = getOptimalStreams(algorithm);
    }
    
    if (!setupZramStreams(streams)) {
        std::cerr << "Failed to setup ZRAM streams" << std::endl;
        return;
    }
    
    if (!setupZramSize()) {
        std::cerr << "Failed to setup ZRAM size" << std::endl;
        return;
    }
    
    if (!activateZram()) {
        std::cerr << "Failed to activate ZRAM" << std::endl;
        return;
    }
    
    logZramStats();
    
    monitor_thread = std::thread(&ZramManager::monitorZram, this);
}

void ZramManager::stop() {
    running = false;
    if (monitor_thread.joinable()) {
        monitor_thread.join();
    }
    
    system("swapoff /dev/block/zram0 2>/dev/null");
    std::ofstream reset_file(ZRAM_SYSFS + "reset");
    reset_file << "1";
    reset_file.close();
}

double ZramManager::getCurrentCompressionRatio() {
    std::ifstream mm_stat_file(ZRAM_SYSFS + "mm_stat");
    if (!mm_stat_file.is_open()) {
        return 0.0;
    }
    
    std::string line;
    std::getline(mm_stat_file, line);
    std::istringstream iss(line);
    long compr_size, orig_size;
    iss >> compr_size >> compr_size >> orig_size;
    mm_stat_file.close();
    
    if (compr_size > 0) {
        return static_cast<double>(orig_size) / compr_size;
    }
    
    return 0.0;
}

void ZramManager::logZramStats() {
    double ratio = getCurrentCompressionRatio();
    std::cout << "Current ZRAM compression ratio: " << ratio << ":1" << std::endl;
    
    std::ifstream mm_stat_file(ZRAM_SYSFS + "mm_stat");
    if (mm_stat_file.is_open()) {
        std::string line;
        std::getline(mm_stat_file, line);
        std::cout << "ZRAM mm_stat: " << line << std::endl;
        mm_stat_file.close();
    }
}

void ZramManager::monitorZram() {
    while (running) {
        std::this_thread::sleep_for(std::chrono::seconds(30));
        
        double ratio = getCurrentCompressionRatio();
        if (ratio > 0 && ratio < 1.5) {
            std::cout << "Warning: Low compression ratio detected: " << ratio << std::endl;
        }
        
        if (config.needsReload()) {
            std::cout << "Configuration changed, reloading ZRAM..." << std::endl;
            config.load();
            stop();
            std::this_thread::sleep_for(std::chrono::seconds(1));
            if (initialize()) {
                run();
            }
            break;
        }
    }
}
