struct S {
  int32_t i;
  int32_t j;
};
void f(S *s) {
  int32_t p = reinterpret_cast<int32_t>(s); // Non-compliant
}
