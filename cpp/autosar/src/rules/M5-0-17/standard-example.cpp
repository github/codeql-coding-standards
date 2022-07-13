void f1() {
  int32_t a1[10];
  int32_t a2[10];
  int32_t *p1 = &a1[1];
  int32_t *p2 = &a2[10];
  int32_t diff;
  diff = p1 - a1; // Compliant
  diff = p2 - a2; // Compliant
  diff = p1 - p2; // Non-compliant
}