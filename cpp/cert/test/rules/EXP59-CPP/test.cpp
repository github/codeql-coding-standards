#include <cstddef>

class C1 {
public:
  virtual void f1() = 0;
  int a;
};

class C2 {
public:
  int a;
  int f2() { return 0; }
};

class C3 {
public:
  static int a;
};

class C4 {
public:
  int a : 2;
};

void f1() {
  offsetof(C1, a); // NON_COMPLIANT
  offsetof(C2, a); // COMPLIANT

  //
  // These cases are all not compliant, but do not compile.
  //
  // size_t off3 = offsetof(C3, a);
  // size_t off4 = offsetof(C4, a);
  // size_t off5 = offsetof(C2, f2);
}
