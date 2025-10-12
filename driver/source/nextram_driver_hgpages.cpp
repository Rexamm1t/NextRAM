#include "nextram_driver_hgpages.h"
#include <fstream>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>

HugePages::HugePages() {
    supported_ = probeHugePageSupport();
}

HugePages::~HugePages() {
    release();
}

bool HugePages::probeHugePageSupport() {
    std::ifstream hugepages_dir("/sys/kernel/mm/hugepages");
    return hugepages_dir.good();
}

bool HugePages::isSupported() {
    return supported_;
}

bool HugePages::mountHugePagesFS() {
    if (system("mkdir -p /dev/hugepages") != 0) return false;
    if (system("mount -t hugetlbfs -o pagesize=2M none /dev/hugepages") != 0) return false;
    return true;
}

bool HugePages::configureKernelHugePages(size_t count) {
    std::ofstream nr_hugepages("/proc/sys/vm/nr_hugepages");
    if (!nr_hugepages.is_open()) return false;
    nr_hugepages << count;
    
    if (!nr_hugepages.good()) return false;
    
    total_pages_ = count;
    page_size_ = 2 * 1024 * 1024;
    return true;
}

bool HugePages::allocate(size_t count, size_t size_mb) {
    (void)size_mb;
    if (!supported_) return false;
    
    if (!mountHugePagesFS()) return false;
    if (!configureKernelHugePages(count)) return false;
    
    for (size_t i = 0; i < count; ++i) {
        void* page = allocateSingleHugePage();
        if (page) {
            allocated_blocks_.push_back(page);
            current_allocation_ += page_size_;
        }
    }
    
    initialized_ = true;
    return true;
}

void* HugePages::allocateSingleHugePage() {
    int flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB;
    void* addr = mmap(nullptr, page_size_, PROT_READ | PROT_WRITE, flags, -1, 0);
    
    if (addr == MAP_FAILED) return nullptr;
    return addr;
}

bool HugePages::release() {
    for (void* block : allocated_blocks_) {
        munmap(block, page_size_);
    }
    allocated_blocks_.clear();
    
    system("umount /dev/hugepages 2>/dev/null");
    
    std::ofstream nr_hugepages("/proc/sys/vm/nr_hugepages");
    if (nr_hugepages.is_open()) {
        nr_hugepages << "0";
    }
    
    current_allocation_ = 0;
    initialized_ = false;
    return true;
}

void* HugePages::allocateHugeMemory(size_t size) {
    if (!initialized_) return nullptr;
    
    int flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB;
    void* addr = mmap(nullptr, size, PROT_READ | PROT_WRITE, flags, -1, 0);
    
    if (addr == MAP_FAILED) return nullptr;
    return addr;
}

bool HugePages::freeHugeMemory(void* ptr, size_t size) {
    return munmap(ptr, size) == 0;
}
