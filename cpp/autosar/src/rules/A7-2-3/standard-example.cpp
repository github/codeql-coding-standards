// $Id: A7-2-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>

enum E1 : std::int32_t // Non-compliant
{ E10,
  E11,
  E12 };

enum class E2 : std::int32_t // Compliant
{ E20,
  E21,
  E22 };

// static std::int32_t E1_0 = 5; // E1_0 symbol redeclaration, compilation
// error

static std::int32_t e20 = 5; // No redeclarations, no compilation error

extern void F1(std::int32_t number) {}

void F2() {
  F1(0);

  F1(E11); // Implicit conversion from enum to std::int32_t type
  // f1(E2::E2_1); // Implicit conversion not possible, compilation error

  F1(static_cast<std::int32_t>(E2::E21)); // Only explicit conversion allows to
  // pass E2_1 value to f1() function
}