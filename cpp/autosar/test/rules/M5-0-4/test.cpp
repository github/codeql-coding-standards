#include <cstdint>

void f() {
  using std::int16_t;
  using std::uint16_t;

  int16_t s16;
  uint16_t u16;

  s16 = u16;                              // NON_COMPLIANT
  s16 = s16 + u16;                        // NON_COMPLIANT
  s16 = static_cast<int16_t>(s16) + u16;  // NON_COMPLIANT
  u16 = static_cast<uint16_t>(s16);       // COMPLIANT
  u16 = static_cast<uint16_t>(s16) + u16; // COMPLIANT
}