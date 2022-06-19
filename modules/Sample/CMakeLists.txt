# For C/C++ build

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

add_subdirectory(src)
add_subdirectory(tests)

# Python binding
add_subdirectory(python)
