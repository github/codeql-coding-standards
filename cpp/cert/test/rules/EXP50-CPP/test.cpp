#include <iostream>
#include <utility>

int g1 = 0;
int g2[] = {0, 1, 2, 3};

void f1() {
  g1 = ++g1 +
       1; // NON_COMPLIANT, g1 is modified twice in the same full expression
  g2[g1++] = g1; // NON_COMPLIANT, the side effect on g1 (i.e., post increment)
                 // is unsequenced relative to the value computation of g1 and
                 // thus undefined behavior
  g1 = g1 + 1;   // COMPLIANT, g1 is modified once in the same full expression
  g1 += g1++;    // NON_COMPLIANT
  g1 = g1 +=
      1 + 1; // NON_COMPLIANT; g1 is modified twice in the same full expression
}

void f2(int p1, int p2);
void f3(int p1) {
  f2(p1++, p1); // NON_COMPLIANT, the side effect on p1 (i.e., post increment)
                // is unsequenced relative to the value computation of p1 and
                // thus undefined behavior.
}

void f4(int p1) {
  std::cout << p1++ << p1
            << '\n'; // NON_COMPLIANT, calls the overloaded operator<< and
                     // these have the same restrictions regarding
                     // sequencing of arguments as function calls.
}

int f5() { return ++g1; }

int f6() {
  g1 = 1;
  return g1;
}

int f7() { return f6(); }

struct S1 {
  int l1;
  static int l2;
  S1() : l1(0) {}
  int m1() { return ++l1; }
  int m2() { return ++l2; }
};

int S1::l2 = 0;

class C {
public:
  C() : l1(0) {}

  int m1() { return ++this->l1; }

private:
  int l1;
};

int f8(int *p) { return ++(*p); }
int f8(int &p) { return ++p; }

int f9(int *p) {
  *p = 0;
  return *p;
}

int f9(int &p) {
  p = 0;
  return p;
}

int f10() { return f5() + 1; }

int f11(int *p) { return f8(p) + 1; }

int f11(int &p) { return f8(p) + 1; }

void f12() {
  f2(f5(), f6()); // NON_COMPLIANT, order of evaluation for function arguments
  // is unspecified.
  f2(f5(), f7()); // NON_COMPLIANT, order of evaluation for function arguments
                  // is unspecified.
  S1 l1, l2;
  f2(l1.m1(), l1.m1()); // NON_COMPLIANT
  f2(l1.m1(), l2.m1()); // COMPLIANT
  f2(l1.m2(), l2.m2()); // NON_COMPLIANT

  int i;
  f2(f8(&i), f9(&i));  // NON_COMPLIANT
  f2(f8(&i), f11(&i)); // NON_COMPLIANT

  f2(f8(i), f9(i));  // NON_COMPLIANT
  f2(f8(i), f11(i)); // NON_COMPLIANT

  C c1, c2;
  f2(c1.m1(), c1.m1()); // NON_COMPLIANT
  f2(c1.m1(), c2.m1()); // COMPLIANT
}