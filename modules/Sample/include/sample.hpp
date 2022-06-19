#pragma once

#include <cstddef>

#if __cplusplus
extern "C" {
#endif

/**
 * \brief Adds two numbers.
 *
 * This function takes two numbers, adds them, and then returns the result.
 *
 * \param m The first number to add.
 * \param n The second number to add.
 * \return The sum of the two numbers.
 */
int caAdd(int m, int n);

int caWriteString(char* buffer, size_t buffer_size, const char* string);

#if __cplusplus
}
#endif
