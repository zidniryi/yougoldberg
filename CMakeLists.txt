cmake_minimum_required(VERSION 3.10)
project(yougoldberg)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(CURL REQUIRED)

# Add executable
add_executable(yougoldberg main.cpp)

# Include directories and link libraries
target_include_directories(yougoldberg PRIVATE ${CURL_INCLUDE_DIRS})
target_link_libraries(yougoldberg ${CURL_LIBRARIES})

# Set compiler flags for better error reporting
target_compile_options(yougoldberg PRIVATE -Wall -Wextra) 