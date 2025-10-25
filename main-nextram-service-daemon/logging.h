#ifndef LOGGING_H
#define LOGGING_H

#include <string>
#include <cstring>

enum class LogLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR
};

class Logger {
public:
    static void init();
    static void setLevel(LogLevel level);
    static void debug(const std::string& message);
    static void info(const std::string& message);
    static void warn(const std::string& message);
    static void error(const std::string& message);
    
private:
    static LogLevel current_level;
    static void log(LogLevel level, const std::string& message);
    static std::string getTimestamp();
};

#endif
