// nextram-zramlib.h
#ifndef NEXTRAM_ZRAMLIB_H
#define NEXTRAM_ZRAMLIB_H

#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    unsigned long long orig_size;
    unsigned long long compr_size;
    unsigned long long mem_used_total;
    unsigned long long mem_limit;
    unsigned long long pages_compacted;
    unsigned long long huge_pages;
    unsigned long long backend_refs;
} nr_zram_stats;

void nr_zram_init_lib(const char* config_path, const char* log_path);
bool nr_zram_device_init(void);
bool nr_zram_device_reset(void);
bool nr_zram_set_algorithm(const char* algorithm);
bool nr_zram_set_streams(int streams);
bool nr_zram_set_disksize(unsigned long size_kb);
bool nr_zram_set_memory_limit(const char* limit);
bool nr_zram_activate_swap(int priority);
bool nr_zram_deactivate(void);
bool nr_zram_get_stats(nr_zram_stats* stats);
char* nr_zram_test_algorithms(const char* test_dir);
bool nr_zram_start_monitoring(int interval_sec, const char* log_dir);
bool nr_zram_stop_monitoring(void);
bool nr_zram_cleanup(void);
unsigned long nr_zram_calculate_optimal_size(void);
int nr_zram_get_optimal_streams(const char* algorithm);

int nr_config_get_int(const char* key, int def);
const char* nr_config_get_str(const char* key, const char* def);
bool nr_config_get_bool(const char* key, bool def);
double nr_config_get_double(const char* key, double def);

#ifdef __cplusplus
}
#endif

#endif
