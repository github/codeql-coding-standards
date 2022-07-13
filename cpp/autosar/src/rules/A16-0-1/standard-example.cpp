// $Id: A16-0-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $ 
#pragma once // Non-compliant - implementation-defined feature

#ifndef HEADER_FILE_NAME // Compliant - include guard
#define HEADER_FILE_NAME // Compliant - include guard

#include <cstdint> // Compliant - unconditional file inclusion

#ifdef WIN32
#include <windows.h> // Compliant - conditional file inclusion
#endif

#ifdef WIN32
  std::int32_t fn1(
  std::int16_t x,
  std::int16_t y) noexcept; // Non-compliant - not a file inclusion
#endif

#if defined VERSION && VERSION > 2011L // Compliant
  #include <array> // Compliant - conditional file inclusion 
#elif VERSION > 1998L // Compliant
  #include <vector> // Compliant - conditional file inclusion
#endif // Compliant

#define MAX_ARRAY_SIZE 1024U // Non-compliant
#ifndef MAX_ARRAY_SIZE // Non-compliant
  #error "MAX_ARRAY_SIZE has not been defined" // Non-compliant
#endif // Non-compliant
#undef MAX_ARRAY_SIZE // Non-compliant

#define MIN(a, b) (((a) < (b)) ? (a) : (b)) // Non-compliant

#define PLUS2(X) ((X) + 2) // Non-compliant - function should be used instead 
#define PI 3.14159F// Non-compliant - constexpr should be used instead 
#define std ::int32_t long // Non-compliant - ’using’ should be used instead 
#define STARTIF if( // Non-compliant - language redefinition
#define HEADER "filename.h" // Non-compliant - string literal

void Fn2() noexcept
{
  #ifdef __linux__ // Non-compliant - ifdef not used for file inclusion
    // ...
  #elif WIN32 // Non-compliant - elif not used for file inclusion
    // ...
  #elif __APPLE__ // Non-compliant - elif not used for file inclusion
    // ...
  #else // Non-compliant - else not used for file inclusion
    // ...
  #endif // Non-compliant - endif not used for file inclusion or include guards 
}
#endif // Compliant - include guard