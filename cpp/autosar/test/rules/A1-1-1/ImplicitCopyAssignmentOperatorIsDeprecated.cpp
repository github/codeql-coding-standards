class A {
public:
  A();
  A(const A &); // copy constructor
};

class C {
public:
  C();
  C(const C &);    // copy constructor
  C &operator=(C); // copy-assignment operator
};

void test() {
  A a1, a2;
  C c1, c2;

  a2 = a1; // NON_COMPLIANT
  c2 = c1; // COMPLIANT
}