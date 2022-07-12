void f1() {
  int l1 = 0;
  int l2[3] = {1, 2, 3};

  int l3 = l2[l1] + l1++; // NON_COMPLIANT
  int l4 = l2[l1] + l1;   // COMPLIANT
  l1++;
}

extern int f2(int, int);
void f3() {
  int l1 = 0;
  int l2 = f2(l1++, l1); // NON_COMPLIANT
}

struct S1 {
  void m1(S1 *);
};

void f4(S1 *p1) {
  p1->m1(p1++); // NON_COMPLIANT in C++14 and COMPLIANT since C++17 the
                // expression that names the function is sequenced before every
                // argument expression and every default argument
}

int addc(int *n, int c) { return *n += c; }
void f5(int *p1) { int l1 = addc(p1, 1) + addc(p1, 2); } // NON_COMPLIANT

void f6() {
  int l1 = 0;
  int l2;

  l2 = l1 = l1++; // NON_COMPLIANT
}

void f7() {
  volatile int l1;

  int l2 = l1 + l1; // NON_COMPLIANT, access of a volatile qualified type may
                    // change its value.
}

void f8() {
  int l1;
  addc(&l1, 1); // COMPLIANT
}

void f9(int p1) {
  int l1 = 0;
  int l2[] = {1, 2, 3, 4, 5};

  l2[l1++] = p1; // COMPLIANT
}

void f10(int *p1) {
  *p1++ = 1; // COMPLIANT
  *p1++ = 2; // COMPLIANT
  *p1++ = 3; // COMPLIANT
}