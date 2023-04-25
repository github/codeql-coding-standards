void f1() {
L1:;
  goto L2; // COMPLIANT
  ;
  goto L1; // NON_COMPLIANT

L2:;
}

void f2() {
L1:;
L2:
  goto L3; // COMPLIANT
  goto L2; // NON_COMPLIANT
L3:
  goto L1; // NON_COMPLIANT
}
