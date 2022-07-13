class A { // COMPLIANT
  virtual void a() {}
};

class A1 : A {}; // COMPLIANT

class B { // COMPLIANT
  virtual void b() {}
};

class BB {}; // COMPLIANT

struct B1 {}; // COMPLIANT

struct B2 : B {}; // NON-COMPLIANT - virtual function in base class.

struct B3 : BB { // NON-COMPLIANT - first non-static member is a base class
  B b;
};
