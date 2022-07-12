namespace test {
class A {
public:
  int m1; // ignored - 0 uses
  int m2; // NON_COMPLIANT - one use, in an explicit constructor field init
  int m3; // NON_COMPLIANT - used once in setm3
  int m4; // NON_COMPLIANT - used once is setm4
  int m5; // COMPLIANT - set and read
  A(int x, int y) : m2(x), m5(y) {}
  void setm3(int x) { m3 = x; }
  int getm5() { return m5; }
};

void setm4(A *a) { a->m4 = 0; }

void test_nested_struct() {
  struct s1 {
    int sm1 : 7; // NON_COMPLIANT - used only once
    int pad : 1; // ignored - never used
    int sm2 : 6; // ignored - never used
    int : 2;     // ignored - never used
  } l1;
  l1.sm1; // use of `sm1`
  l1;     // second use of `l1` (to avoid flagging l1 for local case)
}

class B {
public:
  int m1; // ignored, f1 is not defined and may also access `m1`
  void f1(int m1);
  int f2() { return m1; }
};

class C {
protected:
  int m1; // NON_COMPLIANT - used only once
  int m2; // NON_COMPLIANT - used only once in sub-class
  int m3; // COMPLIANT - used once here, once in subclass
  int f1() { return m1; }
  virtual void f2() = 0; // pure virtual function, so consider to be defined
  int f3() { return m3; }
};

class D : C {
  virtual void f2() {
    m2;
    m3;
  }
};

template <class T> class E {
public:
  T m1; // ignored - unused
  T m2; // COMPLIANT - used twice
  T m3; // NON_COMPLIANT - used once, but only flagged if T is a POD type
  E(T p1, T p2) : m2(p1), m3(p2) {}
  T getT() { return m2; }
};

void test_e() { // Ensure that the template E is fully instantiated
  B b;
  E<B> e = E<B>(
      b,
      b); // B is a POD type, so E<B> is a POD type. This template instantiation
          // should therefore trigger the m3 NON_COMPLIANT case in E.
  e.getT();

  D d;
  E<D> e2 = E<D>(
      d, d); // S is not a POD type, so E<D> is not a POD type. This template
             // instantiation should therefore not trigger any results.
  e2.getT();
}

} // namespace test