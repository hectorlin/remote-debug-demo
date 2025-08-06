# Makefile for remote debugging with g++ and gdb

# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -pedantic
DEBUG_FLAGS = -g -O0 -fno-omit-frame-pointer
RELEASE_FLAGS = -O2 -DNDEBUG

# Target executable name
TARGET = debug_demo

# Source files
SOURCES = main.cpp

# Default target
all: debug

# Debug build with symbols
debug: $(SOURCES)
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) -o $(TARGET) $(SOURCES)
	@echo "Debug build completed. Use 'make run' to execute or 'make gdb' to debug."

# Release build
release: $(SOURCES)
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) -o $(TARGET) $(SOURCES)
	@echo "Release build completed."

# Run the program
run: debug
	./$(TARGET)

# Start gdb debugging
gdb: debug
	gdb $(TARGET)

# Remote debugging setup (for gdbserver)
remote-debug: debug
	@echo "Starting gdbserver on port 1234..."
	@echo "On the target machine, run: gdbserver :1234 ./$(TARGET)"
	@echo "On the host machine, run: gdb"
	@echo "Then in gdb: target remote target_ip:1234"

# Clean build artifacts
clean:
	rm -f $(TARGET) *.o
	@echo "Cleaned build artifacts."

# Show help
help:
	@echo "Available targets:"
	@echo "  debug      - Build with debug symbols (default)"
	@echo "  release    - Build optimized release version"
	@echo "  run        - Build and run the program"
	@echo "  gdb        - Build and start gdb debugging"
	@echo "  remote-debug - Setup for remote debugging with gdbserver"
	@echo "  clean      - Remove build artifacts"
	@echo "  help       - Show this help message"

.PHONY: all debug release run gdb remote-debug clean help 