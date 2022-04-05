cmake_minimum_required(VERSION 3.21)
project(opentelemetry_demo)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_C_COMPILER "/usr/bin/clang")
set(CMAKE_CXX_COMPILER "/usr/bin/clang++")
set(THIRDPARTY_DIR "/Users/zhb/workspace/opentelemetry-demo/thirdparty/installed")

# Set include dirs
include_directories(${THIRDPARTY_DIR}/include)

add_library(opentelemetry_trace STATIC IMPORTED GLOBAL)
set_target_properties(opentelemetry_trace PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib/libopentelemetry_trace.a)

add_library(opentelemetry_common STATIC IMPORTED GLOBAL)
set_target_properties(opentelemetry_common PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib/libopentelemetry_common.a)

add_library(opentelemetry_exporter_ostream_span STATIC IMPORTED GLOBAL)
set_target_properties(opentelemetry_exporter_ostream_span PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib/libopentelemetry_exporter_ostream_span.a)

add_library(opentelemetry_resources STATIC IMPORTED GLOBAL)
set_target_properties(opentelemetry_resources PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib/libopentelemetry_resources.a)

add_executable(opentelemetry_demo main.cpp tracer.cpp tracer.h)
target_link_libraries(opentelemetry_demo PUBLIC opentelemetry_trace)
target_link_libraries(opentelemetry_demo PUBLIC opentelemetry_common)
target_link_libraries(opentelemetry_demo PUBLIC opentelemetry_exporter_ostream_span)
target_link_libraries(opentelemetry_demo PUBLIC opentelemetry_resources)