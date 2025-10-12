#ifndef NEXTRA_ZRAM_DRIVER_H
#define NEXTRA_ZRAM_DRIVER_H

#include "nextram_driver_mem.h"
#include <vector>
#include <thread>
#include <atomic>
#include <chrono>

class ZRAMOptimizer {
private:
    std::atomic<bool> running_{false};
    std::atomic<bool> adaptive_mode_{true};
    std::thread optimization_thread_;
    std::thread monitoring_thread_;
    
    struct AlgorithmPerformance {
        ZramAlgorithm algorithm;
        float compression_ratio;
        uint64_t compression_speed;
        uint64_t decompression_speed;
        uint32_t cpu_usage;
        uint32_t memory_overhead;
    };
    
    std::vector<AlgorithmPerformance> algorithm_stats_;
    std::atomic<ZramAlgorithm> current_algorithm_{ZramAlgorithm::LZ4};
    
    uint64_t last_compressed_size_{0};
    uint64_t last_original_size_{0};
    std::chrono::steady_clock::time_point last_update_;
    
    void continuousOptimization();
    void realTimeMonitoring();
    bool testAlgorithmPerformance(ZramAlgorithm algo, AlgorithmPerformance& result);
    void applyOptimalAlgorithm();
    void hardwareAcceleratedCompression(const void* src, void* dst, size_t size, ZramAlgorithm algo);
    
public:
    ZRAMOptimizer();
    ~ZRAMOptimizer();
    
    bool initialize();
    void startOptimization();
    void stopOptimization();
    
    bool configureZRAMDevice(ZramAlgorithm algo, size_t size_kb);
    bool setCompressionStreams(uint32_t streams);
    ZramAlgorithm findOptimalAlgorithm();
    
    float getCurrentCompressionRatio();
    uint64_t getZRAMUsage();
    ZramAlgorithm getCurrentAlgorithm();
    
    void enableAdaptiveMode(bool enable) { adaptive_mode_ = enable; }
    
private:
    bool writeSysfs(const std::string& path, const std::string& value);
    std::string readSysfs(const std::string& path);
    bool executeCommand(const std::string& cmd);
};

#endif