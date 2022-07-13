extern void f1();
void f2(int p1, int p2) {
  if (p1 > 0 && p1 < 10) { // NON_COMPLIANT
    f1();
  }

  if ((p1 > 0) || p2 > 0) { // NON_COMPLIANT
    f1();
  }

  if ((p1 > 0) && (p1 < 10)) { // COMPLIANT
    f1();
  }

  if ((p1 > 0) || (p2 > 0)) { // COMPLIANT
    f1();
  }
}