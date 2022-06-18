# SWIG related settings

set(CMAKE_SWIG_FLAGS)
find_package(SWIG REQUIRED)
include(UseSWIG)

if(${SWIG_VERSION} VERSION_GREATER_EQUAL 4)
  list(APPEND CMAKE_SWIG_FLAGS "-doxygen")
endif()

# Python related settings for SWIG
list(APPEND CMAKE_SWIG_FLAGS "-py3" "-DPY3")

