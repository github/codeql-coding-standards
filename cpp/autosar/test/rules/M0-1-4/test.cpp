/** Test cases for `SingleUseLocalPODVariable.ql` */
#include <array>
class A {};

class B {
public:
  void mf1();
};

void test_unused_local() {
  A a; // ignored - no uses
  B b; // NON_COMPLIANT - only a single use
  b.mf1();
  int i = 0; // NON_COMPLIANT - only used for initialization
}

// Not a POD class
class C {
public:
  void mf1();
  virtual void mf2() {}
};

template <class T> void f1() {
  T t; // NON_COMPLIANT - only used once, but only flagged if T is a POD type
  t.mf1();
}

void test_templates() {
  f1<B>(); // Triggers a NON_COMPLIANT case in f1(), because B is a POD type
  f1<C>(); // Does not trigger a NON_COMPLIANT case in f1(), because C is not a
           // POD type
}

class C1 {
  static constexpr int used{2}; // COMPLIANT
  int test_use() { return used; }
  static constexpr int size{3};               // COMPLIANT
  std::array<bool, size> array{false, false}; // size is used here
};