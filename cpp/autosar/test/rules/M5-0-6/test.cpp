#include <cstdint>

void test_integral_conversions() {
  using std::int16_t;
  using std::int32_t;
  using std::int8_t;
  int32_t i32;
  int16_t i16;
  int8_t i8;

  i8 = 256;     // NON_COMPLIANT
  i8 = 255 + 1; // NON_COMPLIANT
  i8 = i32;     // NON_COMPLIANT
  i8 = i16;     // NON_COMPLIANT
  i8 = 0; // COMPLIANT - we can prove it is within range so no loss of data
  i8 = static_cast<int8_t>(i16); // COMPLIANT
  i8 = static_cast<int8_t>(i32); // COMPLIANT
}

void test_floating_point_conversions() {
  float f32;
  double f64;

  f32 = 3.5e38;                  // NON_COMPLIANT
  f32 = f64;                     // NON_COMPLIANT
  f32 = static_cast<float>(f64); // COMPLIANT
}