//% $Id: A3-9-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
void F() {
  std::int32_t i1 = 5;   // Compliant
  int i2 = 10;           // Non-compliant
  std::int64_t i3 = 250; // Compliant
  long int i4 = 50;      // Non-compliant
  std::int8_t i5 = 16;   // Compliant
  char i6 = 23;          // Non-compliant
}