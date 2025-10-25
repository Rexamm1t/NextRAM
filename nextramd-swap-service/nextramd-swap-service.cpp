#include <iostream>
#include <fstream>
#include <csignal>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "version.h"
#include "swap_manager.h"

class SwapService {
private:
    SwapManager swap_manager;
    volatile bool running = true;
    
public:
    bool initialize() {
        std::cout << SWAP_SERVICE_NAME << " v" << SWAP_SERVICE_VERSION << " starting..." << std::endl;
        
        if (!swap_manager.initialize()) {
            std::cerr << "Failed to initialize Swap manager" << std::endl;
            return false;
        }
        
        setupSignalHandlers();
        return true;
    }
    
    void run() {
        swap_manager.run();
        
        std::cout << "Swap service running..." << std::endl;
        
        while (running) {
            std::this_thread::sleep_for(std::chrono::seconds(5));
        }
    }
    
    void stop() {
        std::cout << "Stopping Swap service..." << std::endl;
        running = false;
        swap_manager.stop();
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
        
        std::signal(SIGUSR1, [](int sig) {
            std::cout << "Received SIGUSR1 - swap status" << std::endl;
            system("free -m");
            system("cat /proc/swaps");
        });
    }
    
    static SwapService& getInstance() {
        static SwapService instance;
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
            std::cout << SWAP_SERVICE_NAME << " v" << SWAP_SERVICE_VERSION << std::endl;
            std::cout << "Build: " << SWAP_BUILD_DATE << " " << SWAP_BUILD_TIME << std::endl;
            return 0;
        }
        if (arg == "--help" || arg == "-h") {
            std::cout << "Usage: nextramd-swap-service [OPTIONS]" << std::endl;
            std::cout << "Options:" << std::endl;
            std::cout << "  -v, --version    Show version information" << std::endl;
            std::cout << "  -h, --help       Show this help message" << std::endl;
            std::cout << "  -f, --foreground Run in foreground" << std::endl;
            return 0;
        }
        if (arg == "--foreground" || arg == "-f") {
            SwapService service;
            if (service.initialize()) {
                service.run();
            }
            return 0;
        }
    }
    
    daemonize();
    
    SwapService service;
    if (!service.initialize()) {
        return EXIT_FAILURE;
    }
    
    service.run();
    return EXIT_SUCCESS;
}
