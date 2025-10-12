cmake_minimum_required(VERSION 3.10)
project(nextram_driver)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -O2 -fstack-protector-strong")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -O2")

set(SOURCES
    source/nextram_service_driver.cpp
    source/nextram_driver_mem.cpp
    source/nextram_driver_zram.cpp
    source/nextram_driver_hgpages.cpp
    source/nextram_driver_chpages.cpp
)

add_executable(nextram_driver ${SOURCES})
target_include_directories(nextram_driver PRIVATE include)
add_executable(nextram_kernel kernel/nextram_kernel.c)