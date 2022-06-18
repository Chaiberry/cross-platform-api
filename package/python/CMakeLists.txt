#######################
## Python sub modules #
#######################
set(PYTHON_SUB_MODULES Sample)

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
  ${PROJECT_SOURCE_DIR}/package/python/setup.py.in
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
  WORKING_DIRECTORY python)
