void f1(const int32_t *a1) {
  int32_t a2[10];
  const int32_t *p1 = &a1[1]; // Non-compliant – a1 not an array
  int32_t *p2 = &a2[10];      // Compliant
  int32_t *p3 = &a2[11];      // Non-compliant
}
void f2() {
  int32_t b;
  int32_t c[10];
  f1(&b);
  f1(c);
}