void f() {
  float32_t f32;
  int32_t s32;
  s32 = f32;                         // Non-compliant
  f32 = s32;                         // Non-compliant
  f32 = static_cast<float32_t>(s32); // Compliant
}