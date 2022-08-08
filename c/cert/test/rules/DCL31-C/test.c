
extern g; // NON_COMPLIANT

extern int g1; // COMPLIANT

f(void) { // NON_COMPLIANT
  return 1;
}

int f1(void) { // COMPLIANT
  return 1;
}