#!/bin/bash

clang++ -std=c++17 -Wall -Wextra -O2 -fstack-protector-strong -I./include \
    -o nextram_driver \
    source/nextram_service_driver.cpp \
    source/nextram_driver_mem.cpp \
    source/nextram_driver_zram.cpp \
    source/nextram_driver_hgpages.cpp \
    source/nextram_driver_chpages.cpp \
    source/nextram_driver_profiles.cpp \
    source/nextram_driver_ai.cpp \
    source/nextram_driver_thermal.cpp \
    source/nextram_driver_process.cpp \
    source/nextram_driver_context.cpp \
    source/nextram_driver_metrics.cpp \
    -llog -latomic -pthread

if [ $? -eq 0 ]; then
    echo "NextRAM driver compiled successfully!"
else
    echo "Compilation failed!"
    exit 1
fi
