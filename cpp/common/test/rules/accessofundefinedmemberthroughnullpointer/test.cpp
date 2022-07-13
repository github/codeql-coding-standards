struct S1 {
  void f1() {}
  int m1;
};

void f1() {
  S1 *l1 = new S1;
  void (S1::*l2)() = nullptr;
  int S1::*l3 = nullptr;
  (l1->*l2)(); // NON_COMPLIANT
  l1->*l3;     // NON_COMPLIANT

  l2 = &S1::f1;
  l3 = &S1::m1;
  (l1->*l2)(); // COMPLIANT
  l1->*l3;     // COMPLIANT

  delete l1;
}