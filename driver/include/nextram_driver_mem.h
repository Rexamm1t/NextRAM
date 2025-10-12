#ifndef NEXTRA_MEM_DRIVER_H
#define NEXTRA_MEM_DRIVER_H

#include <cstdint>
#include <string>
#include <vector>
#include <atomic>
#include <mutex>
#include <unordered_map>

enum class ZramAlgorithm {
    LZ4, ZSTD, LZO, LZO_RLE, DEFLATE, LZ4HC
};

struct MemoryStats {
    uint64_t total_ram;
    uint64_t available_ram;
    uint64_t zram_compressed;
    uint64_t zram_original;
    uint32_t swap_usage;
    float compression_ratio;
    uint32_t tlb_misses;
    uint32_t page_faults;
};

struct SystemCapabilities {
    bool zram_supported;
    bool hugepages_supported;
    bool memory_tiering_supported;
    bool hardware_acceleration;
    uint32_t max_comp_streams;
    std::vector<ZramAlgorithm> available_algorithms;
};

class ZRAMOptimizer;
class HugePages;
class PageCache;
class ProfileManager;
class AIOptimizer;
class ThermalManager;
class ProcessAwareOptimizer;
class ContextAwareOptimizer;
class AdvancedMetrics;

class MemoryManager {
private:
    std::atomic<bool> initialized_{false};
    std::mutex config_mutex_;
    MemoryStats current_stats_{};
    SystemCapabilities system_caps_{};
    
    ZRAMOptimizer* zram_optimizer_;
    HugePages* huge_pages_;
    PageCache* page_cache_;
    ProfileManager* profile_manager_;
    AIOptimizer* ai_optimizer_;
    ThermalManager* thermal_manager_;
    ProcessAwareOptimizer* process_optimizer_;
    ContextAwareOptimizer* context_optimizer_;
    AdvancedMetrics* advanced_metrics_;

    void collectRealTimeMetrics();
    void adaptiveTuning();
    bool applyKernelParameters();
    void loadConfiguration();
    void setupNewManagers();
    void loadAppLists();
    std::string get_config(const std::string& key);

public:
    static MemoryManager& getInstance();
    
    bool initialize();
    void shutdown();
    
    bool optimizeMemory();
    MemoryStats getStats();
    SystemCapabilities getCapabilities();
    
    bool configureZRAM(ZramAlgorithm algo, size_t size_mb);
    bool enableAdaptiveCompression(bool enable);
    bool setupHugePages(size_t count, size_t size_mb = 2);
    bool releaseHugePages();
    bool optimizePageCache(uint32_t pressure = 50);
    bool setMemoryTiering(bool enable);
    
    bool setPerformanceProfile(int profile);
    bool enableAIOptimizer(bool enable);
    bool enableThermalControl(bool enable);
    bool enableProcessAwareOptimization(bool enable);
    bool enableContextAwareOptimization(bool enable);
    bool addPerformanceApp(const std::string& app);
    bool removePerformanceApp(const std::string& app);
    bool generateReport(const std::string& filename);
    void onScreenStateChanged(bool screen_on);
    void onAppChanged(const std::string& package);
    
    int getCurrentProfile() const;
    int getCurrentContext() const;

private:
    MemoryManager();
    ~MemoryManager();
    bool probeSystemCapabilities();
    bool setupKernelModules();
};

#endif