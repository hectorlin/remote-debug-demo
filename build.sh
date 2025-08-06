#!/bin/bash

# Build script for Remote Debug Demo
# Usage: ./build.sh [debug|release|clean|run|help]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="debug_demo"
SOURCE_FILE="main.cpp"
COMPILER="g++"
CXX_STANDARD="c++11"

# Default build type
BUILD_TYPE="debug"

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
    echo -e "${BLUE}  Remote Debug Demo Build Tool${NC}"
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
    
    if ! command -v $COMPILER &> /dev/null; then
        print_error "$COMPILER is not installed"
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

# Function to build debug version
build_debug() {
    print_status "Building debug version..."
    
    local flags="-std=$CXX_STANDARD -g -O0 -Wall -Wextra -pedantic -fno-omit-frame-pointer"
    
    $COMPILER $flags -o $PROJECT_NAME $SOURCE_FILE
    
    if [ $? -eq 0 ]; then
        print_status "Debug build completed successfully!"
        print_status "Executable: $PROJECT_NAME"
        print_status "Size: $(du -h $PROJECT_NAME | cut -f1)"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to build release version
build_release() {
    print_status "Building release version..."
    
    local flags="-std=$CXX_STANDARD -O2 -DNDEBUG -Wall -Wextra"
    
    $COMPILER $flags -o $PROJECT_NAME $SOURCE_FILE
    
    if [ $? -eq 0 ]; then
        print_status "Release build completed successfully!"
        print_status "Executable: $PROJECT_NAME"
        print_status "Size: $(du -h $PROJECT_NAME | cut -f1)"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    
    local files_to_remove=(
        "$PROJECT_NAME"
        "main"
        "*.o"
        "*.out"
        "*.exe"
    )
    
    for pattern in "${files_to_remove[@]}"; do
        if ls $pattern 2>/dev/null; then
            rm -f $pattern
            print_status "Removed: $pattern"
        fi
    done
    
    print_status "Clean completed!"
}

# Function to run the program
run_program() {
    if [ ! -f "$PROJECT_NAME" ]; then
        print_warning "Executable not found. Building debug version first..."
        build_debug
    fi
    
    print_status "Running $PROJECT_NAME..."
    echo ""
    ./$PROJECT_NAME
}

# Function to start gdb debugging
start_gdb() {
    if [ ! -f "$PROJECT_NAME" ]; then
        print_warning "Executable not found. Building debug version first..."
        build_debug
    fi
    
    print_status "Starting gdb debugging..."
    gdb $PROJECT_NAME
}

# Function to setup remote debugging
setup_remote() {
    if [ ! -f "$PROJECT_NAME" ]; then
        print_warning "Executable not found. Building debug version first..."
        build_debug
    fi
    
    print_status "Setting up remote debugging..."
    echo ""
    echo "On the target machine, run:"
    echo "  gdbserver :1234 ./$PROJECT_NAME"
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
    if [ -f "$PROJECT_NAME" ]; then
        print_status "Build information:"
        echo "  Executable: $PROJECT_NAME"
        echo "  Size: $(du -h $PROJECT_NAME | cut -f1)"
        echo "  Created: $(stat -c %y $PROJECT_NAME)"
        echo "  Permissions: $(stat -c %a $PROJECT_NAME)"
    else
        print_warning "No executable found. Run build first."
    fi
}

# Main script logic
main() {
    # Parse command line arguments
    if [ $# -eq 0 ]; then
        BUILD_TYPE="debug"
    else
        case "$1" in
            "debug")
                BUILD_TYPE="debug"
                ;;
            "release")
                BUILD_TYPE="release"
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
    case "$BUILD_TYPE" in
        "debug")
            build_debug
            ;;
        "release")
            build_release
            ;;
        *)
            print_error "Unknown build type: $BUILD_TYPE"
            exit 1
            ;;
    esac
    
    # Show build info
    show_build_info
}

# Run main function with all arguments
main "$@" 