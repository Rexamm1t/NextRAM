#include <iostream>
#include <fstream>
#include <csignal>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <vector>
#include <sstream>
#include <thread>
#include <chrono>

#include "version.h"
#include "config_parser.h"
#include "service_manager.h"
#include "logging.h"

class NextramDaemon {
private:
    ConfigManager config;
    ServiceManager services;
    volatile bool running = true;
    std::string config_path = "/data/adb/nextram/cfg-main.prop";
    
public:
    NextramDaemon() : config(config_path), services(config) {}
    
    bool initialize() {
        if (!initializeSystem()) {
            return false;
        }
        
        Logger::info(std::string(SERVICE_NAME) + " v" + SERVICE_VERSION + " starting...");
        
        if (!initializeConfiguration()) {
            return false;
        }
        
        setupSignalHandlers();
        
        Logger::info("Main daemon initialized successfully");
        logConfigurationSummary();
        
        return true;
    }
    
    void run() {
        Logger::info("Starting all enabled services...");
        services.startAll();
        
        Logger::info("Main daemon monitoring loop started");
        
        int check_counter = 0;
        int status_log_counter = 0;
        
        while (running) {
            std::this_thread::sleep_for(std::chrono::seconds(5));
            
            check_counter++;
            status_log_counter++;
            
            if (check_counter % 6 == 0) {
                if (!services.checkAllRunning()) {
                    Logger::warn("Some services stopped unexpectedly");
                }
                check_counter = 0;
            }
            
            if (status_log_counter % 12 == 0) {
                Logger::info("Daemon monitoring active - services are being watched");
                services.printStatus();
                status_log_counter = 0;
            }
            
            if (config.needsReload()) {
                handleConfigReload();
            }
        }
        
        Logger::info("Main daemon monitoring loop ended");
    }
    
    void shutdown() {
        Logger::info("Shutting down NextRAM daemon");
        running = false;
        services.stopAll();
        Logger::info("NextRAM daemon shutdown complete");
    }
    
    ServiceManager& getServiceManager() {
        return services;
    }
    
    ConfigManager& getConfigManager() {
        return config;
    }
    
private:
    bool initializeSystem() {
        
        if (!createEssentialDirectories()) {
            Logger::error("Failed to create essential directories");
            return false;
        }
        
        Logger::init();
        
        return true;
    }
    
    bool initializeConfiguration() {
        Logger::info("Initializing configuration system...");
        
        if (!config.load()) {
            Logger::error("Critical: Failed to load configuration");
            
            Logger::info("Attempting to create default configuration...");
            if (!config.createDefaultConfig()) {
                Logger::error("CRITICAL: Cannot create configuration file!");
                return false;
            }
            
            Logger::info("Default configuration created, attempting to reload...");
            if (!config.load()) {
                Logger::error("Still cannot load config after creation");
                return false;
            }
        }
        
        Logger::setLevel(static_cast<LogLevel>(config.getInt("LOG_LEVEL", 1)));
        
        Logger::info("Configuration loaded successfully");
        Logger::info("ZRAM_ENABLED: " + config.get("ZRAM_ENABLED", "false"));
        Logger::info("SWAP_ENABLED: " + config.get("SWAP_ENABLED", "false")); 
        Logger::info("EXTRA_TUNING: " + config.get("EXTRA_TUNING", "false"));
        Logger::info("AI_OPTIMIZER_ENABLED: " + config.get("AI_OPTIMIZER_ENABLED", "false"));
        
        auto stats = config.getConfigStats();
        for (const auto& stat : stats) {
            Logger::info(stat);
        }
        
        return true;
    }
    
    bool createEssentialDirectories() {
        const std::vector<std::string> directories = {
            "/data/adb",
            "/data/adb/nextram", 
            "/data/adb/nextram/logs",
            "/data/adb/nextram/cache",
            "/data/adb/nextram/reports"
        };
        
        for (const auto& dir : directories) {
            if (mkdir(dir.c_str(), 0755) != 0 && errno != EEXIST) {
                std::cerr << "Failed to create directory " << dir << ": " << strerror(errno) << std::endl;
                return false;
            }
            
            chmod(dir.c_str(), 0755);
        }
        
        std::cout << "Created essential directory structure" << std::endl;
        return true;
    }
    
    void handleConfigReload() {
        Logger::info("Configuration change detected, reloading...");
        
        if (config.load()) {
            Logger::setLevel(static_cast<LogLevel>(config.getInt("LOG_LEVEL", 1)));
            services.reloadAll();
            
            logConfigurationSummary();
            Logger::info("Configuration reloaded successfully");
        } else {
            Logger::error("Failed to reload configuration");
        }
    }
    
    void logConfigurationSummary() {
        Logger::info("Current configuration: " +
                    std::string("ZRAM=") + config.get("ZRAM_ENABLED") + ", " +
                    std::string("SWAP=") + config.get("SWAP_ENABLED") + ", " +
                    std::string("TUNING=") + config.get("EXTRA_TUNING") + ", " +
                    std::string("AI=") + config.get("AI_OPTIMIZER_ENABLED") + ", " +
                    std::string("PROFILE=") + config.get("PERFORMANCE_PROFILE"));
    }
    
    void setupSignalHandlers() {
        std::signal(SIGTERM, [](int) { 
            Logger::info("Received SIGTERM - graceful shutdown");
            getInstance().shutdown(); 
        });
        
        std::signal(SIGINT, [](int) { 
            Logger::info("Received SIGINT - graceful shutdown");
            getInstance().shutdown(); 
        });
        
        std::signal(SIGHUP, [](int) { 
            Logger::info("Received SIGHUP - reloading configuration");
            getInstance().getConfigManager().forceReload();
        });
        
        std::signal(SIGUSR1, [](int) {
            Logger::info("Received SIGUSR1 - status report");
            getInstance().services.printStatus();
        });
        
        std::signal(SIGUSR2, [](int) {
            Logger::info("Received SIGUSR2 - service restart");
            getInstance().services.restartAll();
        });
    }
    
    static NextramDaemon& getInstance() {
        static NextramDaemon instance;
        return instance;
    }
};

void daemonize() {
    pid_t pid = fork();
    
    if (pid < 0) {
        std::cerr << "Failed to fork daemon" << std::endl;
        exit(EXIT_FAILURE);
    }
    
    if (pid > 0) {
        exit(EXIT_SUCCESS);
    }
    
    umask(0);
    setsid();
    
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);
    
    int null_fd = open("/dev/null", O_RDWR);
    if (null_fd != -1) {
        dup2(null_fd, STDIN_FILENO);
        dup2(null_fd, STDOUT_FILENO);
        dup2(null_fd, STDERR_FILENO);
        close(null_fd);
    }
}

int executeCtlCommand(int argc, char* argv[]) {
    std::vector<std::string> args;
    for (int i = 1; i < argc; i++) {
        args.push_back(argv[i]);
    }
    
    ConfigManager config("/data/adb/nextram/cfg-main.prop");
    if (!config.load()) {
        std::cerr << "Failed to load configuration for ctl command" << std::endl;
        return EXIT_FAILURE;
    }
    
    ServiceManager services(config);
    services.executeCtlCommand(args);
    return EXIT_SUCCESS;
}

void printUsage() {
    std::cout << "Usage: main-nextram-service-daemon [OPTIONS]" << std::endl;
    std::cout << "Options:" << std::endl;
    std::cout << "  -v, --version          Show version information" << std::endl;
    std::cout << "  -h, --help             Show this help message" << std::endl;
    std::cout << "  -f, --foreground       Run in foreground" << std::endl;
    std::cout << "  -s, --status           Show service status and exit" << std::endl;
    std::cout << "  -r, --reload           Reload configuration and restart services" << std::endl;
    std::cout << "  -S, --stop             Stop all services and exit" << std::endl;
    std::cout << "  -c, --create-config    Create default configuration and exit" << std::endl;
    std::cout << "  -i, --info             Show configuration information" << std::endl;
    std::cout << "  <ctl-command>          Execute nextramd-ctl-global command" << std::endl;
}

int main(int argc, char* argv[]) {
    if (argc > 1) {
        std::string arg = argv[1];
        if (arg == "--version" || arg == "-v") {
            std::cout << SERVICE_NAME << " v" << SERVICE_VERSION << std::endl;
            std::cout << "Build: " << BUILD_DATE << " " << BUILD_TIME << std::endl;
            return 0;
        }
        if (arg == "--help" || arg == "-h") {
            printUsage();
            return 0;
        }
        if (arg == "--foreground" || arg == "-f") {
            NextramDaemon daemon;
            if (daemon.initialize()) {
                daemon.run();
            }
            return 0;
        }
        if (arg == "--status" || arg == "-s") {
            ConfigManager config("/data/adb/nextram/cfg-main.prop");
            if (!config.load()) {
                std::cerr << "Failed to load configuration" << std::endl;
                return EXIT_FAILURE;
            }
            ServiceManager services(config);
            services.printStatus();
            return 0;
        }
        if (arg == "--reload" || arg == "-r") {
            NextramDaemon daemon;
            if (daemon.initialize()) {
                daemon.getServiceManager().reloadAll();
            }
            return 0;
        }
        if (arg == "--stop" || arg == "-S") {
            NextramDaemon daemon;
            daemon.getServiceManager().stopAll();
            return 0;
        }
        if (arg == "--create-config" || arg == "-c") {
            ConfigManager config("/data/adb/nextram/cfg-main.prop");
            if (config.createDefaultConfig()) {
                std::cout << "Default configuration created successfully!" << std::endl;
                auto stats = config.getConfigStats();
                for (const auto& stat : stats) {
                    std::cout << stat << std::endl;
                }
                return 0;
            } else {
                std::cerr << "Failed to create configuration!" << std::endl;
                return 1;
            }
        }
        if (arg == "--info" || arg == "-i") {
            ConfigManager config("/data/adb/nextram/cfg-main.prop");
            if (config.load()) {
                auto stats = config.getConfigStats();
                for (const auto& stat : stats) {
                    std::cout << stat << std::endl;
                }
            } else {
                std::cerr << "Cannot load configuration" << std::endl;
            }
            return 0;
        }
        
        return executeCtlCommand(argc, argv);
    }
    
    daemonize();
    
    NextramDaemon daemon;
    if (!daemon.initialize()) {
        return EXIT_FAILURE;
    }
    
    daemon.run();
    return EXIT_SUCCESS;
}
