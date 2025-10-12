#ifndef NEXTRA_HUGEPAGES_DRIVER_H
#define NEXTRA_HUGEPAGES_DRIVER_H

#include <cstddef>
#include <vector>

class HugePages {
private:
    bool supported_{false};
    bool initialized_{false};
    size_t current_allocation_{0};
    size_t page_size_{0};
    size_t total_pages_{0};
    
    std::vector<void*> allocated_blocks_;
    
    bool mountHugePagesFS();
    bool configureKernelHugePages(size_t count);
    void* allocateSingleHugePage();
    
public:
    HugePages();
    ~HugePages();
    
    bool isSupported();
    bool allocate(size_t count, size_t size_mb = 2);
    bool release();
    
    size_t getAllocatedSize() const { return current_allocation_; }
    size_t getPageSize() const { return page_size_; }
    size_t getTotalPages() const { return total_pages_; }
    
    void* allocateHugeMemory(size_t size);
    bool freeHugeMemory(void* ptr, size_t size);
    
    bool isInitialized() const { return initialized_; }
    
private:
    bool probeHugePageSupport();
};

#endif