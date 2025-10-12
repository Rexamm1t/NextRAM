#include "nextram_driver_context.h"
#include <fstream>

ContextAwareOptimizer::ContextAwareOptimizer() 
    : current_context_(Context::UNKNOWN), previous_context_(Context::UNKNOWN) {
}

ContextAwareOptimizer::Context ContextAwareOptimizer::detectCurrentContext() {
    Context screen_state = detectScreenState();
    Context app_context = detectAppContext();
    Context user_activity = detectUserActivity();
    
    if (screen_state == Context::SCREEN_OFF) {
        current_context_ = Context::SCREEN_OFF;
    } else if (app_context == Context::GAMING) {
        current_context_ = Context::GAMING;
    } else if (app_context == Context::VIDEO_PLAYBACK) {
        current_context_ = Context::VIDEO_PLAYBACK;
    } else if (user_activity == Context::FILE_TRANSFER) {
        current_context_ = Context::FILE_TRANSFER;
    } else {
        current_context_ = Context::BROWSING;
    }
    
    if (current_context_ != previous_context_) {
        applyContextOptimizations(current_context_);
        previous_context_ = current_context_;
    }
    
    return current_context_;
}

ContextAwareOptimizer::Context ContextAwareOptimizer::detectScreenState() {
    std::ifstream wake_lock("/sys/power/wake_lock");
    std::ifstream wake_unlock("/sys/power/wake_unlock");
    
    if (wake_lock.good() && wake_unlock.good()) {
        std::string lock_content, unlock_content;
        std::getline(wake_lock, lock_content);
        std::getline(wake_unlock, unlock_content);
        
        if (!lock_content.empty() && lock_content != unlock_content) {
            return Context::SCREEN_ON;
        }
    }
    
    return Context::SCREEN_OFF;
}

ContextAwareOptimizer::Context ContextAwareOptimizer::detectAppContext() {
    std::ifstream proc_dir("/proc/");
    if (!proc_dir.good()) {
        return Context::UNKNOWN;
    }
    
    std::ifstream processes("/proc/loadavg");
    if (processes.good()) {
        float load1, load5, load15;
        processes >> load1 >> load5 >> load15;
        
        if (load1 > 2.0f) {
            return Context::GAMING;
        }
    }
    
    return Context::BROWSING;
}

ContextAwareOptimizer::Context ContextAwareOptimizer::detectUserActivity() {
    std::ifstream vmstat("/proc/vmstat");
    if (vmstat.good()) {
        std::string line;
        uint64_t pgpgin = 0, pgpgout = 0;
        
        while (std::getline(vmstat, line)) {
            if (line.find("pgpgin") != std::string::npos) {
                sscanf(line.c_str(), "pgpgin %lu", &pgpgin);
            } else if (line.find("pgpgout") != std::string::npos) {
                sscanf(line.c_str(), "pgpgout %lu", &pgpgout);
            }
        }
        
        if (pgpgin > 1000 || pgpgout > 1000) {
            return Context::FILE_TRANSFER;
        }
    }
    
    return Context::BROWSING;
}

void ContextAwareOptimizer::applyContextOptimizations(Context context) {
    switch (context) {
        case Context::SCREEN_OFF:
            writeToProcfs("/proc/sys/vm/swappiness", "20");
            writeToProcfs("/proc/sys/vm/vfs_cache_pressure", "50");
            writeToProcfs("/proc/sys/vm/dirty_ratio", "10");
            writeToProcfs("/proc/sys/vm/dirty_background_ratio", "5");
            break;
            
        case Context::GAMING:
            writeToProcfs("/proc/sys/vm/swappiness", "100");
            writeToProcfs("/proc/sys/vm/vfs_cache_pressure", "30");
            writeToProcfs("/proc/sys/vm/dirty_ratio", "30");
            writeToProcfs("/proc/sys/vm/dirty_background_ratio", "15");
            break;
            
        case Context::VIDEO_PLAYBACK:
            writeToProcfs("/proc/sys/vm/swappiness", "40");
            writeToProcfs("/proc/sys/vm/vfs_cache_pressure", "60");
            writeToProcfs("/proc/sys/vm/dirty_ratio", "20");
            writeToProcfs("/proc/sys/vm/dirty_background_ratio", "10");
            break;
            
        case Context::FILE_TRANSFER:
            writeToProcfs("/proc/sys/vm/swappiness", "60");
            writeToProcfs("/proc/sys/vm/vfs_cache_pressure", "80");
            writeToProcfs("/proc/sys/vm/dirty_ratio", "40");
            writeToProcfs("/proc/sys/vm/dirty_background_ratio", "20");
            break;
            
        case Context::BROWSING:
        default:
            writeToProcfs("/proc/sys/vm/swappiness", "60");
            writeToProcfs("/proc/sys/vm/vfs_cache_pressure", "50");
            writeToProcfs("/proc/sys/vm/dirty_ratio", "20");
            writeToProcfs("/proc/sys/vm/dirty_background_ratio", "10");
            break;
    }
}

void ContextAwareOptimizer::onScreenStateChanged(bool screen_on) {
    if (screen_on) {
        current_context_ = Context::SCREEN_ON;
    } else {
        current_context_ = Context::SCREEN_OFF;
    }
    applyContextOptimizations(current_context_);
}

void ContextAwareOptimizer::onAppChanged(const std::string& /*package*/) {
    detectCurrentContext();
}

std::string ContextAwareOptimizer::getContextName(Context context) {
    switch (context) {
        case Context::SCREEN_OFF: return "screen_off";
        case Context::SCREEN_ON: return "screen_on";
        case Context::GAMING: return "gaming";
        case Context::BROWSING: return "browsing";
        case Context::VIDEO_PLAYBACK: return "video_playback";
        case Context::FILE_TRANSFER: return "file_transfer";
        case Context::UNKNOWN: return "unknown";
        default: return "unknown";
    }
}

bool ContextAwareOptimizer::writeToProcfs(const std::string& path, const std::string& value) {
    std::ofstream file(path);
    if (!file.is_open()) return false;
    file << value;
    return file.good();
}