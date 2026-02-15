// nextram-zramlib.cpp
#include "nextram-zramlib.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/sysinfo.h>
#include <dirent.h>
#include <time.h>
#include <signal.h>
#include <pthread.h>
#include <map>
#include <string>
#include <vector>
#include <algorithm>
#include <cmath>

#include <lz4.h>
#include <lz4hc.h>
#include <zstd.h>
#include <lzo/lzo1x.h>
#include <zlib.h>

#define ZRAM_DEVICE "/dev/block/zram0"
#define ZRAM_SYSFS "/sys/block/zram0"
#define CONFIG_FILE_DEFAULT "config.conf"
#define LOG_FILE_ENV "LOG_FILE"
#define MODDIR_ENV "MODDIR"

static std::string g_config_path;
static std::string g_log_path;
static bool g_monitor_running = false;
static pthread_t g_monitor_thread;
static int g_monitor_interval = 30;
static std::string g_monitor_logdir;
static std::map<std::string, std::string> g_config;

static void nr_log(const char* level, const char* msg) {
    FILE* log_fp = nullptr;
    if (!g_log_path.empty()) log_fp = fopen(g_log_path.c_str(), "a");
    if (!log_fp) log_fp = stderr;
    time_t now = time(nullptr);
    struct tm* tm_info = localtime(&now);
    char timestamp[20];
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", tm_info);
    fprintf(log_fp, "[%s] [%s] %s\n", timestamp, level, msg);
    if (log_fp != stderr) fclose(log_fp);
}

#define LOG_DEBUG(msg) nr_log("DEBUG", msg)
#define LOG_INFO(msg)  nr_log("INFO", msg)
#define LOG_WARN(msg)  nr_log("WARN", msg)
#define LOG_ERROR(msg) nr_log("ERROR", msg)

static bool write_sysfs(const std::string& path, const std::string& value) {
    int fd = open(path.c_str(), O_WRONLY);
    if (fd < 0) { LOG_ERROR(("Cannot open " + path).c_str()); return false; }
    ssize_t written = write(fd, value.c_str(), value.size());
    close(fd);
    if (written != (ssize_t)value.size()) {
        LOG_ERROR(("Write to " + path + " failed").c_str());
        return false;
    }
    return true;
}

static std::string read_sysfs(const std::string& path) {
    int fd = open(path.c_str(), O_RDONLY);
    if (fd < 0) return "";
    char buf[256];
    ssize_t n = read(fd, buf, sizeof(buf)-1);
    close(fd);
    if (n > 0) {
        buf[n] = '\0';
        if (n > 0 && buf[n-1] == '\n') buf[n-1] = '\0';
        return std::string(buf);
    }
    return "";
}

static void load_config() {
    g_config.clear();
    std::ifstream f(g_config_path);
    if (!f.is_open()) {
        LOG_ERROR(("Cannot open config file: " + g_config_path).c_str());
        return;
    }
    std::string line;
    while (std::getline(f, line)) {
        size_t comment = line.find('#');
        if (comment != std::string::npos) line = line.substr(0, comment);
        size_t start = line.find_first_not_of(" \t\r\n");
        if (start == std::string::npos) continue;
        size_t end = line.find_last_not_of(" \t\r\n");
        line = line.substr(start, end - start + 1);
        if (line.empty()) continue;
        size_t eq = line.find('=');
        if (eq == std::string::npos) continue;
        std::string key = line.substr(0, eq);
        std::string value = line.substr(eq + 1);
        key.erase(0, key.find_first_not_of(" \t"));
        key.erase(key.find_last_not_of(" \t") + 1);
        value.erase(0, value.find_first_not_of(" \t"));
        value.erase(value.find_last_not_of(" \t") + 1);
        g_config[key] = value;
    }
    LOG_INFO("Configuration loaded");
}

int nr_config_get_int(const char* key, int def) {
    auto it = g_config.find(key);
    if (it != g_config.end()) return std::stoi(it->second);
    return def;
}

const char* nr_config_get_str(const char* key, const char* def) {
    auto it = g_config.find(key);
    if (it != g_config.end()) return it->second.c_str();
    return def;
}

bool nr_config_get_bool(const char* key, bool def) {
    auto it = g_config.find(key);
    if (it != g_config.end()) {
        std::string v = it->second;
        std::transform(v.begin(), v.end(), v.begin(), ::tolower);
        if (v == "true" || v == "yes" || v == "1") return true;
        if (v == "false" || v == "no" || v == "0") return false;
    }
    return def;
}

double nr_config_get_double(const char* key, double def) {
    auto it = g_config.find(key);
    if (it != g_config.end()) return std::stod(it->second);
    return def;
}

void nr_zram_init_lib(const char* config_path, const char* log_path) {
    if (config_path && config_path[0]) {
        g_config_path = config_path;
    } else {
        const char* moddir = getenv(MODDIR_ENV);
        if (moddir) g_config_path = std::string(moddir) + "/" + CONFIG_FILE_DEFAULT;
        else g_config_path = CONFIG_FILE_DEFAULT;
    }
    load_config();
    if (log_path && log_path[0]) {
        g_log_path = log_path;
    } else {
        const char* log_env = getenv(LOG_FILE_ENV);
        if (log_env) g_log_path = log_env;
    }
}

static bool zram_device_exists() {
    return access(ZRAM_DEVICE, F_OK) == 0;
}

static bool zram_hot_add() {
    std::string control = "/sys/class/zram-control/hot_add";
    if (access(control.c_str(), W_OK) == 0) {
        int fd = open(control.c_str(), O_WRONLY);
        if (fd >= 0) {
            write(fd, "1", 1);
            close(fd);
            usleep(200000);
            return zram_device_exists();
        }
    }
    return false;
}

static bool zram_insmod() {
    const char* modules[] = {"/system/lib/modules/zram.ko", "/vendor/lib/modules/zram.ko", nullptr};
    for (const char** mod = modules; *mod; ++mod) {
        if (access(*mod, R_OK) == 0) {
            pid_t pid = fork();
            if (pid == 0) {
                execl("/system/bin/insmod", "insmod", *mod, nullptr);
                exit(1);
            } else if (pid > 0) {
                int status;
                waitpid(pid, &status, 0);
                if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
                    usleep(200000);
                    return zram_device_exists();
                }
            }
        }
    }
    return false;
}

bool nr_zram_device_init() {
    if (zram_device_exists()) return true;
    if (zram_hot_add()) return true;
    if (zram_insmod()) return true;
    LOG_ERROR("ZRAM device not available");
    return false;
}

bool nr_zram_device_reset() {
    return write_sysfs(std::string(ZRAM_SYSFS) + "/reset", "1");
}

bool nr_zram_set_algorithm(const char* algorithm) {
    std::string alg_path = std::string(ZRAM_SYSFS) + "/comp_algorithm";
    std::string available = read_sysfs(alg_path);
    if (available.empty()) {
        LOG_ERROR("Cannot read available algorithms");
        return false;
    }
    std::string alg(algorithm);
    bool found = false;
    size_t pos = 0;
    while (pos < available.size()) {
        while (pos < available.size() && isspace(available[pos])) pos++;
        if (pos >= available.size()) break;
        bool bracket = (available[pos] == '[');
        if (bracket) pos++;
        size_t start = pos;
        while (pos < available.size() && !isspace(available[pos]) && available[pos] != ']') pos++;
        std::string token = available.substr(start, pos - start);
        if (token == alg) { found = true; break; }
        if (bracket && pos < available.size() && available[pos] == ']') pos++;
    }
    if (!found) {
        LOG_WARN(("Algorithm " + alg + " not available").c_str());
        return false;
    }
    return write_sysfs(alg_path, alg);
}

bool nr_zram_set_streams(int streams) {
    std::string stream_path = std::string(ZRAM_SYSFS) + "/max_comp_streams";
    char buf[16];
    snprintf(buf, sizeof(buf), "%d", streams);
    if (!write_sysfs(stream_path, buf)) return false;
    std::string actual = read_sysfs(stream_path);
    if (!actual.empty() && std::stoi(actual) != streams) {
        LOG_WARN(("Requested streams " + std::to_string(streams) + " but got " + actual).c_str());
    }
    return true;
}

bool nr_zram_set_disksize(unsigned long size_kb) {
    std::string disksize_path = std::string(ZRAM_SYSFS) + "/disksize";
    char buf[32];
    snprintf(buf, sizeof(buf), "%luK", size_kb);
    return write_sysfs(disksize_path, buf);
}

bool nr_zram_set_memory_limit(const char* limit) {
    if (!limit || !limit[0]) return true;
    std::string path = std::string(ZRAM_SYSFS) + "/mem_limit";
    return write_sysfs(path, limit);
}

bool nr_zram_activate_swap(int priority) {
    pid_t pid = fork();
    if (pid == 0) {
        execl("/system/bin/mkswap", "mkswap", ZRAM_DEVICE, nullptr);
        exit(1);
    } else if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
            LOG_ERROR("mkswap failed");
            return false;
        }
    } else { LOG_ERROR("fork failed for mkswap"); return false; }
    char priority_str[16];
    snprintf(priority_str, sizeof(priority_str), "%d", priority);
    pid = fork();
    if (pid == 0) {
        execl("/system/bin/swapon", "swapon", "-p", priority_str, ZRAM_DEVICE, nullptr);
        exit(1);
    } else if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
            LOG_ERROR("swapon failed");
            return false;
        }
    } else { LOG_ERROR("fork failed for swapon"); return false; }
    LOG_INFO("ZRAM activated with priority");
    return true;
}

bool nr_zram_deactivate() {
    pid_t pid = fork();
    if (pid == 0) {
        execl("/system/bin/swapoff", "swapoff", ZRAM_DEVICE, nullptr);
        exit(1);
    } else if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
            LOG_WARN("swapoff failed (maybe not active)");
        }
    } else { LOG_ERROR("fork failed for swapoff"); }
    nr_zram_device_reset();
    return true;
}

bool nr_zram_get_stats(nr_zram_stats* stats) {
    std::string stat_path = std::string(ZRAM_SYSFS) + "/mm_stat";
    std::string content = read_sysfs(stat_path);
    if (content.empty()) return false;
    unsigned long long vals[7];
    int n = sscanf(content.c_str(), "%llu %llu %llu %llu %llu %llu %llu",
                   &vals[0], &vals[1], &vals[2], &vals[3], &vals[4], &vals[5], &vals[6]);
    if (n >= 3) {
        stats->orig_size = vals[2];
        stats->compr_size = vals[1];
        stats->mem_used_total = vals[2];
        if (n >= 4) stats->mem_limit = vals[3];
        if (n >= 5) stats->pages_compacted = vals[4];
        if (n >= 6) stats->huge_pages = vals[5];
        if (n >= 7) stats->backend_refs = vals[6];
        return true;
    }
    return false;
}

char* nr_zram_test_algorithms(const char* test_dir) {
    std::string tmp_dir = test_dir ? test_dir : "/data/local/tmp/nextram_test";
    mkdir(tmp_dir.c_str(), 0755);
    std::string alg_path = std::string(ZRAM_SYSFS) + "/comp_algorithm";
    std::string available = read_sysfs(alg_path);
    if (available.empty()) {
        LOG_ERROR("Cannot read available algorithms");
        return strdup("lz4");
    }
    std::vector<std::string> algorithms;
    size_t pos = 0;
    while (pos < available.size()) {
        while (pos < available.size() && isspace(available[pos])) pos++;
        if (pos >= available.size()) break;
        bool bracket = (available[pos] == '[');
        if (bracket) pos++;
        size_t start = pos;
        while (pos < available.size() && !isspace(available[pos]) && available[pos] != ']') pos++;
        std::string token = available.substr(start, pos - start);
        if (!token.empty() && token != "none") algorithms.push_back(token);
        if (bracket && pos < available.size() && available[pos] == ']') pos++;
    }
    if (algorithms.empty()) return strdup("lz4");
    std::vector<std::string> test_files;
    std::string rand_file = tmp_dir + "/random.bin";
    FILE* f = fopen(rand_file.c_str(), "wb");
    if (f) {
        for (int i = 0; i < 5 * 1024 * 1024 / 1024; i++) {
            unsigned int buf[256];
            for (int j = 0; j < 256; j++) buf[j] = rand();
            fwrite(buf, 1024, 1, f);
        }
        fclose(f);
        test_files.push_back(rand_file);
    }
    std::string zero_file = tmp_dir + "/zeros.bin";
    f = fopen(zero_file.c_str(), "wb");
    if (f) {
        char zeros[1024] = {0};
        for (int i = 0; i < 5 * 1024; i++) fwrite(zeros, 1024, 1, f);
        fclose(f);
        test_files.push_back(zero_file);
    }
    std::string log_file = tmp_dir + "/logs.txt";
    system(("logcat -d > " + log_file + " 2>/dev/null").c_str());
    if (access(log_file.c_str(), R_OK) == 0) test_files.push_back(log_file);
    std::string apk_file = tmp_dir + "/app.apk";
    system(("cp /system/framework/framework-res.apk " + apk_file + " 2>/dev/null").c_str());
    if (access(apk_file.c_str(), R_OK) == 0) test_files.push_back(apk_file);
    struct AlgorithmScore {
        std::string name; double score; double ratio;
    };
    std::vector<AlgorithmScore> scores;
    for (const auto& alg : algorithms) {
        LOG_INFO(("Testing algorithm: " + alg).c_str());
        nr_zram_device_reset();
        if (!write_sysfs(alg_path, alg)) { LOG_WARN(("Failed to set algorithm " + alg).c_str()); continue; }
        if (!nr_zram_set_disksize(50 * 1024)) { LOG_WARN("Failed to set disksize"); continue; }
        int fd = open(ZRAM_DEVICE, O_RDWR);
        if (fd < 0) { LOG_WARN("Cannot open ZRAM device"); continue; }
        double total_score = 0, total_ratio = 0;
        int test_count = 0;
        for (const auto& tf : test_files) {
            FILE* tf_f = fopen(tf.c_str(), "rb");
            if (!tf_f) continue;
            fseek(tf_f, 0, SEEK_END);
            long fsize = ftell(tf_f);
            fseek(tf_f, 0, SEEK_SET);
            char* buffer = (char*)malloc(fsize);
            if (!buffer) { fclose(tf_f); continue; }
            fread(buffer, 1, fsize, tf_f);
            fclose(tf_f);
            struct timespec start, end;
            clock_gettime(CLOCK_MONOTONIC, &start);
            ssize_t written = write(fd, buffer, fsize);
            clock_gettime(CLOCK_MONOTONIC, &end);
            free(buffer);
            if (written != fsize) { LOG_WARN(("Write to ZRAM failed for " + tf).c_str()); continue; }
            long elapsed_ns = (end.tv_sec - start.tv_sec) * 1000000000 + (end.tv_nsec - start.tv_nsec);
            double elapsed_ms = elapsed_ns / 1e6;
            nr_zram_stats stats;
            if (!nr_zram_get_stats(&stats)) { LOG_WARN("Cannot get stats"); continue; }
            double ratio = (double)stats.orig_size / stats.compr_size;
            double speed = fsize / 1024.0 / 1024.0 / (elapsed_ms / 1000.0);
            double score = speed * 3 + ratio * 4;
            total_score += score;
            total_ratio += ratio;
            test_count++;
        }
        close(fd);
        if (test_count > 0) {
            AlgorithmScore as;
            as.name = alg;
            as.score = total_score / test_count;
            as.ratio = total_ratio / test_count;
            scores.push_back(as);
            LOG_INFO(("Algorithm " + alg + " score=" + std::to_string(as.score)).c_str());
        }
    }
    std::string best = "lz4";
    double best_score = -1;
    for (const auto& as : scores) {
        if (as.score > best_score) { best_score = as.score; best = as.name; }
    }
    for (const auto& tf : test_files) unlink(tf.c_str());
    rmdir(tmp_dir.c_str());
    LOG_INFO(("Best algorithm: " + best).c_str());
    return strdup(best.c_str());
}

static void* monitor_thread_func(void* arg) {
    while (g_monitor_running) {
        nr_zram_stats stats;
        if (nr_zram_get_stats(&stats)) {
            time_t now = time(nullptr);
            struct tm* tm_info = localtime(&now);
            char timestamp[20];
            strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", tm_info);
            double ratio = (stats.orig_size > 0 && stats.compr_size > 0) ? (double)stats.orig_size / stats.compr_size : 0.0;
            std::string line = std::string(timestamp) + "," + std::to_string(stats.compr_size) + "," + std::to_string(stats.orig_size) + "," + std::to_string(ratio);
            std::string logfile = g_monitor_logdir + "/zram_monitor.csv";
            FILE* f = fopen(logfile.c_str(), "a");
            if (f) { fprintf(f, "%s\n", line.c_str()); fclose(f); }
        }
        sleep(g_monitor_interval);
    }
    return nullptr;
}

bool nr_zram_start_monitoring(int interval_sec, const char* log_dir) {
    if (g_monitor_running) return false;
    g_monitor_interval = interval_sec;
    if (log_dir && log_dir[0]) g_monitor_logdir = log_dir;
    else {
        const char* moddir = getenv(MODDIR_ENV);
        if (moddir) g_monitor_logdir = std::string(moddir) + "/logs";
        else g_monitor_logdir = ".";
    }
    mkdir(g_monitor_logdir.c_str(), 0755);
    g_monitor_running = true;
    pthread_create(&g_monitor_thread, nullptr, monitor_thread_func, nullptr);
    LOG_INFO("ZRAM monitoring started");
    return true;
}

bool nr_zram_stop_monitoring() {
    if (!g_monitor_running) return false;
    g_monitor_running = false;
    pthread_join(g_monitor_thread, nullptr);
    LOG_INFO("ZRAM monitoring stopped");
    return true;
}

bool nr_zram_cleanup() {
    nr_zram_stop_monitoring();
    nr_zram_deactivate();
    std::string control = "/sys/class/zram-control/hot_remove";
    if (access(control.c_str(), W_OK) == 0) {
        int fd = open(control.c_str(), O_WRONLY);
        if (fd >= 0) { write(fd, "0", 1); close(fd); }
    }
    return true;
}

static unsigned long get_meminfo_value(const char* key) {
    FILE* f = fopen("/proc/meminfo", "r");
    if (!f) return 0;
    char line[256];
    unsigned long value = 0;
    while (fgets(line, sizeof(line), f)) {
        if (strncmp(line, key, strlen(key)) == 0) {
            char* colon = strchr(line, ':');
            if (colon) {
                value = strtoul(colon + 1, nullptr, 10);
                break;
            }
        }
    }
    fclose(f);
    return value;
}

unsigned long nr_zram_calculate_optimal_size() {
    unsigned long mem_total = get_meminfo_value("MemTotal");
    unsigned long mem_available = get_meminfo_value("MemAvailable");
    unsigned long swap_total = get_meminfo_value("SwapTotal");
    unsigned long swap_free = get_meminfo_value("SwapFree");

    if (mem_total == 0) {
        LOG_WARN("Cannot read MemTotal, using default 1GB");
        return 1024 * 1024;
    }

    double ratio = nr_config_get_double("ZRAM_RATIO", 1.5);
    unsigned long base_size = (unsigned long)(mem_total * ratio);

    if (mem_available > 0 && mem_available < mem_total / 4) {
        base_size = base_size * 120 / 100;
    }

    if (swap_total > 0) {
        unsigned long swap_used = swap_total - swap_free;
        int swap_usage_percent = (swap_used * 100) / swap_total;
        if (swap_usage_percent > 70) {
            base_size = base_size * 130 / 100;
        }
    }

    unsigned long max_zram = mem_total * 4;
    unsigned long min_zram = 512 * 1024;
    if (base_size > max_zram) base_size = max_zram;
    if (base_size < min_zram) base_size = min_zram;

    const char* mem_limit_str = nr_config_get_str("ZRAM_MEMORY_LIMIT", "");
    if (mem_limit_str && mem_limit_str[0]) {
        unsigned long limit = 0;
        char unit = 0;
        if (sscanf(mem_limit_str, "%lu%c", &limit, &unit) >= 1) {
            switch (unit) {
                case 'G': case 'g': limit *= 1024 * 1024; break;
                case 'M': case 'm': limit *= 1024; break;
                case 'K': case 'k': break;
                default: limit *= 1024;
            }
            if (limit > 0 && limit < base_size) base_size = limit;
        }
    }

    LOG_INFO(("Calculated optimal ZRAM size: " + std::to_string(base_size) + " KB").c_str());
    return base_size;
}

int nr_zram_get_optimal_streams(const char* algorithm) {
    int cpu_cores = get_nprocs_conf();
    if (cpu_cores <= 0) cpu_cores = 4;

    for (int i = 0; i < cpu_cores; i++) {
        std::string path = "/sys/devices/system/cpu/cpu" + std::to_string(i) + "/cpufreq/cpuinfo_max_freq";
        std::string freq_str = read_sysfs(path);
        if (!freq_str.empty()) {
            unsigned long freq = strtoul(freq_str.c_str(), nullptr, 10);
            if (freq > 1500000) {
                break;
            }
        }
    }

    int streams = cpu_cores;
    std::string alg(algorithm);
    if (alg == "lz4" || alg == "lz4hc") {
        streams = cpu_cores > 4 ? cpu_cores - 1 : cpu_cores;
    } else if (alg == "zstd") {
        streams = cpu_cores;
    } else {
        streams = 1;
    }

    int max_streams = nr_config_get_int("MAX_COMP_STREAMS", 4);
    if (max_streams > 0 && streams > max_streams) streams = max_streams;

    if (alg == "lzo" || alg == "lzo-rle") {
        if (streams > 2) streams = 2;
    }

    return streams;
}
