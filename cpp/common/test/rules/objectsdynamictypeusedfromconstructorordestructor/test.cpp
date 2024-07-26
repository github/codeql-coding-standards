#include <typeinfo>

class Other {
public:
  virtual void foo();
};

class OtherDerived : public Other {
  void foo() override {}
};

class A {
public:
  A() {
    typeid(this);            // COMPLIANT
    typeid(A);               // COMPLIANT
    dynamic_cast<A *>(this); // COMPLIANT
  }

  ~A() {
    typeid(this);                // COMPLIANT
    ((Other *)(nullptr))->foo(); // COMPLIANT
  }
};

class B {
public:
  B() {
    typeid(this);            // NON_COMPLIANT
    dynamic_cast<B *>(this); // NON_COMPLIANT
    f1();                    // NON_COMPLIANT
    B::f1();                 // COMPLIANT
    ctor_method1();
  }

  ~B() {
    ((Other *)(nullptr))->foo(); // COMPLIANT
  }

  void ctor_method1_internal() {
    typeid(this); // NON_COMPLIANT
  }

  void ctor_method1() { ctor_method1_internal(); }

protected:
  virtual void f1();
};

class C : public B {
  C() {
    B::f1(); // COMPLIANT
    ctor_method1_internal();
    typeid(this); // NON_COMPLIANT
  }

  void f1() override {}
};