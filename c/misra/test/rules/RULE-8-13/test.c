int f1(int *p) { // NON_COMPLIANT
  return *p;
}

int f2(const int *p) { // COMPLIANT
  return *p;
}

int f3(int *const p) { // NON_COMPLIANT
  return *p;
}

int f4(int a[5]) { // NON_COMPLIANT
  int b = a[0];
  return b;
}

int f5(const int a[5]) { // COMPLIANT
  return a[0];
}

int f6(int a[5]) { // COMPLIANT
  a[2] = a[1];
  return a[0];
}

int f7(int *p1) { // COMPLIANT
  int *v1 = p1;   // NON_COMPLIANT
  return v1[0];
}

int f8(int *p1) { // COMPLIANT
  int *v1 = 0;    // NON_COMPLIANT
  int *v2 = p1;   // NON_COMPLIANT
  return v1[0];
}

int f9(int *p1) { // COMPLIANT
  int *v1 = p1;   // COMPLIANT
  *v1 = 0;
  return v1[0];
}

int f10(int *p1) { // COMPLIANT
  return f8(p1);
}

int f11(int *p1) { // NON_COMPLIANT
  return f2(p1);
}

char *f12(char *p1) { // NON_COMPLIANT
  return p1;
}

char *const f13(char *const p1) { // NON_COMPLIANT
  return p1;
}

char *f14(char *p1) { // NON_COMPLIANT
  int v1 = p1[0] + 1;
  char *v2 = 0; // NON_COMPLIANT
  return v2;
}

const char *f15(char *p1) { // NON_COMPLIANT
  const char *v1 = p1;      // COMPLIANT
  return v1;
}

char *f16(char *p1) { // NON_COMPLIANT
  return ++p1;
}

int f17(char *p1) { // NON_COMPLIANT
  p1++;
  return 0;
}