#ifndef CTL_METRICS_H
#define CTL_METRICS_H

#include <string>

class CtlMetrics {
public:
    static void showDetailedMetrics();
    static void generateMetricsReport();
    static void showAIStatus();
    static void trainAIModel();
    
private:
    static std::string getMetricsReportPath();
    static void collectMemoryInfo(std::ostream& output);
    static void collectZRAMInfo(std::ostream& output);
    static void collectVMSettings(std::ostream& output);
    static void collectProcessInfo(std::ostream& output);
};

#endif
