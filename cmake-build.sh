#!/bin/bash

# CMake Build Script for Remote Debug Demo
# Usage: ./cmake-build.sh [debug|release|clean|run|gdb|remote|help]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="RemoteDebugDemo"
BUILD_DIR="build"
SOURCE_DIR="."
DEFAULT_BUILD_TYPE="Debug"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  CMake Build Tool${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to show help
show_help() {
    print_header
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  debug     Build debug version with symbols (default)"
    echo "  release   Build optimized release version"
    echo "  clean     Remove build artifacts"
    echo "  run       Build and run the program"
    echo "  gdb       Build and start gdb debugging"
    echo "  remote    Setup for remote debugging"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 debug"
    echo "  $0 release"
    echo "  $0 clean"
    echo "  $0 run"
    echo ""
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v cmake &> /dev/null; then
        print_error "cmake is not installed"
        exit 1
    fi
    
    if ! command -v g++ &> /dev/null; then
        print_error "g++ is not installed"
        exit 1
    fi
    
    if ! command -v gdb &> /dev/null; then
        print_warning "gdb is not installed - debugging will not work"
    fi
    
    if ! command -v gdbserver &> /dev/null; then
        print_warning "gdbserver is not installed - remote debugging will not work"
    fi
    
    print_status "Dependencies check completed"
}

# Function to configure CMake
configure_cmake() {
    local build_type="$1"
    
    print_status "Configuring CMake for $build_type build..."
    
    if [ ! -d "$BUILD_DIR" ]; then
        mkdir -p "$BUILD_DIR"
    fi
    
    cd "$BUILD_DIR"
    
    cmake -DCMAKE_BUILD_TYPE="$build_type" \
          -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
          -DCMAKE_CXX_FLAGS="-fdiagnostics-color=always" \
          ..
    
    cd ..
    
    print_status "CMake configuration completed"
}

# Function to build project
build_project() {
    local build_type="$1"
    
    print_status "Building $build_type version..."
    
    configure_cmake "$build_type"
    
    cd "$BUILD_DIR"
    make -j$(nproc)
    cd ..
    
    if [ $? -eq 0 ]; then
        print_status "$build_type build completed successfully!"
        print_status "Executable: $BUILD_DIR/bin/debug_demo"
        if [ -f "$BUILD_DIR/bin/debug_demo" ]; then
            print_status "Size: $(du -h $BUILD_DIR/bin/debug_demo | cut -f1)"
        fi
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
        print_status "Removed build directory: $BUILD_DIR"
    else
        print_warning "Build directory does not exist"
    fi
    
    print_status "Clean completed!"
}

# Function to run the program
run_program() {
    local executable="$BUILD_DIR/bin/debug_demo"
    
    if [ ! -f "$executable" ]; then
        print_warning "Executable not found. Building debug version first..."
        build_project "Debug"
    fi
    
    print_status "Running $executable..."
    echo ""
    "$executable"
}

# Function to start gdb debugging
start_gdb() {
    local executable="$BUILD_DIR/bin/debug_demo"
    
    if [ ! -f "$executable" ]; then
        print_warning "Executable not found. Building debug version first..."
        build_project "Debug"
    fi
    
    print_status "Starting gdb debugging..."
    gdb "$executable"
}

# Function to setup remote debugging
setup_remote() {
    local executable="$BUILD_DIR/bin/debug_demo"
    
    if [ ! -f "$executable" ]; then
        print_warning "Executable not found. Building debug version first..."
        build_project "Debug"
    fi
    
    print_status "Setting up remote debugging..."
    echo ""
    echo "On the target machine, run:"
    echo "  gdbserver :1234 $executable"
    echo ""
    echo "On the host machine, run:"
    echo "  gdb"
    echo "  (gdb) target remote target_ip:1234"
    echo "  (gdb) break main"
    echo "  (gdb) continue"
    echo ""
    print_status "Remote debugging setup instructions displayed"
}

# Function to show build info
show_build_info() {
    local executable="$BUILD_DIR/bin/debug_demo"
    
    if [ -f "$executable" ]; then
        print_status "Build information:"
        echo "  Executable: $executable"
        echo "  Size: $(du -h $executable | cut -f1)"
        echo "  Created: $(stat -c %y $executable)"
        echo "  Permissions: $(stat -c %a $executable)"
    else
        print_warning "No executable found. Run build first."
    fi
}

# Function to install project
install_project() {
    print_status "Installing project..."
    
    if [ ! -d "$BUILD_DIR" ]; then
        print_warning "Build directory not found. Building debug version first..."
        build_project "Debug"
    fi
    
    cd "$BUILD_DIR"
    sudo make install
    cd ..
    
    print_status "Installation completed!"
}

# Main script logic
main() {
    # Parse command line arguments
    if [ $# -eq 0 ]; then
        BUILD_TYPE="Debug"
    else
        case "$1" in
            "debug")
                BUILD_TYPE="Debug"
                ;;
            "release")
                BUILD_TYPE="Release"
                ;;
            "clean")
                clean_build
                exit 0
                ;;
            "run")
                run_program
                exit 0
                ;;
            "gdb")
                start_gdb
                exit 0
                ;;
            "remote")
                setup_remote
                exit 0
                ;;
            "install")
                install_project
                exit 0
                ;;
            "help"|"-h"|"--help")
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    fi
    
    # Check dependencies
    check_dependencies
    
    # Build based on type
    build_project "$BUILD_TYPE"
    
    # Show build info
    show_build_info
}

# Run main function with all arguments
main "$@" 