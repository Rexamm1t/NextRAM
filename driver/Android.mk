LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := nextram_driver
LOCAL_SRC_FILES := source/nextram_service_driver.cpp \
                   source/nextram_driver_mem.cpp \
                   source/nextram_driver_zram.cpp \
                   source/nextram_driver_hgpages.cpp \
                   source/nextram_driver_chpages.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_CFLAGS := -std=c++17 -Wall -Wextra -O2 -fPIE -fstack-protector-strong
LOCAL_LDFLAGS := -fPIE -pie -llog -latomic
LOCAL_LDLIBS := -llog

include $(BUILD_EXECUTABLE)
