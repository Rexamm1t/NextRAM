#include "nextram_driver_metrics.h"
#include <fstream>
#include <sstream>
#include <iomanip>
#include <dirent.h>
#include <thread>
#include <chrono>

AdvancedMetrics::AdvancedMetrics() {
    std::string log_path = "/data/adb/modules/NextRAM/metrics.log";
    log_file_.open(log_path, std::ios::app);
}

AdvancedMetrics::~AdvancedMetrics() {
    stopCollection();
    if (log_file_.is_open()) {
        log_file_.close();
    }
}

void AdvancedMetrics::startCollection() {
    collecting_ = true;
    metrics_thread_ = std::thread(&AdvancedMetrics::continuousCollection, this);
}

void AdvancedMetrics::stopCollection() {
    collecting_ = false;
    if (metrics_thread_.joinable()) {
        metrics_thread_.join();
    }
}

void AdvancedMetrics::continuousCollection() {
    while (collecting_) {
        SystemSnapshot snapshot = takeSnapshot();
        history_.push_back(snapshot);
        
        if (history_.size() > 1000) {
            history_.erase(history_.begin());
        }
        
        std::this_thread::sleep_for(std::chrono::seconds(30));
    }
}

SystemSnapshot AdvancedMetrics::takeSnapshot() {
    SystemSnapshot snapshot;
    snapshot.timestamp = std::chrono::system_clock::now();
    
    std::ifstream meminfo("/proc/meminfo");
    std::string line;
    while (std::getline(meminfo, line)) {
        std::istringstream iss(line);
        std::string key;
        uint64_t value;
        std::string unit;
        
        iss >> key >> value >> unit;
        
        if (key == "MemTotal:") snapshot.total_memory = value * 1024;
        else if (key == "MemFree:") snapshot.free_memory = value * 1024;
        else if (key == "Cached:") snapshot.cached_memory = value * 1024;
        else if (key == "SwapTotal:") snapshot.swap_used = value;
    }
    
    std::ifstream mm_stat("/sys/block/zram0/mm_stat");
    if (mm_stat.good()) {
        uint64_t comp_size, orig_size;
        mm_stat >> orig_size >> comp_size;
        snapshot.zram_compressed = comp_size;
        snapshot.zram_original = orig_size;
        snapshot.compression_ratio = (comp_size > 0) ? (float)orig_size / comp_size : 0.0f;
    }
    
    std::ifstream vmstat("/proc/vmstat");
    while (std::getline(vmstat, line)) {
        if (line.find("pgfault") != std::string::npos) {
            sscanf(line.c_str(), "pgfault %u", &snapshot.page_faults);
        }
        if (line.find("tlb_miss") != std::string::npos) {
            sscanf(line.c_str(), "tlb_miss %u", &snapshot.tlb_misses);
        }
    }
    
    std::ifstream temp_file("/sys/class/thermal/thermal_zone0/temp");
    if (temp_file.good()) {
        int temp;
        temp_file >> temp;
        snapshot.temperature = temp / 1000;
    }
    
    snapshot.active_context = "unknown";
    
    return snapshot;
}

DetailedMetrics AdvancedMetrics::getDetailedMetrics() {
    DetailedMetrics metrics;
    
    if (history_.empty()) {
        return metrics;
    }
    
    const auto& latest = history_.back();
    
    metrics.cache_hit_rate = (latest.cached_memory * 100) / latest.total_memory;
    
    metrics.tlb_efficiency = latest.tlb_misses > 0 ? 
        (latest.page_faults * 100) / latest.tlb_misses : 100;
    
    metrics.memory_latency = (latest.free_memory * 100.0f) / latest.total_memory;
    
    metrics.compression_efficiency = static_cast<uint32_t>(latest.compression_ratio * 100);
    
    metrics.top_processes = getTopProcesses();
    
    return metrics;
}

std::vector<std::pair<std::string, uint64_t>> AdvancedMetrics::getTopProcesses() {
    std::vector<std::pair<std::string, uint64_t>> top_processes;
    
    DIR* proc_dir = opendir("/proc");
    if (!proc_dir) {
        return top_processes;
    }
    
    struct dirent* entry;
    while ((entry = readdir(proc_dir)) != nullptr) {
        if (entry->d_type == DT_DIR && isdigit(entry->d_name[0])) {
            std::string pid = entry->d_name;
            std::string stat_path = "/proc/" + pid + "/stat";
            std::ifstream stat_file(stat_path);
            
            if (stat_file.good()) {
                std::string line;
                std::getline(stat_file, line);
                
                std::istringstream iss(line);
                std::string process_name;
                uint64_t rss;
                
                for (int i = 0; i < 23; ++i) {
                    iss >> process_name;
                }
                iss >> rss;
                
                rss *= 4096;
                
                top_processes.emplace_back(process_name, rss);
            }
        }
    }
    
    closedir(proc_dir);
    
    std::sort(top_processes.begin(), top_processes.end(),
              [](const auto& a, const auto& b) { return a.second > b.second; });
    
    if (top_processes.size() > 10) {
        top_processes.resize(10);
    }
    
    return top_processes;
}

void AdvancedMetrics::generateReport(const std::string& filename) {
    std::ofstream report(filename);
    if (!report.is_open()) {
        return;
    }
    
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    
    report << "=== NextRAM Advanced Metrics Report ===" << std::endl;
    report << "Generated: " << std::ctime(&time_t);
    report << "Total snapshots: " << history_.size() << std::endl;
    report << std::endl;
    
    if (!history_.empty()) {
        const auto& latest = history_.back();
        report << "=== Current System State ===" << std::endl;
        report << "Memory: " << latest.total_memory << " total, " 
               << latest.free_memory << " free, " 
               << latest.cached_memory << " cached" << std::endl;
        report << "ZRAM: " << latest.zram_compressed << " compressed, " 
               << latest.zram_original << " original, ratio: " 
               << latest.compression_ratio << std::endl;
        report << "Page faults: " << latest.page_faults 
               << ", TLB misses: " << latest.tlb_misses << std::endl;
        report << "Temperature: " << latest.temperature << "°C" << std::endl;
        report << std::endl;
    }
    
    report << "=== Top Memory Processes ===" << std::endl;
    auto top_processes = getTopProcesses();
    for (const auto& [name, usage] : top_processes) {
        report << name << ": " << usage << " bytes" << std::endl;
    }
}

bool AdvancedMetrics::detectMemoryLeaks() {
    if (history_.size() < 10) {
        return false;
    }
    
    float avg_free_memory = 0;
    for (const auto& snapshot : history_) {
        avg_free_memory += snapshot.free_memory;
    }
    avg_free_memory /= history_.size();
    
    const auto& latest = history_.back();
    return latest.free_memory < avg_free_memory * 0.8f;
}

void AdvancedMetrics::logEvent(const std::string& event, const std::string& details) {
    if (log_file_.is_open()) {
        auto now = std::chrono::system_clock::now();
        auto time_t = std::chrono::system_clock::to_time_t(now);
        
        log_file_ << std::put_time(std::localtime(&time_t), "%Y-%m-%d %H:%M:%S") 
                  << " - " << event << ": " << details << std::endl;
        log_file_.flush();
    }
}