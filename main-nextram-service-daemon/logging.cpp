#include "logging.h"
#include <sstream>
#include <fstream>
#include <iostream>
#include <chrono>
#include <iomanip>
#include <sys/stat.h>

LogLevel Logger::current_level = LogLevel::INFO;

void Logger::init() {
    mkdir("/data/adb/nextram/logs", 0755);
}

void Logger::setLevel(LogLevel level) {
    current_level = level;
}

void Logger::debug(const std::string& message) {
    log(LogLevel::DEBUG, message);
}

void Logger::info(const std::string& message) {
    log(LogLevel::INFO, message);
}

void Logger::warn(const std::string& message) {
    log(LogLevel::WARN, message);
}

void Logger::error(const std::string& message) {
    log(LogLevel::ERROR, message);
}

void Logger::log(LogLevel level, const std::string& message) {
    if (level < current_level) return;
    
    std::string level_str;
    switch (level) {
        case LogLevel::DEBUG: level_str = "DEBUG"; break;
        case LogLevel::INFO: level_str = "INFO"; break;
        case LogLevel::WARN: level_str = "WARN"; break;
        case LogLevel::ERROR: level_str = "ERROR"; break;
    }
    
    std::string log_entry = "[" + getTimestamp() + "] [" + level_str + "] " + message;
    
    std::cout << log_entry << std::endl;
    
    std::ofstream log_file("/data/adb/nextram/logs/main-daemon.log", std::ios_base::app);
    if (log_file.is_open()) {
        log_file << log_entry << std::endl;
        log_file.close();
    }
}

std::string Logger::getTimestamp() {
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    
    std::stringstream ss;
    ss << std::put_time(std::localtime(&time_t), "%Y-%m-%d %H:%M:%S");
    return ss.str();
}
