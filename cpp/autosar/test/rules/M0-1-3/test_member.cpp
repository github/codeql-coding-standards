namespace test {
class A {
public:
  int m1; // NON_COMPLIANT - unused
  int m2; // COMPLIANT - initialized in constructor
  int m3; // COMPLIANT - written in method
  int m4; // COMPLIANT - written outside class
  A(int x) : m2(x) {}
  void setm3(int x) { m3 = x; }
};

void setm4(A *a) { a->m4 = 0; }

void test_nested_struct() {
  struct s1 {
    int sm1 : 7; // COMPLIANT - used
    int pad : 1; // NON_COMPLIANT - padding bytes, so not used, but is not
                 // unnamed
    int sm2 : 6; // NON_COMPLIANT - unused
    int : 2;     // COMPLIANT - unnamed padding bytes
  } l1;
  l1.sm1; // use of `sm1`
}

class B {
  int m1; // ignored, f1 is not defined and may access `m1`
  void f1();
};

class C {
  int m1;                // NON_COMPLIANT - unused
  virtual void f1() = 0; // pure virtual function, so consider to be defined
};

template <class T> class D {
public:
  T m1; // NON_COMPLIANT[FALSE_NEGATIVE] - unused, but excluded because of
        // templates
  T m2; // COMPLIANT - used
  D(T p1) : m2(p1) {}
  T getT() { return m2; }
};

void test_d() {
  B b;
  D<B> d = D<B>(b);
  d.getT();
}

} // namespace test