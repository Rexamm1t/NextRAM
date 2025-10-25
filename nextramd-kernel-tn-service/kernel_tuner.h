#ifndef KERNEL_TUNER_H
#define KERNEL_TUNER_H

#include "kernel_config.h"
#include <string>
#include <thread>
#include <atomic>
#include <unordered_map>
#include <mutex>
#include <vector>

class KernelTuner {
private:
    KernelConfig config;
    std::atomic<bool> running{true};
    std::atomic<bool> initialized{false};
    std::thread monitor_thread;
    std::mutex tuning_mutex;
    
    struct SysFsPath {
        const char* path;
        const char* description;
        int min_value;
        int max_value;
    };
    
    std::unordered_map<std::string, SysFsPath> sysfs_paths = {
        {"swappiness", {"/proc/sys/vm/swappiness", "Swap usage tendency", 0, 200}},
        {"vfs_cache_pressure", {"/proc/sys/vm/vfs_cache_pressure", "VFS cache pressure", 1, 500}},
        {"dirty_ratio", {"/proc/sys/vm/dirty_ratio", "Dirty page ratio", 0, 100}},
        {"dirty_background_ratio", {"/proc/sys/vm/dirty_background_ratio", "Background dirty ratio", 0, 100}},
        {"oom_kill_allocating_task", {"/proc/sys/vm/oom_kill_allocating_task", "OOM kill allocating task", 0, 1}},
        {"overcommit_memory", {"/proc/sys/vm/overcommit_memory", "Memory overcommit", 0, 2}},
        {"laptop_mode", {"/proc/sys/vm/laptop_mode", "Laptop mode", 0, 5}},
        {"page-cluster", {"/proc/sys/vm/page-cluster", "Page cluster", 0, 10}},
        {"extra_free_kbytes", {"/proc/sys/vm/extra_free_kbytes", "Extra free KB", 0, 524288}},
        {"dirty_expire_centisecs", {"/proc/sys/vm/dirty_expire_centisecs", "Dirty expire centisecs", 100, 30000}},
        {"dirty_writeback_centisecs", {"/proc/sys/vm/dirty_writeback_centisecs", "Dirty writeback centisecs", 100, 30000}},
        {"min_free_kbytes", {"/proc/sys/vm/min_free_kbytes", "Min free KB", 1024, 524288}},
        {"watermark_scale_factor", {"/proc/sys/vm/watermark_scale_factor", "Watermark scale factor", 10, 1000}},
        {"compaction_proactive", {"/proc/sys/vm/compaction_proactive", "Compaction proactive", 0, 1}}
    };
    
    struct TuningStats {
        int successful_tunings = 0;
        int failed_tunings = 0;
        std::chrono::steady_clock::time_point last_successful_tuning;
    } stats;
    
public:
    KernelTuner();
    ~KernelTuner();
    
    bool initialize();
    void run();
    void stop();
    bool isInitialized() const { return initialized.load(); }
    TuningStats getStats() const { return stats; }
    
private:
    bool validateSysFsPath(const std::string& path) const;
    bool writeSysFs(const std::string& path, const std::string& value);
    std::string readSysFs(const std::string& path);
    bool setParameter(const std::string& param, const std::string& value);
    bool setParameter(const std::string& param, int value);
    bool validateParameterValue(const std::string& param, int value) const;
    
    void adjustSwappiness();
    void applyKernelTuning();
    void applyPerformanceTuning();
    void applyVMTuning();
    void applyHugePages();
    void applyProcessAwareOptimizations();
    void applyContextAwareOptimizations();
    void applyThermalControl();
    
    size_t getTotalMemory();
    bool isZramActive();
    int calculateDynamicSwappiness();
    void monitorKernelParameters();
    void logCurrentParameters();
    void emergencyStop();
    void backupCurrentParameters();
    void restoreParametersIfNeeded();
};

#endif
