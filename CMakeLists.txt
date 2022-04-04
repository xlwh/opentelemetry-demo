cmake_minimum_required(VERSION 3.21)
project(opentelemetry_demo)

set(CMAKE_CXX_STANDARD 14)

set(THIRDPARTY_DIR "/Users/zhb/workspace/opentelemetry-demo/thirdparty/installed")
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(PIC_LIB_PATH "${THIRDPARTY_DIR}")

# Add common cmake prefix path and link library path
list(APPEND CMAKE_PREFIX_PATH ${THIRDPARTY_DIR}/lib/cmake)
list(APPEND CMAKE_PREFIX_PATH ${THIRDPARTY_DIR}/lib64/cmake)
link_directories(${THIRDPARTY_DIR}/lib ${THIRDPARTY_DIR}/lib64)


add_library(opentelemetry-cpp STATIC IMPORTED)
set_target_properties(opentelemetry-cpp::version PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_version.a)
set_target_properties(opentelemetry-cpp::common PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_common.a)
set_target_properties(opentelemetry-cpp::trace PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_trace.a)
set_target_properties(opentelemetry-cpp::metrics PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_metrics.a)
set_target_properties(opentelemetry-cpp::ostream_span_exporter PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_exporter_ostream_span.a)
set_target_properties(opentelemetry-cpp::resources PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libopentelemetry_resources.a)
set_target_properties(opentelemetry-cpp::http_client_curl PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib64/libhttp_client_curl.a)

# Set include dirs
include_directories(
        BEFORE
        ${SRC_DIR}/formats/orc/apache-orc/c++/include/
)
include_directories(
        ${THIRDPARTY_DIR}/include
)

add_executable(opentelemetry_demo main.cpp)
