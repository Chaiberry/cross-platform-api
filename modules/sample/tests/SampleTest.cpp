#include <stdio.h>
#include "sample.hpp"
#include "gtest/gtest.h"

TEST(SampleTest, caAdd){
    int val = caAdd(4, 5);
    ASSERT_TRUE(val == 9);
}

TEST(SampleTest, caWriteString){
    char str[100];
    const char* srcString = "hello";
    int val = caWriteString(str, sizeof(str), srcString);
    EXPECT_EQ(val, strlen(srcString));
    for(int i = 0; i < val; i++){
        EXPECT_EQ(str[i], srcString[i]);
    }
}