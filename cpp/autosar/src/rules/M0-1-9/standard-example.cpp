int16_t has_dead_code(int16_t para) {
  int16_t local = 99;
  para = para + local;
  local = para;     // dead code – Non-compliant
  if (0 == local) { // dead code – Non-compliant
    local++;        // dead code – Non-compliant
  }                 // dead code – Non-compliant
  return para;
}