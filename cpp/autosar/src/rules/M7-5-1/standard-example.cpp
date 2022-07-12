int32_t *fn1(void) {
  int32_t x = 99;
  return (&x); // Non-compliant
}
int32_t *fn2(int32_t y) {
  return (&y); // Non-compliant
}
int32_t &fn3(void) {
  int32_t x = 99;
  return (x); // Non-compliant
}
int32_t &fn4(int32_t y) {
  return (y); // Non-compliant
}
int32_t *fn5(void) {
  static int32_t x = 0;
  return &x; // Compliant
}