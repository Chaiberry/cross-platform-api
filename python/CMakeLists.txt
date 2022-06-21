# Find Python 3
find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
message(STATUS "Python path:${Python3_EXECUTABLE}")

set(PYTHON_PROJECT CrossPlatformApi)
message(STATUS "Python project: ${PYTHON_PROJECT}")
set(PYTHON_PROJECT_DIR ${PROJECT_BINARY_DIR}/python/${PYTHON_PROJECT})
message(STATUS "Python project build path: ${PYTHON_PROJECT_DIR}")

# Find if the python module is available,
# otherwise install it (PACKAGE_NAME) to the Python3 user install directory.
function(search_python_module)
  set(options NO_VERSION)
  set(oneValueArgs NAME PACKAGE)
  set(multiValueArgs "")

  cmake_parse_arguments(MODULE
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  message(STATUS "Searching python module: \"${MODULE_NAME}\"")
  if(${MODULE_NO_VERSION})
    execute_process(
      COMMAND ${Python3_EXECUTABLE} -c "import ${MODULE_NAME}"
      RESULT_VARIABLE _RESULT
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(MODULE_VERSION "unknown")
  else()
    execute_process(
      COMMAND ${Python3_EXECUTABLE} -c "import ${MODULE_NAME}; print(${MODULE_NAME}.__version__)"
      RESULT_VARIABLE _RESULT
      OUTPUT_VARIABLE MODULE_VERSION
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()

  if(${_RESULT} STREQUAL "0")
    message(STATUS "Found python module: \"${MODULE_NAME}\" (found version \"${MODULE_VERSION}\")")
  else()
    if(FETCH_PYTHON_DEPS)
      message(WARNING "Can't find python module: \"${MODULE_NAME}\", install it using pip...")
      execute_process(
        COMMAND ${Python3_EXECUTABLE} -m pip install --user ${MODULE_PACKAGE}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    else()
      message(FATAL_ERROR "Can't find python module: \"${MODULE_NAME}\", please install it using your system package manager.")
    endif()
  endif()
endfunction()

# Find if a python builtin module is available.
function(search_python_internal_module)
  set(options "")
  set(oneValueArgs NAME)
  set(multiValueArgs "")

  cmake_parse_arguments(MODULE
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  message(STATUS "Searching python module: \"${MODULE_NAME}\"")
  execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import ${MODULE_NAME}"
    RESULT_VARIABLE _RESULT
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(${_RESULT} STREQUAL "0")
    message(STATUS "Found python internal module: \"${MODULE_NAME}\"")
  else()
    message(FATAL_ERROR "Can't find python internal module \"${MODULE_NAME}\", please install it using your system package manager.")
  endif()
endfunction()

search_python_module(NAME virtualenv PACKAGE virtualenv)
# venv not working on github windows runners
# search_python_internal_module(NAME venv)
# Testing using a vitual environment
set(VENV_EXECUTABLE ${Python3_EXECUTABLE} -m virtualenv)
#set(VENV_EXECUTABLE ${Python3_EXECUTABLE} -m venv)
set(VENV_DIR ${CMAKE_CURRENT_BINARY_DIR}/python/venv)
if(WIN32)
  set(VENV_Python3_EXECUTABLE ${VENV_DIR}/Scripts/python.exe)
else()
  set(VENV_Python3_EXECUTABLE ${VENV_DIR}/bin/python)
endif()

#######################
## Set Swig flag      #
#######################
set(CMAKE_SWIG_FLAGS)
if(${SWIG_VERSION} VERSION_GREATER_EQUAL 4)
  list(APPEND CMAKE_SWIG_FLAGS "-doxygen")
endif()

# Python related settings for SWIG
list(APPEND CMAKE_SWIG_FLAGS "-py3" "-DPY3")

#######################
## Python sub modules #
#######################
set(PYTHON_SUB_MODULES Sample)

# build sub modules
add_subdirectory(src)

#######################
## Python Packaging  ##
#######################

file(GENERATE OUTPUT ${PYTHON_PROJECT_DIR}/__init__.py CONTENT "__version__ = \"${PROJECT_VERSION}\"\n")
foreach(SUBPROJECT IN ITEMS ${PYTHON_SUB_MODULES})
  file(GENERATE OUTPUT ${PYTHON_PROJECT_DIR}/${SUBPROJECT}/__init__.py CONTENT "")
endforeach()

# setup.py.in contains cmake variable e.g. @PYTHON_PROJECT@ and
# generator expression e.g. $<TARGET_FILE_NAME:pySample>
configure_file(
  ${PROJECT_SOURCE_DIR}/python/setup.py.in
  ${PROJECT_BINARY_DIR}/python/setup.py.in
  @ONLY)

file(GENERATE
  OUTPUT ${PROJECT_BINARY_DIR}/python/setup.py
  INPUT ${PROJECT_BINARY_DIR}/python/setup.py.in)

# Look for python module wheel
search_python_module(NAME setuptools PACKAGE setuptools)
search_python_module(NAME wheel PACKAGE wheel)

add_custom_command(
  OUTPUT ${PROJECT_BINARY_DIR}/python/dist/timestamp
  COMMAND ${CMAKE_COMMAND} -E remove_directory dist
  COMMAND ${CMAKE_COMMAND} -E make_directory ${PYTHON_PROJECT}/.libs
  COMMAND ${CMAKE_COMMAND} -E $<IF:$<STREQUAL:$<TARGET_PROPERTY:Sample,TYPE>,SHARED_LIBRARY>,copy,true>
  $<$<STREQUAL:$<TARGET_PROPERTY:Sample,TYPE>,SHARED_LIBRARY>:$<TARGET_SONAME_FILE:Sample>>
  ${PYTHON_PROJECT}/.libs
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:pySample> ${PYTHON_PROJECT}/Sample
  COMMAND ${Python3_EXECUTABLE} setup.py bdist_wheel
  COMMAND ${CMAKE_COMMAND} -E touch ${PROJECT_BINARY_DIR}/python/dist/timestamp
  MAIN_DEPENDENCY
    ${PROJECT_BINARY_DIR}/python/setup.py.in
  DEPENDS
    ${PROJECT_BINARY_DIR}/python/setup.py
    ${PROJECT_NAMESPACE}::Sample
    ${PROJECT_NAMESPACE}::pySample
  BYPRODUCTS
    python/${PYTHON_PROJECT}
    python/${PYTHON_PROJECT}.egg-info
    python/build
    python/dist
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/python
  COMMAND_EXPAND_LISTS)

# Main Target
add_custom_target(python_package ALL
  DEPENDS ${PROJECT_BINARY_DIR}/python/dist/timestamp
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/python)

# make a virtualenv to install our python package in it
add_custom_command(TARGET python_package POST_BUILD
  # Clean previous install otherwise pip install may do nothing
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${VENV_DIR}
  COMMAND ${VENV_EXECUTABLE} -p ${Python3_EXECUTABLE} ${VENV_DIR}
  #COMMAND ${VENV_EXECUTABLE} ${VENV_DIR}
  # Must NOT call it in a folder containing the setup.py otherwise pip call it
  # (i.e. "python setup.py bdist") while we want to consume the wheel package
  COMMAND ${VENV_Python3_EXECUTABLE} -m pip install --find-links=${CMAKE_BINARY_DIR}/python/dist ${PYTHON_PROJECT}
  BYPRODUCTS ${VENV_DIR}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/python
  COMMENT "Create venv and install ${PYTHON_PROJECT}"
  VERBATIM)

add_subdirectory(tests)
