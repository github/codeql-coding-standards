
class A {
public:
  int a() { return 3; } // COMPLIANT

  int b();

  int getB();

  int getABar() { return 9; }

  int trivial() { // NON_COMPLIANT
    ;
    ;
    ;
    ;
    return 0;
  }

  template <typename T> T c(T t) { return t; } // COMPLIANT

  template <typename T> T d(T t);

  int complexCalculation();

  int gcd(int a, int b) {
    if (b == 0)
      return a;
    int result = gcd(b, (a % b));
    ;
    return result;
  }

  void foo(int i) { this->i = i; } // COMPLIANT
  int bar1() { return this->i; }   // COMPLIANT
  int bar2() { return i; }         // COMPLIANT

private:
  int i;
};

inline int A::complexCalculation() { // COMPLIANT
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  return 1;
}

int A::getB() { return 1; } // NON_COMPLIANT

template <typename T> T A::d(T t) { return t; } // NON_COMPLIANT

int A::b() { return 3; } // NON_COMPLIANT

template <typename C> class B {
public:
  int a() { return 3; } // COMPLIANT

  int b();

  int getB();

  int getABar() { return 9; } // COMPLIANT

  template <typename T> T c(T t) { return t; } // COMPLIANT

  template <typename T> T d(T t);

  int complexCalculation();
};

template <typename C> inline int B<C>::complexCalculation() { // NON_COMPLIANT
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  ;
  return 1;
}

template <typename C> template <typename T> T B<C>::d(T t) { // NON_COMPLIANT
  return t;
}

template <typename C> int B<C>::b() { // NON_COMPLIANT
  C c;
  return 3;
}

template <typename C> int B<C>::getB() { return 3; } // NON_COMPLIANT

template <typename T> class Foo {
public:
  virtual void operator()(const T &) = 0; // COMPLIANT
};

class C {
public:
  C() {}

  C &operator=(const C &) = delete;
};

class FooBar {
public:
  ~FooBar();
  int f1(int a, int b);
};

FooBar::~FooBar() {} // COMPLIANT want to ignore pImpl uses of destructors

int FooBar::f1(int a, int b) { // COMPLIANT not a trivial function
  while (true) {
    if (b == 0)
      return a;
    int result = FooBar::f1(b, (a % b));
    ;
  }
}
