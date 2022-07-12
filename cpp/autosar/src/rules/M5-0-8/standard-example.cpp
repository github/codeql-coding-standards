void f() {
  int16_t s16;
  int32_t s32;
  s32 = static_cast<int32_t>(s16 + s16); // Non-compliant
  s32 = static_cast<int32_t>(s16) + s16; // Compliant
}