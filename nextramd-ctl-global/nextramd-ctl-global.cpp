#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <sstream>

#include "version.h"
#include "ctl_config.h"
#include "ctl_validator.h"
#include "ctl_logger.h"
#include "ctl_app_manager.h"
#include "ctl_metrics.h"

enum ExitCodes {
    SUCCESS = 0,
    INVALID_ARG = 1,
    MISSING_ARG = 2,
    INVALID_VALUE = 3,
    FILE_MISSING = 4,
    DEPENDENCY_MISSING = 5,
    OPERATION_FAILED = 6
};

class NextramCtl {
private:
    CtlConfig config;
    CtlAppManager app_manager;
    
public:
    NextramCtl() : app_manager(config) {}
    
    int run(int argc, char* argv[]) {
        if (argc < 2) {
            showHelp();
            return SUCCESS;
        }
        
        CtlLogger::init();
        
        if (!config.load()) {
            std::cout << "ERROR: Configuration file not found." << std::endl;
            return FILE_MISSING;
        }
        
        std::string command = argv[1];
        
        if (command == "-status") {
            showStatus();
        } else if (command == "-swap") {
            return handleSwap(argc, argv);
        } else if (command == "-zram") {
            return handleZram(argc, argv);
        } else if (command == "-vm") {
            return handleVM(argc, argv);
        } else if (command == "-tuning") {
            return handleTuning(argc, argv);
        } else if (command == "-dyn") {
            return handleDynamic(argc, argv);
        } else if (command == "-perf") {
            return handlePerformance(argc, argv);
        } else if (command == "-zauto") {
            return handleZramAuto(argc, argv);
        } else if (command == "-ai") {
            return handleAI(argc, argv);
        } else if (command == "-thermal") {
            return handleThermal(argc, argv);
        } else if (command == "-process") {
            return handleProcess(argc, argv);
        } else if (command == "-context") {
            return handleContext(argc, argv);
        } else if (command == "-profile") {
            return handleProfile(argc, argv);
        } else if (command == "-apps") {
            return handleApps(argc, argv);
        } else if (command == "-metrics") {
            CtlMetrics::showDetailedMetrics();
        } else if (command == "-report") {
            CtlMetrics::generateMetricsReport();
        } else if (command == "-log") {
            CtlLogger::showLog();
        } else if (command == "-help") {
            showHelp();
        } else {
            std::cout << "ERROR: Unknown command: " << command << std::endl;
            showHelp();
            return INVALID_ARG;
        }
        
        CtlLogger::log("Command executed: " + std::string(argv[1]));
        return SUCCESS;
    }
    
private:
    void showStatus() {
        std::cout << "    \  |               |     _ \      \      \  |  by " << std::endl;
        std::cout << "     \ |   _ \ \ \  /  __|  |   |    _ \    |\/ |  " << std::endl;
        std::cout << "   |\  |   __/  \  <   |    __ <    ___ \   |   |  @rexamm1t" << std::endl;
        std::cout << "  _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _|  @matrix_5858" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "=== Basic Settings ===" << std::endl;
        std::cout << "Swap: " << (config.getBool("SWAP_ENABLED") ? "Enabled (" + config.get("SWAP_SIZE_GB") + "GB)" : "Disabled") << std::endl;
        std::cout << "Swap Overhead: " << config.get("OVERHEAD_GB") << "GB" << std::endl;
        std::cout << "ZRAM: " << (config.getBool("ZRAM_ENABLED") ? "Enabled (Ratio: " + config.get("ZRAM_RATIO") + ")" : "Disabled") << std::endl;
        std::cout << "ZRAM Algorithm: " << config.get("ZRAM_ALGORITHM") << std::endl;
        std::cout << "Max Compression Streams: " << config.get("MAX_COMP_STREAMS") << std::endl;
        std::cout << "Swappiness: " << config.get("SWAPPINESS") << std::endl;
        std::cout << "Cache Pressure: " << config.get("CACHE_PRESSURE") << std::endl;
        std::cout << "Dirty Ratio: " << config.get("DIRTY_RATIO") << std::endl;
        std::cout << "Dirty Background Ratio: " << config.get("DIRTY_BACKGROUND_RATIO") << std::endl;
        
        std::cout << " " << std::endl;
        std::cout << "=== Advanced Features ===" << std::endl;
        std::cout << "Performance Profile: " << config.get("PERFORMANCE_PROFILE") << std::endl;
        std::cout << "AI Optimizer: " << config.get("AI_OPTIMIZER_ENABLED") << std::endl;
        std::cout << "Thermal Control: " << config.get("THERMAL_CONTROL_ENABLED") << std::endl;
        std::cout << "Process Aware: " << config.get("PROCESS_AWARE_OPTIMIZATION") << std::endl;
        std::cout << "Context Aware: " << config.get("CONTEXT_AWARE_OPTIMIZATION") << std::endl;
        std::cout << "Extra Tuning: " << config.get("EXTRA_TUNING") << std::endl;
        std::cout << "Dynamic Swappiness: " << config.get("DYNAMIC_SWAPPINESS") << std::endl;
        std::cout << "Performance Mode: " << config.get("PERFORMANCE_MODE") << std::endl;
        std::cout << "ZRAM Auto Tune: " << config.get("ZRAM_AUTO_TUNE") << std::endl;
        
        std::cout << " " << std::endl;
        std::cout << "=== System Info ===" << std::endl;
        std::cout << "Config file: /data/adb/nextram/cfg-main.prop" << std::endl;
        std::cout << "Log file: /data/adb/nextram/logs/nextram-ctl.log" << std::endl;
        std::cout << "Reports: /data/adb/nextram/reports" << std::endl;
    }
    
    int handleSwap(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -swap [-on | -off | -size <size> | -over <size>]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("SWAP_ENABLED", "true");
            config.save();
            std::cout << "Swap enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            if (!confirmAction("Disabling swap may affect system performance.")) {
                return SUCCESS;
            }
            config.set("SWAP_ENABLED", "false");
            config.save();
            std::cout << "Swap disabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-size") {
            if (argc < 4) {
                std::cout << "ERROR: Missing size value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateNumber(value)) {
                std::cout << "ERROR: '" << value << "' is not a valid number." << std::endl;
                return INVALID_VALUE;
            }
            config.set("SWAP_SIZE_GB", value);
            config.save();
            std::cout << "Swap size set to " << value << "GB. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-over") {
            if (argc < 4) {
                std::cout << "ERROR: Missing overhead value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateNumber(value)) {
                std::cout << "ERROR: '" << value << "' is not a valid number." << std::endl;
                return INVALID_VALUE;
            }
            config.set("OVERHEAD_GB", value);
            config.save();
            std::cout << "Swap overhead set to " << value << "GB. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -swap: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleZram(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -zram [-on | -off | -alg | -ratio <ratio> | -algo <algo> | -str <streams>]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("ZRAM_ENABLED", "true");
            config.save();
            std::cout << "ZRAM enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            if (!confirmAction("Disabling ZRAM may affect system performance.")) {
                return SUCCESS;
            }
            config.set("ZRAM_ENABLED", "false");
            config.save();
            std::cout << "ZRAM disabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-alg") {
            showAvailableAlgorithms();
        } else if (subcmd == "-ratio") {
            if (argc < 4) {
                std::cout << "ERROR: Missing ratio value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateNumber(value)) {
                std::cout << "ERROR: '" << value << "' is not a valid number." << std::endl;
                return INVALID_VALUE;
            }
            config.set("ZRAM_RATIO", value);
            config.save();
            std::cout << "ZRAM ratio set to " << value << ". Restart device to apply changes." << std::endl;
        } else if (subcmd == "-algo") {
            if (argc < 4) {
                std::cout << "ERROR: Missing algorithm value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateAlgorithm(value)) {
                return INVALID_VALUE;
            }
            config.set("ZRAM_ALGORITHM", value);
            config.save();
            std::cout << "ZRAM algorithm set to " << value << ". Restart device to apply changes." << std::endl;
        } else if (subcmd == "-str") {
            if (argc < 4) {
                std::cout << "ERROR: Missing streams value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateInteger(value)) {
                std::cout << "ERROR: '" << value << "' is not a valid integer." << std::endl;
                return INVALID_VALUE;
            }
            config.set("MAX_COMP_STREAMS", value);
            config.save();
            std::cout << "ZRAM compression streams set to " << value << ". Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -zram: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleVM(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -vm [-swap <value> | -cache <value> | -dirty <value> | -dirtybg <value>]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-swap") {
            if (argc < 4) {
                std::cout << "ERROR: Missing swappiness value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateSwappiness(value)) {
                std::cout << "ERROR: Value must be between 0 and 100." << std::endl;
                return INVALID_VALUE;
            }
            config.set("SWAPPINESS", value);
            config.save();
            std::cout << "Swappiness set to " << value << ". Restart device to apply changes." << std::endl;
        } else if (subcmd == "-cache") {
            if (argc < 4) {
                std::cout << "ERROR: Missing cache pressure value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateNumber(value)) {
                std::cout << "ERROR: '" << value << "' is not a valid number." << std::endl;
                return INVALID_VALUE;
            }
            config.set("CACHE_PRESSURE", value);
            config.save();
            std::cout << "Cache pressure set to " << value << ". Restart device to apply changes." << std::endl;
        } else if (subcmd == "-dirty") {
            if (argc < 4) {
                std::cout << "ERROR: Missing dirty ratio value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateRange(value, 0, 100)) {
                std::cout << "ERROR: Value must be between 0 and 100." << std::endl;
                return INVALID_VALUE;
            }
            config.set("DIRTY_RATIO", value);
            config.save();
            std::cout << "Dirty ratio set to " << value << ". Restart device to apply changes." << std::endl;
        } else if (subcmd == "-dirtybg") {
            if (argc < 4) {
                std::cout << "ERROR: Missing dirty background ratio value" << std::endl;
                return MISSING_ARG;
            }
            std::string value = argv[3];
            if (!CtlValidator::validateRange(value, 0, 100)) {
                std::cout << "ERROR: Value must be between 0 and 100." << std::endl;
                return INVALID_VALUE;
            }
            config.set("DIRTY_BACKGROUND_RATIO", value);
            config.save();
            std::cout << "Dirty background ratio set to " << value << ". Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -vm: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleTuning(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -tuning [-on | -off]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("EXTRA_TUNING", "true");
            config.save();
            std::cout << "Extra tuning enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("EXTRA_TUNING", "false");
            config.save();
            std::cout << "Extra tuning disabled. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -tuning: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleDynamic(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -dyn [-on | -off]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("DYNAMIC_SWAPPINESS", "true");
            config.save();
            std::cout << "Dynamic swappiness enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("DYNAMIC_SWAPPINESS", "false");
            config.save();
            std::cout << "Dynamic swappiness disabled. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -dyn: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handlePerformance(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -perf [-on | -off]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("PERFORMANCE_MODE", "true");
            config.save();
            std::cout << "Performance mode enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("PERFORMANCE_MODE", "false");
            config.save();
            std::cout << "Performance mode disabled. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -perf: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleZramAuto(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -zauto [-on | -off]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("ZRAM_AUTO_TUNE", "true");
            config.save();
            std::cout << "ZRAM auto tuning enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("ZRAM_AUTO_TUNE", "false");
            config.save();
            std::cout << "ZRAM auto tuning disabled. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -zauto: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleAI(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -ai [-on | -off | -status | -train]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("AI_OPTIMIZER_ENABLED", "true");
            config.save();
            std::cout << "AI optimizer enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("AI_OPTIMIZER_ENABLED", "false");
            config.save();
            std::cout << "AI optimizer disabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-status") {
            CtlMetrics::showAIStatus();
        } else if (subcmd == "-train") {
            CtlMetrics::trainAIModel();
        } else {
            std::cout << "ERROR: Invalid argument for -ai: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleThermal(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -thermal [-on | -off]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("THERMAL_CONTROL_ENABLED", "true");
            config.save();
            std::cout << "Thermal control enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("THERMAL_CONTROL_ENABLED", "false");
            config.save();
            std::cout << "Thermal control disabled. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -thermal: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleProcess(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -process [-on | -off]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("PROCESS_AWARE_OPTIMIZATION", "true");
            config.save();
            std::cout << "Process-aware optimization enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("PROCESS_AWARE_OPTIMIZATION", "false");
            config.save();
            std::cout << "Process-aware optimization disabled. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -process: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleContext(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -context [-on | -off]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-on") {
            config.set("CONTEXT_AWARE_OPTIMIZATION", "true");
            config.save();
            std::cout << "Context-aware optimization enabled. Restart device to apply changes." << std::endl;
        } else if (subcmd == "-off") {
            config.set("CONTEXT_AWARE_OPTIMIZATION", "false");
            config.save();
            std::cout << "Context-aware optimization disabled. Restart device to apply changes." << std::endl;
        } else {
            std::cout << "ERROR: Invalid argument for -context: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    int handleProfile(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -profile [-battery | -balanced | -performance | -gaming | -multitask | -auto]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        std::string profile;
        
        if (subcmd == "-battery") {
            profile = "battery";
        } else if (subcmd == "-balanced") {
            profile = "balanced";
        } else if (subcmd == "-performance") {
            profile = "performance";
        } else if (subcmd == "-gaming") {
            profile = "gaming";
        } else if (subcmd == "-multitask") {
            profile = "multitasking";
        } else if (subcmd == "-auto") {
            profile = "auto";
        } else {
            std::cout << "ERROR: Invalid argument for -profile: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        config.set("PERFORMANCE_PROFILE", profile);
        config.save();
        std::cout << "Performance profile set to " << profile << ". Restart device to apply changes." << std::endl;
        
        return SUCCESS;
    }
    
    int handleApps(int argc, char* argv[]) {
        if (argc < 3) {
            std::cout << "ERROR: Usage: nextramd-ctl-global -apps [-perf | -bg | -add | -remove]" << std::endl;
            return INVALID_ARG;
        }
        
        std::string subcmd = argv[2];
        
        if (subcmd == "-perf") {
            app_manager.showPerformanceApps();
        } else if (subcmd == "-bg") {
            app_manager.showBackgroundApps();
        } else if (subcmd == "-add") {
            if (argc < 5) {
                std::cout << "ERROR: Missing app specification" << std::endl;
                return MISSING_ARG;
            }
            std::string type = argv[3];
            std::string app = argv[4];
            
            if (type == "-perf") {
                app_manager.addPerformanceApp(app);
            } else if (type == "-bg") {
                app_manager.addBackgroundApp(app);
            } else {
                std::cout << "ERROR: Invalid app type: " << type << std::endl;
                return INVALID_ARG;
            }
        } else if (subcmd == "-remove") {
            if (argc < 5) {
                std::cout << "ERROR: Missing app specification" << std::endl;
                return MISSING_ARG;
            }
            std::string type = argv[3];
            std::string app = argv[4];
            
            if (type == "-perf") {
                app_manager.removePerformanceApp(app);
            } else if (type == "-bg") {
                app_manager.removeBackgroundApp(app);
            } else {
                std::cout << "ERROR: Invalid app type: " << type << std::endl;
                return INVALID_ARG;
            }
        } else {
            std::cout << "ERROR: Invalid argument for -apps: " << subcmd << std::endl;
            return INVALID_ARG;
        }
        
        return SUCCESS;
    }
    
    void showAvailableAlgorithms() {
        std::string available_algorithms = CtlValidator::getAvailableAlgorithms();
        if (available_algorithms.empty()) {
            std::cout << "ERROR: ZRAM device not available. Cannot check algorithms." << std::endl;
            return;
        }
        
        std::cout << "Available ZRAM compression algorithms:" << std::endl;
        std::string current_alg = config.get("ZRAM_ALGORITHM");
        
        std::istringstream iss(available_algorithms);
        std::string alg;
        while (iss >> alg) {
            if (alg == current_alg) {
                std::cout << "  " << alg << " (current)" << std::endl;
            } else {
                std::cout << "  " << alg << std::endl;
            }
        }
    }
    
    bool confirmAction(const std::string& message) {
        std::cout << "WARNING: " << message << std::endl;
        std::cout << "Are you sure you want to continue? (y/N): ";
        
        std::string response;
        std::getline(std::cin, response);
        
        return response == "y" || response == "Y" || response == "yes" || response == "YES";
    }
    
    void showHelp() {
        std::cout << " " << std::endl;
        std::cout << "    \  |               |     _ \      \      \  |  by " << std::endl;
        std::cout << "     \ |   _ \ \ \  /  __|  |   |    _ \    |\/ |  " << std::endl;
        std::cout << "   |\  |   __/  \  <   |    __ <    ___ \   |   |  @rexamm1t" << std::endl;
        std::cout << "  _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _|  @matrix_5858" << std::endl;
        std::cout << " " << std::endl; 
        std::cout << "                    === NextRAM Commands ===" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "                      --Attention!--" << std::endl;
        std::cout << "The <value> may contain (for example): 1, 3.3, 4.1. or lz4, zstd..." << std::endl;
        std::cout << "All size values are in gigabytes." << std::endl;
        std::cout << "To select the compression algorithm, look at the available ones first)" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "=== Basic Commands ===" << std::endl;
        std::cout << "nextramd-ctl-global -status                          Show current status" << std::endl;
        std::cout << "nextramd-ctl-global -swap -on                        Enable swap" << std::endl;
        std::cout << "nextramd-ctl-global -swap -off                       Disable swap" << std::endl;
        std::cout << "nextramd-ctl-global -swap -size <value>              Set swap size in GB" << std::endl;
        std::cout << "nextramd-ctl-global -swap -over <value>              Set swap overhead in GB" << std::endl;
        std::cout << "nextramd-ctl-global -zram -on                        Enable ZRAM" << std::endl;
        std::cout << "nextramd-ctl-global -zram -off                       Disable ZRAM" << std::endl;
        std::cout << "nextramd-ctl-global -zram -alg                       Show available compression algorithms" << std::endl;
        std::cout << "nextramd-ctl-global -zram -ratio <value>             Set ZRAM ratio" << std::endl;
        std::cout << "nextramd-ctl-global -zram -algo <value>              Set compression algorithm" << std::endl;
        std::cout << "nextramd-ctl-global -zram -str <value>               Set compression streams" << std::endl;
        std::cout << "nextramd-ctl-global -vm -swap <value>                Set swappiness (0-100)" << std::endl;
        std::cout << "nextramd-ctl-global -vm -cache <value>               Set cache pressure" << std::endl;
        std::cout << "nextramd-ctl-global -vm -dirty <value>               Set dirty ratio (0-100)" << std::endl;
        std::cout << "nextramd-ctl-global -vm -dirtybg <value>             Set dirty background ratio (0-100)" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "=== Advanced Features ===" << std::endl;
        std::cout << "nextramd-ctl-global -tuning -on                      Enable extra tuning" << std::endl;
        std::cout << "nextramd-ctl-global -tuning -off                     Disable extra tuning" << std::endl;
        std::cout << "nextramd-ctl-global -dyn -on                         Enable dynamic swappiness" << std::endl;
        std::cout << "nextramd-ctl-global -dyn -off                        Disable dynamic swappiness" << std::endl;
        std::cout << "nextramd-ctl-global -perf -on                        Enable performance mode" << std::endl;
        std::cout << "nextramd-ctl-global -perf -off                       Disable performance mode" << std::endl;
        std::cout << "nextramd-ctl-global -zauto -on                       Enable ZRAM auto tuning" << std::endl;
        std::cout << "nextramd-ctl-global -zauto -off                      Disable ZRAM auto tuning" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "=== AI & Smart Features ===" << std::endl;
        std::cout << "nextramd-ctl-global -ai -on                          Enable AI optimizer" << std::endl;
        std::cout << "nextramd-ctl-global -ai -off                         Disable AI optimizer" << std::endl;
        std::cout << "nextramd-ctl-global -ai -status                      Show AI status" << std::endl;
        std::cout << "nextramd-ctl-global -ai -train                       Train AI model" << std::endl;
        std::cout << "nextramd-ctl-global -thermal -on                     Enable thermal control" << std::endl;
        std::cout << "nextramd-ctl-global -thermal -off                    Disable thermal control" << std::endl;
        std::cout << "nextramd-ctl-global -process -on                     Enable process-aware optimization" << std::endl;
        std::cout << "nextramd-ctl-global -process -off                    Disable process-aware optimization" << std::endl;
        std::cout << "nextramd-ctl-global -context -on                     Enable context-aware optimization" << std::endl;
        std::cout << "nextramd-ctl-global -context -off                    Disable context-aware optimization" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "=== Performance Profiles ===" << std::endl;
        std::cout << "nextramd-ctl-global -profile -battery                Battery saver profile" << std::endl;
        std::cout << "nextramd-ctl-global -profile -balanced               Balanced profile (default)" << std::endl;
        std::cout << "nextramd-ctl-global -profile -performance            Performance profile" << std::endl;
        std::cout << "nextramd-ctl-global -profile -gaming                 Gaming profile" << std::endl;
        std::cout << "nextramd-ctl-global -profile -multitask              Multitasking profile" << std::endl;
        std::cout << "nextramd-ctl-global -profile -auto                   Auto-detect profile" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "=== Application Management ===" << std::endl;
        std::cout << "nextramd-ctl-global -apps -perf                      Show performance apps" << std::endl;
        std::cout << "nextramd-ctl-global -apps -bg                        Show background apps" << std::endl;
        std::cout << "nextramd-ctl-global -apps -add -perf <app>           Add app to performance list" << std::endl;
        std::cout << "nextramd-ctl-global -apps -remove -perf <app>        Remove app from performance list" << std::endl;
        std::cout << "nextramd-ctl-global -apps -add -bg <app>             Add app to background list" << std::endl;
        std::cout << "nextramd-ctl-global -apps -remove -bg <app>          Remove app from background list" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "=== Monitoring & Reports ===" << std::endl;
        std::cout << "nextramd-ctl-global -metrics                         Show detailed metrics" << std::endl;
        std::cout << "nextramd-ctl-global -report                          Generate metrics report" << std::endl;
        std::cout << "nextramd-ctl-global -log                             Show log file" << std::endl;
        std::cout << "nextramd-ctl-global -help                            Show this help" << std::endl;
        std::cout << " " << std::endl;
        std::cout << "    --After each action, you need to restart the device--  " << std::endl;
        std::cout << " " << std::endl;
    }
};

int main(int argc, char* argv[]) {
    if (argc > 1) {
        std::string arg = argv[1];
        if (arg == "--version" || arg == "-v") {
            std::cout << CTL_GLOBAL_NAME << " v" << CTL_GLOBAL_VERSION << std::endl;
            std::cout << "Build: " << CTL_GLOBAL_BUILD_DATE << " " << CTL_GLOBAL_BUILD_TIME << std::endl;
            return SUCCESS;
        }
    }
    
    NextramCtl ctl;
    return ctl.run(argc, argv);
}
