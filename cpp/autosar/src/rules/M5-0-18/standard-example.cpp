void f1() {
  int32_t a1[10];
  int32_t a2[10];
  int32_t *p1 = a1;
  if (p1 < a1) // Compliant
  {
  }
  if (p1 < a2) // Non-compliant
  {
  }
}