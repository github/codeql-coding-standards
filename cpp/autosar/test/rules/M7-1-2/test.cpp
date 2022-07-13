#include <string>
void f(int *p,                // COMPLIANT
       const int *p1,         // COMPLIANT
       int *p2,               // NON_COMPLIANT
       int *const p3,         // NON_COMPLIANT
       const int *const p4) { // COMPLIANT

  *p = *p1 + *p2 + *p3 + *p4;
}

class A {
public:
  int m;
  int *p;
  int f1() const { return m; }
  void f2() { m++; }
};

void f1(A &a) { // NON_COMPLIANT
  int l = a.f1();
}

void f2(A *a) { // COMPLIANT
  a->f2();
}

void f3(A *a) { // COMPLIANT
  // not an interesting case to report
  int l;
}

void f4(A *a) { // COMPLIANT
  f3(a);
}

void f5(std::string &p1) { // COMPLIANT
  char &front = p1.front();
  front = 'a';
}

int *f6(int *i) { // COMPLIANT
  // not focused on also reporting which return types to const
  return i;
}

struct B {
  A a;
};

void f7(A *a) { // NON_COMPLIANT
  B b;
  b.a = *a;
}

void f8(int *i) { // COMPLIANT
  A a1;
  a1.p = i;
}