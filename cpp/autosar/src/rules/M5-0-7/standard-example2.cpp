// Float to Integral
void f2() {
  float32_t f32a;
  float32_t f32b;
  float32_t f32c;
  int16_t s16a;
  // The following performs floating-point division
  s16a = static_cast<int16_t>(f32a / f32b); // Non-compliant
  // The following also performs floating-point division
  f32c = f32a / f32b;
  s16a = static_cast<int16_t>(f32c); // Compliant
  // The following performs integer division
  s16a = static_cast<int16_t>(f32a) / f32b; // Compliant
}