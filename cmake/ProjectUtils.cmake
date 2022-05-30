
function(PrintProjectSettings)
    message(STATUS "CMAKE_SYSTEM_NAME:${CMAKE_SYSTEM_NAME}")
    if(APPLE)
        message(STATUS "CMAKE_OSX_ARCHITECTURES:${CMAKE_OSX_ARCHITECTURES}")
    else()
        message(STATUS "CMAKE_SYSTEM_PROCESSOR:${CMAKE_SYSTEM_PROCESSOR}")
    endif()
    message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR:${CMAKE_HOST_SYSTEM_PROCESSOR}")
    message(STATUS "CMAKE_INSTALL_PREFEX=${CMAKE_INSTALL_PREFIX}")
endfunction()
