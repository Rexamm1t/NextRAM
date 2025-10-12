#ifndef NEXTRA_METRICS_DRIVER_H
#define NEXTRA_METRICS_DRIVER_H

#include <vector>
#include <string>
#include <chrono>
#include <fstream>
#include <thread>
#include <atomic>

struct SystemSnapshot {
    std::chrono::system_clock::time_point timestamp;
    uint64_t total_memory;
    uint64_t free_memory;
    uint64_t cached_memory;
    uint64_t zram_compressed;
    uint64_t zram_original;
    uint32_t swap_used;
    uint32_t page_faults;
    uint32_t tlb_misses;
    float compression_ratio;
    int temperature;
    std::string active_context;
};

struct DetailedMetrics {
    uint64_t cache_hit_rate;
    uint64_t tlb_efficiency;
    float memory_latency;
    uint32_t compression_efficiency;
    std::vector<std::pair<std::string, uint64_t>> top_processes;
};

class AdvancedMetrics {
private:
    std::vector<SystemSnapshot> history_;
    std::thread metrics_thread_;
    std::atomic<bool> collecting_{false};
    std::ofstream log_file_;
    
    void continuousCollection();
    SystemSnapshot takeSnapshot();
    DetailedMetrics analyzeSnapshot(const SystemSnapshot& snapshot);
    std::vector<std::pair<std::string, uint64_t>> getTopProcesses();
    
public:
    AdvancedMetrics();
    ~AdvancedMetrics();
    
    void startCollection();
    void stopCollection();
    DetailedMetrics getDetailedMetrics();
    void generateReport(const std::string& filename);
    bool detectMemoryLeaks();
    void logEvent(const std::string& event, const std::string& details);
    
    const std::vector<SystemSnapshot>& getHistory() const { return history_; }
};

#endif