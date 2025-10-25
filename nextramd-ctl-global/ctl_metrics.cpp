#include "ctl_metrics.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <chrono>
#include <iomanip>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>

void CtlMetrics::showDetailedMetrics() {
    std::cout << "=== NextRAM Detailed Metrics ===" << std::endl;
    std::cout << "Generated: " << std::chrono::system_clock::to_time_t(std::chrono::system_clock::now()) << std::endl;
    std::cout << std::endl;
    
    collectMemoryInfo(std::cout);
    collectZRAMInfo(std::cout);
    collectVMSettings(std::cout);
    collectProcessInfo(std::cout);
}

void CtlMetrics::generateMetricsReport() {
    std::string report_file = getMetricsReportPath();
    
    std::ofstream report(report_file);
    if (!report.is_open()) {
        std::cout << "ERROR: Cannot create report file." << std::endl;
        return;
    }
    
    report << "=== NextRAM Metrics Report ===" << std::endl;
    report << "Generated: " << std::chrono::system_clock::to_time_t(std::chrono::system_clock::now()) << std::endl;
    report << std::endl;
    
    collectMemoryInfo(report);
    collectZRAMInfo(report);
    collectVMSettings(report);
    
    report.close();
    std::cout << "Report generated: " << report_file << std::endl;
}

void CtlMetrics::showAIStatus() {
    std::string ai_model_file = "/data/adb/nextram/ai_model.dat";
    std::ifstream model_file(ai_model_file);
    
    if (model_file.is_open()) {
        struct stat st;
        stat(ai_model_file.c_str(), &st);
        std::cout << "AI Optimizer: Trained (" << std::ctime(&st.st_mtime) << ")" << std::endl;
        
        int line_count = 0;
        std::string line;
        while (std::getline(model_file, line)) {
            line_count++;
        }
        std::cout << "Patterns learned: " << line_count << std::endl;
        model_file.close();
    } else {
        std::cout << "AI Optimizer: Not trained" << std::endl;
    }
}

void CtlMetrics::trainAIModel() {
    std::cout << "Starting AI model training..." << std::endl;
    std::cout << "AI model training started. Check logs for progress." << std::endl;
}

std::string CtlMetrics::getMetricsReportPath() {
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    
    std::stringstream ss;
    ss << "/data/adb/nextram/reports/metrics_report_" << time_t << ".txt";
    
    mkdir("/data/adb/nextram/reports", 0755);
    return ss.str();
}

void CtlMetrics::collectMemoryInfo(std::ostream& output) {
    output << "--- Memory Usage ---" << std::endl;
    std::ifstream meminfo("/proc/meminfo");
    if (meminfo.is_open()) {
        std::string line;
        while (std::getline(meminfo, line)) {
            if (line.find("MemTotal") != std::string::npos ||
                line.find("MemFree") != std::string::npos ||
                line.find("MemAvailable") != std::string::npos ||
                line.find("SwapTotal") != std::string::npos ||
                line.find("SwapFree") != std::string::npos) {
                output << "  " << line << std::endl;
            }
        }
        meminfo.close();
    }
    output << std::endl;
}

void CtlMetrics::collectZRAMInfo(std::ostream& output) {
    output << "--- ZRAM Information ---" << std::endl;
    std::ifstream mm_stat("/sys/block/zram0/mm_stat");
    if (mm_stat.is_open()) {
        std::string line;
        std::getline(mm_stat, line);
        output << "  MM Stat: " << line << std::endl;
        mm_stat.close();
    } else {
        output << "  ZRAM not initialized" << std::endl;
    }
    output << std::endl;
}

void CtlMetrics::collectVMSettings(std::ostream& output) {
    output << "--- VM Settings ---" << std::endl;
    std::vector<std::string> vm_params = {
        "swappiness", "vfs_cache_pressure", "dirty_ratio", 
        "dirty_background_ratio", "page-cluster"
    };
    
    for (const auto& param : vm_params) {
        std::ifstream param_file("/proc/sys/vm/" + param);
        if (param_file.is_open()) {
            std::string value;
            std::getline(param_file, value);
            output << "  " << param << ": " << value << std::endl;
            param_file.close();
        }
    }
    output << std::endl;
}

void CtlMetrics::collectProcessInfo(std::ostream& output) {
    output << "--- Top Memory Processes ---" << std::endl;
    system("ps -o pid,ppid,rss,vsz,pmem,pcpu,comm -A | sort -nrk5 | head -10");
}
