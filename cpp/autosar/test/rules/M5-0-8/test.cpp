#include <cstdint>
void f() {
  using std::int16_t;
  using std::int32_t;
  using std::int8_t;

  int8_t i8;
  int16_t i16;
  int32_t i32;
  i32 = static_cast<int32_t>(i16 + i8);  // NON_COMPLIANT
  i32 = static_cast<int32_t>(i16 + i16); // NON_COMPLIANT
  i16 = static_cast<int16_t>(1 + 1);     // NON_COMPLIANT
  i8 = static_cast<int8_t>(1 + 1);       // COMPLIANT
  i32 = static_cast<int32_t>(i16) + i16; // COMPLIANT
  i32 = static_cast<int32_t>(i16) + i8;  // COMPLIANT

  // In this test `float` is 4 bytes and `double` is 8 bytes.
  float f32;
  double f64;

  f64 = static_cast<double>(f32 + 1);     // NON_COMPLIANT
  f64 = static_cast<double>(1.0f + 1.0f); // NON_COMPLIANT
  f32 = static_cast<float>(1.0f + 1);     // COMPLIANT
  f64 = static_cast<double>(1.0 + 1); // COMPLIANT; no suffix defines a double
}