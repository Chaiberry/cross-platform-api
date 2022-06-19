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
