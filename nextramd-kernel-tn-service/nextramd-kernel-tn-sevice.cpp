#include <iostream>
#include <fstream>
#include <csignal>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <thread>
#include <atomic>
#include <mutex>

#include "version.h"
#include "kernel_tuner.h"

class KernelTuningService {
private:
    KernelTuner kernel_tuner;
    std::atomic<bool> running{true};
    std::mutex service_mutex;
    
public:
    bool initialize() {
        std::lock_guard<std::mutex> lock(service_mutex);
        
        std::cout << KERNEL_TUNING_SERVICE_NAME << " v" << KERNEL_TUNING_SERVICE_VERSION << " starting..." << std::endl;
        
        if (getuid() != 0) {
            std::cerr << "Error: Service requires root privileges" << std::endl;
            return false;
        }
        
        if (!kernel_tuner.initialize()) {
            std::cerr << "Failed to initialize Kernel Tuner" << std::endl;
            return false;
        }
        
        setupSignalHandlers();
        return true;
    }
    
    void run() {
        if (!kernel_tuner.isInitialized()) {
            std::cerr << "Service not properly initialized" << std::endl;
            return;
        }
        
        kernel_tuner.run();
        
        std::cout << "Kernel tuning service running..." << std::endl;
        
        while (running) {
            std::this_thread::sleep_for(std::chrono::seconds(2));
            
            if (!isServiceHealthy()) {
                std::cerr << "Service health check failed, restarting..." << std::endl;
                restartService();
            }
        }
    }
    
    void stop() {
        std::cout << "Stopping Kernel tuning service..." << std::endl;
        running = false;
        kernel_tuner.stop();
    }
    
private:
    void setupSignalHandlers() {
        struct sigaction sa;
        sa.sa_handler = signalHandler;
        sigemptyset(&sa.sa_mask);
        sa.sa_flags = SA_RESTART;
        
        sigaction(SIGTERM, &sa, nullptr);
        sigaction(SIGHUP, &sa, nullptr);
        sigaction(SIGUSR1, &sa, nullptr);
        sigaction(SIGUSR2, &sa, nullptr);
        sigaction(SIGINT, &sa, nullptr);
        
        signal(SIGPIPE, SIG_IGN);
    }
    
    static void signalHandler(int sig) {
        static std::mutex signal_mutex;
        std::lock_guard<std::mutex> lock(signal_mutex);
        
        switch(sig) {
            case SIGTERM:
            case SIGINT:
                std::cout << "Received shutdown signal" << std::endl;
                getInstance().stop();
                break;
            case SIGHUP:
                std::cout << "Received reload signal" << std::endl;
                getInstance().reloadService();
                break;
            case SIGUSR1:
                std::cout << "Received status request" << std::endl;
                getInstance().showStatus();
                break;
            case SIGUSR2:
                std::cout << "Received memory status request" << std::endl;
                getInstance().showMemoryStatus();
                break;
        }
    }
    
    bool isServiceHealthy() {
        auto stats = kernel_tuner.getStats();
        auto now = std::chrono::steady_clock::now();
        auto time_since_success = std::chrono::duration_cast<std::chrono::minutes>(
            now - stats.last_successful_tuning);
            
        return time_since_success.count() < 10;
    }
    
    void restartService() {
        std::lock_guard<std::mutex> lock(service_mutex);
        stop();
        std::this_thread::sleep_for(std::chrono::seconds(2));
        initialize();
        run();
    }
    
    void reloadService() {
        std::lock_guard<std::mutex> lock(service_mutex);
        kernel_tuner.stop();
        std::this_thread::sleep_for(std::chrono::seconds(1));
        kernel_tuner.initialize();
        kernel_tuner.run();
    }
    
    void showStatus() {
        auto stats = kernel_tuner.getStats();
        std::cout << "=== Service Status ===" << std::endl;
        std::cout << "Successful tunings: " << stats.successful_tunings << std::endl;
        std::cout << "Failed tunings: " << stats.failed_tunings << std::endl;
        std::cout << "Uptime: " << std::chrono::duration_cast<std::chrono::minutes>(
            std::chrono::steady_clock::now() - stats.last_successful_tuning).count() 
                  << " minutes" << std::endl;
    }
    
    void showMemoryStatus() {
        std::cout << "=== Memory Status ===" << std::endl;
        system("free -m && echo \"---\" && cat /proc/meminfo | grep -E 'MemTotal|MemFree|SwapTotal|SwapFree|Dirty|Writeback'");
    }
    
    static KernelTuningService& getInstance() {
        static KernelTuningService instance;
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
    open("/dev/null", O_RDWR);
}

int main(int argc, char* argv[]) {
    if (argc > 1) {
        std::string arg = argv[1];
        if (arg == "--version" || arg == "-v") {
            std::cout << KERNEL_TUNING_SERVICE_NAME << " v" << KERNEL_TUNING_SERVICE_VERSION << std::endl;
            std::cout << "Build: " << KERNEL_TUNING_BUILD_DATE << " " << KERNEL_TUNING_BUILD_TIME << std::endl;
            return 0;
        }
        if (arg == "--help" || arg == "-h") {
            std::cout << "Usage: nextramd-kernel-tn-service [OPTIONS]" << std::endl;
            std::cout << "Options:" << std::endl;
            std::cout << "  -v, --version    Show version information" << std::endl;
            std::cout << "  -h, --help       Show this help message" << std::endl;
            std::cout << "  -f, --foreground Run in foreground" << std::endl;
            std::cout << "  -a, --apply      Apply tuning once and exit" << std::endl;
            return 0;
        }
        if (arg == "--foreground" || arg == "-f") {
            KernelTuningService service;
            if (service.initialize()) {
                service.run();
            }
            return 0;
        }
        if (arg == "--apply" || arg == "-a") {
            KernelTuner tuner;
            if (tuner.initialize()) {
                std::cout << "Applying kernel tuning once..." << std::endl;
                tuner.run();
                std::this_thread::sleep_for(std::chrono::seconds(2));
                tuner.stop();
            }
            return 0;
        }
    }
    
    daemonize();
    
    KernelTuningService service;
    if (!service.initialize()) {
        return EXIT_FAILURE;
    }
    
    service.run();
    return EXIT_SUCCESS;
}
