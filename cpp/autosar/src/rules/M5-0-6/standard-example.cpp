void f() {
  int32_t s32;
  int16_t s16;
  s16 = s32;                       // Non-compliant
  s16 = static_cast<int16_t>(s32); // Compliant
}