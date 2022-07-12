void f() {
  int8_t s8;
  uint8_t u8;
  s8 = u8;                            // Non-compliant
  u8 = s8 + u8;                       // Non-compliant
  u8 = static_cast<uint8_t>(s8) + u8; // Compliant
}