set(C_STANDARD 11)
set(CXX_STANDARD 11)

message(STATUS "Target processor: ${CMAKE_SYSTEM_PROCESSOR}")

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
endif()

if (EMSCRIPTEN)
  message(STATUS "Building with Emscripten")
endif()

if (APPLE)
  include(XCodeFlags)
Endif()