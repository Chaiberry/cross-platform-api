#include "sample.hpp"
#include <cstdio>

int caAdd(int m, int n)
{
    return m + n;
}

int caWriteString(char* buffer, size_t buffer_size, const char* string)
{
    return snprintf(buffer, buffer_size, string);
}
