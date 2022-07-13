void f(int) {
  reinterpret_cast<void (*)()>(&f); // NON_COMPLIANT
  reinterpret_cast<void *>(&f);     // NON_COMPLIANT
}