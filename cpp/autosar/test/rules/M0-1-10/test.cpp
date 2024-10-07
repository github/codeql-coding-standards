bool f1();          // IGNORED - we only consider functions with a definition
void f2() {}        // COMPLIANT - called by main,f3
void f3() { f2(); } // COMPLIANT - called by main
void f4() {}        // NON_COMPLIANT - never called
void f5() {}        // COMPLIANT - address taken in main, and function called
int f6() {
  return 10;
} // COMPLIANT - used in global variable initializer for `x`
int f7();                           // COMPLIANT - called in g2 lambda in main
int f8();                           // COMPLIANT - called in l2 intializer
void f9(void (*g5)()) { g5(); }     // COMPLIANT - used in main
template <class T> void f10(T t) {} // COMPLIANT - used in main
template <class T> void f11(T t) {} // NON_COMPLIANT - never instantiated
void f12() {} // NON_COMPLIANT - only called from unused function cycle
void f14();   // Declaration only, definition below
void f13() {  // NON_COMPLIANT - participates in unused function cycle
  if (f1()) {
    f14();
  } else {
    f12();
  }
}
void f14() { f13(); } // NON_COMPLIANT - participates in unused function cycle

int x = f6(); // entry point

class A {
public:
  virtual void h1() = 0; // COMPLIANT - h1() called directly
  virtual void h2() = 0; // NON_COMPLIANT - h2() is never called itself
  void h3(){};           // NON_COMPLIANT
  virtual void h4(){};   // NON_COMPLIANT
};

class B : public A {
public:
  virtual void h1(){}; // COMPLIANT - A.h1() is called on a B instance
  virtual void h2(){}; // COMPLIANT - B.h2() is called directly
};

template <class T> class C {
public:
  T getAT() { // COMPLIANT - used in main for C<B>
    T t;
    return t;
  }

  void i1(T t) {}         // COMPLIANT - used in main for C<S>
  void i2(T t) {}         // NON_COMPLIANT - never used in any instantiation
  T i3(T t) { return t; } // NON_COMPLIANT - never used in any instantiation
  void i4() {}            // NON_COMPLIANT - never used in any instantiation
  inline void i5() {}     // NON_COMPLIANT - never used in any instantiation
};

#include "test.hpp"
#include <type_traits>

template <typename T1, typename T2>
constexpr bool aConstExprFunc() noexcept { // COMPLIANT
  static_assert(std::is_trivially_copy_constructible<T1>() &&
                    std::is_trivially_copy_constructible<T2>(),
                "assert");
  return true;
}

template <typename T, int val> class AClass { T anArr[val]; };

void aCalledFunc1() // COMPLIANT
{
  struct ANestedClass {
    ANestedClass() noexcept(false) { // COMPLIANT: False Positive!
      static_cast<void>(0);
    }
  };
  static_assert(std::is_trivially_copy_constructible<AClass<ANestedClass, 5>>(),
                "Must be trivially copy constructible");
}

void anUnusedFunction() // NON_COMPLIANT
{
  struct AnotherNestedClass {
    AnotherNestedClass() noexcept(false) { // NON_COMPLAINT
      static_cast<void>(0);
    }
  };
  AnotherNestedClass d;
}

void aCalledFunc2() // COMPLIANT
{
  struct YetAnotherNestedClass {
    YetAnotherNestedClass() noexcept(false) {
      static_cast<void>(0);
    } // COMPLIANT
  };
  YetAnotherNestedClass d;
};

int main() { // COMPLIANT - this is a main like function which acts as an entry
             // point
  f3();
  void (*g1)() = &f5;
  g1();
  auto g2 = [](auto a) { // COMPLIANT - used below
    f7();
    return a;
  };
  int l1 = g2(1);
  int l2 = f8();

  struct S {
    static void g3() {} // COMPLIANT - used below
    static void g4() {} // NON_COMPLIANT
  };

  S::g3();

  auto g5 = []() {}; // COMPLIANT - used in f9
  f9(g5); // NOTE: we do not currently track whether lambdas get used, just
          // whether the enclosing type is used

  B b1;
  f10(b1);

  B *b = new B();
  b->h2();
  A *a = b;
  a->h1();

  C<B> c1;
  C<S> c2;
  c1.getAT();
  S s;
  c2.i1(s);

  int aVar;
  aConstExprFunc<decltype(aCalledFuncInHeader(aVar)), int>();
  aCalledFunc1();
  aCalledFunc2();
}
class M {
public:
  M(const M &) = delete; // COMPLIANT - ignore if deleted
};

#include <gtest/gtest.h>
int called_from_google_test_function(
    int a_param) // COMPLIANT - called from TEST
{
  int something = a_param;
  something++;
  return something;
}

TEST(
    sample_test,
    called_from_google_test_function) // COMPLIANT - False positive!
                                      // ~sample_test_called_from_google_test_function_Test
{
  bool pass = false;
  if (called_from_google_test_function(0) >= 10)
    pass = true;
}
