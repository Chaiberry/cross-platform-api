#pragma once

#include <cstddef>

#if __cplusplus
extern "C" {
#endif

int caAdd(int m, int n);

int caWriteString(char* buffer, size_t buffer_size, const char* string);

#if __cplusplus
}
#endif
