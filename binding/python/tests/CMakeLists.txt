# add_python_test()
function(add_python_test FILE_NAME)
    message(STATUS "Configuring test ${FILE_NAME} ...")

    get_filename_component(EXAMPLE_NAME ${FILE_NAME} NAME_WE)
    add_test(
        NAME python_test_${EXAMPLE_NAME}
        COMMAND ${VENV_Python3_EXECUTABLE} ${FILE_NAME}
        WORKING_DIRECTORY ${VENV_DIR})

    message(STATUS "Configuring test ${FILE_NAME} done")
endfunction()

add_subdirectory(Sample)
