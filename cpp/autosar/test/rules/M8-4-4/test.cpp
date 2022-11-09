#include <string>

struct S {
  void g() {}
  static void h() {}
};

void f();

void test_function_identifier_f1() {
  void (*pf)() = f;        // NON_COMPLIANT
  pf = &f;                 // COMPLIANT by exception
  void (S::*pg)() = &S::g; // COMPLIANT
  void (*ph)() = S::h;     // NON_COMPLIANT
  ph = &S::h;              // COMPLIANT
}

void test_function_identifier_f2() {
  if (f == 0) { // NON_COMPLIANT
  }
  if (&f == 0) { // NON_COMPLIANT
  }
  (f)(); // COMPLIANT
}

template <typename F> static void Log(const F kF) {}

template <typename... As> static void LogFatal(const As &...rest) {
  Log([](const std::string &s) -> void {}); // COMPLIANT
}

void l1() {
  int a;
  LogFatal(a);
}