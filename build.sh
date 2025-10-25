#!/system/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PINK_RED='\033[1;35m'
NC='\033[0m'

print_ascii_art() {
    clear
    echo -e "${PINK_RED}"
    echo "   \  |               |     _ \      \      \  |"
    echo "    \ |   _ \ \ \  /  __|  |   |    _ \    |\/ |"
    echo "  |\  |   __/  \  <   |    __ <    ___ \   |   |"
    echo " _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _|"
    echo -e "${NC}"
    sleep 2
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

BUILD_DIR="./out"
SRC_DIR="."
BIN_DIR="/system/bin"

detect_environment() {
    if [ -d "/data/data/com.termux/files/usr" ]; then
        echo "termux"
    else
        echo "pc"
    fi
}

ENVIRONMENT=$(detect_environment)

print_status "Detected environment: $ENVIRONMENT"

if [ "$ENVIRONMENT" = "termux" ]; then
    CC="clang"
    CXX="clang++"
    CFLAGS=""
    CXXFLAGS="-std=c++17 -Wall -Wextra -fPIE -Wno-unused-parameter"
    LDFLAGS="-pie -llog -landroid -lm"
    
elif [ "$ENVIRONMENT" = "pc" ]; then
    detect_ndk() {
        local ndk_paths=(
            "$HOME/android-ndk-*"
            "/opt/android-ndk-*"
            "/usr/local/android-ndk-*"
            "/home/*/android-ndk-*"
        )
        
        for path in "${ndk_paths[@]}"; do
            for ndk in $path; do
                if [ -d "$ndk" ]; then
                    echo "$ndk"
                    return 0
                fi
            done
        done
        
        if [ -d "/usr/lib/android-ndk" ]; then
            echo "/usr/lib/android-ndk"
            return 0
        fi
        
        return 1
    }
    
    NDK_PATH=$(detect_ndk)
    
    if [ -n "$NDK_PATH" ]; then
        print_success "Found Android NDK: $NDK_PATH"
        
        HOST_ARCH="linux-x86_64"
        TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_ARCH"
        SYSROOT="$TOOLCHAIN/sysroot"
        
        TARGET="aarch64-linux-android"
        API_LEVEL="21"
        
        CC="$TOOLCHAIN/bin/${TARGET}${API_LEVEL}-clang"
        CXX="$TOOLCHAIN/bin/${TARGET}${API_LEVEL}-clang++"
        CFLAGS="--target=$TARGET --sysroot=$SYSROOT -D__ANDROID_API__=$API_LEVEL"
        CXXFLAGS="-std=c++17 -Wall -Wextra -fPIE -Wno-unused-parameter"
        LDFLAGS="-pie -L$SYSROOT/usr/lib/$TARGET/$API_LEVEL -llog -landroid -lm -latomic"
        
    else
        print_warning "Android NDK not found, using system compiler (for testing only)"
        print_warning "Resulting binaries will not run on Android!"
        
        CC="gcc"
        CXX="g++"
        CFLAGS=""
        CXXFLAGS="-std=c++17"
        LDFLAGS="-pie -lm"
    fi
fi

SERVICES=(
    "main-nextram-service-daemon:main-nextram-service-daemon"
    "nextramd-zram-service:nextramd-zram-service"
    "nextramd-swap-service:nextramd-swap-service"
    "nextramd-kernel-tn-service:nextramd-kernel-tn-service"
    "nextramd-ctl-global:nextramd-ctl-global"
)

print_service_header() {
    clear
    echo -e "${YELLOW}"
    echo "building >>> $1"
    echo -e "${NC}"
    sleep 2
}

check_dependencies() {
    print_status "Checking build dependencies..."
    
    if ! command -v $CC >/dev/null 2>&1; then
        print_error "Compiler not found: $CC"
        return 1
    fi
    
    if ! command -v $CXX >/dev/null 2>&1; then
        print_error "C++ compiler not found: $CXX"
        return 1
    fi
    
    print_success "Compiler: $($CC --version | head -n1)"
    print_success "C++ compiler: $($CXX --version | head -n1)"
    
    if [ "$ENVIRONMENT" = "pc" ] && [ -n "$NDK_PATH" ]; then
        print_success "Using Android NDK: $(basename $NDK_PATH)"
    fi
    
    if [ ! -d "$SRC_DIR" ]; then
        print_error "Source directory $SRC_DIR not found"
        return 1
    fi
    
    print_success "All dependencies satisfied"
    return 0
}

prepare_build_dir() {
    print_status "Preparing build directory..."
    
    if [ -d "$BUILD_DIR" ]; then
        print_warning "Removing existing build directory"
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    
    if [ $? -ne 0 ]; then
        print_error "Failed to create build directory"
        return 1
    fi
    
    print_success "Build directory created: $BUILD_DIR"
    return 0
}

build_service() {
    local service_name=$1
    local service_dir=$2
    local source_path="$SRC_DIR/$service_dir"
    local build_path="$BUILD_DIR/obj/$service_dir"
    local output_binary="$BUILD_DIR/bin/$service_name"
    
    print_service_header "$service_name"
    
    if [ ! -d "$source_path" ]; then
        print_error "Source directory not found: $source_path"
        return 1
    fi
    
    mkdir -p "$build_path"
    mkdir -p "$(dirname "$output_binary")"
    
    print_status "Scanning source files..."
    
    local cpp_files=()
    local h_files=()
    
    for file in "$source_path"/*.cpp "$source_path"/*.h; do
        if [ -f "$file" ]; then
            if [[ "$file" == *.cpp ]]; then
                cpp_files+=("$file")
                print_status "  C++: $(basename "$file")"
            elif [[ "$file" == *.h ]]; then
                h_files+=("$file")
                print_status "  Header: $(basename "$file")"
            fi
        fi
    done
    
    if [ ${#cpp_files[@]} -eq 0 ]; then
        print_error "No C++ source files found in $source_path"
        return 1
    fi
    
    print_status "Compiling $service_name..."
    
    local object_files=()
    for cpp_file in "${cpp_files[@]}"; do
        local obj_name="$build_path/$(basename "$cpp_file" .cpp).o"
        object_files+=("$obj_name")
        
        print_status "  Compiling: $(basename "$cpp_file") -> $(basename "$obj_name")"
        
        $CXX $CFLAGS $CXXFLAGS -c "$cpp_file" -o "$obj_name"
        
        if [ $? -ne 0 ]; then
            print_error "Failed to compile $cpp_file"
            return 1
        fi
    done
    
    print_status "Linking $service_name..."
    
    $CXX "${object_files[@]}" $LDFLAGS -o "$output_binary"
    
    if [ $? -ne 0 ]; then
        print_error "Failed to link $service_name"
        return 1
    fi
    
    if [ -f "$output_binary" ]; then
        chmod 755 "$output_binary"
        local binary_size=$(du -h "$output_binary" | cut -f1)
        print_success "Built: $service_name ($binary_size)"
        return 0
    else
        print_error "Binary not created: $output_binary"
        return 1
    fi
}

build_all_services() {
    print_status "Building all services..."
    
    local success_count=0
    local total_count=${#SERVICES[@]}
    
    for service in "${SERVICES[@]}"; do
        IFS=':' read -r service_name service_dir <<< "$service"
        
        if build_service "$service_name" "$service_dir"; then
            ((success_count++))
        else
            print_error "Build failed for $service_name"
            return 1
        fi
    done
    
    if [ $success_count -eq $total_count ]; then
        print_success "All $total_count services built successfully"
        return 0
    else
        print_error "Only $success_count out of $total_count services built"
        return 1
    fi
}

install_binaries() {
    print_status "Installing binaries to $BIN_DIR..."
    
    if [ ! -d "$BIN_DIR" ]; then
        print_error "Installation directory $BIN_DIR not found"
        return 1
    fi
    
    local install_count=0
    for service in "${SERVICES[@]}"; do
        IFS=':' read -r service_name service_dir <<< "$service"
        local source_binary="$BUILD_DIR/bin/$service_name"
        local target_binary="$BIN_DIR/$service_name"
        
        if [ -f "$source_binary" ]; then
            print_status "Installing: $service_name"
            
            cp "$source_binary" "$target_binary"
            
            if [ $? -eq 0 ]; then
                chmod 755 "$target_binary"
                ((install_count++))
                print_success "Installed: $service_name"
            else
                print_error "Failed to install $service_name"
            fi
        else
            print_error "Binary not found: $source_binary"
        fi
    done
    
    if [ $install_count -eq ${#SERVICES[@]} ]; then
        print_success "All binaries installed successfully"
        return 0
    else
        print_error "Only $install_count out of ${#SERVICES[@]} binaries installed"
        return 1
    fi
}

create_install_script() {
    print_status "Creating installation script..."
    
    local install_script="$BUILD_DIR/install-nextram.sh"
    
    cat > "$install_script" << 'EOF'
#!/system/bin/sh

echo "NextRAM Installation Script"
echo "==========================="

BIN_DIR="/system/bin"
BACKUP_DIR="/data/adb/nextram/backup"

mkdir -p "$BACKUP_DIR"

for binary in main-nextram-service-daemon nextramd-zram-service nextramd-swap-service nextramd-kernel-tn-service nextramd-ctl-global; do
    if [ -f "$BIN_DIR/$binary" ]; then
        echo "Backing up existing $binary..."
        cp "$BIN_DIR/$binary" "$BACKUP_DIR/$binary.backup.$(date +%s)"
    fi
done

echo "Installation complete!"
echo "Please restart your device to start using NextRAM services."
EOF
    
    chmod 755 "$install_script"
    print_success "Installation script created: $install_script"
}

show_build_summary() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      Build Summary                           ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    
    for service in "${SERVICES[@]}"; do
        IFS=':' read -r service_name service_dir <<< "$service"
        local binary_path="$BUILD_DIR/bin/$service_name"
        
        if [ -f "$binary_path" ]; then
            local size=$(du -h "$binary_path" | cut -f1)
            echo -e "║  ${GREEN}✓${CYAN} $service_name ($size)${NC}"
        else
            echo -e "║  ${RED}✗${CYAN} $service_name (MISSING)${NC}"
        fi
    done
    
    echo -e "╠══════════════════════════════════════════════════════════════╣"
    echo -e "║  Environment: $ENVIRONMENT${NC}"
    if [ "$ENVIRONMENT" = "pc" ] && [ -n "$NDK_PATH" ]; then
        echo -e "║  Toolchain: Android NDK ($(basename $NDK_PATH))${NC}"
    elif [ "$ENVIRONMENT" = "pc" ]; then
        echo -e "║  Toolchain: System compiler (TESTING ONLY)${NC}"
    else
        echo -e "║  Toolchain: Termux native${NC}"
    fi
    echo -e "║  Build Directory: $BUILD_DIR${NC}"
    echo -e "║  Binaries Location: $BUILD_DIR/bin${NC}"
    echo -e "║  Compiler: $($CXX --version | head -n1)${NC}"
    echo -e "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

cleanup() {
    print_status "Cleaning up..."
    
    if [ -d "$BUILD_DIR" ] && [ "$1" != "keep" ]; then
        rm -rf "$BUILD_DIR"
        print_success "Build directory cleaned"
    fi
}

main() {
    clear
    print_ascii_art
    local start_time=$(date +%s)
    
    case "${1:-}" in
        "clean")
            cleanup
            return 0
            ;;
        "install")
            if install_binaries; then
                local end_time=$(date +%s)
                local duration=$((end_time - start_time))
                print_success "Installation completed in ${duration}s"
            else
                print_error "Installation failed"
                return 1
            fi
            return 0
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo "Commands:"
            echo "  build    - Build all services (default)"
            echo "  install  - Install binaries to system"
            echo "  clean    - Clean build directory"
            echo "  help     - Show this help"
            return 0
            ;;
    esac
    
    print_status "Build started at: $(date)"
    sleep 2
    if ! check_dependencies; then
        print_error "Dependency check failed"
        return 1
    fi
    
    if ! prepare_build_dir; then
        print_error "Failed to prepare build directory"
        return 1
    fi
    
    if ! build_all_services; then
        print_error "Build failed"
        cleanup
        return 1
    fi
    sleep 2
    create_install_script
    show_build_summary
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Build completed successfully in ${duration}s"
}

trap 'print_error "Build interrupted"; cleanup; exit 1' INT TERM

main "$@"
