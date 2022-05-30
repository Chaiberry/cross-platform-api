set(TEST SampleTest)

add_executable(${TEST} SampleTest.cpp)

find_package(GTest CONFIG REQUIRED)
target_link_libraries(${TEST} PRIVATE Sample GTest::gmock GTest::gtest GTest::gmock_main GTest::gtest_main)
