#include "nextram_driver_chpages.h"
#include <fstream>
#include <sstream>
#include <cmath>

PageCache::PageCache() {
    collectMetrics();
}

bool PageCache::optimize(uint32_t pressure) {
    if (!applyPressureSettings(pressure)) return false;
    
    if (pressure >= 70) {
        applyDirtyRatios(5, 10);
        applySwappiness(100);
        applyPageCluster(3);
    } else if (pressure >= 40) {
        applyDirtyRatios(10, 20);
        applySwappiness(80);
        applyPageCluster(2);
    } else {
        applyDirtyRatios(15, 30);
        applySwappiness(60);
        applyPageCluster(1);
    }
    
    collectMetrics();
    return true;
}

bool PageCache::applyPressureSettings(uint32_t pressure) {
    return writeProcfs("/proc/sys/vm/vfs_cache_pressure", std::to_string(pressure));
}

bool PageCache::applyDirtyRatios(uint32_t background_ratio, uint32_t ratio) {
    bool success = true;
    success &= writeProcfs("/proc/sys/vm/dirty_background_ratio", std::to_string(background_ratio));
    success &= writeProcfs("/proc/sys/vm/dirty_ratio", std::to_string(ratio));
    return success;
}

bool PageCache::applySwappiness(uint32_t swappiness) {
    return writeProcfs("/proc/sys/vm/swappiness", std::to_string(swappiness));
}

bool PageCache::applyPageCluster(uint32_t cluster) {
    return writeProcfs("/proc/sys/vm/page-cluster", std::to_string(cluster));
}

bool PageCache::setCachePressure(uint32_t pressure) {
    return applyPressureSettings(pressure);
}

bool PageCache::setDirtyRatios(uint32_t background_ratio, uint32_t ratio) {
    return applyDirtyRatios(background_ratio, ratio);
}

bool PageCache::setSwappiness(uint32_t swappiness) {
    return applySwappiness(swappiness);
}

bool PageCache::enableAggressiveCaching() {
    return optimize(30);
}

bool PageCache::enableConservativeCaching() {
    return optimize(80);
}

void PageCache::collectMetrics() {
    std::ifstream meminfo("/proc/meminfo");
    std::string line;
    
    while (std::getline(meminfo, line)) {
        std::istringstream iss(line);
        std::string key;
        uint64_t value;
        std::string unit;
        
        iss >> key >> value >> unit;
        
        if (key == "Cached:") current_metrics_.cached = value * 1024;
        else if (key == "Dirty:") current_metrics_.dirty = value * 1024;
        else if (key == "Writeback:") current_metrics_.writeback = value * 1024;
        else if (key == "SReclaimable:") current_metrics_.reclaimable = value * 1024;
    }
}

PageCache::CacheMetrics PageCache::getStats() {
    collectMetrics();
    return current_metrics_;
}

float PageCache::getEfficiency() {
    collectMetrics();
    if (current_metrics_.cached == 0) return 0.0f;
    return (float)(current_metrics_.cached - current_metrics_.dirty) / current_metrics_.cached;
}

bool PageCache::writeProcfs(const std::string& path, const std::string& value) {
    std::ofstream file(path);
    if (!file.is_open()) return false;
    file << value;
    return file.good();
}

std::string PageCache::readProcfs(const std::string& path) {
    std::ifstream file(path);
    if (!file.is_open()) return "";
    std::string content;
    std::getline(file, content);
    return content;
}