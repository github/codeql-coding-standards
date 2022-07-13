class A {
public:
  int a;
  A() {} // NON_COMPLIANT
  A(int a) {}
  A(const A &a) {}
};

class B : A {
public:
  int b;
  B(int b) : A(b) { this->b = b; }

  B(const B &b) : A(b), b(b.b) {} // NON_COMPLIANT
};

class C : A {
public:
  int b;
  C(int b) : A(b) { this->b = b; }

  C(const C &b) {}

  ~C() { int a; }
};

class D : A {
public:
  int b;
  D() noexcept {}
  D(int b) : b(b) { this->b = b; }

  D(const D &b) : b(b.b), A(b) { // NON_COMPLIANT
  }

  ~D() {} // NON_COMPLIANT
};

class E : A {
public:
  E &operator=(E &&) = default; // COMPLIANT
  ~E() = default;               // COMPLIANT
};

class F : A {
public:
  F &operator=(F &&f) { return f; }   // NON_COMPLIANT
  F &operator=(F o) { return *this; } // NON_COMPLIANT
};

class G : A {
public:
  int a;
  int b;
  G &operator=(G o) { // NON_COMPLIANT
    this->a = o.a;
    this->b = o.b;
    return *this;
  }
};

class H : A {
public:
  int a;
  int b;
  H &operator=(H &&h); // COMPLIANT
  H &operator=(H o);   // COMPLIANT
};

class I : A {
public:
  I &operator=(I &&i); // COMPLIANT
  I &operator=(I o);   // COMPLIANT
};
