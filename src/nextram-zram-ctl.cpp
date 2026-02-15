// nextram-zram-ctl.cpp
#include "nextram-zramlib.h"
#include <iostream>
#include <cstring>
#include <cstdlib>
#include <getopt.h>

static void usage(const char* prog) {
    std::cerr << "Usage: " << prog << " <command> [options]\n"
              << "Commands:\n"
              << "  init\n"
              << "  reset\n"
              << "  set-algorithm ALG\n"
              << "  set-streams N\n"
              << "  set-size SIZE_KB\n"
              << "  set-memory-limit LIMIT\n"
              << "  activate [PRIORITY]\n"
              << "  deactivate\n"
              << "  stats\n"
              << "  test [DIR]\n"
              << "  monitor [INTERVAL] [DIR]\n"
              << "  stop-monitor\n"
              << "  cleanup\n"
              << "  calc-size\n"
              << "  optimal-streams ALG\n"
              << "  setup\n"
              << "Options:\n"
              << "  --config FILE\n"
              << "  --log FILE\n";
}

int main(int argc, char** argv) {
    const char* config_path = nullptr;
    const char* log_path = nullptr;
    int opt;
    static struct option long_options[] = {
        {"config", required_argument, 0, 'c'},
        {"log", required_argument, 0, 'l'},
        {0, 0, 0, 0}
    };
    int option_index = 0;
    while ((opt = getopt_long(argc, argv, "c:l:", long_options, &option_index)) != -1) {
        switch (opt) {
            case 'c': config_path = optarg; break;
            case 'l': log_path = optarg; break;
            default: usage(argv[0]); return 1;
        }
    }
    nr_zram_init_lib(config_path, log_path);
    if (optind >= argc) { usage(argv[0]); return 1; }
    std::string cmd = argv[optind]; optind++;

    if (cmd == "init") return nr_zram_device_init() ? 0 : 1;
    if (cmd == "reset") return nr_zram_device_reset() ? 0 : 1;
    if (cmd == "set-algorithm") {
        if (optind >= argc) { std::cerr << "Missing algorithm\n"; return 1; }
        return nr_zram_set_algorithm(argv[optind]) ? 0 : 1;
    }
    if (cmd == "set-streams") {
        if (optind >= argc) { std::cerr << "Missing number of streams\n"; return 1; }
        int streams = atoi(argv[optind]);
        return nr_zram_set_streams(streams) ? 0 : 1;
    }
    if (cmd == "set-size") {
        if (optind >= argc) { std::cerr << "Missing size in KB\n"; return 1; }
        unsigned long size = strtoul(argv[optind], nullptr, 10);
        return nr_zram_set_disksize(size) ? 0 : 1;
    }
    if (cmd == "set-memory-limit") {
        if (optind >= argc) { std::cerr << "Missing limit (e.g., 4G)\n"; return 1; }
        return nr_zram_set_memory_limit(argv[optind]) ? 0 : 1;
    }
    if (cmd == "activate") {
        int priority = 100;
        if (optind < argc) priority = atoi(argv[optind]);
        return nr_zram_activate_swap(priority) ? 0 : 1;
    }
    if (cmd == "deactivate") return nr_zram_deactivate() ? 0 : 1;
    if (cmd == "stats") {
        nr_zram_stats stats;
        if (!nr_zram_get_stats(&stats)) { std::cerr << "Failed to get stats\n"; return 1; }
        printf("Original size: %llu KB\n", stats.orig_size / 1024);
        printf("Compressed size: %llu KB\n", stats.compr_size / 1024);
        if (stats.compr_size > 0) printf("Ratio: %.2f\n", (double)stats.orig_size / stats.compr_size);
        return 0;
    }
    if (cmd == "test") {
        const char* test_dir = (optind < argc) ? argv[optind] : nullptr;
        char* best = nr_zram_test_algorithms(test_dir);
        if (best) { printf("Best algorithm: %s\n", best); free(best); return 0; }
        return 1;
    }
    if (cmd == "monitor") {
        int interval = 30;
        const char* log_dir = nullptr;
        if (optind < argc) interval = atoi(argv[optind]);
        if (optind+1 < argc) log_dir = argv[optind+1];
        return nr_zram_start_monitoring(interval, log_dir) ? 0 : 1;
    }
    if (cmd == "stop-monitor") return nr_zram_stop_monitoring() ? 0 : 1;
    if (cmd == "cleanup") return nr_zram_cleanup() ? 0 : 1;
    if (cmd == "calc-size") {
        unsigned long size = nr_zram_calculate_optimal_size();
        printf("%lu KB\n", size);
        return 0;
    }
    if (cmd == "optimal-streams") {
        if (optind >= argc) { std::cerr << "Missing algorithm\n"; return 1; }
        int streams = nr_zram_get_optimal_streams(argv[optind]);
        printf("%d\n", streams);
        return 0;
    }
    if (cmd == "setup") {
        if (!nr_zram_device_init()) return 1;
        nr_zram_device_reset();

        const char* alg = nr_config_get_str("ZRAM_ALGORITHM", "lz4");
        if (!nr_zram_set_algorithm(alg)) {
            bool auto_tune = nr_config_get_bool("ZRAM_AUTO_TUNE", false);
            if (auto_tune) {
                char* best = nr_zram_test_algorithms(nullptr);
                if (best) { nr_zram_set_algorithm(best); free(best); }
            }
        }

        int streams = nr_zram_get_optimal_streams(nr_config_get_str("ZRAM_ALGORITHM", "lz4"));
        nr_zram_set_streams(streams);

        unsigned long size_kb = nr_zram_calculate_optimal_size();
        nr_zram_set_disksize(size_kb);

        const char* mem_limit = nr_config_get_str("ZRAM_MEMORY_LIMIT", "");
        nr_zram_set_memory_limit(mem_limit);

        int priority = nr_config_get_int("ZRAM_PRIORITY", 100);
        return nr_zram_activate_swap(priority) ? 0 : 1;
    }

    std::cerr << "Unknown command: " << cmd << std::endl;
    usage(argv[0]);
    return 1;
}
