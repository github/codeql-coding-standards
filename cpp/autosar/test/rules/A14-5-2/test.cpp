template <typename T> class template_base {
public:
  using type = T; // COMPLIANT
};                // used for testing

template <typename T> class C1 {
public:
  enum E1 : T { e1, e2 }; // COMPLIANT

  using T1 = typename template_base<T>::type;   // COMPLIANT[FALSE_POSITIVE]
  using T2 = typename template_base<int>::type; // NON_COMPLIANT

  class C11 { // COMPLIANT
    enum E2 {
      e3,
      e4
    }; // Not checked for compliance since it's not a template class.

    enum E3 : T {
      e5,
      e6
    }; // Not checked for compliance since it's not a template class.

    T a1;   // Not checked for compliance since it's not a template class.
    int a2; // Not checked for compliance since it's not a template class.
  };

  template <typename N> class C12 { // NON_COMPLIANT
    N a;                            // COMPLIANT
  };
};

template <typename T> class C2 {
public:
  enum E1 : T { e1, e2 }; // COMPLIANT

  template <typename N> class C22 { // COMPLIANT
  public:
    enum E2 : N { // COMPLIANT
      e3,
      e4
    };
    class C222 : N, T {}; // COMPLIANT

    T a1;   // NON_COMPLIANT
    int a2; // NON_COMPLIANT

    void f0() {}    // NON_COMPLIANT
    void f1(T i) {} // NON_COMPLIANT
    void f2(N i) {} // COMPLIANT

    void f3(T i, N j) {}              // COMPLIANT
    T f4(N j) { return 1; }           // COMPLIANT
    void f5() { template_base<T> t; } // NON_COMPLIANT
    void f6() { template_base<N> t; } // COMPLIANT

    void f7() { // COMPLIANT
      template_base<T> t;
      template_base<N> n;
    }
  };

  void f0() {}                      // NON_COMPLIANT
  void f1(T i) {}                   // COMPLIANT
  T f2() { return 1; }              // COMPLIANT
  void f3() { template_base<T> t; } // COMPLIANT
  void f4() {                       // COMPLIANT
    struct f44 {
      template_base<T> t;
    };

    f44 a;
  }
};

template <typename T> class C3 {
public:
  class C31 { // COMPLIANT - not a template class, but must still reference the
              // outer template

    T a1;   // Not checked for compliance since it's not a template class.
    int a2; // Not checked for compliance since it's not a template class.

    class C311 { // Not checked for compliance since it's not a template class.
    };
  };
};

class Base {};

template <class T1, class T3> class A {
public:
  T3 t3;                        // COMPLIANT
  T1 t1;                        // COMPLIANT
  template <class T2> class B { // NON_COMPLIANT
  public:
    T2 t2;           // COMPLIANT
    class X : T2 {}; // COMPLIANT
    X x;             // COMPLIANT
    int b;           // NON_COMPLIANT
  };
  int a; // NON_COMPLIANT
};

void f1() {
  C1<int> a;
  C2<int> b;
  C2<int>::C22<int> bb;
  b.f0();
  b.f1(1);
  b.f2();
  b.f3();
  b.f4();

  bb.f0();
  bb.f1(1);
  bb.f2(1);
  bb.f3(1, 1);
  bb.f4(1);
  bb.f5();
  bb.f6();
  bb.f7();
}

void f2() {
  A<int, int> a;
  A<int, int>::B<Base> b;
  A<int, int>::B<Base>::X c;
}

template <typename T> class Value {
public:
  bool m;                         // NON_COMPLIANT
  bool less(const Value *other) { // COMPLIANT
    return m < static_cast<const Value<T> *>(other)->m;
  }
};

void f3() {
  Value<int> v;
  v.less(&v);
}

class J final {
public:
  enum Type { A, B, C };
};

template <J::Type t> class V {
public:
  J::Type type() const { // COMPLIANT[FALSE_POSITIVE]
    return t;
  }
};

void f4() {
  V<J::Type::A> v;
  v.type();
}