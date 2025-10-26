#include "service_manager.h"
#include "logging.h"
#include <sys/wait.h>
#include <unistd.h>
#include <thread>
#include <sstream>
#include <chrono>
#include <iostream>

ServiceManager::ServiceManager(ConfigManager& cfg) : config(cfg) {
    initializeServices();
}

ServiceManager::~ServiceManager() {
    stopMonitoring();
    stopAll();
}

void ServiceManager::initializeServices() {
    services.clear();
    services = {
        {"zram", ServiceInfo("zram", "/system/bin/nextramd-zram-service", "ZRAM_ENABLED", false, false, false)},
        {"swap", ServiceInfo("swap", "/system/bin/nextramd-swap-service", "SWAP_ENABLED", false, false, false)},
        {"kernel", ServiceInfo("kernel", "/system/bin/nextramd-kernel-tn-service", "EXTRA_TUNING", false, false, false)},
        {"ctl", ServiceInfo("ctl", "/system/bin/nextramd-ctl-global", "", true, true, true)}
    };

    updateServiceStates();
}

void ServiceManager::updateServiceStates() {
    for (auto& [name, service] : services) {
        bool new_should_run = isServiceEnabled(name);
        
        if (service.should_run != new_should_run) {
            Logger::info("Service " + name + " state changed: " + 
                        (service.should_run ? "enabled" : "disabled") + " -> " + 
                        (new_should_run ? "enabled" : "disabled"));
            service.should_run = new_should_run;
        }
        
        service.enabled = service.should_run;
    }
}

bool ServiceManager::isServiceEnabled(const std::string& name) {
    auto it = services.find(name);
    if (it == services.end()) return false;
    
    auto& service = it->second;
    
    if (service.config_key.empty()) {
        return true;
    }
    
    return config.getBool(service.config_key, name == "ctl");
}

void ServiceManager::startAll() {
    Logger::info("Starting enabled services based on configuration");
    
    updateServiceStates();
    
    int started_count = 0;
    int enabled_count = 0;
    for (auto& [name, service] : services) {
        if (service.should_run && service.pid == 0 && !service.is_ctl_service) {
            Logger::info("Starting service: " + name);
            if (startService(name)) {
                started_count++;
                enabled_count++;
            } else {
                Logger::error("Failed to start service: " + name);
            }
        } else if (!service.should_run && !service.is_ctl_service) {
            Logger::info("Skipping disabled service: " + name);
        } else if (service.is_ctl_service) {
            Logger::info("Skipping ctl service (not a daemon): " + name);
        } else if (service.pid > 0) {
            Logger::info("Service already running: " + name + " (PID: " + std::to_string(service.pid) + ")");
            enabled_count++;
        }
    }
    
    Logger::info("Started " + std::to_string(started_count) + " new services, " + 
                std::to_string(enabled_count) + " services enabled total");
    
    if (!monitoring && enabled_count > 0) {
        monitoring = true;
        monitor_thread = std::thread(&ServiceManager::monitorServices, this);
        Logger::info("Service monitoring started for " + std::to_string(enabled_count) + " services");
    } else if (enabled_count == 0) {
        Logger::info("No services enabled, monitoring not started");
    }
}

void ServiceManager::stopAll() {
    Logger::info("Stopping all services");
    
    int stopped_count = 0;
    for (auto& [name, service] : services) {
        if (service.pid > 0 && !service.is_ctl_service) {
            if (stopService(name)) {
                stopped_count++;
            }
        }
    }
    
    Logger::info("Stopped " + std::to_string(stopped_count) + " services");
}

bool ServiceManager::startService(const std::string& name) {
    auto it = services.find(name);
    if (it == services.end()) return false;
    
    auto& service = it->second;
    
    if (!service.should_run) {
        Logger::warn("Cannot start disabled service: " + name);
        return false;
    }
    
    if (service.pid > 0) {
        Logger::warn("Service " + name + " is already running with PID: " + std::to_string(service.pid));
        return true;
    }
    
    pid_t pid = fork();
    if (pid == 0) {
        execl(service.binary_path.c_str(), service.binary_path.c_str(), nullptr);
        
        Logger::error("Failed to execute service binary: " + service.binary_path);
        std::cerr << "Failed to execute: " << service.binary_path << " - " << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    } else if (pid > 0) {
        service.pid = pid;
        service.running = true;
        service.restart_count = 0;
        Logger::info("Started service: " + name + " (PID: " + std::to_string(pid) + ")");
        return true;
    } else {
        Logger::error("Failed to fork for service: " + name + " - " + strerror(errno));
        return false;
    }
}

bool ServiceManager::stopService(const std::string& name) {
    auto it = services.find(name);
    if (it == services.end()) return false;
    
    auto& service = it->second;
    
    if (service.pid > 0) {
        Logger::info("Stopping service: " + name + " (PID: " + std::to_string(service.pid) + ")");
        
        kill(service.pid, SIGTERM);
        
        int status;
        int wait_result = waitpid(service.pid, &status, WNOHANG);
        
        if (wait_result == 0) {
            std::this_thread::sleep_for(std::chrono::seconds(2));
            if (waitpid(service.pid, &status, WNOHANG) == 0) {
                Logger::warn("Service " + name + " not responding to SIGTERM, force killing");
                kill(service.pid, SIGKILL);
                waitpid(service.pid, &status, 0);
            }
        }
        
        service.pid = 0;
        service.running = false;
        Logger::info("Stopped service: " + name);
        return true;
    }
    return false;
}

void ServiceManager::restartAll() {
    Logger::info("Restarting all services");
    stopAll();
    std::this_thread::sleep_for(std::chrono::seconds(2));
    startAll();
}

void ServiceManager::reloadAll() {
    Logger::info("Reloading service configuration");
    
    updateServiceStates();
    
    int changes = 0;
    for (auto& [name, service] : services) {
        if (service.is_ctl_service) continue;
        
        bool is_running = (service.pid > 0);
        bool should_run = service.should_run;
        
        if (should_run && !is_running) {
            Logger::info("Service " + name + " should be running but is not. Starting...");
            if (startService(name)) {
                changes++;
            }
        } else if (!should_run && is_running) {
            Logger::info("Service " + name + " should be stopped but is running. Stopping...");
            if (stopService(name)) {
                changes++;
            }
        }
    }
    
    Logger::info("Applied " + std::to_string(changes) + " service state changes");
}

bool ServiceManager::checkAllRunning() {
    bool all_running = true;
    for (const auto& [name, service] : services) {
        if (service.should_run && service.pid > 0 && !service.is_ctl_service) {
            if (kill(service.pid, 0) != 0) {
                Logger::warn("Service " + name + " (PID: " + std::to_string(service.pid) + ") is not running");
                all_running = false;
            }
        }
    }
    return all_running;
}

void ServiceManager::printStatus() {
    Logger::info("starting service_manager...");
    int running_count = 0;
    int enabled_count = 0;
    
    for (const auto& [name, service] : services) {
        std::string status;
        if (service.pid > 0) {
            if (kill(service.pid, 0) == 0) {
                status = "RUNNING (PID: " + std::to_string(service.pid) + ")";
                running_count++;
            } else {
                status = "ZOMBIE (PID: " + std::to_string(service.pid) + ")";
            }
        } else {
            status = "STOPPED";
        }
        
        std::string config_state = service.should_run ? "ENABLED" : "DISABLED";
        if (service.should_run) enabled_count++;
        
        Logger::info(name + ": " + status + " [Config: " + config_state + "]");
    }
    
    Logger::info("Summary: " + std::to_string(running_count) + "/" + 
                std::to_string(enabled_count) + " services running");
    Logger::info("...done");
}

void ServiceManager::stopMonitoring() {
    monitoring = false;
    if (monitor_thread.joinable()) {
        monitor_thread.join();
    }
}

void ServiceManager::monitorServices() {
    Logger::info("Starting service monitoring");
    
    int monitoring_cycles = 0;
    
    while (monitoring) {
        std::this_thread::sleep_for(std::chrono::seconds(10));
        monitoring_cycles++;
        
        for (auto& [name, service] : services) {
            if (service.is_ctl_service) continue;
            
            if (service.should_run && service.pid > 0) {
                int status;
                pid_t result = waitpid(service.pid, &status, WNOHANG);
                
                if (result != 0) {
                    Logger::warn("Service " + name + " crashed with status " + std::to_string(status));
                    service.restart_count++;
                    
                    if (service.restart_count < 5) {
                        Logger::info("Restarting service " + name + " (attempt " + 
                                   std::to_string(service.restart_count) + "/5)");
                        service.pid = 0;
                        service.running = false;
                        if (startService(name)) {
                            Logger::info("Service " + name + " restarted successfully");
                        } else {
                            Logger::error("Failed to restart service " + name);
                        }
                    } else {
                        Logger::error("Service " + name + " restart limit exceeded (5 attempts), disabling");
                        service.should_run = false;
                        service.enabled = false;
                    }
                } else {
                    service.running = true;
                }
            }
        }
    }
    
    Logger::info("Service monitoring stopped after " + std::to_string(monitoring_cycles) + " cycles");
}

void ServiceManager::executeCtlCommand(const std::vector<std::string>& args) {
    if (args.empty()) {
        Logger::error("No arguments provided for ctl command");
        return;
    }
    
    std::stringstream command;
    command << "/system/bin/nextramd-ctl-global";
    
    for (const auto& arg : args) {
        command << " " << arg;
    }
    
    Logger::info("Executing ctl command: " + command.str());
    
    int result = system(command.str().c_str());
    
    if (result == 0) {
        Logger::info("Ctl command executed successfully");
        
        if (args[0] == "-apply" || args[0] == "-restart" || 
            (args.size() > 1 && (args[0] == "-swap" || args[0] == "-zram" || 
                                args[0] == "-vm" || args[0] == "-tuning"))) {
            Logger::info("Configuration changed, reloading services...");
            reloadAll();
        }
    } else {
        Logger::error("Ctl command failed with code: " + std::to_string(result));
    }
}
