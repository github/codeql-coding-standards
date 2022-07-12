class A {
public:
  A();                   // constructor
  A &operator=(const A); // destructor
};

class B {
public:
  B();          // constructor
  B(const B &); // copy constructor
};

void test() {
  A a1;
  A a2(a1); // NON_COMPLIANT

  B b1;
  B b2(b1); // COMPLIANT
}