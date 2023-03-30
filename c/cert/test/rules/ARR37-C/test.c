struct s1 {
  int f1;
  int f2;
  int f3;
  int f4[2];
};

struct s2 {
  int f1;
  int f2;
  int data[];
};

void test_ptr_arithmetic_nested(int *p1) {
  // path-dependent
  int *v1 = p1;
  int *v2 = p1;
  (void)(v1++);
  (void)(v2--);
  (void)(p1 + 1);
  (void)(p1 - 1);
  (void)p1[1];
  (void)(1 [p1]);
  (void)p1[*p1 + 0];
  (void)p1[0 + 1];
  (void)p1[0]; // COMPLIANT
}

void test(struct s1 p1, struct s1 *p2, struct s2 *p3) {
  struct s1 v1[3];
  struct s2 v2[3];

  (void)*(v1 + 2); // COMPLIANT
  (void)*(v1 + 2); // COMPLIANT

  (void)v1[2]; // COMPLIANT
  (void)v2[2]; // COMPLIANT

  (void)((&v1[0].f1)[1]);       // NON_COMPLIANT
  (void)(&v1[0].f1 + v1[1].f1); // NON_COMPLIANT

  (void)(&p1.f1)[1];  // NON_COMPLIANT
  (void)(&p1.f1 + 1); // NON_COMPLIANT
  (void)(&p1.f2 - 1); // NON_COMPLIANT

  (void)(&p1.f1 + p1.f1); // NON_COMPLIANT
  (void)(p1.f4 + 1);      // COMPLIANT
  (void)(&p1.f4 + 1);     // COMPLIANT

  test_ptr_arithmetic_nested((int *)&v1[0].f4); // COMPLIANT
  test_ptr_arithmetic_nested(&v1[0].f1);        // NON_COMPLIANT
}