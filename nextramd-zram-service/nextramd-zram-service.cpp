#include <iostream>
#include <fstream>
#include <csignal>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "version.h"
#include "zram_manager.h"

class ZramService {
private:
    ZramManager zram_manager;
    volatile bool running = true;
    
public:
    bool initialize() {
        std::cout << ZRAM_SERVICE_NAME << " v" << ZRAM_SERVICE_VERSION << " starting..." << std::endl;
        
        if (!zram_manager.initialize()) {
            std::cerr << "Failed to initialize ZRAM manager" << std::endl;
            return false;
        }
        
        setupSignalHandlers();
        return true;
    }
    
    void run() {
        zram_manager.run();
        
        std::cout << "ZRAM service running..." << std::endl;
        
        while (running) {
            std::this_thread::sleep_for(std::chrono::seconds(5));
        }
    }
    
    void stop() {
        std::cout << "Stopping ZRAM service..." << std::endl;
        running = false;
        zram_manager.stop();
    }
    
private:
    void setupSignalHandlers() {
        std::signal(SIGTERM, [](int sig) {
            std::cout << "Received SIGTERM" << std::endl;
            getInstance().stop();
        });
        
        std::signal(SIGHUP, [](int sig) {
            std::cout << "Received SIGHUP - reloading configuration" << std::endl;
            getInstance().stop();
            std::this_thread::sleep_for(std::chrono::seconds(1));
            if (getInstance().initialize()) {
                getInstance().run();
            }
        });
    }
    
    static ZramService& getInstance() {
        static ZramService instance;
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
    
    open("/dev/null", O_RDONLY);
    open("/dev/null", O_WRONLY);
    open("/dev/null", O_WRONLY);
}

int main(int argc, char* argv[]) {
    if (argc > 1) {
        std::string arg = argv[1];
        if (arg == "--version" || arg == "-v") {
            std::cout << ZRAM_SERVICE_NAME << " v" << ZRAM_SERVICE_VERSION << std::endl;
            std::cout << "Build: " << ZRAM_BUILD_DATE << " " << ZRAM_BUILD_TIME << std::endl;
            return 0;
        }
        if (arg == "--help" || arg == "-h") {
            std::cout << "Usage: nextramd-zram-service [OPTIONS]" << std::endl;
            std::cout << "Options:" << std::endl;
            std::cout << "  -v, --version    Show version information" << std::endl;
            std::cout << "  -h, --help       Show this help message" << std::endl;
            std::cout << "  -f, --foreground Run in foreground" << std::endl;
            return 0;
        }
        if (arg == "--foreground" || arg == "-f") {
            ZramService service;
            if (service.initialize()) {
                service.run();
            }
            return 0;
        }
    }
    
    daemonize();
    
    ZramService service;
    if (!service.initialize()) {
        return EXIT_FAILURE;
    }
    
    service.run();
    return EXIT_SUCCESS;
}
