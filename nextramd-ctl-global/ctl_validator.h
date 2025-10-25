#ifndef CTL_VALIDATOR_H
#define CTL_VALIDATOR_H

#include <string>

class CtlValidator {
public:
    static bool validateNumber(const std::string& value);
    static bool validateInteger(const std::string& value);
    static bool validateRange(const std::string& value, double min, double max);
    static bool validateSwappiness(const std::string& value);
    static bool validateAlgorithm(const std::string& algorithm);
    static bool validateBoolean(const std::string& value);
    static std::string getAvailableAlgorithms();
};

#endif
