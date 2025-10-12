#ifndef NEXTRA_CONTEXT_DRIVER_H
#define NEXTRA_CONTEXT_DRIVER_H

#include <string>

class ContextAwareOptimizer {
public:
    enum class Context {
        SCREEN_OFF,
        SCREEN_ON,
        GAMING,
        BROWSING,
        VIDEO_PLAYBACK,
        FILE_TRANSFER,
        UNKNOWN
    };
    
private:
    Context current_context_;
    Context previous_context_;
    
    Context detectScreenState();
    Context detectAppContext();
    Context detectUserActivity();
    bool writeToProcfs(const std::string& path, const std::string& value);
    
public:
    ContextAwareOptimizer();
    
    Context detectCurrentContext();
    void applyContextOptimizations(Context context);
    void onScreenStateChanged(bool screen_on);
    void onAppChanged(const std::string& package);
    
    Context getCurrentContext() const { return current_context_; }
    std::string getContextName(Context context);
};

#endif