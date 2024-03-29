cmake_minimum_required(VERSION 3.9)

set(VER_MAJOR "0")
set(VER_MINOR "0")
set(VER_REVISION "1")
set(VER_STRING "${VER_MAJOR}.${VER_MINOR}.${VER_REVISION}")

project(CrossPlatformApi VERSION ${VER_STRING} LANGUAGES C CXX)
message(STATUS "${PROJECT_NAME} version: ${PROJECT_VERSION} with CMake ${CMAKE_VERSION}")

set(PROJECT_GROUP_ID ChaiBerry)
set(PROJECT_ARTIFACT_ID ${PROJECT_NAME})

set(PROJECT_NAMESPACE ${PROJECT_NAME})

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
cmake_policy(SET CMP0122 NEW)

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

# Need swig to build Python/Dotnet/Java
find_package(SWIG REQUIRED)
include(UseSWIG)

# Enable testing
enable_testing()

#################################################
# C/C++ build
#################################################
# Compilation flag
include(CompilerFlags)

# Include directories
add_subdirectory(cpp)

# Python
if (BUILD_PYTHON)
  add_subdirectory(python)
endif()

# Dotnet
if (BUILD_DOTNET)
  add_subdirectory(dotnet)
endif()

# Java
if (BUILD_JAVA)
  add_subdirectory(java)
endif()
