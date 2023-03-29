void foo(int, int);

void unsequenced_sideeffects1() {
  volatile int l1, l2;

  int l3 = l1 + l1; // NON_COMPLIANT
  int l4 = l1 + l2; // NON_COMPLIANT

  // Store value of volatile object in temporary non-volatile object.
  int l5 = l1;
  // Store value of volatile object in temporary non-volatile object.
  int l6 = l2;
  int l7 = l5 + l6; // COMPLIANT

  int l8, l9;
  l1 = l1 & 0x80;      // COMPLIANT
  l8 = l1 = l1 & 0x80; // NON_COMPLIANT

  foo(l1, l2); // NON_COMPLIANT
  // Store value of volatile object in temporary non-volatile object.
  l8 = l1;
  // Store value of volatile object in temporary non-volatile object.
  l9 = l2;
  foo(l8, l9);   // COMPLIANT
  foo(l8++, l8); // NON_COMPLIANT

  int l10 = l8++, l11 = l8++; // COMPLIANT
}

int g1[], g2[];
#define test(i) (g1[i] = g2[i])
void unsequenced_sideeffects2() {
  int i;
  for (i = 0; i < 10; i++) {
    test(i++); // NON_COMPLIANT
  }
}