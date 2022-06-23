set_property(SOURCE Sample.i PROPERTY CPLUSPLUS ON)
set_property(SOURCE Sample.i PROPERTY COMPILE_OPTIONS
  -package ${JAVA_PACKAGE}.Sample)

swig_add_library(jniSample
  TYPE OBJECT
  LANGUAGE java
  OUTPUT_DIR ${JAVA_PROJECT_DIR}/${JAVA_SRC_PATH}/Sample
  SOURCES Sample.i)

set_target_properties(jniSample PROPERTIES
  SWIG_INCLUDE_DIRECTORIES ${PROJECT_SOURCE_DIR}/java
  SWIG_USE_TARGET_INCLUDE_DIRECTORIES ON
  POSITION_INDEPENDENT_CODE ON)

target_include_directories(jniSample PRIVATE ${JNI_INCLUDE_DIRS})
target_include_directories(jniSample PRIVATE ${PROJECT_SOURCE_DIR}/cpp/Sample/include)

target_link_libraries(jniSample PRIVATE ${PROJECT_NAMESPACE}::Sample)
