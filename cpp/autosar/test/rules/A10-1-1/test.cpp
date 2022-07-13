class A {
  int m1;
};
class B {
  int m2;
};
class C : A {};    // COMPLIANT
class D : B, A {}; // NON_COMPLIANT
class E {
public:
  virtual void foo1() = 0;
};
class F {
public:
  virtual void foo2() = 0;
};
class G : public E, public F {};       // COMPLIANT
class H : public E, public A {};       // COMPLIANT
class I : public E, public F, B, A {}; // NON_COMPLIANT