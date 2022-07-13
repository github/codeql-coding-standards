#include <cstdint>

void f1() {
  using std::int16_t;
  using std::int32_t;
  using std::int8_t;

  int16_t s16a;
  int16_t s16b;
  int16_t s16c;
  float f32a;
  float f32b;

  f32a = static_cast<float>(s16a / s16b); // NON_COMPLIANT
  f32a = static_cast<float>(s16c);        // COMPLIANT
  f32a = static_cast<float>(s16a) / s16b; // COMPLIANT

  s16a = static_cast<int16_t>(f32a / f32b); // NON_COMPLIANT
  s16a = static_cast<int16_t>(f32a);        // COMPLIANT
  s16a = static_cast<int16_t>(f32a) / f32b; // COMPLIANT
}