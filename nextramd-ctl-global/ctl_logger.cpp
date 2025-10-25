#include "ctl_logger.h"
#include <iostream>
#include <sstream>
#include <fstream>
#include <chrono>
#include <iomanip>
#include <sys/stat.h>
#include <vector>

void CtlLogger::init() {
    mkdir("/data/adb/nextram", 0755);
    mkdir("/data/adb/nextram/logs", 0755);
}

void CtlLogger::log(const std::string& message) {
    std::ofstream log_file(getLogFilePath(), std::ios_base::app);
    if (log_file.is_open()) {
        log_file << "[" << getTimestamp() << "] - " << message << std::endl;
        log_file.close();
    }
}

void CtlLogger::showLog() {
    std::ifstream log_file(getLogFilePath());
    if (!log_file.is_open()) {
        std::cout << "Log file does not exist yet." << std::endl;
        return;
    }
    
    std::cout << "=== Last 100 log entries ===" << std::endl;
    std::string line;
    std::vector<std::string> lines;
    
    while (std::getline(log_file, line)) {
        lines.push_back(line);
    }
    
    int start = lines.size() > 100 ? lines.size() - 100 : 0;
    for (size_t i = start; i < lines.size(); i++) {
        std::cout << lines[i] << std::endl;
    }
    
    log_file.close();
}

std::string CtlLogger::getLogFilePath() {
    return "/data/adb/nextram/logs/nextram-ctl.log";
}

std::string CtlLogger::getTimestamp() {
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    
    std::stringstream ss;
    ss << std::put_time(std::localtime(&time_t), "%Y-%m-%d %H:%M:%S");
    return ss.str();
}
