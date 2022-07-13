#include <memory>

class A;
class B;
class A1;
class B1;
class A2;

class A {
  std::shared_ptr<B> v1; // NON_COMPLIANT
};

class B {
  std::shared_ptr<A> v1; // NON_COMPLIANT
};

class A1 : A {};

class B1 : B {
  std::shared_ptr<A1> v2; // NON_COMPLIANT
  std::shared_ptr<B> v3;  // NON_COMPLIANT
};

class C : std::shared_ptr<int> { // COMPLIANT
  std::shared_ptr<int> v1;       // COMPLIANT
  std::shared_ptr<A> v2;         // NON_COMPLIANT
};

class D {
  std::shared_ptr<C> v1; // NON_COMPLIANT
};

class E {
  std::shared_ptr<D> v1; // COMPLIANT
};

class F {
  std::shared_ptr<E> v1; // COMPLIANT
};

class A2 : A {
  class SubA2 {
    std::shared_ptr<A> v2; // NON_COMPLIANT
    std::shared_ptr<D> v3; // NON_COMPLIANT
  } b;
};