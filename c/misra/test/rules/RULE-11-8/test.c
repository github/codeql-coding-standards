int f1(void) {
  const volatile char *const a = 0;
  const volatile char *b = (const volatile char *)a; // COMPLIANT
  const char *c = (const char *)b;                   // NON_COMPLIANT
  const char *c2 = (const char *)c;                  // COMPLIANT
  char *d = (char *)c;                               // NON_COMPLIANT
  const char *e = (const char *)d;                   // COMPLIANT
  return 0;
}