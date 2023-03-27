void f1(int p1) {

l1:
  if (p1) {
    goto l2; // COMPLIANT
  }
  goto l1; // NON_COMPLIANT

l2:;
}

void f2(int p1) {

l1:;
l2:
  if (p1) {
    goto l3; // COMPLIANT
  }
  goto l2; // NON_COMPLIANT
l3:
  goto l1; // NON_COMPLIANT
}

void f3() {
l1:
  goto l1; // NON_COMPLIANT
}