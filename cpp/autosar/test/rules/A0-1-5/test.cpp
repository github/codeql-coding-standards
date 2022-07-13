// dummy function to show `x` is used
void use(int x);

class A {
  void f0(int x) {}        // not virtual, not covered by this rule
  virtual void f1(int x) { // COMPLIANT - default implementation uses the param
    use(x);
  }
  virtual void f2(int x) = 0; // NON_COMPLIANT
  virtual void f3(int x);     // NON_COMPLIANT
  virtual void f4(int);   // COMPLIANT -parameter is not named, and therefore
                          // not required to be used
  virtual void f5(int x); // COMPLIANT - used in Class C
};

void A::f3(int) {} // Not reported, because this location is not named

class B : A {
  virtual void f2(int x) { // NON_COMPLIANT - parameter named and unused
  }
  virtual void f3(int) { // COMPLIANT - parameter is not named, and therefore
                         // not required to be used
  }
  virtual void f4(int) { // COMPLIANT - parameter is not named, and therefore
                         // not required to be used
  }
};

class C : B {
  virtual void f5(int x) { // COMPLIANT - parameter is used
    use(x);
  }
};
// dummy function to show `t` is used
template <class T> void useT(T t);

template <class T> class D {
public:
  virtual void f6(T t) { useT(t); } // COMPLIANT
  virtual void f7(T t) = 0;         // COMPLIANT
  virtual void f8(T t) = 0;         // NON_COMPLIANT
  virtual void f9(T t) = 0;         // COMPLIANT
};

template <class T> class E : D<T> {
public:
  virtual void f7(T t) { useT(t); } // COMPLIANT
  virtual void f8(T t) {}           // NON_COMPLIANT
  virtual void f9(T t) { useT(t); } // COMPLIANT
};

// Create at least one instantiation of the template, otherwise we consider all
// the parameters to be unused
void test_instantiation() {
  // Instantiate the template, otherwise implementations of the function are not
  // created
  E<C> e;
  C c;
  e.f7(c);
}