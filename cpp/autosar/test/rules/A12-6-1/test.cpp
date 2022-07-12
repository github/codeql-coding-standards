class A {
public:
  int a;
  int b;
  int c;

  A(int a, int b) { // NON_COMPLIANT
    this->a = a;
    { this->b = b; }
  }

  A(int a) : a(a) { // NON_COMPLIANT
    this->a = a;
    { this->b = 1000; }
  }
};

class B {
public:
  int a;
  int b;

  B(int a, int b) { // NON_COMPLIANT
    this->a = a;
    { this->b = b; }
  }

  B(int a) : a(a) { // NON_COMPLIANT
    this->a = a;
    { this->b = 1000; }
  }
};

class C {
public:
  int a;
  int b;
  int c;

  C(int a, int b) : a(a), b(b) {
    this->a = a;
    { this->b = b; }
  }

  C(int a) : a(a), b(1), c(1) {
    this->a = a;
    { this->b = 1000; }
  }
};