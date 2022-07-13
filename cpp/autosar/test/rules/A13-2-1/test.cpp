class A {
public:
  A &operator=(const A &oth) { // COMPLIANT
    return *this;
  }
};

class B {
public:
  const B &operator=(const B &oth) { // NON_COMPLIANT
    return *this;
  }
};

class C {
public:
  const C operator=(const C &oth) { // NON_COMPLIANT
    return *this;
  }
};

class D {
public:
  const D *operator=(const D &oth) { // NON_COMPLIANT
    return this;
  }
};