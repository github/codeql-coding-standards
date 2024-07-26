int f() { return 42; }

void test_reinterpret_cast() {
  // NON_COMPLIANT
  void (*fp1)() = reinterpret_cast<void (*)()>(f);
  // NON_COMPLIANT
  int (*fp2)() = reinterpret_cast<int (*)()>(fp1);
}
