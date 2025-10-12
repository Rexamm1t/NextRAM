#include "nextram_driver_zram.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cmath>

#ifdef __ARM_NEON
#include <arm_neon.h>
#endif

ZRAMOptimizer::ZRAMOptimizer() : last_update_(std::chrono::steady_clock::now()) {}

ZRAMOptimizer::~ZRAMOptimizer() {
    stopOptimization();
}

bool ZRAMOptimizer::initialize() {
    if (!writeSysfs("/sys/block/zram0/reset", "1")) {
        return false;
    }
    
    startOptimization();
    return true;
}

void ZRAMOptimizer::startOptimization() {
    running_ = true;
    optimization_thread_ = std::thread(&ZRAMOptimizer::continuousOptimization, this);
    monitoring_thread_ = std::thread(&ZRAMOptimizer::realTimeMonitoring, this);
}

void ZRAMOptimizer::stopOptimization() {
    running_ = false;
    if (optimization_thread_.joinable()) optimization_thread_.join();
    if (monitoring_thread_.joinable()) monitoring_thread_.join();
}

void ZRAMOptimizer::continuousOptimization() {
    while (running_) {
        if (adaptive_mode_) {
            applyOptimalAlgorithm();
        }
        
        std::this_thread::sleep_for(std::chrono::seconds(30));
    }
}

void ZRAMOptimizer::realTimeMonitoring() {
    while (running_) {
        auto current_time = std::chrono::steady_clock::now();
        auto time_diff = std::chrono::duration_cast<std::chrono::seconds>(current_time - last_update_).count();
        
        if (time_diff >= 10) {
            float current_ratio = getCurrentCompressionRatio();
            if (current_ratio < 1.3f && adaptive_mode_) {
                findOptimalAlgorithm();
            }
            last_update_ = current_time;
        }
        
        std::this_thread::sleep_for(std::chrono::seconds(5));
    }
}

bool ZRAMOptimizer::configureZRAMDevice(ZramAlgorithm algo, size_t size_kb) {
    std::string algorithm_str;
    switch (algo) {
        case ZramAlgorithm::LZ4: algorithm_str = "lz4"; break;
        case ZramAlgorithm::ZSTD: algorithm_str = "zstd"; break;
        case ZramAlgorithm::LZO: algorithm_str = "lzo"; break;
        case ZramAlgorithm::LZO_RLE: algorithm_str = "lzo-rle"; break;
        case ZramAlgorithm::DEFLATE: algorithm_str = "deflate"; break;
        case ZramAlgorithm::LZ4HC: algorithm_str = "lz4hc"; break;
    }
    
    if (!writeSysfs("/sys/block/zram0/comp_algorithm", algorithm_str)) {
        return false;
    }
    
    std::string size_str = std::to_string(size_kb) + "K";
    if (!writeSysfs("/sys/block/zram0/disksize", size_str)) {
        return false;
    }
    
    current_algorithm_ = algo;
    
    executeCommand("mkswap /dev/block/zram0");
    executeCommand("swapon /dev/block/zram0 -p 100");
    
    return true;
}

bool ZRAMOptimizer::testAlgorithmPerformance(ZramAlgorithm algo, AlgorithmPerformance& result) {
    AlgorithmPerformance test_result;
    test_result.algorithm = algo;
    
    auto start_time = std::chrono::high_resolution_clock::now();
    
    if (!configureZRAMDevice(algo, 51200)) {
        return false;
    }
    
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
    
    test_result.compression_speed = duration.count();
    
    std::string mm_stat = readSysfs("/sys/block/zram0/mm_stat");
    if (!mm_stat.empty()) {
        uint64_t comp_size, orig_size;
        sscanf(mm_stat.c_str(), "%*u %lu %lu", &comp_size, &orig_size);
        
        if (comp_size > 0 && orig_size > 0) {
            test_result.compression_ratio = (float)orig_size / comp_size;
        }
    }
    
    result = test_result;
    return true;
}

ZramAlgorithm ZRAMOptimizer::findOptimalAlgorithm() {
    AlgorithmPerformance best_performance;
    ZramAlgorithm best_algorithm = ZramAlgorithm::LZ4;
    float best_score = 0.0f;
    
    std::vector<ZramAlgorithm> test_algorithms = {
        ZramAlgorithm::LZ4, ZramAlgorithm::ZSTD, ZramAlgorithm::LZO, 
        ZramAlgorithm::LZ4HC, ZramAlgorithm::DEFLATE
    };
    
    for (auto algo : test_algorithms) {
        AlgorithmPerformance perf;
        if (testAlgorithmPerformance(algo, perf)) {
            float score = (perf.compression_ratio * 0.6f) + (1000000.0f / perf.compression_speed * 0.4f);
            
            if (score > best_score) {
                best_score = score;
                best_algorithm = algo;
                best_performance = perf;
            }
        }
    }
    
    configureZRAMDevice(best_algorithm, 0);
    current_algorithm_ = best_algorithm;
    
    return best_algorithm;
}

void ZRAMOptimizer::applyOptimalAlgorithm() {
    float current_ratio = getCurrentCompressionRatio();
    
    if (current_ratio < 1.5f) {
        findOptimalAlgorithm();
    }
}

float ZRAMOptimizer::getCurrentCompressionRatio() {
    std::string mm_stat = readSysfs("/sys/block/zram0/mm_stat");
    if (mm_stat.empty()) return 0.0f;
    
    uint64_t comp_size, orig_size;
    sscanf(mm_stat.c_str(), "%*u %lu %lu", &comp_size, &orig_size);
    
    if (comp_size == 0) return 0.0f;
    return (float)orig_size / comp_size;
}

uint64_t ZRAMOptimizer::getZRAMUsage() {
    std::string mm_stat = readSysfs("/sys/block/zram0/mm_stat");
    if (mm_stat.empty()) return 0;
    
    uint64_t comp_size;
    sscanf(mm_stat.c_str(), "%*u %lu", &comp_size);
    return comp_size;
}

bool ZRAMOptimizer::setCompressionStreams(uint32_t streams) {
    return writeSysfs("/sys/block/zram0/max_comp_streams", std::to_string(streams));
}

bool ZRAMOptimizer::writeSysfs(const std::string& path, const std::string& value) {
    std::ofstream file(path);
    if (!file.is_open()) return false;
    file << value;
    return file.good();
}

std::string ZRAMOptimizer::readSysfs(const std::string& path) {
    std::ifstream file(path);
    if (!file.is_open()) return "";
    std::string content;
    std::getline(file, content);
    return content;
}

bool ZRAMOptimizer::executeCommand(const std::string& cmd) {
    return system(cmd.c_str()) == 0;
}

ZramAlgorithm ZRAMOptimizer::getCurrentAlgorithm() {
    return current_algorithm_;
}