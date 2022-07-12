class A {
public:
  template <typename T> A(T &); // NON_COMPLIANT
};

class B {
public:
  template <typename T> B(T &&); // NON_COMPLIANT
};

class C {
public:
  C(C &) = default;
  template <typename T> C foo(T &, int i); // COMPLIANT
};

class D {
public:
  D(D &) = default;
  template <typename T> D(T &); // NON_COMPLIANT
};

template <typename T> class E {
public:
  E(T &); // NON_COMPLIANT
};