void f(int32_t) {
  reinterpret_cast<void (*)()>(&f); // Non-compliant
  reinterpret_cast<void *>(&f);     // Non-compliant
}