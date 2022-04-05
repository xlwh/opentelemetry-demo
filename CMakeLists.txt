cmake_minimum_required(VERSION 3.21)
project(opentelemetry_demo)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_C_COMPILER "/usr/bin/clang")
set(CMAKE_CXX_COMPILER "/usr/bin/clang++")
set(THIRDPARTY_DIR "/Users/zhb/workspace/opentelemetry-demo/thirdparty/installed")

# Set include dirs
include_directories(${THIRDPARTY_DIR}/include)

find_library(LIB_OPENTELEMETRY_TRACE opentelemetry_trace HINTS ${THIRDPARTY_DIR}/lib)
add_library(opentelemetry_trace STATIC IMPORTED GLOBAL)
set_target_properties(opentelemetry_trace PROPERTIES IMPORTED_LOCATION "${LIB_OPENTELEMETRY_TRACE}")

find_library(LIB_OPENTELEMETRY_COMMON opentelemetry_common HINTS ${THIRDPARTY_DIR}/lib)
add_library(opentelemetry_common STATIC IMPORTED GLOBAL)
set_target_properties(opentelemetry_common PROPERTIES IMPORTED_LOCATION "${LIB_OPENTELEMETRY_COMMON}")

add_executable(opentelemetry_demo main.cpp)
target_link_libraries(opentelemetry_demo PUBLIC opentelemetry_trace)
target_link_libraries(opentelemetry_demo PUBLIC opentelemetry_common)