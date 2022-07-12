struct S {
  long int i;
  long int j;
};

void f(S *s) {
  int p = reinterpret_cast<long long int>(s); // NON_COMPLIANT
  int p1 = reinterpret_cast<long int>(&s->i); // NON_COMPLIANT
}