cmake_minimum_required(VERSION 3.14)
project(main CXX)
set(CMAKE_CXX_STANDARD 20)
# set(CMAKE_CXX_CLANG_TIDY "clang-tidy;-checks=*")

# compiler flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  # using Visual Studio C++
    add_compile_options(/W4 /O2 /WX /fsanitize=address)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  # using GCC
    add_compile_options(-Wall -O3 -Wextra -pedantic -Werror -Wshadow-compatible-local)
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  # using Clang
    add_compile_options(-Wall -O3 -Wextra -pedantic -Werror -Wshadow-uncaptured-local)
endif()


add_executable(main src/main.cpp)

target_include_directories(main PUBLIC include)

# find_package(fmt REQUIRED)
# target_link_libraries(main PRIVATE fmt::fmt)

find_package(range-v3 REQUIRED)
target_link_libraries(main PRIVATE range-v3::range-v3)