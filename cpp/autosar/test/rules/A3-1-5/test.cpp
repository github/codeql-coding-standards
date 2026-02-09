
class A {
public:
  int a() { return 3; } // COMPLIANT

  int b();

  int getB();

  int getABar() { return 9; }

  int not_trivial() { // COMPLIANT - with threshold of 10 loc
    ;
    ;
    ;
    ;
    return 0;
  }

  template <typename T> T c(T t) { return t; } // COMPLIANT

  template <typename T> T d(T t);

  int complexCalculation();

  int gcd(int a, int b) { // NON_COMPLIANT
    if (b == 0)
      return a;
    int result = gcd(b, (a % b));
    ;
    ;
    ;
    ;
    ;
    ;
    ;
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

int A::getB() { return 1; } // COMPLIANT

template <typename T> T A::d(T t) { return t; } // COMPLIANT

int A::b() { return 3; } // COMPLIANT

template <typename C> class B {
public:
  int a() { return 3; } // COMPLIANT

  int b();

  int getB();

  int getABar() { return 9; } // COMPLIANT

  template <typename T> T c(T t) { return t; } // COMPLIANT

  template <typename T> T d(T t);

  int complexCalculation();

  int complexCalculation2() { // COMPLIANT - template
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
};

void test_B() {
  B<int> b;
  b.complexCalculation2();
}

template <typename C> inline int B<C>::complexCalculation() { // COMPLIANT
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

template <typename C> template <typename T> T B<C>::d(T t) { // COMPLIANT
  return t;
}

template <typename C> int B<C>::b() { // COMPLIANT
  C c;
  return 3;
}

template <typename C> int B<C>::getB() { return 3; } // COMPLIANT

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

  template <typename C> int complexCalculation() { // COMPLIANT - template
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
};

void test_FooBar() {
  FooBar foobar;
  foobar.complexCalculation<int>();
}

FooBar::~FooBar() {} // COMPLIANT want to ignore pImpl uses of destructors

int FooBar::f1(int a, int b) { // COMPLIANT not a trivial function
  while (true) {
    if (b == 0)
      return a;
    int result = FooBar::f1(b, (a % b));
    ;
    ;
    ;
    ;
    ;
    ;
    ;
    ;
  }
}