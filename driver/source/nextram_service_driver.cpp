#include <iostream>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "nextram_driver_mem.h"

std::atomic<bool> shutdown_requested{false};

void signalHandler(int signal) {
    (void)signal;
    shutdown_requested = true;
}

int main(int argc, char** argv) {
    (void)argc;
    (void)argv;
    signal(SIGTERM, signalHandler);
    signal(SIGINT, signalHandler);
    
    auto& memoryManager = MemoryManager::getInstance();
    
    if (!memoryManager.initialize()) {
        return 1;
    }
    
    while (!shutdown_requested) {
        memoryManager.optimizeMemory();
        sleep(5);
    }
    
    memoryManager.shutdown();
    return 0;
}
