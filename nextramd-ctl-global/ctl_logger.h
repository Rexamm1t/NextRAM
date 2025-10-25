#ifndef CTL_LOGGER_H
#define CTL_LOGGER_H

#include <string>

class CtlLogger {
public:
    static void init();
    static void log(const std::string& message);
    static void showLog();
    
private:
    static std::string getLogFilePath();
    static std::string getTimestamp();
};

#endif
