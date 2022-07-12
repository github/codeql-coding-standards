
class A {
public:
  ~A(){}; // NON_COMPLIANT
};

class DerivedA : public A {};

class B {
public:
  virtual ~B(){}; // COMPLIANT
};

class DerivedB : public B {};

class C {
protected:
  ~C(){}; // COMPLIANT
};

class DerivedC : public C {};

class D final {
public:
  ~D(){}; // COMPLIANT
};

class E { // Abstract class assumed to be used as a base class
public:
  ~E(){}; // NON_COMPLIANT
  virtual void f1() = 0;
};