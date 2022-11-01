void f1() {
  const int a = 3;
  int *aa;

  aa = &a; // NON_COMPLIANT
  *aa = 100;
}

void f1a() {
  const int a = 3;
  int *aa;

  aa = &a; // COMPLIANT
}

void f2() {
  int a = 3;
  int *aa;
  a = 3;

  aa = &a;
  *aa = a;
  *aa = &a;
}

void f4a(int *a) {
  *a = 100; // NON_COMPLAINT
}

void f4b(int *a) {}

void f4() {
  const int a = 100;
  int *p1 = &a; // NON_COMPLIANT
  const int **p2;

  *p2 = &a; // NON_COMPLIANT

  f4a(p1);  // NON_COMPLIANT
  f4a(*p2); // NON_COMPLIANT
}

void f5() {
  const int a = 100;
  int *p1 = &a; // COMPLIANT
  const int **p2;

  *p2 = &a; // COMPLIANT

  f4b(p1);
  f4b(*p2);
}