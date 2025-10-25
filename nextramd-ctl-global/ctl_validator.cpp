#include "ctl_validator.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <regex>
#include <algorithm>

bool CtlValidator::validateNumber(const std::string& value) {
    if (value.empty()) return false;
    bool dot_found = false;
    for (char c : value) {
        if (c == '.') {
            if (dot_found) return false;
            dot_found = true;
        } else if (!std::isdigit(static_cast<unsigned char>(c))) {
            return false;
        }
    }
    return true;
}

bool CtlValidator::validateInteger(const std::string& value) {
    if (value.empty()) return false;
    
    for (char c : value) {
        if (!std::isdigit(static_cast<unsigned char>(c))) {
            return false;
        }
    }
    return true;
}

bool CtlValidator::validateRange(const std::string& value, double min, double max) {
    if (!validateNumber(value)) {
        return false;
    }
    
    try {
        double num = std::stod(value);
        return num >= min && num <= max;
    } catch (...) {
        return false;
    }
}

bool CtlValidator::validateSwappiness(const std::string& value) {
    return validateRange(value, 0, 100);
}

bool CtlValidator::validateBoolean(const std::string& value) {
    return value == "true" || value == "false";
}

std::string CtlValidator::getAvailableAlgorithms() {
    std::ifstream alg_file("/sys/block/zram0/comp_algorithm");
    if (!alg_file.is_open()) {
        return "";
    }
    
    std::string algorithms;
    std::getline(alg_file, algorithms);
    alg_file.close();
    
    algorithms.erase(std::remove(algorithms.begin(), algorithms.end(), '['), algorithms.end());
    algorithms.erase(std::remove(algorithms.begin(), algorithms.end(), ']'), algorithms.end());
    
    return algorithms;
}

bool CtlValidator::validateAlgorithm(const std::string& algorithm) {
    std::string available_algorithms = getAvailableAlgorithms();
    if (available_algorithms.empty()) {
        std::cout << "WARNING: Cannot verify algorithm availability. ZRAM device not accessible." << std::endl;
        return true;
    }
    
    std::istringstream iss(available_algorithms);
    std::string alg;
    bool found = false;
    
    while (iss >> alg) {
        if (alg == algorithm) {
            found = true;
            break;
        }
    }
    
    if (!found) {
        std::cout << "ERROR: Algorithm '" << algorithm << "' is not available." << std::endl;
        std::cout << "Available algorithms: " << available_algorithms << std::endl;
        return false;
    }
    
    return true;
}
