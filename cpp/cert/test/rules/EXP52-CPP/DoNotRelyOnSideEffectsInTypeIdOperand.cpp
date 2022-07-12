#include <typeinfo>

int f1() { return 0; }

const std::type_info &til1 = typeid(int);  // COMPLIANT
const std::type_info &til2 = typeid(f1()); // NON_COMPLIANT

class A {
  virtual int m1() { return 0; }
};

class B {
public:
  static A *m1() { return nullptr; }
  static int m2() { return 1; }
};

B b;

const std::type_info &til3 = typeid(b);       // COMPLIANT
const std::type_info &til4 = typeid(B::m1()); // NON_COMPLIANT
const std::type_info &til5 = typeid(B::m2()); // NON_COMPLIANT

void f2(const char *p);

#define m(x)                                                                   \
  do {                                                                         \
    const std::type_info &l1 = typeid(x);                                      \
    f2(l1.name());                                                             \
  } while (0)

void f3() {
  m(B::m1()); // COMPLIANT, side effect happens in macro that doesn't rely on
              // its value
}