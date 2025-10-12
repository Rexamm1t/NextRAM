#include "nextram_driver_ai.h"
#include <cmath>
#include <algorithm>
#include <fstream>

AIOptimizer::AIOptimizer() : last_analysis_(std::chrono::steady_clock::now()) {
}

AIOptimizer::~AIOptimizer() {
    stopAnalysis();
}

void AIOptimizer::startAnalysis() {
    training_ = true;
    analysis_thread_ = std::thread(&AIOptimizer::continuousAnalysis, this);
}

void AIOptimizer::stopAnalysis() {
    training_ = false;
    if (analysis_thread_.joinable()) {
        analysis_thread_.join();
    }
}

void AIOptimizer::continuousAnalysis() {
    while (training_) {
        auto now = std::chrono::steady_clock::now();
        auto time_diff = std::chrono::duration_cast<std::chrono::minutes>(now - last_analysis_).count();
        
        if (time_diff >= 5) {
            if (!learned_patterns_.empty()) {
                analyzePattern(learned_patterns_.back());
            }
            last_analysis_ = now;
        }
        
        std::this_thread::sleep_for(std::chrono::seconds(30));
    }
}

void AIOptimizer::addPattern(const MemoryPattern& pattern) {
    std::lock_guard<std::mutex> lock(patterns_mutex_);
    learned_patterns_.push_back(pattern);
    
    if (learned_patterns_.size() > 1000) {
        learned_patterns_.erase(learned_patterns_.begin());
    }
}

void AIOptimizer::analyzePattern(const MemoryPattern& pattern) {
    std::vector<std::pair<float, MemoryPattern>> similarities;
    
    for (const auto& stored_pattern : learned_patterns_) {
        if (&stored_pattern == &pattern) continue;
        
        float similarity = calculateSimilarity(pattern, stored_pattern);
        similarities.emplace_back(similarity, stored_pattern);
    }
    
    std::sort(similarities.begin(), similarities.end(), 
              [](const auto& a, const auto& b) { return a.first > b.first; });
    
    size_t count = std::min(similarities.size(), size_t(5));
    if (count == 0) return;
}

float AIOptimizer::calculateSimilarity(const MemoryPattern& a, const MemoryPattern& b) {
    float memory_similarity = 1.0f - std::abs(static_cast<float>(a.memory_usage) - static_cast<float>(b.memory_usage)) / static_cast<float>(a.memory_usage + b.memory_usage);
    float cache_similarity = 1.0f - std::abs(static_cast<float>(a.cache_usage) - static_cast<float>(b.cache_usage)) / static_cast<float>(a.cache_usage + b.cache_usage);
    
    auto a_time = std::chrono::system_clock::to_time_t(a.timestamp);
    auto b_time = std::chrono::system_clock::to_time_t(b.timestamp);
    struct tm a_tm = *std::localtime(&a_time);
    struct tm b_tm = *std::localtime(&b_time);
    
    float time_similarity = 1.0f - std::abs(a_tm.tm_hour - b_tm.tm_hour) / 24.0f;
    
    return (memory_similarity + cache_similarity + time_similarity) / 3.0f;
}

AIPrediction AIOptimizer::predictOptimalSettings() {
    AIPrediction prediction;
    
    if (learned_patterns_.empty()) {
        prediction.predicted_memory_usage = 0.5f;
        prediction.recommended_swappiness = 60;
        prediction.recommended_zram_algorithm = "lz4";
        prediction.should_enable_hugepages = true;
        return prediction;
    }
    
    size_t count = std::min(learned_patterns_.size(), size_t(10));
    float total_swappiness = 0;
    float total_memory_usage = 0;
    
    auto it = learned_patterns_.rbegin();
    for (size_t i = 0; i < count && it != learned_patterns_.rend(); ++i, ++it) {
        total_swappiness += it->swappiness;
        total_memory_usage += static_cast<float>(it->memory_usage);
    }
    
    prediction.recommended_swappiness = static_cast<uint32_t>(total_swappiness / count);
    prediction.predicted_memory_usage = total_memory_usage / count;
    prediction.recommended_zram_algorithm = "lz4";
    prediction.should_enable_hugepages = true;
    
    return prediction;
}

bool AIOptimizer::trainModel() {
    return learned_patterns_.size() > 10;
}

float AIOptimizer::calculateOptimalSwappiness() {
    if (learned_patterns_.empty()) {
        return 60.0f;
    }
    
    size_t count = std::min(learned_patterns_.size(), size_t(20));
    float total = 0;
    
    auto it = learned_patterns_.rbegin();
    for (size_t i = 0; i < count && it != learned_patterns_.rend(); ++i, ++it) {
        total += it->swappiness;
    }
    
    return total / count;
}

std::string AIOptimizer::recommendZRAMAlgorithm() {
    if (learned_patterns_.empty()) {
        return "lz4";
    }
    
    float avg_memory_usage = 0;
    for (const auto& pattern : learned_patterns_) {
        avg_memory_usage += static_cast<float>(pattern.memory_usage);
    }
    avg_memory_usage /= learned_patterns_.size();
    
    if (avg_memory_usage > 0.8f) {
        return "zstd";
    } else {
        return "lz4";
    }
}