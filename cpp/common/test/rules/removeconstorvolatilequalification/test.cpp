class C {
public:
  explicit C(int) {}
};

volatile int *f2();

void f(const char *str) {
  C const l = C(10);
  C *l1 = const_cast<C *>(&l); // NON_COMPLIANT
  C *l2 = (C *)&l;             // NON_COMPLIANT
  C l3 = l;                    // COMPLIANT
  const C *l8 = (const C *)&l; // COMPLIANT

  *(const_cast<char *>(str)) = '\0'; // NON_COMPLIANT

  volatile int *l4 = f2();         // COMPLIANT
  int *l5 = const_cast<int *>(l4); // NON_COMPLIANT
  int *l6 = (int *)l4;             // NON_COMPLIANT
  int *l7 = (int *)f2();           // NON_COMPLIANT
}