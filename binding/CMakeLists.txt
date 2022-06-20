# SWIG related settings

find_package(SWIG REQUIRED)
include(UseSWIG)

if (BUILD_PYTHON)
    add_subdirectory(python)
endif()

if (BUILD_DOTNET)
    add_subdirectory(dotnet)
endif()
