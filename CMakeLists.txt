cmake_minimum_required(VERSION 3.21)
project(opentelemetry_demo)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_C_COMPILER "/usr/bin/clang")
set(CMAKE_CXX_COMPILER "/usr/bin/clang++")

set(THIRDPARTY_DIR "/Users/zhb/workspace/opentelemetry-demo/thirdparty/installed")
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(PIC_LIB_PATH "${THIRDPARTY_DIR}")

# Add common cmake prefix path and link library path
list(APPEND CMAKE_PREFIX_PATH ${THIRDPARTY_DIR}/lib64/cmake)
link_directories(${THIRDPARTY_DIR}/lib64)

add_library(opentelemetry-cpp STATIC IMPORTED)
set_target_properties(opentelemetry-cpp PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libhttp_client_curl.a)
set_target_properties(opentelemetry-cpp PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_common.a)
set_target_properties(opentelemetry-cpp PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_trace.a)
set_target_properties(opentelemetry-cpp PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_metrics.a)
set_target_properties(opentelemetry-cpp PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_exporter_ostream_span.a)
set_target_properties(opentelemetry-cpp PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_resources.a)

#target_link_libraries(opentelemetry-cpp)

# Set include dirs
include_directories(
        ${THIRDPARTY_DIR}/include
)

add_executable(opentelemetry_demo main.cpp)
