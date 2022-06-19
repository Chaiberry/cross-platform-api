set(TEST SampleTest)

add_executable(${TEST} SampleTest.cpp)

target_link_libraries(${TEST} PRIVATE Sample GTest::gmock GTest::gtest GTest::gmock_main GTest::gtest_main)

add_test(NAME ${TEST} COMMAND SampleTest)
