#include <cstdint>
#include <string>
#include <utility>
int foo() { return 1; }

void test_c_style_cast() {
  double f = 3.14;
  std::uint32_t n1 = (std::uint32_t)f; // NON_COMPLIANT - C-style cast
  std::uint32_t n2 = unsigned(f);      // COMPLIANT[FALSE_POSITIVE]

  std::uint8_t n3 = 1;
  std::uint8_t n4 = 1;
  std::uint8_t n5 = n3 + n4; // ignored, implicit casts

  (void)foo(); // NON_COMPLIANT
}

class A {
public:
  virtual void f1() {}
};

class B : A {
public:
  virtual void f1() {}
};

class C {
  void f1() {}
};

void test_cpp_style_cast() {
  // These cases may contravene other rules, but are marked as COMPLIANT for
  // this rule
  A a1;
  const A *a2 = &a1;
  A *a3 = const_cast<A *>(a2);      // COMPLIANT
  B *b = dynamic_cast<B *>(a3);     // COMPLIANT
  C *c = reinterpret_cast<C *>(a3); // COMPLIANT
  std::int16_t n8 = 0;
  std::int32_t n9 = static_cast<std::int32_t>(n8); // COMPLIANT
  static_cast<void>(foo());                        // COMPLIANT
}

class A5_2_2a {
public:
  template <typename... As>
  static void Foo(const std::string &name, As &&...rest) {
    Fun(Log(
        std::forward<As>(rest)...)); // COMPLIANT - reported as a false positive
  }

  template <typename... As> static std::string Log(As &&...tail) {
    return std::string();
  }

  static void Fun(const std::string &message) {}
};

class A5_2_2 final {
public:
  void f(const std::string &s) const { A5_2_2a::Foo("name", "x", "y", "z"); }
};

void a5_2_2_test() {
  A5_2_2 a;
  a.f("");
}

#define ADD_ONE(x) ((int)x) + 1
#define NESTED_ADD_ONE(x) ADD_ONE(x)
#define NO_CAST_ADD_ONE(x) x + 1

#include "macro_c_style_casts.h"

void test_macro_cast() {
  ADD_ONE(1);         // NON_COMPLIANT - expansion of user-defined macro creates
                      // c-style cast
  NESTED_ADD_ONE(1);  // NON_COMPLIANT - expansion of user-defined macro creates
                      // c-style cast
  LIBRARY_ADD_TWO(1); // COMPLIANT - macro generating the cast is defined in a
                      // library, and is not modifiable by the user
  LIBRARY_NESTED_ADD_TWO(1); // COMPLIANT - macro generating the cast is defined
                             // in a library, and is not modifiable by the user
  NO_CAST_ADD_ONE((int)1.0); // NON_COMPLIANT - cast in argument to macro
  LIBRARY_NO_CAST_ADD_TWO((int)1.0); // NON_COMPLIANT - library macro with
                                     // c-style cast in argument, written by
                                     // user so should be reported
}

class D {
public:
  D(int x) : fx(x), fy(0) {}
  D(int x, int y) : fx(x), fy(y) {}

private:
  int fx;
  int fy;
};

D testNonFunctionalCast() {
  return (D)1; // NON_COMPLIANT[FALSE_NEGATIVE]
}

D testFunctionalCast() {
  return D(1); // COMPLIANT
}

D testFunctionalCastMulti() {
  return D(1, 2); // COMPLIANT
}

template <typename T> T testFunctionalCastTemplate() {
  return T(1); // COMPLIANT[FALSE_POSITIVE]
}

template <typename T> T testFunctionalCastTemplateMulti() {
  return T(1, 2); // COMPLIANT
}

void testFunctionalCastTemplateUse() {
  testFunctionalCastTemplate<D>();
  testFunctionalCastTemplate<int>();
  testFunctionalCastTemplateMulti<D>();
}

template <typename T> class E {
public:
  class F {
  public:
    F(int x) : fx(x), fy(0) {}
    F(int x, int y) : fx(x), fy(y) {}

  private:
    int fx;
    int fy;
  };

  F f() {
    return F(1); // COMPLIANT
  }

  D d() {
    return D(1); // COMPLIANT
  }

  int i() {
    double f = 3.14;
    return (unsigned int)f; // NON_COMPLIANT
  }
};

class G {};

void testE() {
  E<G> e;
  e.f();
  e.d();
  e.i();
}
