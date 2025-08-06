cmake_minimum_required(VERSION 3.10)

# Project name and version
project(RemoteDebugDemo VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set default build type to Debug if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Compiler flags
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -Wall -Wextra -pedantic -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG -Wall -Wextra")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -Wall -Wextra")

# Enable testing
enable_testing()

# Find required packages
find_package(Threads REQUIRED)

# Source files
set(SOURCES
    main.cpp
)

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Set target properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "debug_demo"
    DEBUG_POSTFIX ""
    RELEASE_POSTFIX "_release"
)

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Threads::Threads
)

# Compiler-specific settings
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(${PROJECT_NAME} PRIVATE
        -fdiagnostics-color=always
        -fno-omit-frame-pointer
    )
endif()

# Debug configuration
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        DEBUG
        _DEBUG
    )
    
    # Add debug symbols
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(${PROJECT_NAME} PRIVATE
            -g3
            -ggdb
        )
    endif()
endif()

# Release configuration
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        NDEBUG
        RELEASE
    )
endif()

# Install rules
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Install configuration files
install(FILES
    README.md
    Makefile
    build.sh
    DESTINATION share/${PROJECT_NAME}
)

# Install VS Code configuration
install(DIRECTORY .vscode/
    DESTINATION share/${PROJECT_NAME}/.vscode
    FILES_MATCHING PATTERN "*.json"
)

# Custom targets for debugging
add_custom_target(debug-build
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config Debug
    COMMENT "Building debug version"
)

add_custom_target(release-build
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config Release
    COMMENT "Building release version"
)

add_custom_target(clean-build
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
    COMMENT "Cleaning build artifacts"
)

# Custom target to run the program
add_custom_target(run
    COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/${PROJECT_NAME}
    DEPENDS ${PROJECT_NAME}
    COMMENT "Running ${PROJECT_NAME}"
)

# Custom target for gdb debugging
add_custom_target(gdb-debug
    COMMAND gdb ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/${PROJECT_NAME}
    DEPENDS ${PROJECT_NAME}
    COMMENT "Starting gdb debugging"
)

# Custom target for remote debugging setup
add_custom_target(remote-setup
    COMMAND ${CMAKE_COMMAND} -E echo "Remote debugging setup:"
    COMMAND ${CMAKE_COMMAND} -E echo "On target machine: gdbserver :1234 ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/${PROJECT_NAME}"
    COMMAND ${CMAKE_COMMAND} -E echo "On host machine: gdb"
    COMMAND ${CMAKE_COMMAND} -E echo "(gdb) target remote target_ip:1234"
    COMMAND ${CMAKE_COMMAND} -E echo "(gdb) break main"
    COMMAND ${CMAKE_COMMAND} -E echo "(gdb) continue"
    DEPENDS ${PROJECT_NAME}
    COMMENT "Remote debugging setup instructions"
)

# Print configuration information
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "C++ flags: ${CMAKE_CXX_FLAGS}")
message(STATUS "C++ flags (Debug): ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "C++ flags (Release): ${CMAKE_CXX_FLAGS_RELEASE}")
message(STATUS "Output directory: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")

# VS Code configuration files are already present
# No need to configure them from templates 