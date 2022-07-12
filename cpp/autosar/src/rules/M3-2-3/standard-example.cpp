// header.hpp
extern int16_t a;
// file1.cpp
#include "header.hpp"
extern int16_t b;
// file2.cpp
#include "header.hpp"
extern int32_t b;   // Non-compliant - compiler may not detect the error
int32_t a;          // Compliant     - compiler will detect the error