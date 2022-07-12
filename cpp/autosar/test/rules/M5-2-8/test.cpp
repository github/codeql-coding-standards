struct S {
  int i;
  int j;
};

void f(void *v, int i) {
  S *s1 = reinterpret_cast<S *>(v); // NON_COMPLIANT
  S *s2 = reinterpret_cast<S *>(i); // NON_COMPLIANT
}