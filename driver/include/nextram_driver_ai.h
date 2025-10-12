#ifndef NEXTRA_AI_DRIVER_H
#define NEXTRA_AI_DRIVER_H

#include <vector>
#include <chrono>
#include <atomic>
#include <thread>
#include <mutex>

struct MemoryPattern {
    std::chrono::system_clock::time_point timestamp;
    uint64_t memory_usage;
    uint64_t cache_usage;
    uint32_t swappiness;
    float compression_ratio;
    std::string active_app;
};

struct AIPrediction {
    float predicted_memory_usage;
    uint32_t recommended_swappiness;
    std::string recommended_zram_algorithm;
    bool should_enable_hugepages;
};

class AIOptimizer {
private:
    std::vector<MemoryPattern> learned_patterns_;
    std::chrono::steady_clock::time_point last_analysis_;
    std::atomic<bool> training_{false};
    std::thread analysis_thread_;
    std::mutex patterns_mutex_;
    
    void continuousAnalysis();
    void analyzePattern(const MemoryPattern& pattern);
    float calculateSimilarity(const MemoryPattern& a, const MemoryPattern& b);
    
public:
    AIOptimizer();
    ~AIOptimizer();
    
    void startAnalysis();
    void stopAnalysis();
    void addPattern(const MemoryPattern& pattern);
    AIPrediction predictOptimalSettings();
    bool trainModel();
    float calculateOptimalSwappiness();
    std::string recommendZRAMAlgorithm();
    
    bool isTrained() const { return learned_patterns_.size() > 10; }
};

#endif