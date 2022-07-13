struct S {
  int32_t i;
  int32_t j;
};
void f(void *v, int32_t i) {
  S *s1 = reinterpret_cast<S *>(v); // Non-compliant
  S *s2 = reinterpret_cast<S *>(i); // Non-compliant
}