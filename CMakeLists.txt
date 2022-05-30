cmake_minimum_required(VERSION 3.9)

set(VER_MAJOR "0")
set(VER_MINOR "0")
set(VER_REVISION "1")
set(VER_STRING "${VER_MAJOR}.${VER_MINOR}.${VER_REVISION}")

project(CrossPlatformApi VERSION ${VER_STRING} LANGUAGES C CXX)
message(STATUS "${PROJECT_NAME} version: ${PROJECT_VERSION} with CMake ${CMAKE_VERSION}")

set(PROJECT_GROUP_ID chaiberry.github.com)
set(PROJECT_ARTIFACT_ID CrossPlatformApi)

set(PROJECT_NAMESPACE CrossPlatformApi)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(ProjectUtils)

get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(isMultiConfig)
  if(NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING
    "Choose the type of builds, options are: Debug Release RelWithDebInfo MinSizeRel. (default: Release;Debug)"
    FORCE)
  endif()
  message(STATUS "Configuration types: ${CMAKE_CONFIGURATION_TYPES}")
else()
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING
    "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel. (default: Release)"
    FORCE)
  endif()
  message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
endif()

# Define the output location for various file types
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

# for multi-config builds (e.g. msvc)
foreach(OutputConfig IN LISTS CMAKE_CONFIGURATION_TYPES)
    string(TOLOWER ${OutputConfig} OUTPUTCONFIG)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_LIBDIR})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_LIBDIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_BINDIR})
endforeach()

# CMake policies
cmake_policy(SET CMP0078 NEW)
cmake_policy(SET CMP0079 NEW)
cmake_policy(SET CMP0086 NEW)

# CMake options
option(BUILD_DOTNET "Build .NET Library" OFF)
message(STATUS "Build .Net: ${BUILD_DOTNET}")
option(BUILD_JAVA "Build Java Library" OFF)
message(STATUS "Build Java: ${BUILD_JAVA}")
option(BUILD_PYTHON "Build Python Library" OFF)
message(STATUS "Build Python: ${BUILD_PYTHON}")

option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(BUILD_TESTING "Build tests" ON)

PrintProjectSettings()

# Enable testing
enable_testing()

#################################################
# C/C++ build
#################################################
# Compilation flag
include(CompilerFlags)

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)
add_subdirectory(modules)

# tests
# add_subdirectory(tests)