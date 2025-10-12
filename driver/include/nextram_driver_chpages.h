#ifndef NEXTRA_PAGECACHE_DRIVER_H
#define NEXTRA_PAGECACHE_DRIVER_H

#include <cstdint>
#include <string>

class PageCache {
private:
    struct CacheMetrics {
        uint64_t cached;
        uint64_t dirty;
        uint64_t writeback;
        uint64_t reclaimable;
        uint32_t hit_rate;
        uint32_t miss_rate;
    };
    
    CacheMetrics current_metrics_{};
    
    bool applyPressureSettings(uint32_t pressure);
    bool applyDirtyRatios(uint32_t background_ratio, uint32_t ratio);
    bool applySwappiness(uint32_t swappiness);
    bool applyPageCluster(uint32_t cluster);
    
public:
    PageCache();
    
    bool optimize(uint32_t pressure = 50);
    bool setCachePressure(uint32_t pressure);
    bool setDirtyRatios(uint32_t background_ratio, uint32_t ratio);
    bool setSwappiness(uint32_t swappiness);
    
    bool enableAggressiveCaching();
    bool enableConservativeCaching();
    
    CacheMetrics getStats();
    float getEfficiency();
    
private:
    bool writeProcfs(const std::string& path, const std::string& value);
    std::string readProcfs(const std::string& path);
    void collectMetrics();
};

#endif