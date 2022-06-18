
set_property(SOURCE Sample.i PROPERTY CPLUSPLUS ON)
set_property(SOURCE Sample.i PROPERTY SWIG_MODULE_NAME pySample)

swig_add_library(pySample
  TYPE SHARED
  LANGUAGE python
  OUTPUT_DIR ${PYTHON_PROJECT_DIR}/Sample
  SOURCES Sample.i)

add_library(${PROJECT_NAMESPACE}::pySample ALIAS pySample)

target_include_directories(pySample
  PRIVATE 
  ../include
  ${Python3_INCLUDE_DIRS}
  )

set_property(TARGET pySample PROPERTY SWIG_USE_TARGET_INCLUDE_DIRECTORIES ON)

if(APPLE)
  set_target_properties(pySample PROPERTIES
    SUFFIX ".so"
    INSTALL_RPATH "@loader_path;@loader_path/../../${PYTHON_PROJECT}/.libs"
    )
  set_property(TARGET pySample APPEND PROPERTY
    LINK_FLAGS "-flat_namespace -undefined suppress"
    )
elseif(UNIX)
  set_target_properties(pySample PROPERTIES
    INSTALL_RPATH "$ORIGIN:$ORIGIN/../../${PYTHON_PROJECT}/.libs"
    )
endif()

target_link_libraries(pySample PRIVATE ${PROJECT_NAMESPACE}::Sample)

if(MSVC)
  target_link_libraries(pySample PRIVATE ${Python3_LIBRARIES})
endif()
