#include <typeinfo>

int f1() { return 0; }

const std::type_info &til1 = typeid(int);  // COMPLIANT
const std::type_info &til2 = typeid(f1()); // NON_COMPLIANT

class A {
  virtual int f1() { return 0; }
};

class B {
public:
  static A *f1() { return nullptr; }
  static int f2() { return 1; }
};

B b;

const std::type_info &til3 = typeid(b);       // COMPLIANT
const std::type_info &til4 = typeid(B::f1()); // NON_COMPLIANT
const std::type_info &til5 = typeid(B::f2()); // NON_COMPLIANT