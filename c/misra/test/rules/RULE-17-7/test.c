void f1() {}
int f2() { return 0; }

int t1() {
  f1();
  f2();         // NON_COMPLIANT
  (void)f2();   // COMPLIANT
  int a = f2(); // COMPLIANT
  a = f2();     // COMPLIANT

  void (*fp1)(void) = &f1;
  int (*fp2)(void) = &f2;

  (*f1)();       // COMPLIANT
  (*f2)();       // NON_COMPLIANT
  (void)(*f2)(); // COMPLIANT
  a = (*f2)();   // COMPLIANT
}