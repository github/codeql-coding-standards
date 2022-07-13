void f() {
  int8_t s8;
  uint8_t u8;
  s8 = static_cast<int8_t>(u8 + u8);                      // Non-compliant
  s8 = static_cast<int8_t>(u8) + static_cast<int8_t>(u8); // Compliant
}