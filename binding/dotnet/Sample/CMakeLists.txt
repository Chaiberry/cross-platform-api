set_property(SOURCE Sample.i PROPERTY CPLUSPLUS ON)
set_property(SOURCE Sample.i PROPERTY COMPILE_OPTIONS
  -namespace ${DOTNET_PROJECT}.Sample
  -dllimport ${PROJECT_GROUP_ID}-${PROJECT_ARTIFACT_ID}-native)
 
swig_add_library(dotnet_Sample
  TYPE OBJECT
  LANGUAGE csharp
  OUTPUT_DIR ${DOTNET_PROJECT_DIR}/Sample
  SOURCES Sample.i)

set_target_properties(dotnet_Sample PROPERTIES
  SWIG_INCLUDE_DIRECTORIES ${PROJECT_SOURCE_DIR}/dotnet
  SWIG_USE_TARGET_INCLUDE_DIRECTORIES ON
  POSITION_INDEPENDENT_CODE ON)

target_include_directories(dotnet_Sample
  PRIVATE 
  ../include)

target_link_libraries(dotnet_Sample PRIVATE ${PROJECT_NAMESPACE}::Sample)
