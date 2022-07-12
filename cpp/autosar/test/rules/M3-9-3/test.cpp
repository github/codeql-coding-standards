#include <cstdint>
using std::uint8_t;
float sign(float f) {
  unsigned char *ptr = reinterpret_cast<unsigned char *>(&f);
  *(ptr + 3) &= 0x7F; // NON-COMPLIANT-generate the absolute value

  return (f);
}

float abs2(float f) {
  uint8_t *ptr = (uint8_t *)&f;
  *ptr &= 0x7F;
  return f; // NON-COMPLIANT-generate the absolute value
}
