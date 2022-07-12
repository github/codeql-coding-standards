// Integral to Float
void f1() {
  int16_t s16a;
  int16_t s16b;
  int16_t s16c;
  float32_t f32a;
  // The following performs integer division
  f32a = static_cast<float32_t>(s16a / s16b); // Non-compliant
  // The following also performs integer division
  s16c = s16a / s16b;
  f32a = static_cast<float32_t>(s16c); // Compliant
  // The following performs floating-point division
  f32a = static_cast<float32_t>(s16a) / s16b; // Compliant
}