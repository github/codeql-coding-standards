#include <cstdint>
#include <string>
#include <utility>
int foo() { return 1; }

void test_c_style_cast() {
  double f = 3.14;
  std::uint32_t n1 = (std::uint32_t)f; // NON_COMPLIANT - C-style cast
  std::uint32_t n2 = unsigned(f);      // NON_COMPLIANT - functional cast

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