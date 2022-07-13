int16_t with_unreach(int16_t para) {
  int16_t local;
  local = 0;
  switch (para) {
    local = para; // unreachable – Non-compliant
  case 1: {
    break;
  }
  default: {
    break;
  }
  }
  return para;
  para++; // unreachable – Non-compliant
}
