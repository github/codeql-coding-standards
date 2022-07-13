class A {};

class B {
  virtual bool foo() { return false; }
};

class C : public B {};

class D : public A, public C {
  virtual bool foo() { return true; }
};

void f() {
  A a;
  B b;
  C c;
  D d;

  auto cast1 = reinterpret_cast<D const *>(&a); // NON_COMPLIANT
  auto cast2 = reinterpret_cast<D const *>(&b); // NON_COMPLIANT
  auto cast3 = reinterpret_cast<C const *>(&b); // NON_COMPLIANT
  auto cast4 = reinterpret_cast<A const *>(&d); // COMPLIANT
  auto cast5 = reinterpret_cast<B const *>(&c); // COMPLIANT
  auto cast6 = reinterpret_cast<B const *>(&d); // COMPLIANT
}