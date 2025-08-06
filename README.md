# Remote Debug Demo with g++ and gdb

This is a simple C++ program designed for remote debugging using g++ and gdb.

## Files

- `main.cpp` - Main source code with debug-friendly features
- `Makefile` - Build configuration with debug targets
- `README.md` - This file

## Quick Start

### Local Development

1. **Build with debug symbols:**
   ```bash
   make debug
   ```

2. **Run the program:**
   ```bash
   make run
   ```

3. **Start local debugging:**
   ```bash
   make gdb
   ```

### Remote Debugging Setup

#### Option 1: Using gdbserver (Recommended)

**On the target machine (remote):**
```bash
# Build the program
make debug

# Start gdbserver
gdbserver :1234 ./debug_demo
```

**On the host machine (local):**
```bash
# Start gdb
gdb

# Connect to remote target
(gdb) target remote target_ip:1234

# Set breakpoints and debug
(gdb) break main
(gdb) break Calculator::add
(gdb) continue
```

#### Option 2: Using gdb remote protocol

**On the target machine:**
```bash
# Build the program
make debug

# Start gdb server mode
gdb --server :1234 ./debug_demo
```

**On the host machine:**
```bash
gdb
(gdb) target remote target_ip:1234
```

## Debug Features in the Code

The `main.cpp` includes several features useful for debugging:

1. **Class with methods** - `Calculator` class for testing object-oriented debugging
2. **Vector operations** - For testing container debugging
3. **Recursive function** - `factorial()` for testing call stack
4. **User input** - Interactive input for testing I/O debugging
5. **Loops and variables** - Multiple debugging scenarios

## Useful GDB Commands

```bash
# Basic debugging
break main                    # Set breakpoint at main
break Calculator::add         # Set breakpoint at class method
break 42                     # Set breakpoint at line 42
info breakpoints             # List all breakpoints
delete 1                     # Delete breakpoint 1

# Execution control
run                          # Start program
continue                     # Continue execution
next                         # Step over (next line)
step                         # Step into (function call)
finish                       # Step out of current function

# Variable inspection
print calc                   # Print variable
print calc.result            # Print member variable
print numbers                # Print vector
print numbers[0]             # Print vector element
info locals                  # Show local variables
info args                    # Show function arguments

# Stack and call trace
bt                           # Backtrace (call stack)
frame 1                      # Switch to frame 1
info frame                   # Show current frame info

# Memory inspection
x/10x &debugVar              # Examine memory as hex
x/10i $pc                    # Examine instructions at PC
```

## Build Options

- `make debug` - Build with debug symbols (default)
- `make release` - Build optimized version
- `make run` - Build and run
- `make gdb` - Build and start gdb
- `make clean` - Clean build artifacts
- `make help` - Show all options

## Troubleshooting

### Common Issues

1. **"No debugging symbols found"**
   - Make sure you built with `make debug` (includes `-g` flag)

2. **"Cannot find gdbserver"**
   - Install gdbserver: `sudo apt-get install gdbserver` (Ubuntu/Debian)
   - Or: `sudo yum install gdb-gdbserver` (RHEL/CentOS)

3. **Connection refused**
   - Check if gdbserver is running on the target
   - Verify port 1234 is not blocked by firewall
   - Try different port: `gdbserver :1235 ./debug_demo`

4. **"Cannot access memory"**
   - This is normal for some variables in optimized builds
   - Use debug build (`make debug`) for better debugging experience

## Advanced Remote Debugging

### Cross-compilation
If debugging on different architectures:

```bash
# Build for target architecture
make CXX=target-g++ debug

# Use appropriate gdb for target
target-gdb
```

### Debugging with VS Code
Create `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Remote Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/debug_demo",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerServerAddress": "target_ip:1234",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
``` 